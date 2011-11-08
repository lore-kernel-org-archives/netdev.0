From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_choke: use skb_header_pointer()
Date: Tue, 08 Nov 2011 21:45:04 +0100
Message-ID: <1320785104.26025.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42454 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933278Ab1KHUpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 15:45:08 -0500
Received: by wyh15 with SMTP id 15so935917wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 12:45:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the assumption that skb_get_rxhash() makes IP header and ports
linear, and use skb_header_pointer() instead in choke_match_flow()

This permits __skb_get_rxhash() to use skb_header_pointer() eventually.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_choke.c |   27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 3422b25..061bcb7 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -152,15 +152,14 @@ static bool choke_match_flow(struct sk_buff *skb1,
 {
 	int off1, off2, poff;
 	const u32 *ports1, *ports2;
+	u32 _ports1, _ports2;
 	u8 ip_proto;
 	__u32 hash1;
 
 	if (skb1->protocol != skb2->protocol)
 		return false;
 
-	/* Use hash value as quick check
-	 * Assumes that __skb_get_rxhash makes IP header and ports linear
-	 */
+	/* Use rxhash value as quick check */
 	hash1 = skb_get_rxhash(skb1);
 	if (!hash1 || hash1 != skb_get_rxhash(skb2))
 		return false;
@@ -172,10 +171,12 @@ static bool choke_match_flow(struct sk_buff *skb1,
 	switch (skb1->protocol) {
 	case __constant_htons(ETH_P_IP): {
 		const struct iphdr *ip1, *ip2;
+		struct iphdr _ip1, _ip2;
 
-		ip1 = (const struct iphdr *) (skb1->data + off1);
-		ip2 = (const struct iphdr *) (skb2->data + off2);
-
+		ip1 = skb_header_pointer(skb1, off1, sizeof(_ip1), &_ip1);
+		ip2 = skb_header_pointer(skb2, off2, sizeof(_ip2), &_ip2);
+		if (!ip1 || !ip2)
+			return false;
 		ip_proto = ip1->protocol;
 		if (ip_proto != ip2->protocol ||
 		    ip1->saddr != ip2->saddr || ip1->daddr != ip2->daddr)
@@ -190,9 +191,12 @@ static bool choke_match_flow(struct sk_buff *skb1,
 
 	case __constant_htons(ETH_P_IPV6): {
 		const struct ipv6hdr *ip1, *ip2;
+		struct ipv6hdr _ip1, _ip2;
 
-		ip1 = (const struct ipv6hdr *) (skb1->data + off1);
-		ip2 = (const struct ipv6hdr *) (skb2->data + off2);
+		ip1 = skb_header_pointer(skb1, off1, sizeof(_ip1), &_ip1);
+		ip2 = skb_header_pointer(skb2, off2, sizeof(_ip2), &_ip2);
+		if (!ip1 || !ip2)
+			return false;
 
 		ip_proto = ip1->nexthdr;
 		if (ip_proto != ip2->nexthdr ||
@@ -214,8 +218,11 @@ static bool choke_match_flow(struct sk_buff *skb1,
 	off1 += poff;
 	off2 += poff;
 
-	ports1 = (__force u32 *)(skb1->data + off1);
-	ports2 = (__force u32 *)(skb2->data + off2);
+	ports1 = skb_header_pointer(skb1, off1, sizeof(_ports1), &_ports1);
+	ports2 = skb_header_pointer(skb2, off2, sizeof(_ports2), &_ports2);
+	if (!ports1 || !ports2)
+		return false;
+
 	return *ports1 == *ports2;
 }
 
