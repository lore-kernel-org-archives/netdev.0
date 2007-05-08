From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Tue, 08 May 2007 01:38:54 -0400
Message-ID: <46400CEE.8050709@garzik.org>
References: <200704270048.l3R0m3WV015597@pasqua.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-mips@linux-mips.org
To: Marc St-Jean <stjeanma@pmc-sierra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54551 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967926AbXEHFjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:39:04 -0400
In-Reply-To: <200704270048.l3R0m3WV015597@pasqua.pmc-sierra.bc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +#include <linux/dma-mapping.h>
> +#include <linux/platform_device.h>
> +#include <net/xfrm.h>
> +#include <asm/cpu-features.h>
> +#include <msp_regs.h>
> +#include <msp_regops.h>
> +#include <msp_prom.h>
> +#include <msp_int.h>
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +#include <asm/r4kcache.h>
> +#include <asm/brecis/prom.h>
> +#include <asm/brecis/brecisint.h>
> +#include <asm/brecis/brecisint.h>
> +#include <asm/brecis/BrecisSysRegs.h>
> +#include <brecis/msp.h>
> +#endif /* LINUX_VERSION_CODE */
> +
> +#include "pmcmspeth.h"
> +
> +/**************************************************************************
> + * The name of the card. Is used for messages and in the requests for
> + * io regions, irqs and dma channels, versions, etc. Also, various other
> + * identifying character constants.
> + */
> +static const char cardname[] = "pmcmspeth";
> +
> +/**************************************************************************
> + * List of PHYs. Each MAC will have a certain number (maybe zero)
> + * PHYs hanging off the MDIO interface.
> + */
> +static struct mspeth_phy *root_phy_dev = NULL;
> +
> +/* Debugging flags */
> +static unsigned int mspeth_debug = MSPETH_DEBUG;

use netif_msg_init() and the bitmapped message flags.  grep for 
'netif_msg_' and 'msg_enable' in various drivers.


> +/**************************************************************************
> + * Function prototypes
> + */
> +
> +/* Functions that get called by upper layers */
> +static int mspeth_open(struct net_device *dev);
> +static int mspeth_send_packet(struct sk_buff *skb,
> +				struct net_device *dev);
> +static void mspeth_tx_timeout(struct net_device *dev);
> +static void mspeth_hard_restart_bh(unsigned long dev_addr);
> +static int mspeth_close(struct net_device *dev);
> +static struct net_device_stats *mspeth_get_stats(struct net_device *dev);
> +static void mspeth_set_multicast_list(struct net_device *dev);
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +static irqreturn_t mspeth_interrupt(int irq, void *dev_id);
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +static void mspeth_interrupt(int irq, void *dev_id, struct pt_regs *regs);
> +#endif

remove all kernel compat ifdefs



> +	/* protect access with spin lock */
> +	spin_lock_irqsave(&(phyptr->lock), flags);
> +
> +	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
> +		MD_CA_BUSY_BIT) {;}
> +	__raw_writel(MD_CA_BUSY_BIT | phyptr->phyaddr << 5 | phy_reg,
> +			phyptr->memaddr + MSPPHY_MII_CTRL);
> +	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
> +		MD_CA_BUSY_BIT) {;}
> +	data = __raw_readl(phyptr->memaddr + MSPPHY_MII_DATA);

no infinite loops allowed


> +	/* unlock */
> +	spin_unlock_irqrestore(&(phyptr->lock), flags);
> +
> +	return data & 0xffff;
> +}
> +
> +static void
> +mspphy_write(struct mspeth_phy *phyptr, int phy_reg, u32 data)
> +{
> +	unsigned long flags;
> +
> +	if (phyptr == NULL) {
> +		printk(KERN_WARNING "MSPETH(mspphy_write): "
> +			"Cannot write to a NULL PHY!\n");

This is a BUG_ON() condition


> +	/* protect access with spin lock */
> +	spin_lock_irqsave(&(phyptr->lock), flags);

remove extra parens


> +	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
> +		MD_CA_BUSY_BIT) {;}
> +	__raw_writel(data, phyptr->memaddr + MSPPHY_MII_DATA);
> +	__raw_writel(MD_CA_BUSY_BIT | MD_CA_Wr |
> +			phyptr->phyaddr << 5 | phy_reg,
> +			phyptr->memaddr + MSPPHY_MII_CTRL);
> +	while (__raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
> +		MD_CA_BUSY_BIT) {;}

no infinite loops


> +	/* unlock */
> +	spin_unlock_irqrestore(&(phyptr->lock), flags);
> +}
> +
> +#ifdef CONFIG_MSPETH_SKB_RECYCLE
> +/* initialise the recycle bin for skb */
> +static void
> +init_skbuff_bin(void)
> +{
> +	spin_lock_init(&skb_bin.lock);
> +	skb_bin.recycle_max = RX_BUF_NUM * 4; /* max size of bin */
> +	skb_bin.recycle_count = 0;
> +	skb_bin.recycle_queue = NULL;
> +	skb_bin.user_count = 0;
> +}
> +
> +/* free the skb's in recycle bin */
> +static void
> +free_skbuff_bin(void)
> +{
> +	spin_lock_bh(&skb_bin.lock);
> +
> +	/* check any skb's are present in the recycle bin */
> +	if (skb_bin.recycle_count > 0) {
> +		struct sk_buff *skb;
> +		while (skb_bin.recycle_queue != NULL ) {
> +			skb = skb_bin.recycle_queue->next;
> +			dev_kfree_skb_any(skb_bin.recycle_queue);
> +			skb_bin.recycle_queue = skb;
> +		}
> +	}
> +
> +	/* reset fields */
> +	skb_bin.recycle_queue = NULL;
> +	skb_bin.recycle_count = 0;
> +	
> +	spin_unlock_bh(&skb_bin.lock);
> +}
> +
> +inline static void
> +mspeth_skb_headerinit(struct sk_buff *skb)
> +{
> +	/* these are essential before init */
> +	dst_release(skb->dst);
> +#ifdef CONFIG_XFRM
> +	secpath_put(skb->sp);
> +#endif
> +#ifdef CONFIG_NETFILTER
> +	nf_conntrack_put(skb->nfct);
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	nf_conntrack_put_reasm(skb->nfct_reasm);
> +#endif
> +#ifdef CONFIG_BRIDGE_NETFILTER
> +	nf_bridge_put(skb->nf_bridge);
> +#endif
> +#endif /* CONFIG_NETFILTER */
> +
> +	/* now initialise the skb . . . */
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	/* clear the members till skb->truesize */
> +	memset(skb, 0, offsetof(struct sk_buff, truesize));
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +	skb->prev = NULL;
> +	skb->list = NULL;
> +	skb->sk = NULL;
> +	skb->stamp.tv_sec = 0;
> +#ifdef CONFIG_BRECIS
> +	skb->stamp.tv_usec = 0;
> +#endif /* CONFIG_BRECIS */
> +	skb->dev = NULL;
> +	skb->real_dev = NULL;
> +	skb->dst = NULL;
> +	memset(skb->cb, 0, sizeof(skb->cb));
> +	skb->pkt_type = PACKET_HOST;
> +	skb->priority = 0;
> +	skb->security = 0;
> +
> +#ifdef CONFIG_NETFILTER
> +	skb->nfmark = skb->nfcache = 0;
> +	skb->nfct = NULL;
> +#ifdef CONFIG_NETFILTER_DEBUG
> +	skb->nf_debug = 0;
> +#endif
> +#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
> +	skb->nf_bridge = NULL;
> +#endif
> +#endif /* CONFIG_NETFILTER */
> +#ifdef CONFIG_NET_SCHED
> +	skb->tc_index = 0;
> +#endif
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	skb->nfct_reasm = NULL;
> +#endif
> +#endif /* LINUX_VERSION_CODE */
> +}
> +#endif /* CONFIG_MSPETH_SKB_RECYCLE */

Absolutely not.  No.  NAK.  This is unmaintainable crap that does not 
belong in a driver at all.

You should not be hand-initializing skbs.


> +/**************************************************************************
> + * Allocate and align a max length socket buffer for this device
> + */
> +inline static struct sk_buff *
> +mspeth_alloc_skb(struct net_device *dev)
> +{
> +	struct sk_buff *skb = NULL;
> +	
> +#ifdef CONFIG_MSPETH_SKB_RECYCLE
> +	/* try to get an skb from the recycle bin */
> +	spin_lock_bh(&skb_bin.lock);
> +
> +	/* check if the bin si empty */
> +	if (skb_bin.recycle_queue) {
> +		/* grab an skb from the bin */
> +		skb = skb_bin.recycle_queue;
> +		skb_bin.recycle_queue = skb->next;
> +		
> +		/* we have taken one, so reduce the count */
> +		skb_bin.recycle_count--;
> +		skb_bin.recycle_hits++;
> +		spin_unlock_bh(&skb_bin.lock);
> +
> +		skb->next = NULL; /* must be set to NULL */
> +		skb->truesize = (skb->end - skb->head) +
> +				sizeof(struct sk_buff);
> +		atomic_set(&skb->users, 1);
> +		
> +		/* reset the payload pointers */
> +		skb->data = skb->head;
> +		skb->tail = skb->head;
> +
> +		/* reset shared info fields */
> +		atomic_set(&(skb_shinfo(skb)->dataref), 1);
> +		skb_shinfo(skb)->nr_frags = 0;
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +		skb_shinfo(skb)->gso_size = 0;
> +		skb_shinfo(skb)->gso_segs = 0;
> +#endif
> +		skb_shinfo(skb)->frag_list = NULL;
> +		
> +		/* compliance with __dev_alloc_skb */
> +		skb_reserve(skb, NET_SKB_PAD);
> +	} else {
> +		/* no skb in bin */
> +		spin_unlock_bh(&skb_bin.lock);
> +	}
> +#endif /* CONFIG_MSPETH_SKB_RECYCLE */
> +
> +	if (skb == NULL) {
> +		/*
> +		 * We need a bit more than an ethernet frame for the
> +		 * aligment stuff so preallocate two more.
> +		 */
> +		skb = dev_alloc_skb(MSP_END_BUFSIZE + 2);
> +#ifdef CONFIG_MSPETH_SKB_RECYCLE
> +		skb_bin.recycle_misses++;
> +#endif
> +		if (skb == NULL) {
> +			printk(KERN_WARNING "MSPETH(alloc_skb) %s: "
> +				"cannot allocate skb!\n", dev->name);
> +			return NULL;
> +		}
> +	}
> +
> +	/*
> +	 * Align and fill out fields specific to our device. Notice that
> +	 * our device is smart about FCS etc ......
> +	 */
> +	skb_reserve(skb, 2);
> +	skb->dev = dev;
> +	skb->ip_summed = CHECKSUM_NONE;
> +
> +	return skb;
> +}
> +
> +/**************************************************************************
> + * Add the used skb to recycle bin or free it
> + */
> +inline static void
> +mspeth_free_skb(struct sk_buff *skb)
> +{
> +#ifdef CONFIG_MSPETH_SKB_RECYCLE
> +	/*
> +	 * First try to recycle the skb.
> +	 * Check if the skb can be recycled.
> +	 */
> +	if ((skb->end - skb->head) >= SKBUFF_RECYCLABLE_SIZE &&
> +	    (!skb->destructor) &&
> +	    (!skb->cloned) &&
> +	    (atomic_dec_and_test(&skb->users))) {
> +		/* skb is recyclable */
> +		spin_lock_bh(&skb_bin.lock);
> +		
> +		/* check the bin has room to add our skb */
> +		if (likely(skb_bin.recycle_count < skb_bin.recycle_max)) {
> +			/* everything ok; go recycle it */
> +			/* prerequisite before adding to recycle bin */
> +			mspeth_skb_headerinit(skb);
> +			
> +			/* now we can add the skb to bin */
> +			skb->next = skb_bin.recycle_queue;
> +			skb_bin.recycle_queue = skb;
> +			
> +			/* we have one more skb in bin, increase the count */
> +			skb_bin.recycle_count++;
> +			
> +			spin_unlock_bh(&skb_bin.lock);
> +			return;
> +		} else {
> +			/* bin has no room */
> +			spin_unlock_bh(&skb_bin.lock);
> +		}
> +	}
> +#endif /* CONFIG_MSPETH_SKB_RECYCLE */
> +
> +	/* Can't add skb to recycle bin, so free it in normal way. */
> +	dev_kfree_skb_any(skb);
> +}
> +
> +/**************************************************************************
> + * Error reporting functions -- used for debugging mostly
> + */
> +static void
> +dump_qdesc(struct q_desc *fd)
> +{
> +	printk(KERN_INFO "  q_desc(%p): %08x %08x %08x %08x\n",
> +		fd, fd->fd.FDNext, fd->fd.FDSystem,
> +		fd->fd.FDStat, fd->fd.FDCtl);
> +	printk(KERN_INFO "    BD: %08x %08x\n",
> +		fd->bd.BuffData, fd->bd.BDCtl);
> +}
> +
> +static void
> +print_buf(char *add, int length)
> +{
> +	int i;
> +	int len = length;
> +
> +	printk(KERN_INFO "print_buf(%08x)(%x)\n",
> +		(unsigned int)add, length);
> +
> +	if (len > 100)
> +		len = 100;
> +	for (i = 0; i < len; i++) {
> +		printk(KERN_INFO " %2.2X", (unsigned char)add[i]);
> +		if (!(i % 16))
> +			printk(KERN_INFO "\n");
> +	}
> +	printk(KERN_INFO "\n");
> +}
> +
> +static void
> +print_eth(int rx, char *add, int len)
> +{
> +	int i;
> +	int lentyp;
> +
> +	if (rx)
> +		printk(KERN_INFO "\n************************** RX packet "
> +			"0x%08x ****************************\n", (u32)add);
> +	else
> +		printk(KERN_INFO "\n************************** TX packet "
> +			"0x%08x ****************************\n", (u32)add);
> +
> +	printk(KERN_INFO "---- ethernet ----\n");
> +	printk(KERN_INFO "==> dest: ");
> +	for (i = 0; i < 6; i++) {
> +		printk(KERN_INFO "%02x", (unsigned char)add[i]);
> +		printk((i < 5) ? KERN_INFO ":" : KERN_INFO "\n");
> +	}
> +
> +	printk(KERN_INFO "==>  src: ");
> +	for (i = 0; i < 6; i++) {
> +		printk(KERN_INFO "%02x", (unsigned char)add[i + 6]);
> +		printk((i < 5) ? KERN_INFO ":" : KERN_INFO "\n");
> +	}
> +	lentyp = ((unsigned char)add[12] << 8) | (unsigned char)add[13];
> +	if (lentyp <= 1500)
> +		printk(KERN_INFO "==>  len: %d\n", lentyp);
> +	else if (lentyp > 1535)
> +		printk(KERN_INFO "==> type: 0x%04x\n", lentyp);
> +	else
> +		printk(KERN_INFO "==> ltyp: 0x%04x\n", lentyp);
> +
> +	if (len > 0x100)
> +		len = 0x100;
> +
> +	for (i = 0; i < ((u32)add & 0x0000000F); i++)
> +		printk(KERN_INFO "   ");
> +	for (i = 0; i < len; i++, add++) {
> +		printk(KERN_INFO " %02x", *((unsigned char *)add));
> +		if (!(((u32)add + 1) % 16))
> +			printk(KERN_INFO "\n");
> +	}
> +	printk(KERN_INFO "\n");
> +}
> +
> +/*
> + * Used mainly for debugging unusual conditions signalled by a
> + * fatal error interrupt (eg, IntBLEx). This function stops the transmit
> + * and receive in an attempt to capture the true state of the queues
> + * at the time of the interrupt.
> + */
> +#undef MSPETH_DUMP_QUEUES
> +#ifdef MSPETH_DUMP_QUEUES
> +static void
> +dump_blist(struct bl_desc *fd)
> +{
> +	int i;
> +
> +	printk(KERN_INFO "  bl_desc(%p): %08x %08x %08x %08x\n",
> +		fd, fd->fd.FDNext,
> +			fd->fd.FDSystem, fd->fd.FDStat, fd->fd.FDCtl);
> +	for (i = 0; i < RX_BUF_NUM << 1; i++)
> +		printk(KERN_INFO "    BD #%d: %08x %08x\n",
> +			i, fd->bd[i].BuffData, fd->bd[i].BDCtl);
> +}
> +
> +/* Catalog the received buffers numbers */
> +static int rx_bdnums[2][RX_BUF_NUM << 2];
> +static int rx_bdnums_ind[2] = {0, 0};
> +static inline void
> +catalog_rx_bdnum(int hwnum, int bdnum)
> +{
> +	rx_bdnums_ind[hwnum] = (rx_bdnums_ind[hwnum] + 1) &
> +				((RX_BUF_NUM << 2) - 1);
> +	rx_bdnums[hwnum][rx_bdnums_ind[hwnum]] = bdnum;
> +}
> +
> +static void
> +mspeth_dump_queues(struct net_device *dev)
> +{
> +	struct mspeth_priv *lp = netdev_priv(dev);
> +	int unit = lp->unit;
> +	int i;
> +
> +	/* Halt Xmit and Recv to preserve the state of queues */
> +	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) & ~Rx_RxEn);
> +	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) & ~Tx_En);
> +
> +	/* Print receive queue */
> +	printk(KERN_INFO "Receive Queue\n");
> +	printk(KERN_INFO "=============\n\n");
> +	printk(KERN_INFO "rxfd_base = 0x%08x\n",
> +		(unsigned int) lp->rxfd_base);
> +	printk(KERN_INFO "rxfd_curr = 0x%08x\n",
> +		(unsigned int) lp->rxfd_curr);
> +	for (i = 0; i < RX_BUF_NUM; i++) {
> +		printk(KERN_INFO "%d:", i);
> +		dump_qdesc((struct q_desc *) &lp->rxfd_base[i]);
> +	}
> +
> +	/* Print transmit queue */
> +	printk(KERN_INFO "\nTransmit Queue\n");
> +	printk(KERN_INFO "==============\n");
> +	printk(KERN_INFO "txfd_base = 0x%08x\n",
> +		(unsigned int) lp->txfd_base);
> +	printk(KERN_INFO "tx_head = %d, tx_tail = %d\n",
> +		lp->tx_head, lp->tx_tail);
> +	for (i = 0; i < TX_BUF_NUM; i++) {
> +		printk(KERN_INFO "%d:", i);
> +		dump_qdesc((struct q_desc *) &lp->txfd_base[i]);
> +	}
> +
> +	/* Print the free buffer list */
> +	printk(KERN_INFO "\nFree Buffer List\n");
> +	printk(KERN_INFO "================\n");
> +	printk(KERN_INFO "blfd_ptr = 0x%08x\n", (unsigned int) lp->blfd_ptr);
> +	dump_blist(lp->blfd_ptr);
> +
> +	/* Print the bdnum history and current index as a reference */
> +	printk(KERN_INFO "\nbdnum history\n");
> +	printk(KERN_INFO "=============\n");
> +	for (i = 0; i < RX_BUF_NUM; i++) {
> +		printk(KERN_INFO "\t%d\t%d\t%d\t%d\n",
> +			rx_bdnums[unit][4 * i],
> +			rx_bdnums[unit][4 * i + 1],
> +			rx_bdnums[unit][4 * i + 2],
> +			rx_bdnums[unit][4 * i + 3]);
> +	}
> +	printk(KERN_INFO "Current bdnum index: %d\n", rx_bdnums_ind[unit]);
> +
> +	/* Re-enable Xmit/Recv */
> +	msp_write(lp, MSPETH_Rx_Ctl, msp_read(lp, MSPETH_Rx_Ctl) | Rx_RxEn);
> +	msp_write(lp, MSPETH_Tx_Ctl, msp_read(lp, MSPETH_Tx_Ctl) | Tx_En);
> +}
> +
> +static void
> +mspeth_dump_stats(struct net_device *dev)
> +{
> +	struct mspeth_priv *lp = netdev_priv(dev);
> +
> +	printk(KERN_INFO "Interface stats:\n");
> +	printk(KERN_INFO "\ttx_ints: %d\n", lp->lstats.tx_ints);
> +	printk(KERN_INFO "\trx_ints: %d\n", lp->lstats.rx_ints);
> +	printk(KERN_INFO "\ttx_full: %d\n", lp->lstats.tx_full);
> +	printk(KERN_INFO "\tfd_exha: %d\n", lp->lstats.fd_exha);
> +}
> +#else
> +#define mspeth_dump_stats(a) do {} while (0)
> +#define mspeth_dump_queues(a) do {} while (0)
> +#define catalog_rx_bdnum(a, b) do {} while (0)
> +#define dump_blist(a) do {} while (0)
> +#endif /* MSPETH_DUMP_QUEUES */
> +
> +/*
> + * Actual functions used in the driver are defined here. They should
> + * all start with mspeth.
> + */
> +
> +/**************************************************************************
> + * Check for an mspeth ethernet device and return 0 if there is one.
> + * Also a good time to fill out some of the device fields and do some
> + * preliminary initialization. The mspeth resources are statically
> + * allocated.
> + */
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +int mspeth_probe(struct platform_device *pldev)
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +int __init mspeth_probe(struct net_device *dev)
> +#endif
> +{
> +	int unit, hwunit;
> +	int i, err;
> +	u8 macaddr[8];
> +	struct mspeth_priv *lp;
> +	char tmp_str[128];
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	struct net_device *dev = NULL;
> +	struct resource *res;
> +	void *mapaddr;
> +	unit = pldev->id;
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +	sscanf(dev->name, "eth%d", &unit);
> +#endif
> +
> +	/* default return value -- no device here */
> +	err = -ENODEV;
> +
> +	/*
> +	 * Scan the hardware list and associate a logical unit with a
> +	 * hardware unit it's important to keep these two straight.
> +	 * hwunit is used for accessing the prom and all hardware.
> +	 * unit is used when parsing the commandline and any other
> +	 * uses that might refer to *all* eth devices (not just mspeth
> +	 * devices) in the system.
> +	 */
> +	for (i = 0, hwunit = 0; hwunit < MSPETH_MAX_UNITS; hwunit++) {
> +		if (identify_enet(hwunit) != FEATURE_NOEXIST)
> +			if (i++ == unit)
> +				break;
> +	}
> +
> +	/* Sanity checks on hardware parameters */
> +	if (unit < 0 || hwunit >= MSPETH_MAX_UNITS)
> +		goto out_err;
> +
> +	/* Retrieve the mac address from the PROM */
> +	snprintf(tmp_str, 128, "ethaddr%d", hwunit);
> +	if (get_ethernet_addr(tmp_str, macaddr)) {
> +		printk(KERN_WARNING "MSPETH(probe): "
> +			"No Mac addr specified for eth%d, hwunit %d\n",
> +			unit, hwunit);
> +		goto out_err;
> +	}
> +
> +	if (macaddr[0] & 0x01) {
> +		printk(KERN_WARNING "MSPETH(probe): "
> +			"Bad Multicast Mac addr specified for eth%d, "
> +			"hwunit %d %02x:%02x:%02x:%02x:%02x:%02x\n",
> +			unit, hwunit,
> +			macaddr[0], macaddr[1], macaddr[2],
> +			macaddr[3], macaddr[4], macaddr[5]);
> +		goto out_err;
> +	}
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	dev = alloc_etherdev(sizeof(struct mspeth_priv));
> +	if (!dev) {
> +		err = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	SET_MODULE_OWNER(dev);
> +	SET_NETDEV_DEV(dev, &pldev->dev);
> +	dev_set_drvdata(&pldev->dev, dev);
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +	/* Create & initialize the local device structure */
> +	if (dev->priv == NULL) {
> +		dev->priv = kmalloc(sizeof(struct mspeth_priv),
> +					GFP_KERNEL);
> +		if (dev->priv == NULL)
> +			goto out_err;
> +	}
> +#endif
> +
> +	lp = netdev_priv(dev);
> +	memset(lp, 0, sizeof(struct mspeth_priv));

redundant memset()


> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	lp->dev = &pldev->dev;
> +
> +	res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		printk(KERN_ERR "MSPETH(probe) %s: "
> +			"IOMEM resource not found for eth%d\n",
> +			dev->name, unit);
> +		goto out_netdev;
> +	}
> +	
> +	/* reserve the memory region */
> +	if (!request_mem_region(res->start, res->end - res->start + 1,
> +				cardname)) {
> +		printk(KERN_ERR "MSPETH(probe) %s: unable to "
> +			"get memory/io address region 0x08%lx\n",
> +			dev->name, dev->base_addr);
> +		goto out_netdev;
> +	}
> +
> +	/* remap the memory */
> +	mapaddr = ioremap_nocache(res->start, res->end - res->start + 1);
> +	if (!mapaddr) {
> +		printk(KERN_WARNING "MSPETH(probe) %s: "
> +			"unable to ioremap address 0x%08x\n",
> +			dev->name, res->start);
> +		goto out_unreserve;
> +	}
> +	
> +	lp->mapaddr = mapaddr;
> +	dev->base_addr = res->start;
> +	dev->irq = platform_get_irq(pldev, 0);
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +	/*
> +	 * Dig out the parameters from the defines and do other
> +	 * hwunit specific stuff
> +	 */
> +	switch (hwunit) {
> +	case 0:
> +		dev->base_addr = MSP_MAC0_BASE;
> +		dev->irq = MSP_INT_MAC0;
> +		break;
> +	case 1:
> +		dev->base_addr = MSP_MAC1_BASE;
> +		dev->irq = MSP_INT_MAC1;
> +		break;
> +	case 2:
> +		dev->base_addr = MSP_MAC2_BASE;
> +		dev->irq = MSP_INT_MAC2;
> +		break;
> +	default:
> +		printk(KERN_WARNING "MSPETH(probe): "
> +			"Unsupported hardware unit %d\n", hwunit);
> +		goto out_unmap;
> +	}
> +
> +	/* reserve the memory region */
> +	if (!request_mem_region(dev->base_addr, MSP_MAC_SIZE, cardname)) {
> +		printk(KERN_ERR "MSPETH(probe) %s: unable to "
> +			"get memory/io address region 0x08%lx\n",
> +			dev->name, dev->base_addr);
> +		goto out_err;
> +	}
> +
> +	/* remap the memory */
> +	lp->mapaddr = ioremap_nocache(dev->base_addr, MSP_MAC_SIZE);
> +	if (!lp->mapaddr) {
> +		printk(KERN_ERR "MSPETH(probe) %s: unable to "
> +			"ioremap address 0x%08lx\n",
> +			dev->name, dev->base_addr);
> +		goto out_unreserve;
> +	}
> +#endif
> +	
> +	/* remap the system reset registers */
> +	lp->rstaddr = ioremap_nocache(MSP_RST_BASE, MSP_RST_SIZE);
> +	if (!lp->rstaddr) {
> +		printk(KERN_ERR "MSPETH(probe) %s: unable to "
> +			"ioremap address 0x%08x\n",
> +			dev->name, MSP_RST_BASE);
> +		goto out_unmap;
> +	}
> +
> +	/* set the logical and hardware units */
> +	lp->unit = unit;
> +	lp->hwunit = hwunit;
> +
> +	/* probe for PHYS attached to this MACs MDIO interface */
> +	if (mspeth_phyprobe(dev))
> +		goto out_unmap;
> +
> +	/* parse the environment and command line */
> +	mspeth_init_cmdline(dev);
> +	mspeth_init_phyaddr(dev);
> +
> +	/* MAC address */
> +	dev->addr_len = ETH_ALEN;
> +	for (i = 0; i < dev->addr_len; i++)
> +		dev->dev_addr[i] = macaddr[i];
> +
> +	/* register the /proc entry */
> +	snprintf(tmp_str, 128, "pmcmspeth%d", unit);
> +	create_proc_read_entry(tmp_str, 0644, proc_net,
> +				mspeth_proc_info, dev);
> +
> +#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)) && \
> +    (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
> +	ether_setup(dev);
> +#endif
> +	/* set the various call back functions */
> +	dev->open		= mspeth_open;
> +	dev->stop		= mspeth_close;
> +	dev->tx_timeout		= mspeth_tx_timeout;
> +	dev->watchdog_timeo	= TX_TIMEOUT * HZ;
> +	dev->hard_start_xmit	= mspeth_send_packet;
> +	dev->get_stats		= mspeth_get_stats;
> +	dev->set_multicast_list = mspeth_set_multicast_list;
> +#ifdef CONFIG_MSPETH_NAPI
> +	dev->poll		= mspeth_poll;
> +	dev->weight		= NAPI_WEIGHT;
> +#endif
> +
> +	/* debugging output */
> +	printk(KERN_INFO
> +		"eth%d: found at physical address %lx, irq %d\n",
> +		unit, dev->base_addr, dev->irq);
> +	if (mspeth_debug > 1) {
> +		printk(KERN_INFO "MSPETH(probe) eth%d: "
> +			"associated with hardware unit %d\n",
> +			unit, hwunit);
> +		printk(KERN_INFO "MSPETH(probe) eth%d: assigned "
> +			"MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
> +			unit, macaddr[0], macaddr[1], macaddr[2],
> +			macaddr[3], macaddr[4], macaddr[5]);
> +		printk(KERN_INFO "MSPETH(probe) eth%d: "
> +			"phytype %c, phyclk %c\n",
> +			unit, identify_enet(hwunit),
> +			identify_enetTxD(hwunit));
> +	}
> +
> +#ifdef CONFIG_MSPETH_SKB_RECYCLE
> +	/* initialize the socket buffer recycle bin */
> +	init_skbuff_bin();
> +#endif
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	err = register_netdev(dev);
> +	if (err) {
> +		printk(KERN_WARNING "MSPETH(probe) eth%d: "
> +			"unable to register network device\n", unit);
> +		goto out_unmap;
> +	}
> +#endif
> +
> +	return 0;
> +
> +out_unmap:
> +	if (lp->rstaddr)
> +		iounmap(lp->rstaddr);	
> +	iounmap(lp->mapaddr);
> +	
> +out_unreserve:
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
> +	release_mem_region(res->start, res->end - res->start + 1);
> +
> +out_netdev: 
> +	free_netdev(dev);
> +#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
> +	release_mem_region(dev->base_addr, MSP_MAC_SIZE);
> +#endif
> +
> +out_err:
> +	return err;
> +}

I stopped reviewing here.  Will await resend with changes, particularly 
removal of all kernel back-compat code

