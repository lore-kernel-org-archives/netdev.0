From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch v2 net-next 01/12] net:fec: add enet refrence clock for i.MX 6SX chip
Date: Wed, 10 Sep 2014 04:15:32 +0800
Message-ID: <1410293743-27874-2-git-send-email-Frank.Li@freescale.com>
References: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0114.outbound.protection.outlook.com ([157.56.111.114]:20706
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751155AbaIIUjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 16:39:22 -0400
In-Reply-To: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

i.MX6sx enet has below clocks for user config:
clk_ipg: ipg_clk_s, ipg_clk_mac0_s, 66Mhz
clk_ahb: enet system clock, it is enet AXI clock for imx6sx.
	 For imx6sx, it alos is the clock source of interrupt coalescing.
	 The clock range: 200Mhz ~ 266Mhz.
clk_ref: refrence clock for tx and rx. For imx6sx enet RGMII mode,
	 the refrence clock is 125Mhz coming from internal PLL or external.
	 In i.MX6sx-arm2 board, the clock is from internal PLL.
	 clk_ref is optional, depends on board.
clk_enet_out: The clock can be output from internal PLL. It can supply 50Mhz
	 clock for phy. clk_enet_out is optional, depends on chip and board.
clk_ptp: 1588 ts clock. It is optional, depends on chip.

The patch add clk_ref to distiguish the different clocks.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  1 +
 drivers/net/ethernet/freescale/fec_main.c | 17 +++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index ee41d98..635772b 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -272,6 +272,7 @@ struct fec_enet_private {
 
 	struct clk *clk_ipg;
 	struct clk *clk_ahb;
+	struct clk *clk_ref;
 	struct clk *clk_enet_out;
 	struct clk *clk_ptp;
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 89355a7..c21ecff1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1621,6 +1621,11 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 			}
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
+		if (fep->clk_ref) {
+			ret = clk_prepare_enable(fep->clk_ref);
+			if (ret)
+				goto failed_clk_ref;
+		}
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
 		clk_disable_unprepare(fep->clk_ipg);
@@ -1632,9 +1637,15 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 			fep->ptp_clk_on = false;
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
+		if (fep->clk_ref)
+			clk_disable_unprepare(fep->clk_ref);
 	}
 
 	return 0;
+
+failed_clk_ref:
+	if (fep->clk_ref)
+		clk_disable_unprepare(fep->clk_ref);
 failed_clk_ptp:
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
@@ -2637,6 +2648,12 @@ fec_probe(struct platform_device *pdev)
 
 	fep->ptp_clk_on = false;
 	mutex_init(&fep->ptp_clk_mutex);
+
+	/* clk_ref is optional, depends on board */
+	fep->clk_ref = devm_clk_get(&pdev->dev, "enet_clk_ref");
+	if (IS_ERR(fep->clk_ref))
+		fep->clk_ref = NULL;
+
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
 	fep->bufdesc_ex =
 		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
-- 
1.9.1
