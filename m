From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] netdevice lance: Convert directly reference of netdev->priv
Date: Wed, 19 Nov 2008 10:11:05 +0800
Message-ID: <492375B9.8020807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64236 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbYKSCL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 21:11:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to kill directly reference of netdev->priv too.
Because the private data should be allocated in DMA area, alloc_etherdev()
can't satisfy this needs.
Use netdev->ml_priv to point to lance_private.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/lance.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index f63789a..e81b611 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -359,7 +359,7 @@ int __init init_module(void)
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	if (dev->dma != 4)
 		free_dma(dev->dma);
 	release_region(dev->base_addr, LANCE_TOTAL_SIZE);
@@ -418,7 +418,7 @@ static int __init do_lance_probe(struct net_device *dev)
 			if (card < NUM_CARDS) { /*Signature OK*/
 				result = lance_probe1(dev, ioaddr, 0, 0);
 				if (!result) {
-					struct lance_private *lp = dev->priv;
+					struct lance_private *lp = dev->ml_priv;
 					int ver = lp->chip_version;
 
 					r->name = chip_table[ver].name;
@@ -537,7 +537,7 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 	if(lp==NULL)
 		return -ENODEV;
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
-	dev->priv = lp;
+	dev->ml_priv = lp;
 	lp->name = chipname;
 	lp->rx_buffs = (unsigned long)kmalloc(PKT_BUF_SZ*RX_RING_SIZE,
 						  GFP_DMA | GFP_KERNEL);
@@ -741,7 +741,7 @@ out_lp:
 static int
 lance_open(struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	int ioaddr = dev->base_addr;
 	int i;
 
@@ -829,7 +829,7 @@ lance_open(struct net_device *dev)
 static void
 lance_purge_ring(struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	int i;
 
 	/* Free all the skbuffs in the Rx and Tx queues. */
@@ -853,7 +853,7 @@ lance_purge_ring(struct net_device *dev)
 static void
 lance_init_ring(struct net_device *dev, gfp_t gfp)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	int i;
 
 	lp->cur_rx = lp->cur_tx = 0;
@@ -895,7 +895,7 @@ lance_init_ring(struct net_device *dev, gfp_t gfp)
 static void
 lance_restart(struct net_device *dev, unsigned int csr0_bits, int must_reinit)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 
 	if (must_reinit ||
 		(chip_table[lp->chip_version].flags & LANCE_MUST_REINIT_RING)) {
@@ -909,7 +909,7 @@ lance_restart(struct net_device *dev, unsigned int csr0_bits, int must_reinit)
 
 static void lance_tx_timeout (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = (struct lance_private *) dev->ml_priv;
 	int ioaddr = dev->base_addr;
 
 	outw (0, ioaddr + LANCE_ADDR);
@@ -943,7 +943,7 @@ static void lance_tx_timeout (struct net_device *dev)
 
 static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	int ioaddr = dev->base_addr;
 	int entry;
 	unsigned long flags;
@@ -1020,7 +1020,7 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 	int must_restart;
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = dev->ml_priv;
 
 	spin_lock (&lp->devlock);
 
@@ -1133,7 +1133,7 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 static int
 lance_rx(struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 	int entry = lp->cur_rx & RX_RING_MOD_MASK;
 	int i;
 
@@ -1211,7 +1211,7 @@ static int
 lance_close(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 
 	netif_stop_queue (dev);
 
@@ -1244,7 +1244,7 @@ lance_close(struct net_device *dev)
 
 static struct net_device_stats *lance_get_stats(struct net_device *dev)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = dev->ml_priv;
 
 	if (chip_table[lp->chip_version].flags & LANCE_HAS_MISSED_FRAME) {
 		short ioaddr = dev->base_addr;
-- 
1.5.3.4

