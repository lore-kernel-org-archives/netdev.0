From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: fs_enet: Use net_device_stats from struct net_device
Date: Wed, 19 Oct 2016 11:24:57 +0200
Message-ID: <20161019092457.15006-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
 Vitaly Bordug <vbordug@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Instead of using a private copy of struct net_device_stats in struct
fs_enet_private, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 43 +++++++++-------------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |  1 -
 2 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 925d1bca6a26..44f50e168703 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -118,22 +118,22 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 			  BD_ENET_TX_RL | BD_ENET_TX_UN | BD_ENET_TX_CSL)) {
 
 			if (sc & BD_ENET_TX_HB)	/* No heartbeat */
-				fep->stats.tx_heartbeat_errors++;
+				dev->stats.tx_heartbeat_errors++;
 			if (sc & BD_ENET_TX_LC)	/* Late collision */
-				fep->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 			if (sc & BD_ENET_TX_RL)	/* Retrans limit */
-				fep->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (sc & BD_ENET_TX_UN)	/* Underrun */
-				fep->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			if (sc & BD_ENET_TX_CSL)	/* Carrier lost */
-				fep->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 
 			if (sc & (BD_ENET_TX_LC | BD_ENET_TX_RL | BD_ENET_TX_UN)) {
-				fep->stats.tx_errors++;
+				dev->stats.tx_errors++;
 				do_restart = 1;
 			}
 		} else
-			fep->stats.tx_packets++;
+			dev->stats.tx_packets++;
 
 		if (sc & BD_ENET_TX_READY) {
 			dev_warn(fep->dev,
@@ -145,7 +145,7 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 		 * but we eventually sent the packet OK.
 		 */
 		if (sc & BD_ENET_TX_DEF)
-			fep->stats.collisions++;
+			dev->stats.collisions++;
 
 		/* unmap */
 		if (fep->mapped_as_page[dirtyidx])
@@ -212,19 +212,19 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 		 */
 		if (sc & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_CL |
 			  BD_ENET_RX_NO | BD_ENET_RX_CR | BD_ENET_RX_OV)) {
-			fep->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			/* Frame too long or too short. */
 			if (sc & (BD_ENET_RX_LG | BD_ENET_RX_SH))
-				fep->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			/* Frame alignment */
 			if (sc & (BD_ENET_RX_NO | BD_ENET_RX_CL))
-				fep->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			/* CRC Error */
 			if (sc & BD_ENET_RX_CR)
-				fep->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			/* FIFO overrun */
 			if (sc & BD_ENET_RX_OV)
-				fep->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 
 			skbn = fep->rx_skbuff[curidx];
 		} else {
@@ -233,9 +233,9 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 			/*
 			 * Process the incoming frame.
 			 */
-			fep->stats.rx_packets++;
+			dev->stats.rx_packets++;
 			pkt_len = CBDR_DATLEN(bdp) - 4;	/* remove CRC */
-			fep->stats.rx_bytes += pkt_len + 4;
+			dev->stats.rx_bytes += pkt_len + 4;
 
 			if (pkt_len <= fpi->rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
@@ -277,7 +277,7 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 				received++;
 				netif_receive_skb(skb);
 			} else {
-				fep->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				skbn = skb;
 			}
 		}
@@ -543,7 +543,7 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	curidx = bdp - fep->tx_bd_base;
 
 	len = skb->len;
-	fep->stats.tx_bytes += len;
+	dev->stats.tx_bytes += len;
 	if (nr_frags)
 		len -= skb->data_len;
 	fep->tx_free -= nr_frags + 1;
@@ -619,7 +619,7 @@ static void fs_timeout(struct net_device *dev)
 	unsigned long flags;
 	int wake = 0;
 
-	fep->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_lock_irqsave(&fep->lock, flags);
 
@@ -774,12 +774,6 @@ static int fs_enet_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *fs_enet_get_stats(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	return &fep->stats;
-}
-
 /*************************************************************************/
 
 static void fs_get_drvinfo(struct net_device *dev,
@@ -905,7 +899,6 @@ extern void fs_mii_disconnect(struct net_device *dev);
 static const struct net_device_ops fs_enet_netdev_ops = {
 	.ndo_open		= fs_enet_open,
 	.ndo_stop		= fs_enet_close,
-	.ndo_get_stats		= fs_enet_get_stats,
 	.ndo_start_xmit		= fs_enet_start_xmit,
 	.ndo_tx_timeout		= fs_timeout,
 	.ndo_set_rx_mode	= fs_set_multicast_list,
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
index fee24c822fad..5ce516c8a62a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
@@ -137,7 +137,6 @@ struct fs_enet_private {
 	cbd_t __iomem *cur_rx;
 	cbd_t __iomem *cur_tx;
 	int tx_free;
-	struct net_device_stats stats;
 	struct timer_list phy_timer_list;
 	const struct phy_info *phy;
 	u32 msg_enable;
-- 
2.9.0
