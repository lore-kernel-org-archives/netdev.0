From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH v2] net: smc91x: fix SMC accesses
Date: Sat, 27 Aug 2016 17:33:03 +0100
Message-ID: <E1bdgXX-0005I4-1N@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, Daniel Mack <daniel@zonque.org>,
        Haojian Zhuang <haojian.zhuang@gmail.com>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Steven Miao <realmz6@gmail.com>,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org,
        Nicolas Pitre <nico@fluxnic.net>,
        Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:42990 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754710AbcH0Qd1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 12:33:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b70661c70830 ("net: smc91x: use run-time configuration on all ARM
machines") broke some ARM platforms through several mistakes.  Firstly,
the access size must correspond to the following rule:

(a) at least one of 16-bit or 8-bit access size must be supported
(b) 32-bit accesses are optional, and may be enabled in addition to
    the above.

Secondly, it provides no emulation of 16-bit accesses, instead blindly
making 16-bit accesses even when the platform specifies that only 8-bit
is supported.

Reorganise smc91x.h so we can make use of the existing 16-bit access
emulation already provided - if 16-bit accesses are supported, use
16-bit accesses directly, otherwise if 8-bit accesses are supported,
use the provided 16-bit access emulation.  If neither, BUG().  This
exactly reflects the driver behaviour prior to the commit being fixed.

Since the conversion incorrectly cut down the available access sizes on
several platforms, we also need to go through every platform and fix up
the overly-restrictive access size: Arnd assumed that if a platform can
perform 32-bit, 16-bit and 8-bit accesses, then only a 32-bit access
size needed to be specified - not so, all available access sizes must
be specified.

This likely fixes some performance regressions in doing this: if a
platform does not support 8-bit accesses, 8-bit accesses have been
emulated by performing a 16-bit read-modify-write access.

Tested on the Intel Assabet/Neponset platform, which supports only 8-bit
accesses, which was broken by the original commit.

Fixes: b70661c70830 ("net: smc91x: use run-time configuration on all ARM machines")
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
Robert, this is the full patch - can I add your tested-by to this for
the subset patch please?

Nico, I'd appreciate at least an acked-by from you as an approval for
this approach and to confirm that what I've said above is correct.
I'm not asking for you to test it.

Thanks.

Sorry, v2 against mainline rather than with some of my other SMC91x
changes.  Please ignore the previous version.

 arch/arm/mach-pxa/idp.c                    |  3 +-
 arch/arm/mach-pxa/xcep.c                   |  3 +-
 arch/arm/mach-realview/core.c              |  3 +-
 arch/arm/mach-sa1100/pleb.c                |  2 +-
 arch/blackfin/mach-bf561/boards/cm_bf561.c |  3 +-
 arch/blackfin/mach-bf561/boards/ezkit.c    |  3 +-
 drivers/net/ethernet/smsc/smc91x.c         |  7 ++++
 drivers/net/ethernet/smsc/smc91x.h         | 65 +++++++++++++++++++++---------
 include/linux/smc91x.h                     | 10 +++++
 9 files changed, 73 insertions(+), 26 deletions(-)

diff --git a/arch/arm/mach-pxa/idp.c b/arch/arm/mach-pxa/idp.c
index c410d84b243d..66070acaa888 100644
--- a/arch/arm/mach-pxa/idp.c
+++ b/arch/arm/mach-pxa/idp.c
@@ -83,7 +83,8 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_32BIT | SMC91X_USE_DMA | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_USE_DMA | SMC91X_NOWAIT,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-pxa/xcep.c b/arch/arm/mach-pxa/xcep.c
index 3f06cd90567a..056369ef250e 100644
--- a/arch/arm/mach-pxa/xcep.c
+++ b/arch/arm/mach-pxa/xcep.c
@@ -120,7 +120,8 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata xcep_smc91x_info = {
-	.flags	= SMC91X_USE_32BIT | SMC91X_NOWAIT | SMC91X_USE_DMA,
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		  SMC91X_NOWAIT | SMC91X_USE_DMA,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index baf174542e36..a0ead0ae23d6 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -93,7 +93,8 @@ static struct smsc911x_platform_config smsc911x_config = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 };
 
 static struct platform_device realview_eth_device = {
diff --git a/arch/arm/mach-sa1100/pleb.c b/arch/arm/mach-sa1100/pleb.c
index 1525d7b5f1b7..88149f85bc49 100644
--- a/arch/arm/mach-sa1100/pleb.c
+++ b/arch/arm/mach-sa1100/pleb.c
@@ -45,7 +45,7 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_16BIT | SMC91X_USE_8BIT | SMC91X_NOWAIT,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/blackfin/mach-bf561/boards/cm_bf561.c b/arch/blackfin/mach-bf561/boards/cm_bf561.c
index c6db52ba3a06..10c57771822d 100644
--- a/arch/blackfin/mach-bf561/boards/cm_bf561.c
+++ b/arch/blackfin/mach-bf561/boards/cm_bf561.c
@@ -146,7 +146,8 @@ static struct platform_device hitachi_fb_device = {
 #include <linux/smc91x.h>
 
 static struct smc91x_platdata smc91x_info = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 	.leda = RPC_LED_100_10,
 	.ledb = RPC_LED_TX_RX,
 };
diff --git a/arch/blackfin/mach-bf561/boards/ezkit.c b/arch/blackfin/mach-bf561/boards/ezkit.c
index f35525b55819..57d1c43726d9 100644
--- a/arch/blackfin/mach-bf561/boards/ezkit.c
+++ b/arch/blackfin/mach-bf561/boards/ezkit.c
@@ -134,7 +134,8 @@ static struct platform_device net2272_bfin_device = {
 #include <linux/smc91x.h>
 
 static struct smc91x_platdata smc91x_info = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 	.leda = RPC_LED_100_10,
 	.ledb = RPC_LED_TX_RX,
 };
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 726b80f45906..503a3b6dce91 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2275,6 +2275,13 @@ static int smc_drv_probe(struct platform_device *pdev)
 	if (pd) {
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 		lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
+
+		if (!SMC_8BIT(lp) && !SMC_16BIT(lp)) {
+			dev_err(&pdev->dev,
+				"at least one of 8-bit or 16-bit access support is required.\n");
+			ret = -ENXIO;
+			goto out_free_netdev;
+		}
 	}
 
 #if IS_BUILTIN(CONFIG_OF)
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 1a55c7976df0..e17671c9d1b0 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -37,6 +37,27 @@
 #include <linux/smc91x.h>
 
 /*
+ * Any 16-bit access is performed with two 8-bit accesses if the hardware
+ * can't do it directly. Most registers are 16-bit so those are mandatory.
+ */
+#define SMC_outw_b(x, a, r)						\
+	do {								\
+		unsigned int __val16 = (x);				\
+		unsigned int __reg = (r);				\
+		SMC_outb(__val16, a, __reg);				\
+		SMC_outb(__val16 >> 8, a, __reg + (1 << SMC_IO_SHIFT));	\
+	} while (0)
+
+#define SMC_inw_b(a, r)							\
+	({								\
+		unsigned int __val16;					\
+		unsigned int __reg = r;					\
+		__val16  = SMC_inb(a, __reg);				\
+		__val16 |= SMC_inb(a, __reg + (1 << SMC_IO_SHIFT)) << 8; \
+		__val16;						\
+	})
+
+/*
  * Define your architecture specific bus configuration parameters here.
  */
 
@@ -55,10 +76,30 @@
 #define SMC_IO_SHIFT		(lp->io_shift)
 
 #define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_inw(a, r)							\
+	({								\
+		unsigned int __smc_r = r;				\
+		SMC_16BIT(lp) ? readw((a) + __smc_r) :			\
+		SMC_8BIT(lp) ? SMC_inw_b(a, __smc_r) :			\
+		({ BUG(); 0; });					\
+	})
+
 #define SMC_inl(a, r)		readl((a) + (r))
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)						\
+	do {								\
+		unsigned int __v = v, __smc_r = r;			\
+		if (SMC_16BIT(lp))					\
+			__SMC_outw(__v, a, __smc_r);			\
+		else if (SMC_8BIT(lp))					\
+			SMC_outw_b(__v, a, __smc_r);			\
+		else							\
+			BUG();						\
+	} while (0)
+
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insb(a, r, p, l)	readsb((a) + (r), p, l)
+#define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, l)
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
@@ -66,7 +107,7 @@
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
 /* We actually can't write halfwords properly if not word aligned */
-static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
+static inline void __SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 {
 	if ((machine_is_mainstone() || machine_is_stargate2() ||
 	     machine_is_pxa_idp()) && reg & 2) {
@@ -416,24 +457,8 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 
 #if ! SMC_CAN_USE_16BIT
 
-/*
- * Any 16-bit access is performed with two 8-bit accesses if the hardware
- * can't do it directly. Most registers are 16-bit so those are mandatory.
- */
-#define SMC_outw(x, ioaddr, reg)					\
-	do {								\
-		unsigned int __val16 = (x);				\
-		SMC_outb( __val16, ioaddr, reg );			\
-		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
-	} while (0)
-#define SMC_inw(ioaddr, reg)						\
-	({								\
-		unsigned int __val16;					\
-		__val16 =  SMC_inb( ioaddr, reg );			\
-		__val16 |= SMC_inb( ioaddr, reg + (1 << SMC_IO_SHIFT)) << 8; \
-		__val16;						\
-	})
-
+#define SMC_outw(x, ioaddr, reg)	SMC_outw_b(x, ioaddr, reg)
+#define SMC_inw(ioaddr, reg)		SMC_inw_b(ioaddr, reg)
 #define SMC_insw(a, r, p, l)		BUG()
 #define SMC_outsw(a, r, p, l)		BUG()
 
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 76199b75d584..e302c447e057 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -1,6 +1,16 @@
 #ifndef __SMC91X_H__
 #define __SMC91X_H__
 
+/*
+ * These bits define which access sizes a platform can support, rather
+ * than the maximal access size.  So, if your platform can do 16-bit
+ * and 32-bit accesses to the SMC91x device, but not 8-bit, set both
+ * SMC91X_USE_16BIT and SMC91X_USE_32BIT.
+ *
+ * The SMC91x driver requires at least one of SMC91X_USE_8BIT or
+ * SMC91X_USE_16BIT to be supported - just setting SMC91X_USE_32BIT is
+ * an invalid configuration.
+ */
 #define SMC91X_USE_8BIT (1 << 0)
 #define SMC91X_USE_16BIT (1 << 1)
 #define SMC91X_USE_32BIT (1 << 2)
-- 
2.1.0
