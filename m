From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/7] net: add netfilter ingress hook
Date: Fri, 10 Apr 2015 22:17:19 +0200
Message-ID: <20150410201719.GC5968@salvia>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-6-git-send-email-pablo@netfilter.org>
 <20150410132120.GE23070@casper.infradead.org>
 <20150410133610.GA19454@acer.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sm4nu43k4a2Rpi4c"
Cc: Thomas Graf <tgraf@suug.ch>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53944 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754828AbbDJUNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 16:13:10 -0400
Content-Disposition: inline
In-Reply-To: <20150410133610.GA19454@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Apr 10, 2015 at 02:36:11PM +0100, Patrick McHardy wrote:
> On 10.04, Thomas Graf wrote:
> > On 04/10/15 at 02:15pm, Pablo Neira Ayuso wrote:
> > >  static int __netif_receive_skb_ingress(struct sk_buff *skb, bool pfmemalloc,
> > >  				       struct net_device *orig_dev)
> > >  {
> > > @@ -3772,6 +3800,8 @@ skip_taps:
> > >  	if (!skb)
> > >  		return NET_RX_DROP;
> > >  #endif
> > > +	if (nf_hook_ingress_active(skb))
> > > +		return nf_hook_ingress(skb, pt_prev, orig_dev, pfmemalloc);
> > >  
> > >  	return __netif_receive_skb_finish(skb, pfmemalloc, pt_prev, orig_dev);
> > >  }
> > 
> > I would favour if we avoid for every subsystem to manage its ingress
> > filter pointers in net_device. From a net_device perspective, all it
> > takes is a single pointer which points to a single linked list of
> > filters which need to be run through. These entries could represent
> > an ingress qdisc or a netfilter chain or something else (L2 ingress
> > qdisc?).
> 
> I'm wondering if the hook is the right abstraction at all. Netfilter hooks
> require async resumption (okfn) support, which is why all the refactoring is
> needed. Is that something that we need for NF_PROTO_NETDEV? For ingress
> userspace queueing *might* actually work if the missing pieces are added,
> but for offloaded rules it obviously can not work.

For userspace queueing from ingress we still have to call
skb_share_check() and hold a reference to orig_dev from the escape
path. But this support is still missing in nf_tables (actually, we
only support NFPROTO_IPV4 and NFPROTO_IPV6 at this moment, see patch
attached). Regarding offload, this path will not see any packet.

--sm4nu43k4a2Rpi4c
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_tables-restrict-nft_queue-to-AF_INET-an.patch"

>From db2fba74dea98b69ee7615fca86b9847bc42887f Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 10 Apr 2015 21:40:58 +0200
Subject: [PATCH] netfilter: nf_tables: restrict nft_queue to AF_INET and
 AF_INET6

Other families need the corresponding struct nf_afinfo in place to work.
Restrict it to NFPROTO_IPV4 and NFPROTO_IPV6 until the necessary code is in
place.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_queue.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index e8ae2f6..42ca976 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -129,4 +129,5 @@ module_exit(nft_queue_module_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Eric Leblond <eric@regit.org>");
-MODULE_ALIAS_NFT_EXPR("queue");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET, "queue");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET6, "queue");
-- 
1.7.10.4


--sm4nu43k4a2Rpi4c--
