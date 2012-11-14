From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/11] batman-adv: send announcement when backbone gw is registered
Date: Wed, 14 Nov 2012 21:16:22 +0100
Message-ID: <1352924189-18843-5-git-send-email-ordex@autistici.org>
References: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:31073 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423309Ab2KNUR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 15:17:29 -0500
In-Reply-To: <1352924189-18843-1-git-send-email-ordex@autistici.org>
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
index 49c35a6..c49cf24 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -354,7 +354,7 @@ out:
  */
 static struct batadv_backbone_gw *
 batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
-			   short vid)
+			   short vid, bool own_backbone)
 {
 	struct batadv_backbone_gw *entry;
 	struct batadv_orig_node *orig_node;
@@ -401,6 +401,10 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 					  "became a backbone gateway");
 		batadv_orig_node_free_ref(orig_node);
 	}
+
+	if (own_backbone)
+		batadv_bla_send_announce(bat_priv, entry);
+
 	return entry;
 }
 
@@ -416,7 +420,7 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
 
 	backbone_gw = batadv_bla_get_backbone_gw(bat_priv,
 						 primary_if->net_dev->dev_addr,
-						 vid);
+						 vid, true);
 	if (unlikely(!backbone_gw))
 		return;
 
@@ -624,7 +628,8 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 	if (memcmp(an_addr, batadv_announce_mac, 4) != 0)
 		return 0;
 
-	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid,
+						 false);
 
 	if (unlikely(!backbone_gw))
 		return 1;
@@ -722,7 +727,8 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 
 	/* register the gateway if not yet available, and add the claim. */
 
-	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid,
+						 false);
 
 	if (unlikely(!backbone_gw))
 		return 1;
-- 
1.8.0
