From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_choke: use skb_flow_dissect()
Date: Tue, 29 Nov 2011 15:22:15 +0100
Message-ID: <1322576535.2465.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50785 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab1K2OWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 09:22:18 -0500
Received: by qyk4 with SMTP id 4so1599655qyk.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 06:22:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a custom flow dissector, use skb_flow_dissect() and
benefit from tunnelling support.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_choke.c |  120 ++++++++++------------------------------
 1 file changed, 31 insertions(+), 89 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 061bcb7..205d369 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -19,10 +19,7 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
-#include <linux/ip.h>
-#include <net/ip.h>
-#include <linux/ipv6.h>
-#include <net/ipv6.h>
+#include <net/flow_keys.h>
 
 /*
    CHOKe stateless AQM for fair bandwidth allocation
@@ -142,92 +139,10 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	--sch->q.qlen;
 }
 
-/*
- * Compare flow of two packets
- *  Returns true only if source and destination address and port match.
- *          false for special cases
- */
-static bool choke_match_flow(struct sk_buff *skb1,
-			     struct sk_buff *skb2)
-{
-	int off1, off2, poff;
-	const u32 *ports1, *ports2;
-	u32 _ports1, _ports2;
-	u8 ip_proto;
-	__u32 hash1;
-
-	if (skb1->protocol != skb2->protocol)
-		return false;
-
-	/* Use rxhash value as quick check */
-	hash1 = skb_get_rxhash(skb1);
-	if (!hash1 || hash1 != skb_get_rxhash(skb2))
-		return false;
-
-	/* Probably match, but be sure to avoid hash collisions */
-	off1 = skb_network_offset(skb1);
-	off2 = skb_network_offset(skb2);
-
-	switch (skb1->protocol) {
-	case __constant_htons(ETH_P_IP): {
-		const struct iphdr *ip1, *ip2;
-		struct iphdr _ip1, _ip2;
-
-		ip1 = skb_header_pointer(skb1, off1, sizeof(_ip1), &_ip1);
-		ip2 = skb_header_pointer(skb2, off2, sizeof(_ip2), &_ip2);
-		if (!ip1 || !ip2)
-			return false;
-		ip_proto = ip1->protocol;
-		if (ip_proto != ip2->protocol ||
-		    ip1->saddr != ip2->saddr || ip1->daddr != ip2->daddr)
-			return false;
-
-		if (ip_is_fragment(ip1) | ip_is_fragment(ip2))
-			ip_proto = 0;
-		off1 += ip1->ihl * 4;
-		off2 += ip2->ihl * 4;
-		break;
-	}
-
-	case __constant_htons(ETH_P_IPV6): {
-		const struct ipv6hdr *ip1, *ip2;
-		struct ipv6hdr _ip1, _ip2;
-
-		ip1 = skb_header_pointer(skb1, off1, sizeof(_ip1), &_ip1);
-		ip2 = skb_header_pointer(skb2, off2, sizeof(_ip2), &_ip2);
-		if (!ip1 || !ip2)
-			return false;
-
-		ip_proto = ip1->nexthdr;
-		if (ip_proto != ip2->nexthdr ||
-		    ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) ||
-		    ipv6_addr_cmp(&ip1->daddr, &ip2->daddr))
-			return false;
-		off1 += 40;
-		off2 += 40;
-	}
-
-	default: /* Maybe compare MAC header here? */
-		return false;
-	}
-
-	poff = proto_ports_offset(ip_proto);
-	if (poff < 0)
-		return true;
-
-	off1 += poff;
-	off2 += poff;
-
-	ports1 = skb_header_pointer(skb1, off1, sizeof(_ports1), &_ports1);
-	ports2 = skb_header_pointer(skb2, off2, sizeof(_ports2), &_ports2);
-	if (!ports1 || !ports2)
-		return false;
-
-	return *ports1 == *ports2;
-}
-
 struct choke_skb_cb {
-	u16 classid;
+	u16			classid;
+	u8			keys_valid;
+	struct flow_keys	keys;
 };
 
 static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
@@ -248,6 +163,32 @@ static u16 choke_get_classid(const struct sk_buff *skb)
 }
 
 /*
+ * Compare flow of two packets
+ *  Returns true only if source and destination address and port match.
+ *          false for special cases
+ */
+static bool choke_match_flow(struct sk_buff *skb1,
+			     struct sk_buff *skb2)
+{
+	if (skb1->protocol != skb2->protocol)
+		return false;
+
+	if (!choke_skb_cb(skb1)->keys_valid) {
+		choke_skb_cb(skb1)->keys_valid = 1;
+		skb_flow_dissect(skb1, &choke_skb_cb(skb1)->keys);
+	}
+
+	if (!choke_skb_cb(skb2)->keys_valid) {
+		choke_skb_cb(skb2)->keys_valid = 1;
+		skb_flow_dissect(skb2, &choke_skb_cb(skb2)->keys);
+	}
+
+	return !memcmp(&choke_skb_cb(skb1)->keys,
+		       &choke_skb_cb(skb2)->keys,
+		       sizeof(struct flow_keys));
+}
+
+/*
  * Classify flow using either:
  *  1. pre-existing classification result in skb
  *  2. fast internal classification
@@ -333,6 +274,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			goto other_drop;	/* Packet was eaten by filter */
 	}
 
+	choke_skb_cb(skb)->keys_valid = 0;
 	/* Compute average queue usage (see RED) */
 	p->qavg = red_calc_qavg(p, sch->q.qlen);
 	if (red_is_idling(p))
