From: Marc St-Jean <stjeanma@pmc-sierra.com>
Subject: [PATCH] drivers: PMC MSP71xx ethernet driver
Date: Fri, 23 Feb 2007 16:40:11 -0600
Message-ID: <200702232240.l1NMeBCL006272@pasqua.pmc-sierra.bc.ca>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

[PATCH] drivers: PMC MSP71xx ethernet driver

Patch to add 10/100 Mbps ethernet support for the PMC-Sierra
MSP71xx devices.

This patch references some platform support files previously
submitted to the linux-mips@linux-mips.org list.

Thanks,
Marc

Signed-off-by: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
---
 arch/mips/pmc-sierra/msp71xx/msp_eth.c |   55 
 drivers/net/Kconfig                    |    6 
 drivers/net/Makefile                   |    1 
 drivers/net/pmcmspeth.c                | 2622 +++++++++++++++++++++++++++++++++
 drivers/net/pmcmspeth.h                |  545 ++++++
 5 files changed, 3229 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 76f98f3..1f4e0b0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -201,6 +201,12 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
+config PMC_MSP_ETH
+	bool "Ethernet for PMC-Sierra MSP"
+	depends on NET_ETHERNET && PMC_MSP
+	---help---
+	This adds support for the the MACs found on the PMC-Sierra MSP devices.
+
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on NET_ETHERNET && PPC_PMAC && PPC32
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c26ba39..6d21e56 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -68,6 +68,7 @@ obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
+obj-$(CONFIG_PMC_MSP_ETH) += pmcmspeth.o
 obj-$(CONFIG_RIONET) += rionet.o
 
 #
diff --git a/drivers/net/pmcmspeth.c b/drivers/net/pmcmspeth.c
new file mode 100644
index 0000000..0ea7ffa
--- /dev/null
+++ b/drivers/net/pmcmspeth.c
@@ -0,0 +1,2622 @@
+/******************************************************************
+ * Copyright 2005 PMC-Sierra, Inc
+ *
+ * PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND
+ * FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS
+ * SOFTWARE.
+ */
+
+/***********************************************************************
+ *  pmcmspeth.c :  PMC-Sierra MSP EVM ethernet driver for linux
+ *
+ * Originally based on mspeth.c driver which contains substantially the
+ * same hardware.
+ * Based on skelton.c by Donald Becker.
+ * ported by Andrew Hughes, Andrew_Hughes@pmc-sierra.com
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
+ * WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
+ * NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
+ * USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
+ * ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * You should have received a copy of the  GNU General Public License along
+ * with this program; if not, write  to the Free Software Foundation, Inc.,
+ * 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <asm/pmc-sierra/msp71xx/msp_prom.h>
+#include <asm/pmc-sierra/msp71xx/msp_int.h>
+
+/* Include file with the procfs structs and function protos */
+#include <linux/proc_fs.h>
+
+/* driver includes */
+#include "pmcmspeth.h"
+
+/**************************************************************************
+ * The name of the card. Is used for messages and in the requests for
+ * io regions, irqs and dma channels.  versions etc.  Also, various other
+ * identifying character constants.
+ */
+static const char version[]     = "pmcmspeth.c:v0.00 25/05/2005, PMC-Sierra\n";
+static const char cardname[]    = "pmcmspeth";
+static const char drv_version[] = "$Revision: 1.21 $";
+static const char drv_reldate[] = "$Date: 2006/10/19 22:08:16 $";
+static const char drv_file[]    = __FILE__;
+
+/**************************************************************************
+ * list of PHYs.  Each MAC will have a certain number (maybe zero) PHYs
+ * hanging off the MDIO interface.
+ */
+static struct mspeth_phy *root_phy_dev = NULL;
+
+/* debugging flags */
+/* hammtrev, 2005-11-25:
+ * For some odd reason, setting MSPETH_DEBUG to a non-zero value was setting
+ * this variable to some garbage value when assigned statically here. Moving
+ * assignment of this variable into mspeth_probe().
+ */
+static unsigned int mspeth_debug;
+
+/**************************************************************************
+ * Function prototypes
+ */
+/* all the functions that get called by upper layers */
+static int	mspeth_open(struct net_device *dev);
+static int	mspeth_send_packet(struct sk_buff *skb, struct net_device *dev);
+static void	mspeth_tx_timeout(struct net_device *dev);
+static irqreturn_t mspeth_interrupt(int irq, void *dev_id);
+static void	mspeth_hard_restart_bh(unsigned long devaddr);
+static void	mspeth_rx(unsigned long devaddr);
+static void	mspeth_txdone(unsigned long devaddr);
+static int	mspeth_close(struct net_device *dev);
+static struct net_device_stats *mspeth_get_stats(struct net_device *dev);
+static void	mspeth_set_multicast_list(struct net_device *dev);
+
+/* private utility functions */
+static void mspeth_soft_restart(struct net_device *dev);
+static void mspeth_hard_restart(struct net_device *dev);
+static void mspeth_mac_reset(struct net_device *dev);
+static void mspeth_mac_init(struct net_device *dev);
+static void mspeth_phy_init(struct net_device *dev);
+static void mspeth_phy_reset(struct net_device *dev);
+static int  mspeth_proc_info(char *buf, char **buf_loc, off_t off, int len, int *eof, void *data);
+static bool mspeth_queue_init(struct net_device *dev);
+static void mspeth_set_arc_entry(struct net_device *dev, int index, unsigned char *addr);
+static void mspeth_check_tx_stat(struct net_device *dev, int status);\
+static int  mspeth_phyprobe(struct net_device *dev);
+static void mspeth_init_phyaddr(struct net_device *dev);
+static void mspeth_init_cmdline(struct net_device *dev);
+static void mspeth_clear_queues(struct net_device *dev);
+static void mspeth_fatal_error_interrupt(struct net_device *dev, int status);
+
+#ifndef MSP_INT_MAC2
+#define MSP_INT_MAC2 0
+#endif
+
+/*
+*#############################################################################
+*#                                                                           #
+*# Define the utility functions used by the the various other actual         #
+*#     routines here.  These should all be inline or macros                  #
+*#                                                                           #
+*#############################################################################
+*/
+#define flush_memqueue() \
+({__asm__ volatile ("lw $0, %0" : : "m" (*MEM_CFG1_REG));})
+#define flush_dmaqueue() \
+({__asm__ volatile ("lw $0, %0" : : "m" (*(volatile u32 *)(lp->mapaddr+MSPETH_Int_Src)));})
+
+#define read_addr(addr) (*(volatile u32 *)((addr)))
+/************************************************************************
+ * read_addr_blocking -  Read address with blocking load
+ * 
+ * - Uncached writes need to be read back to ensure they reach RAM.
+ * The returned value must be 'used' to prevent from becoming a
+ * non-blocking load.
+ */
+#define read_addr_blocking(addr)		\
+({										\
+	u32 __value;						\
+	__asm__ __volatile__(				\
+	"	.set	push				\n"	\
+	"	.set	noreorder			\n"	\
+	"	lw		%0, %1				\n"	\
+	"	move	%0, %0				\n"	\
+	"	.set	pop					\n"	\
+	: "=r" (__value)					\
+	: "m" (*(volatile u32 *)(addr)));			\
+	__value;	\
+})
+#define write_addr(addr,val) (*(volatile u32 *)((addr)) = (u32)(val))
+
+#define vtonocache(p)   KSEG1ADDR(virt_to_phys(p))
+
+#define rd_nocache(addr) (*(volatile u32 *)(KSEG1ADDR((u32)(addr))))
+#define wr_nocache(val,addr) (*(volatile u32 *)(KSEG1ADDR((u32)(addr))) = (u32)(val))
+
+#ifdef CONFIG_DMA_NONCOHERENT
+/************************************************************************
+ * writeback_buffer - force the cache to write contents of cached buffer
+ * to memory and invalidate the buffer.  Must start on cache line boundary,
+ * must "own" to next higher cache line boundary from end of buffer
+ * 
+ * stjeanma, 2006-06-12:
+ * - uses L1_CACHE_ALIGN to cache align the buffer rounding down to
+ * the next cache line. It is the resposibility of the caller to ensure
+ * that any partial cache line before the pointer isn't conflicting with
+ * other memory shared with the controller.
+ * stjeanma, 2006-01-26:
+ * - kernel comment states Hit_Writeback_D is more dangerous than
+ * Hit_Writeback_Inv_D used by flush_dcache_line. Since this function
+ * should only be called on buffers the controller never modifies we
+ * are safe to NOT invalidate.
+ */
+inline static void
+writeback_buffer(void *bufaddr, unsigned int length)
+{
+	unsigned long end = (unsigned long)bufaddr + length;
+	bufaddr =
+	    (void *) ((unsigned long)bufaddr & ~(L1_CACHE_BYTES - 1));
+
+	while ((unsigned long)bufaddr + UNROLL_INCR < end) {
+		CACHE_UNROLL(bufaddr, Hit_Writeback_D);
+		bufaddr += UNROLL_INCR;
+	}
+
+	while ((unsigned long)bufaddr < end) {
+		flush_dcache_line((unsigned long)bufaddr);
+		bufaddr += L1_CACHE_BYTES;
+	}
+}
+
+/************************************************************************
+ * writeback_qdesc - writeback a Q_Desc structure.  Must start on a
+ *     16 byte boundary
+ */
+inline static void
+writeback_qdesc(struct Q_Desc *qdesc)
+{
+	flush_dcache_line((u32)qdesc);
+#if L1_CACHE_BYTES == 0x10
+	flush_dcache_line((u32)qdesc+0x10);
+#endif
+}
+
+/************************************************************************
+ * writeback_bdesc - writeback a BDesc structure.
+ * 
+ * stjeanma, 2006-01-26:
+ * - This function must not be called on architectures with larger
+ * than 8 byte cache lines if the BDesc are in a packed array.
+ * Otherwise one or more BDesc will be unintentionally overwritten.
+ */
+inline static void
+writeback_bdesc(struct BDesc *bdesc)
+{
+	flush_dcache_line((u32)bdesc);
+}
+#else
+#define writeback_buffer(a,l) do {} while (0)
+#define writeback_qdesc(a) do {} while (0)
+#define writeback_bdesc(a) do {} while (0)
+#endif /* CONFIG_DMA_NONCOHERENT */
+
+/************************************************************************
+ * pref - prefetch to data cache
+ *      Prefetch data to help improve performance
+ */
+#define pref(base, offset)	  __asm__ __volatile__(   \
+		"pref 0, %1(%0)"	\
+		:				   	\
+		: "r" (base),		\
+		  "I" (offset));
+
+/************************************************************************
+ * invalidate_buffer - Invalidate buffer cache
+ *      - must start on cache line boundary
+ *      - must "own" to next higher cache line boundary from end of buffer
+ *
+ * stjeanma, 2006-06-12:
+ * - uses L1_CACHE_ALIGN to cache align the buffer rounding down to
+ * the next cache line. It is the resposibility of the caller to ensure
+ * that any partial cache line before the pointer isn't conflicting with
+ * other memory shared with the controller.
+ */
+inline static void
+invalidate_buffer(void *bufaddr, unsigned int length)
+{
+	unsigned long end = (unsigned long)bufaddr + length;
+	bufaddr =
+	    (void *) ((unsigned long)bufaddr & ~(L1_CACHE_BYTES - 1));
+
+	while ((unsigned long)bufaddr + UNROLL_INCR < end) {
+		CACHE_UNROLL(bufaddr, Hit_Invalidate_D);
+		bufaddr += UNROLL_INCR;
+	}
+
+	while ((unsigned long)bufaddr < end) {
+		invalidate_dcache_line((unsigned long)bufaddr );
+		bufaddr += L1_CACHE_BYTES;
+	}
+}
+
+/************************************************************************
+ * invalidate_qdesc - Invalidate a Q_Desc structure.  Must start on a
+ *     16 byte boundary
+ */
+inline static void
+invalidate_qdesc(struct Q_Desc *qdesc)
+{
+	invalidate_dcache_line((u32)qdesc);
+#if L1_CACHE_BYTES == 0x10
+	invalidate_dcache_line(((u32)qdesc)+0x10);
+#endif
+}
+
+
+/************************************************************************
+ * Read/Write a MSP eth register.
+ */
+inline static u32
+msp_read(struct mspeth_local *lp, unsigned int offset)
+{
+	return read_addr((u32)lp->mapaddr+offset);
+}
+
+inline static void
+msp_write(struct mspeth_local *lp, unsigned int offset,u32 val)
+{
+	write_addr((u32)lp->mapaddr+offset,val);
+}
+
+
+/************************************************************************
+ * Read/Write a MDIO register.
+ */
+inline static u32
+mspphy_read(struct mspeth_phy *phyptr, int phy_reg)
+{
+	unsigned long flags;
+	u32 data;
+
+	if(phyptr == NULL) {
+		printk("MSPETH(mspphy_read): Cannot read from a NULL PHY!\n");
+		return 0x0;
+	}
+
+	/* protect access with spin lock */
+	spin_lock_irqsave(&(phyptr->lock),flags);
+
+	while (read_addr(phyptr->memaddr + MSPPHY_MII_CTRL) & MD_CA_BUSY_BIT) {;}
+	write_addr(phyptr->memaddr + MSPPHY_MII_CTRL,
+				MD_CA_BUSY_BIT | phyptr->phyaddr << 5 | phy_reg);
+	while (read_addr(phyptr->memaddr + MSPPHY_MII_CTRL) & MD_CA_BUSY_BIT) {;}
+	data = read_addr(phyptr->memaddr + MSPPHY_MII_DATA);
+
+	/* unlock */
+	spin_unlock_irqrestore(&(phyptr->lock),flags);
+
+	return data & 0xffff;
+}
+
+inline static void
+mspphy_write(struct mspeth_phy *phyptr, int phy_reg,u32 data)
+{
+	unsigned long flags;
+
+	if(phyptr == NULL) {
+		printk("MSPETH(mspphy_write): Cannot write to a NULL PHY!\n");
+		return;
+	}
+
+	/* protect access with spin lock */
+	spin_lock_irqsave(&(phyptr->lock),flags);
+
+	while (read_addr(phyptr->memaddr + MSPPHY_MII_CTRL) & MD_CA_BUSY_BIT) {;}
+	write_addr(phyptr->memaddr + MSPPHY_MII_DATA,data);
+	write_addr(phyptr->memaddr + MSPPHY_MII_CTRL,
+				MD_CA_BUSY_BIT | MD_CA_Wr | phyptr->phyaddr << 5 | phy_reg);
+	while (read_addr(phyptr->memaddr + MSPPHY_MII_CTRL) & MD_CA_BUSY_BIT) {;}
+
+	/* unlock */
+	spin_unlock_irqrestore(&(phyptr->lock),flags);
+
+	return;
+}
+
+/**************************************************************************
+ * allocate and align a max length socket buffer for this device
+ */
+inline static struct sk_buff *
+mspeth_alloc_skb(struct net_device *dev)
+{
+	struct sk_buff *skb;
+
+	/* we need a bit more that an ethernet frame for the aligment stuff so
+	 * preallocate two more*/
+	skb = dev_alloc_skb(MSP_END_BUFSIZE + 2);
+	if (skb == NULL) {
+		printk(KERN_WARNING "MSETH (alloc_skb) %s: cannot allocate skb!\n",
+				dev->name);
+		return NULL;
+	}
+
+	/* align and fill out fields specific to our device.  Notice that
+	 * our device is smart about FCS etc ......
+	 */
+	skb_reserve(skb,2);
+	skb->dev = dev;
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+}
+
+
+
+/**************************************************************************
+ * error reporting functions -- used for debugging mostly
+ */
+static void
+dump_qdesc(struct Q_Desc *fd)
+{
+	printk("  Q_Desc(%p): %08x %08x %08x %08x\n", fd, fd->fd.FDNext,
+			fd->fd.FDSystem, fd->fd.FDStat, fd->fd.FDCtl);
+	printk("    BD: %08x %08x\n",fd->bd.BuffData,fd->bd.BDCtl);
+}
+
+static void
+print_buf(char *add, int length)
+{
+	int i;
+	int len = length;
+
+	printk("print_buf(%08x)(%x)\n", (unsigned int) add, length);
+
+	if (len > 100)
+		len = 100;
+	for (i = 0; i < len; i++) {
+		printk(" %2.2X", (unsigned char) add[i]);
+		if (!(i % 16))
+			printk("\n");
+	}
+	printk("\n");
+}
+
+static void
+print_eth(int rx,char *add,int len)
+{
+	int i;
+	int lentyp;
+
+	if(rx)
+		printk("\n************************** RX packet 0x%08x ****************************\n",(u32)add);
+	else
+		printk("\n************************** TX packet 0x%08x ****************************\n",(u32)add);
+
+	printk("---- ethernet ----\n");
+	printk("==> dest: ");
+	for (i = 0; i < 6; i++) {
+		printk("%02x", (unsigned char)add[i]);
+		printk(i<5?":":"\n");
+	}
+	printk("==>  src: ");
+	for (i = 0; i < 6; i++) {
+		printk("%02x", (unsigned char)add[i+6]);
+		printk(i<5?":":"\n");
+	}
+	lentyp = ((unsigned char)add[12] << 8) | (unsigned char)add[13];
+	if(lentyp <= 1500)
+		printk("==>  len: %d\n",lentyp);
+	else if(lentyp > 1535)
+		printk("==> type: 0x%04x\n",lentyp);
+	else
+		printk("==> ltyp: 0x%04x\n",lentyp);
+
+	if (len > 0x100)
+		len = 0x100;
+
+	for(i=0;i < ((u32)add & 0x0000000F);i++) {
+		printk("   ");
+	}
+	for (i = 0; i < len; i++,add++) {
+		printk(" %02x", *((unsigned char *)add));
+		if (!(((u32)add + 1) % 0x10))
+			printk("\n");
+	}
+	printk("\n");
+}
+
+/* Used mainly for debugging unusual conditions signalled by a 
+ * fatal error interrupt (eg, IntBLEx). This function stops the transmit
+ * and receive in an attempt to capture the true state of the queues
+ * at the time of the interrupt.
+ */
+#undef MSPETH_DUMP_QUEUES
+#ifdef MSPETH_DUMP_QUEUES
+static void
+dump_blist(struct BL_Desc *fd)
+{
+	int i;
+	
+	printk("  BL_Desc(%p): %08x %08x %08x %08x\n", fd, fd->fd.FDNext,
+			fd->fd.FDSystem, fd->fd.FDStat, fd->fd.FDCtl);
+	for (i = 0; i < RX_BUF_NUM << 1; i++)
+		printk("    BD #%d: %08x %08x\n", i, fd->bd[i].BuffData,
+				fd->bd[i].BDCtl);
+}
+
+/* Catalog the received buffers numbers */
+static int rx_bdnums[2][RX_BUF_NUM << 2];
+static int rx_bdnums_ind[2] = {0, 0};
+static inline void catalog_rx_bdnum(int hwnum, int bdnum)
+{
+	rx_bdnums_ind[hwnum] = (rx_bdnums_ind[hwnum] + 1) & ((RX_BUF_NUM<<2)-1);
+	rx_bdnums[hwnum][rx_bdnums_ind[hwnum]] = bdnum;
+}
+
+static void mspeth_dump_queues(struct net_device *dev)
+{
+	struct mspeth_local *lp = (struct mspeth_local *) dev->priv;
+	int unit = lp->unit;
+	int i;
+
+	/* Halt Xmit and Recv to preserve the state of queues */
+	/* msp_write(lp, MSPETH_MAC_Ctl, MAC_HaltReq); */
+	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) & ~Rx_RxEn);
+	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) & ~Tx_En);
+
+	/* Print receive queue */
+	printk("Receive Queue\n");
+	printk("=============\n\n");
+	printk("rxfd_base = 0x%08x\n", (unsigned int) lp->rxfd_base);
+	printk("rxfd_curr = 0x%08x\n", (unsigned int) lp->rxfd_curr);
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		printk("%d:", i);
+		dump_qdesc((struct Q_Desc *) &lp->rxfd_base[i]);
+	}
+
+	/* Print transmit queue */
+	printk("\nTransmit Queue\n");
+	printk("==============\n");
+	printk("txfd_base = 0x%08x\n", (unsigned int) lp->txfd_base);
+	printk("tx_head = %d, tx_tail = %d\n", lp->tx_head, lp->tx_tail);
+	for (i = 0; i < TX_BUF_NUM; i++) {
+		printk("%d:", i);
+		dump_qdesc((struct Q_Desc *) &lp->txfd_base[i]);
+	}
+
+	/* Print the free buffer list */
+	printk("\nFree Buffer List\n");
+	printk("================\n");
+	printk("blfd_ptr = 0x%08x\n", (unsigned int) lp->blfd_ptr);
+	dump_blist(lp->blfd_ptr);
+
+	/* Finally print the bdnum history and current index as a reference */
+	printk("\nbdnum history\n");
+	printk("=============\n");
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		printk("\t%d\t%d\t%d\t%d\n", 
+				rx_bdnums[unit][4*i], rx_bdnums[unit][4*i+1],
+				rx_bdnums[unit][4*i+2], rx_bdnums[unit][4*i+3]);
+	}
+	printk("Current bdnum index: %d\n", rx_bdnums_ind[unit]);
+
+	/* Re-enable Xmit/Recv */
+	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) | Rx_RxEn);
+	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) | Tx_En);
+}
+
+static void mspeth_dump_stats(struct net_device *dev)
+{
+	struct mspeth_local *lp = (struct mspeth_local *) dev->priv;
+
+	printk("Interface stats:\n");
+	printk("\ttx_ints: %d\n", lp->lstats.tx_ints);
+	printk("\trx_ints: %d\n", lp->lstats.rx_ints);
+	printk("\ttx_full: %d\n", lp->lstats.tx_full);
+	printk("\tfd_exha: %d\n", lp->lstats.fd_exha);
+}
+#else
+#define mspeth_dump_stats(a) do {} while (0)
+#define mspeth_dump_queues(a) do {} while (0)
+#define catalog_rx_bdnum(a,b) do {} while (0)
+#define dump_blist(a) do {} while (0)
+#endif				/* MSPETH_DUMP_QUEUES */
+
+/*
+##############################################################################
+#                                                                            #
+# Actual functions used in the driver are defined here.  They should         #
+#   all start with mspeth                                                    #
+#                                                                            #
+##############################################################################
+*/
+
+/**************************************************************************
+ * Check for an mspeth ethernet device and return 0 if there is one.  Also
+ * a good time to fill out some of the device fields and do some preliminary
+ * initialization.  The mspeth resources are statically allocated.
+ */
+int
+mspeth_probe(struct device *pldev)
+{
+
+	int unit,hwunit;
+	int i,err;
+	u8 macaddr[8];
+	struct net_device *dev;
+	struct mspeth_local *lp;
+	char tmp_str[128];
+
+	/* default return value -- no device here */
+	err = -ENODEV;
+
+	/* determine what interface we think we are */
+	unit = to_platform_device(pldev)->id;
+
+	/* scan the hardware list and associate a logical unit with a hardware unit
+	 * it's important to keep these two straight.  hwunit is used for accessing
+	 * the prom and all hardware.  unit is used when parsing the commandline
+	 * and any other uses that might refer to *all* eth devices (not just
+	 * mspeth devices) in the system
+	 */
+	for (i = 0,hwunit = 0;hwunit < MSPETH_MAX_UNITS;hwunit++) {
+		if (identify_enet(hwunit) != FEATURE_NOEXIST) {
+			if (i++ == unit)
+				break;
+		}
+	}
+
+	/* Sanity checks on hardware parameters */
+	if (unit < 0 || hwunit >= MSPETH_MAX_UNITS)
+		goto out_err;
+
+	mspeth_debug = MSPETH_DEBUG;
+
+	/* Retrieve the mac address from the PROM */
+	snprintf(tmp_str,128,"ethaddr%d",hwunit);
+	if (get_ethernet_addr(tmp_str, macaddr)) {
+		printk(KERN_INFO " No Mac addr specified for eth%d, hwunit %d\n",
+				unit, hwunit);
+		goto out_err;
+	}
+
+	if (macaddr[0] & 0x01) {
+		printk(KERN_INFO "Bad Multicast Mac addr specified for eth%d, "
+			"hwunit %d %02x:%02x:%02x:%02x:%02x:%02x\n",
+			unit, hwunit,
+			macaddr[0], macaddr[1], macaddr[2],
+			macaddr[3], macaddr[4], macaddr[5]);
+		goto out_err;
+	}
+	
+	/* we're pretty sure that there's a device here, so go ahead and start
+	 * initializing memory */
+	dev = alloc_etherdev(sizeof(struct mspeth_local));
+	if (!dev)
+		goto out_err;
+
+	lp = netdev_priv(dev);
+	memset(lp, 0, sizeof(struct mspeth_local));
+
+	/* dig out the parameters from the defines and do other hwunit specific
+	 * stuff */
+	switch (hwunit) {
+		case 0:
+			dev->base_addr = MSP_MAC0_BASE;
+			dev->irq	   = MSP_INT_MAC0;
+			break;
+			
+		case 1:
+			dev->base_addr = MSP_MAC1_BASE;
+			dev->irq	   = MSP_INT_MAC1;
+			break;
+
+		case 2:
+			dev->base_addr = MSP_MAC2_BASE;
+			dev->irq	   = MSP_INT_MAC2;
+			break;
+
+		default :
+			printk(KERN_INFO " Unsupported hardware unit %d\n",hwunit);
+			goto out_err;
+	}
+	
+	/* set the logical and hardware units */
+	lp->unit	 = unit;
+	lp->hwunit   = hwunit;
+
+	/* MAC address */
+	dev->addr_len = ETH_ALEN;
+	for (i = 0; i < dev->addr_len; i++)
+		dev->dev_addr[i] = macaddr[i];
+
+	/* register the /proc entry */
+	snprintf(tmp_str,128,"pmcmspeth%d",unit);
+	create_proc_read_entry(tmp_str,0644,proc_net,mspeth_proc_info,dev);
+
+	/* set the various call back functions */
+	dev->open		= mspeth_open;
+	dev->stop		= mspeth_close;
+	dev->tx_timeout		= mspeth_tx_timeout;
+	dev->watchdog_timeo	 = TX_TIMEOUT*HZ;
+	dev->hard_start_xmit	= mspeth_send_packet;
+	dev->get_stats		= mspeth_get_stats;
+	dev->set_multicast_list = mspeth_set_multicast_list;
+
+	/* probe for PHYS attached to this MACs MDIO interface */
+	mspeth_phyprobe(dev);
+
+	/* debugging output */
+	#ifndef MODULE
+	{
+		static u8 printed_version;
+
+		if (!printed_version++) {
+			printk(KERN_INFO "%s: %s, %s\n", drv_file, drv_version, drv_reldate);
+			printk(KERN_INFO "%s: PMC-Sierra, www.pmc-sierra.com\n",drv_file);
+		}
+	}
+	#endif  /* !MODULE */
+
+	/* debugging output */
+	printk(KERN_INFO "MSPETH (probe) eth%d: found at physical address %lx, irq %d\n",
+			unit, dev->base_addr,dev->irq);
+	if (mspeth_debug > 1) {
+		printk(KERN_INFO "MSPETH (probe) eth%d: associated with hardware unit %d\n",
+				unit,hwunit);
+		printk(KERN_INFO "MSPETH (probe) eth%d: assigned MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+				unit, macaddr[0], macaddr[1], macaddr[2],
+				macaddr[3], macaddr[4], macaddr[5]);
+		printk(KERN_INFO "MSPETH (probe) eth%d: phytype %c, phyclk %c\n",
+				unit, identify_enet(hwunit),identify_enetTxD(hwunit));
+	}
+
+	err = register_netdev(dev);
+	if(err) {
+		printk("eth%d: unable to register netword device\n",unit);
+		goto out_freedev;
+	}
+
+	return 0;
+
+out_freedev:
+	kfree(dev);
+	
+out_err:
+	return err;
+}
+
+/**************************************************************************
+ * Probe the hardware and fill out the array of PHY control elements
+ */
+static int
+mspeth_phyprobe(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 reg1;
+	int phyaddr;
+	struct mspeth_phy tmp_phy;
+	struct mspeth_phy **tail_pp;
+
+	tmp_phy.next_phy = NULL;
+	tmp_phy.hwunit   = lp->hwunit;
+	tmp_phy.phyaddr  = 0;
+	tmp_phy.memaddr  = KSEG1ADDR(dev->base_addr)+MSPETH_MD_DATA;
+	tmp_phy.assigned = false;
+	tmp_phy.linkup   = false;
+	spin_lock_init(&tmp_phy.lock);
+
+	/* find the tail of the phy list */
+	for(tail_pp = &root_phy_dev; *tail_pp != NULL;
+		tail_pp = &((*tail_pp)->next_phy)) {;}
+
+	/* probe the phys and add to list */
+	for(phyaddr = 0;phyaddr < MD_MAX_PHY;phyaddr++) {
+		tmp_phy.phyaddr = phyaddr;
+		reg1 = mspphy_read(&tmp_phy,MII_BMSR);
+
+		if((reg1 & BMSR_EXISTS) && reg1 != 0xffff && reg1 != 0xc000) {
+			if (mspeth_debug > 1) {
+				printk(KERN_INFO "MSPETH (phyprobe): phyaddr = %d, hwindex = %d has phy status 0x%04x\n",
+						phyaddr,lp->hwunit,reg1);
+			}
+			*tail_pp = kmalloc(sizeof(struct mspeth_phy),GFP_KERNEL);
+			if(!*tail_pp) {
+				printk("MSPETH (phy_probe) eth%d: unable to allocate phy\n",
+						lp->hwunit);
+				return -1;
+			}
+			**tail_pp = tmp_phy;
+			spin_lock_init(&((*tail_pp)->lock));
+			tail_pp = &((*tail_pp)->next_phy);
+		}
+	}
+
+	return 0;
+}
+
+/**************************************************************************
+ * Scan the environment and fill the phyaddresses
+ */
+static void
+mspeth_init_phyaddr(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int	 	hwunit;
+	int	 	phyaddr;
+	char	*phystr;
+	char	name[80];
+
+	/* defaults */
+	lp->phyptr = NULL;
+
+	/* new style enviroment scan to determine the phy addresses */
+	sprintf(name, "phyaddr%d", lp->hwunit);
+	phystr = prom_getenv(name);
+
+	if(mspeth_debug > 0) {
+		printk("MSPETH (init_phyaddr): hwunit = %d, phystr prom = \"%s\"\n",
+				lp->hwunit,phystr);
+	}
+
+	if (phystr != NULL &&
+		sscanf(phystr, "%d:%d", &hwunit, &phyaddr) == 2 &&
+		hwunit < MSPETH_MAX_UNITS &&
+		(phyaddr < MD_MAX_PHY || phyaddr == MD_DYNAMIC_PHY))
+	{
+		/* look through the phylist and find a phy that matches the PROM
+		 * settings */
+		for(lp->phyptr = root_phy_dev; lp->phyptr != NULL;
+				lp->phyptr = lp->phyptr->next_phy) {
+			if(lp->phyptr->phyaddr == phyaddr && lp->phyptr->hwunit == hwunit) {
+				if (lp->phyptr->assigned) {
+					lp->phyptr = NULL;
+					printk(KERN_WARNING "MSPETH (init_phyaddr) %s: PROM phyaddress is already in use!\
+					phystr prom = \"%s\"\n",dev->name,phystr);
+				} else {
+					lp->phyptr->assigned = true;
+				}
+				break;
+			}
+		}
+	} else {
+		/* no acceptable PROM settings so we have to make something up */
+		if (lp->option & MSP_OPT_SWITCH) {
+			/* commandline set us to a switch so no phy settings required.
+			 * consider changing this later so that we can access the registers
+			 * in the switch through MDIO etc.  Could be autoprobed too.
+			 */
+		} else {
+			/* search through the list of phys and use the first unassigned one
+			 * We need some way of determining which phy is connected to which
+			 * MAC other than first come, first serve.
+			 * stjeanma, 2006-02-13:
+			 * -We must keep all PHYs on a global list for boards which have
+			 * all PHY MDIOs hooked to a single MAC. However for boards with 
+			 * PHYs hooked up to inidvidual MACs, we must first search the 
+			 * list for PHYs belonging to the MAC being initialized.
+			 */
+			 
+			for(lp->phyptr = root_phy_dev;lp->phyptr != NULL;
+					lp->phyptr = lp->phyptr->next_phy) {
+				if(!lp->phyptr->assigned &&
+					lp->phyptr->hwunit == lp->hwunit) {
+					lp->phyptr->assigned = true;
+					break;
+				}
+			}
+			
+			if(lp->phyptr == NULL) {
+				for(lp->phyptr = root_phy_dev;lp->phyptr != NULL;
+						lp->phyptr = lp->phyptr->next_phy) {
+					if(!lp->phyptr->assigned) {
+						lp->phyptr->assigned = true;
+						break;
+					}
+				}
+			}
+		}
+
+		/* rudimentary error checking */
+		if (phystr != NULL) {
+			printk(KERN_INFO "MSPETH (init_phyaddr) eth%d: bad phyaddr value %s\n",
+					lp->unit, phystr);
+		}
+	}
+}
+
+/**************************************************************************
+ * Scan the environment to get the kernel command line options for ethernet
+ */
+static void
+mspeth_init_cmdline(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int		index;
+	int		unit;
+	char	c = ' ';
+	char	command_line[COMMAND_LINE_SIZE];
+	char	*ptr = &command_line[0];
+	char	*ethptr = NULL;
+
+	/* default options */
+	lp->option = MSP_OPT_AUTO;
+
+	/* scan the command line looking for static configurations */
+	strcpy(command_line, prom_getcmdline());
+	while (c != '\0') {
+		if (c != ' ' || memcmp(ptr, "ip=", 3) != 0) {
+			c = *ptr++;
+			continue;
+		}
+
+		c = *ptr++;
+		index = 0;
+		unit = -1;
+
+		while (index < 8) {
+			c = *ptr++;
+
+			if (c == '\0' || c == ' ') {
+				if (index == 7) {
+					index++;
+					*--ptr = '\0';
+		 			ptr++;
+				}
+
+				break;
+			}
+
+			if (c == ':') {
+				index++;
+
+				if (index == 5) {
+					if (memcmp(ptr, "eth", 3) != 0) {
+						break;
+					}
+					
+					ethptr = &ptr[3];
+					ptr = ethptr;
+				}
+
+				if (index == 6) {
+					*--ptr = '\0';
+					ptr++;
+					unit = simple_strtol(ethptr, NULL, 0);
+				}
+
+				if (index == 7) {
+					ethptr = ptr;
+				}
+
+				if (index == 8) {
+					*--ptr = '\0';
+					ptr++;
+				}
+			}
+		}
+
+		if (index < 8 || unit < 0 || unit > MSPETH_MAX_UNITS)
+			continue;
+
+		/* check to see if this our option and parse them out */
+		if (lp->unit == unit) {
+			if (memcmp(ethptr, "100fs",5) == 0) {
+				/* 100M full-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_FDUP | MSP_OPT_SWITCH;
+			}
+			else if (memcmp(ethptr, "100hs",5) == 0) {
+				/* 100M half-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP | MSP_OPT_SWITCH;
+			}
+			else if (memcmp(ethptr, "10fs",4) == 0) {
+				/* 10M full-duplex switch */
+				lp->option = MSP_OPT_10M | MSP_OPT_FDUP | MSP_OPT_SWITCH;
+			}
+			else if (memcmp(ethptr, "10hs",4) == 0) {
+				/* 10M half-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP | MSP_OPT_SWITCH;
+			}
+			else if (memcmp(ethptr, "100f",4) == 0)
+				/* 100M full-duplex */
+				lp->option = MSP_OPT_100M | MSP_OPT_FDUP;
+			else if (memcmp(ethptr, "100h",4) == 0)
+				/* 100M half-duplex */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP;
+			else if (memcmp(ethptr, "10f",3) == 0)
+				/* 10M full-duplex */
+				lp->option = MSP_OPT_10M | MSP_OPT_FDUP;
+			else if (memcmp(ethptr, "10h",3) == 0)
+				/* 100M half-duplex */
+				lp->option = MSP_OPT_10M | MSP_OPT_HDUP;
+		}
+
+		if(mspeth_debug > 0)
+			printk(KERN_INFO "MSPETH (init_cmdline) eth%d: boot = %s, option = %02x\n",
+					lp->unit, command_line,lp->option);
+	}
+}
+
+/**************************************************************************
+ * Reset the phy
+ */
+static void
+mspeth_phy_reset(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 id0,id1;
+
+	if(lp->phyptr == NULL)
+		return;
+
+	/* reset the phy */
+	mspphy_write(lp->phyptr,MII_BMCR,BMCR_RESET);
+	while((mspphy_read(lp->phyptr,MII_BMCR) & BMCR_RESET) != 0)
+		udelay(100);
+
+	if (mspeth_debug > 0) {
+		id0 = mspphy_read(lp->phyptr, MII_PHYSID1);
+		id1 = mspphy_read(lp->phyptr, MII_PHYSID2);
+		printk(KERN_INFO "MSPETH (phy_chip_init) eth%d: PHY ID %04x %04x\n",
+			lp->unit,id0,id1);
+		printk(KERN_INFO "MSPETH (phy_chip_init) eth%d: speed = %d, duplex = %s\n",
+			lp->unit,lp->speed,(lp->fullduplex?"FULL":"HALF"));
+	}
+}
+
+/**************************************************************************
+ * Initialize the phy -- set the speed and duplex.  Wait for autonegotiation
+ * to complete.  If it doesn't then force the renegotiation.  If *that* fails
+ * then reset the phy and try again.  Finally just make some assumptions.  If
+ * autonegotiation is disabled then just force values
+ */
+static void
+mspeth_phy_init(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 ctl,neg_result;
+	int i;
+	enum {AUTONEG, AUTONEG_FORCE, PHYRESET} auto_status;
+	char *link_type;
+	char *link_stat;
+
+	/* check for defaults and autonegotiate */
+	if (lp->option == MSP_OPT_AUTO) {
+		/* make sure the autonegotiation is enabled and then wait for the
+		 * autonegotion to complete
+		 */
+		link_type = "Autoneg";
+		for(auto_status = AUTONEG;auto_status <= PHYRESET;auto_status++) {
+
+			/* run through all the various autonegotion methods until we fail */
+			switch (auto_status) {
+				case AUTONEG :
+					mspphy_write(lp->phyptr,MII_BMCR,BMCR_ANENABLE);
+					break;
+
+				case AUTONEG_FORCE :
+					printk(KERN_WARNING "MSPETH %s: Forcing autonegotiation\n",
+					  		  dev->name);
+					mspphy_write(lp->phyptr,
+							MII_BMCR,BMCR_ANENABLE | BMCR_ANRESTART);
+					break;
+
+				case PHYRESET :
+					printk(KERN_WARNING "MSPETH %s: Resetting phy\n", dev->name);
+					mspphy_write(lp->phyptr,MII_BMCR,BMCR_RESET);
+					while((mspphy_read(lp->phyptr,MII_BMCR) & BMCR_RESET) != 0)
+						udelay(100);
+					mspphy_write(lp->phyptr,
+							MII_BMCR,BMCR_ANENABLE | BMCR_ANRESTART);
+					break;
+
+				default :
+					printk(KERN_DEBUG "MSPETH %s: Unknown autonegotation mode??\n",
+							dev->name);
+					return;
+			}
+
+			/* ok.  Autoneg should be underway, so lets do the loop thingy and
+			 * wait for it to exit
+			 */
+			printk(KERN_INFO "MSPETH %s: Auto Negotiation...", dev->name);
+
+			for (i=0; i<2000 &&
+					!(mspphy_read(lp->phyptr,MII_BMSR) & BMSR_ANEGCOMPLETE);i++) {
+				mdelay(1);
+			}
+
+			if (i == 2000) {
+				/* autonegotiation failed to complete so go to next level of
+				 * negotiation.
+				 */
+				printk(" failed.\n");
+				continue;
+			}
+
+			/* must have succeeded so we can set the speed etc */
+			printk(" done.\n");
+			neg_result = mspphy_read(lp->phyptr, MII_LPA);
+			if (neg_result & (LPA_100FULL | LPA_100HALF))
+				lp->speed = 100;
+			else
+				lp->speed = 10;
+			if (neg_result & (LPA_100FULL | LPA_10FULL))
+				lp->fullduplex = true;
+			else
+				lp->fullduplex = false;
+			break;
+		}
+
+		/* check to see if *everything* failed and try to set some default
+		 * values */
+		if (auto_status > PHYRESET) {
+			printk("Autonegotion failed.  Assume 10Mbps, half-duplex\n");
+			link_type = "Autoneg (failed)";
+			lp->speed = 10;
+			lp->fullduplex = false;
+		}
+	} else {
+		/* if speed and duplex are statically configured then set that here */
+		link_type = "Static";
+		ctl = 0;
+		if (lp->option & MSP_OPT_100M) {
+			lp->speed = 100;
+			ctl |= BMCR_SPEED100;
+		 } else {
+			lp->speed = 10;
+			ctl &= ~BMCR_SPEED100;
+		}
+
+		if (lp->option & MSP_OPT_FDUP) {
+			lp->fullduplex = true;
+			ctl |= BMCR_FULLDPLX;
+		} else {
+			lp->fullduplex = false;
+			ctl &= ~BMCR_FULLDPLX;
+		}
+
+		/* stjeanma: Don't write to the PHY for a switch */
+		if (!(lp->option & MSP_OPT_SWITCH))
+			mspphy_write(lp->phyptr,MII_BMCR,ctl);
+	}
+
+	if (!(lp->option & MSP_OPT_SWITCH)) {
+		/* wait for a little bit to see if we've got a carrier -- don't
+		 * go crazy though */
+		printk(KERN_INFO "MSPETH %s: Waiting for carrier ...",dev->name);
+		for (i=0; i<1000 &&
+			!(mspphy_read(lp->phyptr, MII_BMSR) & BMSR_LSTATUS);i++) {
+			mdelay(1);
+		}
+
+		if (i == 1000) {
+			printk(" no carrier.\n");
+			lp->phyptr->linkup = false;
+			netif_carrier_off(dev);
+			link_stat = "Link down";
+		}
+		else {
+			printk(" carrier detected.\n");
+			lp->phyptr->linkup = true;
+			netif_carrier_on(dev);
+			link_stat = "Link up";
+		}
+	}
+	else {
+		/* Assume we're connected. If we're using a switch we always will be.*/
+		printk(KERN_INFO "MSPETH %s: Using internal switch\n", dev->name);
+		/* stjeanma: PHY might not be allocated for a switch */
+		if (lp->phyptr != NULL)
+			lp->phyptr->linkup = true;
+		/* stjeanma: Don't turn off the carrier for a switch
+		netif_carrier_off(dev); */
+		link_stat = "Link up";
+	}
+
+	/* configure the MAC with the duplex setting -- it doesn't care about
+	 * speed */
+	if (lp->fullduplex) {
+		msp_write(lp, MSPETH_MAC_Ctl, msp_read(lp,MSPETH_MAC_Ctl) | MAC_FullDup);
+	} else {
+		msp_write(lp, MSPETH_MAC_Ctl, msp_read(lp,MSPETH_MAC_Ctl) & ~MAC_FullDup);
+	}
+
+	printk(KERN_INFO "MSPETH %s: %s, %s, linkspeed %dMbps, %s Duplex\n",
+		dev->name, link_type, link_stat, lp->speed,
+		(lp->fullduplex) ? "Full" : "Half");
+}
+
+/**************************************************************************
+ * Check the link for a carrier when the link check timer expires.  If the
+ * link is down and it has been down for a while (at least 1 timer delay)
+ * then change the upper layer link state to match.  Do a soft-restart if
+ * we're bringing the link up.  Reschedule the timer of course.
+ */
+static void
+mspeth_link_check(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mspeth_local *lp = netdev_priv(dev);
+	enum {LINKGOOD, LINKBAD, LINKUNKNOWN} linkstatus;
+
+	/* check the current link status */
+	linkstatus = LINKUNKNOWN;
+	if (mspphy_read(lp->phyptr, MII_BMSR) & BMSR_LSTATUS) {
+		if (lp->phyptr->linkup)
+			linkstatus = LINKGOOD;
+		lp->phyptr->linkup = true;
+	} else {
+		if (!lp->phyptr->linkup)
+			linkstatus = LINKBAD;
+		lp->phyptr->linkup = false;
+	}
+
+	/* check the upper layer status */
+	if (netif_carrier_ok(dev)) {
+		/* upper layer thinks we're ok but the link is bad, so
+		 * take the link down
+		 */
+		if (linkstatus == LINKBAD) {
+			printk(KERN_INFO "%s: NO LINK DETECTED\n",dev->name);
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
+		}
+	} else {
+		/* the upper layer thinks we're broken but we've recovered so
+		 * do a soft-restart and bring the link back up
+		 */
+		if (linkstatus == LINKGOOD) {
+			printk(KERN_INFO "%s: LINK DETECTED\n",dev->name);
+			mspeth_soft_restart(dev);
+			netif_carrier_on(dev);
+		}
+	}
+
+	/* reschedule the timer */
+	lp->link_timer.expires = jiffies + HZ / LINK_DELAY_DIV;
+	add_timer(&lp->link_timer);
+}
+
+
+/**************************************************************************
+ * Reset the hardware and restore defaults.  Queues etc must be
+ * cleared afterwards, although we don't change the pointers so they don't
+ * need to be reallocated.
+ */
+static void
+mspeth_mac_reset(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int	 i;
+	u32	 rstpat;
+
+	/* hardware reset */
+	switch (lp->hwunit) {
+		case 0:
+			rstpat = MSP_EA_RST;
+			break;
+		case 1:
+			rstpat = MSP_EB_RST;
+			break;
+		case 2:
+			rstpat = MSP_EC_RST;
+			break;
+		default:
+			printk("MSPETH(mac_reset) %s: Unsupported hwunit %d\n",
+					dev->name,lp->hwunit);
+			return;
+	}
+
+	*RST_SET_REG = rstpat;
+	mdelay(100);
+	*RST_CLR_REG = rstpat;
+
+	/* Wait for the MAC to come out of reset */
+	for (i = 0; i < 10; i++) {
+		if((*RST_STS_REG & rstpat) == 0)
+			break;
+		ndelay(100);
+	}
+
+	/* initialize registers to default value */
+	msp_write(lp,MSPETH_MAC_Ctl,0);
+	msp_write(lp,MSPETH_DMA_Ctl,0);
+	msp_write(lp,MSPETH_TxThrsh,0);
+	msp_write(lp,MSPETH_TxPollCtr,0);
+	msp_write(lp,MSPETH_RxFragSize,0);
+	msp_write(lp,MSPETH_Int_En,0);
+	msp_write(lp,MSPETH_FDA_Bas,0);
+	msp_write(lp,MSPETH_FDA_Lim,0);
+	msp_write(lp,MSPETH_Int_Src,0xffffffff);	/* Write 1 to clear */
+	msp_write(lp,MSPETH_ARC_Ctl,0);
+	msp_write(lp,MSPETH_Tx_Ctl,0);
+	msp_write(lp,MSPETH_Rx_Ctl,0);
+	msp_write(lp,MSPETH_ARC_Ena,0);
+	(void)msp_read(lp,MSPETH_Miss_Cnt);	/* Read to clear */
+}
+
+
+/**************************************************************************
+ * initialize the hardware and start the DMA/MAC RX/TX.  The queues must
+ * be setup before this is called.
+ */
+static void
+mspeth_mac_init(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int flags;
+
+	/* do not interrupt me while I'm configuring the MAC */
+	local_irq_save(flags);
+
+	/* configure the BRCTL RII registers if we're an RMII device */
+	if (identify_enet(lp->hwunit) == ENET_RMII) {
+		u32 brctl = msp_read(lp,MSPETH_BCTRL_Reg) & ~RMII_Reset;
+		if (identify_enetTxD(lp->hwunit) == ENETTXD_RISING)
+			brctl |= RMII_ClkRising;
+		if (identify_enetTxD(lp->hwunit) == ENETTXD_FALLING)
+			brctl &= ~RMII_ClkRising;
+		if (lp->speed == 10)
+			brctl |= RMII_10MBIT;
+		else
+			brctl &= ~RMII_10MBIT;
+		msp_write(lp,MSPETH_BCTRL_Reg,brctl);
+	}
+
+	/* set some device structure parameters */
+	dev->tx_queue_len = TX_BUF_NUM;
+
+	/* allocate and initialize the tasklets */
+	tasklet_init(&lp->rx_tasklet,mspeth_rx,(u32)dev);
+	tasklet_init(&lp->tx_tasklet,mspeth_txdone,(u32)dev);
+	/* hammtrev, 2005/12/08:
+	 * Adding a new BH handler to reset the device in response to BLEx.
+	 */
+	tasklet_init(&lp->hard_restart_tasklet, mspeth_hard_restart_bh, (u32) dev);
+
+	/* load station address to ARC */
+	mspeth_set_arc_entry(dev, ARC_ENTRY_SOURCE, dev->dev_addr);
+
+	/* Enable ARC (broadcast and unicast) */
+	msp_write(lp,MSPETH_ARC_Ena,ARC_Ena_Bit(ARC_ENTRY_SOURCE));
+	msp_write(lp,MSPETH_ARC_Ctl,ARC_CompEn | ARC_BroadAcc);
+
+	/* configure DMA */
+	msp_write(lp,MSPETH_DMA_Ctl,DMA_CTL_CMD);
+
+	/* configure the RX/TX mac */
+	msp_write(lp,MSPETH_RxFragSize,0);
+	msp_write(lp,MSPETH_TxPollCtr,TX_POLL_CNT);
+	msp_write(lp,MSPETH_TxThrsh,TX_THRESHOLD);
+
+	/* zero and enable the interrupts */
+	lp->fatal_icnt = 0;
+	msp_write(lp,MSPETH_Int_En,INT_EN_CMD);
+
+	/* set queues */
+	/* NOTE: This needs to be checked against the documentation:
+	 * How much does (RX_BUF_NUM-1) need to be shifted over.
+	 * Andrew thinks 5, used to be 4. */
+	/* hammtrev, 2005-11-25:
+	 * Using the formula used in the old MSP4200 driver, which gives a
+	 * little bit less than (RX_BUF_NUM-1)<<5, allowing for more 
+	 * buffer descriptors attached to a frame descriptor.
+	 */
+	msp_write(lp,MSPETH_FDA_Bas,(u32)lp->rxfd_base);
+	msp_write(lp,MSPETH_FDA_Lim,(RX_BUF_NUM - 1) << 5);
+
+	/*
+	 * Activation method:
+	 * First, enable the MAC Transmitter and the DMA Receive circuits.
+	 * Then enable the DMA Transmitter and the MAC Receive circuits.
+	 */
+	msp_write(lp,MSPETH_BLFrmPtr,(u32)lp->blfd_ptr);	/* start DMA receiver */
+	msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD);		/* start MAC receiver */
+
+	msp_write(lp,MSPETH_TxFrmPtr,(u32)lp->txfd_base);	/* start the DMA transmitter */
+	msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD);	  /* start the MAC transmitter */
+
+	/* turn the interrupts back on */
+	local_irq_restore(flags);
+}
+
+/**************************************************************************
+ * start the Address Recognition circuit.  It must be initialized with
+ * address of the device (which can be changed in the PROM).
+ */
+static void
+mspeth_set_arc_entry(struct net_device *dev, int index, unsigned char *addr)
+{
+	int arc_index = index * 6;
+	unsigned long arc_data;
+	unsigned long saved_addr;
+	struct mspeth_local *lp = netdev_priv(dev);
+
+	saved_addr = msp_read(lp,MSPETH_ARC_Adr);
+
+	if (mspeth_debug > 1) {
+		int i;
+		printk(KERN_DEBUG "%s: arc %d:", cardname, index);
+		for (i = 0; i < 6; i++)
+			printk(" %02x", addr[i]);
+		printk("\n");
+	}
+	
+	if (index & 1) {
+		/* read modify write */
+		msp_write(lp,MSPETH_ARC_Adr,arc_index - 2);
+		arc_data = msp_read(lp,MSPETH_ARC_Data) & 0xffff0000;
+		arc_data |= addr[0] << 8 | addr[1];
+		msp_write(lp,MSPETH_ARC_Data,arc_data);
+
+		/* write whole word */
+		msp_write(lp,MSPETH_ARC_Adr,arc_index + 2);
+		arc_data = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) | addr[5];
+		msp_write(lp,MSPETH_ARC_Data,arc_data);
+	} else {
+		/* write whole word */
+		msp_write(lp,MSPETH_ARC_Adr,arc_index);
+		arc_data = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
+		msp_write(lp,MSPETH_ARC_Data,arc_data);
+
+		/* read modify write */
+		msp_write(lp,MSPETH_ARC_Adr,arc_index + 4);
+		arc_data = msp_read(lp,MSPETH_ARC_Data) & 0x0000ffff;
+		arc_data |= addr[4] << 24 | (addr[5] << 16);
+		msp_write(lp,MSPETH_ARC_Data,arc_data);
+	}
+
+	if (mspeth_debug > 2) {
+		int i;
+		for (i = arc_index / 4; i < arc_index / 4 + 2; i++) {
+			msp_write(lp,MSPETH_ARC_Adr,i * 4);
+			printk("arc 0x%x: %08x\n",
+					i * 4, msp_read(lp,MSPETH_ARC_Data));
+		}
+	}
+	msp_write(lp,MSPETH_ARC_Adr,saved_addr);
+}
+
+/**************************************************************************
+ * Initialize the RX/TX queues and the free buffer list.  This routine
+ * allocates memory and care must be taken to free the memory when it
+ * is no longer required
+ */
+static bool
+mspeth_queue_init(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int i,size;
+	u32 tmp_addr;
+	struct sk_buff *skb;
+
+	/* The queue structure allocates individual buffers large enough to hold
+	 * an entire packet.  There is no packing so each FD requires a single BD.
+	 * There is one Q_Desc (an FD and a BD, 16-byte aligned) for each packet
+	 * recieved and the same for each packet to transmit.  The list of free
+	 * buffers has one FD and an arbitrary number of BDs following it
+	 * (but even).  There is one BD for each RX buffer
+	 */
+
+	/* need to add some error checking here for reentry into this routine */
+	/* descriptors for the rx/tx buffers and the buffer list */
+	size = (RX_BUF_NUM+TX_BUF_NUM)*sizeof(struct Q_Desc)+sizeof(struct BL_Desc);
+
+	/* test for allocation requirements */
+	if(lp->FD_base == NULL) {
+		/* add enough margin to align to 16-byte boundary */
+		lp->FD_base = kmalloc(size+(L1_CACHE_BYTES-1),GFP_KERNEL);
+		if(lp->FD_base == NULL) {
+			printk(KERN_ERR "Cannot allocate space for MSPETH descriptors!\n");
+			return false;
+		}
+
+		/* Move frame descriptors to uncached addresses. This prevents
+		 * spurious IntBLEx interrupts. */
+		lp->FD_base = (void*)KSEG1ADDR((u32)lp->FD_base);
+
+		memset(lp->FD_base,0,size+(L1_CACHE_BYTES-1));
+		if (mspeth_debug > 1)
+			printk(KERN_INFO "MSPETH (queue_init) %s:FD_base = %p\n",
+					dev->name, lp->FD_base);
+	}
+
+	/* stjeanma, 2006-01-26:
+	 * -Fixed to add instead of subtract and take into account the
+	 * architecture's cache line size.
+	 * hammtrev, 2005-11-25:
+	 * Should this be (FD_base+15) & ~15? The formula here rounds
+	 * _down_, which could give a lower address than what's given by
+	 * kmalloc. I think we're lucky here, since kmalloc typically hands
+	 * out cache-aligned addresses anyway.
+	 */
+	tmp_addr = ((u32) lp->FD_base+(L1_CACHE_BYTES-1)) & ~(L1_CACHE_BYTES-1);
+
+	/* allocate the rx queue (aka free descriptor area) */
+	lp->rxfd_base = (struct Q_Desc *)tmp_addr;
+	lp->rxfd_curr = lp->rxfd_base;
+	tmp_addr += RX_BUF_NUM * sizeof(struct Q_Desc);
+
+	/* initialize the receive queue (these values are mostly overwritten by
+	 * the MAC) */
+	for (i=0;i<RX_BUF_NUM;i++) {
+		lp->rxfd_base[i].fd0.FDNext   = 0x00000000;
+		lp->rxfd_base[i].fd0.FDSystem = 0x00000000;
+		lp->rxfd_base[i].fd0.FDStat   = 0x00000000;
+		lp->rxfd_base[i].fd0.FDCtl	  = FD_CownsFD;
+
+		lp->rxfd_base[i].fd1.FDNext   = 0x00000000;
+		lp->rxfd_base[i].fd1.FDSystem = 0x00000000;
+		lp->rxfd_base[i].fd1.FDStat   = 0x00000000;
+		lp->rxfd_base[i].fd1.FDCtl	  = FD_CownsFD;
+	}
+
+	/* allocate the tx queue */
+	lp->txfd_base = (struct Q_Desc *)tmp_addr;
+	lp->tx_head = lp->tx_tail = 0;
+	tmp_addr += TX_BUF_NUM * sizeof(struct Q_Desc);
+
+	/* initialize the transmit queue */
+	for (i=0;i<TX_BUF_NUM;i++) {
+		lp->txfd_base[i].fd.FDNext   = (u32)(&lp->txfd_base[i+1]);
+		lp->txfd_base[i].fd.FDSystem = 0x00000000;
+		lp->txfd_base[i].fd.FDStat   = 0x00000000;
+		lp->txfd_base[i].fd.FDCtl	 = 0x00000000;
+	}
+	lp->txfd_base[TX_BUF_NUM-1].fd.FDNext   = (u32)(&lp->txfd_base[0]);
+
+	/* initialize the buffer list FD */
+	lp->blfd_ptr = (struct BL_Desc *)tmp_addr;
+	lp->blfd_ptr->fd.FDNext = (u32)lp->blfd_ptr;
+	lp->blfd_ptr->fd.FDCtl = (RX_BUF_NUM << 1 | FD_CownsFD);
+	tmp_addr += sizeof(struct BL_Desc);
+
+	/* allocate the array of sk_buff pointers */
+	if (lp->rx_skbp == NULL) {
+		lp->rx_skbp = (struct sk_buff **)kmalloc(
+				(RX_BUF_NUM << 1)*sizeof(struct sk_buff *), GFP_KERNEL);
+		for (i=0;i<RX_BUF_NUM << 1;i++)
+			lp->rx_skbp[i] = NULL;
+	}
+
+	/* allocate and initialize the actual sk_buffs proper */
+	for (i=0;i<RX_BUF_NUM << 1;i++) {
+		/* free up old sk_buffs */
+		if (lp->rx_skbp[i] != NULL) {
+			dev_kfree_skb_any(lp->rx_skbp[i]);
+			lp->rx_skbp[i] = NULL;
+		}
+
+		/* allocate and align the skb */
+		skb = mspeth_alloc_skb(dev);
+		lp->rx_skbp[i] = skb;
+
+		/* initialize the buffer list entries
+		 * reserving 2 bytes in the skb results in a 16-byte aligned 
+		 * IP header, but also puts the skb->data at a 16-bit 
+		 * boundary.  The hardware requires a 32-bit aligned buffer.
+		 * So we round back two bytes and then instruct the hardware
+		 * to skip forward 2 bytes into the buffer.
+		 */
+		lp->blfd_ptr->bd[i].BuffData = (u32)skb->data & ~15;
+		lp->blfd_ptr->bd[i].BDCtl =
+				(BD_CownsBD | (i << BD_RxBDID_SHIFT) | MSP_END_BUFSIZE);
+	}
+
+	/* configure the queue length and return */
+	atomic_set(&lp->tx_qspc,TX_BUF_NUM);
+	
+	return true;
+}
+
+
+/**************************************************************************
+ * Clear the queues of any outstanding packet.  This *will* cause packet
+ * loss, so it's a recovery mechanism.
+ */
+static void
+mspeth_clear_queues(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int i;
+	struct sk_buff *skb;
+
+	if (lp->txfd_base != NULL) {
+		for (i = 0; i < TX_BUF_NUM; i++) {
+			if (lp->txfd_base[i].fd.FDSystem != 0x00000000) {
+				skb = (struct sk_buff *)lp->txfd_base[i].fd.FDSystem;
+				dev_kfree_skb_any(skb);
+			}
+			lp->txfd_base[i].fd.FDSystem = (0x00000000);
+		}
+	}
+
+	mspeth_queue_init(dev);
+}
+
+/**************************************************************************
+ * converse of the mspeth_init_queues routine.  This frees all the memory
+ * associated with the queues.  It must be called when closing the device.
+ */
+static void
+mspeth_free_queues(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	struct sk_buff *skb;
+	int i;
+
+	/* free up any TX buffers */
+	if (lp->txfd_base != NULL) {
+		for (i = 0; i < TX_BUF_NUM; i++) {
+			if (lp->txfd_base[i].fd.FDSystem != 0x00000000) {
+				skb = (struct sk_buff *)lp->txfd_base[i].fd.FDSystem;
+				dev_kfree_skb_any(skb);
+			}
+			lp->txfd_base[i].fd.FDSystem = 0x00000000;
+		}
+	}
+
+	/* free up the buffer list */
+	if (lp->rx_skbp != NULL) {
+		for (i=0;i<RX_BUF_NUM << 1;i++) {
+			skb = lp->rx_skbp[i];
+			if (skb != NULL)
+				dev_kfree_skb_any(skb);
+		}
+		kfree(lp->rx_skbp);
+	}
+
+	/* free the descriptor area. Move FD_base back to KSEG0 before freeing it. */
+	if (lp->FD_base != NULL)
+		kfree((void*)KSEG0ADDR(lp->FD_base));
+
+	/* nullify all the pointers and zero out the queue space */
+	lp->FD_base   = NULL;
+	lp->rxfd_base = NULL;
+	lp->rxfd_curr = NULL;
+	lp->txfd_base = NULL;
+	lp->blfd_ptr  = NULL;
+	lp->rx_skbp   = NULL;
+	lp->tx_head = lp->tx_tail = 0;
+	atomic_set(&lp->tx_qspc,0);
+}
+
+/**************************************************************************
+ * Do a safe soft restart of the device.  This *will* cause packet loss, so
+ * it's only used as a recovery mechanism
+ */
+static void
+mspeth_soft_restart(struct net_device *dev)
+{
+	int flags;
+
+	printk("MSPETH (soft_restart) %s: Soft device restart\n",dev->name);
+
+	netif_stop_queue(dev);
+
+	/* please don't interrupt me while I'm resetting everything */
+	local_irq_save(flags);
+
+	/* Try to restart the adaptor. */
+	mspeth_mac_reset(dev);
+	mspeth_clear_queues(dev);
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);
+
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+	/* and start up the queue!  We should be fixed .... */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+}
+
+/**************************************************************************
+ * Do a *hard* restart of the device.  This *will* cause packet loss, so
+ * it's only used as a recovery mechanism
+ */
+static void
+mspeth_hard_restart(struct net_device *dev)
+{
+	int flags;
+
+	printk("MSPETH (hard_restart) %s: Hard device restart\n",dev->name);
+
+	netif_stop_queue(dev);
+
+	/* please don't interrupt me while I'm resetting everything */
+	local_irq_save(flags);
+
+	/* Try to restart the adaptor. */
+	mspeth_mac_reset(dev);
+	mspeth_phy_reset(dev);
+	mspeth_free_queues(dev);
+	mspeth_queue_init(dev);
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);
+
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+	/* and start up the queue!  We should be fixed .... */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+}
+
+/**************************************************************************
+ * Open/initialize the board. This is called (in the current kernel)
+ * sometime after booting when the 'ifconfig' program is run.
+ *
+ * This routine should set everything up anew at each open, even
+ * registers that "should" only need to be set once at boot, so that
+ * there is non-reboot way to recover if something goes wrong.
+ */
+static int
+mspeth_open(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	int err = -EBUSY;
+
+	/* reserve the memory region */
+	if (!request_mem_region(dev->base_addr, MSPETHSIZE, cardname)) {
+		printk(KERN_WARNING
+			"MSPETH(open) %s: unable to get memory/io address region 0x08%lx\n",
+			dev->name, dev->base_addr);
+		goto out_err;
+	}
+
+	/* remap the memory */
+	lp->mapaddr = ioremap_nocache(dev->base_addr,MSPETHSIZE);
+	if(!lp->mapaddr) {
+		printk(KERN_WARNING 
+			"MSPETH(open) %s: unable to ioremap address 0x%08lx\n",
+			dev->name,dev->base_addr);
+		goto out_unreserve;
+	}
+	
+	/* reset the hardware, disabling/clearing all interrupts */
+	mspeth_mac_reset(dev);
+	mspeth_phy_reset(dev);	
+
+	/* Allocate the IRQ */
+	if(request_irq(dev->irq, mspeth_interrupt, 0, cardname, dev)) {
+		printk(KERN_WARNING
+			"MSPETH(open) %s: unable to reserve IRQ %d\n",
+			dev->name,dev->irq);
+		goto out_unmap;
+	}
+
+	/* parse the environment and command line */
+	mspeth_init_cmdline(dev);
+	mspeth_init_phyaddr(dev);
+
+	/* determine preset speed and duplex settings */
+	if(lp->option & MSP_OPT_10M) {
+		lp->speed = 10;
+	} else {
+		lp->speed = 100;
+	}
+	if(lp->option & MSP_OPT_FDUP) {
+		lp->fullduplex = true;
+	} else {
+		lp->fullduplex = false;
+	}
+
+	/* initialize the queues and the hardware */
+	if (!mspeth_queue_init(dev)) {
+		printk(KERN_WARNING
+			"MSPETH(open) %s: Unable to allocate queues\n",
+			dev->name);
+		goto out_freeirq;
+	}
+
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);	
+
+	// stjeanma: No need to poll the link status for a switch
+	if (!(lp->option & MSP_OPT_SWITCH)) {
+		/* initialize the link check timer */
+		init_timer(&lp->link_timer);
+		lp->link_timer.expires = jiffies + HZ / LINK_DELAY_DIV;
+		lp->link_timer.data = (u32)dev;
+		lp->link_timer.function = mspeth_link_check;
+		add_timer(&lp->link_timer);
+	}
+	
+	/* and start up the queue */
+	netif_start_queue(dev);
+	return 0;
+	
+out_freeirq:
+	free_irq(dev->irq,dev);
+
+out_unmap:
+	iounmap(lp->mapaddr);
+
+out_unreserve:
+	release_mem_region(dev->base_addr, MSPETHSIZE);
+
+out_err:
+	return err;
+}
+
+/**************************************************************************
+ * The inverse routine to mspeth_open().  Close the device and clean up
+ */
+static int
+mspeth_close(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 flags;
+
+	/* please don't interrupt me while I'm shutting down everything */
+	local_irq_save(flags);
+
+	/* stop the queue & let the world know about it */
+	netif_stop_queue(dev);
+	netif_carrier_off(dev);
+
+	/* smite the link check timers */
+	del_timer_sync(&lp->link_timer);
+
+	/* Clean up the adaptor. */
+	mspeth_mac_reset(dev);
+	mspeth_phy_reset(dev);
+
+	/* free the the queue memeory */
+	mspeth_free_queues(dev);
+	
+	/* free up the resources */
+	free_irq(dev->irq,dev);	
+	iounmap(lp->mapaddr);
+	release_mem_region(dev->base_addr, MSPETHSIZE);
+	
+	/* deassign the phy */
+	/* stjeanma: PHY might not be allocated for a switch */
+	if (lp->phyptr != NULL)
+		lp->phyptr->assigned = false;
+	
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+	return 0;
+}
+
+/**************************************************************************
+ * The typical workload of the driver:
+ *   Handle the network interface interrupts.
+ */
+static irqreturn_t
+mspeth_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 status;
+
+	if (unlikely(dev == NULL)) {
+		printk(KERN_WARNING "%s: irq %d for unknown device.\n", cardname, irq);
+		return IRQ_NONE;
+	}
+
+	/* stjeanma, 2006-02-08:
+	 * - This read flushes the dma queue in addition to obtaining status */
+	status = msp_read(lp,MSPETH_Int_Src);
+
+	/* acknowledge the interrupts and check for null entry */
+	if (unlikely(status == 0))
+		return IRQ_HANDLED;
+	else
+		msp_write(lp,MSPETH_Int_Src,status);
+
+	/* collect debugging stats */
+	if (status & IntSrc_MacRx)
+		lp->lstats.rx_ints++;
+
+	if (status & IntSrc_MacTx)
+		lp->lstats.tx_ints++;
+
+
+	/* handle most likely cases first */
+	/* hammtrev, 2005-11-25:
+	 * Should we be disabling more than just Rx_EnGood? */
+	if (likely(status == IntSrc_MacRx)) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD & ~Rx_EnGood);
+		tasklet_schedule(&lp->rx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	if (likely(status == IntSrc_MacTx)) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	if (likely(status == (IntSrc_MacTx | IntSrc_MacRx))) {
+		/* disable interrupts and schedule tasklets */
+		msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD & ~Rx_EnGood);
+		msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+		tasklet_schedule(&lp->rx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	/* all other combined cases */
+	if (status & IntSrc_MacRx) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD & ~Rx_EnGood);
+		tasklet_schedule(&lp->rx_tasklet);
+	}
+
+	if (status & IntSrc_MacTx) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+	}
+
+	/* recoverable errors */
+	if (status & IntSrc_FDAEx) {
+		/* disable FDAEx int. (until we make room...) */
+		msp_write(lp,MSPETH_Int_En,INT_EN_CMD & ~IntEn_FDAEx);
+		lp->lstats.fd_exha++;
+		lp->stats.rx_dropped++;
+	}
+
+	/* Some boards generate a link state interrupt on power-up. We don't
+	* know why, but ACK it and it will go away.
+	*		  -- hammtrev, 2005/08/30
+	*/
+	if (status & IntSrc_Link_St) {
+		msp_write(lp, MSPETH_MAC_Ctl, msp_read(lp,MSPETH_MAC_Ctl) | MAC_LnkChg);
+	}
+
+	/* and now all the wacky unrecoverable fatal error conditions
+	 * this includes BLEx errors since we can *never* have one -- if we
+	 * do, it indicates that there is some sort of queue corruption.
+	 */
+	if (status & FATAL_ERROR_INT) {
+		/* Disable further interrupts until device reset. */
+		msp_write(lp, MSPETH_DMA_Ctl, msp_read(lp, MSPETH_DMA_Ctl) | DMA_IntMask);
+		/* this one may be overkill... */
+		msp_write(lp, MSPETH_MAC_Ctl, msp_read(lp,MSPETH_MAC_Ctl) | MAC_HaltImm);
+		mspeth_fatal_error_interrupt(dev, status);
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**************************************************************************
+ * fatal error interrupts reset the entire device but they don't require
+ * reallocating the queues, just clearing them
+ */
+
+static void
+mspeth_fatal_error_interrupt(struct net_device *dev, int status)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+
+	printk(KERN_WARNING "MSPETH(fatal_error) %s: Fatal Error Interrupt (0x%08x):",
+		   dev->name, status);
+
+	if (status & IntSrc_DmParErr)
+		printk(" DmParErr");
+	if (status & IntSrc_NRAB)
+		printk(" IntNRAB");
+	if (status & IntSrc_BLEx)
+		printk(" IntBLEx");
+	printk("\n");
+
+	/* panic if it gets too crazy */
+	if (lp->fatal_icnt++ > 100)
+		panic("MSPETH(fatal_error) %s: too many fatal errors.\n", dev->name);
+
+	/* Dump our descriptors, if desired */
+	if (mspeth_debug > 0) {
+		mspeth_dump_queues(dev);
+		mspeth_dump_stats(dev);
+	}
+
+	/* Try to restart the adaptor. */
+	/* hammtrev, 2005/12/08:
+	 * This is too much work for a top-half interrupt handler, and
+	 * may result in unexpected race conditions with other tasklets.
+	 * Now deferring the device reset to a bottom-half tasklet, to
+	 * allow any currently-running tasklet to complete without unexpected
+	 * changes to frame/buffer descriptors, etc.
+	 */
+	/* mspeth_hard_restart(dev); */
+	tasklet_schedule(&lp->hard_restart_tasklet);
+}
+
+/**************************************************************************
+ * Handle deferred processing of the IntBLEx interrupt.
+ */
+static void mspeth_hard_restart_bh(unsigned long devaddr)
+{
+	struct net_device *dev = (struct net_device *)devaddr;
+	
+	printk(KERN_WARNING "MSPETH(fatal_error) %s: restarting device\n",
+		   dev->name);
+	mspeth_hard_restart(dev);
+}
+
+/**************************************************************************
+ * process a single RX packet, including sending it up the stack and
+ * reallocating the buffer.  Return the next buffer in the RX queue.
+ * This routine assumes that the current FD pointed to by rxfd_curr
+ * has been invalidated with the cache and is current with main memory
+ */
+static struct Q_Desc *
+mspeth_rx_onepkt(struct net_device *dev) {
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 status;
+	struct Q_Desc *next_rxfd;
+	int bdnum,len;
+	struct sk_buff *skb;
+	unsigned char *data;
+
+	/* collect all the relevent information */
+	status = lp->rxfd_curr->fd.FDStat;
+	len = lp->rxfd_curr->bd.BDCtl & BD_BuffLength_MASK;
+	len -= 4; /* Drop the FCS from the length */
+	bdnum = (lp->rxfd_curr->bd.BDCtl & 0x00FF0000) >> BD_RxBDID_SHIFT;
+
+	if (mspeth_debug > 2)
+		printk("%s: RxFD.\n", dev->name);
+	if (mspeth_debug > 3)	
+		dump_qdesc(lp->rxfd_curr);
+
+#ifdef MSPETH_DUMP_QUEUES
+	if (mspeth_debug > 2 &&
+			(!bdnum && (rx_bdnums[lp->unit][rx_bdnums_ind[lp->unit]]
+				!= ((RX_BUF_NUM << 1)-1))))
+		dump_qdesc(lp->rxfd_curr);
+	catalog_rx_bdnum(lp->unit,bdnum);
+#endif /* MSPETH_DUMP_QUEUES */
+
+	/* the packet has been received correctly so prepare to send it up
+	 * the stack */
+	if (likely(status & Rx_Good)) {
+		skb = lp->rx_skbp[bdnum];
+		data = (unsigned char *)skb->data;
+
+		/* basic non-interleaved buffer processing */
+		invalidate_buffer(skb->data,len);
+
+		/* allocate a new buffer to replace it */
+		lp->rx_skbp[bdnum] = mspeth_alloc_skb(dev);
+
+		/* if a replacement buffer can be allocated then send the skb up
+		 * the stack otherwise we drop the packet and reuse the existing buffer
+		 */
+		if (likely(lp->rx_skbp[bdnum] != NULL)) {
+			/* complete the skb and send it up the stack */
+			skb_put(skb,len);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
+			dev->last_rx = jiffies;
+
+			lp->stats.rx_packets++;
+			lp->stats.rx_bytes += len;
+
+			if (mspeth_debug > 4) {
+				print_eth(1,data,len);
+				if(mspeth_debug > 5) {
+					print_buf(skb->data, len);
+				}
+			}
+		} else {
+			printk(KERN_NOTICE "MSPETH(rx) %s: Memory squeeze, dropping packet.\n",
+				   dev->name);
+			lp->rx_skbp[bdnum] = skb;
+			lp->stats.rx_dropped++;
+		}
+
+		/* Do the rounding for the 32-bit data alignment */
+		lp->blfd_ptr->bd[bdnum].BuffData =
+				(u32)lp->rx_skbp[bdnum]->data & ~15;
+		read_addr_blocking(&lp->blfd_ptr->bd[bdnum].BuffData);
+	} else {
+		lp->stats.rx_errors++;
+		/* WORKAROUND: LongErr and CRCErr means Overflow. */
+		if ((status & Rx_LongErr) && (status & Rx_CRCErr)) {
+			status &= ~(Rx_LongErr|Rx_CRCErr);
+			status |= Rx_Over;
+		}
+		if (status & Rx_LongErr)
+			lp->stats.rx_length_errors++;
+		if (status & Rx_Over)
+			lp->stats.rx_fifo_errors++;
+		if (status & Rx_CRCErr)
+			lp->stats.rx_crc_errors++;
+		if (status & Rx_Align)
+			lp->stats.rx_frame_errors++;
+	}
+
+	/* allocate buffer & FD back to controller */
+	lp->blfd_ptr->bd[bdnum].BDCtl =
+			(BD_CownsBD | (bdnum << BD_RxBDID_SHIFT) | MSP_END_BUFSIZE);
+	read_addr_blocking(&lp->blfd_ptr->bd[bdnum].BDCtl);
+
+	next_rxfd = (struct Q_Desc *)lp->rxfd_curr->fd.FDNext;
+
+	/* Return Q_Desc to the controller. Setting fd0.FDCtl last prevents
+	 * the controller from using this Q_Desc until we're done.
+	 */
+	 
+	/* writeback the changes back to the RAM so that MAC can see the
+	 * available buffers on a write-through cache this doesn't really
+	 * do anything, but on a writeback cache this is quite important .....
+	 * 
+	 * stjeanma, 2006-02-08:
+	 * -Uncached writes need to be read back to ensure they reach RAM.
+	 */
+	lp->rxfd_curr->fd0.FDNext = 0;
+	lp->rxfd_curr->fd0.FDSystem = 0;
+	lp->rxfd_curr->fd0.FDStat = 0;
+	lp->rxfd_curr->fd1.FDNext = 0;
+	lp->rxfd_curr->fd1.FDSystem = 0;
+	lp->rxfd_curr->fd1.FDStat = 0;
+	lp->rxfd_curr->fd1.FDCtl = FD_CownsFD;
+	lp->rxfd_curr->fd0.FDCtl = FD_CownsFD;
+	read_addr_blocking(&lp->rxfd_curr->fd0.FDNext);
+	read_addr_blocking(&lp->rxfd_curr->fd0.FDSystem);
+	read_addr_blocking(&lp->rxfd_curr->fd0.FDStat);
+	read_addr_blocking(&lp->rxfd_curr->fd1.FDNext);
+	read_addr_blocking(&lp->rxfd_curr->fd1.FDSystem);
+	read_addr_blocking(&lp->rxfd_curr->fd1.FDStat);
+	read_addr_blocking(&lp->rxfd_curr->fd1.FDCtl);
+	read_addr_blocking(&lp->rxfd_curr->fd0.FDCtl);
+ 
+	return next_rxfd;
+}
+
+/**************************************************************************
+ * a packet has been received so shove it up the network stack and
+ * allocate another buffer for reception. Called by the rx_tasklet which
+ * is scheduled by the interrupt handler.
+ */
+static void
+mspeth_rx(unsigned long devaddr)
+{
+	struct net_device *dev = (struct net_device *)devaddr;
+	struct mspeth_local *lp = netdev_priv(dev);
+	u32 status;
+	int rx_cnt;
+
+	/* make sure the memory queue is flushed and the cache is invalidated
+	 * this is only really important in the case where we have a single
+	 * packet to process otherwise the packet at the head of the queue will
+	 * *certainly* be flushed from the memory queue.  We don't need to
+	 * flush the DMA queue since the ISR that scheduled this routine
+	 * will have done it already.
+	 */
+	flush_memqueue();
+
+	/* loop around processing the rx packet queue
+	 * this should be adjusted to process a maximum number of packets, or
+	 * perhaps insert a call to "schedule" within it so that it doesn't
+	 * monopolize the CPU
+	 */
+	for(rx_cnt = 0; rx_cnt < RX_MAX_PKT &&
+					!(lp->rxfd_curr->fd.FDCtl & FD_CownsFD); rx_cnt++) {
+		/* process the current packet and move to the next frame descriptor */
+		lp->rxfd_curr = mspeth_rx_onepkt(dev);
+	}
+
+	/* re-enable FDA Exhausted interupts 'cause there's room now */
+	if (rx_cnt > 0) {
+		msp_write(lp,MSPETH_Int_En,INT_EN_CMD);
+	}
+
+	/* check to see if there is an unprocessed packet -- reschedule if so */
+	/* hammtrev, 2005-12-16:
+	 * We should flush the memory queue and invalidate the cache lines
+	 * before re-examining the current rxfd */
+	flush_memqueue();
+
+	if (!(lp->rxfd_curr->fd.FDCtl & FD_CownsFD)) {
+		tasklet_schedule(&lp->rx_tasklet);
+	} else {
+		/* re-enable the RX completion interrupt and check to see if there is
+		 * an outstanding interrupt
+		 */
+		msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD);
+		status = msp_read(lp,MSPETH_Int_Src);
+
+		/* if there is an outstanding RX interrupt, then reschedule the routine */
+		if (status & IntSrc_MacRx) {
+			/* ack the interrupt, disable it and reschedule */
+			msp_write(lp,MSPETH_Int_Src,IntSrc_MacRx);
+			msp_write(lp,MSPETH_Rx_Ctl,RX_CTL_CMD & ~Rx_EnGood);
+			tasklet_schedule(&lp->rx_tasklet);
+		}
+	}
+}
+
+/**************************************************************************
+ * basic transmit function -- called from the upper network layers
+ */
+static int
+mspeth_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	struct Q_Desc *txfd_ptr;
+
+	/*************************************************************************
+	 * note that if we cannot transmit then we must return 1 and *not touch*
+	 * the skb since it doesn't belong to us.  The networking layer above will
+	 * take care of it.
+	 *************************************************************************
+	 */
+
+	/* Don't take drastic action right away if the queue is stopped, but if its
+	 * been that way for quite a while we'll attempt to restart the adatper
+	 */
+	if (netif_queue_stopped(dev)) {
+		/*
+		 * If we get here, some higher level has decided we are broken.
+		 * There should really be a "kick me" function call instead.
+		 */
+		int tickssofar = jiffies - dev->trans_start;
+		if (tickssofar < 5) {
+			printk(KERN_WARNING "MSPETH(send_packet) %s: queue stopped ...\n",
+					dev->name);
+			return 1;
+		}
+
+		printk(KERN_WARNING "MSPETH(send_packet) %s: transmit timed out, restarting adaptor.  TX_Status =  %08x\n",
+			   dev->name, msp_read(lp,MSPETH_Tx_Stat));
+
+		/* do a hard restart and return */
+		mspeth_hard_restart(dev);
+		return 1;
+	}
+
+	/* protect access to the transmit queue with the atomic queue space
+	 * variable */
+	if(atomic_read(&lp->tx_qspc) == 0) {	/* no room on queue for another packet */
+		lp->lstats.tx_full++;
+		netif_stop_queue(dev);
+		return 1;
+	}
+
+	/* we have room, so get the next availabe tx FD */
+	txfd_ptr = &(lp->txfd_base[lp->tx_head]);
+	lp->tx_head = (lp->tx_head + 1) & TX_BUF_MASK;
+
+	lp->stats.tx_bytes += skb->len;
+
+	/* stjeanma, 2006-02-08:
+	 * -Uncached writes need to be read back to ensure they reach RAM.
+	 */
+	txfd_ptr->bd.BuffData = (u32)skb->data;
+	txfd_ptr->bd.BDCtl = skb->len;
+	txfd_ptr->fd.FDSystem = (u32)skb;
+	txfd_ptr->fd.FDCtl = (FD_CownsFD | (1 << FD_BDCnt_SHIFT));
+	read_addr_blocking(&txfd_ptr->bd.BuffData);
+	read_addr_blocking(&txfd_ptr->bd.BDCtl);
+	read_addr_blocking(&txfd_ptr->fd.FDSystem);
+	read_addr_blocking(&txfd_ptr->fd.FDCtl);
+
+	/* writeback the cache and flush the sdram queue */
+	writeback_buffer(skb->data,skb->len);
+	
+	/* one more packet on the TX queue */
+	atomic_dec(&lp->tx_qspc);
+
+	if (mspeth_debug > 4) {
+		print_eth(0,(unsigned char *)skb->data,skb->len);
+		if(mspeth_debug > 5) {
+			print_buf(skb->data, skb->len);
+		}
+	}
+
+	/* wake up the transmitter */
+	msp_write(lp,MSPETH_DMA_Ctl,DMA_CTL_CMD | DMA_TxWakeUp);
+
+	dev->trans_start = jiffies;
+
+	return 0;
+}
+
+/**************************************************************************
+ * Free the buffers which have been transmitted from the transmit queue.
+ * Called from the tx_tasklet which is scheduled by the interrupt handler
+ */
+static void
+mspeth_txdone(unsigned long devaddr)
+{
+	struct net_device *dev = (struct net_device *)devaddr;
+	struct mspeth_local *lp = netdev_priv(dev);
+	struct Q_Desc *txfd_ptr;
+	int num_done = 0;
+	u32 status;
+	
+	/* walk the queue until we come to the end or a buffer we don't control
+	 * we don't worry much about leaving a buffer or two on the tx queue; we'll
+	 * get to them later and if we're busy then we'll get to them RSN.
+	 * stjeanma, 2006-02-08:
+	 * -Flush the MAC queued updates
+	 */
+	txfd_ptr = &(lp->txfd_base[lp->tx_tail]);
+	flush_memqueue();
+
+	while (atomic_read(&lp->tx_qspc) < TX_BUF_NUM &&
+			!(txfd_ptr->fd.FDCtl & FD_CownsFD)) {
+		struct sk_buff *skb;
+		status = txfd_ptr->fd.FDStat;
+
+		if (mspeth_debug > 2)
+			printk("%s: TxFD done.\n", dev->name);
+		if (mspeth_debug > 3)
+			dump_qdesc(txfd_ptr);
+		
+		mspeth_check_tx_stat(dev, status);
+
+		/* free the current socket buffer and change ownership of the
+		 * TX descriptor.
+		 * 
+		 * hammtrev, 2005/12/08:
+		 * We are seeing the occasional "kfree_skb passed an skb still
+		 * on a list" errors in response to IntBLEx events.
+		 * Could freeing the skb before zeroing the FDSystem field
+		 * be causing a race condition (ie, what if the IntBLEx
+		 * occurs after, or in the middle of, dev_kfree_skb_any and
+		 * before FDSystem=0???
+		 * Moving the kfree_skb call after the txfd ops; we'll see
+		 * if we get anymore panics during a lengthy test.
+		 */
+		 
+		/* writeback the change to RAM so that the controller can see them
+		 * 
+		 * stjeanma, 2006-02-08:
+		 * -Uncached writes need to be read back to ensure they reach RAM.
+		 */
+		skb = (struct sk_buff *)(txfd_ptr->fd.FDSystem);
+		txfd_ptr->fd.FDSystem = 0x00000000;
+		txfd_ptr->fd.FDCtl	= 0x00000000;
+		read_addr_blocking(&txfd_ptr->fd.FDSystem);
+		read_addr_blocking(&txfd_ptr->fd.FDCtl);
+
+		if (skb != NULL) {
+			dev_kfree_skb_any(skb);
+		}
+		
+		/* advance to the next TX descriptor */
+		atomic_inc(&lp->tx_qspc);
+		num_done++;
+		lp->tx_tail = (lp->tx_tail + 1) & TX_BUF_MASK;
+		txfd_ptr = &(lp->txfd_base[lp->tx_tail]);
+		flush_memqueue();
+	}
+
+	/* If we freed at least one buffer and the queue is stopped then restart it. */
+	if (num_done > 0 && netif_queue_stopped(dev))
+		netif_wake_queue(dev);
+
+	/* re-enable interrupts regardless */
+	msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD);
+
+	/* Check for outstanding packets */
+	status = msp_read(lp,MSPETH_Int_Src);
+
+	/* If we have an outstanding packet, reschedule the tasklet */
+	if (status & IntSrc_MacTx) {
+		/* ack interrupt, disable it, and reschedule */
+		msp_write(lp,MSPETH_Int_Src,IntSrc_MacTx);
+		msp_write(lp,MSPETH_Tx_Ctl,TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+	}
+}
+
+/**************************************************************************
+ * if there is a timeout we soft restart the entire device
+ */
+static void
+mspeth_tx_timeout(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	printk(KERN_WARNING "MSPETH(tx_timeout) %s: transmit timed out, status 0x%08x\n",
+		   dev->name, msp_read(lp,MSPETH_Tx_Stat));
+
+	/* try to restart the adaptor */
+	mspeth_soft_restart(dev);
+}
+
+/**************************************************************************
+ * debugging code to dump out the transmit status register
+ */
+/* hammtrev, 2005-11-25:
+ * The Tx_NCarr condition makes a lot of noise on the PMC Gateway, but
+ * doesn't seem to affect the success of transmissions. Removing for now.
+ * Note: The old MSP4200 driver also ignored Tx_NCarr.
+ */
+#define TX_STA_ERR (Tx_ExColl|Tx_Under|Tx_Defer|Tx_LateColl|Tx_TxPar|Tx_SQErr)
+static void
+mspeth_check_tx_stat(struct net_device *dev, int status)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	const char *msg = NULL;
+
+	/* count collisions */
+	if (status & Tx_ExColl)
+		lp->stats.collisions += 16;
+	if (status & Tx_TxColl_MASK)
+		lp->stats.collisions += status & Tx_TxColl_MASK;
+
+	/* WORKAROUND: ignore LostCrS when there is no carrier .... */
+	if (!netif_carrier_ok(dev))
+		status &= ~Tx_NCarr;
+
+	if (likely(!(status & TX_STA_ERR))) {
+		/* no error. */
+		lp->stats.tx_packets++;
+		return;
+	}
+
+	lp->stats.tx_errors++;
+	if (status & Tx_ExColl) {
+		lp->stats.tx_aborted_errors++;
+		msg = "Excessive Collision.";
+	}
+	if (status & Tx_Under) {
+		lp->stats.tx_fifo_errors++;
+		msg = "Tx FIFO Underrun.";
+	}
+	if (status & Tx_Defer) {
+		lp->stats.tx_fifo_errors++;
+		msg = "Excessive Deferral.";
+	}
+#if 0
+	if (status & Tx_NCarr) {
+		lp->stats.tx_carrier_errors++;
+		msg = "Lost Carrier Sense.";
+	}
+#endif
+	if (status & Tx_LateColl) {
+		lp->stats.tx_aborted_errors++;
+		msg = "Late Collision.";
+	}
+	if (status & Tx_TxPar) {
+		lp->stats.tx_fifo_errors++;
+		msg = "Transmit Parity Error.";
+	}
+	if (status & Tx_SQErr) {
+		lp->stats.tx_heartbeat_errors++;
+		msg = "Signal Quality Error.";
+	}
+	if (msg)
+		printk(KERN_WARNING "MSPETH(check_tx_stats) %s: %s (%#x)\n",
+				dev->name, msg, status);
+}
+
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *
+mspeth_get_stats(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	if (netif_running(dev)) {
+		local_irq_save(flags);
+		/* Update the statistics from the device registers. */
+		lp->stats.rx_missed_errors = msp_read(lp,MSPETH_Miss_Cnt);
+		local_irq_restore(flags);
+	}
+
+	return &lp->stats;
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ * num_addrs == -1	Promiscuous mode, receive all packets
+ * num_addrs == 0	Normal mode, clear multicast list
+ * num_addrs > 0	Multicast mode, receive normal and MC packets,
+ *			and do best-effort filtering.
+ */
+static void
+mspeth_set_multicast_list(struct net_device *dev)
+{
+	struct mspeth_local *lp = netdev_priv(dev);
+
+	if (dev->flags&IFF_PROMISC)
+	{
+		/* Enable promiscuous mode */
+		msp_write(lp,MSPETH_ARC_Ctl,
+				ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc | ARC_StationAcc);
+	}
+	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > ARC_ENTRY_MAX - 3)
+	{
+		/* ARC 0, 1, 20 are reserved. */
+		/* Disable promiscuous mode, use normal mode. */
+		msp_write(lp,MSPETH_ARC_Ctl,ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc);
+	}
+	else if(dev->mc_count)
+	{
+		struct dev_mc_list* cur_addr = dev->mc_list;
+		int i;
+		int ena_bits = ARC_Ena_Bit(ARC_ENTRY_SOURCE);
+
+		msp_write(lp,MSPETH_ARC_Ctl,0);
+		/* Walk the address list, and load the filter */
+		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+			if (!cur_addr)
+				break;
+				
+			/* entry 0,1 is reserved. */
+			mspeth_set_arc_entry(dev, i + 2, cur_addr->dmi_addr);
+			ena_bits |= ARC_Ena_Bit(i + 2);
+		}
+		msp_write(lp,MSPETH_ARC_Ena,ena_bits);
+		msp_write(lp,MSPETH_ARC_Ctl,ARC_CompEn | ARC_BroadAcc);
+	}
+	else {
+		msp_write(lp,MSPETH_ARC_Ena,ARC_Ena_Bit(ARC_ENTRY_SOURCE));
+		msp_write(lp,MSPETH_ARC_Ctl,ARC_CompEn | ARC_BroadAcc);
+	}
+}
+
+static int
+mspeth_proc_info(char *buf, char **bloc, off_t off, int length, int *eof, void *data)
+{
+	int len = 0;
+	int i,cnt;
+	struct net_device *dev = (struct net_device *)data;
+	struct mspeth_local *lp = netdev_priv(dev);
+
+	/* finished reading regardless of anything else */
+	if(off > 0)
+		return 0;
+
+	len += sprintf(buf, "MSPETH hwunit %d statistics:\n",lp->hwunit);
+	len += sprintf(buf + len,
+		"%s: tx_ints %d, rx_ints %d, max_tx_qlen %d, tx_full %d, fd_exha %d\n",
+		dev->name,
+		lp->lstats.tx_ints,
+		lp->lstats.rx_ints,
+		lp->lstats.max_tx_qlen,
+		lp->lstats.tx_full,
+		lp->lstats.fd_exha);
+	len += sprintf(buf + len, "    FD_base = %p\n",lp->FD_base);
+	len += sprintf(buf + len, "    rxfd_base = %p, rxfd_curr = %p\n",
+		lp->rxfd_base, lp->rxfd_curr);
+
+	if (lp->rxfd_base != NULL) {
+		cnt = 0;
+		for(i=0;i<RX_BUF_NUM;i++) {
+			if(rd_nocache(lp->rxfd_base[i].fd.FDCtl) & FD_CownsFD)
+				cnt++;
+		}
+		len += sprintf(buf + len,"        Controller FD count = %d\n",cnt);
+	}
+	len += sprintf(buf + len, "    tx_base = %p, tx_head = %d, tx_tail = %d, qspc = %d\n",
+			lp->txfd_base, lp->tx_head, lp->tx_tail,atomic_read(&lp->tx_qspc));
+	len += sprintf(buf + len, "    blfd_ptr = %p, rx_skbp = %p\n\n",
+			lp->blfd_ptr, lp->rx_skbp);
+	len += sprintf(buf + len, "    pause sent: %d, pause recv: %d\n\n",
+			    msp_read(lp,MSPETH_PauseCnt), msp_read(lp,MSPETH_RemPauCnt));
+
+	return len;
+}
+
+
+
+
+/* platform device stuff for linux 2.6 */
+
+static char mspeth_string[] = "mspeth";
+static struct platform_device *mspeth_device[MSPETH_MAX_UNITS];
+
+static struct device_driver mspeth_driver = {
+	.name   = mspeth_string,
+	.bus    = &platform_bus_type,
+	.probe  = mspeth_probe,
+	/*.remove = __devexit_p(mspeth_device_remove),
+	 * stjeanma, 2006-05-01:
+	 * Must define an actual function when MODULE or CONFIG_HOTPLUG
+	 * are enabled in the configuration. Since we don't occupy PCI
+	 * or other I/O space we don't need to implement immediately.  */
+};
+
+
+static void mspeth_platform_release (struct device *device)
+{
+	struct platform_device *pldev;
+
+	/* free device */
+	pldev = to_platform_device (device);
+	kfree (pldev);
+}
+
+/*
+ * Register the mspeth with the kernel
+ */
+static int __init mspeth_init_module(void)
+{
+	struct platform_device *pldev;
+	int i;
+
+	printk(KERN_NOTICE
+		   "PMC-Sierra MSPETH 10/100 Ethernet Driver \n");
+
+	if (driver_register(&mspeth_driver)) {
+		printk(KERN_ERR "Driver registration failed\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < MSPETH_MAX_UNITS; i++) {
+		mspeth_device[i] = NULL;
+
+		if (!(pldev = kmalloc(sizeof(*pldev), GFP_KERNEL)))
+			continue;
+
+		memset (pldev, 0, sizeof (*pldev));
+		pldev->name		 = mspeth_string;
+		pldev->id		   = i;
+		pldev->dev.release	  = mspeth_platform_release;
+		mspeth_device[i]	  = pldev;
+
+		if (platform_device_register(pldev)) {
+			kfree (pldev);
+			mspeth_device[i] = NULL;
+			continue;
+		}
+
+		if (!pldev->dev.driver) {
+			/*
+			 * The driver was not bound to this device, there was
+			 * no hardware at this address. Unregister it, as the
+			 * release function will take care of freeing the
+			 * allocated structure
+			 */
+			mspeth_device[i] = NULL;
+			platform_device_unregister (pldev);
+		}
+	}
+
+	return 0;
+}
+
+/*
+ * Unregister the mspeth from the kernel
+ */
+static void __exit mspeth_cleanup_module(void)
+{
+	int i;
+
+	driver_unregister(&mspeth_driver);
+
+	for (i = 0; i < 3; i++) {
+		if (mspeth_device[i]) {
+			platform_device_unregister(mspeth_device[i]);
+			mspeth_device[i] = NULL;
+		}
+	}
+}
+
+MODULE_AUTHOR("Andrew Hughes <Andrew_Hughes@pmc-sierra.com>");
+MODULE_DESCRIPTION("PMC MSP Ethernet driver");
+MODULE_LICENSE("GPL");
+
+module_init(mspeth_init_module);
+module_exit(mspeth_cleanup_module);
diff --git a/drivers/net/pmcmspeth.h b/drivers/net/pmcmspeth.h
new file mode 100644
index 0000000..75a54b5
--- /dev/null
+++ b/drivers/net/pmcmspeth.h
@@ -0,0 +1,545 @@
+/******************************************************************
+ * Copyright 2005 PMC-Sierra, Inc
+ *
+ * PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND
+ * FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS
+ * SOFTWARE.
+ */
+
+/***********************************************************************
+ *  pmcmspeth.h :  PMC-Sierra MSP EVM ethernet driver for linux
+ * 
+ * Originally based on mspeth.c driver which contains substantially the
+ * same hardware. 
+ * Based on skelton.c by Donald Becker.
+ * ported by Andrew Hughes, Andrew_Hughes@pmc-sierra.com
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
+ * WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
+ * NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
+ * USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
+ * ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * You should have received a copy of the  GNU General Public License along
+ * with this program; if not, write  to the Free Software Foundation, Inc.,
+ * 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+ 
+#ifndef _MSPETH_H_
+#define _MSPETH_H_
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/interrupt.h>
+#include <linux/ptrace.h>
+#include <linux/ioport.h>
+#include <linux/in.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+
+#include <asm/bootinfo.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <asm/io.h>
+#include <asm/dma.h>
+#include <asm/byteorder.h>
+#include <asm/delay.h>
+#include <asm/r4kcache.h>
+#include <asm/cpu-features.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+#include <linux/delay.h>
+#include <linux/proc_fs.h>
+#include <linux/mii.h>
+
+#include <msp_regs.h>
+
+/**************************************************************************
+ * Device constants for our various types of MSP chips
+ */
+#define MSPETH_MAX_UNITS (3)
+#define STDETH_MAX_UNITS (8)
+
+/**************************************************************************
+ * Tuning parameters
+ */
+#define DMA_BURST_SIZE	32      /* maximum burst size for the DMA transfers */
+#define TX_TIMEOUT      (1)     /* time (in seconds) for the TX timeout */
+#if defined(CONFIG_PMC_MSP7120_EVAL) \
+ || defined(CONFIG_PMC_MSP7120_GW) \
+ || defined(CONFIG_PMC_MSP7120_FPGA)
+#define TX_THRESHOLD	100     /* MAC TX fifo depth before we start sending */
+#else
+#define TX_THRESHOLD	1000    /* MAC TX fifo depth before we start sending */
+#endif
+#define TX_POLL_CNT     0       /* interval for the TX poll mechanism -- not used, leave at zero */
+#define LINK_DELAY_DIV  4		/* delay for checking the link status */
+#define RX_MAX_PKT      16      /* maximum number of packet the RX handler will process at one time */
+
+/* define the RX/TX buffer counts.  Notice that they *must* be <= 256 and also
+ * a power of two.  So much so that we test for it at compile time and set the order 
+ * of the queue lengths instead of the numbers directly
+ */
+#define RX_BUF_ORDER 5		/* 32 buffers */
+#define TX_BUF_ORDER 5		/* 32 buffers */
+
+/* use 0 for production, 1 for verification, >2 for debug */
+#ifndef MSPETH_DEBUG
+#define MSPETH_DEBUG 0
+#endif
+
+/* These values were used in MSP4200 driver */
+#define MAX_PKT_SIZE		1532
+#define MSP_END_PREPEND		224
+#define MAX_ETH_BUFFER_SIZE	(MAX_PKT_SIZE + MSP_END_PREPEND)
+#define MSP_END_BUFSIZE		(MAX_ETH_BUFFER_SIZE + 24)
+/*#define MAX_ETH_BUFFER_SIZE	1552*/
+
+/**************************************************************************
+ * Option defines
+ */
+#define MSP_OPT_AUTO    0x00
+#define MSP_OPT_10M     0x01
+#define MSP_OPT_100M    0x02
+#define MSP_OPT_FDUP    0x04
+#define MSP_OPT_HDUP    0x08
+#define MSP_OPT_SWITCH  0x10
+
+/**************************************************************************
+ * Local error codes etc (mac errors start at 9000)
+ */
+#define MSP_SUCCESS             0
+#define MSP_FAIL                -1
+#define MSP_MAC_MEM_ALLOC_ERROR 9002
+#define MSP_MAC_PHY_ERROR       9006
+#define MSP_MAC_PHY_NO_LINK     9012 
+
+/**************************************************************************
+ * Hardware register locations & constants
+ */
+#define MSPETHSIZE       (0xE0)	    /* Size of each MAC register space */ 
+#define POLO_MAC2_ENABLE (0x20000000)    
+
+/**************************************************************************
+ * Macros & inline functions
+ */
+
+/* select the correct cache flush/invalidate operations */
+#if CONFIG_MIPS_L1_CACHE_SHIFT == 4
+	#define CACHE_UNROLL cache16_unroll32
+	#define UNROLL_INCR 0x200
+#elif CONFIG_MIPS_L1_CACHE_SHIFT == 5
+	#define CACHE_UNROLL cache32_unroll32
+	#define UNROLL_INCR 0x400
+#elif CONFIG_MIPS_L1_CACHE_SHIFT == 6
+	#define CACHE_UNROLL cache64_unroll32
+	#define UNROLL_INCR 0x800
+#endif
+
+
+
+/**************************************************************************
+ * Register definitions
+ */
+/* MAC */
+#define  MSPETH_DMA_Ctl        (0x00)
+#define  MSPETH_TxFrmPtr       (0x04)
+#define  MSPETH_TxThrsh        (0x08)
+#define  MSPETH_TxPollCtr      (0x0c)
+#define  MSPETH_BLFrmPtr       (0x10)
+#define  MSPETH_RxFragSize     (0x14)
+#define  MSPETH_Int_En         (0x18)
+#define  MSPETH_FDA_Bas        (0x1c)
+#define  MSPETH_FDA_Lim        (0x20)
+#define  MSPETH_Int_Src        (0x24)
+#define  MSPETH_PauseCnt       (0x30)
+#define  MSPETH_RemPauCnt      (0x34)
+#define  MSPETH_TxCtlFrmStat   (0x38)
+#define  MSPETH_MAC_Ctl        (0x40)
+#define  MSPETH_ARC_Ctl        (0x44)
+#define  MSPETH_Tx_Ctl         (0x48)
+#define  MSPETH_Tx_Stat        (0x4c)
+#define  MSPETH_Rx_Ctl         (0x50)
+#define  MSPETH_Rx_Stat        (0x54)
+#define  MSPETH_MD_DATA        (0x58)
+#define  MSPETH_MD_CA          (0x5c)
+#define  MSPETH_ARC_Adr        (0x60)
+#define  MSPETH_ARC_Data       (0x64)
+#define  MSPETH_ARC_Ena        (0x68)
+#define  MSPETH_Miss_Cnt       (0x7c)
+#define  MSPETH_BSWE1_Add      (0xc0)
+#define  MSPETH_BSWE2_Add      (0xc4)
+#define  MSPETH_BMWE1_Add      (0xc8)
+#define  MSPETH_BMWE2_Add      (0xcc)
+#define  MSPETH_INTBRW_Add     (0xd0)
+#define  MSPETH_BCTRL_Reg      (0xd4)
+/* PHY */
+#define  MSPPHY_MII_DATA       (0x00)
+#define  MSPPHY_MII_CTRL       (0x04)
+
+/*
+ * Bit Assignments
+ */
+/* DMA_Ctl (0x00) bit assign ------------------------------------------------*/
+#define DMA_RxAlign3           0x00C00000 /* Receive Alignment (skip 3 bytes)*/
+#define DMA_RxAlign2           0x00800000 /* Receive Alignment (skip 2 bytes)*/
+#define DMA_RxAlign1           0x00400000 /* Receive Alignment (skip 1 byte) */
+/* RESERVED                    0x00300000        not used, must be zero      */
+#define DMA_M66EnStat          0x00080000 /* 1:Station clock/30              */
+#define DMA_IntMask            0x00040000 /* 1:Interupt mask                 */
+#define DMA_SWIntReq           0x00020000 /* 1:Software Interrupt request    */
+#define DMA_TxWakeUp           0x00010000 /* 1:Transmit Wake Up              */
+#define DMA_RxBigE             0x00008000 /* 1:Receive Big Endian            */
+#define DMA_TxBigE             0x00004000 /* 1:Transmit Big Endian           */
+#define DMA_TestMode           0x00002000 /* 1:Test Mode                     */
+#define DMA_PowrMgmnt          0x00001000 /* 1:Power Management              */
+#define DMA_BRST_Mask          0x000001fc /* DMA Burst size                  */
+#define DMA_BRST_Shift         2
+
+/* RxFragSize (0x14) bit assign -------------------------------------------- */
+#define RxFrag_EnPack          0x00008000 /* 1:Enable Packing                */
+#define RxFrag_MinFragMask     0x00000ffc /* Minimum Fragment                */
+
+/*
+ * Int_En (0x18) bit assign ------------------------------------------------
+ * Since bit 6 of the Int_En register at 0x18 is reserved and even writing
+ * to this register bit causes random interrupts, take caution when writing to
+ * this register - always write 0 there. For this reason there are two
+ * definitions for Enable and Disable and couldn't use the ~ of the Enable for
+ * Disable,
+ */
+#define IntEn_NRAB             0x00000800 /* Non-recoverable abort enable  */
+#define IntEn_TxCtlCmp         0x00000400 /* Transmit Ctl Complete enable  */
+#define IntEn_DmParErr         0x00000200 /* DMA Parity Error enable       */
+#define IntEn_DParD            0x00000100 /* Data Parity Detected enable   */
+#define IntEn_EarNot           0x00000080 /* Early Rx Notify enable        */
+/* RESERVED                    0x00000040        not used, must be zero    */
+#define IntEn_SSysErr          0x00000020 /* Signalled System Error enable */
+#define IntEn_RMAB             0x00000010 /* Received Master Abort enable  */
+#define IntEn_RTAB             0x00000008 /* Received Target Abort enable  */
+#define IntEn_STAB             0x00000004 /* Signaled Target Abort enable  */
+#define IntEn_BLEx             0x00000002 /* Buffer List Exhausted enable  */
+#define IntEn_FDAEx            0x00000001 /* FDA Exhausted Enable          */
+
+/* Int_Src (0x24) bit assign ----------------------------------------------- */
+#define IntSrc_ExtE            0x00040000 /* External Event int.             */
+/* RESERVED                    0x00020000        not used, must be zero      */
+#define IntSrc_ExDefer         0x00010000 /* Excessive Tx Deferrals int.     */
+#define IntSrc_Link_St         0x00008000 /* Link State Change status        */
+#define IntSrc_NRAB            0x00004000 /* Non-recoverable abort int.      */
+#define IntSrc_DmParErr        0x00002000 /* DMA Parity Error int.           */
+#define IntSrc_BLEx            0x00001000 /* Buffer List Exhausted int       */
+#define IntSrc_FDAEx           0x00000800 /* FDA Exhausted, int.             */
+#define IntSrc_NRAB_St         0x00000400 /* Non-recoverable abort status    */
+#define	IntSrc_Cmp             0x00000200 /* MAC ctrl packet int.            */
+#define IntSrc_ExBD            0x00000100 /* Excessive BD status             */
+#define IntSrc_DmParErr_St     0x00000080 /* DMA Parity Error status         */
+#define IntSrc_EarNot          0x00000040 /* Rx early notify int.            */
+#define IntSrc_SWInt_St        0x00000020 /* Software Request status         */
+#define IntSrc_BLEx_St         0x00000010 /* Buffer List Exhausted status    */
+#define IntSrc_FDAEx_St        0x00000008 /* FDA Exhausted status            */
+/* RESERVED                    0x00000004        not used, must be zero      */
+#define IntSrc_MacRx           0x00000002 /* Rx packet int.                  */
+#define IntSrc_MacTx           0x00000001 /* Tx packet int.                  */
+
+/* MAC_Ctl (0x40) bit assign ----------------------------------------------- */
+#define MAC_Link10             0x00008000 /* 1:Link Status 10Mbits           */
+/* RESERVED                    0x00004000        not used, must be zero      */
+#define MAC_EnMissRoll         0x00002000 /* 1:Enable Missed Roll            */
+#define MAC_MissRoll           0x00000400 /* 1:Missed Roll                   */
+#define MAC_LnkChg             0x00000100 /* write 1 to clear Int_Link       */
+#define MAC_Loop10             0x00000080 /* 1:Loop 10 Mbps                  */
+#define MAC_Conn_Auto          0x00000000 /*00:Connection mode (Automatic)   */
+#define MAC_Conn_10M           0x00000020 /*01:                (10Mbps endec)*/
+#define MAC_Conn_Mll           0x00000040 /*10:                (Mll clock)   */
+#define MAC_MacLoop            0x00000010 /* 1:MAC Loopback                  */
+#define MAC_FullDup            0x00000008 /* 1:Full Duplex 0:Half Duplex     */
+#define MAC_Reset              0x00000004 /* 1:Software Reset                */
+#define MAC_HaltImm            0x00000002 /* 1:Halt Immediate                */
+#define MAC_HaltReq            0x00000001 /* 1:Halt request                  */
+ 
+ /* ARC_Ctl (0x44) (bit assign --------------------------------------------- */
+#define ARC_CompEn             0x00000010 /* 1:ARC Compare Enable            */
+#define ARC_NegCAM             0x00000008 /* 1:Reject packets ARC recognizes,*/
+                                          /*                    accept other */
+#define ARC_BroadAcc           0x00000004 /* 1:Broadcast assept              */
+#define ARC_GroupAcc           0x00000002 /* 1:Multicast assept              */
+#define ARC_StationAcc         0x00000001 /* 1:unicast accept                */
+
+/* Tx_Ctl (0x48) bit assign ------------------------------------------------ */
+#define Tx_EnComp              0x00004000 /* 1:Enable Completion             */
+#define Tx_EnTxPar             0x00002000 /* 1:Enable Transmit Parity        */
+#define Tx_EnLateColl          0x00001000 /* 1:Enable Late Collision         */
+#define Tx_EnExColl            0x00000800 /* 1:Enable Excessive Collision    */
+#define Tx_EnLCarr             0x00000400 /* 1:Enable Lost Carrier           */
+#define Tx_EnExDefer           0x00000200 /* 1:Enable Excessive Deferral     */
+#define Tx_EnUnder             0x00000100 /* 1:Enable Underrun               */
+#define Tx_FBack               0x00000010 /* 1:Fast Back-off                 */
+#define Tx_NoCRC               0x00000008 /* 1:Suppress Padding              */
+#define Tx_NoPad               0x00000004 /* 1:Suppress Padding              */
+#define Tx_TxHalt              0x00000002 /* 1:Transmit Halt Request         */
+#define Tx_En                  0x00000001 /* 1:Transmit enable               */
+
+/* Tx_Stat (0x4C) bit assign ----------------------------------------------- */
+#define Tx_SQErr               0x00010000 /* Signal Quality Error(SQE)       */
+#define Tx_Halted              0x00008000 /* Tx Halted                       */
+#define Tx_Comp                0x00004000 /* Completion                      */
+#define Tx_TxPar               0x00002000 /* Tx Parity Error                 */
+#define Tx_LateColl            0x00001000 /* Late Collision                  */
+#define Tx_10Stat              0x00000800 /* 10Mbps Status                   */
+#define Tx_NCarr               0x00000400 /* No Carrier                      */
+#define Tx_Defer               0x00000200 /* Deferral                        */
+#define Tx_Under               0x00000100 /* Underrun                        */
+#define Tx_IntTx               0x00000080 /* Interrupt on Tx                 */
+#define Tx_Paused              0x00000040 /* Transmit Paused                 */
+#define Tx_TXDefer             0x00000020 /* Transmit Defered                */
+#define Tx_ExColl              0x00000010 /* Excessive Collision             */
+#define Tx_TxColl_MASK         0x0000000F /* Tx Collision Count              */
+
+/*
+ * Rx_Ctl (0x50) bit assign ------------------------------------------------
+ * EnLenErr is a bit that is NOT defined in the manual but was added
+ * It indicates the reception of a frame whose protocol id field value
+ * does not match a length.  This interrupt allows us the process IP
+ * and other packets whose protocol id field is not treated as a length
+ */
+#define Rx_EnGood              0x00004000 /* 1:Enable Good                   */
+#define Rx_EnRxPar             0x00002000 /* 1:Enable Receive Parity         */
+#define Rx_EnLenErr            0x00001000 /* 1:Enable Length Error           */
+#define Rx_EnLongErr           0x00000800 /* 1:Enable Long Error             */
+#define Rx_EnOver              0x00000400 /* 1:Enable OverFlow               */
+#define Rx_EnCRCErr            0x00000200 /* 1:Enable CRC Error              */
+#define Rx_EnAlign             0x00000100 /* 1:Enable Alignment              */
+/* RESERVED                    0x00000080        not used, must be zero      */
+#define Rx_IgnoreCRC           0x00000040 /* 1:Ignore CRC Value              */
+#define Rx_StripCRC            0x00000010 /* 1:Strip CRC Value               */
+#define Rx_ShortEn             0x00000008 /* 1:Short Enable                  */
+#define Rx_LongEn              0x00000004 /* 1:Long Enable                   */
+#define Rx_RxHalt              0x00000002 /* 1:Receive Halt Request          */
+#define Rx_RxEn                0x00000001 /* 1:Receive Intrrupt Enable       */
+
+/* Rx_Stat (0x54) bit assign ----------------------------------------------- */
+#define Rx_Halted              0x00008000 /* Rx Halted                       */
+#define Rx_Good                0x00004000 /* Rx Good                         */
+#define Rx_RxPar               0x00002000 /* Rx Parity Error                 */
+/* RESERVED                    0x00001000        not used, must be zero      */
+#define Rx_LongErr             0x00000800 /* Rx Long Error                   */
+#define Rx_Over                0x00000400 /* Rx Overflow                     */
+#define Rx_CRCErr              0x00000200 /* Rx CRC Error                    */
+#define Rx_Align               0x00000100 /* Rx Alignment Error              */
+#define Rx_10Stat              0x00000080 /* Rx 10Mbps Status                */
+#define Rx_IntRx               0x00000040 /* Rx Interrupt                    */
+#define Rx_CtlRecd             0x00000020 /* Rx Control Receive              */
+#define Rx_Stat_Mask           0x0000EFC0 /* Rx All Status Mask              */
+
+/* MD_CA (0x5C) bit assign ------------------------------------------------- */
+#define MD_CA_PreSup           0x00001000 /* 1:Preamble Supress              */
+#define MD_CA_BUSY_BIT         0x00000800 /* 1:Busy (Start Operation)        */
+#define MD_CA_Wr               0x00000400 /* 1:Write 0:Read                  */
+#define MD_CA_PHYADD           0x000003E0 /*   bits 9:5                      */
+#define MD_CA_PHYREG           0x0000001F /*   bits 4:0                      */
+#define MD_CA_PhyShift    (5)
+#define MD_MAX_PHY        32     /* Maximum number of PHY per MII             */
+#define MD_UNASSIGNED_PHY 0xFD    /* PHY address has not been determined yet   */
+#define MD_SWITCH_PHY     0xFE    /* No PHY exists - case for a switch         */
+#define MD_DYNAMIC_PHY    0xFF    /* Software indication dynamically find phy  */
+
+/* ARC_Ena (0x68) bit assign ----------------------------------------------- */
+#define ARC_ENTRY_MAX                  21     /* ARC Data entry max count    */
+#define ARC_Ena_Mask ((1 << ARC_ENTRY_MAX)-1) /* ARC Enable bits (Max 21)    */
+#define ARC_Ena_Bit(index)      (1<<(index))
+#define ARC_ENTRY_DESTINATION	0
+#define ARC_ENTRY_SOURCE	1
+#define ARC_ENTRY_MACCTL	20
+
+/* BCTRL_Reg (0xd4) bit assign ----------------------------------------------- */
+#define RMII_Reset             0x00000004    /* RMII Reset                     */
+#define RMII_10MBIT            0x00000002    /* 1 if 10 Mbs, 0 if 100 Mbs      */
+#define RMII_ClkRising         0x00000001    /* 0 if TxD generated off falling edge,
+                                              * 1 if generated off rising edge of Tx-CLK */
+                                              
+/**************************************************************************
+ * Data structures
+ */
+/* Frame descripter */
+struct FDesc {
+	volatile __u32 FDNext;
+	volatile __u32 FDSystem;
+	volatile __u32 FDStat;
+	volatile __u32 FDCtl;
+};
+
+/* Buffer descripter */
+struct BDesc {
+	volatile __u32 BuffData;
+	volatile __u32 BDCtl;
+};
+
+#define FD_ALIGN	16
+
+/* Frame Descripter bit assign ---------------------------------------------- */
+#define FD_Next_EOL            0x00000001 /* FDNext EOL indicator             */
+#define FD_Next_MASK           0xFFFFFFF0 /* FDNext valid pointer             */
+
+#define FD_FDLength_MASK       0x0000FFFF /* Length MASK                      */
+#define FD_BDCnt_MASK          0x001F0000 /* BD count MASK in FD              */
+#define FD_FrmOpt_MASK         0x7C000000 /* Frame option MASK                */
+#define FD_FrmOpt_BigEndian    0x40000000 /* Tx/Rx */
+#define FD_FrmOpt_IntTx        0x20000000 /* Tx only */
+#define FD_FrmOpt_NoCRC        0x10000000 /* Tx only */
+#define FD_FrmOpt_NoPadding    0x08000000 /* Tx only */
+#define FD_FrmOpt_Packing      0x04000000 /* Rx only */
+#define FD_CownsFD             0x80000000 /* FD Controller owner bit         */
+#define FD_BDCnt_SHIFT         16
+
+/* Buffer Descripter bit assign --------------------------------------------- */
+#define BD_BuffLength_MASK     0x0000FFFF /* Recieve Data Size               */
+#define BD_RxBDID_MASK         0x00FF0000 /* BD ID Number MASK               */
+#define BD_RxBDSeqN_MASK       0x7F000000 /* Rx BD Sequence Number           */
+#define BD_CownsBD             0x80000000 /* BD Controller owner bit         */
+#define BD_RxBDID_SHIFT        16
+#define BD_RxBDSeqN_SHIFT      24
+
+/* operational constants */
+#define DMA_CTL_CMD (DMA_M66EnStat | DMA_RxBigE | DMA_TxBigE | \
+			DMA_RxAlign2  | (DMA_BURST_SIZE << DMA_BRST_Shift))
+
+#define TX_CTL_CMD	(Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
+			Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | Tx_EnUnder | \
+			Tx_En)
+
+#define RX_CTL_CMD	(Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver \
+			| Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn)
+
+#define INT_EN_CMD (IntEn_NRAB | IntEn_DmParErr | IntEn_SSysErr | \
+		    IntEn_BLEx  | IntEn_FDAEx)
+
+#define FATAL_ERROR_INT (IntSrc_NRAB | IntSrc_DmParErr | IntSrc_BLEx)
+
+#define BMSR_EXISTS (BMSR_ANEGCAPABLE | BMSR_10HALF | BMSR_10FULL | \
+			BMSR_100HALF | BMSR_100FULL)
+
+/* error check and calculate constants & masks */
+#if RX_BUF_ORDER > 8 || RX_BUF_ORDER < 0
+#error "RX buffer order out of limits.  0 < ORDER < 9"
+#endif
+
+#if TX_BUF_ORDER > 8 || TX_BUF_ORDER < 0
+#error "TX buffer order out of limits.  0 < ORDER < 9"
+#endif
+
+#define RX_BUF_NUM  (1 << RX_BUF_ORDER)
+#define RX_BUF_MASK (RX_BUF_NUM - 1)
+#define TX_BUF_NUM  (1 << TX_BUF_ORDER)
+#define TX_BUF_MASK (TX_BUF_NUM - 1)
+
+struct Q_Desc {
+	union {
+		struct FDesc fd;
+		struct FDesc fd0;
+	};
+	union {
+		struct BDesc bd;
+		struct FDesc fd1;
+	};
+};      
+
+/* hammtrev, 2005-11-25:
+ * Apparently, the MSP Ethernet has a hardware issue which could hang the
+ * device if a BLEx interrupt comes before a FDAEx, so they should be avoided
+ * if at all possible. Changing to ensure there are twice as many buffer
+ * descriptors as frame descriptors.
+ */
+struct BL_Desc {
+	struct FDesc fd;
+	struct BDesc bd[RX_BUF_NUM << 1];
+};
+
+
+/* structure to define access to each phy (for control purposes) */
+struct mspeth_phy {
+	struct mspeth_phy *next_phy;
+	u8 hwunit;
+	u8 phyaddr;
+	u32 memaddr;
+	bool assigned;
+	bool linkup;
+	spinlock_t lock;
+};
+
+/* Information that need to be kept for each board. */
+struct mspeth_local {
+	/* device configuration & constants */
+	u8 unit;			/* logical unit number  */
+	u8 hwunit;			/* hardware unit number */
+	u8 option;			/* option setting from PROM or bootline */
+	int  speed;			/* actual speed, 10 or 100 */
+	bool fullduplex;	/* actual duplex */
+	
+	/* phy configuration & control index */
+	struct mspeth_phy *phyptr;
+	
+	/* ioremapped register access cookie */
+	void *mapaddr;
+		
+	/* tasklet queues */
+	struct tasklet_struct rx_tasklet;
+	struct tasklet_struct tx_tasklet;
+	struct tasklet_struct hard_restart_tasklet;
+	
+	/* link monitor timer */
+	struct timer_list link_timer;
+
+	/* statistics */
+	struct net_device_stats stats; /* statistics */
+	int fatal_icnt;
+	struct {
+		int max_tx_qlen;
+		int tx_ints;
+		int rx_ints;
+		int tx_full;
+		int fd_exha;
+	} lstats;
+
+	/* Buffer structures */
+	/*
+	 * Transmitting: Batch Mode.
+	 *	1 BD in 1 TxFD
+	 *      circular list of FDs
+	 * Receiving: non-Packing mode
+	 *	1 circular FD for Free Buffer List.
+	 *	RX_BUF_NUM BD in Free Buffer FD.
+	 *	One Free Buffer BD has preallocated skb data
+	 */ 
+	void *FD_base;
+	struct Q_Desc *rxfd_base;  /* RX FD region ptr  */
+	struct Q_Desc *rxfd_curr;  /* RX FD current ptr */	
+	
+	struct Q_Desc *txfd_base;  /* TX FD region ptr  */	
+	u32 tx_head,tx_tail;       /* insert/delete for TX queue */
+	atomic_t tx_qspc ;	 /* space available on the transmit queue */
+	
+	struct BL_Desc *blfd_ptr;  /* Free list FD head */
+	struct sk_buff **rx_skbp;
+};
+
+#endif /* _MSPETH_H_ */
diff --git a/arch/mips/pmc-sierra/msp71xx/msp_eth.c b/arch/mips/pmc-sierra/msp71xx/msp_eth.c
new file mode 100644
index 0000000..79e7a99
--- /dev/null
+++ b/arch/mips/pmc-sierra/msp71xx/msp_eth.c
@@ -0,0 +1,55 @@
+/*
+ * The setup file for ethernet related hardware on PMC-Sierra MSP processors.
+ *
+ * Copyright 2005 PMC-Sierra, Inc.
+ *
+ *  This program is free software; you can redistribute  it and/or modify it
+ *  under  the terms of  the GNU General  Public License as published by the
+ *  Free Software Foundation;  either version 2 of the  License, or (at your
+ *  option) any later version.
+ *
+ *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
+ *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
+ *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
+ *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
+ *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
+ *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
+ *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *  You should have received a copy of the  GNU General Public License along
+ *  with this program; if not, write  to the Free Software Foundation, Inc.,
+ *  675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+
+#include <msp_regs.h>
+#include <msp_gpio_macros.h>
+
+#if defined(CONFIG_PMC_MSP4200_GW)
+#define MSP_ETHERNET_GPIO	9
+#elif defined(CONFIG_PMC_MSP7120_GW)
+#define MSP_ETHERNET_GPIO	14
+#endif
+
+static int __init msp_eth_setup(void)
+{
+#if defined(CONFIG_PMC_MSP4200_GW)
+	/* Configure the GPIO and take the ethernet PHY out of reset */
+	*((unsigned long *) GPIO_CFG3_REG) = 0x8000;
+	*((unsigned long *) GPIO_DATA3_REG) = 0x8;
+#elif defined(CONFIG_PMC_MSP7120_GW)
+	/* Configure the GPIO and take the ethernet PHY out of reset */
+	msp_gpio_pin_mode( MSP_GPIO_OUTPUT, MSP_ETHERNET_GPIO );
+	msp_gpio_pin_hi( MSP_ETHERNET_GPIO );
+#endif
+
+	return 0;
+}
+
+subsys_initcall(msp_eth_setup);
+
