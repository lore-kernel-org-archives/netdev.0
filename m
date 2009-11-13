From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Fri, 13 Nov 2009 17:14:52 +0100
Message-ID: <1258128892-28800-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Taken from socketcan-svn, fixed remaining todos, cleaned up, tested with a
phyCORE-MPC5200B-IO and a custom board.

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---

This patch is based on net-next as of yesterday.

To make the review easier for those who are already familiar with earlier
versions of this driver (especially for Wolfgang), I put my development branch
online, so you can check my changes incrementally:

http://git.pengutronix.de/?p=wsa/linux-2.6.git;a=summary

 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +
 drivers/net/can/Kconfig                            |   19 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/mscan/Makefile                     |    5 +
 drivers/net/can/mscan/mpc52xx_can.c                |  279 ++++++++
 drivers/net/can/mscan/mscan.c                      |  699 ++++++++++++++++++++
 drivers/net/can/mscan/mscan.h                      |  262 ++++++++
 7 files changed, 1274 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/mscan/Makefile
 create mode 100644 drivers/net/can/mscan/mpc52xx_can.c
 create mode 100644 drivers/net/can/mscan/mscan.c
 create mode 100644 drivers/net/can/mscan/mscan.h

diff --git a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
index 8447fd7..b151fb1 100644
--- a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
@@ -178,3 +178,12 @@ External interrupts:
 	external irq3:	interrupts = <1 3 n>;
 'n' is sense (0: level high, 1: edge rising, 2: edge falling 3: level low)
 
+fsl,mpc5200-mscan nodes
+-----------------------
+In addition to the required compatible-, reg- and interrupt-properites, you can
+also specify which clock shall be used for the bus:
+
+- fsl,mscan-clk-src	- a string describing the clock source. Valid values
+			  are "ip" for IP_CLK and "sys" for SYS_XTAL.
+			  "sys" is the default in case the property is not
+			  present.
diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index b819cc2..c16e6ff 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -108,6 +108,25 @@ config CAN_MCP251X
 	---help---
 	  Driver for the Microchip MCP251x SPI CAN controllers.
 
+config CAN_MSCAN
+	depends on CAN_DEV && (PPC || M68K || M68KNOMMU)
+	tristate "Support for Freescale MSCAN based chips"
+	---help---
+	  The Motorola Scalable Controller Area Network (MSCAN) definition
+	  is based on the MSCAN12 definition which is the specific
+	  implementation of the Motorola Scalable CAN concept targeted for
+	  the Motorola MC68HC12 Microcontroller Family.
+
+config CAN_MPC52XX
+	tristate "Freescale MPC5xxx onboard CAN controller"
+	depends on CAN_MSCAN && PPC_MPC52xx
+	---help---
+	  If you say yes here you get support for Freescale's MPC52xx
+	  onboard dualCAN controller.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called mpc5xxx_can.
+
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 1489181..56899fe 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -10,6 +10,7 @@ can-dev-y			:= dev.o
 obj-y				+= usb/
 
 obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
+obj-$(CONFIG_CAN_MSCAN)		+= mscan/
 obj-$(CONFIG_CAN_AT91)		+= at91_can.o
 obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
diff --git a/drivers/net/can/mscan/Makefile b/drivers/net/can/mscan/Makefile
new file mode 100644
index 0000000..2bd9f04
--- /dev/null
+++ b/drivers/net/can/mscan/Makefile
@@ -0,0 +1,5 @@
+
+obj-$(CONFIG_CAN_MPC52XX)	+= mscan-mpc52xx.o
+mscan-mpc52xx-objs		:= mscan.o mpc52xx_can.o
+
+ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/mscan/mpc52xx_can.c b/drivers/net/can/mscan/mpc52xx_can.c
new file mode 100644
index 0000000..4707a82
--- /dev/null
+++ b/drivers/net/can/mscan/mpc52xx_can.c
@@ -0,0 +1,279 @@
+/*
+ * CAN bus driver for the Freescale MPC5xxx embedded CPU.
+ *
+ * Copyright (C) 2004-2005 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
+ *                         Varma Electronics Oy
+ * Copyright (C) 2008-2009 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
+ * Copyright (C) 2009 Wolfram Sang, Pengutronix <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/of_platform.h>
+#include <sysdev/fsl_soc.h>
+#include <linux/io.h>
+#include <asm/mpc52xx.h>
+
+#include "mscan.h"
+
+
+#define DRV_NAME "mpc5xxx_can"
+
+static struct of_device_id mpc52xx_cdm_ids[] __devinitdata = {
+	{ .compatible = "fsl,mpc5200-cdm", },
+	{ .compatible = "fsl,mpc5200b-cdm", },
+	{}
+};
+
+/*
+ * Get the frequency of the external oscillator clock connected
+ * to the SYS_XTAL_IN pin, or return 0 if it cannot be determined.
+ */
+static unsigned int  __devinit mpc52xx_can_xtal_freq(struct of_device *of)
+{
+	struct mpc52xx_cdm  __iomem *cdm;
+	struct device_node *np_cdm;
+	unsigned int freq;
+	u32 val;
+
+	freq = mpc5xxx_get_bus_frequency(of->node);
+	if (!freq)
+		return 0;
+
+	/*
+	 * Determine SYS_XTAL_IN frequency from the clock domain settings
+	 */
+	np_cdm = of_find_matching_node(NULL, mpc52xx_cdm_ids);
+	if (!np_cdm) {
+		dev_err(&of->dev, "can't get clock node!\n");
+		return 0;
+	}
+	cdm = of_iomap(np_cdm, 0);
+	of_node_put(np_cdm);
+
+	if (in_8(&cdm->ipb_clk_sel) & 0x1)
+		freq *= 2;
+	val  = in_be32(&cdm->rstcfg);
+	if (val & (1 << 5))
+		freq *= 8;
+	else
+		freq *= 4;
+	if (val & (1 << 6))
+		freq /= 12;
+	else
+		freq /= 16;
+
+	iounmap(cdm);
+
+	return freq;
+}
+
+/*
+ * Get frequency of the MSCAN clock source
+ *
+ * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock (IP_CLK)
+ * can be selected. According to the MPC5200 user's manual, the oscillator
+ * clock is the better choice as it has less jitter but due to a hardware
+ * bug, it can not be selected for the old MPC5200 Rev. A chips.
+ */
+
+static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
+						      int clock_src)
+{
+	unsigned int pvr;
+
+	pvr = mfspr(SPRN_PVR);
+
+	if (clock_src == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
+		return mpc5xxx_get_bus_frequency(of->node);
+
+	return mpc52xx_can_xtal_freq(of);
+}
+
+static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
+				       const struct of_device_id *id)
+{
+	struct device_node *np = ofdev->node;
+	struct net_device *dev;
+	struct mscan_priv *priv;
+	void __iomem *base;
+	const char *clk_src;
+	int err, irq, clock_src;
+
+	base = of_iomap(ofdev->node, 0);
+	if (!base) {
+		dev_err(&ofdev->dev, "couldn't ioremap\n");
+		err = -ENOMEM;
+		goto exit_release_mem;
+	}
+
+	irq = irq_of_parse_and_map(np, 0);
+	if (!irq) {
+		dev_err(&ofdev->dev, "no irq found\n");
+		err = -ENODEV;
+		goto exit_unmap_mem;
+	}
+
+	dev = alloc_mscandev();
+	if (!dev) {
+		err = -ENOMEM;
+		goto exit_dispose_irq;
+	}
+
+	priv = netdev_priv(dev);
+	priv->reg_base = base;
+	dev->irq = irq;
+
+	/*
+	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
+	 * (IP_CLK) can be selected as MSCAN clock source. According to
+	 * the MPC5200 user's manual, the oscillator clock is the better
+	 * choice as it has less jitter. For this reason, it is selected
+	 * by default.
+	 */
+	clk_src = of_get_property(np, "fsl,mscan-clk-src", NULL);
+	if (clk_src && strcmp(clk_src, "ip") == 0)
+		clock_src = MSCAN_CLKSRC_BUS;
+	else
+		clock_src = MSCAN_CLKSRC_XTAL;
+	priv->can.clock.freq = mpc52xx_can_clock_freq(ofdev, clock_src);
+	if (!priv->can.clock.freq) {
+		dev_err(&ofdev->dev, "couldn't get MSCAN clock frequency\n");
+		err = -ENODEV;
+		goto exit_free_mscan;
+	}
+
+	SET_NETDEV_DEV(dev, &ofdev->dev);
+
+	err = register_mscandev(dev, clock_src);
+	if (err) {
+		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
+			DRV_NAME, err);
+		goto exit_free_mscan;
+	}
+
+	dev_set_drvdata(&ofdev->dev, dev);
+
+	dev_info(&ofdev->dev, "MSCAN at 0x%p, irq %d, clock %d Hz\n",
+		 priv->reg_base, dev->irq, priv->can.clock.freq);
+
+	return 0;
+
+exit_free_mscan:
+	free_candev(dev);
+exit_dispose_irq:
+	irq_dispose_mapping(irq);
+exit_unmap_mem:
+	iounmap(base);
+exit_release_mem:
+	return err;
+}
+
+static int __devexit mpc5xxx_can_remove(struct of_device *ofdev)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+
+	dev_set_drvdata(&ofdev->dev, NULL);
+
+	unregister_mscandev(dev);
+	iounmap(priv->reg_base);
+	irq_dispose_mapping(dev->irq);
+	free_candev(dev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static struct mscan_regs saved_regs;
+static int mpc5xxx_can_suspend(struct of_device *ofdev, pm_message_t state)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	_memcpy_fromio(&saved_regs, regs, sizeof(*regs));
+
+	return 0;
+}
+
+static int mpc5xxx_can_resume(struct of_device *ofdev)
+{
+	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	regs->canctl0 |= MSCAN_INITRQ;
+	while ((regs->canctl1 & MSCAN_INITAK) == 0)
+		udelay(10);
+
+	regs->canctl1 = saved_regs.canctl1;
+	regs->canbtr0 = saved_regs.canbtr0;
+	regs->canbtr1 = saved_regs.canbtr1;
+	regs->canidac = saved_regs.canidac;
+
+	/* restore masks, buffers etc. */
+	_memcpy_toio(&regs->canidar1_0, (void *)&saved_regs.canidar1_0,
+		     sizeof(*regs) - offsetof(struct mscan_regs, canidar1_0));
+
+	regs->canctl0 &= ~MSCAN_INITRQ;
+	regs->cantbsel = saved_regs.cantbsel;
+	regs->canrier = saved_regs.canrier;
+	regs->cantier = saved_regs.cantier;
+	regs->canctl0 = saved_regs.canctl0;
+
+	return 0;
+}
+#endif
+
+static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
+	{.compatible = "fsl,mpc5200-mscan"},
+	{.compatible = "fsl,mpc5200b-mscan"},
+	{},
+};
+
+static struct of_platform_driver mpc5xxx_can_driver = {
+	.owner = THIS_MODULE,
+	.name = "mpc5xxx_can",
+	.probe = mpc5xxx_can_probe,
+	.remove = __devexit_p(mpc5xxx_can_remove),
+#ifdef CONFIG_PM
+	.suspend = mpc5xxx_can_suspend,
+	.resume = mpc5xxx_can_resume,
+#endif
+	.match_table = mpc5xxx_can_table,
+};
+
+static int __init mpc5xxx_can_init(void)
+{
+	return of_register_platform_driver(&mpc5xxx_can_driver);
+}
+module_init(mpc5xxx_can_init);
+
+static void __exit mpc5xxx_can_exit(void)
+{
+	return of_unregister_platform_driver(&mpc5xxx_can_driver);
+};
+module_exit(mpc5xxx_can_exit);
+
+MODULE_AUTHOR("Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>");
+MODULE_DESCRIPTION("Freescale MPC5200 CAN driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
new file mode 100644
index 0000000..49542ca
--- /dev/null
+++ b/drivers/net/can/mscan/mscan.c
@@ -0,0 +1,699 @@
+/*
+ * CAN bus driver for the alone generic (as possible as) MSCAN controller.
+ *
+ * Copyright (C) 2005-2006 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
+ *                         Varma Electronics Oy
+ * Copyright (C) 2008-2009 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
+ * Copytight (C) 2008-2009 Pengutronix <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/list.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+#include <linux/io.h>
+
+#include "mscan.h"
+
+#define MSCAN_NORMAL_MODE	0
+#define MSCAN_SLEEP_MODE	MSCAN_SLPRQ
+#define MSCAN_INIT_MODE		(MSCAN_INITRQ | MSCAN_SLPRQ)
+#define MSCAN_POWEROFF_MODE	(MSCAN_CSWAI | MSCAN_SLPRQ)
+#define MSCAN_SET_MODE_RETRIES	255
+#define MSCAN_ECHO_SKB_MAX	3
+
+#define BTR0_BRP_MASK		0x3f
+#define BTR0_SJW_SHIFT		6
+#define BTR0_SJW_MASK		(0x3 << BTR0_SJW_SHIFT)
+
+#define BTR1_TSEG1_MASK 	0xf
+#define BTR1_TSEG2_SHIFT	4
+#define BTR1_TSEG2_MASK 	(0x7 << BTR1_TSEG2_SHIFT)
+#define BTR1_SAM_SHIFT  	7
+
+#define BTR0_SET_BRP(brp)	(((brp) - 1) & BTR0_BRP_MASK)
+#define BTR0_SET_SJW(sjw)	((((sjw) - 1) << BTR0_SJW_SHIFT) & \
+				 BTR0_SJW_MASK)
+
+#define BTR1_SET_TSEG1(tseg1)	(((tseg1) - 1) &  BTR1_TSEG1_MASK)
+#define BTR1_SET_TSEG2(tseg2)	((((tseg2) - 1) << BTR1_TSEG2_SHIFT) & \
+				 BTR1_TSEG2_MASK)
+#define BTR1_SET_SAM(sam)	((sam) ? 1 << BTR1_SAM_SHIFT : 0)
+
+static struct can_bittiming_const mscan_bittiming_const = {
+	.name = "mscan",
+	.tseg1_min = 4,
+	.tseg1_max = 16,
+	.tseg2_min = 2,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 64,
+	.brp_inc = 1,
+};
+
+struct mscan_state {
+	u8 mode;
+	u8 canrier;
+	u8 cantier;
+};
+
+#define F_RX_PROGRESS	0
+#define F_TX_PROGRESS	1
+#define F_TX_WAIT_ALL	2
+
+static enum can_state state_map[] = {
+	CAN_STATE_ERROR_ACTIVE,
+	CAN_STATE_ERROR_WARNING,
+	CAN_STATE_ERROR_PASSIVE,
+	CAN_STATE_BUS_OFF
+};
+
+static int mscan_set_mode(struct net_device *dev, u8 mode)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	int ret = 0;
+	int i;
+	u8 canctl1;
+
+	if (mode != MSCAN_NORMAL_MODE) {
+
+		if (priv->tx_active) {
+			/* Abort transfers before going to sleep */#
+			out_8(&regs->cantarq, priv->tx_active);
+			/* Suppress TX done interrupts */
+			out_8(&regs->cantier, 0);
+		}
+
+		canctl1 = in_8(&regs->canctl1);
+		if ((mode & MSCAN_SLPRQ) && (canctl1 & MSCAN_SLPAK) == 0) {
+			out_8(&regs->canctl0,
+			      in_8(&regs->canctl0) | MSCAN_SLPRQ);
+			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
+				if (in_8(&regs->canctl1) & MSCAN_SLPAK)
+					break;
+				udelay(100);
+			}
+			/*
+			 * The mscan controller will fail to enter sleep mode,
+			 * while there are irregular activities on bus, like
+			 * somebody keeps retransmitting. This behavior is
+			 * undocumented and seems to differ between mscan built
+			 * in mpc5200b and mpc5200. We proceed in that case,
+			 * since otherwise the slprq will be kept set and the
+			 * controller will get stuck. NOTE: INITRQ or CSWAI
+			 * will abort all active transmit actions, if still
+			 * any, at once.
+			 */
+			if (i >= MSCAN_SET_MODE_RETRIES)
+				dev_dbg(dev->dev.parent,
+					"device failed to enter sleep mode. "
+					"We proceed anyhow.\n");
+			else
+				priv->can.state = CAN_STATE_SLEEPING;
+		}
+
+		if ((mode & MSCAN_INITRQ) && (canctl1 & MSCAN_INITAK) == 0) {
+			out_8(&regs->canctl0,
+			      in_8(&regs->canctl0) | MSCAN_INITRQ);
+			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
+				if (in_8(&regs->canctl1) & MSCAN_INITAK)
+					break;
+			}
+			if (i >= MSCAN_SET_MODE_RETRIES)
+				ret = -ENODEV;
+		}
+		if (!ret)
+			priv->can.state = CAN_STATE_STOPPED;
+
+		if (mode & MSCAN_CSWAI)
+			out_8(&regs->canctl0,
+			      in_8(&regs->canctl0) | MSCAN_CSWAI);
+
+	} else {
+		canctl1 = in_8(&regs->canctl1);
+		if (canctl1 & (MSCAN_SLPAK | MSCAN_INITAK)) {
+			out_8(&regs->canctl0, in_8(&regs->canctl0) &
+			      ~(MSCAN_SLPRQ | MSCAN_INITRQ));
+			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
+				canctl1 = in_8(&regs->canctl1);
+				if (!(canctl1 & (MSCAN_INITAK | MSCAN_SLPAK)))
+					break;
+			}
+			if (i >= MSCAN_SET_MODE_RETRIES)
+				ret = -ENODEV;
+			else
+				priv->can.state = CAN_STATE_ERROR_ACTIVE;
+		}
+	}
+	return ret;
+}
+
+static int mscan_start(struct net_device *dev)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	u8 canrflg;
+	int err;
+
+	out_8(&regs->canrier, 0);
+
+	INIT_LIST_HEAD(&priv->tx_head);
+	priv->prev_buf_id = 0;
+	priv->cur_pri = 0;
+	priv->tx_active = 0;
+	priv->shadow_canrier = 0;
+	priv->flags = 0;
+
+	err = mscan_set_mode(dev, MSCAN_NORMAL_MODE);
+	if (err)
+		return err;
+
+	canrflg = in_8(&regs->canrflg);
+	priv->shadow_statflg = canrflg & MSCAN_STAT_MSK;
+	priv->can.state = state_map[max(MSCAN_STATE_RX(canrflg),
+				    MSCAN_STATE_TX(canrflg))];
+	out_8(&regs->cantier, 0);
+
+	/* Enable receive interrupts. */
+	out_8(&regs->canrier, MSCAN_OVRIE | MSCAN_RXFIE | MSCAN_CSCIE |
+	      MSCAN_RSTATE1 | MSCAN_RSTATE0 | MSCAN_TSTATE1 | MSCAN_TSTATE0);
+
+	return 0;
+}
+
+static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct can_frame *frame = (struct can_frame *)skb->data;
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	int i, rtr, buf_id;
+	u32 can_id;
+
+	if (frame->can_dlc > 8)
+		return -EINVAL;
+
+	out_8(&regs->cantier, 0);
+
+	i = ~priv->tx_active & MSCAN_TXE;
+	buf_id = ffs(i) - 1;
+	switch (hweight8(i)) {
+	case 0:
+		netif_stop_queue(dev);
+		dev_err(dev->dev.parent, "Tx Ring full when queue awake!\n");
+		return NETDEV_TX_BUSY;
+	case 1:
+		/*
+		 * if buf_id < 3, then current frame will be send out of order,
+		 * since buffer with lower id have higher priority (hell..)
+		 */
+		netif_stop_queue(dev);
+	case 2:
+		if (buf_id < priv->prev_buf_id) {
+			priv->cur_pri++;
+			if (priv->cur_pri == 0xff) {
+				set_bit(F_TX_WAIT_ALL, &priv->flags);
+				netif_stop_queue(dev);
+			}
+		}
+		set_bit(F_TX_PROGRESS, &priv->flags);
+		break;
+	}
+	priv->prev_buf_id = buf_id;
+	out_8(&regs->cantbsel, i);
+
+	rtr = frame->can_id & CAN_RTR_FLAG;
+
+	if (frame->can_id & CAN_EFF_FLAG) {
+		can_id = (frame->can_id & CAN_EFF_MASK) << 1;
+		if (rtr)
+			can_id |= 1;
+		out_be16(&regs->tx.idr3_2, can_id);
+
+		can_id >>= 16;
+		can_id = (can_id & 0x7) | ((can_id << 2) & 0xffe0) | (3 << 3);
+	} else {
+		can_id = (frame->can_id & CAN_SFF_MASK) << 5;
+		if (rtr)
+			can_id |= 1 << 4;
+	}
+	out_be16(&regs->tx.idr1_0, can_id);
+
+	if (!rtr) {
+		void __iomem *data = &regs->tx.dsr1_0;
+		u16 *payload = (u16 *) frame->data;
+		/* It is safe to write into dsr[dlc+1] */
+		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
+			out_be16(data, *payload++);
+			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
+		}
+	}
+
+	out_8(&regs->tx.dlr, frame->can_dlc);
+	out_8(&regs->tx.tbpr, priv->cur_pri);
+
+	/* Start transmission. */
+	out_8(&regs->cantflg, 1 << buf_id);
+
+	if (!test_bit(F_TX_PROGRESS, &priv->flags))
+		dev->trans_start = jiffies;
+
+	list_add_tail(&priv->tx_queue[buf_id].list, &priv->tx_head);
+
+	can_put_echo_skb(skb, dev, buf_id);
+
+	/* Enable interrupt. */
+	priv->tx_active |= 1 << buf_id;
+	out_8(&regs->cantier, priv->tx_active);
+
+	return NETDEV_TX_OK;
+}
+
+/* This function returns the old state to see where we came from */
+static enum can_state check_set_state(struct net_device *dev, u8 canrflg)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	enum can_state state, old_state = priv->can.state;
+
+	if (canrflg & MSCAN_CSCIF && old_state <= CAN_STATE_BUS_OFF) {
+		state = state_map[max(MSCAN_STATE_RX(canrflg),
+				      MSCAN_STATE_TX(canrflg))];
+		priv->can.state = state;
+	}
+	return old_state;
+}
+
+static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	u32 can_id;
+	int i;
+
+	can_id = in_be16(&regs->rx.idr1_0);
+	if (can_id & (1 << 3)) {
+		frame->can_id = CAN_EFF_FLAG;
+		can_id = ((can_id << 16) | in_be16(&regs->rx.idr3_2));
+		can_id = ((can_id & 0xffe00000) |
+			  ((can_id & 0x7ffff) << 2)) >> 2;
+	} else {
+		can_id >>= 4;
+		frame->can_id = 0;
+	}
+
+	frame->can_id |= can_id >> 1;
+	if (can_id & 1)
+		frame->can_id |= CAN_RTR_FLAG;
+	frame->can_dlc = in_8(&regs->rx.dlr) & 0xf;
+
+	if (!(frame->can_id & CAN_RTR_FLAG)) {
+		void __iomem *data = &regs->rx.dsr1_0;
+		u16 *payload = (u16 *) frame->data;
+		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
+			*payload++ = in_be16(data);
+			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
+		}
+	}
+
+	out_8(&regs->canrflg, MSCAN_RXF);
+}
+
+static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
+				u8 canrflg)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct net_device_stats *stats = &dev->stats;
+	enum can_state old_state;
+
+	dev_dbg(dev->dev.parent, "error interrupt (canrflg=%#x)\n", canrflg);
+	frame->can_id = CAN_ERR_FLAG;
+
+	if (canrflg & MSCAN_OVRIF) {
+		frame->can_id |= CAN_ERR_CRTL;
+		frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
+		stats->rx_over_errors++;
+		stats->rx_errors++;
+	} else
+		frame->data[1] = 0;
+
+	old_state = check_set_state(dev, canrflg);
+	/* State changed */
+	if (old_state != priv->can.state) {
+		switch (priv->can.state) {
+		case CAN_STATE_ERROR_WARNING:
+			frame->can_id |= CAN_ERR_CRTL;
+			priv->can.can_stats.error_warning++;
+			if ((priv->shadow_statflg & MSCAN_RSTAT_MSK) <
+			    (canrflg & MSCAN_RSTAT_MSK))
+				frame->data[1] |= CAN_ERR_CRTL_RX_WARNING;
+
+			if ((priv->shadow_statflg & MSCAN_TSTAT_MSK) <
+			    (canrflg & MSCAN_TSTAT_MSK))
+				frame->data[1] |= CAN_ERR_CRTL_TX_WARNING;
+			break;
+		case CAN_STATE_ERROR_PASSIVE:
+			frame->can_id |= CAN_ERR_CRTL;
+			priv->can.can_stats.error_passive++;
+			frame->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
+			break;
+		case CAN_STATE_BUS_OFF:
+			frame->can_id |= CAN_ERR_BUSOFF;
+			/*
+			 * The MSCAN on the MPC5200 does recover from bus-off
+			 * automatically. To avoid that we stop the chip doing
+			 * a light-weight stop (we are in irq-context).
+			 */
+			out_8(&regs->cantier, 0);
+			out_8(&regs->canrier, 0);
+			out_8(&regs->canctl0, in_8(&regs->canctl0) |
+				MSCAN_SLPRQ | MSCAN_INITRQ);
+			can_bus_off(dev);
+			break;
+		default:
+			break;
+		}
+	}
+	priv->shadow_statflg = canrflg & MSCAN_STAT_MSK;
+	frame->can_dlc = CAN_ERR_DLC;
+	out_8(&regs->canrflg, MSCAN_ERR_IF);
+}
+
+static int mscan_rx_poll(struct napi_struct *napi, int quota)
+{
+	struct mscan_priv *priv = container_of(napi, struct mscan_priv, napi);
+	struct net_device *dev = napi->dev;
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct net_device_stats *stats = &dev->stats;
+	int npackets = 0;
+	int ret = 1;
+	struct sk_buff *skb;
+	struct can_frame *frame;
+	u8 canrflg;
+
+	while (npackets < quota && ((canrflg = in_8(&regs->canrflg)) &
+				    (MSCAN_RXF | MSCAN_ERR_IF))) {
+
+		skb = alloc_can_skb(dev, &frame);
+		if (!skb) {
+			if (printk_ratelimit())
+				dev_notice(dev->dev.parent, "packet dropped\n");
+			stats->rx_dropped++;
+			out_8(&regs->canrflg, canrflg);
+			continue;
+		}
+
+		if (canrflg & MSCAN_RXF)
+			mscan_get_rx_frame(dev, frame);
+		 else if (canrflg & MSCAN_ERR_IF)
+			mscan_get_err_frame(dev, frame, canrflg);
+
+		stats->rx_packets++;
+		stats->rx_bytes += frame->can_dlc;
+		npackets++;
+		netif_receive_skb(skb);
+	}
+
+	if (!(in_8(&regs->canrflg) & (MSCAN_RXF | MSCAN_ERR_IF))) {
+		napi_complete(&priv->napi);
+		clear_bit(F_RX_PROGRESS, &priv->flags);
+		if (priv->can.state < CAN_STATE_BUS_OFF)
+			out_8(&regs->canrier, priv->shadow_canrier);
+		ret = 0;
+	}
+	return ret;
+}
+
+static irqreturn_t mscan_isr(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct net_device_stats *stats = &dev->stats;
+	u8 cantier, cantflg, canrflg;
+	irqreturn_t ret = IRQ_NONE;
+
+	cantier = in_8(&regs->cantier) & MSCAN_TXE;
+	cantflg = in_8(&regs->cantflg) & cantier;
+
+	if (cantier && cantflg) {
+
+		struct list_head *tmp, *pos;
+
+		list_for_each_safe(pos, tmp, &priv->tx_head) {
+			struct tx_queue_entry *entry =
+			    list_entry(pos, struct tx_queue_entry, list);
+			u8 mask = entry->mask;
+
+			if (!(cantflg & mask))
+				continue;
+
+			out_8(&regs->cantbsel, mask);
+			stats->tx_bytes += in_8(&regs->tx.dlr);
+			stats->tx_packets++;
+			can_get_echo_skb(dev, entry->id);
+			priv->tx_active &= ~mask;
+			list_del(pos);
+		}
+
+		if (list_empty(&priv->tx_head)) {
+			clear_bit(F_TX_WAIT_ALL, &priv->flags);
+			clear_bit(F_TX_PROGRESS, &priv->flags);
+			priv->cur_pri = 0;
+		} else
+			dev->trans_start = jiffies;
+
+		if (!test_bit(F_TX_WAIT_ALL, &priv->flags))
+			netif_wake_queue(dev);
+
+		out_8(&regs->cantier, priv->tx_active);
+		ret = IRQ_HANDLED;
+	}
+
+	canrflg = in_8(&regs->canrflg);
+	if ((canrflg & ~MSCAN_STAT_MSK) &&
+	    !test_and_set_bit(F_RX_PROGRESS, &priv->flags)) {
+		if (canrflg & ~MSCAN_STAT_MSK) {
+			priv->shadow_canrier = in_8(&regs->canrier);
+			out_8(&regs->canrier, 0);
+			napi_schedule(&priv->napi);
+			ret = IRQ_HANDLED;
+		} else
+			clear_bit(F_RX_PROGRESS, &priv->flags);
+	}
+	return ret;
+}
+
+static int mscan_do_set_mode(struct net_device *dev, enum can_mode mode)
+{
+
+	struct mscan_priv *priv = netdev_priv(dev);
+	int ret = 0;
+
+	if (!priv->open_time)
+		return -EINVAL;
+
+	switch (mode) {
+	case CAN_MODE_SLEEP:
+	case CAN_MODE_STOP:
+		netif_stop_queue(dev);
+		mscan_set_mode(dev,
+			       (mode ==
+				CAN_MODE_STOP) ? MSCAN_INIT_MODE :
+			       MSCAN_SLEEP_MODE);
+		break;
+	case CAN_MODE_START:
+		if (priv->can.state <= CAN_STATE_BUS_OFF)
+			mscan_set_mode(dev, MSCAN_INIT_MODE);
+		ret = mscan_start(dev);
+		if (ret)
+			break;
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+	return ret;
+}
+
+static int mscan_do_set_bittiming(struct net_device *dev)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct can_bittiming *bt = &priv->can.bittiming;
+	u8 btr0, btr1;
+
+	btr0 = BTR0_SET_BRP(bt->brp) | BTR0_SET_SJW(bt->sjw);
+	btr1 = (BTR1_SET_TSEG1(bt->prop_seg + bt->phase_seg1) |
+		BTR1_SET_TSEG2(bt->phase_seg2) |
+		BTR1_SET_SAM(priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES));
+
+	dev_info(dev->dev.parent, "setting BTR0=0x%02x BTR1=0x%02x\n",
+		btr0, btr1);
+
+	out_8(&regs->canbtr0, btr0);
+	out_8(&regs->canbtr1, btr1);
+
+	return 0;
+}
+
+static int mscan_open(struct net_device *dev)
+{
+	int ret;
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	/* common open */
+	ret = open_candev(dev);
+	if (ret)
+		return ret;
+
+	napi_enable(&priv->napi);
+
+	ret = request_irq(dev->irq, mscan_isr, 0, dev->name, dev);
+	if (ret < 0) {
+		napi_disable(&priv->napi);
+		printk(KERN_ERR "%s - failed to attach interrupt\n",
+		       dev->name);
+		return ret;
+	}
+
+	priv->open_time = jiffies;
+
+	out_8(&regs->canctl1, in_8(&regs->canctl1) & ~MSCAN_LISTEN);
+
+	ret = mscan_start(dev);
+	if (ret)
+		return ret;
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int mscan_close(struct net_device *dev)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+	netif_stop_queue(dev);
+	napi_disable(&priv->napi);
+
+	out_8(&regs->cantier, 0);
+	out_8(&regs->canrier, 0);
+	mscan_set_mode(dev, MSCAN_INIT_MODE);
+	close_candev(dev);
+	free_irq(dev->irq, dev);
+	priv->open_time = 0;
+
+	return 0;
+}
+
+static const struct net_device_ops mscan_netdev_ops = {
+       .ndo_open               = mscan_open,
+       .ndo_stop               = mscan_close,
+       .ndo_start_xmit         = mscan_start_xmit,
+};
+
+int register_mscandev(struct net_device *dev, int clock_src)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	u8 ctl1;
+
+	ctl1 = in_8(&regs->canctl1);
+	if (clock_src)
+		ctl1 |= MSCAN_CLKSRC;
+	else
+		ctl1 &= ~MSCAN_CLKSRC;
+
+	ctl1 |= MSCAN_CANE;
+	out_8(&regs->canctl1, ctl1);
+	udelay(100);
+
+	/* acceptance mask/acceptance code (accept everything) */
+	out_be16(&regs->canidar1_0, 0);
+	out_be16(&regs->canidar3_2, 0);
+	out_be16(&regs->canidar5_4, 0);
+	out_be16(&regs->canidar7_6, 0);
+
+	out_be16(&regs->canidmr1_0, 0xffff);
+	out_be16(&regs->canidmr3_2, 0xffff);
+	out_be16(&regs->canidmr5_4, 0xffff);
+	out_be16(&regs->canidmr7_6, 0xffff);
+	/* Two 32 bit Acceptance Filters */
+	out_8(&regs->canidac, MSCAN_AF_32BIT);
+
+	mscan_set_mode(dev, MSCAN_INIT_MODE);
+
+	return register_candev(dev);
+}
+EXPORT_SYMBOL_GPL(register_mscandev);
+
+void unregister_mscandev(struct net_device *dev)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	mscan_set_mode(dev, MSCAN_INIT_MODE);
+	out_8(&regs->canctl1, in_8(&regs->canctl1) & ~MSCAN_CANE);
+	unregister_candev(dev);
+}
+EXPORT_SYMBOL_GPL(unregister_mscandev);
+
+struct net_device *alloc_mscandev(void)
+{
+	struct net_device *dev;
+	struct mscan_priv *priv;
+	int i;
+
+	dev = alloc_candev(sizeof(struct mscan_priv), MSCAN_ECHO_SKB_MAX);
+	if (!dev)
+		return NULL;
+	priv = netdev_priv(dev);
+
+	dev->netdev_ops = &mscan_netdev_ops;
+
+	dev->flags |= IFF_ECHO;	/* we support local echo */
+
+	netif_napi_add(dev, &priv->napi, mscan_rx_poll, 8);
+
+	priv->can.bittiming_const = &mscan_bittiming_const;
+	priv->can.do_set_bittiming = mscan_do_set_bittiming;
+	priv->can.do_set_mode = mscan_do_set_mode;
+
+	for (i = 0; i < TX_QUEUE_SIZE; i++) {
+		priv->tx_queue[i].id = i;
+		priv->tx_queue[i].mask = 1 << i;
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(alloc_mscandev);
+
+MODULE_AUTHOR("Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("CAN port driver for a MSCAN based chips");
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
new file mode 100644
index 0000000..57820f5
--- /dev/null
+++ b/drivers/net/can/mscan/mscan.h
@@ -0,0 +1,262 @@
+/*
+ * Definitions of consts/structs to drive the Freescale MSCAN.
+ *
+ * Copyright (C) 2005-2006 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
+ *                         Varma Electronics Oy
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef __MSCAN_H__
+#define __MSCAN_H__
+
+#include <linux/types.h>
+
+/* MSCAN control register 0 (CANCTL0) bits */
+#define MSCAN_RXFRM		0x80
+#define MSCAN_RXACT		0x40
+#define MSCAN_CSWAI		0x20
+#define MSCAN_SYNCH		0x10
+#define MSCAN_TIME		0x08
+#define MSCAN_WUPE		0x04
+#define MSCAN_SLPRQ		0x02
+#define MSCAN_INITRQ		0x01
+
+/* MSCAN control register 1 (CANCTL1) bits */
+#define MSCAN_CANE		0x80
+#define MSCAN_CLKSRC		0x40
+#define MSCAN_LOOPB		0x20
+#define MSCAN_LISTEN		0x10
+#define MSCAN_WUPM		0x04
+#define MSCAN_SLPAK		0x02
+#define MSCAN_INITAK		0x01
+
+/* Use the MPC5200 MSCAN variant? */
+#ifdef CONFIG_PPC
+#define MSCAN_FOR_MPC5200
+#endif
+
+#ifdef MSCAN_FOR_MPC5200
+#define MSCAN_CLKSRC_BUS	0
+#define MSCAN_CLKSRC_XTAL	MSCAN_CLKSRC
+#else
+#define MSCAN_CLKSRC_BUS	MSCAN_CLKSRC
+#define MSCAN_CLKSRC_XTAL	0
+#endif
+
+/* MSCAN receiver flag register (CANRFLG) bits */
+#define MSCAN_WUPIF		0x80
+#define MSCAN_CSCIF		0x40
+#define MSCAN_RSTAT1		0x20
+#define MSCAN_RSTAT0		0x10
+#define MSCAN_TSTAT1		0x08
+#define MSCAN_TSTAT0		0x04
+#define MSCAN_OVRIF		0x02
+#define MSCAN_RXF		0x01
+#define MSCAN_ERR_IF 		(MSCAN_OVRIF | MSCAN_CSCIF)
+#define MSCAN_RSTAT_MSK		(MSCAN_RSTAT1 | MSCAN_RSTAT0)
+#define MSCAN_TSTAT_MSK		(MSCAN_TSTAT1 | MSCAN_TSTAT0)
+#define MSCAN_STAT_MSK		(MSCAN_RSTAT_MSK | MSCAN_TSTAT_MSK)
+
+#define MSCAN_STATE_BUS_OFF	(MSCAN_RSTAT1 | MSCAN_RSTAT0 | \
+				 MSCAN_TSTAT1 | MSCAN_TSTAT0)
+#define MSCAN_STATE_TX(canrflg)	(((canrflg)&MSCAN_TSTAT_MSK)>>2)
+#define MSCAN_STATE_RX(canrflg)	(((canrflg)&MSCAN_RSTAT_MSK)>>4)
+#define MSCAN_STATE_ACTIVE	0
+#define MSCAN_STATE_WARNING	1
+#define MSCAN_STATE_PASSIVE	2
+#define MSCAN_STATE_BUSOFF	3
+
+/* MSCAN receiver interrupt enable register (CANRIER) bits */
+#define MSCAN_WUPIE		0x80
+#define MSCAN_CSCIE		0x40
+#define MSCAN_RSTATE1		0x20
+#define MSCAN_RSTATE0		0x10
+#define MSCAN_TSTATE1		0x08
+#define MSCAN_TSTATE0		0x04
+#define MSCAN_OVRIE		0x02
+#define MSCAN_RXFIE		0x01
+
+/* MSCAN transmitter flag register (CANTFLG) bits */
+#define MSCAN_TXE2		0x04
+#define MSCAN_TXE1		0x02
+#define MSCAN_TXE0		0x01
+#define MSCAN_TXE		(MSCAN_TXE2 | MSCAN_TXE1 | MSCAN_TXE0)
+
+/* MSCAN transmitter interrupt enable register (CANTIER) bits */
+#define MSCAN_TXIE2		0x04
+#define MSCAN_TXIE1		0x02
+#define MSCAN_TXIE0		0x01
+#define MSCAN_TXIE		(MSCAN_TXIE2 | MSCAN_TXIE1 | MSCAN_TXIE0)
+
+/* MSCAN transmitter message abort request (CANTARQ) bits */
+#define MSCAN_ABTRQ2		0x04
+#define MSCAN_ABTRQ1		0x02
+#define MSCAN_ABTRQ0		0x01
+
+/* MSCAN transmitter message abort ack (CANTAAK) bits */
+#define MSCAN_ABTAK2		0x04
+#define MSCAN_ABTAK1		0x02
+#define MSCAN_ABTAK0		0x01
+
+/* MSCAN transmit buffer selection (CANTBSEL) bits */
+#define MSCAN_TX2		0x04
+#define MSCAN_TX1		0x02
+#define MSCAN_TX0		0x01
+
+/* MSCAN ID acceptance control register (CANIDAC) bits */
+#define MSCAN_IDAM1		0x20
+#define MSCAN_IDAM0		0x10
+#define MSCAN_IDHIT2		0x04
+#define MSCAN_IDHIT1		0x02
+#define MSCAN_IDHIT0		0x01
+
+#define MSCAN_AF_32BIT		0x00
+#define MSCAN_AF_16BIT		MSCAN_IDAM0
+#define MSCAN_AF_8BIT		MSCAN_IDAM1
+#define MSCAN_AF_CLOSED		(MSCAN_IDAM0|MSCAN_IDAM1)
+#define MSCAN_AF_MASK		(~(MSCAN_IDAM0|MSCAN_IDAM1))
+
+/* MSCAN Miscellaneous Register (CANMISC) bits */
+#define MSCAN_BOHOLD		0x01
+
+#ifdef MSCAN_FOR_MPC5200
+#define _MSCAN_RESERVED_(n, num) u8 _res##n[num]
+#define _MSCAN_RESERVED_DSR_SIZE	2
+#else
+#define _MSCAN_RESERVED_(n, num)
+#define _MSCAN_RESERVED_DSR_SIZE	0
+#endif
+
+/* Structure of the hardware registers */
+struct mscan_regs {
+	/* (see doc S12MSCANV3/D)		  MPC5200    MSCAN */
+	u8 canctl0;				/* + 0x00     0x00 */
+	u8 canctl1;				/* + 0x01     0x01 */
+	_MSCAN_RESERVED_(1, 2);			/* + 0x02          */
+	u8 canbtr0;				/* + 0x04     0x02 */
+	u8 canbtr1;				/* + 0x05     0x03 */
+	_MSCAN_RESERVED_(2, 2);			/* + 0x06          */
+	u8 canrflg;				/* + 0x08     0x04 */
+	u8 canrier;				/* + 0x09     0x05 */
+	_MSCAN_RESERVED_(3, 2);			/* + 0x0a          */
+	u8 cantflg;				/* + 0x0c     0x06 */
+	u8 cantier;				/* + 0x0d     0x07 */
+	_MSCAN_RESERVED_(4, 2);			/* + 0x0e          */
+	u8 cantarq;				/* + 0x10     0x08 */
+	u8 cantaak;				/* + 0x11     0x09 */
+	_MSCAN_RESERVED_(5, 2);			/* + 0x12          */
+	u8 cantbsel;				/* + 0x14     0x0a */
+	u8 canidac;				/* + 0x15     0x0b */
+	u8 reserved;				/* + 0x16     0x0c */
+	_MSCAN_RESERVED_(6, 5);			/* + 0x17          */
+#ifndef MSCAN_FOR_MPC5200
+	u8 canmisc;				/*            0x0d */
+#endif
+	u8 canrxerr;				/* + 0x1c     0x0e */
+	u8 cantxerr;				/* + 0x1d     0x0f */
+	_MSCAN_RESERVED_(7, 2);			/* + 0x1e          */
+	u16 canidar1_0;				/* + 0x20     0x10 */
+	_MSCAN_RESERVED_(8, 2);			/* + 0x22          */
+	u16 canidar3_2;				/* + 0x24     0x12 */
+	_MSCAN_RESERVED_(9, 2);			/* + 0x26          */
+	u16 canidmr1_0;				/* + 0x28     0x14 */
+	_MSCAN_RESERVED_(10, 2);		/* + 0x2a          */
+	u16 canidmr3_2;				/* + 0x2c     0x16 */
+	_MSCAN_RESERVED_(11, 2);		/* + 0x2e          */
+	u16 canidar5_4;				/* + 0x30     0x18 */
+	_MSCAN_RESERVED_(12, 2);		/* + 0x32          */
+	u16 canidar7_6;				/* + 0x34     0x1a */
+	_MSCAN_RESERVED_(13, 2);		/* + 0x36          */
+	u16 canidmr5_4;				/* + 0x38     0x1c */
+	_MSCAN_RESERVED_(14, 2);		/* + 0x3a          */
+	u16 canidmr7_6;				/* + 0x3c     0x1e */
+	_MSCAN_RESERVED_(15, 2);		/* + 0x3e          */
+	struct {
+		u16 idr1_0;			/* + 0x40     0x20 */
+		 _MSCAN_RESERVED_(16, 2);	/* + 0x42          */
+		u16 idr3_2;			/* + 0x44     0x22 */
+		 _MSCAN_RESERVED_(17, 2);	/* + 0x46          */
+		u16 dsr1_0;			/* + 0x48     0x24 */
+		 _MSCAN_RESERVED_(18, 2);	/* + 0x4a          */
+		u16 dsr3_2;			/* + 0x4c     0x26 */
+		 _MSCAN_RESERVED_(19, 2);	/* + 0x4e          */
+		u16 dsr5_4;			/* + 0x50     0x28 */
+		 _MSCAN_RESERVED_(20, 2);	/* + 0x52          */
+		u16 dsr7_6;			/* + 0x54     0x2a */
+		 _MSCAN_RESERVED_(21, 2);	/* + 0x56          */
+		u8 dlr;				/* + 0x58     0x2c */
+		 u8:8;				/* + 0x59     0x2d */
+		 _MSCAN_RESERVED_(22, 2);	/* + 0x5a          */
+		u16 time;			/* + 0x5c     0x2e */
+	} rx;
+	 _MSCAN_RESERVED_(23, 2);		/* + 0x5e          */
+	struct {
+		u16 idr1_0;			/* + 0x60     0x30 */
+		 _MSCAN_RESERVED_(24, 2);	/* + 0x62          */
+		u16 idr3_2;			/* + 0x64     0x32 */
+		 _MSCAN_RESERVED_(25, 2);	/* + 0x66          */
+		u16 dsr1_0;			/* + 0x68     0x34 */
+		 _MSCAN_RESERVED_(26, 2);	/* + 0x6a          */
+		u16 dsr3_2;			/* + 0x6c     0x36 */
+		 _MSCAN_RESERVED_(27, 2);	/* + 0x6e          */
+		u16 dsr5_4;			/* + 0x70     0x38 */
+		 _MSCAN_RESERVED_(28, 2);	/* + 0x72          */
+		u16 dsr7_6;			/* + 0x74     0x3a */
+		 _MSCAN_RESERVED_(29, 2);	/* + 0x76          */
+		u8 dlr;				/* + 0x78     0x3c */
+		u8 tbpr;			/* + 0x79     0x3d */
+		 _MSCAN_RESERVED_(30, 2);	/* + 0x7a          */
+		u16 time;			/* + 0x7c     0x3e */
+	} tx;
+	 _MSCAN_RESERVED_(31, 2);		/* + 0x7e          */
+} __attribute__ ((packed));
+
+#undef _MSCAN_RESERVED_
+#define MSCAN_REGION 	sizeof(struct mscan)
+
+#define TX_QUEUE_SIZE	3
+
+struct tx_queue_entry {
+	struct list_head list;
+	u8 mask;
+	u8 id;
+};
+
+struct mscan_priv {
+	struct can_priv can;	/* must be the first member */
+	long open_time;
+	unsigned long flags;
+	void __iomem *reg_base;	/* ioremap'ed address to registers */
+	u8 shadow_statflg;
+	u8 shadow_canrier;
+	u8 cur_pri;
+	u8 prev_buf_id;
+	u8 tx_active;
+
+	struct list_head tx_head;
+	struct tx_queue_entry tx_queue[TX_QUEUE_SIZE];
+	struct napi_struct napi;
+};
+
+struct net_device *alloc_mscandev(void);
+/*
+ * clock_src:
+ *	1 = The MSCAN clock source is the onchip Bus Clock.
+ *	0 = The MSCAN clock source is the chip Oscillator Clock.
+ */
+extern int register_mscandev(struct net_device *dev, int clock_src);
+extern void unregister_mscandev(struct net_device *dev);
+
+#endif /* __MSCAN_H__ */
-- 
1.6.3.3
