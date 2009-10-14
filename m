From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/6] net: Add driver for Octeon MDIO buses.
Date: Wed, 14 Oct 2009 12:04:38 -0700
Message-ID: <1255547082-7388-2-git-send-email-ddaney@caviumnetworks.com>
References: <4AD6205A.8070200@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4AD6205A.8070200@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

The Octeon SOC has two types of Ethernet ports, each type with its own
driver.  However, the PHYs for all the ports are controlled by a
common MDIO bus.  Because the mdio driver is not associated with a
particular driver, but is instead a system level resource, we create s
stand-alone driver for it.

As for the driver, we put the register definitions in
arch/mips/include/asm/octeon where most of the other Octeon register
definitions live.  This is a platform driver with the platform device
for "mdio-octeon" being registered in the platform startup code.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/mips/include/asm/octeon/cvmx-smix-defs.h |  178 ++++++++++++++++++++++++
 drivers/net/phy/Kconfig                       |   11 ++
 drivers/net/phy/Makefile                      |    1 +
 drivers/net/phy/mdio-octeon.c                 |  180 +++++++++++++++++++++++++
 4 files changed, 370 insertions(+), 0 deletions(-)
 create mode 100644 arch/mips/include/asm/octeon/cvmx-smix-defs.h
 create mode 100644 drivers/net/phy/mdio-octeon.c

diff --git a/arch/mips/include/asm/octeon/cvmx-smix-defs.h b/arch/mips/include/asm/octeon/cvmx-smix-defs.h
new file mode 100644
index 0000000..9ae45fc
--- /dev/null
+++ b/arch/mips/include/asm/octeon/cvmx-smix-defs.h
@@ -0,0 +1,178 @@
+/***********************license start***************
+ * Author: Cavium Networks
+ *
+ * Contact: support@caviumnetworks.com
+ * This file is part of the OCTEON SDK
+ *
+ * Copyright (c) 2003-2008 Cavium Networks
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this file; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
+ * or visit http://www.gnu.org/licenses/.
+ *
+ * This file may also be available under a different license from Cavium.
+ * Contact Cavium Networks for more information
+ ***********************license end**************************************/
+
+#ifndef __CVMX_SMIX_DEFS_H__
+#define __CVMX_SMIX_DEFS_H__
+
+#define CVMX_SMIX_CLK(offset) \
+	 CVMX_ADD_IO_SEG(0x0001180000001818ull + (((offset) & 1) * 256))
+#define CVMX_SMIX_CMD(offset) \
+	 CVMX_ADD_IO_SEG(0x0001180000001800ull + (((offset) & 1) * 256))
+#define CVMX_SMIX_EN(offset) \
+	 CVMX_ADD_IO_SEG(0x0001180000001820ull + (((offset) & 1) * 256))
+#define CVMX_SMIX_RD_DAT(offset) \
+	 CVMX_ADD_IO_SEG(0x0001180000001810ull + (((offset) & 1) * 256))
+#define CVMX_SMIX_WR_DAT(offset) \
+	 CVMX_ADD_IO_SEG(0x0001180000001808ull + (((offset) & 1) * 256))
+
+union cvmx_smix_clk {
+	uint64_t u64;
+	struct cvmx_smix_clk_s {
+		uint64_t reserved_25_63:39;
+		uint64_t mode:1;
+		uint64_t reserved_21_23:3;
+		uint64_t sample_hi:5;
+		uint64_t sample_mode:1;
+		uint64_t reserved_14_14:1;
+		uint64_t clk_idle:1;
+		uint64_t preamble:1;
+		uint64_t sample:4;
+		uint64_t phase:8;
+	} s;
+	struct cvmx_smix_clk_cn30xx {
+		uint64_t reserved_21_63:43;
+		uint64_t sample_hi:5;
+		uint64_t reserved_14_15:2;
+		uint64_t clk_idle:1;
+		uint64_t preamble:1;
+		uint64_t sample:4;
+		uint64_t phase:8;
+	} cn30xx;
+	struct cvmx_smix_clk_cn30xx cn31xx;
+	struct cvmx_smix_clk_cn30xx cn38xx;
+	struct cvmx_smix_clk_cn30xx cn38xxp2;
+	struct cvmx_smix_clk_cn50xx {
+		uint64_t reserved_25_63:39;
+		uint64_t mode:1;
+		uint64_t reserved_21_23:3;
+		uint64_t sample_hi:5;
+		uint64_t reserved_14_15:2;
+		uint64_t clk_idle:1;
+		uint64_t preamble:1;
+		uint64_t sample:4;
+		uint64_t phase:8;
+	} cn50xx;
+	struct cvmx_smix_clk_s cn52xx;
+	struct cvmx_smix_clk_cn50xx cn52xxp1;
+	struct cvmx_smix_clk_s cn56xx;
+	struct cvmx_smix_clk_cn50xx cn56xxp1;
+	struct cvmx_smix_clk_cn30xx cn58xx;
+	struct cvmx_smix_clk_cn30xx cn58xxp1;
+};
+
+union cvmx_smix_cmd {
+	uint64_t u64;
+	struct cvmx_smix_cmd_s {
+		uint64_t reserved_18_63:46;
+		uint64_t phy_op:2;
+		uint64_t reserved_13_15:3;
+		uint64_t phy_adr:5;
+		uint64_t reserved_5_7:3;
+		uint64_t reg_adr:5;
+	} s;
+	struct cvmx_smix_cmd_cn30xx {
+		uint64_t reserved_17_63:47;
+		uint64_t phy_op:1;
+		uint64_t reserved_13_15:3;
+		uint64_t phy_adr:5;
+		uint64_t reserved_5_7:3;
+		uint64_t reg_adr:5;
+	} cn30xx;
+	struct cvmx_smix_cmd_cn30xx cn31xx;
+	struct cvmx_smix_cmd_cn30xx cn38xx;
+	struct cvmx_smix_cmd_cn30xx cn38xxp2;
+	struct cvmx_smix_cmd_s cn50xx;
+	struct cvmx_smix_cmd_s cn52xx;
+	struct cvmx_smix_cmd_s cn52xxp1;
+	struct cvmx_smix_cmd_s cn56xx;
+	struct cvmx_smix_cmd_s cn56xxp1;
+	struct cvmx_smix_cmd_cn30xx cn58xx;
+	struct cvmx_smix_cmd_cn30xx cn58xxp1;
+};
+
+union cvmx_smix_en {
+	uint64_t u64;
+	struct cvmx_smix_en_s {
+		uint64_t reserved_1_63:63;
+		uint64_t en:1;
+	} s;
+	struct cvmx_smix_en_s cn30xx;
+	struct cvmx_smix_en_s cn31xx;
+	struct cvmx_smix_en_s cn38xx;
+	struct cvmx_smix_en_s cn38xxp2;
+	struct cvmx_smix_en_s cn50xx;
+	struct cvmx_smix_en_s cn52xx;
+	struct cvmx_smix_en_s cn52xxp1;
+	struct cvmx_smix_en_s cn56xx;
+	struct cvmx_smix_en_s cn56xxp1;
+	struct cvmx_smix_en_s cn58xx;
+	struct cvmx_smix_en_s cn58xxp1;
+};
+
+union cvmx_smix_rd_dat {
+	uint64_t u64;
+	struct cvmx_smix_rd_dat_s {
+		uint64_t reserved_18_63:46;
+		uint64_t pending:1;
+		uint64_t val:1;
+		uint64_t dat:16;
+	} s;
+	struct cvmx_smix_rd_dat_s cn30xx;
+	struct cvmx_smix_rd_dat_s cn31xx;
+	struct cvmx_smix_rd_dat_s cn38xx;
+	struct cvmx_smix_rd_dat_s cn38xxp2;
+	struct cvmx_smix_rd_dat_s cn50xx;
+	struct cvmx_smix_rd_dat_s cn52xx;
+	struct cvmx_smix_rd_dat_s cn52xxp1;
+	struct cvmx_smix_rd_dat_s cn56xx;
+	struct cvmx_smix_rd_dat_s cn56xxp1;
+	struct cvmx_smix_rd_dat_s cn58xx;
+	struct cvmx_smix_rd_dat_s cn58xxp1;
+};
+
+union cvmx_smix_wr_dat {
+	uint64_t u64;
+	struct cvmx_smix_wr_dat_s {
+		uint64_t reserved_18_63:46;
+		uint64_t pending:1;
+		uint64_t val:1;
+		uint64_t dat:16;
+	} s;
+	struct cvmx_smix_wr_dat_s cn30xx;
+	struct cvmx_smix_wr_dat_s cn31xx;
+	struct cvmx_smix_wr_dat_s cn38xx;
+	struct cvmx_smix_wr_dat_s cn38xxp2;
+	struct cvmx_smix_wr_dat_s cn50xx;
+	struct cvmx_smix_wr_dat_s cn52xx;
+	struct cvmx_smix_wr_dat_s cn52xxp1;
+	struct cvmx_smix_wr_dat_s cn56xx;
+	struct cvmx_smix_wr_dat_s cn56xxp1;
+	struct cvmx_smix_wr_dat_s cn58xx;
+	struct cvmx_smix_wr_dat_s cn58xxp1;
+};
+
+#endif
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d5d8e1c..fc5938b 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -115,4 +115,15 @@ config MDIO_GPIO
 	  To compile this driver as a module, choose M here: the module
 	  will be called mdio-gpio.
 
+config MDIO_OCTEON
+	tristate "Support for MDIO buses on Octeon SOCs"
+	depends on  CPU_CAVIUM_OCTEON
+	default y
+	help
+
+	  This module provides a driver for the Octeon MDIO busses.
+	  It is required by the Octeon Ethernet device drivers.
+
+	  If in doubt, say Y.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index edfaac4..1342585 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -20,3 +20,4 @@ obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
+obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
new file mode 100644
index 0000000..61a4461
--- /dev/null
+++ b/drivers/net/phy/mdio-octeon.c
@@ -0,0 +1,180 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2009 Cavium Networks
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+
+#include <asm/octeon/octeon.h>
+#include <asm/octeon/cvmx-smix-defs.h>
+
+#define DRV_VERSION "1.0"
+#define DRV_DESCRIPTION "Cavium Networks Octeon SMI/MDIO driver"
+
+struct octeon_mdiobus {
+	struct mii_bus *mii_bus;
+	int unit;
+	int phy_irq[PHY_MAX_ADDR];
+};
+
+static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
+{
+	struct octeon_mdiobus *p = bus->priv;
+	union cvmx_smix_cmd smi_cmd;
+	union cvmx_smix_rd_dat smi_rd;
+	int timeout = 1000;
+
+	smi_cmd.u64 = 0;
+	smi_cmd.s.phy_op = 1; /* MDIO_CLAUSE_22_READ */
+	smi_cmd.s.phy_adr = phy_id;
+	smi_cmd.s.reg_adr = regnum;
+	cvmx_write_csr(CVMX_SMIX_CMD(p->unit), smi_cmd.u64);
+
+	do {
+		/*
+		 * Wait 1000 clocks so we don't saturate the RSL bus
+		 * doing reads.
+		 */
+		cvmx_wait(1000);
+		smi_rd.u64 = cvmx_read_csr(CVMX_SMIX_RD_DAT(p->unit));
+	} while (smi_rd.s.pending && --timeout);
+
+	if (smi_rd.s.val)
+		return smi_rd.s.dat;
+	else
+		return -EIO;
+}
+
+static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
+				int regnum, u16 val)
+{
+	struct octeon_mdiobus *p = bus->priv;
+	union cvmx_smix_cmd smi_cmd;
+	union cvmx_smix_wr_dat smi_wr;
+	int timeout = 1000;
+
+	smi_wr.u64 = 0;
+	smi_wr.s.dat = val;
+	cvmx_write_csr(CVMX_SMIX_WR_DAT(p->unit), smi_wr.u64);
+
+	smi_cmd.u64 = 0;
+	smi_cmd.s.phy_op = 0; /* MDIO_CLAUSE_22_WRITE */
+	smi_cmd.s.phy_adr = phy_id;
+	smi_cmd.s.reg_adr = regnum;
+	cvmx_write_csr(CVMX_SMIX_CMD(p->unit), smi_cmd.u64);
+
+	do {
+		/*
+		 * Wait 1000 clocks so we don't saturate the RSL bus
+		 * doing reads.
+		 */
+		cvmx_wait(1000);
+		smi_wr.u64 = cvmx_read_csr(CVMX_SMIX_WR_DAT(p->unit));
+	} while (smi_wr.s.pending && --timeout);
+
+	if (timeout <= 0)
+		return -EIO;
+
+	return 0;
+}
+
+static int __init octeon_mdiobus_probe(struct platform_device *pdev)
+{
+	struct octeon_mdiobus *bus;
+	int i;
+	int err = -ENOENT;
+
+	bus = devm_kzalloc(&pdev->dev, sizeof(*bus), GFP_KERNEL);
+	if (!bus)
+		return -ENOMEM;
+
+	/* The platform_device id is our unit number.  */
+	bus->unit = pdev->id;
+
+	bus->mii_bus = mdiobus_alloc();
+
+	if (!bus->mii_bus)
+		goto err;
+
+	/*
+	 * Standard Octeon evaluation boards don't support phy
+	 * interrupts, we need to poll.
+	 */
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bus->phy_irq[i] = PHY_POLL;
+
+	bus->mii_bus->priv = bus;
+	bus->mii_bus->irq = bus->phy_irq;
+	bus->mii_bus->name = "mdio-octeon";
+	snprintf(bus->mii_bus->id, MII_BUS_ID_SIZE, "%x", bus->unit);
+	bus->mii_bus->parent = &pdev->dev;
+
+	bus->mii_bus->read = octeon_mdiobus_read;
+	bus->mii_bus->write = octeon_mdiobus_write;
+
+	dev_set_drvdata(&pdev->dev, bus);
+
+	err = mdiobus_register(bus->mii_bus);
+	if (err)
+		goto err_register;
+
+	dev_info(&pdev->dev, "Version " DRV_VERSION "\n");
+
+	return 0;
+err_register:
+	mdiobus_free(bus->mii_bus);
+
+err:
+	devm_kfree(&pdev->dev, bus);
+	return err;
+}
+
+static int __exit octeon_mdiobus_remove(struct platform_device *pdev)
+{
+	struct octeon_mdiobus *bus;
+
+	bus = dev_get_drvdata(&pdev->dev);
+
+	mdiobus_unregister(bus->mii_bus);
+	mdiobus_free(bus->mii_bus);
+	return 0;
+}
+
+static struct platform_driver octeon_mdiobus_driver = {
+	.driver = {
+		.name		= "mdio-octeon",
+		.owner		= THIS_MODULE,
+	},
+	.probe		= octeon_mdiobus_probe,
+	.remove		= __exit_p(octeon_mdiobus_remove),
+};
+
+void octeon_mdiobus_force_mod_depencency(void)
+{
+	/* Let ethernet drivers force us to be loaded.  */
+}
+EXPORT_SYMBOL(octeon_mdiobus_force_mod_depencency);
+
+static int __init octeon_mdiobus_mod_init(void)
+{
+	return platform_driver_register(&octeon_mdiobus_driver);
+}
+
+static void __exit octeon_mdiobus_mod_exit(void)
+{
+	platform_driver_unregister(&octeon_mdiobus_driver);
+}
+
+module_init(octeon_mdiobus_mod_init);
+module_exit(octeon_mdiobus_mod_exit);
+
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_VERSION(DRV_VERSION);
+MODULE_AUTHOR("David Daney");
+MODULE_LICENSE("GPL");
-- 
1.6.0.6
