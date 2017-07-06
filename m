From: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable option
Date: Thu, 6 Jul 2017 15:05:30 +0200
Message-ID: <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>,
        Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
To: <fugang.duan-3arQi8VN3Tc@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1499346330-12166-1-git-send-email-richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some PHYs (for example the LAN8710) doesn't allow turning the clocks off
and on again without reset (according to their datasheet). Exactly this
behaviour was introduced for power saving reasons by commit e8fcfcd5684a
("net: fec: optimize the clock management to save power")
Therefore add a devictree option to perform a PHY reset and
configuration after every clock enable.

For a better understanding here's a outline of the time response of the
clock and reset lines before and after this patch:

			  v--fec_probe()              v--fec_enet_open()
			  v                           v
	w/o patch eCLK: ___||||||||____________________|||||||||||||||||
	w/o patch nRST: ----__------------------------------------------
	w/o patch CONF: _______XX_______________________________________

	w/  patch eCLK: ___||||||||____________________|||||||||||||||||
	w/  patch nRST: ----__--------------------------__--------------
	w/  patch CONF: _______XX__________________________XX___________
			  ^                           ^
			  ^--fec_probe()              ^--fec_enet_open()

In our case this problem does occur at about every 10th to 50th POR of
an LAN8710 connected to an i.MX6 SoC. The typical symptom of this
problem is a "swinging" ethernet link. Similar issues were experienced
by users of the NXP forum:
	https://community.nxp.com/thread/389902
	https://community.nxp.com/message/309354
With this patch applied the issue didn't occur for at least a few
hundred PORs of our board.

Fixes: e8fcfcd5684a ("net: fec: optimize the clock management to sa...")
Signed-off-by: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |  3 +++
 drivers/net/ethernet/freescale/fec.h              |  1 +
 drivers/net/ethernet/freescale/fec_main.c         | 16 ++++++++++++++++
 3 files changed, 20 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 6f55bdd..1766579 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -23,6 +23,9 @@ Optional properties:
 - phy-handle : phandle to the PHY device connected to this device.
 - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
   Use instead of phy-handle.
+- phy-reset-after-clk-enable : If present then a phy reset and configuration
+  will be performed everytime after the clocks are enabled. This is required
+  for some PHYs to work properly.
 - fsl,num-tx-queues : The property is valid for enet-avb IP, which supports
   hw multi queues. Should specify the tx queue number, otherwise set tx queue
   number to 1.
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 3da8084..d4f658a 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -538,6 +538,7 @@ struct fec_enet_private {
 	int	phy_reset_duration;
 	int	phy_reset_post_delay;
 	bool	phy_reset_active_high;
+	bool	phy_reset_after_clk_enable;
 
 	struct	napi_struct napi;
 	int	csum_flags;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cbbf7b8..4e744f3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -68,6 +68,7 @@
 
 static void set_multicast_list(struct net_device *ndev);
 static void fec_enet_itr_coal_init(struct net_device *ndev);
+static int fec_reset_phy(struct net_device *ndev);
 
 #define DRIVER_NAME	"fec"
 
@@ -1862,6 +1863,18 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		ret = clk_prepare_enable(fep->clk_ref);
 		if (ret)
 			goto failed_clk_ref;
+
+		/* reset the phy after clk is enabled if it's configured */
+		if (fep->phy_reset_after_clk_enable) {
+			ret = fec_reset_phy(ndev);
+			if (ret)
+				goto failed_reset;
+			if (ndev->phydev) {
+				ret = phy_init_hw(ndev->phydev);
+				if (ret)
+					goto failed_reset;
+			}
+		}
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
 		clk_disable_unprepare(fep->clk_enet_out);
@@ -1876,6 +1889,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 
 	return 0;
 
+failed_reset:
 failed_clk_ref:
 	if (fep->clk_ref)
 		clk_disable_unprepare(fep->clk_ref);
@@ -3350,6 +3364,7 @@ fec_probe(struct platform_device *pdev)
 			fep->phy_reset_post_delay = 1;
 
 		fep->phy_reset_active_high =  of_property_read_bool(np, "phy-reset-active-high");
+		fep->phy_reset_after_clk_enable = of_property_read_bool(np, "phy-reset-after-clk-enable");
 
 		ret = devm_gpio_request_one(&pdev->dev, fep->phy_reset,
 					    fep->phy_reset_active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
@@ -3360,6 +3375,7 @@ fec_probe(struct platform_device *pdev)
 		}
 	} else {
 		fep->phy_reset = 0;
+		fep->phy_reset_after_clk_enable = false;
 	}
 
 	ret = of_get_phy_mode(pdev->dev.of_node);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
