From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] cirrus: cs89x0: remove two obsolete Kconfig macros
Date: Fri, 29 Mar 2013 11:51:30 +0100
Message-ID: <1364554290.1345.52.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_ARCH_IXDP2X01 and CONFIG_MACH_IXDP2351 Kconfig macros are
unused since the ixp23xx and ixp2000 platforms were removed in v3.5. So
remove the last code still depending on these macros. And since
CS89x0_NONISA_IRQ was only set if either of these two macros was defined
we can also remove that macro and the code depending on it.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Compile tested only, for 32 bit x86. (Which was slightly more work than
I expected, since Fedora - which I happen to run - has ISA disabled as
of Fedora 17. And I use their configuration as base for my local setups.
Do other distributions also disable ISA by default?)

 drivers/net/ethernet/cirrus/cs89x0.c | 54 +-----------------------------------
 1 file changed, 1 insertion(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 1384469..8f90eca 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -101,23 +101,6 @@ static char version[] __initdata =
  * them to system IRQ numbers. This mapping is card specific and is set to
  * the configuration of the Cirrus Eval board for this chip.
  */
-#if defined(CONFIG_MACH_IXDP2351)
-#define CS89x0_NONISA_IRQ
-static unsigned int netcard_portlist[] __used __initdata = {
-	IXDP2351_VIRT_CS8900_BASE, 0
-};
-static unsigned int cs8900_irq_map[] = {
-	IRQ_IXDP2351_CS8900, 0, 0, 0
-};
-#elif defined(CONFIG_ARCH_IXDP2X01)
-#define CS89x0_NONISA_IRQ
-static unsigned int netcard_portlist[] __used __initdata = {
-	IXDP2X01_CS8900_VIRT_BASE, 0
-};
-static unsigned int cs8900_irq_map[] = {
-	IRQ_IXDP2X01_CS8900, 0, 0, 0
-};
-#else
 #ifndef CONFIG_CS89x0_PLATFORM
 static unsigned int netcard_portlist[] __used __initdata = {
 	0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240,
@@ -127,7 +110,6 @@ static unsigned int cs8900_irq_map[] = {
 	10, 11, 12, 5
 };
 #endif
-#endif
 
 #if DEBUGGING
 static unsigned int net_debug = DEBUGGING;
@@ -210,32 +192,6 @@ static int __init media_fn(char *str)
 __setup("cs89x0_media=", media_fn);
 #endif
 
-#if defined(CONFIG_MACH_IXDP2351)
-static u16
-readword(unsigned long base_addr, int portno)
-{
-	return __raw_readw(base_addr + (portno << 1));
-}
-
-static void
-writeword(unsigned long base_addr, int portno, u16 value)
-{
-	__raw_writew(value, base_addr + (portno << 1));
-}
-#elif defined(CONFIG_ARCH_IXDP2X01)
-static u16
-readword(unsigned long base_addr, int portno)
-{
-	return __raw_readl(base_addr + (portno << 1));
-}
-
-static void
-writeword(unsigned long base_addr, int portno, u16 value)
-{
-	__raw_writel(value, base_addr + (portno << 1));
-}
-#endif
-
 static void readwords(struct net_local *lp, int portno, void *buf, int length)
 {
 	u8 *buf8 = (u8 *)buf;
@@ -908,7 +864,7 @@ net_open(struct net_device *dev)
 			goto bad_out;
 		}
 	} else {
-#if !defined(CS89x0_NONISA_IRQ) && !defined(CONFIG_CS89x0_PLATFORM)
+#if !defined(CONFIG_CS89x0_PLATFORM)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			pr_err("%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
 			       dev->name, dev->irq, lp->irq_map);
@@ -1321,9 +1277,7 @@ static const struct net_device_ops net_ops = {
 static void __init reset_chip(struct net_device *dev)
 {
 #if !defined(CONFIG_MACH_MX31ADS)
-#if !defined(CS89x0_NONISA_IRQ)
 	struct net_local *lp = netdev_priv(dev);
-#endif /* CS89x0_NONISA_IRQ */
 	int reset_start_time;
 
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
@@ -1331,7 +1285,6 @@ static void __init reset_chip(struct net_device *dev)
 	/* wait 30 ms */
 	msleep(30);
 
-#if !defined(CS89x0_NONISA_IRQ)
 	if (lp->chip_type != CS8900) {
 		/* Hardware problem requires PNP registers to be reconfigured after a reset */
 		iowrite16(PP_CS8920_ISAINT, lp->virt_addr + ADD_PORT);
@@ -1344,7 +1297,6 @@ static void __init reset_chip(struct net_device *dev)
 		iowrite8((dev->mem_start >> 8) & 0xff,
 			 lp->virt_addr + DATA_PORT + 1);
 	}
-#endif /* CS89x0_NONISA_IRQ */
 
 	/* Wait until the chip is reset */
 	reset_start_time = jiffies;
@@ -1579,9 +1531,6 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 		i = lp->isa_config & INT_NO_MASK;
 #ifndef CONFIG_CS89x0_PLATFORM
 		if (lp->chip_type == CS8900) {
-#ifdef CS89x0_NONISA_IRQ
-			i = cs8900_irq_map[0];
-#else
 			/* Translate the IRQ using the IRQ mapping table. */
 			if (i >= ARRAY_SIZE(cs8900_irq_map))
 				pr_err("invalid ISA interrupt number %d\n", i);
@@ -1599,7 +1548,6 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 					lp->irq_map = ((irq_map_buff[0] >> 8) |
 						       (irq_map_buff[1] << 8));
 			}
-#endif
 		}
 #endif
 		if (!dev->irq)
-- 
1.7.11.7
