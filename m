From: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: macb: add phy-handle support for the macb
Date: Sat, 13 Aug 2016 15:31:49 +0530
Message-ID: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>,
	<gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	<michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for the 'phy-handle' binding which allows for a
system to specifically select a phy which can be attached via any MDIO
bus available in the system.

Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/devicetree/bindings/net/macb.txt |  3 +++
 drivers/net/ethernet/cadence/macb.c            | 11 +++++++++--
 drivers/net/ethernet/cadence/macb.h            |  1 +
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5a42df..3cfff7c 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -23,6 +23,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- phy-handle	: See ethernet.txt file in the same directory.
+
 Optional properties for PHY child node:
 - reset-gpios : Should specify the gpio for phy reset
 - magic-packet : If present, indicates that the hardware supports waking
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6b797e3..4ddd45d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -421,7 +421,7 @@ static int macb_mii_probe(struct net_device *dev)
 static int macb_mii_init(struct macb *bp)
 {
 	struct macb_platform_data *pdata;
-	struct device_node *np;
+	struct device_node *np, *np1;
 	int err = -ENXIO, i;
 
 	/* Enable management port */
@@ -445,7 +445,13 @@ static int macb_mii_init(struct macb *bp)
 	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
 
 	np = bp->pdev->dev.of_node;
-	if (np) {
+	np1 = of_get_parent(bp->phy_node);
+	if (np1) {
+		of_node_put(np1);
+		err = of_mdiobus_register(bp->mii_bus, np1);
+		if (err)
+			goto err_out_unregister_bus;
+	} else if (np) {
 		/* try dt phy registration */
 		err = of_mdiobus_register(bp->mii_bus, np);
 
@@ -3016,6 +3022,7 @@ static int macb_probe(struct platform_device *pdev)
 	} else {
 		bp->phy_interface = err;
 	}
+	bp->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
 	/* IP specific init */
 	err = init(pdev);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index aa3aeec..83d1617 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -855,6 +855,7 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+	struct device_node	*phy_node;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
