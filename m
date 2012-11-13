From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/11] batman-adv: wait multiple periods before activating bla
Date: Tue, 13 Nov 2012 10:15:34 +0100
Message-ID: <1352798139-19458-7-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52701 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab2KMJQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:35 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

For some reasons (bridge forward delay, network device setup order, etc)
the initial bridge loop avoidance announcement packets may be lost. This
may lead to problems in finding other backbone gws, and therfore create
loops in the startup time.

Fix this by extending the waiting periods to 3 (define can be changed)
before allowing broadcast traffic.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 9 ++++++++-
 net/batman-adv/main.h                  | 1 +
 net/batman-adv/types.h                 | 1 +
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 77ee47e..415343f 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -390,6 +390,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 	entry->crc = BATADV_BLA_CRC_INIT;
 	entry->bat_priv = bat_priv;
 	atomic_set(&entry->request_sent, 0);
+	atomic_set(&entry->wait_periods, 0);
 	memcpy(entry->orig, orig, ETH_ALEN);
 
 	/* one for the hash, one for returning */
@@ -419,6 +420,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 
 		/* this will be decreased in the worker thread */
 		atomic_inc(&entry->request_sent);
+		atomic_set(&entry->wait_periods, BATADV_BLA_WAIT_PERIODS);
 		atomic_inc(&bat_priv->bla.num_requests);
 	}
 
@@ -1160,12 +1162,17 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 			 * problems when we are not yet known as backbone gw
 			 * in the backbone.
 			 *
-			 * We can reset this now and allow traffic again.
+			 * We can reset this now after we waited some periods
+			 * to give bridge forward delays and bla group forming
+			 * some grace time.
 			 */
 
 			if (atomic_read(&backbone_gw->request_sent) == 0)
 				continue;
 
+			if (!atomic_dec_and_test(&backbone_gw->wait_periods))
+				continue;
+
 			atomic_dec(&backbone_gw->bat_priv->bla.num_requests);
 			atomic_set(&backbone_gw->request_sent, 0);
 		}
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 240c74f..8f149bb 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -95,6 +95,7 @@
 #define BATADV_BLA_PERIOD_LENGTH	10000	/* 10 seconds */
 #define BATADV_BLA_BACKBONE_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 3)
 #define BATADV_BLA_CLAIM_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 10)
+#define BATADV_BLA_WAIT_PERIODS		3
 
 #define BATADV_DUPLIST_SIZE		16
 #define BATADV_DUPLIST_TIMEOUT		500	/* 500 ms */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e8a1b18..fa09961 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -369,6 +369,7 @@ struct batadv_backbone_gw {
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
 	unsigned long lasttime;	/* last time we heard of this backbone gw */
+	atomic_t wait_periods;
 	atomic_t request_sent;
 	atomic_t refcount;
 	struct rcu_head rcu;
-- 
1.8.0
