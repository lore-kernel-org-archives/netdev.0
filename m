From: Marc St-Jean <stjeanma@pmc-sierra.com>
Subject: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Thu, 26 Apr 2007 18:48:03 -0600
Message-ID: <200704270048.l3R0m3WV015597@pasqua.pmc-sierra.bc.ca>
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	linux-mips@linux-mips.org
To: netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

[PATCH 10/12] drivers: PMC MSP71xx ethernet driver

Patch to add an ethernet driver for the PMC-Sierra MSP71xx devices.

Patches 1 through 9 were posted to linux-mips@linux-mips.org as well
as other sub-system lists/maintainers as appropriate. This patch has
some dependencies on the first few patches in the set. If you would
like to receive these or the entire set, please email me.

Thanks,
Marc

Signed-off-by: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
---
Changes since last posting:
-Major cleanup in style, etc.
-Converted to platfrom driver model.
-Added iomapping support.
-Added dma sync support.
-Added NAPI support.
-Added skb buffer recycling.

 arch/mips/pmc-sierra/msp71xx/msp_eth.c |  122 +
 drivers/net/Kconfig                    |   20 
 drivers/net/Makefile                   |    1 
 drivers/net/pmcmspeth.c                | 3178 +++++++++++++++++++++++++++++++++
 drivers/net/pmcmspeth.h                |  624 ++++++
 5 files changed, 3945 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 76f98f3..53a7246 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -201,6 +201,26 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
+config MSPETH
+	bool "Ethernet for PMC-Sierra MSP"
+	depends on NET_ETHERNET && PMC_MSP
+	---help---
+	This adds support for the the MACs found on the PMC-Sierra MSP devices.
+
+config MSPETH_NAPI
+	bool "NAPI support"
+	depends on MSPETH
+	help
+	  NAPI(New API) is a technique to improve network performance on Linux.
+
+config MSPETH_SKB_RECYCLE
+	bool "Socket Buffer recycling support"
+	depends on MSPETH
+	help
+	  Reuse the socket buffers used during the transmission of packets for the receive
+	  operation. This improves performance by reducing kmalloc/kfree operations.
+
+
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on NET_ETHERNET && PPC_PMAC && PPC32
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c26ba39..cc90aa0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -68,6 +68,7 @@ obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
+obj-$(CONFIG_MSPETH) += pmcmspeth.o
 obj-$(CONFIG_RIONET) += rionet.o
 
 #
diff --git a/drivers/net/pmcmspeth.c b/drivers/net/pmcmspeth.c
new file mode 100644
index 0000000..788fa23
--- /dev/null
+++ b/drivers/net/pmcmspeth.c
@@ -0,0 +1,3178 @@
+/*
+ * PMC-Sierra MSP EVM ethernet driver for linux
+ *
+ * Copyright 2005-2007 PMC-Sierra, Inc
+ *
+ * Originally based on mspeth.c driver which contains substantially the
+ * same hardware.
+ * Based on skelton.c by Donald Becker.
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
+#include <linux/version.h>
+#include <linux/etherdevice.h>
+#include <linux/proc_fs.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+
+#include <asm/bootinfo.h>
+#include <asm/dma.h>
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+#include <linux/dma-mapping.h>
+#include <linux/platform_device.h>
+#include <net/xfrm.h>
+#include <asm/cpu-features.h>
+#include <msp_regs.h>
+#include <msp_regops.h>
+#include <msp_prom.h>
+#include <msp_int.h>
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+#include <asm/r4kcache.h>
+#include <asm/brecis/prom.h>
+#include <asm/brecis/brecisint.h>
+#include <asm/brecis/brecisint.h>
+#include <asm/brecis/BrecisSysRegs.h>
+#include <brecis/msp.h>
+#endif /* LINUX_VERSION_CODE */
+
+#include "pmcmspeth.h"
+
+/**************************************************************************
+ * The name of the card. Is used for messages and in the requests for
+ * io regions, irqs and dma channels, versions, etc. Also, various other
+ * identifying character constants.
+ */
+static const char cardname[] = "pmcmspeth";
+
+/**************************************************************************
+ * List of PHYs. Each MAC will have a certain number (maybe zero)
+ * PHYs hanging off the MDIO interface.
+ */
+static struct mspeth_phy *root_phy_dev = NULL;
+
+/* Debugging flags */
+static unsigned int mspeth_debug = MSPETH_DEBUG;
+
+/**************************************************************************
+ * Function prototypes
+ */
+
+/* Functions that get called by upper layers */
+static int mspeth_open(struct net_device *dev);
+static int mspeth_send_packet(struct sk_buff *skb,
+				struct net_device *dev);
+static void mspeth_tx_timeout(struct net_device *dev);
+static void mspeth_hard_restart_bh(unsigned long dev_addr);
+static int mspeth_close(struct net_device *dev);
+static struct net_device_stats *mspeth_get_stats(struct net_device *dev);
+static void mspeth_set_multicast_list(struct net_device *dev);
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+static irqreturn_t mspeth_interrupt(int irq, void *dev_id);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+static void mspeth_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+#endif
+
+#ifdef CONFIG_MSPETH_NAPI
+static int mspeth_poll(struct net_device *dev, int *budget);
+inline static void mspeth_txdone(unsigned long dev_addr);
+#else
+static void mspeth_rx(unsigned long dev_addr);
+static void mspeth_txdone(unsigned long dev_addr);
+#endif /* CONFIG_MSPETH_NAPI */
+
+/* Private utility functions */
+static void mspeth_soft_restart(struct net_device *dev);
+static void mspeth_hard_restart(struct net_device *dev);
+static void mspeth_mac_reset(struct net_device *dev);
+static void mspeth_mac_init(struct net_device *dev);
+static void mspeth_phy_init(struct net_device *dev);
+static void mspeth_phy_reset(struct net_device *dev);
+static int mspeth_proc_info(char *buf, char **buf_loc, off_t off,
+				int len, int *eof, void *data);
+static void mspeth_set_arc_entry(struct net_device *dev,
+				int index, unsigned char *addr);
+static void mspeth_check_tx_stat(struct net_device *dev, int status);
+static int mspeth_phyprobe(struct net_device *dev);
+static void mspeth_init_phyaddr(struct net_device *dev);
+static void mspeth_init_cmdline(struct net_device *dev);
+static void mspeth_fatal_error_interrupt(struct net_device *dev,
+						int status);
+
+/*
+ * Define the utility functions used by the the various other actual
+ * routines here. These should all be inline or macros.
+ */
+
+/************************************************************************
+ * flush_memqueue - Ensure all queued memory transactions are
+ * 			complete.
+ */
+#define flush_memqueue()	blocking_read_reg32(MEM_CFG1_REG)
+
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+/************************************************************************
+ * writeback_buffer - force the cache to write contents of cached buffer
+ * to memory and invalidate the buffer. Must start on cache line boundary,
+ * must "own" to next higher cache line boundary from end of buffer
+ *
+ * stjeanma, 2006-06-12:
+ * Use L1_CACHE_ALIGN to cache align the buffer rounding down to
+ * the next cache line. It is the resposibility of the caller to ensure
+ * that any partial cache line before the pointer isn't conflicting with
+ * other memory shared with the controller.
+ */
+inline static void
+writeback_buffer(void *buf_addr, unsigned int length)
+{
+	unsigned long end = (unsigned long)buf_addr + length;
+	buf_addr = (void *)((unsigned long)buf_addr &
+			~(L1_CACHE_BYTES - 1));
+
+	while ((unsigned long)buf_addr + UNROLL_INCR < end) {
+		CACHE_UNROLL(buf_addr, Hit_Writeback_Inv_D);
+		buf_addr += UNROLL_INCR;
+	}
+
+	while ((unsigned long)buf_addr < end) {
+		flush_dcache_line((unsigned long)buf_addr);
+		buf_addr += L1_CACHE_BYTES;
+	}
+}
+
+/************************************************************************
+ * invalidate_buffer - Invalidate buffer cache
+ *	- must start on cache line boundary
+ *	- must "own" to next higher cache line boundary from end of buffer
+ *
+ * stjeanma, 2006-06-12:
+ * Use L1_CACHE_ALIGN to cache align the buffer rounding down to
+ * the next cache line. It is the resposibility of the caller to ensure
+ * that any partial cache line before the pointer isn't conflicting with
+ * other memory shared with the controller.
+ */
+inline static void
+invalidate_buffer(void *buf_addr, unsigned int length)
+{
+	unsigned long end = (unsigned long)buf_addr + length;
+	buf_addr = (void *)((unsigned long)buf_addr & ~(L1_CACHE_BYTES - 1));
+
+	while ((unsigned long)buf_addr + UNROLL_INCR < end) {
+		CACHE_UNROLL(buf_addr, Hit_Invalidate_D);
+		buf_addr += UNROLL_INCR;
+	}
+
+	while ((unsigned long)buf_addr < end) {
+		invalidate_dcache_line((unsigned long)buf_addr );
+		buf_addr += L1_CACHE_BYTES;
+	}
+}
+#else
+#define writeback_buffer(a, l) do {} while (0)
+#define invalidate_buffer(a, l) do {} while (0)
+#endif /* CONFIG_DMA_NONCOHERENT && LINUX_VERSION_CODE */
+
+/************************************************************************
+ * Read/Write a MSP eth register.
+ */
+inline static u32
+msp_read(struct mspeth_priv *lp, unsigned int offset)
+{
+	return __raw_readl(lp->mapaddr + offset);
+}
+
+inline static void
+msp_write(struct mspeth_priv *lp, unsigned int offset, u32 val)
+{
+	__raw_writel(val, lp->mapaddr + offset);
+}
+
+/************************************************************************
+ * Read/Write a MDIO register.
+ */
+static u32
+mspphy_read(struct mspeth_phy *phyptr, int phy_reg)
+{
+	unsigned long flags;
+	u32 data;
+
+	if (phyptr == NULL) {
+		printk(KERN_WARNING "MSPETH(mspphy_read): "
+			"Cannot read from a NULL PHY!\n");
+		return 0x0;
+	}
+
+	/* protect access with spin lock */
+	spin_lock_irqsave(&(phyptr->lock), flags);
+
+	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
+		MD_CA_BUSY_BIT) {;}
+	__raw_writel(MD_CA_BUSY_BIT | phyptr->phyaddr << 5 | phy_reg,
+			phyptr->memaddr + MSPPHY_MII_CTRL);
+	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
+		MD_CA_BUSY_BIT) {;}
+	data = __raw_readl(phyptr->memaddr + MSPPHY_MII_DATA);
+
+	/* unlock */
+	spin_unlock_irqrestore(&(phyptr->lock), flags);
+
+	return data & 0xffff;
+}
+
+static void
+mspphy_write(struct mspeth_phy *phyptr, int phy_reg, u32 data)
+{
+	unsigned long flags;
+
+	if (phyptr == NULL) {
+		printk(KERN_WARNING "MSPETH(mspphy_write): "
+			"Cannot write to a NULL PHY!\n");
+		return;
+	}
+
+	/* protect access with spin lock */
+	spin_lock_irqsave(&(phyptr->lock), flags);
+
+	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
+		MD_CA_BUSY_BIT) {;}
+	__raw_writel(data, phyptr->memaddr + MSPPHY_MII_DATA);
+	__raw_writel(MD_CA_BUSY_BIT | MD_CA_Wr |
+			phyptr->phyaddr << 5 | phy_reg,
+			phyptr->memaddr + MSPPHY_MII_CTRL);
+	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
+		MD_CA_BUSY_BIT) {;}
+
+	/* unlock */
+	spin_unlock_irqrestore(&(phyptr->lock), flags);
+}
+
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+/* initialise the recycle bin for skb */
+static void
+init_skbuff_bin(void)
+{
+	spin_lock_init(&skb_bin.lock);
+	skb_bin.recycle_max = RX_BUF_NUM * 4; /* max size of bin */
+	skb_bin.recycle_count = 0;
+	skb_bin.recycle_queue = NULL;
+	skb_bin.user_count = 0;
+}
+
+/* free the skb's in recycle bin */
+static void
+free_skbuff_bin(void)
+{
+	spin_lock_bh(&skb_bin.lock);
+
+	/* check any skb's are present in the recycle bin */
+	if (skb_bin.recycle_count > 0) {
+		struct sk_buff *skb;
+		while (skb_bin.recycle_queue != NULL ) {
+			skb = skb_bin.recycle_queue->next;
+			dev_kfree_skb_any(skb_bin.recycle_queue);
+			skb_bin.recycle_queue = skb;
+		}
+	}
+
+	/* reset fields */
+	skb_bin.recycle_queue = NULL;
+	skb_bin.recycle_count = 0;
+	
+	spin_unlock_bh(&skb_bin.lock);
+}
+
+inline static void
+mspeth_skb_headerinit(struct sk_buff *skb)
+{
+	/* these are essential before init */
+	dst_release(skb->dst);
+#ifdef CONFIG_XFRM
+	secpath_put(skb->sp);
+#endif
+#ifdef CONFIG_NETFILTER
+	nf_conntrack_put(skb->nfct);
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	nf_conntrack_put_reasm(skb->nfct_reasm);
+#endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_put(skb->nf_bridge);
+#endif
+#endif /* CONFIG_NETFILTER */
+
+	/* now initialise the skb . . . */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	/* clear the members till skb->truesize */
+	memset(skb, 0, offsetof(struct sk_buff, truesize));
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	skb->prev = NULL;
+	skb->list = NULL;
+	skb->sk = NULL;
+	skb->stamp.tv_sec = 0;
+#ifdef CONFIG_BRECIS
+	skb->stamp.tv_usec = 0;
+#endif /* CONFIG_BRECIS */
+	skb->dev = NULL;
+	skb->real_dev = NULL;
+	skb->dst = NULL;
+	memset(skb->cb, 0, sizeof(skb->cb));
+	skb->pkt_type = PACKET_HOST;
+	skb->priority = 0;
+	skb->security = 0;
+
+#ifdef CONFIG_NETFILTER
+	skb->nfmark = skb->nfcache = 0;
+	skb->nfct = NULL;
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug = 0;
+#endif
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+	skb->nf_bridge = NULL;
+#endif
+#endif /* CONFIG_NETFILTER */
+#ifdef CONFIG_NET_SCHED
+	skb->tc_index = 0;
+#endif
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	skb->nfct_reasm = NULL;
+#endif
+#endif /* LINUX_VERSION_CODE */
+}
+#endif /* CONFIG_MSPETH_SKB_RECYCLE */
+
+/**************************************************************************
+ * Allocate and align a max length socket buffer for this device
+ */
+inline static struct sk_buff *
+mspeth_alloc_skb(struct net_device *dev)
+{
+	struct sk_buff *skb = NULL;
+	
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	/* try to get an skb from the recycle bin */
+	spin_lock_bh(&skb_bin.lock);
+
+	/* check if the bin si empty */
+	if (skb_bin.recycle_queue) {
+		/* grab an skb from the bin */
+		skb = skb_bin.recycle_queue;
+		skb_bin.recycle_queue = skb->next;
+		
+		/* we have taken one, so reduce the count */
+		skb_bin.recycle_count--;
+		skb_bin.recycle_hits++;
+		spin_unlock_bh(&skb_bin.lock);
+
+		skb->next = NULL; /* must be set to NULL */
+		skb->truesize = (skb->end - skb->head) +
+				sizeof(struct sk_buff);
+		atomic_set(&skb->users, 1);
+		
+		/* reset the payload pointers */
+		skb->data = skb->head;
+		skb->tail = skb->head;
+
+		/* reset shared info fields */
+		atomic_set(&(skb_shinfo(skb)->dataref), 1);
+		skb_shinfo(skb)->nr_frags = 0;
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+		skb_shinfo(skb)->gso_size = 0;
+		skb_shinfo(skb)->gso_segs = 0;
+#endif
+		skb_shinfo(skb)->frag_list = NULL;
+		
+		/* compliance with __dev_alloc_skb */
+		skb_reserve(skb, NET_SKB_PAD);
+	} else {
+		/* no skb in bin */
+		spin_unlock_bh(&skb_bin.lock);
+	}
+#endif /* CONFIG_MSPETH_SKB_RECYCLE */
+
+	if (skb == NULL) {
+		/*
+		 * We need a bit more than an ethernet frame for the
+		 * aligment stuff so preallocate two more.
+		 */
+		skb = dev_alloc_skb(MSP_END_BUFSIZE + 2);
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+		skb_bin.recycle_misses++;
+#endif
+		if (skb == NULL) {
+			printk(KERN_WARNING "MSPETH(alloc_skb) %s: "
+				"cannot allocate skb!\n", dev->name);
+			return NULL;
+		}
+	}
+
+	/*
+	 * Align and fill out fields specific to our device. Notice that
+	 * our device is smart about FCS etc ......
+	 */
+	skb_reserve(skb, 2);
+	skb->dev = dev;
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+}
+
+/**************************************************************************
+ * Add the used skb to recycle bin or free it
+ */
+inline static void
+mspeth_free_skb(struct sk_buff *skb)
+{
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	/*
+	 * First try to recycle the skb.
+	 * Check if the skb can be recycled.
+	 */
+	if ((skb->end - skb->head) >= SKBUFF_RECYCLABLE_SIZE &&
+	    (!skb->destructor) &&
+	    (!skb->cloned) &&
+	    (atomic_dec_and_test(&skb->users))) {
+		/* skb is recyclable */
+		spin_lock_bh(&skb_bin.lock);
+		
+		/* check the bin has room to add our skb */
+		if (likely(skb_bin.recycle_count < skb_bin.recycle_max)) {
+			/* everything ok; go recycle it */
+			/* prerequisite before adding to recycle bin */
+			mspeth_skb_headerinit(skb);
+			
+			/* now we can add the skb to bin */
+			skb->next = skb_bin.recycle_queue;
+			skb_bin.recycle_queue = skb;
+			
+			/* we have one more skb in bin, increase the count */
+			skb_bin.recycle_count++;
+			
+			spin_unlock_bh(&skb_bin.lock);
+			return;
+		} else {
+			/* bin has no room */
+			spin_unlock_bh(&skb_bin.lock);
+		}
+	}
+#endif /* CONFIG_MSPETH_SKB_RECYCLE */
+
+	/* Can't add skb to recycle bin, so free it in normal way. */
+	dev_kfree_skb_any(skb);
+}
+
+/**************************************************************************
+ * Error reporting functions -- used for debugging mostly
+ */
+static void
+dump_qdesc(struct q_desc *fd)
+{
+	printk(KERN_INFO "  q_desc(%p): %08x %08x %08x %08x\n",
+		fd, fd->fd.FDNext, fd->fd.FDSystem,
+		fd->fd.FDStat, fd->fd.FDCtl);
+	printk(KERN_INFO "    BD: %08x %08x\n",
+		fd->bd.BuffData, fd->bd.BDCtl);
+}
+
+static void
+print_buf(char *add, int length)
+{
+	int i;
+	int len = length;
+
+	printk(KERN_INFO "print_buf(%08x)(%x)\n",
+		(unsigned int)add, length);
+
+	if (len > 100)
+		len = 100;
+	for (i = 0; i < len; i++) {
+		printk(KERN_INFO " %2.2X", (unsigned char)add[i]);
+		if (!(i % 16))
+			printk(KERN_INFO "\n");
+	}
+	printk(KERN_INFO "\n");
+}
+
+static void
+print_eth(int rx, char *add, int len)
+{
+	int i;
+	int lentyp;
+
+	if (rx)
+		printk(KERN_INFO "\n************************** RX packet "
+			"0x%08x ****************************\n", (u32)add);
+	else
+		printk(KERN_INFO "\n************************** TX packet "
+			"0x%08x ****************************\n", (u32)add);
+
+	printk(KERN_INFO "---- ethernet ----\n");
+	printk(KERN_INFO "==> dest: ");
+	for (i = 0; i < 6; i++) {
+		printk(KERN_INFO "%02x", (unsigned char)add[i]);
+		printk((i < 5) ? KERN_INFO ":" : KERN_INFO "\n");
+	}
+
+	printk(KERN_INFO "==>  src: ");
+	for (i = 0; i < 6; i++) {
+		printk(KERN_INFO "%02x", (unsigned char)add[i + 6]);
+		printk((i < 5) ? KERN_INFO ":" : KERN_INFO "\n");
+	}
+	lentyp = ((unsigned char)add[12] << 8) | (unsigned char)add[13];
+	if (lentyp <= 1500)
+		printk(KERN_INFO "==>  len: %d\n", lentyp);
+	else if (lentyp > 1535)
+		printk(KERN_INFO "==> type: 0x%04x\n", lentyp);
+	else
+		printk(KERN_INFO "==> ltyp: 0x%04x\n", lentyp);
+
+	if (len > 0x100)
+		len = 0x100;
+
+	for (i = 0; i < ((u32)add & 0x0000000F); i++)
+		printk(KERN_INFO "   ");
+	for (i = 0; i < len; i++, add++) {
+		printk(KERN_INFO " %02x", *((unsigned char *)add));
+		if (!(((u32)add + 1) % 16))
+			printk(KERN_INFO "\n");
+	}
+	printk(KERN_INFO "\n");
+}
+
+/*
+ * Used mainly for debugging unusual conditions signalled by a
+ * fatal error interrupt (eg, IntBLEx). This function stops the transmit
+ * and receive in an attempt to capture the true state of the queues
+ * at the time of the interrupt.
+ */
+#undef MSPETH_DUMP_QUEUES
+#ifdef MSPETH_DUMP_QUEUES
+static void
+dump_blist(struct bl_desc *fd)
+{
+	int i;
+
+	printk(KERN_INFO "  bl_desc(%p): %08x %08x %08x %08x\n",
+		fd, fd->fd.FDNext,
+			fd->fd.FDSystem, fd->fd.FDStat, fd->fd.FDCtl);
+	for (i = 0; i < RX_BUF_NUM << 1; i++)
+		printk(KERN_INFO "    BD #%d: %08x %08x\n",
+			i, fd->bd[i].BuffData, fd->bd[i].BDCtl);
+}
+
+/* Catalog the received buffers numbers */
+static int rx_bdnums[2][RX_BUF_NUM << 2];
+static int rx_bdnums_ind[2] = {0, 0};
+static inline void
+catalog_rx_bdnum(int hwnum, int bdnum)
+{
+	rx_bdnums_ind[hwnum] = (rx_bdnums_ind[hwnum] + 1) &
+				((RX_BUF_NUM << 2) - 1);
+	rx_bdnums[hwnum][rx_bdnums_ind[hwnum]] = bdnum;
+}
+
+static void
+mspeth_dump_queues(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int unit = lp->unit;
+	int i;
+
+	/* Halt Xmit and Recv to preserve the state of queues */
+	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) & ~Rx_RxEn);
+	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) & ~Tx_En);
+
+	/* Print receive queue */
+	printk(KERN_INFO "Receive Queue\n");
+	printk(KERN_INFO "=============\n\n");
+	printk(KERN_INFO "rxfd_base = 0x%08x\n",
+		(unsigned int) lp->rxfd_base);
+	printk(KERN_INFO "rxfd_curr = 0x%08x\n",
+		(unsigned int) lp->rxfd_curr);
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		printk(KERN_INFO "%d:", i);
+		dump_qdesc((struct q_desc *) &lp->rxfd_base[i]);
+	}
+
+	/* Print transmit queue */
+	printk(KERN_INFO "\nTransmit Queue\n");
+	printk(KERN_INFO "==============\n");
+	printk(KERN_INFO "txfd_base = 0x%08x\n",
+		(unsigned int) lp->txfd_base);
+	printk(KERN_INFO "tx_head = %d, tx_tail = %d\n",
+		lp->tx_head, lp->tx_tail);
+	for (i = 0; i < TX_BUF_NUM; i++) {
+		printk(KERN_INFO "%d:", i);
+		dump_qdesc((struct q_desc *) &lp->txfd_base[i]);
+	}
+
+	/* Print the free buffer list */
+	printk(KERN_INFO "\nFree Buffer List\n");
+	printk(KERN_INFO "================\n");
+	printk(KERN_INFO "blfd_ptr = 0x%08x\n", (unsigned int) lp->blfd_ptr);
+	dump_blist(lp->blfd_ptr);
+
+	/* Print the bdnum history and current index as a reference */
+	printk(KERN_INFO "\nbdnum history\n");
+	printk(KERN_INFO "=============\n");
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		printk(KERN_INFO "\t%d\t%d\t%d\t%d\n",
+			rx_bdnums[unit][4 * i],
+			rx_bdnums[unit][4 * i + 1],
+			rx_bdnums[unit][4 * i + 2],
+			rx_bdnums[unit][4 * i + 3]);
+	}
+	printk(KERN_INFO "Current bdnum index: %d\n", rx_bdnums_ind[unit]);
+
+	/* Re-enable Xmit/Recv */
+	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) | Rx_RxEn);
+	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) | Tx_En);
+}
+
+static void
+mspeth_dump_stats(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+
+	printk(KERN_INFO "Interface stats:\n");
+	printk(KERN_INFO "\ttx_ints: %d\n", lp->lstats.tx_ints);
+	printk(KERN_INFO "\trx_ints: %d\n", lp->lstats.rx_ints);
+	printk(KERN_INFO "\ttx_full: %d\n", lp->lstats.tx_full);
+	printk(KERN_INFO "\tfd_exha: %d\n", lp->lstats.fd_exha);
+}
+#else
+#define mspeth_dump_stats(a) do {} while (0)
+#define mspeth_dump_queues(a) do {} while (0)
+#define catalog_rx_bdnum(a, b) do {} while (0)
+#define dump_blist(a) do {} while (0)
+#endif /* MSPETH_DUMP_QUEUES */
+
+/*
+ * Actual functions used in the driver are defined here. They should
+ * all start with mspeth.
+ */
+
+/**************************************************************************
+ * Check for an mspeth ethernet device and return 0 if there is one.
+ * Also a good time to fill out some of the device fields and do some
+ * preliminary initialization. The mspeth resources are statically
+ * allocated.
+ */
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+int mspeth_probe(struct platform_device *pldev)
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+int __init mspeth_probe(struct net_device *dev)
+#endif
+{
+	int unit, hwunit;
+	int i, err;
+	u8 macaddr[8];
+	struct mspeth_priv *lp;
+	char tmp_str[128];
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	struct net_device *dev = NULL;
+	struct resource *res;
+	void *mapaddr;
+	unit = pldev->id;
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	sscanf(dev->name, "eth%d", &unit);
+#endif
+
+	/* default return value -- no device here */
+	err = -ENODEV;
+
+	/*
+	 * Scan the hardware list and associate a logical unit with a
+	 * hardware unit it's important to keep these two straight.
+	 * hwunit is used for accessing the prom and all hardware.
+	 * unit is used when parsing the commandline and any other
+	 * uses that might refer to *all* eth devices (not just mspeth
+	 * devices) in the system.
+	 */
+	for (i = 0, hwunit = 0; hwunit < MSPETH_MAX_UNITS; hwunit++) {
+		if (identify_enet(hwunit) != FEATURE_NOEXIST)
+			if (i++ == unit)
+				break;
+	}
+
+	/* Sanity checks on hardware parameters */
+	if (unit < 0 || hwunit >= MSPETH_MAX_UNITS)
+		goto out_err;
+
+	/* Retrieve the mac address from the PROM */
+	snprintf(tmp_str, 128, "ethaddr%d", hwunit);
+	if (get_ethernet_addr(tmp_str, macaddr)) {
+		printk(KERN_WARNING "MSPETH(probe): "
+			"No Mac addr specified for eth%d, hwunit %d\n",
+			unit, hwunit);
+		goto out_err;
+	}
+
+	if (macaddr[0] & 0x01) {
+		printk(KERN_WARNING "MSPETH(probe): "
+			"Bad Multicast Mac addr specified for eth%d, "
+			"hwunit %d %02x:%02x:%02x:%02x:%02x:%02x\n",
+			unit, hwunit,
+			macaddr[0], macaddr[1], macaddr[2],
+			macaddr[3], macaddr[4], macaddr[5]);
+		goto out_err;
+	}
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	dev = alloc_etherdev(sizeof(struct mspeth_priv));
+	if (!dev) {
+		err = -ENOMEM;
+		goto out_err;
+	}
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pldev->dev);
+	dev_set_drvdata(&pldev->dev, dev);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	/* Create & initialize the local device structure */
+	if (dev->priv == NULL) {
+		dev->priv = kmalloc(sizeof(struct mspeth_priv),
+					GFP_KERNEL);
+		if (dev->priv == NULL)
+			goto out_err;
+	}
+#endif
+
+	lp = netdev_priv(dev);
+	memset(lp, 0, sizeof(struct mspeth_priv));
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	lp->dev = &pldev->dev;
+
+	res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
+	if (!res) {
+		printk(KERN_ERR "MSPETH(probe) %s: "
+			"IOMEM resource not found for eth%d\n",
+			dev->name, unit);
+		goto out_netdev;
+	}
+	
+	/* reserve the memory region */
+	if (!request_mem_region(res->start, res->end - res->start + 1,
+				cardname)) {
+		printk(KERN_ERR "MSPETH(probe) %s: unable to "
+			"get memory/io address region 0x08%lx\n",
+			dev->name, dev->base_addr);
+		goto out_netdev;
+	}
+
+	/* remap the memory */
+	mapaddr = ioremap_nocache(res->start, res->end - res->start + 1);
+	if (!mapaddr) {
+		printk(KERN_WARNING "MSPETH(probe) %s: "
+			"unable to ioremap address 0x%08x\n",
+			dev->name, res->start);
+		goto out_unreserve;
+	}
+	
+	lp->mapaddr = mapaddr;
+	dev->base_addr = res->start;
+	dev->irq = platform_get_irq(pldev, 0);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	/*
+	 * Dig out the parameters from the defines and do other
+	 * hwunit specific stuff
+	 */
+	switch (hwunit) {
+	case 0:
+		dev->base_addr = MSP_MAC0_BASE;
+		dev->irq = MSP_INT_MAC0;
+		break;
+	case 1:
+		dev->base_addr = MSP_MAC1_BASE;
+		dev->irq = MSP_INT_MAC1;
+		break;
+	case 2:
+		dev->base_addr = MSP_MAC2_BASE;
+		dev->irq = MSP_INT_MAC2;
+		break;
+	default:
+		printk(KERN_WARNING "MSPETH(probe): "
+			"Unsupported hardware unit %d\n", hwunit);
+		goto out_unmap;
+	}
+
+	/* reserve the memory region */
+	if (!request_mem_region(dev->base_addr, MSP_MAC_SIZE, cardname)) {
+		printk(KERN_ERR "MSPETH(probe) %s: unable to "
+			"get memory/io address region 0x08%lx\n",
+			dev->name, dev->base_addr);
+		goto out_err;
+	}
+
+	/* remap the memory */
+	lp->mapaddr = ioremap_nocache(dev->base_addr, MSP_MAC_SIZE);
+	if (!lp->mapaddr) {
+		printk(KERN_ERR "MSPETH(probe) %s: unable to "
+			"ioremap address 0x%08lx\n",
+			dev->name, dev->base_addr);
+		goto out_unreserve;
+	}
+#endif
+	
+	/* remap the system reset registers */
+	lp->rstaddr = ioremap_nocache(MSP_RST_BASE, MSP_RST_SIZE);
+	if (!lp->rstaddr) {
+		printk(KERN_ERR "MSPETH(probe) %s: unable to "
+			"ioremap address 0x%08x\n",
+			dev->name, MSP_RST_BASE);
+		goto out_unmap;
+	}
+
+	/* set the logical and hardware units */
+	lp->unit = unit;
+	lp->hwunit = hwunit;
+
+	/* probe for PHYS attached to this MACs MDIO interface */
+	if (mspeth_phyprobe(dev))
+		goto out_unmap;
+
+	/* parse the environment and command line */
+	mspeth_init_cmdline(dev);
+	mspeth_init_phyaddr(dev);
+
+	/* MAC address */
+	dev->addr_len = ETH_ALEN;
+	for (i = 0; i < dev->addr_len; i++)
+		dev->dev_addr[i] = macaddr[i];
+
+	/* register the /proc entry */
+	snprintf(tmp_str, 128, "pmcmspeth%d", unit);
+	create_proc_read_entry(tmp_str, 0644, proc_net,
+				mspeth_proc_info, dev);
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+	ether_setup(dev);
+#endif
+	/* set the various call back functions */
+	dev->open		= mspeth_open;
+	dev->stop		= mspeth_close;
+	dev->tx_timeout		= mspeth_tx_timeout;
+	dev->watchdog_timeo	= TX_TIMEOUT * HZ;
+	dev->hard_start_xmit	= mspeth_send_packet;
+	dev->get_stats		= mspeth_get_stats;
+	dev->set_multicast_list = mspeth_set_multicast_list;
+#ifdef CONFIG_MSPETH_NAPI
+	dev->poll		= mspeth_poll;
+	dev->weight		= NAPI_WEIGHT;
+#endif
+
+	/* debugging output */
+	printk(KERN_INFO
+		"eth%d: found at physical address %lx, irq %d\n",
+		unit, dev->base_addr, dev->irq);
+	if (mspeth_debug > 1) {
+		printk(KERN_INFO "MSPETH(probe) eth%d: "
+			"associated with hardware unit %d\n",
+			unit, hwunit);
+		printk(KERN_INFO "MSPETH(probe) eth%d: assigned "
+			"MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+			unit, macaddr[0], macaddr[1], macaddr[2],
+			macaddr[3], macaddr[4], macaddr[5]);
+		printk(KERN_INFO "MSPETH(probe) eth%d: "
+			"phytype %c, phyclk %c\n",
+			unit, identify_enet(hwunit),
+			identify_enetTxD(hwunit));
+	}
+
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	/* initialize the socket buffer recycle bin */
+	init_skbuff_bin();
+#endif
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_WARNING "MSPETH(probe) eth%d: "
+			"unable to register network device\n", unit);
+		goto out_unmap;
+	}
+#endif
+
+	return 0;
+
+out_unmap:
+	if (lp->rstaddr)
+		iounmap(lp->rstaddr);	
+	iounmap(lp->mapaddr);
+	
+out_unreserve:
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	release_mem_region(res->start, res->end - res->start + 1);
+
+out_netdev: 
+	free_netdev(dev);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	release_mem_region(dev->base_addr, MSP_MAC_SIZE);
+#endif
+
+out_err:
+	return err;
+}
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+/**************************************************************************
+ * Release the mspeth ethernet device and return 0 if there is one.
+ */
+static int
+mspeth_remove(struct platform_device *pldev)
+{
+	struct net_device *dev = dev_get_drvdata(&pldev->dev);
+	struct mspeth_priv *lp = netdev_priv(dev);
+	struct mspeth_phy **tail_pp;
+
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	skb_bin.user_count--;
+	if (skb_bin.user_count == 0) {
+		/* free the recycle bin */
+		free_skbuff_bin();
+	}
+#endif
+
+	for (tail_pp = &root_phy_dev; *tail_pp != NULL; ) {
+		struct mspeth_phy **next_pp = &((*tail_pp)->next_phy);
+		kfree(*tail_pp);
+		tail_pp = next_pp;
+	}
+
+	unregister_netdev(dev);
+		
+	iounmap(lp->rstaddr);
+	lp->rstaddr = NULL;
+	iounmap(lp->mapaddr);
+	lp->mapaddr = NULL;
+	release_mem_region(dev->base_addr, MSP_MAC_SIZE);
+
+	free_netdev(dev);
+	
+	return 0;	
+}
+#endif
+
+/**************************************************************************
+ * Probe the hardware and fill out the array of PHY control elements
+ */
+static int
+mspeth_phyprobe(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 reg1;
+	int phyaddr;
+	struct mspeth_phy tmp_phy;
+	struct mspeth_phy **tail_pp;
+
+	tmp_phy.next_phy = NULL;
+	tmp_phy.hwunit = lp->hwunit;
+	tmp_phy.phyaddr = 0;
+	tmp_phy.memaddr = lp->mapaddr + MSPETH_MD_DATA;
+	tmp_phy.assigned = false;
+	tmp_phy.linkup = false;
+	spin_lock_init(&tmp_phy.lock);
+
+	/* find the tail of the phy list */
+	for (tail_pp = &root_phy_dev; *tail_pp != NULL;
+		tail_pp = &((*tail_pp)->next_phy)) {;}
+
+	/* probe the phys and add to list */
+	for (phyaddr = 0; phyaddr < MD_MAX_PHY; phyaddr++) {
+		tmp_phy.phyaddr = phyaddr;
+		reg1 = mspphy_read(&tmp_phy, MII_BMSR);
+
+		if ((reg1 & BMSR_EXISTS) &&
+		    reg1 != 0xffff && reg1 != 0xc000) {
+			if (mspeth_debug > 1)
+				printk(KERN_INFO "MSPETH(phyprobe): "
+					"phyaddr = %d, hwindex = %d has "
+					"phy status 0x%04x\n",
+					phyaddr, lp->hwunit, reg1);
+
+			*tail_pp = kmalloc(sizeof(struct mspeth_phy),
+						GFP_KERNEL);
+			if (!*tail_pp) {
+				printk(KERN_WARNING "MSPETH(phyprobe) "
+					"eth%d: unable to allocate phy\n",
+					lp->hwunit);
+				return -1;
+			}
+
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
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int hwunit;
+	int phyaddr;
+	char *phystr;
+	char name[80];
+
+	/* defaults */
+	lp->phyptr = NULL;
+
+	/* new style enviroment scan to determine the phy addresses */
+	sprintf(name, "phyaddr%d", lp->hwunit);
+	phystr = prom_getenv(name);
+
+	if (mspeth_debug > 0)
+		printk(KERN_INFO "MSPETH(init_phyaddr): "
+			"hwunit = %d, phystr prom = \"%s\"\n",
+			lp->hwunit, phystr);
+
+	if (phystr != NULL &&
+	    sscanf(phystr, "%d:%d", &hwunit, &phyaddr) == 2 &&
+	    hwunit < MSPETH_MAX_UNITS &&
+	    (phyaddr < MD_MAX_PHY || phyaddr == MD_DYNAMIC_PHY)) {
+		/*
+		 * Look through the phylist and find a phy that matches
+		 * the PROM settings
+		 */
+		for (lp->phyptr = root_phy_dev; lp->phyptr != NULL;
+				lp->phyptr = lp->phyptr->next_phy) {
+			if (lp->phyptr->phyaddr == phyaddr &&
+			    lp->phyptr->hwunit == hwunit) {
+				if (lp->phyptr->assigned) {
+					lp->phyptr = NULL;
+					printk(KERN_WARNING
+						"MSPETH(init_phyaddr) %s: "
+						"PROM phyaddress is already "
+						"in use!\
+						phystr prom = \"%s\"\n",
+						dev->name, phystr);
+				} else
+					lp->phyptr->assigned = true;
+
+				break;
+			}
+		}
+	} else {
+		/*
+		 * No acceptable PROM settings so we have to make
+		 * something up
+		 */
+		if (lp->option & MSP_OPT_SWITCH) {
+			/*
+			 * Commandline set us to a switch so no phy
+			 * settings required. Consider changing this later
+			 * so that we can access the registers in the
+			 * switch through MDIO etc. Could be autoprobed too.
+			 */
+		} else {
+			/*
+			 * Search through the list of phys and use the
+			 * first unassigned one. We need some way of
+			 * determining which phy is connected to which
+			 * MAC other than first come, first serve.
+			 *
+			 * stjeanma, 2006-02-13:
+			 * We must keep all PHYs on a global list for
+			 * boards which have all PHY MDIOs hooked to a
+			 * single MAC. However for boards with PHYs hooked
+			 * up to inidvidual MACs, we must first search the
+			 * list for PHYs belonging to the MAC being
+			 * initialized.
+			 */
+			for (lp->phyptr = root_phy_dev; lp->phyptr != NULL;
+					lp->phyptr = lp->phyptr->next_phy) {
+				if (!lp->phyptr->assigned &&
+				    lp->phyptr->hwunit == lp->hwunit) {
+					lp->phyptr->assigned = true;
+					break;
+				}
+			}
+
+			if (lp->phyptr == NULL) {
+				for (lp->phyptr = root_phy_dev;
+				     lp->phyptr != NULL;
+				     lp->phyptr = lp->phyptr->next_phy) {
+					if (!lp->phyptr->assigned) {
+						lp->phyptr->assigned = true;
+						break;
+					}
+				}
+			}
+		}
+
+		/* rudimentary error checking */
+		if (phystr != NULL)
+			printk(KERN_WARNING "MSPETH(init_phyaddr) "
+				"eth%d: bad phyaddr value %s\n",
+				lp->unit, phystr);
+	}
+}
+
+/**************************************************************************
+ * Scan the environment to get the kernel command line options
+ * for ethernet.
+ */
+static void
+mspeth_init_cmdline(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int index;
+	int unit;
+	char c = ' ';
+	char command_line[COMMAND_LINE_SIZE];
+	char *ptr = command_line;
+	char *ethptr = NULL;
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
+				break;
+			}
+
+			if (c == ':') {
+				index++;
+				if (index == 5) {
+					if (memcmp(ptr, "eth", 3) != 0)
+						break;
+
+					ethptr = &ptr[3];
+					ptr = ethptr;
+				}
+
+				if (index == 6) {
+					*--ptr = '\0';
+					ptr++;
+					unit = simple_strtol(
+							ethptr, NULL, 0);
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
+			if (memcmp(ethptr, "100fs", 5) == 0)
+				/* 100M full-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_FDUP |
+						MSP_OPT_SWITCH;
+			else if (memcmp(ethptr, "100hs", 5) == 0)
+				/* 100M half-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP |
+						MSP_OPT_SWITCH;
+			else if (memcmp(ethptr, "10fs", 4) == 0)
+				/* 10M full-duplex switch */
+				lp->option = MSP_OPT_10M | MSP_OPT_FDUP |
+						MSP_OPT_SWITCH;
+			else if (memcmp(ethptr, "10hs", 4) == 0)
+				/* 10M half-duplex switch */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP |
+						MSP_OPT_SWITCH;
+			else if (memcmp(ethptr, "100f", 4) == 0)
+				/* 100M full-duplex */
+				lp->option = MSP_OPT_100M | MSP_OPT_FDUP;
+			else if (memcmp(ethptr, "100h", 4) == 0)
+				/* 100M half-duplex */
+				lp->option = MSP_OPT_100M | MSP_OPT_HDUP;
+			else if (memcmp(ethptr, "10f", 3) == 0)
+				/* 10M full-duplex */
+				lp->option = MSP_OPT_10M | MSP_OPT_FDUP;
+			else if (memcmp(ethptr, "10h", 3) == 0)
+				/* 100M half-duplex */
+				lp->option = MSP_OPT_10M | MSP_OPT_HDUP;
+		}
+
+		if (mspeth_debug > 0)
+			printk(KERN_INFO "MSPETH(init_cmdline) eth%d: "
+				"boot = %s, option = %02x\n",
+				lp->unit, command_line, lp->option);
+	}
+}
+
+/**************************************************************************
+ * Reset the phy
+ */
+static void
+mspeth_phy_reset(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 id0, id1;
+
+	if (lp->phyptr == NULL)
+		return;
+
+	/* reset the phy */
+	mspphy_write(lp->phyptr, MII_BMCR, BMCR_RESET);
+	while ((mspphy_read(lp->phyptr, MII_BMCR) & BMCR_RESET) != 0)
+		udelay(100);
+
+	if (mspeth_debug > 0) {
+		id0 = mspphy_read(lp->phyptr, MII_PHYSID1);
+		id1 = mspphy_read(lp->phyptr, MII_PHYSID2);
+		printk(KERN_INFO "MSPETH(phy_reset) eth%d: "
+			"PHY ID %04x %04x\n", lp->unit, id0, id1);
+		printk(KERN_INFO "MSPETH(phy_reset) eth%d: "
+			"speed = %d, duplex = %s\n", lp->unit, lp->speed,
+			((lp->fullduplex) ? "FULL" : "HALF"));
+	}
+}
+
+/**************************************************************************
+ * Initialize the phy -- set the speed and duplex. Wait for
+ * autonegotiation to complete. If it doesn't then force the
+ * renegotiation. If *that* fails then reset the phy and try
+ * again. Finally just make some assumptions. If autonegotiation
+ * is disabled then just force values.
+ */
+static void
+mspeth_phy_init(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 ctl, neg_result;
+	int i;
+	enum {AUTONEG, AUTONEG_FORCE, PHYRESET} auto_status;
+	char *link_type;
+	char *link_stat;
+
+	/* check for defaults and autonegotiate */
+	if (lp->option == MSP_OPT_AUTO) {
+		/*
+		 * Make sure the autonegotiation is enabled and then wait
+		 * for the autonegotion to complete.
+		 */
+		link_type = "Autoneg";
+		for (auto_status = AUTONEG; auto_status <= PHYRESET;
+						auto_status++) {
+			/*
+			 * Run through all the various autonegotion methods
+			 * until we fail
+			 */
+			switch (auto_status) {
+			case AUTONEG:
+				mspphy_write(lp->phyptr, MII_BMCR,
+						BMCR_ANENABLE);
+				break;
+			case AUTONEG_FORCE:
+				printk(KERN_INFO "MSPETH(phy_init) "
+					"%s: Forcing autonegotiation\n",
+					dev->name);
+				mspphy_write(lp->phyptr, MII_BMCR,
+					BMCR_ANENABLE | BMCR_ANRESTART);
+				break;
+			case PHYRESET:
+				printk(KERN_INFO "MSPETH(phy_init) "
+					"%s: Resetting phy\n", dev->name);
+				mspphy_write(lp->phyptr, MII_BMCR,
+						BMCR_RESET);
+				while ((mspphy_read(lp->phyptr, MII_BMCR) &
+					BMCR_RESET) != 0)
+					udelay(100);
+				mspphy_write(lp->phyptr, MII_BMCR,
+					BMCR_ANENABLE | BMCR_ANRESTART);
+				break;
+			default:
+				printk(KERN_WARNING "MSPETH(phy_init) "
+					"%s: Unknown autonegotation mode?\n",
+					dev->name);
+				return;
+			}
+
+			/*
+			 * Autoneg should be underway, so lets loop
+			 * and wait for it to exit.
+			 */
+			printk(KERN_INFO
+				"%s: Auto Negotiation...", dev->name);
+
+			for (i = 0; i < 2000 &&
+				    !(mspphy_read(lp->phyptr, MII_BMSR) &
+				    BMSR_ANEGCOMPLETE); i++) {
+				mdelay(1);
+			}
+
+			if (i == 2000) {
+				/*
+				 * Autonegotiation failed to complete so
+				 * go to next level of negotiation.
+				 */
+				printk(KERN_INFO " failed.\n");
+				continue;
+			}
+
+			/* must have succeeded so we can set the speed etc */
+			printk(KERN_INFO " done.\n");
+			neg_result = mspphy_read(lp->phyptr, MII_LPA);
+			if (neg_result & (LPA_100FULL | LPA_100HALF))
+				lp->speed = 100;
+			else
+				lp->speed = 10;
+
+			if (neg_result & (LPA_100FULL | LPA_10FULL))
+				lp->fullduplex = true;
+			else
+				lp->fullduplex = false;
+			break;
+		}
+
+		/*
+		 * Check to see if *everything* failed and try to set
+		 * some default values.
+		 */
+		if (auto_status > PHYRESET) {
+			printk(KERN_WARNING "Autonegotion failed. "
+				"Assuming 10Mbps, half-duplex.\n");
+			link_type = "Autoneg (failed)";
+			lp->speed = 10;
+			lp->fullduplex = false;
+		}
+	} else {
+		/*
+		 * If speed and duplex are statically configured then
+		 * set that here.
+		 */
+		link_type = "Static";
+		ctl = 0;
+		if (lp->option & MSP_OPT_100M) {
+			lp->speed = 100;
+			ctl |= BMCR_SPEED100;
+		} else {
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
+			mspphy_write(lp->phyptr, MII_BMCR, ctl);
+	}
+
+	if (!(lp->option & MSP_OPT_SWITCH)) {
+		/*
+		 * Wait for a little bit to see if we've got a carrier
+		 * -- don't go crazy though.
+		 */
+		printk(KERN_INFO
+			"%s: Waiting for carrier ...", dev->name);
+		for (i = 0; i < 1000 &&
+			    !(mspphy_read(lp->phyptr, MII_BMSR) &
+			    BMSR_LSTATUS); i++) {
+			mdelay(1);
+		}
+
+		if (i == 1000) {
+			printk(KERN_INFO " no carrier.\n");
+			lp->phyptr->linkup = false;
+			netif_carrier_off(dev);
+			link_stat = "Link down";
+		} else {
+			printk(KERN_INFO " carrier detected.\n");
+			lp->phyptr->linkup = true;
+			netif_carrier_on(dev);
+			link_stat = "Link up";
+		}
+	} else {
+
+		/*
+		 * Assume we're connected. If we're using a switch
+		 * we always will be.
+		 */
+		printk(KERN_INFO
+			"%s: Using internal switch\n", dev->name);
+
+		/* stjeanma: PHY might not be allocated for a switch */
+		if (lp->phyptr != NULL)
+			lp->phyptr->linkup = true;
+
+		/* Turn on the carrier */
+		netif_carrier_on(dev);
+		link_stat = "Link up";
+	}
+
+	/*
+	 * Configure the MAC with the duplex setting
+	 * -- it doesn't care about speed.
+	 */
+	if (lp->fullduplex)
+		msp_write(lp, MSPETH_MAC_Ctl,
+			msp_read(lp, MSPETH_MAC_Ctl) | MAC_FullDup);
+	else
+		msp_write(lp, MSPETH_MAC_Ctl,
+			msp_read(lp, MSPETH_MAC_Ctl) & ~MAC_FullDup);
+
+	printk(KERN_INFO
+		"%s: %s, %s, linkspeed %dMbps, %s Duplex\n",
+		dev->name, link_type, link_stat, lp->speed,
+		(lp->fullduplex) ? "Full" : "Half");
+}
+
+/**************************************************************************
+ * Check the link for a carrier when the link check timer expires.
+ * If the link is down and it has been down for a while (at least 1
+ * timer delay) then change the upper layer link state to match.
+ * Do a soft-restart if we're bringing the link up. Reschedule the
+ * timer of course.
+ */
+static void
+mspeth_link_check(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mspeth_priv *lp = netdev_priv(dev);
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
+		/*
+		 * Upper layer thinks we're ok but the link is bad, so
+		 * take the link down.
+		 */
+		if (linkstatus == LINKBAD) {
+			printk(KERN_INFO "MSPETH(link_check) %s: "
+				"NO LINK DETECTED\n", dev->name);
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
+		}
+	} else {
+		/*
+		 * Upper layer thinks we're broken but we've recovered so
+		 * do a soft-restart and bring the link back up.
+		 */
+		if (linkstatus == LINKGOOD) {
+			printk(KERN_INFO "MSPETH(link_check) %s: "
+				"LINK DETECTED\n", dev->name);
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
+/**************************************************************************
+ * Reset the hardware and restore defaults. Queues etc must be
+ * cleared afterwards, although we don't change the pointers so
+ * they don't need to be reallocated.
+ */
+static void
+mspeth_mac_reset(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int i;
+	u32 rstpat;
+
+	/* hardware reset */
+	switch (lp->hwunit) {
+	case 0:
+		rstpat = MSP_EA_RST;
+		break;
+	case 1:
+		rstpat = MSP_EB_RST;
+		break;
+	case 2:
+		rstpat = MSP_EC_RST;
+		break;
+	default:
+		printk(KERN_WARNING
+			"MSPETH(mac_reset) %s: Unsupported hwunit %d\n",
+			dev->name, lp->hwunit);
+		return;
+	}
+	
+	__raw_writel(rstpat, lp->rstaddr + MSPRST_SET);
+	mdelay(100);
+	__raw_writel(rstpat, lp->rstaddr + MSPRST_CLR);
+
+	/* Wait for the MAC to come out of reset */
+	for (i = 0; i < 10; i++) {
+		if ((__raw_readl(lp->rstaddr + MSPRST_STS) & rstpat) == 0)
+			break;
+		ndelay(100);
+	}
+
+	/* initialize registers to default value */
+	msp_write(lp, MSPETH_MAC_Ctl, 0);
+	msp_write(lp, MSPETH_DMA_Ctl, 0);
+	msp_write(lp, MSPETH_TxThrsh, 0);
+	msp_write(lp, MSPETH_TxPollCtr, 0);
+	msp_write(lp, MSPETH_RxFragSize, 0);
+	msp_write(lp, MSPETH_Int_En, 0);
+	msp_write(lp, MSPETH_FDA_Bas, 0);
+	msp_write(lp, MSPETH_FDA_Lim, 0);
+	msp_write(lp, MSPETH_Int_Src, 0xffffffff); /* Write 1 to clear */
+	msp_write(lp, MSPETH_ARC_Ctl, 0);
+	msp_write(lp, MSPETH_Tx_Ctl, 0);
+	msp_write(lp, MSPETH_Rx_Ctl, 0);
+	msp_write(lp, MSPETH_ARC_Ena, 0);
+	(void)msp_read(lp, MSPETH_Miss_Cnt);	/* Read to clear */
+}
+
+/**************************************************************************
+ * Initialize the hardware and start the DMA/MAC RX/TX. The queues must
+ * be setup before this is called.
+ */
+static void
+mspeth_mac_init(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int flags;
+
+	/* do not interrupt me while I'm configuring the MAC */
+	local_irq_save(flags);
+
+	/* configure the BRCTL RMII registers if we're an RMII device */
+	if (identify_enet(lp->hwunit) == ENET_RMII) {
+		u32 brctl = msp_read(lp, MSPETH_BCTRL_Reg) & ~RMII_Reset;
+		if (identify_enetTxD(lp->hwunit) == ENETTXD_RISING)
+			brctl |= RMII_ClkRising;
+		if (identify_enetTxD(lp->hwunit) == ENETTXD_FALLING)
+			brctl &= ~RMII_ClkRising;
+		if (lp->speed == 10)
+			brctl |= RMII_10MBIT;
+		else
+			brctl &= ~RMII_10MBIT;
+		msp_write(lp, MSPETH_BCTRL_Reg, brctl);
+	}
+
+	/* set some device structure parameters */
+	dev->tx_queue_len = TX_BUF_NUM;
+
+	/* load station address to ARC */
+	mspeth_set_arc_entry(dev, ARC_ENTRY_SOURCE, dev->dev_addr);
+
+	/* Enable ARC (broadcast and unicast) */
+	msp_write(lp, MSPETH_ARC_Ena, ARC_Ena_Bit(ARC_ENTRY_SOURCE));
+	msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
+
+	/* configure DMA */
+	msp_write(lp, MSPETH_DMA_Ctl, DMA_CTL_CMD);
+
+	/* configure the RX/TX mac */
+	msp_write(lp, MSPETH_RxFragSize, 0);
+	msp_write(lp, MSPETH_TxPollCtr, TX_POLL_CNT);
+	msp_write(lp, MSPETH_TxThrsh, TX_THRESHOLD);
+
+	/* zero and enable the interrupts */
+	lp->fatal_icnt = 0;
+	msp_write(lp, MSPETH_Int_En, INT_EN_CMD);
+
+	/*
+	 * Set queues
+	 *
+	 * hammtrev, 2005-11-25:
+	 * Using the formula used in the old driver, which gives a
+	 * little bit less than (RX_BUF_NUM - 1) << 5, allowing for more
+	 * buffer descriptors attached to a frame descriptor.
+	 */
+	msp_write(lp, MSPETH_FDA_Bas, (u32)lp->rxfd_base);
+	msp_write(lp, MSPETH_FDA_Lim, (RX_BUF_NUM - 1) << 5);
+
+	/*
+	 * Activation method:
+	 * First, enable the MAC Transmitter and the DMA Receive circuits.
+	 * Then enable the DMA Transmitter and the MAC Receive circuits.
+	 */
+	/* start DMA receiver */
+	msp_write(lp, MSPETH_BLFrmPtr, (u32)lp->blfd_ptr);
+	/* start MAC receiver */
+	msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD);
+
+	/* start the DMA transmitter */
+	msp_write(lp, MSPETH_TxFrmPtr, (u32)lp->txfd_base);
+
+#ifdef CONFIG_MSPETH_NAPI
+	/* start the MAC transmitter */
+	msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+#else
+	msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD);
+#endif /* CONFIG_MSPETH_NAPI */
+
+	/* turn the interrupts back on */
+	local_irq_restore(flags);
+}
+
+/**************************************************************************
+ * Start the Address Recognition circuit. It must be initialized with
+ * address of the device (which can be changed in the PROM).
+ */
+static void
+mspeth_set_arc_entry(struct net_device *dev, int index, unsigned char *addr)
+{
+	int arc_index = index * 6;
+	unsigned long arc_data;
+	unsigned long saved_addr;
+	struct mspeth_priv *lp = netdev_priv(dev);
+
+	saved_addr = msp_read(lp, MSPETH_ARC_Adr);
+
+	if (mspeth_debug > 1) {
+		int i;
+		printk(KERN_INFO "MSPETH(set_arc_entry) %s: "
+			"arc %d:", dev->name, index);
+		for (i = 0; i < 6; i++)
+			printk(KERN_INFO " %02x", addr[i]);
+		printk(KERN_INFO "\n");
+	}
+
+	if (index & 1) {
+		/* read modify write */
+		msp_write(lp, MSPETH_ARC_Adr, arc_index - 2);
+		arc_data = msp_read(lp, MSPETH_ARC_Data) & 0xffff0000;
+		arc_data |= addr[0] << 8 | addr[1];
+		msp_write(lp, MSPETH_ARC_Data, arc_data);
+
+		/* write whole word */
+		msp_write(lp, MSPETH_ARC_Adr, arc_index + 2);
+		arc_data = (addr[2] << 24) | (addr[3] << 16) |
+				(addr[4] << 8) | addr[5];
+		msp_write(lp, MSPETH_ARC_Data, arc_data);
+	} else {
+		/* write whole word */
+		msp_write(lp, MSPETH_ARC_Adr, arc_index);
+		arc_data = (addr[0] << 24) | (addr[1] << 16) |
+				(addr[2] << 8) | addr[3];
+		msp_write(lp, MSPETH_ARC_Data, arc_data);
+
+		/* read modify write */
+		msp_write(lp, MSPETH_ARC_Adr, arc_index + 4);
+		arc_data = msp_read(lp, MSPETH_ARC_Data) & 0x0000ffff;
+		arc_data |= addr[4] << 24 | (addr[5] << 16);
+		msp_write(lp, MSPETH_ARC_Data, arc_data);
+	}
+
+	if (mspeth_debug > 2) {
+		int i;
+		for (i = arc_index / 4; i < arc_index / 4 + 2; i++) {
+			msp_write(lp, MSPETH_ARC_Adr, i * 4);
+			printk(KERN_INFO "arc 0x%x: %08x\n",
+				i * 4, msp_read(lp, MSPETH_ARC_Data));
+		}
+	}
+	msp_write(lp, MSPETH_ARC_Adr, saved_addr);
+}
+
+/**************************************************************************
+ * Initialize the RX/TX queues and the free buffer list. This routine
+ * allocates memory and care must be taken to free the memory when it
+ * is no longer required
+ */
+static bool
+mspeth_init_queues(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int i, size;
+	u32 tmp_addr;
+	struct sk_buff *skb;
+	dma_addr_t dma_skb;
+
+	/*
+	 * The queue structure allocates individual buffers large enough
+	 * to hold an entire packet. There is no packing so each FD
+	 * requires a single BD. There is one q_desc (an FD and a BD,
+	 * 16-byte aligned) for each packet recieved and the same for
+	 * each packet to transmit. The list of free buffers has one
+	 * FD and an arbitrary number of BDs following it (but even).
+	 * There is one BD for each RX buffer.
+	 */
+
+	/*
+	 * TODO: Need to add some error checking here for reentry into
+	 * this routine.
+	 */
+	/* descriptors for the rx/tx buffers and the buffer list */
+	size = (RX_BUF_NUM + TX_BUF_NUM) * sizeof(struct q_desc) +
+		sizeof(struct bl_desc);
+
+	/* test for allocation requirements */
+	if (lp->fd_base == NULL) {
+		/* add enough margin to align to 16-byte boundary */
+		lp->fd_base = kmalloc(size + (L1_CACHE_BYTES - 1),
+					GFP_KERNEL);
+		if (lp->fd_base == NULL) {
+			printk(KERN_ERR "MSPETH(init_queues) %s: "
+				"Cannot allocate space for descriptors!\n",
+				dev->name);
+			return false;
+		}
+
+		/*
+		 * Move frame descriptors to uncached addresses. This
+		 * prevents spurious IntBLEx interrupts.
+		 */
+		lp->fd_base = (void*)KSEG1ADDR((u32)lp->fd_base);
+		memset(lp->fd_base, 0, size + (L1_CACHE_BYTES - 1));
+		
+		if (mspeth_debug > 1)
+			printk(KERN_INFO
+				"MSPETH(init_queues) %s: fd_base = %p\n",
+				dev->name, lp->fd_base);
+	}
+
+	/*
+	 * stjeanma, 2006-01-26:
+	 * Add instead of subtract and take into account the
+	 * architecture's cache line size.
+	 */
+	tmp_addr = ((u32) lp->fd_base +
+			(L1_CACHE_BYTES - 1)) & ~(L1_CACHE_BYTES - 1);
+
+	/* allocate the RX queue (aka free descriptor area) */
+	lp->rxfd_base = (struct q_desc *)tmp_addr;
+	lp->rxfd_curr = lp->rxfd_base;
+	tmp_addr += RX_BUF_NUM * sizeof(struct q_desc);
+
+	/*
+	 * Initialize the RX queue (these values are mostly
+	 * overwritten by the MAC).
+	 */
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		lp->rxfd_base[i].fd0.FDNext = 0x00000000;
+		lp->rxfd_base[i].fd0.FDSystem = 0x00000000;
+		lp->rxfd_base[i].fd0.FDStat = 0x00000000;
+		lp->rxfd_base[i].fd0.FDCtl = FD_CownsFD;
+		lp->rxfd_base[i].fd1.FDNext = 0x00000000;
+		lp->rxfd_base[i].fd1.FDSystem = 0x00000000;
+		lp->rxfd_base[i].fd1.FDStat = 0x00000000;
+		lp->rxfd_base[i].fd1.FDCtl = FD_CownsFD;
+	}
+
+	/* initialize the actual TX sk_buff pointers */
+	if (lp->txfd_base != NULL) {
+		for (i = 0; i < TX_BUF_NUM; i++) {
+			skb = (struct sk_buff *)lp->txfd_base[i].fd.FDSystem;
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+			dma_skb = lp->txfd_base[i].fd1.FDStat;
+			if (dma_skb != 0x00000000) {
+				lp->txfd_base[i].fd1.FDStat = 0x00000000;
+				/* unmap any dma pointers */
+				dma_unmap_single(lp->dev, dma_skb,
+					skb->len, DMA_BIDIRECTIONAL);
+			}
+#endif
+			if (skb != NULL) {
+				lp->txfd_base[i].fd.FDSystem = 0x00000000;
+				dev_kfree_skb_any(skb);
+			}
+		}
+	}
+
+	/* allocate the TX queue */
+	lp->txfd_base = (struct q_desc *)tmp_addr;
+	lp->tx_head = lp->tx_tail = 0;
+	tmp_addr += TX_BUF_NUM * sizeof(struct q_desc);
+
+	/* initialize the TX queue */
+	for (i = 0; i < TX_BUF_NUM; i++) {
+		lp->txfd_base[i].fd.FDNext = (u32)(&lp->txfd_base[i + 1]);
+		lp->txfd_base[i].fd.FDSystem = 0x00000000;
+		lp->txfd_base[i].fd.FDStat = 0x00000000;
+		lp->txfd_base[i].fd.FDCtl = 0x00000000;
+	}
+	lp->txfd_base[TX_BUF_NUM - 1].fd.FDNext = (u32)(&lp->txfd_base[0]);
+
+	/* initialize the buffer list FD */
+	lp->blfd_ptr = (struct bl_desc *)tmp_addr;
+	lp->blfd_ptr->fd.FDNext = (u32)lp->blfd_ptr;
+	lp->blfd_ptr->fd.FDCtl = (RX_BUF_NUM << 1) | FD_CownsFD;
+
+	/* allocate the RX sk_buff array */
+	if (lp->rx_skbp == NULL) {
+		lp->rx_skbp = (struct sk_buff **)kmalloc(
+				(RX_BUF_NUM << 1) * sizeof(struct sk_buff *),
+				GFP_KERNEL);
+		if (lp->rx_skbp == NULL) {
+			printk(KERN_ERR "MSPETH(init_queues) %s: "
+				"Cannot allocate the array of "
+				"sk_buff pointers!\n", dev->name);
+			return false;
+		}
+		
+		for (i = 0; i < RX_BUF_NUM << 1; i++)
+			lp->rx_skbp[i] = NULL;
+	}
+
+	/* initialize the actual RX sk_buff pointers */
+	for (i = 0; i < RX_BUF_NUM << 1; i++) {
+		/* free up old sk_buffs */
+		skb = lp->rx_skbp[i];
+		if (skb != NULL) {
+			lp->rx_skbp[i] = NULL;
+			dev_kfree_skb_any(skb);
+		}
+
+		/* allocate and align the skb */
+		skb = dev_alloc_skb(MSP_END_BUFSIZE + 2);
+		if (skb == NULL) {
+			printk(KERN_ERR "MSPETH(init_queues) %s: "
+				"Cannot allocate the sk_buffs!\n", dev->name);
+			return false;
+		}
+		lp->rx_skbp[i] = skb;
+		
+		/*
+		 * Slign and fill out fields specific to our
+		 * device. Notice that our device is smart about
+		 * FCS etc.
+		 */
+		skb_reserve(skb, 2);
+		skb->dev = dev;
+		skb->ip_summed = CHECKSUM_NONE;
+
+		/*
+		 * Initialize the buffer list entries reserving 2 bytes
+		 * in the skb results in a 16-byte aligned  IP header,
+		 * but also puts the skb->data at a 16-bit boundary.
+		 * The hardware requires a 32-bit aligned buffer. So we
+		 * round back two bytes and then instruct the hardware
+		 * to skip forward 2 bytes into the buffer.
+		 */
+		lp->blfd_ptr->bd[i].BuffData = (u32)skb->data &
+						BD_DataAlign_MASK;
+		lp->blfd_ptr->bd[i].BDCtl = (BD_CownsBD |
+			(i << BD_RxBDID_SHIFT) | MSP_END_BUFSIZE);
+	}
+
+	/* allocate the RX dma array */
+	if (lp->rx_dma_skbp == NULL) {
+		lp->rx_dma_skbp = (dma_addr_t *)kmalloc(
+				(RX_BUF_NUM << 1) * sizeof(dma_addr_t),
+				GFP_KERNEL);
+		if (lp->rx_dma_skbp == NULL) {
+			printk(KERN_ERR "MSPETH(init_queues) %s: "
+				"Cannot allocate the array of "
+				"RX dma addresses!\n", dev->name);
+			return false;
+		}
+		
+		for (i = 0; i < RX_BUF_NUM << 1; i++)
+			lp->rx_dma_skbp[i] = 0x00000000;
+	}
+
+	/* initialize the RX dma pointers */
+	for (i = 0; i < RX_BUF_NUM << 1; i++) {
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+		dma_skb = lp->rx_dma_skbp[i];
+		/* unmap any dma pointers */
+		if (dma_skb != 0x00000000) {
+			lp->rx_dma_skbp[i] = 0x00000000;
+			dma_unmap_single(lp->dev, dma_skb,
+					MSP_END_BUFSIZE, DMA_BIDIRECTIONAL);
+		}
+#endif
+	}
+
+	/* configure the queue length and return */
+	atomic_set(&lp->tx_qspc, TX_BUF_NUM);
+
+	return true;
+}
+
+/**************************************************************************
+ * Converse of the mspeth_init_queues routine. This frees all the memory
+ * associated with the queues. It must be called when closing the device.
+ */
+static void
+mspeth_free_queues(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	struct sk_buff *skb;
+	dma_addr_t dma_skb;
+	int i;
+
+	/* free up any TX buffers */
+	if (lp->txfd_base != NULL) {
+		for (i = 0; i < TX_BUF_NUM; i++) {
+			skb = (struct sk_buff *)lp->txfd_base[i].fd.FDSystem;
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+ 			dma_skb = lp->txfd_base[i].fd1.FDStat;
+			if (dma_skb != 0x00000000) {
+				lp->txfd_base[i].fd1.FDStat = 0x00000000;
+				/* unmap any dma pointers */
+				dma_unmap_single(lp->dev, dma_skb,
+						skb->len, DMA_BIDIRECTIONAL);
+			}
+#endif
+			if (skb != NULL) {
+				lp->txfd_base[i].fd.FDSystem = 0x00000000;
+				dev_kfree_skb_any(skb);
+			}
+		}
+	}
+
+	/* free up the RX sk_buff buffer and array */
+	if (lp->rx_skbp != NULL) {
+		for (i = 0; i < RX_BUF_NUM << 1; i++) {
+			skb = lp->rx_skbp[i];
+			if (skb != NULL) {
+				dev_kfree_skb_any(skb);
+			}
+		}
+		kfree(lp->rx_skbp);
+	}
+
+	/* unmap any RX dma pointers and free up the array */
+	if (lp->rx_dma_skbp != NULL) {
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+		for (i = 0; i < RX_BUF_NUM << 1; i++) {
+			dma_skb = lp->rx_dma_skbp[i];
+			if (dma_skb != 0x00000000)
+				dma_unmap_single(lp->dev, dma_skb,
+					MSP_END_BUFSIZE, DMA_BIDIRECTIONAL);
+		}
+#endif
+		kfree(lp->rx_dma_skbp);
+	}
+
+	/*
+	 * Free the descriptor area. Move fd_base back to KSEG0 before
+	 * freeing it.
+	 */
+	if (lp->fd_base != NULL)
+		kfree((void*)KSEG0ADDR(lp->fd_base));
+
+	/* nullify all the pointers and zero out the queue space */
+	lp->fd_base = NULL;
+	lp->rxfd_base = NULL;
+	lp->rxfd_curr = NULL;
+	lp->txfd_base = NULL;
+	lp->blfd_ptr = NULL;
+	lp->rx_skbp = NULL;
+	lp->rx_dma_skbp = NULL;
+	lp->tx_head = lp->tx_tail = 0;
+
+	atomic_set(&lp->tx_qspc, 0);
+}
+
+/**************************************************************************
+ * Do a safe soft restart of the device. This *will* cause packet loss,
+ * so it's only used as a recovery mechanism.
+ */
+static void
+mspeth_soft_restart(struct net_device *dev)
+{
+	int flags;
+
+	printk(KERN_INFO "MSPETH(soft_restart) %s: "
+		"Soft device restart\n", dev->name);
+
+	netif_stop_queue(dev);
+
+	/* please don't interrupt me while I'm resetting everything */
+	local_irq_save(flags);
+
+	/* Try to restart the adaptor. */
+	mspeth_mac_reset(dev);
+	mspeth_init_queues(dev);
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);
+
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+	/* and start up the queue! We should be fixed .... */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+}
+
+/**************************************************************************
+ * Do a *hard* restart of the device. This *will* cause packet loss, so
+ * it's only used as a recovery mechanism
+ */
+static void
+mspeth_hard_restart(struct net_device *dev)
+{
+	int flags;
+
+	printk(KERN_INFO "MSPETH(hard_restart) %s: "
+		"Hard device restart\n", dev->name);
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
+	mspeth_init_queues(dev);
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);
+
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+	/* and start up the queue! We should be fixed .... */
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
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int err = -EBUSY;
+
+	/* reset the hardware, disabling/clearing all interrupts */
+	mspeth_mac_reset(dev);
+	mspeth_phy_reset(dev);
+
+	/* determine preset speed and duplex settings */
+	if (lp->option & MSP_OPT_10M)
+		lp->speed = 10;
+	else
+		lp->speed = 100;
+
+	if (lp->option & MSP_OPT_FDUP)
+		lp->fullduplex = true;
+	else
+		lp->fullduplex = false;
+
+	/* initialize the queues and the hardware */
+	if (!mspeth_init_queues(dev)) {
+		printk(KERN_ERR "MSPETH(open) %s: "
+			"Unable to allocate queues\n", dev->name);
+		goto out_err;
+	}
+
+	/* allocate and initialize the tasklets */
+#ifndef CONFIG_MSPETH_NAPI
+	tasklet_init(&lp->rx_tasklet, mspeth_rx, (u32)dev);
+	tasklet_init(&lp->tx_tasklet, mspeth_txdone, (u32)dev);
+#endif
+
+	/*
+	 * hammtrev, 2005/12/08:
+	 * Adding a new BH handler to reset the device in response to BLEx.
+	 */
+	tasklet_init(&lp->hard_restart_tasklet, mspeth_hard_restart_bh,
+			(u32)dev);
+
+	mspeth_mac_init(dev);
+	mspeth_phy_init(dev);
+
+	/* stjeanma: No need to poll the link status for a switch */
+	if (!(lp->option & MSP_OPT_SWITCH)) {
+		/* initialize the link check timer */
+		init_timer(&lp->link_timer);
+		lp->link_timer.expires = jiffies + HZ / LINK_DELAY_DIV;
+		lp->link_timer.data = (u32)dev;
+		lp->link_timer.function = mspeth_link_check;
+		add_timer(&lp->link_timer);
+	}
+
+	/* Allocate the IRQ */
+	if (request_irq(dev->irq, &mspeth_interrupt, 0, cardname, dev)) {
+		printk(KERN_ERR
+			"MSPETH(open) %s: unable to reserve IRQ %d\n",
+			dev->name, dev->irq);
+		goto out_err;
+	}
+	
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	skb_bin.user_count++;
+#endif
+	/* and start up the queue */
+	netif_start_queue(dev);
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+	MOD_INC_USE_COUNT;
+#endif
+	return 0;
+
+out_err:
+	return err;
+}
+
+/**************************************************************************
+ * The inverse routine to mspeth_open(). Close the device and clean up
+ */
+static int
+mspeth_close(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 flags;
+
+	/* please don't interrupt me while I'm shutting down everything */
+	local_irq_save(flags);
+
+	/* stop the queue & let the world know about it */
+	netif_stop_queue(dev);
+	netif_carrier_off(dev);
+
+	/* kill the tasklets before resetting devices */
+#ifndef CONFIG_MSPETH_NAPI
+	tasklet_kill(&lp->rx_tasklet);
+	tasklet_kill(&lp->tx_tasklet);
+#endif
+	tasklet_kill(&lp->hard_restart_tasklet);
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
+	free_irq(dev->irq, dev);
+
+	/*
+	 * Deassign the phy.
+	 * stjeanma: PHY might not be allocated for a switch.
+	 */
+	if (lp->phyptr != NULL)
+		lp->phyptr->assigned = false;
+
+	/* turn back on the interrupts */
+	local_irq_restore(flags);
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+	MOD_DEC_USE_COUNT;
+#endif
+
+	return 0;
+}
+
+/**************************************************************************
+ * The typical workload of the driver:
+ *	Handle the network interface interrupts.
+ */
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+static irqreturn_t mspeth_interrupt(int irq, void *dev_id)
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+static void mspeth_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+#endif
+{
+	struct net_device *dev = dev_id;
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 status;
+
+	if (unlikely(dev == NULL)) {
+		printk(KERN_WARNING "MSPETH(interrupt) %s: "
+			"irq %d for unknown device.\n", dev->name, irq);
+		return IRQ_NONE;
+	}
+
+	/*
+	 * stjeanma, 2006-02-08:
+	 * This read flushes the dma queue in addition to obtaining
+	 * status.
+	 */
+	status = msp_read(lp, MSPETH_Int_Src);
+
+	/* acknowledge the interrupts and check for null entry */
+	if (unlikely(status == 0))
+		return IRQ_HANDLED;
+	else
+		msp_write(lp, MSPETH_Int_Src, status);
+
+#if MSPETH_DEBUG
+	/* collect debugging stats */
+	if (likely(status & IntSrc_MacRx))
+		lp->lstats.rx_ints++;
+	if (status & IntSrc_MacTx)
+		lp->lstats.tx_ints++;
+#endif
+
+#ifdef CONFIG_MSPETH_NAPI
+	/* if NAPI is enabled schedule rx jobs */
+	if (likely(status == IntSrc_MacRx)) {
+		if (netif_rx_schedule_prep(dev)) {
+			msp_write(lp, MSPETH_Rx_Ctl,
+					RX_CTL_CMD & ~Rx_EnGood);
+			msp_write(lp, MSPETH_Int_En,
+					INT_EN_CMD & ~IntEn_FDAEx);
+			__netif_rx_schedule(dev);
+		}
+		return IRQ_HANDLED;
+	}
+
+	if (status & IntSrc_MacRx) {
+		/* if NAPI is enabled schedule rx jobs */
+		 if (netif_rx_schedule_prep(dev)) {
+			msp_write(lp, MSPETH_Rx_Ctl,
+					RX_CTL_CMD & ~Rx_EnGood);
+			msp_write(lp, MSPETH_Int_En,
+					INT_EN_CMD & ~IntEn_FDAEx);
+			__netif_rx_schedule(dev);
+		}
+	}
+
+	/*
+	 * Workaround for transmission timeouts due to transmit queue
+	 * exhaust even if the queue has room.
+	 */
+	if (status & IntSrc_MacTx) {
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+		netif_wake_queue(dev);
+	}
+#else
+	/*
+	 * At least for every TXDONE_MAX_PKT one IntSrc_MacTx will be
+	 * generated.
+	 */
+	if (likely(status == IntSrc_MacRx)) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD & ~Rx_EnGood);
+		tasklet_schedule(&lp->rx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	if (likely(status == IntSrc_MacTx)) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	if (likely(status == (IntSrc_MacRx | IntSrc_MacTx))) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD & ~Rx_EnGood);
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+		tasklet_schedule(&lp->rx_tasklet);
+		return IRQ_HANDLED;
+	}
+
+	if (status & IntSrc_MacRx) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD & ~Rx_EnGood);
+		tasklet_schedule(&lp->rx_tasklet);
+	}
+
+	/* all other combined cases */
+	if (status & IntSrc_MacTx) {
+		/* disable interrupt and schedule tasklet */
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+	}
+#endif /* CONFIG_MSPETH_NAPI */
+
+	/* recoverable errors */
+	if (status & IntSrc_FDAEx) {
+		/* disable FDAEx int. (until we make room...) */
+		msp_write(lp, MSPETH_Int_En, INT_EN_CMD & ~IntEn_FDAEx);
+		lp->lstats.fd_exha++;
+		lp->stats.rx_dropped++;
+	}
+
+	/*
+	 * hammtrev, 2005/08/30:
+	 * Some boards generate a link state interrupt on power-up.
+	 * ACK it and it will go away.
+	 */
+	if (status & IntSrc_Link_St)
+		msp_write(lp, MSPETH_MAC_Ctl,
+			  msp_read(lp, MSPETH_MAC_Ctl) | MAC_LnkChg);
+
+	/*
+	 * And now all the unrecoverable fatal error conditions, this
+	 * includes BLEx errors since we can *never* have one -- if we
+	 * do, it indicates that there is some sort of queue corruption.
+	 */
+	if (status & FATAL_ERROR_INT) {
+		/* Disable further interrupts until device reset. */
+		msp_write(lp, MSPETH_DMA_Ctl,
+				msp_read(lp, MSPETH_DMA_Ctl) | DMA_IntMask);
+		/* this one may be overkill... */
+		msp_write(lp, MSPETH_MAC_Ctl,
+				msp_read(lp, MSPETH_MAC_Ctl) | MAC_HaltImm);
+		mspeth_fatal_error_interrupt(dev, status);
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**************************************************************************
+ * Fatal error interrupts reset the entire device but they don't require
+ * reallocating the queues, just clearing them
+ */
+static void
+mspeth_fatal_error_interrupt(struct net_device *dev, int status)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+
+	printk(KERN_WARNING
+		"MSPETH(fatal_error_interrupt) %s: "
+		"Fatal Error Interrupt (0x%08x):", dev->name, status);
+
+	if (status & IntSrc_DmParErr)
+		printk(KERN_WARNING " DmParErr");
+	if (status & IntSrc_NRAB)
+		printk(KERN_WARNING " IntNRAB");
+	if (status & IntSrc_BLEx)
+		printk(KERN_WARNING " IntBLEx");
+	printk(KERN_WARNING "\n");
+
+	/* panic if it gets too crazy */
+	if (lp->fatal_icnt++ > 100)
+		panic("MSPETH(fatal_error_interrupt) %s: "
+			"too many fatal errors.\n", dev->name);
+
+	/* Dump our descriptors, if desired */
+	if (mspeth_debug > 0) {
+		mspeth_dump_queues(dev);
+		mspeth_dump_stats(dev);
+	}
+
+	/*
+	 * Try to restart the adaptor.
+	 *
+	 * hammtrev, 2005/12/08:
+	 * This is too much work for a top-half interrupt handler, and
+	 * may result in unexpected race conditions with other tasklets.
+	 * Now deferring the device reset to a bottom-half tasklet, to
+	 * allow any currently-running tasklet to complete without
+	 * unexpected changes to frame/buffer descriptors, etc.
+	 */
+	tasklet_schedule(&lp->hard_restart_tasklet);
+}
+
+/**************************************************************************
+ * Handle deferred processing of the IntBLEx interrupt.
+ */
+static void
+mspeth_hard_restart_bh(unsigned long dev_addr)
+{
+	struct net_device *dev = (struct net_device *)dev_addr;
+
+	printk(KERN_WARNING "MSPETH(hard_restart_bh) %s: "
+		"restarting device\n", dev->name);
+	mspeth_hard_restart(dev);
+}
+
+
+/**************************************************************************
+ * Process a single RX packet, including sending it up the stack and
+ * reallocating the buffer. Return the next buffer in the RX queue.
+ * This routine assumes that the current FD pointed to by rxfd_curr
+ * has been invalidated with the cache and is current with main memory.
+ *
+ * Changed __hotnet to inline: slight performance improvement.
+ */
+inline static struct q_desc *
+mspeth_rx_onepkt(struct net_device *dev) {
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 status;
+	struct q_desc *next_rxfd;
+	int bdnum, len;
+	struct sk_buff *skb;
+	dma_addr_t dma_skb;
+
+	/* collect all the relevent information */
+	status = lp->rxfd_curr->fd.FDStat;
+	/* Drop the FCS from the length */
+	len = (lp->rxfd_curr->bd.BDCtl & BD_BuffLength_MASK) - 4;
+	bdnum = (lp->rxfd_curr->bd.BDCtl & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
+
+	if (mspeth_debug > 2)
+		printk(KERN_INFO "MSPETH(rx_onepkt) %s: "
+			"RxFD.\n", dev->name);
+	if (mspeth_debug > 3)
+		dump_qdesc(lp->rxfd_curr);
+#ifdef MSPETH_DUMP_QUEUES
+	if (mspeth_debug > 2 &&
+	    (!bdnum && (rx_bdnums[lp->unit][rx_bdnums_ind[lp->unit]]
+					!= ((RX_BUF_NUM << 1) - 1))))
+		dump_qdesc(lp->rxfd_curr);
+	catalog_rx_bdnum(lp->unit, bdnum);
+#endif /* MSPETH_DUMP_QUEUES */
+
+	/*
+	 * The packet has been received correctly so prepare to send
+	 * it up the stack
+	 */
+	if (likely(status & Rx_Good)) {
+		skb = lp->rx_skbp[bdnum];
+		dma_skb = lp->rx_dma_skbp[bdnum];
+
+		/*
+		 * If a replacement buffer can be allocated then send
+		 * the skb up the stack otherwise we drop the packet
+		 * and reuse the existing buffer
+		 */
+		lp->rx_skbp[bdnum] = mspeth_alloc_skb(dev);
+		if (likely(lp->rx_skbp[bdnum] != NULL)) {
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+			/* Replacement buffer map and sync for dma */
+			lp->rx_dma_skbp[bdnum] = dma_map_single(
+					lp->dev, lp->rx_skbp[bdnum]->data, 
+					MSP_END_BUFSIZE, DMA_FROM_DEVICE);
+
+		 	/*
+		 	 * Replacement buffer has been allocated
+		 	 * successfully, so sync and un-map original
+		 	 * buffer.
+		 	 */
+			dma_sync_single_for_cpu(lp->dev, dma_skb,
+						len, DMA_FROM_DEVICE);
+			dma_unmap_single(lp->dev, dma_skb,
+					MSP_END_BUFSIZE, DMA_NONE);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+			invalidate_buffer(skb->data, len);
+#endif
+
+			/* complete the skb and send it up the stack */
+			skb_put(skb, len);
+			skb->protocol = eth_type_trans(skb, dev);
+
+#ifdef CONFIG_MSPETH_NAPI
+			netif_receive_skb(skb);
+#else
+			netif_rx(skb);
+#endif /* CONFIG_MSPETH_NAPI */
+			dev->last_rx = jiffies;
+
+			lp->stats.rx_packets++;
+			lp->stats.rx_bytes += len;
+
+			if (mspeth_debug > 4) {
+				print_eth(1, skb->data, len);
+				if (mspeth_debug > 5)
+					print_buf(skb->data, len);
+			}
+		} else {
+			printk(KERN_WARNING "MSPETH(rx_onepkt) %s: "
+				"Memory squeeze, dropping packet.\n",
+				dev->name);
+			lp->rx_skbp[bdnum] = skb;
+			lp->stats.rx_dropped++;
+		}
+
+		/* Do the rounding for the 32-bit data alignment */
+		lp->blfd_ptr->bd[bdnum].BuffData =
+				(u32)lp->rx_skbp[bdnum]->data &
+				BD_DataAlign_MASK;
+	} else {
+		lp->stats.rx_errors++;
+		/* WORKAROUND: LongErr and CRCErr means Overflow. */
+		if ((status & Rx_LongErr) && (status & Rx_CRCErr)) {
+			status &= ~(Rx_LongErr | Rx_CRCErr);
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
+	/* allocate buffer back to controller */
+	lp->blfd_ptr->bd[bdnum].BDCtl =
+		(BD_CownsBD | (bdnum << BD_RxBDID_SHIFT) | MSP_END_BUFSIZE);
+	blocking_read_reg32(&lp->blfd_ptr->bd[bdnum].BDCtl);
+	
+	/* save next FD before allocating current one to controller */
+	next_rxfd = (struct q_desc *)lp->rxfd_curr->fd.FDNext;
+
+	/*
+	 * Return q_desc to the controller. Setting fd0.FDCtl last prevents
+	 * the controller from using this q_desc until we're done.
+	 *
+	 * Writeback the changes back to the RAM so that MAC can see the
+	 * available buffers on a write-through cache this doesn't really
+	 * do anything, but on a writeback cache this is quite important.
+	 *
+	 * stjeanma, 2006-02-08:
+	 * Uncached writes need to be read back to ensure they reach RAM.
+	 */
+	lp->rxfd_curr->fd0.FDNext = 0;
+	lp->rxfd_curr->fd0.FDSystem = 0;
+	lp->rxfd_curr->fd0.FDStat = 0;
+	lp->rxfd_curr->fd1.FDNext = 0;
+	lp->rxfd_curr->fd1.FDSystem = 0;
+	lp->rxfd_curr->fd1.FDStat = 0;
+	lp->rxfd_curr->fd1.FDCtl = FD_CownsFD;
+	lp->rxfd_curr->fd0.FDCtl = FD_CownsFD;
+	blocking_read_reg32(&lp->rxfd_curr->fd0.FDCtl);
+
+	return next_rxfd;
+}
+
+#ifdef CONFIG_MSPETH_NAPI
+/*************************************************************************
+ * mspeth polling method used by NAPI.
+ */
+static int __hotnet
+mspeth_poll(struct net_device *dev, int *budget)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	int work_limit = min(*budget, dev->quota);
+	int work_done;
+	int done = 1;
+	
+	flush_memqueue();
+
+	for (work_done = 0; (work_done < work_limit) &&
+				!(lp->rxfd_curr->fd.FDCtl & FD_CownsFD);
+				work_done++)
+		lp->rxfd_curr = mspeth_rx_onepkt(dev);
+
+	if (likely(work_done > 0)) {
+		*budget -= work_done;
+		dev->quota -= work_done;
+		done = (work_done < work_limit);
+	}
+
+	if (done) {
+		/*
+		 * Reenable rx and FDAEXhaust interrupts since we
+		 * handled all recieved packets.
+		 */
+		local_irq_disable();
+		__netif_rx_complete(dev);
+		msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD | Rx_EnGood);
+		msp_write(lp, MSPETH_Int_En, INT_EN_CMD);
+		local_irq_enable();
+	}
+
+	return !done;
+}
+#else
+/**************************************************************************
+ * A packet has been received so shove it up the network stack and
+ * allocate another buffer for reception. Called by the rx_tasklet which
+ * is scheduled by the interrupt handler.
+ */
+static void __hotnet
+mspeth_rx(unsigned long dev_addr)
+{
+	struct net_device *dev = (struct net_device *)dev_addr;
+	struct mspeth_priv *lp = netdev_priv(dev);
+	u32 status;
+	int rx_cnt;
+
+	/*
+	 * Make sure the memory queue is flushed and the cache is
+	 * invalidated this is only really important in the case where
+	 * we have a single packet to process otherwise the packet at
+	 * the head of the queue will *certainly* be flushed from the
+	 * memory queue. We don't need to flush the DMA queue since the
+	 * ISR that scheduled this routine will have done it already.
+	 */
+	flush_memqueue();
+
+	/*
+	 * Loop around processing the rx packet queue.
+	 * This should be adjusted to process a maximum number of
+	 * packets, or perhaps insert a call to "schedule" within it
+	 * so that it doesn't monopolize the CPU.
+	 */
+	for (rx_cnt = 0; rx_cnt < RX_MAX_PKT &&
+	     !(lp->rxfd_curr->fd.FDCtl & FD_CownsFD); rx_cnt++) {
+		/*
+		 * Process the current packet and move to the next
+		 * frame descriptor.
+		 */
+		lp->rxfd_curr = mspeth_rx_onepkt(dev);
+	}
+
+	/* re-enable FDA Exhausted interupts 'cause there's room now */
+	if (rx_cnt > 0)
+		msp_write(lp, MSPETH_Int_En, INT_EN_CMD);
+
+	/*
+	 * Check to see if there is an unprocessed packet
+	 * -- reschedule if so.
+	 *
+	 * hammtrev, 2005-12-16:
+	 * Flush the memory queue and invalidate the cache
+	 * lines before re-examining the current rxfd.
+	 */
+	flush_memqueue();
+
+	if (!(lp->rxfd_curr->fd.FDCtl & FD_CownsFD)) {
+		tasklet_schedule(&lp->rx_tasklet);
+	} else {
+		/*
+		 * Re-enable the RX completion interrupt and check to see
+		 * if there is an outstanding interrupt.
+		 */
+		msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD);
+		status = msp_read(lp, MSPETH_Int_Src);
+
+		/*
+		 * If there is an outstanding RX interrupt, then reschedule
+		 * the routine
+		 */
+		if (status & IntSrc_MacRx) {
+			/* ack the interrupt, disable it and reschedule */
+			msp_write(lp, MSPETH_Int_Src, IntSrc_MacRx);
+			msp_write(lp, MSPETH_Rx_Ctl,
+					RX_CTL_CMD & ~Rx_EnGood);
+			tasklet_schedule(&lp->rx_tasklet);
+		}
+	}
+}
+#endif /* CONFIG_MSPETH_NAPI */
+
+/**************************************************************************
+ * Basic transmit function -- called from the upper network layers
+ */
+static int __hotnet
+mspeth_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	struct q_desc *txfd_ptr;
+
+	/*
+	 * NOTE that if we cannot transmit then we must return 1 and
+	 * *not touch* the skb since it doesn't belong to us. The
+	 * networking layer above will take care of it.
+	 */
+
+#ifdef CONFIG_MSPETH_NAPI
+	/*
+	 * We have no txdone interrupt on NAPI.
+	 * Free transmitted buffers here.
+	 */
+	mspeth_txdone((unsigned long)dev);
+#endif
+
+	/*
+	 * Don't take drastic action right away if the queue is stopped,
+	 * but if its been that way for quite a while we'll attempt to
+	 * restart the adatper.
+	 */
+	if (netif_queue_stopped(dev)) {
+		/*
+		 * If we get here, some higher level has decided we are
+		 * broken. There should really be a "kick me" function
+		 * call instead.
+		 */
+		int tickssofar = jiffies - dev->trans_start;
+		if (tickssofar < 5) {
+			printk(KERN_WARNING "MSPETH(send_packet) %s: "
+				"queue stopped ...\n", dev->name);
+			return 1;
+		}
+
+		printk(KERN_WARNING "MSPETH(send_packet) %s: "
+			"transmit timed out, restarting adaptor. "
+			"TX_Status = %08x\n",
+			dev->name, msp_read(lp, MSPETH_Tx_Stat));
+
+		/* do a hard restart and return */
+		mspeth_hard_restart(dev);
+		return 1;
+	}
+
+	/*
+	 * Protect access to the transmit queue with the atomic queue
+	 * space variable.
+	 */
+	if (atomic_read(&lp->tx_qspc) == 0) {
+		/* no room on queue for another packet */
+		netif_stop_queue(dev);
+#ifdef CONFIG_MSPETH_NAPI
+		/* workaround for waking the queue */
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD);
+#endif
+		lp->lstats.tx_full++;
+		return 1;
+	}
+
+	lp->stats.tx_bytes += skb->len;
+
+	/* we have room, so get the next availabe tx FD */
+	txfd_ptr = &(lp->txfd_base[lp->tx_head]);
+	lp->tx_head = (lp->tx_head + 1) & TX_BUF_MASK;
+
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+	/* map and sync for dma */
+	txfd_ptr->fd1.FDStat = dma_map_single(lp->dev, skb->data,
+						skb->len, DMA_TO_DEVICE);
+#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
+	/* writeback the cache and flush the sdram queue */
+	writeback_buffer(skb->data, skb->len);
+#endif
+
+	/*
+	 * stjeanma, 2006-02-08:
+	 * Uncached writes need to be read back to ensure they reach RAM.
+	 */
+	txfd_ptr->bd.BuffData = (u32)skb->data;
+	txfd_ptr->bd.BDCtl = skb->len;
+	txfd_ptr->fd.FDSystem = (u32)skb;
+	txfd_ptr->fd.FDCtl = FD_CownsFD_Set;
+	blocking_read_reg32(&txfd_ptr->fd.FDCtl);
+
+	/* one more packet on the TX queue */
+	atomic_dec(&lp->tx_qspc);
+
+	if (mspeth_debug > 4) {
+		print_eth(0, (unsigned char *)skb->data, skb->len);
+		if (mspeth_debug > 5)
+			print_buf(skb->data, skb->len);
+	}
+
+	/* wake up the transmitter */
+	msp_write(lp, MSPETH_DMA_Ctl, DMA_CTL_CMD | DMA_TxWakeUp);
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
+#ifdef CONFIG_MSPETH_NAPI
+inline static void
+#else
+static void __hotnet
+#endif
+mspeth_txdone(unsigned long dev_addr)
+{
+	struct net_device *dev = (struct net_device *)dev_addr;
+	struct mspeth_priv *lp = netdev_priv(dev);
+	struct q_desc *txfd_ptr;
+	int num_done = 0;
+	u32 status;
+
+	/*
+	 * Walk the queue until we come to the end or a buffer we don't
+	 * control we don't worry much about leaving a buffer or two on
+	 * the tx queue; we'll get to them later and if we're busy then
+	 * we'll get to them RSN.
+	 *
+	 * stjeanma, 2006-02-08:
+	 * Flush the memory queue to see the MAC queue updates.
+	 */
+	txfd_ptr = &(lp->txfd_base[lp->tx_tail]);
+	flush_memqueue();
+
+	while (atomic_read(&lp->tx_qspc) < TXDONE_MAX_PKT &&
+			!(txfd_ptr->fd.FDCtl & FD_CownsFD)) {
+		struct sk_buff *skb;
+		dma_addr_t dma_skb;
+
+		status = txfd_ptr->fd.FDStat;
+		mspeth_check_tx_stat(dev, status);
+
+		if (mspeth_debug > 2)
+			printk(KERN_INFO "MSPETH(txdone) %s: "
+				"TxFD done.\n", dev->name);
+		if (mspeth_debug > 3)
+			dump_qdesc(txfd_ptr);
+
+		/*
+		 * Free the current socket buffer and change ownership of
+		 * the TX descriptor.
+		 *
+		 * Writeback the change to RAM so that the controller can
+		 * see them.
+		 *
+		 * stjeanma, 2006-02-08:
+		 * Uncached writes need to be read back to ensure they
+		 * reach RAM.
+		 */
+		dma_skb = txfd_ptr->fd1.FDStat;
+		txfd_ptr->fd1.FDStat = 0x00000000;
+
+		skb = (struct sk_buff *)(txfd_ptr->fd.FDSystem);
+		txfd_ptr->fd.FDSystem = 0x00000000;
+		txfd_ptr->fd.FDCtl = 0x00000000;
+		blocking_read_reg32(&txfd_ptr->fd.FDCtl);
+
+#if defined(CONFIG_DMA_NONCOHERENT) && \
+    LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+		/* unmap dma sync */
+		if (dma_skb != 0x00000000)
+			dma_unmap_single(lp->dev, dma_skb,
+					skb->len, DMA_NONE);
+#endif
+		if (skb != NULL)
+			mspeth_free_skb(skb);
+
+		/* advance to the next TX descriptor */
+		atomic_inc(&lp->tx_qspc);
+		num_done++;
+		lp->tx_tail = (lp->tx_tail + 1) & TX_BUF_MASK;
+		
+		txfd_ptr = &(lp->txfd_base[lp->tx_tail]);
+		flush_memqueue();
+	}
+
+#ifndef CONFIG_MSPETH_NAPI
+	/*
+	 * If we freed at least one buffer and the queue is stopped
+	 * then restart it.
+	 */
+	if (num_done > 0 && netif_queue_stopped(dev))
+		netif_wake_queue(dev);
+
+	/* re-enable interrupts regardless */
+	msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD);
+
+	/* Check for outstanding packets */
+	status = msp_read(lp, MSPETH_Int_Src);
+
+	/* If we have an outstanding packet, reschedule the tasklet */
+	if (status & IntSrc_MacTx) {
+		/* ack interrupt, disable it, and reschedule */
+		msp_write(lp, MSPETH_Int_Src, IntSrc_MacTx);
+		msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
+		tasklet_schedule(&lp->tx_tasklet);
+	}
+#endif /* CONFIG_MSPETH_NAPI */
+}
+
+/**************************************************************************
+ * If there is a timeout we soft restart the entire device
+ */
+static void
+mspeth_tx_timeout(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	printk(KERN_WARNING "MSPETH(tx_timeout) %s: "
+		"transmit timed out, status 0x%08x\n",
+		dev->name, msp_read(lp, MSPETH_Tx_Stat));
+
+	/* try to restart the adaptor */
+	mspeth_soft_restart(dev);
+}
+
+/**************************************************************************
+ * Debugging code to dump out the transmit status register
+ *
+ * hammtrev, 2005-11-25:
+ * The Tx_NCarr condition makes a lot of noise on the PMC RG, but
+ * doesn't seem to affect the success of transmissions. Removing for now.
+ */
+#define TX_STA_ERR \
+	(Tx_ExColl | Tx_Under | Tx_Defer | Tx_LateColl | Tx_TxPar | Tx_SQErr)
+static void
+mspeth_check_tx_stat(struct net_device *dev, int status)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
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
+		printk(KERN_WARNING
+			"MSPETH(check_tx_stats) %s: %s (%#x)\n",
+			dev->name, msg, status);
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *
+mspeth_get_stats(struct net_device *dev)
+{
+	struct mspeth_priv *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	if (netif_running(dev)) {
+		local_irq_save(flags);
+		/* Update the statistics from the device registers. */
+		lp->stats.rx_missed_errors = msp_read(lp, MSPETH_Miss_Cnt);
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
+	struct mspeth_priv *lp = netdev_priv(dev);
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Enable promiscuous mode */
+		msp_write(lp, MSPETH_ARC_Ctl,
+				ARC_CompEn | ARC_BroadAcc |
+				ARC_GroupAcc | ARC_StationAcc);
+	} else if ((dev->flags & IFF_ALLMULTI) ||
+		   dev->mc_count > ARC_ENTRY_MAX - 3) {
+		/* ARC 0, 1, 20 are reserved. */
+		/* Disable promiscuous mode, use normal mode. */
+		msp_write(lp, MSPETH_ARC_Ctl,
+				ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc);
+	} else if (dev->mc_count) {
+		struct dev_mc_list* cur_addr = dev->mc_list;
+		int i;
+		int ena_bits = ARC_Ena_Bit(ARC_ENTRY_SOURCE);
+
+		msp_write(lp, MSPETH_ARC_Ctl, 0);
+		/* Walk the address list, and load the filter */
+		for (i = 0; i < dev->mc_count; i++,
+				cur_addr = cur_addr->next) {
+			if (!cur_addr)
+				break;
+
+			/* entry 0, 1 is reserved. */
+			mspeth_set_arc_entry(dev, i + 2, cur_addr->dmi_addr);
+			ena_bits |= ARC_Ena_Bit(i + 2);
+		}
+		msp_write(lp, MSPETH_ARC_Ena, ena_bits);
+		msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
+	} else {
+		msp_write(lp, MSPETH_ARC_Ena, ARC_Ena_Bit(ARC_ENTRY_SOURCE));
+		msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
+	}
+}
+
+static int
+mspeth_proc_info(char *buf, char **bloc, off_t off,
+			int length, int *eof, void *data)
+{
+	int len = 0;
+	int i, cnt;
+	struct net_device *dev = (struct net_device *)data;
+	struct mspeth_priv *lp = netdev_priv(dev);
+
+	/* finished reading regardless of anything else */
+	if (off > 0)
+		return 0;
+
+	len += sprintf(buf, "MSPETH hwunit %d statistics:\n", lp->hwunit);
+	len += sprintf(buf + len, "%s: tx_ints %d, rx_ints %d, "
+			"max_tx_qlen %d, tx_full %d, fd_exha %d\n",
+			dev->name,
+			lp->lstats.tx_ints,
+			lp->lstats.rx_ints,
+			lp->lstats.max_tx_qlen,
+			lp->lstats.tx_full,
+			lp->lstats.fd_exha);
+	len += sprintf(buf + len, "    fd_base = %p\n\n", lp->fd_base);
+	len += sprintf(buf + len, "    rxfd_base = %p, rxfd_curr = %p\n",
+			lp->rxfd_base, lp->rxfd_curr);
+
+	if (lp->rxfd_base != NULL) {
+		cnt = 0;
+		for (i = 0; i < RX_BUF_NUM; i++) {
+			if (lp->rxfd_base[i].fd.FDCtl & FD_CownsFD)
+				cnt++;
+		}
+		len += sprintf(buf + len,
+				"    Controller FD count = %d\n\n", cnt);
+	}
+	len += sprintf(buf + len, "    tx_base = %p, tx_head = %d, "
+			"tx_tail = %d, qspc = %d\n",
+			lp->txfd_base, lp->tx_head, lp->tx_tail,
+			atomic_read(&lp->tx_qspc));
+	len += sprintf(buf + len, "    blfd_ptr = %p, rx_skbp = %p\n\n",
+			lp->blfd_ptr, lp->rx_skbp);
+	if (lp->mapaddr != NULL)
+		len += sprintf(buf + len,
+				"    pause sent: %d, pause recv: %d\n\n",
+				msp_read(lp, MSPETH_PauseCnt),
+				msp_read(lp, MSPETH_RemPauCnt));
+#ifdef CONFIG_MSPETH_NAPI
+	len += sprintf(buf + len, "    NAPI is enabled\n\n");
+#endif
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+	len += sprintf(buf + len,
+			"    Socket Buffer Recycling is enabled\n");
+	len += sprintf(buf + len,
+			"        recycle hits = %lu, recycle misses = %lu\n",
+			skb_bin.recycle_hits, skb_bin.recycle_misses);
+	len += sprintf(buf + len, "        recycle bin skb count = %lu\n\n",
+			skb_bin.recycle_count);
+#endif
+
+	return len;
+}
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+/* platform device stuff for linux 2.6 */
+static char mspeth_string[] = "mspeth";
+
+static struct platform_driver mspeth_driver = {
+	.probe  = mspeth_probe,
+	.remove	= __devexit_p(mspeth_remove),
+	.driver {
+		.name = mspeth_string,
+	},
+};
+
+/*
+ * Register the mspeth with the kernel
+ */
+static int __init mspeth_init_module(void)
+{
+	printk(KERN_INFO "PMC MSPETH 10/100 Ethernet Driver\n");
+
+	if (platform_driver_register(&mspeth_driver)) {
+		printk(KERN_ERR "Driver registration failed\n");
+		return -ENOMEM;
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
+	platform_driver_unregister(&mspeth_driver);
+}
+
+MODULE_DESCRIPTION("PMC MSPETH 10/100 Ethernet Driver");
+MODULE_LICENSE("GPL");
+
+module_init(mspeth_init_module);
+module_exit(mspeth_cleanup_module);
+#endif
diff --git a/drivers/net/pmcmspeth.h b/drivers/net/pmcmspeth.h
new file mode 100644
index 0000000..f1909aa
--- /dev/null
+++ b/drivers/net/pmcmspeth.h
@@ -0,0 +1,624 @@
+/*
+ * PMC-Sierra MSP EVM ethernet driver for linux
+ *
+ * Copyright 2005-2007 PMC-Sierra, Inc
+ *
+ * Originally based on mspeth.c driver which contains substantially the
+ * same hardware.
+ * Based on skelton.c by Donald Becker.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' A	  ANY  EXPRESS OR IMPLIED
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
+/**************************************************************************
+ * Cache size externs and defines
+ */
+extern int ic_lsize, dc_lsize;	/* Primary cache linesize in bytes */
+extern int sc_lsize;		/* Secondary cache linesize in bytes */
+				/* must be included after the above */
+
+/**************************************************************************
+ * Temporary define to determine cache policy -- at some time in the near
+ * future, this will get migrated to something in the configuration
+ */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#if !defined(CONFIG_UCLINUX) && \
+    (CONF_CM_DEFAULT == CONF_CM_CACHABLE_NONCOHERENT)
+#define CONFIG_DMA_NONCOHERENT
+#endif
+#endif
+
+/* Get the private data pointer */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#define netdev_priv(dev) ((struct mspeth_priv *)dev->priv)
+#endif
+
+/* Define __hotnet macro for 2.6 */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+#define __hotnet
+#endif
+
+/* Define dma_addr_t for 2.4 */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#define dma_addr_t	u32
+#endif
+
+/**************************************************************************
+ * Device constants for our various types of MSP chips
+ */
+#define MSPETH_MAX_UNITS	3
+#define STDETH_MAX_UNITS	8
+
+/**************************************************************************
+ * Tuning parameters
+ */
+#define DMA_BURST_SIZE	32	/* maximum burst size for the DMA transfers */
+#define TX_TIMEOUT	1	/* time (in seconds) for the TX timeout */
+
+#if defined(CONFIG_PMC_MSP7120_EVAL) || \
+    defined(CONFIG_PMC_MSP7120_GW) || \
+    defined(CONFIG_PMC_MSP7120_FPGA)
+#define TX_THRESHOLD	100	/* MAC TX fifo depth before we start sending */
+#else
+#define TX_THRESHOLD	1000	/* MAC TX fifo depth before we start sending */
+#endif
+#define TX_POLL_CNT	0	/* interval for the TX poll mechanism
+				 * -- not used, leave at zero */
+#define LINK_DELAY_DIV	4	/* delay for checking the link status	*/
+#define RX_MAX_PKT	16	/* maximum number of packet the RX handler */
+				/* will process at one time 		*/
+
+/*
+ * Define the RX/TX buffer counts. Notice that they *must* be <= 256 and
+ * also a power of two. So much so that we test for it at compile time and
+ * set the order  of the queue lengths instead of the numbers directly.
+ *
+ * cavanaug 2006-02-21: Changed buffer order from 5 to 6. This prevents
+ * corruption of the queues on eth1 that were preventing eth1 from working
+ * without the cable being unplugged and plugged back in.
+ */
+#define RX_BUF_ORDER	6	/* 64 buffers */
+#define TX_BUF_ORDER	6	/* 64 buffers */
+
+/* Use 0 for production, 1 for verification, >2 for debug */
+#ifndef MSPETH_DEBUG
+#define MSPETH_DEBUG	0
+#endif
+
+/**************************************************************************
+ * Buffer sizes
+ */
+#define MAX_PKT_SIZE		1532
+#define MSP_END_PREPEND		224
+#define MAX_ETH_BUFFER_SIZE	(MAX_PKT_SIZE + MSP_END_PREPEND)
+#define MSP_END_BUFSIZE		(MAX_ETH_BUFFER_SIZE + 24)
+
+/**************************************************************************
+ * Option defines
+ */
+#define MSP_OPT_AUTO	0x00
+#define MSP_OPT_10M	0x01
+#define MSP_OPT_100M	0x02
+#define MSP_OPT_FDUP	0x04
+#define MSP_OPT_HDUP	0x08
+#define MSP_OPT_SWITCH	0x10
+
+/**************************************************************************
+ * Local error codes etc (mac errors start at 9000)
+ */
+#define MSP_SUCCESS		0
+#define MSP_FAIL		-1
+#define MSP_MAC_MEM_ALLOC_ERROR	9002
+#define MSP_MAC_PHY_ERROR	9006
+#define MSP_MAC_PHY_NO_LINK	9012
+
+/**************************************************************************
+ * Hardware register locations & constants
+ */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#define MSP_MAC0_BASE	0xB8600000	/* Base address to MAC0 Controller */
+#define MSP_MAC1_BASE	0xB8700000	/* Base address to MAC1 Controller */
+#define MSP_MAC2_BASE	0xB8900000	/* Base address to MAC2 Controller */
+#define MSP_RST_BASE	SYS_RST_REG	/* Base address to system reset	   */
+
+#define MSP_EA_RST	MAC0_RST
+#define MSP_EB_RST	MAC1_RST
+#define MSP_EC_RST	MAC2_RST
+
+#define	MSP_INT_MAC0	BRECISINT_MAC0
+#define	MSP_INT_MAC1	BRECISINT_MAC1
+#define	MSP_INT_MAC2	BRECISINT_MAC2
+
+#define MEM_CFG1_REG	MEM_CNFG1_REG
+#endif
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
+#ifndef MSP_INT_MAC2
+#define MSP_INT_MAC2	0
+#endif
+#endif
+
+/**************************************************************************
+ * Macros & inline functions
+ */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#define IRQ_HANDLED
+#define IRQ_NONE
+#endif
+
+/* Select the correct cache flush/invalidate operations */
+#if CONFIG_MIPS_L1_CACHE_SHIFT == 4
+#define CACHE_UNROLL	cache16_unroll32
+#define UNROLL_INCR	0x200
+#elif CONFIG_MIPS_L1_CACHE_SHIFT == 5
+#define CACHE_UNROLL	cache32_unroll32
+#define UNROLL_INCR	0x400
+#elif CONFIG_MIPS_L1_CACHE_SHIFT == 6
+#define CACHE_UNROLL	cache64_unroll32
+#define UNROLL_INCR	0x800
+#elif (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
+      (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
+#define CACHE_UNROLL	cache16_unroll32
+#define UNROLL_INCR	0x200
+#endif
+
+/**************************************************************************
+ * Register definitions
+ */
+
+/* MAC */
+#define MSPETH_DMA_Ctl		0x00
+#define MSPETH_TxFrmPtr		0x04
+#define MSPETH_TxThrsh		0x08
+#define MSPETH_TxPollCtr	0x0c
+#define MSPETH_BLFrmPtr		0x10
+#define MSPETH_RxFragSize	0x14
+#define MSPETH_Int_En	 	0x18
+#define MSPETH_FDA_Bas		0x1c
+#define MSPETH_FDA_Lim		0x20
+#define MSPETH_Int_Src		0x24
+#define MSPETH_PauseCnt		0x30
+#define MSPETH_RemPauCnt	0x34
+#define MSPETH_TxCtlFrmStat	0x38
+#define MSPETH_MAC_Ctl		0x40
+#define MSPETH_ARC_Ctl		0x44
+#define MSPETH_Tx_Ctl	 	0x48
+#define MSPETH_Tx_Stat		0x4c
+#define MSPETH_Rx_Ctl	 	0x50
+#define MSPETH_Rx_Stat		0x54
+#define MSPETH_MD_DATA		0x58
+#define MSPETH_MD_CA	 	0x5c
+#define MSPETH_ARC_Adr		0x60
+#define MSPETH_ARC_Data		0x64
+#define MSPETH_ARC_Ena		0x68
+#define MSPETH_Miss_Cnt		0x7c
+#define MSPETH_BSWE1_Add	0xc0
+#define MSPETH_BSWE2_Add	0xc4
+#define MSPETH_BMWE1_Add	0xc8
+#define MSPETH_BMWE2_Add	0xcc
+#define MSPETH_INTBRW_Add	0xd0
+#define MSPETH_BCTRL_Reg	0xd4
+
+/* PHY */
+#define MSPPHY_MII_DATA		0x00
+#define MSPPHY_MII_CTRL		0x04
+
+/* Reset */
+#define MSPRST_STS		0x00
+#define MSPRST_SET		0x04
+#define MSPRST_CLR		0x08
+
+/*
+ * Bit Assignments
+ */
+
+/* DMA_Ctl (0x00) bit assign -------------------------------------------*/
+#define DMA_RxAlign3	0x00C00000 /* Receive Alignment (skip 3 bytes)	*/
+#define DMA_RxAlign2	0x00800000 /* Receive Alignment (skip 2 bytes)	*/
+#define DMA_RxAlign1	0x00400000 /* Receive Alignment (skip 1 byte)	*/
+/* RESERVED		0x00300000    Not used, must be zero	 	*/
+#define DMA_M66EnStat	0x00080000 /* 1:Station clock/30	 	*/
+#define DMA_IntMask	0x00040000 /* 1:Interupt mask		 	*/
+#define DMA_SWIntReq	0x00020000 /* 1:Software Interrupt request	*/
+#define DMA_TxWakeUp	0x00010000 /* 1:Transmit Wake Up		*/
+#define DMA_RxBigE	0x00008000 /* 1:Receive Big Endian		*/
+#define DMA_TxBigE	0x00004000 /* 1:Transmit Big Endian		*/
+#define DMA_TestMode	0x00002000 /* 1:Test Mode			*/
+#define DMA_PowrMgmnt	0x00001000 /* 1:Power Management		*/
+#define DMA_BRST_Mask	0x000001fc /* DMA Burst size		 	*/
+#define DMA_BRST_Shift	2
+
+/* RxFragSize (0x14) bit assign --------------------------------------- */
+#define RxFrag_EnPack		0x00008000 /* 1:Enable Packing		*/
+#define RxFrag_MinFragMask	0x00000ffc /* Minimum Fragment		*/
+
+/*
+ * Int_En (0x18) bit assign -------------------------------------------
+ * Since bit 6 of the Int_En register at 0x18 is reserved and even writing
+ * to this register bit causes random interrupts, take caution when writing
+ * to this register - always write 0 there. For this reason there are two
+ * definitions for Enable and Disable and couldn't use the ~ of the Enable
+ * for Disable,
+ */
+#define IntEn_NRAB	0x00000800 /* Non-recoverable abort enable	*/
+#define IntEn_TxCtlCmp	0x00000400 /* Transmit Ctl Complete enable	*/
+#define IntEn_DmParErr	0x00000200 /* DMA Parity Error enable		*/
+#define IntEn_DParD	0x00000100 /* Data Parity Detected enable	*/
+#define IntEn_EarNot	0x00000080 /* Early Rx Notify enable		*/
+/* RESERVED		0x00000040    Not used, must be zero		*/
+#define IntEn_SSysErr	0x00000020 /* Signalled System Error enable	*/
+#define IntEn_RMAB	0x00000010 /* Received Master Abort enable	*/
+#define IntEn_RTAB	0x00000008 /* Received Target Abort enable	*/
+#define IntEn_STAB	0x00000004 /* Signaled Target Abort enable	*/
+#define IntEn_BLEx	0x00000002 /* Buffer List Exhausted enable	*/
+#define IntEn_FDAEx	0x00000001 /* FDA Exhausted Enable		*/
+
+/* Int_Src (0x24) bit assign ------------------------------------------ */
+#define IntSrc_ExtE		0x00040000 /* External Event int.	*/
+/* RESERVED			0x00020000    Not used, must be zero	*/
+#define IntSrc_ExDefer		0x00010000 /* Excessive Tx Deferrals int. */
+#define IntSrc_Link_St		0x00008000 /* Link State Change status	*/
+#define IntSrc_NRAB		0x00004000 /* Non-recoverable abort int.*/
+#define IntSrc_DmParErr		0x00002000 /* DMA Parity Error int.	*/
+#define IntSrc_BLEx		0x00001000 /* Buffer List Exhausted int	*/
+#define IntSrc_FDAEx		0x00000800 /* FDA Exhausted, int.	*/
+#define IntSrc_NRAB_St		0x00000400 /* Non-recoverable abort status */
+#define	IntSrc_Cmp		0x00000200 /* MAC ctrl packet int.	*/
+#define IntSrc_ExBD		0x00000100 /* Excessive BD status	*/
+#define IntSrc_DmParErr_St	0x00000080 /* DMA Parity Error status	*/
+#define IntSrc_EarNot		0x00000040 /* Rx early notify int.	*/
+#define IntSrc_SWInt_St		0x00000020 /* Software Request status	*/
+#define IntSrc_BLEx_St		0x00000010 /* Buffer List Exhausted status */
+#define IntSrc_FDAEx_St		0x00000008 /* FDA Exhausted status	*/
+/* RESERVED			0x00000004    Not used, must be zero	*/
+#define IntSrc_MacRx		0x00000002 /* Rx packet int.		*/
+#define IntSrc_MacTx		0x00000001 /* Tx packet int.		*/
+
+/* MAC_Ctl (0x40) bit assign ------------------------------------------ */
+#define MAC_Link10		0x00008000 /* 1:Link Status 10Mbits	*/
+/* RESERVED			0x00004000    Not used, must be zero	*/
+#define MAC_EnMissRoll		0x00002000 /* 1:Enable Missed Roll	*/
+#define MAC_MissRoll		0x00000400 /* 1:Missed Roll		*/
+#define MAC_LnkChg		0x00000100 /* write 1 to clear Int_Link	*/
+#define MAC_Loop10		0x00000080 /* 1:Loop 10 Mbps		*/
+#define MAC_Conn_Auto	 	0x00000000 /* 00:Connection mode (Automatic) */
+#define MAC_Conn_10M		0x00000020 /* 01:10Mbps endec)		*/
+#define MAC_Conn_Mll		0x00000040 /* 10:(Mll clock)		*/
+#define MAC_MacLoop		0x00000010 /* 1:MAC Loopback		*/
+#define MAC_FullDup		0x00000008 /* 1:Full Duplex 0:Half Duplex */
+#define MAC_Reset		0x00000004 /* 1:Software Reset		*/
+#define MAC_HaltImm		0x00000002 /* 1:Halt Immediate		*/
+#define MAC_HaltReq		0x00000001 /* 1:Halt request		*/
+
+ /* ARC_Ctl (0x44) (bit assign ---------------------------------------- */
+#define ARC_CompEn		0x00000010 /* 1:ARC Compare Enable	*/
+#define ARC_NegCAM		0x00000008 /* 1:Reject packets ARC	*/
+					   /* recognizes, accept other */
+#define ARC_BroadAcc		0x00000004 /* 1:Broadcast accept	*/
+#define ARC_GroupAcc		0x00000002 /* 1:Multicast accept	*/
+#define ARC_StationAcc		0x00000001 /* 1:unicast accept		*/
+
+/* Tx_Ctl (0x48) bit assign ------------------------------------------- */
+#define Tx_EnComp		0x00004000 /* 1:Enable Completion	*/
+#define Tx_EnTxPar		0x00002000 /* 1:Enable Transmit Parity	*/
+#define Tx_EnLateColl		0x00001000 /* 1:Enable Late Collision	*/
+#define Tx_EnExColl		0x00000800 /* 1:Enable Excessive Collision */
+#define Tx_EnLCarr		0x00000400 /* 1:Enable Lost Carrier	*/
+#define Tx_EnExDefer		0x00000200 /* 1:Enable Excessive Deferral */
+#define Tx_EnUnder		0x00000100 /* 1:Enable Underrun		*/
+#define Tx_FBack		0x00000010 /* 1:Fast Back-off		*/
+#define Tx_NoCRC		0x00000008 /* 1:Suppress Padding	*/
+#define Tx_NoPad		0x00000004 /* 1:Suppress Padding	*/
+#define Tx_TxHalt		0x00000002 /* 1:Transmit Halt Request	*/
+#define Tx_En			0x00000001 /* 1:Transmit enable		*/
+
+/* Tx_Stat (0x4C) bit assign ------------------------------------------ */
+#define Tx_SQErr		0x00010000 /* Signal Quality Error(SQE)	*/
+#define Tx_Halted		0x00008000 /* Tx Halted			*/
+#define Tx_Comp			0x00004000 /* Completion		*/
+#define Tx_TxPar		0x00002000 /* Tx Parity Error		*/
+#define Tx_LateColl		0x00001000 /* Late Collision		*/
+#define Tx_10Stat		0x00000800 /* 10Mbps Status		*/
+#define Tx_NCarr		0x00000400 /* No Carrier		*/
+#define Tx_Defer		0x00000200 /* Deferral			*/
+#define Tx_Under		0x00000100 /* Underrun			*/
+#define Tx_IntTx		0x00000080 /* Interrupt on Tx		*/
+#define Tx_Paused		0x00000040 /* Transmit Paused		*/
+#define Tx_TXDefer		0x00000020 /* Transmit Defered		*/
+#define Tx_ExColl		0x00000010 /* Excessive Collision	*/
+#define Tx_TxColl_MASK		0x0000000F /* Tx Collision Count	*/
+
+/*
+ * Rx_Ctl (0x50) bit assign -------------------------------------------
+ * EnLenErr is a bit that is NOT defined in the manual but was added
+ * It indicates the reception of a frame whose protocol id field value
+ * does not match a length. This interrupt allows us the process IP
+ * and other packets whose protocol id field is not treated as a length
+ */
+#define Rx_EnGood		0x00004000 /* 1:Enable Good		*/
+#define Rx_EnRxPar		0x00002000 /* 1:Enable Receive Parity	*/
+#define Rx_EnLenErr		0x00001000 /* 1:Enable Length Error	*/
+#define Rx_EnLongErr		0x00000800 /* 1:Enable Long Error	*/
+#define Rx_EnOver		0x00000400 /* 1:Enable OverFlow		*/
+#define Rx_EnCRCErr		0x00000200 /* 1:Enable CRC Error	*/
+#define Rx_EnAlign		0x00000100 /* 1:Enable Alignment	*/
+/* RESERVED			0x00000080    Not used, must be zero	*/
+#define Rx_IgnoreCRC		0x00000040 /* 1:Ignore CRC Value	*/
+#define Rx_StripCRC		0x00000010 /* 1:Strip CRC Value		*/
+#define Rx_ShortEn		0x00000008 /* 1:Short Enable		*/
+#define Rx_LongEn		0x00000004 /* 1:Long Enable		*/
+#define Rx_RxHalt		0x00000002 /* 1:Receive Halt Request	*/
+#define Rx_RxEn			0x00000001 /* 1:Receive Intrrupt Enable	*/
+
+/* Rx_Stat (0x54) bit assign ------------------------------------------ */
+#define Rx_Halted		0x00008000 /* Rx Halted			*/
+#define Rx_Good			0x00004000 /* Rx Good			*/
+#define Rx_RxPar		0x00002000 /* Rx Parity Error		*/
+/* RESERVED			0x00001000    Not used, must be zero	*/
+#define Rx_LongErr		0x00000800 /* Rx Long Error		*/
+#define Rx_Over			0x00000400 /* Rx Overflow		*/
+#define Rx_CRCErr		0x00000200 /* Rx CRC Error		*/
+#define Rx_Align		0x00000100 /* Rx Alignment Error	*/
+#define Rx_10Stat		0x00000080 /* Rx 10Mbps Status		*/
+#define Rx_IntRx		0x00000040 /* Rx Interrupt		*/
+#define Rx_CtlRecd		0x00000020 /* Rx Control Receive	*/
+#define Rx_Stat_Mask		0x0000EFC0 /* Rx All Status Mask	*/
+
+/* MD_CA (0x5C) bit assign -------------------------------------------- */
+#define MD_CA_PreSup		0x00001000 /* 1:Preamble Supress	*/
+#define MD_CA_BUSY_BIT	 	0x00000800 /* 1:Busy (Start Operation)	*/
+#define MD_CA_Wr		0x00000400 /* 1:Write 0:Read		*/
+#define MD_CA_PHYADD		0x000003E0 /* bits 9:5			*/
+#define MD_CA_PHYREG		0x0000001F /* bits 4:0			*/
+#define MD_CA_PhyShift		5
+#define MD_MAX_PHY		32	/* Maximum number of PHY per MII */
+#define MD_UNASSIGNED_PHY	0xFD	/* PHY address has not been 	*/
+					/* determined yet		*/
+#define MD_SWITCH_PHY		0xFE	/* No PHY exists		*/
+#define MD_DYNAMIC_PHY		0xFF	/* Dynamically find phy 	*/
+
+/* ARC_Ena (0x68) bit assign ------------------------------------------ */
+#define ARC_ENTRY_MAX		21	 /* ARC Data entry max count	*/
+#define ARC_Ena_Mask		((1 << ARC_ENTRY_MAX) - 1)
+					/* ARC Enable bits (Max 21) */
+#define ARC_Ena_Bit(index)	(1 << (index))
+#define ARC_ENTRY_DESTINATION	0
+#define ARC_ENTRY_SOURCE	1
+#define ARC_ENTRY_MACCTL	20
+
+/* BCTRL_Reg (0xd4) bit assign ---------------------------------------- */
+#define RMII_Reset		0x00000004 /* RMII Reset		*/
+#define RMII_10MBIT		0x00000002 /* 1 if 10 Mbs, 0 if 100 Mbs */
+#define RMII_ClkRising		0x00000001 /* 0 if TxD generated off	*/
+					   /* falling edge,		*/
+					   /* 1 if generated off	*/
+					   /* rising edge of Tx-CLK	*/
+
+/**********************************************************************
+ * Data structures
+ */
+
+/* Frame descripter */
+struct f_desc {
+	volatile u32 FDNext;
+	volatile u32 FDSystem;
+	volatile u32 FDStat;
+	volatile u32 FDCtl;
+};
+
+/* Buffer descripter */
+struct b_desc {
+	volatile u32 BuffData;
+	volatile u32 BDCtl;
+};
+
+#define FD_ALIGN	16
+
+/* Frame Descripter bit assign ---------------------------------------- */
+#define FD_Next_EOL		0x00000001 /* FDNext EOL indicator	*/
+#define FD_Next_MASK		0xFFFFFFF0 /* FDNext valid pointer	*/
+
+#define FD_FDLength_MASK	0x0000FFFF /* Length MASK		*/
+#define FD_BDCnt_MASK	 	0x001F0000 /* BD count MASK in FD	*/
+#define FD_FrmOpt_MASK	 	0x7C000000 /* Frame option MASK		*/
+#define FD_FrmOpt_BigEndian	0x40000000 /* Tx/Rx			*/
+#define FD_FrmOpt_IntTx		0x20000000 /* Tx only			*/
+#define FD_FrmOpt_NoCRC		0x10000000 /* Tx only			*/
+#define FD_FrmOpt_NoPadding	0x08000000 /* Tx only			*/
+#define FD_FrmOpt_Packing	0x04000000 /* Rx only			*/
+#define FD_CownsFD		0x80000000 /* FD Controller owner bit	*/
+#define FD_BDCnt_SHIFT	 	16
+#define FD_CownsFD_Set		0x80010000 /* (FD_CownsFD | 		*/
+					   /* (1 << FD_BDCnt_SHIFT))	*/
+
+/* Buffer Descripter bit assign --------------------------------------- */
+#define BD_BuffLength_MASK	0x0000FFFF /* Recieve Data Size		*/
+#define BD_RxBDID_MASK		0x00FF0000 /* BD ID Number MASK		*/
+#define BD_RxBDSeqN_MASK	0x7F000000 /* Rx BD Sequence Number	*/
+#define BD_CownsBD		0x80000000 /* BD Controller owner bit	*/
+#define BD_DataAlign_MASK	0xFFFFFFF0 /* Buffer alignment mask	*/
+#define BD_RxBDID_SHIFT		16
+#define BD_RxBDSeqN_SHIFT	24
+
+/* Operational constants */
+#define DMA_CTL_CMD (DMA_M66EnStat | DMA_RxBigE | DMA_TxBigE | \
+			DMA_RxAlign2 | (DMA_BURST_SIZE << DMA_BRST_Shift))
+
+#define TX_CTL_CMD (Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
+			Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | \
+			Tx_EnUnder | Tx_En)
+
+#define RX_CTL_CMD (Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver | \
+			Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn)
+
+#define INT_EN_CMD (IntEn_NRAB | IntEn_DmParErr | IntEn_SSysErr | \
+			IntEn_BLEx | IntEn_FDAEx)
+
+#define FATAL_ERROR_INT (IntSrc_NRAB | IntSrc_DmParErr | IntSrc_BLEx)
+
+#define BMSR_EXISTS (BMSR_ANEGCAPABLE | BMSR_10HALF | BMSR_10FULL | \
+			BMSR_100HALF | BMSR_100FULL)
+
+/* Error check and calculate constants & masks */
+#if RX_BUF_ORDER > 8 || RX_BUF_ORDER < 0
+#error "RX buffer order out of limits. 0 < ORDER < 9"
+#endif
+
+#if TX_BUF_ORDER > 8 || TX_BUF_ORDER < 0
+#error "TX buffer order out of limits. 0 < ORDER < 9"
+#endif
+
+#define RX_BUF_NUM	(1 << RX_BUF_ORDER)
+#define RX_BUF_MASK	(RX_BUF_NUM - 1)
+#define TX_BUF_NUM	(1 << TX_BUF_ORDER)
+#define TX_BUF_MASK	(TX_BUF_NUM - 1)
+
+#ifdef CONFIG_MSPETH_NAPI
+#define TXDONE_MAX_PKT	4
+#define NAPI_WEIGHT	64	/* Number of packets handled at one poll */
+#else
+#define TXDONE_MAX_PKT	TX_BUF_NUM
+#endif /* CONFIG_MSPETH_NAPI */
+
+#ifdef CONFIG_MSPETH_SKB_RECYCLE
+#define SKBUFF_RECYCLABLE_SIZE (SKB_DATA_ALIGN(MSP_END_BUFSIZE + 2 + 16))
+
+/* Handler for skb recycle bin */
+struct {
+	struct sk_buff	*recycle_queue; /* recyclable skbs are queued here */
+	unsigned long	recycle_max;	/* storage capacity in no.of skbs */
+	unsigned long	recycle_count;	/* avilable skbs in bin */
+	unsigned long	user_count;	/* bin usage count */
+	unsigned long	recycle_hits;	/* number of hits */
+	unsigned long	recycle_misses; /* number of misses */
+	spinlock_t	lock;		/* for mutual exclusion */
+} skb_bin;
+#endif /* CONFIG_MSPETH_SKB_RECYCLE */
+
+struct q_desc {
+	union {
+		struct f_desc fd;
+		struct f_desc fd0;
+	};
+	union {
+		struct b_desc bd;
+		struct f_desc fd1;
+	};
+};
+
+/*
+ * hammtrev, 2005-11-25:
+ * Apparently, the MSP Ethernet has a hardware issue which could hang the
+ * device if a BLEx interrupt comes before a FDAEx, so they should be
+ * avoided if at all possible. Changing to ensure there are twice as many
+ * buffer descriptors as frame descriptors.
+ */
+struct bl_desc {
+	struct f_desc fd;
+	struct b_desc bd[RX_BUF_NUM << 1];
+};
+
+
+/* Structure to define access to each phy (for control purposes) */
+struct mspeth_phy {
+	struct mspeth_phy *next_phy;
+	u8 hwunit;
+	u8 phyaddr;
+	void *memaddr;
+	bool assigned;
+	bool linkup;
+	spinlock_t lock;
+};
+
+/* Information that need to be kept for each board. */
+struct mspeth_priv {
+	/* device configuration & constants */
+	u8 unit;		/* logical unit number */
+	u8 hwunit;		/* hardware unit number */
+	u8 option;		/* option setting from PROM or bootline */
+	int speed;		/* actual speed, 10 or 100 */
+	bool fullduplex;	/* actual duplex */
+
+	/* device object pointer */
+	struct device *dev;
+
+	/* phy configuration & control index */
+	struct mspeth_phy *phyptr;
+
+	/* ioremapped register access cookie */
+	void *mapaddr;
+	
+	/* ioremapped system reset registers */
+	void *rstaddr;
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
+	/*
+	 * Buffer structures
+	 *
+	 * Transmitting: Batch Mode.
+	 * 1 BD in 1 TxFD
+	 * circular list of FDs
+	 * Receiving: Non-Packing mode
+	 * 1 circular FD for Free Buffer List.
+	 * RX_BUF_NUM BD in Free Buffer FD.
+	 * One Free Buffer BD has preallocated skb data
+	 */
+	void *fd_base;
+
+	struct q_desc *rxfd_base; /* RX FD region ptr */
+	struct q_desc *rxfd_curr; /* RX FD current ptr */
+	struct q_desc *txfd_base; /* TX FD region ptr */
+
+	u32 tx_head, tx_tail;	/* insert/delete for TX queue */
+	atomic_t tx_qspc;	/* space available on the transmit queue */
+
+	struct bl_desc *blfd_ptr; /* Free list FD head */
+	struct sk_buff **rx_skbp; /* RX skb ptr array */
+	dma_addr_t *rx_dma_skbp;  /* RX dma map array */
+};
+
+#endif /* _MSPETH_H_ */
diff --git a/arch/mips/pmc-sierra/msp71xx/msp_eth.c b/arch/mips/pmc-sierra/msp71xx/msp_eth.c
new file mode 100644
index 0000000..8799960
--- /dev/null
+++ b/arch/mips/pmc-sierra/msp71xx/msp_eth.c
@@ -0,0 +1,122 @@
+/*
+ * The setup file for ethernet related hardware on PMC-Sierra MSP processors.
+ *
+ * Copyright 2005-2006 PMC-Sierra, Inc.
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
+#include <linux/platform_device.h>
+
+#include <msp_regs.h>
+#include <msp_int.h>
+
+#if defined(CONFIG_PMC_MSP4200_GW)
+#include <msp_regops.h>
+#include <msp_gpio.h>
+#define	MSP_ETH_GPIO		9
+#define	MSP_ETH_GPIO_MODE_REG	GPIO_CFG3_REG
+#define	MSP_ETH_GPIO_DATA_REG	GPIO_DATA3_REG
+#elif defined(CONFIG_PMC_MSP7120_GW)
+#include <msp_regops.h>
+#include <msp_gpio.h>
+#define MSP_ETH_GPIO		14
+#define	MSP_ETH_GPIO_MODE_REG	GPIO_CFG4_REG
+#define	MSP_ETH_GPIO_DATA_REG	GPIO_DATA4_REG
+#endif
+
+#define MSP_ETH_ID	"mspeth"
+
+static struct resource msp_eth0_resources[] = {
+	[0] = {
+		.start	= MSP_MAC0_BASE,
+		.end	= MSP_MAC0_BASE + MSP_MAC_SIZE - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start	= MSP_INT_MAC0,
+		.end	= MSP_INT_MAC0,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct resource msp_eth1_resources[] = {
+	[0] = {
+		.start	= MSP_MAC1_BASE,
+		.end	= MSP_MAC1_BASE + MSP_MAC_SIZE - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start	= MSP_INT_MAC1,
+		.end	= MSP_INT_MAC1,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device msp_eth_devs[] = {
+	[0] = {
+		.name	= MSP_ETH_ID,
+		.id	= 0,
+		.num_resources = ARRAY_SIZE(msp_eth0_resources),
+		.resource = msp_eth0_resources,
+	},
+	[1] = {
+		.name	= MSP_ETH_ID,
+		.id	= 1,
+		.num_resources = ARRAY_SIZE(msp_eth1_resources),
+		.resource = msp_eth1_resources,
+	},
+};
+
+static int __init msp_eth_setup(void)
+{
+	int i, ret = 0;
+	
+#if defined(CONFIG_PMC_MSP4200_GW) || \
+    defined(CONFIG_PMC_MSP7120_GW)
+	/* Configure the GPIO and take the ethernet PHY out of reset */
+	set_value_reg32(MSP_ETH_GPIO_MODE_REG,
+			BASIC_MODE_MASK(MSP_ETH_GPIO),
+			BASIC_MODE(MSP_GPIO_OUTPUT, MSP_ETH_GPIO));
+	set_reg32(MSP_ETH_GPIO_DATA_REG, 
+			BASIC_DATA_MASK(MSP_ETH_GPIO));
+#endif
+
+	/* Register the ethernet devices and bind the drivers */
+	for (i = 0; i < ARRAY_SIZE(msp_eth_devs); i++) {
+		ret = platform_device_register(&msp_eth_devs[i]);
+		if (ret) {
+			while (--i >= 0)
+				platform_device_unregister(&msp_eth_devs[i]);
+			break;
+		}
+	}
+	
+	if (ret)
+		printk(KERN_WARNING
+			"Could not initialize MSPETH device structures.\n");
+
+	return ret;
+}
+
+subsys_initcall(msp_eth_setup);
