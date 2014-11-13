From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH] can: Fix bug in suspend/resume
Date: Thu, 13 Nov 2014 12:28:11 +0530
Message-ID: <a44efc1fb0144cca9d0c4851cc51db25@BL2FFO11FD024.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-can@vger.kernel.org,
 Kedareswara rao Appana <appanad@xilinx.com>,
 linux-arm-kernel@lists.infradead.org
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <michal.simek@xilinx.com>,
 <soren.brinkmann@xilinx.com>, <grant.likely@linaro.org>, <robh+dt@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

When accessing the priv structure use container_of instead of dev_get_drvdata.
Enable the clocks in the suspend before accessing the registers of the CAN.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/can/xilinx_can.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 5e8b560..63ef645 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -972,15 +972,30 @@ static const struct net_device_ops xcan_netdev_ops = {
  */
 static int __maybe_unused xcan_suspend(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
+	struct platform_device *pdev = container_of(dev,
+			struct platform_device, dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
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
 
@@ -999,7 +1014,8 @@ static int __maybe_unused xcan_suspend(struct device *dev)
  */
 static int __maybe_unused xcan_resume(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
+	struct platform_device *pdev = container_of(dev,
+			struct platform_device, dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct xcan_priv *priv = netdev_priv(ndev);
 	int ret;
-- 
1.7.4
