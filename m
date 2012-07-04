From: <gerg@snapgear.com>
Subject: [PATCH v2 2/2] net: add support for NS8390 based eth controllers on some ColdFire CPU boards
Date: Thu, 5 Jul 2012 09:50:00 +1000
Message-ID: <1341445800-396-3-git-send-email-gerg@snapgear.com>
References: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Ungerer <gerg@uclinux.org>
To: <netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Ungerer <gerg@uclinux.org>

A number of older ColdFire CPU based boards use NS8390 based network
controllers. Most use the Davicom 9008F or the UMC 9008F. This driver
provides the support code to get these devices working on these platforms.

Generally the NS8390 based eth device is direct connected via the general
purpose bus of the ColdFire CPU. So its addressing and interrupt setup is
fixed on each of the different platforms (classic platform setup).

This driver is based on the other drivers/net/ethernet/8390 drivers, and
includes the lib8390.c code. It uses the existing definitions of the
board NS8390 device addresses, interrupts and access types from the
arch/m68k/include/asm/mcf8390.h, but moves the IO access functions into
the driver code and out of that header.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---
 arch/m68k/include/asm/mcf8390.h     |  129 +---------
 drivers/net/ethernet/8390/Kconfig   |   14 +
 drivers/net/ethernet/8390/Makefile  |    1 +
 drivers/net/ethernet/8390/mcf8390.c |  480 +++++++++++++++++++++++++++++++++++
 4 files changed, 504 insertions(+), 120 deletions(-)
 create mode 100644 drivers/net/ethernet/8390/mcf8390.c

diff --git a/arch/m68k/include/asm/mcf8390.h b/arch/m68k/include/asm/mcf8390.h
index bf3d97b..a72a208 100644
--- a/arch/m68k/include/asm/mcf8390.h
+++ b/arch/m68k/include/asm/mcf8390.h
@@ -37,6 +37,7 @@
 #if defined(CONFIG_ARN5206)
 #define NE2000_ADDR		0x40000300
 #define NE2000_ODDOFFSET	0x00010000
+#define NE2000_ADDRSIZE		0x00020000
 #define	NE2000_IRQ_VECTOR	0xf0
 #define	NE2000_IRQ_PRIORITY	2
 #define	NE2000_IRQ_LEVEL	4
@@ -46,6 +47,7 @@
 #if defined(CONFIG_M5206eC3)
 #define	NE2000_ADDR		0x40000300
 #define	NE2000_ODDOFFSET	0x00010000
+#define	NE2000_ADDRSIZE		0x00020000
 #define	NE2000_IRQ_VECTOR	0x1c
 #define	NE2000_IRQ_PRIORITY	2
 #define	NE2000_IRQ_LEVEL	4
@@ -54,6 +56,7 @@
 
 #if defined(CONFIG_M5206e) && defined(CONFIG_NETtel)
 #define NE2000_ADDR		0x30000300
+#define NE2000_ADDRSIZE		0x00001000
 #define NE2000_IRQ_VECTOR	25
 #define NE2000_IRQ_PRIORITY	1
 #define NE2000_IRQ_LEVEL	3
@@ -63,6 +66,7 @@
 #if defined(CONFIG_M5307C3)
 #define NE2000_ADDR		0x40000300
 #define NE2000_ODDOFFSET	0x00010000
+#define NE2000_ADDRSIZE		0x00020000
 #define NE2000_IRQ_VECTOR	0x1b
 #define	NE2000_BYTE		volatile unsigned short
 #endif
@@ -70,6 +74,7 @@
 #if defined(CONFIG_M5272) && defined(CONFIG_NETtel)
 #define NE2000_ADDR		0x30600300
 #define NE2000_ODDOFFSET	0x00008000
+#define NE2000_ADDRSIZE		0x00010000
 #define NE2000_IRQ_VECTOR	67
 #undef	BSWAP
 #define	BSWAP(w)		(w)
@@ -82,6 +87,7 @@
 #define NE2000_ADDR0		0x30600300
 #define NE2000_ADDR1		0x30800300
 #define NE2000_ODDOFFSET	0x00008000
+#define NE2000_ADDRSIZE		0x00010000
 #define NE2000_IRQ_VECTOR0	27
 #define NE2000_IRQ_VECTOR1	29
 #undef	BSWAP
@@ -94,6 +100,7 @@
 #if defined(CONFIG_M5307) && defined(CONFIG_SECUREEDGEMP3)
 #define NE2000_ADDR		0x30600300
 #define NE2000_ODDOFFSET	0x00008000
+#define NE2000_ADDRSIZE		0x00010000
 #define NE2000_IRQ_VECTOR	27
 #undef	BSWAP
 #define	BSWAP(w)		(w)
@@ -105,6 +112,7 @@
 #if defined(CONFIG_ARN5307)
 #define NE2000_ADDR		0xfe600300
 #define NE2000_ODDOFFSET	0x00010000
+#define NE2000_ADDRSIZE		0x00020000
 #define NE2000_IRQ_VECTOR	0x1b
 #define NE2000_IRQ_PRIORITY	2
 #define NE2000_IRQ_LEVEL	3
@@ -114,129 +122,10 @@
 #if defined(CONFIG_M5407C3)
 #define NE2000_ADDR		0x40000300
 #define NE2000_ODDOFFSET	0x00010000
+#define NE2000_ADDRSIZE		0x00020000
 #define NE2000_IRQ_VECTOR	0x1b
 #define	NE2000_BYTE		volatile unsigned short
 #endif
 
 /****************************************************************************/
-
-/*
- *	Side-band address space for odd address requires re-mapping
- *	many of the standard ISA access functions.
- */
-#ifdef NE2000_ODDOFFSET
-
-#undef outb
-#undef outb_p
-#undef inb
-#undef inb_p
-#undef outsb
-#undef outsw
-#undef insb
-#undef insw
-
-#define	outb	ne2000_outb
-#define	inb	ne2000_inb
-#define	outb_p	ne2000_outb
-#define	inb_p	ne2000_inb
-#define	outsb	ne2000_outsb
-#define	outsw	ne2000_outsw
-#define	insb	ne2000_insb
-#define	insw	ne2000_insw
-
-
-#ifndef COLDFIRE_NE2000_FUNCS
-
-void ne2000_outb(unsigned int val, unsigned int addr);
-int  ne2000_inb(unsigned int addr);
-void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len);
-void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len);
-void ne2000_outsb(unsigned int addr, void *vbuf, unsigned long len);
-void ne2000_outsw(unsigned int addr, void *vbuf, unsigned long len);
-
-#else
-
-/*
- *	This macro converts a conventional register address into the
- *	real memory pointer of the mapped NE2000 device.
- *	On most NE2000 implementations on ColdFire boards the chip is
- *	mapped in kinda funny, due to its ISA heritage.
- */
-#define	NE2000_PTR(addr)	((addr&0x1)?(NE2000_ODDOFFSET+addr-1):(addr))
-#define	NE2000_DATA_PTR(addr)	(addr)
-
-
-void ne2000_outb(unsigned int val, unsigned int addr)
-{
-	NE2000_BYTE	*rp;
-
-	rp = (NE2000_BYTE *) NE2000_PTR(addr);
-	*rp = RSWAP(val);
-}
-
-int ne2000_inb(unsigned int addr)
-{
-	NE2000_BYTE	*rp, val;
-
-	rp = (NE2000_BYTE *) NE2000_PTR(addr);
-	val = *rp;
-	return((int) ((NE2000_BYTE) RSWAP(val)));
-}
-
-void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len)
-{
-	NE2000_BYTE	*rp, val;
-	unsigned char	*buf;
-
-	buf = (unsigned char *) vbuf;
-	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		val = *rp;
-		*buf++ = RSWAP(val);
-	}
-}
-
-void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len)
-{
-	volatile unsigned short	*rp;
-	unsigned short		w, *buf;
-
-	buf = (unsigned short *) vbuf;
-	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		w = *rp;
-		*buf++ = BSWAP(w);
-	}
-}
-
-void ne2000_outsb(unsigned int addr, const void *vbuf, unsigned long len)
-{
-	NE2000_BYTE	*rp, val;
-	unsigned char	*buf;
-
-	buf = (unsigned char *) vbuf;
-	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		val = *buf++;
-		*rp = RSWAP(val);
-	}
-}
-
-void ne2000_outsw(unsigned int addr, const void *vbuf, unsigned long len)
-{
-	volatile unsigned short	*rp;
-	unsigned short		w, *buf;
-
-	buf = (unsigned short *) vbuf;
-	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		w = *buf++;
-		*rp = BSWAP(w);
-	}
-}
-
-#endif /* COLDFIRE_NE2000_FUNCS */
-#endif /* NE2000_OFFOFFSET */
-
-/****************************************************************************/
 #endif	/* mcf8390_h */
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 2e53867..e1219e0 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -162,6 +162,20 @@ config MAC8390
 	  and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
+config MCF8390
+	tristate "ColdFire NS8390 based Ethernet support"
+	depends on COLDFIRE
+	select CRC32
+	---help---
+	  This driver is for Ethernet devices using an NS8390-compatible
+	  chipset on many common ColdFire CPU based boards. Many of the older
+	  Freescale dev boards use this, and some other common boards like
+	  some SnapGear routers do as well.
+
+	  If you have one of these boards and want to use the network interface
+	  on them then choose Y. To compile this driver as a module, choose M
+	  here, the module will be called mcf8390.
+
 config NE2000
 	tristate "NE2000/NE1000 support"
 	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX)
diff --git a/drivers/net/ethernet/8390/Makefile b/drivers/net/ethernet/8390/Makefile
index d13790b..f43038b 100644
--- a/drivers/net/ethernet/8390/Makefile
+++ b/drivers/net/ethernet/8390/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
 obj-$(CONFIG_LNE390) += lne390.o 8390.o
+obj-$(CONFIG_MCF8390) += mcf8390.o 8390.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
new file mode 100644
index 0000000..230efd6
--- /dev/null
+++ b/drivers/net/ethernet/8390/mcf8390.c
@@ -0,0 +1,480 @@
+/*
+ *  Support for ColdFire CPU based boards using a NS8390 Ethernet device.
+ *
+ *  Derived from the many other 8390 drivers.
+ *
+ *  (C) Copyright 2012,  Greg Ungerer <gerg@uclinux.org>
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/jiffies.h>
+#include <linux/io.h>
+#include <asm/mcf8390.h>
+
+static const char version[] =
+	"mcf8390.c: (15-06-2012) Greg Ungerer <gerg@uclinux.org>";
+
+#define NE_CMD		0x00
+#define NE_DATAPORT	0x10	/* NatSemi-defined port window offset */
+#define NE_RESET	0x1f	/* Issue a read to reset ,a write to clear */
+#define NE_EN0_ISR	0x07
+#define NE_EN0_DCFG	0x0e
+#define NE_EN0_RSARLO	0x08
+#define NE_EN0_RSARHI	0x09
+#define NE_EN0_RCNTLO	0x0a
+#define NE_EN0_RXCR	0x0c
+#define NE_EN0_TXCR	0x0d
+#define NE_EN0_RCNTHI	0x0b
+#define NE_EN0_IMR	0x0f
+
+#define NESM_START_PG	0x40	/* First page of TX buffer */
+#define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
+
+#ifdef NE2000_ODDOFFSET
+/*
+ * A lot of the ColdFire boards use a separate address region for odd offset
+ * register addresses. The following functions convert and map as required.
+ * Note that the data port accesses are treated a little differently, and
+ * always accessed via the insX/outsX functions.
+ */
+static inline u32 NE_PTR(u32 addr)
+{
+	if (addr & 1)
+		return addr - 1 + NE2000_ODDOFFSET;
+	return addr;
+}
+
+static inline u32 NE_DATA_PTR(u32 addr)
+{
+	return addr;
+}
+
+void ei_outb(u32 val, u32 addr)
+{
+	NE2000_BYTE *rp;
+
+	rp = (NE2000_BYTE *) NE_PTR(addr);
+	*rp = RSWAP(val);
+}
+
+#define	ei_inb	ei_inb
+u8 ei_inb(u32 addr)
+{
+	NE2000_BYTE *rp, val;
+
+	rp = (NE2000_BYTE *) NE_PTR(addr);
+	val = *rp;
+	return (u8) (RSWAP(val) & 0xff);
+}
+
+void ei_insb(u32 addr, void *vbuf, int len)
+{
+	NE2000_BYTE *rp, val;
+	u8 *buf;
+
+	buf = (u8 *) vbuf;
+	rp = (NE2000_BYTE *) NE_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		val = *rp;
+		*buf++ = RSWAP(val);
+	}
+}
+
+void ei_insw(u32 addr, void *vbuf, int len)
+{
+	volatile u16 *rp;
+	u16 w, *buf;
+
+	buf = (u16 *) vbuf;
+	rp = (volatile u16 *) NE_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		w = *rp;
+		*buf++ = BSWAP(w);
+	}
+}
+
+void ei_outsb(u32 addr, const void *vbuf, int len)
+{
+	NE2000_BYTE *rp, val;
+	u8 *buf;
+
+	buf = (u8 *) vbuf;
+	rp = (NE2000_BYTE *) NE_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		val = *buf++;
+		*rp = RSWAP(val);
+	}
+}
+
+void ei_outsw(u32 addr, const void *vbuf, int len)
+{
+	volatile u16 *rp;
+	u16 w, *buf;
+
+	buf = (u16 *) vbuf;
+	rp = (volatile u16 *) NE_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		w = *buf++;
+		*rp = BSWAP(w);
+	}
+}
+
+#else /* !NE2000_ODDOFFSET */
+
+#define	ei_inb		inb
+#define	ei_outb		outb
+#define	ei_insb		insb
+#define	ei_insw		insw
+#define	ei_outsb	outsb
+#define	ei_outsw	outsw
+
+#endif /* !NE2000_ODDOFFSET */
+
+#define	ei_inb_p	ei_inb
+#define	ei_outb_p	ei_outb
+
+#include "lib8390.c"
+
+/*
+ * Hard reset the card. This used to pause for the same period that a
+ * 8390 reset command required, but that shouldn't be necessary.
+ */
+static void mcf8390_reset_8390(struct net_device *dev)
+{
+	unsigned long reset_start_time = jiffies;
+	u32 addr = dev->base_addr;
+
+	if (ei_debug > 1)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
+
+	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
+
+	ei_status.txing = 0;
+	ei_status.dmaing = 0;
+
+	/* This check _should_not_ be necessary, omit eventually. */
+	while ((ei_inb(addr + NE_EN0_ISR) & ENISR_RESET) == 0) {
+		if (time_after(jiffies, reset_start_time + 2 * HZ / 100)) {
+			netdev_warn(dev, "%s: did not complete\n", __func__);
+			break;
+		}
+	}
+
+	ei_outb(ENISR_RESET, addr + NE_EN0_ISR);
+}
+
+/*
+ * This *shouldn't* happen.
+ * If it does, it's the last thing you'll see
+ */
+static void mcf8390_dmaing_err(const char *func, struct net_device *dev,
+			       struct ei_device *ei_local)
+{
+	netdev_err(dev, "%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
+		func, ei_local->dmaing, ei_local->irqlock);
+}
+
+/*
+ * Grab the 8390 specific header. Similar to the block_input routine, but
+ * we don't need to be concerned with ring wrap as the header will be at
+ * the start of a page, so we optimize accordingly.
+ */
+static void mcf8390_get_8390_hdr(struct net_device *dev,
+				 struct e8390_pkt_hdr *hdr, int ring_page)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	u32 addr = dev->base_addr;
+
+	if (ei_local->dmaing) {
+		mcf8390_dmaing_err(__func__, dev, ei_local);
+		return;
+	}
+
+	ei_local->dmaing |= 0x01;
+	ei_outb(E8390_NODMA + E8390_PAGE0 + E8390_START, addr + NE_CMD);
+	ei_outb(ENISR_RDC, addr + NE_EN0_ISR);
+	ei_outb(sizeof(struct e8390_pkt_hdr), addr + NE_EN0_RCNTLO);
+	ei_outb(0, addr + NE_EN0_RCNTHI);
+	ei_outb(0, addr + NE_EN0_RSARLO);		/* On page boundary */
+	ei_outb(ring_page, addr + NE_EN0_RSARHI);
+	ei_outb(E8390_RREAD + E8390_START, addr + NE_CMD);
+
+	ei_insw(addr + NE_DATAPORT, hdr, sizeof(struct e8390_pkt_hdr) >> 1);
+
+	outb(ENISR_RDC, addr + NE_EN0_ISR);	/* Ack intr */
+	ei_local->dmaing &= ~0x01;
+
+	hdr->count = cpu_to_le16(hdr->count);
+}
+
+/*
+ * Block input and output, similar to the Crynwr packet driver.
+ * If you are porting to a new ethercard, look at the packet driver source
+ * for hints. The NEx000 doesn't share the on-board packet memory --
+ * you have to put the packet out through the "remote DMA" dataport
+ * using z_writeb.
+ */
+static void mcf8390_block_input(struct net_device *dev, int count,
+				struct sk_buff *skb, int ring_offset)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	u32 addr = dev->base_addr;
+	char *buf = skb->data;
+
+	if (ei_local->dmaing) {
+		mcf8390_dmaing_err(__func__, dev, ei_local);
+		return;
+	}
+
+	ei_local->dmaing |= 0x01;
+	ei_outb(E8390_NODMA + E8390_PAGE0 + E8390_START, addr + NE_CMD);
+	ei_outb(ENISR_RDC, addr + NE_EN0_ISR);
+	ei_outb(count & 0xff, addr + NE_EN0_RCNTLO);
+	ei_outb(count >> 8, addr + NE_EN0_RCNTHI);
+	ei_outb(ring_offset & 0xff, addr + NE_EN0_RSARLO);
+	ei_outb(ring_offset >> 8, addr + NE_EN0_RSARHI);
+	ei_outb(E8390_RREAD + E8390_START, addr + NE_CMD);
+
+	ei_insw(addr + NE_DATAPORT, buf, count >> 1);
+	if (count & 1)
+		buf[count - 1] = ei_inb(addr + NE_DATAPORT);
+
+	ei_outb(ENISR_RDC, addr + NE_EN0_ISR);	/* Ack intr */
+	ei_local->dmaing &= ~0x01;
+}
+
+static void mcf8390_block_output(struct net_device *dev, int count,
+				 const unsigned char *buf,
+				 const int start_page)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	u32 addr = dev->base_addr;
+	unsigned long dma_start;
+
+	/* Make sure we transfer all bytes if 16bit IO writes */
+	if (count & 0x1)
+		count++;
+
+	if (ei_local->dmaing) {
+		mcf8390_dmaing_err(__func__, dev, ei_local);
+		return;
+	}
+
+	ei_local->dmaing |= 0x01;
+	/* We should already be in page 0, but to be safe... */
+	ei_outb(E8390_PAGE0 + E8390_START + E8390_NODMA, addr + NE_CMD);
+
+	ei_outb(ENISR_RDC, addr + NE_EN0_ISR);
+
+	/* Now the normal output. */
+	ei_outb(count & 0xff, addr + NE_EN0_RCNTLO);
+	ei_outb(count >> 8, addr + NE_EN0_RCNTHI);
+	ei_outb(0x00, addr + NE_EN0_RSARLO);
+	ei_outb(start_page, addr + NE_EN0_RSARHI);
+	ei_outb(E8390_RWRITE + E8390_START, addr + NE_CMD);
+
+	ei_outsw(addr + NE_DATAPORT, buf, count >> 1);
+
+	dma_start = jiffies;
+	while ((ei_inb(addr + NE_EN0_ISR) & ENISR_RDC) == 0) {
+		if (time_after(jiffies, dma_start + 2 * HZ / 100)) { /* 20ms */
+			netdev_err(dev, "timeout waiting for Tx RDC\n");
+			mcf8390_reset_8390(dev);
+			__NS8390_init(dev, 1);
+			break;
+		}
+	}
+
+	ei_outb(ENISR_RDC, addr + NE_EN0_ISR);	/* Ack intr */
+	ei_local->dmaing &= ~0x01;
+}
+
+static const struct net_device_ops mcf8390_netdev_ops = {
+	.ndo_open		= __ei_open,
+	.ndo_stop		= __ei_close,
+	.ndo_start_xmit		= __ei_start_xmit,
+	.ndo_tx_timeout		= __ei_tx_timeout,
+	.ndo_get_stats		= __ei_get_stats,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= __ei_poll,
+#endif
+};
+
+static int mcf8390_init(struct net_device *dev)
+{
+	static u32 offsets[] = {
+		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+		0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+	};
+	struct ei_device *ei_local = netdev_priv(dev);
+	unsigned char SA_prom[32];
+	u32 addr = dev->base_addr;
+	int start_page, stop_page;
+	int i, ret;
+
+	mcf8390_reset_8390(dev);
+
+	/*
+	 * Read the 16 bytes of station address PROM.
+	 * We must first initialize registers,
+	 * similar to NS8390_init(eifdev, 0).
+	 * We can't reliably read the SAPROM address without this.
+	 * (I learned the hard way!).
+	 */
+	{
+		static const struct {
+			u32 value;
+			u32 offset;
+		} program_seq[] = {
+			{E8390_NODMA + E8390_PAGE0 + E8390_STOP, NE_CMD},
+						/* Select page 0 */
+			{0x48,	NE_EN0_DCFG},	/* 0x48: Set byte-wide access */
+			{0x00,	NE_EN0_RCNTLO},	/* Clear the count regs */
+			{0x00,	NE_EN0_RCNTHI},
+			{0x00,	NE_EN0_IMR},	/* Mask completion irq */
+			{0xFF,	NE_EN0_ISR},
+			{E8390_RXOFF, NE_EN0_RXCR}, /* 0x20 Set to monitor */
+			{E8390_TXOFF, NE_EN0_TXCR}, /* 0x02 and loopback mode */
+			{32,	NE_EN0_RCNTLO},
+			{0x00,	NE_EN0_RCNTHI},
+			{0x00,	NE_EN0_RSARLO},	/* DMA starting at 0x0000 */
+			{0x00,	NE_EN0_RSARHI},
+			{E8390_RREAD + E8390_START, NE_CMD},
+		};
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++) {
+			ei_outb(program_seq[i].value,
+				 addr + program_seq[i].offset);
+		}
+	}
+
+	for (i = 0; i < 16; i++) {
+		SA_prom[i] = ei_inb(addr + NE_DATAPORT);
+		ei_inb(addr + NE_DATAPORT);
+	}
+
+	/* We must set the 8390 for word mode. */
+	ei_outb(0x49, addr + NE_EN0_DCFG);
+	start_page = NESM_START_PG;
+	stop_page = NESM_STOP_PG;
+
+	/* Install the Interrupt handler */
+	ret = request_irq(dev->irq, __ei_interrupt, 0, dev->name, dev);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dev->dev_addr[i] = SA_prom[i];
+
+	netdev_dbg(dev, "Found ethernet address: %pM\n", dev->dev_addr);
+
+	ei_local->name = "mcf8390";
+	ei_local->tx_start_page = start_page;
+	ei_local->stop_page = stop_page;
+	ei_local->word16 = 1;
+	ei_local->rx_start_page = start_page + TX_PAGES;
+	ei_local->reset_8390 = mcf8390_reset_8390;
+	ei_local->block_input = mcf8390_block_input;
+	ei_local->block_output = mcf8390_block_output;
+	ei_local->get_8390_hdr = mcf8390_get_8390_hdr;
+	ei_local->reg_offset = offsets;
+
+	dev->netdev_ops = &mcf8390_netdev_ops;
+	__NS8390_init(dev, 0);
+	ret = register_netdev(dev);
+	if (ret) {
+		free_irq(dev->irq, dev);
+		return ret;
+	}
+
+	netdev_info(dev, "addr=0x%08x irq=%d, Ethernet Address %pM\n",
+		addr, dev->irq, dev->dev_addr);
+	return 0;
+}
+
+static int mcf8390_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct ei_device *ei_local;
+	struct resource *mem, *irq;
+	resource_size_t msize;
+	int ret;
+
+	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (irq == NULL) {
+		dev_err(&pdev->dev, "no IRQ specified?\n");
+		return -ENXIO;
+	}
+
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (mem == NULL) {
+		dev_err(&pdev->dev, "no memory address specified?\n");
+		return -ENXIO;
+	}
+	msize = resource_size(mem);
+	if (!request_mem_region(mem->start, msize, pdev->name))
+		return -EBUSY;
+
+	dev = ____alloc_ei_netdev(0);
+	if (dev == NULL) {
+		release_mem_region(mem->start, msize);
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);
+	ei_local = netdev_priv(dev);
+
+	dev->irq = irq->start;
+	dev->base_addr = mem->start;
+
+	ret = mcf8390_init(dev);
+	if (ret) {
+		release_mem_region(mem->start, msize);
+		free_netdev(dev);
+		return ret;
+	}
+	return 0;
+}
+
+static int mcf8390_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct resource *mem;
+
+	unregister_netdev(dev);
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (mem)
+		release_mem_region(mem->start, resource_size(mem));
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_driver mcf8390_drv = {
+	.driver = {
+		.name	= "mcf8390",
+		.owner	= THIS_MODULE,
+	},
+	.probe		= mcf8390_probe,
+	.remove		= mcf8390_remove,
+};
+
+module_platform_driver(mcf8390_drv);
+
+MODULE_DESCRIPTION("MCF8390 ColdFire NS8390 driver");
+MODULE_AUTHOR("Greg Ungerer <gerg@uclinux.org>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:mcf8390");
-- 
1.7.0.4
