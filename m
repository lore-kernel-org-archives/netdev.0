From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/18] batman-adv: rename bridge loop avoidance claim types
Date: Thu, 23 Aug 2012 15:10:13 +0200
Message-ID: <1345727427-20805-5-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28751 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933055Ab2HWNKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:50 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

for consistency reasons within the code and with the documentation,
we should always call it "claim" and "unclaim".

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |   18 +++++++++---------
 net/batman-adv/packet.h                |    4 ++--
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5f1ad80..84dd841 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -295,7 +295,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 
 	/* now we pretend that the client would have sent this ... */
 	switch (claimtype) {
-	case BATADV_CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_CLAIM:
 		/* normal claim frame
 		 * set Ethernet SRC to the clients mac
 		 */
@@ -303,7 +303,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
 		break;
-	case BATADV_CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_UNCLAIM:
 		/* unclaim frame
 		 * set HW SRC to the clients mac
 		 */
@@ -468,7 +468,7 @@ static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
 				continue;
 
 			batadv_bla_send_claim(bat_priv, claim->addr, claim->vid,
-					      BATADV_CLAIM_TYPE_ADD);
+					      BATADV_CLAIM_TYPE_CLAIM);
 		}
 		rcu_read_unlock();
 	}
@@ -703,7 +703,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 	if (primary_if && batadv_compare_eth(backbone_addr,
 					     primary_if->net_dev->dev_addr))
 		batadv_bla_send_claim(bat_priv, claim_addr, vid,
-				      BATADV_CLAIM_TYPE_DEL);
+				      BATADV_CLAIM_TYPE_UNCLAIM);
 
 	backbone_gw = batadv_backbone_hash_find(bat_priv, backbone_addr, vid);
 
@@ -739,7 +739,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 	batadv_bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
 	if (batadv_compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
 		batadv_bla_send_claim(bat_priv, claim_addr, vid,
-				      BATADV_CLAIM_TYPE_ADD);
+				      BATADV_CLAIM_TYPE_CLAIM);
 
 	/* TODO: we could call something like tt_local_del() here. */
 
@@ -784,12 +784,12 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 	 * otherwise assume it is in the hw_src
 	 */
 	switch (bla_dst->type) {
-	case BATADV_CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_CLAIM:
 		backbone_addr = hw_src;
 		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 	case BATADV_CLAIM_TYPE_ANNOUNCE:
-	case BATADV_CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_UNCLAIM:
 		backbone_addr = ethhdr->h_source;
 		break;
 	default:
@@ -905,12 +905,12 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 
 	/* check for the different types of claim frames ... */
 	switch (bla_dst->type) {
-	case BATADV_CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_CLAIM:
 		if (batadv_handle_claim(bat_priv, primary_if, hw_src,
 					ethhdr->h_source, vid))
 			return 1;
 		break;
-	case BATADV_CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_UNCLAIM:
 		if (batadv_handle_unclaim(bat_priv, primary_if,
 					  ethhdr->h_source, hw_src, vid))
 			return 1;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 8d3e55a..65d66e4 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -92,8 +92,8 @@ enum batadv_tt_client_flags {
 
 /* claim frame types for the bridge loop avoidance */
 enum batadv_bla_claimframe {
-	BATADV_CLAIM_TYPE_ADD		= 0x00,
-	BATADV_CLAIM_TYPE_DEL		= 0x01,
+	BATADV_CLAIM_TYPE_CLAIM		= 0x00,
+	BATADV_CLAIM_TYPE_UNCLAIM	= 0x01,
 	BATADV_CLAIM_TYPE_ANNOUNCE	= 0x02,
 	BATADV_CLAIM_TYPE_REQUEST	= 0x03,
 };
-- 
1.7.9.4
