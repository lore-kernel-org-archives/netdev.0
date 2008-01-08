From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier state
 in ->poll()
Date: Mon, 07 Jan 2008 21:39:07 -0800 (PST)
Message-ID: <20080107.213907.160610552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbYAHFjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:39:08 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F19F1C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:39:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET]: Do not check netif_running() and carrier state in ->poll()

Drivers do this to try to break out of the ->poll()'ing loop
when the device is being brought administratively down.

Now that we have a napi_disable() "pending" state we are going
to solve that problem generically.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/e100.c                 |    2 +-
 drivers/net/e1000/e1000_main.c     |    8 +-------
 drivers/net/e1000e/netdev.c        |    8 +-------
 drivers/net/epic100.c              |    2 +-
 drivers/net/fec_8xx/fec_main.c     |    5 -----
 drivers/net/fs_enet/fs_enet-main.c |    3 ---
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    8 +-------
 drivers/net/ixp2000/ixpdev.c       |    2 --
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/natsemi.c              |    2 +-
 drivers/net/qla3xxx.c              |    7 +------
 drivers/net/s2io.c                 |    3 ---
 drivers/net/tulip/interrupt.c      |    5 -----
 drivers/net/xen-netfront.c         |    5 -----
 15 files changed, 9 insertions(+), 55 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 2b06e4b..68316f1 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1997,7 +1997,7 @@ static int e100_poll(struct napi_struct *napi, int budget)
 	tx_cleaned = e100_tx_clean(nic);
 
 	/* If no Rx and Tx cleanup work was done, exit polling mode. */
-	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+	if((!tx_cleaned && (work_done == 0))) {
 		netif_rx_complete(netdev, napi);
 		e100_enable_irq(nic);
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4f37506..9de7144 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3924,10 +3924,6 @@ e1000_clean(struct napi_struct *napi, int budget)
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(poll_dev))
-		goto quit_polling;
-
 	/* e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring[0] from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
@@ -3942,9 +3938,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
-	   !netif_running(poll_dev)) {
-quit_polling:
+	if ((!tx_cleaned && (work_done == 0))) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4fd2e23..dd9698c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1389,10 +1389,6 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(poll_dev))
-		goto quit_polling;
-
 	/* e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
@@ -1405,9 +1401,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	adapter->clean_rx(adapter, &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget)) ||
-	   !netif_running(poll_dev)) {
-quit_polling:
+	if ((!tx_cleaned && (work_done < budget))) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index ecdd3fc..0b365b8 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1273,7 +1273,7 @@ rx_action:
 
 	epic_rx_err(dev, ep);
 
-	if (netif_running(dev) && (work_done < budget)) {
+	if (work_done < budget) {
 		unsigned long flags;
 		int more;
 
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index 8d2904f..ab9637a 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -476,11 +476,6 @@ static int fec_enet_rx_common(struct fec_enet_private *ep,
 	__u16 pkt_len, sc;
 	int curidx;
 
-	if (fpi->use_napi) {
-		if (!netif_running(dev))
-			return 0;
-	}
-
 	/*
 	 * First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index f2a4d39..3e1a57a 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -96,9 +96,6 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 	u16 pkt_len, sc;
 	int curidx;
 
-	if (!netif_running(dev))
-		return 0;
-
 	/*
 	 * First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index bf9085f..a8bef52 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1794,7 +1794,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
 	ixgb_clean_rx_irq(adapter, &work_done, budget);
 
 	/* if no Tx and not enough Rx work done, exit the polling mode */
-	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+	if((!tx_cleaned && (work_done == 0))) {
 		netif_rx_complete(netdev, napi);
 		ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00bc525..7c31930 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1470,19 +1470,13 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(adapter->netdev))
-		goto quit_polling;
-
 	/* In non-MSIX case, there is no multi-Tx/Rx queue */
 	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[0], &work_done,
 			   budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget)) ||
-	    !netif_running(adapter->netdev)) {
-quit_polling:
+	if ((!tx_cleaned && (work_done < budget))) {
 		netif_rx_complete(netdev, napi);
 		ixgbe_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 6c0dd49..484cb2b 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -135,8 +135,6 @@ static int ixpdev_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = ip->dev;
 	int rx;
 
-	/* @@@ Have to stop polling when nds[0] is administratively
-	 * downed while we are polling.  */
 	rx = 0;
 	do {
 		ixp2000_reg_write(IXP2000_IRQ_THD_RAW_STATUS_A_0, 0x00ff);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 8def865..c90958f 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1239,7 +1239,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(mgp, budget);
 
-	if (work_done < budget || !netif_running(netdev)) {
+	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
 		put_be32(htonl(3), mgp->irq_claim);
 	}
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 87cde06..c329a4f 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2266,7 +2266,7 @@ static int natsemi_poll(struct napi_struct *napi, int budget)
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
 	spin_lock(&np->lock);
-	if (!np->hands_off && netif_running(dev))
+	if (!np->hands_off)
 		natsemi_irq_enable(dev);
 	spin_unlock(&np->lock);
 
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a579111..cf0774d 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2320,14 +2320,9 @@ static int ql_poll(struct napi_struct *napi, int budget)
 	unsigned long hw_flags;
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
 
-	if (!netif_carrier_ok(ndev))
-		goto quit_polling;
-
 	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, budget);
 
-	if (tx_cleaned + rx_cleaned != budget ||
-	    !netif_running(ndev)) {
-quit_polling:
+	if (tx_cleaned + rx_cleaned != budget) {
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		__netif_rx_complete(ndev, napi);
 		ql_update_small_bufq_prod_index(qdev);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 9d80f1c..fa57c49 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2704,9 +2704,6 @@ static int s2io_poll(struct napi_struct *napi, int budget)
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int i;
 
-	if (!is_s2io_card_up(nic))
-		return 0;
-
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 0461956..6284afd 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -117,9 +117,6 @@ int tulip_poll(struct napi_struct *napi, int budget)
 	int received = 0;
 #endif
 
-	if (!netif_running(dev))
-		goto done;
-
 #ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 
 /* that one buffer is needed for mit activation; or might be a
@@ -261,8 +258,6 @@ int tulip_poll(struct napi_struct *napi, int budget)
                 * finally: amount of IO did not increase at all. */
        } while ((ioread32(tp->base_addr + CSR5) & RxIntr));
 
-done:
-
  #ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 
           /* We use this simplistic scheme for IM. It's proven by
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 2a8fc43..bca37bf 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -852,11 +852,6 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 
 	spin_lock(&np->rx_lock);
 
-	if (unlikely(!netif_carrier_ok(dev))) {
-		spin_unlock(&np->rx_lock);
-		return 0;
-	}
-
 	skb_queue_head_init(&rxq);
 	skb_queue_head_init(&errq);
 	skb_queue_head_init(&tmpq);
-- 
1.5.4.rc2.38.gd6da3

