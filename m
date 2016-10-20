From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels
Date: Thu, 20 Oct 2016 09:32:19 -0700
Message-ID: <1476981139-28889-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35703 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbcJTQcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 12:32:22 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so6011519pfj.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:32:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a kernel that is being kexec'd we re-enable the integrated GPHY in
order for the subsequent MDIO bus scan to succeed and properly bind to
the bcm7xxx PHY driver. If we did not do that, the GPHY would be shut
down by the time the MDIO driver is probing the bus, and it would fail
to read the correct PHY OUI and therefore bind to an appropriate PHY
driver. Later on, this would cause DSA not to be able to successfully
attach to the PHY, and the interface would not be created at all.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 0427009bc924..077a24541584 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -30,6 +30,7 @@
 #include <linux/etherdevice.h>
 #include <net/switchdev.h>
 #include <linux/platform_data/b53.h>
+#include <linux/kexec.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -1133,6 +1134,18 @@ static int bcm_sf2_sw_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static void bcm_sf2_sw_shutdown(struct platform_device *pdev)
+{
+	struct bcm_sf2_priv *priv = platform_get_drvdata(pdev);
+
+	/* For a kernel about to be kexec'd we want to keep the GPHY on for a
+	 * successful MDIO bus scan to occur. If we did turn off the GPHY
+	 * before (e.g: port_disable), this will also power it back on.
+	 */
+	if (priv->hw_params.num_gphy == 1)
+		bcm_sf2_gphy_enable_set(priv->dev->ds, kexec_in_progress);
+}
+
 #ifdef CONFIG_PM_SLEEP
 static int bcm_sf2_suspend(struct device *dev)
 {
@@ -1163,6 +1176,7 @@ MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
 static struct platform_driver bcm_sf2_driver = {
 	.probe	= bcm_sf2_sw_probe,
 	.remove	= bcm_sf2_sw_remove,
+	.shutdown = bcm_sf2_sw_shutdown,
 	.driver = {
 		.name = "brcm-sf2",
 		.of_match_table = bcm_sf2_of_match,
-- 
2.7.4
