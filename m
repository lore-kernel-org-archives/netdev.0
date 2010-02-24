From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 4/5]IPv6:netfilter: Record MIB counter after
 a fragment reached
Date: Wed, 24 Feb 2010 14:08:41 +0800
Message-ID: <4B84C269.6010700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Shan Wei <shanwei@cn.fujitsu.com>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51177 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753968Ab0BXGIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 01:08:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch records MIB counter about fragments reassembly
after a fragment reached.

Note: 
For the lack of memory, if fails to clone skb, pull skb or create fragment queue,
then not to forward skb to IPv6 stack, and drop it, just like IPv4.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 9f50c13..32c5bbd 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -593,27 +593,31 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	u8 prevhdr;
 	struct sk_buff *ret_skb = NULL;
 	struct net *net = dev ? dev_net(dev) : dev_net(skb_dst(skb)->dev);
+	struct inet6_dev *idev;
 
+	idev = dev ? in6_dev_get(dev) : ip6_dst_idev(skb_dst(skb));
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len == 0) {
 		pr_debug("payload len = 0\n");
-		return skb;
+		goto out_nofrag;
 	}
 
 	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
-		return skb;
+		goto out_nofrag;
+
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMREQDS);
 
 	clone = skb_clone(skb, GFP_ATOMIC);
 	if (clone == NULL) {
 		pr_debug("Can't clone skb\n");
-		return skb;
+		goto out_drop_skb;
 	}
 
 	NFCT_FRAG6_CB(clone)->orig = skb;
 
 	if (!pskb_may_pull(clone, fhoff + sizeof(*fhdr))) {
 		pr_debug("message is too short.\n");
-		goto ret_orig;
+		goto out_drop_skb;
 	}
 
 	skb_set_transport_header(clone, fhoff);
@@ -623,6 +627,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	if (!(fhdr->frag_off & htons(0xFFF9))) {
 		pr_debug("Invalid fragment offset\n");
 		/* It is not a fragmented frame */
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMOKS);
 		goto ret_orig;
 	}
 
@@ -632,7 +637,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
 		pr_debug("Can't find and can't create new queue\n");
-		goto ret_orig;
+		goto out_drop_skb;
 	}
 
 	spin_lock(&fq->q.lock);
@@ -651,13 +656,23 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
 	spin_unlock(&fq->q.lock);
-
+	if (dev && idev)
+		in6_dev_put(idev);
 	fq_put(fq);
 	return ret_skb;
 
 ret_orig:
 	kfree_skb(clone);
+out_nofrag:
+	if (dev && idev)
+		in6_dev_put(idev);
 	return skb;
+out_drop_skb:
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMFAILS);
+	kfree_skb(clone);
+	kfree_skb(skb);
+	skb = NULL;
+	goto out_nofrag;
 }
 
 void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
-- 
1.6.3.3

