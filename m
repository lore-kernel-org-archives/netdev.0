From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/3] ns83820: move eeprom.h and clean up
Date: Fri, 15 Oct 2004 15:44:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015154400.11611d9b@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The file linux/eeprom.h was only being used by the ns83820 driver,
and it contained non-inline functions in a .h file.  This patch 
fixes that and:
	* Only two functions are actually used (and only used once)
	  so ditch the rest and make those inline.
	* EEprom is in iomemory space so get rid of the warnings.
	
Compiles but I don't have this hardware, so it has not been tested.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	2004-10-15 15:30:10 -07:00
+++ b/drivers/net/ns83820.c	2004-10-15 15:30:10 -07:00
@@ -107,7 +107,6 @@
 #include <linux/init.h>
 #include <linux/ip.h>	/* for iph */
 #include <linux/in.h>	/* for IPPROTO_... */
-#include <linux/eeprom.h>
 #include <linux/compiler.h>
 #include <linux/prefetch.h>
 #include <linux/ethtool.h>
@@ -118,6 +117,8 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
+#include "ns83820_eeprom.h"
+
 #define DRV_NAME "ns83820"
 
 /* Global parameters.  See module_param near the bottom. */
@@ -1897,8 +1898,8 @@
 
 	dev->IMR_cache = 0;
 
-	setup_ee_mem_bitbanger(&dev->ee, (long)dev->base + MEAR, 3, 2, 1, 0,
-		0);
+	setup_ee_mem_bitbanger(&dev->ee, (void __iomem *)dev->base + MEAR, 
+			       3, 2, 1, 0, 0);
 
 	err = request_irq(pci_dev->irq, ns83820_irq, SA_SHIRQ,
 			  DRV_NAME, ndev);
diff -Nru a/drivers/net/ns83820_eeprom.h b/drivers/net/ns83820_eeprom.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/ns83820_eeprom.h	2004-10-15 15:30:10 -07:00
@@ -0,0 +1,72 @@
+/* credit winbond-840.c
+ */
+#include <asm/io.h>
+struct eeprom_ops {
+	void	(*set_cs)(void *ee);
+	void	(*clear_cs)(void *ee);
+};
+
+#define EEPOL_EEDI	0x01
+#define EEPOL_EEDO	0x02
+#define EEPOL_EECLK	0x04
+#define EEPOL_EESEL	0x08
+
+struct eeprom {
+	void *dev;
+	struct eeprom_ops *ops;
+
+	void __iomem    *addr;
+
+	unsigned	ee_addr_bits;
+
+	unsigned	eesel;
+	unsigned	eeclk;
+	unsigned	eedo;
+	unsigned	eedi;
+	unsigned	polarity;
+	unsigned	ee_state;
+
+	spinlock_t	*lock;
+	u32		*cache;
+};
+
+/* The EEPROM commands include the alway-set leading bit. */
+enum EEPROM_Cmds {
+        EE_WriteCmd=(5 << 6), EE_ReadCmd=(6 << 6), EE_EraseCmd=(7 << 6),
+};
+
+static inline void setup_ee_mem_bitbanger(struct eeprom *ee, 
+					  void __iomem *memaddr, 
+					  int eesel_bit, int eeclk_bit, 
+					  int eedo_bit, int eedi_bit, 
+					  unsigned polarity)
+{
+	ee->addr = memaddr;
+	ee->eesel = 1 << eesel_bit;
+	ee->eeclk = 1 << eeclk_bit;
+	ee->eedo = 1 << eedo_bit;
+	ee->eedi = 1 << eedi_bit;
+
+	ee->polarity = polarity;
+
+	*ee->cache = readl(ee->addr);
+}
+
+/* foo. put this in a .c file */
+static inline void eeprom_update(struct eeprom *ee, u32 mask, int pol)
+{
+	unsigned long flags;
+	u32 data;
+
+	spin_lock_irqsave(ee->lock, flags);
+	data = *ee->cache;
+
+	data &= ~mask;
+	if (pol)
+		data |= mask;
+
+	*ee->cache = data;
+//printk("update: %08x\n", data);
+	writel(data, ee->addr);
+	spin_unlock_irqrestore(ee->lock, flags);
+}
diff -Nru a/include/linux/eeprom.h b/include/linux/eeprom.h
--- a/include/linux/eeprom.h	2004-10-15 15:30:10 -07:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,136 +0,0 @@
-/* credit winbond-840.c
- */
-#include <asm/io.h>
-struct eeprom_ops {
-	void	(*set_cs)(void *ee);
-	void	(*clear_cs)(void *ee);
-};
-
-#define EEPOL_EEDI	0x01
-#define EEPOL_EEDO	0x02
-#define EEPOL_EECLK	0x04
-#define EEPOL_EESEL	0x08
-
-struct eeprom {
-	void *dev;
-	struct eeprom_ops *ops;
-
-	long		addr;
-
-	unsigned	ee_addr_bits;
-
-	unsigned	eesel;
-	unsigned	eeclk;
-	unsigned	eedo;
-	unsigned	eedi;
-	unsigned	polarity;
-	unsigned	ee_state;
-
-	spinlock_t	*lock;
-	u32		*cache;
-};
-
-
-u8   eeprom_readb(struct eeprom *ee, unsigned address);
-void eeprom_read(struct eeprom *ee, unsigned address, u8 *bytes,
-		unsigned count);
-void eeprom_writeb(struct eeprom *ee, unsigned address, u8 data);
-void eeprom_write(struct eeprom *ee, unsigned address, u8 *bytes,
-		unsigned count);
-
-/* The EEPROM commands include the alway-set leading bit. */
-enum EEPROM_Cmds {
-        EE_WriteCmd=(5 << 6), EE_ReadCmd=(6 << 6), EE_EraseCmd=(7 << 6),
-};
-
-void setup_ee_mem_bitbanger(struct eeprom *ee, long memaddr, int eesel_bit, int eeclk_bit, int eedo_bit, int eedi_bit, unsigned polarity)
-{
-	ee->addr = memaddr;
-	ee->eesel = 1 << eesel_bit;
-	ee->eeclk = 1 << eeclk_bit;
-	ee->eedo = 1 << eedo_bit;
-	ee->eedi = 1 << eedi_bit;
-
-	ee->polarity = polarity;
-
-	*ee->cache = readl(ee->addr);
-}
-
-/* foo. put this in a .c file */
-static inline void eeprom_update(struct eeprom *ee, u32 mask, int pol)
-{
-	unsigned long flags;
-	u32 data;
-
-	spin_lock_irqsave(ee->lock, flags);
-	data = *ee->cache;
-
-	data &= ~mask;
-	if (pol)
-		data |= mask;
-
-	*ee->cache = data;
-//printk("update: %08x\n", data);
-	writel(data, ee->addr);
-	spin_unlock_irqrestore(ee->lock, flags);
-}
-
-void eeprom_clk_lo(struct eeprom *ee)
-{
-	int pol = !!(ee->polarity & EEPOL_EECLK);
-
-	eeprom_update(ee, ee->eeclk, pol);
-	udelay(2);
-}
-
-void eeprom_clk_hi(struct eeprom *ee)
-{
-	int pol = !!(ee->polarity & EEPOL_EECLK);
-
-	eeprom_update(ee, ee->eeclk, !pol);
-	udelay(2);
-}
-
-void eeprom_send_addr(struct eeprom *ee, unsigned address)
-{
-	int pol = !!(ee->polarity & EEPOL_EEDI);
-	unsigned i;
-	address |= 6 << 6;
-
-        /* Shift the read command bits out. */
-        for (i=0; i<11; i++) {
-		eeprom_update(ee, ee->eedi, ((address >> 10) & 1) ^ pol);
-		address <<= 1;
-		eeprom_clk_hi(ee);
-		eeprom_clk_lo(ee);
-        }
-	eeprom_update(ee, ee->eedi, pol);
-}
-
-u16   eeprom_readw(struct eeprom *ee, unsigned address)
-{
-	unsigned i;
-	u16	res = 0;
-
-	eeprom_clk_lo(ee);
-	eeprom_update(ee, ee->eesel, 1 ^ !!(ee->polarity & EEPOL_EESEL));
-	eeprom_send_addr(ee, address);
-
-	for (i=0; i<16; i++) {
-		u32 data;
-		eeprom_clk_hi(ee);
-		res <<= 1;
-		data = readl(ee->addr);
-//printk("eeprom_readw: %08x\n", data);
-		res |= !!(data & ee->eedo) ^ !!(ee->polarity & EEPOL_EEDO);
-		eeprom_clk_lo(ee);
-	}
-	eeprom_update(ee, ee->eesel, 0 ^ !!(ee->polarity & EEPOL_EESEL));
-
-	return res;
-}
-
-
-void eeprom_writeb(struct eeprom *ee, unsigned address, u8 data)
-{
-}
