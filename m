From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 3/6] bus: Add platform driver for iProc shared MDIO Controller
Date: Thu, 21 Apr 2016 14:48:40 +0530
Message-ID: <1461230323-27891-4-git-send-email-pramod.kumar@broadcom.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Cc: BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	Punit Agrawal <punit.agrawal@arm.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add platform driver to populate shared MDIO masters on iProc SoC.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Anup Patel <anup.patel@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
Reviewed-by: Vikram Prakash <vikram.prakash@broadcom.com>
---
 drivers/bus/Kconfig             |  11 ++
 drivers/bus/Makefile            |   1 +
 drivers/bus/iproc_shared_mdio.c | 287 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 299 insertions(+)
 create mode 100644 drivers/bus/iproc_shared_mdio.c

diff --git a/drivers/bus/Kconfig b/drivers/bus/Kconfig
index 1b51b1a..c3f2cb9 100644
--- a/drivers/bus/Kconfig
+++ b/drivers/bus/Kconfig
@@ -118,6 +118,17 @@ config SHARED_MDIO
 	  Respective drivers would be called matching a compatible string
 	  provided in master node.
 
+config IPROC_SHARED_MDIO
+	tristate "iProc Shared MDIO Driver"
+	depends on OF
+	select SHARED_MDIO
+	default ARCH_BCM_IPROC
+	help
+	  Platform driver for shared MDIO controller. Broadcom's iProc based
+	  SoCs have many masters which uses one shared bus to accessed its PHY.
+	  This platform driver populates all master to Shared bus and provide
+	  the MDIO controller specific implementation.
+
 config SIMPLE_PM_BUS
 	bool "Simple Power-Managed Bus Driver"
 	depends on OF && PM
diff --git a/drivers/bus/Makefile b/drivers/bus/Makefile
index 2b6d6e9..3e364da 100644
--- a/drivers/bus/Makefile
+++ b/drivers/bus/Makefile
@@ -20,3 +20,4 @@ obj-$(CONFIG_SIMPLE_PM_BUS)	+= simple-pm-bus.o
 obj-$(CONFIG_UNIPHIER_SYSTEM_BUS)	+= uniphier-system-bus.o
 obj-$(CONFIG_VEXPRESS_CONFIG)	+= vexpress-config.o
 obj-$(CONFIG_SHARED_MDIO)	+= shared_mdio.o
+obj-$(CONFIG_IPROC_SHARED_MDIO)	+= iproc_shared_mdio.o
diff --git a/drivers/bus/iproc_shared_mdio.c b/drivers/bus/iproc_shared_mdio.c
new file mode 100644
index 0000000..af232eb
--- /dev/null
+++ b/drivers/bus/iproc_shared_mdio.c
@@ -0,0 +1,287 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Platform driver for Shared MDIO Masters on iProc SoC
+ */
+
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include <linux/shared_mdio.h>
+#include <linux/mutex.h>
+#include <linux/delay.h>
+
+struct shared_mdio_master_param {
+	bool is_internal;
+	bool is_c45;
+	unsigned int master_id;
+};
+
+struct iproc_shared_mdio {
+	struct device *dev;
+	struct mutex lock;
+	void __iomem *regs;
+	unsigned int num_masters;
+	struct shared_mdio_master **masters;
+};
+
+#define PHY_INTERNAL 1
+#define CLAUSE_45 1
+
+#define MDIO_PARAM_OFFSET		0x00
+#define MDIO_PARAM_MIIM_CYCLE		29
+#define MDIO_PARAM_INTERNAL_SEL		25
+#define MDIO_PARAM_BUS_ID		22
+#define MDIO_PARAM_C45_SEL		21
+#define MDIO_PARAM_PHY_ID		16
+#define MDIO_PARAM_PHY_DATA		0
+
+#define MDIO_READ_OFFSET		0x04
+#define MDIO_READ_DATA_MASK		0xffff
+#define MDIO_ADDR_OFFSET		0x08
+
+#define MDIO_CTRL_OFFSET		0x0C
+#define MDIO_CTRL_WRITE_OP		0x1
+#define MDIO_CTRL_READ_OP		0x2
+
+#define MDIO_STAT_OFFSET		0x10
+#define MDIO_STAT_DONE			1
+
+static int iproc_mdio_wait_for_idle(void __iomem *base, bool result)
+{
+	u32 val;
+	unsigned int timeout = 1000; /* loop for 1s */
+
+	do {
+		val = readl(base + MDIO_STAT_OFFSET);
+		if ((val & MDIO_STAT_DONE) == result)
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static inline u32 get_cmd(bool con, u16 mid, bool is_c45, u16 phyid, u16 val)
+{
+	u32 cmd;
+
+	cmd =  (con ? 1 : 0) << MDIO_PARAM_INTERNAL_SEL;
+	cmd |= mid << MDIO_PARAM_BUS_ID;
+	cmd |= (is_c45 ? 1 : 0) << MDIO_PARAM_C45_SEL;
+	cmd |= phyid << MDIO_PARAM_PHY_ID;
+	cmd |= val << MDIO_PARAM_PHY_DATA;
+
+	return cmd;
+}
+
+/*
+ * start_miim_ops- Program and start MDIO transaction over mdio bus.
+ * @base: Base address
+ * @cmd: param values that need to be programmed in MDIO PARAM_OFFSET.
+ * @reg: register offset ot be read/written.
+ * @op: Operation that need to be carried out.
+ *      MDIO_CTRL_READ_OP: Read transaction.
+ *      MDIO_CTRL_WRITE_OP: Write transaction.
+ *
+ * Return value: Sucessfull Read operation returns read reg values and write
+ *      operation returns 0. Failure opertation returns negative error code.
+ */
+static int start_miim_ops(void __iomem *base, u32 cmd, u32 reg, u32 op)
+{
+	int ret = 0;
+
+	writel(0, base + MDIO_CTRL_OFFSET);
+	ret = iproc_mdio_wait_for_idle(base, false);
+	if (ret)
+		return ret;
+
+	writel(cmd, base + MDIO_PARAM_OFFSET);
+	writel(reg, base + MDIO_ADDR_OFFSET);
+
+	writel(op, base + MDIO_CTRL_OFFSET);
+
+	ret = iproc_mdio_wait_for_idle(base, true);
+	if (ret)
+		return ret;
+
+	if (op == MDIO_CTRL_READ_OP)
+		ret = readl(base + MDIO_READ_OFFSET) & MDIO_READ_DATA_MASK;
+
+	return ret;
+}
+
+static int iproc_shared_mdio_read(struct shared_mdio_master *master,
+							u16 phyid, u16 reg)
+{
+	int ret;
+	u32 cmd;
+	struct iproc_shared_mdio *imdio = dev_get_drvdata(master->dev.parent);
+	struct shared_mdio_master_param *param = master->priv;
+
+	mutex_lock(&imdio->lock);
+
+	dev_dbg(imdio->dev, "master=%d phy=%d reg=%d\n",
+				param->master_id, phyid, reg);
+
+	cmd = get_cmd(param->is_internal, param->master_id, param->is_c45,
+								phyid, 0x0);
+	ret = start_miim_ops(imdio->regs, cmd, reg, MDIO_CTRL_READ_OP);
+	if (ret < 0)
+		dev_err(imdio->dev, "MDIO read operation failed!!!");
+
+	mutex_unlock(&imdio->lock);
+	return ret;
+}
+
+static int iproc_shared_mdio_write(struct shared_mdio_master *master,
+						u16 phyid, u16 reg, u16 val)
+{
+	u32 cmd;
+	int ret;
+	struct iproc_shared_mdio *imdio = dev_get_drvdata(master->dev.parent);
+	struct shared_mdio_master_param *param = master->priv;
+
+	mutex_lock(&imdio->lock);
+
+	dev_dbg(imdio->dev, "master=%d phy=%d reg=%d val=0x%x\n",
+					param->master_id, phyid, reg, val);
+
+	/* Write val at reg offset */
+	cmd = get_cmd(param->is_internal, param->master_id, param->is_c45,
+								phyid, val);
+	ret = start_miim_ops(imdio->regs, cmd, reg, MDIO_CTRL_WRITE_OP);
+	if (ret < 0)
+		dev_err(imdio->dev, "MDIO Write operation failed!!!");
+
+	mutex_unlock(&imdio->lock);
+	return ret;
+}
+
+static int iproc_shared_mdio_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct device_node *dn = dev->of_node, *child;
+	struct iproc_shared_mdio *imdio;
+	struct resource *res;
+	int ret = 0, cnt;
+
+	imdio = devm_kzalloc(dev, sizeof(*imdio), GFP_KERNEL);
+	if (!imdio)
+		return -ENOMEM;
+
+	imdio->num_masters = of_get_available_child_count(dn);
+	if (!imdio->num_masters)
+		return -ENODEV;
+
+	imdio->masters = devm_kcalloc(dev, imdio->num_masters,
+					sizeof(**imdio->masters), GFP_KERNEL);
+	if (!imdio->masters)
+		return -ENOMEM;
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "mdio");
+	imdio->regs = devm_ioremap_resource(dev, res);
+	if (IS_ERR(imdio->regs))
+		return PTR_ERR(imdio->regs);
+
+	imdio->dev = dev;
+	mutex_init(&imdio->lock);
+
+	cnt = 0;
+	for_each_available_child_of_node(dn, child) {
+		unsigned int id;
+		struct shared_mdio_master *master;
+		struct shared_mdio_master_param *param;
+
+		if (of_property_read_u32(child, "reg", &id)) {
+			dev_err(dev, "missing reg property in node %s\n",
+					child->name);
+			ret = -EINVAL;
+			goto fail;
+		}
+
+		master = shared_mdio_alloc_master(dev, child);
+		if (IS_ERR(master)) {
+			ret = PTR_ERR(master);
+			goto fail;
+		}
+		imdio->masters[cnt] = master;
+
+		param  = devm_kzalloc(dev, sizeof(*param), GFP_KERNEL);
+		if (!param) {
+			ret = -ENOMEM;
+			goto fail;
+		}
+		master->priv = param;
+		param->master_id = id;
+
+		param->is_internal = of_property_read_bool(child,
+							"brcm,phy-internal");
+		param->is_c45 = of_property_read_bool(child, "brcm,is-c45");
+		master->mdio_read = iproc_shared_mdio_read;
+		master->mdio_write = iproc_shared_mdio_write;
+
+		ret = shared_mdio_add_master(master);
+		if (ret)
+			goto fail;
+		cnt++;
+	}
+	platform_set_drvdata(pdev, imdio);
+	dev_info(dev, "registered %d masters(s)\n", cnt);
+	return 0;
+fail:
+	for (cnt = 0; cnt < imdio->num_masters; cnt++) {
+		if (imdio->masters[cnt]) {
+			shared_mdio_remove_master(imdio->masters[cnt]);
+			imdio->masters[cnt] = NULL;
+		}
+	}
+	return ret;
+}
+
+static int iproc_shared_mdio_remove(struct platform_device *pdev)
+{
+	int i;
+	struct iproc_shared_mdio *imdio = platform_get_drvdata(pdev);
+
+	for (i = 0; i < imdio->num_masters; i++) {
+		if (imdio->masters[i]) {
+			shared_mdio_remove_master(imdio->masters[i]);
+			imdio->masters[i] = NULL;
+		}
+	}
+
+	return 0;
+}
+
+static const struct of_device_id iproc_shared_mdio_of_match[] = {
+	{ .compatible = "brcm,iproc-shared-mdio", },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, iproc_shared_mdio_of_match);
+
+static struct platform_driver iproc_shared_mdio_driver = {
+	.probe = iproc_shared_mdio_probe,
+	.remove = iproc_shared_mdio_remove,
+	.driver = {
+		.name = "iproc-shared-mdio",
+		.of_match_table = iproc_shared_mdio_of_match,
+	},
+};
+
+module_platform_driver(iproc_shared_mdio_driver);
+
+MODULE_DESCRIPTION("iProc Shared MDIO Master Driver");
+MODULE_AUTHOR("Pramod Kumar <pramod.kumar@broadcom.com>");
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
