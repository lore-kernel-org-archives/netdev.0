From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/14] batman-adv: add WiFi penalty
Date: Mon, 13 Jan 2014 23:31:28 +0100
Message-ID: <1389652298-472-5-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:36310 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaAMWdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:22 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

If the same interface is used for sending and receiving, there might be
throughput degradation on half-duplex interfaces such as WiFi. Add a
penalty if the same interface is used to reflect this problem in the
metric. At the same time, change the hop penalty from 30 to 15 so there
will be no change for single wifi mesh network. the effective hop
penalty will stay at 30 due to the new wifi penalty for these networks.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c     | 27 ++++++++++++++++++++++-----
 net/batman-adv/hard-interface.h |  1 +
 net/batman-adv/soft-interface.c |  2 +-
 3 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1f9fe42..789aaa9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1088,6 +1088,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
 	int tq_asym_penalty, inv_asym_penalty, if_num, ret = 0;
 	unsigned int combined_tq;
+	int tq_iface_penalty;
 
 	/* find corresponding one hop neighbor */
 	rcu_read_lock();
@@ -1169,15 +1170,31 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	inv_asym_penalty /= neigh_rq_max_cube;
 	tq_asym_penalty = BATADV_TQ_MAX_VALUE - inv_asym_penalty;
 
-	combined_tq = batadv_ogm_packet->tq * tq_own * tq_asym_penalty;
-	combined_tq /= BATADV_TQ_MAX_VALUE * BATADV_TQ_MAX_VALUE;
+	/* penalize if the OGM is forwarded on the same interface. WiFi
+	 * interfaces and other half duplex devices suffer from throughput
+	 * drops as they can't send and receive at the same time.
+	 */
+	tq_iface_penalty = BATADV_TQ_MAX_VALUE;
+	if (if_outgoing && (if_incoming == if_outgoing) &&
+	    batadv_is_wifi_netdev(if_outgoing->net_dev))
+		tq_iface_penalty = batadv_hop_penalty(BATADV_TQ_MAX_VALUE,
+						      bat_priv);
+
+	combined_tq = batadv_ogm_packet->tq *
+		      tq_own *
+		      tq_asym_penalty *
+		      tq_iface_penalty;
+	combined_tq /= BATADV_TQ_MAX_VALUE *
+		       BATADV_TQ_MAX_VALUE *
+		       BATADV_TQ_MAX_VALUE;
 	batadv_ogm_packet->tq = combined_tq;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, total tq: %3i\n",
+		   "bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, iface_penalty: %3i, total tq: %3i, if_incoming = %s, if_outgoing = %s\n",
 		   orig_node->orig, orig_neigh_node->orig, total_count,
-		   neigh_rq_count, tq_own,
-		   tq_asym_penalty, batadv_ogm_packet->tq);
+		   neigh_rq_count, tq_own, tq_asym_penalty, tq_iface_penalty,
+		   batadv_ogm_packet->tq, if_incoming->net_dev->name,
+		   if_outgoing ? if_outgoing->net_dev->name : "DEFAULT");
 
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 8d4304b..ccd42c2 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -40,6 +40,7 @@ enum batadv_hard_if_cleanup {
 extern struct notifier_block batadv_hard_if_notifier;
 
 bool batadv_is_wifi_netdev(struct net_device *net_device);
+bool batadv_is_wifi_iface(int ifindex);
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c50f643..2dc2270 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -697,7 +697,7 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
 	atomic_set(&bat_priv->gw.bandwidth_up, 20);
 	atomic_set(&bat_priv->orig_interval, 1000);
-	atomic_set(&bat_priv->hop_penalty, 30);
+	atomic_set(&bat_priv->hop_penalty, 15);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_set(&bat_priv->log_level, 0);
 #endif
-- 
1.8.5.2
