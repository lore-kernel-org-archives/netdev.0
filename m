From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] tg3: Add the ability to conditionally build w/ HWMON
Date: Mon,  6 Mar 2017 12:56:02 -0800
Message-ID: <20170306205605.6547-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Jon Mason <jon.mason@broadcom.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33555 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752024AbdCFVYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 16:24:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a Kconfig option: CONFIG_TIGON3_HWMON which allows to build
in/out support for thermal sensors reported by Tigon3 NICs.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 8 +++++++-
 drivers/net/ethernet/broadcom/tg3.c   | 7 +++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 940fb24bba21..96413808c726 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -109,7 +109,6 @@ config TIGON3
 	tristate "Broadcom Tigon3 support"
 	depends on PCI
 	select PHYLIB
-	select HWMON
 	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
@@ -117,6 +116,13 @@ config TIGON3
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
+config TIGON3_HWMON
+	bool "Broadcom Tigon3 HWMON support"
+	default y
+	depends on TIGON3 && HWMON && !(TIGON3=y && HWMON=m)
+	---help---
+	  Say Y if you want to expose the thermal sensor on Tigon3 devices.
+
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 30d1eb9ebec9..f395b951f5e7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -825,6 +825,7 @@ static int tg3_ape_event_lock(struct tg3 *tp, u32 timeout_us)
 	return timeout_us ? 0 : -EBUSY;
 }
 
+#ifdef CONFIG_TIGON3_HWMON
 static int tg3_ape_wait_for_event(struct tg3 *tp, u32 timeout_us)
 {
 	u32 i, apedata;
@@ -904,6 +905,7 @@ static int tg3_ape_scratchpad_read(struct tg3 *tp, u32 *data, u32 base_off,
 
 	return 0;
 }
+#endif
 
 static int tg3_ape_send_event(struct tg3 *tp, u32 event)
 {
@@ -10744,6 +10746,7 @@ static int tg3_init_hw(struct tg3 *tp, bool reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
+#ifdef CONFIG_TIGON3_HWMON
 static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
 {
 	int i;
@@ -10826,6 +10829,10 @@ static void tg3_hwmon_open(struct tg3 *tp)
 		dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
 	}
 }
+#else
+static inline void tg3_hwmon_close(struct tg3 *tp) { }
+static inline void tg3_hwmon_open(struct tg3 *tp) { }
+#endif /* CONFIG_TIGON3_HWMON */
 
 
 #define TG3_STAT_ADD32(PSTAT, REG) \
-- 
2.9.3
