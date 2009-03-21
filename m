From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 68/77] prism54: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:35 -0700
Message-ID: <20090321053717.765575826@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=lscpi-stats.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Also, make ethtool_ops const as it should be, and get rid
of useless cast.

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/wireless/prism54/islpci_dev.c |   14 --------------
 drivers/net/wireless/prism54/islpci_dev.h |    3 ---
 drivers/net/wireless/prism54/islpci_eth.c |   13 ++++++-------
 3 files changed, 6 insertions(+), 24 deletions(-)

--- a/drivers/net/wireless/prism54/islpci_dev.c	2009-03-20 18:37:36.129838594 -0700
+++ b/drivers/net/wireless/prism54/islpci_dev.c	2009-03-20 18:37:36.137839156 -0700
@@ -43,7 +43,6 @@
 
 static int prism54_bring_down(islpci_private *);
 static int islpci_alloc_memory(islpci_private *);
-static struct net_device_stats *islpci_statistics(struct net_device *);
 
 /* Temporary dummy MAC address to use until firmware is loaded.
  * The idea there is that some tools (such as nameif) may query
@@ -614,18 +613,6 @@ islpci_reset(islpci_private *priv, int r
 	return rc;
 }
 
-static struct net_device_stats *
-islpci_statistics(struct net_device *ndev)
-{
-	islpci_private *priv = netdev_priv(ndev);
-
-#if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics\n");
-#endif
-
-	return &priv->statistics;
-}
-
 /******************************************************************************
     Network device configuration functions
 ******************************************************************************/
@@ -811,7 +798,6 @@ static const struct ethtool_ops islpci_e
 static const struct net_device_ops islpci_netdev_ops = {
 	.ndo_open 		= islpci_open,
 	.ndo_stop		= islpci_close,
-	.ndo_get_stats		= islpci_statistics,
 	.ndo_do_ioctl		= prism54_ioctl,
 	.ndo_start_xmit		= islpci_eth_transmit,
 	.ndo_tx_timeout		= islpci_eth_tx_timeout,
--- a/drivers/net/wireless/prism54/islpci_dev.h	2009-03-20 18:36:43.697901654 -0700
+++ b/drivers/net/wireless/prism54/islpci_dev.h	2009-03-20 18:37:36.137839156 -0700
@@ -158,9 +158,6 @@ typedef struct {
 	dma_addr_t pci_map_tx_address[ISL38XX_CB_TX_QSIZE];
 	dma_addr_t pci_map_rx_address[ISL38XX_CB_RX_QSIZE];
 
-	/* driver network interface members */
-	struct net_device_stats statistics;
-
 	/* wait for a reset interrupt */
 	wait_queue_head_t reset_done;
 
--- a/drivers/net/wireless/prism54/islpci_eth.c	2009-03-20 18:37:59.821964445 -0700
+++ b/drivers/net/wireless/prism54/islpci_eth.c	2009-03-20 18:38:59.740714710 -0700
@@ -231,8 +231,8 @@ islpci_eth_transmit(struct sk_buff *skb,
 
 	/* set the transmission time */
 	ndev->trans_start = jiffies;
-	priv->statistics.tx_packets++;
-	priv->statistics.tx_bytes += skb->len;
+	ndev->stats.tx_packets++;
+	ndev->stats.tx_bytes += skb->len;
 
 	/* trigger the device */
 	islpci_trigger(priv);
@@ -243,7 +243,7 @@ islpci_eth_transmit(struct sk_buff *skb,
 	return 0;
 
       drop_free:
-	priv->statistics.tx_dropped++;
+	ndev->stats.tx_dropped++;
 	spin_unlock_irqrestore(&priv->slock, flags);
 	dev_kfree_skb(skb);
 	return err;
@@ -408,8 +408,8 @@ islpci_eth_receive(islpci_private *priv)
 		skb->protocol = eth_type_trans(skb, ndev);
 	}
 	skb->ip_summed = CHECKSUM_NONE;
-	priv->statistics.rx_packets++;
-	priv->statistics.rx_bytes += size;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += size;
 
 	/* deliver the skb to the network layer */
 #ifdef ISLPCI_ETH_DEBUG
@@ -497,10 +497,9 @@ void
 islpci_eth_tx_timeout(struct net_device *ndev)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct net_device_stats *statistics = &priv->statistics;
 
 	/* increment the transmit error counter */
-	statistics->tx_errors++;
+	ndev->stats.tx_errors++;
 
 	if (!priv->reset_task_pending) {
 		printk(KERN_WARNING

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
