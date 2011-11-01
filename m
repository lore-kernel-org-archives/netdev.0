From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH 16/18] net/irda: convert au1k_ir to platform driver.
Date: Tue,  1 Nov 2011 20:03:42 +0100
Message-ID: <1320174224-27305-17-git-send-email-manuel.lauss@googlemail.com>
References: <1320174224-27305-1-git-send-email-manuel.lauss@googlemail.com>
Cc: Manuel Lauss <manuel.lauss@googlemail.com>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: Linux-MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34155 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab1KATFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 15:05:03 -0400
Received: by mail-fx0-f46.google.com with SMTP id n17so6808348faa.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 12:05:02 -0700 (PDT)
In-Reply-To: <1320174224-27305-1-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moderate driver cleanup:
convert to platform driver, get rid of board-specific code.

Driver loads and runs on a DB1100 board.  But since I have no other
IrDA hardware to exchange data with I can't say whether it really sends
and receives.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
---
I'd like for this to go in via the MIPS tree since other mips patches depend
on it.

 arch/mips/include/asm/mach-au1x00/au1000.h |   52 +-
 drivers/net/irda/Kconfig                   |    6 +-
 drivers/net/irda/au1000_ircc.h             |  125 ---
 drivers/net/irda/au1k_ir.c                 | 1226 +++++++++++++++------------
 4 files changed, 700 insertions(+), 709 deletions(-)
 delete mode 100644 drivers/net/irda/au1000_ircc.h

diff --git a/arch/mips/include/asm/mach-au1x00/au1000.h b/arch/mips/include/asm/mach-au1x00/au1000.h
index 65f1262..569828d 100644
--- a/arch/mips/include/asm/mach-au1x00/au1000.h
+++ b/arch/mips/include/asm/mach-au1x00/au1000.h
@@ -1265,44 +1265,20 @@ enum soc_au1200_ints {
 #define SSI_ENABLE_CD		(1 << 1)
 #define SSI_ENABLE_E		(1 << 0)
 
-/* IrDA Controller */
-#define IRDA_BASE		0xB0300000
-#define IR_RING_PTR_STATUS	(IRDA_BASE + 0x00)
-#define IR_RING_BASE_ADDR_H	(IRDA_BASE + 0x04)
-#define IR_RING_BASE_ADDR_L	(IRDA_BASE + 0x08)
-#define IR_RING_SIZE		(IRDA_BASE + 0x0C)
-#define IR_RING_PROMPT		(IRDA_BASE + 0x10)
-#define IR_RING_ADDR_CMPR	(IRDA_BASE + 0x14)
-#define IR_INT_CLEAR		(IRDA_BASE + 0x18)
-#define IR_CONFIG_1		(IRDA_BASE + 0x20)
-#  define IR_RX_INVERT_LED	(1 << 0)
-#  define IR_TX_INVERT_LED	(1 << 1)
-#  define IR_ST 		(1 << 2)
-#  define IR_SF 		(1 << 3)
-#  define IR_SIR		(1 << 4)
-#  define IR_MIR		(1 << 5)
-#  define IR_FIR		(1 << 6)
-#  define IR_16CRC		(1 << 7)
-#  define IR_TD 		(1 << 8)
-#  define IR_RX_ALL		(1 << 9)
-#  define IR_DMA_ENABLE 	(1 << 10)
-#  define IR_RX_ENABLE		(1 << 11)
-#  define IR_TX_ENABLE		(1 << 12)
-#  define IR_LOOPBACK		(1 << 14)
-#  define IR_SIR_MODE		(IR_SIR | IR_DMA_ENABLE | \
-				 IR_RX_ALL | IR_RX_ENABLE | IR_SF | IR_16CRC)
-#define IR_SIR_FLAGS		(IRDA_BASE + 0x24)
-#define IR_ENABLE		(IRDA_BASE + 0x28)
-#  define IR_RX_STATUS		(1 << 9)
-#  define IR_TX_STATUS		(1 << 10)
-#define IR_READ_PHY_CONFIG	(IRDA_BASE + 0x2C)
-#define IR_WRITE_PHY_CONFIG	(IRDA_BASE + 0x30)
-#define IR_MAX_PKT_LEN		(IRDA_BASE + 0x34)
-#define IR_RX_BYTE_CNT		(IRDA_BASE + 0x38)
-#define IR_CONFIG_2		(IRDA_BASE + 0x3C)
-#  define IR_MODE_INV		(1 << 0)
-#  define IR_ONE_PIN		(1 << 1)
-#define IR_INTERFACE_CONFIG	(IRDA_BASE + 0x40)
+
+/*
+ * The IrDA peripheral has an IRFIRSEL pin, but on the DB/PB boards it's not
+ * used to select FIR/SIR mode on the transceiver but as a GPIO.  Instead a
+ * CPLD has to be told about the mode.
+ */
+#define AU1000_IRDA_PHY_MODE_OFF	0
+#define AU1000_IRDA_PHY_MODE_SIR	1
+#define AU1000_IRDA_PHY_MODE_FIR	2
+
+struct au1k_irda_platform_data {
+	void(*set_phy_mode)(int mode);
+};
+
 
 /* GPIO */
 #define SYS_PINFUNC		0xB190002C
diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index d423d18..e535137 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -313,8 +313,12 @@ config TOSHIBA_FIR
 	  donauboe.
 
 config AU1000_FIR
-	tristate "Alchemy Au1000 SIR/FIR"
+	tristate "Alchemy IrDA SIR/FIR"
 	depends on IRDA && MIPS_ALCHEMY
+	help
+	  Say Y/M here to build suppor the the IrDA peripheral on the
+	  Alchemy Au1000 and Au1100 SoCs.
+	  Say M to build a module; it will be called au1k_ir.ko
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
diff --git a/drivers/net/irda/au1000_ircc.h b/drivers/net/irda/au1000_ircc.h
deleted file mode 100644
index c072c09..0000000
--- a/drivers/net/irda/au1000_ircc.h
+++ /dev/null
@@ -1,125 +0,0 @@
-/*
- *
- * BRIEF MODULE DESCRIPTION
- *	Au1000 IrDA driver.
- *
- * Copyright 2001 MontaVista Software Inc.
- * Author: MontaVista Software, Inc.
- *         	ppopov@mvista.com or source@mvista.com
- *
- *  This program is free software; you can redistribute  it and/or modify it
- *  under  the terms of  the GNU General  Public License as published by the
- *  Free Software Foundation;  either version 2 of the  License, or (at your
- *  option) any later version.
- *
- *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
- *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
- *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
- *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
- *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
- *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
- *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- *  You should have received a copy of the  GNU General Public License along
- *  with this program; if not, write  to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#ifndef AU1000_IRCC_H
-#define AU1000_IRCC_H
-
-#include <linux/time.h>
-
-#include <linux/spinlock.h>
-#include <linux/pm.h>
-#include <asm/io.h>
-
-#define NUM_IR_IFF          1
-#define NUM_IR_DESC        64
-#define RING_SIZE_4       0x0
-#define RING_SIZE_16      0x3
-#define RING_SIZE_64      0xF
-#define MAX_NUM_IR_DESC    64
-#define MAX_BUF_SIZE     2048
-
-#define BPS_115200          0
-#define BPS_57600           1
-#define BPS_38400           2
-#define BPS_19200           5
-#define BPS_9600           11
-#define BPS_2400           47
-
-/* Ring descriptor flags */
-#define AU_OWN           (1<<7) /* tx,rx */
-
-#define IR_DIS_CRC       (1<<6) /* tx */
-#define IR_BAD_CRC       (1<<5) /* tx */
-#define IR_NEED_PULSE    (1<<4) /* tx */
-#define IR_FORCE_UNDER   (1<<3) /* tx */
-#define IR_DISABLE_TX    (1<<2) /* tx */
-#define IR_HW_UNDER      (1<<0) /* tx */
-#define IR_TX_ERROR      (IR_DIS_CRC|IR_BAD_CRC|IR_HW_UNDER)
-
-#define IR_PHY_ERROR     (1<<6) /* rx */
-#define IR_CRC_ERROR     (1<<5) /* rx */
-#define IR_MAX_LEN       (1<<4) /* rx */
-#define IR_FIFO_OVER     (1<<3) /* rx */
-#define IR_SIR_ERROR     (1<<2) /* rx */
-#define IR_RX_ERROR      (IR_PHY_ERROR|IR_CRC_ERROR| \
-		IR_MAX_LEN|IR_FIFO_OVER|IR_SIR_ERROR)
-
-typedef struct db_dest {
-	struct db_dest *pnext;
-	volatile u32 *vaddr;
-	dma_addr_t dma_addr;
-} db_dest_t;
-
-
-typedef struct ring_desc {
-	u8 count_0;               /* 7:0  */
-	u8 count_1;               /* 12:8 */
-	u8 reserved;
-	u8 flags;
-	u8 addr_0;                /* 7:0   */
-	u8 addr_1;                /* 15:8  */
-	u8 addr_2;                /* 23:16 */
-	u8 addr_3;                /* 31:24 */
-} ring_dest_t;
-
-
-/* Private data for each instance */
-struct au1k_private {
-
-	db_dest_t *pDBfree;
-	db_dest_t db[2*NUM_IR_DESC];
-	volatile ring_dest_t *rx_ring[NUM_IR_DESC];
-	volatile ring_dest_t *tx_ring[NUM_IR_DESC];
-	db_dest_t *rx_db_inuse[NUM_IR_DESC];
-	db_dest_t *tx_db_inuse[NUM_IR_DESC];
-	u32 rx_head;
-	u32 tx_head;
-	u32 tx_tail;
-	u32 tx_full;
-
-	iobuff_t rx_buff;
-
-	struct net_device *netdev;
-	
-	struct timeval stamp;
-	struct timeval now;
-	struct qos_info		qos;
-	struct irlap_cb		*irlap;
-	
-	u8 open;
-	u32 speed;
-	u32 newspeed;
-	
-	u32 intr_work_done; /* number of Rx and Tx pkts processed in the isr */
-	struct timer_list timer;
-
-	spinlock_t lock;           /* For serializing operations */
-};
-#endif /* AU1000_IRCC_H */
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 670bb05..fc503aa 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -18,101 +18,220 @@
  *  with this program; if not, write to the Free Software Foundation, Inc.,
  *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  */
-#include <linux/module.h>
-#include <linux/types.h>
+
 #include <linux/init.h>
-#include <linux/errno.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/slab.h>
-#include <linux/rtnetlink.h>
 #include <linux/interrupt.h>
-#include <linux/pm.h>
-#include <linux/bitops.h>
-
-#include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/au1000.h>
-#if defined(CONFIG_MIPS_DB1000)
-#include <asm/mach-db1x00/bcsr.h>
-#else 
-#error au1k_ir: unsupported board
-#endif
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/time.h>
+#include <linux/types.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irmod.h>
 #include <net/irda/wrapper.h>
 #include <net/irda/irda_device.h>
-#include "au1000_ircc.h"
+#include <asm/mach-au1x00/au1000.h>
+
+/* registers */
+#define IR_RING_PTR_STATUS	0x00
+#define IR_RING_BASE_ADDR_H	0x04
+#define IR_RING_BASE_ADDR_L	0x08
+#define IR_RING_SIZE		0x0C
+#define IR_RING_PROMPT		0x10
+#define IR_RING_ADDR_CMPR	0x14
+#define IR_INT_CLEAR		0x18
+#define IR_CONFIG_1		0x20
+#define IR_SIR_FLAGS		0x24
+#define IR_STATUS		0x28
+#define IR_READ_PHY_CONFIG	0x2C
+#define IR_WRITE_PHY_CONFIG	0x30
+#define IR_MAX_PKT_LEN		0x34
+#define IR_RX_BYTE_CNT		0x38
+#define IR_CONFIG_2		0x3C
+#define IR_ENABLE		0x40
+
+/* Config1 */
+#define IR_RX_INVERT_LED	(1 << 0)
+#define IR_TX_INVERT_LED	(1 << 1)
+#define IR_ST			(1 << 2)
+#define IR_SF			(1 << 3)
+#define IR_SIR			(1 << 4)
+#define IR_MIR			(1 << 5)
+#define IR_FIR			(1 << 6)
+#define IR_16CRC		(1 << 7)
+#define IR_TD			(1 << 8)
+#define IR_RX_ALL		(1 << 9)
+#define IR_DMA_ENABLE		(1 << 10)
+#define IR_RX_ENABLE		(1 << 11)
+#define IR_TX_ENABLE		(1 << 12)
+#define IR_LOOPBACK		(1 << 14)
+#define IR_SIR_MODE		(IR_SIR | IR_DMA_ENABLE | \
+				 IR_RX_ALL | IR_RX_ENABLE | IR_SF | \
+				 IR_16CRC)
+
+/* ir_status */
+#define IR_RX_STATUS		(1 << 9)
+#define IR_TX_STATUS		(1 << 10)
+#define IR_PHYEN		(1 << 15)
+
+/* ir_write_phy_config */
+#define IR_BR(x)		(((x) & 0x3f) << 10)	/* baud rate */
+#define IR_PW(x)		(((x) & 0x1f) << 5)	/* pulse width */
+#define IR_P(x)			((x) & 0x1f)		/* preamble bits */
+
+/* Config2 */
+#define IR_MODE_INV		(1 << 0)
+#define IR_ONE_PIN		(1 << 1)
+#define IR_PHYCLK_40MHZ		(0 << 2)
+#define IR_PHYCLK_48MHZ		(1 << 2)
+#define IR_PHYCLK_56MHZ		(2 << 2)
+#define IR_PHYCLK_64MHZ		(3 << 2)
+#define IR_DP			(1 << 4)
+#define IR_DA			(1 << 5)
+#define IR_FLT_HIGH		(0 << 6)
+#define IR_FLT_MEDHI		(1 << 6)
+#define IR_FLT_MEDLO		(2 << 6)
+#define IR_FLT_LO		(3 << 6)
+#define IR_IEN			(1 << 8)
+
+/* ir_enable */
+#define IR_HC			(1 << 3)	/* divide SBUS clock by 2 */
+#define IR_CE			(1 << 2)	/* clock enable */
+#define IR_C			(1 << 1)	/* coherency bit */
+#define IR_BE			(1 << 0)	/* set in big endian mode */
+
+#define NUM_IR_DESC	64
+#define RING_SIZE_4	0x0
+#define RING_SIZE_16	0x3
+#define RING_SIZE_64	0xF
+#define MAX_NUM_IR_DESC	64
+#define MAX_BUF_SIZE	2048
+
+/* Ring descriptor flags */
+#define AU_OWN		(1 << 7) /* tx,rx */
+#define IR_DIS_CRC	(1 << 6) /* tx */
+#define IR_BAD_CRC	(1 << 5) /* tx */
+#define IR_NEED_PULSE	(1 << 4) /* tx */
+#define IR_FORCE_UNDER	(1 << 3) /* tx */
+#define IR_DISABLE_TX	(1 << 2) /* tx */
+#define IR_HW_UNDER	(1 << 0) /* tx */
+#define IR_TX_ERROR	(IR_DIS_CRC | IR_BAD_CRC | IR_HW_UNDER)
+
+#define IR_PHY_ERROR	(1 << 6) /* rx */
+#define IR_CRC_ERROR	(1 << 5) /* rx */
+#define IR_MAX_LEN	(1 << 4) /* rx */
+#define IR_FIFO_OVER	(1 << 3) /* rx */
+#define IR_SIR_ERROR	(1 << 2) /* rx */
+#define IR_RX_ERROR	(IR_PHY_ERROR | IR_CRC_ERROR | \
+			 IR_MAX_LEN | IR_FIFO_OVER | IR_SIR_ERROR)
+
+struct db_dest {
+	struct db_dest *pnext;
+	volatile u32 *vaddr;
+	dma_addr_t dma_addr;
+};
+
+struct ring_dest {
+	u8 count_0;	/* 7:0  */
+	u8 count_1;	/* 12:8 */
+	u8 reserved;
+	u8 flags;
+	u8 addr_0;	/* 7:0   */
+	u8 addr_1;	/* 15:8  */
+	u8 addr_2;	/* 23:16 */
+	u8 addr_3;	/* 31:24 */
+};
+
+/* Private data for each instance */
+struct au1k_private {
+	void __iomem *iobase;
+	int irq_rx, irq_tx;
+
+	struct db_dest *pDBfree;
+	struct db_dest db[2 * NUM_IR_DESC];
+	volatile struct ring_dest *rx_ring[NUM_IR_DESC];
+	volatile struct ring_dest *tx_ring[NUM_IR_DESC];
+	struct db_dest *rx_db_inuse[NUM_IR_DESC];
+	struct db_dest *tx_db_inuse[NUM_IR_DESC];
+	u32 rx_head;
+	u32 tx_head;
+	u32 tx_tail;
+	u32 tx_full;
+
+	iobuff_t rx_buff;
+
+	struct net_device *netdev;
+	struct timeval stamp;
+	struct timeval now;
+	struct qos_info qos;
+	struct irlap_cb *irlap;
+
+	u8 open;
+	u32 speed;
+	u32 newspeed;
 
-static int au1k_irda_net_init(struct net_device *);
-static int au1k_irda_start(struct net_device *);
-static int au1k_irda_stop(struct net_device *dev);
-static int au1k_irda_hard_xmit(struct sk_buff *, struct net_device *);
-static int au1k_irda_rx(struct net_device *);
-static void au1k_irda_interrupt(int, void *);
-static void au1k_tx_timeout(struct net_device *);
-static int au1k_irda_ioctl(struct net_device *, struct ifreq *, int);
-static int au1k_irda_set_speed(struct net_device *dev, int speed);
+	struct timer_list timer;
 
-static void *dma_alloc(size_t, dma_addr_t *);
-static void dma_free(void *, size_t);
+	struct resource *ioarea;
+	struct au1k_irda_platform_data *platdata;
+};
 
 static int qos_mtt_bits = 0x07;  /* 1 ms or more */
-static struct net_device *ir_devs[NUM_IR_IFF];
-static char version[] __devinitdata =
-    "au1k_ircc:1.2 ppopov@mvista.com\n";
 
 #define RUN_AT(x) (jiffies + (x))
 
-static DEFINE_SPINLOCK(ir_lock);
+static void au1k_irda_plat_set_phy_mode(struct au1k_private *p, int mode)
+{
+	if (p->platdata && p->platdata->set_phy_mode)
+		p->platdata->set_phy_mode(mode);
+}
 
-/*
- * IrDA peripheral bug. You have to read the register
- * twice to get the right value.
- */
-u32 read_ir_reg(u32 addr) 
-{ 
-	readl(addr);
-	return readl(addr);
+static inline unsigned long irda_read(struct au1k_private *p,
+				      unsigned long ofs)
+{
+	/*
+	* IrDA peripheral bug. You have to read the register
+	* twice to get the right value.
+	*/
+	(void)__raw_readl(p->iobase + ofs);
+	return __raw_readl(p->iobase + ofs);
 }
 
+static inline void irda_write(struct au1k_private *p, unsigned long ofs,
+			      unsigned long val)
+{
+	__raw_writel(val, p->iobase + ofs);
+	wmb();
+}
 
 /*
  * Buffer allocation/deallocation routines. The buffer descriptor returned
- * has the virtual and dma address of a buffer suitable for 
+ * has the virtual and dma address of a buffer suitable for
  * both, receive and transmit operations.
  */
-static db_dest_t *GetFreeDB(struct au1k_private *aup)
+static struct db_dest *GetFreeDB(struct au1k_private *aup)
 {
-	db_dest_t *pDB;
-	pDB = aup->pDBfree;
-
-	if (pDB) {
-		aup->pDBfree = pDB->pnext;
-	}
-	return pDB;
-}
+	struct db_dest *db;
+	db = aup->pDBfree;
 
-static void ReleaseDB(struct au1k_private *aup, db_dest_t *pDB)
-{
-	db_dest_t *pDBfree = aup->pDBfree;
-	if (pDBfree)
-		pDBfree->pnext = pDB;
-	aup->pDBfree = pDB;
+	if (db)
+		aup->pDBfree = db->pnext;
+	return db;
 }
 
-
 /*
   DMA memory allocation, derived from pci_alloc_consistent.
   However, the Au1000 data cache is coherent (when programmed
   so), therefore we return KSEG0 address, not KSEG1.
 */
-static void *dma_alloc(size_t size, dma_addr_t * dma_handle)
+static void *dma_alloc(size_t size, dma_addr_t *dma_handle)
 {
 	void *ret;
 	int gfp = GFP_ATOMIC | GFP_DMA;
 
-	ret = (void *) __get_free_pages(gfp, get_order(size));
+	ret = (void *)__get_free_pages(gfp, get_order(size));
 
 	if (ret != NULL) {
 		memset(ret, 0, size);
@@ -122,7 +241,6 @@ static void *dma_alloc(size_t size, dma_addr_t * dma_handle)
 	return ret;
 }
 
-
 static void dma_free(void *vaddr, size_t size)
 {
 	vaddr = (void *)KSEG0ADDR(vaddr);
@@ -130,206 +248,306 @@ static void dma_free(void *vaddr, size_t size)
 }
 
 
-static void 
-setup_hw_rings(struct au1k_private *aup, u32 rx_base, u32 tx_base)
+static void setup_hw_rings(struct au1k_private *aup, u32 rx_base, u32 tx_base)
 {
 	int i;
-	for (i=0; i<NUM_IR_DESC; i++) {
-		aup->rx_ring[i] = (volatile ring_dest_t *) 
-			(rx_base + sizeof(ring_dest_t)*i);
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		aup->rx_ring[i] = (volatile struct ring_dest *)
+			(rx_base + sizeof(struct ring_dest) * i);
 	}
-	for (i=0; i<NUM_IR_DESC; i++) {
-		aup->tx_ring[i] = (volatile ring_dest_t *) 
-			(tx_base + sizeof(ring_dest_t)*i);
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		aup->tx_ring[i] = (volatile struct ring_dest *)
+			(tx_base + sizeof(struct ring_dest) * i);
 	}
 }
 
-static int au1k_irda_init(void)
-{
-	static unsigned version_printed = 0;
-	struct au1k_private *aup;
-	struct net_device *dev;
-	int err;
-
-	if (version_printed++ == 0) printk(version);
-
-	dev = alloc_irdadev(sizeof(struct au1k_private));
-	if (!dev)
-		return -ENOMEM;
-
-	dev->irq = AU1000_IRDA_RX_INT; /* TX has its own interrupt */
-	err = au1k_irda_net_init(dev);
-	if (err)
-		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
-	ir_devs[0] = dev;
-	printk(KERN_INFO "IrDA: Registered device %s\n", dev->name);
-	return 0;
-
-out1:
-	aup = netdev_priv(dev);
-	dma_free((void *)aup->db[0].vaddr,
-		MAX_BUF_SIZE * 2*NUM_IR_DESC);
-	dma_free((void *)aup->rx_ring[0],
-		2 * MAX_NUM_IR_DESC*(sizeof(ring_dest_t)));
-	kfree(aup->rx_buff.head);
-out:
-	free_netdev(dev);
-	return err;
-}
-
 static int au1k_irda_init_iobuf(iobuff_t *io, int size)
 {
 	io->head = kmalloc(size, GFP_KERNEL);
 	if (io->head != NULL) {
-		io->truesize = size;
-		io->in_frame = FALSE;
-		io->state    = OUTSIDE_FRAME;
-		io->data     = io->head;
+		io->truesize	= size;
+		io->in_frame	= FALSE;
+		io->state	= OUTSIDE_FRAME;
+		io->data	= io->head;
 	}
 	return io->head ? 0 : -ENOMEM;
 }
 
-static const struct net_device_ops au1k_irda_netdev_ops = {
-	.ndo_open		= au1k_irda_start,
-	.ndo_stop		= au1k_irda_stop,
-	.ndo_start_xmit		= au1k_irda_hard_xmit,
-	.ndo_tx_timeout		= au1k_tx_timeout,
-	.ndo_do_ioctl		= au1k_irda_ioctl,
-};
-
-static int au1k_irda_net_init(struct net_device *dev)
+/*
+ * Set the IrDA communications speed.
+ */
+static int au1k_irda_set_speed(struct net_device *dev, int speed)
 {
 	struct au1k_private *aup = netdev_priv(dev);
-	int i, retval = 0, err;
-	db_dest_t *pDB, *pDBfree;
-	dma_addr_t temp;
+	volatile struct ring_dest *ptxd;
+	unsigned long control;
+	int ret = 0, timeout = 10, i;
 
-	err = au1k_irda_init_iobuf(&aup->rx_buff, 14384);
-	if (err)
-		goto out1;
+	if (speed == aup->speed)
+		return ret;
 
-	dev->netdev_ops = &au1k_irda_netdev_ops;
+	/* disable PHY first */
+	au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_OFF);
+	irda_write(aup, IR_STATUS, irda_read(aup, IR_STATUS) & ~IR_PHYEN);
 
-	irda_init_max_qos_capabilies(&aup->qos);
+	/* disable RX/TX */
+	irda_write(aup, IR_CONFIG_1,
+	    irda_read(aup, IR_CONFIG_1) & ~(IR_RX_ENABLE | IR_TX_ENABLE));
+	msleep(20);
+	while (irda_read(aup, IR_STATUS) & (IR_RX_STATUS | IR_TX_STATUS)) {
+		msleep(20);
+		if (!timeout--) {
+			printk(KERN_ERR "%s: rx/tx disable timeout\n",
+					dev->name);
+			break;
+		}
+	}
 
-	/* The only value we must override it the baudrate */
-	aup->qos.baud_rate.bits = IR_9600|IR_19200|IR_38400|IR_57600|
-		IR_115200|IR_576000 |(IR_4000000 << 8);
-	
-	aup->qos.min_turn_time.bits = qos_mtt_bits;
-	irda_qos_bits_to_value(&aup->qos);
+	/* disable DMA */
+	irda_write(aup, IR_CONFIG_1,
+		   irda_read(aup, IR_CONFIG_1) & ~IR_DMA_ENABLE);
+	msleep(20);
 
-	retval = -ENOMEM;
+	/* After we disable tx/rx. the index pointers go back to zero. */
+	aup->tx_head = aup->tx_tail = aup->rx_head = 0;
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		ptxd = aup->tx_ring[i];
+		ptxd->flags = 0;
+		ptxd->count_0 = 0;
+		ptxd->count_1 = 0;
+	}
 
-	/* Tx ring follows rx ring + 512 bytes */
-	/* we need a 1k aligned buffer */
-	aup->rx_ring[0] = (ring_dest_t *)
-		dma_alloc(2*MAX_NUM_IR_DESC*(sizeof(ring_dest_t)), &temp);
-	if (!aup->rx_ring[0])
-		goto out2;
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		ptxd = aup->rx_ring[i];
+		ptxd->count_0 = 0;
+		ptxd->count_1 = 0;
+		ptxd->flags = AU_OWN;
+	}
 
-	/* allocate the data buffers */
-	aup->db[0].vaddr = 
-		(void *)dma_alloc(MAX_BUF_SIZE * 2*NUM_IR_DESC, &temp);
-	if (!aup->db[0].vaddr)
-		goto out3;
+	if (speed == 4000000)
+		au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_FIR);
+	else
+		au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_SIR);
 
-	setup_hw_rings(aup, (u32)aup->rx_ring[0], (u32)aup->rx_ring[0] + 512);
+	switch (speed) {
+	case 9600:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_BR(11) | IR_PW(12));
+		irda_write(aup, IR_CONFIG_1, IR_SIR_MODE);
+		break;
+	case 19200:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_BR(5) | IR_PW(12));
+		irda_write(aup, IR_CONFIG_1, IR_SIR_MODE);
+		break;
+	case 38400:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_BR(2) | IR_PW(12));
+		irda_write(aup, IR_CONFIG_1, IR_SIR_MODE);
+		break;
+	case 57600:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_BR(1) | IR_PW(12));
+		irda_write(aup, IR_CONFIG_1, IR_SIR_MODE);
+		break;
+	case 115200:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_PW(12));
+		irda_write(aup, IR_CONFIG_1, IR_SIR_MODE);
+		break;
+	case 4000000:
+		irda_write(aup, IR_WRITE_PHY_CONFIG, IR_P(15));
+		irda_write(aup, IR_CONFIG_1, IR_FIR | IR_DMA_ENABLE |
+				IR_RX_ENABLE);
+		break;
+	default:
+		printk(KERN_ERR "%s unsupported speed %x\n", dev->name, speed);
+		ret = -EINVAL;
+		break;
+	}
 
-	pDBfree = NULL;
-	pDB = aup->db;
-	for (i=0; i<(2*NUM_IR_DESC); i++) {
-		pDB->pnext = pDBfree;
-		pDBfree = pDB;
-		pDB->vaddr = 
-			(u32 *)((unsigned)aup->db[0].vaddr + MAX_BUF_SIZE*i);
-		pDB->dma_addr = (dma_addr_t)virt_to_bus(pDB->vaddr);
-		pDB++;
+	aup->speed = speed;
+	irda_write(aup, IR_STATUS, irda_read(aup, IR_STATUS) | IR_PHYEN);
+
+	control = irda_read(aup, IR_STATUS);
+	irda_write(aup, IR_RING_PROMPT, 0);
+
+	if (control & (1 << 14)) {
+		printk(KERN_ERR "%s: configuration error\n", dev->name);
+	} else {
+		if (control & (1 << 11))
+			printk(KERN_DEBUG "%s Valid SIR config\n", dev->name);
+		if (control & (1 << 12))
+			printk(KERN_DEBUG "%s Valid MIR config\n", dev->name);
+		if (control & (1 << 13))
+			printk(KERN_DEBUG "%s Valid FIR config\n", dev->name);
+		if (control & (1 << 10))
+			printk(KERN_DEBUG "%s TX enabled\n", dev->name);
+		if (control & (1 << 9))
+			printk(KERN_DEBUG "%s RX enabled\n", dev->name);
 	}
-	aup->pDBfree = pDBfree;
 
-	/* attach a data buffer to each descriptor */
-	for (i=0; i<NUM_IR_DESC; i++) {
-		pDB = GetFreeDB(aup);
-		if (!pDB) goto out;
-		aup->rx_ring[i]->addr_0 = (u8)(pDB->dma_addr & 0xff);
-		aup->rx_ring[i]->addr_1 = (u8)((pDB->dma_addr>>8) & 0xff);
-		aup->rx_ring[i]->addr_2 = (u8)((pDB->dma_addr>>16) & 0xff);
-		aup->rx_ring[i]->addr_3 = (u8)((pDB->dma_addr>>24) & 0xff);
-		aup->rx_db_inuse[i] = pDB;
+	return ret;
+}
+
+static void update_rx_stats(struct net_device *dev, u32 status, u32 count)
+{
+	struct net_device_stats *ps = &dev->stats;
+
+	ps->rx_packets++;
+
+	if (status & IR_RX_ERROR) {
+		ps->rx_errors++;
+		if (status & (IR_PHY_ERROR | IR_FIFO_OVER))
+			ps->rx_missed_errors++;
+		if (status & IR_MAX_LEN)
+			ps->rx_length_errors++;
+		if (status & IR_CRC_ERROR)
+			ps->rx_crc_errors++;
+	} else
+		ps->rx_bytes += count;
+}
+
+static void update_tx_stats(struct net_device *dev, u32 status, u32 pkt_len)
+{
+	struct net_device_stats *ps = &dev->stats;
+
+	ps->tx_packets++;
+	ps->tx_bytes += pkt_len;
+
+	if (status & IR_TX_ERROR) {
+		ps->tx_errors++;
+		ps->tx_aborted_errors++;
 	}
-	for (i=0; i<NUM_IR_DESC; i++) {
-		pDB = GetFreeDB(aup);
-		if (!pDB) goto out;
-		aup->tx_ring[i]->addr_0 = (u8)(pDB->dma_addr & 0xff);
-		aup->tx_ring[i]->addr_1 = (u8)((pDB->dma_addr>>8) & 0xff);
-		aup->tx_ring[i]->addr_2 = (u8)((pDB->dma_addr>>16) & 0xff);
-		aup->tx_ring[i]->addr_3 = (u8)((pDB->dma_addr>>24) & 0xff);
-		aup->tx_ring[i]->count_0 = 0;
-		aup->tx_ring[i]->count_1 = 0;
-		aup->tx_ring[i]->flags = 0;
-		aup->tx_db_inuse[i] = pDB;
+}
+
+static void au1k_tx_ack(struct net_device *dev)
+{
+	struct au1k_private *aup = netdev_priv(dev);
+	volatile struct ring_dest *ptxd;
+
+	ptxd = aup->tx_ring[aup->tx_tail];
+	while (!(ptxd->flags & AU_OWN) && (aup->tx_tail != aup->tx_head)) {
+		update_tx_stats(dev, ptxd->flags,
+				(ptxd->count_1 << 8) | ptxd->count_0);
+		ptxd->count_0 = 0;
+		ptxd->count_1 = 0;
+		wmb();
+		aup->tx_tail = (aup->tx_tail + 1) & (NUM_IR_DESC - 1);
+		ptxd = aup->tx_ring[aup->tx_tail];
+
+		if (aup->tx_full) {
+			aup->tx_full = 0;
+			netif_wake_queue(dev);
+		}
 	}
 
-#if defined(CONFIG_MIPS_DB1000)
-	/* power on */
-	bcsr_mod(BCSR_RESETS, BCSR_RESETS_IRDA_MODE_MASK,
-			      BCSR_RESETS_IRDA_MODE_FULL);
-#endif
+	if (aup->tx_tail == aup->tx_head) {
+		if (aup->newspeed) {
+			au1k_irda_set_speed(dev, aup->newspeed);
+			aup->newspeed = 0;
+		} else {
+			irda_write(aup, IR_CONFIG_1,
+			    irda_read(aup, IR_CONFIG_1) & ~IR_TX_ENABLE);
+			irda_write(aup, IR_CONFIG_1,
+			    irda_read(aup, IR_CONFIG_1) | IR_RX_ENABLE);
+			irda_write(aup, IR_RING_PROMPT, 0);
+		}
+	}
+}
 
-	return 0;
+static int au1k_irda_rx(struct net_device *dev)
+{
+	struct au1k_private *aup = netdev_priv(dev);
+	volatile struct ring_dest *prxd;
+	struct sk_buff *skb;
+	struct db_dest *pDB;
+	u32 flags, count;
 
-out3:
-	dma_free((void *)aup->rx_ring[0],
-		2 * MAX_NUM_IR_DESC*(sizeof(ring_dest_t)));
-out2:
-	kfree(aup->rx_buff.head);
-out1:
-	printk(KERN_ERR "au1k_init_module failed.  Returns %d\n", retval);
-	return retval;
+	prxd = aup->rx_ring[aup->rx_head];
+	flags = prxd->flags;
+
+	while (!(flags & AU_OWN))  {
+		pDB = aup->rx_db_inuse[aup->rx_head];
+		count = (prxd->count_1 << 8) | prxd->count_0;
+		if (!(flags & IR_RX_ERROR)) {
+			/* good frame */
+			update_rx_stats(dev, flags, count);
+			skb = alloc_skb(count + 1, GFP_ATOMIC);
+			if (skb == NULL) {
+				dev->stats.rx_dropped++;
+				continue;
+			}
+			skb_reserve(skb, 1);
+			if (aup->speed == 4000000)
+				skb_put(skb, count);
+			else
+				skb_put(skb, count - 2);
+			skb_copy_to_linear_data(skb, (void *)pDB->vaddr,
+						count - 2);
+			skb->dev = dev;
+			skb_reset_mac_header(skb);
+			skb->protocol = htons(ETH_P_IRDA);
+			netif_rx(skb);
+			prxd->count_0 = 0;
+			prxd->count_1 = 0;
+		}
+		prxd->flags |= AU_OWN;
+		aup->rx_head = (aup->rx_head + 1) & (NUM_IR_DESC - 1);
+		irda_write(aup, IR_RING_PROMPT, 0);
+
+		/* next descriptor */
+		prxd = aup->rx_ring[aup->rx_head];
+		flags = prxd->flags;
+
+	}
+	return 0;
 }
 
+static irqreturn_t au1k_irda_interrupt(int dummy, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct au1k_private *aup = netdev_priv(dev);
+
+	irda_write(aup, IR_INT_CLEAR, 0); /* ack irda interrupts */
+
+	au1k_irda_rx(dev);
+	au1k_tx_ack(dev);
+
+	return IRQ_HANDLED;
+}
 
 static int au1k_init(struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
+	u32 enable, ring_address;
 	int i;
-	u32 control;
-	u32 ring_address;
 
-	/* bring the device out of reset */
-	control = 0xe; /* coherent, clock enable, one half system clock */
-			  
+	enable = IR_HC | IR_CE | IR_C;
 #ifndef CONFIG_CPU_LITTLE_ENDIAN
-	control |= 1;
+	enable |= IR_BE;
 #endif
 	aup->tx_head = 0;
 	aup->tx_tail = 0;
 	aup->rx_head = 0;
 
-	for (i=0; i<NUM_IR_DESC; i++) {
+	for (i = 0; i < NUM_IR_DESC; i++)
 		aup->rx_ring[i]->flags = AU_OWN;
-	}
 
-	writel(control, IR_INTERFACE_CONFIG);
-	au_sync_delay(10);
+	irda_write(aup, IR_ENABLE, enable);
+	msleep(20);
 
-	writel(read_ir_reg(IR_ENABLE) & ~0x8000, IR_ENABLE); /* disable PHY */
-	au_sync_delay(1);
+	/* disable PHY */
+	au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_OFF);
+	irda_write(aup, IR_STATUS, irda_read(aup, IR_STATUS) & ~IR_PHYEN);
+	msleep(20);
 
-	writel(MAX_BUF_SIZE, IR_MAX_PKT_LEN);
+	irda_write(aup, IR_MAX_PKT_LEN, MAX_BUF_SIZE);
 
 	ring_address = (u32)virt_to_phys((void *)aup->rx_ring[0]);
-	writel(ring_address >> 26, IR_RING_BASE_ADDR_H);
-	writel((ring_address >> 10) & 0xffff, IR_RING_BASE_ADDR_L);
+	irda_write(aup, IR_RING_BASE_ADDR_H, ring_address >> 26);
+	irda_write(aup, IR_RING_BASE_ADDR_L, (ring_address >> 10) & 0xffff);
 
-	writel(RING_SIZE_64<<8 | RING_SIZE_64<<12, IR_RING_SIZE);
+	irda_write(aup, IR_RING_SIZE,
+				(RING_SIZE_64 << 8) | (RING_SIZE_64 << 12));
 
-	writel(1<<2 | IR_ONE_PIN, IR_CONFIG_2); /* 48MHz */
-	writel(0, IR_RING_ADDR_CMPR);
+	irda_write(aup, IR_CONFIG_2, IR_PHYCLK_48MHZ | IR_ONE_PIN);
+	irda_write(aup, IR_RING_ADDR_CMPR, 0);
 
 	au1k_irda_set_speed(dev, 9600);
 	return 0;
@@ -337,25 +555,28 @@ static int au1k_init(struct net_device *dev)
 
 static int au1k_irda_start(struct net_device *dev)
 {
-	int retval;
-	char hwname[32];
 	struct au1k_private *aup = netdev_priv(dev);
+	char hwname[32];
+	int retval;
 
-	if ((retval = au1k_init(dev))) {
+	retval = au1k_init(dev);
+	if (retval) {
 		printk(KERN_ERR "%s: error in au1k_init\n", dev->name);
 		return retval;
 	}
 
-	if ((retval = request_irq(AU1000_IRDA_TX_INT, au1k_irda_interrupt, 
-					0, dev->name, dev))) {
-		printk(KERN_ERR "%s: unable to get IRQ %d\n", 
+	retval = request_irq(aup->irq_tx, &au1k_irda_interrupt, 0,
+			     dev->name, dev);
+	if (retval) {
+		printk(KERN_ERR "%s: unable to get IRQ %d\n",
 				dev->name, dev->irq);
 		return retval;
 	}
-	if ((retval = request_irq(AU1000_IRDA_RX_INT, au1k_irda_interrupt, 
-					0, dev->name, dev))) {
-		free_irq(AU1000_IRDA_TX_INT, dev);
-		printk(KERN_ERR "%s: unable to get IRQ %d\n", 
+	retval = request_irq(aup->irq_rx, &au1k_irda_interrupt, 0,
+			     dev->name, dev);
+	if (retval) {
+		free_irq(aup->irq_tx, dev);
+		printk(KERN_ERR "%s: unable to get IRQ %d\n",
 				dev->name, dev->irq);
 		return retval;
 	}
@@ -365,9 +586,13 @@ static int au1k_irda_start(struct net_device *dev)
 	aup->irlap = irlap_open(dev, &aup->qos, hwname);
 	netif_start_queue(dev);
 
-	writel(read_ir_reg(IR_CONFIG_2) | 1<<8, IR_CONFIG_2); /* int enable */
+	/* int enable */
+	irda_write(aup, IR_CONFIG_2, irda_read(aup, IR_CONFIG_2) | IR_IEN);
 
-	aup->timer.expires = RUN_AT((3*HZ)); 
+	/* power up */
+	au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_SIR);
+
+	aup->timer.expires = RUN_AT((3 * HZ));
 	aup->timer.data = (unsigned long)dev;
 	return 0;
 }
@@ -376,11 +601,12 @@ static int au1k_irda_stop(struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
 
+	au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_OFF);
+
 	/* disable interrupts */
-	writel(read_ir_reg(IR_CONFIG_2) & ~(1<<8), IR_CONFIG_2);
-	writel(0, IR_CONFIG_1); 
-	writel(0, IR_INTERFACE_CONFIG); /* disable clock */
-	au_sync();
+	irda_write(aup, IR_CONFIG_2, irda_read(aup, IR_CONFIG_2) & ~IR_IEN);
+	irda_write(aup, IR_CONFIG_1, 0);
+	irda_write(aup, IR_ENABLE, 0); /* disable clock */
 
 	if (aup->irlap) {
 		irlap_close(aup->irlap);
@@ -391,83 +617,12 @@ static int au1k_irda_stop(struct net_device *dev)
 	del_timer(&aup->timer);
 
 	/* disable the interrupt */
-	free_irq(AU1000_IRDA_TX_INT, dev);
-	free_irq(AU1000_IRDA_RX_INT, dev);
-	return 0;
-}
-
-static void __exit au1k_irda_exit(void)
-{
-	struct net_device *dev = ir_devs[0];
-	struct au1k_private *aup = netdev_priv(dev);
-
-	unregister_netdev(dev);
-
-	dma_free((void *)aup->db[0].vaddr,
-		MAX_BUF_SIZE * 2*NUM_IR_DESC);
-	dma_free((void *)aup->rx_ring[0],
-		2 * MAX_NUM_IR_DESC*(sizeof(ring_dest_t)));
-	kfree(aup->rx_buff.head);
-	free_netdev(dev);
-}
-
-
-static inline void 
-update_tx_stats(struct net_device *dev, u32 status, u32 pkt_len)
-{
-	struct au1k_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &aup->stats;
-
-	ps->tx_packets++;
-	ps->tx_bytes += pkt_len;
-
-	if (status & IR_TX_ERROR) {
-		ps->tx_errors++;
-		ps->tx_aborted_errors++;
-	}
-}
-
-
-static void au1k_tx_ack(struct net_device *dev)
-{
-	struct au1k_private *aup = netdev_priv(dev);
-	volatile ring_dest_t *ptxd;
-
-	ptxd = aup->tx_ring[aup->tx_tail];
-	while (!(ptxd->flags & AU_OWN) && (aup->tx_tail != aup->tx_head)) {
-		update_tx_stats(dev, ptxd->flags, 
-				ptxd->count_1<<8 | ptxd->count_0);
-		ptxd->count_0 = 0;
-		ptxd->count_1 = 0;
-		au_sync();
-
-		aup->tx_tail = (aup->tx_tail + 1) & (NUM_IR_DESC - 1);
-		ptxd = aup->tx_ring[aup->tx_tail];
-
-		if (aup->tx_full) {
-			aup->tx_full = 0;
-			netif_wake_queue(dev);
-		}
-	}
+	free_irq(aup->irq_tx, dev);
+	free_irq(aup->irq_rx, dev);
 
-	if (aup->tx_tail == aup->tx_head) {
-		if (aup->newspeed) {
-			au1k_irda_set_speed(dev, aup->newspeed);
-			aup->newspeed = 0;
-		}
-		else {
-			writel(read_ir_reg(IR_CONFIG_1) & ~IR_TX_ENABLE, 
-					IR_CONFIG_1); 
-			au_sync();
-			writel(read_ir_reg(IR_CONFIG_1) | IR_RX_ENABLE, 
-					IR_CONFIG_1); 
-			writel(0, IR_RING_PROMPT);
-			au_sync();
-		}
-	}
+	return 0;
 }
 
-
 /*
  * Au1000 transmit routine.
  */
@@ -475,15 +630,12 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
 	int speed = irda_get_next_speed(skb);
-	volatile ring_dest_t *ptxd;
-	u32 len;
-
-	u32 flags;
-	db_dest_t *pDB;
+	volatile struct ring_dest *ptxd;
+	struct db_dest *pDB;
+	u32 len, flags;
 
-	if (speed != aup->speed && speed != -1) {
+	if (speed != aup->speed && speed != -1)
 		aup->newspeed = speed;
-	}
 
 	if ((skb->len == 0) && (aup->newspeed)) {
 		if (aup->tx_tail == aup->tx_head) {
@@ -501,138 +653,47 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
-		return NETDEV_TX_BUSY;
-	}
-	else if (((aup->tx_head + 1) & (NUM_IR_DESC - 1)) == aup->tx_tail) {
+		return 1;
+	} else if (((aup->tx_head + 1) & (NUM_IR_DESC - 1)) == aup->tx_tail) {
 		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
-		return NETDEV_TX_BUSY;
+		return 1;
 	}
 
 	pDB = aup->tx_db_inuse[aup->tx_head];
 
 #if 0
-	if (read_ir_reg(IR_RX_BYTE_CNT) != 0) {
-		printk("tx warning: rx byte cnt %x\n", 
-				read_ir_reg(IR_RX_BYTE_CNT));
+	if (irda_read(aup, IR_RX_BYTE_CNT) != 0) {
+		printk(KERN_DEBUG "tx warning: rx byte cnt %x\n",
+				irda_read(aup, IR_RX_BYTE_CNT));
 	}
 #endif
-	
+
 	if (aup->speed == 4000000) {
 		/* FIR */
-		skb_copy_from_linear_data(skb, pDB->vaddr, skb->len);
+		skb_copy_from_linear_data(skb, (void *)pDB->vaddr, skb->len);
 		ptxd->count_0 = skb->len & 0xff;
 		ptxd->count_1 = (skb->len >> 8) & 0xff;
-
-	}
-	else {
+	} else {
 		/* SIR */
 		len = async_wrap_skb(skb, (u8 *)pDB->vaddr, MAX_BUF_SIZE);
 		ptxd->count_0 = len & 0xff;
 		ptxd->count_1 = (len >> 8) & 0xff;
 		ptxd->flags |= IR_DIS_CRC;
-		au_writel(au_readl(0xae00000c) & ~(1<<13), 0xae00000c);
 	}
 	ptxd->flags |= AU_OWN;
-	au_sync();
+	wmb();
 
-	writel(read_ir_reg(IR_CONFIG_1) | IR_TX_ENABLE, IR_CONFIG_1); 
-	writel(0, IR_RING_PROMPT);
-	au_sync();
+	irda_write(aup, IR_CONFIG_1,
+		   irda_read(aup, IR_CONFIG_1) | IR_TX_ENABLE);
+	irda_write(aup, IR_RING_PROMPT, 0);
 
 	dev_kfree_skb(skb);
 	aup->tx_head = (aup->tx_head + 1) & (NUM_IR_DESC - 1);
 	return NETDEV_TX_OK;
 }
 
-
-static inline void 
-update_rx_stats(struct net_device *dev, u32 status, u32 count)
-{
-	struct au1k_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &aup->stats;
-
-	ps->rx_packets++;
-
-	if (status & IR_RX_ERROR) {
-		ps->rx_errors++;
-		if (status & (IR_PHY_ERROR|IR_FIFO_OVER))
-			ps->rx_missed_errors++;
-		if (status & IR_MAX_LEN)
-			ps->rx_length_errors++;
-		if (status & IR_CRC_ERROR)
-			ps->rx_crc_errors++;
-	}
-	else 
-		ps->rx_bytes += count;
-}
-
-/*
- * Au1000 receive routine.
- */
-static int au1k_irda_rx(struct net_device *dev)
-{
-	struct au1k_private *aup = netdev_priv(dev);
-	struct sk_buff *skb;
-	volatile ring_dest_t *prxd;
-	u32 flags, count;
-	db_dest_t *pDB;
-
-	prxd = aup->rx_ring[aup->rx_head];
-	flags = prxd->flags;
-
-	while (!(flags & AU_OWN))  {
-		pDB = aup->rx_db_inuse[aup->rx_head];
-		count = prxd->count_1<<8 | prxd->count_0;
-		if (!(flags & IR_RX_ERROR))  {
-			/* good frame */
-			update_rx_stats(dev, flags, count);
-			skb=alloc_skb(count+1,GFP_ATOMIC);
-			if (skb == NULL) {
-				aup->netdev->stats.rx_dropped++;
-				continue;
-			}
-			skb_reserve(skb, 1);
-			if (aup->speed == 4000000)
-				skb_put(skb, count);
-			else
-				skb_put(skb, count-2);
-			skb_copy_to_linear_data(skb, pDB->vaddr, count - 2);
-			skb->dev = dev;
-			skb_reset_mac_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
-			netif_rx(skb);
-			prxd->count_0 = 0;
-			prxd->count_1 = 0;
-		}
-		prxd->flags |= AU_OWN;
-		aup->rx_head = (aup->rx_head + 1) & (NUM_IR_DESC - 1);
-		writel(0, IR_RING_PROMPT);
-		au_sync();
-
-		/* next descriptor */
-		prxd = aup->rx_ring[aup->rx_head];
-		flags = prxd->flags;
-
-	}
-	return 0;
-}
-
-
-static irqreturn_t au1k_irda_interrupt(int dummy, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-
-	writel(0, IR_INT_CLEAR); /* ack irda interrupts */
-
-	au1k_irda_rx(dev);
-	au1k_tx_ack(dev);
-
-	return IRQ_HANDLED;
-}
-
-
 /*
  * The Tx ring has been full longer than the watchdog timeout
  * value. The transmitter must be hung?
@@ -650,142 +711,7 @@ static void au1k_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-
-/*
- * Set the IrDA communications speed.
- */
-static int 
-au1k_irda_set_speed(struct net_device *dev, int speed)
-{
-	unsigned long flags;
-	struct au1k_private *aup = netdev_priv(dev);
-	u32 control;
-	int ret = 0, timeout = 10, i;
-	volatile ring_dest_t *ptxd;
-#if defined(CONFIG_MIPS_DB1000)
-	unsigned long irda_resets;
-#endif
-
-	if (speed == aup->speed)
-		return ret;
-
-	spin_lock_irqsave(&ir_lock, flags);
-
-	/* disable PHY first */
-	writel(read_ir_reg(IR_ENABLE) & ~0x8000, IR_ENABLE);
-
-	/* disable RX/TX */
-	writel(read_ir_reg(IR_CONFIG_1) & ~(IR_RX_ENABLE|IR_TX_ENABLE), 
-			IR_CONFIG_1);
-	au_sync_delay(1);
-	while (read_ir_reg(IR_ENABLE) & (IR_RX_STATUS | IR_TX_STATUS)) {
-		mdelay(1);
-		if (!timeout--) {
-			printk(KERN_ERR "%s: rx/tx disable timeout\n",
-					dev->name);
-			break;
-		}
-	}
-
-	/* disable DMA */
-	writel(read_ir_reg(IR_CONFIG_1) & ~IR_DMA_ENABLE, IR_CONFIG_1);
-	au_sync_delay(1);
-
-	/* 
-	 *  After we disable tx/rx. the index pointers
- 	 * go back to zero.
-	 */
-	aup->tx_head = aup->tx_tail = aup->rx_head = 0;
-	for (i=0; i<NUM_IR_DESC; i++) {
-		ptxd = aup->tx_ring[i];
-		ptxd->flags = 0;
-		ptxd->count_0 = 0;
-		ptxd->count_1 = 0;
-	}
-
-	for (i=0; i<NUM_IR_DESC; i++) {
-		ptxd = aup->rx_ring[i];
-		ptxd->count_0 = 0;
-		ptxd->count_1 = 0;
-		ptxd->flags = AU_OWN;
-	}
-
-	if (speed == 4000000) {
-#if defined(CONFIG_MIPS_DB1000)
-		bcsr_mod(BCSR_RESETS, 0, BCSR_RESETS_FIR_SEL);
-#else /* Pb1000 and Pb1100 */
-		writel(1<<13, CPLD_AUX1);
-#endif
-	}
-	else {
-#if defined(CONFIG_MIPS_DB1000)
-		bcsr_mod(BCSR_RESETS, BCSR_RESETS_FIR_SEL, 0);
-#else /* Pb1000 and Pb1100 */
-		writel(readl(CPLD_AUX1) & ~(1<<13), CPLD_AUX1);
-#endif
-	}
-
-	switch (speed) {
-	case 9600:	
-		writel(11<<10 | 12<<5, IR_WRITE_PHY_CONFIG); 
-		writel(IR_SIR_MODE, IR_CONFIG_1); 
-		break;
-	case 19200:	
-		writel(5<<10 | 12<<5, IR_WRITE_PHY_CONFIG); 
-		writel(IR_SIR_MODE, IR_CONFIG_1); 
-		break;
-	case 38400:
-		writel(2<<10 | 12<<5, IR_WRITE_PHY_CONFIG); 
-		writel(IR_SIR_MODE, IR_CONFIG_1); 
-		break;
-	case 57600:	
-		writel(1<<10 | 12<<5, IR_WRITE_PHY_CONFIG); 
-		writel(IR_SIR_MODE, IR_CONFIG_1); 
-		break;
-	case 115200: 
-		writel(12<<5, IR_WRITE_PHY_CONFIG); 
-		writel(IR_SIR_MODE, IR_CONFIG_1); 
-		break;
-	case 4000000:
-		writel(0xF, IR_WRITE_PHY_CONFIG);
-		writel(IR_FIR|IR_DMA_ENABLE|IR_RX_ENABLE, IR_CONFIG_1); 
-		break;
-	default:
-		printk(KERN_ERR "%s unsupported speed %x\n", dev->name, speed);
-		ret = -EINVAL;
-		break;
-	}
-
-	aup->speed = speed;
-	writel(read_ir_reg(IR_ENABLE) | 0x8000, IR_ENABLE);
-	au_sync();
-
-	control = read_ir_reg(IR_ENABLE);
-	writel(0, IR_RING_PROMPT);
-	au_sync();
-
-	if (control & (1<<14)) {
-		printk(KERN_ERR "%s: configuration error\n", dev->name);
-	}
-	else {
-		if (control & (1<<11))
-			printk(KERN_DEBUG "%s Valid SIR config\n", dev->name);
-		if (control & (1<<12))
-			printk(KERN_DEBUG "%s Valid MIR config\n", dev->name);
-		if (control & (1<<13))
-			printk(KERN_DEBUG "%s Valid FIR config\n", dev->name);
-		if (control & (1<<10))
-			printk(KERN_DEBUG "%s TX enabled\n", dev->name);
-		if (control & (1<<9))
-			printk(KERN_DEBUG "%s RX enabled\n", dev->name);
-	}
-
-	spin_unlock_irqrestore(&ir_lock, flags);
-	return ret;
-}
-
-static int 
-au1k_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
+static int au1k_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 {
 	struct if_irda_req *rq = (struct if_irda_req *)ifreq;
 	struct au1k_private *aup = netdev_priv(dev);
@@ -826,8 +752,218 @@ au1k_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 	return ret;
 }
 
+static const struct net_device_ops au1k_irda_netdev_ops = {
+	.ndo_open		= au1k_irda_start,
+	.ndo_stop		= au1k_irda_stop,
+	.ndo_start_xmit		= au1k_irda_hard_xmit,
+	.ndo_tx_timeout		= au1k_tx_timeout,
+	.ndo_do_ioctl		= au1k_irda_ioctl,
+};
+
+static int __devinit au1k_irda_net_init(struct net_device *dev)
+{
+	struct au1k_private *aup = netdev_priv(dev);
+	struct db_dest *pDB, *pDBfree;
+	int i, err, retval = 0;
+	dma_addr_t temp;
+
+	err = au1k_irda_init_iobuf(&aup->rx_buff, 14384);
+	if (err)
+		goto out1;
+
+	dev->netdev_ops = &au1k_irda_netdev_ops;
+
+	irda_init_max_qos_capabilies(&aup->qos);
+
+	/* The only value we must override it the baudrate */
+	aup->qos.baud_rate.bits = IR_9600 | IR_19200 | IR_38400 |
+		IR_57600 | IR_115200 | IR_576000 | (IR_4000000 << 8);
+
+	aup->qos.min_turn_time.bits = qos_mtt_bits;
+	irda_qos_bits_to_value(&aup->qos);
+
+	retval = -ENOMEM;
+
+	/* Tx ring follows rx ring + 512 bytes */
+	/* we need a 1k aligned buffer */
+	aup->rx_ring[0] = (struct ring_dest *)
+		dma_alloc(2 * MAX_NUM_IR_DESC * (sizeof(struct ring_dest)),
+			  &temp);
+	if (!aup->rx_ring[0])
+		goto out2;
+
+	/* allocate the data buffers */
+	aup->db[0].vaddr =
+		(void *)dma_alloc(MAX_BUF_SIZE * 2 * NUM_IR_DESC, &temp);
+	if (!aup->db[0].vaddr)
+		goto out3;
+
+	setup_hw_rings(aup, (u32)aup->rx_ring[0], (u32)aup->rx_ring[0] + 512);
+
+	pDBfree = NULL;
+	pDB = aup->db;
+	for (i = 0; i < (2 * NUM_IR_DESC); i++) {
+		pDB->pnext = pDBfree;
+		pDBfree = pDB;
+		pDB->vaddr =
+		       (u32 *)((unsigned)aup->db[0].vaddr + (MAX_BUF_SIZE * i));
+		pDB->dma_addr = (dma_addr_t)virt_to_bus(pDB->vaddr);
+		pDB++;
+	}
+	aup->pDBfree = pDBfree;
+
+	/* attach a data buffer to each descriptor */
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		pDB = GetFreeDB(aup);
+		if (!pDB)
+			goto out3;
+		aup->rx_ring[i]->addr_0 = (u8)(pDB->dma_addr & 0xff);
+		aup->rx_ring[i]->addr_1 = (u8)((pDB->dma_addr >>  8) & 0xff);
+		aup->rx_ring[i]->addr_2 = (u8)((pDB->dma_addr >> 16) & 0xff);
+		aup->rx_ring[i]->addr_3 = (u8)((pDB->dma_addr >> 24) & 0xff);
+		aup->rx_db_inuse[i] = pDB;
+	}
+	for (i = 0; i < NUM_IR_DESC; i++) {
+		pDB = GetFreeDB(aup);
+		if (!pDB)
+			goto out3;
+		aup->tx_ring[i]->addr_0 = (u8)(pDB->dma_addr & 0xff);
+		aup->tx_ring[i]->addr_1 = (u8)((pDB->dma_addr >>  8) & 0xff);
+		aup->tx_ring[i]->addr_2 = (u8)((pDB->dma_addr >> 16) & 0xff);
+		aup->tx_ring[i]->addr_3 = (u8)((pDB->dma_addr >> 24) & 0xff);
+		aup->tx_ring[i]->count_0 = 0;
+		aup->tx_ring[i]->count_1 = 0;
+		aup->tx_ring[i]->flags = 0;
+		aup->tx_db_inuse[i] = pDB;
+	}
+
+	return 0;
+
+out3:
+	dma_free((void *)aup->rx_ring[0],
+		2 * MAX_NUM_IR_DESC * (sizeof(struct ring_dest)));
+out2:
+	kfree(aup->rx_buff.head);
+out1:
+	printk(KERN_ERR "au1k_irda_net_init() failed.  Returns %d\n", retval);
+	return retval;
+}
+
+static int __devinit au1k_irda_probe(struct platform_device *pdev)
+{
+	struct au1k_private *aup;
+	struct net_device *dev;
+	struct resource *r;
+	int err;
+
+	dev = alloc_irdadev(sizeof(struct au1k_private));
+	if (!dev)
+		return -ENOMEM;
+
+	aup = netdev_priv(dev);
+
+	aup->platdata = pdev->dev.platform_data;
+
+	err = -EINVAL;
+	r = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!r)
+		goto out;
+
+	aup->irq_tx = r->start;
+
+	r = platform_get_resource(pdev, IORESOURCE_IRQ, 1);
+	if (!r)
+		goto out;
+
+	aup->irq_rx = r->start;
+
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!r)
+		goto out;
+
+	err = -EBUSY;
+	aup->ioarea = request_mem_region(r->start, r->end - r->start + 1,
+					 pdev->name);
+	if (!aup->ioarea)
+		goto out;
+
+	aup->iobase = ioremap_nocache(r->start, r->end - r->start + 1);
+	if (!aup->iobase)
+		goto out2;
+
+	dev->irq = aup->irq_rx;
+
+	err = au1k_irda_net_init(dev);
+	if (err)
+		goto out3;
+	err = register_netdev(dev);
+	if (err)
+		goto out4;
+
+	platform_set_drvdata(pdev, dev);
+
+	printk(KERN_INFO "IrDA: Registered device %s\n", dev->name);
+	return 0;
+
+out4:
+	dma_free((void *)aup->db[0].vaddr,
+		MAX_BUF_SIZE * 2 * NUM_IR_DESC);
+	dma_free((void *)aup->rx_ring[0],
+		2 * MAX_NUM_IR_DESC * (sizeof(struct ring_dest)));
+	kfree(aup->rx_buff.head);
+out3:
+	iounmap(aup->iobase);
+out2:
+	release_resource(aup->ioarea);
+	kfree(aup->ioarea);
+out:
+	free_netdev(dev);
+	return err;
+}
+
+static int __devexit au1k_irda_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct au1k_private *aup = netdev_priv(dev);
+
+	unregister_netdev(dev);
+
+	dma_free((void *)aup->db[0].vaddr,
+		MAX_BUF_SIZE * 2 * NUM_IR_DESC);
+	dma_free((void *)aup->rx_ring[0],
+		2 * MAX_NUM_IR_DESC * (sizeof(struct ring_dest)));
+	kfree(aup->rx_buff.head);
+
+	iounmap(aup->iobase);
+	release_resource(aup->ioarea);
+	kfree(aup->ioarea);
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+static struct platform_driver au1k_irda_driver = {
+	.driver	= {
+		.name	= "au1000-irda",
+		.owner	= THIS_MODULE,
+	},
+	.probe		= au1k_irda_probe,
+	.remove		= __devexit_p(au1k_irda_remove),
+};
+
+static int __init au1k_irda_load(void)
+{
+	return platform_driver_register(&au1k_irda_driver);
+}
+
+static void __exit au1k_irda_unload(void)
+{
+	return platform_driver_unregister(&au1k_irda_driver);
+}
+
 MODULE_AUTHOR("Pete Popov <ppopov@mvista.com>");
 MODULE_DESCRIPTION("Au1000 IrDA Device Driver");
 
-module_init(au1k_irda_init);
-module_exit(au1k_irda_exit);
+module_init(au1k_irda_load);
+module_exit(au1k_irda_unload);
-- 
1.7.7.1
