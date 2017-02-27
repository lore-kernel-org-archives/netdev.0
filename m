From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: bridge: allow IPv6 when multicast flood is disabled
Date: Mon, 27 Feb 2017 17:11:29 +0000
Message-ID: <1488215489-26372-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:44804 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751471AbdB0SLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:11:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with multicast flooding turned off, IPv6 ND should still work so
that IPv6 connectivity is provided. Allow this by continuing to flood
multicast traffic originated by us. And similar to the unicast case,
set auto-mask if the multicast flood flag is set.

Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 include/linux/if_bridge.h | 2 +-
 net/bridge/br_forward.c   | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index c5847dc..7731808 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -40,12 +40,12 @@ struct br_ip_list {
 #define BR_ADMIN_COST		BIT(4)
 #define BR_LEARNING		BIT(5)
 #define BR_FLOOD		BIT(6)
-#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING)
 #define BR_PROMISC		BIT(7)
 #define BR_PROXYARP		BIT(8)
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 #define BR_MCAST_FLOOD		BIT(11)
+#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING | BR_MCAST_FLOOD)
 #define BR_MULTICAST_TO_UNICAST	BIT(12)
 #define BR_VLAN_TUNNEL		BIT(13)
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6bfac29..7fe7d58 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -186,8 +186,9 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
 			continue;
+		/* Do not flood if mc off, except for traffic we originate */
 		if (pkt_type == BR_PKT_MULTICAST &&
-		    !(p->flags & BR_MCAST_FLOOD))
+		    !(p->flags & BR_MCAST_FLOOD) && (skb->dev != br->dev))
 			continue;
 
 		/* Do not flood to ports that enable proxy ARP */
-- 
2.1.4
