From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 4/7] mfd: add MFD based flexcard driver
Date: Tue, 13 Aug 2013 11:08:39 +0200
Message-ID: <1376384922-8519-6-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Lee Jones <lee.jones@linaro.org>,
	Holger Dengler <dengler@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48287 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab3HMJI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:57 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides support for Eberp=C3=A4cher Flexcard. The Flexcard =
comes
with two PCI bars, one for the glue layer and one for the "IPs". The
second bar may have multiple other devices like flexray or d_can
devices. The driver utilites the MFD framework and creates various
subdevices. Not only for the additional "IPs" but also for the clock
source and clockevent provided by the card.

Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Lee Jones <lee.jones@linaro.org>
Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/mfd/Kconfig           |   40 ++
 drivers/mfd/Makefile          |    2 +
 drivers/mfd/flexcard-core.c   | 1059 +++++++++++++++++++++++++++++++++=
++++++++
 drivers/mfd/flexcard-dma.c    |  561 ++++++++++++++++++++++
 drivers/mfd/flexcard-irq.c    |  333 +++++++++++++
 drivers/mfd/flexcard.h        |    8 +
 include/linux/eray.h          |  650 +++++++++++++++++++++++++
 include/linux/flexcard.h      |   95 ++++
 include/uapi/linux/Kbuild     |    2 +
 include/uapi/linux/eray.h     |   34 ++
 include/uapi/linux/flexcard.h |  429 +++++++++++++++++
 11 files changed, 3213 insertions(+)
 create mode 100644 drivers/mfd/flexcard-core.c
 create mode 100644 drivers/mfd/flexcard-dma.c
 create mode 100644 drivers/mfd/flexcard-irq.c
 create mode 100644 drivers/mfd/flexcard.h
 create mode 100644 include/linux/eray.h
 create mode 100644 include/linux/flexcard.h
 create mode 100644 include/uapi/linux/eray.h
 create mode 100644 include/uapi/linux/flexcard.h

diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index aecd6dd..f847d52 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -223,6 +223,46 @@ config MFD_INTEL_MSIC
 	  Passage) chip. This chip embeds audio, battery, GPIO, etc.
 	  devices used in Intel Medfield platforms.
=20
+config MFD_EBEL_FLEXCARD
+	tristate "Support for the Ebersp=C3=A4cher Electronic Flexcard"
+	select MFD_CORE
+	select UIO
+	select UIO_PDRV
+	select UIO_PDRV_GENIRQ
+	depends on PCI
+	help
+	  If you say yes here you get support for the Ebersp=C3=A4cher Electr=
onic
+	  Flexcard. This driver provides common support for accessing the
+	  device, additional drivers must be enabled in order to use the
+	  functionality of the device.
+
+config MFD_EBEL_FLEXCARD_DEBUG
+	bool "extended debug information"
+	depends on MFD_EBEL_FLEXCARD
+	help
+	  enable extended debug information
+
+config MFD_EBEL_FLEXCARD_DMA_POLL
+	bool "poll DMA interrupts"
+	depends on MFD_EBEL_FLEXCARD
+	default y
+	help
+	  poll Flexcard DMA interrupts
+
+config MFD_EBEL_FLEXCARD_DMA_POLL_INTERVAL
+	int "Flexcard DMA poll intervall (us)"
+	depends on MFD_EBEL_FLEXCARD_DMA_POLL
+	default 500
+
+config MFD_EBEL_FLEXCARD_PROTPARAM
+	bool "Eray-specific Flexray Protocol Parameter ranges"
+	depends on MFD_EBEL_FLEXCARD
+	default y
+	help
+	  Say Y if you want to use Eray-specific Flexray Protocol Parameter
+	  ranges instead of the Protocol Parameter ranges that are specified =
in
+	  Flexray Protocol definition v2 and/or v3.
+
 config MFD_JANZ_CMODIO
 	tristate "Janz CMOD-IO PCI MODULbus Carrier Board"
 	select MFD_CORE
diff --git a/drivers/mfd/Makefile b/drivers/mfd/Makefile
index 3c90051..1e22660 100644
--- a/drivers/mfd/Makefile
+++ b/drivers/mfd/Makefile
@@ -150,6 +150,8 @@ obj-$(CONFIG_TPS65911_COMPARATOR)	+=3D tps65911-com=
parator.o
 obj-$(CONFIG_MFD_TPS65090)	+=3D tps65090.o
 obj-$(CONFIG_MFD_AAT2870_CORE)	+=3D aat2870-core.o
 obj-$(CONFIG_MFD_INTEL_MSIC)	+=3D intel_msic.o
+flexcard-objs			:=3D flexcard-core.o flexcard-irq.o
+obj-$(CONFIG_MFD_EBEL_FLEXCARD)		+=3D flexcard.o flexcard-dma.o
 obj-$(CONFIG_MFD_PALMAS)	+=3D palmas.o
 obj-$(CONFIG_MFD_VIPERBOARD)    +=3D viperboard.o
 obj-$(CONFIG_MFD_RC5T583)	+=3D rc5t583.o rc5t583-irq.o
diff --git a/drivers/mfd/flexcard-core.c b/drivers/mfd/flexcard-core.c
new file mode 100644
index 0000000..c5924b5
--- /dev/null
+++ b/drivers/mfd/flexcard-core.c
@@ -0,0 +1,1059 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#include <linux/device.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/mfd/core.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/platform_device.h>
+#include <linux/stringify.h>
+#include <linux/uio_driver.h>
+
+#include <linux/flexcard.h>
+
+#include "flexcard.h"
+
+#define FC_UIO_VERSION  "1.0"
+#define FC_MAX_CARDS	32
+#define FC_MAX_DCAN	32
+#define FC_MAX_ERAY	32
+
+static DECLARE_BITMAP(fc_cards, FC_MAX_CARDS);
+
+static const char fc_dcan_string[] =3D "d_can";
+static const char fc_eray_string[] =3D "flexcard-eray";
+
+/* Clock Function */
+static struct resource fc_evt_res[] =3D {
+	{
+		.name   =3D "flexcard-clkevt",
+		.start  =3D 0x154,
+		.end    =3D 0x157,
+		.flags  =3D IORESOURCE_MEM,
+	},
+};
+
+static struct mfd_cell fc_evt_dev[] =3D {
+	{
+		.id =3D 0,
+		.name =3D "flexcard-clkevt",
+		.num_resources =3D ARRAY_SIZE(fc_evt_res),
+		.resources =3D fc_evt_res,
+	},
+};
+
+static struct resource fc_clk_res[] =3D {
+	{
+		.name   =3D "flexcard-clksrc",
+		.start  =3D 0x700,
+		.end    =3D 0x70c,
+		.flags  =3D IORESOURCE_MEM,
+	},
+};
+
+static struct mfd_cell fc_clk_dev[] =3D {
+	{
+		.id =3D 0,
+		.name =3D "flexcard-clksrc",
+		.num_resources =3D ARRAY_SIZE(fc_clk_res),
+		.resources =3D fc_clk_res,
+	},
+};
+
+static struct resource fc_dma_res[] =3D {
+	{
+		.name   =3D "flexcard-dma",
+		.start  =3D 0x0,
+		.end    =3D 0x600,
+		.flags  =3D IORESOURCE_MEM,
+	},
+	{
+		.name   =3D "flexcard-dma",
+		.start  =3D FC_IRQ_DMA_CBL_OFF,
+		.end    =3D FC_IRQ_DMA_CBL_OFF,
+		.flags  =3D IORESOURCE_IRQ,
+	},
+	{
+		.name   =3D "flexcard-dma",
+		.start  =3D FC_IRQ_DMA_CO_OFF,
+		.end    =3D FC_IRQ_DMA_CO_OFF,
+		.flags  =3D IORESOURCE_IRQ,
+	},
+};
+
+static struct mfd_cell fc_dma_dev[] =3D {
+	{
+		.id =3D 0,
+		.name =3D "flexcard-dma",
+		.num_resources =3D ARRAY_SIZE(fc_dma_res),
+		.resources =3D fc_dma_res,
+	},
+};
+
+static ssize_t show_userid(struct uio_info *uio, char *buf)
+{
+	void __iomem *internal_addr;
+	u32 reg;
+
+	internal_addr =3D ioremap(uio->mem[0].addr, uio->mem[0].size);
+	if (!internal_addr)
+		return -EIO;
+	reg =3D readl(internal_addr + FC_FC_UID);
+	iounmap(internal_addr);
+
+	return sprintf(buf, "0x%x\n", reg);
+}
+
+static ssize_t store_userid(struct uio_info *uio, const char *buf, siz=
e_t count)
+{
+	void __iomem *internal_addr;
+	u32 reg;
+	int ret;
+
+	ret =3D kstrtos32(buf, 0, &reg);
+	if (ret)
+		return ret;
+
+	internal_addr =3D ioremap(uio->mem[0].addr, uio->mem[0].size);
+	if (!internal_addr)
+		return -EIO;
+
+	writel(reg, internal_addr + FC_FC_UID);
+	iounmap(internal_addr);
+
+	return count;
+}
+static UIO_ATTR(userid, 0644, show_userid, store_userid);
+
+static const struct uio_attribute *fc_uio_attr[] =3D {
+	&uio_attr_userid,
+	NULL,
+};
+
+static struct uio_info fc_uio_pdata =3D {
+	.name =3D "fc_fc_uio",
+	.version =3D FC_UIO_VERSION,
+	.irq =3D 0,
+	.attributes =3D fc_uio_attr,
+	.owner =3D THIS_MODULE,
+};
+
+static struct resource fc_uio_res[] =3D {
+	/* FlexCard PCI bar 0 */
+	{
+		.name   =3D "flexcard-uio",
+		.start  =3D 0x000,
+		.end    =3D 0xfff,
+		.flags  =3D IORESOURCE_MEM,
+	},
+	/* FlexCard PCI bar 1 */
+	{
+		.name   =3D "flexcard-uio",
+		.start  =3D 0x000,
+		.end    =3D 0xffff,
+		.flags  =3D IORESOURCE_MEM,
+	},
+};
+
+static struct mfd_cell fc_uio_dev[] =3D {
+	{
+		.id =3D 0,
+		.name =3D "uio_pdrv",
+		.platform_data =3D &fc_uio_pdata,
+		.pdata_size =3D sizeof(fc_uio_pdata),
+		.num_resources =3D ARRAY_SIZE(fc_uio_res),
+		.resources =3D fc_uio_res,
+	},
+};
+
+#define irq_res(irq_name) \
+	static struct resource fc_irq_res_##irq_name =3D {	\
+		.name =3D __stringify(fc_irq_##irq_name##_off),	\
+		.start  =3D FC_IRQ_##irq_name##_OFF,		\
+		.end  =3D FC_IRQ_##irq_name##_OFF,		\
+		.flags  =3D IORESOURCE_IRQ			\
+	};							\
+								\
+	static struct uio_info fc_irq_pdata_##irq_name =3D {	\
+		.name   =3D __stringify(irq_name),		\
+		.version =3D "0",					\
+	}
+
+irq_res(CC3CYCS);
+irq_res(CC4CYCS);
+irq_res(WAKE4A);
+irq_res(WAKE4B);
+irq_res(WAKE3A);
+irq_res(WAKE3B);
+irq_res(WAKE2A);
+irq_res(WAKE2B);
+irq_res(WAKE1A);
+irq_res(WAKE1B);
+irq_res(CC1CYCS);
+irq_res(CC2CYCS);
+irq_res(CC1T0);
+irq_res(CC2T0);
+irq_res(CC3T0);
+irq_res(CC4T0);
+
+#define fc_irq_cell(irq_name, irq_id)			\
+{							\
+	.id =3D irq_id,					\
+	.name =3D "uio_pdrv_genirq",			\
+	.platform_data =3D &fc_irq_pdata_##irq_name,	\
+	.pdata_size =3D sizeof(fc_irq_pdata_##irq_name),	\
+	.num_resources =3D 1,				\
+	.resources =3D &fc_irq_res_##irq_name		\
+}
+
+static struct mfd_cell fc_irq_dev[] =3D {
+	fc_irq_cell(CC3CYCS, 0),
+	fc_irq_cell(CC4CYCS, 1),
+	fc_irq_cell(WAKE4A, 2),
+	fc_irq_cell(WAKE4B, 3),
+	fc_irq_cell(WAKE3A, 4),
+	fc_irq_cell(WAKE3B, 5),
+	fc_irq_cell(WAKE2A, 6),
+	fc_irq_cell(WAKE2B, 7),
+	fc_irq_cell(WAKE1A, 8),
+	fc_irq_cell(WAKE1B, 9),
+	fc_irq_cell(CC1CYCS, 10),
+	fc_irq_cell(CC2CYCS, 11),
+	fc_irq_cell(CC1T0, 12),
+	fc_irq_cell(CC2T0, 13),
+	fc_irq_cell(CC3T0, 14),
+	fc_irq_cell(CC4T0, 15),
+};
+
+/* sysfs info */
+static ssize_t show_fw_ver(struct device *dev, struct device_attribute=
 *attr,
+			   char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 fw_ver;
+
+	fw_ver =3D readl(priv->conf + FC_FC_FW_VER);
+
+	return sprintf(buf, "%d.%d.%d\n",
+		       fw_ver >> 16 & 0xff, fw_ver >> 8 & 0xff, fw_ver & 0xff);
+}
+static DEVICE_ATTR(fw_ver, S_IRUGO, show_fw_ver, NULL);
+
+static ssize_t show_hw_ver(struct device *dev, struct device_attribute=
 *attr,
+			   char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 hw_ver;
+
+	hw_ver =3D readl(priv->conf + FC_FC_HW_VER);
+
+	return sprintf(buf, "%d.%d.%d\n",
+		       hw_ver >> 16 & 0xff, hw_ver >> 8 & 0xff, hw_ver & 0xff);
+}
+static DEVICE_ATTR(hw_ver, S_IRUGO, show_hw_ver, NULL);
+
+static ssize_t show_fw_cur(struct device *dev, struct device_attribute=
 *attr,
+			   char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 fw_cur;
+
+	fw_cur =3D readl(priv->conf + FC_ACTIMG);
+
+	return sprintf(buf, "%d\n", fw_cur & 0xff);
+
+}
+static DEVICE_ATTR(fw_cur, S_IRUGO, show_fw_cur, NULL);
+
+static ssize_t show_apl_mode(struct device *dev, struct device_attribu=
te *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 apl_mode[8];
+	int i;
+
+	writel(0x1, priv->conf + FC_UPDIMGINF);
+	mdelay(1);
+	for (i =3D 0; i < 8; i++)
+		apl_mode[i] =3D readl(priv->conf + 0xAE0 + i*4);
+
+	return sprintf(buf, "0x%08x 0x%08x 0x%08x 0x%08x\n"
+		       "0x%08x 0x%08x 0x%08x 0x%08x\n",
+		       apl_mode[0], apl_mode[1], apl_mode[2], apl_mode[3],
+		       apl_mode[4], apl_mode[5], apl_mode[6], apl_mode[7]);
+}
+static DEVICE_ATTR(apl_mode, S_IRUGO, show_apl_mode, NULL);
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DEBUG
+static ssize_t show_dma_stat(struct device *dev, struct device_attribu=
te *attr,
+			    char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_STAT);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_stat, S_IRUGO, show_dma_stat, NULL);
+
+static ssize_t show_dma_ctrl(struct device *dev, struct device_attribu=
te *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_CTRL);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_ctrl, S_IRUGO, show_dma_ctrl, NULL);
+
+static ssize_t show_dma_irer(struct device *dev, struct device_attribu=
te *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_IRER);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_irer, S_IRUGO, show_dma_irer, NULL);
+
+static ssize_t show_dma_irsr(struct device *dev, struct device_attribu=
te *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_IRSR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_irsr, S_IRUGO, show_dma_irsr, NULL);
+
+static ssize_t show_dma_cblc(struct device *dev, struct device_attribu=
te *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_CBCR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static ssize_t store_dma_cblc(struct device *dev, struct device_attrib=
ute *attr,
+			      const char *buf, size_t count)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 cblc;
+	int ret;
+
+	ret =3D kstrtouint(buf, 0, &cblc);
+	if (ret)
+		return ret;
+	if (cblc >=3D 2 * 1024 * 1024)
+		return -ERANGE;
+
+	writel(cblc, priv->conf + FC_DMA_CBCR);
+
+	return count;
+}
+static DEVICE_ATTR(dma_cblc, 0644, show_dma_cblc, store_dma_cblc);
+
+static ssize_t show_dma_cbl(struct device *dev, struct device_attribut=
e *attr,
+			    char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_CBLR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_cbl, S_IRUGO, show_dma_cbl, NULL);
+
+static ssize_t show_dma_rptr(struct device *dev, struct device_attribu=
te *attr,
+			    char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_RPTR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_rptr, S_IRUGO, show_dma_rptr, NULL);
+
+static ssize_t show_dma_wptr(struct device *dev, struct device_attribu=
te *attr,
+			    char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_DMA_RPTR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(dma_wptr, S_IRUGO, show_dma_wptr, NULL);
+
+static ssize_t show_fc_rocr(struct device *dev, struct device_attribut=
e *attr,
+			    char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 rocr;
+
+	rocr =3D readl(priv->conf + FC_FC_ROCR);
+
+	return sprintf(buf, "%08x\n", rocr);
+}
+static ssize_t store_fc_rocr(struct device *dev, struct device_attribu=
te *attr,
+			     const char *buf, size_t count)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 rocr;
+	int ret;
+
+	ret =3D kstrtouint(buf, 0, &rocr);
+	if (ret)
+		return ret;
+	if (rocr & ~3)
+		return -ERANGE;
+	rocr <<=3D 30;
+	writel(rocr, priv->conf + FC_FC_ROCR);
+
+	return count;
+}
+static DEVICE_ATTR(fc_rocr, 0644, show_fc_rocr, store_fc_rocr);
+
+static ssize_t show_eray_mtccv(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 mtccv;
+
+	mtccv =3D readl(priv->mmio + 0x114);
+
+	return sprintf(buf, "%08x\n", mtccv);
+}
+static DEVICE_ATTR(eray_mtccv, S_IRUGO, show_eray_mtccv, NULL);
+#endif
+
+static ssize_t show_ier(struct device *dev, struct device_attribute *a=
ttr,
+			char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_IER);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(ier, S_IRUGO, show_ier, NULL);
+
+static ssize_t show_isr(struct device *dev, struct device_attribute *a=
ttr,
+			char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_ISR);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static DEVICE_ATTR(isr, S_IRUGO, show_isr, NULL);
+
+static ssize_t show_amreg(struct device *dev, struct device_attribute =
*attr,
+			  char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 status;
+
+	status =3D readl(priv->conf + FC_AMREG);
+
+	return sprintf(buf, "%08x\n", status);
+}
+static ssize_t store_amreg(struct device *dev, struct device_attribute=
 *attr,
+			   const char *buf, size_t count)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 amreg;
+	int ret;
+
+	ret =3D kstrtouint(buf, 0, &amreg);
+	if (ret)
+		return ret;
+	if (amreg & ~0x3)
+		return -ERANGE;
+	writel(amreg, priv->conf + FC_AMREG);
+
+	return count;
+}
+static DEVICE_ATTR(amreg, 0644, show_amreg, store_amreg);
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+
+static ssize_t show_poll_interval(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d us\n", fc_poll_interval / 1000);
+}
+static ssize_t store_poll_interval(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t count)
+{
+	unsigned int tmp;
+	int ret;
+
+	ret =3D kstrtouint(buf, 0, &tmp);
+	if (ret)
+		return ret;
+
+	if (tmp > USEC_PER_SEC)
+		return -ERANGE;
+
+	tmp *=3D NSEC_PER_USEC;
+	fc_poll_interval =3D tmp;
+	return count;
+}
+static DEVICE_ATTR(poll_interval, 0644, show_poll_interval,
+		store_poll_interval);
+
+static ssize_t show_dma_on_irq(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+
+	return sprintf(buf, "%d\n", priv->dma_on_irq);
+}
+static ssize_t store_dma_on_irq(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+	unsigned int tmp;
+
+	ret =3D kstrtouint(buf, 0, &tmp);
+	if (ret)
+		return ret;
+	if (tmp)
+		priv->dma_on_irq =3D 1;
+	else
+		priv->dma_on_irq =3D 0;
+
+	return count;
+}
+static DEVICE_ATTR(dma_on_irq, 0644, show_dma_on_irq, store_dma_on_irq=
);
+
+#endif
+
+static void reset_flexcard(struct fc_priv *priv)
+{
+	writel(FC_RST_FC, priv->conf + FC_FC_ROCR);
+	writel(0, priv->conf + FC_TIRQIR);
+	writel(0, priv->conf + FC_FC_NFCTRL);
+	writel(UINT_MAX, priv->conf + FC_FC_RESET);
+	writel(0, priv->conf + FC_PL_TERM);
+}
+
+static int fc_init_uio(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+
+	fc_uio_res[0].start =3D pci_resource_start(pdev, 0);
+	fc_uio_res[0].end =3D fc_uio_res[0].start + 0xfff;
+	fc_uio_res[0].parent =3D &pdev->resource[0];
+	fc_uio_res[1].start =3D pci_resource_start(pdev, 1);
+	fc_uio_res[1].end =3D fc_uio_res[1].start + 0xffff;
+	fc_uio_res[1].parent =3D &pdev->resource[1];
+
+	ret =3D mfd_add_devices(&pdev->dev,
+			priv->card_nr * ARRAY_SIZE(fc_uio_dev), fc_uio_dev,
+			ARRAY_SIZE(fc_uio_dev), NULL, priv->irq_start, NULL);
+	if (ret)
+		mfd_remove_devices(&pdev->dev);
+
+	return ret;
+}
+
+static int fc_init_dma(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+
+	ret =3D mfd_add_devices(&pdev->dev,
+			priv->card_nr * ARRAY_SIZE(fc_dma_dev), fc_dma_dev,
+			ARRAY_SIZE(fc_dma_dev), &pdev->resource[0],
+			priv->irq_start, NULL);
+	if (ret)
+		mfd_remove_devices(&pdev->dev);
+
+	return ret;
+}
+
+static int fc_init_event(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+
+	ret =3D mfd_add_devices(&pdev->dev,
+			priv->card_nr * ARRAY_SIZE(fc_irq_dev), fc_irq_dev,
+			ARRAY_SIZE(fc_irq_dev), NULL, priv->irq_start, NULL);
+	if (ret)
+		mfd_remove_devices(&pdev->dev);
+
+	return ret;
+}
+
+static int fc_init_clk(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+
+	ret =3D mfd_add_devices(&pdev->dev,
+			priv->card_nr * ARRAY_SIZE(fc_evt_dev), fc_evt_dev,
+			ARRAY_SIZE(fc_evt_dev), &pdev->resource[0],
+			priv->irq_start, NULL);
+	if (ret)
+		goto out;
+
+	ret =3D mfd_add_devices(&pdev->dev,
+			priv->card_nr * ARRAY_SIZE(fc_clk_dev), fc_clk_dev,
+			ARRAY_SIZE(fc_clk_dev), &pdev->resource[0],
+			priv->irq_start, NULL);
+	if (ret)
+		goto out;
+
+	return 0;
+out:
+	mfd_remove_devices(&pdev->dev);
+	return ret;
+}
+
+static int fc_init_bus(struct pci_dev *pdev)
+{
+	struct resource res[3];
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	u32 avail, sup;
+	int i, ret =3D -ENOMEM;
+
+	avail =3D readl(priv->conf + FC_FC_LIC0) & FC_LIC0_CAN_MASK;
+	avail >>=3D FC_LIC0_CAN_SHIFT;
+	sup =3D readl(priv->conf + FC_FC_SLIC0) & FC_SLIC0_CAN_MASK;
+	sup >>=3D FC_SLIC0_CAN_SHIFT;
+
+	priv->nrdcan =3D min(avail, sup);
+	priv->dcan =3D kzalloc(priv->nrdcan*sizeof(struct mfd_cell), GFP_KERN=
EL);
+	if (!priv->dcan)
+		goto out;
+
+	avail =3D readl(priv->conf + FC_FC_LIC0) & FC_LIC0_FLEXRAY_MASK;
+	sup =3D readl(priv->conf + FC_FC_SLIC0) & FC_SLIC0_FLEXRAY_MASK;
+
+	priv->nreray =3D min(avail, sup);
+	priv->eray =3D kzalloc(priv->nreray*sizeof(struct mfd_cell), GFP_KERN=
EL);
+	if (!priv->eray)
+		goto out_dcan;
+
+	for (i =3D 0; i < priv->nrdcan; i++) {
+		priv->dcan[i].name =3D fc_dcan_string;
+		priv->dcan[i].id =3D PLATFORM_DEVID_AUTO;
+		priv->dcan[i].resources =3D res;
+		priv->dcan[i].num_resources =3D ARRAY_SIZE(res);
+		res[0].name =3D "flexcard-dcan";
+		res[0].start =3D pci_resource_start(pdev, 1) +
+			priv->nreray * 0x4000 + i * 0x2000;
+		res[0].end =3D res[0].start + 0x1fff;
+		res[0].parent =3D &pdev->resource[1];
+		res[0].flags =3D IORESOURCE_MEM;
+		res[1].name =3D "flexcard-dcan";
+		res[1].start =3D pci_resource_start(pdev, 0);
+		res[1].end =3D res[1].start + 0xfff;
+		res[1].parent =3D &pdev->resource[0];
+		res[1].flags =3D IORESOURCE_MEM;
+		res[2].name =3D "flexcard-dcan";
+		res[2].start =3D FC_IRQ_DMA_RX_OFF(priv->nreray + i);
+		res[2].end =3D FC_IRQ_DMA_RX_OFF(priv->nreray + i);
+		res[2].flags =3D IORESOURCE_IRQ;
+
+		ret =3D mfd_add_devices(&pdev->dev, priv->card_nr * FC_MAX_DCAN,
+				&priv->dcan[i], 1, NULL, priv->irq_start,
+				NULL);
+		if (ret)
+			goto out_eray;
+	}
+
+	for (i =3D 0; i < priv->nreray; i++) {
+		priv->eray[i].name =3D fc_eray_string;
+		priv->eray[i].id =3D PLATFORM_DEVID_AUTO;
+		priv->eray[i].resources =3D res;
+		priv->eray[i].num_resources =3D ARRAY_SIZE(res);
+		res[0].name =3D "flexcard-eray";
+		res[0].start =3D pci_resource_start(pdev, 0);
+		res[0].end =3D res[0].start + 0xfff;
+		res[0].parent =3D &pdev->resource[0];
+		res[0].flags =3D IORESOURCE_MEM;
+		res[1].name =3D "flexcard-eray";
+		res[1].start =3D pci_resource_start(pdev, 1) + i * 0x4000;
+		res[1].end =3D res[1].start + 0x3fff;
+		res[1].parent =3D &pdev->resource[1];
+		res[1].flags =3D IORESOURCE_MEM;
+		res[2].name =3D "flexcard-eray";
+		res[2].start =3D FC_IRQ_DMA_RX_OFF(i);
+		res[2].end =3D FC_IRQ_DMA_RX_OFF(i);
+		res[2].flags =3D IORESOURCE_IRQ;
+
+		ret =3D mfd_add_devices(&pdev->dev, priv->card_nr * FC_MAX_ERAY,
+				&priv->eray[i], 1, NULL, priv->irq_start,
+				NULL);
+		if (ret)
+			goto out_eray;
+	}
+	return 0;
+
+out_eray:
+	kfree(priv->eray);
+out_dcan:
+	kfree(priv->dcan);
+out:
+	mfd_remove_devices(&pdev->dev);
+	return ret;
+}
+
+static int fc_register_attr(struct pci_dev *pdev)
+{
+	int ret;
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	ret =3D device_create_file(&pdev->dev, &dev_attr_poll_interval);
+	if (ret)
+		goto out;
+
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_on_irq);
+	if (ret)
+		goto out_poll;
+#endif
+	ret =3D device_create_file(&pdev->dev, &dev_attr_isr);
+	if (ret)
+		goto out_dma_on_irq;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_ier);
+	if (ret)
+		goto out_isr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_amreg);
+	if (ret)
+		goto out_ier;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_fw_ver);
+	if (ret)
+		goto out_amreg;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_hw_ver);
+	if (ret)
+		goto out_fw_attr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_fw_cur);
+	if (ret)
+		goto out_hw_attr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_apl_mode);
+	if (ret)
+		goto out_cur_attr;
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DEBUG
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_irsr);
+	if (ret)
+		goto out_apl_attr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_irer);
+	if (ret)
+		goto out_dma_irsr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_ctrl);
+	if (ret)
+		goto out_dma_irer;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_stat);
+	if (ret)
+		goto out_dma_ctrl;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_cbl);
+	if (ret)
+		goto out_dma_stat;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_cblc);
+	if (ret)
+		goto out_dma_cbl;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_rptr);
+	if (ret)
+		goto out_dma_cblc;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_dma_wptr);
+	if (ret)
+		goto out_dma_rptr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_fc_rocr);
+	if (ret)
+		goto out_dma_wptr;
+	ret =3D device_create_file(&pdev->dev, &dev_attr_eray_mtccv);
+	if (ret)
+		goto out_fc_rocr;
+#endif
+
+	return 0;
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DEBUG
+out_fc_rocr:
+	device_remove_file(&pdev->dev, &dev_attr_fc_rocr);
+out_dma_wptr:
+	device_remove_file(&pdev->dev, &dev_attr_dma_wptr);
+out_dma_rptr:
+	device_remove_file(&pdev->dev, &dev_attr_dma_rptr);
+out_dma_cblc:
+	device_remove_file(&pdev->dev, &dev_attr_dma_cblc);
+out_dma_cbl:
+	device_remove_file(&pdev->dev, &dev_attr_dma_cbl);
+out_dma_stat:
+	device_remove_file(&pdev->dev, &dev_attr_dma_stat);
+out_dma_ctrl:
+	device_remove_file(&pdev->dev, &dev_attr_dma_ctrl);
+out_dma_irer:
+	device_remove_file(&pdev->dev, &dev_attr_dma_irer);
+out_dma_irsr:
+	device_remove_file(&pdev->dev, &dev_attr_dma_irsr);
+out_apl_attr:
+	device_remove_file(&pdev->dev, &dev_attr_apl_mode);
+#endif
+out_cur_attr:
+	device_remove_file(&pdev->dev, &dev_attr_fw_cur);
+out_hw_attr:
+	device_remove_file(&pdev->dev, &dev_attr_hw_ver);
+out_fw_attr:
+	device_remove_file(&pdev->dev, &dev_attr_fw_ver);
+out_amreg:
+	device_remove_file(&pdev->dev, &dev_attr_amreg);
+out_ier:
+	device_remove_file(&pdev->dev, &dev_attr_ier);
+out_isr:
+	device_remove_file(&pdev->dev, &dev_attr_isr);
+out_dma_on_irq:
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	device_remove_file(&pdev->dev, &dev_attr_dma_on_irq);
+out_poll:
+	device_remove_file(&pdev->dev, &dev_attr_poll_interval);
+out:
+#endif
+	return ret;
+}
+
+static void fc_unregister_attr(struct pci_dev *pdev)
+{
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DEBUG
+	device_remove_file(&pdev->dev, &dev_attr_eray_mtccv);
+	device_remove_file(&pdev->dev, &dev_attr_fc_rocr);
+	device_remove_file(&pdev->dev, &dev_attr_dma_wptr);
+	device_remove_file(&pdev->dev, &dev_attr_dma_rptr);
+	device_remove_file(&pdev->dev, &dev_attr_dma_cblc);
+	device_remove_file(&pdev->dev, &dev_attr_dma_cbl);
+	device_remove_file(&pdev->dev, &dev_attr_dma_stat);
+	device_remove_file(&pdev->dev, &dev_attr_dma_ctrl);
+	device_remove_file(&pdev->dev, &dev_attr_dma_irer);
+	device_remove_file(&pdev->dev, &dev_attr_dma_irsr);
+#endif
+	device_remove_file(&pdev->dev, &dev_attr_apl_mode);
+	device_remove_file(&pdev->dev, &dev_attr_fw_cur);
+	device_remove_file(&pdev->dev, &dev_attr_hw_ver);
+	device_remove_file(&pdev->dev, &dev_attr_fw_ver);
+	device_remove_file(&pdev->dev, &dev_attr_amreg);
+	device_remove_file(&pdev->dev, &dev_attr_ier);
+	device_remove_file(&pdev->dev, &dev_attr_isr);
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	device_remove_file(&pdev->dev, &dev_attr_poll_interval);
+	device_remove_file(&pdev->dev, &dev_attr_dma_on_irq);
+#endif
+}
+
+static int fc_pci_probe(struct pci_dev *pdev,
+			const struct pci_device_id *id)
+{
+	struct fc_priv *priv;
+	u32 fw_ver, hw_ver;
+	int ret =3D -ENOMEM;
+
+	if (bitmap_full(fc_cards, FC_MAX_CARDS)) {
+		dev_err(&pdev->dev, "could not handle more then %d cards\n",
+			FC_MAX_CARDS);
+		goto out;
+	}
+
+	priv =3D kzalloc(sizeof(struct fc_priv), GFP_KERNEL);
+	if (!priv) {
+		dev_err(&pdev->dev, "out of memory\n");
+		goto out;
+	}
+
+	priv->dev =3D pdev;
+	priv->card_nr =3D find_first_zero_bit(fc_cards, FC_MAX_CARDS);
+	set_bit(priv->card_nr, fc_cards);
+
+	pci_set_drvdata(pdev, priv);
+	pci_set_master(pdev);
+
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev, "could not enable device\n");
+		goto out_free_priv;
+	}
+
+	if (pci_request_regions(pdev, "flexcard")) {
+		dev_err(&pdev->dev, "could not request mem regions\n");
+		goto out_disable;
+	}
+
+	priv->conf =3D ioremap(pci_resource_start(pdev, 0),
+			     pci_resource_len(pdev, 0));
+	if (!priv->conf) {
+		dev_err(&pdev->dev, "could not remap BAR0\n");
+		goto out_release;
+	}
+
+	priv->mmio =3D ioremap(pci_resource_start(pdev, 1),
+			     pci_resource_len(pdev, 1));
+	if (!priv->mmio) {
+		dev_err(&pdev->dev, "could not remap BAR1\n");
+		goto out_unmap;
+	}
+
+	ret =3D fc_irq_add(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not add IRQ controller\n");
+		goto out_unmap_mmio;
+	}
+
+	reset_flexcard(priv);
+
+	ret =3D fc_register_attr(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register devive attributes\n");
+		goto out_irq;
+	}
+
+	ret =3D fc_init_dma(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register DMA\n");
+		goto out_attr;
+	}
+
+	ret =3D fc_init_uio(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register UIO\n");
+		goto out_attr;
+	}
+
+	ret =3D fc_init_event(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register events\n");
+		goto out_attr;
+	}
+
+	ret =3D fc_init_clk(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register clock\n");
+		goto out_attr;
+	}
+
+	ret =3D fc_init_bus(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register CAN/FlexRay\n");
+		goto out_attr;
+	}
+
+	fw_ver =3D readl(priv->conf + FC_FC_FW_VER);
+	hw_ver =3D readl(priv->conf + FC_FC_HW_VER);
+	dev_info(&pdev->dev, "Flexcard HW ver. %d.%d.%d FW ver. %d.%d.%d\n",
+		 hw_ver >> 16 & 0xff, hw_ver >> 8 & 0xff, hw_ver & 0xff,
+		 fw_ver >> 16 & 0xff, fw_ver >> 8 & 0xff, fw_ver & 0xff);
+
+	return 0;
+
+out_attr:
+	fc_unregister_attr(pdev);
+out_irq:
+	fc_irq_remove(pdev);
+out_unmap_mmio:
+	iounmap(priv->mmio);
+out_unmap:
+	iounmap(priv->conf);
+out_release:
+	pci_release_regions(pdev);
+out_disable:
+	pci_disable_device(pdev);
+out_free_priv:
+	clear_bit(priv->card_nr, fc_cards);
+	kfree(priv);
+out:
+	return -ENODEV;
+}
+
+static void fc_pci_remove(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+
+	/*
+	 * Reset FlexCard to avoid serious problems due
+	 * to spurious packet generation.
+	 */
+	reset_flexcard(priv);
+	mfd_remove_devices(&pdev->dev);
+
+	fc_unregister_attr(pdev);
+	fc_irq_remove(pdev);
+
+	pci_clear_master(pdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+
+	iounmap(priv->mmio);
+	iounmap(priv->conf);
+
+	kfree(priv->dcan);
+	kfree(priv->eray);
+
+	clear_bit(priv->card_nr, fc_cards);
+
+	kfree(priv);
+}
+
+static DEFINE_PCI_DEVICE_TABLE(fc_pci_ids) =3D {
+	{ PCI_DEVICE(PCI_VENDOR_ID_EBEL, PCI_DEVICE_ID_FC_PMC2) },
+	{ }
+};
+MODULE_DEVICE_TABLE(pci, fc_pci_ids);
+
+static struct pci_driver fc_pci_driver =3D {
+	.name =3D "flexcard",
+	.id_table =3D fc_pci_ids,
+	.probe =3D fc_pci_probe,
+	.remove =3D fc_pci_remove,
+};
+module_pci_driver(fc_pci_driver);
+
+MODULE_DESCRIPTION("Driver for the Ebersp=C3=A4cher Electronics CAN/Fl=
exRay cards");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/mfd/flexcard-dma.c b/drivers/mfd/flexcard-dma.c
new file mode 100644
index 0000000..06cf919
--- /dev/null
+++ b/drivers/mfd/flexcard-dma.c
@@ -0,0 +1,561 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#include <linux/device.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/mfd/core.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/hrtimer.h>
+#include <linux/netdevice.h>
+#include <linux/uio_driver.h>
+
+#include <linux/flexcard.h>
+
+#undef DEBUG_DMA_BUFFER_OUTPUT
+
+#define FC_DEFAULT_CBLC		0x1000
+#define FC_PACKET_OFF(x)	(0xe0000000 + x * 0x200000)
+
+/* The first supported FW Version is 6.4.0 */
+#define MIN_FW_MAJOR	6
+#define MIN_FW_MINOR	4
+#define MIN_FW_UPDATE	0
+
+static LIST_HEAD(rx_cb_list);
+static DEFINE_SPINLOCK(rx_cb_lock);
+
+struct dma_flexcard {
+	int act;
+	int irq;
+	int irq_ovr;
+	u32 cnt_old;
+	u32 rptr;
+	u32 dmaptr;
+	void *buf;
+	dma_addr_t phys;
+	void __iomem *reg;
+	struct uio_info info;
+	int nr_eray;
+};
+
+struct fc_rx_cb {
+	struct list_head list;
+	int (*rx_cb) (void *priv, void *data, size_t len);
+	int cc;
+	void *priv;
+};
+
+
+
+int fc_register_rx_pkt(int cc, void *priv,
+		       int (*rx_cb)(void *priv, void *data, size_t len))
+{
+	unsigned long flags;
+	struct fc_rx_cb *cb, *next;
+
+	if (!rx_cb)
+		return -EINVAL;
+
+	cb =3D kmalloc(sizeof(*cb), GFP_ATOMIC);
+	if (!cb)
+		return -ENOMEM;
+
+	cb->cc =3D cc;
+	cb->priv =3D priv;
+	cb->rx_cb =3D rx_cb;
+
+	spin_lock_irqsave(&rx_cb_lock, flags);
+	list_for_each_entry(next, &rx_cb_list, list)
+		if (next->cc =3D=3D cc)
+			goto out;
+
+	list_add_tail(&cb->list, &rx_cb_list);
+	spin_unlock_irqrestore(&rx_cb_lock, flags);
+
+	return 0;
+out:
+	spin_unlock_irqrestore(&rx_cb_lock, flags);
+	kfree(cb);
+
+	return -EBUSY;
+}
+EXPORT_SYMBOL_GPL(fc_register_rx_pkt);
+
+void fc_unregister_rx_pkt(int cc)
+{
+	unsigned long flags;
+	struct fc_rx_cb *cur, *next;
+	int found =3D 0;
+
+	spin_lock_irqsave(&rx_cb_lock, flags);
+	list_for_each_entry_safe(cur, next, &rx_cb_list, list) {
+		if (cur->cc =3D=3D cc) {
+			list_del(&cur->list);
+			kfree(cur);
+			found =3D 1;
+			break;
+		}
+	}
+
+	WARN_ON(!found);
+
+	spin_unlock_irqrestore(&rx_cb_lock, flags);
+}
+EXPORT_SYMBOL_GPL(fc_unregister_rx_pkt);
+
+static int fc_send_pkt(int cc, void *buf, size_t len)
+{
+	struct fc_rx_cb *next;
+	int ret =3D -ENODEV;
+
+	spin_lock(&rx_cb_lock);
+	list_for_each_entry(next, &rx_cb_list, list)
+		if (next->cc =3D=3D cc)
+			ret =3D next->rx_cb(next->priv, buf, len);
+	spin_unlock(&rx_cb_lock);
+
+	return ret;
+}
+
+u32 fc_get_packet_len(u32 header)
+{
+	u32 len;
+
+	/*
+	 * header contains the number of transmitted 16bit words in bits 30-1=
6.
+	 * if the number is odd the DMA engine padded with zero to 32bit.
+	 * calculate the number of transmitted bytes.
+	 */
+
+	len =3D le32_to_cpu(header);
+
+	len >>=3D FC_BUF_HEADER_LEN_SHIFT;
+	len &=3D FC_BUF_HEADER_LEN_MASK;
+
+	len =3D roundup(len, 4);
+
+	return len;
+}
+EXPORT_SYMBOL_GPL(fc_get_packet_len);
+
+static u32 fc_parse_packet(struct fc_packet_buf *pb, u32 avail,
+			   struct dma_flexcard *priv)
+{
+	u32 l, cc, len =3D sizeof(struct fc_packet);
+	union fc_packet_types *pt =3D &pb->packet;
+
+	switch (le32_to_cpu(pb->header.type)) {
+	case fc_packet_type_info:
+		len +=3D sizeof(struct fc_info_packet);
+		cc =3D pt->info_packet.cc;
+		break;
+	case fc_packet_type_error:
+		len +=3D sizeof(struct fc_error_packet);
+		cc =3D pt->error_packet.cc;
+		break;
+	case fc_packet_type_status:
+		len +=3D sizeof(struct fc_status_packet);
+		cc =3D pt->status_packet.cc;
+		if ((priv->nr_eray =3D=3D 1) && (cc =3D=3D 1))
+			cc =3D 0;		/* self sync status */
+		break;
+	case fc_packet_type_nmv_vector:
+		len +=3D sizeof(struct fc_nm_vector_packet);
+		cc =3D pt->nm_vector_packet.cc;
+		break;
+	case fc_packet_type_notification:
+		len +=3D sizeof(struct fc_notification_packet);
+		cc =3D 0;
+		break;
+	case fc_packet_type_trigger_ex:
+		len +=3D sizeof(struct fc_trigger_ex_info_packet);
+		cc =3D 0;
+		break;
+	case fc_packet_type_can:
+		len +=3D sizeof(struct fc_can_packet);
+		cc =3D FC_CANIF_OFFSET + pt->can_packet.cc;
+		break;
+	case fc_packet_type_can_error:
+		len +=3D sizeof(struct fc_can_error_packet);
+		cc =3D FC_CANIF_OFFSET + pt->can_error_packet.cc;
+		break;
+	case fc_packet_type_flexray_frame:
+		len +=3D sizeof(struct fc_flexray_frame);
+		pt->flexray_frame.pdata =3D len;
+		l =3D fc_get_packet_len(pt->flexray_frame.header);
+		len +=3D l;
+		cc =3D pt->flexray_frame.cc;
+		break;
+	case fc_packet_type_tx_ack:
+		len +=3D sizeof(struct fc_tx_ack_packet);
+		pt->tx_ack_packet.pdata =3D len;
+		l =3D fc_get_packet_len(pt->tx_ack_packet.header);
+		len +=3D l;
+		cc =3D pt->tx_ack_packet.cc;
+		if ((priv->nr_eray =3D=3D 1) && (cc =3D=3D 1))
+			cc =3D 0;		/* self sync tx ack */
+		break;
+	case fc_packet_type_trigger:
+	default:
+		return 0;
+	}
+
+	if (len > avail)
+		return 0;
+
+	fc_send_pkt(cc, pb, len);
+	return len;
+}
+
+static int poll_dma_until_idle(struct dma_flexcard *priv)
+{
+	unsigned int retry =3D 500;
+
+	while (1) {
+		u32 idle;
+
+		idle =3D readl(priv->reg + FC_DMA_CTRL) & FC_DMA_CTRL_DMA_IDLE;
+		if (idle)
+			return 0;
+		retry--;
+		if (!retry)
+			return -ETIMEDOUT;
+		udelay(10);
+	};
+}
+
+static irqreturn_t flexcard_isr(int irq, void *dev_id)
+{
+	struct platform_device *pdev =3D dev_id;
+	struct dma_flexcard *priv =3D platform_get_drvdata(pdev);
+	u32 avail, parsed, rptr =3D priv->rptr;
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	u32 newcnt, cnt;
+	int ret;
+	/*
+	 * Calculate the number of newly available bytes and kick the
+	 * DMA engine.
+	 *
+	 * CHECKME: Is it guaranteed, that the last transfer has
+	 * finished? This really wants a sanity check.
+	 */
+	ret =3D poll_dma_until_idle(priv);
+	if (ret)
+		dev_err(&pdev->dev, "Could not stop the DMA engine.\n");
+
+	/* If there is new data, we kick the DMA engine */
+	cnt =3D readl(priv->reg + FC_FC_DATA_CNT);
+	newcnt =3D cnt - priv->cnt_old;
+	if (newcnt) {
+		writel(newcnt, priv->reg + FC_DMA_TXR);
+		writel(FC_DMA_TXR_TX_ENA | newcnt, priv->reg + FC_DMA_TXR);
+	}
+
+	/*
+	 * Now check if we have data to process.
+	 *
+	 * priv->dmaptr: The offset into the dma buffer on which the
+	 *		 previous DMA transfer ends
+	 * priv->rptr:	 The offset into the buffer on which our last
+	 *		 parser call finished
+	 */
+	avail =3D (priv->dmaptr - rptr) & FC_DMA_BUF_MASK;
+
+	/* Update the data for the next round */
+	priv->cnt_old =3D cnt;
+	priv->dmaptr =3D (priv->dmaptr + newcnt) & FC_DMA_BUF_MASK;
+#else
+	/* Get amount of available data from common buffer level*/
+	avail =3D readl(priv->reg + FC_DMA_CBLR);
+#endif
+
+	if (!avail)
+		return IRQ_NONE;
+
+	do {
+		u32 tocp =3D rptr + FC_MAX_PAKET_SIZE;
+		/*
+		 * For simplicity the parser always looks at contiguous
+		 * buffer space.
+		 *
+		 * We ensure that by copying the eventually wrapped
+		 * bytes of the next message from the bottom of the
+		 * dma buffer to the space right after the dma buffer
+		 * which has been allocated just for that reason.
+		 */
+		if (tocp > FC_DMA_BUF_SIZE) {
+			tocp &=3D FC_DMA_BUF_MASK;
+			memcpy(priv->buf + FC_DMA_BUF_SIZE, priv->buf, tocp);
+		}
+
+		parsed =3D fc_parse_packet(priv->buf + rptr, avail, priv);
+		if (parsed > avail) {
+			dev_err(&pdev->dev, "Parser overrun\n");
+			rptr =3D (rptr + parsed) & FC_DMA_BUF_MASK;
+			break;
+		}
+		avail -=3D parsed;
+		rptr =3D (rptr + parsed) & FC_DMA_BUF_MASK;
+	} while (parsed && avail);
+
+	/* Update the read pointer in the device if we processed data */
+	if (priv->rptr !=3D rptr) {
+		u32 *p =3D priv->buf + 2 * FC_DMA_BUF_SIZE - 4;
+		*p =3D priv->rptr =3D rptr;
+		writel(rptr, priv->reg + FC_DMA_RPTR);
+	} else {
+		/* This should not happen. Or can it ? */
+		dev_err(&pdev->dev, "rptr unchanged\n");
+	}
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t flexcard_ovr_isr(int irq, void *dev_id)
+{
+	struct platform_device *pdev =3D dev_id;
+	struct dma_flexcard *priv =3D platform_get_drvdata(pdev);
+	u32 stat;
+
+	/* check overflow flag */
+	stat =3D readl(priv->reg + FC_DMA_STAT);
+	if (!(stat & FC_DMA_STAT_OFL))
+		return IRQ_NONE;
+
+	dev_err(&pdev->dev, "DMA buffer overflow\n");
+	writel(0, priv->reg + FC_DMA_RPTR);
+
+	/* reset overflow flag */
+	writel(FC_DMA_STAT_OFL, priv->reg + FC_DMA_STAT);
+
+	return IRQ_HANDLED;
+}
+
+static int check_flex_fw_version(u32 fw_version)
+{
+	u8 fw_major, fw_minor, fw_update;
+
+	fw_major =3D (fw_version >> 16) & 0xff;
+	fw_minor =3D (fw_version >> 8) & 0xff;
+	fw_update =3D fw_version & 0xff;
+
+	if ((fw_major =3D=3D 0xFF) && (fw_minor =3D=3D 0xFF) && (fw_update =3D=
=3D 0xFF))
+		/* error while reading informations */
+		return -EINVAL;
+	if (fw_major > MIN_FW_MAJOR)
+		return 0;
+	if (fw_major < MIN_FW_MAJOR)
+		return -EINVAL;
+	if (fw_minor > MIN_FW_MINOR)
+		return 0;
+	if (fw_minor < MIN_FW_MINOR)
+		return -EINVAL;
+	if (fw_update < MIN_FW_UPDATE)
+		return -EINVAL;
+	return 0;
+}
+
+static int flexcard_dma_probe(struct platform_device *pdev)
+{
+	struct dma_flexcard *priv;
+	struct resource *res;
+	int irq_ovr, irq, ret =3D -ENXIO;
+	u32 fw_version;
+	u32 avail, sup;
+
+	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "failed to get I/O memory\n");
+		goto out;
+	}
+
+	irq =3D platform_get_irq(pdev, 0);
+	if (irq < 0) {
+		dev_err(&pdev->dev, "failed to get CBL IRQ\n");
+		goto out;
+	}
+
+	irq_ovr =3D platform_get_irq(pdev, 1);
+	if (irq_ovr < 0) {
+		dev_err(&pdev->dev, "failed to get CO IRQ\n");
+		goto out;
+	}
+
+	priv =3D kzalloc(sizeof(struct dma_flexcard), GFP_KERNEL);
+	if (!priv) {
+		dev_err(&pdev->dev, "out of memory\n");
+		goto out;
+	}
+
+	priv->buf =3D dma_alloc_coherent(&pdev->dev,
+				       2 * FC_DMA_BUF_SIZE,
+				       &priv->phys, GFP_KERNEL);
+	if (!priv->buf) {
+		dev_err(&pdev->dev, "could not allocate DMA memory\n");
+		goto out_free_priv;
+	}
+
+	priv->reg =3D ioremap_nocache(res->start, resource_size(res));
+	if (!priv->reg) {
+		dev_err(&pdev->dev, "failed to remap I/O memory\n");
+		goto out_free_buf;
+	}
+
+	fw_version =3D readl(priv->reg + FC_FC_FW_VER);
+	ret =3D check_flex_fw_version(fw_version);
+	if (ret) {
+		dev_err(&pdev->dev, "minimum FW Version %d.%d.%d required.",
+			MIN_FW_MAJOR, MIN_FW_MINOR, MIN_FW_UPDATE);
+		goto out_unmap;
+	}
+
+	avail =3D readl(priv->reg + FC_FC_LIC0) & FC_LIC0_FLEXRAY_MASK;
+	sup =3D readl(priv->reg + FC_FC_SLIC0) & FC_SLIC0_FLEXRAY_MASK;
+
+	priv->nr_eray =3D min(avail, sup);
+
+	priv->info.mem[0].addr =3D priv->phys;
+	priv->info.mem[0].size =3D 2 * FC_DMA_BUF_SIZE;
+	priv->info.mem[0].memtype =3D UIO_MEM_PHYS;
+	priv->info.name =3D "FlexCard_DMA_buffer";
+	priv->info.version =3D "0.0.1";
+	priv->info.irq =3D 0;
+	if (uio_register_device(&pdev->dev, &priv->info)) {
+		dev_err(&pdev->dev, "could not register debug device\n");
+		goto out_unmap;
+	}
+
+	priv->irq =3D irq;
+	priv->irq_ovr =3D irq_ovr;
+	priv->cnt_old =3D readl(priv->reg + FC_FC_DATA_CNT);
+	writel(0, priv->reg + FC_DMA_IRER);
+
+	/* reset dma controller */
+	writel(FC_DMA_CTRL_RST_DMA, priv->reg + FC_DMA_CTRL);
+
+	ret =3D poll_dma_until_idle(priv);
+	if (ret) {
+		dev_err(&pdev->dev, "could not reset Flexcard DMA\n");
+		goto out_uio;
+	}
+
+	platform_set_drvdata(pdev, priv);
+
+	writel(0x0, priv->reg + FC_DMA_WPTR);
+	writel(0x0, priv->reg + FC_DMA_RPTR);
+	writel(0x0, priv->reg + FC_DMA_CTRL);
+
+	writel(priv->phys, priv->reg + FC_DMA_CBAL);
+	writel((u64) priv->phys >> 32, priv->reg + FC_DMA_CBAH);
+	writel(FC_DMA_BUF_SIZE, priv->reg + FC_DMA_CBS);
+
+	ret =3D request_threaded_irq(irq, NULL, flexcard_isr, IRQF_ONESHOT,
+				   "flexcard-CBL", pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "could not request Flexcard DMA CBL IRQ\n");
+		goto out_unmap;
+	}
+
+	ret =3D request_irq(irq_ovr, flexcard_ovr_isr, 0, "flexcard-CO", pdev=
);
+	if (ret) {
+		dev_err(&pdev->dev, "could not request Flexcard DMA CO IRQ\n");
+		goto out_free_irq;
+	}
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	writel((FC_DMA_CTRL_DMA_ENA | FC_DMA_CTRL_MAN_ENA),
+			priv->reg + FC_DMA_CTRL);
+#else
+	/* enable dma but not manual dma mode */
+	writel(FC_DMA_CTRL_DMA_ENA, priv->reg + FC_DMA_CTRL);
+	/* set common buffer level configuration to an initial value */
+	writel(0x300, priv->reg + FC_DMA_CBCR);
+#endif
+
+	dev_info(&pdev->dev, "Flexcard DMA registered");
+	return 0;
+
+out_free_irq:
+	writel(0x0, priv->reg + FC_DMA_CTRL);
+	free_irq(irq, pdev);
+	platform_set_drvdata(pdev, NULL);
+out_uio:
+	uio_unregister_device(&priv->info);
+out_unmap:
+	iounmap(priv->reg);
+out_free_buf:
+	dma_free_coherent(&pdev->dev, 2 * FC_DMA_BUF_SIZE, priv->buf,
+			  priv->phys);
+out_free_priv:
+	kfree(priv);
+out:
+	return ret;
+}
+
+static int flexcard_dma_remove(struct platform_device *pdev)
+{
+	struct dma_flexcard *priv =3D platform_get_drvdata(pdev);
+	int retry =3D 200;
+	int ret;
+
+	WARN_ON(!list_empty(&rx_cb_list));
+
+	uio_unregister_device(&priv->info);
+
+	free_irq(priv->irq, pdev);
+	free_irq(priv->irq_ovr, pdev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	writel(FC_DMA_CTRL_STOP_REQ, priv->reg + FC_DMA_CTRL);
+	ret =3D poll_dma_until_idle(priv);
+	if (ret)
+		dev_err(&pdev->dev, "could not stop DMA state machine\n");
+
+	while (1) {
+		u32 busy;
+
+		busy =3D readl(priv->reg + FC_DMA_STAT);
+		busy &=3D FC_DMA_STAT_DMA_DSTAT_BUSY;
+		if (!busy)
+			break;
+		retry--;
+		if (!retry)
+			break;
+		udelay(1);
+	};
+	if (!retry)
+		dev_err(&pdev->dev, "could not stop DMA\n");
+
+	/* reset dma controller */
+	writel(FC_DMA_CTRL_RST_DMA, priv->reg + FC_DMA_CTRL);
+	writel(0x0, priv->reg + FC_DMA_CBCR);
+
+	/* disable dma controller */
+	writel(0x0, priv->reg + FC_DMA_CTRL);
+	iounmap(priv->reg);
+
+	dma_free_coherent(&pdev->dev, 2 * FC_DMA_BUF_SIZE, priv->buf,
+			  priv->phys);
+	kfree(priv);
+
+	return 0;
+}
+
+static struct platform_driver flexcard_dma_driver =3D {
+	.probe		=3D flexcard_dma_probe,
+	.remove		=3D flexcard_dma_remove,
+	.driver		=3D {
+		.name   =3D "flexcard-dma",
+		.owner =3D THIS_MODULE,
+	}
+};
+module_platform_driver(flexcard_dma_driver);
+MODULE_ALIAS("platform:flexcard-dma");
+
+MODULE_DESCRIPTION("Flexcard DMA Platform Driver");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/mfd/flexcard-irq.c b/drivers/mfd/flexcard-irq.c
new file mode 100644
index 0000000..c566841
--- /dev/null
+++ b/drivers/mfd/flexcard-irq.c
@@ -0,0 +1,333 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#include <linux/device.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/mfd/core.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/platform_device.h>
+#include <linux/uio_driver.h>
+#include <linux/flexcard.h>
+#include <linux/eray.h>
+
+#include "flexcard.h"
+
+#define to_irq_tab(e, r, s) \
+{	\
+	.enable =3D (1 << e),	\
+	.reset  =3D (1 << r),	\
+	.status =3D (1 << s),	\
+}
+
+/*
+ * Interrupt Controler Register S-Box
+ * Unlike other irq controllers the FlexCard bits for enable, reset an=
d status
+ * look more like a cryptographic S-box. Make a const table to have a =
more
+ * easier access to this bits in the irqchip callback functions.
+ * The table contains the registers for PMC2-cards.
+ */
+static const struct fc_irq_tab fc_irq_tab[] =3D {
+	to_irq_tab(18,  2, 30), /* CC3YCS */
+	to_irq_tab(19,  6, 25), /* CC4YCS */
+	to_irq_tab(20, 14, 17), /* WAKE4A */
+	to_irq_tab(21, 15, 16), /* WAKE4B */
+	to_irq_tab(22, 12, 19), /* WAKE3A */
+	to_irq_tab(23, 13, 18), /* WAKE3B */
+	to_irq_tab(24,  8, 23), /* WAKE2A */
+	to_irq_tab(25,  9, 22), /* WAKE2B */
+	to_irq_tab(26,  4, 26), /* WAKE1A */
+	to_irq_tab(27,  5, 27), /* WAKE1B */
+	to_irq_tab(28,  0, 28), /* TIMER  */
+	to_irq_tab(29,  1, 29), /* CC1YCS */
+	to_irq_tab(30, 10, 21), /* CC2YCS */
+	to_irq_tab( 0,  0,  0), /* NOP    */
+	to_irq_tab(15 , 0, 31), /* CC1T0  */
+	to_irq_tab(14 , 0,  3), /* CC2T0  */
+	to_irq_tab(16 , 0, 24), /* CC3T0  */
+	to_irq_tab(17 , 0, 20), /* CC4T0  */
+	to_irq_tab( 0 , 0,  0), /* DMA_C0 */
+	to_irq_tab( 1 , 1,  1), /* DMA_TE */
+	to_irq_tab( 4 , 4,  4), /* DMA_TI */
+	to_irq_tab( 5 , 5,  5), /* DMA_CBL*/
+};
+
+/* reset interrupt */
+static void fc_irq_ack(struct irq_data *d)
+{
+	struct fc_priv *priv =3D irq_data_get_irq_chip_data(d);
+	int irq =3D d->irq - priv->irq_start;
+
+	if (irq < FC_IRQ_BANK1_NR) {
+		writel(fc_irq_tab[irq].reset, priv->conf + FC_ISR);
+	} else if (irq < FC_IRQ_BANK2_NR) {
+		writel(ERAY_SIR_BIT(TI0), priv->mmio + ERAY_SIR +
+		       (irq - FC_IRQ_BANK1_NR) * 0x4000);
+	} else if (irq < FC_IRQ_BANK3_NR) {
+		writel(fc_irq_tab[irq].reset, priv->conf + FC_DMA_IRSR);
+	}
+}
+
+/* disable interrupt */
+static void fc_irq_mask(struct irq_data *d)
+{
+	struct fc_priv *priv =3D irq_data_get_irq_chip_data(d);
+	unsigned long flags;
+	int irq =3D d->irq - priv->irq_start;
+	u32 irc;
+
+	if (irq < FC_IRQ_BANK2_NR) {
+		raw_spin_lock_irqsave(&priv->irq_lock, flags);
+		irc =3D readl(priv->conf + FC_IER);
+		irc &=3D ~fc_irq_tab[irq].enable;
+		writel(irc, priv->conf + FC_IER);
+		raw_spin_unlock_irqrestore(&priv->irq_lock, flags);
+	} else if (irq < FC_IRQ_BANK3_NR) {
+		raw_spin_lock_irqsave(&priv->irq_lock, flags);
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+		priv->active &=3D ~(1 << irq);
+#else
+		irc =3D readl(priv->conf + FC_DMA_IRER);
+		irc &=3D ~fc_irq_tab[irq].enable;
+		writel(irc, priv->conf + FC_DMA_IRER);
+#endif
+		raw_spin_unlock_irqrestore(&priv->irq_lock, flags);
+	}
+}
+
+/* enable interrupt */
+static void fc_irq_unmask(struct irq_data *d)
+{
+	struct fc_priv *priv =3D irq_data_get_irq_chip_data(d);
+	unsigned long flags;
+	int irq =3D d->irq - priv->irq_start;
+	u32 irc;
+
+	if (irq < FC_IRQ_BANK2_NR) {
+		raw_spin_lock_irqsave(&priv->irq_lock, flags);
+		irc =3D readl(priv->conf + FC_IER);
+		irc |=3D fc_irq_tab[irq].enable;
+		writel(irc, priv->conf + FC_IER);
+		raw_spin_unlock_irqrestore(&priv->irq_lock, flags);
+	} else if (irq < FC_IRQ_BANK3_NR) {
+		raw_spin_lock_irqsave(&priv->irq_lock, flags);
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+		priv->active |=3D 1 << irq;
+#else
+		irc =3D readl(priv->conf + FC_DMA_IRER);
+		irc |=3D FC_DMA_IRER_DIRE;
+		irc |=3D fc_irq_tab[irq].enable;
+		writel(irc, priv->conf + FC_DMA_IRER);
+#endif
+		raw_spin_unlock_irqrestore(&priv->irq_lock, flags);
+	}
+}
+
+static struct irq_chip fc_irq_chip =3D {
+	.name		=3D "fc_irq",
+	.irq_ack	=3D fc_irq_ack,
+	.irq_mask	=3D fc_irq_mask,
+	.irq_unmask	=3D fc_irq_unmask,
+};
+
+/*
+ * the firmware multiplexes the interrupts and saves the interrupt rea=
son in
+ * two registers FC_ISR and FC_DMA_IRSR
+ * here we distribute the interrupts.
+*/
+static irqreturn_t fc_demux(int irq, void *data)
+{
+	struct fc_priv *priv =3D data;
+	int i;
+	u32 stat, stat_dma;
+	irqreturn_t ret =3D IRQ_NONE;
+	int err;
+
+	stat =3D readl(priv->conf + FC_ISR);
+	stat_dma =3D readl(priv->conf + FC_DMA_IRSR);
+	if (!stat && !stat_dma)
+		return IRQ_NONE;
+
+	/* FC_IRQ_BANK1/FC_IRQ_BANK2 */
+	for (i =3D 0; i < FC_IRQ_BANK2_NR; i++)
+		if (stat & fc_irq_tab[i].status) {
+			err =3D generic_handle_irq(priv->irq_start + i);
+			if (!err)
+				ret =3D IRQ_HANDLED;
+		}
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	if (stat & fc_irq_tab[FC_IRQ_TIMER_OFF].status ||
+	    stat & fc_irq_tab[FC_IRQ_CC1CYCS_OFF].status ||
+	    stat & fc_irq_tab[FC_IRQ_CC2CYCS_OFF].status ||
+	    stat & fc_irq_tab[FC_IRQ_CC3CYCS_OFF].status ||
+	    stat & fc_irq_tab[FC_IRQ_CC4CYCS_OFF].status) {
+		if (priv->dma_on_irq) {
+			err =3D generic_handle_irq(priv->irq_start +
+					FC_IRQ_DMA_CBL_OFF);
+			if (!err)
+				ret =3D IRQ_HANDLED;
+		}
+	}
+#endif
+
+	/* DMA */
+	if (stat_dma & FC_DMA_IRSR_COISR) {
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_CO_OFF);
+		ret =3D IRQ_HANDLED;
+	}
+
+	if (stat_dma & FC_DMA_IRSR_TEISR) {
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_TE_OFF);
+		ret =3D IRQ_HANDLED;
+	}
+
+	if (stat_dma & FC_DMA_IRSR_TISR) {
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_TI_OFF);
+		ret =3D IRQ_HANDLED;
+	}
+
+	if (stat_dma & FC_DMA_IRSR_CBLISR) {
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_CBL_OFF);
+		ret =3D IRQ_HANDLED;
+	}
+
+	return ret;
+}
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+#define FC_DMA_INITIAL_POLL_TIME	1000000
+
+unsigned int fc_poll_interval =3D CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL_IN=
TERVAL*1000;
+EXPORT_SYMBOL_GPL(fc_poll_interval);
+
+/*
+ * Timer callback function. Called with interrupts disabled.
+ */
+static enum hrtimer_restart dma_irq_poll(struct hrtimer *handle)
+{
+	struct fc_priv *priv =3D container_of(handle, struct fc_priv, timer);
+	u32 irsr, txr;
+
+	irsr =3D readl(priv->conf + FC_DMA_IRSR);
+	txr =3D readl(priv->conf + FC_DMA_TXR);
+
+	/*
+	 * poll the FC_DMA_IRSR_COISR flag in FC_DMA_IRSR and
+	 * the FC_DMA_TXR_TX_ENA flag in FC_DMA_TXR and eject an
+	 * FC_IRQ_DMA_CO or FC_IRQ_DMA_CBL interrupt if needed.
+	 */
+	if ((irsr & FC_DMA_IRSR_COISR) &&
+	    (priv->active & (1 << FC_IRQ_DMA_CO_OFF)))
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_CO_OFF);
+
+	if (!(txr & FC_DMA_TXR_TX_ENA) &&
+	    (priv->active & (1 << FC_IRQ_DMA_CBL_OFF)))
+		generic_handle_irq(priv->irq_start + FC_IRQ_DMA_CBL_OFF);
+
+	hrtimer_forward_now(&priv->timer,
+			    ktime_set(0, fc_poll_interval));
+
+	return HRTIMER_RESTART;
+}
+#endif
+
+static int fc_request_msi_irq(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int ret;
+
+	ret =3D pci_enable_msi(pdev);
+	if (ret) {
+		dev_warn(&pdev->dev, "could not enable MSI\n");
+		return ret;
+	}
+	dev_info(&pdev->dev, "MSI enabled\n");
+
+	ret =3D request_irq(pdev->irq, fc_demux, IRQF_NO_THREAD, "flexcard",
+			  priv);
+	if (ret) {
+		pci_disable_msi(pdev);
+		dev_warn(&pdev->dev, "request MSI irq failed. MSI disabled\n");
+	}
+
+	return ret;
+}
+
+int fc_irq_add(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int i, ret;
+
+	/* Make sure none of the subirqs is enabled */
+	writel(0, priv->conf + FC_IER);
+	writel(0, priv->conf + FC_DMA_IRER);
+
+	raw_spin_lock_init(&priv->irq_lock);
+
+	ret =3D irq_alloc_descs(-1, 0, NR_FC_INTS, numa_node_id());
+	if (ret < 0) {
+		dev_err(&pdev->dev, "could not request irq_descs(%d)\n", ret);
+		goto out;
+	}
+	priv->irq_start =3D ret;
+
+	for (i =3D 0; i < NR_FC_INTS; i++) {
+		irq_set_chip_and_handler_name(priv->irq_start + i,
+					      &fc_irq_chip,
+					      handle_level_irq,
+					      "fc_demux");
+		irq_set_chip_data(priv->irq_start + i, priv);
+		irq_modify_status(priv->irq_start + i,
+				  IRQ_NOREQUEST | IRQ_NOAUTOEN,
+				  IRQ_NOPROBE);
+	}
+
+	if (fc_request_msi_irq(pdev)) {
+		/* shared PCI irq fallback */
+		ret =3D request_irq(pdev->irq, fc_demux, IRQF_NO_THREAD |
+				IRQF_SHARED, "flexcard", priv);
+		if (ret) {
+			dev_err(&pdev->dev, "could not request IRQ\n");
+			goto out_free_irq_descs;
+		}
+	}
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	priv->active =3D 0;
+	hrtimer_init(&priv->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	priv->timer.function =3D dma_irq_poll;
+
+	hrtimer_start(&priv->timer, ktime_set(0, FC_DMA_INITIAL_POLL_TIME),
+		      HRTIMER_MODE_REL);
+#endif
+	return 0;
+
+out_free_irq_descs:
+	irq_free_descs(priv->irq_start, NR_FC_INTS);
+out:
+	return ret;
+}
+
+void fc_irq_remove(struct pci_dev *pdev)
+{
+	struct fc_priv *priv =3D pci_get_drvdata(pdev);
+	int i;
+
+	writel(0, priv->conf + FC_IER);
+	writel(0, priv->conf + FC_DMA_IRER);
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	hrtimer_cancel(&priv->timer);
+#endif
+
+	free_irq(pdev->irq, priv);
+	pci_disable_msi(pdev);
+
+	for (i =3D 0; i < NR_FC_INTS; i++)
+		irq_set_chip(priv->irq_start + i, NULL);
+
+	irq_free_descs(priv->irq_start, NR_FC_INTS);
+}
diff --git a/drivers/mfd/flexcard.h b/drivers/mfd/flexcard.h
new file mode 100644
index 0000000..764f50e
--- /dev/null
+++ b/drivers/mfd/flexcard.h
@@ -0,0 +1,8 @@
+#ifndef _FLEXCARD_H_
+#define _FLEXCARD_H_
+
+extern unsigned int fc_poll_interval;
+int fc_irq_add(struct pci_dev *pdev);
+void fc_irq_remove(struct pci_dev *pdev);
+
+#endif
diff --git a/include/linux/eray.h b/include/linux/eray.h
new file mode 100644
index 0000000..9ce9c9b
--- /dev/null
+++ b/include/linux/eray.h
@@ -0,0 +1,650 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef _LINUX_ERAY_H
+#define _LINUX_ERAY_H
+
+#include <linux/delay.h>
+#include <uapi/linux/eray.h>
+
+#define ERAY_CIF1	0x000
+#define ERAY_CIF2	0x004
+#define ERAY_CIF3	0x008
+#define ERAY_CIF4	0x00c
+
+#define ERAY_LCK	0x01c
+#define ERAY_EIR	0x020
+#define ERAY_SIR	0x024
+#define ERAY_EILS	0x028
+#define ERAY_SILS	0x02c
+#define ERAY_EIES	0x030
+#define ERAY_EIER	0x034
+#define ERAY_SIES	0x038
+#define ERAY_SIER	0x03c
+#define ERAY_ILE	0x040
+#define ERAY_T0C	0x044
+#define ERAY_T1C	0x048
+#define ERAY_STPW1	0x04c
+#define ERAY_STPW2	0x050
+
+#define ERAY_SUCC1	0x080
+#define ERAY_SUCC2	0x084
+#define ERAY_SUCC3	0x088
+#define ERAY_NEMC	0x08c
+#define ERAY_PRTC1	0x090
+#define ERAY_PRTC2	0x094
+#define ERAY_MHDC	0x098
+
+#define ERAY_GTUC1	0x0a0
+#define ERAY_GTUC2	0x0a4
+#define ERAY_GTUC3	0x0a8
+#define ERAY_GTUC4	0x0ac
+#define ERAY_GTUC5	0x0b0
+#define ERAY_GTUC6	0x0b4
+#define ERAY_GTUC7	0x0b8
+#define ERAY_GTUC8	0x0bc
+#define ERAY_GTUC9	0x0c0
+#define ERAY_GTUC10	0x0c4
+#define ERAY_GTUC11	0x0c8
+
+#define ERAY_CCSV	0x100
+#define ERAY_CCEV	0x104
+
+#define ERAY_SCV	0x110
+#define ERAY_MTCCV	0x114
+#define ERAY_RCV	0x118
+#define ERAY_OCV	0x11c
+#define ERAY_SFS	0x120
+#define ERAY_SWNIT	0x124
+#define ERAY_ACS	0x128
+
+#define ERAY_ESID1	0x130
+#define ERAY_ESID2	0x134
+#define ERAY_ESID3	0x138
+#define ERAY_ESID4	0x13c
+#define ERAY_ESID5	0x140
+#define ERAY_ESID6	0x144
+#define ERAY_ESID7	0x148
+#define ERAY_ESID8	0x14c
+#define ERAY_ESID9	0x150
+#define ERAY_ESID10	0x154
+#define ERAY_ESID11	0x158
+#define ERAY_ESID12	0x15c
+#define ERAY_ESID13	0x160
+#define ERAY_ESID14	0x164
+#define ERAY_ESID15	0x168
+
+#define ERAY_OSID1	0x170
+#define ERAY_OSID2	0x174
+#define ERAY_OSID3	0x178
+#define ERAY_OSID4	0x17c
+#define ERAY_OSID5	0x180
+#define ERAY_OSID6	0x184
+#define ERAY_OSID7	0x188
+#define ERAY_OSID8	0x18c
+#define ERAY_OSID9	0x190
+#define ERAY_OSID10	0x194
+#define ERAY_OSID11	0x198
+#define ERAY_OSID12	0x19c
+#define ERAY_OSID13	0x1a0
+#define ERAY_OSID14	0x1a4
+#define ERAY_OSID15	0x1a8
+
+#define ERAY_NMV1	0x1b0
+#define ERAY_NMV2	0x1b4
+#define ERAY_NMV3	0x1b8
+
+#define ERAY_MRC	0x300
+#define ERAY_FRF	0x304
+#define ERAY_FRFM	0x308
+#define ERAY_FCL	0x30c
+#define ERAY_MHDS	0x310
+#define ERAY_LDTS	0x314
+#define ERAY_FSR	0x318
+#define ERAY_MHDF	0x31c
+#define ERAY_TXRQ1	0x320
+#define ERAY_TXRQ2	0x324
+#define ERAY_TXRQ3	0x328
+#define ERAY_TXRQ4	0x32c
+#define ERAY_NDAT1	0x330
+#define ERAY_NDAT2	0x334
+#define ERAY_NDAT3	0x338
+#define ERAY_NDAT4	0x33c
+#define ERAY_MBSC1	0x340
+#define ERAY_MBSC2	0x344
+#define ERAY_MBSC3	0x348
+#define ERAY_MBSC4	0x34c
+
+#define ERAY_CREL	0x3f0
+#define ERAY_ENDN	0x3f4
+
+#define ERAY_WRDS(x)	(0x400 + (x * 4))
+#define ERAY_WRHS1	0x500
+#define ERAY_WRHS2	0x504
+#define ERAY_WRHS3	0x508
+
+#define ERAY_IBCM	0x510
+#define ERAY_IBCR	0x514
+
+#define ERAY_RDDS(x)	(0x600 + (x * 4))
+#define ERAY_RDHS1	0x700
+#define ERAY_RDHS2	0x704
+#define ERAY_RDHS3	0x708
+#define ERAY_MBS	0x70c
+#define ERAY_OBCM	0x710
+#define ERAY_OBCR	0x714
+
+/* SIR / SILS / SIES / SIER */
+#define ERAY_SIR_WST	(1 << 0)
+#define ERAY_SIR_CAS	(1 << 1)
+#define ERAY_SIR_CYCS	(1 << 2)
+#define ERAY_SIR_RXI	(1 << 3)
+#define ERAY_SIR_TXI	(1 << 4)
+#define ERAY_SIR_RFNE	(1 << 5)
+#define ERAY_SIR_RFCL	(1 << 6)
+#define ERAY_SIR_NMVC	(1 << 7)
+#define ERAY_SIR_TI0	(1 << 8)
+#define ERAY_SIR_TI1	(1 << 9)
+#define ERAY_SIR_TIBC	(1 << 10)
+#define ERAY_SIR_TOBC	(1 << 11)
+#define ERAY_SIR_SWE	(1 << 12)
+#define ERAY_SIR_SUCS	(1 << 13)
+#define ERAY_SIR_MBSI	(1 << 14)
+#define ERAY_SIR_SDS	(1 << 15)
+#define ERAY_SIR_WUPA	(1 << 16)
+#define ERAY_SIR_MTSA	(1 << 17)
+#define ERAY_SIR_WUPB	(1 << 24)
+#define ERAY_SIR_MTSB	(1 << 25)
+
+#define ERAY_SIR_BIT(x)		ERAY_SIR_##x
+#define ERAY_SIES_BIT(x)	ERAY_SIR_##x
+#define ERAY_SILS_BIT(x)	ERAY_SIR_##x
+#define ERAY_SIER_BIT(x)	ERAY_SIR_##x
+
+#define ERAY_SIR_MASK						      \
+	ERAY_SIR_WST | ERAY_SIR_CAS | ERAY_SIR_CYCS |		\
+	ERAY_SIR_RXI | ERAY_SIR_TXI | ERAY_SIR_RFNE |		\
+	ERAY_SIR_RFCL | ERAY_SIR_NMVC | ERAY_SIR_TI0 |		\
+	ERAY_SIR_TI1 | ERAY_SIR_TIBC | ERAY_SIR_TOBC |		\
+	ERAY_SIR_SWE | ERAY_SIR_SUCS | ERAY_SIR_MBSI |		\
+	ERAY_SIR_SDS | ERAY_SIR_WUPA | ERAY_SIR_MTSA |		\
+	ERAY_SIR_WUPB | ERAY_SIR_MTSB
+
+/* ILE */
+#define ERAY_ILE_EINT0_MASK	(0x1 << 0)
+#define ERAY_ILE_EINT0_SHIFT	0
+#define ERAY_ILE_EINT1_MASK	(0x1 << 1)
+#define ERAY_ILE_EINT1_SHIFT	1
+#define ERAY_ILE_MASK		(ERAY_ILE_EINT0_MASK | ERAY_ILE_EINT1_MASK)
+#define ERAY_ILE_SHIFT		ERAY_ILE_EINT0_SHIFT
+
+/* SUCC1 */
+#define ERAY_SUCC1_CMD_MASK	(0xf << 0)
+#define ERAY_SUCC1_CMD_SHIFT	0
+#define ERAY_SUCC1_PBSY_MASK	(1 << 7)
+#define ERAY_SUCC1_PBSY_SHIFT	7
+#define ERAY_SUCC1_TXST_MASK	(1 << 8)
+#define ERAY_SUCC1_TXST_SHIFT	8
+#define ERAY_SUCC1_TXSY_MASK	(1 << 9)
+#define ERAY_SUCC1_TXSY_SHIFT	9
+#define ERAY_SUCC1_CSA_MASK	(0x1f << 11)
+#define ERAY_SUCC1_CSA_SHIFT	11
+#define ERAY_SUCC1_PTA_MASK	(0x1f << 16)
+#define ERAY_SUCC1_PTA_SHIFT	16
+#define ERAY_SUCC1_WUCS_MASK	(1 << 21)
+#define ERAY_SUCC1_WUCS_SHIFT	21
+#define ERAY_SUCC1_TSM_MASK	(1 << 22)
+#define ERAY_SUCC1_TSM_SHIFT	22
+#define ERAY_SUCC1_HCSE_MASK	(1 << 23)
+#define ERAY_SUCC1_HCSE_SHIFT	23
+#define ERAY_SUCC1_MTSA_MASK	(1 << 24)
+#define ERAY_SUCC1_MTSA_SHIFT	24
+#define ERAY_SUCC1_MTSB_MASK	(1 << 25)
+#define ERAY_SUCC1_MTSB_SHIFT	25
+#define ERAY_SUCC1_MTS_MASK	(ERAY_SUCC1_MTSA_MASK | ERAY_SUCC1_MTSB_MA=
SK)
+#define ERAY_SUCC1_MTS_SHIFT	ERAY_SUCC1_MTSA_SHIFT
+#define ERAY_SUCC1_CCHA_MASK	(1 << 26)
+#define ERAY_SUCC1_CCHA_SHIFT	26
+#define ERAY_SUCC1_CCHB_MASK	(1 << 27)
+#define ERAY_SUCC1_CCHB_SHIFT	27
+#define ERAY_SUCC1_CCH_MASK	(ERAY_SUCC1_CCHA_MASK | ERAY_SUCC1_CCHB_MA=
SK)
+#define ERAY_SUCC1_CCH_SHIFT	ERAY_SUCC1_CCHA_SHIFT
+
+/* SUCC2 */
+#define ERAY_SUCC2_LT_MASK	(0x1fffff << 0)
+#define ERAY_SUCC2_LT_SHIFT	0
+#define ERAY_SUCC2_LTN_MASK	(0xf << 24)
+#define ERAY_SUCC2_LTN_SHIFT	24
+
+/* SUCC3 */
+#define ERAY_SUCC3_WCP_MASK	(0xf << 0)
+#define ERAY_SUCC3_WCP_SHIFT	0
+#define ERAY_SUCC3_WCF_MASK	(0xf << 4)
+#define ERAY_SUCC3_WCF_SHIFT	4
+
+/* NEMC */
+#define ERAY_NEMC_NML_MASK	(0xf << 0)
+#define ERAY_NEMC_NML_SHIFT	0
+
+/* PRTC1 */
+#define ERAY_PRTC1_TSST_MASK	(0xf << 0)
+#define ERAY_PRTC1_TSST_SHIFT	0
+#define ERAY_PRTC1_CASM_MASK	(0x7f << 4)
+#define ERAY_PRTC1_CASM_SHIFT	4
+#define ERAY_PRTC1_SPP_MASK	(0x3 << 12)
+#define ERAY_PRTC1_SPP_SHIFT	12
+#define ERAY_PRTC1_BRP_MASK	(0x3 << 14)
+#define ERAY_PRTC1_BRP_SHIFT	14
+#define ERAY_PRTC1_RXW_MASK	(0x1ff << 16)
+#define ERAY_PRTC1_RXW_SHIFT	16
+#define ERAY_PRTC1_RWP_MASK	(0x3f << 26)
+#define ERAY_PRTC1_RWP_SHIFT	26
+
+/* PRTC2 */
+#define ERAY_PRTC2_RXI_MASK	(0x3f << 0)
+#define ERAY_PRTC2_RXI_SHIFT	0
+#define ERAY_PRTC2_RXL_MASK	(0x3f << 8)
+#define ERAY_PRTC2_RXL_SHIFT	8
+#define ERAY_PRTC2_TXI_MASK	(0xff << 16)
+#define ERAY_PRTC2_TXI_SHIFT	16
+#define ERAY_PRTC2_TXL_MASK	(0x3f << 24)
+#define ERAY_PRTC2_TXL_SHIFT	24
+
+/* OBCM */
+#define ERAY_OBCM_RHSS_MASK	(0x1 << 0)
+#define ERAY_OBCM_RHSS_SHIFT	0
+#define ERAY_OBCM_RDSS_MASK	(0x1 << 1)
+#define ERAY_OBCM_RDSS_SHIFT	1
+#define ERAY_OBCM_RHSH_MASK	(0x1 << 16)
+#define ERAY_OBCM_RHSH_SHIFT	16
+#define ERAY_OBCM_RDSH_MASK	(0x1 << 17)
+#define ERAY_OBCM_RDSH_SHIFT	17
+
+/* OBCR */
+#define ERAY_OBCR_OBRS_MASK	(0x7f << 0)
+#define ERAY_OBCR_OBRS_SHIFT	0
+#define ERAY_OBCR_VIEW_MASK	(0x1 << 8)
+#define ERAY_OBCR_VIEW_SHIFT	8
+#define ERAY_OBCR_REQ_MASK	(0x1 << 9)
+#define ERAY_OBCR_REQ_SHIFT	9
+#define ERAY_OBCR_OBSYS_MASK	(0x1 << 15)
+#define ERAY_OBCR_OBSYS_SHIFT	15
+#define ERAY_OBCR_OBRH_MASK	(0x7f << 16)
+#define ERAY_OBCR_OBRH_SHIFT	16
+
+/* WRHS1 */
+#define ERAY_WRHS1_FID_MASK	(0x7ff << 0)
+#define ERAY_WRHS1_FID_SHIFT	0
+#define ERAY_WRHS1_CYC_MASK	(0x7f << 16)
+#define ERAY_WRHS1_CYC_SHIFT	16
+#define ERAY_WRHS1_CHA_MASK	(0x1 << 24)
+#define ERAY_WRHS1_CHA_SHIFT	24
+#define ERAY_WRHS1_CHB_MASK	(0x1 << 25)
+#define ERAY_WRHS1_CHB_SHIFT	25
+#define ERAY_WRHS1_CH_MASK	(ERAY_WRHS1_CHA_MASK | ERAY_WRHS1_CHB_MASK)
+#define ERAY_WRHS1_CH_SHIFT	ERAY_WRHS1_CHA_SHIFT
+#define ERAY_WRHS1_CFG_MASK	(0x1 << 26)
+#define ERAY_WRHS1_CFG_SHIFT	26
+#define ERAY_WRHS1_PPIT_MASK	(0x1 << 27)
+#define ERAY_WRHS1_PPIT_SHIFT	27
+#define ERAY_WRHS1_TXM_MASK	(0x1 << 28)
+#define ERAY_WRHS1_TXM_SHIFT	28
+#define ERAY_WRHS1_MBI_MASK	(0x1 << 29)
+#define ERAY_WRHS1_MBI_SHIFT	29
+
+/* WRHS2 */
+#define ERAY_WRHS2_CRC_MASK	(0x7ff << 0)
+#define ERAY_WRHS2_CRC_SHIFT	0
+#define ERAY_WRHS2_PLC_MASK	(0x7f << 16)
+#define ERAY_WRHS2_PLC_SHIFT	16
+
+/* WRHS3 */
+#define ERAY_WRHS3_DP_MASK	(0x7ff << 0)
+#define ERAY_WRHS3_DP_SHIFT	0
+
+/* IBCR */
+#define ERAY_IBCR_IBRH_MASK	(0x7f << 0)
+#define ERAY_IBCR_IBRH_SHIFT	0
+#define ERAY_IBCR_IBSYH_MASK	(0x1 << 15)
+#define ERAY_IBCR_IBSYH_SHIFT	15
+#define ERAY_IBCR_IBRS_MASK	(0x7f << 16)
+#define ERAY_IBCR_IBRS_SHIFT	16
+#define ERAY_IBCR_IBSYS_MASK	(0x1 << 31)
+#define ERAY_IBCR_IBSYS_SHIFT	31
+
+/* RDHS1 */
+#define ERAY_RDHS1_FID_MASK	(0x7ff << 0)
+#define ERAY_RDHS1_FID_SHIFT	0
+#define ERAY_RDHS1_CYC_MASK	(0x7f << 16)
+#define ERAY_RDHS1_CYC_SHIFT	16
+#define ERAY_RDHS1_CHA_MASK	(0x1 << 24)
+#define ERAY_RDHS1_CHA_SHIFT	24
+#define ERAY_RDHS1_CHB_MASK	(0x1 << 25)
+#define ERAY_RDHS1_CHB_SHIFT	25
+#define ERAY_RDHS1_CH_MASK	(ERAY_RDHS1_CHA_MASK | ERAY_RDHS1_CHB_MASK)
+#define ERAY_RDHS1_CH_SHIFT	ERAY_RDHS1_CHA_SHIFT
+#define ERAY_RDHS1_CFG_MASK	(0x1 << 26)
+#define ERAY_RDHS1_CFG_SHIFT	26
+#define ERAY_RDHS1_PPIT_MASK	(0x1 << 27)
+#define ERAY_RDHS1_PPIT_SHIFT	27
+#define ERAY_RDHS1_TXM_MASK	(0x1 << 28)
+#define ERAY_RDHS1_TXM_SHIFT	28
+#define ERAY_RDHS1_MBI_MASK	(0x1 << 29)
+#define ERAY_RDHS1_MBI_SHIFT	29
+
+/* RDHS2 */
+#define ERAY_RDHS2_CRC_MASK	(0x7ff << 0)
+#define ERAY_RDHS2_CRC_SHIFT	0
+#define ERAY_RDHS2_PLC_MASK	(0x7f << 16)
+#define ERAY_RDHS2_PLC_SHIFT	16
+#define ERAY_RDHS2_PLR_MASK	(0x7f << 24)
+#define ERAY_RDHS2_PLR_SHIFT	24
+
+/* RDHS3 */
+#define ERAY_RDHS3_DP_MASK	(0x7ff << 0)
+#define ERAY_RDHS3_DP_SHIFT	0
+#define ERAY_RDHS3_RCC_MASK	(0x3f << 16)
+#define ERAY_RDHS3_RCC_SHIFT	16
+#define ERAY_RDHS3_RCI_MASK	(0x1 << 24)
+#define ERAY_RDHS3_RCI_SHIFT	24
+#define ERAY_RDHS3_SFI_MASK	(0x1 << 25)
+#define ERAY_RDHS3_SFI_SHIFT	25
+#define ERAY_RDHS3_SYN_MASK	(0x1 << 26)
+#define ERAY_RDHS3_SYN_SHIFT	26
+#define ERAY_RDHS3_NFI_MASK	(0x1 << 27)
+#define ERAY_RDHS3_NFI_SHIFT	27
+#define ERAY_RDHS3_PPI_MASK	(0x1 << 28)
+#define ERAY_RDHS3_PPI_SHIFT	28
+#define ERAY_RDHS3_RES_MASK	(0x1 << 29)
+#define ERAY_RDHS3_RES_SHIFT	29
+
+/* IBCM */
+#define ERAY_IBCM_LHSH_MASK	(0x1 << 0)
+#define ERAY_IBCM_LHSH_SHIFT	0
+#define ERAY_IBCM_LDSH_MASK	(0x1 << 1)
+#define ERAY_IBCM_LDSH_SHIFT	1
+#define ERAY_IBCM_STXRH_MASK	(0x1 << 2)
+#define ERAY_IBCM_STXRH_SHIFT	2
+#define ERAY_IBCM_LHSS_MASK	(0x1 << 16)
+#define ERAY_IBCM_LHSS_SHIFT	16
+#define ERAY_IBCM_LDSS_MASK	(0x1 << 17)
+#define ERAY_IBCM_LDSS_SHIFT	17
+#define ERAY_IBCM_STXRS_MASK	(0x1 << 18)
+#define ERAY_IBCM_STXRS_SHIFT	18
+
+/* MHDC */
+#define ERAY_MHDC_SFDL_MASK	(0x7f << 0)
+#define ERAY_MHDC_SFDL_SHIFT	0
+#define ERAY_MHDC_SLT_MASK	(0x1fff << 16)
+#define ERAY_MHDC_SLT_SHIFT	16
+
+/* GTUC1 */
+#define ERAY_GTUC1_UT_MASK	(0xfffff << 0)
+#define ERAY_GTUC1_UT_SHIFT	0
+
+/* GTUC2 */
+#define ERAY_GTUC2_MPC_MASK	(0x3fff << 0)
+#define ERAY_GTUC2_MPC_SHIFT	0
+#define ERAY_GTUC2_SNM_MASK	(0xf << 16)
+#define ERAY_GTUC2_SNM_SHIFT	16
+
+/* GTUC3 */
+#define ERAY_GTUC3_UIOA_MASK	(0xff << 0)
+#define ERAY_GTUC3_UIOA_SHIFT	0
+#define ERAY_GTUC3_UIOB_MASK	(0xff << 8)
+#define ERAY_GTUC3_UIOB_SHIFT	8
+#define ERAY_GTUC3_MIOA_MASK	(0x7f << 16)
+#define ERAY_GTUC3_MIOA_SHIFT	16
+#define ERAY_GTUC3_MIOB_MASK	(0x7f << 24)
+#define ERAY_GTUC3_MIOB_SHIFT	24
+
+/* GTUC4 */
+#define ERAY_GTUC4_NIT_MASK	(0x3fff << 0)
+#define ERAY_GTUC4_NIT_SHIFT	0
+#define ERAY_GTUC4_OCS_MASK	(0x3fff << 16)
+#define ERAY_GTUC4_OCS_SHIFT	16
+
+/* GTUC5 */
+#define ERAY_GTUC5_DCA_MASK	(0xff << 0)
+#define ERAY_GTUC5_DCA_SHIFT	0
+#define ERAY_GTUC5_DCB_MASK	(0xff << 8)
+#define ERAY_GTUC5_DCB_SHIFT	8
+#define ERAY_GTUC5_CDD_MASK	(0x1f << 16)
+#define ERAY_GTUC5_CDD_SHIFT	16
+#define ERAY_GTUC5_DEC_MASK	(0xff << 24)
+#define ERAY_GTUC5_DEC_SHIFT	24
+
+/* GTUC6 */
+#define ERAY_GTUC6_ASR_MASK	(0x7ff << 0)
+#define ERAY_GTUC6_ASR_SHIFT	0
+#define ERAY_GTUC6_MOD_MASK	(0x7ff << 16)
+#define ERAY_GTUC6_MOD_SHIFT	16
+
+/* GTUC7 */
+#define ERAY_GTUC7_SSL_MASK	(0x3ff << 0)
+#define ERAY_GTUC7_SSL_SHIFT	0
+#define ERAY_GTUC7_NSS_MASK	(0x3ff << 16)
+#define ERAY_GTUC7_NSS_SHIFT	16
+
+/* GTUC8 */
+#define ERAY_GTUC8_MSL_MASK	(0x3f << 0)
+#define ERAY_GTUC8_MSL_SHIFT	0
+#define ERAY_GTUC8_NMS_MASK	(0x1fff << 16)
+#define ERAY_GTUC8_NMS_SHIFT	16
+
+/* GTUC9 */
+#define ERAY_GTUC9_APO_MASK	(0x3f << 0)
+#define ERAY_GTUC9_APO_SHIFT	0
+#define ERAY_GTUC9_MAPO_MASK	(0x1f << 8)
+#define ERAY_GTUC9_MAPO_SHIFT	8
+#define ERAY_GTUC9_DSI_MASK	(0x3 << 16)
+#define ERAY_GTUC9_DSI_SHIFT	16
+
+/* GTUC10 */
+#define ERAY_GTUC10_MOC_MASK	(0x3fff << 0)
+#define ERAY_GTUC10_MOC_SHIFT	0
+#define ERAY_GTUC10_MRC_MASK	(0x7ff << 16)
+#define ERAY_GTUC10_MRC_SHIFT	16
+
+/* GTUC11 */
+#define ERAY_GTUC11_EOCC_MASK	(0x3 << 0)
+#define ERAY_GTUC11_EOCC_SHIFT	0
+#define ERAY_GTUC11_ERCC_MASK	(0x3 << 8)
+#define ERAY_GTUC11_ERCC_SHIFT	8
+#define ERAY_GTUC11_EOC_MASK	(0x7 << 16)
+#define ERAY_GTUC11_EOC_SHIFT	16
+#define ERAY_GTUC11_ERC_MASK	(0x7 << 24)
+#define ERAY_GTUC11_ERC_SHIFT	24
+
+/* FRF */
+#define ERAY_FRF_CH_MASK	(0x3 << 0)
+#define ERAY_FRF_CH_SHIFT	0
+#define ERAY_FRF_FID_MASK	(0x3ff << 2)
+#define ERAY_FRF_FID_SHIFT	2
+#define ERAY_FRF_CYC_MASK	(0x7f << 16)
+#define ERAY_FRF_CYC_SHIFT	16
+#define ERAY_FRF_RSS_MASK	(0x1 << 23)
+#define ERAY_FRF_RSS_SHIFT	23
+#define ERAY_FRF_RNF_MASK	(0x1 << 24)
+#define ERAY_FRF_RNF_SHIFT	24
+
+/* FRFM */
+#define ERAY_FRFM_MFID_MASK	(0x3ff << 2)
+#define ERAY_FRFM_MFID_SHIFT	2
+
+/* MRC */
+#define ERAY_MRC_FDB_MASK	(0xff << 0)
+#define ERAY_MRC_FDB_SHIFT	0
+#define ERAY_MRC_FFB_MASK	(0xff << 8)
+#define ERAY_MRC_FFB_SHIFT	8
+#define ERAY_MRC_LCB_MASK	(0xff << 16)
+#define ERAY_MRC_LCB_SHIFT	16
+#define ERAY_MRC_SEC_MASK	(0x03 << 24)
+#define ERAY_MRC_SEC_SHIFT	24
+#define ERAY_MRC_SPLM_MASK	(0x01 << 26)
+#define ERAY_MRC_SPLM_SHIFT	26
+
+#define ERAY_MAX_BUFS		128
+#define ERAY_MAX_BUFS_SSYNC	2
+#define ERAY_MAX_MEM		2048
+
+#define ERAY_MSGBUF_CFG_LEN	4
+
+#define ERAY_FIFO_THRESHOLD	5
+
+enum eray_msgbuf_type {
+	eray_msgbuf_type_none,
+	eray_msgbuf_type_fifo,
+	eray_msgbuf_type_rx,
+	eray_msgbuf_type_tx,
+};
+
+enum eray_msgbuf_channel {
+	eray_msgbuf_ch_none,
+	eray_msgbuf_ch_a,
+	eray_msgbuf_ch_b,
+	eray_msgbuf_ch_both,
+};
+
+struct eray_msgbuf_cfg {
+	u32 flags;
+	u8 id;
+	u8 cyc;
+	u16 len;
+	u16 max;
+	u16 start;
+	u32 frame_id;
+	u32 reject_mask;
+	u32 wrhs1;
+	u32 wrhs2;
+	u32 wrhs3;
+	enum eray_msgbuf_type type;
+	enum eray_msgbuf_channel channel;
+	u8 queued;
+	u8 tx_cont_len;
+	unsigned char tx_cont_data[256];
+	spinlock_t lock;
+} __packed;
+
+struct eray_cc {
+	struct eray_msgbuf_cfg cfg[ERAY_MAX_BUFS];
+	DECLARE_BITMAP(memmap, ERAY_MAX_MEM);
+	u8 rev_id[ERAY_MAX_BUFS];
+	int act_cfg;
+	int sync_start;
+	struct eray_msgbuf_cfg sync_cfg;
+	int sync_num;
+	int ssync_start;
+	struct eray_msgbuf_cfg ssync_cfg[ERAY_MAX_BUFS_SSYNC];
+	int ssync_num;
+	int ready;
+	u16 fifo_len;
+	u8 fifo_threshold;
+	u16 static_id;
+	u8 static_len;
+	spinlock_t lock;
+	void __iomem *base;
+};
+
+static inline u32 eray_readl(struct eray_cc *cc, int offset)
+{
+	return readl(cc->base + offset);
+}
+
+static inline void eray_writel(u32 val, struct eray_cc *cc, int offset=
)
+{
+	writel(val, cc->base + offset);
+}
+
+static inline void eray_get_val8(u8 *val, struct eray_cc *cc, int offs=
et,
+				 u32 mask, u32 shift)
+{
+	u32 tmp;
+
+	tmp =3D eray_readl(cc, offset);
+	tmp &=3D mask;
+	tmp >>=3D shift;
+	*val =3D tmp & 0xff;
+}
+
+static inline void eray_get_val16(u16 *val, struct eray_cc *cc, int of=
fset,
+				  u32 mask, u32 shift)
+{
+	u32 tmp;
+
+	tmp =3D eray_readl(cc, offset);
+	tmp &=3D mask;
+	tmp >>=3D shift;
+	*val =3D tmp & 0xffff;
+}
+
+static inline void eray_get_val32(u32 *val, struct eray_cc *cc, int of=
fset,
+				  u32 mask, u32 shift)
+{
+	u32 tmp;
+
+	tmp =3D eray_readl(cc, offset);
+	tmp &=3D mask;
+	tmp >>=3D shift;
+	*val =3D tmp;
+}
+
+static inline void eray_chg_reg(u32 val, struct eray_cc *cc, int offse=
t,
+				u32 mask, u32 shift)
+{
+	u32 tmp;
+
+	tmp =3D eray_readl(cc, offset);
+	tmp &=3D ~mask;
+	tmp |=3D (val << shift) & mask;
+	writel(tmp, cc->base + offset);
+}
+
+static inline void eray_mask_reg(u32 *val, struct eray_cc *cc, int off=
set,
+				 u32 mask, u32 shift)
+{
+	u32 tmp;
+
+	tmp =3D eray_readl(cc, offset);
+	*val =3D (tmp & mask) >> shift;
+}
+
+static inline int eray_read_succ1(struct eray_cc *cc, int retry)
+{
+	/* SUCC1 use only 31 bit */
+	u32 succ1, i;
+
+	for (i =3D 0; i < retry; i++) {
+		succ1 =3D eray_readl(cc, ERAY_SUCC1);
+
+		if (!(succ1 & ERAY_SUCC1_PBSY_MASK))
+			return succ1;
+
+		udelay(10);
+	}
+
+	return -EBUSY;
+}
+
+static inline int eray_wait_clear(struct eray_cc *cc, u32 reg, u32 mas=
k,
+				  int retry)
+{
+	int i;
+
+	for (i =3D 0; i < retry; i++) {
+		if (!(eray_readl(cc, reg) & mask))
+			return 0;
+
+		udelay(5);
+	}
+
+	return -EBUSY;
+}
+
+static inline int eray_wait_for_obsys(struct eray_cc *cc, int retry)
+{
+	return eray_wait_clear(cc, ERAY_OBCR, ERAY_OBCR_OBSYS_MASK, retry);
+}
+
+#endif
diff --git a/include/linux/flexcard.h b/include/linux/flexcard.h
new file mode 100644
index 0000000..1a4ec8b
--- /dev/null
+++ b/include/linux/flexcard.h
@@ -0,0 +1,95 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef LINUX_FLEXCARD_H
+#define LINUX_FLEXCARD_H
+
+#include <linux/types.h>
+#include <uapi/linux/flexcard.h>
+
+#define PCI_VENDOR_ID_EBEL	0x1974
+#define PCI_DEVICE_ID_FC_PMC2	0x0009
+
+#define FC_MAX_CC		8
+#define FC_DMA_BUF_SIZE		0x200000
+#define FC_DMA_BUF_MASK		(FC_DMA_BUF_SIZE - 1)
+#define FC_DMA_INFO_SPACE	0x1000
+#define FC_MAX_PAKET_SIZE	0x200
+#define FC_MAX_XFER_SIZE	(FC_DMA_BUF_SIZE - FC_MAX_PAKET_SIZE)
+#define FC_CARRY_OFFSET		0x20
+
+#define FC_CANIF_OFFSET		0x20
+
+/* IRQ */
+#define FC_IRQ_BANK1_NR	14
+#define FC_IRQ_BANK2_NR	18
+#define FC_IRQ_BANK3_NR	22
+#define FC_IRQ_BANK4_NR	30
+#define NR_FC_INTS	FC_IRQ_BANK4_NR
+
+/* offset */
+#define FC_IRQ_CC3CYCS_OFF	0
+#define FC_IRQ_CC4CYCS_OFF	1
+#define FC_IRQ_WAKE4A_OFF	2
+#define FC_IRQ_WAKE4B_OFF	3
+#define FC_IRQ_WAKE3A_OFF	4
+#define FC_IRQ_WAKE3B_OFF	5
+#define FC_IRQ_WAKE2A_OFF	6
+#define FC_IRQ_WAKE2B_OFF	7
+#define FC_IRQ_WAKE1A_OFF	8
+#define FC_IRQ_WAKE1B_OFF	9
+#define FC_IRQ_TIMER_OFF	10
+#define FC_IRQ_CC1CYCS_OFF	11
+#define FC_IRQ_CC2CYCS_OFF	12
+/* Flexcard IRQ 13 is not in use */
+
+#define FC_IRQ_CC1T0_OFF	14
+#define FC_IRQ_CC2T0_OFF	15
+#define FC_IRQ_CC3T0_OFF	16
+#define FC_IRQ_CC4T0_OFF	17
+
+/* DMA */
+#define FC_IRQ_DMA_CO_OFF	18
+#define FC_IRQ_DMA_TE_OFF	19
+#define FC_IRQ_DMA_TI_OFF	20
+#define FC_IRQ_DMA_CBL_OFF	21
+
+/* virt. DMA IRQ */
+#define FC_IRQ_DMA_RX_OFF(irq)	(FC_IRQ_BANK3_NR + irq)
+
+/* self sync register offset */
+#define FC_SSYNC_OFFSET		0x800
+#define FC_SSYNC_TXACK_OFFSET	0x200
+
+struct fc_priv {
+	raw_spinlock_t irq_lock;
+	struct pci_dev *dev;
+	void __iomem *conf;
+	void __iomem *mmio;
+	int nrdcan;
+	int nreray;
+	int card_nr;
+	int irq_start;
+	struct mfd_cell *dcan;
+	struct mfd_cell *eray;
+
+#ifdef CONFIG_MFD_EBEL_FLEXCARD_DMA_POLL
+	u32 active;
+	struct hrtimer timer;
+	int dma_on_irq;
+#endif
+};
+
+struct fc_irq_tab {
+	u32 enable;
+	u32 reset;
+	u32 status;
+};
+
+u32 fc_get_packet_len(u32 header);
+int fc_register_rx_pkt(int cc, void *priv,
+		int (*rx_cb) (void *priv, void *data, size_t len));
+void fc_unregister_rx_pkt(int cc);
+
+#endif
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 997f9f2..8d2be7a 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -106,6 +106,7 @@ header-y +=3D elf-em.h
 header-y +=3D elf-fdpic.h
 header-y +=3D elf.h
 header-y +=3D elfcore.h
+header-y +=3D eray.h
 header-y +=3D errno.h
 header-y +=3D errqueue.h
 header-y +=3D ethtool.h
@@ -123,6 +124,7 @@ header-y +=3D filter.h
 header-y +=3D firewire-cdev.h
 header-y +=3D firewire-constants.h
 header-y +=3D flat.h
+header-y +=3D flexcard.h
 header-y +=3D fs.h
 header-y +=3D fsl_hypervisor.h
 header-y +=3D fuse.h
diff --git a/include/uapi/linux/eray.h b/include/uapi/linux/eray.h
new file mode 100644
index 0000000..9d03cfd
--- /dev/null
+++ b/include/uapi/linux/eray.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef UAPI_LINUX_ERAY_H
+#define UAPI_LINUX_ERAY_H
+
+/* The lower 16 bit in message buffer flags are reserved for eray */
+#define ERAY_MSGBUF_USED		0x0001
+#define ERAY_MSGBUF_STARTUP		0x0002
+#define ERAY_MSGBUF_SYNC		0x0004
+#define ERAY_MSGBUF_PPIT		0x0008
+#define ERAY_MSGBUF_TXCONT		0x0010
+#define ERAY_MSGBUF_FIFOREJ_NULL	0x0020
+#define ERAY_MSGBUF_FIFOREJ_INSEG	0x0040
+#define ERAY_MSGBUF_FLAGS_END		0x8000
+
+enum eray_cc_state {
+	ERAY_CMD_INVALID,
+	ERAY_CMD_CONFIG,
+	ERAY_CMD_READY,
+	ERAY_CMD_WAKEUP,
+	ERAY_CMD_RUN,
+	ERAY_CMD_ALL_SLOTS,
+	ERAY_CMD_HALT,
+	ERAY_CMD_FREEZE,
+	ERAY_CMD_SEND_MTS,
+	ERAY_CMD_ALLOW_COLDSTART,
+	ERAY_CMD_RESET_STATUS_INDICATORS,
+	ERAY_CMD_MONITOR_MODE,
+	ERAY_CMD_CLEAR_RAMS,
+};
+
+#endif
diff --git a/include/uapi/linux/flexcard.h b/include/uapi/linux/flexcar=
d.h
new file mode 100644
index 0000000..a48806a
--- /dev/null
+++ b/include/uapi/linux/flexcard.h
@@ -0,0 +1,429 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef UAPI_LINUX_FLEXCARD_H
+#define UAPI_LINUX_FLEXCARD_H
+
+#include <linux/types.h>
+
+/* BAR0 memory map */
+#define FC_FC_FW_VER	0x004
+#define FC_FC_HW_VER	0x008
+#define FC_FC_SN	0x018
+#define FC_FC_UID	0x020
+#define FC_FC_LIC0	0x040
+#define FC_FC_LIC1	0x044
+#define FC_FC_LIC2	0x048
+#define FC_FC_LIC3	0x04c
+#define FC_FC_LIC4	0x050
+#define FC_FC_LIC5	0x054
+#define FC_FC_SLIC0	0x058
+#define FC_FC_SLIC1	0x05c
+#define FC_FC_SLIC2	0x060
+#define FC_FC_SLIC3	0x064
+#define FC_FC_SLIC4	0x068
+#define FC_FC_SLIC5	0x06c
+#define FC_TRIG_CTRL1	0x070
+#define FC_TRIG_CTRL2	0x078
+#define FC_AMREG	0x0d4
+#define FC_TINY_STAT	0x0d8
+#define FC_FC_DATA_CNT	0x0f8
+#define FC_FC_ROCR	0x100
+#define FC_PL_TERM	0x10c
+#define FC_ISR		0x114
+#define FC_IER		0x11c
+#define FC_FC_TS	0x140
+#define FC_FC_RESET	0x144
+#define FC_TRIG_SC_CTRL	0x148
+#define FC_CTRL		0x14c
+#define FC_TIRQIR	0x154
+#define FC_FC_NFCTRL	0x170
+#define FC_NF_CNT	0x174
+
+#define FC_DMA_CTRL	0x500
+#define FC_DMA_STAT	0x504
+#define FC_DMA_CBAL	0x510
+#define FC_DMA_CBAH	0x514
+#define FC_DMA_CBS	0x518
+#define FC_DMA_TXR	0x51c
+#define FC_DMA_IRER	0x520
+#define FC_DMA_IRSR	0x524
+#define FC_DMA_CBCR	0x550
+#define FC_DMA_CBLR	0x554
+#define FC_DMA_ITCR	0x560
+#define FC_DMA_ITR	0x564
+#define FC_DMA_WPTR	0x570
+#define FC_DMA_RPTR	0x574
+
+#define FC_RXFILTID	0x780
+#define FC_RXFILTCH	0x784
+
+#define FC_TXFILTID	0x788
+#define FC_TXFILTCH	0x78C
+
+#define FC_ACTIMG	0xa10
+#define FC_UPDIMGINF	0xa14
+
+#define FC_COOV		0x80000000
+#define FC_RST_FR	0x00000001
+#define FC_RST_FC	0x40000000
+#define FC_RST_TS	0x00008000
+
+#define FC_FC_RESET_OFF	0x5bc
+
+#define FC_LIC0_FLEXRAY_MASK		0x000f
+#define FC_LIC0_FLEXRAY_SHIFT		0
+#define FC_LIC0_CAN_MASK		0x00f0
+#define FC_LIC0_CAN_SHIFT		4
+#define FC_LIC0_SELFSYNC_MASK		0x0f00
+#define FC_LIC0_SELFSYNC_SHIFT		8
+
+#define FC_SLIC0_FLEXRAY_MASK		0x000f
+#define FC_SLIC0_FLEXRAY_SHIFT		0
+#define FC_SLIC0_CAN_MASK		0x00f0
+#define FC_SLIC0_CAN_SHIFT		4
+#define FC_SLIC0_SELFSYNC_MASK		0x0f00
+#define FC_SLIC0_SELFSYNC_SHIFT		8
+
+#define FC_LIC5_LINUX_MASK		(1 << 31)
+#define FC_LIC5_LINUX_SHIFT		31
+#define FC_LIC5_XENOMAI_MASK		(1 << 30)
+#define FC_LIC5_XENOMAI_SHIFT		30
+#define FC_LIC5_WINDOWS_MASK		(1 << 29)
+#define FC_LIC5_WINDOWS_SHIFT		29
+#define FC_LIC5_LABVIEW_MASK		(1 << 28)
+#define FC_LIC5_LABVIEW_SHIFT		28
+
+#define FC_DMA_TXR_TX_ENA		0x80000000
+
+#define FC_DMA_CTRL_DMA_ENA (1 << 0)
+#define FC_DMA_CTRL_MAN_ENA (1 << 1)
+#define FC_DMA_CTRL_STOP_REQ (1 << 16)
+#define FC_DMA_CTRL_DMA_IDLE (1 << 17)
+#define FC_DMA_CTRL_RST_DMA (1 << 31)
+
+#define FC_DMA_IRER_DIRE (1 << 31)
+
+#define FC_ISR_CC1T0IRQ (1 << 31)
+#define FC_ISR_CC2T0IRQ (1 << 3)
+#define FC_ISR_CC3T0IRQ (1 << 24)
+#define FC_ISR_CC4T0IRQ (1 << 20)
+
+#define FC_DMA_IRSR_COISR (1 << 0)
+#define FC_DMA_IRSR_TEISR (1 << 1)
+#define FC_DMA_IRSR_TISR (1 << 4)
+#define FC_DMA_IRSR_CBLISR (1 << 5)
+
+#define FC_DMA_STAT_DMA_DSTAT_BUSY (1 << 15)
+#define FC_DMA_STAT_OFL (1 << 31)
+
+#define FC_BUFFER_INFO_TABLE		0x1000
+#define FC_BUF_INFO_ENABLE_PAYLOAD	(1 << 28)
+#define FC_BUF_INFO_ENABLE_NULLFRAMES	(1 << 27)
+#define FC_BUF_INFO_IS_TX		(1 << 13)
+#define FC_BUF_INFO_CYC_SHIFT		14
+#define FC_BUF_INFO_CHANNEL_SHIFT	11
+#define FC_BUF_HEADER_LEN_SHIFT		15
+#define FC_BUF_HEADER_LEN_MASK		0xfe
+
+/* message buffer ID flag for self sync */
+#define FC_FLEX_ID_SSYNC_FLAG	0x80000000
+
+/* FlexCard CAN TX fifo */
+#define FC_TXFIFO_MO		127
+
+#define FC_TXFIFO_FLAG		(1 << 7)
+#define FC_TXACKOFF_FLAG	(1 << 6)
+#define FC_TXFIFO_DLC_MASK	0xf
+#define FC_TXFIFO_SFF_SHIFT	16
+
+#define FC_TXFIFO_MSGID		0x800
+#define FC_TXFIFO_MSGID_STDID	0x1FFC0000
+#define FC_TXFIFO_MSGID_STDID_SHIFT	18
+#define FC_TXFIFO_MSGID_EXTID	0x1FFFFFFF
+#define FC_TXFIFO_MSGID_EXT	(1 << 30)
+
+#define FC_TXFIFO_MSGCTRL	0x804
+
+#define FC_TXFIFO_MSGDA		0x808
+#define FC_TXFIFO_MSGDB		0x80c
+
+#define FC_TXFIFO_CONF		0x820
+#define FC_TXFIFO_CONF_MO_MASK	0xff
+#define FC_TXFIFO_CONF_TXACK	(1 << 16)
+#define FC_TXFIFO_CONF_EAR	(1 << 17)
+#define FC_TXFIFO_CONF_EN	(1 << 31)
+
+#define FC_TXFIFO_STAT		0x824
+#define FC_TXFIFO_STAT_FULL	(1 << 9)
+#define FC_TXFIFO_STAT_EMPTY	(1 << 31)
+
+#define FC_TXFIFO_CTRL		0x828
+#define FC_TXFIFO_CTRL_REQ	(1 << 0)
+#define FC_TXFIFO_CTRL_CLEAR	(1 << 31)
+
+#define FC_TXFIFO_TIMER		0x830
+
+struct fc_conf_bar {
+	__u32 r1;			/* 000 */
+	__u32 fc_fw_ver;		/* 004 */
+	__u32 fc_hw_ver;		/* 008 */
+	__u32 r2[3];			/* 00c */
+	__u64 fc_sn;			/* 018 */
+	__u32 fc_uid;			/* 020 */
+	__u32 r3[7];			/* 024 */
+	__u32 fc_lic[6];		/* 040 */
+	__u32 fc_slic[6];		/* 058 */
+	__u32 trig_ctrl1;		/* 070 */
+	__u32 r4;			/* 074 */
+	__u32 trig_ctrl2;		/* 078 */
+	__u32 r5[22];			/* 07c */
+	__u32 amreg;			/* 0d4 */
+	__u32 tiny_stat;		/* 0d8 */
+	__u32 r6[5];			/* 0dc */
+	__u32 can_dat_cnt;		/* 0f0 */
+	__u32 can_err_cnt;		/* 0f4 */
+	__u32 fc_data_cnt;		/* 0f8 */
+	__u32 r7;			/* 0fc */
+	__u32 fc_rocr;			/* 100 */
+	__u32 r8;			/* 104 */
+	__u32 pg_ctrl;			/* 108 */
+	__u32 pg_term;			/* 10c */
+	__u32 r9;			/* 110 */
+	__u32 irs;			/* 114 */
+	__u32 fr_tx_cnt;		/* 118 */
+	__u32 irc;			/* 11c */
+	__u64 pcnt;			/* 120 */
+	__u32 r10;			/* 128 */
+	__u32 nmv_cnt;			/* 12c */
+	__u32 info_cnt;			/* 130 */
+	__u32 stat_trg_cnt;		/* 134 */
+	__u32 r11;			/* 138 */
+	__u32 fr_rx_cnt;		/* 13c */
+	__u32 fc_ts;			/* 140 */
+	__u32 fc_reset;			/* 144 */
+	__u32 trig_sc_ctrl;		/* 148 */
+	__u32 trig_ctrl;		/* 14c */
+	__u32 r12;			/* 150 */
+	__u32 tirqir;			/* 154 */
+	__u32 pccr1;			/* 158 */
+	__u32 pccr2;			/* 15c */
+	__u32 r13[4];			/* 160 */
+	__u32 fc_nfctrl;		/* 170 */
+	__u32 nf_cnt;			/* 174 */
+	__u32 r14;			/* 178 */
+	__u32 pl_ctrl;			/* 17c */
+	__u32 r15[0xe0];		/* 180 */
+	__u32 dma_ctrl;			/* 500 */
+	__u32 dma_stat;			/* 504 */
+	__u32 r16[2];			/* 508 */
+	__u64 dma_cba;			/* 510 */
+	__u32 dma_cbs;			/* 518 */
+	__u32 dma_txr;			/* 51c */
+	__u32 dma_irer;			/* 520 */
+	__u32 dma_irsr;			/* 524 */
+	__u32 r17[10];			/* 528 */
+	__u32 dma_cbcr;			/* 550 */
+	__u32 dma_cblr;			/* 554 */
+	__u32 r18[2];			/* 558 */
+	__u32 dma_itcr;			/* 560 */
+	__u32 dma_itr;			/* 564 */
+	__u32 r19[2];			/* 568 */
+	__u32 dma_wptr;			/* 570 */
+	__u32 dma_rptr;			/* 574 */
+	__u32 r20[0xe2];		/* 578 */
+	__u32 faddr;			/* 900 */
+	__u32 fwdat;			/* 904 */
+	__u32 fctrl;			/* 908 */
+	__u32 frdat;			/* 90c */
+	__u32 bwdat[16];		/* 910 */
+	__u32 brdat[16];		/* 950 */
+	__u32 r21[28];			/* 990 */
+	__u32 fwmode;			/* a00 */
+	__u32 recond;			/* a04 */
+	__u32 wdtctrl;			/* a08 */
+	__u32 imgsel;			/* a0c */
+	__u32 actimg;			/* a10 */
+	__u32 updimginf;		/* a14 */
+	__u32 r22[0x32];		/* a18 */
+	__u32 factory_image_info[8];	/* ae0 */
+	__u32 app_image0_info[8];	/* b00 */
+	__u32 app_image1_info[8];	/* b20 */
+	__u32 app_image2_info[8];	/* b40 */
+	__u32 app_image3_info[8];	/* b60 */
+	__u32 app_image4_info[8];	/* b80 */
+	__u32 app_image5_info[8];	/* ba0 */
+	__u32 app_image6_info[8];	/* bc0 */
+	__u32 app_image7_info[8];	/* be0 */
+	__u32 r23[0x100];		/* c00 */
+} __packed;
+
+enum fc_packet_type {
+	fc_packet_type_info =3D 1,
+	fc_packet_type_flexray_frame =3D 2,
+	fc_packet_type_error =3D 3,
+	fc_packet_type_status =3D 4,
+	fc_packet_type_trigger =3D 5,
+	fc_packet_type_tx_ack =3D 6,
+	fc_packet_type_nmv_vector =3D 7,
+	fc_packet_type_notification =3D 8,
+	fc_packet_type_trigger_ex =3D 9,
+	fc_packet_type_can =3D 10,
+	fc_packet_type_can_error =3D 11,
+};
+
+struct fc_packet {
+	__u32 type;
+	__u32 p_packet;
+	__u32 p_next_packet;
+} __packed;
+
+struct fc_info_packet {
+	__u32 current_cycle;
+	__u32 timestamp;
+	__u32 offset_rate_correction;
+	__u32 pta_ccf_count;
+	__u32 cc;
+} __packed;
+
+struct fc_flexray_frame {
+	__u32 header;
+	__u32 header_crc;
+	__u32 pdata;
+	__u32 channel;
+	__u32 frame_crc;
+	__u32 timestamp;
+	__u32 cc;
+} __packed;
+
+struct fc_error_packet {
+	__u32 flag;
+	__u32 timestamp;
+	__u32 cycle_count;
+	__u64 additional_info;
+	__u32 cc;
+	__u32 reserved;
+} __packed;
+
+struct fc_status_packet {
+	__u32 flag;
+	__u32 timestamp;
+	__u32 cycle_count;
+	__u32 additional_info;
+	__u32 cc;
+	__u32 reserved[2];
+} __packed;
+
+struct fc_tx_ack_packet {
+	__u32 bufferid;
+	__u32 timestamp;
+	__u32 cycle_count;
+	__u32 header;
+	__u32 header_crc;
+	__u32 pdata;
+	__u32 channel;
+	__u32 cc;
+} __packed;
+
+struct fc_nm_vector_packet {
+	__u32 timestamp;
+	__u32 cycle_count;
+	__u32 nmv_vector_length;
+	__u32 nmv_vector[3];
+	__u32 cc;
+	__u32 reserved;
+} __packed;
+
+struct fc_notification_packet {
+	__u32 timestamp;
+	__u32 sequence_count;
+	__u32 reserved;
+} __packed;
+
+struct fc_trigger_ex_info_packet {
+	__u32 condition;
+	__u32 timestamp;
+	__u32 sequence_count;
+	__u32 reserved1;
+	__u64 performance_counter;
+	__u32 edge;
+	__u32 trigger_line;
+	__u32 reserved[4];
+} __packed;
+
+struct fc_can_packet {
+	__u32 id;
+	__u32 timestamp;
+	__u32 flags;
+	__u32 reserved;
+	__u32 cc;
+	__u8 data[8];
+} __packed;
+
+struct fc_can_error_packet {
+	__u32 type;
+	__u32 state;
+	__u32 timestamp;
+	__u32 rx_error_counter;
+	__u32 tx_error_counter;
+	__u32 cc;
+	__u32 reserved[2];
+} __packed;
+
+enum fc_can_cc_state {
+	fc_can_state_unknown =3D 0,
+	fc_can_state_config,
+	fc_can_state_normalActive,
+	fc_can_state_warning,
+	fc_can_state_error_passive,
+	fc_can_state_bus_off,
+};
+
+enum fc_can_error_type {
+	fc_can_error_none =3D 0,
+	fc_can_error_stuff,
+	fc_can_error_form,
+	fc_can_error_acknowledge,
+	fc_can_error_bit1,
+	fc_can_error_bit0,
+	fc_can_error_crc,
+	fc_can_error_parity,
+};
+
+union fc_packet_types {
+	struct fc_info_packet		info_packet;
+	struct fc_flexray_frame		flexray_frame;
+	struct fc_error_packet		error_packet;
+	struct fc_status_packet		status_packet;
+	struct fc_tx_ack_packet		tx_ack_packet;
+	struct fc_nm_vector_packet	nm_vector_packet;
+	struct fc_notification_packet	notification_packet;
+	struct fc_trigger_ex_info_packet ex_info_packet;
+	struct fc_can_packet		can_packet;
+	struct fc_can_error_packet	can_error_packet;
+};
+
+struct fc_packet_buf {
+	struct	fc_packet	header;
+	union	fc_packet_types	packet;
+} __packed;
+
+enum fc_clksrc_type {
+	FC_CLK_INTERNAL_1MHZ =3D 0x0,
+	FC_CLK_INTERNAL_10MHZ =3D 0x1,
+	FC_CLK_INTERNAL_100MHZ =3D 0x2,
+	FC_CLK_INTERNAL_TRIGGER1 =3D 0x11,
+	FC_CLK_INTERNAL_TRIGGER2 =3D 0x12,
+};
+
+struct fc_clksrc {
+	enum fc_clksrc_type type;
+	__u32 freq;
+	__u32 mul;
+};
+
+#define FCGCLKSRC	_IOR(0xeb, 0, struct fc_clksrc)
+#define FCSCLKSRC	_IOW(0xeb, 1, struct fc_clksrc)
+
+#endif
--=20
1.8.4.rc2
