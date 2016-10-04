From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 05/13] fsl/fman: simplify device tree reads
Date: Tue, 4 Oct 2016 10:32:51 +0300
Message-ID: <1475566379-5078-6-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@freescale.com>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c      | 30 ++++++++++---------------
 drivers/net/ethernet/freescale/fman/fman_port.c | 24 ++++++--------------
 drivers/net/ethernet/freescale/fman/mac.c       | 24 +++++++++-----------
 3 files changed, 30 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index fb25748..2278bbd 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2737,8 +2737,8 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 	struct fman *fman;
 	struct device_node *fm_node, *muram_node;
 	struct resource *res;
-	const u32 *u32_prop;
-	int lenp, err, irq;
+	u32 val, range[2];
+	int err, irq;
 	struct clk *clk;
 	u32 clk_rate;
 	phys_addr_t phys_base_addr;
@@ -2750,16 +2750,13 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 
 	fm_node = of_node_get(of_dev->dev.of_node);
 
-	u32_prop = (const u32 *)of_get_property(fm_node, "cell-index", &lenp);
-	if (!u32_prop) {
-		dev_err(&of_dev->dev, "%s: of_get_property(%s, cell-index) failed\n",
+	err = of_property_read_u32(fm_node, "cell-index", &val);
+	if (err) {
+		dev_err(&of_dev->dev, "%s: failed to read cell-index for %s\n",
 			__func__, fm_node->full_name);
 		goto fman_node_put;
 	}
-	if (WARN_ON(lenp != sizeof(u32)))
-		goto fman_node_put;
-
-	fman->dts_params.id = (u8)fdt32_to_cpu(u32_prop[0]);
+	fman->dts_params.id = (u8)val;
 
 	/* Get the FM interrupt */
 	res = platform_get_resource(of_dev, IORESOURCE_IRQ, 0);
@@ -2806,18 +2803,15 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 	/* Rounding to MHz */
 	fman->dts_params.clk_freq = DIV_ROUND_UP(clk_rate, 1000000);
 
-	u32_prop = (const u32 *)of_get_property(fm_node,
-						"fsl,qman-channel-range",
-						&lenp);
-	if (!u32_prop) {
-		dev_err(&of_dev->dev, "%s: of_get_property(%s, fsl,qman-channel-range) failed\n",
+	err = of_property_read_u32_array(fm_node, "fsl,qman-channel-range",
+					 &range[0], 2);
+	if (err) {
+		dev_err(&of_dev->dev, "%s: failed to read fsl,qman-channel-range for %s\n",
 			__func__, fm_node->full_name);
 		goto fman_node_put;
 	}
-	if (WARN_ON(lenp != sizeof(u32) * 2))
-		goto fman_node_put;
-	fman->dts_params.qman_channel_base = fdt32_to_cpu(u32_prop[0]);
-	fman->dts_params.num_of_qman_channels = fdt32_to_cpu(u32_prop[1]);
+	fman->dts_params.qman_channel_base = range[0];
+	fman->dts_params.num_of_qman_channels = range[1];
 
 	/* Get the MURAM base address and size */
 	muram_node = of_find_matching_node(fm_node, fman_muram_match);
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index 8b043e7..9f3bb50 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1625,7 +1625,7 @@ static int fman_port_probe(struct platform_device *of_dev)
 	struct device_node *fm_node, *port_node;
 	struct resource res;
 	struct resource *dev_res;
-	const u32 *u32_prop;
+	u32 val;
 	int err = 0, lenp;
 	enum fman_port_type port_type;
 	u16 port_speed;
@@ -1654,28 +1654,20 @@ static int fman_port_probe(struct platform_device *of_dev)
 		goto return_err;
 	}
 
-	u32_prop = (const u32 *)of_get_property(port_node, "cell-index", &lenp);
-	if (!u32_prop) {
-		dev_err(port->dev, "%s: of_get_property(%s, cell-index) failed\n",
+	err = of_property_read_u32(port_node, "cell-index", &val);
+	if (err) {
+		dev_err(port->dev, "%s: reading cell-index for %s failed\n",
 			__func__, port_node->full_name);
 		err = -EINVAL;
 		goto return_err;
 	}
-	if (WARN_ON(lenp != sizeof(u32))) {
-		err = -EINVAL;
-		goto return_err;
-	}
-	port_id = (u8)fdt32_to_cpu(u32_prop[0]);
-
+	port_id = (u8)val;
 	port->dts_params.id = port_id;
 
 	if (of_device_is_compatible(port_node, "fsl,fman-v3-port-tx")) {
 		port_type = FMAN_PORT_TYPE_TX;
 		port_speed = 1000;
-		u32_prop = (const u32 *)of_get_property(port_node,
-							"fsl,fman-10g-port",
-							&lenp);
-		if (u32_prop)
+		if (of_find_property(port_node, "fsl,fman-10g-port", &lenp))
 			port_speed = 10000;
 
 	} else if (of_device_is_compatible(port_node, "fsl,fman-v2-port-tx")) {
@@ -1688,9 +1680,7 @@ static int fman_port_probe(struct platform_device *of_dev)
 	} else if (of_device_is_compatible(port_node, "fsl,fman-v3-port-rx")) {
 		port_type = FMAN_PORT_TYPE_RX;
 		port_speed = 1000;
-		u32_prop = (const u32 *)of_get_property(port_node,
-						  "fsl,fman-10g-port", &lenp);
-		if (u32_prop)
+		if (of_find_property(port_node, "fsl,fman-10g-port", &lenp))
 			port_speed = 10000;
 
 	} else if (of_device_is_compatible(port_node, "fsl,fman-v2-port-rx")) {
diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index f94fad7..dc04e61 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -653,7 +653,7 @@ MODULE_DEVICE_TABLE(of, mac_match);
 
 static int mac_probe(struct platform_device *_of_dev)
 {
-	int			 err, i, lenp, nph;
+	int			 err, i, nph;
 	struct device		*dev;
 	struct device_node	*mac_node, *dev_node;
 	struct mac_device	*mac_dev;
@@ -661,7 +661,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	struct resource		 res;
 	struct mac_priv_s	*priv;
 	const u8		*mac_addr;
-	const u32		*u32_prop;
+	u32			 val;
 	u8			fman_id;
 
 	dev = &_of_dev->dev;
@@ -723,16 +723,15 @@ static int mac_probe(struct platform_device *_of_dev)
 	}
 
 	/* Get the FMan cell-index */
-	u32_prop = of_get_property(dev_node, "cell-index", &lenp);
-	if (!u32_prop) {
-		dev_err(dev, "of_get_property(%s, cell-index) failed\n",
+	err = of_property_read_u32(dev_node, "cell-index", &val);
+	if (err) {
+		dev_err(dev, "failed to read cell-index for %s\n",
 			dev_node->full_name);
 		err = -EINVAL;
 		goto _return_of_node_put;
 	}
-	WARN_ON(lenp != sizeof(u32));
 	/* cell-index 0 => FMan id 1 */
-	fman_id = (u8)(fdt32_to_cpu(u32_prop[0]) + 1);
+	fman_id = (u8)(val + 1);
 
 	priv->fman = fman_bind(&of_dev->dev);
 	if (!priv->fman) {
@@ -779,15 +778,14 @@ static int mac_probe(struct platform_device *_of_dev)
 	}
 
 	/* Get the cell-index */
-	u32_prop = of_get_property(mac_node, "cell-index", &lenp);
-	if (!u32_prop) {
-		dev_err(dev, "of_get_property(%s, cell-index) failed\n",
+	err = of_property_read_u32(mac_node, "cell-index", &val);
+	if (err) {
+		dev_err(dev, "failed to read cell-index for %s\n",
 			mac_node->full_name);
 		err = -EINVAL;
 		goto _return_dev_set_drvdata;
 	}
-	WARN_ON(lenp != sizeof(u32));
-	priv->cell_index = (u8)fdt32_to_cpu(u32_prop[0]);
+	priv->cell_index = (u8)val;
 
 	/* Get the MAC address */
 	mac_addr = of_get_mac_address(mac_node);
@@ -847,7 +845,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	priv->phy_if = of_get_phy_mode(mac_node);
 	if (priv->phy_if < 0) {
 		dev_warn(dev,
-			 "of_get_property(%s, phy-connection-type) failed. Defaulting to MII\n",
+			 "of_get_phy_mode() for %s failed. Defaulting to MII\n",
 			 mac_node->full_name);
 		priv->phy_if = PHY_INTERFACE_MODE_MII;
 	}
-- 
2.1.0
