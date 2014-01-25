From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Sat, 25 Jan 2014 23:48:47 +0100
Message-ID: <1390690127-559-3-git-send-email-fw@strlen.de>
References: <1390690127-559-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33746 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752413AbaAYWxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 17:53:11 -0500
In-Reply-To: <1390690127-559-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given:
Host <mtu1500> R1 <mtu1200> R2

Host sends tcp stream which is routed via R1 and R2.
R1 nics perform GRO.

In this case, the kernel will fail to send ICMP fragmentation needed
messages (or pkt too big for ipv6), as gso packets currently bypass the
dst mtu checks in forward path. Instead, Linux tries to send out packets
exceeding R1-R2 link mtu.

When locking route MTU on Host (i.e., no ipv4 DF bit set), R1 does
not fragment the packets when forwarding, and again tries to send out
packets exceeding R1-R2 link mtu.

This alters the forwarding dstmtu checks to take the individual gso
segment lengths into account.

For ipv6, we send out pkt too big error for gso if the individual
segments are too big.

For ipv4, we either send icmp fragmentation needed, or, if the DF bit
is not set, perform software segmentation and let the output path
create fragments when the packet is leaving the machine.  This is
technically not 100% accurate, as the error message will contain the
gro-skb tcp header (we'd have to segment unconditionally and use first
segment instead), but it does seem to work.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h | 17 +++++++++++++++
 net/ipv4/ip_forward.c  | 58 ++++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6_output.c  | 18 ++++++++++++++--
 3 files changed, 89 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3d76066..37cb679 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2811,5 +2811,22 @@ static inline bool skb_head_is_locked(const struct sk_buff *skb)
 {
 	return !skb->head_frag || skb_cloned(skb);
 }
+
+/**
+ * skb_gso_network_seglen - Return length of individual segments of a gso packet
+ *
+ * @skb: GSO skb
+ *
+ * skb_gso_network_seglen is used to determine the real size of the
+ * individual segments, including Layer3 (IP, IPv6) and L4 headers (TCP/UDP).
+ *
+ * The MAC/L2 header is not accounted for.
+ */
+static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
+{
+	unsigned int hdr_len = skb_transport_header(skb) -
+			       skb_network_header(skb);
+	return hdr_len + skb_gso_transport_seglen(skb);
+}
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 694de3b..78f2e2a 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -39,6 +39,58 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 
+static bool ip_may_fragment(const struct sk_buff *skb)
+{
+	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0) ||
+	       !skb->local_df;
+}
+
+static bool ip_gso_exceeds_dst_mtu(const struct sk_buff *skb)
+{
+	if (skb->local_df || !skb_is_gso(skb))
+		return false;
+	return skb_gso_network_seglen(skb) > dst_mtu(skb_dst(skb));
+}
+
+static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
+{
+	unsigned len;
+
+	if (skb->local_df)
+		return false;
+	len = skb_is_gso(skb) ? skb_gso_network_seglen(skb) : skb->len;
+
+	return len > mtu;
+}
+
+/* called if GSO skb needs to be fragmented on forward.  */
+static int ip_forward_finish_gso(struct sk_buff *skb)
+{
+	struct sk_buff *segs = skb_gso_segment(skb, 0);
+	int ret = 0;
+
+	if (IS_ERR(segs)) {
+		kfree_skb(skb);
+		return -ENOMEM;
+	}
+
+	consume_skb(skb);
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int err;
+
+		segs->next = NULL;
+		err = dst_output(segs);
+
+		if (err && ret == 0)
+			ret = err;
+		segs = nskb;
+	} while (segs);
+
+	return ret;
+}
+
 static int ip_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options *opt	= &(IPCB(skb)->opt);
@@ -49,6 +101,9 @@ static int ip_forward_finish(struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
+	if (ip_gso_exceeds_dst_mtu(skb))
+		return ip_forward_finish_gso(skb);
+
 	return dst_output(skb);
 }
 
@@ -88,8 +143,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
+	if (!ip_may_fragment(skb) && ip_exceeds_mtu(skb, dst_mtu(&rt->dst))) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->dst)));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e6f9319..e1a5aec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -321,6 +321,21 @@ static inline int ip6_forward_finish(struct sk_buff *skb)
 	return dst_output(skb);
 }
 
+static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
+{
+	unsigned int len;
+
+	if (skb->local_df)
+		return false;
+
+	if (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)
+		return true;
+
+	len = skb_is_gso(skb) ? skb_gso_network_seglen(skb) : skb->len;
+
+	return len > mtu;
+}
+
 int ip6_forward(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -443,8 +458,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-	if ((!skb->local_df && skb->len > mtu && !skb_is_gso(skb)) ||
-	    (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
+	if (ip6_pkt_too_big(skb, mtu)) {
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-- 
1.8.1.5
