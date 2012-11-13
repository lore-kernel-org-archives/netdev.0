From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/11] batman-adv: send announcement when backbone gw is registered
Date: Tue, 13 Nov 2012 10:15:32 +0100
Message-ID: <1352798139-19458-5-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52643 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab2KMJQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:33 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

To avoid loops in the startup phase until the first announcement is
sent, send an announcement immediately as soon as a backbone gw is
added.

This may happen due to various reasons, e.g. a packet passes the rx
or tx path.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index decc042..d1a817f 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -366,7 +366,7 @@ out:
  */
 static struct batadv_backbone_gw *
 batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
-			   short vid)
+			   short vid, bool own_backbone)
 {
 	struct batadv_backbone_gw *entry;
 	struct batadv_orig_node *orig_node;
@@ -413,6 +413,10 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 					  "became a backbone gateway");
 		batadv_orig_node_free_ref(orig_node);
 	}
+
+	if (own_backbone)
+		batadv_bla_send_announce(bat_priv, entry);
+
 	return entry;
 }
 
@@ -428,7 +432,7 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
 
 	backbone_gw = batadv_bla_get_backbone_gw(bat_priv,
 						 primary_if->net_dev->dev_addr,
-						 vid);
+						 vid, true);
 	if (unlikely(!backbone_gw))
 		return;
 
@@ -636,7 +640,8 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 	if (memcmp(an_addr, batadv_announce_mac, 4) != 0)
 		return 0;
 
-	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid,
+						 false);
 
 	if (unlikely(!backbone_gw))
 		return 1;
@@ -734,7 +739,8 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 
 	/* register the gateway if not yet available, and add the claim. */
 
-	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid,
+						 false);
 
 	if (unlikely(!backbone_gw))
 		return 1;
-- 
1.8.0
