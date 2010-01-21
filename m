From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH 1/3] fs_enet: use dev_xxx instead of printk
Date: Thu, 21 Jan 2010 03:13:17 +0100
Message-ID: <1264039999-25731-2-git-send-email-agust@denx.de>
References: <1264039999-25731-1-git-send-email-agust@denx.de>
Cc: dzu@denx.de, wd@denx.de, Anatolij Gustschin <agust@denx.de>,
	<linuxppc-dev@ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33392 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab0AUCNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 21:13:21 -0500
In-Reply-To: <1264039999-25731-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: <linuxppc-dev@ozlabs.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
Cc: Piotr Ziecik <kosmo@semihalf.com>
Cc: Wolfgang Denk <wd@denx.de>
---
 drivers/net/fs_enet/fs_enet-main.c |   39 +++++++++++++----------------------
 drivers/net/fs_enet/mac-fcc.c      |    5 ++-
 drivers/net/fs_enet/mac-fec.c      |   12 ++++------
 drivers/net/fs_enet/mac-scc.c      |    9 +++----
 4 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index ec2f503..c34a7e0 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -108,9 +108,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 		 * the last indicator should be set.
 		 */
 		if ((sc & BD_ENET_RX_LAST) == 0)
-			printk(KERN_WARNING DRV_MODULE_NAME
-			       ": %s rcv is not +last\n",
-			       dev->name);
+			dev_warn(fep->dev, "rcv is not +last\n");
 
 		/*
 		 * Check for errors.
@@ -178,9 +176,8 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 				received++;
 				netif_receive_skb(skb);
 			} else {
-				printk(KERN_WARNING DRV_MODULE_NAME
-				       ": %s Memory squeeze, dropping packet.\n",
-				       dev->name);
+				dev_warn(fep->dev,
+					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
@@ -242,9 +239,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 		 * the last indicator should be set.
 		 */
 		if ((sc & BD_ENET_RX_LAST) == 0)
-			printk(KERN_WARNING DRV_MODULE_NAME
-			       ": %s rcv is not +last\n",
-			       dev->name);
+			dev_warn(fep->dev, "rcv is not +last\n");
 
 		/*
 		 * Check for errors.
@@ -313,9 +308,8 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				received++;
 				netif_rx(skb);
 			} else {
-				printk(KERN_WARNING DRV_MODULE_NAME
-				       ": %s Memory squeeze, dropping packet.\n",
-				       dev->name);
+				dev_warn(fep->dev,
+					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
@@ -388,10 +382,10 @@ static void fs_enet_tx(struct net_device *dev)
 		} else
 			fep->stats.tx_packets++;
 
-		if (sc & BD_ENET_TX_READY)
-			printk(KERN_WARNING DRV_MODULE_NAME
-			       ": %s HEY! Enet xmit interrupt and TX_READY.\n",
-			       dev->name);
+		if (sc & BD_ENET_TX_READY) {
+			dev_warn(fep->dev,
+				 "HEY! Enet xmit interrupt and TX_READY.\n");
+		}
 
 		/*
 		 * Deferred means some collisions occurred during transmit,
@@ -511,9 +505,8 @@ void fs_init_bds(struct net_device *dev)
 	for (i = 0, bdp = fep->rx_bd_base; i < fep->rx_ring; i++, bdp++) {
 		skb = dev_alloc_skb(ENET_RX_FRSIZE);
 		if (skb == NULL) {
-			printk(KERN_WARNING DRV_MODULE_NAME
-			       ": %s Memory squeeze, unable to allocate skb\n",
-			       dev->name);
+			dev_warn(fep->dev,
+				 "Memory squeeze, unable to allocate skb\n");
 			break;
 		}
 		skb_align(skb, ENET_RX_ALIGN);
@@ -610,8 +603,7 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Ooops.  All transmit buffers are full.  Bail out.
 		 * This should not happen, since the tx queue should be stopped.
 		 */
-		printk(KERN_WARNING DRV_MODULE_NAME
-		       ": %s tx queue full!.\n", dev->name);
+		dev_warn(fep->dev, "tx queue full!.\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -788,8 +780,7 @@ static int fs_enet_open(struct net_device *dev)
 	r = request_irq(fep->interrupt, fs_enet_interrupt, IRQF_SHARED,
 			"fs_enet-mac", dev);
 	if (r != 0) {
-		printk(KERN_ERR DRV_MODULE_NAME
-		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
+		dev_err(fep->dev, "Could not allocate FS_ENET IRQ!");
 		if (fep->fpi->use_napi)
 			napi_disable(&fep->napi);
 		return -EINVAL;
@@ -1053,7 +1044,7 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	if (ret)
 		goto out_free_bd;
 
-	printk(KERN_INFO "%s: fs_enet: %pM\n", ndev->name, ndev->dev_addr);
+	pr_info("%s: fs_enet: %pM\n", ndev->name, ndev->dev_addr);
 
 	return 0;
 
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 22e5a84..dd78640 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -476,8 +476,9 @@ static void clear_int_events(struct net_device *dev, u32 int_events)
 
 static void ev_error(struct net_device *dev, u32 int_events)
 {
-	printk(KERN_WARNING DRV_MODULE_NAME
-	       ": %s FS_ENET ERROR(s) 0x%x\n", dev->name, int_events);
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	dev_warn(fep->dev, "FS_ENET ERROR(s) 0x%x\n", int_events);
 }
 
 static int get_regs(struct net_device *dev, void *p, int *sizep)
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index ca7bcb8..a664aa1 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -257,8 +257,7 @@ static void restart(struct net_device *dev)
 
 	r = whack_reset(fep->fec.fecp);
 	if (r != 0)
-		printk(KERN_ERR DRV_MODULE_NAME
-				": %s FEC Reset FAILED!\n", dev->name);
+		dev_err(fep->dev, "FEC Reset FAILED!\n");
 	/*
 	 * Set station address.
 	 */
@@ -355,9 +354,7 @@ static void stop(struct net_device *dev)
 		udelay(1);
 
 	if (i == FEC_RESET_DELAY)
-		printk(KERN_WARNING DRV_MODULE_NAME
-		       ": %s FEC timeout on graceful transmit stop\n",
-		       dev->name);
+		dev_warn(fep->dev, "FEC timeout on graceful transmit stop\n");
 	/*
 	 * Disable FEC. Let only MII interrupts.
 	 */
@@ -433,8 +430,9 @@ static void clear_int_events(struct net_device *dev, u32 int_events)
 
 static void ev_error(struct net_device *dev, u32 int_events)
 {
-	printk(KERN_WARNING DRV_MODULE_NAME
-	       ": %s FEC ERROR(s) 0x%x\n", dev->name, int_events);
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	dev_warn(fep->dev, "FEC ERROR(s) 0x%x\n", int_events);
 }
 
 static int get_regs(struct net_device *dev, void *p, int *sizep)
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 008cdd9..2d8917f 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -367,9 +367,7 @@ static void stop(struct net_device *dev)
 		udelay(1);
 
 	if (i == SCC_RESET_DELAY)
-		printk(KERN_WARNING DRV_MODULE_NAME
-		       ": %s SCC timeout on graceful transmit stop\n",
-		       dev->name);
+		dev_warn(fep->dev, "SCC timeout on graceful transmit stop\n");
 
 	W16(sccp, scc_sccm, 0);
 	C32(sccp, scc_gsmrl, SCC_GSMRL_ENR | SCC_GSMRL_ENT);
@@ -429,8 +427,9 @@ static void clear_int_events(struct net_device *dev, u32 int_events)
 
 static void ev_error(struct net_device *dev, u32 int_events)
 {
-	printk(KERN_WARNING DRV_MODULE_NAME
-	       ": %s SCC ERROR(s) 0x%x\n", dev->name, int_events);
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	dev_warn(fep->dev, "SCC ERROR(s) 0x%x\n", int_events);
 }
 
 static int get_regs(struct net_device *dev, void *p, int *sizep)
-- 
1.5.6.3

