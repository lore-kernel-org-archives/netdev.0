From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 21/27] net: mvpp2: handle register mapping and access for PPv2.2
Date: Wed, 21 Dec 2016 12:16:28 +0100
Message-ID: <1482318994-23488-22-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56124 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757422AbcLULQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:16:46 -0500
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adjusts the mvpp2 driver register mapping and access logic
to support PPv2.2, to handle a number of differences.

Due to how the registers are laid out in memory, the Device Tree binding
for the "reg" property is different:

 - On PPv2.1, we had a first area for the common registers, and then one
   area per port.

 - On PPv2.2, we have a first area for the common registers, and a
   second area for all the per-ports registers.

In addition, on PPv2.2, the area for the common registers is split into
so-called "address spaces" of 64 KB each. They allow to access the same
registers, but from different CPUs. Hence the introduction of cpu_base[]
in 'struct mvpp2', and the modification of the mvpp2_write() and
mvpp2_read() register accessors. For PPv2.1, the compatibility is
preserved by using an "address space" size of 0.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 78 +++++++++++++++++++++++++++++-------
 1 file changed, 64 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index eb9fe86..4163b0e 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -304,6 +304,9 @@
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(v)	(((v) << 6) & \
 					MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK)
 
+#define MVPP22_PORT_BASE			0x30e00
+#define MVPP22_PORT_OFFSET			0x1000
+
 #define MVPP2_CAUSE_TXQ_SENT_DESC_ALL_MASK	0xff
 
 /* Descriptor ring Macros */
@@ -631,6 +634,11 @@ enum mvpp2_prs_l3_cast {
  */
 #define MVPP2_BM_SHORT_PKT_SIZE		MVPP2_RX_MAX_PKT_SIZE(512)
 
+#define MVPP21_ADDR_SPACE_SZ		0
+#define MVPP22_ADDR_SPACE_SZ		SZ_64K
+
+#define MVPP2_MAX_CPUS			4
+
 enum mvpp2_bm_type {
 	MVPP2_BM_FREE,
 	MVPP2_BM_SWF_LONG,
@@ -644,6 +652,13 @@ struct mvpp2 {
 	/* Shared registers' base addresses */
 	void __iomem *base;
 	void __iomem *lms_base;
+	void __iomem *iface_base;
+
+	/* On PPv2.2, each CPU can access the base register through a
+	 * separate address space, each 64 KB apart from each
+	 * other.
+	 */
+	void __iomem *cpu_base[MVPP2_MAX_CPUS];
 
 	/* Common clocks */
 	struct clk *pp_clk;
@@ -1021,12 +1036,21 @@ static int txq_number = MVPP2_MAX_TXQ;
 
 static void mvpp2_write(struct mvpp2 *priv, u32 offset, u32 data)
 {
-	writel(data, priv->base + offset);
+	int cpu = get_cpu();
+
+	writel(data, priv->cpu_base[cpu] + offset);
+	put_cpu();
 }
 
 static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 {
-	return readl(priv->base + offset);
+	int cpu = get_cpu();
+	u32 val;
+
+	val = readl(priv->cpu_base[cpu] + offset);
+	put_cpu();
+
+	return val;
 }
 
 static dma_addr_t mvpp2_txdesc_phys_addr_get(struct mvpp2_port *port,
@@ -6408,7 +6432,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	u32 id;
 	int features;
 	int phy_mode;
-	int priv_common_regs_num = 2;
 	int err, i, cpu;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mvpp2_port), txq_number,
@@ -6458,12 +6481,24 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	port->phy_node = phy_node;
 	port->phy_interface = phy_mode;
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM,
-				    priv_common_regs_num + id);
-	port->base = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(port->base)) {
-		err = PTR_ERR(port->base);
-		goto err_free_irq;
+	if (priv->ip_version == MVPP21) {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 2 + id);
+		port->base = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(port->base)) {
+			err = PTR_ERR(port->base);
+			goto err_free_irq;
+		}
+	} else {
+		u32 gop_id;
+
+		if (of_property_read_u32(port_node, "gop-port-id", &gop_id)) {
+			err = -EINVAL;
+			dev_err(&pdev->dev, "missing gop-port-id value\n");
+			goto err_free_irq;
+		}
+
+		port->base = priv->iface_base + MVPP22_PORT_BASE +
+			gop_id * MVPP22_PORT_OFFSET;
 	}
 
 	/* Alloc per-cpu stats */
@@ -6691,7 +6726,7 @@ static int mvpp2_probe(struct platform_device *pdev)
 	struct device_node *port_node;
 	struct mvpp2 *priv;
 	struct resource *res;
-	int port_count, first_rxq;
+	int port_count, first_rxq, cpu;
 	int err;
 
 	priv = devm_kzalloc(&pdev->dev, sizeof(struct mvpp2), GFP_KERNEL);
@@ -6706,10 +6741,25 @@ static int mvpp2_probe(struct platform_device *pdev)
 	if (IS_ERR(priv->base))
 		return PTR_ERR(priv->base);
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	priv->lms_base = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(priv->lms_base))
-		return PTR_ERR(priv->lms_base);
+	if (priv->ip_version == MVPP21) {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		priv->lms_base = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(priv->lms_base))
+			return PTR_ERR(priv->lms_base);
+	} else {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		priv->iface_base = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(priv->iface_base))
+			return PTR_ERR(priv->iface_base);
+	}
+
+	for_each_present_cpu(cpu) {
+		u32 addr_space_sz;
+
+		addr_space_sz = (priv->ip_version == MVPP21 ?
+				 MVPP21_ADDR_SPACE_SZ : MVPP22_ADDR_SPACE_SZ);
+		priv->cpu_base[cpu] = priv->base + cpu * addr_space_sz;
+	}
 
 	priv->pp_clk = devm_clk_get(&pdev->dev, "pp_clk");
 	if (IS_ERR(priv->pp_clk))
-- 
2.7.4
