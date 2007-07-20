From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 6/10] ps3: use net_device_stats of net_device structure
Date: Fri, 20 Jul 2007 17:31:07 +0900
Message-ID: <20070720172913.6798.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:33236 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937036AbXGTIbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:31:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed the statistics information from private structre. 
Instead, use net_device_stats in net_device structure.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |   31 ++++++++-----------------------
 drivers/net/ps3_gelic_net.h |    1 -
 2 files changed, 8 insertions(+), 24 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -404,13 +404,13 @@ static void gelic_net_release_tx_chain(s
 					 "%s: forcing end of tx descriptor " \
 					 "with status %x\n",
 					 __func__, status);
-			card->netdev_stats.tx_dropped++;
+			card->netdev->stats.tx_dropped++;
 			break;
 
 		case GELIC_NET_DESCR_COMPLETE:
 			if (tx_chain->tail->skb) {
-				card->netdev_stats.tx_packets++;
-				card->netdev_stats.tx_bytes +=
+				card->netdev->stats.tx_packets++;
+				card->netdev->stats.tx_bytes +=
 					tx_chain->tail->skb->len;
 			}
 			break;
@@ -790,7 +790,7 @@ static int gelic_net_xmit(struct sk_buff
 		 * DMA map failed.  As chanses are that failure
 		 * would continue, just release skb and return
 		 */
-		card->netdev_stats.tx_dropped++;
+		card->netdev->stats.tx_dropped++;
 		dev_kfree_skb_any(skb);
 		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
 		return NETDEV_TX_OK;
@@ -810,7 +810,7 @@ static int gelic_net_xmit(struct sk_buff
 		 * kick failed.
 		 * release descriptors which were just prepared
 		 */
-		card->netdev_stats.tx_dropped++;
+		card->netdev->stats.tx_dropped++;
 		gelic_net_release_tx_descr(card, descr);
 		gelic_net_release_tx_descr(card, descr->next);
 		card->tx_chain.tail = descr->next->next;
@@ -872,8 +872,8 @@ static void gelic_net_pass_skb_up(struct
 		skb->ip_summed = CHECKSUM_NONE;
 
 	/* update netdevice statistics */
-	card->netdev_stats.rx_packets++;
-	card->netdev_stats.rx_bytes += skb->len;
+	card->netdev->stats.rx_packets++;
+	card->netdev->stats.rx_bytes += skb->len;
 
 	/* pass skb up to stack */
 	netif_receive_skb(skb);
@@ -913,7 +913,7 @@ static int gelic_net_decode_one_descr(st
 	    (status == GELIC_NET_DESCR_FORCE_END)) {
 		dev_info(ctodev(card), "dropping RX descriptor with state %x\n",
 			 status);
-		card->netdev_stats.rx_dropped++;
+		card->netdev->stats.rx_dropped++;
 		goto refill;
 	}
 
@@ -986,20 +986,6 @@ static int gelic_net_poll(struct net_dev
 	} else
 		return 1;
 }
-
-/**
- * gelic_net_get_stats - get interface statistics
- * @netdev: interface device structure
- *
- * returns the interface statistics residing in the gelic_net_card struct
- */
-static struct net_device_stats *gelic_net_get_stats(struct net_device *netdev)
-{
-	struct gelic_net_card *card = netdev_priv(netdev);
-
-	return &card->netdev_stats;
-}
-
 /**
  * gelic_net_change_mtu - changes the MTU of an interface
  * @netdev: interface device structure
@@ -1337,7 +1323,6 @@ static void gelic_net_setup_netdev_ops(s
 	netdev->open = &gelic_net_open;
 	netdev->stop = &gelic_net_stop;
 	netdev->hard_start_xmit = &gelic_net_xmit;
-	netdev->get_stats = &gelic_net_get_stats;
 	netdev->set_multicast_list = &gelic_net_set_multi;
 	netdev->change_mtu = &gelic_net_change_mtu;
 	/* tx watchdog */
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -210,7 +210,6 @@ struct gelic_net_card {
 	/* gurad dmac descriptor chain*/
 	spinlock_t chain_lock;
 
-	struct net_device_stats netdev_stats;
 	int rx_csum;
 	/* guard tx_dma_progress */
 	spinlock_t tx_dma_lock;

--
Masakazu MOKUNO

