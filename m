From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next v3 2/3] can: mscan-mpc5xxx: add support for the MPC512x processor
Date: Thu,  7 Jan 2010 15:10:20 +0100
Message-ID: <1262873421-6863-3-git-send-email-wg@grandegger.com>
References: <1262873421-6863-1-git-send-email-wg@grandegger.com>
 <1262873421-6863-2-git-send-email-wg@grandegger.com>
Cc: Socketcan-core@lists.berlios.de, Linuxppc-dev@lists.ozlabs.org,
	Devicetree-discuss@lists.ozlabs.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Wolfgang Grandegger <wg@denx.de>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1262873421-6863-2-git-send-email-wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@denx.de>

The main differences compared to the MSCAN on the MPC5200 are:

- More flexibility in choosing the CAN source clock and frequency:

  Three different clock sources can be selected: "ip", "ref" or "sys".
  For the latter two, a clock divider can be defined as well. If the
  clock source is not specified by the device tree, we first try to
  find an optimal CAN source clock based on the system clock. If that
  is not possible, the reference clock will be used.

- The behavior of bus-off recovery is configurable:

  To comply with the usual handling of Socket-CAN bus-off recovery,
  "recovery on request" is selected (instead of automatic recovery).

Note that only MPC5121 Rev. 2 and later is supported.

Signed-off-by: Wolfgang Grandegger <wg@denx.de>
---
 drivers/net/can/mscan/Kconfig       |    7 +-
 drivers/net/can/mscan/mpc5xxx_can.c |  246 +++++++++++++++++++++++++++++------
 drivers/net/can/mscan/mscan.c       |   51 ++++++--
 drivers/net/can/mscan/mscan.h       |   86 +++++++------
 4 files changed, 295 insertions(+), 95 deletions(-)

diff --git a/drivers/net/can/mscan/Kconfig b/drivers/net/can/mscan/Kconfig
index cd0f2d6..27d1d39 100644
--- a/drivers/net/can/mscan/Kconfig
+++ b/drivers/net/can/mscan/Kconfig
@@ -11,12 +11,13 @@ if CAN_MSCAN
 
 config CAN_MPC5XXX
 	tristate "Freescale MPC5xxx onboard CAN controller"
-	depends on PPC_MPC52xx
+	depends on (PPC_MPC52xx || PPC_MPC512x)
 	---help---
 	  If you say yes here you get support for Freescale's MPC5xxx
-	  onboard CAN controller.
+	  onboard CAN controller. Currently, the MPC5200, MPC5200B and
+	  MPC5121 (Rev. 2 and later) are supported.
 
-	  This driver can also be built as a module.  If so, the module
+	  This driver can also be built as a module. If so, the module
 	  will be called mscan-mpc5xxx.ko.
 
 endif
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 1de6f63..f73487f 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -29,6 +29,7 @@
 #include <linux/can/dev.h>
 #include <linux/of_platform.h>
 #include <sysdev/fsl_soc.h>
+#include <linux/clk.h>
 #include <linux/io.h>
 #include <asm/mpc52xx.h>
 
@@ -36,22 +37,21 @@
 
 #define DRV_NAME "mpc5xxx_can"
 
-static struct of_device_id mpc52xx_cdm_ids[] __devinitdata = {
+struct mpc5xxx_can_data {
+	unsigned int type;
+	u32 (*get_clock)(struct of_device *ofdev, const char *clock_name,
+			 int *mscan_clksrc);
+};
+
+#ifdef CONFIG_PPC_MPC5200
+static struct of_device_id __devinitdata mpc52xx_cdm_ids[] = {
 	{ .compatible = "fsl,mpc5200-cdm", },
 	{}
 };
 
-/*
- * Get frequency of the MSCAN clock source
- *
- * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock (IP_CLK)
- * can be selected. According to the MPC5200 user's manual, the oscillator
- * clock is the better choice as it has less jitter but due to a hardware
- * bug, it can not be selected for the old MPC5200 Rev. A chips.
- */
-
-static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
-						      int clock_src)
+static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
+					   const char *clock_name,
+					   int *mscan_clksrc)
 {
 	unsigned int pvr;
 	struct mpc52xx_cdm  __iomem *cdm;
@@ -61,11 +61,24 @@ static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
 
 	pvr = mfspr(SPRN_PVR);
 
-	freq = mpc5xxx_get_bus_frequency(of->node);
+	/*
+	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
+	 * (IP_CLK) can be selected as MSCAN clock source. According to
+	 * the MPC5200 user's manual, the oscillator clock is the better
+	 * choice as it has less jitter. For this reason, it is selected
+	 * by default. Unfortunately, it can not be selected for the old
+	 * MPC5200 Rev. A chips due to a hardware bug (check errata).
+	 */
+	if (clock_name && strcmp(clock_name, "ip") == 0)
+		*mscan_clksrc = MSCAN_CLKSRC_BUS;
+	else
+		*mscan_clksrc = MSCAN_CLKSRC_XTAL;
+
+	freq = mpc5xxx_get_bus_frequency(ofdev->node);
 	if (!freq)
 		return 0;
 
-	if (clock_src == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
+	if (*mscan_clksrc == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
 		return freq;
 
 	/* Determine SYS_XTAL_IN frequency from the clock domain settings */
@@ -75,7 +88,6 @@ static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
 		return 0;
 	}
 	cdm = of_iomap(np_cdm, 0);
-	of_node_put(np_cdm);
 
 	if (in_8(&cdm->ipb_clk_sel) & 0x1)
 		freq *= 2;
@@ -84,26 +96,174 @@ static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
 	freq *= (val & (1 << 5)) ? 8 : 4;
 	freq /= (val & (1 << 6)) ? 12 : 16;
 
+	of_node_put(np_cdm);
 	iounmap(cdm);
 
 	return freq;
 }
+#else /* !CONFIG_PPC_MPC5200 */
+static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
+					   const char *clock_name,
+					   int *mscan_clksrc)
+{
+	return 0;
+}
+#endif /* CONFIG_PPC_MPC5200 */
+
+#ifdef CONFIG_PPC_MPC512x
+struct mpc512x_clockctl {
+	u32 spmr;		/* System PLL Mode Reg */
+	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
+	u32 scfr1;		/* System Clk Freq Reg 1 */
+	u32 scfr2;		/* System Clk Freq Reg 2 */
+	u32 reserved;
+	u32 bcr;		/* Bread Crumb Reg */
+	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
+	u32 spccr;		/* SPDIF Clk Ctrl Reg */
+	u32 cccr;		/* CFM Clk Ctrl Reg */
+	u32 dccr;		/* DIU Clk Cnfg Reg */
+	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
+};
+
+static struct of_device_id __devinitdata mpc512x_clock_ids[] = {
+	{ .compatible = "fsl,mpc5121-clock", },
+	{}
+};
+
+static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
+					   const char *clock_name,
+					   int *mscan_clksrc)
+{
+	struct mpc512x_clockctl __iomem *clockctl;
+	struct device_node *np_clock;
+	struct clk *sys_clk, *ref_clk;
+	int plen, clockidx, clocksrc = -1;
+	u32 sys_freq, val, clockdiv = 1, freq = 0;
+	const u32 *pval;
+
+	np_clock = of_find_matching_node(NULL, mpc512x_clock_ids);
+	if (!np_clock) {
+		dev_err(&ofdev->dev, "couldn't find clock node\n");
+		return -ENODEV;
+	}
+	clockctl = of_iomap(np_clock, 0);
+	if (!clockctl) {
+		dev_err(&ofdev->dev, "couldn't map clock registers\n");
+		return 0;
+	}
+
+	/* Determine the MSCAN device index from the physical address */
+	pval = of_get_property(ofdev->node, "reg", &plen);
+	BUG_ON(!pval || plen < sizeof(*pval));
+	clockidx = (*pval & 0x80) ? 1 : 0;
+	if (*pval & 0x2000)
+		clockidx += 2;
+
+	/*
+	 * Clock source and divider selection: 3 different clock sources
+	 * can be selected: "ip", "ref" or "sys". For the latter two, a
+	 * clock divider can be defined as well. If the clock source is
+	 * not specified by the device tree, we first try to find an
+	 * optimal CAN source clock based on the system clock. If that
+	 * is not posslible, the reference clock will be used.
+	 */
+	if (clock_name && !strcmp(clock_name, "ip")) {
+		*mscan_clksrc = MSCAN_CLKSRC_IPS;
+		freq = mpc5xxx_get_bus_frequency(ofdev->node);
+	} else {
+		*mscan_clksrc = MSCAN_CLKSRC_BUS;
+
+		pval = of_get_property(ofdev->node,
+				       "fsl,mscan-clock-divider", &plen);
+		if (pval && plen == sizeof(*pval))
+			clockdiv = *pval;
+		if (!clockdiv)
+			clockdiv = 1;
+
+		if (!clock_name || !strcmp(clock_name, "sys")) {
+			sys_clk = clk_get(&ofdev->dev, "sys_clk");
+			if (!sys_clk) {
+				dev_err(&ofdev->dev, "couldn't get sys_clk\n");
+				goto exit_unmap;
+			}
+			/* Get and round up/down sys clock rate */
+			sys_freq = 1000000 *
+				((clk_get_rate(sys_clk) + 499999) / 1000000);
+
+			if (!clock_name) {
+				/* A multiple of 16 MHz would be optimal */
+				if ((sys_freq % 16000000) == 0) {
+					clocksrc = 0;
+					clockdiv = sys_freq / 16000000;
+					freq = sys_freq / clockdiv;
+				}
+			} else {
+				clocksrc = 0;
+				freq = sys_freq / clockdiv;
+			}
+		}
+
+		if (clocksrc < 0) {
+			ref_clk = clk_get(&ofdev->dev, "ref_clk");
+			if (!ref_clk) {
+				dev_err(&ofdev->dev, "couldn't get ref_clk\n");
+				goto exit_unmap;
+			}
+			clocksrc = 1;
+			freq = clk_get_rate(ref_clk) / clockdiv;
+		}
+	}
+
+	/* Disable clock */
+	out_be32(&clockctl->mccr[clockidx], 0x0);
+	if (clocksrc >= 0) {
+		/* Set source and divider */
+		val = (clocksrc << 14) | ((clockdiv - 1) << 17);
+		out_be32(&clockctl->mccr[clockidx], val);
+		/* Enable clock */
+		out_be32(&clockctl->mccr[clockidx], val | 0x10000);
+	}
+
+	/* Enable MSCAN clock domain */
+	val = in_be32(&clockctl->sccr[1]);
+	if (!(val & (1 << 25)))
+		out_be32(&clockctl->sccr[1], val | (1 << 25));
+
+	dev_dbg(&ofdev->dev, "using '%s' with frequency divider %d\n",
+		*mscan_clksrc == MSCAN_CLKSRC_IPS ? "ips_clk" :
+		clocksrc == 1 ? "ref_clk" : "sys_clk", clockdiv);
+
+exit_unmap:
+	of_node_put(np_clock);
+	iounmap(clockctl);
+
+	return freq;
+}
+#else /* !CONFIG_PPC_MPC512x */
+static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
+					   const char *clock_name,
+					   int *mscan_clksrc)
+{
+	return 0;
+}
+#endif /* CONFIG_PPC_MPC512x */
 
 static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
 				       const struct of_device_id *id)
 {
+	struct mpc5xxx_can_data *data = (struct mpc5xxx_can_data *)id->data;
 	struct device_node *np = ofdev->node;
 	struct net_device *dev;
 	struct mscan_priv *priv;
 	void __iomem *base;
-	const char *clk_src;
-	int err, irq, clock_src;
+	const char *clock_name = NULL;
+	int irq, mscan_clksrc = 0;
+	int err = -ENOMEM;
 
-	base = of_iomap(ofdev->node, 0);
+	base = of_iomap(np, 0);
 	if (!base) {
 		dev_err(&ofdev->dev, "couldn't ioremap\n");
-		err = -ENOMEM;
-		goto exit_release_mem;
+		return err;
 	}
 
 	irq = irq_of_parse_and_map(np, 0);
@@ -114,37 +274,27 @@ static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
 	}
 
 	dev = alloc_mscandev();
-	if (!dev) {
-		err = -ENOMEM;
+	if (!dev)
 		goto exit_dispose_irq;
-	}
 
 	priv = netdev_priv(dev);
 	priv->reg_base = base;
 	dev->irq = irq;
 
-	/*
-	 * Either the oscillator clock (SYS_XTAL_IN) or the IP bus clock
-	 * (IP_CLK) can be selected as MSCAN clock source. According to
-	 * the MPC5200 user's manual, the oscillator clock is the better
-	 * choice as it has less jitter. For this reason, it is selected
-	 * by default.
-	 */
-	clk_src = of_get_property(np, "fsl,mscan-clock-source", NULL);
-	if (clk_src && strcmp(clk_src, "ip") == 0)
-		clock_src = MSCAN_CLKSRC_BUS;
-	else
-		clock_src = MSCAN_CLKSRC_XTAL;
-	priv->can.clock.freq = mpc52xx_can_clock_freq(ofdev, clock_src);
+	clock_name = of_get_property(np, "fsl,mscan-clock-source", NULL);
+
+	BUG_ON(!data);
+	priv->type = data->type;
+	priv->can.clock.freq = data->get_clock(ofdev, clock_name,
+					       &mscan_clksrc);
 	if (!priv->can.clock.freq) {
-		dev_err(&ofdev->dev, "couldn't get MSCAN clock frequency\n");
-		err = -ENODEV;
+		dev_err(&ofdev->dev, "couldn't get MSCAN clock properties\n");
 		goto exit_free_mscan;
 	}
 
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
-	err = register_mscandev(dev, clock_src);
+	err = register_mscandev(dev, mscan_clksrc);
 	if (err) {
 		dev_err(&ofdev->dev, "registering %s failed (err=%d)\n",
 			DRV_NAME, err);
@@ -164,7 +314,7 @@ exit_dispose_irq:
 	irq_dispose_mapping(irq);
 exit_unmap_mem:
 	iounmap(base);
-exit_release_mem:
+
 	return err;
 }
 
@@ -225,8 +375,20 @@ static int mpc5xxx_can_resume(struct of_device *ofdev)
 }
 #endif
 
+static struct mpc5xxx_can_data __devinitdata mpc5200_can_data = {
+	.type = MSCAN_TYPE_MPC5200,
+	.get_clock = mpc52xx_can_get_clock,
+};
+
+static struct mpc5xxx_can_data __devinitdata mpc5121_can_data = {
+	.type = MSCAN_TYPE_MPC5121,
+	.get_clock = mpc512x_can_get_clock,
+};
+
 static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
-	{.compatible = "fsl,mpc5200-mscan"},
+	{ .compatible = "fsl,mpc5200-mscan", .data = &mpc5200_can_data, },
+	/* Note that only MPC5121 Rev. 2 (and later) is supported */
+	{ .compatible = "fsl,mpc5121-mscan", .data = &mpc5121_can_data, },
 	{},
 };
 
@@ -255,5 +417,5 @@ static void __exit mpc5xxx_can_exit(void)
 module_exit(mpc5xxx_can_exit);
 
 MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
-MODULE_DESCRIPTION("Freescale MPC5200 CAN driver");
+MODULE_DESCRIPTION("Freescale MPC5xxx CAN driver");
 MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 955a164..a896293 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -152,6 +152,12 @@ static int mscan_start(struct net_device *dev)
 	priv->shadow_canrier = 0;
 	priv->flags = 0;
 
+	if (priv->type == MSCAN_TYPE_MPC5121) {
+		/* Clear pending bus-off condition */
+		if (in_8(&regs->canmisc) & MSCAN_BOHOLD)
+			out_8(&regs->canmisc, MSCAN_BOHOLD);
+	}
+
 	err = mscan_set_mode(dev, MSCAN_NORMAL_MODE);
 	if (err)
 		return err;
@@ -163,8 +169,29 @@ static int mscan_start(struct net_device *dev)
 	out_8(&regs->cantier, 0);
 
 	/* Enable receive interrupts. */
-	out_8(&regs->canrier, MSCAN_OVRIE | MSCAN_RXFIE | MSCAN_CSCIE |
-	      MSCAN_RSTATE1 | MSCAN_RSTATE0 | MSCAN_TSTATE1 | MSCAN_TSTATE0);
+	out_8(&regs->canrier, MSCAN_RX_INTS_ENABLE);
+
+	return 0;
+}
+
+static int mscan_restart(struct net_device *dev)
+{
+	struct mscan_priv *priv = netdev_priv(dev);
+
+	if (priv->type == MSCAN_TYPE_MPC5121) {
+		struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+		WARN(!(in_8(&regs->canmisc) & MSCAN_BOHOLD),
+		     "bus-off state expected");
+		out_8(&regs->canmisc, MSCAN_BOHOLD);
+		/* Re-enable receive interrupts. */
+		out_8(&regs->canrier, MSCAN_RX_INTS_ENABLE);
+	} else {
+		if (priv->can.state <= CAN_STATE_BUS_OFF)
+			mscan_set_mode(dev, MSCAN_INIT_MODE);
+		return mscan_start(dev);
+	}
 
 	return 0;
 }
@@ -364,9 +391,12 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 			 * automatically. To avoid that we stop the chip doing
 			 * a light-weight stop (we are in irq-context).
 			 */
-			out_8(&regs->cantier, 0);
-			out_8(&regs->canrier, 0);
-			setbits8(&regs->canctl0, MSCAN_SLPRQ | MSCAN_INITRQ);
+			if (priv->type != MSCAN_TYPE_MPC5121) {
+				out_8(&regs->cantier, 0);
+				out_8(&regs->canrier, 0);
+				setbits8(&regs->canctl0,
+					 MSCAN_SLPRQ | MSCAN_INITRQ);
+			}
 			can_bus_off(dev);
 			break;
 		default:
@@ -496,9 +526,7 @@ static int mscan_do_set_mode(struct net_device *dev, enum can_mode mode)
 
 	switch (mode) {
 	case CAN_MODE_START:
-		if (priv->can.state <= CAN_STATE_BUS_OFF)
-			mscan_set_mode(dev, MSCAN_INIT_MODE);
-		ret = mscan_start(dev);
+		ret = mscan_restart(dev);
 		if (ret)
 			break;
 		if (netif_queue_stopped(dev))
@@ -597,18 +625,21 @@ static const struct net_device_ops mscan_netdev_ops = {
        .ndo_start_xmit         = mscan_start_xmit,
 };
 
-int register_mscandev(struct net_device *dev, int clock_src)
+int register_mscandev(struct net_device *dev, int mscan_clksrc)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
 	u8 ctl1;
 
 	ctl1 = in_8(&regs->canctl1);
-	if (clock_src)
+	if (mscan_clksrc)
 		ctl1 |= MSCAN_CLKSRC;
 	else
 		ctl1 &= ~MSCAN_CLKSRC;
 
+	if (priv->type == MSCAN_TYPE_MPC5121)
+		ctl1 |= MSCAN_BORM; /* bus-off recovery upon request */
+
 	ctl1 |= MSCAN_CANE;
 	out_8(&regs->canctl1, ctl1);
 	udelay(100);
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 00fc4aa..4ff9664 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -38,18 +38,20 @@
 #define MSCAN_CLKSRC		0x40
 #define MSCAN_LOOPB		0x20
 #define MSCAN_LISTEN		0x10
+#define MSCAN_BORM		0x08
 #define MSCAN_WUPM		0x04
 #define MSCAN_SLPAK		0x02
 #define MSCAN_INITAK		0x01
 
-/* Use the MPC5200 MSCAN variant? */
+/* Use the MPC5XXX MSCAN variant? */
 #ifdef CONFIG_PPC
-#define MSCAN_FOR_MPC5200
+#define MSCAN_FOR_MPC5XXX
 #endif
 
-#ifdef MSCAN_FOR_MPC5200
+#ifdef MSCAN_FOR_MPC5XXX
 #define MSCAN_CLKSRC_BUS	0
 #define MSCAN_CLKSRC_XTAL	MSCAN_CLKSRC
+#define MSCAN_CLKSRC_IPS	MSCAN_CLKSRC
 #else
 #define MSCAN_CLKSRC_BUS	MSCAN_CLKSRC
 #define MSCAN_CLKSRC_XTAL	0
@@ -136,7 +138,7 @@
 #define MSCAN_EFF_RTR_SHIFT	0
 #define MSCAN_EFF_FLAGS		0x18	/* IDE + SRR */
 
-#ifdef MSCAN_FOR_MPC5200
+#ifdef MSCAN_FOR_MPC5XXX
 #define _MSCAN_RESERVED_(n, num) u8 _res##n[num]
 #define _MSCAN_RESERVED_DSR_SIZE	2
 #else
@@ -165,67 +167,66 @@ struct mscan_regs {
 	u8 cantbsel;				/* + 0x14     0x0a */
 	u8 canidac;				/* + 0x15     0x0b */
 	u8 reserved;				/* + 0x16     0x0c */
-	_MSCAN_RESERVED_(6, 5);			/* + 0x17          */
-#ifndef MSCAN_FOR_MPC5200
-	u8 canmisc;				/*            0x0d */
-#endif
+	_MSCAN_RESERVED_(6, 2);			/* + 0x17          */
+	u8 canmisc;				/* + 0x19     0x0d */
+	_MSCAN_RESERVED_(7, 2);			/* + 0x1a          */
 	u8 canrxerr;				/* + 0x1c     0x0e */
 	u8 cantxerr;				/* + 0x1d     0x0f */
-	_MSCAN_RESERVED_(7, 2);			/* + 0x1e          */
+	_MSCAN_RESERVED_(8, 2);			/* + 0x1e          */
 	u16 canidar1_0;				/* + 0x20     0x10 */
-	_MSCAN_RESERVED_(8, 2);			/* + 0x22          */
+	_MSCAN_RESERVED_(9, 2);			/* + 0x22          */
 	u16 canidar3_2;				/* + 0x24     0x12 */
-	_MSCAN_RESERVED_(9, 2);			/* + 0x26          */
+	_MSCAN_RESERVED_(10, 2);		/* + 0x26          */
 	u16 canidmr1_0;				/* + 0x28     0x14 */
-	_MSCAN_RESERVED_(10, 2);		/* + 0x2a          */
+	_MSCAN_RESERVED_(11, 2);		/* + 0x2a          */
 	u16 canidmr3_2;				/* + 0x2c     0x16 */
-	_MSCAN_RESERVED_(11, 2);		/* + 0x2e          */
+	_MSCAN_RESERVED_(12, 2);		/* + 0x2e          */
 	u16 canidar5_4;				/* + 0x30     0x18 */
-	_MSCAN_RESERVED_(12, 2);		/* + 0x32          */
+	_MSCAN_RESERVED_(13, 2);		/* + 0x32          */
 	u16 canidar7_6;				/* + 0x34     0x1a */
-	_MSCAN_RESERVED_(13, 2);		/* + 0x36          */
+	_MSCAN_RESERVED_(14, 2);		/* + 0x36          */
 	u16 canidmr5_4;				/* + 0x38     0x1c */
-	_MSCAN_RESERVED_(14, 2);		/* + 0x3a          */
+	_MSCAN_RESERVED_(15, 2);		/* + 0x3a          */
 	u16 canidmr7_6;				/* + 0x3c     0x1e */
-	_MSCAN_RESERVED_(15, 2);		/* + 0x3e          */
+	_MSCAN_RESERVED_(16, 2);		/* + 0x3e          */
 	struct {
 		u16 idr1_0;			/* + 0x40     0x20 */
-		 _MSCAN_RESERVED_(16, 2);	/* + 0x42          */
+		_MSCAN_RESERVED_(17, 2);	/* + 0x42          */
 		u16 idr3_2;			/* + 0x44     0x22 */
-		 _MSCAN_RESERVED_(17, 2);	/* + 0x46          */
+		_MSCAN_RESERVED_(18, 2);	/* + 0x46          */
 		u16 dsr1_0;			/* + 0x48     0x24 */
-		 _MSCAN_RESERVED_(18, 2);	/* + 0x4a          */
+		_MSCAN_RESERVED_(19, 2);	/* + 0x4a          */
 		u16 dsr3_2;			/* + 0x4c     0x26 */
-		 _MSCAN_RESERVED_(19, 2);	/* + 0x4e          */
+		_MSCAN_RESERVED_(20, 2);	/* + 0x4e          */
 		u16 dsr5_4;			/* + 0x50     0x28 */
-		 _MSCAN_RESERVED_(20, 2);	/* + 0x52          */
+		_MSCAN_RESERVED_(21, 2);	/* + 0x52          */
 		u16 dsr7_6;			/* + 0x54     0x2a */
-		 _MSCAN_RESERVED_(21, 2);	/* + 0x56          */
+		_MSCAN_RESERVED_(22, 2);	/* + 0x56          */
 		u8 dlr;				/* + 0x58     0x2c */
-		 u8:8;				/* + 0x59     0x2d */
-		 _MSCAN_RESERVED_(22, 2);	/* + 0x5a          */
+		u8 reserved;			/* + 0x59     0x2d */
+		_MSCAN_RESERVED_(23, 2);	/* + 0x5a          */
 		u16 time;			/* + 0x5c     0x2e */
 	} rx;
-	 _MSCAN_RESERVED_(23, 2);		/* + 0x5e          */
+	_MSCAN_RESERVED_(24, 2);		/* + 0x5e          */
 	struct {
 		u16 idr1_0;			/* + 0x60     0x30 */
-		 _MSCAN_RESERVED_(24, 2);	/* + 0x62          */
+		_MSCAN_RESERVED_(25, 2);	/* + 0x62          */
 		u16 idr3_2;			/* + 0x64     0x32 */
-		 _MSCAN_RESERVED_(25, 2);	/* + 0x66          */
+		_MSCAN_RESERVED_(26, 2);	/* + 0x66          */
 		u16 dsr1_0;			/* + 0x68     0x34 */
-		 _MSCAN_RESERVED_(26, 2);	/* + 0x6a          */
+		_MSCAN_RESERVED_(27, 2);	/* + 0x6a          */
 		u16 dsr3_2;			/* + 0x6c     0x36 */
-		 _MSCAN_RESERVED_(27, 2);	/* + 0x6e          */
+		_MSCAN_RESERVED_(28, 2);	/* + 0x6e          */
 		u16 dsr5_4;			/* + 0x70     0x38 */
-		 _MSCAN_RESERVED_(28, 2);	/* + 0x72          */
+		_MSCAN_RESERVED_(29, 2);	/* + 0x72          */
 		u16 dsr7_6;			/* + 0x74     0x3a */
-		 _MSCAN_RESERVED_(29, 2);	/* + 0x76          */
+		_MSCAN_RESERVED_(30, 2);	/* + 0x76          */
 		u8 dlr;				/* + 0x78     0x3c */
 		u8 tbpr;			/* + 0x79     0x3d */
-		 _MSCAN_RESERVED_(30, 2);	/* + 0x7a          */
+		_MSCAN_RESERVED_(31, 2);	/* + 0x7a          */
 		u16 time;			/* + 0x7c     0x3e */
 	} tx;
-	 _MSCAN_RESERVED_(31, 2);		/* + 0x7e          */
+	_MSCAN_RESERVED_(32, 2);		/* + 0x7e          */
 } __attribute__ ((packed));
 
 #undef _MSCAN_RESERVED_
@@ -237,6 +238,15 @@ struct mscan_regs {
 #define MSCAN_POWEROFF_MODE	(MSCAN_CSWAI | MSCAN_SLPRQ)
 #define MSCAN_SET_MODE_RETRIES	255
 #define MSCAN_ECHO_SKB_MAX	3
+#define MSCAN_RX_INTS_ENABLE	(MSCAN_OVRIE | MSCAN_RXFIE | MSCAN_CSCIE | \
+				 MSCAN_RSTATE1 | MSCAN_RSTATE0 | \
+				 MSCAN_TSTATE1 | MSCAN_TSTATE0)
+
+/* MSCAN type variants */
+enum {
+	MSCAN_TYPE_MPC5200,
+	MSCAN_TYPE_MPC5121
+};
 
 #define BTR0_BRP_MASK		0x3f
 #define BTR0_SJW_SHIFT		6
@@ -270,6 +280,7 @@ struct tx_queue_entry {
 
 struct mscan_priv {
 	struct can_priv can;	/* must be the first member */
+	unsigned int type; 	/* MSCAN type variants */
 	long open_time;
 	unsigned long flags;
 	void __iomem *reg_base;	/* ioremap'ed address to registers */
@@ -285,12 +296,7 @@ struct mscan_priv {
 };
 
 extern struct net_device *alloc_mscandev(void);
-/*
- * clock_src:
- *	1 = The MSCAN clock source is the onchip Bus Clock.
- *	0 = The MSCAN clock source is the chip Oscillator Clock.
- */
-extern int register_mscandev(struct net_device *dev, int clock_src);
+extern int register_mscandev(struct net_device *dev, int mscan_clksrc);
 extern void unregister_mscandev(struct net_device *dev);
 
 #endif /* __MSCAN_H__ */
-- 
1.6.2.5

