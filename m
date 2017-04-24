From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: bridge: suppress broadcast when multicast flood is disabled
Date: Mon, 24 Apr 2017 15:09:04 +0100
Message-ID: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:57280 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1171115AbdDXOJ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:09:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flood suppression for packets that are not unicast needs to be handled
consistently by also not flooding broadcast packets. As broadcast is a
special case of multicast, the same kernel parameter should be used to
suppress flooding for both of these packet types.

Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/bridge/br_forward.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 902af6b..a61c7ad 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -183,13 +183,16 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	struct net_bridge_port *p;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
-		/* Do not flood unicast traffic to ports that turn it off */
-		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
-			continue;
-		/* Do not flood if mc off, except for traffic we originate */
-		if (pkt_type == BR_PKT_MULTICAST &&
-		    !(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
-			continue;
+		/* Do not flood unicast traffic to ports that turn it off, nor
+		 * other traffic if mc flood off except for traffic we originate
+		 */
+		if (pkt_type == BR_PKT_UNICAST) {
+			if (!(p->flags & BR_FLOOD))
+				continue;
+		} else {
+			if (!(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
+				continue;
+		}
 
 		/* Do not flood to ports that enable proxy ARP */
 		if (p->flags & BR_PROXYARP)
-- 
2.1.4
