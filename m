From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Mon, 25 Oct 2004 04:24:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025082413.GA21877@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Continuing the merge...  e100, defxx, set-config no-op removal, acenic

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/media/dvb/dvb-core/dvb_net.c |    9 -
 drivers/net/acenic.c                 |  171 +++++++++++++++--------------------
 drivers/net/acenic.h                 |   23 +---
 drivers/net/acenic_firmware.h        |    2 
 drivers/net/defxx.c                  |  144 ++++++++++++++---------------
 drivers/net/defxx.h                  |    2 
 drivers/net/e100.c                   |   51 ++++++----
 drivers/net/ibmlana.c                |    9 -
 drivers/net/meth.c                   |   26 -----
 drivers/net/sk_mca.c                 |    9 -
 drivers/net/wan/lmc/lmc_main.c       |    9 -
 drivers/net/wireless/netwave_cs.c    |   12 --
 12 files changed, 185 insertions(+), 282 deletions(-)

through these ChangeSets:

Anton Blanchard:
  o fix acenic hotplug

Ganesh Venkatesan:
  o e100: Driver version number update
  o e100: Fix set ringparam for ethtool returning error code on bad input
  o e100: Fix loss of connectivity to BMC when interface is brought down.
  o e100 driver version number update
  o e100 - use NET_IP_ALIGN to set rx data buffer alignment
  o e100 - Use pci_device_name for syslog messages till registering netdevice

Jeff Garzik:
  o [netdev] Remove no-op in-driver implementations of ->set_config()

Jesse Brandeburg:
  o e100: whitespace and DPRINTKS
  o e100: fix NAPI race with watchdog

Maciej W. Rozycki:
  o defxx device name fixes
  o defxx trivial updates

Stephen Hemminger:
  o (4/4) acenic - don't spin forever in hard_start_xmit
  o (3/4) acenic - __iomem warnings cleanup
  o (2/4) acenic - eliminate MAX_SKB_FRAGS #if
  o (1/4) acenic - use netdev_priv

diff -Nru a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
--- a/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-25 03:39:21 -04:00
@@ -917,14 +917,6 @@
 }
 
 
-static int dvb_net_set_config(struct net_device *dev, struct ifmap *map)
-{
-	if (netif_running(dev))
-		return -EBUSY;
-	return 0;
-}
-
-
 static void wq_restart_net_feed (void *data)
 {
 	struct net_device *dev = data;
@@ -983,7 +975,6 @@
 	dev->hard_start_xmit	= dvb_net_tx;
 	dev->get_stats		= dvb_net_get_stats;
 	dev->set_multicast_list = dvb_net_set_multicast_list;
-	dev->set_config         = dvb_net_set_config;
 	dev->set_mac_address    = dvb_net_set_mac;
 	dev->mtu		= 4096;
 	dev->mc_count           = 0;
diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/acenic.c	2004-10-25 03:39:21 -04:00
@@ -443,7 +443,7 @@
 MODULE_PARM_DESC(tx_ratio, "AceNIC/3C985/GA620 ratio of NIC memory used for TX/RX descriptors (range 0-63)");
 
 
-static char version[] __initdata = 
+static char version[] __devinitdata = 
   "acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
   "                            http://home.cern.ch/~jes/gige/acenic.html\n";
 
@@ -538,7 +538,7 @@
 	 * addresses but who gives a damn.
 	 */
 	dev->base_addr = pci_resource_start(pdev, 0);
-	ap->regs = (struct ace_regs *)ioremap(dev->base_addr, 0x4000);
+	ap->regs = ioremap(dev->base_addr, 0x4000);
 	if (!ap->regs) {
 		printk(KERN_ERR "%s:  Unable to map I/O register, "
 		       "AceNIC %i will be disabled.\n",
@@ -631,7 +631,7 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i;
 
 	unregister_netdev(dev);
@@ -884,7 +884,7 @@
 /*
  * Commands are considered to be slow.
  */
-static inline void ace_issue_cmd(struct ace_regs *regs, struct cmd *cmd)
+static inline void ace_issue_cmd(struct ace_regs __iomem *regs, struct cmd *cmd)
 {
 	u32 idx;
 
@@ -897,10 +897,10 @@
 }
 
 
-static int __init ace_init(struct net_device *dev)
+static int __devinit ace_init(struct net_device *dev)
 {
 	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs;
 	struct ace_info *info = NULL;
 	struct pci_dev *pdev;
 	unsigned long myjif;
@@ -1318,11 +1318,10 @@
 	writel(TX_RING_BASE, &regs->WinBase);
 
 	if (ACE_IS_TIGON_I(ap)) {
-		ap->tx_ring = (struct tx_desc *)regs->Window;
-		for (i = 0; i < (TIGON_I_TX_RING_ENTRIES * 
-				 sizeof(struct tx_desc) / 4); i++) {
-			writel(0, (unsigned long)ap->tx_ring + i * 4);
-		}
+		ap->tx_ring = (struct tx_desc *) regs->Window;
+		for (i = 0; i < (TIGON_I_TX_RING_ENTRIES 
+				 * sizeof(struct tx_desc)) / sizeof(u32); i++)
+			writel(0, (void __iomem *)ap->tx_ring  + i * 4);
 
 		set_aceaddr(&info->tx_ctrl.rngptr, TX_RING_BASE);
 	} else {
@@ -1549,14 +1548,9 @@
 
 static void ace_set_rxtx_parms(struct net_device *dev, int jumbo)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
-	int board_idx;
-
-	ap = netdev_priv(dev);
-	regs = ap->regs;
-
-	board_idx = ap->board_idx;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
+	int board_idx = ap->board_idx;
 
 	if (board_idx >= 0) {
 		if (!jumbo) {
@@ -1594,7 +1588,7 @@
 {
 	struct net_device *dev = data;
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 
 	/*
 	 * We haven't received a stats update event for more than 2.5
@@ -1617,7 +1611,7 @@
 
 static void ace_tasklet(unsigned long dev)
 {
-	struct ace_private *ap = ((struct net_device *)dev)->priv;
+	struct ace_private *ap = netdev_priv((struct net_device *)dev);
 	int cur_size;
 
 	cur_size = atomic_read(&ap->cur_rx_bufs);
@@ -1675,10 +1669,9 @@
  */
 static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs)
 {
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
-
-	regs = ap->regs;
+	
 
 	prefetchw(&ap->cur_rx_bufs);
 
@@ -1739,11 +1732,9 @@
 
 static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
 {
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
-	regs = ap->regs;
-
 	prefetchw(&ap->cur_mini_bufs);
 
 	idx = ap->rx_mini_skbprd;
@@ -1798,11 +1789,9 @@
  */
 static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs)
 {
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
-	regs = ap->regs;
-
 	idx = ap->rx_jumbo_skbprd;
 
 	for (i = 0; i < nr_bufs; i++) {
@@ -2082,8 +2071,7 @@
 	 * the 12.3.x Firmware - my Tigon I NICs seem to disagree!
 	 */
 	if (ACE_IS_TIGON_I(ap)) {
-		struct ace_regs *regs = ap->regs;
-		writel(idx, &regs->RxRetCsm);
+		writel(idx, &ap->regs->RxRetCsm);
 	}
 	ap->cur_rx = idx;
 
@@ -2163,16 +2151,13 @@
 
 static irqreturn_t ace_interrupt(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
 	struct net_device *dev = (struct net_device *)dev_id;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	u32 idx;
 	u32 txcsm, rxretcsm, rxretprd;
 	u32 evtcsm, evtprd;
 
-	ap = netdev_priv(dev);
-	regs = ap->regs;
-
 	/*
 	 * In case of PCI shared interrupts or spurious interrupts,
 	 * we want to make sure it is actually our interrupt before
@@ -2325,13 +2310,10 @@
 
 static int ace_open(struct net_device *dev)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	struct cmd cmd;
 
-	ap = netdev_priv(dev);
-	regs = ap->regs;
-
 	if (!(ap->fw_running)) {
 		printk(KERN_WARNING "%s: Firmware not running!\n", dev->name);
 		return -EBUSY;
@@ -2383,8 +2365,8 @@
 
 static int ace_close(struct net_device *dev)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	struct cmd cmd;
 	unsigned long flags;
 	short i;
@@ -2396,9 +2378,7 @@
 	 */
 	netif_stop_queue(dev);
 
-	ap = netdev_priv(dev);
-	regs = ap->regs;
-
+	
 	if (ap->promisc) {
 		cmd.evt = C_SET_PROMISC_MODE;
 		cmd.code = C_C_PROMISC_DISABLE;
@@ -2433,9 +2413,11 @@
 
 		if (mapping) {
 			if (ACE_IS_TIGON_I(ap)) {
-				writel(0, &ap->tx_ring[i].addr.addrhi);
-				writel(0, &ap->tx_ring[i].addr.addrlo);
-				writel(0, &ap->tx_ring[i].flagsize);
+				struct tx_desc __iomem *tx 
+					= (struct tx_desc __iomem *) &ap->tx_ring[i];
+				writel(0, &tx->addr.addrhi);
+				writel(0, &tx->addr.addrlo);
+				writel(0, &tx->flagsize);
 			} else
 				memset(ap->tx_ring + i, 0,
 				       sizeof(struct tx_desc));
@@ -2492,11 +2474,12 @@
 #endif
 
 	if (ACE_IS_TIGON_I(ap)) {
-		writel(addr >> 32, &desc->addr.addrhi);
-		writel(addr & 0xffffffff, &desc->addr.addrlo);
-		writel(flagsize, &desc->flagsize);
+		struct tx_desc __iomem *io = (struct tx_desc __iomem *) desc;
+		writel(addr >> 32, &io->addr.addrhi);
+		writel(addr & 0xffffffff, &io->addr.addrlo);
+		writel(flagsize, &io->flagsize);
 #if ACENIC_DO_VLAN
-		writel(vlan_tag, &desc->vlanres);
+		writel(vlan_tag, &io->vlanres);
 #endif
 	} else {
 		desc->addr.addrhi = addr >> 32;
@@ -2512,9 +2495,10 @@
 static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	struct tx_desc *desc;
 	u32 idx, flagsize;
+	unsigned long maxjiff = jiffies + 3*HZ;
 
 restart:
 	idx = ap->tx_prd;
@@ -2522,10 +2506,7 @@
 	if (tx_ring_full(ap, ap->tx_ret_csm, idx))
 		goto overflow;
 
-#if MAX_SKB_FRAGS
-	if (!skb_shinfo(skb)->nr_frags)
-#endif
-	{
+	if (!skb_shinfo(skb)->nr_frags)	{
 		dma_addr_t mapping;
 		u32 vlan_tag = 0;
 
@@ -2547,9 +2528,7 @@
 			flagsize |= BD_FLG_COAL_NOW;
 
 		ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
-	}
-#if MAX_SKB_FRAGS
-	else {
+	} else {
 		dma_addr_t mapping;
 		u32 vlan_tag = 0;
 		int i, len = 0;
@@ -2604,7 +2583,6 @@
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
-#endif
 
  	wmb();
  	ap->tx_prd = idx;
@@ -2624,7 +2602,7 @@
 	}
 
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 
 overflow:
 	/*
@@ -2643,15 +2621,22 @@
 	 * Alternative is to return with 1 not throttling queue. In this
 	 * case loop becomes longer, no more useful effects.
 	 */
-	barrier();
-	goto restart;
+	if (time_before(jiffies, maxjiff)) {
+		barrier();
+		cpu_relax();
+		goto restart;
+	}
+	
+	/* The ring is stuck full. */
+	printk(KERN_WARNING "%s: Transmit ring stuck full\n", dev->name);
+	return NETDEV_TX_BUSY;
 }
 
 
 static int ace_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 
 	if (new_mtu > ACE_JUMBO_MTU)
 		return -EINVAL;
@@ -2688,7 +2673,7 @@
 static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	u32 link;
 
 	memset(ecmd, 0, sizeof(struct ethtool_cmd));
@@ -2741,7 +2726,7 @@
 static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	u32 link, speed;
 
 	link = readl(&regs->GigLnkState);
@@ -2821,8 +2806,9 @@
  */
 static int ace_set_mac_addr(struct net_device *dev, void *p)
 {
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	struct sockaddr *addr=p;
-	struct ace_regs *regs;
 	u8 *da;
 	struct cmd cmd;
 
@@ -2833,7 +2819,6 @@
 
 	da = (u8 *)dev->dev_addr;
 
-	regs = ((struct ace_private *)netdev_priv(dev))->regs;
 	writel(da[0] << 8 | da[1], &regs->MacAddrHi);
 	writel((da[2] << 24) | (da[3] << 16) | (da[4] << 8) | da[5],
 	       &regs->MacAddrLo);
@@ -2850,7 +2835,7 @@
 static void ace_set_multicast_list(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	struct cmd cmd;
 
 	if ((dev->flags & IFF_ALLMULTI) && !(ap->mcast_all)) {
@@ -2904,8 +2889,8 @@
 static struct net_device_stats *ace_get_stats(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_mac_stats *mac_stats =
-		(struct ace_mac_stats *)ap->regs->Stats;
+	struct ace_mac_stats __iomem *mac_stats =
+		(struct ace_mac_stats __iomem *)ap->regs->Stats;
 
 	ap->stats.rx_missed_errors = readl(&mac_stats->drop_space);
 	ap->stats.multicast = readl(&mac_stats->kept_mc);
@@ -2915,10 +2900,10 @@
 }
 
 
-static void __init ace_copy(struct ace_regs *regs, void *src,
+static void __devinit ace_copy(struct ace_regs __iomem *regs, void *src,
 			    u32 dest, int size)
 {
-	unsigned long tdest;
+	void __iomem *tdest;
 	u32 *wsrc;
 	short tsize, i;
 
@@ -2928,7 +2913,7 @@
 	while (size > 0) {
 		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
 			    min_t(u32, size, ACE_WINDOW_SIZE));
-		tdest = (unsigned long)&regs->Window +
+		tdest = (void __iomem *) &regs->Window + 
 			(dest & (ACE_WINDOW_SIZE - 1));
 		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
 		/*
@@ -2948,9 +2933,9 @@
 }
 
 
-static void __init ace_clear(struct ace_regs *regs, u32 dest, int size)
+static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int size)
 {
-	unsigned long tdest;
+	void __iomem *tdest;
 	short tsize = 0, i;
 
 	if (size <= 0)
@@ -2959,7 +2944,7 @@
 	while (size > 0) {
 		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
 				min_t(u32, size, ACE_WINDOW_SIZE));
-		tdest = (unsigned long)&regs->Window +
+		tdest = (void __iomem *) &regs->Window + 
 			(dest & (ACE_WINDOW_SIZE - 1));
 		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
 
@@ -2981,13 +2966,10 @@
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-int __init ace_load_firmware(struct net_device *dev)
+int __devinit ace_load_firmware(struct net_device *dev)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
-
-	ap = netdev_priv(dev);
-	regs = ap->regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 
 	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
 		printk(KERN_ERR "%s: trying to download firmware while the "
@@ -3035,7 +3017,7 @@
  * Thanks to Stevarino Webinski for helping tracking down the bugs in the
  * code i2c readout code by beta testing all my hacks.
  */
-static void __init eeprom_start(struct ace_regs *regs)
+static void __devinit eeprom_start(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -3064,7 +3046,7 @@
 }
 
 
-static void __init eeprom_prep(struct ace_regs *regs, u8 magic)
+static void __devinit eeprom_prep(struct ace_regs __iomem *regs, u8 magic)
 {
 	short i;
 	u32 local;
@@ -3101,7 +3083,7 @@
 }
 
 
-static int __init eeprom_check_ack(struct ace_regs *regs)
+static int __devinit eeprom_check_ack(struct ace_regs __iomem *regs)
 {
 	int state;
 	u32 local;
@@ -3129,7 +3111,7 @@
 }
 
 
-static void __init eeprom_stop(struct ace_regs *regs)
+static void __devinit eeprom_stop(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -3164,11 +3146,11 @@
 /*
  * Read a whole byte from the EEPROM.
  */
-static int __init read_eeprom_byte(struct net_device *dev,
+static int __devinit read_eeprom_byte(struct net_device *dev,
 				   unsigned long offset)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	unsigned long flags;
 	u32 local;
 	int result = 0;
@@ -3179,9 +3161,6 @@
 		result = -ENODEV;
 		goto out;
 	}
-
-	ap = netdev_priv(dev);
-	regs = ap->regs;
 
 	/*
 	 * Don't take interrupts on this CPU will bit banging
diff -Nru a/drivers/net/acenic.h b/drivers/net/acenic.h
--- a/drivers/net/acenic.h	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/acenic.h	2004-10-25 03:39:21 -04:00
@@ -10,11 +10,6 @@
  */
 #define USE_TX_COAL_NOW	 0
 
-#ifndef MAX_SKB_FRAGS
-#define MAX_SKB_FRAGS 0
-#endif
-
-
 /*
  * Addressing:
  *
@@ -638,7 +633,7 @@
 struct ace_private
 {
 	struct ace_info		*info;
-	struct ace_regs		*regs;		/* register base */
+	struct ace_regs	__iomem	*regs;		/* register base */
 	struct ace_skb		*skb;
 	dma_addr_t		info_dma;	/* 32/64 bit */
 
@@ -712,13 +707,7 @@
 }
 
 #define tx_free(ap) 		tx_space((ap)->tx_ret_csm, (ap)->tx_prd, ap)
-
-#if MAX_SKB_FRAGS
 #define tx_ring_full(ap, csm, prd)	(tx_space(ap, csm, prd) <= TX_RESERVED)
-#else
-#define tx_ring_full			0
-#endif
-
 
 static inline void set_aceaddr(aceaddr *aa, dma_addr_t addr)
 {
@@ -729,7 +718,7 @@
 }
 
 
-static inline void ace_set_txprd(struct ace_regs *regs,
+static inline void ace_set_txprd(struct ace_regs __iomem *regs,
 				 struct ace_private *ap, u32 value)
 {
 #ifdef INDEX_DEBUG
@@ -750,8 +739,8 @@
 
 static inline void ace_mask_irq(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
-	struct ace_regs *regs = ap->regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 
 	if (ACE_IS_TIGON_I(ap))
 		writel(1, &regs->MaskInt);
@@ -764,8 +753,8 @@
 
 static inline void ace_unmask_irq(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
-	struct ace_regs *regs = ap->regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
  
 	if (ACE_IS_TIGON_I(ap))
 		writel(0, &regs->MaskInt);
diff -Nru a/drivers/net/acenic_firmware.h b/drivers/net/acenic_firmware.h
--- a/drivers/net/acenic_firmware.h	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/acenic_firmware.h	2004-10-25 03:39:21 -04:00
@@ -23,7 +23,7 @@
 #define tigonFwRodata NULL
 #else
 /* Generated by genfw.c */
-static u32 tigonFwText[(MAX_TEXT_LEN/4) + 1] __initdata = {
+static u32 tigonFwText[(MAX_TEXT_LEN/4) + 1] __devinitdata = {
 0x10000003, 
 0x0, 0xd, 0xd, 0x3c1d0001, 
 0x8fbd5c54, 0x3a0f021, 0x3c100000, 0x26104000, 
diff -Nru a/drivers/net/defxx.c b/drivers/net/defxx.c
--- a/drivers/net/defxx.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/defxx.c	2004-10-25 03:39:21 -04:00
@@ -19,7 +19,7 @@
  *   LVS	Lawrence V. Stefani <lstefani@yahoo.com>
  *
  * Maintainers:
- *   macro	Maciej W. Rozycki <macro@ds2.pg.gda.pl>
+ *   macro	Maciej W. Rozycki <macro@linux-mips.org>
  *
  * Credits:
  *   I'd like to thank Patricia Cross for helping me get started with
@@ -190,6 +190,7 @@
  *		Feb 2001			Skb allocation fixes
  *		Feb 2001	davej		PCI enable cleanups.
  *		04 Aug 2003	macro		Converted to the DMA API.
+ *		14 Aug 2004	macro		Fix device names reported.
  */
 
 /* Include files */
@@ -214,12 +215,14 @@
 
 #include "defxx.h"
 
-/* Version information string - should be updated prior to each new release!!! */
+/* Version information string should be updated prior to each new release!  */
+#define DRV_NAME "defxx"
+#define DRV_VERSION "v1.07"
+#define DRV_RELDATE "2004/08/14"
 
 static char version[] __devinitdata =
-	"defxx.c:v1.06 2003/08/04  Lawrence V. Stefani and others\n";
-
-#define DRV_NAME "defxx"
+	DRV_NAME ": " DRV_VERSION " " DRV_RELDATE
+	"  Lawrence V. Stefani and others\n";
 
 #define DYNAMIC_BUFFERS 1
 
@@ -235,7 +238,7 @@
 static void		dfx_bus_init(struct net_device *dev);
 static void		dfx_bus_config_check(DFX_board_t *bp);
 
-static int		dfx_driver_init(struct net_device *dev);
+static int		dfx_driver_init(struct net_device *dev, const char *print_name);
 static int		dfx_adap_init(DFX_board_t *bp, int get_buffers);
 
 static int		dfx_open(struct net_device *dev);
@@ -404,24 +407,25 @@
  */
 static int __devinit dfx_init_one_pci_or_eisa(struct pci_dev *pdev, long ioaddr)
 {
+	static int version_disp;
+	char *print_name = DRV_NAME;
 	struct net_device *dev;
 	DFX_board_t	  *bp;			/* board pointer */
 	int alloc_size;				/* total buffer size used */
 	int err;
 
-#ifndef MODULE
-	static int version_disp;
-
-	if (!version_disp)	/* display version info if adapter is found */
-	{
+	if (!version_disp) {	/* display version info if adapter is found */
 		version_disp = 1;	/* set display flag to TRUE so that */
 		printk(version);	/* we only display this string ONCE */
 	}
-#endif
+
+	if (pdev != NULL)
+		print_name = pdev->slot_name;
 
 	dev = alloc_fddidev(sizeof(*bp));
 	if (!dev) {
-		printk (KERN_ERR "defxx: unable to allocate fddidev, aborting\n");
+		printk(KERN_ERR "%s: unable to allocate fddidev, aborting\n",
+		       print_name);
 		return -ENOMEM;
 	}
 
@@ -437,9 +441,12 @@
 
 	bp = dev->priv;
 
-	if (!request_region (ioaddr, pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN, DRV_NAME)) {
-		printk (KERN_ERR "%s: Cannot reserve I/O resource 0x%x @ 0x%lx, aborting\n",
-			DRV_NAME, PFI_K_CSR_IO_LEN, ioaddr);
+	if (!request_region(ioaddr,
+			    pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN,
+			    print_name)) {
+		printk(KERN_ERR "%s: Cannot reserve I/O resource "
+		       "0x%x @ 0x%lx, aborting\n", print_name,
+		       pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN, ioaddr);
 		err = -EBUSY;
 		goto err_out;
 	}
@@ -468,7 +475,7 @@
 		pci_set_master (pdev);
 	}
 
-	if (dfx_driver_init(dev) != DFX_K_SUCCESS) {
+	if (dfx_driver_init(dev, print_name) != DFX_K_SUCCESS) {
 		err = -ENODEV;
 		goto err_out_region;
 	}
@@ -477,6 +484,7 @@
 	if (err)
 		goto err_out_kfree;
 
+	printk("%s: registered as %s\n", print_name, dev->name);
 	return 0;
 
 err_out_kfree:
@@ -770,6 +778,7 @@
  *       
  * Arguments:
  *   dev - pointer to device information
+ *   print_name - printable device name
  *
  * Functional Description:
  *   This function allocates additional resources such as the host memory
@@ -792,7 +801,8 @@
  *   returning from this routine.
  */
 
-static int __devinit dfx_driver_init(struct net_device *dev)
+static int __devinit dfx_driver_init(struct net_device *dev,
+				     const char *print_name)
 {
 	DFX_board_t *bp = dev->priv;
 	int			alloc_size;			/* total buffer size needed */
@@ -841,26 +851,20 @@
 
 	/*  Read the factory MAC address from the adapter then save it */
 
-	if (dfx_hw_port_ctrl_req(bp,
-							PI_PCTRL_M_MLA,
-							PI_PDATA_A_MLA_K_LO,
-							0,
-							&data) != DFX_K_SUCCESS)
-		{
-		printk("%s: Could not read adapter factory MAC address!\n", dev->name);
+	if (dfx_hw_port_ctrl_req(bp, PI_PCTRL_M_MLA, PI_PDATA_A_MLA_K_LO, 0,
+				 &data) != DFX_K_SUCCESS) {
+		printk("%s: Could not read adapter factory MAC address!\n",
+		       print_name);
 		return(DFX_K_FAILURE);
-		}
+	}
 	memcpy(&bp->factory_mac_addr[0], &data, sizeof(u32));
 
-	if (dfx_hw_port_ctrl_req(bp,
-							PI_PCTRL_M_MLA,
-							PI_PDATA_A_MLA_K_HI,
-							0,
-							&data) != DFX_K_SUCCESS)
-		{
-		printk("%s: Could not read adapter factory MAC address!\n", dev->name);
+	if (dfx_hw_port_ctrl_req(bp, PI_PCTRL_M_MLA, PI_PDATA_A_MLA_K_HI, 0,
+				 &data) != DFX_K_SUCCESS) {
+		printk("%s: Could not read adapter factory MAC address!\n",
+		       print_name);
 		return(DFX_K_FAILURE);
-		}
+	}
 	memcpy(&bp->factory_mac_addr[4], &data, sizeof(u16));
 
 	/*
@@ -872,27 +876,19 @@
 
 	memcpy(dev->dev_addr, bp->factory_mac_addr, FDDI_K_ALEN);
 	if (bp->bus_type == DFX_BUS_TYPE_EISA)
-		printk("%s: DEFEA at I/O addr = 0x%lX, IRQ = %d, Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
-				dev->name,
-				dev->base_addr,
-				dev->irq,
-				dev->dev_addr[0],
-				dev->dev_addr[1],
-				dev->dev_addr[2],
-				dev->dev_addr[3],
-				dev->dev_addr[4],
-				dev->dev_addr[5]);
+		printk("%s: DEFEA at I/O addr = 0x%lX, IRQ = %d, "
+		       "Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
+		       print_name, dev->base_addr, dev->irq,
+		       dev->dev_addr[0], dev->dev_addr[1],
+		       dev->dev_addr[2], dev->dev_addr[3],
+		       dev->dev_addr[4], dev->dev_addr[5]);
 	else
-		printk("%s: DEFPA at I/O addr = 0x%lX, IRQ = %d, Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
-				dev->name,
-				dev->base_addr,
-				dev->irq,
-				dev->dev_addr[0],
-				dev->dev_addr[1],
-				dev->dev_addr[2],
-				dev->dev_addr[3],
-				dev->dev_addr[4],
-				dev->dev_addr[5]);
+		printk("%s: DEFPA at I/O addr = 0x%lX, IRQ = %d, "
+		       "Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
+		       print_name, dev->base_addr, dev->irq,
+		       dev->dev_addr[0], dev->dev_addr[1],
+		       dev->dev_addr[2], dev->dev_addr[3],
+		       dev->dev_addr[4], dev->dev_addr[5]);
 
 	/*
 	 * Get memory for descriptor block, consumer block, and other buffers
@@ -909,11 +905,11 @@
 					(PI_ALIGN_K_DESC_BLK - 1);
 	bp->kmalloced = top_v = pci_alloc_consistent(bp->pci_dev, alloc_size,
 						     &bp->kmalloced_dma);
-	if (top_v == NULL)
-		{
-		printk("%s: Could not allocate memory for host buffers and structures!\n", dev->name);
+	if (top_v == NULL) {
+		printk("%s: Could not allocate memory for host buffers "
+		       "and structures!\n", print_name);
 		return(DFX_K_FAILURE);
-		}
+	}
 	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
 	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
 
@@ -970,14 +966,20 @@
 
 	/* Display virtual and physical addresses if debug driver */
 
-	DBG_printk("%s: Descriptor block virt = %0lX, phys = %0X\n",				dev->name, (long)bp->descr_block_virt,	bp->descr_block_phys);
-	DBG_printk("%s: Command Request buffer virt = %0lX, phys = %0X\n",			dev->name, (long)bp->cmd_req_virt,		bp->cmd_req_phys);
-	DBG_printk("%s: Command Response buffer virt = %0lX, phys = %0X\n",			dev->name, (long)bp->cmd_rsp_virt,		bp->cmd_rsp_phys);
-	DBG_printk("%s: Receive buffer block virt = %0lX, phys = %0X\n",			dev->name, (long)bp->rcv_block_virt,	bp->rcv_block_phys);
-	DBG_printk("%s: Consumer block virt = %0lX, phys = %0X\n",				dev->name, (long)bp->cons_block_virt,	bp->cons_block_phys);
+	DBG_printk("%s: Descriptor block virt = %0lX, phys = %0X\n",
+		   print_name,
+		   (long)bp->descr_block_virt, bp->descr_block_phys);
+	DBG_printk("%s: Command Request buffer virt = %0lX, phys = %0X\n",
+		   print_name, (long)bp->cmd_req_virt, bp->cmd_req_phys);
+	DBG_printk("%s: Command Response buffer virt = %0lX, phys = %0X\n",
+		   print_name, (long)bp->cmd_rsp_virt, bp->cmd_rsp_phys);
+	DBG_printk("%s: Receive buffer block virt = %0lX, phys = %0X\n",
+		   print_name, (long)bp->rcv_block_virt, bp->rcv_block_phys);
+	DBG_printk("%s: Consumer block virt = %0lX, phys = %0X\n",
+		   print_name, (long)bp->cons_block_virt, bp->cons_block_phys);
 
 	return(DFX_K_SUCCESS);
-	}
+}
 
 
 /*
@@ -2668,12 +2670,12 @@
  
 static void my_skb_align(struct sk_buff *skb, int n)
 {
-	unsigned long x=(unsigned long)skb->data;	
+	unsigned long x = (unsigned long)skb->data;
 	unsigned long v;
 	
-	v=(x+n-1)&~(n-1);	/* Where we want to be */
+	v = ALIGN(x, n);	/* Where we want to be */
 	
-	skb_reserve(skb, v-x);
+	skb_reserve(skb, v - x);
 }
 
 
@@ -3428,11 +3430,6 @@
 {
 	int rc_pci, rc_eisa;
 
-/* when a module, this is printed whether or not devices are found in probe */
-#ifdef MODULE
-	printk(version);
-#endif
-
 	rc_pci = pci_module_init(&dfx_driver);
 	if (rc_pci >= 0) dfx_have_pci = 1;
 	
@@ -3453,6 +3450,9 @@
 
 module_init(dfx_init);
 module_exit(dfx_cleanup);
+MODULE_AUTHOR("Lawrence V. Stefani");
+MODULE_DESCRIPTION("DEC FDDIcontroller EISA/PCI (DEFEA/DEFPA) driver "
+		   DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");
 
 
diff -Nru a/drivers/net/defxx.h b/drivers/net/defxx.h
--- a/drivers/net/defxx.h	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/defxx.h	2004-10-25 03:39:21 -04:00
@@ -16,7 +16,7 @@
  *   LVS	Lawrence V. Stefani <lstefani@yahoo.com>
  *
  * Maintainers:
- *   macro	Maciej W. Rozycki <macro@ds2.pg.gda.pl>
+ *   macro	Maciej W. Rozycki <macro@linux-mips.org>
  *
  * Modification History:
  *		Date		Name	Description
diff -Nru a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/e100.c	2004-10-25 03:39:21 -04:00
@@ -154,8 +154,8 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.0.27-k2"DRV_EXT
+#define DRV_EXT		"-NAPI"
+#define DRV_VERSION		"3.2.3-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -574,13 +574,21 @@
 
 static inline void e100_enable_irq(struct nic *nic)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_none, &nic->csr->scb.cmd_hi);
+	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 	e100_write_flush(nic);
 }
 
 static inline void e100_disable_irq(struct nic *nic)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_all, &nic->csr->scb.cmd_hi);
+	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 	e100_write_flush(nic);
 }
 
@@ -595,16 +603,6 @@
 	writel(software_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
 
-	/* TCO workaround - 82559 and greater */
-	if(nic->mac >= mac_82559_D101M) {
-		/* Issue a redundant CU load base without setting
-		 * general pointer, and without waiting for scb to
-		 * clear.  This gets us into post-driver.  Finally,
-		 * wait 20 msec for reset to take effect. */
-		writeb(cuc_load_base, &nic->csr->scb.cmd_lo);
-		mdelay(20);
-	}
-
 	/* Mask off our interrupt line - it's unmasked after reset */
 	e100_disable_irq(nic);
 }
@@ -1253,8 +1251,13 @@
 	mii_check_link(&nic->mii);
 
 	/* Software generated interrupt to recover from (rare) Rx
-	 * allocation failure */
-	writeb(irq_sw_gen, &nic->csr->scb.cmd_hi);
+	* allocation failure.
+	* Unfortunately have to use a spinlock to not re-enable interrupts
+	* accidentally, due to hardware that shares a register between the
+	* interrupt mask bit and the SW Interrupt generation bit */
+	spin_lock_irq(&nic->cmd_lock);
+	writeb(readb(&nic->csr->scb.cmd_hi) | irq_sw_gen,&nic->csr->scb.cmd_hi);
+	spin_unlock_irq(&nic->cmd_lock);
 	e100_write_flush(nic);
 
 	e100_update_stats(nic);
@@ -1304,6 +1307,7 @@
 	switch(err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
+		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
 		netif_stop_queue(netdev);
 		break;
 	case -ENOMEM:
@@ -1424,14 +1428,12 @@
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static inline int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
-	unsigned int rx_offset = 2; /* u32 align protocol headers */
-
-	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + rx_offset)))
+	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
 	rx->skb->dev = nic->netdev;
-	skb_reserve(rx->skb, rx_offset);
+	skb_reserve(rx->skb, NET_IP_ALIGN);
 	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
@@ -1470,7 +1472,7 @@
 
 	/* If data isn't ready, nothing to indicate */
 	if(unlikely(!(rfd_status & cb_complete)))
-       		return -EAGAIN;
+		return -EAGAIN;
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1762,7 +1764,7 @@
 
 	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))
-       		err = -EAGAIN;
+		err = -EAGAIN;
 
 err_loopback_none:
 	mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, 0);
@@ -1955,12 +1957,17 @@
 	struct param_range *rfds = &nic->params.rfds;
 	struct param_range *cbs = &nic->params.cbs;
 
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+		return -EINVAL;
+
 	if(netif_running(netdev))
 		e100_down(nic);
 	rfds->count = max(ring->rx_pending, rfds->min);
 	rfds->count = min(rfds->count, rfds->max);
 	cbs->count = max(ring->tx_pending, cbs->min);
 	cbs->count = min(cbs->count, cbs->max);
+	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n",
+	        rfds->count, cbs->count);
 	if(netif_running(netdev))
 		e100_up(nic);
 
@@ -2172,6 +2179,7 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
+	strcpy(netdev->name, pci_name(pdev));
 
 	nic = netdev_priv(netdev);
 	nic->netdev = netdev;
@@ -2255,6 +2263,7 @@
 
 	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
 
+	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
 		goto err_out_free;
@@ -2351,7 +2360,7 @@
 		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}
-        return pci_module_init(&e100_driver);
+	return pci_module_init(&e100_driver);
 }
 
 static void __exit e100_cleanup_module(void)
diff -Nru a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
--- a/drivers/net/ibmlana.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/ibmlana.c	2004-10-25 03:39:21 -04:00
@@ -885,14 +885,6 @@
 	return &priv->stat;
 }
 
-/* we don't support runtime reconfiguration, since am MCA card can
-   be unambigously identified by its POS registers. */
-
-static int ibmlana_config(struct net_device *dev, struct ifmap *map)
-{
-	return 0;
-}
-
 /* switch receiver mode. */
 
 static void ibmlana_set_multicast_list(struct net_device *dev)
@@ -984,7 +976,6 @@
 
 	dev->open = ibmlana_open;
 	dev->stop = ibmlana_close;
-	dev->set_config = ibmlana_config;
 	dev->hard_start_xmit = ibmlana_tx;
 	dev->do_ioctl = NULL;
 	dev->get_stats = ibmlana_stats;
diff -Nru a/drivers/net/meth.c b/drivers/net/meth.c
--- a/drivers/net/meth.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/meth.c	2004-10-25 03:39:21 -04:00
@@ -368,31 +368,6 @@
 }
 
 /*
- * Configuration changes (passed on by ifconfig)
- */
-static int meth_config(struct net_device *dev, struct ifmap *map)
-{
-	if (dev->flags & IFF_UP) /* can't act on a running interface */
-		return -EBUSY;
-
-	/* Don't allow changing the I/O address */
-	if (map->base_addr != dev->base_addr) {
-		printk(KERN_WARNING "meth: Can't change I/O address\n");
-		return -EOPNOTSUPP;
-	}
-
-	/* Don't allow changing the IRQ */
-	if (map->irq != dev->irq) {
-		printk(KERN_WARNING "meth: Can't change IRQ\n");
-		return -EOPNOTSUPP;
-	}
-	DPRINTK("Configured\n");
-
-	/* ignore other fields */
-	return 0;
-}
-
-/*
  * Receive a packet: retrieve, encapsulate and pass over to upper levels
  */
 static void meth_rx(struct net_device* dev, unsigned long int_status)
@@ -813,7 +788,6 @@
 
 	dev->open            = meth_open;
 	dev->stop            = meth_release;
-	dev->set_config      = meth_config;
 	dev->hard_start_xmit = meth_tx;
 	dev->do_ioctl        = meth_ioctl;
 	dev->get_stats       = meth_stats;
diff -Nru a/drivers/net/sk_mca.c b/drivers/net/sk_mca.c
--- a/drivers/net/sk_mca.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/sk_mca.c	2004-10-25 03:39:21 -04:00
@@ -972,14 +972,6 @@
 	return &(priv->stat);
 }
 
-/* we don't support runtime reconfiguration, since an MCA card can
-   be unambigously identified by its POS registers. */
-
-static int skmca_config(struct net_device *dev, struct ifmap *map)
-{
-	return 0;
-}
-
 /* switch receiver mode.  We use the LANCE's multicast filter to prefilter
    multicast addresses. */
 
@@ -1147,7 +1139,6 @@
 	/* set methods */
 	dev->open = skmca_open;
 	dev->stop = skmca_close;
-	dev->set_config = skmca_config;
 	dev->hard_start_xmit = skmca_tx;
 	dev->do_ioctl = NULL;
 	dev->get_stats = skmca_stats;
diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/wan/lmc/lmc_main.c	2004-10-25 03:39:21 -04:00
@@ -101,7 +101,6 @@
 static int lmc_close(struct net_device *dev);
 static struct net_device_stats *lmc_get_stats(struct net_device *dev);
 static irqreturn_t lmc_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
-static int lmc_set_config(struct net_device *dev, struct ifmap *map);
 static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base, size_t csr_size);
 static void lmc_softreset(lmc_softc_t * const);
 static void lmc_running_reset(struct net_device *dev);
@@ -814,7 +813,6 @@
     dev->stop = lmc_close;
     dev->get_stats = lmc_get_stats;
     dev->do_ioctl = lmc_ioctl;
-    dev->set_config = lmc_set_config;
     dev->tx_timeout = lmc_driver_timeout;
     dev->watchdog_timeo = (HZ); /* 1 second */
     
@@ -1973,13 +1971,6 @@
     LMC_CSR_WRITE (sc, csr_txlist, virt_to_bus (sc->lmc_txring));
 
     lmc_trace(sc->lmc_device, "lmc_softreset out");
-}
-
-static int lmc_set_config(struct net_device *dev, struct ifmap *map) /*fold00*/
-{
-    lmc_trace(dev, "lmc_set_config in");
-    lmc_trace(dev, "lmc_set_config out");
-    return -EOPNOTSUPP;
 }
 
 void lmc_gpio_mkinput(lmc_softc_t * const sc, u_int32_t bits) /*fold00*/
diff -Nru a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
--- a/drivers/net/wireless/netwave_cs.c	2004-10-25 03:39:21 -04:00
+++ b/drivers/net/wireless/netwave_cs.c	2004-10-25 03:39:21 -04:00
@@ -219,7 +219,6 @@
 /* Misc device stuff */
 static int netwave_open(struct net_device *dev);  /* Open the device */
 static int netwave_close(struct net_device *dev); /* Close the device */
-static int netwave_config(struct net_device *dev, struct ifmap *map);
 
 /* Packet transmission and Packet reception */
 static int netwave_start_xmit( struct sk_buff *skb, struct net_device *dev);
@@ -482,7 +481,6 @@
     /* Netwave specific entries in the device structure */
     SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &netwave_start_xmit;
-    dev->set_config = &netwave_config;
     dev->get_stats  = &netwave_get_stats;
     dev->set_multicast_list = &set_multicast_list;
     /* wireless extensions */
@@ -1286,16 +1284,6 @@
     /* Set the IENA bit in COR */
     wait_WOC(iobase);
     outb(corConfIENA + corConfLVLREQ, iobase + NETWAVE_REG_COR);
-}
-
-/*
- * Function netwave_config (dev, map)
- *
- *    Configure device, this work is done by netwave_pcmcia_config when a
- *    card is inserted
- */
-static int netwave_config(struct net_device *dev, struct ifmap *map) {
-    return 0; 
 }
 
 /*
