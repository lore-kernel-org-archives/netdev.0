From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Fri, 30 Nov 2007 21:23:06 -0500
Message-ID: <20071201022306.GA28032@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave/Herbert,

Here are a few intended for 2.6.25.  The bulk of them are the beginnings
of support for 802.11n in mac80211.  There is also a rework of the
support for devices which can run scans in hardware, and a couple of
additions to feature-removal-schedule.txt heralding the end of softmac.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem/

---

The following changes since commit 3b0c5b8640d12a566cb77f24162dce9bf5988263:
  Arnaldo Carvalho de Melo (1):
        [TFRC]: Hide tx history details from the CCIDs

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Johannes Berg (2):
      mac80211: make ieee80211_iterate_active_interfaces not need rtnl
      mac80211: allow setting drop_unencrypted with wext

John W. Linville (3):
      mac80211: remove "bcn_int" and "capab" scan results info
      bcm43xx: mark as obsolete and schedule for removal
      softmac: mark as obsolete and schedule for removal

Ron Rindjunsky (8):
      mac80211: restructuring data Rx handlers
      mac80211: adding MAC80211_HT_DEBUG config variable
      mac80211: adding 802.11n HT framework definitions
      mac80211: adding 802.11n IEs handling
      mac80211: adding 802.11n essential A-MPDU addBA capability
      mac80211: adding 802.11n essential A-MSDU Rx capability
      mac80211: adding 802.11n configuration flows
      mac80211: move A-MSDU identifier to flags

Zhu Yi (1):
      mac80211: hardware scan rework

 Documentation/feature-removal-schedule.txt |   17 ++
 MAINTAINERS                                |    2 +-
 drivers/net/wireless/bcm43xx/Kconfig       |    9 +-
 include/net/mac80211.h                     |   62 +++++-
 net/ieee80211/Kconfig                      |    5 +-
 net/mac80211/Kconfig                       |   10 +
 net/mac80211/ieee80211.c                   |   64 +++++-
 net/mac80211/ieee80211_i.h                 |   20 ++-
 net/mac80211/ieee80211_ioctl.c             |    9 +-
 net/mac80211/ieee80211_sta.c               |  336 ++++++++++++++++++++++++----
 net/mac80211/rx.c                          |  260 +++++++++++++++++----
 net/mac80211/sta_info.h                    |    3 +
 net/mac80211/tx.c                          |   14 +-
 net/mac80211/util.c                        |   21 +--
 14 files changed, 686 insertions(+), 146 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 20c4c8b..aeaa129 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -333,3 +333,20 @@ Why:	This driver has been marked obsolete for many years.
 Who:	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
 
 ---------------------------
+
+What:	bcm43xx wireless network driver
+When:	2.6.26
+Files:	drivers/net/wireless/bcm43xx
+Why:	This driver's functionality has been replaced by the
+	mac80211-based b43 and b43legacy drivers.
+Who:	John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
+
+---------------------------
+
+What:	iee80211 softmac wireless networking component
+When:	2.6.26 (or after removal of bcm43xx and port of zd1211rw to mac80211)
+Files:	net/ieee80211/softmac
+Why:	No in-kernel drivers will depend on it any longer.
+Who:	John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
+
+---------------------------
diff --git a/MAINTAINERS b/MAINTAINERS
index 488867e..3e7497d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -808,7 +808,7 @@ P:	Stefano Brivio
 M:	stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://bcm43xx.berlios.de/
-S:	Maintained
+S:	Obsolete
 
 BEFS FILE SYSTEM
 P:	Sergey S. Kostyliov
diff --git a/drivers/net/wireless/bcm43xx/Kconfig b/drivers/net/wireless/bcm43xx/Kconfig
index ce397e4..0159701 100644
--- a/drivers/net/wireless/bcm43xx/Kconfig
+++ b/drivers/net/wireless/bcm43xx/Kconfig
@@ -1,12 +1,15 @@
 config BCM43XX
-	tristate "Broadcom BCM43xx wireless support"
+	tristate "Broadcom BCM43xx wireless support (DEPRECATED)"
 	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
 	select WIRELESS_EXT
 	select FW_LOADER
 	select HW_RANDOM
 	---help---
-	  This is an experimental driver for the Broadcom 43xx wireless chip,
-	  found in the Apple Airport Extreme and various other devices.
+	  This is an experimental driver for the Broadcom 43xx wireless
+	  chip, found in the Apple Airport Extreme and various other
+	  devices.  This driver is deprecated and will be removed
+	  from the kernel in the near future.  It has been replaced
+	  by the b43 and b43legacy drivers.
 
 config BCM43XX_DEBUG
 	bool "Broadcom BCM43xx debugging (RECOMMENDED)"
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 1470e1b..0d67b33 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -139,17 +139,54 @@ enum ieee80211_phymode {
 };
 
 /**
+ * struct ieee80211_ht_info - describing STA's HT capabilities
+ *
+ * This structure describes most essential parameters needed
+ * to describe 802.11n HT capabilities for an STA.
+ *
+ * @ht_supported: is HT supported by STA, 0: no, 1: yes
+ * @cap: HT capabilities map as described in 802.11n spec
+ * @ampdu_factor: Maximum A-MPDU length factor
+ * @ampdu_density: Minimum A-MPDU spacing
+ * @supp_mcs_set: Supported MCS set as described in 802.11n spec
+ */
+struct ieee80211_ht_info {
+	u8 ht_supported;
+	u16 cap; /* use IEEE80211_HT_CAP_ */
+	u8 ampdu_factor;
+	u8 ampdu_density;
+	u8 supp_mcs_set[16];
+};
+
+/**
+ * struct ieee80211_ht_bss_info - describing BSS's HT characteristics
+ *
+ * This structure describes most essential parameters needed
+ * to describe 802.11n HT characteristics in a BSS
+ *
+ * @primary_channel: channel number of primery channel
+ * @bss_cap: 802.11n's general BSS capabilities (e.g. channel width)
+ * @bss_op_mode: 802.11n's BSS operation modes (e.g. HT protection)
+ */
+struct ieee80211_ht_bss_info {
+	u8 primary_channel;
+	u8 bss_cap;  /* use IEEE80211_HT_IE_CHA_ */
+	u8 bss_op_mode; /* use IEEE80211_HT_IE_ */
+};
+
+/**
  * struct ieee80211_hw_mode - PHY mode definition
  *
  * This structure describes the capabilities supported by the device
  * in a single PHY mode.
  *
+ * @list: internal
+ * @channels: pointer to array of supported channels
+ * @rates: pointer to array of supported bitrates
  * @mode: the PHY mode for this definition
  * @num_channels: number of supported channels
- * @channels: pointer to array of supported channels
  * @num_rates: number of supported bitrates
- * @rates: pointer to array of supported bitrates
- * @list: internal
+ * @ht_info: PHY's 802.11n HT abilities for this mode
  */
 struct ieee80211_hw_mode {
 	struct list_head list;
@@ -158,6 +195,7 @@ struct ieee80211_hw_mode {
 	enum ieee80211_phymode mode;
 	int num_channels;
 	int num_rates;
+	struct ieee80211_ht_info ht_info;
 };
 
 /**
@@ -406,11 +444,12 @@ struct ieee80211_tx_status {
  *
  * @IEEE80211_CONF_SHORT_SLOT_TIME: use 802.11g short slot time
  * @IEEE80211_CONF_RADIOTAP: add radiotap header at receive time (if supported)
- *
+ * @IEEE80211_CONF_SUPPORT_HT_MODE: use 802.11n HT capabilities (if supported)
  */
 enum ieee80211_conf_flags {
-	IEEE80211_CONF_SHORT_SLOT_TIME	= 1<<0,
-	IEEE80211_CONF_RADIOTAP		= 1<<1,
+	IEEE80211_CONF_SHORT_SLOT_TIME	= (1<<0),
+	IEEE80211_CONF_RADIOTAP		= (1<<1),
+	IEEE80211_CONF_SUPPORT_HT_MODE	= (1<<2),
 };
 
 /**
@@ -434,6 +473,8 @@ enum ieee80211_conf_flags {
  * @antenna_sel_tx: transmit antenna selection, 0: default/diversity,
  *	1/2: antenna 0/1
  * @antenna_sel_rx: receive antenna selection, like @antenna_sel_tx
+ * @ht_conf: describes current self configuration of 802.11n HT capabilies
+ * @ht_bss_conf: describes current BSS configuration of 802.11n HT parameters
  */
 struct ieee80211_conf {
 	int channel;			/* IEEE 802.11 channel number */
@@ -452,6 +493,9 @@ struct ieee80211_conf {
 	u8 antenna_max;
 	u8 antenna_sel_tx;
 	u8 antenna_sel_rx;
+
+	struct ieee80211_ht_info ht_conf;
+	struct ieee80211_ht_bss_info ht_bss_conf;
 };
 
 /**
@@ -997,6 +1041,8 @@ enum ieee80211_erp_change_flags {
  * @tx_last_beacon: Determine whether the last IBSS beacon was sent by us.
  *	This is needed only for IBSS mode and the result of this function is
  *	used to determine whether to reply to Probe Requests.
+ *
+ * @conf_ht: Configures low level driver with 802.11n HT data. Must be atomic.
  */
 struct ieee80211_ops {
 	int (*tx)(struct ieee80211_hw *hw, struct sk_buff *skb,
@@ -1042,6 +1088,7 @@ struct ieee80211_ops {
 			     struct sk_buff *skb,
 			     struct ieee80211_tx_control *control);
 	int (*tx_last_beacon)(struct ieee80211_hw *hw);
+	int (*conf_ht)(struct ieee80211_hw *hw, struct ieee80211_conf *conf);
 };
 
 /**
@@ -1411,10 +1458,9 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw);
  *
  * This function iterates over the interfaces associated with a given
  * hardware that are currently active and calls the callback for them.
- * Must be called under RTNL.
  *
  * @hw: the hardware struct of which the interfaces should be iterated over
- * @iterator: the iterator function to call
+ * @iterator: the iterator function to call, cannot sleep
  * @data: first argument of the iterator function
  */
 void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
diff --git a/net/ieee80211/Kconfig b/net/ieee80211/Kconfig
index 1438ade..bd50104 100644
--- a/net/ieee80211/Kconfig
+++ b/net/ieee80211/Kconfig
@@ -1,8 +1,9 @@
 config IEEE80211
-	tristate "Generic IEEE 802.11 Networking Stack"
+	tristate "Generic IEEE 802.11 Networking Stack (DEPRECATED)"
 	---help---
 	This option enables the hardware independent IEEE 802.11
-	networking stack.
+	networking stack.  This component is deprecated in favor of the
+	mac80211 component.
 
 config IEEE80211_DEBUG
 	bool "Enable full debugging output"
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index ce176e6..09711b0 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -51,6 +51,16 @@ config MAC80211_DEBUG
 	  If you are not trying to debug or develop the ieee80211
 	  subsystem, you most likely want to say N here.
 
+config MAC80211_HT_DEBUG
+       bool "Enable HT debugging output"
+       depends on MAC80211_DEBUG
+       ---help---
+       This option enables 802.11n High Throughput features
+       debug tracing output.
+
+       If you are not trying to debug of develop the ieee80211
+       subsystem, you most likely want to say N here.
+
 config MAC80211_VERBOSE_DEBUG
 	bool "Verbose debugging output"
 	depends on MAC80211_DEBUG
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 505af1f..ca0a260 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -34,6 +34,8 @@
 #include "debugfs.h"
 #include "debugfs_netdev.h"
 
+#define SUPP_MCS_SET_LEN 16
+
 /*
  * For seeing transmitted packets on monitor interfaces
  * we have a radiotap header too.
@@ -350,11 +352,14 @@ static int ieee80211_stop(struct net_device *dev)
 		synchronize_rcu();
 		skb_queue_purge(&sdata->u.sta.skb_queue);
 
-		if (!local->ops->hw_scan &&
-		    local->scan_dev == sdata->dev) {
-			local->sta_scanning = 0;
-			cancel_delayed_work(&local->scan_work);
+		if (local->scan_dev == sdata->dev) {
+			if (!local->ops->hw_scan) {
+				local->sta_sw_scanning = 0;
+				cancel_delayed_work(&local->scan_work);
+			} else
+				local->sta_hw_scanning = 0;
 		}
+
 		flush_workqueue(local->hw.workqueue);
 
 		sdata->u.sta.flags &= ~IEEE80211_STA_PRIVACY_INVOKED;
@@ -527,7 +532,7 @@ int ieee80211_hw_config(struct ieee80211_local *local)
 	struct ieee80211_channel *chan;
 	int ret = 0;
 
-	if (local->sta_scanning) {
+	if (local->sta_sw_scanning) {
 		chan = local->scan_channel;
 		mode = local->scan_hw_mode;
 	} else {
@@ -561,6 +566,55 @@ int ieee80211_hw_config(struct ieee80211_local *local)
 	return ret;
 }
 
+/**
+ * ieee80211_hw_config_ht should be used only after legacy configuration
+ * has been determined, as ht configuration depends upon the hardware's
+ * HT abilities for a _specific_ band.
+ */
+int ieee80211_hw_config_ht(struct ieee80211_local *local, int enable_ht,
+			   struct ieee80211_ht_info *req_ht_cap,
+			   struct ieee80211_ht_bss_info *req_bss_cap)
+{
+	struct ieee80211_conf *conf = &local->hw.conf;
+	struct ieee80211_hw_mode *mode = conf->mode;
+	int i;
+
+	/* HT is not supported */
+	if (!mode->ht_info.ht_supported) {
+		conf->flags &= ~IEEE80211_CONF_SUPPORT_HT_MODE;
+		return -EOPNOTSUPP;
+	}
+
+	/* disable HT */
+	if (!enable_ht) {
+		conf->flags &= ~IEEE80211_CONF_SUPPORT_HT_MODE;
+	} else {
+		conf->flags |= IEEE80211_CONF_SUPPORT_HT_MODE;
+		conf->ht_conf.cap = req_ht_cap->cap & mode->ht_info.cap;
+		conf->ht_conf.cap &= ~(IEEE80211_HT_CAP_MIMO_PS);
+		conf->ht_conf.cap |=
+			mode->ht_info.cap & IEEE80211_HT_CAP_MIMO_PS;
+		conf->ht_bss_conf.primary_channel =
+			req_bss_cap->primary_channel;
+		conf->ht_bss_conf.bss_cap = req_bss_cap->bss_cap;
+		conf->ht_bss_conf.bss_op_mode = req_bss_cap->bss_op_mode;
+		for (i = 0; i < SUPP_MCS_SET_LEN; i++)
+			conf->ht_conf.supp_mcs_set[i] =
+				mode->ht_info.supp_mcs_set[i] &
+				  req_ht_cap->supp_mcs_set[i];
+
+		/* In STA mode, this gives us indication
+		 * to the AP's mode of operation */
+		conf->ht_conf.ht_supported = 1;
+		conf->ht_conf.ampdu_factor = req_ht_cap->ampdu_factor;
+		conf->ht_conf.ampdu_density = req_ht_cap->ampdu_density;
+	}
+
+	local->ops->conf_ht(local_to_hw(local), &local->hw.conf);
+
+	return 0;
+}
+
 void ieee80211_erp_info_change_notify(struct net_device *dev, u8 changes)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 2be7fce..b54ed5f 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -89,6 +89,8 @@ struct ieee80211_sta_bss {
 	size_t rsn_ie_len;
 	u8 *wmm_ie;
 	size_t wmm_ie_len;
+	u8 *ht_ie;
+	size_t ht_ie_len;
 #define IEEE80211_MAX_SUPP_RATES 32
 	u8 supp_rates[IEEE80211_MAX_SUPP_RATES];
 	size_t supp_rates_len;
@@ -121,6 +123,7 @@ typedef enum {
 /* frame is destined to interface currently processed (incl. multicast frames) */
 #define IEEE80211_TXRXD_RXRA_MATCH		BIT(5)
 #define IEEE80211_TXRXD_TX_INJECTED		BIT(6)
+#define IEEE80211_TXRXD_RX_AMSDU		BIT(7)
 struct ieee80211_txrx_data {
 	struct sk_buff *skb;
 	struct net_device *dev;
@@ -470,7 +473,8 @@ struct ieee80211_local {
 
 	struct list_head interfaces;
 
-	int sta_scanning;
+	bool sta_sw_scanning;
+	bool sta_hw_scanning;
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
 	unsigned long last_scan_completed;
@@ -704,6 +708,9 @@ int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
 struct ieee80211_rate *ieee80211_get_rate(struct ieee80211_local *local,
 					  int phymode, int hwrate);
+int ieee80211_hw_config_ht(struct ieee80211_local *local, int enable_ht,
+			   struct ieee80211_ht_info *req_ht_cap,
+			   struct ieee80211_ht_bss_info *req_bss_cap);
 
 /* ieee80211_ioctl.c */
 extern const struct iw_handler_def ieee80211_iw_handler_def;
@@ -745,7 +752,8 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len);
 void ieee80211_sta_req_auth(struct net_device *dev,
 			    struct ieee80211_if_sta *ifsta);
 int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len);
-void ieee80211_sta_rx_scan(struct net_device *dev, struct sk_buff *skb,
+ieee80211_txrx_result ieee80211_sta_rx_scan(struct net_device *dev,
+					    struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status);
 void ieee80211_rx_bss_list_init(struct net_device *dev);
 void ieee80211_rx_bss_list_deinit(struct net_device *dev);
@@ -757,7 +765,11 @@ int ieee80211_sta_deauthenticate(struct net_device *dev, u16 reason);
 int ieee80211_sta_disassociate(struct net_device *dev, u16 reason);
 void ieee80211_erp_info_change_notify(struct net_device *dev, u8 changes);
 void ieee80211_reset_erp_info(struct net_device *dev);
-
+int ieee80211_ht_cap_ie_to_ht_info(struct ieee80211_ht_cap *ht_cap_ie,
+				   struct ieee80211_ht_info *ht_info);
+int ieee80211_ht_addt_info_ie_to_ht_bss_info(
+			struct ieee80211_ht_addt_info *ht_add_info_ie,
+			struct ieee80211_ht_bss_info *bss_info);
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
 		     struct net_device **new_dev, int type);
@@ -790,7 +802,7 @@ extern void *mac80211_wiphy_privid; /* for wiphy privid */
 extern const unsigned char rfc1042_header[6];
 extern const unsigned char bridge_tunnel_header[6];
 u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
-int ieee80211_is_eapol(const struct sk_buff *skb);
+int ieee80211_is_eapol(const struct sk_buff *skb, int hdrlen);
 int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 			     int rate, int erp, int short_preamble);
 void mac80211_ev_michael_mic_failure(struct net_device *dev, int keyidx,
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 503b64a..646e2f2 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -315,7 +315,7 @@ int ieee80211_set_channel(struct ieee80211_local *local, int channel, int freq)
 	}
 
 	if (set) {
-		if (local->sta_scanning)
+		if (local->sta_sw_scanning)
 			ret = 0;
 		else
 			ret = ieee80211_hw_config(local);
@@ -545,8 +545,10 @@ static int ieee80211_ioctl_giwscan(struct net_device *dev,
 {
 	int res;
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	if (local->sta_scanning)
+
+	if (local->sta_sw_scanning || local->sta_hw_scanning)
 		return -EAGAIN;
+
 	res = ieee80211_sta_scan_results(dev, extra, data->length);
 	if (res >= 0) {
 		data->length = res;
@@ -928,6 +930,9 @@ static int ieee80211_ioctl_siwauth(struct net_device *dev,
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
 	case IW_AUTH_KEY_MGMT:
 		break;
+	case IW_AUTH_DROP_UNENCRYPTED:
+		sdata->drop_unencrypted = !!data->value;
+		break;
 	case IW_AUTH_PRIVACY_INVOKED:
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			ret = -EINVAL;
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 94537b2..5ee9622 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -57,6 +57,13 @@
 
 #define ERP_INFO_USE_PROTECTION BIT(1)
 
+/* mgmt header + 1 byte action code */
+#define IEEE80211_MIN_ACTION_SIZE (24 + 1)
+
+#define IEEE80211_ADDBA_PARAM_POLICY_MASK 0x0002
+#define IEEE80211_ADDBA_PARAM_TID_MASK 0x003C
+#define IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK 0xFFA0
+
 static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 				     u8 *ssid, size_t ssid_len);
 static struct ieee80211_sta_bss *
@@ -90,7 +97,8 @@ struct ieee802_11_elems {
 	u8 *ext_supp_rates;
 	u8 *wmm_info;
 	u8 *wmm_param;
-
+	u8 *ht_cap_elem;
+	u8 *ht_info_elem;
 	/* length of them, respectively */
 	u8 ssid_len;
 	u8 supp_rates_len;
@@ -106,6 +114,8 @@ struct ieee802_11_elems {
 	u8 ext_supp_rates_len;
 	u8 wmm_info_len;
 	u8 wmm_param_len;
+	u8 ht_cap_elem_len;
+	u8 ht_info_elem_len;
 };
 
 static void ieee802_11_parse_elems(u8 *start, size_t len,
@@ -190,6 +200,14 @@ static void ieee802_11_parse_elems(u8 *start, size_t len,
 			elems->ext_supp_rates = pos;
 			elems->ext_supp_rates_len = elen;
 			break;
+		case WLAN_EID_HT_CAPABILITY:
+			elems->ht_cap_elem = pos;
+			elems->ht_cap_elem_len = elen;
+			break;
+		case WLAN_EID_HT_EXTRA_INFO:
+			elems->ht_info_elem = pos;
+			elems->ht_info_elem_len = elen;
+			break;
 		default:
 			break;
 		}
@@ -332,6 +350,51 @@ static void ieee80211_handle_erp_ie(struct net_device *dev, u8 erp_value)
 		ieee80211_erp_info_change_notify(dev, changes);
 }
 
+int ieee80211_ht_cap_ie_to_ht_info(struct ieee80211_ht_cap *ht_cap_ie,
+				   struct ieee80211_ht_info *ht_info)
+{
+
+	if (ht_info == NULL)
+		return -EINVAL;
+
+	memset(ht_info, 0, sizeof(*ht_info));
+
+	if (ht_cap_ie) {
+		u8 ampdu_info = ht_cap_ie->ampdu_params_info;
+
+		ht_info->ht_supported = 1;
+		ht_info->cap = le16_to_cpu(ht_cap_ie->cap_info);
+		ht_info->ampdu_factor =
+			ampdu_info & IEEE80211_HT_CAP_AMPDU_FACTOR;
+		ht_info->ampdu_density =
+			(ampdu_info & IEEE80211_HT_CAP_AMPDU_DENSITY) >> 2;
+		memcpy(ht_info->supp_mcs_set, ht_cap_ie->supp_mcs_set, 16);
+	} else
+		ht_info->ht_supported = 0;
+
+	return 0;
+}
+
+int ieee80211_ht_addt_info_ie_to_ht_bss_info(
+			struct ieee80211_ht_addt_info *ht_add_info_ie,
+			struct ieee80211_ht_bss_info *bss_info)
+{
+	if (bss_info == NULL)
+		return -EINVAL;
+
+	memset(bss_info, 0, sizeof(*bss_info));
+
+	if (ht_add_info_ie) {
+		u16 op_mode;
+		op_mode = le16_to_cpu(ht_add_info_ie->operation_mode);
+
+		bss_info->primary_channel = ht_add_info_ie->control_chan;
+		bss_info->bss_cap = ht_add_info_ie->ht_param;
+		bss_info->bss_op_mode = (u8)(op_mode & 0xff);
+	}
+
+	return 0;
+}
 
 static void ieee80211_sta_send_associnfo(struct net_device *dev,
 					 struct ieee80211_if_sta *ifsta)
@@ -630,6 +693,19 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		*pos++ = 1; /* WME ver */
 		*pos++ = 0;
 	}
+	/* wmm support is a must to HT */
+	if (wmm && mode->ht_info.ht_supported) {
+		__le16 tmp = cpu_to_le16(mode->ht_info.cap);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap)+2);
+		*pos++ = WLAN_EID_HT_CAPABILITY;
+		*pos++ = sizeof(struct ieee80211_ht_cap);
+		memset(pos, 0, sizeof(struct ieee80211_ht_cap));
+		memcpy(pos, &tmp, sizeof(u16));
+		pos += sizeof(u16);
+		*pos++ = (mode->ht_info.ampdu_factor |
+				(mode->ht_info.ampdu_density << 2));
+		memcpy(pos, mode->ht_info.supp_mcs_set, 16);
+	}
 
 	kfree(ifsta->assocreq_ies);
 	ifsta->assocreq_ies_len = (skb->data + skb->len) - ies;
@@ -922,6 +998,91 @@ static void ieee80211_auth_challenge(struct net_device *dev,
 			    elems.challenge_len + 2, 1);
 }
 
+static void ieee80211_send_addba_resp(struct net_device *dev, u8 *da, u16 tid,
+					u8 dialog_token, u16 status, u16 policy,
+					u16 buf_size, u16 timeout)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	u16 capab;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom);
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer "
+		       "for addba resp frame\n", dev->name);
+		return;
+	}
+
+	skb_reserve(skb, local->hw.extra_tx_headroom);
+	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	memset(mgmt, 0, 24);
+	memcpy(mgmt->da, da, ETH_ALEN);
+	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
+	if (sdata->type == IEEE80211_IF_TYPE_AP)
+		memcpy(mgmt->bssid, dev->dev_addr, ETH_ALEN);
+	else
+		memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_ACTION);
+
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.addba_resp));
+	mgmt->u.action.category = WLAN_CATEGORY_BACK;
+	mgmt->u.action.u.addba_resp.action_code = WLAN_ACTION_ADDBA_RESP;
+	mgmt->u.action.u.addba_resp.dialog_token = dialog_token;
+
+	capab = (u16)(policy << 1);	/* bit 1 aggregation policy */
+	capab |= (u16)(tid << 2); 	/* bit 5:2 TID number */
+	capab |= (u16)(buf_size << 6);	/* bit 15:6 max size of aggregation */
+
+	mgmt->u.action.u.addba_resp.capab = cpu_to_le16(capab);
+	mgmt->u.action.u.addba_resp.timeout = cpu_to_le16(timeout);
+	mgmt->u.action.u.addba_resp.status = cpu_to_le16(status);
+
+	ieee80211_sta_tx(dev, skb, 0);
+
+	return;
+}
+
+static void ieee80211_sta_process_addba_request(struct net_device *dev,
+						struct ieee80211_mgmt *mgmt,
+						size_t len)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct sta_info *sta;
+	u16 capab, tid, timeout, ba_policy, buf_size, status;
+	u8 dialog_token;
+
+	sta = sta_info_get(local, mgmt->sa);
+	if (!sta)
+		return;
+
+	/* extract session parameters from addba request frame */
+	dialog_token = mgmt->u.action.u.addba_req.dialog_token;
+	timeout = le16_to_cpu(mgmt->u.action.u.addba_req.timeout);
+
+	capab = le16_to_cpu(mgmt->u.action.u.addba_req.capab);
+	ba_policy = (capab & IEEE80211_ADDBA_PARAM_POLICY_MASK) >> 1;
+	tid = (capab & IEEE80211_ADDBA_PARAM_TID_MASK) >> 2;
+	buf_size = (capab & IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK) >> 6;
+
+	/* TODO - currently aggregation is declined (A-MPDU add BA request
+	* acceptance is not obligatory by 802.11n draft), but here is
+	* the entry point for dealing with it */
+#ifdef MAC80211_HT_DEBUG
+	if (net_ratelimit())
+		printk(KERN_DEBUG "Add Block Ack request arrived,"
+				   " currently denying it\n");
+#endif /* MAC80211_HT_DEBUG */
+
+	status = WLAN_STATUS_REQUEST_DECLINED;
+
+	ieee80211_send_addba_resp(sta->dev, sta->addr, tid, dialog_token,
+				status, 1, buf_size, timeout);
+	sta_info_put(sta);
+}
 
 static void ieee80211_rx_mgmt_auth(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta,
@@ -1280,6 +1441,19 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	}
 	sta->supp_rates = rates;
 
+	if (elems.ht_cap_elem && elems.ht_info_elem && elems.wmm_param &&
+	    local->ops->conf_ht) {
+		struct ieee80211_ht_bss_info bss_info;
+
+		ieee80211_ht_cap_ie_to_ht_info(
+				(struct ieee80211_ht_cap *)
+				elems.ht_cap_elem, &sta->ht_info);
+		ieee80211_ht_addt_info_ie_to_ht_bss_info(
+				(struct ieee80211_ht_addt_info *)
+				elems.ht_info_elem, &bss_info);
+		ieee80211_hw_config_ht(local, 1, &sta->ht_info, &bss_info);
+	}
+
 	rate_control_rate_init(sta, local);
 
 	if (elems.wmm_param && (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
@@ -1384,6 +1558,7 @@ static void ieee80211_rx_bss_free(struct ieee80211_sta_bss *bss)
 	kfree(bss->wpa_ie);
 	kfree(bss->rsn_ie);
 	kfree(bss->wmm_ie);
+	kfree(bss->ht_ie);
 	kfree(bss);
 }
 
@@ -1487,8 +1662,18 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 		u32 supp_rates, prev_rates;
 		int i, j;
 
-		mode = local->sta_scanning ?
+		mode = local->sta_sw_scanning ?
 		       local->scan_hw_mode : local->oper_hw_mode;
+
+		if (local->sta_hw_scanning) {
+			/* search for the correct mode matches the beacon */
+			list_for_each_entry(mode, &local->modes_list, list)
+				if (mode->mode == rx_status->phymode)
+					break;
+
+			if (mode == NULL)
+				mode = local->oper_hw_mode;
+		}
 		rates = mode->rates;
 		num_rates = mode->num_rates;
 
@@ -1631,7 +1816,22 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 		bss->wmm_ie = NULL;
 		bss->wmm_ie_len = 0;
 	}
-
+	if (elems.ht_cap_elem &&
+	    (!bss->ht_ie || bss->ht_ie_len != elems.ht_cap_elem_len ||
+	     memcmp(bss->ht_ie, elems.ht_cap_elem, elems.ht_cap_elem_len))) {
+		kfree(bss->ht_ie);
+		bss->ht_ie = kmalloc(elems.ht_cap_elem_len + 2, GFP_ATOMIC);
+		if (bss->ht_ie) {
+			memcpy(bss->ht_ie, elems.ht_cap_elem - 2,
+			       elems.ht_cap_elem_len + 2);
+			bss->ht_ie_len = elems.ht_cap_elem_len + 2;
+		} else
+			bss->ht_ie_len = 0;
+	} else if (!elems.ht_cap_elem && bss->ht_ie) {
+		kfree(bss->ht_ie);
+		bss->ht_ie = NULL;
+		bss->ht_ie_len = 0;
+	}
 
 	bss->hw_mode = rx_status->phymode;
 	bss->freq = rx_status->freq;
@@ -1676,6 +1876,8 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 	struct ieee80211_if_sta *ifsta;
 	size_t baselen;
 	struct ieee802_11_elems elems;
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_conf *conf = &local->hw.conf;
 
 	ieee80211_rx_bss_info(dev, mgmt, len, rx_status, 1);
 
@@ -1698,6 +1900,23 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 	if (elems.erp_info && elems.erp_info_len >= 1)
 		ieee80211_handle_erp_ie(dev, elems.erp_info[0]);
 
+	if (elems.ht_cap_elem && elems.ht_info_elem &&
+	    elems.wmm_param && local->ops->conf_ht &&
+	    conf->flags & IEEE80211_CONF_SUPPORT_HT_MODE) {
+		struct ieee80211_ht_bss_info bss_info;
+
+		ieee80211_ht_addt_info_ie_to_ht_bss_info(
+				(struct ieee80211_ht_addt_info *)
+				elems.ht_info_elem, &bss_info);
+		/* check if AP changed bss inforamation */
+		if ((conf->ht_bss_conf.primary_channel !=
+		     bss_info.primary_channel) ||
+		    (conf->ht_bss_conf.bss_cap != bss_info.bss_cap) ||
+		    (conf->ht_bss_conf.bss_op_mode != bss_info.bss_op_mode))
+			ieee80211_hw_config_ht(local, 1, &conf->ht_conf,
+						&bss_info);
+	}
+
 	if (elems.wmm_param && (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
 		ieee80211_sta_wmm_params(dev, ifsta, elems.wmm_param,
 					 elems.wmm_param_len);
@@ -1779,6 +1998,34 @@ static void ieee80211_rx_mgmt_probe_req(struct net_device *dev,
 	ieee80211_sta_tx(dev, skb, 0);
 }
 
+void ieee80211_rx_mgmt_action(struct net_device *dev,
+			     struct ieee80211_if_sta *ifsta,
+			     struct ieee80211_mgmt *mgmt,
+			     size_t len)
+{
+	if (len < IEEE80211_MIN_ACTION_SIZE)
+		return;
+
+	switch (mgmt->u.action.category) {
+	case WLAN_CATEGORY_BACK:
+		switch (mgmt->u.action.u.addba_req.action_code) {
+		case WLAN_ACTION_ADDBA_REQ:
+			if (len < (IEEE80211_MIN_ACTION_SIZE +
+				   sizeof(mgmt->u.action.u.addba_req)))
+				break;
+			ieee80211_sta_process_addba_request(dev, mgmt, len);
+			break;
+		default:
+			if (net_ratelimit())
+			   printk(KERN_DEBUG "%s: received unsupported BACK\n",
+					dev->name);
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+}
 
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status)
@@ -1808,6 +2055,7 @@ void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 	case IEEE80211_STYPE_REASSOC_RESP:
 	case IEEE80211_STYPE_DEAUTH:
 	case IEEE80211_STYPE_DISASSOC:
+	case IEEE80211_STYPE_ACTION:
 		skb_queue_tail(&ifsta->skb_queue, skb);
 		queue_work(local->hw.workqueue, &ifsta->work);
 		return;
@@ -1865,37 +2113,48 @@ static void ieee80211_sta_rx_queued_mgmt(struct net_device *dev,
 	case IEEE80211_STYPE_DISASSOC:
 		ieee80211_rx_mgmt_disassoc(dev, ifsta, mgmt, skb->len);
 		break;
+	case IEEE80211_STYPE_ACTION:
+		ieee80211_rx_mgmt_action(dev, ifsta, mgmt, skb->len);
+		break;
 	}
 
 	kfree_skb(skb);
 }
 
 
-void ieee80211_sta_rx_scan(struct net_device *dev, struct sk_buff *skb,
-			   struct ieee80211_rx_status *rx_status)
+ieee80211_txrx_result
+ieee80211_sta_rx_scan(struct net_device *dev, struct sk_buff *skb,
+		      struct ieee80211_rx_status *rx_status)
 {
 	struct ieee80211_mgmt *mgmt;
 	u16 fc;
 
-	if (skb->len < 24) {
-		dev_kfree_skb(skb);
-		return;
-	}
+	if (skb->len < 2)
+		return TXRX_DROP;
 
 	mgmt = (struct ieee80211_mgmt *) skb->data;
 	fc = le16_to_cpu(mgmt->frame_control);
 
+	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL)
+		return TXRX_CONTINUE;
+
+	if (skb->len < 24)
+		return TXRX_DROP;
+
 	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT) {
 		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP) {
 			ieee80211_rx_mgmt_probe_resp(dev, mgmt,
 						     skb->len, rx_status);
+			dev_kfree_skb(skb);
+			return TXRX_QUEUED;
 		} else if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_BEACON) {
 			ieee80211_rx_mgmt_beacon(dev, mgmt, skb->len,
 						 rx_status);
+			dev_kfree_skb(skb);
+			return TXRX_QUEUED;
 		}
 	}
-
-	dev_kfree_skb(skb);
+	return TXRX_CONTINUE;
 }
 
 
@@ -1985,7 +2244,7 @@ void ieee80211_sta_work(struct work_struct *work)
 	if (!netif_running(dev))
 		return;
 
-	if (local->sta_scanning)
+	if (local->sta_sw_scanning || local->sta_hw_scanning)
 		return;
 
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
@@ -2643,9 +2902,15 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 	union iwreq_data wrqu;
 
 	local->last_scan_completed = jiffies;
-	wmb();
-	local->sta_scanning = 0;
+	memset(&wrqu, 0, sizeof(wrqu));
+	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
 
+	if (local->sta_hw_scanning) {
+		local->sta_hw_scanning = 0;
+		goto done;
+	}
+
+	local->sta_sw_scanning = 0;
 	if (ieee80211_hw_config(local))
 		printk(KERN_DEBUG "%s: failed to restore operational "
 		       "channel after scan\n", dev->name);
@@ -2661,9 +2926,6 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 
 	netif_tx_unlock_bh(local->mdev);
 
-	memset(&wrqu, 0, sizeof(wrqu));
-	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 
@@ -2681,6 +2943,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 	}
 	rcu_read_unlock();
 
+done:
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		struct ieee80211_if_sta *ifsta = &sdata->u.sta;
@@ -2703,7 +2966,7 @@ void ieee80211_sta_scan_work(struct work_struct *work)
 	int skip;
 	unsigned long next_delay = 0;
 
-	if (!local->sta_scanning)
+	if (!local->sta_sw_scanning)
 		return;
 
 	switch (local->scan_state) {
@@ -2766,7 +3029,7 @@ void ieee80211_sta_scan_work(struct work_struct *work)
 		break;
 	}
 
-	if (local->sta_scanning)
+	if (local->sta_sw_scanning)
 		queue_delayed_work(local->hw.workqueue, &local->scan_work,
 				   next_delay);
 }
@@ -2798,7 +3061,7 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 	  * ResultCode: SUCCESS, INVALID_PARAMETERS
 	 */
 
-	if (local->sta_scanning) {
+	if (local->sta_sw_scanning || local->sta_hw_scanning) {
 		if (local->scan_dev == dev)
 			return 0;
 		return -EBUSY;
@@ -2806,15 +3069,15 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 
 	if (local->ops->hw_scan) {
 		int rc = local->ops->hw_scan(local_to_hw(local),
-					    ssid, ssid_len);
+					     ssid, ssid_len);
 		if (!rc) {
-			local->sta_scanning = 1;
+			local->sta_hw_scanning = 1;
 			local->scan_dev = dev;
 		}
 		return rc;
 	}
 
-	local->sta_scanning = 1;
+	local->sta_sw_scanning = 1;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
@@ -2869,7 +3132,7 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return ieee80211_sta_start_scan(dev, ssid, ssid_len);
 
-	if (local->sta_scanning) {
+	if (local->sta_sw_scanning || local->sta_hw_scanning) {
 		if (local->scan_dev == dev)
 			return 0;
 		return -EBUSY;
@@ -3001,31 +3264,6 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		}
 	}
 
-	do {
-		char *buf;
-
-		buf = kmalloc(100, GFP_ATOMIC);
-		if (!buf)
-			break;
-
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		sprintf(buf, "bcn_int=%d", bss->beacon_int);
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
-
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		sprintf(buf, "capab=0x%04x", bss->capability);
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
-
-		kfree(buf);
-		break;
-	} while (0);
-
 	return current_ev;
 }
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 00f908d..50f99e7 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -243,6 +243,10 @@ ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx)
 		u8 *qc = data + ieee80211_get_hdrlen(rx->fc) - QOS_CONTROL_LEN;
 		/* frame has qos control */
 		tid = qc[0] & QOS_CONTROL_TID_MASK;
+		if (qc[0] & IEEE80211_QOS_CONTROL_A_MSDU_PRESENT)
+			rx->flags |= IEEE80211_TXRXD_RX_AMSDU;
+		else
+			rx->flags &= ~IEEE80211_TXRXD_RX_AMSDU;
 	} else {
 		if (unlikely((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT)) {
 			/* Separate TID for management frames */
@@ -338,8 +342,14 @@ ieee80211_rx_h_passive_scan(struct ieee80211_txrx_data *rx)
 	struct ieee80211_local *local = rx->local;
 	struct sk_buff *skb = rx->skb;
 
-	if (unlikely(local->sta_scanning != 0)) {
-		ieee80211_sta_rx_scan(rx->dev, skb, rx->u.rx.status);
+	if (unlikely(local->sta_hw_scanning))
+		return ieee80211_sta_rx_scan(rx->dev, skb, rx->u.rx.status);
+
+	if (unlikely(local->sta_sw_scanning)) {
+		/* drop all the other packets during a software scan anyway */
+		if (ieee80211_sta_rx_scan(rx->dev, skb, rx->u.rx.status)
+		    != TXRX_QUEUED)
+			dev_kfree_skb(skb);
 		return TXRX_QUEUED;
 	}
 
@@ -956,68 +966,64 @@ ieee80211_rx_h_remove_qos_control(struct ieee80211_txrx_data *rx)
 	return TXRX_CONTINUE;
 }
 
-static ieee80211_txrx_result
-ieee80211_rx_h_802_1x_pae(struct ieee80211_txrx_data *rx)
+static int
+ieee80211_drop_802_1x_pae(struct ieee80211_txrx_data *rx, int hdrlen)
 {
-	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb) &&
+	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb, hdrlen) &&
 	    rx->sdata->type != IEEE80211_IF_TYPE_STA &&
 	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
-		return TXRX_CONTINUE;
+		return 0;
 
 	if (unlikely(rx->sdata->ieee802_1x &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)) &&
-		     !ieee80211_is_eapol(rx->skb))) {
+		     !ieee80211_is_eapol(rx->skb, hdrlen))) {
 #ifdef CONFIG_MAC80211_DEBUG
-		struct ieee80211_hdr *hdr =
-			(struct ieee80211_hdr *) rx->skb->data;
-		DECLARE_MAC_BUF(mac);
-		printk(KERN_DEBUG "%s: dropped frame from %s"
-		       " (unauthorized port)\n", rx->dev->name,
-		       print_mac(mac, hdr->addr2));
+		printk(KERN_DEBUG "%s: dropped frame "
+		       "(unauthorized port)\n", rx->dev->name);
 #endif /* CONFIG_MAC80211_DEBUG */
-		return TXRX_DROP;
+		return -EACCES;
 	}
 
-	return TXRX_CONTINUE;
+	return 0;
 }
 
-static ieee80211_txrx_result
-ieee80211_rx_h_drop_unencrypted(struct ieee80211_txrx_data *rx)
+static int
+ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx, int hdrlen)
 {
 	/*
 	 * Pass through unencrypted frames if the hardware has
 	 * decrypted them already.
 	 */
 	if (rx->u.rx.status->flag & RX_FLAG_DECRYPTED)
-		return TXRX_CONTINUE;
+		return 0;
 
 	/* Drop unencrypted frames if key is set. */
 	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
 		     (rx->key || rx->sdata->drop_unencrypted) &&
-		     (rx->sdata->eapol == 0 || !ieee80211_is_eapol(rx->skb)))) {
+		     (rx->sdata->eapol == 0 ||
+		      !ieee80211_is_eapol(rx->skb, hdrlen)))) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: RX non-WEP frame, but expected "
 			       "encryption\n", rx->dev->name);
-		return TXRX_DROP;
+		return -EACCES;
 	}
-	return TXRX_CONTINUE;
+	return 0;
 }
 
-static ieee80211_txrx_result
-ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
+static int
+ieee80211_data_to_8023(struct ieee80211_txrx_data *rx)
 {
 	struct net_device *dev = rx->dev;
-	struct ieee80211_local *local = rx->local;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) rx->skb->data;
 	u16 fc, hdrlen, ethertype;
 	u8 *payload;
 	u8 dst[ETH_ALEN];
 	u8 src[ETH_ALEN];
-	struct sk_buff *skb = rx->skb, *skb2;
+	struct sk_buff *skb = rx->skb;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	DECLARE_MAC_BUF(mac);
 	DECLARE_MAC_BUF(mac2);
@@ -1025,11 +1031,9 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 	DECLARE_MAC_BUF(mac4);
 
 	fc = rx->fc;
-	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
-		return TXRX_CONTINUE;
 
 	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
-		return TXRX_DROP;
+		return -1;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
 
@@ -1058,7 +1062,7 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 				       print_mac(mac, hdr->addr1),
 				       print_mac(mac2, hdr->addr2),
 				       print_mac(mac3, hdr->addr3));
-			return TXRX_DROP;
+			return -1;
 		}
 		break;
 	case (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
@@ -1075,7 +1079,7 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 				       print_mac(mac2, hdr->addr2),
 				       print_mac(mac3, hdr->addr3),
 				       print_mac(mac4, hdr->addr4));
-			return TXRX_DROP;
+			return -1;
 		}
 		break;
 	case IEEE80211_FCTL_FROMDS:
@@ -1086,7 +1090,7 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 		if (sdata->type != IEEE80211_IF_TYPE_STA ||
 		    (is_multicast_ether_addr(dst) &&
 		     !compare_ether_addr(src, dev->dev_addr)))
-			return TXRX_DROP;
+			return -1;
 		break;
 	case 0:
 		/* DA SA BSSID */
@@ -1102,21 +1106,20 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 				       print_mac(mac2, hdr->addr2),
 				       print_mac(mac3, hdr->addr3));
 			}
-			return TXRX_DROP;
+			return -1;
 		}
 		break;
 	}
 
-	payload = skb->data + hdrlen;
-
 	if (unlikely(skb->len - hdrlen < 8)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: RX too short data frame "
 			       "payload\n", dev->name);
 		}
-		return TXRX_DROP;
+		return -1;
 	}
 
+	payload = skb->data + hdrlen;
 	ethertype = (payload[6] << 8) | payload[7];
 
 	if (likely((compare_ether_addr(payload, rfc1042_header) == 0 &&
@@ -1137,12 +1140,19 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 		memcpy(ehdr->h_source, src, ETH_ALEN);
 		ehdr->h_proto = len;
 	}
-	skb->dev = dev;
+	return 0;
+}
 
-	skb2 = NULL;
+static void
+ieee80211_deliver_skb(struct ieee80211_txrx_data *rx)
+{
+	struct net_device *dev = rx->dev;
+	struct ieee80211_local *local = rx->local;
+	struct sk_buff *skb, *xmit_skb;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += skb->len;
+	skb = rx->skb;
+	xmit_skb = NULL;
 
 	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
 	    || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
@@ -1150,8 +1160,8 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 		if (is_multicast_ether_addr(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
-			skb2 = skb_copy(skb, GFP_ATOMIC);
-			if (!skb2 && net_ratelimit())
+			xmit_skb = skb_copy(skb, GFP_ATOMIC);
+			if (!xmit_skb && net_ratelimit())
 				printk(KERN_DEBUG "%s: failed to clone "
 				       "multicast frame\n", dev->name);
 		} else {
@@ -1166,7 +1176,7 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 				 * AP, so send the frame directly to it and
 				 * do not pass the frame to local net stack.
 				 */
-				skb2 = skb;
+				xmit_skb = skb;
 				skb = NULL;
 			}
 			if (dsta)
@@ -1181,13 +1191,164 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 		netif_rx(skb);
 	}
 
-	if (skb2) {
+	if (xmit_skb) {
 		/* send to wireless media */
-		skb2->protocol = __constant_htons(ETH_P_802_3);
-		skb_set_network_header(skb2, 0);
-		skb_set_mac_header(skb2, 0);
-		dev_queue_xmit(skb2);
+		xmit_skb->protocol = __constant_htons(ETH_P_802_3);
+		skb_set_network_header(xmit_skb, 0);
+		skb_set_mac_header(xmit_skb, 0);
+		dev_queue_xmit(xmit_skb);
 	}
+}
+
+static ieee80211_txrx_result
+ieee80211_rx_h_amsdu(struct ieee80211_txrx_data *rx)
+{
+	struct net_device *dev = rx->dev;
+	struct ieee80211_local *local = rx->local;
+	u16 fc, ethertype;
+	u8 *payload;
+	struct sk_buff *skb = rx->skb, *frame = NULL;
+	const struct ethhdr *eth;
+	int remaining, err;
+	u8 dst[ETH_ALEN];
+	u8 src[ETH_ALEN];
+	DECLARE_MAC_BUF(mac);
+
+	fc = rx->fc;
+	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
+		return TXRX_CONTINUE;
+
+	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
+		return TXRX_DROP;
+
+	if (!(rx->flags & IEEE80211_TXRXD_RX_AMSDU))
+		return TXRX_CONTINUE;
+
+	err = ieee80211_data_to_8023(rx);
+	if (unlikely(err))
+		return TXRX_DROP;
+
+	skb->dev = dev;
+
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+
+	/* skip the wrapping header */
+	eth = (struct ethhdr *) skb_pull(skb, sizeof(struct ethhdr));
+	if (!eth)
+		return TXRX_DROP;
+
+	while (skb != frame) {
+		u8 padding;
+		__be16 len = eth->h_proto;
+		unsigned int subframe_len = sizeof(struct ethhdr) + ntohs(len);
+
+		remaining = skb->len;
+		memcpy(dst, eth->h_dest, ETH_ALEN);
+		memcpy(src, eth->h_source, ETH_ALEN);
+
+		padding = ((4 - subframe_len) & 0x3);
+		/* the last MSDU has no padding */
+		if (subframe_len > remaining) {
+			printk(KERN_DEBUG "%s: wrong buffer size", dev->name);
+			return TXRX_DROP;
+		}
+
+		skb_pull(skb, sizeof(struct ethhdr));
+		/* if last subframe reuse skb */
+		if (remaining <= subframe_len + padding)
+			frame = skb;
+		else {
+			frame = dev_alloc_skb(local->hw.extra_tx_headroom +
+					      subframe_len);
+
+			if (frame == NULL)
+				return TXRX_DROP;
+
+			skb_reserve(frame, local->hw.extra_tx_headroom +
+				    sizeof(struct ethhdr));
+			memcpy(skb_put(frame, ntohs(len)), skb->data,
+				ntohs(len));
+
+			eth = (struct ethhdr *) skb_pull(skb, ntohs(len) +
+							padding);
+			if (!eth) {
+				printk(KERN_DEBUG "%s: wrong buffer size ",
+				       dev->name);
+				dev_kfree_skb(frame);
+				return TXRX_DROP;
+			}
+		}
+
+		skb_set_network_header(frame, 0);
+		frame->dev = dev;
+		frame->priority = skb->priority;
+		rx->skb = frame;
+
+		if ((ieee80211_drop_802_1x_pae(rx, 0)) ||
+		    (ieee80211_drop_unencrypted(rx, 0))) {
+			if (skb == frame) /* last frame */
+				return TXRX_DROP;
+			dev_kfree_skb(frame);
+			continue;
+		}
+
+		payload = frame->data;
+		ethertype = (payload[6] << 8) | payload[7];
+
+		if (likely((compare_ether_addr(payload, rfc1042_header) == 0 &&
+			ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
+			compare_ether_addr(payload,
+					   bridge_tunnel_header) == 0)) {
+			/* remove RFC1042 or Bridge-Tunnel
+			 * encapsulation and replace EtherType */
+			skb_pull(frame, 6);
+			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
+			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
+		} else {
+			memcpy(skb_push(frame, sizeof(__be16)), &len,
+				sizeof(__be16));
+			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
+			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
+		}
+
+
+		ieee80211_deliver_skb(rx);
+	}
+
+	return TXRX_QUEUED;
+}
+
+static ieee80211_txrx_result
+ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
+{
+	struct net_device *dev = rx->dev;
+	u16 fc;
+	int err, hdrlen;
+
+	fc = rx->fc;
+	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
+		return TXRX_CONTINUE;
+
+	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
+		return TXRX_DROP;
+
+	hdrlen = ieee80211_get_hdrlen(fc);
+
+	if ((ieee80211_drop_802_1x_pae(rx, hdrlen)) ||
+	    (ieee80211_drop_unencrypted(rx, hdrlen)))
+		return TXRX_DROP;
+
+	err = ieee80211_data_to_8023(rx);
+	if (unlikely(err))
+		return TXRX_DROP;
+
+	rx->skb->dev = dev;
+
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += rx->skb->len;
+
+	ieee80211_deliver_skb(rx);
 
 	return TXRX_QUEUED;
 }
@@ -1341,8 +1502,7 @@ ieee80211_rx_handler ieee80211_rx_handlers[] =
 	 * are not passed to user space by these functions
 	 */
 	ieee80211_rx_h_remove_qos_control,
-	ieee80211_rx_h_802_1x_pae,
-	ieee80211_rx_h_drop_unencrypted,
+	ieee80211_rx_h_amsdu,
 	ieee80211_rx_h_data,
 	ieee80211_rx_h_mgmt,
 	NULL
@@ -1486,7 +1646,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		goto end;
 	}
 
-	if (unlikely(local->sta_scanning))
+	if (unlikely(local->sta_sw_scanning || local->sta_hw_scanning))
 		rx.flags |= IEEE80211_TXRXD_RXIN_SCAN;
 
 	if (__ieee80211_invoke_rx_handlers(local, local->rx_pre_handlers, &rx,
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 8f7ebe4..e1a4ac1 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -99,6 +99,9 @@ struct sta_info {
 
 	u16 listen_interval;
 
+	struct ieee80211_ht_info ht_info; /* 802.11n HT capabilities
+					     of this STA */
+
 #ifdef CONFIG_MAC80211_DEBUGFS
 	struct sta_info_debugfsdentries {
 		struct dentry *dir;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 9ccf4b5..12c1558 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -225,7 +225,7 @@ ieee80211_tx_h_check_assoc(struct ieee80211_txrx_data *tx)
 	if (unlikely(tx->flags & IEEE80211_TXRXD_TX_INJECTED))
 		return TXRX_CONTINUE;
 
-	if (unlikely(tx->local->sta_scanning != 0) &&
+	if (unlikely(tx->local->sta_sw_scanning) &&
 	    ((tx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
 	     (tx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PROBE_REQ))
 		return TXRX_DROP;
@@ -420,7 +420,6 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_txrx_data *tx)
 	return TXRX_CONTINUE;
 }
 
-
 static ieee80211_txrx_result
 ieee80211_tx_h_ps_buf(struct ieee80211_txrx_data *tx)
 {
@@ -433,13 +432,15 @@ ieee80211_tx_h_ps_buf(struct ieee80211_txrx_data *tx)
 		return ieee80211_tx_h_multicast_ps_buf(tx);
 }
 
-
-
-
 static ieee80211_txrx_result
 ieee80211_tx_h_select_key(struct ieee80211_txrx_data *tx)
 {
 	struct ieee80211_key *key;
+	const struct ieee80211_hdr *hdr;
+	u16 fc;
+
+	hdr = (const struct ieee80211_hdr *) tx->skb->data;
+	fc = le16_to_cpu(hdr->frame_control);
 
 	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
@@ -448,7 +449,8 @@ ieee80211_tx_h_select_key(struct ieee80211_txrx_data *tx)
 	else if ((key = rcu_dereference(tx->sdata->default_key)))
 		tx->key = key;
 	else if (tx->sdata->drop_unencrypted &&
-		 !(tx->sdata->eapol && ieee80211_is_eapol(tx->skb))) {
+		 !(tx->sdata->eapol &&
+		   ieee80211_is_eapol(tx->skb, ieee80211_get_hdrlen(fc)))) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TXRX_DROP;
 	} else {
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 88f262b..7b278e9 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -218,23 +218,11 @@ int ieee80211_get_hdrlen_from_skb(const struct sk_buff *skb)
 }
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
-int ieee80211_is_eapol(const struct sk_buff *skb)
+int ieee80211_is_eapol(const struct sk_buff *skb, int hdrlen)
 {
-	const struct ieee80211_hdr *hdr;
-	u16 fc;
-	int hdrlen;
-
 	if (unlikely(skb->len < 10))
 		return 0;
 
-	hdr = (const struct ieee80211_hdr *) skb->data;
-	fc = le16_to_cpu(hdr->frame_control);
-
-	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
-		return 0;
-
-	hdrlen = ieee80211_get_hdrlen(fc);
-
 	if (unlikely(skb->len >= hdrlen + sizeof(eapol_header) &&
 		     memcmp(skb->data + hdrlen, eapol_header,
 			    sizeof(eapol_header)) == 0))
@@ -494,10 +482,9 @@ void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata;
 
-	ASSERT_RTNL();
+	rcu_read_lock();
 
-	/* we hold the RTNL here so can safely walk the list */
-	list_for_each_entry(sdata, &local->interfaces, list) {
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		switch (sdata->type) {
 		case IEEE80211_IF_TYPE_INVALID:
 		case IEEE80211_IF_TYPE_MNTR:
@@ -515,5 +502,7 @@ void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
 			iterator(data, sdata->dev->dev_addr,
 				 sdata->dev->ifindex);
 	}
+
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
