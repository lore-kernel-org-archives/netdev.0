From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v6 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Thu, 13 Feb 2014 23:09:12 +0100
Message-ID: <1392329352-31606-2-git-send-email-fw@strlen.de>
References: <1392329352-31606-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45311 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751199AbaBMWNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:13:06 -0500
In-Reply-To: <1392329352-31606-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcelo Ricardo Leitner reported problems when the forwarding link path
has a lower mtu than the incoming one if the inbound interface supports GRO.

Given:
Host <mtu1500> R1 <mtu1200> R2

Host sends tcp stream which is routed via R1 and R2.  R1 performs GRO.

In this case, the kernel will fail to send ICMP fragmentation needed
messages (or pkt too big for ipv6), as GSO packets currently bypass dstmtu
checks in forward path. Instead, Linux tries to send out packets exceeding
the mtu.

When locking route MTU on Host (i.e., no ipv4 DF bit set), R1 does
not fragment the packets when forwarding, and again tries to send out
packets exceeding R1-R2 link mtu.

This alters the forwarding dstmtu checks to take the individual gso
segment lengths into account.

For ipv6, we send out pkt too big error for gso if the individual
segments are too big.

For ipv4, we either send icmp fragmentation needed, or, if the DF bit
is not set, perform software segmentation and let the output path
create fragments when the packet is leaving the machine.
It is not 100% correct as the error message will contain the headers of
the GRO skb instead of the original/segmented one, but it seems to
work fine in my (limited) tests.

Eric Dumazet suggested to simply shrink mss via ->gso_size to avoid
sofware segmentation.

However it turns out that skb_segment() assumes skb nr_frags is related
to mss size so we would BUG there.  I don't want to mess with it considering
Herbert and Eric disagree on what the correct behavior should be.

Hannes Frederic Sowa notes that when we would shrink gso_size
skb_segment would then also need to deal with the case where
SKB_MAX_FRAGS would be exceeded.

This uses sofware segmentation in the forward path when we hit ipv4
non-DF packets and the outgoing link mtu is too small.  Its not perfect,
but given the lack of bug reports wrt. GRO fwd being broken this is a
rare case anyway.  Also its not like this could not be improved later
once the dust settles.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
Changes since v5; propagated Herberts Ack from v5 to changelog.
[ resend is due to error in earlier patch in series ]

Changes since V4:
 - use new netif_skb_dev_features instead of netif_skb_features
   as we need dst->dev and not skb->dev (spotted by
   Hannes Frederic Sowa)

Changes since V3:
 - use ip_dst_mtu_maybe_forward instead of dst_mtu
 - add comment wrt. DF bit not being set

Changes since V2:
 - make this thing apply to current -net tree
 - kill unused variables in ip_forward/ip6_output

Changes since V1:
 suggestions from Eric Dumazet:
  - skip more expensive computation for small packets in fwd path
  - use netif_skb_features() feature mask and remove GSO flags
    instead of using 0 feature set.

 include/linux/skbuff.h | 17 ++++++++++++
 net/ipv4/ip_forward.c  | 71 ++++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6_output.c  | 17 ++++++++++--
 3 files changed, 101 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f589c9a..3ebbbe7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2916,5 +2916,22 @@ static inline bool skb_head_is_locked(const struct sk_buff *skb)
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
index e9f1217..f3869c1 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -39,6 +39,71 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 
+static bool ip_may_fragment(const struct sk_buff *skb)
+{
+	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0) ||
+	       !skb->local_df;
+}
+
+static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
+{
+	if (skb->len <= mtu || skb->local_df)
+		return false;
+
+	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+		return false;
+
+	return true;
+}
+
+static bool ip_gso_exceeds_dst_mtu(const struct sk_buff *skb)
+{
+	unsigned int mtu;
+
+	if (skb->local_df || !skb_is_gso(skb))
+		return false;
+
+	mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
+
+	/* if seglen > mtu, do software segmentation for IP fragmentation on
+	 * output.  DF bit cannot be set since ip_forward would have sent
+	 * icmp error.
+	 */
+	return skb_gso_network_seglen(skb) > mtu;
+}
+
+/* called if GSO skb needs to be fragmented on forward */
+static int ip_forward_finish_gso(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	netdev_features_t features;
+	struct sk_buff *segs;
+	int ret = 0;
+
+	features = netif_skb_dev_features(skb, dst->dev);
+	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
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
@@ -49,6 +114,9 @@ static int ip_forward_finish(struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
+	if (ip_gso_exceeds_dst_mtu(skb))
+		return ip_forward_finish_gso(skb);
+
 	return dst_output(skb);
 }
 
@@ -91,8 +159,7 @@ int ip_forward(struct sk_buff *skb)
 
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
-	if (unlikely(skb->len > mtu && !skb_is_gso(skb) &&
-		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
+	if (!ip_may_fragment(skb) && ip_exceeds_mtu(skb, mtu)) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ef02b26..070a2fa 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -342,6 +342,20 @@ static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
 	return mtu;
 }
 
+static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
+{
+	if (skb->len <= mtu || skb->local_df)
+		return false;
+
+	if (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)
+		return true;
+
+	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+		return false;
+
+	return true;
+}
+
 int ip6_forward(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -466,8 +480,7 @@ int ip6_forward(struct sk_buff *skb)
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
