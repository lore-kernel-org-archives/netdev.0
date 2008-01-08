From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Tue, 8 Jan 2008 14:29:14 -0500
Message-ID: <20080108192914.GA3086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2632 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbYAHTu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 14:50:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a few more for 2.6.25.  The are mostly clean-ups for the new
PID rate control algorithm, and some A-MPDU bits related to supporting
802.11n.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

---

The following changes since commit 60d4ec5e8360560484bdac9244758f1ff7046dd6:
  Eric Dumazet (1):
        [XFRM]: xfrm_state_clone() should be static, not exported

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Andrew Lutomirski (1):
      rc80211_pid should respect fixed rates.

Helmut Schaa (1):
      mac80211: Restore rx.fc before every invocation of ieee80211_invoke_rx_handlers

Ivo van Doorn (1):
      mac80211: Add radio led trigger

Johannes Berg (3):
      mac80211: remove misleading 'res' variable
      mac80211: make rc_pid_fop_events static
      mac80211: better rate control algorithm selection

Ron Rindjunsky (8):
      mac80211: restructure __ieee80211_rx
      mac80211: A-MPDU Rx add low level driver API
      mac80211: A-MPDU Rx add MLME structures
      mac80211: A-MPDU Rx adding basic functionality
      mac80211: A-MPDU Rx MLME data initialization
      mac80211: A-MPDU Rx handling aggregation reordering
      mac80211: A-MPDU Rx adding BAR handling capability
      mac80211: A-MPDU Rx handling DELBA requests

Stefano Brivio (7):
      rc80211-pid: export human-readable target_pf value to debugfs
      rc80211-pid: add kerneldoc for tunable parameters
      rc80211-pid: simplify and fix shift_adjust
      rc80211-pid: fix sta_info refcounting
      rc80211-pid: pf_target tuning
      rc80211-pid: add MAINTAINERS entry
      rc80211-pid: fix definition of rate control interval

 MAINTAINERS                        |   10 +
 include/linux/ieee80211.h          |    7 +
 include/net/mac80211.h             |   50 ++++++
 net/mac80211/Kconfig               |   37 ++--
 net/mac80211/Makefile              |   41 +++--
 net/mac80211/ieee80211.c           |   46 +++---
 net/mac80211/ieee80211_i.h         |   11 +-
 net/mac80211/ieee80211_ioctl.c     |    2 +
 net/mac80211/ieee80211_led.c       |   35 ++++
 net/mac80211/ieee80211_led.h       |    6 +
 net/mac80211/ieee80211_rate.c      |    4 +
 net/mac80211/ieee80211_rate.h      |   38 ++++-
 net/mac80211/ieee80211_sta.c       |  269 ++++++++++++++++++++++++++++--
 net/mac80211/rc80211_pid.h         |   52 ++++--
 net/mac80211/rc80211_pid_algo.c    |   75 ++++++---
 net/mac80211/rc80211_pid_debugfs.c |    2 +-
 net/mac80211/rc80211_simple.c      |   21 +++-
 net/mac80211/rx.c                  |  331 +++++++++++++++++++++++++++++++-----
 net/mac80211/sta_info.c            |   17 ++
 net/mac80211/sta_info.h            |   47 +++++
 net/mac80211/tx.c                  |    3 +-
 net/mac80211/util.c                |   15 ++-
 22 files changed, 957 insertions(+), 162 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index fc16750..120d114 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2480,6 +2480,16 @@ W:	http://linuxwireless.org/
 T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
 S:	Maintained
 
+MAC80211 PID RATE CONTROL
+P:	Stefano Brivio
+M:	stefano.brivio@polimi.it
+P:	Mattias Nissler
+M:	mattias.nissler@gmx.de
+L:	linux-wireless@vger.kernel.org
+W:	http://linuxwireless.org/en/developers/Documentation/mac80211/RateControl/PID
+T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
+S:	Maintained
+
 MACVLAN DRIVER
 P:	Patrick McHardy
 M:	kaber@trash.net
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 3e64159..4d5a4c9 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -472,6 +472,13 @@ enum ieee80211_back_actioncode {
 	WLAN_ACTION_DELBA = 2,
 };
 
+/* BACK (block-ack) parties */
+enum ieee80211_back_parties {
+	WLAN_BACK_RECIPIENT = 0,
+	WLAN_BACK_INITIATOR = 1,
+	WLAN_BACK_TIMER = 2,
+};
+
 /* A-MSDU 802.11n */
 #define IEEE80211_QOS_CONTROL_A_MSDU_PRESENT 0x0080
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index a762a75..be2a383 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -918,6 +918,18 @@ enum ieee80211_erp_change_flags {
 	IEEE80211_ERP_CHANGE_PREAMBLE	= 1<<1,
 };
 
+/**
+ * enum ieee80211_ampdu_mlme_action - A-MPDU actions
+ *
+ * These flags are used with the ampdu_action() callback in
+ * &struct ieee80211_ops to indicate which action is needed.
+ * @IEEE80211_AMPDU_RX_START: start Rx aggregation
+ * @IEEE80211_AMPDU_RX_STOP: stop Rx aggregation
+ */
+enum ieee80211_ampdu_mlme_action {
+	IEEE80211_AMPDU_RX_START,
+	IEEE80211_AMPDU_RX_STOP,
+};
 
 /**
  * struct ieee80211_ops - callbacks from mac80211 to the driver
@@ -1046,6 +1058,12 @@ enum ieee80211_erp_change_flags {
  *	used to determine whether to reply to Probe Requests.
  *
  * @conf_ht: Configures low level driver with 802.11n HT data. Must be atomic.
+ *
+ * @ampdu_action: Perform a certain A-MPDU action
+ * 	The RA/TID combination determines the destination and TID we want
+ * 	the ampdu action to be performed for. The action is defined through
+ * 	ieee80211_ampdu_mlme_action. Starting sequence number (@ssn)
+ * 	is the first frame we expect to perform the action on.
  */
 struct ieee80211_ops {
 	int (*tx)(struct ieee80211_hw *hw, struct sk_buff *skb,
@@ -1091,6 +1109,9 @@ struct ieee80211_ops {
 			     struct ieee80211_tx_control *control);
 	int (*tx_last_beacon)(struct ieee80211_hw *hw);
 	int (*conf_ht)(struct ieee80211_hw *hw, struct ieee80211_conf *conf);
+	int (*ampdu_action)(struct ieee80211_hw *hw,
+			    enum ieee80211_ampdu_mlme_action action,
+			    const u8 *ra, u16 tid, u16 ssn);
 };
 
 /**
@@ -1122,6 +1143,7 @@ int ieee80211_register_hw(struct ieee80211_hw *hw);
 extern char *__ieee80211_get_tx_led_name(struct ieee80211_hw *hw);
 extern char *__ieee80211_get_rx_led_name(struct ieee80211_hw *hw);
 extern char *__ieee80211_get_assoc_led_name(struct ieee80211_hw *hw);
+extern char *__ieee80211_get_radio_led_name(struct ieee80211_hw *hw);
 #endif
 /**
  * ieee80211_get_tx_led_name - get name of TX LED
@@ -1161,6 +1183,16 @@ static inline char *ieee80211_get_rx_led_name(struct ieee80211_hw *hw)
 #endif
 }
 
+/**
+ * ieee80211_get_assoc_led_name - get name of association LED
+ *
+ * mac80211 creates a association LED trigger for each wireless hardware
+ * that can be used to drive LEDs if your driver registers a LED device.
+ * This function returns the name (or %NULL if not configured for LEDs)
+ * of the trigger so you can automatically link the LED device.
+ *
+ * @hw: the hardware to get the LED trigger name for
+ */
 static inline char *ieee80211_get_assoc_led_name(struct ieee80211_hw *hw)
 {
 #ifdef CONFIG_MAC80211_LEDS
@@ -1170,6 +1202,24 @@ static inline char *ieee80211_get_assoc_led_name(struct ieee80211_hw *hw)
 #endif
 }
 
+/**
+ * ieee80211_get_radio_led_name - get name of radio LED
+ *
+ * mac80211 creates a radio change LED trigger for each wireless hardware
+ * that can be used to drive LEDs if your driver registers a LED device.
+ * This function returns the name (or %NULL if not configured for LEDs)
+ * of the trigger so you can automatically link the LED device.
+ *
+ * @hw: the hardware to get the LED trigger name for
+ */
+static inline char *ieee80211_get_radio_led_name(struct ieee80211_hw *hw)
+{
+#ifdef CONFIG_MAC80211_LEDS
+	return __ieee80211_get_radio_led_name(hw);
+#else
+	return NULL;
+#endif
+}
 
 /* Register a new hardware PHYMODE capability to the stack. */
 int ieee80211_register_hwmode(struct ieee80211_hw *hw,
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index cac6cf2..09c2550 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -13,25 +13,17 @@ config MAC80211
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
 
-config MAC80211_RC_DEFAULT_CHOICE
-	bool "Choose default rate control algorithm" if EMBEDDED
-	default y
-	depends on MAC80211
-	---help---
-	  This options enables selection of a default rate control
-	  algorithm to be built into the mac80211 module.  Alternate
-	  rate control algorithms might be built into the mac80211
-	  module as well.
+menu "Rate control algorithm selection"
+	depends on MAC80211 != n
 
 choice
 	prompt "Default rate control algorithm"
 	default MAC80211_RC_DEFAULT_PID
-	depends on MAC80211 && MAC80211_RC_DEFAULT_CHOICE
 	---help---
 	  This option selects the default rate control algorithm
 	  mac80211 will use. Note that this default can still be
 	  overriden through the ieee80211_default_rc_algo module
-	  parameter.
+	  parameter if different algorithms are available.
 
 config MAC80211_RC_DEFAULT_PID
 	bool "PID controller based rate control algorithm"
@@ -50,19 +42,27 @@ config MAC80211_RC_DEFAULT_SIMPLE
 	  dumb algorithm. You should choose the PID rate control
 	  instead.
 
+config MAC80211_RC_DEFAULT_NONE
+	bool "No default algorithm"
+	depends on EMBEDDED
+	help
+	  Selecting this option will select no default algorithm
+	  and allow you to not build any. Do not choose this
+	  option unless you know your driver comes with another
+	  suitable algorithm.
 endchoice
 
+comment "Selecting 'y' for an algorithm will"
+comment "build the algorithm into mac80211."
+
 config MAC80211_RC_DEFAULT
 	string
-	depends on MAC80211
 	default "pid" if MAC80211_RC_DEFAULT_PID
 	default "simple" if MAC80211_RC_DEFAULT_SIMPLE
 	default ""
 
 config MAC80211_RC_PID
-	bool "PID controller based rate control algorithm"
-	default y
-	depends on MAC80211
+	tristate "PID controller based rate control algorithm"
 	---help---
 	  This option enables a TX rate control algorithm for
 	  mac80211 that uses a PID controller to select the TX
@@ -72,16 +72,15 @@ config MAC80211_RC_PID
 	  different rate control algorithm.
 
 config MAC80211_RC_SIMPLE
-	bool "Simple rate control algorithm (DEPRECATED)"
-	default n
-	depends on MAC80211
+	tristate "Simple rate control algorithm (DEPRECATED)"
 	---help---
 	  This option enables a very simple, non-responsive TX
 	  rate control algorithm. This algorithm is deprecated
-	  and will be removed from the kernel in near future.
+	  and will be removed from the kernel in the near future.
 	  It has been replaced by the PID algorithm.
 
 	  Say N unless you know what you are doing.
+endmenu
 
 config MAC80211_LEDS
 	bool "Enable LED triggers"
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 06aea80..54f46bc 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -1,19 +1,15 @@
 obj-$(CONFIG_MAC80211) += mac80211.o
 
-mac80211-objs-$(CONFIG_MAC80211_LEDS) += ieee80211_led.o
-mac80211-objs-$(CONFIG_NET_SCHED) += wme.o
-mac80211-objs-$(CONFIG_MAC80211_RC_SIMPLE) += rc80211_simple.o
-mac80211-objs-$(CONFIG_MAC80211_RC_PID) += rc80211_pid_algo.o
+# objects for PID algorithm
+rc80211_pid-y := rc80211_pid_algo.o
+rc80211_pid-$(CONFIG_MAC80211_DEBUGFS) += rc80211_pid_debugfs.o
 
-mac80211-debugfs-objs-$(CONFIG_MAC80211_RC_PID) += rc80211_pid_debugfs.o
-mac80211-objs-$(CONFIG_MAC80211_DEBUGFS) += \
-	debugfs.o \
-	debugfs_sta.o \
-	debugfs_netdev.o \
-	debugfs_key.o \
-	$(mac80211-debugfs-objs-y)
+# build helper for PID algorithm
+rc-pid-y := $(rc80211_pid-y)
+rc-pid-m := rc80211_pid.o
 
-mac80211-objs := \
+# mac80211 objects
+mac80211-y := \
 	ieee80211.o \
 	ieee80211_ioctl.o \
 	sta_info.o \
@@ -31,5 +27,22 @@ mac80211-objs := \
 	tx.o \
 	key.o \
 	util.o \
-	event.o \
-	$(mac80211-objs-y)
+	event.o
+
+mac80211-$(CONFIG_MAC80211_LEDS) += ieee80211_led.o
+mac80211-$(CONFIG_NET_SCHED) += wme.o
+mac80211-$(CONFIG_MAC80211_DEBUGFS) += \
+	debugfs.o \
+	debugfs_sta.o \
+	debugfs_netdev.o \
+	debugfs_key.o
+
+
+# Build rate control algorithm(s)
+CFLAGS_rc80211_simple.o += -DRC80211_SIMPLE_COMPILE
+CFLAGS_rc80211_pid_algo.o += -DRC80211_PID_COMPILE
+mac80211-$(CONFIG_MAC80211_RC_SIMPLE) += rc80211_simple.o
+mac80211-$(CONFIG_MAC80211_RC_PID) += $(rc-pid-$(CONFIG_MAC80211_RC_PID))
+
+# Modular rate algorithms are assigned to mac80211-m - make separate modules
+obj-m += $(mac80211-m)
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 9c14e3d..4807e52 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -219,6 +219,7 @@ static int ieee80211_open(struct net_device *dev)
 		if (res)
 			return res;
 		ieee80211_hw_config(local);
+		ieee80211_led_radio(local, local->hw.conf.radio_enabled);
 	}
 
 	switch (sdata->type) {
@@ -292,9 +293,18 @@ static int ieee80211_stop(struct net_device *dev)
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_if_init_conf conf;
+	struct sta_info *sta;
+	int i;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
+	list_for_each_entry(sta, &local->sta_list, list) {
+		for (i = 0; i <  STA_TID_NUM; i++)
+			ieee80211_sta_stop_rx_ba_session(sta->dev, sta->addr,
+						i, WLAN_BACK_RECIPIENT,
+						WLAN_REASON_QSTA_LEAVE_QBSS);
+	}
+
 	netif_stop_queue(dev);
 
 	/*
@@ -383,6 +393,8 @@ static int ieee80211_stop(struct net_device *dev)
 		if (local->ops->stop)
 			local->ops->stop(local_to_hw(local));
 
+		ieee80211_led_radio(local, 0);
+
 		tasklet_disable(&local->tx_pending_tasklet);
 		tasklet_disable(&local->tasklet);
 	}
@@ -1314,23 +1326,19 @@ static int __init ieee80211_init(void)
 
 	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
 
-#ifdef CONFIG_MAC80211_RC_SIMPLE
-	ret = ieee80211_rate_control_register(&mac80211_rcsimple);
+	ret = rc80211_simple_init();
 	if (ret)
 		goto fail;
-#endif
 
-#ifdef CONFIG_MAC80211_RC_PID
-	ret = ieee80211_rate_control_register(&mac80211_rcpid);
+	ret = rc80211_pid_init();
 	if (ret)
-		goto fail;
-#endif
+		goto fail_simple;
 
 	ret = ieee80211_wme_register();
 	if (ret) {
 		printk(KERN_DEBUG "ieee80211_init: failed to "
 		       "initialize WME (err=%d)\n", ret);
-		goto fail;
+		goto fail_pid;
 	}
 
 	ieee80211_debugfs_netdev_init();
@@ -1338,26 +1346,18 @@ static int __init ieee80211_init(void)
 
 	return 0;
 
-fail:
-
-#ifdef CONFIG_MAC80211_RC_SIMPLE
-	ieee80211_rate_control_unregister(&mac80211_rcsimple);
-#endif
-#ifdef CONFIG_MAC80211_RC_PID
-	ieee80211_rate_control_unregister(&mac80211_rcpid);
-#endif
-
+ fail_pid:
+	rc80211_simple_exit();
+ fail_simple:
+	rc80211_pid_exit();
+ fail:
 	return ret;
 }
 
 static void __exit ieee80211_exit(void)
 {
-#ifdef CONFIG_MAC80211_RC_SIMPLE
-	ieee80211_rate_control_unregister(&mac80211_rcsimple);
-#endif
-#ifdef CONFIG_MAC80211_RC_PID
-	ieee80211_rate_control_unregister(&mac80211_rcpid);
-#endif
+	rc80211_simple_exit();
+	rc80211_pid_exit();
 
 	ieee80211_wme_unregister();
 	ieee80211_debugfs_netdev_exit();
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index baf53c0..b898b31 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -500,8 +500,9 @@ struct ieee80211_local {
 
 #ifdef CONFIG_MAC80211_LEDS
 	int tx_led_counter, rx_led_counter;
-	struct led_trigger *tx_led, *rx_led, *assoc_led;
-	char tx_led_name[32], rx_led_name[32], assoc_led_name[32];
+	struct led_trigger *tx_led, *rx_led, *assoc_led, *radio_led;
+	char tx_led_name[32], rx_led_name[32],
+	     assoc_led_name[32], radio_led_name[32];
 #endif
 
 	u32 channel_use;
@@ -767,6 +768,9 @@ int ieee80211_ht_cap_ie_to_ht_info(struct ieee80211_ht_cap *ht_cap_ie,
 int ieee80211_ht_addt_info_ie_to_ht_bss_info(
 			struct ieee80211_ht_addt_info *ht_add_info_ie,
 			struct ieee80211_ht_bss_info *bss_info);
+void ieee80211_sta_stop_rx_ba_session(struct net_device *dev, u8 *da,
+				u16 tid, u16 initiator, u16 reason);
+void sta_rx_agg_session_timer_expired(unsigned long data);
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
 		     struct net_device **new_dev, int type);
@@ -798,7 +802,8 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void *mac80211_wiphy_privid; /* for wiphy privid */
 extern const unsigned char rfc1042_header[6];
 extern const unsigned char bridge_tunnel_header[6];
-u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
+u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len,
+			enum ieee80211_if_types type);
 int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 			     int rate, int erp, int short_preamble);
 void mac80211_ev_michael_mic_failure(struct net_device *dev, int keyidx,
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 0c52ed8..02b4092 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -21,6 +21,7 @@
 
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
+#include "ieee80211_led.h"
 #include "ieee80211_rate.h"
 #include "wpa.h"
 #include "aes_ccm.h"
@@ -652,6 +653,7 @@ static int ieee80211_ioctl_siwtxpower(struct net_device *dev,
 	if (local->hw.conf.radio_enabled != !(data->txpower.disabled)) {
 		local->hw.conf.radio_enabled = !(data->txpower.disabled);
 		need_reconfig = 1;
+		ieee80211_led_radio(local, local->hw.conf.radio_enabled);
 	}
 
 	if (need_reconfig) {
diff --git a/net/mac80211/ieee80211_led.c b/net/mac80211/ieee80211_led.c
index 4cf89af..f401484 100644
--- a/net/mac80211/ieee80211_led.c
+++ b/net/mac80211/ieee80211_led.c
@@ -43,6 +43,16 @@ void ieee80211_led_assoc(struct ieee80211_local *local, bool associated)
 		led_trigger_event(local->assoc_led, LED_OFF);
 }
 
+void ieee80211_led_radio(struct ieee80211_local *local, bool enabled)
+{
+	if (unlikely(!local->radio_led))
+		return;
+	if (enabled)
+		led_trigger_event(local->radio_led, LED_FULL);
+	else
+		led_trigger_event(local->radio_led, LED_OFF);
+}
+
 void ieee80211_led_init(struct ieee80211_local *local)
 {
 	local->rx_led = kzalloc(sizeof(struct led_trigger), GFP_KERNEL);
@@ -77,10 +87,25 @@ void ieee80211_led_init(struct ieee80211_local *local)
 			local->assoc_led = NULL;
 		}
 	}
+
+	local->radio_led = kzalloc(sizeof(struct led_trigger), GFP_KERNEL);
+	if (local->radio_led) {
+		snprintf(local->radio_led_name, sizeof(local->radio_led_name),
+			 "%sradio", wiphy_name(local->hw.wiphy));
+		local->radio_led->name = local->radio_led_name;
+		if (led_trigger_register(local->radio_led)) {
+			kfree(local->radio_led);
+			local->radio_led = NULL;
+		}
+	}
 }
 
 void ieee80211_led_exit(struct ieee80211_local *local)
 {
+	if (local->radio_led) {
+		led_trigger_unregister(local->radio_led);
+		kfree(local->radio_led);
+	}
 	if (local->assoc_led) {
 		led_trigger_unregister(local->assoc_led);
 		kfree(local->assoc_led);
@@ -95,6 +120,16 @@ void ieee80211_led_exit(struct ieee80211_local *local)
 	}
 }
 
+char *__ieee80211_get_radio_led_name(struct ieee80211_hw *hw)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+
+	if (local->radio_led)
+		return local->radio_led_name;
+	return NULL;
+}
+EXPORT_SYMBOL(__ieee80211_get_radio_led_name);
+
 char *__ieee80211_get_assoc_led_name(struct ieee80211_hw *hw)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
diff --git a/net/mac80211/ieee80211_led.h b/net/mac80211/ieee80211_led.h
index 0feb226..77b1e1b 100644
--- a/net/mac80211/ieee80211_led.h
+++ b/net/mac80211/ieee80211_led.h
@@ -16,6 +16,8 @@ extern void ieee80211_led_rx(struct ieee80211_local *local);
 extern void ieee80211_led_tx(struct ieee80211_local *local, int q);
 extern void ieee80211_led_assoc(struct ieee80211_local *local,
 				bool associated);
+extern void ieee80211_led_radio(struct ieee80211_local *local,
+				bool enabled);
 extern void ieee80211_led_init(struct ieee80211_local *local);
 extern void ieee80211_led_exit(struct ieee80211_local *local);
 #else
@@ -29,6 +31,10 @@ static inline void ieee80211_led_assoc(struct ieee80211_local *local,
 				       bool associated)
 {
 }
+static inline void ieee80211_led_radio(struct ieee80211_local *local,
+				       bool enabled)
+{
+}
 static inline void ieee80211_led_init(struct ieee80211_local *local)
 {
 }
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 65fc9ad..5676a26 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -115,6 +115,10 @@ ieee80211_rate_control_ops_get(const char *name)
 		/* try default if specific alg requested but not found */
 		ops = ieee80211_try_rate_control_ops_get(ieee80211_default_rc_algo);
 
+	/* try built-in one if specific alg requested but not found */
+	if (!ops && strlen(CONFIG_MAC80211_RC_DEFAULT))
+		ops = ieee80211_try_rate_control_ops_get(CONFIG_MAC80211_RC_DEFAULT);
+
 	return ops;
 }
 
diff --git a/net/mac80211/ieee80211_rate.h b/net/mac80211/ieee80211_rate.h
index 3eb0696..73f19e8 100644
--- a/net/mac80211/ieee80211_rate.h
+++ b/net/mac80211/ieee80211_rate.h
@@ -58,12 +58,6 @@ struct rate_control_ref {
 	struct kref kref;
 };
 
-/* default 'simple' algorithm */
-extern struct rate_control_ops mac80211_rcsimple;
-
-/* 'PID' algorithm */
-extern struct rate_control_ops mac80211_rcpid;
-
 int ieee80211_rate_control_register(struct rate_control_ops *ops);
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
@@ -170,4 +164,36 @@ int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
 				 const char *name);
 void rate_control_deinitialize(struct ieee80211_local *local);
 
+
+/* Rate control algorithms */
+#if defined(RC80211_SIMPLE_COMPILE) || \
+	(defined(CONFIG_MAC80211_RC_SIMPLE) && \
+	 !defined(CONFIG_MAC80211_RC_SIMPLE_MODULE))
+extern int rc80211_simple_init(void);
+extern void rc80211_simple_exit(void);
+#else
+static inline int rc80211_simple_init(void)
+{
+	return 0;
+}
+static inline void rc80211_simple_exit(void)
+{
+}
+#endif
+
+#if defined(RC80211_PID_COMPILE) || \
+	(defined(CONFIG_MAC80211_RC_PID) && \
+	 !defined(CONFIG_MAC80211_RC_PID_MODULE))
+extern int rc80211_pid_init(void);
+extern void rc80211_pid_exit(void);
+#else
+static inline int rc80211_pid_init(void)
+{
+	return 0;
+}
+static inline void rc80211_pid_exit(void)
+{
+}
+#endif
+
 #endif /* IEEE80211_RATE_H */
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 5b8f484..d1f7199 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -63,6 +63,13 @@
 #define IEEE80211_ADDBA_PARAM_POLICY_MASK 0x0002
 #define IEEE80211_ADDBA_PARAM_TID_MASK 0x003C
 #define IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK 0xFFA0
+#define IEEE80211_DELBA_PARAM_TID_MASK 0xF000
+#define IEEE80211_DELBA_PARAM_INITIATOR_MASK 0x0800
+
+/* next values represent the buffer size for A-MPDU frame.
+ * According to IEEE802.11n spec size varies from 8K to 64K (in powers of 2) */
+#define IEEE80211_MIN_AMPDU_BUF 0x8
+#define IEEE80211_MAX_AMPDU_BUF 0x40
 
 static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 				     u8 *ssid, size_t ssid_len);
@@ -1005,7 +1012,8 @@ static void ieee80211_send_addba_resp(struct net_device *dev, u8 *da, u16 tid,
 	struct ieee80211_mgmt *mgmt;
 	u16 capab;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom);
+	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom + 1 +
+					sizeof(mgmt->u.action.u.addba_resp));
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer "
 		       "for addba resp frame\n", dev->name);
@@ -1047,9 +1055,14 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
 						size_t len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_hw *hw = &local->hw;
+	struct ieee80211_conf *conf = &hw->conf;
 	struct sta_info *sta;
-	u16 capab, tid, timeout, ba_policy, buf_size, status;
+	struct tid_ampdu_rx *tid_agg_rx;
+	u16 capab, tid, timeout, ba_policy, buf_size, start_seq_num, status;
 	u8 dialog_token;
+	int ret = -EOPNOTSUPP;
+	DECLARE_MAC_BUF(mac);
 
 	sta = sta_info_get(local, mgmt->sa);
 	if (!sta)
@@ -1058,28 +1071,254 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
 	/* extract session parameters from addba request frame */
 	dialog_token = mgmt->u.action.u.addba_req.dialog_token;
 	timeout = le16_to_cpu(mgmt->u.action.u.addba_req.timeout);
+	start_seq_num =
+		le16_to_cpu(mgmt->u.action.u.addba_req.start_seq_num) >> 4;
 
 	capab = le16_to_cpu(mgmt->u.action.u.addba_req.capab);
 	ba_policy = (capab & IEEE80211_ADDBA_PARAM_POLICY_MASK) >> 1;
 	tid = (capab & IEEE80211_ADDBA_PARAM_TID_MASK) >> 2;
 	buf_size = (capab & IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK) >> 6;
 
-	/* TODO - currently aggregation is declined (A-MPDU add BA request
-	* acceptance is not obligatory by 802.11n draft), but here is
-	* the entry point for dealing with it */
-#ifdef MAC80211_HT_DEBUG
-	if (net_ratelimit())
-		printk(KERN_DEBUG "Add Block Ack request arrived,"
-				   " currently denying it\n");
-#endif /* MAC80211_HT_DEBUG */
-
 	status = WLAN_STATUS_REQUEST_DECLINED;
 
+	/* sanity check for incoming parameters:
+	 * check if configuration can support the BA policy
+	 * and if buffer size does not exceeds max value */
+	if (((ba_policy != 1)
+		&& (!(conf->ht_conf.cap & IEEE80211_HT_CAP_DELAY_BA)))
+		|| (buf_size > IEEE80211_MAX_AMPDU_BUF)) {
+		status = WLAN_STATUS_INVALID_QOS_PARAM;
+#ifdef CONFIG_MAC80211_HT_DEBUG
+		if (net_ratelimit())
+			printk(KERN_DEBUG "Block Ack Req with bad params from "
+				"%s on tid %u. policy %d, buffer size %d\n",
+				print_mac(mac, mgmt->sa), tid, ba_policy,
+				buf_size);
+#endif /* CONFIG_MAC80211_HT_DEBUG */
+		goto end_no_lock;
+	}
+	/* determine default buffer size */
+	if (buf_size == 0) {
+		struct ieee80211_hw_mode *mode = conf->mode;
+		buf_size = IEEE80211_MIN_AMPDU_BUF;
+		buf_size = buf_size << mode->ht_info.ampdu_factor;
+	}
+
+	tid_agg_rx = &sta->ampdu_mlme.tid_rx[tid];
+
+	/* examine state machine */
+	spin_lock_bh(&sta->ampdu_mlme.ampdu_rx);
+
+	if (tid_agg_rx->state != HT_AGG_STATE_IDLE) {
+#ifdef CONFIG_MAC80211_HT_DEBUG
+		if (net_ratelimit())
+			printk(KERN_DEBUG "unexpected Block Ack Req from "
+				"%s on tid %u\n",
+				print_mac(mac, mgmt->sa), tid);
+#endif /* CONFIG_MAC80211_HT_DEBUG */
+		goto end;
+	}
+
+	/* prepare reordering buffer */
+	tid_agg_rx->reorder_buf =
+		kmalloc(buf_size * sizeof(struct sk_buf *), GFP_ATOMIC);
+	if ((!tid_agg_rx->reorder_buf) && net_ratelimit()) {
+		printk(KERN_ERR "can not allocate reordering buffer "
+						"to tid %d\n", tid);
+		goto end;
+	}
+	memset(tid_agg_rx->reorder_buf, 0,
+		buf_size * sizeof(struct sk_buf *));
+
+	if (local->ops->ampdu_action)
+		ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_START,
+					       sta->addr, tid, start_seq_num);
+#ifdef CONFIG_MAC80211_HT_DEBUG
+	printk(KERN_DEBUG "Rx A-MPDU on tid %d result %d", tid, ret);
+#endif /* CONFIG_MAC80211_HT_DEBUG */
+
+	if (ret) {
+		kfree(tid_agg_rx->reorder_buf);
+		goto end;
+	}
+
+	/* change state and send addba resp */
+	tid_agg_rx->state = HT_AGG_STATE_OPERATIONAL;
+	tid_agg_rx->dialog_token = dialog_token;
+	tid_agg_rx->ssn = start_seq_num;
+	tid_agg_rx->head_seq_num = start_seq_num;
+	tid_agg_rx->buf_size = buf_size;
+	tid_agg_rx->timeout = timeout;
+	tid_agg_rx->stored_mpdu_num = 0;
+	status = WLAN_STATUS_SUCCESS;
+end:
+	spin_unlock_bh(&sta->ampdu_mlme.ampdu_rx);
+
+end_no_lock:
 	ieee80211_send_addba_resp(sta->dev, sta->addr, tid, dialog_token,
 				status, 1, buf_size, timeout);
 	sta_info_put(sta);
 }
 
+void ieee80211_send_delba(struct net_device *dev, const u8 *da, u16 tid,
+				u16 initiator, u16 reason_code)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	u16 params;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom + 1 +
+					sizeof(mgmt->u.action.u.delba));
+
+	if (!skb) {
+		printk(KERN_ERR "%s: failed to allocate buffer "
+					"for delba frame\n", dev->name);
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
+					IEEE80211_STYPE_ACTION);
+
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.delba));
+
+	mgmt->u.action.category = WLAN_CATEGORY_BACK;
+	mgmt->u.action.u.delba.action_code = WLAN_ACTION_DELBA;
+	params = (u16)(initiator << 11); 	/* bit 11 initiator */
+	params |= (u16)(tid << 12); 		/* bit 15:12 TID number */
+
+	mgmt->u.action.u.delba.params = cpu_to_le16(params);
+	mgmt->u.action.u.delba.reason_code = cpu_to_le16(reason_code);
+
+	ieee80211_sta_tx(dev, skb, 0);
+}
+
+void ieee80211_sta_stop_rx_ba_session(struct net_device *dev, u8 *ra, u16 tid,
+					u16 initiator, u16 reason)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_hw *hw = &local->hw;
+	struct sta_info *sta;
+	int ret, i;
+
+	sta = sta_info_get(local, ra);
+	if (!sta)
+		return;
+
+	/* check if TID is in operational state */
+	spin_lock_bh(&sta->ampdu_mlme.ampdu_rx);
+	if (sta->ampdu_mlme.tid_rx[tid].state
+				!= HT_AGG_STATE_OPERATIONAL) {
+		spin_unlock_bh(&sta->ampdu_mlme.ampdu_rx);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "rx BA session requested to stop on "
+				"inactive tid %d\n", tid);
+		sta_info_put(sta);
+		return;
+	}
+	sta->ampdu_mlme.tid_rx[tid].state =
+		HT_AGG_STATE_REQ_STOP_BA_MSK |
+		(initiator << HT_AGG_STATE_INITIATOR_SHIFT);
+		spin_unlock_bh(&sta->ampdu_mlme.ampdu_rx);
+
+	/* stop HW Rx aggregation. ampdu_action existence
+	 * already verified in session init so we add the BUG_ON */
+	BUG_ON(!local->ops->ampdu_action);
+
+	ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_STOP,
+					ra, tid, EINVAL);
+	if (ret)
+		printk(KERN_DEBUG "HW problem - can not stop rx "
+				"aggergation for tid %d\n", tid);
+
+	/* shutdown timer has not expired */
+	if (initiator != WLAN_BACK_TIMER)
+		del_timer_sync(&sta->ampdu_mlme.tid_rx[tid].
+					session_timer);
+
+	/* check if this is a self generated aggregation halt */
+	if (initiator == WLAN_BACK_RECIPIENT || initiator == WLAN_BACK_TIMER)
+		ieee80211_send_delba(dev, ra, tid, 0, reason);
+
+	/* free the reordering buffer */
+	for (i = 0; i < sta->ampdu_mlme.tid_rx[tid].buf_size; i++) {
+		if (sta->ampdu_mlme.tid_rx[tid].reorder_buf[i]) {
+			/* release the reordered frames */
+			dev_kfree_skb(sta->ampdu_mlme.tid_rx[tid].reorder_buf[i]);
+			sta->ampdu_mlme.tid_rx[tid].stored_mpdu_num--;
+			sta->ampdu_mlme.tid_rx[tid].reorder_buf[i] = NULL;
+		}
+	}
+	kfree(sta->ampdu_mlme.tid_rx[tid].reorder_buf);
+
+	sta->ampdu_mlme.tid_rx[tid].state = HT_AGG_STATE_IDLE;
+	sta_info_put(sta);
+}
+
+static void ieee80211_sta_process_delba(struct net_device *dev,
+			struct ieee80211_mgmt *mgmt, size_t len)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct sta_info *sta;
+	u16 tid, params;
+	u16 initiator;
+	DECLARE_MAC_BUF(mac);
+
+	sta = sta_info_get(local, mgmt->sa);
+	if (!sta)
+		return;
+
+	params = le16_to_cpu(mgmt->u.action.u.delba.params);
+	tid = (params & IEEE80211_DELBA_PARAM_TID_MASK) >> 12;
+	initiator = (params & IEEE80211_DELBA_PARAM_INITIATOR_MASK) >> 11;
+
+#ifdef CONFIG_MAC80211_HT_DEBUG
+	if (net_ratelimit())
+		printk(KERN_DEBUG "delba from %s on tid %d reason code %d\n",
+			print_mac(mac, mgmt->sa), tid,
+			mgmt->u.action.u.delba.reason_code);
+#endif /* CONFIG_MAC80211_HT_DEBUG */
+
+	if (initiator == WLAN_BACK_INITIATOR)
+		ieee80211_sta_stop_rx_ba_session(dev, sta->addr, tid,
+						 WLAN_BACK_INITIATOR, 0);
+	sta_info_put(sta);
+}
+
+/*
+ * After receiving Block Ack Request (BAR) we activated a
+ * timer after each frame arrives from the originator.
+ * if this timer expires ieee80211_sta_stop_rx_ba_session will be executed.
+ */
+void sta_rx_agg_session_timer_expired(unsigned long data)
+{
+	/* not an elegant detour, but there is no choice as the timer passes
+	 * only one argument, and verious sta_info are needed here, so init
+	 * flow in sta_info_add gives the TID as data, while the timer_to_id
+	 * array gives the sta through container_of */
+	u8 *ptid = (u8 *)data;
+	u8 *timer_to_id = ptid - *ptid;
+	struct sta_info *sta = container_of(timer_to_id, struct sta_info,
+					 timer_to_tid[0]);
+
+	printk(KERN_DEBUG "rx session timer expired on tid %d\n", (u16)*ptid);
+	ieee80211_sta_stop_rx_ba_session(sta->dev, sta->addr, (u16)*ptid,
+					 WLAN_BACK_TIMER,
+					 WLAN_REASON_QSTA_TIMEOUT);
+}
+
+
 static void ieee80211_rx_mgmt_auth(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta,
 				   struct ieee80211_mgmt *mgmt,
@@ -1997,9 +2236,15 @@ static void ieee80211_rx_mgmt_action(struct net_device *dev,
 				break;
 			ieee80211_sta_process_addba_request(dev, mgmt, len);
 			break;
+		case WLAN_ACTION_DELBA:
+			if (len < (IEEE80211_MIN_ACTION_SIZE +
+				   sizeof(mgmt->u.action.u.delba)))
+				break;
+			ieee80211_sta_process_delba(dev, mgmt, len);
+			break;
 		default:
 			if (net_ratelimit())
-			   printk(KERN_DEBUG "%s: received unsupported BACK\n",
+			   printk(KERN_DEBUG "%s: Rx unknown A-MPDU action\n",
 					dev->name);
 			break;
 		}
diff --git a/net/mac80211/rc80211_pid.h b/net/mac80211/rc80211_pid.h
index 425eb70..04afc13 100644
--- a/net/mac80211/rc80211_pid.h
+++ b/net/mac80211/rc80211_pid.h
@@ -1,5 +1,6 @@
 /*
  * Copyright 2007, Mattias Nissler <mattias.nissler@gmx.de>
+ * Copyright 2007, Stefano Brivio <stefano.brivio@polimi.it>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -9,42 +10,42 @@
 #ifndef RC80211_PID_H
 #define RC80211_PID_H
 
-/* Sampling period for measuring percentage of failed frames. */
-#define RC_PID_INTERVAL (HZ / 8)
+/* Sampling period for measuring percentage of failed frames in ms. */
+#define RC_PID_INTERVAL			125
 
 /* Exponential averaging smoothness (used for I part of PID controller) */
-#define RC_PID_SMOOTHING_SHIFT 3
-#define RC_PID_SMOOTHING (1 << RC_PID_SMOOTHING_SHIFT)
+#define RC_PID_SMOOTHING_SHIFT		3
+#define RC_PID_SMOOTHING		(1 << RC_PID_SMOOTHING_SHIFT)
 
 /* Sharpening factor (used for D part of PID controller) */
-#define RC_PID_SHARPENING_FACTOR 0
-#define RC_PID_SHARPENING_DURATION 0
+#define RC_PID_SHARPENING_FACTOR	0
+#define RC_PID_SHARPENING_DURATION	0
 
 /* Fixed point arithmetic shifting amount. */
-#define RC_PID_ARITH_SHIFT 8
+#define RC_PID_ARITH_SHIFT		8
 
 /* Fixed point arithmetic factor. */
-#define RC_PID_ARITH_FACTOR (1 << RC_PID_ARITH_SHIFT)
+#define RC_PID_ARITH_FACTOR		(1 << RC_PID_ARITH_SHIFT)
 
 /* Proportional PID component coefficient. */
-#define RC_PID_COEFF_P 15
+#define RC_PID_COEFF_P			15
 /* Integral PID component coefficient. */
-#define RC_PID_COEFF_I 9
+#define RC_PID_COEFF_I			9
 /* Derivative PID component coefficient. */
-#define RC_PID_COEFF_D 15
+#define RC_PID_COEFF_D			15
 
 /* Target failed frames rate for the PID controller. NB: This effectively gives
  * maximum failed frames percentage we're willing to accept. If the wireless
  * link quality is good, the controller will fail to adjust failed frames
  * percentage to the target. This is intentional.
  */
-#define RC_PID_TARGET_PF (11 << RC_PID_ARITH_SHIFT)
+#define RC_PID_TARGET_PF		14
 
 /* Rate behaviour normalization quantity over time. */
-#define RC_PID_NORM_OFFSET 3
+#define RC_PID_NORM_OFFSET		3
 
 /* Push high rates right after loading. */
-#define RC_PID_FAST_START 0
+#define RC_PID_FAST_START		0
 
 /* Arithmetic right shift for positive and negative values for ISO C. */
 #define RC_PID_DO_ARITH_RIGHT_SHIFT(x, y) \
@@ -119,6 +120,29 @@ struct rc_pid_events_file_info {
 	unsigned int next_entry;
 };
 
+/**
+ * struct rc_pid_debugfs_entries - tunable parameters
+ *
+ * Algorithm parameters, tunable via debugfs.
+ * @dir: the debugfs directory for a specific phy
+ * @target: target percentage for failed frames
+ * @sampling_period: error sampling interval in milliseconds
+ * @coeff_p: absolute value of the proportional coefficient
+ * @coeff_i: absolute value of the integral coefficient
+ * @coeff_d: absolute value of the derivative coefficient
+ * @smoothing_shift: absolute value of the integral smoothing factor (i.e.
+ *	amount of smoothing introduced by the exponential moving average)
+ * @sharpen_factor: absolute value of the derivative sharpening factor (i.e.
+ *	amount of emphasis given to the derivative term after low activity
+ *	events)
+ * @sharpen_duration: duration of the sharpening effect after the detected low
+ *	activity event, relative to sampling_period
+ * @norm_offset: amount of normalization periodically performed on the learnt
+ *	rate behaviour values (lower means we should trust more what we learnt
+ *	about behaviour of rates, higher means we should trust more the natural
+ *	ordering of rates)
+ * @fast_start: if Y, push high rates right after initialization
+ */
 struct rc_pid_debugfs_entries {
 	struct dentry *dir;
 	struct dentry *target;
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 631e468..66cae53 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -12,7 +12,7 @@
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
-
+#include <linux/debugfs.h>
 #include <net/mac80211.h>
 #include "ieee80211_rate.h"
 
@@ -74,29 +74,27 @@ static int rate_control_pid_shift_adjust(struct rc_pid_rateinfo *r,
 {
 	int i, j, k, tmp;
 
-	if (cur + adj < 0)
-		return 0;
-	if (cur + adj >= l)
-		return l - 1;
+	j = r[cur].rev_index;
+	i = j + adj;
 
-	i = r[cur + adj].rev_index;
+	if (i < 0)
+		return r[0].index;
+	if (i >= l - 1)
+		return r[l - 1].index;
 
-	j = r[cur].rev_index;
+	tmp = i;
 
 	if (adj < 0) {
-			tmp = i;
-			for (k = j; k >= i; k--)
-				if (r[k].diff <= r[j].diff)
-					tmp = k;
-			return r[tmp].index;
-	} else if (adj > 0) {
-			tmp = i;
-			for (k = i + 1; k + i < l; k++)
-				if (r[k].diff <= r[i].diff)
-					tmp = k;
-			return r[tmp].index;
+		for (k = j; k >= i; k--)
+			if (r[k].diff <= r[j].diff)
+				tmp = k;
+	} else {
+		for (k = i + 1; k + i < l; k++)
+			if (r[k].diff <= r[i].diff)
+				tmp = k;
 	}
-	return cur + adj;
+
+	return r[tmp].index;
 }
 
 static void rate_control_pid_adjust_rate(struct ieee80211_local *local,
@@ -110,10 +108,6 @@ static void rate_control_pid_adjust_rate(struct ieee80211_local *local,
 	int back = (adj > 0) ? 1 : -1;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
-	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
-		/* forced unicast rate - do not change STA rate */
-		return;
-	}
 
 	mode = local->oper_hw_mode;
 	maxrate = sdata->bss ? sdata->bss->max_ratectrl_rateidx : -1;
@@ -210,7 +204,7 @@ static void rate_control_pid_sample(struct rc_pid_info *pinfo,
 	rate_control_pid_normalize(pinfo, mode->num_rates);
 
 	/* Compute the proportional, integral and derivative errors. */
-	err_prop = pinfo->target - pf;
+	err_prop = (pinfo->target << RC_PID_ARITH_SHIFT) - pf;
 
 	err_avg = spinfo->err_avg_sc >> pinfo->smoothing_shift;
 	spinfo->err_avg_sc = spinfo->err_avg_sc - err_avg + err_prop;
@@ -243,6 +237,7 @@ static void rate_control_pid_tx_status(void *priv, struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_sub_if_data *sdata;
 	struct rc_pid_info *pinfo = priv;
 	struct sta_info *sta;
 	struct rc_pid_sta_info *spinfo;
@@ -253,10 +248,17 @@ static void rate_control_pid_tx_status(void *priv, struct net_device *dev,
 	if (!sta)
 		return;
 
+	/* Don't update the state if we're not controlling the rate. */
+	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
+		sta->txrate = sdata->bss->max_ratectrl_rateidx;
+		return;
+	}
+
 	/* Ignore all frames that were sent with a different rate than the rate
 	 * we currently advise mac80211 to use. */
 	if (status->control.rate != &local->oper_hw_mode->rates[sta->txrate])
-		return;
+		goto ignore;
 
 	spinfo = sta->rate_ctrl_priv;
 	spinfo->tx_num_xmit++;
@@ -297,6 +299,7 @@ static void rate_control_pid_tx_status(void *priv, struct net_device *dev,
 	if (time_after(jiffies, spinfo->last_sample + period))
 		rate_control_pid_sample(pinfo, local, sta);
 
+ignore:
 	sta_info_put(sta);
 }
 
@@ -493,7 +496,7 @@ static void rate_control_pid_free_sta(void *priv, void *priv_sta)
 	kfree(spinfo);
 }
 
-struct rate_control_ops mac80211_rcpid = {
+static struct rate_control_ops mac80211_rcpid = {
 	.name = "pid",
 	.tx_status = rate_control_pid_tx_status,
 	.get_rate = rate_control_pid_get_rate,
@@ -508,3 +511,23 @@ struct rate_control_ops mac80211_rcpid = {
 	.remove_sta_debugfs = rate_control_pid_remove_sta_debugfs,
 #endif
 };
+
+MODULE_DESCRIPTION("PID controller based rate control algorithm");
+MODULE_AUTHOR("Stefano Brivio");
+MODULE_AUTHOR("Mattias Nissler");
+MODULE_LICENSE("GPL");
+
+int __init rc80211_pid_init(void)
+{
+	return ieee80211_rate_control_register(&mac80211_rcpid);
+}
+
+void __exit rc80211_pid_exit(void)
+{
+	ieee80211_rate_control_unregister(&mac80211_rcpid);
+}
+
+#ifdef CONFIG_MAC80211_RC_PID_MODULE
+module_init(rc80211_pid_init);
+module_exit(rc80211_pid_exit);
+#endif
diff --git a/net/mac80211/rc80211_pid_debugfs.c b/net/mac80211/rc80211_pid_debugfs.c
index 91818e4..88b8dc9 100644
--- a/net/mac80211/rc80211_pid_debugfs.c
+++ b/net/mac80211/rc80211_pid_debugfs.c
@@ -197,7 +197,7 @@ static ssize_t rate_control_pid_events_read(struct file *file, char __user *buf,
 
 #undef RC_PID_PRINT_BUF_SIZE
 
-struct file_operations rc_pid_fop_events = {
+static struct file_operations rc_pid_fop_events = {
 	.owner = THIS_MODULE,
 	.read = rate_control_pid_events_read,
 	.poll = rate_control_pid_events_poll,
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index c1c8b76..33de6f9 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/skbuff.h>
 #include <linux/compiler.h>
+#include <linux/module.h>
 
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
@@ -349,7 +350,7 @@ static void rate_control_simple_remove_sta_debugfs(void *priv, void *priv_sta)
 }
 #endif
 
-struct rate_control_ops mac80211_rcsimple = {
+static struct rate_control_ops mac80211_rcsimple = {
 	.name = "simple",
 	.tx_status = rate_control_simple_tx_status,
 	.get_rate = rate_control_simple_get_rate,
@@ -364,3 +365,21 @@ struct rate_control_ops mac80211_rcsimple = {
 	.remove_sta_debugfs = rate_control_simple_remove_sta_debugfs,
 #endif
 };
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Simple rate control algorithm");
+
+int __init rc80211_simple_init(void)
+{
+	return ieee80211_rate_control_register(&mac80211_rcsimple);
+}
+
+void __exit rc80211_simple_exit(void)
+{
+	ieee80211_rate_control_unregister(&mac80211_rcsimple);
+}
+
+#ifdef CONFIG_MAC80211_RC_SIMPLE_MODULE
+module_init(rc80211_simple_init);
+module_exit(rc80211_simple_exit);
+#endif
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 505159f..ed3b816 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -24,6 +24,10 @@
 #include "tkip.h"
 #include "wme.h"
 
+u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
+				struct tid_ampdu_rx *tid_agg_rx,
+				struct sk_buff *skb, u16 mpdu_seq_num,
+				int bar_req);
 /*
  * monitor mode reception
  *
@@ -64,7 +68,9 @@ static inline int should_drop_frame(struct ieee80211_rx_status *status,
 	if (((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
 			cpu_to_le16(IEEE80211_FTYPE_CTL)) &&
 	    ((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_STYPE)) !=
-			cpu_to_le16(IEEE80211_STYPE_PSPOLL)))
+			cpu_to_le16(IEEE80211_STYPE_PSPOLL)) &&
+	    ((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_STYPE)) !=
+			cpu_to_le16(IEEE80211_STYPE_BACK_REQ)))
 		return 1;
 	return 0;
 }
@@ -288,11 +294,11 @@ ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx)
 	return TXRX_CONTINUE;
 }
 
-static ieee80211_txrx_result
-ieee80211_rx_h_load_stats(struct ieee80211_txrx_data *rx)
+
+u32 ieee80211_rx_load_stats(struct ieee80211_local *local,
+			      struct sk_buff *skb,
+			      struct ieee80211_rx_status *status)
 {
-	struct ieee80211_local *local = rx->local;
-	struct sk_buff *skb = rx->skb;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	u32 load = 0, hdrtime;
 	struct ieee80211_rate *rate;
@@ -306,7 +312,7 @@ ieee80211_rx_h_load_stats(struct ieee80211_txrx_data *rx)
 
 	rate = &mode->rates[0];
 	for (i = 0; i < mode->num_rates; i++) {
-		if (mode->rates[i].val == rx->u.rx.status->rate) {
+		if (mode->rates[i].val == status->rate) {
 			rate = &mode->rates[i];
 			break;
 		}
@@ -330,16 +336,13 @@ ieee80211_rx_h_load_stats(struct ieee80211_txrx_data *rx)
 
 	/* Divide channel_use by 8 to avoid wrapping around the counter */
 	load >>= CHAN_UTIL_SHIFT;
-	local->channel_use_raw += load;
-	rx->u.rx.load = load;
 
-	return TXRX_CONTINUE;
+	return load;
 }
 
 ieee80211_rx_handler ieee80211_rx_pre_handlers[] =
 {
 	ieee80211_rx_h_parse_qos,
-	ieee80211_rx_h_load_stats,
 	NULL
 };
 
@@ -637,7 +640,8 @@ ieee80211_rx_h_sta_process(struct ieee80211_txrx_data *rx)
 	 * BSSID to avoid keeping the current IBSS network alive in cases where
 	 * other STAs are using different BSSID. */
 	if (rx->sdata->type == IEEE80211_IF_TYPE_IBSS) {
-		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len);
+		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len,
+						IEEE80211_IF_TYPE_IBSS);
 		if (compare_ether_addr(bssid, rx->sdata->u.sta.bssid) == 0)
 			sta->last_rx = jiffies;
 	} else
@@ -1380,6 +1384,49 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 }
 
 static ieee80211_txrx_result
+ieee80211_rx_h_ctrl(struct ieee80211_txrx_data *rx)
+{
+	struct ieee80211_local *local = rx->local;
+	struct ieee80211_hw *hw = &local->hw;
+	struct sk_buff *skb = rx->skb;
+	struct ieee80211_bar *bar = (struct ieee80211_bar *) skb->data;
+	struct tid_ampdu_rx *tid_agg_rx;
+	u16 start_seq_num;
+	u16 tid;
+
+	if (likely((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_CTL))
+		return TXRX_CONTINUE;
+
+	if ((rx->fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_BACK_REQ) {
+		if (!rx->sta)
+			return TXRX_CONTINUE;
+		tid = le16_to_cpu(bar->control) >> 12;
+		tid_agg_rx = &(rx->sta->ampdu_mlme.tid_rx[tid]);
+		if (tid_agg_rx->state != HT_AGG_STATE_OPERATIONAL)
+			return TXRX_CONTINUE;
+
+		start_seq_num = le16_to_cpu(bar->start_seq_num) >> 4;
+
+		/* reset session timer */
+		if (tid_agg_rx->timeout) {
+			unsigned long expires =
+				jiffies + (tid_agg_rx->timeout / 1000) * HZ;
+			mod_timer(&tid_agg_rx->session_timer, expires);
+		}
+
+		/* manage reordering buffer according to requested */
+		/* sequence number */
+		rcu_read_lock();
+		ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, NULL,
+						 start_seq_num, 1);
+		rcu_read_unlock();
+		return TXRX_DROP;
+	}
+
+	return TXRX_CONTINUE;
+}
+
+static ieee80211_txrx_result
 ieee80211_rx_h_mgmt(struct ieee80211_txrx_data *rx)
 {
 	struct ieee80211_sub_if_data *sdata;
@@ -1530,6 +1577,7 @@ ieee80211_rx_handler ieee80211_rx_handlers[] =
 	ieee80211_rx_h_remove_qos_control,
 	ieee80211_rx_h_amsdu,
 	ieee80211_rx_h_data,
+	ieee80211_rx_h_ctrl,
 	ieee80211_rx_h_mgmt,
 	NULL
 };
@@ -1613,11 +1661,11 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
 }
 
 /*
- * This is the receive path handler. It is called by a low level driver when an
- * 802.11 MPDU is received from the hardware.
+ * This is the actual Rx frames handler. as it blongs to Rx path it must
+ * be called with rcu_read_lock protection.
  */
-void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
-		    struct ieee80211_rx_status *status)
+void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw, struct sk_buff *skb,
+			    struct ieee80211_rx_status *status, u32 load)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata;
@@ -1625,37 +1673,19 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_hdr *hdr;
 	struct ieee80211_txrx_data rx;
 	u16 type;
-	int prepres;
+	int prepares;
 	struct ieee80211_sub_if_data *prev = NULL;
 	struct sk_buff *skb_new;
 	u8 *bssid;
 	int hdrlen;
 
-	/*
-	 * key references and virtual interfaces are protected using RCU
-	 * and this requires that we are in a read-side RCU section during
-	 * receive processing
-	 */
-	rcu_read_lock();
-
-	/*
-	 * Frames with failed FCS/PLCP checksum are not returned,
-	 * all other frames are returned without radiotap header
-	 * if it was previously present.
-	 * Also, frames with less than 16 bytes are dropped.
-	 */
-	skb = ieee80211_rx_monitor(local, skb, status);
-	if (!skb) {
-		rcu_read_unlock();
-		return;
-	}
-
 	hdr = (struct ieee80211_hdr *) skb->data;
 	memset(&rx, 0, sizeof(rx));
 	rx.skb = skb;
 	rx.local = local;
 
 	rx.u.rx.status = status;
+	rx.u.rx.load = load;
 	rx.fc = le16_to_cpu(hdr->frame_control);
 	type = rx.fc & IEEE80211_FCTL_FTYPE;
 
@@ -1704,8 +1734,6 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		return;
 	}
 
-	bssid = ieee80211_get_bssid(hdr, skb->len);
-
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		if (!netif_running(sdata->dev))
 			continue;
@@ -1713,12 +1741,13 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 			continue;
 
+		bssid = ieee80211_get_bssid(hdr, skb->len, sdata->type);
 		rx.flags |= IEEE80211_TXRXD_RXRA_MATCH;
-		prepres = prepare_for_handlers(sdata, bssid, &rx, hdr);
+		prepares = prepare_for_handlers(sdata, bssid, &rx, hdr);
 		/* prepare_for_handlers can change sta */
 		sta = rx.sta;
 
-		if (!prepres)
+		if (!prepares)
 			continue;
 
 		/*
@@ -1746,6 +1775,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 				       prev->dev->name);
 			continue;
 		}
+		rx.fc = le16_to_cpu(hdr->frame_control);
 		rx.skb = skb_new;
 		rx.dev = prev->dev;
 		rx.sdata = prev;
@@ -1754,6 +1784,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		prev = sdata;
 	}
 	if (prev) {
+		rx.fc = le16_to_cpu(hdr->frame_control);
 		rx.skb = skb;
 		rx.dev = prev->dev;
 		rx.sdata = prev;
@@ -1763,10 +1794,230 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		dev_kfree_skb(skb);
 
  end:
-	rcu_read_unlock();
+	if (sta)
+		sta_info_put(sta);
+}
 
+#define SEQ_MODULO 0x1000
+#define SEQ_MASK   0xfff
+
+static inline int seq_less(u16 sq1, u16 sq2)
+{
+	return (((sq1 - sq2) & SEQ_MASK) > (SEQ_MODULO >> 1));
+}
+
+static inline u16 seq_inc(u16 sq)
+{
+	return ((sq + 1) & SEQ_MASK);
+}
+
+static inline u16 seq_sub(u16 sq1, u16 sq2)
+{
+	return ((sq1 - sq2) & SEQ_MASK);
+}
+
+
+/*
+ * As it function blongs to Rx path it must be called with
+ * the proper rcu_read_lock protection for its flow.
+ */
+u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
+				struct tid_ampdu_rx *tid_agg_rx,
+				struct sk_buff *skb, u16 mpdu_seq_num,
+				int bar_req)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_rx_status status;
+	u16 head_seq_num, buf_size;
+	int index;
+	u32 pkt_load;
+
+	buf_size = tid_agg_rx->buf_size;
+	head_seq_num = tid_agg_rx->head_seq_num;
+
+	/* frame with out of date sequence number */
+	if (seq_less(mpdu_seq_num, head_seq_num)) {
+		dev_kfree_skb(skb);
+		return 1;
+	}
+
+	/* if frame sequence number exceeds our buffering window size or
+	 * block Ack Request arrived - release stored frames */
+	if ((!seq_less(mpdu_seq_num, head_seq_num + buf_size)) || (bar_req)) {
+		/* new head to the ordering buffer */
+		if (bar_req)
+			head_seq_num = mpdu_seq_num;
+		else
+			head_seq_num =
+				seq_inc(seq_sub(mpdu_seq_num, buf_size));
+		/* release stored frames up to new head to stack */
+		while (seq_less(tid_agg_rx->head_seq_num, head_seq_num)) {
+			index = seq_sub(tid_agg_rx->head_seq_num,
+				tid_agg_rx->ssn)
+				% tid_agg_rx->buf_size;
+
+			if (tid_agg_rx->reorder_buf[index]) {
+				/* release the reordered frames to stack */
+				memcpy(&status,
+					tid_agg_rx->reorder_buf[index]->cb,
+					sizeof(status));
+				pkt_load = ieee80211_rx_load_stats(local,
+						tid_agg_rx->reorder_buf[index],
+						&status);
+				__ieee80211_rx_handle_packet(hw,
+					tid_agg_rx->reorder_buf[index],
+					&status, pkt_load);
+				tid_agg_rx->stored_mpdu_num--;
+				tid_agg_rx->reorder_buf[index] = NULL;
+			}
+			tid_agg_rx->head_seq_num =
+				seq_inc(tid_agg_rx->head_seq_num);
+		}
+		if (bar_req)
+			return 1;
+	}
+
+	/* now the new frame is always in the range of the reordering */
+	/* buffer window */
+	index = seq_sub(mpdu_seq_num, tid_agg_rx->ssn)
+				% tid_agg_rx->buf_size;
+	/* check if we already stored this frame */
+	if (tid_agg_rx->reorder_buf[index]) {
+		dev_kfree_skb(skb);
+		return 1;
+	}
+
+	/* if arrived mpdu is in the right order and nothing else stored */
+	/* release it immediately */
+	if (mpdu_seq_num == tid_agg_rx->head_seq_num &&
+			tid_agg_rx->stored_mpdu_num == 0) {
+		tid_agg_rx->head_seq_num =
+			seq_inc(tid_agg_rx->head_seq_num);
+		return 0;
+	}
+
+	/* put the frame in the reordering buffer */
+	tid_agg_rx->reorder_buf[index] = skb;
+	tid_agg_rx->stored_mpdu_num++;
+	/* release the buffer until next missing frame */
+	index = seq_sub(tid_agg_rx->head_seq_num, tid_agg_rx->ssn)
+						% tid_agg_rx->buf_size;
+	while (tid_agg_rx->reorder_buf[index]) {
+		/* release the reordered frame back to stack */
+		memcpy(&status, tid_agg_rx->reorder_buf[index]->cb,
+			sizeof(status));
+		pkt_load = ieee80211_rx_load_stats(local,
+					tid_agg_rx->reorder_buf[index],
+					&status);
+		__ieee80211_rx_handle_packet(hw, tid_agg_rx->reorder_buf[index],
+						&status, pkt_load);
+		tid_agg_rx->stored_mpdu_num--;
+		tid_agg_rx->reorder_buf[index] = NULL;
+		tid_agg_rx->head_seq_num = seq_inc(tid_agg_rx->head_seq_num);
+		index =	seq_sub(tid_agg_rx->head_seq_num,
+			tid_agg_rx->ssn) % tid_agg_rx->buf_size;
+	}
+	return 1;
+}
+
+u8 ieee80211_rx_reorder_ampdu(struct ieee80211_local *local,
+			      struct sk_buff *skb)
+{
+	struct ieee80211_hw *hw = &local->hw;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct sta_info *sta;
+	struct tid_ampdu_rx *tid_agg_rx;
+	u16 fc, sc;
+	u16 mpdu_seq_num;
+	u8 ret = 0, *qc;
+	int tid;
+
+	sta = sta_info_get(local, hdr->addr2);
+	if (!sta)
+		return ret;
+
+	fc = le16_to_cpu(hdr->frame_control);
+
+	/* filter the QoS data rx stream according to
+	 * STA/TID and check if this STA/TID is on aggregation */
+	if (!WLAN_FC_IS_QOS_DATA(fc))
+		goto end_reorder;
+
+	qc = skb->data + ieee80211_get_hdrlen(fc) - QOS_CONTROL_LEN;
+	tid = qc[0] & QOS_CONTROL_TID_MASK;
+	tid_agg_rx = &(sta->ampdu_mlme.tid_rx[tid]);
+
+	if (tid_agg_rx->state != HT_AGG_STATE_OPERATIONAL)
+		goto end_reorder;
+
+	/* null data frames are excluded */
+	if (unlikely(fc & IEEE80211_STYPE_QOS_NULLFUNC))
+		goto end_reorder;
+
+	/* new un-ordered ampdu frame - process it */
+
+	/* reset session timer */
+	if (tid_agg_rx->timeout) {
+		unsigned long expires =
+			jiffies + (tid_agg_rx->timeout / 1000) * HZ;
+		mod_timer(&tid_agg_rx->session_timer, expires);
+	}
+
+	/* if this mpdu is fragmented - terminate rx aggregation session */
+	sc = le16_to_cpu(hdr->seq_ctrl);
+	if (sc & IEEE80211_SCTL_FRAG) {
+		ieee80211_sta_stop_rx_ba_session(sta->dev, sta->addr,
+			tid, 0, WLAN_REASON_QSTA_REQUIRE_SETUP);
+		ret = 1;
+		goto end_reorder;
+	}
+
+	/* according to mpdu sequence number deal with reordering buffer */
+	mpdu_seq_num = (sc & IEEE80211_SCTL_SEQ) >> 4;
+	ret = ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, skb,
+						mpdu_seq_num, 0);
+end_reorder:
 	if (sta)
 		sta_info_put(sta);
+	return ret;
+}
+
+/*
+ * This is the receive path handler. It is called by a low level driver when an
+ * 802.11 MPDU is received from the hardware.
+ */
+void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
+		    struct ieee80211_rx_status *status)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+	u32 pkt_load;
+
+	/*
+	 * key references and virtual interfaces are protected using RCU
+	 * and this requires that we are in a read-side RCU section during
+	 * receive processing
+	 */
+	rcu_read_lock();
+
+	/*
+	 * Frames with failed FCS/PLCP checksum are not returned,
+	 * all other frames are returned without radiotap header
+	 * if it was previously present.
+	 * Also, frames with less than 16 bytes are dropped.
+	 */
+	skb = ieee80211_rx_monitor(local, skb, status);
+	if (!skb) {
+		rcu_read_unlock();
+		return;
+	}
+
+	pkt_load = ieee80211_rx_load_stats(local, skb, status);
+	local->channel_use_raw += pkt_load;
+
+	if (!ieee80211_rx_reorder_ampdu(local, skb))
+		__ieee80211_rx_handle_packet(hw, skb, status, pkt_load);
+
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(__ieee80211_rx);
 
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index ffe8a49..1257c7a 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -104,6 +104,7 @@ static void sta_info_release(struct kref *kref)
 	struct sta_info *sta = container_of(kref, struct sta_info, kref);
 	struct ieee80211_local *local = sta->local;
 	struct sk_buff *skb;
+	int i;
 
 	/* free sta structure; it has already been removed from
 	 * hash table etc. external structures. Make sure that all
@@ -116,6 +117,8 @@ static void sta_info_release(struct kref *kref)
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		dev_kfree_skb_any(skb);
 	}
+	for (i = 0; i <  STA_TID_NUM; i++)
+		del_timer_sync(&sta->ampdu_mlme.tid_rx[i].session_timer);
 	rate_control_free_sta(sta->rate_ctrl, sta->rate_ctrl_priv);
 	rate_control_put(sta->rate_ctrl);
 	kfree(sta);
@@ -133,6 +136,7 @@ struct sta_info * sta_info_add(struct ieee80211_local *local,
 			       struct net_device *dev, u8 *addr, gfp_t gfp)
 {
 	struct sta_info *sta;
+	int i;
 	DECLARE_MAC_BUF(mac);
 
 	sta = kzalloc(sizeof(*sta), gfp);
@@ -152,6 +156,19 @@ struct sta_info * sta_info_add(struct ieee80211_local *local,
 	memcpy(sta->addr, addr, ETH_ALEN);
 	sta->local = local;
 	sta->dev = dev;
+	spin_lock_init(&sta->ampdu_mlme.ampdu_rx);
+	for (i = 0; i < STA_TID_NUM; i++) {
+		/* timer_to_tid must be initialized with identity mapping to
+		 * enable session_timer's data differentiation. refer to
+		 * sta_rx_agg_session_timer_expired for useage */
+		sta->timer_to_tid[i] = i;
+		/* rx timers */
+		sta->ampdu_mlme.tid_rx[i].session_timer.function =
+			sta_rx_agg_session_timer_expired;
+		sta->ampdu_mlme.tid_rx[i].session_timer.data =
+			(unsigned long)&sta->timer_to_tid[i];
+		init_timer(&sta->ampdu_mlme.tid_rx[i].session_timer);
+	}
 	skb_queue_head_init(&sta->ps_tx_buf);
 	skb_queue_head_init(&sta->tx_filtered);
 	__sta_info_get(sta);	/* sta used by caller, decremented by
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index e1a4ac1..96fe3ed 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -31,6 +31,51 @@
 #define WLAN_STA_WME BIT(9)
 #define WLAN_STA_WDS BIT(27)
 
+#define STA_TID_NUM 16
+#define ADDBA_RESP_INTERVAL HZ
+
+#define HT_AGG_STATE_INITIATOR_SHIFT	(4)
+
+#define HT_AGG_STATE_REQ_STOP_BA_MSK	BIT(3)
+
+#define HT_AGG_STATE_IDLE		(0x0)
+#define HT_AGG_STATE_OPERATIONAL	(0x7)
+
+/**
+ * struct tid_ampdu_rx - TID aggregation information (Rx).
+ *
+ * @state: TID's state in session state machine.
+ * @dialog_token: dialog token for aggregation session
+ * @ssn: Starting Sequence Number expected to be aggregated.
+ * @buf_size: buffer size for incoming A-MPDUs
+ * @timeout: reset timer value.
+ * @head_seq_num: head sequence number in reordering buffer.
+ * @stored_mpdu_num: number of MPDUs in reordering buffer
+ * @reorder_buf: buffer to reorder incoming aggregated MPDUs
+ * @session_timer: check if peer keeps Tx-ing on the TID (by timeout value)
+ */
+struct tid_ampdu_rx {
+	u8 state;
+	u8 dialog_token;
+	u16 ssn;
+	u16 buf_size;
+	u16 timeout;
+	u16 head_seq_num;
+	u16 stored_mpdu_num;
+	struct sk_buff **reorder_buf;
+	struct timer_list session_timer;
+};
+
+/**
+ * struct sta_ampdu_mlme - STA aggregation information.
+ *
+ * @tid_agg_info_rx: aggregation info for Rx per TID
+ * @ampdu_rx: for locking sections in aggregation Rx flow
+ */
+struct sta_ampdu_mlme {
+	struct tid_ampdu_rx tid_rx[STA_TID_NUM];
+	spinlock_t ampdu_rx;
+};
 
 struct sta_info {
 	struct kref kref;
@@ -101,6 +146,8 @@ struct sta_info {
 
 	struct ieee80211_ht_info ht_info; /* 802.11n HT capabilities
 					     of this STA */
+	struct sta_ampdu_mlme ampdu_mlme;
+	u8 timer_to_tid[STA_TID_NUM];	/* convert timer id to tid */
 
 #ifdef CONFIG_MAC80211_DEBUGFS
 	struct sta_info_debugfsdentries {
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 8302c70..f619416 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -932,7 +932,6 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr;
 	struct ieee80211_sub_if_data *sdata;
-	ieee80211_txrx_result res = TXRX_CONTINUE;
 
 	int hdrlen;
 
@@ -997,7 +996,7 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	}
 	control->flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
 
-	return res;
+	return TXRX_CONTINUE;
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 2b02b2b..adb85dd 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -127,7 +127,8 @@ void ieee80211_prepare_rates(struct ieee80211_local *local,
 	}
 }
 
-u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
+u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len,
+			enum ieee80211_if_types type)
 {
 	u16 fc;
 
@@ -159,6 +160,18 @@ u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
 	case IEEE80211_FTYPE_CTL:
 		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)
 			return hdr->addr1;
+		else if ((fc & IEEE80211_FCTL_STYPE) ==
+						IEEE80211_STYPE_BACK_REQ) {
+			switch (type) {
+			case IEEE80211_IF_TYPE_STA:
+				return hdr->addr2;
+			case IEEE80211_IF_TYPE_AP:
+			case IEEE80211_IF_TYPE_VLAN:
+				return hdr->addr1;
+			default:
+				return NULL;
+			}
+		}
 		else
 			return NULL;
 	}
-- 
John W. Linville
linville@tuxdriver.com
