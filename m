From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v2 10/12] netdev: mdio-octeon.c: Convert to use device
	tree.
Date: Fri,  4 Mar 2011 11:42:22 -0800
Message-ID: <1299267744-17278-11-git-send-email-ddaney@caviumnetworks.com>
References: <1299267744-17278-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1299267744-17278-1-git-send-email-ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Get the MDIO bus controller addresses from the device tree.

Signed-off-by: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/mips/cavium-octeon/octeon-platform.c |   30 ---------
 drivers/net/phy/mdio-octeon.c             |   92 +++++++++++++++++++---------
 2 files changed, 62 insertions(+), 60 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-platform.c b/arch/mips/cavium-octeon/octeon-platform.c
index 0533351..ce471bd 100644
--- a/arch/mips/cavium-octeon/octeon-platform.c
+++ b/arch/mips/cavium-octeon/octeon-platform.c
@@ -168,36 +168,6 @@ out:
 }
 device_initcall(octeon_rng_device_init);
 
-/* Octeon SMI/MDIO interface.  */
-static int __init octeon_mdiobus_device_init(void)
-{
-	struct platform_device *pd;
-	int ret = 0;
-
-	if (octeon_is_simulation())
-		return 0; /* No mdio in the simulator. */
-
-	/* The bus number is the platform_device id.  */
-	pd = platform_device_alloc("mdio-octeon", 0);
-	if (!pd) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	ret = platform_device_add(pd);
-	if (ret)
-		goto fail;
-
-	return ret;
-fail:
-	platform_device_put(pd);
-
-out:
-	return ret;
-
-}
-device_initcall(octeon_mdiobus_device_init);
-
 /* Octeon mgmt port Ethernet interface.  */
 static int __init octeon_mgmt_device_init(void)
 {
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index bd12ba9..dd33023 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -3,13 +3,15 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2009 Cavium Networks
+ * Copyright (C) 2009, 2010, 2011 Cavium Networks
  */
 
-#include <linux/gfp.h>
-#include <linux/init.h>
-#include <linux/module.h>
 #include <linux/platform_device.h>
+#include <linux/of_mdio.h>
+#include <linux/delay.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/gfp.h>
 #include <linux/phy.h>
 
 #include <asm/octeon/octeon.h>
@@ -18,9 +20,17 @@
 #define DRV_VERSION "1.0"
 #define DRV_DESCRIPTION "Cavium Networks Octeon SMI/MDIO driver"
 
+#define SMI_CMD		0x0
+#define SMI_WR_DAT	0x8
+#define SMI_RD_DAT	0x10
+#define SMI_CLK		0x18
+#define SMI_EN		0x20
+
 struct octeon_mdiobus {
 	struct mii_bus *mii_bus;
-	int unit;
+	u64 register_base;
+	resource_size_t mdio_phys;
+	resource_size_t regsize;
 	int phy_irq[PHY_MAX_ADDR];
 };
 
@@ -35,15 +45,15 @@ static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
 	smi_cmd.s.phy_op = 1; /* MDIO_CLAUSE_22_READ */
 	smi_cmd.s.phy_adr = phy_id;
 	smi_cmd.s.reg_adr = regnum;
-	cvmx_write_csr(CVMX_SMIX_CMD(p->unit), smi_cmd.u64);
+	cvmx_write_csr(p->register_base + SMI_CMD, smi_cmd.u64);
 
 	do {
 		/*
 		 * Wait 1000 clocks so we don't saturate the RSL bus
 		 * doing reads.
 		 */
-		cvmx_wait(1000);
-		smi_rd.u64 = cvmx_read_csr(CVMX_SMIX_RD_DAT(p->unit));
+		__delay(1000);
+		smi_rd.u64 = cvmx_read_csr(p->register_base + SMI_RD_DAT);
 	} while (smi_rd.s.pending && --timeout);
 
 	if (smi_rd.s.val)
@@ -62,21 +72,21 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 
 	smi_wr.u64 = 0;
 	smi_wr.s.dat = val;
-	cvmx_write_csr(CVMX_SMIX_WR_DAT(p->unit), smi_wr.u64);
+	cvmx_write_csr(p->register_base + SMI_WR_DAT, smi_wr.u64);
 
 	smi_cmd.u64 = 0;
 	smi_cmd.s.phy_op = 0; /* MDIO_CLAUSE_22_WRITE */
 	smi_cmd.s.phy_adr = phy_id;
 	smi_cmd.s.reg_adr = regnum;
-	cvmx_write_csr(CVMX_SMIX_CMD(p->unit), smi_cmd.u64);
+	cvmx_write_csr(p->register_base + SMI_CMD, smi_cmd.u64);
 
 	do {
 		/*
 		 * Wait 1000 clocks so we don't saturate the RSL bus
 		 * doing reads.
 		 */
-		cvmx_wait(1000);
-		smi_wr.u64 = cvmx_read_csr(CVMX_SMIX_WR_DAT(p->unit));
+		__delay(1000);
+		smi_wr.u64 = cvmx_read_csr(p->register_base + SMI_WR_DAT);
 	} while (smi_wr.s.pending && --timeout);
 
 	if (timeout <= 0)
@@ -88,8 +98,8 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
+	struct resource *res_mem;
 	union cvmx_smix_en smi_en;
-	int i;
 	int err = -ENOENT;
 
 	bus = devm_kzalloc(&pdev->dev, sizeof(*bus), GFP_KERNEL);
@@ -97,28 +107,36 @@ static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* The platform_device id is our unit number.  */
-	bus->unit = pdev->id;
+	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	if (res_mem == NULL) {
+		dev_err(&pdev->dev, "found no memory resource\n");
+		err = -ENXIO;
+		goto fail_region;
+	}
+	bus->mdio_phys = res_mem->start;
+	bus->regsize = resource_size(res_mem);
+	if (!devm_request_mem_region(&pdev->dev, bus->mdio_phys, bus->regsize,
+				     res_mem->name)) {
+		dev_err(&pdev->dev, "request_mem_region failed\n");
+		goto fail_region;
+	}
+	bus->register_base = (u64)ioremap(bus->mdio_phys, bus->regsize);
 
 	bus->mii_bus = mdiobus_alloc();
 
 	if (!bus->mii_bus)
-		goto err;
+		goto fail_mdio_alloc;
 
 	smi_en.u64 = 0;
 	smi_en.s.en = 1;
-	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
+	cvmx_write_csr(bus->register_base + SMI_EN, smi_en.u64);
 
-	/*
-	 * Standard Octeon evaluation boards don't support phy
-	 * interrupts, we need to poll.
-	 */
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		bus->phy_irq[i] = PHY_POLL;
 
 	bus->mii_bus->priv = bus;
 	bus->mii_bus->irq = bus->phy_irq;
 	bus->mii_bus->name = "mdio-octeon";
-	snprintf(bus->mii_bus->id, MII_BUS_ID_SIZE, "%x", bus->unit);
+	snprintf(bus->mii_bus->id, MII_BUS_ID_SIZE, "%llx", bus->register_base);
 	bus->mii_bus->parent = &pdev->dev;
 
 	bus->mii_bus->read = octeon_mdiobus_read;
@@ -126,20 +144,23 @@ static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 
 	dev_set_drvdata(&pdev->dev, bus);
 
-	err = mdiobus_register(bus->mii_bus);
+	err = of_mdiobus_register(bus->mii_bus, pdev->dev.of_node);
 	if (err)
-		goto err_register;
+		goto fail_register;
 
 	dev_info(&pdev->dev, "Version " DRV_VERSION "\n");
 
 	return 0;
-err_register:
+fail_register:
 	mdiobus_free(bus->mii_bus);
 
-err:
-	devm_kfree(&pdev->dev, bus);
+fail_mdio_alloc:
+	devm_release_mem_region(&pdev->dev, bus->mdio_phys, bus->regsize);
+
+fail_region:
 	smi_en.u64 = 0;
-	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
+	cvmx_write_csr(bus->register_base + SMI_EN, smi_en.u64);
+	devm_kfree(&pdev->dev, bus);
 	return err;
 }
 
@@ -152,15 +173,26 @@ static int __devexit octeon_mdiobus_remove(struct platform_device *pdev)
 
 	mdiobus_unregister(bus->mii_bus);
 	mdiobus_free(bus->mii_bus);
+	devm_release_mem_region(&pdev->dev, bus->mdio_phys, bus->regsize);
 	smi_en.u64 = 0;
-	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
+	cvmx_write_csr(bus->register_base + SMI_EN, smi_en.u64);
+	devm_kfree(&pdev->dev, bus);
 	return 0;
 }
 
+static struct of_device_id octeon_mdiobus_match[] = {
+	{
+		.compatible = "cavium,octeon-3860-mdio",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, octeon_mdiobus_match);
+
 static struct platform_driver octeon_mdiobus_driver = {
 	.driver = {
 		.name		= "mdio-octeon",
 		.owner		= THIS_MODULE,
+		.of_match_table = octeon_mdiobus_match,
 	},
 	.probe		= octeon_mdiobus_probe,
 	.remove		= __devexit_p(octeon_mdiobus_remove),
-- 
1.7.2.3
