From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) acenic - __iomem warnings cleanup
Date: Mon, 20 Sep 2004 10:44:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920104431.0a96d6c1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This cleans all the compile warnings and most of the sparse warnings
for the acenic driver relating to io memory space.
Remaining warnings are because tx_ring can be either in i/o or not
depending on the version of the card.
Not tested on old TIGON card.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-09-20 10:47:00 -07:00
+++ b/drivers/net/acenic.c	2004-09-20 10:47:00 -07:00
@@ -539,7 +539,7 @@
 	 * addresses but who gives a damn.
 	 */
 	dev->base_addr = pci_resource_start(pdev, 0);
-	ap->regs = (struct ace_regs *)ioremap(dev->base_addr, 0x4000);
+	ap->regs = ioremap(dev->base_addr, 0x4000);
 	if (!ap->regs) {
 		printk(KERN_ERR "%s:  Unable to map I/O register, "
 		       "AceNIC %i will be disabled.\n",
@@ -632,7 +632,7 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i;
 
 	unregister_netdev(dev);
@@ -885,7 +885,7 @@
 /*
  * Commands are considered to be slow.
  */
-static inline void ace_issue_cmd(struct ace_regs *regs, struct cmd *cmd)
+static inline void ace_issue_cmd(struct ace_regs __iomem *regs, struct cmd *cmd)
 {
 	u32 idx;
 
@@ -901,7 +901,7 @@
 static int __init ace_init(struct net_device *dev)
 {
 	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs;
 	struct ace_info *info = NULL;
 	struct pci_dev *pdev;
 	unsigned long myjif;
@@ -1319,11 +1319,10 @@
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
@@ -1550,14 +1549,9 @@
 
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
@@ -1595,7 +1589,7 @@
 {
 	struct net_device *dev = data;
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 
 	/*
 	 * We haven't received a stats update event for more than 2.5
@@ -1676,10 +1670,9 @@
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
 
@@ -1740,11 +1733,9 @@
 
 static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
 {
-	struct ace_regs *regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
-	regs = ap->regs;
-
 	prefetchw(&ap->cur_mini_bufs);
 
 	idx = ap->rx_mini_skbprd;
@@ -1799,11 +1790,9 @@
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
@@ -2083,8 +2072,7 @@
 	 * the 12.3.x Firmware - my Tigon I NICs seem to disagree!
 	 */
 	if (ACE_IS_TIGON_I(ap)) {
-		struct ace_regs *regs = ap->regs;
-		writel(idx, &regs->RxRetCsm);
+		writel(idx, &ap->regs->RxRetCsm);
 	}
 	ap->cur_rx = idx;
 
@@ -2164,16 +2152,13 @@
 
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
@@ -2326,13 +2311,10 @@
 
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
@@ -2384,8 +2366,8 @@
 
 static int ace_close(struct net_device *dev)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	struct cmd cmd;
 	unsigned long flags;
 	short i;
@@ -2397,9 +2379,7 @@
 	 */
 	netif_stop_queue(dev);
 
-	ap = netdev_priv(dev);
-	regs = ap->regs;
-
+	
 	if (ap->promisc) {
 		cmd.evt = C_SET_PROMISC_MODE;
 		cmd.code = C_C_PROMISC_DISABLE;
@@ -2434,9 +2414,11 @@
 
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
@@ -2493,11 +2475,12 @@
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
@@ -2513,7 +2496,7 @@
 static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	struct tx_desc *desc;
 	u32 idx, flagsize;
 
@@ -2646,7 +2629,7 @@
 static int ace_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 
 	if (new_mtu > ACE_JUMBO_MTU)
 		return -EINVAL;
@@ -2683,7 +2666,7 @@
 static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	u32 link;
 
 	memset(ecmd, 0, sizeof(struct ethtool_cmd));
@@ -2736,7 +2719,7 @@
 static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	u32 link, speed;
 
 	link = readl(&regs->GigLnkState);
@@ -2816,8 +2799,9 @@
  */
 static int ace_set_mac_addr(struct net_device *dev, void *p)
 {
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	struct sockaddr *addr=p;
-	struct ace_regs *regs;
 	u8 *da;
 	struct cmd cmd;
 
@@ -2828,7 +2812,6 @@
 
 	da = (u8 *)dev->dev_addr;
 
-	regs = ((struct ace_private *)netdev_priv(dev))->regs;
 	writel(da[0] << 8 | da[1], &regs->MacAddrHi);
 	writel((da[2] << 24) | (da[3] << 16) | (da[4] << 8) | da[5],
 	       &regs->MacAddrLo);
@@ -2845,7 +2828,7 @@
 static void ace_set_multicast_list(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 	struct cmd cmd;
 
 	if ((dev->flags & IFF_ALLMULTI) && !(ap->mcast_all)) {
@@ -2899,8 +2882,8 @@
 static struct net_device_stats *ace_get_stats(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_mac_stats *mac_stats =
-		(struct ace_mac_stats *)ap->regs->Stats;
+	struct ace_mac_stats __iomem *mac_stats =
+		(struct ace_mac_stats __iomem *)ap->regs->Stats;
 
 	ap->stats.rx_missed_errors = readl(&mac_stats->drop_space);
 	ap->stats.multicast = readl(&mac_stats->kept_mc);
@@ -2910,10 +2893,10 @@
 }
 
 
-static void __init ace_copy(struct ace_regs *regs, void *src,
+static void __init ace_copy(struct ace_regs __iomem *regs, void *src,
 			    u32 dest, int size)
 {
-	unsigned long tdest;
+	void __iomem *tdest;
 	u32 *wsrc;
 	short tsize, i;
 
@@ -2923,7 +2906,7 @@
 	while (size > 0) {
 		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
 			    min_t(u32, size, ACE_WINDOW_SIZE));
-		tdest = (unsigned long)&regs->Window +
+		tdest = (void __iomem *) &regs->Window + 
 			(dest & (ACE_WINDOW_SIZE - 1));
 		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
 		/*
@@ -2943,9 +2926,9 @@
 }
 
 
-static void __init ace_clear(struct ace_regs *regs, u32 dest, int size)
+static void __init ace_clear(struct ace_regs __iomem *regs, u32 dest, int size)
 {
-	unsigned long tdest;
+	void __iomem *tdest;
 	short tsize = 0, i;
 
 	if (size <= 0)
@@ -2954,7 +2937,7 @@
 	while (size > 0) {
 		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
 				min_t(u32, size, ACE_WINDOW_SIZE));
-		tdest = (unsigned long)&regs->Window +
+		tdest = (void __iomem *) &regs->Window + 
 			(dest & (ACE_WINDOW_SIZE - 1));
 		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
 
@@ -2978,11 +2961,8 @@
  */
 int __init ace_load_firmware(struct net_device *dev)
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
@@ -3030,7 +3010,7 @@
  * Thanks to Stevarino Webinski for helping tracking down the bugs in the
  * code i2c readout code by beta testing all my hacks.
  */
-static void __init eeprom_start(struct ace_regs *regs)
+static void __init eeprom_start(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -3059,7 +3039,7 @@
 }
 
 
-static void __init eeprom_prep(struct ace_regs *regs, u8 magic)
+static void __init eeprom_prep(struct ace_regs __iomem *regs, u8 magic)
 {
 	short i;
 	u32 local;
@@ -3096,7 +3076,7 @@
 }
 
 
-static int __init eeprom_check_ack(struct ace_regs *regs)
+static int __init eeprom_check_ack(struct ace_regs __iomem *regs)
 {
 	int state;
 	u32 local;
@@ -3124,7 +3104,7 @@
 }
 
 
-static void __init eeprom_stop(struct ace_regs *regs)
+static void __init eeprom_stop(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -3162,8 +3142,8 @@
 static int __init read_eeprom_byte(struct net_device *dev,
 				   unsigned long offset)
 {
-	struct ace_private *ap;
-	struct ace_regs *regs;
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
 	unsigned long flags;
 	u32 local;
 	int result = 0;
@@ -3174,9 +3154,6 @@
 		result = -ENODEV;
 		goto out;
 	}
-
-	ap = netdev_priv(dev);
-	regs = ap->regs;
 
 	/*
 	 * Don't take interrupts on this CPU will bit banging
diff -Nru a/drivers/net/acenic.h b/drivers/net/acenic.h
--- a/drivers/net/acenic.h	2004-09-20 10:47:00 -07:00
+++ b/drivers/net/acenic.h	2004-09-20 10:47:00 -07:00
@@ -633,7 +633,7 @@
 struct ace_private
 {
 	struct ace_info		*info;
-	struct ace_regs		*regs;		/* register base */
+	struct ace_regs	__iomem	*regs;		/* register base */
 	struct ace_skb		*skb;
 	dma_addr_t		info_dma;	/* 32/64 bit */
 
@@ -718,7 +718,7 @@
 }
 
 
-static inline void ace_set_txprd(struct ace_regs *regs,
+static inline void ace_set_txprd(struct ace_regs __iomem *regs,
 				 struct ace_private *ap, u32 value)
 {
 #ifdef INDEX_DEBUG
@@ -740,7 +740,7 @@
 static inline void ace_mask_irq(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
 
 	if (ACE_IS_TIGON_I(ap))
 		writel(1, &regs->MaskInt);
@@ -754,7 +754,7 @@
 static inline void ace_unmask_irq(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs *regs = ap->regs;
+	struct ace_regs __iomem *regs = ap->regs;
  
 	if (ACE_IS_TIGON_I(ap))
 		writel(0, &regs->MaskInt);
