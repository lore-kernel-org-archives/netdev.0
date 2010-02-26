From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH v3] can: ti hecc module : add platform specific initialization callback.
Date: Fri, 26 Feb 2010 18:44:38 +0530
Message-ID: <1267190078-22328-1-git-send-email-srk@ti.com>
Cc: socketcan-core@lists.berlios.de, mkl@pengutronix.de,
	Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60539 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936169Ab0BZNOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 08:14:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAN module on AM3517 requires programming of IO expander as part
of init sequence - to enable CAN PHY. Added platform specific
callback to handle phy control(switch on /off).

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
Addressed review comments and also added conditional compile
macros to gaurd against multiple inclusion of header file.

 drivers/net/can/ti_hecc.c            |   17 ++++++++++++++++-
 include/linux/can/platform/ti_hecc.h |    8 ++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index df27d82..ceba29e 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -28,9 +28,11 @@
  *         .mbx_offset             = 0x2000,
  *         .int_line               = 0,
  *         .revision               = 1,
+ *         .transceiver_switch     = hecc_phy_control,
  * };
  *
- * Please see include/can/platform/ti_hecc.h for description of above fields
+ * Please see include/linux/can/platform/ti_hecc.h for description of
+ * above fields.
  *
  */
 
@@ -220,6 +222,7 @@ struct ti_hecc_priv {
 	u32 tx_head;
 	u32 tx_tail;
 	u32 rx_next;
+	void (*transceiver_switch)(int);
 };
 
 static inline int get_tx_head_mb(struct ti_hecc_priv *priv)
@@ -317,6 +320,13 @@ static int ti_hecc_set_btc(struct ti_hecc_priv *priv)
 	return 0;
 }
 
+static void ti_hecc_transceiver_switch(const struct ti_hecc_priv *priv,
+					int on)
+{
+	if (priv->transceiver_switch)
+		priv->transceiver_switch(on);
+}
+
 static void ti_hecc_reset(struct net_device *ndev)
 {
 	u32 cnt;
@@ -816,10 +826,13 @@ static int ti_hecc_open(struct net_device *ndev)
 		return err;
 	}
 
+	ti_hecc_transceiver_switch(priv, 1);
+
 	/* Open common can device */
 	err = open_candev(ndev);
 	if (err) {
 		dev_err(ndev->dev.parent, "open_candev() failed %d\n", err);
+		ti_hecc_transceiver_switch(priv, 0);
 		free_irq(ndev->irq, ndev);
 		return err;
 	}
@@ -840,6 +853,7 @@ static int ti_hecc_close(struct net_device *ndev)
 	ti_hecc_stop(ndev);
 	free_irq(ndev->irq, ndev);
 	close_candev(ndev);
+	ti_hecc_transceiver_switch(priv, 0);
 
 	return 0;
 }
@@ -901,6 +915,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	priv->hecc_ram_offset = pdata->hecc_ram_offset;
 	priv->mbx_offset = pdata->mbx_offset;
 	priv->int_line = pdata->int_line;
+	priv->transceiver_switch = pdata->transceiver_switch;
 
 	priv->can.bittiming_const = &ti_hecc_bittiming_const;
 	priv->can.do_set_mode = ti_hecc_do_set_mode;
diff --git a/include/linux/can/platform/ti_hecc.h b/include/linux/can/platform/ti_hecc.h
index 4688c7b..af17cb3 100644
--- a/include/linux/can/platform/ti_hecc.h
+++ b/include/linux/can/platform/ti_hecc.h
@@ -1,3 +1,6 @@
+#ifndef __CAN_PLATFORM_TI_HECC_H__
+#define __CAN_PLATFORM_TI_HECC_H__
+
 /*
  * TI HECC (High End CAN Controller) driver platform header
  *
@@ -23,6 +26,7 @@
  * @mbx_offset:		Mailbox RAM offset
  * @int_line:		Interrupt line to use - 0 or 1
  * @version:		version for future use
+ * @transceiver_switch:	platform specific callback fn for transceiver control
  *
  * Platform data structure to get all platform specific settings.
  * this structure also accounts the fact that the IP may have different
@@ -35,6 +39,6 @@ struct ti_hecc_platform_data {
 	u32 mbx_offset;
 	u32 int_line;
 	u32 version;
+	void (*transceiver_switch) (int);
 };
-
-
+#endif
-- 
1.6.2.4

