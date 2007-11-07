From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 6 Nov 2007 19:13:14 -0500
Message-ID: <20071107001314.GH4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3818 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754991AbXKGANt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 19:13:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some fixes for 2.6.24...

The iwlwifi patch is needed because the iwlwifi drivers routinely end-up
associated with the "simple" rate control algorithm, yet those drivers
really only work with their own custom algorithms.  The other rate
control patches are there to satisfy dependencies for this patch.

"mac80211: remove ieee80211_common.h" cleans-up an unused file left
hanging-around after an earlier patch already in 2.6.24.

"mac80211: remove unused driver ops" is really a clean-up, but
"mac80211: use IW_AUTH_PRIVACY_INVOKED rather than IW_AUTH_KEY_MGMT"
depends on it.

"ssb: Fix initcall ordering" changes a subsys_initcall to an
fs_initcall.  This seems like a bit of a hack, but it fixes a real
problem and I'm not sure what cleaner solution is either reasonable
or available.  The comment in the patch explains the reasoning for this
somewhat unique situation.

I think the other patches are plain enough to not require further
comment.  Let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem/

---

The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
  Alan Cox (1):
        ata_piix: Add additional PCI identifier for 40 wire short cable

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Johannes Berg (9):
      softmac: fix wext MLME request reason code endianness
      mac80211: make simple rate control algorithm built-in
      mac80211: don't allow registering the same rate control twice
      mac80211: allow driver to ask for a rate control algorithm
      iwlwifi: select proper rate control algorithm
      softmac: MAINTAINERS update
      mac80211: remove ieee80211_common.h
      mac80211: remove unused driver ops
      mac80211: use IW_AUTH_PRIVACY_INVOKED rather than IW_AUTH_KEY_MGMT

John W. Linville (1):
      mac80211: make "decrypt failed" messages conditional upon MAC80211_DEBUG

Michael Buesch (5):
      ssb: Fix initcall ordering
      rfkill: Register LED triggers before registering switch
      rfkill: Use subsys_initcall
      rfkill: Use mutex_lock() at register and add sanity check
      rfkill: Fix sparse warning

 MAINTAINERS                                 |    7 +--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    2 +
 drivers/ssb/main.c                          |    5 +-
 include/net/mac80211.h                      |   26 ++------
 net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
 net/mac80211/Kconfig                        |   12 ++++
 net/mac80211/Makefile                       |    3 +-
 net/mac80211/ieee80211.c                    |   16 +++++-
 net/mac80211/ieee80211_common.h             |   91 ---------------------------
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/ieee80211_ioctl.c              |   21 +++----
 net/mac80211/ieee80211_rate.c               |   24 ++++++-
 net/mac80211/ieee80211_rate.h               |    3 +
 net/mac80211/ieee80211_sta.c                |   18 +++--
 net/mac80211/rc80211_simple.c               |   25 +-------
 net/mac80211/rx.c                           |    2 +
 net/mac80211/wep.c                          |    2 +
 net/mac80211/wpa.c                          |   18 ++++--
 net/rfkill/rfkill.c                         |   37 ++++++-----
 20 files changed, 126 insertions(+), 192 deletions(-)
 delete mode 100644 net/mac80211/ieee80211_common.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c7c229..095522f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3452,15 +3452,10 @@ L:	lm-sensors@lm-sensors.org
 S:	Maintained
 
 SOFTMAC LAYER (IEEE 802.11)
-P:	Johannes Berg
-M:	johannes@sipsolutions.net
-P:	Joe Jezak
-M:	josejx@gentoo.org
 P:	Daniel Drake
 M:	dsd@gentoo.org
-W:	http://softmac.sipsolutions.net/
 L:	linux-wireless@vger.kernel.org
-S:	Maintained
+S:	Obsolete
 
 SOFTWARE RAID (Multiple Disks) SUPPORT
 P:	Ingo Molnar
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4f22a71..be7c9f4 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -8354,6 +8354,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	SET_IEEE80211_DEV(hw, &pdev->dev);
 
+	hw->rate_control_algorithm = "iwl-3945-rs";
+
 	IWL_DEBUG_INFO("*** LOAD DRIVER ***\n");
 	priv = hw->priv;
 	priv->hw = hw;
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d60adcb..6757c6c 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -8955,6 +8955,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	SET_IEEE80211_DEV(hw, &pdev->dev);
 
+	hw->rate_control_algorithm = "iwl-4965-rs";
+
 	IWL_DEBUG_INFO("*** LOAD DRIVER ***\n");
 	priv = hw->priv;
 	priv->hw = hw;
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index c12a741..fc1d589 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1147,7 +1147,10 @@ static int __init ssb_modinit(void)
 
 	return err;
 }
-subsys_initcall(ssb_modinit);
+/* ssb must be initialized after PCI but before the ssb drivers.
+ * That means we must use some initcall between subsys_initcall
+ * and device_initcall. */
+fs_initcall(ssb_modinit);
 
 static void __exit ssb_modexit(void)
 {
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5fcc4c1..17b6039 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -706,11 +706,16 @@ enum ieee80211_hw_flags {
  *
  * @queues: number of available hardware transmit queues for
  *	data packets. WMM/QoS requires at least four.
+ *
+ * @rate_control_algorithm: rate control algorithm for this hardware.
+ *	If unset (NULL), the default algorithm will be used. Must be
+ *	set before calling ieee80211_register_hw().
  */
 struct ieee80211_hw {
 	struct ieee80211_conf conf;
 	struct wiphy *wiphy;
 	struct workqueue_struct *workqueue;
+	const char *rate_control_algorithm;
 	void *priv;
 	u32 flags;
 	unsigned int extra_tx_headroom;
@@ -936,27 +941,11 @@ enum ieee80211_erp_change_flags {
  *	and remove_interface calls, i.e. while the interface with the
  *	given local_address is enabled.
  *
- * @set_ieee8021x: Enable/disable IEEE 802.1X. This item requests wlan card
- *	to pass unencrypted EAPOL-Key frames even when encryption is
- *	configured. If the wlan card does not require such a configuration,
- *	this function pointer can be set to NULL.
- *
- * @set_port_auth: Set port authorization state (IEEE 802.1X PAE) to be
- *	authorized (@authorized=1) or unauthorized (=0). This function can be
- *	used if the wlan hardware or low-level driver implements PAE.
- *	mac80211 will filter frames based on authorization state in any case,
- *	so this function pointer can be NULL if low-level driver does not
- *	require event notification about port state changes.
- *
  * @hw_scan: Ask the hardware to service the scan request, no need to start
  *	the scan state machine in stack.
  *
  * @get_stats: return low-level statistics
  *
- * @set_privacy_invoked: For devices that generate their own beacons and probe
- *	response or association responses this updates the state of privacy_invoked
- *	returns 0 for success or an error number.
- *
  * @get_sequence_counter: For devices that have internal sequence counters this
  *	callback allows mac80211 to access the current value of a counter.
  *	This callback seems not well-defined, tell us if you need it.
@@ -1029,14 +1018,9 @@ struct ieee80211_ops {
 	int (*set_key)(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		       const u8 *local_address, const u8 *address,
 		       struct ieee80211_key_conf *key);
-	int (*set_ieee8021x)(struct ieee80211_hw *hw, int use_ieee8021x);
-	int (*set_port_auth)(struct ieee80211_hw *hw, u8 *addr,
-			     int authorized);
 	int (*hw_scan)(struct ieee80211_hw *hw, u8 *ssid, size_t len);
 	int (*get_stats)(struct ieee80211_hw *hw,
 			 struct ieee80211_low_level_stats *stats);
-	int (*set_privacy_invoked)(struct ieee80211_hw *hw,
-				   int privacy_invoked);
 	int (*get_sequence_counter)(struct ieee80211_hw *hw,
 				    u8* addr, u8 keyidx, u8 txrx,
 				    u32* iv32, u16* iv16);
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index ac36767..e01b59a 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -470,7 +470,7 @@ ieee80211softmac_wx_set_mlme(struct net_device *dev,
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	struct iw_mlme *mlme = (struct iw_mlme *)extra;
-	u16 reason = cpu_to_le16(mlme->reason_code);
+	u16 reason = mlme->reason_code;
 	struct ieee80211softmac_network *net;
 	int err = -EINVAL;
 
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 6fffb38..32c8c08 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -13,6 +13,18 @@ config MAC80211
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
 
+config MAC80211_RCSIMPLE
+	bool "'simple' rate control algorithm"
+	default y
+	depends on MAC80211 && EMBEDDED
+	help
+	  This option allows you to turn off the 'simple' rate
+	  control algorithm in mac80211. If you do turn it off,
+	  you absolutely need another rate control algorithm.
+
+	  Say Y unless you know you will have another algorithm
+	  available.
+
 config MAC80211_LEDS
 	bool "Enable LED triggers"
 	depends on MAC80211 && LEDS_TRIGGERS
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 219cd9f..1e6237b 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -1,8 +1,9 @@
-obj-$(CONFIG_MAC80211) += mac80211.o rc80211_simple.o
+obj-$(CONFIG_MAC80211) += mac80211.o
 
 mac80211-objs-$(CONFIG_MAC80211_LEDS) += ieee80211_led.o
 mac80211-objs-$(CONFIG_MAC80211_DEBUGFS) += debugfs.o debugfs_sta.o debugfs_netdev.o debugfs_key.o
 mac80211-objs-$(CONFIG_NET_SCHED) += wme.o
+mac80211-objs-$(CONFIG_MAC80211_RCSIMPLE) += rc80211_simple.o
 
 mac80211-objs := \
 	ieee80211.o \
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index f484ca7..e0ee65a 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -1072,7 +1072,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	ieee80211_debugfs_add_netdev(IEEE80211_DEV_TO_SUB_IF(local->mdev));
 	ieee80211_if_set_type(local->mdev, IEEE80211_IF_TYPE_AP);
 
-	result = ieee80211_init_rate_ctrl_alg(local, NULL);
+	result = ieee80211_init_rate_ctrl_alg(local,
+					      hw->rate_control_algorithm);
 	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
 		       "algorithm\n", wiphy_name(local->hw.wiphy));
@@ -1233,8 +1234,17 @@ static int __init ieee80211_init(void)
 
 	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
 
+#ifdef CONFIG_MAC80211_RCSIMPLE
+	ret = ieee80211_rate_control_register(&mac80211_rcsimple);
+	if (ret)
+		return ret;
+#endif
+
 	ret = ieee80211_wme_register();
 	if (ret) {
+#ifdef CONFIG_MAC80211_RCSIMPLE
+		ieee80211_rate_control_unregister(&mac80211_rcsimple);
+#endif
 		printk(KERN_DEBUG "ieee80211_init: failed to "
 		       "initialize WME (err=%d)\n", ret);
 		return ret;
@@ -1248,6 +1258,10 @@ static int __init ieee80211_init(void)
 
 static void __exit ieee80211_exit(void)
 {
+#ifdef CONFIG_MAC80211_RCSIMPLE
+	ieee80211_rate_control_unregister(&mac80211_rcsimple);
+#endif
+
 	ieee80211_wme_unregister();
 	ieee80211_debugfs_netdev_exit();
 }
diff --git a/net/mac80211/ieee80211_common.h b/net/mac80211/ieee80211_common.h
deleted file mode 100644
index c15295d..0000000
--- a/net/mac80211/ieee80211_common.h
+++ /dev/null
@@ -1,91 +0,0 @@
-/*
- * IEEE 802.11 driver (80211.o) -- hostapd interface
- * Copyright 2002-2004, Instant802 Networks, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef IEEE80211_COMMON_H
-#define IEEE80211_COMMON_H
-
-#include <linux/types.h>
-
-/*
- * This is common header information with user space. It is used on all
- * frames sent to wlan#ap interface.
- */
-
-#define IEEE80211_FI_VERSION 0x80211001
-
-struct ieee80211_frame_info {
-	__be32 version;
-	__be32 length;
-	__be64 mactime;
-	__be64 hosttime;
-	__be32 phytype;
-	__be32 channel;
-	__be32 datarate;
-	__be32 antenna;
-	__be32 priority;
-	__be32 ssi_type;
-	__be32 ssi_signal;
-	__be32 ssi_noise;
-	__be32 preamble;
-	__be32 encoding;
-
-	/* Note: this structure is otherwise identical to capture format used
-	 * in linux-wlan-ng, but this additional field is used to provide meta
-	 * data about the frame to hostapd. This was the easiest method for
-	 * providing this information, but this might change in the future. */
-	__be32 msg_type;
-} __attribute__ ((packed));
-
-
-enum ieee80211_msg_type {
-	ieee80211_msg_normal = 0,
-	ieee80211_msg_tx_callback_ack = 1,
-	ieee80211_msg_tx_callback_fail = 2,
-	/* hole at 3, was ieee80211_msg_passive_scan but unused */
-	/* hole at 4, was ieee80211_msg_wep_frame_unknown_key but now unused */
-	ieee80211_msg_michael_mic_failure = 5,
-	/* hole at 6, was monitor but never sent to userspace */
-	ieee80211_msg_sta_not_assoc = 7,
-	/* 8 was ieee80211_msg_set_aid_for_sta */
-	/* 9 was ieee80211_msg_key_threshold_notification */
-	/* 11 was ieee80211_msg_radar */
-};
-
-struct ieee80211_msg_key_notification {
-	int tx_rx_count;
-	char ifname[IFNAMSIZ];
-	u8 addr[ETH_ALEN]; /* ff:ff:ff:ff:ff:ff for broadcast keys */
-};
-
-
-enum ieee80211_phytype {
-	ieee80211_phytype_fhss_dot11_97  = 1,
-	ieee80211_phytype_dsss_dot11_97  = 2,
-	ieee80211_phytype_irbaseband     = 3,
-	ieee80211_phytype_dsss_dot11_b   = 4,
-	ieee80211_phytype_pbcc_dot11_b   = 5,
-	ieee80211_phytype_ofdm_dot11_g   = 6,
-	ieee80211_phytype_pbcc_dot11_g   = 7,
-	ieee80211_phytype_ofdm_dot11_a   = 8,
-};
-
-enum ieee80211_ssi_type {
-	ieee80211_ssi_none = 0,
-	ieee80211_ssi_norm = 1, /* normalized, 0-1000 */
-	ieee80211_ssi_dbm = 2,
-	ieee80211_ssi_raw = 3, /* raw SSI */
-};
-
-struct ieee80211_radar_info {
-		int channel;
-		int radar;
-		int radar_type;
-};
-
-#endif /* IEEE80211_COMMON_H */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 4b4ed2a..b4e32ab 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -230,6 +230,7 @@ struct ieee80211_if_vlan {
 #define IEEE80211_STA_AUTO_SSID_SEL	BIT(10)
 #define IEEE80211_STA_AUTO_BSSID_SEL	BIT(11)
 #define IEEE80211_STA_AUTO_CHANNEL_SEL	BIT(12)
+#define IEEE80211_STA_PRIVACY_INVOKED	BIT(13)
 struct ieee80211_if_sta {
 	enum {
 		IEEE80211_DISABLED, IEEE80211_AUTHENTICATE,
@@ -259,7 +260,6 @@ struct ieee80211_if_sta {
 	unsigned long request;
 	struct sk_buff_head skb_queue;
 
-	int key_management_enabled;
 	unsigned long last_probe;
 
 #define IEEE80211_AUTH_ALG_OPEN BIT(0)
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 6caa3ec..7027eed 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -917,7 +917,6 @@ static int ieee80211_ioctl_siwauth(struct net_device *dev,
 				   struct iw_request_info *info,
 				   struct iw_param *data, char *extra)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int ret = 0;
 
@@ -927,18 +926,21 @@ static int ieee80211_ioctl_siwauth(struct net_device *dev,
 	case IW_AUTH_CIPHER_GROUP:
 	case IW_AUTH_WPA_ENABLED:
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-		break;
 	case IW_AUTH_KEY_MGMT:
+		break;
+	case IW_AUTH_PRIVACY_INVOKED:
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			ret = -EINVAL;
 		else {
+			sdata->u.sta.flags &= ~IEEE80211_STA_PRIVACY_INVOKED;
 			/*
-			 * Key management was set by wpa_supplicant,
-			 * we only need this to associate to a network
-			 * that has privacy enabled regardless of not
-			 * having a key.
+			 * Privacy invoked by wpa_supplicant, store the
+			 * value and allow associating to a protected
+			 * network without having a key up front.
 			 */
-			sdata->u.sta.key_management_enabled = !!data->value;
+			if (data->value)
+				sdata->u.sta.flags |=
+					IEEE80211_STA_PRIVACY_INVOKED;
 		}
 		break;
 	case IW_AUTH_80211_AUTH_ALG:
@@ -948,11 +950,6 @@ static int ieee80211_ioctl_siwauth(struct net_device *dev,
 		else
 			ret = -EOPNOTSUPP;
 		break;
-	case IW_AUTH_PRIVACY_INVOKED:
-		if (local->ops->set_privacy_invoked)
-			ret = local->ops->set_privacy_invoked(
-					local_to_hw(local), data->value);
-		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 93abb8f..7254bd6 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -25,13 +25,25 @@ int ieee80211_rate_control_register(struct rate_control_ops *ops)
 {
 	struct rate_control_alg *alg;
 
+	if (!ops->name)
+		return -EINVAL;
+
+	mutex_lock(&rate_ctrl_mutex);
+	list_for_each_entry(alg, &rate_ctrl_algs, list) {
+		if (!strcmp(alg->ops->name, ops->name)) {
+			/* don't register an algorithm twice */
+			WARN_ON(1);
+			return -EALREADY;
+		}
+	}
+
 	alg = kzalloc(sizeof(*alg), GFP_KERNEL);
 	if (alg == NULL) {
+		mutex_unlock(&rate_ctrl_mutex);
 		return -ENOMEM;
 	}
 	alg->ops = ops;
 
-	mutex_lock(&rate_ctrl_mutex);
 	list_add_tail(&alg->list, &rate_ctrl_algs);
 	mutex_unlock(&rate_ctrl_mutex);
 
@@ -61,9 +73,12 @@ ieee80211_try_rate_control_ops_get(const char *name)
 	struct rate_control_alg *alg;
 	struct rate_control_ops *ops = NULL;
 
+	if (!name)
+		return NULL;
+
 	mutex_lock(&rate_ctrl_mutex);
 	list_for_each_entry(alg, &rate_ctrl_algs, list) {
-		if (!name || !strcmp(alg->ops->name, name))
+		if (!strcmp(alg->ops->name, name))
 			if (try_module_get(alg->ops->module)) {
 				ops = alg->ops;
 				break;
@@ -80,9 +95,12 @@ ieee80211_rate_control_ops_get(const char *name)
 {
 	struct rate_control_ops *ops;
 
+	if (!name)
+		name = "simple";
+
 	ops = ieee80211_try_rate_control_ops_get(name);
 	if (!ops) {
-		request_module("rc80211_%s", name ? name : "default");
+		request_module("rc80211_%s", name);
 		ops = ieee80211_try_rate_control_ops_get(name);
 	}
 	return ops;
diff --git a/net/mac80211/ieee80211_rate.h b/net/mac80211/ieee80211_rate.h
index 7cd1eba..2368813 100644
--- a/net/mac80211/ieee80211_rate.h
+++ b/net/mac80211/ieee80211_rate.h
@@ -65,6 +65,9 @@ struct rate_control_ref {
 	struct kref kref;
 };
 
+/* default 'simple' algorithm */
+extern struct rate_control_ops mac80211_rcsimple;
+
 int ieee80211_rate_control_register(struct rate_control_ops *ops);
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index fda0e06..2079e98 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -704,10 +704,11 @@ static int ieee80211_privacy_mismatch(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
-	int res = 0;
+	int bss_privacy;
+	int wep_privacy;
+	int privacy_invoked;
 
-	if (!ifsta || (ifsta->flags & IEEE80211_STA_MIXED_CELL) ||
-	    ifsta->key_management_enabled)
+	if (!ifsta || (ifsta->flags & IEEE80211_STA_MIXED_CELL))
 		return 0;
 
 	bss = ieee80211_rx_bss_get(dev, ifsta->bssid, local->hw.conf.channel,
@@ -715,13 +716,16 @@ static int ieee80211_privacy_mismatch(struct net_device *dev,
 	if (!bss)
 		return 0;
 
-	if (ieee80211_sta_wep_configured(dev) !=
-	    !!(bss->capability & WLAN_CAPABILITY_PRIVACY))
-		res = 1;
+	bss_privacy = !!(bss->capability & WLAN_CAPABILITY_PRIVACY);
+	wep_privacy = !!ieee80211_sta_wep_configured(dev);
+	privacy_invoked = !!(ifsta->flags & IEEE80211_STA_PRIVACY_INVOKED);
 
 	ieee80211_rx_bss_put(dev, bss);
 
-	return res;
+	if ((bss_privacy == wep_privacy) || (bss_privacy == privacy_invoked))
+		return 0;
+
+	return 1;
 }
 
 
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 314b8de..da72737 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -7,7 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
@@ -29,8 +28,6 @@
 #define RATE_CONTROL_INTERVAL (HZ / 20)
 #define RATE_CONTROL_MIN_TX 10
 
-MODULE_ALIAS("rc80211_default");
-
 static void rate_control_rate_inc(struct ieee80211_local *local,
 				  struct sta_info *sta)
 {
@@ -394,8 +391,7 @@ static void rate_control_simple_remove_sta_debugfs(void *priv, void *priv_sta)
 }
 #endif
 
-static struct rate_control_ops rate_control_simple = {
-	.module = THIS_MODULE,
+struct rate_control_ops mac80211_rcsimple = {
 	.name = "simple",
 	.tx_status = rate_control_simple_tx_status,
 	.get_rate = rate_control_simple_get_rate,
@@ -410,22 +406,3 @@ static struct rate_control_ops rate_control_simple = {
 	.remove_sta_debugfs = rate_control_simple_remove_sta_debugfs,
 #endif
 };
-
-
-static int __init rate_control_simple_init(void)
-{
-	return ieee80211_rate_control_register(&rate_control_simple);
-}
-
-
-static void __exit rate_control_simple_exit(void)
-{
-	ieee80211_rate_control_unregister(&rate_control_simple);
-}
-
-
-subsys_initcall(rate_control_simple_init);
-module_exit(rate_control_simple_exit);
-
-MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");
-MODULE_LICENSE("GPL");
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index ece7776..428a9fc 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -509,9 +509,11 @@ ieee80211_rx_h_decrypt(struct ieee80211_txrx_data *rx)
 		rx->key->tx_rx_count++;
 		/* TODO: add threshold stuff again */
 	} else {
+#ifdef CONFIG_MAC80211_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: RX protected frame,"
 			       " but have no key\n", rx->dev->name);
+#endif /* CONFIG_MAC80211_DEBUG */
 		return TXRX_DROP;
 	}
 
diff --git a/net/mac80211/wep.c b/net/mac80211/wep.c
index a84a233..9bf0e1c 100644
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -314,9 +314,11 @@ ieee80211_crypto_wep_decrypt(struct ieee80211_txrx_data *rx)
 
 	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED)) {
 		if (ieee80211_wep_decrypt(rx->local, rx->skb, rx->key)) {
+#ifdef CONFIG_MAC80211_DEBUG
 			if (net_ratelimit())
 				printk(KERN_DEBUG "%s: RX WEP frame, decrypt "
 				       "failed\n", rx->dev->name);
+#endif /* CONFIG_MAC80211_DEBUG */
 			return TXRX_DROP;
 		}
 	} else if (!(rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED)) {
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 6695efb..20cec1c 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -323,9 +323,12 @@ ieee80211_crypto_tkip_decrypt(struct ieee80211_txrx_data *rx)
 					  &rx->u.rx.tkip_iv32,
 					  &rx->u.rx.tkip_iv16);
 	if (res != TKIP_DECRYPT_OK || wpa_test) {
-		printk(KERN_DEBUG "%s: TKIP decrypt failed for RX frame from "
-		       "%s (res=%d)\n",
-		       rx->dev->name, print_mac(mac, rx->sta->addr), res);
+#ifdef CONFIG_MAC80211_DEBUG
+		if (net_ratelimit())
+			printk(KERN_DEBUG "%s: TKIP decrypt failed for RX "
+			       "frame from %s (res=%d)\n", rx->dev->name,
+			       print_mac(mac, rx->sta->addr), res);
+#endif /* CONFIG_MAC80211_DEBUG */
 		return TXRX_DROP;
 	}
 
@@ -594,9 +597,12 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_txrx_data *rx)
 			    skb->data + hdrlen + CCMP_HDR_LEN, data_len,
 			    skb->data + skb->len - CCMP_MIC_LEN,
 			    skb->data + hdrlen + CCMP_HDR_LEN)) {
-			printk(KERN_DEBUG "%s: CCMP decrypt failed for RX "
-			       "frame from %s\n", rx->dev->name,
-			       print_mac(mac, rx->sta->addr));
+#ifdef CONFIG_MAC80211_DEBUG
+			if (net_ratelimit())
+				printk(KERN_DEBUG "%s: CCMP decrypt failed "
+				       "for RX frame from %s\n", rx->dev->name,
+				       print_mac(mac, rx->sta->addr));
+#endif /* CONFIG_MAC80211_DEBUG */
 			return TXRX_DROP;
 		}
 	}
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 51d151c..73d60a3 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -27,6 +27,10 @@
 #include <linux/mutex.h>
 #include <linux/rfkill.h>
 
+/* Get declaration of rfkill_switch_all() to shut up sparse. */
+#include "rfkill-input.h"
+
+
 MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
 MODULE_VERSION("1.0");
 MODULE_DESCRIPTION("RF switch support");
@@ -276,21 +280,17 @@ static struct class rfkill_class = {
 
 static int rfkill_add_switch(struct rfkill *rfkill)
 {
-	int retval;
-
-	retval = mutex_lock_interruptible(&rfkill_mutex);
-	if (retval)
-		return retval;
+	int error;
 
-	retval = rfkill_toggle_radio(rfkill, rfkill_states[rfkill->type]);
-	if (retval)
-		goto out;
+	mutex_lock(&rfkill_mutex);
 
-	list_add_tail(&rfkill->node, &rfkill_list);
+	error = rfkill_toggle_radio(rfkill, rfkill_states[rfkill->type]);
+	if (!error)
+		list_add_tail(&rfkill->node, &rfkill_list);
 
- out:
 	mutex_unlock(&rfkill_mutex);
-	return retval;
+
+	return error;
 }
 
 static void rfkill_remove_switch(struct rfkill *rfkill)
@@ -387,20 +387,23 @@ int rfkill_register(struct rfkill *rfkill)
 
 	if (!rfkill->toggle_radio)
 		return -EINVAL;
+	if (rfkill->type >= RFKILL_TYPE_MAX)
+		return -EINVAL;
+
+	snprintf(dev->bus_id, sizeof(dev->bus_id),
+		 "rfkill%ld", (long)atomic_inc_return(&rfkill_no) - 1);
+
+	rfkill_led_trigger_register(rfkill);
 
 	error = rfkill_add_switch(rfkill);
 	if (error)
 		return error;
 
-	snprintf(dev->bus_id, sizeof(dev->bus_id),
-		 "rfkill%ld", (long)atomic_inc_return(&rfkill_no) - 1);
-
 	error = device_add(dev);
 	if (error) {
 		rfkill_remove_switch(rfkill);
 		return error;
 	}
-	rfkill_led_trigger_register(rfkill);
 
 	return 0;
 }
@@ -416,9 +419,9 @@ EXPORT_SYMBOL(rfkill_register);
  */
 void rfkill_unregister(struct rfkill *rfkill)
 {
-	rfkill_led_trigger_unregister(rfkill);
 	device_del(&rfkill->dev);
 	rfkill_remove_switch(rfkill);
+	rfkill_led_trigger_unregister(rfkill);
 	put_device(&rfkill->dev);
 }
 EXPORT_SYMBOL(rfkill_unregister);
@@ -448,5 +451,5 @@ static void __exit rfkill_exit(void)
 	class_unregister(&rfkill_class);
 }
 
-module_init(rfkill_init);
+subsys_initcall(rfkill_init);
 module_exit(rfkill_exit);
-- 
John W. Linville
linville@tuxdriver.com
