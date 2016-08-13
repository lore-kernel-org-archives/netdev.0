From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 08/12] drivers: net: xgene: Poll link status via GPIO
Date: Fri, 12 Aug 2016 22:05:44 -0700
Message-ID: <1471064748-28033-9-git-send-email-isubramanian@apm.com>
References: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>,
	Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35754 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbcHMFFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 01:05:00 -0400
Received: by mail-pa0-f44.google.com with SMTP id i5so1972132pat.2
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 22:05:00 -0700 (PDT)
In-Reply-To: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When 10GbE SFP+ module is not plugged in or cable is not connected,
the link status register does not report the proper state due
to floating signal. This patch checks the module present status via an
GPIO to determine whether to ignore the link status register and report
link down.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 drivers/net/ethernet/apm/xgene/Kconfig            |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 15 +++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  6 ++++++
 4 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
index 300e3b5..afccb03 100644
--- a/drivers/net/ethernet/apm/xgene/Kconfig
+++ b/drivers/net/ethernet/apm/xgene/Kconfig
@@ -4,6 +4,7 @@ config NET_XGENE
 	depends on ARCH_XGENE || COMPILE_TEST
 	select PHYLIB
 	select MDIO_XGENE
+	select GPIOLIB
 	help
 	  This is the Ethernet driver for the on-chip ethernet interface on the
 	  APM X-Gene SoC.
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 01a9aaf..b8b9495 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -19,6 +19,7 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
+#include <linux/gpio.h>
 #include "xgene_enet_main.h"
 #include "xgene_enet_hw.h"
 #include "xgene_enet_sgmac.h"
@@ -1320,6 +1321,18 @@ static int xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static void xgene_enet_gpiod_get(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+
+	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII)
+		return;
+
+	pdata->sfp_rdy = gpiod_get(dev, "rxlos", GPIOD_IN);
+	if (IS_ERR(pdata->sfp_rdy))
+		pdata->sfp_rdy = gpiod_get(dev, "sfp", GPIOD_IN);
+}
+
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
 	struct platform_device *pdev;
@@ -1409,6 +1422,8 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (ret)
 		return ret;
 
+	xgene_enet_gpiod_get(pdata);
+
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
 		/* Firmware may have set up the clock already. */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 53f4a16..b339fc1 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -217,6 +217,7 @@ struct xgene_enet_pdata {
 	u8 tx_delay;
 	u8 rx_delay;
 	bool mdio_driver;
+	struct gpio_desc *sfp_rdy;
 };
 
 struct xgene_indirect_ctl {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 4087dba..d672e71 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -18,6 +18,8 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
+#include <linux/of_gpio.h>
+#include <linux/gpio.h>
 #include "xgene_enet_main.h"
 #include "xgene_enet_hw.h"
 #include "xgene_enet_xgmac.h"
@@ -399,10 +401,14 @@ static void xgene_enet_link_state(struct work_struct *work)
 {
 	struct xgene_enet_pdata *pdata = container_of(to_delayed_work(work),
 					 struct xgene_enet_pdata, link_work);
+	struct gpio_desc *sfp_rdy = pdata->sfp_rdy;
 	struct net_device *ndev = pdata->ndev;
 	u32 link_status, poll_interval;
 
 	link_status = xgene_enet_link_status(pdata);
+	if (link_status && !IS_ERR(sfp_rdy) && !gpiod_get_value(sfp_rdy))
+		link_status = 0;
+
 	if (link_status) {
 		if (!netif_carrier_ok(ndev)) {
 			netif_carrier_on(ndev);
-- 
1.9.1
