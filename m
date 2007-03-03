From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815 driver update (take 2)
Date: Sat, 03 Mar 2007 23:54:59 +0900 (JST)
Message-ID: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	sshtylyov@ru.mvista.com
To: linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Current tc35815 driver is very obsolete and less maintained for a long
time.  Replace it with a new driver based on one from CELF patch
archive.

Major advantages of CELF version (version 1.23, for kernel 2.6.10) are:

* Independent of JMR3927.
  (Actually independent of MIPS, but AFAIK the chip is used only on
   MIPS platforms)
* TX4938 support.
* 64-bit proof.
* Asynchronous and on-demand auto negotiation.
* High performance on non-coherent architecture.
* ethtool support.
* Many bugfixes and cleanups.

And improvoments since version 1.23 are:

* TX4939 support.
* NETPOLL support.
* NAPI support. (disabled by default)
* Reduce memcpy on receiving.
* PM support.
* Many cleanups and bugfixes.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

 drivers/net/Kconfig     |    3 
 drivers/net/tc35815.c   | 2587 ++++++++++++++++++++++++++++++++++------------
 include/linux/pci_ids.h |    2 
 3 files changed, 1917 insertions(+), 675 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5ff0922..52d7239 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1444,7 +1444,8 @@ config CS89x0
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
-	depends on NET_PCI && PCI && TOSHIBA_JMR3927
+	depends on NET_PCI && PCI && MIPS
+	select MII
 
 config DGRS
 	tristate "Digi Intl. RightSwitch SE-X support"
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index e3a7e3c..ec888db 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1,35 +1,72 @@
-/* tc35815.c: A TOSHIBA TC35815CF PCI 10/100Mbps ethernet driver for linux.
- *
- * Copyright 2001 MontaVista Software Inc.
- * Author: MontaVista Software, Inc.
- *                ahennessy@mvista.com
+/*
+ * tc35815.c: A TOSHIBA TC35815CF PCI 10/100Mbps ethernet driver for linux.
  *
  * Based on skelton.c by Donald Becker.
- * Copyright (C) 2000-2001 Toshiba Corporation
  *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This driver is a replacement of older and less maintained version.
+ * This is a header of the older version:
+ *	-----<snip>-----
+ *	Copyright 2001 MontaVista Software Inc.
+ *	Author: MontaVista Software, Inc.
+ *		ahennessy@mvista.com
+ *	Copyright (C) 2000-2001 Toshiba Corporation
+ *	static const char *version =
+ *		"tc35815.c:v0.00 26/07/2000 by Toshiba Corporation\n";
+ *	-----<snip>-----
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
  *
- * THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
- * WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
- * NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
- * USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
- * ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ * (C) Copyright TOSHIBA CORPORATION 2004-2005
+ * All Rights Reserved.
  *
- * You should have received a copy of the  GNU General Public License along
- * with this program; if not, write  to the Free Software Foundation, Inc.,
- * 675 Mass Ave, Cambridge, MA 02139, USA.
+ *  Revision History:
+ *	1.13	64-bit proof.
+ *	1.14	Do not round-up transmit length.
+ *	1.15	Define TC35815_DMA_SYNC_ONDEMAND, cleanup.
+ *	1.16	Fix free_page bug introduced in 1.15
+ *	1.17	Add mii/ethtool ioctl support.
+ *		Remove workaround for early TX4938.  Cleanup.
+ *	1.20	Kernel 2.6.
+ *	1.21	Fix receive packet length (omit CRC).
+ *		Call netif_carrier_on/netif_carrier_off.
+ *		Add kernel/module options (speed, duplex, doforce).
+ *		Do not try "force link mode" by default.
+ *		Reconfigure CAM on restarting.
+ *		Reset PHY on restarting.
+ *		Add workaround for 100MHalf HUB.
+ *	1.22	Minor fix.
+ *	1.23	Minor cleanup.
+ *	1.24	Remove tc35815_setup since new stype option
+ *		("tc35815.speed=10", etc.) can be used for 2.6 kernel.
+ *	1.25	TX4939 support.
+ *	1.26	Minor cleanup.
+ *	1.27	Move TX4939 PCFG.SPEEDn control code out from this driver.
+ *		Cleanup init_dev_addr. (NETDEV_REGISTER event notifier
+ *		can overwrite dev_addr)
+ *		support ETHTOOL_GPERMADDR.
+ *	1.28	Minor cleanup.
+ *	1.29	support netpoll.
+ *	1.30	Minor cleanup.
+ *	1.31	NAPI support. (disabled by default)
+ *		Use DMA_RxAlign_2 if possible.
+ *		Do not use PackedBuffer.
+ *		Cleanup.
+ *	1.32	Fix free buffer management on non-PackedBuffer mode.
+ *	1.33	Fix netpoll build.
+ *	1.34	Fix netpoll locking.  "BH rule" for NAPI is not enough with
+ *		netpoll, hard_start_xmit might be called from irq context.
+ *		PM support.
  */
 
-static const char *version =
-	"tc35815.c:v0.00 26/07/2000 by Toshiba Corporation\n";
+#ifdef TC35815_NAPI
+#define DRV_VERSION	"1.34-NAPI"
+#else
+#define DRV_VERSION	"1.34"
+#endif
+static const char *version = "tc35815.c:v" DRV_VERSION "\n";
+#define MODNAME			"tc35815"
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -40,6 +77,7 @@ static const char *version =
 #include <linux/in.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/spinlock.h>
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -47,36 +85,47 @@ static const char *version =
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/proc_fs.h>
-#include <linux/spinlock.h>
-#include <linux/bitops.h>
-
-#include <asm/system.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
 #include <asm/io.h>
-#include <asm/dma.h>
 #include <asm/byteorder.h>
 
-/*
- * The name of the card. Is used for messages and in the requests for
- * io regions, irqs and dma channels
- */
-static const char* cardname = "TC35815CF";
-#define TC35815_PROC_ENTRY "net/tc35815"
-
-#define TC35815_MODULE_NAME "TC35815CF"
-#define TX_TIMEOUT (4*HZ)
-
 /* First, a few definitions that the brave might change. */
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef TC35815_DEBUG
-#define TC35815_DEBUG 1
-#endif
-static unsigned int tc35815_debug = TC35815_DEBUG;
-
 #define GATHER_TXINT	/* On-Demand Tx Interrupt */
+#define WORKAROUND_LOSTCAR
+#define WORKAROUND_100HALF_PROMISC
+/* #define TC35815_USE_PACKEDBUFFER */
+
+typedef enum {
+	TC35815CF = 0,
+	TC35815_NWU,
+	TC35815_TX4939,
+} board_t;
+
+/* indexed by board_t, above */
+static const struct {
+	const char *name;
+} board_info[] __devinitdata = {
+	{ "TOSHIBA TC35815CF 10/100BaseTX" },
+	{ "TOSHIBA TC35815 with Wake on LAN" },
+	{ "TOSHIBA TC35815/TX4939" },
+};
+
+static const struct pci_device_id tc35815_pci_tbl[] = {
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF), .driver_data = TC35815CF },
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU), .driver_data = TC35815_NWU },
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
+	{0,}
+};
+MODULE_DEVICE_TABLE (pci, tc35815_pci_tbl);
 
-#define vtonocache(p)	KSEG1ADDR(virt_to_phys(p))
+/* see MODULE_PARM_DESC */
+static struct tc35815_options {
+	int speed;
+	int duplex;
+	int doforce;
+} options;
 
 /*
  * Registers
@@ -119,6 +168,11 @@ struct tc35815_regs {
  * Bit assignments
  */
 /* DMA_Ctl bit asign ------------------------------------------------------- */
+#define DMA_RxAlign            0x00c00000 /* 1:Reception Alignment           */
+#define DMA_RxAlign_1          0x00400000
+#define DMA_RxAlign_2          0x00800000
+#define DMA_RxAlign_3          0x00c00000
+#define DMA_M66EnStat          0x00080000 /* 1:66MHz Enable State            */
 #define DMA_IntMask            0x00040000 /* 1:Interupt mask                 */
 #define DMA_SWIntReq           0x00020000 /* 1:Software Interrupt request    */
 #define DMA_TxWakeUp           0x00010000 /* 1:Transmit Wake Up              */
@@ -269,42 +323,6 @@ struct tc35815_regs {
 #define MD_CA_Wr               0x00000400 /* 1:Write 0:Read                  */
 
 
-/* MII register offsets */
-#define MII_CONTROL             0x0000
-#define MII_STATUS              0x0001
-#define MII_PHY_ID0             0x0002
-#define MII_PHY_ID1             0x0003
-#define MII_ANAR                0x0004
-#define MII_ANLPAR              0x0005
-#define MII_ANER                0x0006
-/* MII Control register bit definitions. */
-#define MIICNTL_FDX             0x0100
-#define MIICNTL_RST_AUTO        0x0200
-#define MIICNTL_ISOLATE         0x0400
-#define MIICNTL_PWRDWN          0x0800
-#define MIICNTL_AUTO            0x1000
-#define MIICNTL_SPEED           0x2000
-#define MIICNTL_LPBK            0x4000
-#define MIICNTL_RESET           0x8000
-/* MII Status register bit significance. */
-#define MIISTAT_EXT             0x0001
-#define MIISTAT_JAB             0x0002
-#define MIISTAT_LINK            0x0004
-#define MIISTAT_CAN_AUTO        0x0008
-#define MIISTAT_FAULT           0x0010
-#define MIISTAT_AUTO_DONE       0x0020
-#define MIISTAT_CAN_T           0x0800
-#define MIISTAT_CAN_T_FDX       0x1000
-#define MIISTAT_CAN_TX          0x2000
-#define MIISTAT_CAN_TX_FDX      0x4000
-#define MIISTAT_CAN_T4          0x8000
-/* MII Auto-Negotiation Expansion/RemoteEnd Register Bits */
-#define MII_AN_TX_FDX           0x0100
-#define MII_AN_TX_HDX           0x0080
-#define MII_AN_10_FDX           0x0040
-#define MII_AN_10_HDX           0x0020
-
-
 /*
  * Descriptors
  */
@@ -352,32 +370,51 @@ struct BDesc {
 
 #ifdef NO_CHECK_CARRIER
 #define TX_CTL_CMD	(Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
-	Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | Tx_EnUnder | \
-	Tx_En)	/* maybe  0x7d01 */
+	Tx_EnExColl | Tx_EnExDefer | Tx_EnUnder | \
+	Tx_En)	/* maybe  0x7b01 */
 #else
 #define TX_CTL_CMD	(Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
-	Tx_EnExColl | Tx_EnExDefer | Tx_EnUnder | \
-	Tx_En)	/* maybe  0x7f01 */
+	Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | Tx_EnUnder | \
+	Tx_En)	/* maybe  0x7b01 */
 #endif
 #define RX_CTL_CMD	(Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver \
 	| Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn)	/* maybe 0x6f01 */
-
 #define INT_EN_CMD  (Int_NRAbtEn | \
-	 Int_DParDEn | Int_DParErrEn | \
+	Int_DmParErrEn | Int_DParDEn | Int_DParErrEn | \
 	Int_SSysErrEn  | Int_RMasAbtEn | Int_RTargAbtEn | \
 	Int_STargAbtEn | \
 	Int_BLExEn  | Int_FDAExEn) /* maybe 0xb7f*/
+#define DMA_CTL_CMD	DMA_BURST_SIZE
+#define HAVE_DMA_RXALIGN(lp)	likely((lp)->boardtype != TC35815CF)
 
 /* Tuning parameters */
 #define DMA_BURST_SIZE	32
 #define TX_THRESHOLD	1024
+#define TX_THRESHOLD_MAX 1536       /* used threshold with packet max byte for low pci transfer ability.*/
+#define TX_THRESHOLD_KEEP_LIMIT 10  /* setting threshold max value when overrun error occured this count. */
 
+/* 16 + RX_BUF_NUM * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*FD_PAGE_NUM */
+#ifdef TC35815_USE_PACKEDBUFFER
 #define FD_PAGE_NUM 2
-#define FD_PAGE_ORDER 1
-/* 16 + RX_BUF_PAGES * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*2 */
-#define RX_BUF_PAGES	8	/* >= 2 */
+#define RX_BUF_NUM	8	/* >= 2 */
 #define RX_FD_NUM	250	/* >= 32 */
 #define TX_FD_NUM	128
+#define RX_BUF_SIZE	PAGE_SIZE
+#else /* TC35815_USE_PACKEDBUFFER */
+#define FD_PAGE_NUM 4
+#define RX_BUF_NUM	128	/* < 256 */
+#define RX_FD_NUM	256	/* >= 32 */
+#define TX_FD_NUM	128
+#if RX_CTL_CMD & Rx_LongEn
+#define RX_BUF_SIZE	PAGE_SIZE
+#elif RX_CTL_CMD & Rx_StripCRC
+#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 4 + 2, 32) /* +2: reserve */
+#else
+#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 2, 32) /* +2: reserve */
+#endif
+#endif /* TC35815_USE_PACKEDBUFFER */
+#define RX_FD_RESERVE	(2 / 2)	/* max 2 BD per RxFD */
+#define NAPI_WEIGHT	16
 
 struct TxFD {
 	struct FDesc fd;
@@ -392,18 +429,27 @@ struct RxFD {
 
 struct FrFD {
 	struct FDesc fd;
-	struct BDesc bd[RX_BUF_PAGES];
+	struct BDesc bd[RX_BUF_NUM];
 };
 
 
-extern unsigned long tc_readl(volatile __u32 *addr);
-extern void tc_writel(unsigned long data, volatile __u32 *addr);
+#define tc_readl(addr)	readl(addr)
+#define tc_writel(d, addr)	writel(d, addr)
 
-dma_addr_t priv_dma_handle;
+#define TC35815_TX_TIMEOUT  msecs_to_jiffies(400)
+
+/* Timer state engine. */
+enum tc35815_timer_state {
+	arbwait  = 0,	/* Waiting for auto negotiation to complete.          */
+	lupwait  = 1,	/* Auto-neg complete, awaiting link-up status.        */
+	ltrywait = 2,	/* Forcing try of all modes, from fastest to slowest. */
+	asleep   = 3,	/* Time inactive.                                     */
+	lcheck   = 4,	/* Check link status.                                 */
+};
 
 /* Information that need to be kept for each board. */
 struct tc35815_local {
-	struct net_device *next_module;
+	struct pci_dev *pci_dev;
 
 	/* statistics */
 	struct net_device_stats stats;
@@ -411,216 +457,372 @@ struct tc35815_local {
 		int max_tx_qlen;
 		int tx_ints;
 		int rx_ints;
+	        int tx_underrun;
 	} lstats;
 
-	int tbusy;
-	int option;
-#define TC35815_OPT_AUTO	0x00
-#define TC35815_OPT_10M	0x01
-#define TC35815_OPT_100M	0x02
-#define TC35815_OPT_FULLDUP	0x04
-	int linkspeed;	/* 10 or 100 */
+	/* Tx control lock.  This protects the transmit buffer ring
+	 * state along with the "tx full" state of the driver.  This
+	 * means all netif_queue flow control actions are protected
+	 * by this lock as well.
+	 */
+	spinlock_t lock;
+
+	int phy_addr;
 	int fullduplex;
+	unsigned short saved_lpa;
+	struct timer_list timer;
+	enum tc35815_timer_state timer_state; /* State of auto-neg timer. */
+	unsigned int timer_ticks;	/* Number of clicks at each state  */
 
 	/*
 	 * Transmitting: Batch Mode.
 	 *	1 BD in 1 TxFD.
-	 * Receiving: Packing Mode.
+	 * Receiving: Packing Mode. (TC35815_USE_PACKEDBUFFER)
 	 *	1 circular FD for Free Buffer List.
-	 *	RX_BUG_PAGES BD in Free Buffer FD.
+	 *	RX_BUF_NUM BD in Free Buffer FD.
 	 *	One Free Buffer BD has PAGE_SIZE data buffer.
+	 * Or Non-Packing Mode.
+	 *	1 circular FD for Free Buffer List.
+	 *	RX_BUF_NUM BD in Free Buffer FD.
+	 *	One Free Buffer BD has ETH_FRAME_LEN data buffer.
 	 */
-        struct pci_dev *pdev;
-	dma_addr_t fd_buf_dma_handle;
-	void * fd_buf;	/* for TxFD, TxFD, FrFD */
+	void * fd_buf;	/* for TxFD, RxFD, FrFD */
+	dma_addr_t fd_buf_dma;
 	struct TxFD *tfd_base;
-	int tfd_start;
-	int tfd_end;
+	unsigned int tfd_start;
+	unsigned int tfd_end;
 	struct RxFD *rfd_base;
 	struct RxFD *rfd_limit;
 	struct RxFD *rfd_cur;
 	struct FrFD *fbl_ptr;
+#ifdef TC35815_USE_PACKEDBUFFER
 	unsigned char fbl_curid;
-	dma_addr_t data_buf_dma_handle[RX_BUF_PAGES];
-	void * data_buf[RX_BUF_PAGES];		/* packing */
-	spinlock_t lock;
+	void * data_buf[RX_BUF_NUM];		/* packing */
+	dma_addr_t data_buf_dma[RX_BUF_NUM];
+	struct {
+		struct sk_buff *skb;
+		dma_addr_t skb_dma;
+	} tx_skbs[TX_FD_NUM];
+#else
+	unsigned int fbl_count;
+	struct {
+		struct sk_buff *skb;
+		dma_addr_t skb_dma;
+	} tx_skbs[TX_FD_NUM], rx_skbs[RX_BUF_NUM];
+#endif
+	struct mii_if_info mii;
+	unsigned short mii_id[2];
+	u32 msg_enable;
+	board_t boardtype;
 };
 
-/* Index to functions, as function prototypes. */
+static inline dma_addr_t fd_virt_to_bus(struct tc35815_local *lp, void *virt)
+{
+	return lp->fd_buf_dma + ((u8 *)virt - (u8 *)lp->fd_buf);
+}
+#ifdef DEBUG
+static inline void *fd_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
+{
+	return (void *)((u8 *)lp->fd_buf + (bus - lp->fd_buf_dma));
+}
+#endif
+#ifdef TC35815_USE_PACKEDBUFFER
+static inline void *rxbuf_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
+{
+	int i;
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		if (bus >= lp->data_buf_dma[i] &&
+		    bus < lp->data_buf_dma[i] + PAGE_SIZE)
+			return (void *)((u8 *)lp->data_buf[i] +
+					(bus - lp->data_buf_dma[i]));
+	}
+	return NULL;
+}
 
-static int __devinit tc35815_probe1(struct pci_dev *pdev, unsigned int base_addr, unsigned int irq);
+#define TC35815_DMA_SYNC_ONDEMAND
+static void* alloc_rxbuf_page(struct pci_dev *hwdev, dma_addr_t *dma_handle)
+{
+#ifdef TC35815_DMA_SYNC_ONDEMAND
+	void *buf;
+	/* pci_map + pci_dma_sync will be more effective than
+	 * pci_alloc_consistent on some archs. */
+	if ((buf = (void *)__get_free_page(GFP_ATOMIC)) == NULL)
+		return NULL;
+	*dma_handle = pci_map_single(hwdev, buf, PAGE_SIZE,
+				     PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(*dma_handle)) {
+		free_page((unsigned long)buf);
+		return NULL;
+	}
+	return buf;
+#else
+	return pci_alloc_consistent(hwdev, PAGE_SIZE, dma_handle);
+#endif
+}
+
+static void free_rxbuf_page(struct pci_dev *hwdev, void *buf, dma_addr_t dma_handle)
+{
+#ifdef TC35815_DMA_SYNC_ONDEMAND
+	pci_unmap_single(hwdev, dma_handle, PAGE_SIZE, PCI_DMA_FROMDEVICE);
+	free_page((unsigned long)buf);
+#else
+	pci_free_consistent(hwdev, PAGE_SIZE, buf, dma_handle);
+#endif
+}
+#else /* TC35815_USE_PACKEDBUFFER */
+static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
+				       struct pci_dev *hwdev,
+				       dma_addr_t *dma_handle)
+{
+	struct sk_buff *skb;
+	skb = dev_alloc_skb(RX_BUF_SIZE);
+	if (!skb)
+		return NULL;
+	skb->dev = dev;
+	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
+				     PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(*dma_handle)) {
+		dev_kfree_skb_any(skb);
+		return NULL;
+	}
+	skb_reserve(skb, 2);	/* make IP header 4byte aligned */
+	return skb;
+}
+
+static void free_rxbuf_skb(struct pci_dev *hwdev, struct sk_buff *skb, dma_addr_t dma_handle)
+{
+	pci_unmap_single(hwdev, dma_handle, RX_BUF_SIZE,
+			 PCI_DMA_FROMDEVICE);
+	dev_kfree_skb_any(skb);
+}
+#endif /* TC35815_USE_PACKEDBUFFER */
+
+/* Index to functions, as function prototypes. */
 
 static int	tc35815_open(struct net_device *dev);
 static int	tc35815_send_packet(struct sk_buff *skb, struct net_device *dev);
-static void     tc35815_tx_timeout(struct net_device *dev);
-static irqreturn_t tc35815_interrupt(int irq, void *dev_id);
+static irqreturn_t	tc35815_interrupt(int irq, void *dev_id);
+#ifdef TC35815_NAPI
+static int	tc35815_rx(struct net_device *dev, int limit);
+static int	tc35815_poll(struct net_device *dev, int *budget);
+#else
 static void	tc35815_rx(struct net_device *dev);
+#endif
 static void	tc35815_txdone(struct net_device *dev);
 static int	tc35815_close(struct net_device *dev);
 static struct	net_device_stats *tc35815_get_stats(struct net_device *dev);
 static void	tc35815_set_multicast_list(struct net_device *dev);
+static void     tc35815_tx_timeout(struct net_device *dev);
+static int	tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void	tc35815_poll_controller(struct net_device *dev);
+#endif
+static const struct ethtool_ops tc35815_ethtool_ops;
 
+/* Example routines you must write ;->. */
 static void 	tc35815_chip_reset(struct net_device *dev);
 static void 	tc35815_chip_init(struct net_device *dev);
+static void	tc35815_find_phy(struct net_device *dev);
 static void 	tc35815_phy_chip_init(struct net_device *dev);
 
-/* A list of all installed tc35815 devices. */
-static struct net_device *root_tc35815_dev = NULL;
+#ifdef DEBUG
+static void	panic_queues(struct net_device *dev);
+#endif
 
-/*
- * PCI device identifiers for "new style" Linux PCI Device Drivers
- */
-static struct pci_device_id tc35815_pci_tbl[] = {
-    { PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-    { 0, }
-};
+static void tc35815_timer(unsigned long data);
+static void tc35815_start_auto_negotiation(struct net_device *dev,
+					   struct ethtool_cmd *ep);
+static int tc_mdio_read(struct net_device *dev, int phy_id, int location);
+static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
+			  int val);
 
-MODULE_DEVICE_TABLE (pci, tc35815_pci_tbl);
+static void __devinit tc35815_init_dev_addr (struct net_device *dev)
+{
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int i;
 
-int
-tc35815_probe(struct pci_dev *pdev,
-		const struct pci_device_id *ent)
+	/* dev_addr will be overwritten on NETDEV_REGISTER event */
+	while (tc_readl(&tr->PROM_Ctl) & PROM_Busy)
+		;
+	for (i = 0; i < 6; i += 2) {
+		unsigned short data;
+		tc_writel(PROM_Busy | PROM_Read | (i / 2 + 2), &tr->PROM_Ctl);
+		while (tc_readl(&tr->PROM_Ctl) & PROM_Busy)
+			;
+		data = tc_readl(&tr->PROM_Data);
+		dev->dev_addr[i] = data & 0xff;
+		dev->dev_addr[i+1] = data >> 8;
+	}
+}
+
+static int __devinit tc35815_init_one (struct pci_dev *pdev,
+				       const struct pci_device_id *ent)
 {
-	int err = 0;
-	int ret;
-	unsigned long pci_memaddr;
-	unsigned int pci_irq_line;
+	void __iomem *ioaddr = NULL;
+	struct net_device *dev;
+	struct tc35815_local *lp;
+	int rc;
+	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
+
+	static int printed_version;
+	if (!printed_version++) {
+		printk(version);
+		dev_printk(KERN_DEBUG, &pdev->dev,
+			   "speed:%d duplex:%d doforce:%d\n",
+			   options.speed, options.duplex, options.doforce);
+	}
 
-	printk(KERN_INFO "tc35815_probe: found device %#08x.%#08x\n", ent->vendor, ent->device);
+	if (!pdev->irq) {
+		dev_warn(&pdev->dev, "no IRQ assigned.\n");
+		return -ENODEV;
+	}
 
-	err = pci_enable_device(pdev);
-	if (err)
-		return err;
+	/* dev zeroed in alloc_etherdev */
+	dev = alloc_etherdev (sizeof (*lp));
+	if (dev == NULL) {
+		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
+		return -ENOMEM;
+	}
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	lp = dev->priv;
 
-        pci_memaddr = pci_resource_start (pdev, 1);
+	/* enable device (incl. PCI PM wakeup), and bus-mastering */
+	rc = pci_enable_device (pdev);
+	if (rc)
+		goto err_out;
 
-        printk(KERN_INFO "    pci_memaddr=%#08lx  resource_flags=%#08lx\n", pci_memaddr, pci_resource_flags (pdev, 0));
+	mmio_start = pci_resource_start (pdev, 1);
+	mmio_end = pci_resource_end (pdev, 1);
+	mmio_flags = pci_resource_flags (pdev, 1);
+	mmio_len = pci_resource_len (pdev, 1);
 
-	if (!pci_memaddr) {
-		printk(KERN_WARNING "no PCI MEM resources, aborting\n");
-		ret = -ENODEV;
+	/* set this immediately, we need to know before
+	 * we talk to the chip directly */
+
+	/* make sure PCI base addr 1 is MMIO */
+	if (!(mmio_flags & IORESOURCE_MEM)) {
+		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
+		rc = -ENODEV;
 		goto err_out;
 	}
-	pci_irq_line = pdev->irq;
-	/* irq disabled. */
-	if (pci_irq_line == 0) {
-		printk(KERN_WARNING "no PCI irq, aborting\n");
-		ret = -ENODEV;
+
+	/* check for weird/broken PCI region reporting */
+	if ((mmio_len < sizeof(struct tc35815_regs))) {
+		dev_err(&pdev->dev, "Invalid PCI region size(s), aborting\n");
+		rc = -ENODEV;
 		goto err_out;
 	}
 
-	ret =  tc35815_probe1(pdev, pci_memaddr, pci_irq_line);
-	if (ret)
+	rc = pci_request_regions (pdev, MODNAME);
+	if (rc)
 		goto err_out;
 
-	pci_set_master(pdev);
+	pci_set_master (pdev);
 
-	return 0;
-
-err_out:
-	pci_disable_device(pdev);
-	return ret;
-}
+	/* ioremap MMIO region */
+	ioaddr = ioremap (mmio_start, mmio_len);
+	if (ioaddr == NULL) {
+		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
+		rc = -EIO;
+		goto err_out_free_res;
+	}
 
-static int __devinit tc35815_probe1(struct pci_dev *pdev, unsigned int base_addr, unsigned int irq)
-{
-	static unsigned version_printed = 0;
-	int i, ret;
-	struct tc35815_local *lp;
-	struct tc35815_regs *tr;
-	struct net_device *dev;
+	/* Initialize the device structure. */
+	dev->open = tc35815_open;
+	dev->hard_start_xmit = tc35815_send_packet;
+	dev->stop = tc35815_close;
+	dev->get_stats = tc35815_get_stats;
+	dev->set_multicast_list = tc35815_set_multicast_list;
+	dev->do_ioctl = tc35815_ioctl;
+	dev->ethtool_ops = &tc35815_ethtool_ops;
+	dev->tx_timeout = tc35815_tx_timeout;
+	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
+#ifdef TC35815_NAPI
+	dev->poll = tc35815_poll;
+	dev->weight = NAPI_WEIGHT;
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = tc35815_poll_controller;
+#endif
 
-	/* Allocate a new 'dev' if needed. */
-	dev = alloc_etherdev(sizeof(struct tc35815_local));
-	if (dev == NULL)
-		return -ENOMEM;
+	dev->irq = pdev->irq;
+	dev->base_addr = (unsigned long) ioaddr;
 
-	/*
-	 * alloc_etherdev allocs and zeros dev->priv
-	 */
+	/* dev->priv/lp zeroed and aligned in alloc_etherdev */
 	lp = dev->priv;
+	spin_lock_init(&lp->lock);
+	lp->pci_dev = pdev;
+	lp->boardtype = ent->driver_data;
 
-	if (tc35815_debug  &&  version_printed++ == 0)
-		printk(KERN_DEBUG "%s", version);
-
-	/* Fill in the 'dev' fields. */
-	dev->irq = irq;
-	dev->base_addr = (unsigned long)ioremap(base_addr,
-						sizeof(struct tc35815_regs));
-	if (!dev->base_addr) {
-		ret = -ENOMEM;
-		goto err_out;
-	}
-	tr = (struct tc35815_regs*)dev->base_addr;
+	lp->msg_enable = NETIF_MSG_TX_ERR | NETIF_MSG_HW | NETIF_MSG_DRV | NETIF_MSG_LINK;
+	pci_set_drvdata(pdev, dev);
 
+	/* Soft reset the chip. */
 	tc35815_chip_reset(dev);
 
-	/* Retrieve and print the ethernet address. */
-	while (tc_readl(&tr->PROM_Ctl) & PROM_Busy)
-		;
-	for (i = 0; i < 6; i += 2) {
-		unsigned short data;
-		tc_writel(PROM_Busy | PROM_Read | (i / 2 + 2), &tr->PROM_Ctl);
-		while (tc_readl(&tr->PROM_Ctl) & PROM_Busy)
-			;
-		data = tc_readl(&tr->PROM_Data);
-		dev->dev_addr[i] = data & 0xff;
-		dev->dev_addr[i+1] = data >> 8;
-	}
+	/* Retrieve the ethernet address. */
+	tc35815_init_dev_addr(dev);
+
+	rc = register_netdev (dev);
+	if (rc)
+		goto err_out_unmap;
+
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+	printk(KERN_INFO "%s: %s at 0x%lx, "
+		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
+		"IRQ %d\n",
+		dev->name,
+		board_info[ent->driver_data].name,
+		dev->base_addr,
+		dev->dev_addr[0], dev->dev_addr[1],
+		dev->dev_addr[2], dev->dev_addr[3],
+		dev->dev_addr[4], dev->dev_addr[5],
+		dev->irq);
+
+	setup_timer(&lp->timer, tc35815_timer, (unsigned long) dev);
+	lp->mii.dev = dev;
+	lp->mii.mdio_read = tc_mdio_read;
+	lp->mii.mdio_write = tc_mdio_write;
+	lp->mii.phy_id_mask = 0x1f;
+	lp->mii.reg_num_mask = 0x1f;
+	tc35815_find_phy(dev);
+	lp->mii.phy_id = lp->phy_addr;
+	lp->mii.full_duplex = 0;
+	lp->mii.force_media = 0;
 
-	/* Initialize the device structure. */
-	lp->pdev = pdev;
-	lp->next_module = root_tc35815_dev;
-	root_tc35815_dev = dev;
+	return 0;
 
-	spin_lock_init(&lp->lock);
+err_out_unmap:
+	iounmap(ioaddr);
+err_out_free_res:
+	pci_release_regions (pdev);
+err_out:
+	free_netdev (dev);
+	return rc;
+}
 
-	if (dev->mem_start > 0) {
-		lp->option = dev->mem_start;
-		if ((lp->option & TC35815_OPT_10M) &&
-		    (lp->option & TC35815_OPT_100M)) {
-			/* if both speed speficied, auto select. */
-			lp->option &= ~(TC35815_OPT_10M | TC35815_OPT_100M);
-		}
-	}
-	//XXX fixme
-        lp->option |= TC35815_OPT_10M;
 
-	/* do auto negotiation */
-	tc35815_phy_chip_init(dev);
+static void __devexit tc35815_remove_one (struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata (pdev);
+	unsigned long mmio_addr;
 
-	dev->open		= tc35815_open;
-	dev->stop		= tc35815_close;
-	dev->tx_timeout         = tc35815_tx_timeout;
-	dev->watchdog_timeo     = TX_TIMEOUT;
-	dev->hard_start_xmit	= tc35815_send_packet;
-	dev->get_stats		= tc35815_get_stats;
-	dev->set_multicast_list = tc35815_set_multicast_list;
-	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	mmio_addr = dev->base_addr;
 
-	ret = register_netdev(dev);
-	if (ret)
-		goto err_out_iounmap;
+	unregister_netdev (dev);
 
-	printk(KERN_INFO "%s: %s found at %#x, irq %d, MAC",
-	       dev->name, cardname, base_addr, irq);
-	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i]);
-	printk("\n");
-	printk(KERN_INFO "%s: linkspeed %dMbps, %s Duplex\n",
-	       dev->name, lp->linkspeed, lp->fullduplex ? "Full" : "Half");
+	if (mmio_addr) {
+		iounmap ((void __iomem *)mmio_addr);
+		pci_release_regions (pdev);
+	}
 
-	return 0;
+	free_netdev (dev);
 
-err_out_iounmap:
-	iounmap((void *) dev->base_addr);
-err_out:
-	free_netdev(dev);
-	return ret;
+	pci_set_drvdata (pdev, NULL);
 }
 
-
 static int
 tc35815_init_queues(struct net_device *dev)
 {
@@ -629,44 +831,64 @@ tc35815_init_queues(struct net_device *d
 	unsigned long fd_addr;
 
 	if (!lp->fd_buf) {
-		if (sizeof(struct FDesc) +
-		    sizeof(struct BDesc) * RX_BUF_PAGES +
-		    sizeof(struct FDesc) * RX_FD_NUM +
-		    sizeof(struct TxFD) * TX_FD_NUM > PAGE_SIZE * FD_PAGE_NUM) {
-			printk(KERN_WARNING "%s: Invalid Queue Size.\n", dev->name);
-			return -ENOMEM;
-		}
+		BUG_ON(sizeof(struct FDesc) +
+		       sizeof(struct BDesc) * RX_BUF_NUM +
+		       sizeof(struct FDesc) * RX_FD_NUM +
+		       sizeof(struct TxFD) * TX_FD_NUM >
+		       PAGE_SIZE * FD_PAGE_NUM);
 
-		if ((lp->fd_buf = (void *)__get_free_pages(GFP_KERNEL, FD_PAGE_ORDER)) == 0)
+		if ((lp->fd_buf = pci_alloc_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM, &lp->fd_buf_dma)) == 0)
 			return -ENOMEM;
-		for (i = 0; i < RX_BUF_PAGES; i++) {
-			if ((lp->data_buf[i] = (void *)get_zeroed_page(GFP_KERNEL)) == 0) {
+		for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
+			if ((lp->data_buf[i] = alloc_rxbuf_page(lp->pci_dev, &lp->data_buf_dma[i])) == NULL) {
 				while (--i >= 0) {
-					free_page((unsigned long)lp->data_buf[i]);
-					lp->data_buf[i] = 0;
+					free_rxbuf_page(lp->pci_dev,
+							lp->data_buf[i],
+							lp->data_buf_dma[i]);
+					lp->data_buf[i] = NULL;
 				}
-				free_page((unsigned long)lp->fd_buf);
-				lp->fd_buf = 0;
+				pci_free_consistent(lp->pci_dev,
+						    PAGE_SIZE * FD_PAGE_NUM,
+						    lp->fd_buf,
+						    lp->fd_buf_dma);
+				lp->fd_buf = NULL;
+				return -ENOMEM;
+			}
+#else
+			lp->rx_skbs[i].skb =
+				alloc_rxbuf_skb(dev, lp->pci_dev,
+						&lp->rx_skbs[i].skb_dma);
+			if (!lp->rx_skbs[i].skb) {
+				while (--i >= 0) {
+					free_rxbuf_skb(lp->pci_dev,
+						       lp->rx_skbs[i].skb,
+						       lp->rx_skbs[i].skb_dma);
+					lp->rx_skbs[i].skb = NULL;
+				}
+				pci_free_consistent(lp->pci_dev,
+						    PAGE_SIZE * FD_PAGE_NUM,
+						    lp->fd_buf,
+						    lp->fd_buf_dma);
+				lp->fd_buf = NULL;
 				return -ENOMEM;
 			}
-#ifdef __mips__
-			dma_cache_wback_inv((unsigned long)lp->data_buf[i], PAGE_SIZE * FD_PAGE_NUM);
 #endif
 		}
-#ifdef __mips__
-		dma_cache_wback_inv((unsigned long)lp->fd_buf, PAGE_SIZE * FD_PAGE_NUM);
+		printk(KERN_DEBUG "%s: FD buf %p DataBuf",
+		       dev->name, lp->fd_buf);
+#ifdef TC35815_USE_PACKEDBUFFER
+		printk(" DataBuf");
+		for (i = 0; i < RX_BUF_NUM; i++)
+			printk(" %p", lp->data_buf[i]);
 #endif
+		printk("\n");
 	} else {
-		memset(lp->fd_buf, 0, PAGE_SIZE * FD_PAGE_NUM);
-#ifdef __mips__
-		dma_cache_wback_inv((unsigned long)lp->fd_buf, PAGE_SIZE * FD_PAGE_NUM);
-#endif
+		for (i = 0; i < FD_PAGE_NUM; i++) {
+			clear_page((void *)((unsigned long)lp->fd_buf + i * PAGE_SIZE));
+		}
 	}
-#ifdef __mips__
-	fd_addr = (unsigned long)vtonocache(lp->fd_buf);
-#else
 	fd_addr = (unsigned long)lp->fd_buf;
-#endif
 
 	/* Free Descriptors (for Receive) */
 	lp->rfd_base = (struct RxFD *)fd_addr;
@@ -675,34 +897,66 @@ tc35815_init_queues(struct net_device *d
 		lp->rfd_base[i].fd.FDCtl = cpu_to_le32(FD_CownsFD);
 	}
 	lp->rfd_cur = lp->rfd_base;
-	lp->rfd_limit = (struct RxFD *)(fd_addr -
-					sizeof(struct FDesc) -
-					sizeof(struct BDesc) * 30);
+	lp->rfd_limit = (struct RxFD *)fd_addr - (RX_FD_RESERVE + 1);
 
 	/* Transmit Descriptors */
 	lp->tfd_base = (struct TxFD *)fd_addr;
 	fd_addr += sizeof(struct TxFD) * TX_FD_NUM;
 	for (i = 0; i < TX_FD_NUM; i++) {
-		lp->tfd_base[i].fd.FDNext = cpu_to_le32(virt_to_bus(&lp->tfd_base[i+1]));
-		lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0);
+		lp->tfd_base[i].fd.FDNext = cpu_to_le32(fd_virt_to_bus(lp, &lp->tfd_base[i+1]));
+		lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0xffffffff);
 		lp->tfd_base[i].fd.FDCtl = cpu_to_le32(0);
 	}
-	lp->tfd_base[TX_FD_NUM-1].fd.FDNext = cpu_to_le32(virt_to_bus(&lp->tfd_base[0]));
+	lp->tfd_base[TX_FD_NUM-1].fd.FDNext = cpu_to_le32(fd_virt_to_bus(lp, &lp->tfd_base[0]));
 	lp->tfd_start = 0;
 	lp->tfd_end = 0;
 
 	/* Buffer List (for Receive) */
 	lp->fbl_ptr = (struct FrFD *)fd_addr;
-	lp->fbl_ptr->fd.FDNext = cpu_to_le32(virt_to_bus(lp->fbl_ptr));
-	lp->fbl_ptr->fd.FDCtl = cpu_to_le32(RX_BUF_PAGES | FD_CownsFD);
-	for (i = 0; i < RX_BUF_PAGES; i++) {
-		lp->fbl_ptr->bd[i].BuffData = cpu_to_le32(virt_to_bus(lp->data_buf[i]));
+	lp->fbl_ptr->fd.FDNext = cpu_to_le32(fd_virt_to_bus(lp, lp->fbl_ptr));
+	lp->fbl_ptr->fd.FDCtl = cpu_to_le32(RX_BUF_NUM | FD_CownsFD);
+#ifndef TC35815_USE_PACKEDBUFFER
+	/*
+	 * move all allocated skbs to head of rx_skbs[] array.
+	 * fbl_count mighe not be RX_BUF_NUM if alloc_rxbuf_skb() in
+	 * tc35815_rx() had failed.
+	 */
+	lp->fbl_count = 0;
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		if (lp->rx_skbs[i].skb) {
+			if (i != lp->fbl_count) {
+				lp->rx_skbs[lp->fbl_count].skb =
+					lp->rx_skbs[i].skb;
+				lp->rx_skbs[lp->fbl_count].skb_dma =
+					lp->rx_skbs[i].skb_dma;
+			}
+			lp->fbl_count++;
+		}
+	}
+#endif
+	for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
+		lp->fbl_ptr->bd[i].BuffData = cpu_to_le32(lp->data_buf_dma[i]);
+#else
+		if (i >= lp->fbl_count) {
+			lp->fbl_ptr->bd[i].BuffData = 0;
+			lp->fbl_ptr->bd[i].BDCtl = 0;
+			continue;
+		}
+		lp->fbl_ptr->bd[i].BuffData =
+			cpu_to_le32(lp->rx_skbs[i].skb_dma);
+#endif
 		/* BDID is index of FrFD.bd[] */
 		lp->fbl_ptr->bd[i].BDCtl =
-			cpu_to_le32(BD_CownsBD | (i << BD_RxBDID_SHIFT) | PAGE_SIZE);
+			cpu_to_le32(BD_CownsBD | (i << BD_RxBDID_SHIFT) |
+				    RX_BUF_SIZE);
 	}
+#ifdef TC35815_USE_PACKEDBUFFER
 	lp->fbl_curid = 0;
+#endif
 
+	printk(KERN_DEBUG "%s: TxFD %p RxFD %p FrFD %p\n",
+	       dev->name, lp->tfd_base, lp->rfd_base, lp->fbl_ptr);
 	return 0;
 }
 
@@ -713,11 +967,25 @@ tc35815_clear_queues(struct net_device *
 	int i;
 
 	for (i = 0; i < TX_FD_NUM; i++) {
-		struct sk_buff *skb = (struct sk_buff *)
-			le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
-		if (skb)
+		u32 fdsystem = le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
+		struct sk_buff *skb =
+			fdsystem != 0xffffffff ?
+			lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
+		if (lp->tx_skbs[i].skb != skb) {
+			printk("%s: tx_skbs mismatch(%d).\n", dev->name, i);
+			panic_queues(dev);
+		}
+#else
+		BUG_ON(lp->tx_skbs[i].skb != skb);
+#endif
+		if (skb) {
+			pci_unmap_single(lp->pci_dev, lp->tx_skbs[i].skb_dma, skb->len, PCI_DMA_TODEVICE);
+			lp->tx_skbs[i].skb = NULL;
+			lp->tx_skbs[i].skb_dma = 0;
 			dev_kfree_skb_any(skb);
-		lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0);
+		}
+		lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0xffffffff);
 	}
 
 	tc35815_init_queues(dev);
@@ -731,28 +999,53 @@ tc35815_free_queues(struct net_device *d
 
 	if (lp->tfd_base) {
 		for (i = 0; i < TX_FD_NUM; i++) {
-			struct sk_buff *skb = (struct sk_buff *)
-				le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
-			if (skb)
-				dev_kfree_skb_any(skb);
-			lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0);
+			u32 fdsystem = le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
+			struct sk_buff *skb =
+				fdsystem != 0xffffffff ?
+				lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
+			if (lp->tx_skbs[i].skb != skb) {
+				printk("%s: tx_skbs mismatch(%d).\n", dev->name, i);
+				panic_queues(dev);
+			}
+#else
+			BUG_ON(lp->tx_skbs[i].skb != skb);
+#endif
+			if (skb) {
+				dev_kfree_skb(skb);
+				pci_unmap_single(lp->pci_dev, lp->tx_skbs[i].skb_dma, skb->len, PCI_DMA_TODEVICE);
+				lp->tx_skbs[i].skb = NULL;
+				lp->tx_skbs[i].skb_dma = 0;
+			}
+			lp->tfd_base[i].fd.FDSystem = cpu_to_le32(0xffffffff);
 		}
 	}
 
 	lp->rfd_base = NULL;
-	lp->rfd_base = NULL;
 	lp->rfd_limit = NULL;
 	lp->rfd_cur = NULL;
 	lp->fbl_ptr = NULL;
 
-	for (i = 0; i < RX_BUF_PAGES; i++) {
-		if (lp->data_buf[i])
-			free_page((unsigned long)lp->data_buf[i]);
-		lp->data_buf[i] = 0;
+	for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
+		if (lp->data_buf[i]) {
+			free_rxbuf_page(lp->pci_dev,
+					lp->data_buf[i], lp->data_buf_dma[i]);
+			lp->data_buf[i] = NULL;
+		}
+#else
+		if (lp->rx_skbs[i].skb) {
+			free_rxbuf_skb(lp->pci_dev, lp->rx_skbs[i].skb,
+				       lp->rx_skbs[i].skb_dma);
+			lp->rx_skbs[i].skb = NULL;
+		}
+#endif
+	}
+	if (lp->fd_buf) {
+		pci_free_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM,
+				    lp->fd_buf, lp->fd_buf_dma);
+		lp->fd_buf = NULL;
 	}
-	if (lp->fd_buf)
-		__free_pages(lp->fd_buf, FD_PAGE_ORDER);
-	lp->fd_buf = NULL;
 }
 
 static void
@@ -792,6 +1085,7 @@ dump_rxfd(struct RxFD *fd)
 	return bd_count;
 }
 
+#if defined(DEBUG) || defined(TC35815_USE_PACKEDBUFFER)
 static void
 dump_frfd(struct FrFD *fd)
 {
@@ -802,20 +1096,22 @@ dump_frfd(struct FrFD *fd)
 	       le32_to_cpu(fd->fd.FDStat),
 	       le32_to_cpu(fd->fd.FDCtl));
 	printk("BD: ");
-	for (i = 0; i < RX_BUF_PAGES; i++)
+	for (i = 0; i < RX_BUF_NUM; i++)
 		printk(" %08x %08x",
 		       le32_to_cpu(fd->bd[i].BuffData),
 		       le32_to_cpu(fd->bd[i].BDCtl));
 	printk("\n");
 }
+#endif
 
+#ifdef DEBUG
 static void
 panic_queues(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
 	int i;
 
-	printk("TxFD base %p, start %d, end %d\n",
+	printk("TxFD base %p, start %u, end %u\n",
 	       lp->tfd_base, lp->tfd_start, lp->tfd_end);
 	printk("RxFD base %p limit %p cur %p\n",
 	       lp->rfd_base, lp->rfd_limit, lp->rfd_cur);
@@ -829,31 +1125,13 @@ panic_queues(struct net_device *dev)
 	dump_frfd(lp->fbl_ptr);
 	panic("%s: Illegal queue state.", dev->name);
 }
-
-#if 0
-static void print_buf(char *add, int length)
-{
-	int i;
-	int len = length;
-
-	printk("print_buf(%08x)(%x)\n", (unsigned int) add,length);
-
-	if (len > 100)
-		len = 100;
-	for (i = 0; i < len; i++) {
-		printk(" %2.2X", (unsigned char) add[i]);
-		if (!(i % 16))
-			printk("\n");
-	}
-	printk("\n");
-}
 #endif
 
 static void print_eth(char *add)
 {
 	int i;
 
-	printk("print_eth(%08x)\n", (unsigned int) add);
+	printk("print_eth(%p)\n", add);
 	for (i = 0; i < 6; i++)
 		printk(" %2.2X", (unsigned char) add[i + 6]);
 	printk(" =>");
@@ -862,6 +1140,73 @@ static void print_eth(char *add)
 	printk(" : %2.2X%2.2X\n", (unsigned char) add[12], (unsigned char) add[13]);
 }
 
+static int tc35815_tx_full(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	return ((lp->tfd_start + 1) % TX_FD_NUM == lp->tfd_end);
+}
+
+static void tc35815_restart(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	int do_phy_reset = 1;
+	del_timer(&lp->timer);		/* Kill if running	*/
+
+	if (lp->mii_id[0] == 0x0016 && (lp->mii_id[1] & 0xfc00) == 0xf800) {
+		/* Resetting PHY cause problem on some chip... (SEEQ 80221) */
+		do_phy_reset = 0;
+	}
+	if (do_phy_reset) {
+		int timeout;
+		tc_mdio_write(dev, pid, MII_BMCR, BMCR_RESET);
+		timeout = 100;
+		while (--timeout) {
+			if (!(tc_mdio_read(dev, pid, MII_BMCR) & BMCR_RESET))
+				break;
+			udelay(1);
+		}
+		if (!timeout)
+			printk(KERN_ERR "%s: BMCR reset failed.\n", dev->name);
+	}
+
+	tc35815_chip_reset(dev);
+	tc35815_clear_queues(dev);
+	tc35815_chip_init(dev);
+	/* Reconfigure CAM again since tc35815_chip_init() initialize it. */
+	tc35815_set_multicast_list(dev);
+}
+
+static void tc35815_tx_timeout(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+
+	printk(KERN_WARNING "%s: transmit timed out, status %#x\n",
+	       dev->name, tc_readl(&tr->Tx_Stat));
+
+	/* Try to restart the adaptor. */
+	spin_lock_irq(&lp->lock);
+	tc35815_restart(dev);
+	spin_unlock_irq(&lp->lock);
+
+	lp->stats.tx_errors++;
+
+	/* If we have space available to accept new transmit
+	 * requests, wake up the queueing layer.  This would
+	 * be the case if the chipset_init() call above just
+	 * flushes out the tx queue and empties it.
+	 *
+	 * If instead, the tx queue is retained then the
+	 * netif_wake_queue() call should be placed in the
+	 * TX completion interrupt handler of the driver instead
+	 * of here.
+	 */
+	if (!tc35815_tx_full(dev))
+		netif_wake_queue(dev);
+}
+
 /*
  * Open/initialize the board. This is called (in the current kernel)
  * sometime after booting when the 'ifconfig' program is run.
@@ -874,16 +1219,16 @@ static int
 tc35815_open(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
+
 	/*
 	 * This is used if the interrupt line can turned off (shared).
 	 * See 3c503.c for an example of selecting the IRQ at config-time.
 	 */
-
-	if (dev->irq == 0  ||
-	    request_irq(dev->irq, &tc35815_interrupt, IRQF_SHARED, cardname, dev)) {
+	if (request_irq(dev->irq, &tc35815_interrupt, IRQF_SHARED, dev->name, dev)) {
 		return -EAGAIN;
 	}
 
+	del_timer(&lp->timer);		/* Kill if running	*/
 	tc35815_chip_reset(dev);
 
 	if (tc35815_init_queues(dev) != 0) {
@@ -892,138 +1237,119 @@ tc35815_open(struct net_device *dev)
 	}
 
 	/* Reset the hardware here. Don't forget to set the station address. */
+	spin_lock_irq(&lp->lock);
 	tc35815_chip_init(dev);
+	spin_unlock_irq(&lp->lock);
 
-	lp->tbusy = 0;
+	/* We are now ready to accept transmit requeusts from
+	 * the queueing layer of the networking.
+	 */
 	netif_start_queue(dev);
 
 	return 0;
 }
 
-static void tc35815_tx_timeout(struct net_device *dev)
-{
-	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
-	unsigned long flags;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	printk(KERN_WARNING "%s: transmit timed out, status %#lx\n",
-	       dev->name, tc_readl(&tr->Tx_Stat));
-	/* Try to restart the adaptor. */
-	tc35815_chip_reset(dev);
-	tc35815_clear_queues(dev);
-	tc35815_chip_init(dev);
-	lp->tbusy=0;
-	spin_unlock_irqrestore(&lp->lock, flags);
-	dev->trans_start = jiffies;
-	netif_wake_queue(dev);
-}
-
+/* This will only be invoked if your driver is _not_ in XOFF state.
+ * What this means is that you need not check it, and that this
+ * invariant will hold if you make sure that the netif_*_queue()
+ * calls are done at the proper times.
+ */
 static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
-
-	if (netif_queue_stopped(dev)) {
-		/*
-		 * If we get here, some higher level has decided we are broken.
-		 * There should really be a "kick me" function call instead.
-		 */
-		int tickssofar = jiffies - dev->trans_start;
-		if (tickssofar < 5)
-			return 1;
-		printk(KERN_WARNING "%s: transmit timed out, status %#lx\n",
-		       dev->name, tc_readl(&tr->Tx_Stat));
-		/* Try to restart the adaptor. */
-		tc35815_chip_reset(dev);
-		tc35815_clear_queues(dev);
-		tc35815_chip_init(dev);
-		lp->tbusy=0;
-		dev->trans_start = jiffies;
-		netif_wake_queue(dev);
-	}
+	struct TxFD *txfd;
+	unsigned long flags;
 
-	/*
-	 * Block a timer-based transmit from overlapping. This could better be
-	 * done with atomic_swap(1, lp->tbusy), but set_bit() works as well.
+	/* If some error occurs while trying to transmit this
+	 * packet, you should return '1' from this function.
+	 * In such a case you _may not_ do anything to the
+	 * SKB, it is still owned by the network queueing
+	 * layer when an error is returned.  This means you
+	 * may not modify any SKB fields, you may not free
+	 * the SKB, etc.
 	 */
-	if (test_and_set_bit(0, (void*)&lp->tbusy) != 0) {
-		printk(KERN_WARNING "%s: Transmitter access conflict.\n", dev->name);
-		dev_kfree_skb_any(skb);
-	} else {
-		short length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
-		unsigned char *buf = skb->data;
-		struct TxFD *txfd = &lp->tfd_base[lp->tfd_start];
-		unsigned long flags;
-		lp->stats.tx_bytes += skb->len;
 
+	/* This is the most common case for modern hardware.
+	 * The spinlock protects this code from the TX complete
+	 * hardware interrupt handler.  Queue flow control is
+	 * thus managed under this lock as well.
+	 */
+	spin_lock_irqsave(&lp->lock, flags);
 
-#ifdef __mips__
-		dma_cache_wback_inv((unsigned long)buf, length);
+	/* failsafe... (handle txdone now if half of FDs are used) */
+	if ((lp->tfd_start + TX_FD_NUM - lp->tfd_end) % TX_FD_NUM >
+	    TX_FD_NUM / 2)
+		tc35815_txdone(dev);
+
+	if (netif_msg_pktdata(lp))
+		print_eth(skb->data);
+#ifdef DEBUG
+	if (lp->tx_skbs[lp->tfd_start].skb) {
+		printk("%s: tx_skbs conflict.\n", dev->name);
+		panic_queues(dev);
+	}
+#else
+	BUG_ON(lp->tx_skbs[lp->tfd_start].skb);
 #endif
-
-		spin_lock_irqsave(&lp->lock, flags);
-
-		/* failsafe... */
-		if (lp->tfd_start != lp->tfd_end)
-			tc35815_txdone(dev);
-
-
-		txfd->bd.BuffData = cpu_to_le32(virt_to_bus(buf));
-
-		txfd->bd.BDCtl = cpu_to_le32(length);
-		txfd->fd.FDSystem = cpu_to_le32((__u32)skb);
-		txfd->fd.FDCtl = cpu_to_le32(FD_CownsFD | (1 << FD_BDCnt_SHIFT));
-
-		if (lp->tfd_start == lp->tfd_end) {
-			/* Start DMA Transmitter. */
-			txfd->fd.FDNext |= cpu_to_le32(FD_Next_EOL);
+	lp->tx_skbs[lp->tfd_start].skb = skb;
+	lp->tx_skbs[lp->tfd_start].skb_dma = pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
+
+	/*add to ring */
+	txfd = &lp->tfd_base[lp->tfd_start];
+	txfd->bd.BuffData = cpu_to_le32(lp->tx_skbs[lp->tfd_start].skb_dma);
+	txfd->bd.BDCtl = cpu_to_le32(skb->len);
+	txfd->fd.FDSystem = cpu_to_le32(lp->tfd_start);
+	txfd->fd.FDCtl = cpu_to_le32(FD_CownsFD | (1 << FD_BDCnt_SHIFT));
+
+	if (lp->tfd_start == lp->tfd_end) {
+		struct tc35815_regs __iomem *tr =
+			(struct tc35815_regs __iomem *)dev->base_addr;
+		/* Start DMA Transmitter. */
+		txfd->fd.FDNext |= cpu_to_le32(FD_Next_EOL);
 #ifdef GATHER_TXINT
-			txfd->fd.FDCtl |= cpu_to_le32(FD_FrmOpt_IntTx);
+		txfd->fd.FDCtl |= cpu_to_le32(FD_FrmOpt_IntTx);
 #endif
-			if (tc35815_debug > 2) {
-				printk("%s: starting TxFD.\n", dev->name);
-				dump_txfd(txfd);
-				if (tc35815_debug > 3)
-					print_eth(buf);
-			}
-			tc_writel(virt_to_bus(txfd), &tr->TxFrmPtr);
-		} else {
-			txfd->fd.FDNext &= cpu_to_le32(~FD_Next_EOL);
-			if (tc35815_debug > 2) {
-				printk("%s: queueing TxFD.\n", dev->name);
-				dump_txfd(txfd);
-				if (tc35815_debug > 3)
-					print_eth(buf);
-			}
+		if (netif_msg_tx_queued(lp)) {
+			printk("%s: starting TxFD.\n", dev->name);
+			dump_txfd(txfd);
+		}
+		tc_writel(fd_virt_to_bus(lp, txfd), &tr->TxFrmPtr);
+	} else {
+		txfd->fd.FDNext &= cpu_to_le32(~FD_Next_EOL);
+		if (netif_msg_tx_queued(lp)) {
+			printk("%s: queueing TxFD.\n", dev->name);
+			dump_txfd(txfd);
 		}
-		lp->tfd_start = (lp->tfd_start + 1) % TX_FD_NUM;
+	}
+	lp->tfd_start = (lp->tfd_start + 1) % TX_FD_NUM;
 
-		dev->trans_start = jiffies;
+	dev->trans_start = jiffies;
 
-		if ((lp->tfd_start + 1) % TX_FD_NUM != lp->tfd_end) {
-			/* we can send another packet */
-			lp->tbusy = 0;
-			netif_start_queue(dev);
-		} else {
-			netif_stop_queue(dev);
-			if (tc35815_debug > 1)
-				printk(KERN_WARNING "%s: TxFD Exhausted.\n", dev->name);
-		}
-		spin_unlock_irqrestore(&lp->lock, flags);
+	/* If we just used up the very last entry in the
+	 * TX ring on this device, tell the queueing
+	 * layer to send no more.
+	 */
+	if (tc35815_tx_full(dev)) {
+		if (netif_msg_tx_queued(lp))
+			printk(KERN_WARNING "%s: TxFD Exhausted.\n", dev->name);
+		netif_stop_queue(dev);
 	}
 
+	/* When the TX completion hw interrupt arrives, this
+	 * is when the transmit statistics are updated.
+	 */
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 	return 0;
 }
 
 #define FATAL_ERROR_INT \
 	(Int_IntPCI | Int_DmParErr | Int_IntNRAbt)
-static void tc35815_fatal_error_interrupt(struct net_device *dev, int status)
+static void tc35815_fatal_error_interrupt(struct net_device *dev, u32 status)
 {
 	static int count;
 	printk(KERN_WARNING "%s: Fatal Error Intterrupt (%#x):",
 	       dev->name, status);
-
 	if (status & Int_IntPCI)
 		printk(" IntPCI");
 	if (status & Int_DmParErr)
@@ -1033,110 +1359,170 @@ static void tc35815_fatal_error_interrup
 	printk("\n");
 	if (count++ > 100)
 		panic("%s: Too many fatal errors.", dev->name);
-	printk(KERN_WARNING "%s: Resetting %s...\n", dev->name, cardname);
+	printk(KERN_WARNING "%s: Resetting ...\n", dev->name);
 	/* Try to restart the adaptor. */
-	tc35815_chip_reset(dev);
-	tc35815_clear_queues(dev);
-	tc35815_chip_init(dev);
+	tc35815_restart(dev);
+}
+
+#ifdef TC35815_NAPI
+static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
+#else
+static int tc35815_do_interrupt(struct net_device *dev, u32 status)
+#endif
+{
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int ret = -1;
+
+	/* Fatal errors... */
+	if (status & FATAL_ERROR_INT) {
+		tc35815_fatal_error_interrupt(dev, status);
+		return 0;
+	}
+	/* recoverable errors */
+	if (status & Int_IntFDAEx) {
+		/* disable FDAEx int. (until we make rooms...) */
+		tc_writel(tc_readl(&tr->Int_En) & ~Int_FDAExEn, &tr->Int_En);
+		printk(KERN_WARNING
+		       "%s: Free Descriptor Area Exhausted (%#x).\n",
+		       dev->name, status);
+		lp->stats.rx_dropped++;
+		ret = 0;
+	}
+	if (status & Int_IntBLEx) {
+		/* disable BLEx int. (until we make rooms...) */
+		tc_writel(tc_readl(&tr->Int_En) & ~Int_BLExEn, &tr->Int_En);
+		printk(KERN_WARNING
+		       "%s: Buffer List Exhausted (%#x).\n",
+		       dev->name, status);
+		lp->stats.rx_dropped++;
+		ret = 0;
+	}
+	if (status & Int_IntExBD) {
+		printk(KERN_WARNING
+		       "%s: Excessive Buffer Descriptiors (%#x).\n",
+		       dev->name, status);
+		lp->stats.rx_length_errors++;
+		ret = 0;
+	}
+
+	/* normal notification */
+	if (status & Int_IntMacRx) {
+		/* Got a packet(s). */
+#ifdef TC35815_NAPI
+		ret = tc35815_rx(dev, limit);
+#else
+		tc35815_rx(dev);
+		ret = 0;
+#endif
+		lp->lstats.rx_ints++;
+	}
+	if (status & Int_IntMacTx) {
+		/* Transmit complete. */
+		lp->lstats.tx_ints++;
+		tc35815_txdone(dev);
+		netif_wake_queue(dev);
+		ret = 0;
+	}
+	return ret;
 }
 
 /*
  * The typical workload of the driver:
- *   Handle the network interface interrupts.
+ * Handle the network interface interrupts.
  */
 static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct tc35815_regs *tr;
-	struct tc35815_local *lp;
-	int status, boguscount = 0;
-	int handled = 0;
-
-	if (dev == NULL) {
-		printk(KERN_WARNING "%s: irq %d for unknown device.\n", cardname, irq);
-		return IRQ_NONE;
-	}
-
-	tr = (struct tc35815_regs*)dev->base_addr;
-	lp = dev->priv;
-
-	do {
-		status = tc_readl(&tr->Int_Src);
-		if (status == 0)
-			break;
-		handled = 1;
-		tc_writel(status, &tr->Int_Src);	/* write to clear */
-
-		/* Fatal errors... */
-		if (status & FATAL_ERROR_INT) {
-			tc35815_fatal_error_interrupt(dev, status);
-			break;
-		}
-		/* recoverable errors */
-		if (status & Int_IntFDAEx) {
-			/* disable FDAEx int. (until we make rooms...) */
-			tc_writel(tc_readl(&tr->Int_En) & ~Int_FDAExEn, &tr->Int_En);
-			printk(KERN_WARNING
-			       "%s: Free Descriptor Area Exhausted (%#x).\n",
-			       dev->name, status);
-			lp->stats.rx_dropped++;
-		}
-		if (status & Int_IntBLEx) {
-			/* disable BLEx int. (until we make rooms...) */
-			tc_writel(tc_readl(&tr->Int_En) & ~Int_BLExEn, &tr->Int_En);
-			printk(KERN_WARNING
-			       "%s: Buffer List Exhausted (%#x).\n",
-			       dev->name, status);
-			lp->stats.rx_dropped++;
-		}
-		if (status & Int_IntExBD) {
-			printk(KERN_WARNING
-			       "%s: Excessive Buffer Descriptiors (%#x).\n",
-			       dev->name, status);
-			lp->stats.rx_length_errors++;
-		}
-		/* normal notification */
-		if (status & Int_IntMacRx) {
-			/* Got a packet(s). */
-			lp->lstats.rx_ints++;
-			tc35815_rx(dev);
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+#ifdef TC35815_NAPI
+	u32 dmactl = tc_readl(&tr->DMA_Ctl);
+
+	if (!(dmactl & DMA_IntMask)) {
+		/* disable interrupts */
+		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
+		if (netif_rx_schedule_prep(dev))
+			__netif_rx_schedule(dev);
+		else {
+			printk(KERN_ERR "%s: interrupt taken in poll\n",
+			       dev->name);
+			BUG();
 		}
-		if (status & Int_IntMacTx) {
-			lp->lstats.tx_ints++;
-			tc35815_txdone(dev);
-		}
-	} while (++boguscount < 20) ;
+		(void)tc_readl(&tr->Int_Src);	/* flush */
+		return IRQ_HANDLED;
+	}
+	return IRQ_NONE;
+#else
+	struct tc35815_local *lp = dev->priv;
+	int handled;
+	u32 status;
+
+	spin_lock(&lp->lock);
+	status = tc_readl(&tr->Int_Src);
+	tc_writel(status, &tr->Int_Src);	/* write to clear */
+	handled = tc35815_do_interrupt(dev, status);
+	(void)tc_readl(&tr->Int_Src);	/* flush */
+	spin_unlock(&lp->lock);
+	return IRQ_RETVAL(handled >= 0);
+#endif /* TC35815_NAPI */
+}
 
-	return IRQ_RETVAL(handled);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void tc35815_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	tc35815_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
 }
+#endif
 
 /* We have a good packet(s), get it/them out of the buffers. */
+#ifdef TC35815_NAPI
+static int
+tc35815_rx(struct net_device *dev, int limit)
+#else
 static void
 tc35815_rx(struct net_device *dev)
+#endif
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
 	unsigned int fdctl;
 	int i;
 	int buf_free_count = 0;
 	int fd_free_count = 0;
+#ifdef TC35815_NAPI
+	int received = 0;
+#endif
 
 	while (!((fdctl = le32_to_cpu(lp->rfd_cur->fd.FDCtl)) & FD_CownsFD)) {
 		int status = le32_to_cpu(lp->rfd_cur->fd.FDStat);
 		int pkt_len = fdctl & FD_FDLength_MASK;
-		struct RxFD *next_rfd;
 		int bd_count = (fdctl & FD_BDCnt_MASK) >> FD_BDCnt_SHIFT;
+#ifdef DEBUG
+		struct RxFD *next_rfd;
+#endif
+#if (RX_CTL_CMD & Rx_StripCRC) == 0
+		pkt_len -= 4;
+#endif
 
-		if (tc35815_debug > 2)
+		if (netif_msg_rx_status(lp))
 			dump_rxfd(lp->rfd_cur);
 		if (status & Rx_Good) {
-			/* Malloc up new buffer. */
 			struct sk_buff *skb;
 			unsigned char *data;
-			int cur_bd, offset;
-
-			lp->stats.rx_bytes += pkt_len;
+			int cur_bd;
+#ifdef TC35815_USE_PACKEDBUFFER
+			int offset;
+#endif
 
+#ifdef TC35815_NAPI
+			if (--limit < 0)
+				break;
+#endif
+#ifdef TC35815_USE_PACKEDBUFFER
+			BUG_ON(bd_count > 2);
 			skb = dev_alloc_skb(pkt_len + 2); /* +2: for reserve */
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
@@ -1155,25 +1541,64 @@ tc35815_rx(struct net_device *dev)
 			while (offset < pkt_len && cur_bd < bd_count) {
 				int len = le32_to_cpu(lp->rfd_cur->bd[cur_bd].BDCtl) &
 					BD_BuffLength_MASK;
-				void *rxbuf =
-					bus_to_virt(le32_to_cpu(lp->rfd_cur->bd[cur_bd].BuffData));
-#ifdef __mips__
-				dma_cache_inv((unsigned long)rxbuf, len);
+				dma_addr_t dma = le32_to_cpu(lp->rfd_cur->bd[cur_bd].BuffData);
+				void *rxbuf = rxbuf_bus_to_virt(lp, dma);
+				if (offset + len > pkt_len)
+					len = pkt_len - offset;
+#ifdef TC35815_DMA_SYNC_ONDEMAND
+				pci_dma_sync_single_for_cpu(lp->pci_dev,
+							    dma, len,
+							    PCI_DMA_FROMDEVICE);
 #endif
 				memcpy(data + offset, rxbuf, len);
 				offset += len;
 				cur_bd++;
 			}
-#if 0
-			print_buf(data,pkt_len);
+#else /* TC35815_USE_PACKEDBUFFER */
+			BUG_ON(bd_count > 1);
+			cur_bd = (le32_to_cpu(lp->rfd_cur->bd[0].BDCtl)
+				  & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
+#ifdef DEBUG
+			if (cur_bd >= RX_BUF_NUM) {
+				printk("%s: invalid BDID.\n", dev->name);
+				panic_queues(dev);
+			}
+			BUG_ON(lp->rx_skbs[cur_bd].skb_dma !=
+			       (le32_to_cpu(lp->rfd_cur->bd[0].BuffData) & ~3));
+			if (!lp->rx_skbs[cur_bd].skb) {
+				printk("%s: NULL skb.\n", dev->name);
+				panic_queues(dev);
+			}
+#else
+			BUG_ON(cur_bd >= RX_BUF_NUM);
 #endif
-			if (tc35815_debug > 3)
+			skb = lp->rx_skbs[cur_bd].skb;
+			prefetch(skb->data);
+			lp->rx_skbs[cur_bd].skb = NULL;
+			lp->fbl_count--;
+			pci_unmap_single(lp->pci_dev,
+					 lp->rx_skbs[cur_bd].skb_dma,
+					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (!HAVE_DMA_RXALIGN(lp))
+				memmove(skb->data, skb->data - 2, pkt_len);
+			data = skb_put(skb, pkt_len);
+#endif /* TC35815_USE_PACKEDBUFFER */
+			if (netif_msg_pktdata(lp))
 				print_eth(data);
 			skb->protocol = eth_type_trans(skb, dev);
+#ifdef TC35815_NAPI
+			netif_receive_skb(skb);
+			received++;
+#else
 			netif_rx(skb);
+#endif
+			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
+			lp->stats.rx_bytes += pkt_len;
 		} else {
 			lp->stats.rx_errors++;
+			printk(KERN_DEBUG "%s: Rx error (status %x)\n",
+			       dev->name, status & Rx_Stat_Mask);
 			/* WORKAROUND: LongErr and CRCErr means Overflow. */
 			if ((status & Rx_LongErr) && (status & Rx_CRCErr)) {
 				status &= ~(Rx_LongErr|Rx_CRCErr);
@@ -1190,63 +1615,150 @@ tc35815_rx(struct net_device *dev)
 			int bdctl = le32_to_cpu(lp->rfd_cur->bd[bd_count - 1].BDCtl);
 			unsigned char id =
 				(bdctl & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
-			if (id >= RX_BUF_PAGES) {
+#ifdef DEBUG
+			if (id >= RX_BUF_NUM) {
 				printk("%s: invalid BDID.\n", dev->name);
 				panic_queues(dev);
 			}
+#else
+			BUG_ON(id >= RX_BUF_NUM);
+#endif
 			/* free old buffers */
-			while (lp->fbl_curid != id) {
-				bdctl = le32_to_cpu(lp->fbl_ptr->bd[lp->fbl_curid].BDCtl);
+#ifdef TC35815_USE_PACKEDBUFFER
+			while (lp->fbl_curid != id)
+#else
+			while (lp->fbl_count < RX_BUF_NUM)
+#endif
+			{
+#ifdef TC35815_USE_PACKEDBUFFER
+				unsigned char curid = lp->fbl_curid;
+#else
+				unsigned char curid =
+					(id + 1 + lp->fbl_count) % RX_BUF_NUM;
+#endif
+				struct BDesc *bd = &lp->fbl_ptr->bd[curid];
+#ifdef DEBUG
+				bdctl = le32_to_cpu(bd->BDCtl);
 				if (bdctl & BD_CownsBD) {
 					printk("%s: Freeing invalid BD.\n",
 					       dev->name);
 					panic_queues(dev);
 				}
+#endif
 				/* pass BD to controler */
+#ifndef TC35815_USE_PACKEDBUFFER
+				if (!lp->rx_skbs[curid].skb) {
+					lp->rx_skbs[curid].skb =
+						alloc_rxbuf_skb(dev,
+								lp->pci_dev,
+								&lp->rx_skbs[curid].skb_dma);
+					if (!lp->rx_skbs[curid].skb)
+						break; /* try on next reception */
+					bd->BuffData = cpu_to_le32(lp->rx_skbs[curid].skb_dma);
+				}
+#endif /* TC35815_USE_PACKEDBUFFER */
 				/* Note: BDLength was modified by chip. */
-				lp->fbl_ptr->bd[lp->fbl_curid].BDCtl =
-					cpu_to_le32(BD_CownsBD |
-						    (lp->fbl_curid << BD_RxBDID_SHIFT) |
-						    PAGE_SIZE);
-				lp->fbl_curid =
-					(lp->fbl_curid + 1) % RX_BUF_PAGES;
-				if (tc35815_debug > 2) {
+				bd->BDCtl = cpu_to_le32(BD_CownsBD |
+							(curid << BD_RxBDID_SHIFT) |
+							RX_BUF_SIZE);
+#ifdef TC35815_USE_PACKEDBUFFER
+				lp->fbl_curid = (curid + 1) % RX_BUF_NUM;
+				if (netif_msg_rx_status(lp)) {
 					printk("%s: Entering new FBD %d\n",
 					       dev->name, lp->fbl_curid);
 					dump_frfd(lp->fbl_ptr);
 				}
+#else
+				lp->fbl_count++;
+#endif
 				buf_free_count++;
 			}
 		}
 
 		/* put RxFD back to controller */
-		next_rfd = bus_to_virt(le32_to_cpu(lp->rfd_cur->fd.FDNext));
-#ifdef __mips__
-		next_rfd = (struct RxFD *)vtonocache(next_rfd);
-#endif
+#ifdef DEBUG
+		next_rfd = fd_bus_to_virt(lp,
+					  le32_to_cpu(lp->rfd_cur->fd.FDNext));
 		if (next_rfd < lp->rfd_base || next_rfd > lp->rfd_limit) {
 			printk("%s: RxFD FDNext invalid.\n", dev->name);
 			panic_queues(dev);
 		}
+#endif
 		for (i = 0; i < (bd_count + 1) / 2 + 1; i++) {
 			/* pass FD to controler */
-			lp->rfd_cur->fd.FDNext = cpu_to_le32(0xdeaddead);	/* for debug */
+#ifdef DEBUG
+			lp->rfd_cur->fd.FDNext = cpu_to_le32(0xdeaddead);
+#else
+			lp->rfd_cur->fd.FDNext = cpu_to_le32(FD_Next_EOL);
+#endif
 			lp->rfd_cur->fd.FDCtl = cpu_to_le32(FD_CownsFD);
 			lp->rfd_cur++;
 			fd_free_count++;
 		}
-
-		lp->rfd_cur = next_rfd;
+		if (lp->rfd_cur > lp->rfd_limit)
+			lp->rfd_cur = lp->rfd_base;
+#ifdef DEBUG
+		if (lp->rfd_cur != next_rfd)
+			printk("rfd_cur = %p, next_rfd %p\n",
+			       lp->rfd_cur, next_rfd);
+#endif
 	}
 
 	/* re-enable BL/FDA Exhaust interrupts. */
 	if (fd_free_count) {
-		tc_writel(tc_readl(&tr->Int_En) | Int_FDAExEn, &tr->Int_En);
+		struct tc35815_regs __iomem *tr =
+			(struct tc35815_regs __iomem *)dev->base_addr;
+		u32 en, en_old = tc_readl(&tr->Int_En);
+		en = en_old | Int_FDAExEn;
 		if (buf_free_count)
-			tc_writel(tc_readl(&tr->Int_En) | Int_BLExEn, &tr->Int_En);
+			en |= Int_BLExEn;
+		if (en != en_old)
+			tc_writel(en, &tr->Int_En);
 	}
+#ifdef TC35815_NAPI
+	return received;
+#endif
 }
 
+#ifdef TC35815_NAPI
+static int
+tc35815_poll(struct net_device *dev, int *budget)
+{
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int limit = min(*budget, dev->quota);
+	int received = 0, handled;
+	u32 status;
+
+	spin_lock(&lp->lock);
+	status = tc_readl(&tr->Int_Src);
+	do {
+		tc_writel(status, &tr->Int_Src);	/* write to clear */
+
+		handled = tc35815_do_interrupt(dev, status, limit);
+		if (handled >= 0) {
+			received += handled;
+			limit -= handled;
+			if (limit <= 0)
+				break;
+		}
+		status = tc_readl(&tr->Int_Src);
+	} while (status);
+	spin_unlock(&lp->lock);
+
+	dev->quota -= received;
+	*budget -= received;
+	if (limit <= 0)
+		return 1;
+
+	netif_rx_complete(dev);
+	/* enable interrupts */
+	tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
+	return 0;
+}
+#endif
+
 #ifdef NO_CHECK_CARRIER
 #define TX_STA_ERR	(Tx_ExColl|Tx_Under|Tx_Defer|Tx_LateColl|Tx_TxPar|Tx_SQErr)
 #else
@@ -1265,9 +1777,17 @@ tc35815_check_tx_stat(struct net_device
 	if (status & Tx_TxColl_MASK)
 		lp->stats.collisions += status & Tx_TxColl_MASK;
 
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have NCarr */
+	if (lp->boardtype == TC35815_TX4939)
+		status &= ~Tx_NCarr;
+#ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
-	if (lp->fullduplex)
+	if ((lp->timer_state != asleep && lp->timer_state != lcheck)
+	    || lp->fullduplex)
 		status &= ~Tx_NCarr;
+#endif
+#endif
 
 	if (!(status & TX_STA_ERR)) {
 		/* no error. */
@@ -1283,6 +1803,15 @@ tc35815_check_tx_stat(struct net_device
 	if (status & Tx_Under) {
 		lp->stats.tx_fifo_errors++;
 		msg = "Tx FIFO Underrun.";
+		if (lp->lstats.tx_underrun < TX_THRESHOLD_KEEP_LIMIT) {
+			lp->lstats.tx_underrun++;
+			if (lp->lstats.tx_underrun >= TX_THRESHOLD_KEEP_LIMIT) {
+				struct tc35815_regs __iomem *tr =
+					(struct tc35815_regs __iomem *)dev->base_addr;
+				tc_writel(TX_THRESHOLD_MAX, &tr->TxThrsh);
+				msg = "Tx FIFO Underrun.Change Tx threshold to max.";
+			}
+		}
 	}
 	if (status & Tx_Defer) {
 		lp->stats.tx_fifo_errors++;
@@ -1306,18 +1835,19 @@ tc35815_check_tx_stat(struct net_device
 		lp->stats.tx_heartbeat_errors++;
 		msg = "Signal Quality Error.";
 	}
-	if (msg)
+	if (msg && netif_msg_tx_err(lp))
 		printk(KERN_WARNING "%s: %s (%#x)\n", dev->name, msg, status);
 }
 
+/* This handles TX complete events posted by the device
+ * via interrupts.
+ */
 static void
 tc35815_txdone(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
 	struct TxFD *txfd;
 	unsigned int fdctl;
-	int num_done = 0;
 
 	txfd = &lp->tfd_base[lp->tfd_end];
 	while (lp->tfd_start != lp->tfd_end &&
@@ -1325,38 +1855,61 @@ tc35815_txdone(struct net_device *dev)
 		int status = le32_to_cpu(txfd->fd.FDStat);
 		struct sk_buff *skb;
 		unsigned long fdnext = le32_to_cpu(txfd->fd.FDNext);
+		u32 fdsystem = le32_to_cpu(txfd->fd.FDSystem);
 
-		if (tc35815_debug > 2) {
+		if (netif_msg_tx_done(lp)) {
 			printk("%s: complete TxFD.\n", dev->name);
 			dump_txfd(txfd);
 		}
 		tc35815_check_tx_stat(dev, status);
 
-		skb = (struct sk_buff *)le32_to_cpu(txfd->fd.FDSystem);
+		skb = fdsystem != 0xffffffff ?
+			lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
+		if (lp->tx_skbs[lp->tfd_end].skb != skb) {
+			printk("%s: tx_skbs mismatch.\n", dev->name);
+			panic_queues(dev);
+		}
+#else
+		BUG_ON(lp->tx_skbs[lp->tfd_end].skb != skb);
+#endif
 		if (skb) {
+			lp->stats.tx_bytes += skb->len;
+			pci_unmap_single(lp->pci_dev, lp->tx_skbs[lp->tfd_end].skb_dma, skb->len, PCI_DMA_TODEVICE);
+			lp->tx_skbs[lp->tfd_end].skb = NULL;
+			lp->tx_skbs[lp->tfd_end].skb_dma = 0;
+#ifdef TC35815_NAPI
 			dev_kfree_skb_any(skb);
+#else
+			dev_kfree_skb_irq(skb);
+#endif
 		}
-		txfd->fd.FDSystem = cpu_to_le32(0);
+		txfd->fd.FDSystem = cpu_to_le32(0xffffffff);
 
-		num_done++;
 		lp->tfd_end = (lp->tfd_end + 1) % TX_FD_NUM;
 		txfd = &lp->tfd_base[lp->tfd_end];
-		if ((fdnext & ~FD_Next_EOL) != virt_to_bus(txfd)) {
+#ifdef DEBUG
+		if ((fdnext & ~FD_Next_EOL) != fd_virt_to_bus(lp, txfd)) {
 			printk("%s: TxFD FDNext invalid.\n", dev->name);
 			panic_queues(dev);
 		}
+#endif
 		if (fdnext & FD_Next_EOL) {
 			/* DMA Transmitter has been stopping... */
 			if (lp->tfd_end != lp->tfd_start) {
+				struct tc35815_regs __iomem *tr =
+					(struct tc35815_regs __iomem *)dev->base_addr;
 				int head = (lp->tfd_start + TX_FD_NUM - 1) % TX_FD_NUM;
 				struct TxFD* txhead = &lp->tfd_base[head];
 				int qlen = (lp->tfd_start + TX_FD_NUM
 					    - lp->tfd_end) % TX_FD_NUM;
 
+#ifdef DEBUG
 				if (!(le32_to_cpu(txfd->fd.FDCtl) & FD_CownsFD)) {
 					printk("%s: TxFD FDCtl invalid.\n", dev->name);
 					panic_queues(dev);
 				}
+#endif
 				/* log max queue length */
 				if (lp->lstats.max_tx_qlen < qlen)
 					lp->lstats.max_tx_qlen = qlen;
@@ -1367,21 +1920,23 @@ tc35815_txdone(struct net_device *dev)
 #ifdef GATHER_TXINT
 				txhead->fd.FDCtl |= cpu_to_le32(FD_FrmOpt_IntTx);
 #endif
-				if (tc35815_debug > 2) {
+				if (netif_msg_tx_queued(lp)) {
 					printk("%s: start TxFD on queue.\n",
 					       dev->name);
 					dump_txfd(txfd);
 				}
-				tc_writel(virt_to_bus(txfd), &tr->TxFrmPtr);
+				tc_writel(fd_virt_to_bus(lp, txfd), &tr->TxFrmPtr);
 			}
 			break;
 		}
 	}
 
-	if (num_done > 0 && lp->tbusy) {
-		lp->tbusy = 0;
-		netif_start_queue(dev);
-	}
+	/* If we had stopped the queue due to a "tx full"
+	 * condition, and space has now been made available,
+	 * wake up the queue.
+	 */
+	if (netif_queue_stopped(dev) && ! tc35815_tx_full(dev))
+		netif_wake_queue(dev);
 }
 
 /* The inverse routine to tc35815_open(). */
@@ -1389,18 +1944,18 @@ static int
 tc35815_close(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-
-	lp->tbusy = 1;
 	netif_stop_queue(dev);
 
 	/* Flush the Tx and disable Rx here. */
 
+	del_timer(&lp->timer);		/* Kill if running	*/
 	tc35815_chip_reset(dev);
 	free_irq(dev->irq, dev);
 
 	tc35815_free_queues(dev);
 
 	return 0;
+
 }
 
 /*
@@ -1410,29 +1965,29 @@ tc35815_close(struct net_device *dev)
 static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
-	unsigned long flags;
-
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	if (netif_running(dev)) {
-		spin_lock_irqsave(&lp->lock, flags);
 		/* Update the statistics from the device registers. */
 		lp->stats.rx_missed_errors = tc_readl(&tr->Miss_Cnt);
-		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 
 	return &lp->stats;
 }
 
-static void tc35815_set_cam_entry(struct tc35815_regs *tr, int index, unsigned char *addr)
+static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned char *addr)
 {
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	int cam_index = index * 6;
-	unsigned long cam_data;
-	unsigned long saved_addr;
+	u32 cam_data;
+	u32 saved_addr;
 	saved_addr = tc_readl(&tr->CAM_Adr);
 
-	if (tc35815_debug > 1) {
+	if (netif_msg_hw(lp)) {
 		int i;
-		printk(KERN_DEBUG "%s: CAM %d:", cardname, index);
+		printk(KERN_DEBUG "%s: CAM %d:", dev->name, index);
 		for (i = 0; i < 6; i++)
 			printk(" %02x", addr[i]);
 		printk("\n");
@@ -1459,14 +2014,6 @@ static void tc35815_set_cam_entry(struct
 		tc_writel(cam_data, &tr->CAM_Data);
 	}
 
-	if (tc35815_debug > 2) {
-		int i;
-		for (i = cam_index / 4; i < cam_index / 4 + 2; i++) {
-			tc_writel(i * 4, &tr->CAM_Adr);
-			printk("CAM 0x%x: %08lx",
-			       i * 4, tc_readl(&tr->CAM_Data));
-		}
-	}
 	tc_writel(saved_addr, &tr->CAM_Adr);
 }
 
@@ -1481,10 +2028,19 @@ static void tc35815_set_cam_entry(struct
 static void
 tc35815_set_multicast_list(struct net_device *dev)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 
 	if (dev->flags&IFF_PROMISC)
 	{
+#ifdef WORKAROUND_100HALF_PROMISC
+		/* With some (all?) 100MHalf HUB, controller will hang
+		 * if we enabled promiscuous mode before linkup... */
+		struct tc35815_local *lp = dev->priv;
+		int pid = lp->phy_addr;
+		if (!(tc_mdio_read(dev, pid, MII_BMSR) & BMSR_LSTATUS))
+			return;
+#endif
 		/* Enable promiscuous mode */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc | CAM_StationAcc, &tr->CAM_Ctl);
 	}
@@ -1506,7 +2062,7 @@ tc35815_set_multicast_list(struct net_de
 			if (!cur_addr)
 				break;
 			/* entry 0,1 is reserved. */
-			tc35815_set_cam_entry(tr, i + 2, cur_addr->dmi_addr);
+			tc35815_set_cam_entry(dev, i + 2, cur_addr->dmi_addr);
 			ena_bits |= CAM_Ena_Bit(i + 2);
 		}
 		tc_writel(ena_bits, &tr->CAM_Ena);
@@ -1518,122 +2074,753 @@ tc35815_set_multicast_list(struct net_de
 	}
 }
 
-static unsigned long tc_phy_read(struct net_device *dev, struct tc35815_regs *tr, int phy, int phy_reg)
+static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct tc35815_local *lp = dev->priv;
-	unsigned long data;
-	unsigned long flags;
+	strcpy(info->driver, MODNAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, pci_name(lp->pci_dev));
+}
 
-	spin_lock_irqsave(&lp->lock, flags);
+static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tc35815_local *lp = dev->priv;
+	spin_lock_irq(&lp->lock);
+	mii_ethtool_gset(&lp->mii, cmd);
+	spin_unlock_irq(&lp->lock);
+	return 0;
+}
 
-	tc_writel(MD_CA_Busy | (phy << 5) | phy_reg, &tr->MD_CA);
+static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tc35815_local *lp = dev->priv;
+	int rc;
+#if 1	/* use our negotiation method... */
+	/* Verify the settings we care about. */
+	if (cmd->autoneg != AUTONEG_ENABLE &&
+	    cmd->autoneg != AUTONEG_DISABLE)
+		return -EINVAL;
+	if (cmd->autoneg == AUTONEG_DISABLE &&
+	    ((cmd->speed != SPEED_100 &&
+	      cmd->speed != SPEED_10) ||
+	     (cmd->duplex != DUPLEX_HALF &&
+	      cmd->duplex != DUPLEX_FULL)))
+		return -EINVAL;
+
+	/* Ok, do it to it. */
+	spin_lock_irq(&lp->lock);
+	del_timer(&lp->timer);
+	tc35815_start_auto_negotiation(dev, cmd);
+	spin_unlock_irq(&lp->lock);
+	rc = 0;
+#else
+	spin_lock_irq(&lp->lock);
+	rc = mii_ethtool_sset(&lp->mii, cmd);
+	spin_unlock_irq(&lp->lock);
+#endif
+	return rc;
+}
+
+static int tc35815_nway_reset(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	int rc;
+	spin_lock_irq(&lp->lock);
+	rc = mii_nway_restart(&lp->mii);
+	spin_unlock_irq(&lp->lock);
+	return rc;
+}
+
+static u32 tc35815_get_link(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	int rc;
+	spin_lock_irq(&lp->lock);
+	rc = mii_link_ok(&lp->mii);
+	spin_unlock_irq(&lp->lock);
+	return rc;
+}
+
+static u32 tc35815_get_msglevel(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	return lp->msg_enable;
+}
+
+static void tc35815_set_msglevel(struct net_device *dev, u32 datum)
+{
+	struct tc35815_local *lp = dev->priv;
+	lp->msg_enable = datum;
+}
+
+static int tc35815_get_stats_count(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	return sizeof(lp->lstats) / sizeof(int);
+}
+
+static void tc35815_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
+{
+	struct tc35815_local *lp = dev->priv;
+	data[0] = lp->lstats.max_tx_qlen;
+	data[1] = lp->lstats.tx_ints;
+	data[2] = lp->lstats.rx_ints;
+	data[3] = lp->lstats.tx_underrun;
+}
+
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "max_tx_qlen" },
+	{ "tx_ints" },
+	{ "rx_ints" },
+	{ "tx_underrun" },
+};
+
+static void tc35815_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	memcpy(data, ethtool_stats_keys, sizeof(ethtool_stats_keys));
+}
+
+static const struct ethtool_ops tc35815_ethtool_ops = {
+	.get_drvinfo		= tc35815_get_drvinfo,
+	.get_settings		= tc35815_get_settings,
+	.set_settings		= tc35815_set_settings,
+	.nway_reset		= tc35815_nway_reset,
+	.get_link		= tc35815_get_link,
+	.get_msglevel		= tc35815_get_msglevel,
+	.set_msglevel		= tc35815_set_msglevel,
+	.get_strings		= tc35815_get_strings,
+	.get_stats_count	= tc35815_get_stats_count,
+	.get_ethtool_stats	= tc35815_get_ethtool_stats,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
+};
+
+static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct tc35815_local *lp = dev->priv;
+	int rc;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	spin_lock_irq(&lp->lock);
+	rc = generic_mii_ioctl(&lp->mii, if_mii(rq), cmd, NULL);
+	spin_unlock_irq(&lp->lock);
+
+	return rc;
+}
+
+static int tc_mdio_read(struct net_device *dev, int phy_id, int location)
+{
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	u32 data;
+	tc_writel(MD_CA_Busy | (phy_id << 5) | location, &tr->MD_CA);
 	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
 		;
 	data = tc_readl(&tr->MD_Data);
-	spin_unlock_irqrestore(&lp->lock, flags);
-	return data;
+	return data & 0xffff;
+}
+
+static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
+			  int val)
+{
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	tc_writel(val, &tr->MD_Data);
+	tc_writel(MD_CA_Busy | MD_CA_Wr | (phy_id << 5) | location, &tr->MD_CA);
+	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
+		;
 }
 
-static void tc_phy_write(struct net_device *dev, unsigned long d, struct tc35815_regs *tr, int phy, int phy_reg)
+/* Auto negotiation.  The scheme is very simple.  We have a timer routine
+ * that keeps watching the auto negotiation process as it progresses.
+ * The DP83840 is first told to start doing it's thing, we set up the time
+ * and place the timer state machine in it's initial state.
+ *
+ * Here the timer peeks at the DP83840 status registers at each click to see
+ * if the auto negotiation has completed, we assume here that the DP83840 PHY
+ * will time out at some point and just tell us what (didn't) happen.  For
+ * complete coverage we only allow so many of the ticks at this level to run,
+ * when this has expired we print a warning message and try another strategy.
+ * This "other" strategy is to force the interface into various speed/duplex
+ * configurations and we stop when we see a link-up condition before the
+ * maximum number of "peek" ticks have occurred.
+ *
+ * Once a valid link status has been detected we configure the BigMAC and
+ * the rest of the Happy Meal to speak the most efficient protocol we could
+ * get a clean link for.  The priority for link configurations, highest first
+ * is:
+ *                 100 Base-T Full Duplex
+ *                 100 Base-T Half Duplex
+ *                 10 Base-T Full Duplex
+ *                 10 Base-T Half Duplex
+ *
+ * We start a new timer now, after a successful auto negotiation status has
+ * been detected.  This timer just waits for the link-up bit to get set in
+ * the BMCR of the DP83840.  When this occurs we print a kernel log message
+ * describing the link type in use and the fact that it is up.
+ *
+ * If a fatal error of some sort is signalled and detected in the interrupt
+ * service routine, and the chip is reset, or the link is ifconfig'd down
+ * and then back up, this entire process repeats itself all over again.
+ */
+/* Note: Above comments are come from sunhme driver. */
+
+static int tc35815_try_next_permutation(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	unsigned long flags;
+	int pid = lp->phy_addr;
+	unsigned short bmcr;
 
-	spin_lock_irqsave(&lp->lock, flags);
+	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
 
-	tc_writel(d, &tr->MD_Data);
-	tc_writel(MD_CA_Busy | MD_CA_Wr | (phy << 5) | phy_reg, &tr->MD_CA);
-	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
-		;
-	spin_unlock_irqrestore(&lp->lock, flags);
+	/* Downgrade from full to half duplex.  Only possible via ethtool.  */
+	if (bmcr & BMCR_FULLDPLX) {
+		bmcr &= ~BMCR_FULLDPLX;
+		printk(KERN_DEBUG "%s: try next permutation (BMCR %x)\n", dev->name, bmcr);
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+		return 0;
+	}
+
+	/* Downgrade from 100 to 10. */
+	if (bmcr & BMCR_SPEED100) {
+		bmcr &= ~BMCR_SPEED100;
+		printk(KERN_DEBUG "%s: try next permutation (BMCR %x)\n", dev->name, bmcr);
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+		return 0;
+	}
+
+	/* We've tried everything. */
+	return -1;
 }
 
-static void tc35815_phy_chip_init(struct net_device *dev)
+static void
+tc35815_display_link_mode(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
-	static int first = 1;
-	unsigned short ctl;
-
-	if (first) {
-		unsigned short id0, id1;
-		int count;
-		first = 0;
-
-		/* first data written to the PHY will be an ID number */
-		tc_phy_write(dev, 0, tr, 0, MII_CONTROL);	/* ID:0 */
-#if 0
-		tc_phy_write(dev, MIICNTL_RESET, tr, 0, MII_CONTROL);
-		printk(KERN_INFO "%s: Resetting PHY...", dev->name);
-		while (tc_phy_read(dev, tr, 0, MII_CONTROL) & MIICNTL_RESET)
-			;
-		printk("\n");
-		tc_phy_write(dev, MIICNTL_AUTO|MIICNTL_SPEED|MIICNTL_FDX, tr, 0,
-			     MII_CONTROL);
-#endif
-		id0 = tc_phy_read(dev, tr, 0, MII_PHY_ID0);
-		id1 = tc_phy_read(dev, tr, 0, MII_PHY_ID1);
-		printk(KERN_DEBUG "%s: PHY ID %04x %04x\n", dev->name,
-		       id0, id1);
-		if (lp->option & TC35815_OPT_10M) {
-			lp->linkspeed = 10;
-			lp->fullduplex = (lp->option & TC35815_OPT_FULLDUP) != 0;
-		} else if (lp->option & TC35815_OPT_100M) {
-			lp->linkspeed = 100;
-			lp->fullduplex = (lp->option & TC35815_OPT_FULLDUP) != 0;
+	int pid = lp->phy_addr;
+	unsigned short lpa, bmcr;
+	char *speed = "", *duplex = "";
+
+	lpa = tc_mdio_read(dev, pid, MII_LPA);
+	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+	if (options.speed ? (bmcr & BMCR_SPEED100) : (lpa & (LPA_100HALF | LPA_100FULL)))
+		speed = "100Mb/s";
+	else
+		speed = "10Mb/s";
+	if (options.duplex ? (bmcr & BMCR_FULLDPLX) : (lpa & (LPA_100FULL | LPA_10FULL)))
+		duplex = "Full Duplex";
+	else
+		duplex = "Half Duplex";
+
+	if (netif_msg_link(lp))
+		printk(KERN_INFO "%s: Link is up at %s, %s.\n",
+		       dev->name, speed, duplex);
+	printk(KERN_DEBUG "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
+	       dev->name,
+	       bmcr, tc_mdio_read(dev, pid, MII_BMSR), lpa);
+}
+
+static void tc35815_display_forced_link_mode(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	unsigned short bmcr;
+	char *speed = "", *duplex = "";
+
+	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+	if (bmcr & BMCR_SPEED100)
+		speed = "100Mb/s";
+	else
+		speed = "10Mb/s";
+	if (bmcr & BMCR_FULLDPLX)
+		duplex = "Full Duplex.\n";
+	else
+		duplex = "Half Duplex.\n";
+
+	if (netif_msg_link(lp))
+		printk(KERN_INFO "%s: Link has been forced up at %s, %s",
+		       dev->name, speed, duplex);
+}
+
+static void tc35815_set_link_modes(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int pid = lp->phy_addr;
+	unsigned short bmcr, lpa;
+	int speed;
+
+	if (lp->timer_state == arbwait) {
+		lpa = tc_mdio_read(dev, pid, MII_LPA);
+		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+		printk(KERN_DEBUG "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
+		       dev->name,
+		       bmcr, tc_mdio_read(dev, pid, MII_BMSR), lpa);
+		if (!(lpa & (LPA_10HALF | LPA_10FULL |
+			     LPA_100HALF | LPA_100FULL))) {
+			/* fall back to 10HALF */
+			printk(KERN_INFO "%s: bad ability %04x - falling back to 10HD.\n",
+			       dev->name, lpa);
+			lpa = LPA_10HALF;
+		}
+		if (options.duplex ? (bmcr & BMCR_FULLDPLX) : (lpa & (LPA_100FULL | LPA_10FULL)))
+			lp->fullduplex = 1;
+		else
+			lp->fullduplex = 0;
+		if (options.speed ? (bmcr & BMCR_SPEED100) : (lpa & (LPA_100HALF | LPA_100FULL)))
+			speed = 100;
+		else
+			speed = 10;
+	} else {
+		/* Forcing a link mode. */
+		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+		if (bmcr & BMCR_FULLDPLX)
+			lp->fullduplex = 1;
+		else
+			lp->fullduplex = 0;
+		if (bmcr & BMCR_SPEED100)
+			speed = 100;
+		else
+			speed = 10;
+	}
+
+	tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_HaltReq, &tr->MAC_Ctl);
+	if (lp->fullduplex) {
+		tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_FullDup, &tr->MAC_Ctl);
+	} else {
+		tc_writel(tc_readl(&tr->MAC_Ctl) & ~MAC_FullDup, &tr->MAC_Ctl);
+	}
+	tc_writel(tc_readl(&tr->MAC_Ctl) & ~MAC_HaltReq, &tr->MAC_Ctl);
+
+	/* TX4939 PCFG.SPEEDn bit will be changed on NETDEV_CHANGE event. */
+
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have EnLCarr */
+	if (lp->boardtype != TC35815_TX4939) {
+#ifdef WORKAROUND_LOSTCAR
+		/* WORKAROUND: enable LostCrS only if half duplex operation */
+		if (!lp->fullduplex && lp->boardtype != TC35815_TX4939)
+			tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr, &tr->Tx_Ctl);
+#endif
+	}
+#endif
+	lp->mii.full_duplex = lp->fullduplex;
+}
+
+static void tc35815_timer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	unsigned short bmsr, bmcr, lpa;
+	int restart_timer = 0;
+
+	spin_lock_irq(&lp->lock);
+
+	lp->timer_ticks++;
+	switch (lp->timer_state) {
+	case arbwait:
+		/*
+		 * Only allow for 5 ticks, thats 10 seconds and much too
+		 * long to wait for arbitration to complete.
+		 */
+		/* TC35815 need more times... */
+		if (lp->timer_ticks >= 10) {
+			/* Enter force mode. */
+			if (!options.doforce) {
+				printk(KERN_NOTICE "%s: Auto-Negotiation unsuccessful,"
+				       " cable probblem?\n", dev->name);
+				/* Try to restart the adaptor. */
+				tc35815_restart(dev);
+				goto out;
+			}
+			printk(KERN_NOTICE "%s: Auto-Negotiation unsuccessful,"
+			       " trying force link mode\n", dev->name);
+			printk(KERN_DEBUG "%s: BMCR %x BMSR %x\n", dev->name,
+			       tc_mdio_read(dev, pid, MII_BMCR),
+			       tc_mdio_read(dev, pid, MII_BMSR));
+			bmcr = BMCR_SPEED100;
+			tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+
+			/*
+			 * OK, seems we need do disable the transceiver
+			 * for the first tick to make sure we get an
+			 * accurate link state at the second tick.
+			 */
+
+			lp->timer_state = ltrywait;
+			lp->timer_ticks = 0;
+			restart_timer = 1;
 		} else {
-			/* auto negotiation */
-			unsigned long neg_result;
-			tc_phy_write(dev, MIICNTL_AUTO | MIICNTL_RST_AUTO, tr, 0, MII_CONTROL);
-			printk(KERN_INFO "%s: Auto Negotiation...", dev->name);
-			count = 0;
-			while (!(tc_phy_read(dev, tr, 0, MII_STATUS) & MIISTAT_AUTO_DONE)) {
-				if (count++ > 5000) {
-					printk(" failed. Assume 10Mbps\n");
-					lp->linkspeed = 10;
-					lp->fullduplex = 0;
-					goto done;
+			/* Anything interesting happen? */
+			bmsr = tc_mdio_read(dev, pid, MII_BMSR);
+			if (bmsr & BMSR_ANEGCOMPLETE) {
+				/* Just what we've been waiting for... */
+				tc35815_set_link_modes(dev);
+
+				/*
+				 * Success, at least so far, advance our state
+				 * engine.
+				 */
+				lp->timer_state = lupwait;
+				restart_timer = 1;
+			} else {
+				restart_timer = 1;
+			}
+		}
+		break;
+
+	case lupwait:
+		/*
+		 * Auto negotiation was successful and we are awaiting a
+		 * link up status.  I have decided to let this timer run
+		 * forever until some sort of error is signalled, reporting
+		 * a message to the user at 10 second intervals.
+		 */
+		bmsr = tc_mdio_read(dev, pid, MII_BMSR);
+		if (bmsr & BMSR_LSTATUS) {
+			/*
+			 * Wheee, it's up, display the link mode in use and put
+			 * the timer to sleep.
+			 */
+			tc35815_display_link_mode(dev);
+			netif_carrier_on(dev);
+#ifdef WORKAROUND_100HALF_PROMISC
+			/* delayed promiscuous enabling */
+			if (dev->flags & IFF_PROMISC)
+				tc35815_set_multicast_list(dev);
+#endif
+#if 1
+			lp->saved_lpa = tc_mdio_read(dev, pid, MII_LPA);
+			lp->timer_state = lcheck;
+			restart_timer = 1;
+#else
+			lp->timer_state = asleep;
+			restart_timer = 0;
+#endif
+		} else {
+			if (lp->timer_ticks >= 10) {
+				printk(KERN_NOTICE "%s: Auto negotiation successful, link still "
+				       "not completely up.\n", dev->name);
+				lp->timer_ticks = 0;
+				restart_timer = 1;
+			} else {
+				restart_timer = 1;
+			}
+		}
+		break;
+
+	case ltrywait:
+		/*
+		 * Making the timeout here too long can make it take
+		 * annoyingly long to attempt all of the link mode
+		 * permutations, but then again this is essentially
+		 * error recovery code for the most part.
+		 */
+		bmsr = tc_mdio_read(dev, pid, MII_BMSR);
+		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+		if (lp->timer_ticks == 1) {
+			/*
+			 * Re-enable transceiver, we'll re-enable the
+			 * transceiver next tick, then check link state
+			 * on the following tick.
+			 */
+			restart_timer = 1;
+			break;
+		}
+		if (lp->timer_ticks == 2) {
+			restart_timer = 1;
+			break;
+		}
+		if (bmsr & BMSR_LSTATUS) {
+			/* Force mode selection success. */
+			tc35815_display_forced_link_mode(dev);
+			netif_carrier_on(dev);
+			tc35815_set_link_modes(dev);
+#ifdef WORKAROUND_100HALF_PROMISC
+			/* delayed promiscuous enabling */
+			if (dev->flags & IFF_PROMISC)
+				tc35815_set_multicast_list(dev);
+#endif
+#if 1
+			lp->saved_lpa = tc_mdio_read(dev, pid, MII_LPA);
+			lp->timer_state = lcheck;
+			restart_timer = 1;
+#else
+			lp->timer_state = asleep;
+			restart_timer = 0;
+#endif
+		} else {
+			if (lp->timer_ticks >= 4) { /* 6 seconds or so... */
+				int ret;
+
+				ret = tc35815_try_next_permutation(dev);
+				if (ret == -1) {
+					/*
+					 * Aieee, tried them all, reset the
+					 * chip and try all over again.
+					 */
+					printk(KERN_NOTICE "%s: Link down, "
+					       "cable problem?\n",
+					       dev->name);
+
+					/* Try to restart the adaptor. */
+					tc35815_restart(dev);
+					goto out;
 				}
-				if (count % 512 == 0)
-					printk(".");
-				mdelay(1);
+				lp->timer_ticks = 0;
+				restart_timer = 1;
+			} else {
+				restart_timer = 1;
+			}
+		}
+		break;
+
+	case lcheck:
+		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+		lpa = tc_mdio_read(dev, pid, MII_LPA);
+		if (bmcr & (BMCR_PDOWN | BMCR_ISOLATE | BMCR_RESET)) {
+			printk(KERN_ERR "%s: PHY down? (BMCR %x)\n", dev->name,
+			       bmcr);
+		} else if ((lp->saved_lpa ^ lpa) &
+			   (LPA_100FULL|LPA_100HALF|LPA_10FULL|LPA_10HALF)) {
+			printk(KERN_NOTICE "%s: link status changed"
+			       " (BMCR %x LPA %x->%x)\n", dev->name,
+			       bmcr, lp->saved_lpa, lpa);
+		} else {
+			/* go on */
+			restart_timer = 1;
+			break;
+		}
+		/* Try to restart the adaptor. */
+		tc35815_restart(dev);
+		goto out;
+
+	case asleep:
+	default:
+		/* Can't happens.... */
+		printk(KERN_ERR "%s: Aieee, link timer is asleep but we got "
+		       "one anyways!\n", dev->name);
+		restart_timer = 0;
+		lp->timer_ticks = 0;
+		lp->timer_state = asleep; /* foo on you */
+		break;
+	}
+
+	if (restart_timer) {
+		lp->timer.expires = jiffies + msecs_to_jiffies(1200);
+		add_timer(&lp->timer);
+	}
+out:
+	spin_unlock_irq(&lp->lock);
+}
+
+static void tc35815_start_auto_negotiation(struct net_device *dev,
+					   struct ethtool_cmd *ep)
+{
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	unsigned short bmsr, bmcr, advertize;
+	int timeout;
+
+	netif_carrier_off(dev);
+	bmsr = tc_mdio_read(dev, pid, MII_BMSR);
+	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+	advertize = tc_mdio_read(dev, pid, MII_ADVERTISE);
+
+	if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
+		if (options.speed || options.duplex) {
+			/* Advertise only specified configuration. */
+			advertize &= ~(ADVERTISE_10HALF |
+				       ADVERTISE_10FULL |
+				       ADVERTISE_100HALF |
+				       ADVERTISE_100FULL);
+			if (options.speed != 10) {
+				if (options.duplex != 1)
+					advertize |= ADVERTISE_100FULL;
+				if (options.duplex != 2)
+					advertize |= ADVERTISE_100HALF;
+			}
+			if (options.speed != 100) {
+				if (options.duplex != 1)
+					advertize |= ADVERTISE_10FULL;
+				if (options.duplex != 2)
+					advertize |= ADVERTISE_10HALF;
 			}
-			printk(" done.\n");
-			neg_result = tc_phy_read(dev, tr, 0, MII_ANLPAR);
-			if (neg_result & (MII_AN_TX_FDX | MII_AN_TX_HDX))
-				lp->linkspeed = 100;
+			if (options.speed == 100)
+				bmcr |= BMCR_SPEED100;
+			else if (options.speed == 10)
+				bmcr &= ~BMCR_SPEED100;
+			if (options.duplex == 2)
+				bmcr |= BMCR_FULLDPLX;
+			else if (options.duplex == 1)
+				bmcr &= ~BMCR_FULLDPLX;
+		} else {
+			/* Advertise everything we can support. */
+			if (bmsr & BMSR_10HALF)
+				advertize |= ADVERTISE_10HALF;
 			else
-				lp->linkspeed = 10;
-			if (neg_result & (MII_AN_TX_FDX | MII_AN_10_FDX))
-				lp->fullduplex = 1;
+				advertize &= ~ADVERTISE_10HALF;
+			if (bmsr & BMSR_10FULL)
+				advertize |= ADVERTISE_10FULL;
 			else
-				lp->fullduplex = 0;
-		done:
-			;
+				advertize &= ~ADVERTISE_10FULL;
+			if (bmsr & BMSR_100HALF)
+				advertize |= ADVERTISE_100HALF;
+			else
+				advertize &= ~ADVERTISE_100HALF;
+			if (bmsr & BMSR_100FULL)
+				advertize |= ADVERTISE_100FULL;
+			else
+				advertize &= ~ADVERTISE_100FULL;
+		}
+
+		tc_mdio_write(dev, pid, MII_ADVERTISE, advertize);
+
+		/* Enable Auto-Negotiation, this is usually on already... */
+		bmcr |= BMCR_ANENABLE;
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+
+		/* Restart it to make sure it is going. */
+		bmcr |= BMCR_ANRESTART;
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+		printk(KERN_DEBUG "%s: ADVERTISE %x BMCR %x\n", dev->name, advertize, bmcr);
+
+		/* BMCR_ANRESTART self clears when the process has begun. */
+		timeout = 64;  /* More than enough. */
+		while (--timeout) {
+			bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+			if (!(bmcr & BMCR_ANRESTART))
+				break; /* got it. */
+			udelay(10);
 		}
+		if (!timeout) {
+			printk(KERN_ERR "%s: TC35815 would not start auto "
+			       "negotiation BMCR=0x%04x\n",
+			       dev->name, bmcr);
+			printk(KERN_NOTICE "%s: Performing force link "
+			       "detection.\n", dev->name);
+			goto force_link;
+		} else {
+			printk(KERN_DEBUG "%s: auto negotiation started.\n", dev->name);
+			lp->timer_state = arbwait;
+		}
+	} else {
+force_link:
+		/* Force the link up, trying first a particular mode.
+		 * Either we are here at the request of ethtool or
+		 * because the Happy Meal would not start to autoneg.
+		 */
+
+		/* Disable auto-negotiation in BMCR, enable the duplex and
+		 * speed setting, init the timer state machine, and fire it off.
+		 */
+		if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
+			bmcr = BMCR_SPEED100;
+		} else {
+			if (ep->speed == SPEED_100)
+				bmcr = BMCR_SPEED100;
+			else
+				bmcr = 0;
+			if (ep->duplex == DUPLEX_FULL)
+				bmcr |= BMCR_FULLDPLX;
+		}
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
+
+		/* OK, seems we need do disable the transceiver for the first
+		 * tick to make sure we get an accurate link state at the
+		 * second tick.
+		 */
+		lp->timer_state = ltrywait;
 	}
 
-	ctl = 0;
-	if (lp->linkspeed == 100)
-		ctl |= MIICNTL_SPEED;
-	if (lp->fullduplex)
-		ctl |= MIICNTL_FDX;
-	tc_phy_write(dev, ctl, tr, 0, MII_CONTROL);
+	del_timer(&lp->timer);
+	lp->timer_ticks = 0;
+	lp->timer.expires = jiffies + msecs_to_jiffies(1200);
+	add_timer(&lp->timer);
+}
 
-	if (lp->fullduplex) {
-		tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_FullDup, &tr->MAC_Ctl);
+static void tc35815_find_phy(struct net_device *dev)
+{
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	unsigned short id0;
+
+	/* find MII phy */
+	for (pid = 31; pid >= 0; pid--) {
+		id0 = tc_mdio_read(dev, pid, MII_BMSR);
+		if (id0 != 0xffff && id0 != 0x0000 &&
+		    (id0 & BMSR_RESV) != (0xffff & BMSR_RESV) /* paranoia? */
+			) {
+			lp->phy_addr = pid;
+			break;
+		}
 	}
+	if (pid < 0) {
+		printk(KERN_ERR "%s: No MII Phy found.\n",
+		       dev->name);
+		lp->phy_addr = pid = 0;
+	}
+
+	lp->mii_id[0] = tc_mdio_read(dev, pid, MII_PHYSID1);
+	lp->mii_id[1] = tc_mdio_read(dev, pid, MII_PHYSID2);
+	if (netif_msg_hw(lp))
+		printk(KERN_INFO "%s: PHY(%02x) ID %04x %04x\n", dev->name,
+		       pid, lp->mii_id[0], lp->mii_id[1]);
 }
 
-static void tc35815_chip_reset(struct net_device *dev)
+static void tc35815_phy_chip_init(struct net_device *dev)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
+	struct tc35815_local *lp = dev->priv;
+	int pid = lp->phy_addr;
+	unsigned short bmcr;
+	struct ethtool_cmd ecmd, *ep;
+
+	/* dis-isolate if needed. */
+	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
+	if (bmcr & BMCR_ISOLATE) {
+		int count = 32;
+		printk(KERN_DEBUG "%s: unisolating...", dev->name);
+		tc_mdio_write(dev, pid, MII_BMCR, bmcr & ~BMCR_ISOLATE);
+		while (--count) {
+			if (!(tc_mdio_read(dev, pid, MII_BMCR) & BMCR_ISOLATE))
+				break;
+			udelay(20);
+		}
+		printk(" %s.\n", count ? "done" : "failed");
+	}
+
+	if (options.speed && options.duplex) {
+		ecmd.autoneg = AUTONEG_DISABLE;
+		ecmd.speed = options.speed == 10 ? SPEED_10 : SPEED_100;
+		ecmd.duplex = options.duplex == 1 ? DUPLEX_HALF : DUPLEX_FULL;
+		ep = &ecmd;
+	} else {
+		ep = NULL;
+	}
+	tc35815_start_auto_negotiation(dev, ep);
+}
 
+static void tc35815_chip_reset(struct net_device *dev)
+{
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int i;
 	/* reset the controller */
 	tc_writel(MAC_Reset, &tr->MAC_Ctl);
-	while (tc_readl(&tr->MAC_Ctl) & MAC_Reset)
-		;
-
+	udelay(4); /* 3200ns */
+	i = 0;
+	while (tc_readl(&tr->MAC_Ctl) & MAC_Reset) {
+		if (i++ > 100) {
+			printk(KERN_ERR "%s: MAC reset failed.\n", dev->name);
+			break;
+		}
+		mdelay(1);
+	}
 	tc_writel(0, &tr->MAC_Ctl);
 
 	/* initialize registers to default value */
@@ -1651,90 +2838,142 @@ static void tc35815_chip_reset(struct ne
 	tc_writel(0, &tr->CAM_Ena);
 	(void)tc_readl(&tr->Miss_Cnt);	/* Read to clear */
 
+	/* initialize internal SRAM */
+	tc_writel(DMA_TestMode, &tr->DMA_Ctl);
+	for (i = 0; i < 0x1000; i += 4) {
+		tc_writel(i, &tr->CAM_Adr);
+		tc_writel(0, &tr->CAM_Data);
+	}
+	tc_writel(0, &tr->DMA_Ctl);
 }
 
 static void tc35815_chip_init(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs*)dev->base_addr;
-	unsigned long flags;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	unsigned long txctl = TX_CTL_CMD;
 
 	tc35815_phy_chip_init(dev);
 
 	/* load station address to CAM */
-	tc35815_set_cam_entry(tr, CAM_ENTRY_SOURCE, dev->dev_addr);
+	tc35815_set_cam_entry(dev, CAM_ENTRY_SOURCE, dev->dev_addr);
 
 	/* Enable CAM (broadcast and unicast) */
 	tc_writel(CAM_Ena_Bit(CAM_ENTRY_SOURCE), &tr->CAM_Ena);
 	tc_writel(CAM_CompEn | CAM_BroadAcc, &tr->CAM_Ctl);
 
-	spin_lock_irqsave(&lp->lock, flags);
-
-	tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
-
+	/* Use DMA_RxAlign_2 to make IP header 4-byte aligned. */
+	if (HAVE_DMA_RXALIGN(lp))
+		tc_writel(DMA_BURST_SIZE | DMA_RxAlign_2, &tr->DMA_Ctl);
+	else
+		tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
+#ifdef TC35815_USE_PACKEDBUFFER
 	tc_writel(RxFrag_EnPack | ETH_ZLEN, &tr->RxFragSize);	/* Packing */
+#else
+	tc_writel(ETH_ZLEN, &tr->RxFragSize);
+#endif
 	tc_writel(0, &tr->TxPollCtr);	/* Batch mode */
 	tc_writel(TX_THRESHOLD, &tr->TxThrsh);
 	tc_writel(INT_EN_CMD, &tr->Int_En);
 
 	/* set queues */
-	tc_writel(virt_to_bus(lp->rfd_base), &tr->FDA_Bas);
+	tc_writel(fd_virt_to_bus(lp, lp->rfd_base), &tr->FDA_Bas);
 	tc_writel((unsigned long)lp->rfd_limit - (unsigned long)lp->rfd_base,
 		  &tr->FDA_Lim);
 	/*
 	 * Activation method:
-	 * First, enable eht MAC Transmitter and the DMA Receive circuits.
+	 * First, enable the MAC Transmitter and the DMA Receive circuits.
 	 * Then enable the DMA Transmitter and the MAC Receive circuits.
 	 */
-	tc_writel(virt_to_bus(lp->fbl_ptr), &tr->BLFrmPtr);	/* start DMA receiver */
+	tc_writel(fd_virt_to_bus(lp, lp->fbl_ptr), &tr->BLFrmPtr);	/* start DMA receiver */
 	tc_writel(RX_CTL_CMD, &tr->Rx_Ctl);	/* start MAC receiver */
+
 	/* start MAC transmitter */
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have EnLCarr */
+	if (lp->boardtype == TC35815_TX4939)
+		txctl &= ~Tx_EnLCarr;
+#ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
-	if (lp->fullduplex)
-		txctl = TX_CTL_CMD & ~Tx_EnLCarr;
+	if ((lp->timer_state != asleep && lp->timer_state != lcheck) ||
+	    lp->fullduplex)
+		txctl &= ~Tx_EnLCarr;
+#endif
+#endif /* !NO_CHECK_CARRIER */
 #ifdef GATHER_TXINT
 	txctl &= ~Tx_EnComp;	/* disable global tx completion int. */
 #endif
 	tc_writel(txctl, &tr->Tx_Ctl);
-#if 0	/* No need to polling */
-	tc_writel(virt_to_bus(lp->tfd_base), &tr->TxFrmPtr);	/* start DMA transmitter */
-#endif
+}
+
+#ifdef CONFIG_PM
+static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tc35815_local *lp = dev->priv;
+	unsigned long flags;
+
+	pci_save_state(pdev);
+	if (!netif_running(dev))
+		return 0;
+	netif_device_detach(dev);
+	spin_lock_irqsave(&lp->lock, flags);
+	del_timer(&lp->timer);		/* Kill if running	*/
+	tc35815_chip_reset(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
+	pci_set_power_state(pdev, PCI_D3hot);
+	return 0;
 }
 
-static struct pci_driver tc35815_driver = {
-	.name = TC35815_MODULE_NAME,
-	.probe = tc35815_probe,
-	.remove = NULL,
-	.id_table = tc35815_pci_tbl,
+static int tc35815_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tc35815_local *lp = dev->priv;
+	unsigned long flags;
+
+	pci_restore_state(pdev);
+	if (!netif_running(dev))
+		return 0;
+	pci_set_power_state(pdev, PCI_D0);
+	spin_lock_irqsave(&lp->lock, flags);
+	tc35815_restart(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	netif_device_attach(dev);
+	return 0;
+}
+#endif /* CONFIG_PM */
+
+static struct pci_driver tc35815_pci_driver = {
+	.name		= MODNAME,
+	.id_table	= tc35815_pci_tbl,
+	.probe		= tc35815_init_one,
+	.remove		= __devexit_p(tc35815_remove_one),
+#ifdef CONFIG_PM
+	.suspend	= tc35815_suspend,
+	.resume		= tc35815_resume,
+#endif
 };
 
+module_param_named(speed, options.speed, int, 0);
+MODULE_PARM_DESC(speed, "0:auto, 10:10Mbps, 100:100Mbps");
+module_param_named(duplex, options.duplex, int, 0);
+MODULE_PARM_DESC(duplex, "0:auto, 1:half, 2:full");
+module_param_named(doforce, options.doforce, int, 0);
+MODULE_PARM_DESC(doforce, "try force link mode if auto-negotiation failed");
+
 static int __init tc35815_init_module(void)
 {
-	return pci_register_driver(&tc35815_driver);
+	return pci_register_driver(&tc35815_pci_driver);
 }
 
 static void __exit tc35815_cleanup_module(void)
 {
-	struct net_device *next_dev;
-
-	/*
-	 * TODO: implement a tc35815_driver.remove hook, and
-	 * move this code into that function.  Then, delete
-	 * all root_tc35815_dev list handling code.
-	 */
-	while (root_tc35815_dev) {
-		struct net_device *dev = root_tc35815_dev;
-		next_dev = ((struct tc35815_local *)dev->priv)->next_module;
-		iounmap((void *)(dev->base_addr));
-		unregister_netdev(dev);
-		free_netdev(dev);
-		root_tc35815_dev = next_dev;
-	}
-
-	pci_unregister_driver(&tc35815_driver);
+	pci_unregister_driver(&tc35815_pci_driver);
 }
 
 module_init(tc35815_init_module);
 module_exit(tc35815_cleanup_module);
+
+MODULE_DESCRIPTION("TOSHIBA TC35815 PCI 10M/100M Ethernet driver");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 600308f..247b5e6 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1459,6 +1459,8 @@
 
 #define PCI_VENDOR_ID_TOSHIBA_2		0x102f
 #define PCI_DEVICE_ID_TOSHIBA_TC35815CF	0x0030
+#define PCI_DEVICE_ID_TOSHIBA_TC35815_NWU	0x0031
+#define PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939	0x0032
 #define PCI_DEVICE_ID_TOSHIBA_TC86C001_IDE	0x0105
 #define PCI_DEVICE_ID_TOSHIBA_TC86C001_MISC	0x0108
 #define PCI_DEVICE_ID_TOSHIBA_SPIDER_NET 0x01b3
