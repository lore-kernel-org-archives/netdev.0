From: Russell Joyce <russell.joyce@york.ac.uk>
Subject: [PATCH] brcmfmac: added LED triggers for transmit/receive
Date: Fri,  7 Jul 2017 15:09:29 +0100
Message-ID: <20170707140941.122115-1-russell.joyce@york.ac.uk>
Cc: Alan Millard <alan.millard@york.ac.uk>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Marcel Holtmann <marcel@holtmann.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Tobias Klauser <tklauser@distanz.ch>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm802
To: Russell Joyce <russell.joyce@york.ac.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add three basic LED triggers to brcmfmac, based on those in mac80211: one
for transmit, one for receive, and one for combined transmit/receive.

Signed-off-by: Russell Joyce <russell.joyce@york.ac.uk>
---
 drivers/net/wireless/broadcom/brcm80211/Kconfig    |  12 +++
 .../wireless/broadcom/brcm80211/brcmfmac/Makefile  |   2 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   4 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |  16 +++
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   5 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/led.c | 113 +++++++++++++++++++++
 .../net/wireless/broadcom/brcm80211/brcmfmac/led.h |  57 +++++++++++
 7 files changed, 209 insertions(+)
 create mode 100644 drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.c
 create mode 100644 drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.h

diff --git a/drivers/net/wireless/broadcom/brcm80211/Kconfig b/drivers/net/wireless/broadcom/brcm80211/Kconfig
index 9d99eb42d917..7bb593aa755a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/Kconfig
+++ b/drivers/net/wireless/broadcom/brcm80211/Kconfig
@@ -68,6 +68,18 @@ config BRCMFMAC_PCIE
 	  IEEE802.11ac embedded FullMAC WLAN driver. Say Y if you want to
 	  use the driver for an PCIE wireless card.
 
+config BRCMFMAC_LEDS
+	bool "LED trigger support for FullMAC driver"
+	depends on BRCMFMAC
+	depends on LEDS_CLASS
+	select LEDS_TRIGGERS
+	default y
+	---help---
+	  This option enables LED trigger support for Broadcom FullMAC WLAN
+	  driver. Say Y to create LED triggers for receive events (phyXrx),
+	  transmit events (phyXtx), and both events combined (phyXrxtx), on
+	  each adapter (where 'phyX' is the phy name).
+
 config BRCM_TRACING
 	bool "Broadcom device tracing"
 	depends on BRCMSMAC || BRCMFMAC
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
index 1f5a9b948abf..5c33c582a75a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
@@ -48,6 +48,8 @@ brcmfmac-$(CONFIG_BRCMFMAC_USB) += \
 		usb.o
 brcmfmac-$(CONFIG_BRCMFMAC_PCIE) += \
 		pcie.o
+brcmfmac-$(CONFIG_BRCMFMAC_LEDS) += \
+		led.o
 brcmfmac-$(CONFIG_BRCMDBG) += \
 		debug.o
 brcmfmac-$(CONFIG_BRCM_TRACING) += \
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index dcde596c9eb9..43c028513aa2 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -40,6 +40,7 @@
 #include "vendor.h"
 #include "bus.h"
 #include "common.h"
+#include "led.h"
 
 #define BRCMF_SCAN_IE_LEN_MAX		2048
 
@@ -7123,6 +7124,8 @@ struct brcmf_cfg80211_info *brcmf_cfg80211_attach(struct brcmf_pub *drvr,
 #endif
 	}
 
+	brcmfmac_led_init(cfg);
+
 	return cfg;
 
 detach:
@@ -7147,6 +7150,7 @@ void brcmf_cfg80211_detach(struct brcmf_cfg80211_info *cfg)
 	if (!cfg)
 		return;
 
+	brcmfmac_led_exit(cfg);
 	brcmf_pno_detach(cfg);
 	brcmf_btcoex_detach(cfg);
 	wiphy_unregister(cfg->wiphy);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
index 7b2835e5e434..304c13b409a1 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
@@ -17,6 +17,8 @@
 #ifndef BRCMFMAC_CFG80211_H
 #define BRCMFMAC_CFG80211_H
 
+#include <linux/leds.h>
+
 /* for brcmu_d11inf */
 #include <brcmu_d11.h>
 
@@ -301,6 +303,12 @@ struct brcmf_cfg80211_wowl {
  * @vif_event: vif event signalling.
  * @wowl: wowl related information.
  * @pno: information of pno module.
+ * @rx_led: receive LED trigger information.
+ * @tx_led: transmit LED trigger information.
+ * @rxtx_led: receive/transmit LED trigger information.
+ * @rx_led_active: receive LED trigger active.
+ * @tx_led_active: transmit LED trigger active.
+ * @rxtx_led_active: receive/transmit LED trigger active.
  */
 struct brcmf_cfg80211_info {
 	struct wiphy *wiphy;
@@ -335,6 +343,14 @@ struct brcmf_cfg80211_info {
 	struct brcmf_assoclist_le assoclist;
 	struct brcmf_cfg80211_wowl wowl;
 	struct brcmf_pno_info *pno;
+#ifdef CONFIG_BRCMFMAC_LEDS
+	struct led_trigger rx_led;
+	struct led_trigger tx_led;
+	struct led_trigger rxtx_led;
+	atomic_t rx_led_active;
+	atomic_t tx_led_active;
+	atomic_t rxtx_led_active;
+#endif
 };
 
 /**
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 2153e8062b4c..8cc0bf111e27 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -37,6 +37,7 @@
 #include "proto.h"
 #include "pcie.h"
 #include "common.h"
+#include "led.h"
 
 #define MAX_WAIT_FOR_8021X_TX			msecs_to_jiffies(950)
 
@@ -336,6 +337,8 @@ void brcmf_rx_frame(struct device *dev, struct sk_buff *skb, bool handle_event)
 
 	brcmf_dbg(DATA, "Enter: %s: rxp=%p\n", dev_name(dev), skb);
 
+	brcmfmac_led_rx(drvr->config);
+
 	if (brcmf_rx_hdrpull(drvr, skb, &ifp))
 		return;
 
@@ -373,6 +376,8 @@ void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool success)
 	eh = (struct ethhdr *)(txp->data);
 	type = ntohs(eh->h_proto);
 
+	brcmfmac_led_tx(ifp->drvr->config);
+
 	if (type == ETH_P_PAE) {
 		atomic_dec(&ifp->pend_8021x_cnt);
 		if (waitqueue_active(&ifp->pend_8021x_wait))
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.c
new file mode 100644
index 000000000000..d85ef430333d
--- /dev/null
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.c
@@ -0,0 +1,113 @@
+/*
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
+ * Copyright 2017, Russell Joyce <russell.joyce@york.ac.uk>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/slab.h>
+#include "led.h"
+
+static void brcmfmac_rx_led_activate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						rx_led);
+
+	atomic_inc(&info->rx_led_active);
+}
+
+static void brcmfmac_rx_led_deactivate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						rx_led);
+
+	atomic_dec(&info->rx_led_active);
+}
+
+static void brcmfmac_tx_led_activate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						tx_led);
+
+	atomic_inc(&info->tx_led_active);
+}
+
+static void brcmfmac_tx_led_deactivate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						tx_led);
+
+	atomic_dec(&info->tx_led_active);
+}
+
+static void brcmfmac_rxtx_led_activate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						rxtx_led);
+
+	atomic_inc(&info->rxtx_led_active);
+}
+
+static void brcmfmac_rxtx_led_deactivate(struct led_classdev *led_cdev)
+{
+	struct brcmf_cfg80211_info *info = container_of(led_cdev->trigger,
+						struct brcmf_cfg80211_info,
+						rxtx_led);
+
+	atomic_dec(&info->rxtx_led_active);
+}
+
+void brcmfmac_led_init(struct brcmf_cfg80211_info *info)
+{
+	info->rx_led.name = kasprintf(GFP_KERNEL, "%srx",
+				      wiphy_name(info->wiphy));
+	info->tx_led.name = kasprintf(GFP_KERNEL, "%stx",
+				      wiphy_name(info->wiphy));
+	info->rxtx_led.name = kasprintf(GFP_KERNEL, "%srxtx",
+					wiphy_name(info->wiphy));
+
+	atomic_set(&info->rx_led_active, 0);
+	info->rx_led.activate = brcmfmac_rx_led_activate;
+	info->rx_led.deactivate = brcmfmac_rx_led_deactivate;
+	if (info->rx_led.name && led_trigger_register(&info->rx_led)) {
+		kfree(info->rx_led.name);
+		info->rx_led.name = NULL;
+	}
+
+	atomic_set(&info->tx_led_active, 0);
+	info->tx_led.activate = brcmfmac_tx_led_activate;
+	info->tx_led.deactivate = brcmfmac_tx_led_deactivate;
+	if (info->tx_led.name && led_trigger_register(&info->tx_led)) {
+		kfree(info->tx_led.name);
+		info->tx_led.name = NULL;
+	}
+
+	atomic_set(&info->rxtx_led_active, 0);
+	info->rxtx_led.activate = brcmfmac_rxtx_led_activate;
+	info->rxtx_led.deactivate = brcmfmac_rxtx_led_deactivate;
+	if (info->rxtx_led.name && led_trigger_register(&info->rxtx_led)) {
+		kfree(info->rxtx_led.name);
+		info->rxtx_led.name = NULL;
+	}
+}
+
+void brcmfmac_led_exit(struct brcmf_cfg80211_info *info)
+{
+	if (info->rx_led.name)
+		led_trigger_unregister(&info->rx_led);
+	if (info->tx_led.name)
+		led_trigger_unregister(&info->tx_led);
+	if (info->rxtx_led.name)
+		led_trigger_unregister(&info->rxtx_led);
+
+	kfree(info->rx_led.name);
+	kfree(info->tx_led.name);
+	kfree(info->rxtx_led.name);
+}
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.h
new file mode 100644
index 000000000000..c9eee5f8f89b
--- /dev/null
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/led.h
@@ -0,0 +1,57 @@
+/*
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
+ * Copyright 2017, Russell Joyce <russell.joyce@york.ac.uk>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/atomic.h>
+#include <linux/leds.h>
+#include "cfg80211.h"
+
+#define BRCMFMAC_BLINK_DELAY 50 /* ms */
+
+static inline void brcmfmac_led_rx(struct brcmf_cfg80211_info *info)
+{
+#ifdef CONFIG_BRCMFMAC_LEDS
+	unsigned long led_delay = BRCMFMAC_BLINK_DELAY;
+
+	if (atomic_read(&info->rx_led_active))
+		led_trigger_blink_oneshot(&info->rx_led, &led_delay,
+					  &led_delay, 0);
+
+	if (atomic_read(&info->rxtx_led_active))
+		led_trigger_blink_oneshot(&info->rxtx_led, &led_delay,
+					  &led_delay, 0);
+#endif
+}
+
+static inline void brcmfmac_led_tx(struct brcmf_cfg80211_info *info)
+{
+#ifdef CONFIG_BRCMFMAC_LEDS
+	unsigned long led_delay = BRCMFMAC_BLINK_DELAY;
+
+	if (atomic_read(&info->tx_led_active))
+		led_trigger_blink_oneshot(&info->tx_led, &led_delay,
+					  &led_delay, 0);
+
+	if (atomic_read(&info->rxtx_led_active))
+		led_trigger_blink_oneshot(&info->rxtx_led, &led_delay,
+					  &led_delay, 0);
+#endif
+}
+
+#ifdef CONFIG_BRCMFMAC_LEDS
+void brcmfmac_led_init(struct brcmf_cfg80211_info *info);
+void brcmfmac_led_exit(struct brcmf_cfg80211_info *info);
+#else
+static inline void brcmfmac_led_init(struct brcmf_cfg80211_info *info)
+{
+}
+
+static inline void brcmfmac_led_exit(struct brcmf_cfg80211_info *info)
+{
+}
+#endif
-- 
2.11.0
