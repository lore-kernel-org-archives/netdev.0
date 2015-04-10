From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] net: add netfilter ingress hook
Date: Fri, 10 Apr 2015 22:33:12 +0100
Message-ID: <20150410213312.GA23727@acer.localdomain>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-6-git-send-email-pablo@netfilter.org>
 <20150410132120.GE23070@casper.infradead.org>
 <20150410133610.GA19454@acer.localdomain>
 <20150410201719.GC5968@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150410201719.GC5968@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.04, Pablo Neira Ayuso wrote:
> On Fri, Apr 10, 2015 at 02:36:11PM +0100, Patrick McHardy wrote:
> > 
> > I'm wondering if the hook is the right abstraction at all. Netfilter hooks
> > require async resumption (okfn) support, which is why all the refactoring is
> > needed. Is that something that we need for NF_PROTO_NETDEV? For ingress
> > userspace queueing *might* actually work if the missing pieces are added,
> > but for offloaded rules it obviously can not work.
> 
> For userspace queueing from ingress we still have to call
> skb_share_check() and hold a reference to orig_dev from the escape
> path. But this support is still missing in nf_tables (actually, we
> only support NFPROTO_IPV4 and NFPROTO_IPV6 at this moment, see patch
> attached). Regarding offload, this path will not see any packet.

We do support all families using the regular NF_QUEUE verdict of course.
But yes, nf_queue.c will simply drop packets that don't have a netfilter
AF registered.

But my question is whether queueing is something that is even worth
considering for the NFPROTO_NETDEV family. As I said, it will at best
work for ingress anyways and that will actually be more tricky than just
calling skb_share_check(), we need to take care of keeping valid
references to all the data you currently store in the CB, including the
packet_type, the device, things attached to the skb at this point to
the stack etc.

If we decide not to support queueing for this family we don't have to
use netfilter hooks for this and all the refactoring for async resume
becomes unnecessary. 

> >From db2fba74dea98b69ee7615fca86b9847bc42887f Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Fri, 10 Apr 2015 21:40:58 +0200
> Subject: [PATCH] netfilter: nf_tables: restrict nft_queue to AF_INET and
>  AF_INET6
> 
> Other families need the corresponding struct nf_afinfo in place to work.
> Restrict it to NFPROTO_IPV4 and NFPROTO_IPV6 until the necessary code is in
> place.
