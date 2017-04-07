From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 08/14] net: nuvoton: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:33 +0200
Message-ID: <20170407081739.5243-9-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34508 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755164AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in
struct w90p910_ether, use stats from struct net_device. Also remove
the now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c | 33 ++++++++++------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 9709c8ca0774..159564d8dcdb 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -152,7 +152,6 @@ struct  w90p910_ether {
 	struct tran_pdesc *tdesc;
 	dma_addr_t rdesc_phys;
 	dma_addr_t tdesc_phys;
-	struct net_device_stats stats;
 	struct platform_device *pdev;
 	struct resource *res;
 	struct sk_buff *skb;
@@ -584,15 +583,6 @@ static int w90p910_ether_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *w90p910_ether_stats(struct net_device *dev)
-{
-	struct w90p910_ether *ether;
-
-	ether = netdev_priv(dev);
-
-	return &ether->stats;
-}
-
 static int w90p910_send_frame(struct net_device *dev,
 					unsigned char *data, int length)
 {
@@ -671,10 +661,10 @@ static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
 			ether->finish_tx = 0;
 
 		if (txbd->sl & TXDS_TXCP) {
-			ether->stats.tx_packets++;
-			ether->stats.tx_bytes += txbd->sl & 0xFFFF;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += txbd->sl & 0xFFFF;
 		} else {
-			ether->stats.tx_errors++;
+			dev->stats.tx_errors++;
 		}
 
 		txbd->sl = 0x0;
@@ -730,7 +720,7 @@ static void netdev_rx(struct net_device *dev)
 			data = ether->rdesc->recv_buf[ether->cur_rx];
 			skb = netdev_alloc_skb(dev, length + 2);
 			if (!skb) {
-				ether->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				return;
 			}
 
@@ -738,24 +728,24 @@ static void netdev_rx(struct net_device *dev)
 			skb_put(skb, length);
 			skb_copy_to_linear_data(skb, data, length);
 			skb->protocol = eth_type_trans(skb, dev);
-			ether->stats.rx_packets++;
-			ether->stats.rx_bytes += length;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += length;
 			netif_rx(skb);
 		} else {
-			ether->stats.rx_errors++;
+			dev->stats.rx_errors++;
 
 			if (status & RXDS_RP) {
 				dev_err(&pdev->dev, "rx runt err\n");
-				ether->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			} else if (status & RXDS_CRCE) {
 				dev_err(&pdev->dev, "rx crc err\n");
-				ether->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			} else if (status & RXDS_ALIE) {
 				dev_err(&pdev->dev, "rx alignment err\n");
-				ether->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			} else if (status & RXDS_PTLE) {
 				dev_err(&pdev->dev, "rx longer err\n");
-				ether->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			}
 		}
 
@@ -912,7 +902,6 @@ static const struct net_device_ops w90p910_ether_netdev_ops = {
 	.ndo_open		= w90p910_ether_open,
 	.ndo_stop		= w90p910_ether_close,
 	.ndo_start_xmit		= w90p910_ether_start_xmit,
-	.ndo_get_stats		= w90p910_ether_stats,
 	.ndo_set_rx_mode	= w90p910_ether_set_multicast_list,
 	.ndo_set_mac_address	= w90p910_set_mac_address,
 	.ndo_do_ioctl		= w90p910_ether_ioctl,
-- 
2.12.2
