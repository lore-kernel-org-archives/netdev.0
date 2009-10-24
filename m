From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 08/16] pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (net)
Date: Sat, 24 Oct 2009 21:42:58 +0200
Message-ID: <1256413386-20501-8-git-send-email-linux@dominikbrodowski.net>
References: <20091024194219.GA19546@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:55643 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751629AbZJXTnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 15:43:12 -0400
In-Reply-To: <20091024194219.GA19546@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert PCMCIA drivers to use the dynamic debug infrastructure, instead of
requiring manual settings of PCMCIA_DEBUG. Only some rare debug checks are
now hidden behind "#ifdef DEBUG" or "#if 0".

Also, remove all usages of the CS_CHECK macro and replace them with proper
Linux style calling and return value checking. The extra error reporting may
be dropped, as the PCMCIA core already complains about any (non-driver-author)
errors.

CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/3c574_cs.c    |   66 ++++++++----------
 drivers/net/pcmcia/3c589_cs.c    |   75 +++++++-------------
 drivers/net/pcmcia/axnet_cs.c    |   53 +++++---------
 drivers/net/pcmcia/com20020_cs.c |   55 ++++++--------
 drivers/net/pcmcia/fmvj18x_cs.c  |  109 ++++++++++------------------
 drivers/net/pcmcia/ibmtr_cs.c    |   54 +++++++-------
 drivers/net/pcmcia/nmclan_cs.c   |  148 +++++++++++++++----------------------
 drivers/net/pcmcia/pcnet_cs.c    |   67 +++++++-----------
 drivers/net/pcmcia/smc91c92_cs.c |   85 ++++++++--------------
 drivers/net/pcmcia/xirc2ps_cs.c  |  111 +++++++++++------------------
 10 files changed, 315 insertions(+), 508 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 6449290..dbef5d9 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -118,14 +118,6 @@ INT_MODULE_PARM(full_duplex, 0);
 /* Autodetect link polarity reversal? */
 INT_MODULE_PARM(auto_polarity, 1);
 
-#ifdef PCMCIA_DEBUG
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =
-"3c574_cs.c 1.65ac1 2003/04/07 Donald Becker/David Hinds, becker@scyld.com.\n";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 
@@ -278,7 +270,7 @@ static int tc574_probe(struct pcmcia_device *link)
 	struct el3_private *lp;
 	struct net_device *dev;
 
-	DEBUG(0, "3c574_attach()\n");
+	dev_dbg(&link->dev, "3c574_attach()\n");
 
 	/* Create the PC card device object. */
 	dev = alloc_etherdev(sizeof(struct el3_private));
@@ -319,7 +311,7 @@ static void tc574_detach(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 
-	DEBUG(0, "3c574_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "3c574_detach()\n");
 
 	if (link->dev_node)
 		unregister_netdev(dev);
@@ -335,16 +327,13 @@ static void tc574_detach(struct pcmcia_device *link)
 	ethernet device available to the system.
 */
 
-#define CS_CHECK(fn, ret) \
-  do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static const char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
 
 static int tc574_config(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 	struct el3_private *lp = netdev_priv(dev);
-	int last_fn, last_ret, i, j;
+	int ret, i, j;
 	unsigned int ioaddr;
 	__be16 *phys_addr;
 	char *cardname;
@@ -354,7 +343,7 @@ static int tc574_config(struct pcmcia_device *link)
 
 	phys_addr = (__be16 *)dev->dev_addr;
 
-	DEBUG(0, "3c574_config(0x%p)\n", link);
+	dev_dbg(&link->dev, "3c574_config()\n");
 
 	link->io.IOAddrLines = 16;
 	for (i = j = 0; j < 0x400; j += 0x20) {
@@ -363,12 +352,16 @@ static int tc574_config(struct pcmcia_device *link)
 		if (i == 0)
 			break;
 	}
-	if (i != 0) {
-		cs_error(link, RequestIO, i);
+	if (i != 0)
+		goto failed;
+
+	ret = pcmcia_request_irq(link, &link->irq);
+	if (ret)
+		goto failed;
+
+	ret = pcmcia_request_configuration(link, &link->conf);
+	if (ret)
 		goto failed;
-	}
-	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
 
 	dev->irq = link->irq.AssignedIRQ;
 	dev->base_addr = link->io.BasePort1;
@@ -433,7 +426,8 @@ static int tc574_config(struct pcmcia_device *link)
 			mii_status = mdio_read(ioaddr, phy & 0x1f, 1);
 			if (mii_status != 0xffff) {
 				lp->phys = phy & 0x1f;
-				DEBUG(0, "  MII transceiver at index %d, status %x.\n",
+				dev_dbg(&link->dev, "  MII transceiver at "
+					"index %d, status %x.\n",
 					  phy, mii_status);
 				if ((mii_status & 0x0040) == 0)
 					mii_preamble_required = 1;
@@ -476,8 +470,6 @@ static int tc574_config(struct pcmcia_device *link)
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
 failed:
 	tc574_release(link);
 	return -ENODEV;
@@ -736,7 +728,7 @@ static int el3_open(struct net_device *dev)
 	lp->media.expires = jiffies + HZ;
 	add_timer(&lp->media);
 	
-	DEBUG(2, "%s: opened, status %4.4x.\n",
+	dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
 		  dev->name, inw(dev->base_addr + EL3_STATUS));
 	
 	return 0;
@@ -770,7 +762,7 @@ static void pop_tx_status(struct net_device *dev)
 		if (tx_status & 0x30)
 			tc574_wait_for_completion(dev, TxReset);
 		if (tx_status & 0x38) {
-			DEBUG(1, "%s: transmit error: status 0x%02x\n",
+			pr_debug("%s: transmit error: status 0x%02x\n",
 				  dev->name, tx_status);
 			outw(TxEnable, ioaddr + EL3_CMD);
 			dev->stats.tx_aborted_errors++;
@@ -786,7 +778,7 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
 	struct el3_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
-	DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
+	pr_debug("%s: el3_start_xmit(length = %ld) called, "
 		  "status %4.4x.\n", dev->name, (long)skb->len,
 		  inw(ioaddr + EL3_STATUS));
 
@@ -825,7 +817,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	ioaddr = dev->base_addr;
 
-	DEBUG(3, "%s: interrupt, status %4.4x.\n",
+	pr_debug("%s: interrupt, status %4.4x.\n",
 		  dev->name, inw(ioaddr + EL3_STATUS));
 
 	spin_lock(&lp->window_lock);
@@ -834,7 +826,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		   (IntLatch | RxComplete | RxEarly | StatsFull)) {
 		if (!netif_device_present(dev) ||
 			((status & 0xe000) != 0x2000)) {
-			DEBUG(1, "%s: Interrupt from dead card\n", dev->name);
+			pr_debug("%s: Interrupt from dead card\n", dev->name);
 			break;
 		}
 
@@ -844,7 +836,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 			work_budget = el3_rx(dev, work_budget);
 
 		if (status & TxAvailable) {
-			DEBUG(3, "  TX room bit was handled.\n");
+			pr_debug("  TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue(dev);
@@ -884,7 +876,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		}
 
 		if (--work_budget < 0) {
-			DEBUG(0, "%s: Too much work in interrupt, "
+			pr_debug("%s: Too much work in interrupt, "
 				  "status %4.4x.\n", dev->name, status);
 			/* Clear all interrupts */
 			outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
@@ -894,7 +886,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		outw(AckIntr | IntReq | IntLatch, ioaddr + EL3_CMD);
 	}
 
-	DEBUG(3, "%s: exiting interrupt, status %4.4x.\n",
+	pr_debug("%s: exiting interrupt, status %4.4x.\n",
 		  dev->name, inw(ioaddr + EL3_STATUS));
 		  
 	spin_unlock(&lp->window_lock);
@@ -1001,7 +993,7 @@ static void update_stats(struct net_device *dev)
 	unsigned int ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
-	DEBUG(2, "%s: updating the statistics.\n", dev->name);
+	pr_debug("%s: updating the statistics.\n", dev->name);
 
 	if (inw(ioaddr+EL3_STATUS) == 0xffff) /* No card. */
 		return;
@@ -1037,7 +1029,7 @@ static int el3_rx(struct net_device *dev, int worklimit)
 	unsigned int ioaddr = dev->base_addr;
 	short rx_status;
 	
-	DEBUG(3, "%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
+	pr_debug("%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
 		  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RxStatus));
 	while (!((rx_status = inw(ioaddr + RxStatus)) & 0x8000) &&
 			worklimit > 0) {
@@ -1059,7 +1051,7 @@ static int el3_rx(struct net_device *dev, int worklimit)
 
 			skb = dev_alloc_skb(pkt_len+5);
 
-			DEBUG(3, "  Receiving packet size %d status %4.4x.\n",
+			pr_debug("  Receiving packet size %d status %4.4x.\n",
 				  pkt_len, rx_status);
 			if (skb != NULL) {
 				skb_reserve(skb, 2);
@@ -1070,7 +1062,7 @@ static int el3_rx(struct net_device *dev, int worklimit)
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			} else {
-				DEBUG(1, "%s: couldn't allocate a sk_buff of"
+				pr_debug("%s: couldn't allocate a sk_buff of"
 					  " size %d.\n", dev->name, pkt_len);
 				dev->stats.rx_dropped++;
 			}
@@ -1099,7 +1091,7 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	struct mii_ioctl_data *data = if_mii(rq);
 	int phy = lp->phys & 0x1f;
 
-	DEBUG(2, "%s: In ioct(%-.6s, %#4.4x) %4.4x %4.4x %4.4x %4.4x.\n",
+	pr_debug("%s: In ioct(%-.6s, %#4.4x) %4.4x %4.4x %4.4x %4.4x.\n",
 		  dev->name, rq->ifr_ifrn.ifrn_name, cmd,
 		  data->phy_id, data->reg_num, data->val_in, data->val_out);
 
@@ -1176,7 +1168,7 @@ static int el3_close(struct net_device *dev)
 	struct el3_private *lp = netdev_priv(dev);
 	struct pcmcia_device *link = lp->p_dev;
 
-	DEBUG(2, "%s: shutting down ethercard.\n", dev->name);
+	dev_dbg(&link->dev, "%s: shutting down ethercard.\n", dev->name);
 	
 	if (pcmcia_dev_present(link)) {
 		unsigned long flags;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index ea04356..4e18fc8 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -130,14 +130,6 @@ MODULE_LICENSE("GPL");
 /* Special hook for setting if_port when module is loaded */
 INT_MODULE_PARM(if_port, 0);
 
-#ifdef PCMCIA_DEBUG
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =
-DRV_NAME ".c " DRV_VERSION " 2001/10/13 00:08:50 (David Hinds)";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 
@@ -189,7 +181,7 @@ static int tc589_probe(struct pcmcia_device *link)
     struct el3_private *lp;
     struct net_device *dev;
 
-    DEBUG(0, "3c589_attach()\n");
+    dev_dbg(&link->dev, "3c589_attach()\n");
 
     /* Create new ethernet device */
     dev = alloc_etherdev(sizeof(struct el3_private));
@@ -231,7 +223,7 @@ static void tc589_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "3c589_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "3c589_detach\n");
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -249,21 +241,18 @@ static void tc589_detach(struct pcmcia_device *link)
     
 ======================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int tc589_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     struct el3_private *lp = netdev_priv(dev);
     __be16 *phys_addr = NULL;
-    int last_fn, last_ret, i, j, multi = 0, fifo;
+    int ret, i, j, multi = 0, fifo;
     unsigned int ioaddr;
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
     u8 *buf;
     size_t len;
     
-    DEBUG(0, "3c589_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "3c589_config\n");
 
     /* Is this a 3c562? */
     if (link->manf_id != MANFID_3COM)
@@ -280,12 +269,16 @@ static int tc589_config(struct pcmcia_device *link)
 	if (i == 0)
 		break;
     }
-    if (i != 0) {
-	cs_error(link, RequestIO, i);
+    if (i != 0)
 	goto failed;
-    }
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+
+    ret = pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
+
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
 	
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
@@ -341,8 +334,6 @@ static int tc589_config(struct pcmcia_device *link)
 	   if_names[dev->if_port]);
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     tc589_release(link);
     return -ENODEV;
@@ -505,24 +496,8 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
 }
 
-#ifdef PCMCIA_DEBUG
-static u32 netdev_get_msglevel(struct net_device *dev)
-{
-	return pc_debug;
-}
-
-static void netdev_set_msglevel(struct net_device *dev, u32 level)
-{
-	pc_debug = level;
-}
-#endif /* PCMCIA_DEBUG */
-
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-#ifdef PCMCIA_DEBUG
-	.get_msglevel		= netdev_get_msglevel,
-	.set_msglevel		= netdev_set_msglevel,
-#endif /* PCMCIA_DEBUG */
 };
 
 static int el3_config(struct net_device *dev, struct ifmap *map)
@@ -557,7 +532,7 @@ static int el3_open(struct net_device *dev)
     lp->media.expires = jiffies + HZ;
     add_timer(&lp->media);
 
-    DEBUG(1, "%s: opened, status %4.4x.\n",
+    dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
 	  dev->name, inw(dev->base_addr + EL3_STATUS));
     
     return 0;
@@ -590,7 +565,7 @@ static void pop_tx_status(struct net_device *dev)
 	if (tx_status & 0x30)
 	    tc589_wait_for_completion(dev, TxReset);
 	if (tx_status & 0x38) {
-	    DEBUG(1, "%s: transmit error: status 0x%02x\n",
+	    pr_debug("%s: transmit error: status 0x%02x\n",
 		  dev->name, tx_status);
 	    outw(TxEnable, ioaddr + EL3_CMD);
 	    dev->stats.tx_aborted_errors++;
@@ -606,7 +581,7 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
     struct el3_private *priv = netdev_priv(dev);
     unsigned long flags;
 
-    DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
+    pr_debug("%s: el3_start_xmit(length = %ld) called, "
 	  "status %4.4x.\n", dev->name, (long)skb->len,
 	  inw(ioaddr + EL3_STATUS));
 
@@ -648,14 +623,14 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 
     ioaddr = dev->base_addr;
 
-    DEBUG(3, "%s: interrupt, status %4.4x.\n",
+    pr_debug("%s: interrupt, status %4.4x.\n",
 	  dev->name, inw(ioaddr + EL3_STATUS));
 
     spin_lock(&lp->lock);    
     while ((status = inw(ioaddr + EL3_STATUS)) &
 	(IntLatch | RxComplete | StatsFull)) {
 	if ((status & 0xe000) != 0x2000) {
-	    DEBUG(1, "%s: interrupt from dead card\n", dev->name);
+	    pr_debug("%s: interrupt from dead card\n", dev->name);
 	    handled = 0;
 	    break;
 	}
@@ -664,7 +639,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 	    el3_rx(dev);
 	
 	if (status & TxAvailable) {
-	    DEBUG(3, "    TX room bit was handled.\n");
+	    pr_debug("    TX room bit was handled.\n");
 	    /* There's room in the FIFO for a full-sized packet. */
 	    outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 	    netif_wake_queue(dev);
@@ -716,7 +691,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 
     lp->last_irq = jiffies;
     spin_unlock(&lp->lock);    
-    DEBUG(3, "%s: exiting interrupt, status %4.4x.\n",
+    pr_debug("%s: exiting interrupt, status %4.4x.\n",
 	  dev->name, inw(ioaddr + EL3_STATUS));
     return IRQ_RETVAL(handled);
 }
@@ -827,7 +802,7 @@ static void update_stats(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
 
-    DEBUG(2, "%s: updating the statistics.\n", dev->name);
+    pr_debug("%s: updating the statistics.\n", dev->name);
     /* Turn off statistics updates while reading. */
     outw(StatsDisable, ioaddr + EL3_CMD);
     /* Switch to the stats window, and read everything. */
@@ -855,7 +830,7 @@ static int el3_rx(struct net_device *dev)
     int worklimit = 32;
     short rx_status;
     
-    DEBUG(3, "%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
+    pr_debug("%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
 	  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS));
     while (!((rx_status = inw(ioaddr + RX_STATUS)) & 0x8000) &&
 		    worklimit > 0) {
@@ -877,7 +852,7 @@ static int el3_rx(struct net_device *dev)
 	    
 	    skb = dev_alloc_skb(pkt_len+5);
 	    
-	    DEBUG(3, "    Receiving packet size %d status %4.4x.\n",
+	    pr_debug("    Receiving packet size %d status %4.4x.\n",
 		  pkt_len, rx_status);
 	    if (skb != NULL) {
 		skb_reserve(skb, 2);
@@ -888,7 +863,7 @@ static int el3_rx(struct net_device *dev)
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 	    } else {
-		DEBUG(1, "%s: couldn't allocate a sk_buff of"
+		pr_debug("%s: couldn't allocate a sk_buff of"
 		      " size %d.\n", dev->name, pkt_len);
 		dev->stats.rx_dropped++;
 	    }
@@ -929,7 +904,7 @@ static int el3_close(struct net_device *dev)
     struct pcmcia_device *link = lp->p_dev;
     unsigned int ioaddr = dev->base_addr;
     
-    DEBUG(1, "%s: shutting down ethercard.\n", dev->name);
+    dev_dbg(&link->dev, "%s: shutting down ethercard.\n", dev->name);
 
     if (pcmcia_dev_present(link)) {
 	/* Turn off statistics ASAP.  We update dev->stats below. */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 3131a59..5af2ccf 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -75,16 +75,6 @@ MODULE_AUTHOR("David Hinds <dahinds@users.sourceforge.net>");
 MODULE_DESCRIPTION("Asix AX88190 PCMCIA ethernet driver");
 MODULE_LICENSE("GPL");
 
-#ifdef PCMCIA_DEBUG
-#define INT_MODULE_PARM(n, v) static int n = v; module_param(n, int, 0)
-
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =
-"axnet_cs.c 1.28 2002/06/29 06:27:37 (David Hinds)";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 
@@ -167,7 +157,7 @@ static int axnet_probe(struct pcmcia_device *link)
     struct net_device *dev;
     struct ei_device *ei_local;
 
-    DEBUG(0, "axnet_attach()\n");
+    dev_dbg(&link->dev, "axnet_attach()\n");
 
     dev = alloc_etherdev(sizeof(struct ei_device) + sizeof(axnet_dev_t));
     if (!dev)
@@ -205,7 +195,7 @@ static void axnet_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "axnet_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "axnet_detach(0x%p)\n", link);
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -272,9 +262,6 @@ static int get_prom(struct pcmcia_device *link)
 
 ======================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int try_io_port(struct pcmcia_device *link)
 {
     int j, ret;
@@ -341,26 +328,29 @@ static int axnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     axnet_dev_t *info = PRIV(dev);
-    int i, j, j2, last_ret, last_fn;
+    int i, j, j2, ret;
 
-    DEBUG(0, "axnet_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "axnet_config(0x%p)\n", link);
 
     /* don't trust the CIS on this; Linksys got it wrong */
     link->conf.Present = 0x63;
-    last_ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
-    if (last_ret != 0) {
-	cs_error(link, RequestIO, last_ret);
+    ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
+    if (ret != 0)
 	goto failed;
-    }
 
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+    ret = pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
     
     if (link->io.NumPorts2 == 8) {
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
 	link->conf.Status = CCSR_AUDIO_ENA;
     }
     
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
+
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
 
@@ -426,14 +416,12 @@ static int axnet_config(struct pcmcia_device *link)
 	   dev->base_addr, dev->irq,
 	   dev->dev_addr);
     if (info->phy_id != -1) {
-	DEBUG(0, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
+	dev_dbg(&link->dev, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
     } else {
 	printk(KERN_NOTICE "  No MII transceivers found!\n");
     }
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     axnet_release(link);
     return -ENODEV;
@@ -543,7 +531,7 @@ static int axnet_open(struct net_device *dev)
     struct pcmcia_device *link = info->p_dev;
     unsigned int nic_base = dev->base_addr;
     
-    DEBUG(2, "axnet_open('%s')\n", dev->name);
+    dev_dbg(&link->dev, "axnet_open('%s')\n", dev->name);
 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
@@ -572,7 +560,7 @@ static int axnet_close(struct net_device *dev)
     axnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
 
-    DEBUG(2, "axnet_close('%s')\n", dev->name);
+    dev_dbg(&link->dev, "axnet_close('%s')\n", dev->name);
 
     ax_close(dev);
     free_irq(dev->irq, dev);
@@ -741,10 +729,8 @@ static void block_input(struct net_device *dev, int count,
     int xfer_count = count;
     char *buf = skb->data;
 
-#ifdef PCMCIA_DEBUG
     if ((ei_debug > 4) && (count != 4))
-	printk(KERN_DEBUG "%s: [bi=%d]\n", dev->name, count+4);
-#endif
+	    pr_debug("%s: [bi=%d]\n", dev->name, count+4);
     outb_p(ring_offset & 0xff, nic_base + EN0_RSARLO);
     outb_p(ring_offset >> 8, nic_base + EN0_RSARHI);
     outb_p(E8390_RREAD+E8390_START, nic_base + AXNET_CMD);
@@ -762,10 +748,7 @@ static void block_output(struct net_device *dev, int count,
 {
     unsigned int nic_base = dev->base_addr;
 
-#ifdef PCMCIA_DEBUG
-    if (ei_debug > 4)
-	printk(KERN_DEBUG "%s: [bo=%d]\n", dev->name, count);
-#endif
+    pr_debug("%s: [bo=%d]\n", dev->name, count);
 
     /* Round the count up for word writes.  Do we need to do this?
        What effect will an odd byte count have on the 8390?
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 7b5c77b..9a2e500 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -53,11 +53,7 @@
 
 #define VERSION "arcnet: COM20020 PCMCIA support loaded.\n"
 
-#ifdef PCMCIA_DEBUG
-
-static int pc_debug = PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
+#ifdef DEBUG
 
 static void regdump(struct net_device *dev)
 {
@@ -92,7 +88,6 @@ static void regdump(struct net_device *dev)
 
 #else
 
-#define DEBUG(n, args...) do { } while (0)
 static inline void regdump(struct net_device *dev) { }
 
 #endif
@@ -144,7 +139,7 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     struct net_device *dev;
     struct arcnet_local *lp;
 
-    DEBUG(0, "com20020_attach()\n");
+    dev_dbg(&p_dev->dev, "com20020_attach()\n");
 
     /* Create new network device */
     info = kzalloc(sizeof(struct com20020_dev_t), GFP_KERNEL);
@@ -198,12 +193,12 @@ static void com20020_detach(struct pcmcia_device *link)
     struct com20020_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
 
-    DEBUG(1,"detach...\n");
+    dev_dbg(&link->dev, "detach...\n");
 
-    DEBUG(0, "com20020_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "com20020_detach\n");
 
     if (link->dev_node) {
-	DEBUG(1,"unregister...\n");
+	dev_dbg(&link->dev, "unregister...\n");
 
 	unregister_netdev(dev);
 
@@ -218,16 +213,16 @@ static void com20020_detach(struct pcmcia_device *link)
     com20020_release(link);
 
     /* Unlink device structure, free bits */
-    DEBUG(1,"unlinking...\n");
+    dev_dbg(&link->dev, "unlinking...\n");
     if (link->priv)
     {
 	dev = info->dev;
 	if (dev)
 	{
-	    DEBUG(1,"kfree...\n");
+	    dev_dbg(&link->dev, "kfree...\n");
 	    free_netdev(dev);
 	}
-	DEBUG(1,"kfree2...\n");
+	dev_dbg(&link->dev, "kfree2...\n");
 	kfree(info);
     }
 
@@ -241,25 +236,22 @@ static void com20020_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int com20020_config(struct pcmcia_device *link)
 {
     struct arcnet_local *lp;
     com20020_dev_t *info;
     struct net_device *dev;
-    int i, last_ret, last_fn;
+    int i, ret;
     int ioaddr;
 
     info = link->priv;
     dev = info->dev;
 
-    DEBUG(1,"config...\n");
+    dev_dbg(&link->dev, "config...\n");
 
-    DEBUG(0, "com20020_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "com20020_config\n");
 
-    DEBUG(1,"arcnet: baseport1 is %Xh\n", link->io.BasePort1);
+    dev_dbg(&link->dev, "baseport1 is %Xh\n", link->io.BasePort1);
     i = -ENODEV;
     if (!link->io.BasePort1)
     {
@@ -276,26 +268,28 @@ static int com20020_config(struct pcmcia_device *link)
     
     if (i != 0)
     {
-	DEBUG(1,"arcnet: requestIO failed totally!\n");
+	dev_dbg(&link->dev, "requestIO failed totally!\n");
 	goto failed;
     }
 	
     ioaddr = dev->base_addr = link->io.BasePort1;
-    DEBUG(1,"arcnet: got ioaddr %Xh\n", ioaddr);
+    dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
 
-    DEBUG(1,"arcnet: request IRQ %d (%Xh/%Xh)\n",
+    dev_dbg(&link->dev, "request IRQ %d (%Xh/%Xh)\n",
 	   link->irq.AssignedIRQ,
 	   link->irq.IRQInfo1, link->irq.IRQInfo2);
     i = pcmcia_request_irq(link, &link->irq);
     if (i != 0)
     {
-	DEBUG(1,"arcnet: requestIRQ failed totally!\n");
+	dev_dbg(&link->dev, "requestIRQ failed totally!\n");
 	goto failed;
     }
 
     dev->irq = link->irq.AssignedIRQ;
 
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
 
     if (com20020_check(dev))
     {
@@ -313,21 +307,20 @@ static int com20020_config(struct pcmcia_device *link)
     i = com20020_found(dev, 0);	/* calls register_netdev */
     
     if (i != 0) {
-	DEBUG(1,KERN_NOTICE "com20020_cs: com20020_found() failed\n");
+	dev_printk(KERN_NOTICE, &link->dev,
+		"com20020_cs: com20020_found() failed\n");
 	link->dev_node = NULL;
 	goto failed;
     }
 
     strcpy(info->node.dev_name, dev->name);
 
-    DEBUG(1,KERN_INFO "%s: port %#3lx, irq %d\n",
+    dev_dbg(&link->dev,KERN_INFO "%s: port %#3lx, irq %d\n",
            dev->name, dev->base_addr, dev->irq);
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
-    DEBUG(1,"com20020_config failed...\n");
+    dev_dbg(&link->dev, "com20020_config failed...\n");
     com20020_release(link);
     return -ENODEV;
 } /* com20020_config */
@@ -342,7 +335,7 @@ failed:
 
 static void com20020_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "com20020_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "com20020_release\n");
 	pcmcia_disable_device(link);
 }
 
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 58954a6..ecdff17 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -72,13 +72,6 @@ MODULE_LICENSE("GPL");
 /* 0:4KB*2 TX buffer   else:8KB*2 TX buffer */
 INT_MODULE_PARM(sram_config, 0);
 
-#ifdef PCMCIA_DEBUG
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version = DRV_NAME ".c " DRV_VERSION " 2002/03/23";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 /*
@@ -245,7 +238,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     local_info_t *lp;
     struct net_device *dev;
 
-    DEBUG(0, "fmvj18x_attach()\n");
+    dev_dbg(&link->dev, "fmvj18x_attach()\n");
 
     /* Make up a FMVJ18x specific data structure */
     dev = alloc_etherdev(sizeof(local_info_t));
@@ -285,7 +278,7 @@ static void fmvj18x_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "fmvj18x_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "fmvj18x_detach\n");
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -297,9 +290,6 @@ static void fmvj18x_detach(struct pcmcia_device *link)
 
 /*====================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int mfc_try_io_port(struct pcmcia_device *link)
 {
     int i, ret;
@@ -354,7 +344,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     local_info_t *lp = netdev_priv(dev);
-    int i, last_fn = RequestIO, last_ret = 0, ret;
+    int i, ret;
     unsigned int ioaddr;
     cardtype_t cardtype;
     char *card_name = "unknown";
@@ -362,7 +352,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
     size_t len;
     u_char buggybuf[32];
 
-    DEBUG(0, "fmvj18x_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "fmvj18x_config\n");
 
     len = pcmcia_get_tuple(link, CISTPL_FUNCE, &buf);
     if (buf)
@@ -370,9 +360,9 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     if (len) {
 	/* Yes, I have CISTPL_FUNCE. Let's check CISTPL_MANFID */
-	last_ret = pcmcia_loop_config(link, fmvj18x_ioprobe, NULL);
-	if (last_ret != 0)
-		goto cs_failed;
+	ret = pcmcia_loop_config(link, fmvj18x_ioprobe, NULL);
+	if (ret != 0)
+		goto failed;
 
 	switch (link->manf_id) {
 	case MANFID_TDK:
@@ -441,15 +431,22 @@ static int fmvj18x_config(struct pcmcia_device *link)
     	link->irq.Attributes =
 		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED|IRQ_HANDLE_PRESENT;
 	ret = mfc_try_io_port(link);
-	if (ret != 0) goto cs_failed;
+	if (ret != 0) goto failed;
     } else if (cardtype == UNGERMANN) {
 	ret = ungermann_try_io_port(link);
-	if (ret != 0) goto cs_failed;
+	if (ret != 0) goto failed;
     } else { 
-	CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
+	    ret = pcmcia_request_io(link, &link->io);
+	    if (ret)
+		    goto failed;
     }
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+    ret = pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
+
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
 
@@ -554,9 +551,6 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     return 0;
     
-cs_failed:
-    /* All Card Services errors end up here */
-    cs_error(link, last_fn, last_ret);
 failed:
     fmvj18x_release(link);
     return -ENODEV;
@@ -575,10 +569,8 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != 0) {
-	cs_error(link, RequestWindow, i);
+    if (i != 0)
 	return -1;
-    }
 
     base = ioremap(req.Base, req.Size);
     mem.Page = 0;
@@ -609,8 +601,6 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 
     iounmap(base);
     j = pcmcia_release_window(link->win);
-    if (j != 0)
-	cs_error(link, ReleaseWindow, j);
     return (i != 0x200) ? 0 : -1;
 
 } /* fmvj18x_get_hwinfo */
@@ -630,10 +620,8 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != 0) {
-	cs_error(link, RequestWindow, i);
+    if (i != 0)
 	return -1;
-    }
 
     lp->base = ioremap(req.Base, req.Size);
     if (lp->base == NULL) {
@@ -647,7 +635,6 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
     if (i != 0) {
 	iounmap(lp->base);
 	lp->base = NULL;
-	cs_error(link, MapMemPage, i);
 	return -1;
     }
     
@@ -674,15 +661,13 @@ static void fmvj18x_release(struct pcmcia_device *link)
     u_char __iomem *tmp;
     int j;
 
-    DEBUG(0, "fmvj18x_release(0x%p)\n", link);
+    dev_dbg(&link->dev, "fmvj18x_release\n");
 
     if (lp->base != NULL) {
 	tmp = lp->base;
 	lp->base = NULL;    /* set NULL before iounmap */
 	iounmap(tmp);
 	j = pcmcia_release_window(link->win);
-	if (j != 0)
-	    cs_error(link, ReleaseWindow, j);
     }
 
     pcmcia_disable_device(link);
@@ -791,8 +776,8 @@ static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
     outb(tx_stat, ioaddr + TX_STATUS);
     outb(rx_stat, ioaddr + RX_STATUS);
     
-    DEBUG(4, "%s: interrupt, rx_status %02x.\n", dev->name, rx_stat);
-    DEBUG(4, "               tx_status %02x.\n", tx_stat);
+    pr_debug("%s: interrupt, rx_status %02x.\n", dev->name, rx_stat);
+    pr_debug("               tx_status %02x.\n", tx_stat);
     
     if (rx_stat || (inb(ioaddr + RX_MODE) & F_BUF_EMP) == 0) {
 	/* there is packet(s) in rx buffer */
@@ -812,8 +797,8 @@ static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 	}
 	netif_wake_queue(dev);
     }
-    DEBUG(4, "%s: exiting interrupt,\n", dev->name);
-    DEBUG(4, "    tx_status %02x, rx_status %02x.\n", tx_stat, rx_stat);
+    pr_debug("%s: exiting interrupt,\n", dev->name);
+    pr_debug("    tx_status %02x, rx_status %02x.\n", tx_stat, rx_stat);
 
     outb(D_TX_INTR, ioaddr + TX_INTR);
     outb(D_RX_INTR, ioaddr + RX_INTR);
@@ -885,7 +870,7 @@ static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
 	    return NETDEV_TX_BUSY;
 	}
 
-	DEBUG(4, "%s: Transmitting a packet of length %lu.\n",
+	pr_debug("%s: Transmitting a packet of length %lu.\n",
 	      dev->name, (unsigned long)skb->len);
 	dev->stats.tx_bytes += skb->len;
 
@@ -940,7 +925,7 @@ static void fjn_reset(struct net_device *dev)
     unsigned int ioaddr = dev->base_addr;
     int i;
 
-    DEBUG(4, "fjn_reset(%s) called.\n",dev->name);
+    pr_debug("fjn_reset(%s) called.\n",dev->name);
 
     /* Reset controller */
     if( sram_config == 0 ) 
@@ -1018,13 +1003,13 @@ static void fjn_rx(struct net_device *dev)
     unsigned int ioaddr = dev->base_addr;
     int boguscount = 10;	/* 5 -> 10: by agy 19940922 */
 
-    DEBUG(4, "%s: in rx_packet(), rx_status %02x.\n",
+    pr_debug("%s: in rx_packet(), rx_status %02x.\n",
 	  dev->name, inb(ioaddr + RX_STATUS));
 
     while ((inb(ioaddr + RX_MODE) & F_BUF_EMP) == 0) {
 	u_short status = inw(ioaddr + DATAPORT);
 
-	DEBUG(4, "%s: Rxing packet mode %02x status %04x.\n",
+	pr_debug("%s: Rxing packet mode %02x status %04x.\n",
 	      dev->name, inb(ioaddr + RX_MODE), status);
 #ifndef final_version
 	if (status == 0) {
@@ -1064,16 +1049,14 @@ static void fjn_rx(struct net_device *dev)
 		 (pkt_len + 1) >> 1);
 	    skb->protocol = eth_type_trans(skb, dev);
 
-#ifdef PCMCIA_DEBUG
-	    if (pc_debug > 5) {
+	    {
 		int i;
-		printk(KERN_DEBUG "%s: Rxed packet of length %d: ",
-		       dev->name, pkt_len);
+		pr_debug("%s: Rxed packet of length %d: ",
+			dev->name, pkt_len);
 		for (i = 0; i < 14; i++)
-		    printk(" %02x", skb->data[i]);
-		printk(".\n");
+			pr_debug(" %02x", skb->data[i]);
+		pr_debug(".\n");
 	    }
-#endif
 
 	    netif_rx(skb);
 	    dev->stats.rx_packets++;
@@ -1097,7 +1080,7 @@ static void fjn_rx(struct net_device *dev)
 	}
 
 	if (i > 0)
-	    DEBUG(5, "%s: Exint Rx packet with mode %02x after "
+	    pr_debug("%s: Exint Rx packet with mode %02x after "
 		  "%d ticks.\n", dev->name, inb(ioaddr + RX_MODE), i);
     }
 */
@@ -1115,24 +1098,8 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
 }
 
-#ifdef PCMCIA_DEBUG
-static u32 netdev_get_msglevel(struct net_device *dev)
-{
-	return pc_debug;
-}
-
-static void netdev_set_msglevel(struct net_device *dev, u32 level)
-{
-	pc_debug = level;
-}
-#endif /* PCMCIA_DEBUG */
-
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-#ifdef PCMCIA_DEBUG
-	.get_msglevel		= netdev_get_msglevel,
-	.set_msglevel		= netdev_set_msglevel,
-#endif /* PCMCIA_DEBUG */
 };
 
 static int fjn_config(struct net_device *dev, struct ifmap *map){
@@ -1144,7 +1111,7 @@ static int fjn_open(struct net_device *dev)
     struct local_info_t *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
-    DEBUG(4, "fjn_open('%s').\n", dev->name);
+    pr_debug("fjn_open('%s').\n", dev->name);
 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
@@ -1170,7 +1137,7 @@ static int fjn_close(struct net_device *dev)
     struct pcmcia_device *link = lp->p_dev;
     unsigned int ioaddr = dev->base_addr;
 
-    DEBUG(4, "fjn_close('%s').\n", dev->name);
+    pr_debug("fjn_close('%s').\n", dev->name);
 
     lp->open_time = 0;
     netif_stop_queue(dev);
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 06618af..0d914f3 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -69,17 +69,6 @@
 #define PCMCIA
 #include "../tokenring/ibmtr.c"
 
-#ifdef PCMCIA_DEBUG
-static int pc_debug = PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =
-"ibmtr_cs.c 1.10   1996/01/06 05:19:00 (Steve Kipisz)\n"
-"           2.2.7  1999/05/03 12:00:00 (Mike Phillips)\n"
-"           2.4.2  2001/30/28 Midnight (Burt Silverman)\n";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 
@@ -143,7 +132,7 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     ibmtr_dev_t *info;
     struct net_device *dev;
 
-    DEBUG(0, "ibmtr_attach()\n");
+    dev_dbg(&link->dev, "ibmtr_attach()\n");
 
     /* Create new token-ring device */
     info = kzalloc(sizeof(*info), GFP_KERNEL);
@@ -190,7 +179,7 @@ static void ibmtr_detach(struct pcmcia_device *link)
     struct net_device *dev = info->dev;
      struct tok_info *ti = netdev_priv(dev);
 
-    DEBUG(0, "ibmtr_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "ibmtr_detach\n");
     
     /* 
      * When the card removal interrupt hits tok_interrupt(), 
@@ -217,9 +206,6 @@ static void ibmtr_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int __devinit ibmtr_config(struct pcmcia_device *link)
 {
     ibmtr_dev_t *info = link->priv;
@@ -227,9 +213,9 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     struct tok_info *ti = netdev_priv(dev);
     win_req_t req;
     memreq_t mem;
-    int i, last_ret, last_fn;
+    int i, ret;
 
-    DEBUG(0, "ibmtr_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "ibmtr_config\n");
 
     link->conf.ConfigIndex = 0x61;
 
@@ -241,11 +227,15 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     if (i != 0) {
 	/* Couldn't get 0xA20-0xA23.  Try ALTERNATE at 0xA24-0xA27. */
 	link->io.BasePort1 = 0xA24;
-	CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
+	ret = pcmcia_request_io(link, &link->io);
+	if (ret)
+		goto failed;
     }
     dev->base_addr = link->io.BasePort1;
 
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+    ret = pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
     dev->irq = link->irq.AssignedIRQ;
     ti->irq = link->irq.AssignedIRQ;
     ti->global_int_enable=GLOBAL_INT_ENABLE+((dev->irq==9) ? 2 : dev->irq);
@@ -256,11 +246,15 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     req.Base = 0; 
     req.Size = 0x2000;
     req.AccessSpeed = 250;
-    CS_CHECK(RequestWindow, pcmcia_request_window(&link, &req, &link->win));
+    ret = pcmcia_request_window(&link, &req, &link->win);
+    if (ret)
+	    goto failed;
 
     mem.CardOffset = mmiobase;
     mem.Page = 0;
-    CS_CHECK(MapMemPage, pcmcia_map_mem_page(link->win, &mem));
+    ret = pcmcia_map_mem_page(link->win, &mem);
+    if (ret)
+	    goto failed;
     ti->mmio = ioremap(req.Base, req.Size);
 
     /* Allocate the SRAM memory window */
@@ -269,17 +263,23 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     req.Base = 0;
     req.Size = sramsize * 1024;
     req.AccessSpeed = 250;
-    CS_CHECK(RequestWindow, pcmcia_request_window(&link, &req, &info->sram_win_handle));
+    ret = pcmcia_request_window(&link, &req, &info->sram_win_handle);
+    if (ret)
+	    goto failed;
 
     mem.CardOffset = srambase;
     mem.Page = 0;
-    CS_CHECK(MapMemPage, pcmcia_map_mem_page(info->sram_win_handle, &mem));
+    ret = pcmcia_map_mem_page(info->sram_win_handle, &mem);
+    if (ret)
+	    goto failed;
 
     ti->sram_base = mem.CardOffset >> 12;
     ti->sram_virt = ioremap(req.Base, req.Size);
     ti->sram_phys = req.Base;
 
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
 
     /*  Set up the Token-Ring Controller Configuration Register and
         turn on the card.  Check the "Local Area Network Credit Card
@@ -305,8 +305,6 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 	   dev->dev_addr);
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     ibmtr_release(link);
     return -ENODEV;
@@ -325,7 +323,7 @@ static void ibmtr_release(struct pcmcia_device *link)
 	ibmtr_dev_t *info = link->priv;
 	struct net_device *dev = info->dev;
 
-	DEBUG(0, "ibmtr_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "ibmtr_release\n");
 
 	if (link->win) {
 		struct tok_info *ti = netdev_priv(dev);
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 4b96b35..a536348 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -381,13 +381,6 @@ typedef struct _mace_private {
 Private Global Variables
 ---------------------------------------------------------------------------- */
 
-#ifdef PCMCIA_DEBUG
-static char rcsid[] =
-"nmclan_cs.c,v 0.16 1995/07/01 06:42:17 rpao Exp rpao";
-static char *version =
-DRV_NAME " " DRV_VERSION " (Roger C. Pao)";
-#endif
-
 static const char *if_names[]={
     "Auto", "10baseT", "BNC",
 };
@@ -406,12 +399,6 @@ MODULE_LICENSE("GPL");
 /* 0=auto, 1=10baseT, 2 = 10base2, default=auto */
 INT_MODULE_PARM(if_port, 0);
 
-#ifdef PCMCIA_DEBUG
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-#else
-#define DEBUG(n, args...)
-#endif
 
 /* ----------------------------------------------------------------------------
 Function Prototypes
@@ -462,8 +449,7 @@ static int nmclan_probe(struct pcmcia_device *link)
     mace_private *lp;
     struct net_device *dev;
 
-    DEBUG(0, "nmclan_attach()\n");
-    DEBUG(1, "%s\n", rcsid);
+    dev_dbg(&link->dev, "nmclan_attach()\n");
 
     /* Create new ethernet device */
     dev = alloc_etherdev(sizeof(mace_private));
@@ -507,7 +493,7 @@ static void nmclan_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "nmclan_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "nmclan_detach\n");
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -654,23 +640,27 @@ nmclan_config
 	ethernet device available to the system.
 ---------------------------------------------------------------------------- */
 
-#define CS_CHECK(fn, ret) \
-  do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int nmclan_config(struct pcmcia_device *link)
 {
   struct net_device *dev = link->priv;
   mace_private *lp = netdev_priv(dev);
   u8 *buf;
   size_t len;
-  int i, last_ret, last_fn;
+  int i, ret;
   unsigned int ioaddr;
 
-  DEBUG(0, "nmclan_config(0x%p)\n", link);
+  dev_dbg(&link->dev, "nmclan_config\n");
+
+  ret = pcmcia_request_io(link, &link->io);
+  if (ret)
+	  goto failed;
+  ret = pcmcia_request_irq(link, &link->irq);
+  if (ret)
+	  goto failed;
+  ret = pcmcia_request_configuration(link, &link->conf);
+  if (ret)
+	  goto failed;
 
-  CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
-  CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-  CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
   dev->irq = link->irq.AssignedIRQ;
   dev->base_addr = link->io.BasePort1;
 
@@ -692,7 +682,7 @@ static int nmclan_config(struct pcmcia_device *link)
     sig[0] = mace_read(lp, ioaddr, MACE_CHIPIDL);
     sig[1] = mace_read(lp, ioaddr, MACE_CHIPIDH);
     if ((sig[0] == 0x40) && ((sig[1] & 0x0F) == 0x09)) {
-      DEBUG(0, "nmclan_cs configured: mace id=%x %x\n",
+      dev_dbg(&link->dev, "nmclan_cs configured: mace id=%x %x\n",
 	    sig[0], sig[1]);
     } else {
       printk(KERN_NOTICE "nmclan_cs: mace id not found: %x %x should"
@@ -728,8 +718,6 @@ static int nmclan_config(struct pcmcia_device *link)
 	 dev->dev_addr);
   return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
 failed:
 	nmclan_release(link);
 	return -ENODEV;
@@ -743,7 +731,7 @@ nmclan_release
 ---------------------------------------------------------------------------- */
 static void nmclan_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "nmclan_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "nmclan_release\n");
 	pcmcia_disable_device(link);
 }
 
@@ -794,7 +782,7 @@ static void nmclan_reset(struct net_device *dev)
   /* Reset Xilinx */
   reg.Action = CS_WRITE;
   reg.Offset = CISREG_COR;
-  DEBUG(1, "nmclan_reset: OrigCorValue=0x%lX, resetting...\n",
+  dev_dbg(&link->dev, "nmclan_reset: OrigCorValue=0x%lX, resetting...\n",
 	OrigCorValue);
   reg.Value = COR_SOFT_RESET;
   pcmcia_access_configuration_register(link, &reg);
@@ -871,7 +859,7 @@ static int mace_close(struct net_device *dev)
   mace_private *lp = netdev_priv(dev);
   struct pcmcia_device *link = lp->p_dev;
 
-  DEBUG(2, "%s: shutting down ethercard.\n", dev->name);
+  dev_dbg(&link->dev, "%s: shutting down ethercard.\n", dev->name);
 
   /* Mask off all interrupts from the MACE chip. */
   outb(0xFF, ioaddr + AM2150_MACE_BASE + MACE_IMR);
@@ -890,24 +878,8 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
 }
 
-#ifdef PCMCIA_DEBUG
-static u32 netdev_get_msglevel(struct net_device *dev)
-{
-	return pc_debug;
-}
-
-static void netdev_set_msglevel(struct net_device *dev, u32 level)
-{
-	pc_debug = level;
-}
-#endif /* PCMCIA_DEBUG */
-
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-#ifdef PCMCIA_DEBUG
-	.get_msglevel		= netdev_get_msglevel,
-	.set_msglevel		= netdev_set_msglevel,
-#endif /* PCMCIA_DEBUG */
 };
 
 /* ----------------------------------------------------------------------------
@@ -945,7 +917,7 @@ static netdev_tx_t mace_start_xmit(struct sk_buff *skb,
 
   netif_stop_queue(dev);
 
-  DEBUG(3, "%s: mace_start_xmit(length = %ld) called.\n",
+  pr_debug("%s: mace_start_xmit(length = %ld) called.\n",
 	dev->name, (long)skb->len);
 
 #if (!TX_INTERRUPTABLE)
@@ -1007,7 +979,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   int IntrCnt = MACE_MAX_IR_ITERATIONS;
 
   if (dev == NULL) {
-    DEBUG(2, "mace_interrupt(): irq 0x%X for unknown device.\n",
+    pr_debug("mace_interrupt(): irq 0x%X for unknown device.\n",
 	  irq);
     return IRQ_NONE;
   }
@@ -1030,7 +1002,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   }
 
   if (!netif_device_present(dev)) {
-    DEBUG(2, "%s: interrupt from dead card\n", dev->name);
+    pr_debug("%s: interrupt from dead card\n", dev->name);
     return IRQ_NONE;
   }
 
@@ -1038,7 +1010,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
     /* WARNING: MACE_IR is a READ/CLEAR port! */
     status = inb(ioaddr + AM2150_MACE_BASE + MACE_IR);
 
-    DEBUG(3, "mace_interrupt: irq 0x%X status 0x%X.\n", irq, status);
+    pr_debug("mace_interrupt: irq 0x%X status 0x%X.\n", irq, status);
 
     if (status & MACE_IR_RCVINT) {
       mace_rx(dev, MACE_MAX_RX_ITERATIONS);
@@ -1157,7 +1129,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
   ) {
     rx_status = inw(ioaddr + AM2150_RCV);
 
-    DEBUG(3, "%s: in mace_rx(), framecnt 0x%X, rx_status"
+    pr_debug("%s: in mace_rx(), framecnt 0x%X, rx_status"
 	  " 0x%X.\n", dev->name, rx_framecnt, rx_status);
 
     if (rx_status & MACE_RCVFS_RCVSTS) { /* Error, update stats. */
@@ -1184,7 +1156,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
       lp->mace_stats.rfs_rcvcc += inb(ioaddr + AM2150_RCV);
         /* rcv collision count */
 
-      DEBUG(3, "    receiving packet size 0x%X rx_status"
+      pr_debug("    receiving packet size 0x%X rx_status"
 	    " 0x%X.\n", pkt_len, rx_status);
 
       skb = dev_alloc_skb(pkt_len+2);
@@ -1203,7 +1175,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
 	outb(0xFF, ioaddr + AM2150_RCV_NEXT); /* skip to next frame */
 	continue;
       } else {
-	DEBUG(1, "%s: couldn't allocate a sk_buff of size"
+	pr_debug("%s: couldn't allocate a sk_buff of size"
 	      " %d.\n", dev->name, pkt_len);
 	lp->linux_stats.rx_dropped++;
       }
@@ -1219,28 +1191,28 @@ pr_linux_stats
 ---------------------------------------------------------------------------- */
 static void pr_linux_stats(struct net_device_stats *pstats)
 {
-  DEBUG(2, "pr_linux_stats\n");
-  DEBUG(2, " rx_packets=%-7ld        tx_packets=%ld\n",
+  pr_debug("pr_linux_stats\n");
+  pr_debug(" rx_packets=%-7ld        tx_packets=%ld\n",
 	(long)pstats->rx_packets, (long)pstats->tx_packets);
-  DEBUG(2, " rx_errors=%-7ld         tx_errors=%ld\n",
+  pr_debug(" rx_errors=%-7ld         tx_errors=%ld\n",
 	(long)pstats->rx_errors, (long)pstats->tx_errors);
-  DEBUG(2, " rx_dropped=%-7ld        tx_dropped=%ld\n",
+  pr_debug(" rx_dropped=%-7ld        tx_dropped=%ld\n",
 	(long)pstats->rx_dropped, (long)pstats->tx_dropped);
-  DEBUG(2, " multicast=%-7ld         collisions=%ld\n",
+  pr_debug(" multicast=%-7ld         collisions=%ld\n",
 	(long)pstats->multicast, (long)pstats->collisions);
 
-  DEBUG(2, " rx_length_errors=%-7ld  rx_over_errors=%ld\n",
+  pr_debug(" rx_length_errors=%-7ld  rx_over_errors=%ld\n",
 	(long)pstats->rx_length_errors, (long)pstats->rx_over_errors);
-  DEBUG(2, " rx_crc_errors=%-7ld     rx_frame_errors=%ld\n",
+  pr_debug(" rx_crc_errors=%-7ld     rx_frame_errors=%ld\n",
 	(long)pstats->rx_crc_errors, (long)pstats->rx_frame_errors);
-  DEBUG(2, " rx_fifo_errors=%-7ld    rx_missed_errors=%ld\n",
+  pr_debug(" rx_fifo_errors=%-7ld    rx_missed_errors=%ld\n",
 	(long)pstats->rx_fifo_errors, (long)pstats->rx_missed_errors);
 
-  DEBUG(2, " tx_aborted_errors=%-7ld tx_carrier_errors=%ld\n",
+  pr_debug(" tx_aborted_errors=%-7ld tx_carrier_errors=%ld\n",
 	(long)pstats->tx_aborted_errors, (long)pstats->tx_carrier_errors);
-  DEBUG(2, " tx_fifo_errors=%-7ld    tx_heartbeat_errors=%ld\n",
+  pr_debug(" tx_fifo_errors=%-7ld    tx_heartbeat_errors=%ld\n",
 	(long)pstats->tx_fifo_errors, (long)pstats->tx_heartbeat_errors);
-  DEBUG(2, " tx_window_errors=%ld\n",
+  pr_debug(" tx_window_errors=%ld\n",
 	(long)pstats->tx_window_errors);
 } /* pr_linux_stats */
 
@@ -1249,48 +1221,48 @@ pr_mace_stats
 ---------------------------------------------------------------------------- */
 static void pr_mace_stats(mace_statistics *pstats)
 {
-  DEBUG(2, "pr_mace_stats\n");
+  pr_debug("pr_mace_stats\n");
 
-  DEBUG(2, " xmtsv=%-7d             uflo=%d\n",
+  pr_debug(" xmtsv=%-7d             uflo=%d\n",
 	pstats->xmtsv, pstats->uflo);
-  DEBUG(2, " lcol=%-7d              more=%d\n",
+  pr_debug(" lcol=%-7d              more=%d\n",
 	pstats->lcol, pstats->more);
-  DEBUG(2, " one=%-7d               defer=%d\n",
+  pr_debug(" one=%-7d               defer=%d\n",
 	pstats->one, pstats->defer);
-  DEBUG(2, " lcar=%-7d              rtry=%d\n",
+  pr_debug(" lcar=%-7d              rtry=%d\n",
 	pstats->lcar, pstats->rtry);
 
   /* MACE_XMTRC */
-  DEBUG(2, " exdef=%-7d             xmtrc=%d\n",
+  pr_debug(" exdef=%-7d             xmtrc=%d\n",
 	pstats->exdef, pstats->xmtrc);
 
   /* RFS1--Receive Status (RCVSTS) */
-  DEBUG(2, " oflo=%-7d              clsn=%d\n",
+  pr_debug(" oflo=%-7d              clsn=%d\n",
 	pstats->oflo, pstats->clsn);
-  DEBUG(2, " fram=%-7d              fcs=%d\n",
+  pr_debug(" fram=%-7d              fcs=%d\n",
 	pstats->fram, pstats->fcs);
 
   /* RFS2--Runt Packet Count (RNTPC) */
   /* RFS3--Receive Collision Count (RCVCC) */
-  DEBUG(2, " rfs_rntpc=%-7d         rfs_rcvcc=%d\n",
+  pr_debug(" rfs_rntpc=%-7d         rfs_rcvcc=%d\n",
 	pstats->rfs_rntpc, pstats->rfs_rcvcc);
 
   /* MACE_IR */
-  DEBUG(2, " jab=%-7d               babl=%d\n",
+  pr_debug(" jab=%-7d               babl=%d\n",
 	pstats->jab, pstats->babl);
-  DEBUG(2, " cerr=%-7d              rcvcco=%d\n",
+  pr_debug(" cerr=%-7d              rcvcco=%d\n",
 	pstats->cerr, pstats->rcvcco);
-  DEBUG(2, " rntpco=%-7d            mpco=%d\n",
+  pr_debug(" rntpco=%-7d            mpco=%d\n",
 	pstats->rntpco, pstats->mpco);
 
   /* MACE_MPC */
-  DEBUG(2, " mpc=%d\n", pstats->mpc);
+  pr_debug(" mpc=%d\n", pstats->mpc);
 
   /* MACE_RNTPC */
-  DEBUG(2, " rntpc=%d\n", pstats->rntpc);
+  pr_debug(" rntpc=%d\n", pstats->rntpc);
 
   /* MACE_RCVCC */
-  DEBUG(2, " rcvcc=%d\n", pstats->rcvcc);
+  pr_debug(" rcvcc=%d\n", pstats->rcvcc);
 
 } /* pr_mace_stats */
 
@@ -1359,7 +1331,7 @@ static struct net_device_stats *mace_get_stats(struct net_device *dev)
 
   update_stats(dev->base_addr, dev);
 
-  DEBUG(1, "%s: updating the statistics.\n", dev->name);
+  pr_debug("%s: updating the statistics.\n", dev->name);
   pr_linux_stats(&lp->linux_stats);
   pr_mace_stats(&lp->mace_stats);
 
@@ -1426,7 +1398,7 @@ static void BuildLAF(int *ladrf, int *adr)
   ladrf[byte] |= (1 << (hashcode & 7));
 
 #ifdef PCMCIA_DEBUG
-  if (pc_debug > 2)
+  if (0)
     printk(KERN_DEBUG "    adr =%pM\n", adr);
   printk(KERN_DEBUG "    hashcode = %d(decimal), ladrf[0:63] =", hashcode);
   for (i = 0; i < 8; i++)
@@ -1453,12 +1425,12 @@ static void restore_multicast_list(struct net_device *dev)
   unsigned int ioaddr = dev->base_addr;
   int i;
 
-  DEBUG(2, "%s: restoring Rx mode to %d addresses.\n",
+  pr_debug("%s: restoring Rx mode to %d addresses.\n",
 	dev->name, num_addrs);
 
   if (num_addrs > 0) {
 
-    DEBUG(1, "Attempt to restore multicast list detected.\n");
+    pr_debug("Attempt to restore multicast list detected.\n");
 
     mace_write(lp, ioaddr, MACE_IAC, MACE_IAC_ADDRCHG | MACE_IAC_LOGADDR);
     /* Poll ADDRCHG bit */
@@ -1510,11 +1482,11 @@ static void set_multicast_list(struct net_device *dev)
   struct dev_mc_list *dmi = dev->mc_list;
 
 #ifdef PCMCIA_DEBUG
-  if (pc_debug > 1) {
+  {
     static int old;
     if (dev->mc_count != old) {
       old = dev->mc_count;
-      DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
+      pr_debug("%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
   }
@@ -1545,7 +1517,7 @@ static void restore_multicast_list(struct net_device *dev)
   unsigned int ioaddr = dev->base_addr;
   mace_private *lp = netdev_priv(dev);
 
-  DEBUG(2, "%s: restoring Rx mode to %d addresses.\n", dev->name,
+  pr_debug("%s: restoring Rx mode to %d addresses.\n", dev->name,
 	lp->multicast_num_addrs);
 
   if (dev->flags & IFF_PROMISC) {
@@ -1566,11 +1538,11 @@ static void set_multicast_list(struct net_device *dev)
   mace_private *lp = netdev_priv(dev);
 
 #ifdef PCMCIA_DEBUG
-  if (pc_debug > 1) {
+  {
     static int old;
     if (dev->mc_count != old) {
       old = dev->mc_count;
-      DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
+      pr_debug("%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
   }
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index bd3447f..80ab9de 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -71,15 +71,6 @@
 
 static const char *if_names[] = { "auto", "10baseT", "10base2"};
 
-#ifdef PCMCIA_DEBUG
-static int pc_debug = PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =
-"pcnet_cs.c 1.153 2003/11/09 18:53:09 (David Hinds)";
-#else
-#define DEBUG(n, args...)
-#endif
 
 /*====================================================================*/
 
@@ -265,7 +256,7 @@ static int pcnet_probe(struct pcmcia_device *link)
     pcnet_dev_t *info;
     struct net_device *dev;
 
-    DEBUG(0, "pcnet_attach()\n");
+    dev_dbg(&link->dev, "pcnet_attach()\n");
 
     /* Create new ethernet device */
     dev = __alloc_ei_netdev(sizeof(pcnet_dev_t));
@@ -297,7 +288,7 @@ static void pcnet_detach(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 
-	DEBUG(0, "pcnet_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "pcnet_detach\n");
 
 	if (link->dev_node)
 		unregister_netdev(dev);
@@ -327,10 +318,8 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != 0) {
-	cs_error(link, RequestWindow, i);
+    if (i != 0)
 	return NULL;
-    }
 
     virt = ioremap(req.Base, req.Size);
     mem.Page = 0;
@@ -349,8 +338,6 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 
     iounmap(virt);
     j = pcmcia_release_window(link->win);
-    if (j != 0)
-	cs_error(link, ReleaseWindow, j);
     return (i < NR_INFO) ? hw_info+i : NULL;
 } /* get_hwinfo */
 
@@ -495,9 +482,6 @@ static hw_info_t *get_hwired(struct pcmcia_device *link)
 
 ======================================================================*/
 
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
-
 static int try_io_port(struct pcmcia_device *link)
 {
     int j, ret;
@@ -567,19 +551,19 @@ static int pcnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     pcnet_dev_t *info = PRIV(dev);
-    int last_ret, last_fn, start_pg, stop_pg, cm_offset;
+    int ret, start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
     hw_info_t *local_hw_info;
 
-    DEBUG(0, "pcnet_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "pcnet_config\n");
 
-    last_ret = pcmcia_loop_config(link, pcnet_confcheck, &has_shmem);
-    if (last_ret) {
-	cs_error(link, RequestIO, last_ret);
+    ret = pcmcia_loop_config(link, pcnet_confcheck, &has_shmem);
+    if (ret)
 	goto failed;
-    }
 
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+    ret = pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
 
     if (link->io.NumPorts2 == 8) {
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
@@ -589,7 +573,9 @@ static int pcnet_config(struct pcmcia_device *link)
 	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
 	link->conf.ConfigIndex |= 0x10;
 
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
+    ret = pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
     if (info->flags & HAS_MISC_REG) {
@@ -687,8 +673,6 @@ static int pcnet_config(struct pcmcia_device *link)
     printk(" hw_addr %pM\n", dev->dev_addr);
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     pcnet_release(link);
     return -ENODEV;
@@ -706,7 +690,7 @@ static void pcnet_release(struct pcmcia_device *link)
 {
 	pcnet_dev_t *info = PRIV(link->priv);
 
-	DEBUG(0, "pcnet_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "pcnet_release\n");
 
 	if (info->flags & USE_SHMEM)
 		iounmap(info->base);
@@ -960,7 +944,7 @@ static void mii_phy_probe(struct net_device *dev)
 	phyid = tmp << 16;
 	phyid |= mdio_read(mii_addr, i, MII_PHYID_REG2);
 	phyid &= MII_PHYID_REV_MASK;
-	DEBUG(0, "%s: MII at %d is 0x%08x\n", dev->name, i, phyid);
+	pr_debug("%s: MII at %d is 0x%08x\n", dev->name, i, phyid);
 	if (phyid == AM79C9XX_HOME_PHY) {
 	    info->pna_phy = i;
 	} else if (phyid != AM79C9XX_ETH_PHY) {
@@ -976,7 +960,7 @@ static int pcnet_open(struct net_device *dev)
     struct pcmcia_device *link = info->p_dev;
     unsigned int nic_base = dev->base_addr;
 
-    DEBUG(2, "pcnet_open('%s')\n", dev->name);
+    dev_dbg(&link->dev, "pcnet_open('%s')\n", dev->name);
 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
@@ -1008,7 +992,7 @@ static int pcnet_close(struct net_device *dev)
     pcnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
 
-    DEBUG(2, "pcnet_close('%s')\n", dev->name);
+    dev_dbg(&link->dev, "pcnet_close('%s')\n", dev->name);
 
     ei_close(dev);
     free_irq(dev->irq, dev);
@@ -1251,10 +1235,8 @@ static void dma_block_input(struct net_device *dev, int count,
     int xfer_count = count;
     char *buf = skb->data;
 
-#ifdef PCMCIA_DEBUG
     if ((ei_debug > 4) && (count != 4))
-	printk(KERN_DEBUG "%s: [bi=%d]\n", dev->name, count+4);
-#endif
+	pr_debug("%s: [bi=%d]\n", dev->name, count+4);
     if (ei_status.dmaing) {
 	printk(KERN_NOTICE "%s: DMAing conflict in dma_block_input."
 	       "[DMAstat:%1x][irqlock:%1x]\n",
@@ -1495,7 +1477,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     pcnet_dev_t *info = PRIV(dev);
     win_req_t req;
     memreq_t mem;
-    int i, window_size, offset, last_ret, last_fn;
+    int i, window_size, offset, ret;
 
     window_size = (stop_pg - start_pg) << 8;
     if (window_size > 32 * 1024)
@@ -1509,13 +1491,17 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     req.Attributes |= WIN_USE_WAIT;
     req.Base = 0; req.Size = window_size;
     req.AccessSpeed = mem_speed;
-    CS_CHECK(RequestWindow, pcmcia_request_window(&link, &req, &link->win));
+    ret = pcmcia_request_window(&link, &req, &link->win);
+    if (ret)
+	    goto failed;
 
     mem.CardOffset = (start_pg << 8) + cm_offset;
     offset = mem.CardOffset % window_size;
     mem.CardOffset -= offset;
     mem.Page = 0;
-    CS_CHECK(MapMemPage, pcmcia_map_mem_page(link->win, &mem));
+    ret = pcmcia_map_mem_page(link->win, &mem);
+    if (ret)
+	    goto failed;
 
     /* Try scribbling on the buffer */
     info->base = ioremap(req.Base, window_size);
@@ -1549,8 +1535,6 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     info->flags |= USE_SHMEM;
     return 0;
 
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     return 1;
 }
@@ -1788,7 +1772,6 @@ static int __init init_pcnet_cs(void)
 
 static void __exit exit_pcnet_cs(void)
 {
-    DEBUG(0, "pcnet_cs: unloading\n");
     pcmcia_unregister_driver(&pcnet_driver);
 }
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index df92bcd..580ec44 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -79,14 +79,6 @@ MODULE_FIRMWARE(FIRMWARE_NAME);
 */
 INT_MODULE_PARM(if_port, 0);
 
-#ifdef PCMCIA_DEBUG
-INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
-static const char *version =
-"smc91c92_cs.c 1.123 2006/11/09 Donald Becker, becker@scyld.com.\n";
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-#else
-#define DEBUG(n, args...)
-#endif
 
 #define DRV_NAME	"smc91c92_cs"
 #define DRV_VERSION	"1.123"
@@ -323,7 +315,7 @@ static int smc91c92_probe(struct pcmcia_device *link)
     struct smc_private *smc;
     struct net_device *dev;
 
-    DEBUG(0, "smc91c92_attach()\n");
+    dev_dbg(&link->dev, "smc91c92_attach()\n");
 
     /* Create new ethernet device */
     dev = alloc_etherdev(sizeof(struct smc_private));
@@ -371,7 +363,7 @@ static void smc91c92_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "smc91c92_detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "smc91c92_detach\n");
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -746,7 +738,7 @@ static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
 	set_bits(0x300, link->io.BasePort1 + OSITECH_AUI_PWR);
 	/* Now, turn on the interrupt for both card functions */
 	set_bits(0x300, link->io.BasePort1 + OSITECH_RESET_ISR);
-	DEBUG(2, "AUI/PWR: %4.4x RESET/ISR: %4.4x\n",
+	dev_dbg(&link->dev, "AUI/PWR: %4.4x RESET/ISR: %4.4x\n",
 	      inw(link->io.BasePort1 + OSITECH_AUI_PWR),
 	      inw(link->io.BasePort1 + OSITECH_RESET_ISR));
     }
@@ -860,12 +852,6 @@ static int check_sig(struct pcmcia_device *link)
 
 ======================================================================*/
 
-#define CS_EXIT_TEST(ret, svc, label)	\
-if (ret != 0) {				\
-	cs_error(link, svc, ret);	\
-	goto label; 			\
-}
-
 static int smc91c92_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
@@ -875,7 +861,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     unsigned int ioaddr;
     u_long mir;
 
-    DEBUG(0, "smc91c92_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "smc91c92_config\n");
 
     smc->manfid = link->manf_id;
     smc->cardid = link->card_id;
@@ -891,12 +877,15 @@ static int smc91c92_config(struct pcmcia_device *link)
     } else {
 	i = smc_config(link);
     }
-    CS_EXIT_TEST(i, RequestIO, config_failed);
+    if (i)
+	    goto config_failed;
 
     i = pcmcia_request_irq(link, &link->irq);
-    CS_EXIT_TEST(i, RequestIRQ, config_failed);
+    if (i)
+	    goto config_failed;
     i = pcmcia_request_configuration(link, &link->conf);
-    CS_EXIT_TEST(i, RequestConfiguration, config_failed);
+    if (i)
+	    goto config_failed;
 
     if (smc->manfid == MANFID_MOTOROLA)
 	mot_config(link);
@@ -1001,7 +990,7 @@ static int smc91c92_config(struct pcmcia_device *link)
 
     if (smc->cfg & CFG_MII_SELECT) {
 	if (smc->mii_if.phy_id != -1) {
-	    DEBUG(0, "  MII transceiver at index %d, status %x.\n",
+	    dev_dbg(&link->dev, "  MII transceiver at index %d, status %x.\n",
 		  smc->mii_if.phy_id, j);
 	} else {
     	    printk(KERN_NOTICE "  No MII transceivers found!\n");
@@ -1011,7 +1000,7 @@ static int smc91c92_config(struct pcmcia_device *link)
 
 config_undo:
     unregister_netdev(dev);
-config_failed:			/* CS_EXIT_TEST() calls jump to here... */
+config_failed:
     smc91c92_release(link);
     return -ENODEV;
 } /* smc91c92_config */
@@ -1026,7 +1015,7 @@ config_failed:			/* CS_EXIT_TEST() calls jump to here... */
 
 static void smc91c92_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "smc91c92_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "smc91c92_release\n");
 	if (link->win) {
 		struct net_device *dev = link->priv;
 		struct smc_private *smc = netdev_priv(dev);
@@ -1123,10 +1112,10 @@ static int smc_open(struct net_device *dev)
     struct smc_private *smc = netdev_priv(dev);
     struct pcmcia_device *link = smc->p_dev;
 
-#ifdef PCMCIA_DEBUG
-    DEBUG(0, "%s: smc_open(%p), ID/Window %4.4x.\n",
+    dev_dbg(&link->dev, "%s: smc_open(%p), ID/Window %4.4x.\n",
 	  dev->name, dev, inw(dev->base_addr + BANK_SELECT));
-    if (pc_debug > 1) smc_dump(dev);
+#ifdef PCMCIA_DEBUG
+    smc_dump(dev);
 #endif
 
     /* Check that the PCMCIA card is still here. */
@@ -1161,7 +1150,7 @@ static int smc_close(struct net_device *dev)
     struct pcmcia_device *link = smc->p_dev;
     unsigned int ioaddr = dev->base_addr;
 
-    DEBUG(0, "%s: smc_close(), status %4.4x.\n",
+    dev_dbg(&link->dev, "%s: smc_close(), status %4.4x.\n",
 	  dev->name, inw(ioaddr + BANK_SELECT));
 
     netif_stop_queue(dev);
@@ -1228,7 +1217,7 @@ static void smc_hardware_send_packet(struct net_device * dev)
 	u_char *buf = skb->data;
 	u_int length = skb->len; /* The chip will pad to ethernet min. */
 
-	DEBUG(2, "%s: Trying to xmit packet of length %d.\n",
+	pr_debug("%s: Trying to xmit packet of length %d.\n",
 	      dev->name, length);
 	
 	/* send the packet length: +6 for status word, length, and ctl */
@@ -1283,7 +1272,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
 
     netif_stop_queue(dev);
 
-    DEBUG(2, "%s: smc_start_xmit(length = %d) called,"
+    pr_debug("%s: smc_start_xmit(length = %d) called,"
 	  " status %4.4x.\n", dev->name, skb->len, inw(ioaddr + 2));
 
     if (smc->saved_skb) {
@@ -1330,7 +1319,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
     }
 
     /* Otherwise defer until the Tx-space-allocated interrupt. */
-    DEBUG(2, "%s: memory allocation deferred.\n", dev->name);
+    pr_debug("%s: memory allocation deferred.\n", dev->name);
     outw((IM_ALLOC_INT << 8) | (ir & 0xff00), ioaddr + INTERRUPT);
     spin_unlock_irqrestore(&smc->lock, flags);
 
@@ -1395,7 +1384,7 @@ static void smc_eph_irq(struct net_device *dev)
 
     SMC_SELECT_BANK(0);
     ephs = inw(ioaddr + EPH);
-    DEBUG(2, "%s: Ethernet protocol handler interrupt, status"
+    pr_debug("%s: Ethernet protocol handler interrupt, status"
 	  " %4.4x.\n", dev->name, ephs);
     /* Could be a counter roll-over warning: update stats. */
     card_stats = inw(ioaddr + COUNTER);
@@ -1435,7 +1424,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
     ioaddr = dev->base_addr;
 
-    DEBUG(3, "%s: SMC91c92 interrupt %d at %#x.\n", dev->name,
+    pr_debug("%s: SMC91c92 interrupt %d at %#x.\n", dev->name,
 	  irq, ioaddr);
 
     spin_lock(&smc->lock);
@@ -1444,7 +1433,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
     if ((saved_bank & 0xff00) != 0x3300) {
 	/* The device does not exist -- the card could be off-line, or
 	   maybe it has been ejected. */
-	DEBUG(1, "%s: SMC91c92 interrupt %d for non-existent"
+	pr_debug("%s: SMC91c92 interrupt %d for non-existent"
 	      "/ejected device.\n", dev->name, irq);
 	handled = 0;
 	goto irq_done;
@@ -1458,7 +1447,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
     do { /* read the status flag, and mask it */
 	status = inw(ioaddr + INTERRUPT) & 0xff;
-	DEBUG(3, "%s: Status is %#2.2x (mask %#2.2x).\n", dev->name,
+	pr_debug("%s: Status is %#2.2x (mask %#2.2x).\n", dev->name,
 	      status, mask);
 	if ((status & mask) == 0) {
 	    if (bogus_cnt == INTR_WORK)
@@ -1503,7 +1492,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	    smc_eph_irq(dev);
     } while (--bogus_cnt);
 
-    DEBUG(3, "  Restoring saved registers mask %2.2x bank %4.4x"
+    pr_debug("  Restoring saved registers mask %2.2x bank %4.4x"
 	  " pointer %4.4x.\n", mask, saved_bank, saved_pointer);
 
     /* restore state register */
@@ -1511,7 +1500,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
     outw(saved_pointer, ioaddr + POINTER);
     SMC_SELECT_BANK(saved_bank);
 
-    DEBUG(3, "%s: Exiting interrupt IRQ%d.\n", dev->name, irq);
+    pr_debug("%s: Exiting interrupt IRQ%d.\n", dev->name, irq);
 
 irq_done:
 
@@ -1562,7 +1551,7 @@ static void smc_rx(struct net_device *dev)
     rx_status = inw(ioaddr + DATA_1);
     packet_length = inw(ioaddr + DATA_1) & 0x07ff;
 
-    DEBUG(2, "%s: Receive status %4.4x length %d.\n",
+    pr_debug("%s: Receive status %4.4x length %d.\n",
 	  dev->name, rx_status, packet_length);
 
     if (!(rx_status & RS_ERRORS)) {		
@@ -1573,7 +1562,7 @@ static void smc_rx(struct net_device *dev)
 	skb = dev_alloc_skb(packet_length+2);
 	
 	if (skb == NULL) {
-	    DEBUG(1, "%s: Low memory, packet dropped.\n", dev->name);
+	    pr_debug("%s: Low memory, packet dropped.\n", dev->name);
 	    dev->stats.rx_dropped++;
 	    outw(MC_RELEASE, ioaddr + MMU_CMD);
 	    return;
@@ -1733,7 +1722,7 @@ static void smc_reset(struct net_device *dev)
     struct smc_private *smc = netdev_priv(dev);
     int i;
 
-    DEBUG(0, "%s: smc91c92 reset called.\n", dev->name);
+    pr_debug("%s: smc91c92 reset called.\n", dev->name);
 
     /* The first interaction must be a write to bring the chip out
        of sleep mode. */
@@ -2050,18 +2039,6 @@ static u32 smc_get_link(struct net_device *dev)
 	return ret;
 }
 
-#ifdef PCMCIA_DEBUG
-static u32 smc_get_msglevel(struct net_device *dev)
-{
-	return pc_debug;
-}
-
-static void smc_set_msglevel(struct net_device *dev, u32 val)
-{
-	pc_debug = val;
-}
-#endif
-
 static int smc_nway_reset(struct net_device *dev)
 {
 	struct smc_private *smc = netdev_priv(dev);
@@ -2085,10 +2062,6 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_settings = smc_get_settings,
 	.set_settings = smc_set_settings,
 	.get_link = smc_get_link,
-#ifdef PCMCIA_DEBUG
-	.get_msglevel = smc_get_msglevel,
-	.set_msglevel = smc_set_msglevel,
-#endif
 	.nway_reset = smc_nway_reset,
 };
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 8ed8449..132a528 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -211,20 +211,6 @@ enum xirc_cmd { 	    /* Commands */
 
 static const char *if_names[] = { "Auto", "10BaseT", "10Base2", "AUI", "100BaseT" };
 
-/****************
- * All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
- * you do not define PCMCIA_DEBUG at all, all the debug code will be
- * left out.  If you compile with PCMCIA_DEBUG=0, the debug code will
- * be present but disabled -- but it can then be enabled for specific
- * modules at load time with a 'pc_debug=#' option to insmod.
- */
-#ifdef PCMCIA_DEBUG
-static int pc_debug = PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KDBG_XIRC args)
-#else
-#define DEBUG(n, args...)
-#endif
 
 #define KDBG_XIRC KERN_DEBUG   "xirc2ps_cs: "
 #define KERR_XIRC KERN_ERR     "xirc2ps_cs: "
@@ -378,7 +364,7 @@ static int do_stop(struct net_device *dev);
 #define PutWord(reg,value) outw((value), ioaddr+(reg))
 
 /*====== Functions used for debugging =================================*/
-#if defined(PCMCIA_DEBUG) && 0 /* reading regs may change system status */
+#if 0 /* reading regs may change system status */
 static void
 PrintRegisters(struct net_device *dev)
 {
@@ -410,7 +396,7 @@ PrintRegisters(struct net_device *dev)
 	}
     }
 }
-#endif /* PCMCIA_DEBUG */
+#endif /* 0 */
 
 /*============== MII Management functions ===============*/
 
@@ -554,7 +540,7 @@ xirc2ps_probe(struct pcmcia_device *link)
     struct net_device *dev;
     local_info_t *local;
 
-    DEBUG(0, "attach()\n");
+    dev_dbg(&link->dev, "attach()\n");
 
     /* Allocate the device structure */
     dev = alloc_etherdev(sizeof(local_info_t));
@@ -593,7 +579,7 @@ xirc2ps_detach(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
 
-    DEBUG(0, "detach(0x%p)\n", link);
+    dev_dbg(&link->dev, "detach\n");
 
     if (link->dev_node)
 	unregister_netdev(dev);
@@ -626,13 +612,11 @@ set_card_type(struct pcmcia_device *link, const void *s)
 {
     struct net_device *dev = link->priv;
     local_info_t *local = netdev_priv(dev);
-  #ifdef PCMCIA_DEBUG
     unsigned cisrev = ((const unsigned char *)s)[2];
-  #endif
     unsigned mediaid= ((const unsigned char *)s)[3];
     unsigned prodid = ((const unsigned char *)s)[4];
 
-    DEBUG(0, "cisrev=%02x mediaid=%02x prodid=%02x\n",
+    dev_dbg(&link->dev, "cisrev=%02x mediaid=%02x prodid=%02x\n",
 	  cisrev, mediaid, prodid);
 
     local->mohawk = 0;
@@ -778,7 +762,7 @@ xirc2ps_config(struct pcmcia_device * link)
 
     local->dingo_ccr = NULL;
 
-    DEBUG(0, "config(0x%p)\n", link);
+    dev_dbg(&link->dev, "config\n");
 
     /*
      * This reads the card's CONFIG tuple to find its configuration
@@ -817,7 +801,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	       (unsigned)parse.manfid.manf);
 	goto failure;
     }
-    DEBUG(0, "found %s card\n", local->manf_str);
+    dev_dbg(&link->dev, "found %s card\n", local->manf_str);
 
     if (!set_card_type(link, buf)) {
 	printk(KNOT_XIRC "this card is not supported\n");
@@ -892,10 +876,8 @@ xirc2ps_config(struct pcmcia_device * link)
 		goto port_found;
 	}
 	link->io.BasePort1 = 0; /* let CS decide */
-	if ((err=pcmcia_request_io(link, &link->io))) {
-	    cs_error(link, RequestIO, err);
+	if ((err=pcmcia_request_io(link, &link->io)))
 	    goto config_error;
-	}
     }
   port_found:
     if (err)
@@ -905,19 +887,15 @@ xirc2ps_config(struct pcmcia_device * link)
      * Now allocate an interrupt line.	Note that this does not
      * actually assign a handler to the interrupt.
      */
-    if ((err=pcmcia_request_irq(link, &link->irq))) {
-	cs_error(link, RequestIRQ, err);
+    if ((err=pcmcia_request_irq(link, &link->irq)))
 	goto config_error;
-    }
 
     /****************
      * This actually configures the PCMCIA socket -- setting up
      * the I/O windows and the interrupt mapping.
      */
-    if ((err=pcmcia_request_configuration(link, &link->conf))) {
-	cs_error(link, RequestConfiguration, err);
+    if ((err=pcmcia_request_configuration(link, &link->conf)))
 	goto config_error;
-    }
 
     if (local->dingo) {
 	conf_reg_t reg;
@@ -932,17 +910,13 @@ xirc2ps_config(struct pcmcia_device * link)
 	reg.Action = CS_WRITE;
 	reg.Offset = CISREG_IOBASE_0;
 	reg.Value = link->io.BasePort2 & 0xff;
-	if ((err = pcmcia_access_configuration_register(link, &reg))) {
-	    cs_error(link, AccessConfigurationRegister, err);
+	if ((err = pcmcia_access_configuration_register(link, &reg)))
 	    goto config_error;
-	}
 	reg.Action = CS_WRITE;
 	reg.Offset = CISREG_IOBASE_1;
 	reg.Value = (link->io.BasePort2 >> 8) & 0xff;
-	if ((err = pcmcia_access_configuration_register(link, &reg))) {
-	    cs_error(link, AccessConfigurationRegister, err);
+	if ((err = pcmcia_access_configuration_register(link, &reg)))
 	    goto config_error;
-	}
 
 	/* There is no config entry for the Ethernet part which
 	 * is at 0x0800. So we allocate a window into the attribute
@@ -951,17 +925,14 @@ xirc2ps_config(struct pcmcia_device * link)
 	req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
 	req.Base = req.Size = 0;
 	req.AccessSpeed = 0;
-	if ((err = pcmcia_request_window(&link, &req, &link->win))) {
-	    cs_error(link, RequestWindow, err);
+	if ((err = pcmcia_request_window(&link, &req, &link->win)))
 	    goto config_error;
-	}
+
 	local->dingo_ccr = ioremap(req.Base,0x1000) + 0x0800;
 	mem.CardOffset = 0x0;
 	mem.Page = 0;
-	if ((err = pcmcia_map_mem_page(link->win, &mem))) {
-	    cs_error(link, MapMemPage, err);
+	if ((err = pcmcia_map_mem_page(link->win, &mem)))
 	    goto config_error;
-	}
 
 	/* Setup the CCRs; there are no infos in the CIS about the Ethernet
 	 * part.
@@ -1053,7 +1024,7 @@ xirc2ps_config(struct pcmcia_device * link)
 static void
 xirc2ps_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "release(0x%p)\n", link);
+	dev_dbg(&link->dev, "release\n");
 
 	if (link->win) {
 		struct net_device *dev = link->priv;
@@ -1120,7 +1091,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	PutByte(XIRCREG_CR, 0);
     }
 
-    DEBUG(6, "%s: interrupt %d at %#x.\n", dev->name, irq, ioaddr);
+    pr_debug("%s: interrupt %d at %#x.\n", dev->name, irq, ioaddr);
 
     saved_page = GetByte(XIRCREG_PR);
     /* Read the ISR to see whats the cause for the interrupt.
@@ -1130,7 +1101,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
     bytes_rcvd = 0;
   loop_entry:
     if (int_status == 0xff) { /* card may be ejected */
-	DEBUG(3, "%s: interrupt %d for dead card\n", dev->name, irq);
+	pr_debug("%s: interrupt %d for dead card\n", dev->name, irq);
 	goto leave;
     }
     eth_status = GetByte(XIRCREG_ESR);
@@ -1143,7 +1114,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
     PutByte(XIRCREG40_TXST0, 0);
     PutByte(XIRCREG40_TXST1, 0);
 
-    DEBUG(3, "%s: ISR=%#2.2x ESR=%#2.2x RSR=%#2.2x TSR=%#4.4x\n",
+    pr_debug("%s: ISR=%#2.2x ESR=%#2.2x RSR=%#2.2x TSR=%#4.4x\n",
 	  dev->name, int_status, eth_status, rx_status, tx_status);
 
     /***** receive section ******/
@@ -1154,14 +1125,14 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	    /* too many bytes received during this int, drop the rest of the
 	     * packets */
 	    dev->stats.rx_dropped++;
-	    DEBUG(2, "%s: RX drop, too much done\n", dev->name);
+	    pr_debug("%s: RX drop, too much done\n", dev->name);
 	} else if (rsr & PktRxOk) {
 	    struct sk_buff *skb;
 
 	    pktlen = GetWord(XIRCREG0_RBC);
 	    bytes_rcvd += pktlen;
 
-	    DEBUG(5, "rsr=%#02x packet_length=%u\n", rsr, pktlen);
+	    pr_debug("rsr=%#02x packet_length=%u\n", rsr, pktlen);
 
 	    skb = dev_alloc_skb(pktlen+3); /* 1 extra so we can use insw */
 	    if (!skb) {
@@ -1229,19 +1200,19 @@ xirc2ps_interrupt(int irq, void *dev_id)
 		    dev->stats.multicast++;
 	    }
 	} else { /* bad packet */
-	    DEBUG(5, "rsr=%#02x\n", rsr);
+	    pr_debug("rsr=%#02x\n", rsr);
 	}
 	if (rsr & PktTooLong) {
 	    dev->stats.rx_frame_errors++;
-	    DEBUG(3, "%s: Packet too long\n", dev->name);
+	    pr_debug("%s: Packet too long\n", dev->name);
 	}
 	if (rsr & CRCErr) {
 	    dev->stats.rx_crc_errors++;
-	    DEBUG(3, "%s: CRC error\n", dev->name);
+	    pr_debug("%s: CRC error\n", dev->name);
 	}
 	if (rsr & AlignErr) {
 	    dev->stats.rx_fifo_errors++; /* okay ? */
-	    DEBUG(3, "%s: Alignment error\n", dev->name);
+	    pr_debug("%s: Alignment error\n", dev->name);
 	}
 
 	/* clear the received/dropped/error packet */
@@ -1253,7 +1224,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
     if (rx_status & 0x10) { /* Receive overrun */
 	dev->stats.rx_over_errors++;
 	PutByte(XIRCREG_CR, ClearRxOvrun);
-	DEBUG(3, "receive overrun cleared\n");
+	pr_debug("receive overrun cleared\n");
     }
 
     /***** transmit section ******/
@@ -1266,13 +1237,13 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	if (nn < n) /* rollover */
 	    dev->stats.tx_packets += 256 - n;
 	else if (n == nn) { /* happens sometimes - don't know why */
-	    DEBUG(0, "PTR not changed?\n");
+	    pr_debug("PTR not changed?\n");
 	} else
 	    dev->stats.tx_packets += lp->last_ptr_value - n;
 	netif_wake_queue(dev);
     }
     if (tx_status & 0x0002) {	/* Execessive collissions */
-	DEBUG(0, "tx restarted due to execssive collissions\n");
+	pr_debug("tx restarted due to execssive collissions\n");
 	PutByte(XIRCREG_CR, RestartTx);  /* restart transmitter process */
     }
     if (tx_status & 0x0040)
@@ -1291,14 +1262,14 @@ xirc2ps_interrupt(int irq, void *dev_id)
 		maxrx_bytes = 2000;
 	    else if (maxrx_bytes > 22000)
 		maxrx_bytes = 22000;
-	    DEBUG(1, "set maxrx=%u (rcvd=%u ticks=%lu)\n",
+	    pr_debug("set maxrx=%u (rcvd=%u ticks=%lu)\n",
 		  maxrx_bytes, bytes_rcvd, duration);
 	} else if (!duration && maxrx_bytes < 22000) {
 	    /* now much faster */
 	    maxrx_bytes += 2000;
 	    if (maxrx_bytes > 22000)
 		maxrx_bytes = 22000;
-	    DEBUG(1, "set maxrx=%u\n", maxrx_bytes);
+	    pr_debug("set maxrx=%u\n", maxrx_bytes);
 	}
     }
 
@@ -1348,7 +1319,7 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     unsigned freespace;
     unsigned pktlen = skb->len;
 
-    DEBUG(1, "do_start_xmit(skb=%p, dev=%p) len=%u\n",
+    pr_debug("do_start_xmit(skb=%p, dev=%p) len=%u\n",
 	  skb, dev, pktlen);
 
 
@@ -1374,7 +1345,7 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     freespace &= 0x7fff;
     /* TRS doesn't work - (indeed it is eliminated with sil-rev 1) */
     okay = pktlen +2 < freespace;
-    DEBUG(2 + (okay ? 2 : 0), "%s: avail. tx space=%u%s\n",
+    pr_debug("%s: avail. tx space=%u%s\n",
 	  dev->name, freespace, okay ? " (okay)":" (not enough)");
     if (!okay) { /* not enough space */
 	return NETDEV_TX_BUSY;  /* upper layer may decide to requeue this packet */
@@ -1476,7 +1447,7 @@ do_config(struct net_device *dev, struct ifmap *map)
 {
     local_info_t *local = netdev_priv(dev);
 
-    DEBUG(0, "do_config(%p)\n", dev);
+    pr_debug("do_config(%p)\n", dev);
     if (map->port != 255 && map->port != dev->if_port) {
 	if (map->port > 4)
 	    return -EINVAL;
@@ -1503,7 +1474,7 @@ do_open(struct net_device *dev)
     local_info_t *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
-    DEBUG(0, "do_open(%p)\n", dev);
+    dev_dbg(&link->dev, "do_open(%p)\n", dev);
 
     /* Check that the PCMCIA card is still here. */
     /* Physical device present signature. */
@@ -1537,7 +1508,7 @@ do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
     unsigned int ioaddr = dev->base_addr;
     struct mii_ioctl_data *data = if_mii(rq);
 
-    DEBUG(1, "%s: ioctl(%-.6s, %#04x) %04x %04x %04x %04x\n",
+    pr_debug("%s: ioctl(%-.6s, %#04x) %04x %04x %04x %04x\n",
 	  dev->name, rq->ifr_ifrn.ifrn_name, cmd,
 	  data->phy_id, data->reg_num, data->val_in, data->val_out);
 
@@ -1586,7 +1557,7 @@ do_reset(struct net_device *dev, int full)
     unsigned int ioaddr = dev->base_addr;
     unsigned value;
 
-    DEBUG(0, "%s: do_reset(%p,%d)\n", dev? dev->name:"eth?", dev, full);
+    pr_debug("%s: do_reset(%p,%d)\n", dev? dev->name:"eth?", dev, full);
 
     hardreset(dev);
     PutByte(XIRCREG_CR, SoftReset); /* set */
@@ -1624,8 +1595,8 @@ do_reset(struct net_device *dev, int full)
     }
     msleep(40);			     /* wait 40 msec to let it complete */
 
-  #ifdef PCMCIA_DEBUG
-    if (pc_debug) {
+  #if 0
+    {
 	SelectPage(0);
 	value = GetByte(XIRCREG_ESR);	 /* read the ESR */
 	printk(KERN_DEBUG "%s: ESR is: %#02x\n", dev->name, value);
@@ -1642,7 +1613,7 @@ do_reset(struct net_device *dev, int full)
 	value |= DisableLinkPulse;
     PutByte(XIRCREG1_ECR, value);
   #endif
-    DEBUG(0, "%s: ECR is: %#02x\n", dev->name, value);
+    pr_debug("%s: ECR is: %#02x\n", dev->name, value);
 
     SelectPage(0x42);
     PutByte(XIRCREG42_SWC0, 0x20); /* disable source insertion */
@@ -1820,7 +1791,7 @@ do_powerdown(struct net_device *dev)
 
     unsigned int ioaddr = dev->base_addr;
 
-    DEBUG(0, "do_powerdown(%p)\n", dev);
+    pr_debug("do_powerdown(%p)\n", dev);
 
     SelectPage(4);
     PutByte(XIRCREG4_GPR1, 0);	     /* clear bit 0: power down */
@@ -1834,7 +1805,7 @@ do_stop(struct net_device *dev)
     local_info_t *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
-    DEBUG(0, "do_stop(%p)\n", dev);
+    dev_dbg(&link->dev, "do_stop(%p)\n", dev);
 
     if (!link)
 	return -ENODEV;
-- 
1.6.0.4

