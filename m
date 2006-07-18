From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/2] bcm43xx-d80211: use host_gen_beacon_template
Date: Tue, 18 Jul 2006 17:51:06 +0200 (CEST)
Message-ID: <20060718155106.3A02A483BC@silver.suse.cz>
References: <20060718175044.204144808.midnight@suse.cz>
Cc: netdev@vger.kernel.org, Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26855 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932307AbWGRPtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:49:18 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060718175044.204144808.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use new host_gen_beacon_template flag. This also means workaround with
"iwconfig essid" after hostapd is run is not necessary anymore.

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   36 ++++++--------------
 1 files changed, 11 insertions(+), 25 deletions(-)

374247361f6872f585ddde1e7bcec4c4564f961e
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index b6425e3..8b63d1c 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1710,17 +1710,12 @@ static void bcm43xx_write_probe_resp_tem
 	kfree(probe_resp_data);
 }
 
-static int bcm43xx_refresh_cached_beacon(struct bcm43xx_private *bcm)
+static int bcm43xx_refresh_cached_beacon(struct bcm43xx_private *bcm,
+					 struct sk_buff *beacon)
 {
-	struct ieee80211_tx_control control;
-
 	if (bcm->cached_beacon)
 		kfree_skb(bcm->cached_beacon);
-	bcm->cached_beacon = ieee80211_beacon_get(bcm->net_dev,
-						  bcm->interface.if_id,
-						  &control);
-	if (unlikely(!bcm->cached_beacon))
-		return -ENOMEM;
+	bcm->cached_beacon = beacon;
 
 	return 0;
 }
@@ -1743,16 +1738,15 @@ static void bcm43xx_update_templates(str
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD, status);
 }
 
-static void bcm43xx_refresh_templates(struct bcm43xx_private *bcm)
+static void bcm43xx_refresh_templates(struct bcm43xx_private *bcm,
+				      struct sk_buff *beacon)
 {
 	int err;
 
-	err = bcm43xx_refresh_cached_beacon(bcm);
+	err = bcm43xx_refresh_cached_beacon(bcm, beacon);
 	if (unlikely(err))
 		return;
 	bcm43xx_update_templates(bcm);
-	kfree_skb(bcm->cached_beacon);
-	bcm->cached_beacon = NULL;
 }
 
 static void bcm43xx_set_ssid(struct bcm43xx_private *bcm,
@@ -1792,19 +1786,11 @@ static void bcm43xx_set_beacon_int(struc
 static void handle_irq_beacon(struct bcm43xx_private *bcm)
 {
 	u32 status;
-	int err;
 
 	bcm->irq_savedstate &= ~BCM43xx_IRQ_BEACON;
 	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD);
 
-	if (!bcm->cached_beacon) {
-		err = bcm43xx_refresh_cached_beacon(bcm);
-		if (unlikely(err))
-			goto ack;
-	}
-
-	if ((status & 0x1) && (status & 0x2)) {
-ack:
+	if (!bcm->cached_beacon || ((status & 0x1) && (status & 0x2))) {
 		/* ACK beacon IRQ. */
 		bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON,
 				BCM43xx_IRQ_BEACON);
@@ -4384,7 +4370,6 @@ #endif
 
 	if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 		bcm43xx_set_beacon_int(bcm, conf->beacon_int);
-		bcm43xx_refresh_templates(bcm);
 	}
 
 	bcm43xx_unlock_irqonly(bcm, flags);
@@ -4555,7 +4540,7 @@ static int bcm43xx_add_interface(struct 
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_select_opmode(bcm);
 		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
-			bcm43xx_refresh_templates(bcm);
+			bcm43xx_refresh_templates(bcm, NULL);
 	}
 	err = 0;
 
@@ -4608,7 +4593,8 @@ static int bcm43xx_config_interface(stru
 		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 			assert(conf->type == IEEE80211_IF_TYPE_AP);
 			bcm43xx_set_ssid(bcm, conf->ssid, conf->ssid_len);
-			bcm43xx_refresh_templates(bcm);
+			if (conf->beacon)
+				bcm43xx_refresh_templates(bcm, conf->beacon);
 		}
 	}
 	bcm43xx_unlock_irqsafe(bcm, flags);
@@ -4702,7 +4688,7 @@ #endif
 		goto out;
 	ieee->version = IEEE80211_VERSION;
 	ieee->name = KBUILD_MODNAME;
-	ieee->host_gen_beacon = 1;
+	ieee->host_gen_beacon_template = 1;
 	ieee->rx_includes_fcs = 1;
 	ieee->monitor_during_oper = 1;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
-- 
1.3.0

