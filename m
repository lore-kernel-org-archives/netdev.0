From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix IWLWIFI mis-merge.
Date: Mon, 21 Jan 2008 00:44:55 -0800 (PST)
Message-ID: <20080121.004455.116537231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, jgarzik@pobox.com,
	linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758823AbYAUIou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 03:44:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just corrected the iwlwifi driver build in the net-2.6.25 tree.

The cause is very simple, the patches applied after Christoph
Hellwig's namespace pollution cleanup to these drivers were not even
build tested.

[IWLWIFI]: Fix up merge errors.

Christoph Hellwig did a driver-wide namespace pollution cleanup
changing iwl_* over to iwl{3945,4965}_*

But subsequent patches to these drivers were not made against that
change and thus kept using the iwl_* names, thus breaking the build.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index 122d712..dc78fb0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -560,8 +560,8 @@ static void rs_tx_status(void *priv_rate,
 	return;
 }
 
-static u16 iwl_get_adjacent_rate(struct iwl_rate_scale_priv *rs_priv,
-				 u8 index, u16 rate_mask, int phymode)
+static u16 iwl3945_get_adjacent_rate(struct iwl3945_rate_scale_priv *rs_priv,
+				     u8 index, u16 rate_mask, int phymode)
 {
 	u8 high = IWL_RATE_INVALID;
 	u8 low = IWL_RATE_INVALID;
@@ -658,7 +658,7 @@ static void rs_get_rate(void *priv_rate, struct net_device *dev,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct sta_info *sta;
 	u16 rate_mask;
-	struct iwl_priv *priv = (struct iwl_priv *)priv_rate;
+	struct iwl3945_priv *priv = (struct iwl3945_priv *)priv_rate;
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_RATE("enter\n");
@@ -726,7 +726,7 @@ static void rs_get_rate(void *priv_rate, struct net_device *dev,
 	current_tpt = window->average_tpt;
 
 	high_low = iwl3945_get_adjacent_rate(rs_priv, index, rate_mask,
-					 local->hw.conf.phymode);
+					     local->hw.conf.phymode);
 	low = high_low & 0xff;
 	high = (high_low >> 8) & 0xff;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
index 5d6a540..b8f2483 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
@@ -83,7 +83,7 @@ struct iwl4965_rate_scale_data {
 /**
  * struct iwl4965_scale_tbl_info -- tx params and success history for all rates
  *
- * There are two of these in struct iwl_rate_scale_priv,
+ * There are two of these in struct iwl4965_rate_scale_priv,
  * one for "active", and one for "search".
  */
 struct iwl4965_scale_tbl_info {
@@ -99,7 +99,7 @@ struct iwl4965_scale_tbl_info {
 };
 
 /**
- * struct iwl_rate_scale_priv -- driver's rate scaling private structure
+ * struct iwl4965_rate_scale_priv -- driver's rate scaling private structure
  *
  * Pointer to this gets passed back and forth between driver and mac80211.
  */
@@ -2017,8 +2017,8 @@ static void rs_get_rate(void *priv_rate, struct net_device *dev,
 	struct ieee80211_conf *conf = &local->hw.conf;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct sta_info *sta;
-	struct iwl_priv *priv = (struct iwl_priv *)priv_rate;
-	struct iwl_rate_scale_priv *lq;
+	struct iwl4965_priv *priv = (struct iwl4965_priv *)priv_rate;
+	struct iwl4965_rate_scale_priv *lq;
 
 	IWL_DEBUG_RATE_LIMIT("rate scale calculate new rate for skb\n");
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 9d38af4..d702662 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -8636,7 +8636,7 @@ static void iwl3945_pci_remove(struct pci_dev *pdev)
 
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
 
-	iwl_down(priv);
+	iwl3945_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -8698,7 +8698,7 @@ static int iwl3945_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	iwl_down(priv);
+	iwl3945_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d10f487..4066515 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -9206,7 +9206,7 @@ static void iwl4965_pci_remove(struct pci_dev *pdev)
 
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
 
-	iwl_down(priv);
+	iwl4965_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -9268,7 +9268,7 @@ static int iwl4965_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	iwl_down(priv);
+	iwl4965_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
