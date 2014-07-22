From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 22 Jul 2014 15:38:02 +0800
Message-ID: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:57374
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750743AbaGVHiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 03:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Ethernet RX DMA buffers are polled in NAPI work queue other than received
directly in DMA RX interrupt handler.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

---
v2-changes:
- avoid test NAPI_STATE_NPSVC bit in net device driver

v3-changes:
- use tabs while indenting the code

v4-changes:
- unconditionally complete the NAPI poll and re-enable the MAC_RX IRQ

v5-changes:
- should match open parenthesis

v6-changes:
- keep a count of bfin_mac_interrupt disabled mac_rx irq in the device private
area then call enable_irq in bfin_mac_poll

v7-changes:
- only IRQ disable when rx_irq_disabled is zero before the increment
and only do the IRQ enable when decrementing rx_irq_disabled will cause
it to become zero
---
 drivers/net/ethernet/adi/bfin_mac.c | 80 +++++++++++++++++++++++--------------
 drivers/net/ethernet/adi/bfin_mac.h |  2 +
 2 files changed, 52 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 7ae74d4..8924802 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1218,11 +1218,11 @@ out:
 #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
 	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
 
-static void bfin_mac_rx(struct net_device *dev)
+static void bfin_mac_rx(struct bfin_mac_local *lp, int budget)
 {
+	struct net_device *dev = lp->ndev;
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
-	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	unsigned int i;
 	unsigned char fcs[ETH_FCS_LEN + 1];
@@ -1256,7 +1256,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
-	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
+	len = (unsigned short)(current_rx_ptr->status.status_word & RX_FRLEN);
 	/* Deduce Ethernet FCS length from Ethernet payload length */
 	len -= ETH_FCS_LEN;
 	skb_put(skb, len);
@@ -1294,7 +1294,8 @@ static void bfin_mac_rx(struct net_device *dev)
 	}
 #endif
 
-	netif_rx(skb);
+	napi_gro_receive(&lp->napi, skb);
+
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 out:
@@ -1302,41 +1303,53 @@ out:
 	current_rx_ptr = current_rx_ptr->next;
 }
 
+static int bfin_mac_poll(struct napi_struct *napi, int budget)
+{
+	int i = 0;
+	struct bfin_mac_local *lp = container_of(napi,
+						 struct bfin_mac_local,
+						 napi);
+
+	while (current_rx_ptr->status.status_word != 0 && i < budget) {
+		bfin_mac_rx(lp, budget);
+		i++;
+	}
+
+	if (i < budget) {
+		napi_complete(napi);
+		if (lp->rx_irq_disabled--)
+			if (!lp->rx_irq_disabled)
+				enable_irq(IRQ_MAC_RX);
+	}
+
+	return i;
+}
+
 /* interrupt routine to handle rx and error signal */
 static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	int number = 0;
-
-get_one_packet:
-	if (current_rx_ptr->status.status_word == 0) {
-		/* no more new packet received */
-		if (number == 0) {
-			if (current_rx_ptr->next->status.status_word != 0) {
-				current_rx_ptr = current_rx_ptr->next;
-				goto real_rx;
-			}
-		}
-		bfin_write_DMA1_IRQ_STATUS(bfin_read_DMA1_IRQ_STATUS() |
-					   DMA_DONE | DMA_ERR);
-		return IRQ_HANDLED;
+	struct bfin_mac_local *lp = netdev_priv(dev_id);
+	u32 status;
+
+	status = bfin_read_DMA1_IRQ_STATUS();
+
+	bfin_write_DMA1_IRQ_STATUS(status | DMA_DONE | DMA_ERR);
+	if ((status & DMA_DONE) && napi_schedule_prep(&lp->napi)) {
+		if (!lp->rx_irq_disabled++)
+			disable_irq_nosync(IRQ_MAC_RX);
+		__napi_schedule(&lp->napi);
 	}
 
-real_rx:
-	bfin_mac_rx(dev);
-	number++;
-	goto get_one_packet;
+	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void bfin_mac_poll(struct net_device *dev)
+static void bfin_mac_poll_controller(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 
-	disable_irq(IRQ_MAC_RX);
 	bfin_mac_interrupt(IRQ_MAC_RX, dev);
 	tx_reclaim_skb(lp);
-	enable_irq(IRQ_MAC_RX);
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
 
@@ -1428,14 +1441,13 @@ static void bfin_mac_timeout(struct net_device *dev)
 		tx_list_head = tx_list_head->next;
 	}
 
-	if (netif_queue_stopped(lp->ndev))
-		netif_wake_queue(lp->ndev);
+	if (netif_queue_stopped(dev))
+		netif_wake_queue(dev);
 
 	bfin_mac_enable(lp->phydev);
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	netif_wake_queue(dev);
 }
 
 static void bfin_mac_multicast_hash(struct net_device *dev)
@@ -1562,6 +1574,7 @@ static int bfin_mac_open(struct net_device *dev)
 		return ret;
 	pr_debug("hardware init finished\n");
 
+	napi_enable(&lp->napi);
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
 
@@ -1579,6 +1592,7 @@ static int bfin_mac_close(struct net_device *dev)
 	pr_debug("%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
+	napi_disable(&lp->napi);
 	netif_carrier_off(dev);
 
 	phy_stop(lp->phydev);
@@ -1604,7 +1618,7 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= bfin_mac_poll,
+	.ndo_poll_controller	= bfin_mac_poll_controller,
 #endif
 };
 
@@ -1689,6 +1703,9 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	lp->tx_reclaim_timer.data = (unsigned long)lp;
 	lp->tx_reclaim_timer.function = tx_reclaim_skb_timeout;
 
+	lp->rx_irq_disabled = 0;
+	netif_napi_add(ndev, &lp->napi, bfin_mac_poll, CONFIG_BFIN_RX_DESC_NUM);
+
 	spin_lock_init(&lp->lock);
 
 	/* now, enable interrupts */
@@ -1723,6 +1740,7 @@ out_err_phc:
 out_err_reg_ndev:
 	free_irq(IRQ_MAC_RX, ndev);
 out_err_request_irq:
+	netif_napi_del(&lp->napi);
 out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
@@ -1743,6 +1761,8 @@ static int bfin_mac_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 
+	netif_napi_del(&lp->napi);
+
 	free_irq(IRQ_MAC_RX, ndev);
 
 	free_netdev(ndev);
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index 6dec86a..f7f2e68 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -80,6 +80,8 @@ struct bfin_mac_local {
 	int irq_wake_requested;
 	struct timer_list tx_reclaim_timer;
 	struct net_device *ndev;
+	struct napi_struct napi;
+	int rx_irq_disabled;
 
 	/* Data for EMAC_VLAN1 regs */
 	u16 vlan1_mask, vlan2_mask;
-- 
1.8.2.3
