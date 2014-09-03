From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 01/11] net:fec: add enet refrence clock for i.MX 6SX chip
Date: Thu, 4 Sep 2014 04:34:36 +0800
Message-ID: <3174.69678489051$1409778757@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

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

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
