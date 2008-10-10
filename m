From: Guennadi Liakhovetski <lg@denx.de>
Subject: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sat, 11 Oct 2008 01:33:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810110125540.10196@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
 <87vdx5gjzo.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37482 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751033AbYJJXdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 19:33:16 -0400
In-Reply-To: <87vdx5gjzo.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN921x controllers from SMSC register cmpatible with LAN911x chips, the 
driver only needs to recognise respective chip IDs. Patch also adds 
network support for the pcm037 board, using this chip.

Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

---

This is an RFC just to let everyone comment on it, it probably would also 
be better to split it into two patches - one only for drivers/net and one 
for arch/arm plus the Kconfig hunk. Based on 2.6.27, would be nice to get 
it into 2.6.28. The CC-list is kept from the previous discussion regarding 
this driver-extension.

diff --git a/arch/arm/mach-mx3/pcm037.c b/arch/arm/mach-mx3/pcm037.c
index df8582a..cd3f3c2 100644
--- a/arch/arm/mach-mx3/pcm037.c
+++ b/arch/arm/mach-mx3/pcm037.c
@@ -22,6 +22,9 @@
 #include <linux/platform_device.h>
 #include <linux/mtd/physmap.h>
 #include <linux/memory.h>
+#include <linux/interrupt.h>
+#include <linux/gpio.h>
+#include <linux/smc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -57,8 +60,37 @@ static struct imxuart_platform_data uart_pdata = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
 
+static struct resource smc911x_resources[] = {
+	[0] = {
+		.start		= CS1_BASE_ADDR + 0x300,
+		.end		= CS1_BASE_ADDR + 0x300 + SZ_64K - 1,
+		.flags		= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
+		.end		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct smc911x_platdata smc911x_info = {
+	.flags		= SMC911X_USE_32BIT,
+	.irq_flags	= IRQF_SHARED | IRQF_TRIGGER_LOW,
+};
+
+static struct platform_device pcm037_eth = {
+	.name		= "smc911x",
+	.id		= -1,
+	.num_resources	= ARRAY_SIZE(smc911x_resources),
+	.resource	= smc911x_resources,
+	.dev		= {
+		.platform_data = &smc911x_info,
+	},
+};
+
 static struct platform_device *devices[] __initdata = {
 	&pcm037_flash,
+	&pcm037_eth,
 };
 
 /*
@@ -79,6 +111,11 @@ static void __init mxc_board_init(void)
 	mxc_iomux_mode(MX31_PIN_CSPI3_MISO__TXD3);
 
 	imx_init_uart(2, &uart_pdata);
+
+	/* SMSC9215 IRQ pin */
+	mxc_iomux_mode(IOMUX_MODE(MX31_PIN_GPIO3_1, IOMUX_CONFIG_GPIO));
+	if (!gpio_request(MX31_PIN_GPIO3_1, "pcm037-eth"))
+		gpio_direction_input(MX31_PIN_GPIO3_1);
 }
 
 /*
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4a11296..c741627 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -960,7 +960,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SUPERH
+	depends on ARCH_PXA || ARCH_MX3 || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index c587162..95b9bfa 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -685,8 +685,10 @@ static void smc911x_phy_detect(struct net_device *dev)
 	 * PHY#1 to PHY#31, and then PHY#0 last.
 	 */
 	switch(lp->version) {
-		case 0x115:
-		case 0x117:
+		case 0x0115:
+		case 0x0117:
+		case 0x115A:
+		case 0x117A:
 			cfg = SMC_GET_HW_CFG(lp);
 			if (cfg & HW_CFG_EXT_PHY_DET_) {
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
@@ -722,6 +724,9 @@ static void smc911x_phy_detect(struct net_device *dev)
 						break;
 					}
 				}
+				if (phyaddr < 32)
+					/* Found an external PHY */
+					break;
 			}
 		default:
 			/* Internal media only */
@@ -992,7 +997,7 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 
 	smc911x_phy_check_media(dev, 0);
 	/* read to clear status bits */
-	SMC_GET_PHY_INT_SRC(lp, phyaddr,status);
+	SMC_GET_PHY_INT_SRC(lp, phyaddr, status);
 	DBG(SMC_DEBUG_MISC, "%s: PHY interrupt status 0x%04x\n",
 		dev->name, status & 0xffff);
 	DBG(SMC_DEBUG_MISC, "%s: AFC_CFG 0x%08x\n",
@@ -1030,7 +1035,6 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	/* set a timeout value, so I don't stay here forever */
 	timeout = 8;
 
-
 	do {
 		status = SMC_GET_INT(lp);
 
@@ -1169,12 +1173,10 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	/* restore mask state */
 	SMC_SET_INT_EN(lp, mask);
 
-	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
-		dev->name, 8-timeout);
-
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
+	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
+		dev->name, 8-timeout);
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 2abfc28..d7a7ca3 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -666,10 +666,14 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 #define LAN911X_INTERNAL_PHY_ID		(0x0007C000)
 
 /* Chip ID values */
-#define CHIP_9115	0x115
-#define CHIP_9116	0x116
-#define CHIP_9117	0x117
-#define CHIP_9118	0x118
+#define CHIP_9115	0x0115
+#define CHIP_9116	0x0116
+#define CHIP_9117	0x0117
+#define CHIP_9118	0x0118
+#define CHIP_9215	0x115A
+#define CHIP_9216	0x116A
+#define CHIP_9217	0x117A
+#define CHIP_9218	0x118A
 
 struct chip_id {
 	u16 id;
@@ -681,6 +685,10 @@ static const struct chip_id chip_ids[] =  {
 	{ CHIP_9116, "LAN9116" },
 	{ CHIP_9117, "LAN9117" },
 	{ CHIP_9118, "LAN9118" },
+	{ CHIP_9215, "LAN9215" },
+	{ CHIP_9216, "LAN9216" },
+	{ CHIP_9217, "LAN9217" },
+	{ CHIP_9218, "LAN9218" },
 	{ 0, NULL },
 };
 
