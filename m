From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) skfddi: netdev_priv and cast cleanup
Date: Tue, 11 Jan 2005 11:21:43 -0800
Message-ID: <20050111112143.64d56c78@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv() and get rid of the PRIV() macro by using the correct
data element. Also eliminate casts, where type is correct.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	2004-12-14 11:07:42 -08:00
+++ b/drivers/net/skfp/skfddi.c	2004-12-14 11:07:42 -08:00
@@ -169,8 +169,6 @@
 #define PRINTK(s, args...)
 #endif				// DRIVERDEBUG
 
-#define PRIV(dev) (&(((struct s_smc *)dev->priv)->os))
-
 /*
  * =================
  * = skfp_init_one =
@@ -269,7 +267,7 @@
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Initialize board structure with bus-specific info */
-	smc = (struct s_smc *) dev->priv;
+	smc = netdev_priv(dev);
 	smc->os.dev = dev;
 	smc->os.bus_type = SK_BUS_TYPE_PCI;
 	smc->os.pdev = *pdev;
@@ -331,7 +329,7 @@
 static void __devexit skfp_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *p = pci_get_drvdata(pdev);
-	struct s_smc *lp = p->priv;
+	struct s_smc *lp = netdev_priv(p);
 
 	unregister_netdev(p);
 
@@ -388,8 +386,8 @@
  */
 static  int skfp_driver_init(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 	int err = -EIO;
 
 	PRINTK(KERN_INFO "entering skfp_driver_init\n");
@@ -495,7 +493,7 @@
  */
 static int skfp_open(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	int err;
 
 	PRINTK(KERN_INFO "entering skfp_open\n");
@@ -562,8 +560,8 @@
  */
 static int skfp_close(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 
 	CLI_FBI();
 	smt_reset_defaults(smc, 1);
@@ -622,15 +620,15 @@
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct s_smc *smc;	/* private board structure pointer */
-	skfddi_priv *bp = PRIV(dev);
-
+	skfddi_priv *bp;
 
 	if (dev == NULL) {
 		printk("%s: irq %d for unknown device\n", dev->name, irq);
 		return IRQ_NONE;
 	}
 
-	smc = (struct s_smc *) dev->priv;
+	smc = netdev_priv(dev);
+	bp = &smc->os;
 
 	// IRQs enabled or disabled ?
 	if (inpd(ADDR(B0_IMSK)) == 0) {
@@ -692,7 +690,7 @@
  */
 struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
 {
-	struct s_smc *bp = (struct s_smc *) dev->priv;
+	struct s_smc *bp = netdev_priv(dev);
 
 	/* Fill the bp->stats structure with driver-maintained counters */
 
@@ -856,7 +854,8 @@
  */
 static void skfp_ctl_set_multicast_list(struct net_device *dev)
 {
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 	unsigned long Flags;
 
 	spin_lock_irqsave(&bp->DriverLock, Flags);
@@ -869,7 +868,7 @@
 
 static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	struct dev_mc_list *dmi;	/* ptr to multicast addr entry */
 	int i;
 
@@ -952,9 +951,9 @@
  */
 static int skfp_ctl_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	struct sockaddr *p_sockaddr = (struct sockaddr *) addr;
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	unsigned long Flags;
 
 
@@ -992,12 +991,14 @@
 
 static int skfp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	skfddi_priv *lp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *lp = &smc->os;
 	struct s_skfp_ioctl ioc;
 	int status = 0;
 
 	if (copy_from_user(&ioc, rq->ifr_data, sizeof(struct s_skfp_ioctl)))
 		return -EFAULT;
+
 	switch (ioc.cmd) {
 	case SKFP_GET_STATS:	/* Get the driver statistics */
 		ioc.len = sizeof(lp->MacStat);
@@ -1070,7 +1071,8 @@
  */
 static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 {
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 
 	PRINTK(KERN_INFO "skfp_send_pkt\n");
 
@@ -1097,7 +1099,7 @@
 	}
 	bp->QueueSkb--;
 	skb_queue_tail(&bp->SendSkbQueue, skb);
-	send_queued_packets((struct s_smc *) dev->priv);
+	send_queued_packets(netdev_priv(dev));
 	if (bp->QueueSkb == 0) {
 		netif_stop_queue(dev);
 	}
@@ -1132,7 +1134,7 @@
  */
 static void send_queued_packets(struct s_smc *smc)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	struct sk_buff *skb;
 	unsigned char fc;
 	int queue;
@@ -1304,7 +1306,7 @@
  ************************/
 void llc_restart_tx(struct s_smc *smc)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 
 	PRINTK(KERN_INFO "[llc_restart_tx]\n");
 
@@ -1488,7 +1490,7 @@
 	 * unmap first, the hardware module could read inconsistent data.
 	 */
 	if (flag & DMA_WR) {
-		skfddi_priv *bp = (skfddi_priv *) & smc->os;
+		skfddi_priv *bp = &smc->os;
 		volatile struct s_smt_fp_rxd *r = &descr->r;
 
 		/* If SKB is NULL, we used the local buffer. */
@@ -1602,7 +1604,7 @@
 void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 			 int frag_count, int len)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	struct sk_buff *skb;
 	unsigned char *virt, *cp;
 	unsigned short ri;
@@ -1734,7 +1736,7 @@
 
 		printk("fddi: Multi-fragment requeue!\n");
 
-	MaxFrameSize = ((skfddi_priv *) & smc->os)->MaxFrameSize;
+	MaxFrameSize = smc->os.MaxFrameSize;
 	src_rxd = rxd;
 	for (; frag_count > 0; frag_count--) {
 		next_rxd = src_rxd->rxd_next;
@@ -1810,7 +1812,7 @@
 	// Walk through the list of free receive buffers, passing receive
 	// buffers to the HWM as long as RXDs are available.
 
-	MaxFrameSize = ((skfddi_priv *) & smc->os)->MaxFrameSize;
+	MaxFrameSize = smc->os.MaxFrameSize;
 	// Check if there is any RXD left.
 	while (HWM_GET_RX_FREE(smc) > 0) {
 		PRINTK(KERN_INFO ".\n");
@@ -1879,7 +1881,7 @@
 	for (; frag_count > 0; frag_count--) {
 		skb = rxd->rxd_os.skb;
 		if (skb != NULL) {
-			skfddi_priv *bp = (skfddi_priv *) & smc->os;
+			skfddi_priv *bp = &smc->os;
 			int MaxFrameSize = bp->MaxFrameSize;
 
 			pci_unmap_single(&bp->pdev, rxd->rxd_os.dma_addr,
@@ -1946,7 +1948,7 @@
 	memcpy(skb->data, look_ahead, len);
 
 	// deliver frame to system
-	skb->protocol = fddi_type_trans(skb, ((skfddi_priv *) & smc->os)->dev);
+	skb->protocol = fddi_type_trans(skb, smc->os.dev);
 	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 
