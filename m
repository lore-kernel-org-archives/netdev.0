From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-12-11
Date: Fri, 11 Dec 2009 14:37:57 -0500
Message-ID: <20091211193757.GC6663@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41948 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761133AbZLKTpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 14:45:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another little batch of fixes intended for 2.6.33.  Most of them
are tiny.  The rtl8187 led patch is self-contained and squashes a
warning during suspend.  The regulatory rules update only applies to the
people _not_ using CRDA, which should be fairly rare nowadays.  But
still, anyone using that configuration should be working with current
and safe rules.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 43de004b6c197b0ea408bdebf4f14afdead74b63:
  Anton Vorontsov (1):
        gianfar: Fix build with CONFIG_NET_POLL_CONTROLLER=y

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Herton Ronaldo Krzesinski (1):
      rtl8187: add radio led and fix warnings on suspend

Javier Cardona (2):
      mac80211: Fixed bug in mesh portal paths
      mac80211: Revert 'Use correct sign for mesh active path refresh'

John W. Linville (2):
      wireless: correctly report signal value for IEEE80211_HW_SIGNAL_UNSPEC
      wireless: update old static regulatory domain rules

Julia Lawall (1):
      net/mac80211: Correct size given to memset

Larry Finger (1):
      b43: Remove reset after fatal DMA error

Luis R. Rodriguez (1):
      ath5k: enable EEPROM checksum check

Vivek Natarajan (1):
      cfg80211: Clear encryption privacy when key off is done.

 drivers/net/wireless/ath/ath5k/eeprom.c     |    3 +-
 drivers/net/wireless/b43/main.c             |    5 ++-
 drivers/net/wireless/rtl818x/rtl8187.h      |    1 +
 drivers/net/wireless/rtl818x/rtl8187_leds.c |   68 +++++++++++++++++--------
 drivers/net/wireless/rtl818x/rtl8187_leds.h |    2 +
 net/mac80211/cfg.c                          |    3 +-
 net/mac80211/mesh.c                         |    2 +-
 net/mac80211/mesh.h                         |    5 +-
 net/mac80211/mesh_hwmp.c                    |    2 +-
 net/mac80211/rx.c                           |    1 -
 net/wireless/reg.c                          |   75 +++++++++------------------
 net/wireless/wext-compat.c                  |    1 +
 12 files changed, 88 insertions(+), 80 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 644962a..7918852 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -97,6 +97,7 @@ ath5k_eeprom_init_header(struct ath5k_hw *ah)
 	struct ath5k_eeprom_info *ee = &ah->ah_capabilities.cap_eeprom;
 	int ret;
 	u16 val;
+	u32 cksum, offset;
 
 	/*
 	 * Read values from EEPROM and store them in the capability structure
@@ -111,7 +112,6 @@ ath5k_eeprom_init_header(struct ath5k_hw *ah)
 	if (ah->ah_ee_version < AR5K_EEPROM_VERSION_3_0)
 		return 0;
 
-#ifdef notyet
 	/*
 	 * Validate the checksum of the EEPROM date. There are some
 	 * devices with invalid EEPROMs.
@@ -124,7 +124,6 @@ ath5k_eeprom_init_header(struct ath5k_hw *ah)
 		ATH5K_ERR(ah->ah_sc, "Invalid EEPROM checksum 0x%04x\n", cksum);
 		return -EIO;
 	}
-#endif
 
 	AR5K_EEPROM_READ_HDR(AR5K_EEPROM_ANT_GAIN(ah->ah_ee_version),
 	    ee_ant_gain);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 077480c..19b4eae 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1784,7 +1784,10 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 			       dma_reason[0], dma_reason[1],
 			       dma_reason[2], dma_reason[3],
 			       dma_reason[4], dma_reason[5]);
-			b43_controller_restart(dev, "DMA error");
+			b43err(dev->wl, "This device does not support DMA "
+			       "on your system. Please use PIO instead.\n");
+			b43err(dev->wl, "CONFIG_B43_FORCE_PIO must be set in "
+			       "your kernel configuration.\n");
 			return;
 		}
 		if (merged_dma_reason & B43_DMAIRQ_NONFATALMASK) {
diff --git a/drivers/net/wireless/rtl818x/rtl8187.h b/drivers/net/wireless/rtl818x/rtl8187.h
index b1a24de..6af0f3f 100644
--- a/drivers/net/wireless/rtl818x/rtl8187.h
+++ b/drivers/net/wireless/rtl818x/rtl8187.h
@@ -108,6 +108,7 @@ struct rtl8187_priv {
 	struct delayed_work work;
 	struct ieee80211_hw *dev;
 #ifdef CONFIG_RTL8187_LEDS
+	struct rtl8187_led led_radio;
 	struct rtl8187_led led_tx;
 	struct rtl8187_led led_rx;
 	struct delayed_work led_on;
diff --git a/drivers/net/wireless/rtl818x/rtl8187_leds.c b/drivers/net/wireless/rtl818x/rtl8187_leds.c
index cf8a4a4..ded44c0 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_leds.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_leds.c
@@ -105,19 +105,36 @@ static void rtl8187_led_brightness_set(struct led_classdev *led_dev,
 	struct rtl8187_led *led = container_of(led_dev, struct rtl8187_led,
 					       led_dev);
 	struct ieee80211_hw *hw = led->dev;
-	struct rtl8187_priv *priv = hw->priv;
+	struct rtl8187_priv *priv;
+	static bool radio_on;
 
-	if (brightness == LED_OFF) {
-		ieee80211_queue_delayed_work(hw, &priv->led_off, 0);
-		/* The LED is off for 1/20 sec so that it just blinks. */
-		ieee80211_queue_delayed_work(hw, &priv->led_on, HZ / 20);
-	} else
-		ieee80211_queue_delayed_work(hw, &priv->led_on, 0);
+	if (!hw)
+		return;
+	priv = hw->priv;
+	if (led->is_radio) {
+		if (brightness == LED_FULL) {
+			ieee80211_queue_delayed_work(hw, &priv->led_on, 0);
+			radio_on = true;
+		} else if (radio_on) {
+			radio_on = false;
+			cancel_delayed_work_sync(&priv->led_on);
+			ieee80211_queue_delayed_work(hw, &priv->led_off, 0);
+		}
+	} else if (radio_on) {
+		if (brightness == LED_OFF) {
+			ieee80211_queue_delayed_work(hw, &priv->led_off, 0);
+			/* The LED is off for 1/20 sec - it just blinks. */
+			ieee80211_queue_delayed_work(hw, &priv->led_on,
+						     HZ / 20);
+		} else
+			ieee80211_queue_delayed_work(hw, &priv->led_on, 0);
+	}
 }
 
 static int rtl8187_register_led(struct ieee80211_hw *dev,
 				struct rtl8187_led *led, const char *name,
-				const char *default_trigger, u8 ledpin)
+				const char *default_trigger, u8 ledpin,
+				bool is_radio)
 {
 	int err;
 	struct rtl8187_priv *priv = dev->priv;
@@ -128,6 +145,7 @@ static int rtl8187_register_led(struct ieee80211_hw *dev,
 		return -EINVAL;
 	led->dev = dev;
 	led->ledpin = ledpin;
+	led->is_radio = is_radio;
 	strncpy(led->name, name, sizeof(led->name));
 
 	led->led_dev.name = led->name;
@@ -145,7 +163,11 @@ static int rtl8187_register_led(struct ieee80211_hw *dev,
 
 static void rtl8187_unregister_led(struct rtl8187_led *led)
 {
+	struct ieee80211_hw *hw = led->dev;
+	struct rtl8187_priv *priv = hw->priv;
+
 	led_classdev_unregister(&led->led_dev);
+	flush_delayed_work(&priv->led_off);
 	led->dev = NULL;
 }
 
@@ -183,33 +205,37 @@ void rtl8187_leds_init(struct ieee80211_hw *dev, u16 custid)
 	INIT_DELAYED_WORK(&priv->led_off, led_turn_off);
 
 	snprintf(name, sizeof(name),
+		 "rtl8187-%s::radio", wiphy_name(dev->wiphy));
+	err = rtl8187_register_led(dev, &priv->led_radio, name,
+			 ieee80211_get_radio_led_name(dev), ledpin, true);
+	if (err)
+		return;
+
+	snprintf(name, sizeof(name),
 		 "rtl8187-%s::tx", wiphy_name(dev->wiphy));
 	err = rtl8187_register_led(dev, &priv->led_tx, name,
-			 ieee80211_get_tx_led_name(dev), ledpin);
+			 ieee80211_get_tx_led_name(dev), ledpin, false);
 	if (err)
-		goto error;
+		goto err_tx;
+
 	snprintf(name, sizeof(name),
 		 "rtl8187-%s::rx", wiphy_name(dev->wiphy));
 	err = rtl8187_register_led(dev, &priv->led_rx, name,
-			 ieee80211_get_rx_led_name(dev), ledpin);
-	if (!err) {
-		ieee80211_queue_delayed_work(dev, &priv->led_on, 0);
+			 ieee80211_get_rx_led_name(dev), ledpin, false);
+	if (!err)
 		return;
-	}
-	/* registration of RX LED failed - unregister TX */
+
+	/* registration of RX LED failed - unregister */
 	rtl8187_unregister_led(&priv->led_tx);
-error:
-	/* If registration of either failed, cancel delayed work */
-	cancel_delayed_work_sync(&priv->led_off);
-	cancel_delayed_work_sync(&priv->led_on);
+err_tx:
+	rtl8187_unregister_led(&priv->led_radio);
 }
 
 void rtl8187_leds_exit(struct ieee80211_hw *dev)
 {
 	struct rtl8187_priv *priv = dev->priv;
 
-	/* turn the LED off before exiting */
-	ieee80211_queue_delayed_work(dev, &priv->led_off, 0);
+	rtl8187_unregister_led(&priv->led_radio);
 	rtl8187_unregister_led(&priv->led_rx);
 	rtl8187_unregister_led(&priv->led_tx);
 	cancel_delayed_work_sync(&priv->led_off);
diff --git a/drivers/net/wireless/rtl818x/rtl8187_leds.h b/drivers/net/wireless/rtl818x/rtl8187_leds.h
index a033202..efe8041 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_leds.h
+++ b/drivers/net/wireless/rtl818x/rtl8187_leds.h
@@ -47,6 +47,8 @@ struct rtl8187_led {
 	u8 ledpin;
 	/* The unique name string for this LED device. */
 	char name[RTL8187_LED_MAX_NAME_LEN + 1];
+	/* If the LED is radio or tx/rx */
+	bool is_radio;
 };
 
 void rtl8187_leds_init(struct ieee80211_hw *dev, u16 code);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 93ee1fd..6dc3579 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -354,7 +354,8 @@ static void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 	sinfo->rx_packets = sta->rx_packets;
 	sinfo->tx_packets = sta->tx_packets;
 
-	if (sta->local->hw.flags & IEEE80211_HW_SIGNAL_DBM) {
+	if ((sta->local->hw.flags & IEEE80211_HW_SIGNAL_DBM) ||
+	    (sta->local->hw.flags & IEEE80211_HW_SIGNAL_UNSPEC)) {
 		sinfo->filled |= STATION_INFO_SIGNAL;
 		sinfo->signal = (s8)sta->last_signal;
 	}
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index c0fe464..6a43314 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -427,7 +427,7 @@ int ieee80211_new_mesh_header(struct ieee80211s_hdr *meshhdr,
 		char *addr5, char *addr6)
 {
 	int aelen = 0;
-	memset(meshhdr, 0, sizeof(meshhdr));
+	memset(meshhdr, 0, sizeof(*meshhdr));
 	meshhdr->ttl = sdata->u.mesh.mshcfg.dot11MeshTTL;
 	put_unaligned(cpu_to_le32(sdata->u.mesh.mesh_seqnum), &meshhdr->seqnum);
 	sdata->u.mesh.mesh_seqnum++;
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 31e1025..85562c5 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -188,8 +188,9 @@ struct mesh_rmc {
  */
 #define MESH_PREQ_MIN_INT	10
 #define MESH_DIAM_TRAVERSAL_TIME 50
-/* Paths will be refreshed if they are closer than PATH_REFRESH_TIME to their
- * expiration
+/* A path will be refreshed if it is used PATH_REFRESH_TIME milliseconds before
+ * timing out.  This way it will remain ACTIVE and no data frames will be
+ * unnecesarily held in the pending queue.
  */
 #define MESH_PATH_REFRESH_TIME			1000
 #define MESH_MIN_DISCOVERY_TIMEOUT (2 * MESH_DIAM_TRAVERSAL_TIME)
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 833b2f3..d28acb6 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -937,7 +937,7 @@ int mesh_nexthop_lookup(struct sk_buff *skb,
 
 	if (mpath->flags & MESH_PATH_ACTIVE) {
 		if (time_after(jiffies,
-			       mpath->exp_time +
+			       mpath->exp_time -
 			       msecs_to_jiffies(sdata->u.mesh.mshcfg.path_refresh_time)) &&
 		    !memcmp(sdata->dev->dev_addr, hdr->addr4, ETH_ALEN) &&
 		    !(mpath->flags & MESH_PATH_RESOLVING) &&
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index f237df4..9f2807a 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1712,7 +1712,6 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 			mpp_path_add(proxied_addr, mpp_addr, sdata);
 		} else {
 			spin_lock_bh(&mppath->state_lock);
-			mppath->exp_time = jiffies;
 			if (compare_ether_addr(mppath->mpp, mpp_addr) != 0)
 				memcpy(mppath->mpp, mpp_addr, ETH_ALEN);
 			spin_unlock_bh(&mppath->state_lock);
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index c01470e..baa898a 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -141,62 +141,35 @@ static const struct ieee80211_regdomain us_regdom = {
 	.reg_rules = {
 		/* IEEE 802.11b/g, channels 1..11 */
 		REG_RULE(2412-10, 2462+10, 40, 6, 27, 0),
-		/* IEEE 802.11a, channel 36 */
-		REG_RULE(5180-10, 5180+10, 40, 6, 23, 0),
-		/* IEEE 802.11a, channel 40 */
-		REG_RULE(5200-10, 5200+10, 40, 6, 23, 0),
-		/* IEEE 802.11a, channel 44 */
-		REG_RULE(5220-10, 5220+10, 40, 6, 23, 0),
+		/* IEEE 802.11a, channel 36..48 */
+		REG_RULE(5180-10, 5240+10, 40, 6, 17, 0),
 		/* IEEE 802.11a, channels 48..64 */
-		REG_RULE(5240-10, 5320+10, 40, 6, 23, 0),
+		REG_RULE(5260-10, 5320+10, 40, 6, 20, NL80211_RRF_DFS),
+		/* IEEE 802.11a, channels 100..124 */
+		REG_RULE(5500-10, 5590+10, 40, 6, 20, NL80211_RRF_DFS),
+		/* IEEE 802.11a, channels 132..144 */
+		REG_RULE(5660-10, 5700+10, 40, 6, 20, NL80211_RRF_DFS),
 		/* IEEE 802.11a, channels 149..165, outdoor */
 		REG_RULE(5745-10, 5825+10, 40, 6, 30, 0),
 	}
 };
 
 static const struct ieee80211_regdomain jp_regdom = {
-	.n_reg_rules = 3,
+	.n_reg_rules = 6,
 	.alpha2 =  "JP",
 	.reg_rules = {
-		/* IEEE 802.11b/g, channels 1..14 */
-		REG_RULE(2412-10, 2484+10, 40, 6, 20, 0),
-		/* IEEE 802.11a, channels 34..48 */
-		REG_RULE(5170-10, 5240+10, 40, 6, 20,
-			NL80211_RRF_PASSIVE_SCAN),
+		/* IEEE 802.11b/g, channels 1..11 */
+		REG_RULE(2412-10, 2462+10, 40, 6, 20, 0),
+		/* IEEE 802.11b/g, channels 12..13 */
+		REG_RULE(2467-10, 2472+10, 20, 6, 20, 0),
+		/* IEEE 802.11b/g, channel 14 */
+		REG_RULE(2484-10, 2484+10, 20, 6, 20, NL80211_RRF_NO_OFDM),
+		/* IEEE 802.11a, channels 36..48 */
+		REG_RULE(5180-10, 5240+10, 40, 6, 20, 0),
 		/* IEEE 802.11a, channels 52..64 */
-		REG_RULE(5260-10, 5320+10, 40, 6, 20,
-			NL80211_RRF_NO_IBSS |
-			NL80211_RRF_DFS),
-	}
-};
-
-static const struct ieee80211_regdomain eu_regdom = {
-	.n_reg_rules = 6,
-	/*
-	 * This alpha2 is bogus, we leave it here just for stupid
-	 * backward compatibility
-	 */
-	.alpha2 =  "EU",
-	.reg_rules = {
-		/* IEEE 802.11b/g, channels 1..13 */
-		REG_RULE(2412-10, 2472+10, 40, 6, 20, 0),
-		/* IEEE 802.11a, channel 36 */
-		REG_RULE(5180-10, 5180+10, 40, 6, 23,
-			NL80211_RRF_PASSIVE_SCAN),
-		/* IEEE 802.11a, channel 40 */
-		REG_RULE(5200-10, 5200+10, 40, 6, 23,
-			NL80211_RRF_PASSIVE_SCAN),
-		/* IEEE 802.11a, channel 44 */
-		REG_RULE(5220-10, 5220+10, 40, 6, 23,
-			NL80211_RRF_PASSIVE_SCAN),
-		/* IEEE 802.11a, channels 48..64 */
-		REG_RULE(5240-10, 5320+10, 40, 6, 20,
-			NL80211_RRF_NO_IBSS |
-			NL80211_RRF_DFS),
-		/* IEEE 802.11a, channels 100..140 */
-		REG_RULE(5500-10, 5700+10, 40, 6, 30,
-			NL80211_RRF_NO_IBSS |
-			NL80211_RRF_DFS),
+		REG_RULE(5260-10, 5320+10, 40, 6, 20, NL80211_RRF_DFS),
+		/* IEEE 802.11a, channels 100..144 */
+		REG_RULE(5500-10, 5700+10, 40, 6, 23, NL80211_RRF_DFS),
 	}
 };
 
@@ -206,15 +179,17 @@ static const struct ieee80211_regdomain *static_regdom(char *alpha2)
 		return &us_regdom;
 	if (alpha2[0] == 'J' && alpha2[1] == 'P')
 		return &jp_regdom;
+	/* Use world roaming rules for "EU", since it was a pseudo
+	   domain anyway... */
 	if (alpha2[0] == 'E' && alpha2[1] == 'U')
-		return &eu_regdom;
-	/* Default, as per the old rules */
-	return &us_regdom;
+		return &world_regdom;
+	/* Default, world roaming rules */
+	return &world_regdom;
 }
 
 static bool is_old_static_regdom(const struct ieee80211_regdomain *rd)
 {
-	if (rd == &us_regdom || rd == &jp_regdom || rd == &eu_regdom)
+	if (rd == &us_regdom || rd == &jp_regdom || rd == &world_regdom)
 		return true;
 	return false;
 }
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 584eb48..54face3 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -479,6 +479,7 @@ static int __cfg80211_set_encryption(struct cfg80211_registered_device *rdev,
 			}
 			err = rdev->ops->del_key(&rdev->wiphy, dev, idx, addr);
 		}
+		wdev->wext.connect.privacy = false;
 		/*
 		 * Applications using wireless extensions expect to be
 		 * able to delete keys that don't exist, so allow that.
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
