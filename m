From: Florian Westphal <fw@strlen.de>
Subject: [PATCH V2 1/2] net: add and use skb_gso_transport_seglen()
Date: Sun, 26 Jan 2014 10:58:16 +0100
Message-ID: <1390730297-10725-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34157 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111AbaAZKBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 05:01:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
skbuff core so it may be reused by upcoming ip forwarding path patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since V1:
 suggestions from Eric Dumazet:
  - don't use uapi udp.h
  - remove tcp.h include from tbf, its not needed anymore

 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 25 +++++++++++++++++++++++++
 net/sched/sch_tbf.c    | 13 +++----------
 3 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6f69b3f..3d76066 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2371,6 +2371,7 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
 int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
 void skb_scrub_packet(struct sk_buff *skb, bool xnet);
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 
 struct skb_checksum_ops {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 06e72d3..ce04da0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -47,6 +47,8 @@
 #include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
 #include <linux/netdevice.h>
 #ifdef CONFIG_NET_CLS_ACT
 #include <net/pkt_sched.h>
@@ -3592,3 +3594,26 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	nf_reset_trace(skb);
 }
 EXPORT_SYMBOL_GPL(skb_scrub_packet);
+
+/**
+ * skb_gso_transport_seglen - Return length of individual segments of a gso packet
+ *
+ * @skb: GSO skb
+ *
+ * skb_gso_transport_seglen is used to determine the real size of the
+ * individual segments, including Layer4 headers (TCP/UDP).
+ *
+ * The MAC/L2 or network (IP, IPv6) headers are not accounted for.
+ */
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
+{
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+	unsigned int hdr_len;
+
+	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+		hdr_len = tcp_hdrlen(skb);
+	else
+		hdr_len = sizeof(struct udphdr);
+	return hdr_len + shinfo->gso_size;
+}
+EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 887e672..758c356 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -21,7 +21,6 @@
 #include <net/netlink.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
-#include <net/tcp.h>
 
 
 /*	Simple Token Bucket Filter.
@@ -148,16 +147,10 @@ static u64 psched_ns_t2l(const struct psched_ratecfg *r,
  * Return length of individual segments of a gso packet,
  * including all headers (MAC, IP, TCP/UDP)
  */
-static unsigned int skb_gso_seglen(const struct sk_buff *skb)
+static unsigned int skb_gso_mac_seglen(const struct sk_buff *skb)
 {
 	unsigned int hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
-	const struct skb_shared_info *shinfo = skb_shinfo(skb);
-
-	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
-		hdr_len += tcp_hdrlen(skb);
-	else
-		hdr_len += sizeof(struct udphdr);
-	return hdr_len + shinfo->gso_size;
+	return hdr_len + skb_gso_transport_seglen(skb);
 }
 
 /* GSO packet is too big, segment it so that tbf can transmit
@@ -202,7 +195,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
-		if (skb_is_gso(skb) && skb_gso_seglen(skb) <= q->max_size)
+		if (skb_is_gso(skb) && skb_gso_mac_seglen(skb) <= q->max_size)
 			return tbf_segment(skb, sch);
 		return qdisc_reshape_fail(skb, sch);
 	}
-- 
1.8.1.5
