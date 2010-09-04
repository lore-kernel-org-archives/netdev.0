From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: rps: add the shortcut for one rps_cpus
Date: Sat,  4 Sep 2010 17:12:37 +0800
Message-ID: <1283591557-31921-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38073 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab0IDJNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 05:13:17 -0400
Received: by pwi3 with SMTP id 3so466991pwi.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 02:13:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is only one rps_cpus, skb_get_rxhash() can be eliminated.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index d8c43e7..2bf740c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2345,7 +2345,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		       struct rps_dev_flow **rflowp)
 {
 	struct netdev_rx_queue *rxqueue;
-	struct rps_map *map;
+	struct rps_map *map = NULL;
 	struct rps_dev_flow_table *flow_table;
 	struct rps_sock_flow_table *sock_flow_table;
 	int cpu = -1;
@@ -2363,8 +2363,17 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	} else
 		rxqueue = dev->_rx;
 
-	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
+	if (rxqueue->rps_map) {
+		map = rcu_dereference(rxqueue->rps_map);
+		if (map && map->len == 1) {
+			tcpu = map->cpus[0];
+			if (cpu_online(tcpu))
+				cpu = tcpu;
+			goto done;
+		}
+	} else if (!rxqueue->rps_flow_table) {
 		goto done;
+	}
 
 	skb_reset_network_header(skb);
 	if (!skb_get_rxhash(skb))
@@ -2409,7 +2418,6 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		}
 	}
 
-	map = rcu_dereference(rxqueue->rps_map);
 	if (map) {
 		tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
 
