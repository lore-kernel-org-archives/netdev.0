From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 3.12.y 1/3] net: add and use skb_gso_transport_seglen()
Date: Sat, 22 Feb 2014 10:28:29 +0100
Message-ID: <1393061311-4723-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44014 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751163AbaBVJcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:32:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit de960aa9ab4decc3304959f69533eef64d05d8e8 upstream.

This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
skbuff core so it may be reused by upcoming ip forwarding path patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 25 +++++++++++++++++++++++++
 net/sched/sch_tbf.c    | 13 +++----------
 3 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index efa1649..2bbc892 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2393,6 +2393,8 @@ extern void	       skb_scrub_packet(struct sk_buff *skb, bool xnet);
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
 
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2c7baa8..21571dc 100644
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
@@ -3519,3 +3521,26 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
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
index 6ddda28..fecd35a 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -21,7 +21,6 @@
 #include <net/netlink.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
-#include <net/tcp.h>
 
 
 /*	Simple Token Bucket Filter.
@@ -122,16 +121,10 @@ struct tbf_sched_data {
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
@@ -176,7 +169,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
-		if (skb_is_gso(skb) && skb_gso_seglen(skb) <= q->max_size)
+		if (skb_is_gso(skb) && skb_gso_mac_seglen(skb) <= q->max_size)
 			return tbf_segment(skb, sch);
 		return qdisc_reshape_fail(skb, sch);
 	}
-- 
1.8.1.5
