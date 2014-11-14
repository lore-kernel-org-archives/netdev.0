From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH v2] can: Fix bug in suspend/resume
Date: Fri, 14 Nov 2014 13:46:19 +0530
Message-ID: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<grant.likely@linaro.org>, <robh+dt@kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The drvdata in the suspend/resume is of type struct net_device,
not the platform device.Enable the clocks in the suspend before
accessing the registers of the CAN.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v2:
  - Removed the struct platform_device* from suspend/resume
    as suggest by Lothar.
  - The clocks are getting disabled and un prepared at the end of the probe. 
    In the suspend the driver is doing a register write.In order
    To do that register write we have to again enable and prepare the clocks.

  
 drivers/net/can/xilinx_can.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 5e8b560..485262f 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -972,15 +972,28 @@ static const struct net_device_ops xcan_netdev_ops = {
  */
 static int __maybe_unused xcan_suspend(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct xcan_priv *priv = netdev_priv(ndev);
+	int ret;
 
 	if (netif_running(ndev)) {
 		netif_stop_queue(ndev);
 		netif_device_detach(ndev);
 	}
 
+	ret = clk_prepare_enable(priv->can_clk);
+	if (ret) {
+		dev_err(dev, "unable to enable device clock\n");
+		return ret;
+	}
+
+	ret = clk_prepare_enable(priv->bus_clk);
+	if (ret) {
+		dev_err(dev, "unable to enable bus clock\n");
+		clk_disable_unprepare(priv->can_clk);
+		return ret;
+	}
+
 	priv->write_reg(priv, XCAN_MSR_OFFSET, XCAN_MSR_SLEEP_MASK);
 	priv->can.state = CAN_STATE_SLEEPING;
 
@@ -999,8 +1012,7 @@ static int __maybe_unused xcan_suspend(struct device *dev)
  */
 static int __maybe_unused xcan_resume(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct xcan_priv *priv = netdev_priv(ndev);
 	int ret;
 
-- 
1.7.4

