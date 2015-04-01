From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 02/14] net: untangle ip_fragment and bridge netfilter
Date: Wed,  1 Apr 2015 22:36:28 +0200
Message-ID: <1427920600-20366-3-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42838 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752570AbbDAUgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:55 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Long time ago it was possible for the netfilter ip_conntrack
core to call ip_fragment in POST_ROUTING hook.

This is no longer the case, so the only case where bridge netfilter
ends up calling ip_fragment is the direct call site in br_netfilter.c.

Add mtu arguments to ip_fragment and remove the bridge netfilter mtu helper.

bridge netfilter uses following MTU choice strategy:

A - frag_max_size is set:
   We're looking at skb where at least one fragment had the DF bit set.
   Use frag_max_size as the MTU to re-create the original fragments as
   close as possible.

   If this would bring us over the MTU, silently drop the skb.
   (This can happen with bridge where not all devices have same MTU,
    but its difficult to imagine such setup that doesn't already have
    worse problems)

B - frag_max_size not set.
    This means original packet did not have DF bit set,
    just use the output device MTU for refragmentation.
    This is safe since any router in the path is free to re-fragment
    as needed.

C - skb too big and ignore_df not set.  Means the input device mtu is bigger
    than outdevice mtu.  Drop skb, setup should be fixed instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 I looked at various other alternatives for 'please undo defrag on this ipv4 packet'.
 But this is the most sensible thing to do.

 Keeping original fragments doesn't fly since we might have performed NAT
 or other manipluations on the (defragmented) skb.
 Building defrag/frag into GRO/GSO doesn't work either since the purpose
 of GRO is a lot different (we also can't rely on all fragments arriving
 in same napi context).

 Instead we refragment using size of largest fragment seen, or using
 the bridge device mtu.

 include/linux/netfilter_bridge.h |  7 -------
 include/net/ip.h                 |  4 ++--
 net/bridge/br_netfilter.c        | 40 +++++++++++++++++++++++++++++++++-------
 net/ipv4/ip_output.c             | 30 ++++++++++++++++++------------
 4 files changed, 53 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 2734977..b131613 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -23,13 +23,6 @@ enum nf_br_hook_priorities {
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
 
-static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
-{
-	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
-		return PPPOE_SES_HLEN;
-	return 0;
-}
-
 int br_handle_frame_finish(struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
diff --git a/include/net/ip.h b/include/net/ip.h
index d0808a3..1fe203a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -108,8 +108,8 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
-int ip_do_nat(struct sk_buff *skb);
+int ip_fragment(struct sk_buff *skb, unsigned int mtu,
+		int (*output)(struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 282ed76..c0c8700 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -837,30 +837,56 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 	return br_dev_queue_push_xmit(skb);
 }
 
+static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
+{
+	if (skb->nf_bridge->mask & BRNF_PPPoE)
+		return PPPOE_SES_HLEN;
+	return 0;
+}
+
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
 	int frag_max_size;
-	unsigned int mtu_reserved;
+	unsigned int mtu_reserved, mtu;
 
 	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
 		return br_dev_queue_push_xmit(skb);
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
+	mtu = min(skb->dev->mtu, IP_MAX_MTU) - mtu_reserved;
+
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
+	 *
+	 * However, the skb might have been subject to NAT.
+	 * We try to un-do the fragmentation, using largest received fragment
+	 * size as mtu if it is set.
 	 */
-	if (skb->len + mtu_reserved > skb->dev->mtu) {
+	if (skb->len > mtu) {
+		if (!skb->ignore_df) /* was not a defragmented */
+			goto err_out;
+
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
+		if (frag_max_size) {
+			if (frag_max_size > mtu) /* too big and DF set */
+				goto err_out;
+			mtu = frag_max_size;
+		}
+
 		if (br_parse_ip_options(skb))
-			/* Drop invalid packet */
-			return NF_DROP;
-		IPCB(skb)->frag_max_size = frag_max_size;
-		ret = ip_fragment(skb, br_nf_push_frag_xmit);
-	} else
+			goto err_out;
+
+		ret = ip_fragment(skb, mtu, br_nf_push_frag_xmit);
+	} else {
 		ret = br_dev_queue_push_xmit(skb);
+	}
 
 	return ret;
+ err_out:
+	IP_INC_STATS_BH(dev_net(skb->dev), IPSTATS_MIB_FRAGFAILS);
+	kfree_skb(skb);
+	return 0;
 }
 #else
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8259e77..9054995 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -216,6 +216,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	netdev_features_t features;
 	struct sk_buff *segs;
 	int ret = 0;
+	unsigned int mtu;
 
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
@@ -236,6 +237,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		return -ENOMEM;
 	}
 
+	mtu = ip_skb_dst_mtu(skb);
 	consume_skb(skb);
 
 	do {
@@ -243,7 +245,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, ip_finish_output2);
+		err = ip_fragment(segs, mtu, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -255,6 +257,8 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 
 static int ip_finish_output(struct sk_buff *skb)
 {
+	unsigned int mtu;
+
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm != NULL) {
@@ -265,8 +269,9 @@ static int ip_finish_output(struct sk_buff *skb)
 	if (skb_is_gso(skb))
 		return ip_finish_output_gso(skb);
 
-	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(skb, ip_finish_output2);
+	mtu = ip_skb_dst_mtu(skb);
+	if (skb->len > mtu)
+		return ip_fragment(skb, mtu, ip_finish_output2);
 
 	return ip_finish_output2(skb);
 }
@@ -473,20 +478,26 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-/*
+/**
+ *	ip_fragment - fragment IP datagram or send ICMP error
+ *
+ *	@skb: the skb to fragment
+ *	@mtu: mtu to use for fragmentation
+ *	@output: transmit function used to send fragments
+ *
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
  *	a block of the data of the original IP data part) that will yet fit in a
  *	single device frame, and queue such a frame for sending.
  */
-
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip_fragment(struct sk_buff *skb, unsigned int mtu,
+		int (*output)(struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs;
+	unsigned int hlen, left, len, ll_rs;
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
@@ -500,7 +511,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	iph = ip_hdr(skb);
 
-	mtu = ip_skb_dst_mtu(skb);
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
@@ -517,10 +527,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	hlen = iph->ihl * 4;
 	mtu = mtu - hlen;	/* Size of data space */
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge)
-		mtu -= nf_bridge_mtu_reduction(skb);
-#endif
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
-- 
2.0.5
