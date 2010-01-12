From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-01-12
Date: Tue, 12 Jan 2010 11:39:24 -0500
Message-ID: <20100112163924.GA2987@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754094Ab0ALQpZ@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

I apologize that it has been a while (i.e. too long) since my last pull
request.  I was giving this round extra time to bake...

Most of these are the usual one-liners and/or isolated fixes.  One
exception is "mac80211: fix skb buffering issue" from Johannes.  The
changelog describes the issue, but basically when the master netdev got
removed our multiqueue support went along with it.  This led to some
regressions that manifested as queueing/congestion problems.  The fix
from Johannes adds multiqueue support to the current mac80211
implementation.  Because this was a significant (but IMHO necessary)
change, I allowed this to bake over the last week or so and collected a
few fixes on top of that change in the process.

One other change of note is an EEPROM checksum change for Atheros
devices.  It seems there were some devices that handled their checksum
differently and they were being disabled after "ath5k: enable EEPROM
checksum check".  This has also been baking for a while and no problems
have been reported.

Finally, thanks for the git advice after the last pull request!  One
more incremental step in improving my workflow... :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9db2f1bec36805e57a003f7bb90e003815d96de8:
  Jarek Poplawski (1):
        sky2: Fix oops in sky2_xmit_frame() after TX timeout

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6 master

Abhijeet Kolekar (1):
      iwlwifi: disable tx on beacon update notification

Benoit Papillault (1):
      zd1211rw: Fix multicast filtering.

Dan Carpenter (2):
      iwl: off by one bug
      iwlwifi: silence buffer overflow warning

Dominik Geyer (1):
      ath9k: Fix Kconfig depends for ATH9K_DEBUGFS

Felix Fietkau (2):
      mac80211: add missing sanity checks for action frames
      mac80211: fix queue selection for data frames on monitor interfaces

Gertjan van Wingerde (2):
      rt2x00: Fix LED configuration setting for rt2800.
      rt2x00: Properly request tx headroom for alignment operations.

Johannes Berg (3):
      mac80211: fix skb buffering issue
      mac80211: fix endian error
      cfg80211: fix refcount imbalance when wext is disabled

John W. Linville (2):
      mac80211: fix-up build breakage in 2.6.33
      Revert "mac80211: replace netif_tx_{start,stop,wake}_all_queues"

Lennert Buytenhek (2):
      mwl8k: fix configure_filter() memory leak on error
      mac80211: fix queue selection for packets injected via monitor interface

Luis R. Rodriguez (2):
      ath5k: Fix eeprom checksum check for custom sized eeproms
      cfg80211: fix syntax error on user regulatory hints

Ming Lei (1):
      ath9k: fix ito64

Pavel Roskin (1):
      rt2x00: use correct headroom for transmission

Zhu Yi (1):
      iwlwifi: fix iwl_queue_used bug when read_ptr == write_ptr

 drivers/net/wireless/ath/ath5k/eeprom.c   |   32 +++++++++-
 drivers/net/wireless/ath/ath5k/eeprom.h   |    8 +++
 drivers/net/wireless/ath/ath9k/Kconfig    |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c   |   45 ++++++++------
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    2 +-
 drivers/net/wireless/mwl8k.c              |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h      |    6 ++
 drivers/net/wireless/rt2x00/rt2x00dev.c   |   12 +++-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c    |   13 ++--
 net/mac80211/iface.c                      |   47 +++++++++++++-
 net/mac80211/mlme.c                       |    8 ++-
 net/mac80211/rx.c                         |    8 ++-
 net/mac80211/scan.c                       |   10 ++--
 net/mac80211/tx.c                         |    5 +-
 net/mac80211/util.c                       |   12 ++++
 net/mac80211/wme.c                        |   96 +++++++++++++++++++++--------
 net/mac80211/wme.h                        |    8 ++-
 net/wireless/core.c                       |    4 +-
 net/wireless/reg.c                        |    2 +-
 23 files changed, 254 insertions(+), 86 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 7918852..9a96550 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -97,7 +97,7 @@ ath5k_eeprom_init_header(struct ath5k_hw *ah)
 	struct ath5k_eeprom_info *ee = &ah->ah_capabilities.cap_eeprom;
 	int ret;
 	u16 val;
-	u32 cksum, offset;
+	u32 cksum, offset, eep_max = AR5K_EEPROM_INFO_MAX;
 
 	/*
 	 * Read values from EEPROM and store them in the capability structure
@@ -116,12 +116,38 @@ ath5k_eeprom_init_header(struct ath5k_hw *ah)
 	 * Validate the checksum of the EEPROM date. There are some
 	 * devices with invalid EEPROMs.
 	 */
-	for (cksum = 0, offset = 0; offset < AR5K_EEPROM_INFO_MAX; offset++) {
+	AR5K_EEPROM_READ(AR5K_EEPROM_SIZE_UPPER, val);
+	if (val) {
+		eep_max = (val & AR5K_EEPROM_SIZE_UPPER_MASK) <<
+			   AR5K_EEPROM_SIZE_ENDLOC_SHIFT;
+		AR5K_EEPROM_READ(AR5K_EEPROM_SIZE_LOWER, val);
+		eep_max = (eep_max | val) - AR5K_EEPROM_INFO_BASE;
+
+		/*
+		 * Fail safe check to prevent stupid loops due
+		 * to busted EEPROMs. XXX: This value is likely too
+		 * big still, waiting on a better value.
+		 */
+		if (eep_max > (3 * AR5K_EEPROM_INFO_MAX)) {
+			ATH5K_ERR(ah->ah_sc, "Invalid max custom EEPROM size: "
+				  "%d (0x%04x) max expected: %d (0x%04x)\n",
+				  eep_max, eep_max,
+				  3 * AR5K_EEPROM_INFO_MAX,
+				  3 * AR5K_EEPROM_INFO_MAX);
+			return -EIO;
+		}
+	}
+
+	for (cksum = 0, offset = 0; offset < eep_max; offset++) {
 		AR5K_EEPROM_READ(AR5K_EEPROM_INFO(offset), val);
 		cksum ^= val;
 	}
 	if (cksum != AR5K_EEPROM_INFO_CKSUM) {
-		ATH5K_ERR(ah->ah_sc, "Invalid EEPROM checksum 0x%04x\n", cksum);
+		ATH5K_ERR(ah->ah_sc, "Invalid EEPROM "
+			  "checksum: 0x%04x eep_max: 0x%04x (%s)\n",
+			  cksum, eep_max,
+			  eep_max == AR5K_EEPROM_INFO_MAX ?
+				"default size" : "custom size");
 		return -EIO;
 	}
 
diff --git a/drivers/net/wireless/ath/ath5k/eeprom.h b/drivers/net/wireless/ath/ath5k/eeprom.h
index 0123f35..473a483 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.h
+++ b/drivers/net/wireless/ath/ath5k/eeprom.h
@@ -37,6 +37,14 @@
 #define AR5K_EEPROM_RFKILL_POLARITY_S	1
 
 #define AR5K_EEPROM_REG_DOMAIN		0x00bf	/* EEPROM regdom */
+
+/* FLASH(EEPROM) Defines for AR531X chips */
+#define AR5K_EEPROM_SIZE_LOWER		0x1b /* size info -- lower */
+#define AR5K_EEPROM_SIZE_UPPER		0x1c /* size info -- upper */
+#define AR5K_EEPROM_SIZE_UPPER_MASK	0xfff0
+#define AR5K_EEPROM_SIZE_UPPER_SHIFT	4
+#define AR5K_EEPROM_SIZE_ENDLOC_SHIFT	12
+
 #define AR5K_EEPROM_CHECKSUM		0x00c0	/* EEPROM checksum */
 #define AR5K_EEPROM_INFO_BASE		0x00c0	/* EEPROM header */
 #define AR5K_EEPROM_INFO_MAX		(0x400 - AR5K_EEPROM_INFO_BASE)
diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/ath/ath9k/Kconfig
index 03a1106..5774cea 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -25,7 +25,7 @@ config ATH9K
 
 config ATH9K_DEBUGFS
 	bool "Atheros ath9k debugging"
-	depends on ATH9K
+	depends on ATH9K && DEBUG_FS
 	---help---
 	  Say Y, if you need access to ath9k's statistics for
 	  interrupts, rate control, etc.
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index e2cef2f..1597a42 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -33,11 +33,11 @@ struct ath_node;
 
 /* Macro to expand scalars to 64-bit objects */
 
-#define	ito64(x) (sizeof(x) == 8) ?			\
+#define	ito64(x) (sizeof(x) == 1) ?			\
 	(((unsigned long long int)(x)) & (0xff)) :	\
-	(sizeof(x) == 16) ?				\
+	(sizeof(x) == 2) ?				\
 	(((unsigned long long int)(x)) & 0xffff) :	\
-	((sizeof(x) == 32) ?				\
+	((sizeof(x) == 4) ?				\
 	 (((unsigned long long int)(x)) & 0xffffffff) : \
 	 (unsigned long long int)(x))
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 484c5fd..9b4b8b5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -1961,7 +1961,7 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 	struct ieee80211_tx_info *info;
 	struct iwl4965_tx_resp *tx_resp = (void *)&pkt->u.raw[0];
 	u32  status = le32_to_cpu(tx_resp->u.status);
-	int tid = MAX_TID_COUNT;
+	int uninitialized_var(tid);
 	int sta_id;
 	int freed;
 	u8 *qc = NULL;
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 574d366..5461f10 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2344,6 +2344,21 @@ static void iwl_ht_conf(struct iwl_priv *priv,
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 }
 
+static inline void iwl_set_no_assoc(struct iwl_priv *priv)
+{
+	priv->assoc_id = 0;
+	iwl_led_disassociate(priv);
+	/*
+	 * inform the ucode that there is no longer an
+	 * association and that no more packets should be
+	 * sent
+	 */
+	priv->staging_rxon.filter_flags &=
+		~RXON_FILTER_ASSOC_MSK;
+	priv->staging_rxon.assoc_id = 0;
+	iwlcore_commit_rxon(priv);
+}
+
 #define IWL_DELAY_NEXT_SCAN_AFTER_ASSOC (HZ*6)
 void iwl_bss_info_changed(struct ieee80211_hw *hw,
 			  struct ieee80211_vif *vif,
@@ -2475,20 +2490,8 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 					IWL_DELAY_NEXT_SCAN_AFTER_ASSOC;
 			if (!iwl_is_rfkill(priv))
 				priv->cfg->ops->lib->post_associate(priv);
-		} else {
-			priv->assoc_id = 0;
-			iwl_led_disassociate(priv);
-
-			/*
-			 * inform the ucode that there is no longer an
-			 * association and that no more packets should be
-			 * send
-			 */
-			priv->staging_rxon.filter_flags &=
-				~RXON_FILTER_ASSOC_MSK;
-			priv->staging_rxon.assoc_id = 0;
-			iwlcore_commit_rxon(priv);
-		}
+		} else
+			iwl_set_no_assoc(priv);
 	}
 
 	if (changes && iwl_is_associated(priv) && priv->assoc_id) {
@@ -2503,12 +2506,14 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 		}
 	}
 
-	if ((changes & BSS_CHANGED_BEACON_ENABLED) &&
-	    vif->bss_conf.enable_beacon) {
-		memcpy(priv->staging_rxon.bssid_addr,
-		       bss_conf->bssid, ETH_ALEN);
-		memcpy(priv->bssid, bss_conf->bssid, ETH_ALEN);
-		iwlcore_config_ap(priv);
+	if (changes & BSS_CHANGED_BEACON_ENABLED) {
+		if (vif->bss_conf.enable_beacon) {
+			memcpy(priv->staging_rxon.bssid_addr,
+			       bss_conf->bssid, ETH_ALEN);
+			memcpy(priv->bssid, bss_conf->bssid, ETH_ALEN);
+			iwlcore_config_ap(priv);
+		} else
+			iwl_set_no_assoc(priv);
 	}
 
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 165d1f6..3822cf5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -711,7 +711,7 @@ extern void iwl_txq_ctx_stop(struct iwl_priv *priv);
 extern int iwl_queue_space(const struct iwl_queue *q);
 static inline int iwl_queue_used(const struct iwl_queue *q, int i)
 {
-	return q->write_ptr > q->read_ptr ?
+	return q->write_ptr >= q->read_ptr ?
 		(i >= q->read_ptr && i < q->write_ptr) :
 		!(i < q->read_ptr && i >= q->write_ptr);
 }
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 59d4915..59f9210 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -3157,8 +3157,10 @@ static void mwl8k_configure_filter(struct ieee80211_hw *hw,
 	/* Clear unsupported feature flags */
 	*total_flags &= FIF_ALLMULTI | FIF_BCN_PRBRESP_PROMISC;
 
-	if (mwl8k_fw_lock(hw))
+	if (mwl8k_fw_lock(hw)) {
+		kfree(cmd);
 		return;
+	}
 
 	if (priv->sniffer_enabled) {
 		mwl8k_enable_sniffer(hw, 0);
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 27bf887..9deae41 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -340,7 +340,7 @@ static int rt2800_blink_set(struct led_classdev *led_cdev,
 	rt2x00_set_field32(&reg, LED_CFG_OFF_PERIOD, *delay_off);
 	rt2x00_set_field32(&reg, LED_CFG_SLOW_BLINK_PERIOD, 3);
 	rt2x00_set_field32(&reg, LED_CFG_R_LED_MODE, 3);
-	rt2x00_set_field32(&reg, LED_CFG_G_LED_MODE, 12);
+	rt2x00_set_field32(&reg, LED_CFG_G_LED_MODE, 3);
 	rt2x00_set_field32(&reg, LED_CFG_Y_LED_MODE, 3);
 	rt2x00_set_field32(&reg, LED_CFG_LED_POLAR, 1);
 	rt2800_register_write(led->rt2x00dev, LED_CFG, reg);
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 4d841c0..dcfc8c2 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -113,6 +113,12 @@
 	(  ((unsigned long)((__skb)->data + (__header))) & 3 )
 
 /*
+ * Constants for extra TX headroom for alignment purposes.
+ */
+#define RT2X00_ALIGN_SIZE	4 /* Only whole frame needs alignment */
+#define RT2X00_L2PAD_SIZE	8 /* Both header & payload need alignment */
+
+/*
  * Standard timing and size defines.
  * These values should follow the ieee80211 specifications.
  */
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 06c43ca..265e66d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -686,7 +686,17 @@ static int rt2x00lib_probe_hw(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Initialize extra TX headroom required.
 	 */
-	rt2x00dev->hw->extra_tx_headroom = rt2x00dev->ops->extra_tx_headroom;
+	rt2x00dev->hw->extra_tx_headroom =
+		max_t(unsigned int, IEEE80211_TX_STATUS_HEADROOM,
+		      rt2x00dev->ops->extra_tx_headroom);
+
+	/*
+	 * Take TX headroom required for alignment into account.
+	 */
+	if (test_bit(DRIVER_REQUIRE_L2PAD, &rt2x00dev->flags))
+		rt2x00dev->hw->extra_tx_headroom += RT2X00_L2PAD_SIZE;
+	else if (test_bit(DRIVER_REQUIRE_DMA, &rt2x00dev->flags))
+		rt2x00dev->hw->extra_tx_headroom += RT2X00_ALIGN_SIZE;
 
 	/*
 	 * Register HW.
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 239afc7..9915a09 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -104,7 +104,7 @@ void rt2x00queue_map_txskb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb)
 	 * is also mapped to the DMA so it can be used for transfering
 	 * additional descriptor information to the hardware.
 	 */
-	skb_push(skb, rt2x00dev->hw->extra_tx_headroom);
+	skb_push(skb, rt2x00dev->ops->extra_tx_headroom);
 
 	skbdesc->skb_dma =
 	    dma_map_single(rt2x00dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
@@ -112,7 +112,7 @@ void rt2x00queue_map_txskb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb)
 	/*
 	 * Restore data pointer to original location again.
 	 */
-	skb_pull(skb, rt2x00dev->hw->extra_tx_headroom);
+	skb_pull(skb, rt2x00dev->ops->extra_tx_headroom);
 
 	skbdesc->flags |= SKBDESC_DMA_MAPPED_TX;
 }
@@ -134,7 +134,7 @@ void rt2x00queue_unmap_skb(struct rt2x00_dev *rt2x00dev, struct sk_buff *skb)
 		 * by the driver, but it was actually mapped to DMA.
 		 */
 		dma_unmap_single(rt2x00dev->dev, skbdesc->skb_dma,
-				 skb->len + rt2x00dev->hw->extra_tx_headroom,
+				 skb->len + rt2x00dev->ops->extra_tx_headroom,
 				 DMA_TO_DEVICE);
 		skbdesc->flags &= ~SKBDESC_DMA_MAPPED_TX;
 	}
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index cc648ef..9d9b263 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -987,12 +987,13 @@ static void zd_op_configure_filter(struct ieee80211_hw *hw,
 	changed_flags &= SUPPORTED_FIF_FLAGS;
 	*new_flags &= SUPPORTED_FIF_FLAGS;
 
-	/* changed_flags is always populated but this driver
-	 * doesn't support all FIF flags so its possible we don't
-	 * need to do anything */
-	if (!changed_flags)
-		return;
-
+	/*
+	 * If multicast parameter (as returned by zd_op_prepare_multicast)
+	 * has changed, no bit in changed_flags is set. To handle this
+	 * situation, we do not return if changed_flags is 0. If we do so,
+	 * we will have some issue with IPv6 which uses multicast for link
+	 * layer address resolution.
+	 */
 	if (*new_flags & (FIF_PROMISC_IN_BSS | FIF_ALLMULTI))
 		zd_mc_add_all(&hash);
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 80c16f6..32abae3 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -15,12 +15,14 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/mac80211.h>
+#include <net/ieee80211_radiotap.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
 #include "debugfs_netdev.h"
 #include "mesh.h"
 #include "led.h"
 #include "driver-ops.h"
+#include "wme.h"
 
 /**
  * DOC: Interface list locking
@@ -314,7 +316,7 @@ static int ieee80211_open(struct net_device *dev)
 	if (sdata->vif.type == NL80211_IFTYPE_STATION)
 		ieee80211_queue_work(&local->hw, &sdata->u.mgd.work);
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
  err_del_interface:
@@ -343,7 +345,7 @@ static int ieee80211_stop(struct net_device *dev)
 	/*
 	 * Stop TX on this interface first.
 	 */
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	/*
 	 * Now delete all active aggregation sessions.
@@ -644,6 +646,12 @@ static void ieee80211_teardown_sdata(struct net_device *dev)
 	WARN_ON(flushed);
 }
 
+static u16 ieee80211_netdev_select_queue(struct net_device *dev,
+					 struct sk_buff *skb)
+{
+	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
+}
+
 static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_open		= ieee80211_open,
 	.ndo_stop		= ieee80211_stop,
@@ -652,8 +660,38 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_set_multicast_list = ieee80211_set_multicast_list,
 	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_select_queue	= ieee80211_netdev_select_queue,
 };
 
+static u16 ieee80211_monitor_select_queue(struct net_device *dev,
+					  struct sk_buff *skb)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = sdata->local;
+	struct ieee80211_hdr *hdr;
+	struct ieee80211_radiotap_header *rtap = (void *)skb->data;
+	u8 *p;
+
+	if (local->hw.queues < 4)
+		return 0;
+
+	if (skb->len < 4 ||
+	    skb->len < le16_to_cpu(rtap->it_len) + 2 /* frame control */)
+		return 0; /* doesn't matter, frame will be dropped */
+
+	hdr = (void *)((u8 *)skb->data + le16_to_cpu(rtap->it_len));
+
+	if (!ieee80211_is_data_qos(hdr->frame_control)) {
+		skb->priority = 7;
+		return ieee802_1d_to_ac[skb->priority];
+	}
+
+	p = ieee80211_get_qos_ctl(hdr);
+	skb->priority = *p & IEEE80211_QOS_CTL_TAG1D_MASK;
+
+	return ieee80211_downgrade_queue(local, skb);
+}
+
 static const struct net_device_ops ieee80211_monitorif_ops = {
 	.ndo_open		= ieee80211_open,
 	.ndo_stop		= ieee80211_stop,
@@ -662,6 +700,7 @@ static const struct net_device_ops ieee80211_monitorif_ops = {
 	.ndo_set_multicast_list = ieee80211_set_multicast_list,
 	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_select_queue	= ieee80211_monitor_select_queue,
 };
 
 static void ieee80211_if_setup(struct net_device *dev)
@@ -768,8 +807,8 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 	ASSERT_RTNL();
 
-	ndev = alloc_netdev(sizeof(*sdata) + local->hw.vif_data_size,
-			    name, ieee80211_if_setup);
+	ndev = alloc_netdev_mq(sizeof(*sdata) + local->hw.vif_data_size,
+			       name, ieee80211_if_setup, local->hw.queues);
 	if (!ndev)
 		return -ENOMEM;
 	dev_net_set(ndev, wiphy_net(local->hw.wiphy));
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index c79e59f..05a18f4 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -942,7 +942,7 @@ static void ieee80211_set_associated(struct ieee80211_sub_if_data *sdata,
 	ieee80211_recalc_ps(local, -1);
 	mutex_unlock(&local->iflist_mtx);
 
-	netif_start_queue(sdata->dev);
+	netif_tx_start_all_queues(sdata->dev);
 	netif_carrier_on(sdata->dev);
 }
 
@@ -1074,7 +1074,7 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 	 * time -- we don't want the scan code to enable queues.
 	 */
 
-	netif_stop_queue(sdata->dev);
+	netif_tx_stop_all_queues(sdata->dev);
 	netif_carrier_off(sdata->dev);
 
 	rcu_read_lock();
@@ -1963,7 +1963,9 @@ static void ieee80211_sta_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 			rma = ieee80211_rx_mgmt_disassoc(sdata, mgmt, skb->len);
 			break;
 		case IEEE80211_STYPE_ACTION:
-			/* XXX: differentiate, can only happen for CSA now! */
+			if (mgmt->u.action.category != WLAN_CATEGORY_SPECTRUM_MGMT)
+				break;
+
 			ieee80211_sta_process_chanswitch(sdata,
 					&mgmt->u.action.u.chan_switch.sw_elem,
 					ifmgd->associated);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 9f2807a..82a30c1 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1746,7 +1746,9 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 			memset(info, 0, sizeof(*info));
 			info->flags |= IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 			info->control.vif = &rx->sdata->vif;
-			ieee80211_select_queue(local, fwd_skb);
+			skb_set_queue_mapping(skb,
+				ieee80211_select_queue(rx->sdata, fwd_skb));
+			ieee80211_set_qos_hdr(local, skb);
 			if (is_multicast_ether_addr(fwd_hdr->addr1))
 				IEEE80211_IFSTA_MESH_CTR_INC(&sdata->u.mesh,
 								fwded_mcast);
@@ -2013,6 +2015,10 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 		}
 		break;
 	default:
+		/* do not process rejected action frames */
+		if (mgmt->u.action.category & 0x80)
+			return RX_DROP_MONITOR;
+
 		return RX_CONTINUE;
 	}
 
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index f1a4c71..f934c96 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -353,10 +353,10 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw, bool aborted)
 		if (sdata->vif.type == NL80211_IFTYPE_STATION) {
 			if (sdata->u.mgd.associated) {
 				ieee80211_scan_ps_disable(sdata);
-				netif_wake_queue(sdata->dev);
+				netif_tx_wake_all_queues(sdata->dev);
 			}
 		} else
-			netif_wake_queue(sdata->dev);
+			netif_tx_wake_all_queues(sdata->dev);
 
 		/* re-enable beaconing */
 		if (sdata->vif.type == NL80211_IFTYPE_AP ||
@@ -411,7 +411,7 @@ static int ieee80211_start_sw_scan(struct ieee80211_local *local)
 		 * are handled in the scan state machine
 		 */
 		if (sdata->vif.type != NL80211_IFTYPE_STATION)
-			netif_stop_queue(sdata->dev);
+			netif_tx_stop_all_queues(sdata->dev);
 	}
 	mutex_unlock(&local->iflist_mtx);
 
@@ -575,7 +575,7 @@ static void ieee80211_scan_state_leave_oper_channel(struct ieee80211_local *loca
 			continue;
 
 		if (sdata->vif.type == NL80211_IFTYPE_STATION) {
-			netif_stop_queue(sdata->dev);
+			netif_tx_stop_all_queues(sdata->dev);
 			if (sdata->u.mgd.associated)
 				ieee80211_scan_ps_enable(sdata);
 		}
@@ -610,7 +610,7 @@ static void ieee80211_scan_state_enter_oper_channel(struct ieee80211_local *loca
 		if (sdata->vif.type == NL80211_IFTYPE_STATION) {
 			if (sdata->u.mgd.associated)
 				ieee80211_scan_ps_disable(sdata);
-			netif_wake_queue(sdata->dev);
+			netif_tx_wake_all_queues(sdata->dev);
 		}
 	}
 	mutex_unlock(&local->iflist_mtx);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 27ceaef..ac210b5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1512,7 +1512,7 @@ static void ieee80211_xmit(struct ieee80211_sub_if_data *sdata,
 				return;
 			}
 
-	ieee80211_select_queue(local, skb);
+	ieee80211_set_qos_hdr(local, skb);
 	ieee80211_tx(sdata, skb, false);
 	rcu_read_unlock();
 }
@@ -2291,6 +2291,9 @@ void ieee80211_tx_skb(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 	skb_set_network_header(skb, 0);
 	skb_set_transport_header(skb, 0);
 
+	/* send all internal mgmt frames on VO */
+	skb_set_queue_mapping(skb, 0);
+
 	/*
 	 * The other path calling ieee80211_xmit is from the tasklet,
 	 * and while we can handle concurrent transmissions locking
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index dc76267..3848140 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -269,6 +269,7 @@ static void __ieee80211_wake_queue(struct ieee80211_hw *hw, int queue,
 				   enum queue_stop_reason reason)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_sub_if_data *sdata;
 
 	if (WARN_ON(queue >= hw->queues))
 		return;
@@ -281,6 +282,11 @@ static void __ieee80211_wake_queue(struct ieee80211_hw *hw, int queue,
 
 	if (!skb_queue_empty(&local->pending[queue]))
 		tasklet_schedule(&local->tx_pending_tasklet);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list)
+		netif_tx_wake_queue(netdev_get_tx_queue(sdata->dev, queue));
+	rcu_read_unlock();
 }
 
 void ieee80211_wake_queue_by_reason(struct ieee80211_hw *hw, int queue,
@@ -305,11 +311,17 @@ static void __ieee80211_stop_queue(struct ieee80211_hw *hw, int queue,
 				   enum queue_stop_reason reason)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_sub_if_data *sdata;
 
 	if (WARN_ON(queue >= hw->queues))
 		return;
 
 	__set_bit(reason, &local->queue_stop_reasons[queue]);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &local->interfaces, list)
+		netif_tx_stop_queue(netdev_get_tx_queue(sdata->dev, queue));
+	rcu_read_unlock();
 }
 
 void ieee80211_stop_queue_by_reason(struct ieee80211_hw *hw, int queue,
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index b19b769..79d887d 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -44,22 +44,69 @@ static int wme_downgrade_ac(struct sk_buff *skb)
 }
 
 
-/* Indicate which queue to use.  */
-static u16 classify80211(struct ieee80211_local *local, struct sk_buff *skb)
+/* Indicate which queue to use. */
+u16 ieee80211_select_queue(struct ieee80211_sub_if_data *sdata,
+			   struct sk_buff *skb)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_local *local = sdata->local;
+	struct sta_info *sta = NULL;
+	u32 sta_flags = 0;
+	const u8 *ra = NULL;
+	bool qos = false;
 
-	if (!ieee80211_is_data(hdr->frame_control)) {
-		/* management frames go on AC_VO queue, but are sent
-		* without QoS control fields */
-		return 0;
+	if (local->hw.queues < 4 || skb->len < 6) {
+		skb->priority = 0; /* required for correct WPA/11i MIC */
+		return min_t(u16, local->hw.queues - 1,
+			     ieee802_1d_to_ac[skb->priority]);
+	}
+
+	rcu_read_lock();
+	switch (sdata->vif.type) {
+	case NL80211_IFTYPE_AP_VLAN:
+		rcu_read_lock();
+		sta = rcu_dereference(sdata->u.vlan.sta);
+		if (sta)
+			sta_flags = get_sta_flags(sta);
+		rcu_read_unlock();
+		if (sta)
+			break;
+	case NL80211_IFTYPE_AP:
+		ra = skb->data;
+		break;
+	case NL80211_IFTYPE_WDS:
+		ra = sdata->u.wds.remote_addr;
+		break;
+#ifdef CONFIG_MAC80211_MESH
+	case NL80211_IFTYPE_MESH_POINT:
+		/*
+		 * XXX: This is clearly broken ... but already was before,
+		 * because ieee80211_fill_mesh_addresses() would clear A1
+		 * except for multicast addresses.
+		 */
+		break;
+#endif
+	case NL80211_IFTYPE_STATION:
+		ra = sdata->u.mgd.bssid;
+		break;
+	case NL80211_IFTYPE_ADHOC:
+		ra = skb->data;
+		break;
+	default:
+		break;
 	}
 
-	if (0 /* injected */) {
-		/* use AC from radiotap */
+	if (!sta && ra && !is_multicast_ether_addr(ra)) {
+		sta = sta_info_get(local, ra);
+		if (sta)
+			sta_flags = get_sta_flags(sta);
 	}
 
-	if (!ieee80211_is_data_qos(hdr->frame_control)) {
+	if (sta_flags & WLAN_STA_WME)
+		qos = true;
+
+	rcu_read_unlock();
+
+	if (!qos) {
 		skb->priority = 0; /* required for correct WPA/11i MIC */
 		return ieee802_1d_to_ac[skb->priority];
 	}
@@ -68,6 +115,12 @@ static u16 classify80211(struct ieee80211_local *local, struct sk_buff *skb)
 	 * data frame has */
 	skb->priority = cfg80211_classify8021d(skb);
 
+	return ieee80211_downgrade_queue(local, skb);
+}
+
+u16 ieee80211_downgrade_queue(struct ieee80211_local *local,
+			      struct sk_buff *skb)
+{
 	/* in case we are a client verify acm is not set for this ac */
 	while (unlikely(local->wmm_acm & BIT(skb->priority))) {
 		if (wme_downgrade_ac(skb)) {
@@ -85,24 +138,17 @@ static u16 classify80211(struct ieee80211_local *local, struct sk_buff *skb)
 	return ieee802_1d_to_ac[skb->priority];
 }
 
-void ieee80211_select_queue(struct ieee80211_local *local, struct sk_buff *skb)
+void ieee80211_set_qos_hdr(struct ieee80211_local *local, struct sk_buff *skb)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	u16 queue;
-	u8 tid;
-
-	queue = classify80211(local, skb);
-	if (unlikely(queue >= local->hw.queues))
-		queue = local->hw.queues - 1;
-
-	/*
-	 * Now we know the 1d priority, fill in the QoS header if
-	 * there is one (and we haven't done this before).
-	 */
+	struct ieee80211_hdr *hdr = (void *)skb->data;
+
+	/* Fill in the QoS header if there is one. */
 	if (ieee80211_is_data_qos(hdr->frame_control)) {
 		u8 *p = ieee80211_get_qos_ctl(hdr);
-		u8 ack_policy = 0;
+		u8 ack_policy = 0, tid;
+
 		tid = skb->priority & IEEE80211_QOS_CTL_TAG1D_MASK;
+
 		if (unlikely(local->wifi_wme_noack_test))
 			ack_policy |= QOS_CONTROL_ACK_POLICY_NOACK <<
 					QOS_CONTROL_ACK_POLICY_SHIFT;
@@ -110,6 +156,4 @@ void ieee80211_select_queue(struct ieee80211_local *local, struct sk_buff *skb)
 		*p++ = ack_policy | tid;
 		*p = 0;
 	}
-
-	skb_set_queue_mapping(skb, queue);
 }
diff --git a/net/mac80211/wme.h b/net/mac80211/wme.h
index d4fd87c..6053b1c 100644
--- a/net/mac80211/wme.h
+++ b/net/mac80211/wme.h
@@ -20,7 +20,11 @@
 
 extern const int ieee802_1d_to_ac[8];
 
-void ieee80211_select_queue(struct ieee80211_local *local,
-			    struct sk_buff *skb);
+u16 ieee80211_select_queue(struct ieee80211_sub_if_data *sdata,
+			   struct sk_buff *skb);
+void ieee80211_set_qos_hdr(struct ieee80211_local *local, struct sk_buff *skb);
+u16 ieee80211_downgrade_queue(struct ieee80211_local *local,
+                              struct sk_buff *skb);
+
 
 #endif /* _WME_H */
diff --git a/net/wireless/core.c b/net/wireless/core.c
index c2a2c56..92b8124 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -745,9 +745,9 @@ static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 			mutex_unlock(&rdev->devlist_mtx);
 			dev_put(dev);
 		}
-#ifdef CONFIG_CFG80211_WEXT
 		cfg80211_lock_rdev(rdev);
 		mutex_lock(&rdev->devlist_mtx);
+#ifdef CONFIG_CFG80211_WEXT
 		wdev_lock(wdev);
 		switch (wdev->iftype) {
 		case NL80211_IFTYPE_ADHOC:
@@ -760,10 +760,10 @@ static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 			break;
 		}
 		wdev_unlock(wdev);
+#endif
 		rdev->opencount++;
 		mutex_unlock(&rdev->devlist_mtx);
 		cfg80211_unlock_rdev(rdev);
-#endif
 		break;
 	case NETDEV_UNREGISTER:
 		/*
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index baa898a..7a0754c 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1690,7 +1690,7 @@ int regulatory_hint_user(const char *alpha2)
 	request->wiphy_idx = WIPHY_IDX_STALE;
 	request->alpha2[0] = alpha2[0];
 	request->alpha2[1] = alpha2[1];
-	request->initiator = NL80211_REGDOM_SET_BY_USER,
+	request->initiator = NL80211_REGDOM_SET_BY_USER;
 
 	queue_regulatory_request(request);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
