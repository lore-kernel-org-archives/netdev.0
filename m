From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] ioc3-eth: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:51 +0400
Message-ID: <1278332034-17122-1-git-send-email-segooon@gmail.com>
Cc: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jpirko@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Patrick McHardy <kaber@trash.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        linux-mips@linux-mips.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ioc3-eth.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index e3b5e94..0c005ad 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -82,7 +82,6 @@ struct ioc3_private {
 	struct ioc3_etxd *txr;
 	struct sk_buff *rx_skbs[512];
 	struct sk_buff *tx_skbs[128];
-	struct net_device_stats stats;
 	int rx_ci;			/* RX consumer index */
 	int rx_pi;			/* RX producer index */
 	int tx_ci;			/* TX consumer index */
@@ -504,8 +503,8 @@ static struct net_device_stats *ioc3_get_stats(struct net_device *dev)
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 
-	ip->stats.collisions += (ioc3_r_etcdc() & ETCDC_COLLCNT_MASK);
-	return &ip->stats;
+	dev->stats.collisions += (ioc3_r_etcdc() & ETCDC_COLLCNT_MASK);
+	return &dev->stats;
 }
 
 static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
@@ -604,7 +603,7 @@ static inline void ioc3_rx(struct ioc3_private *ip)
 			if (!new_skb) {
 				/* Ouch, drop packet and just recycle packet
 				   to keep the ring filled.  */
-				ip->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				new_skb = skb;
 				goto next;
 			}
@@ -622,19 +621,19 @@ static inline void ioc3_rx(struct ioc3_private *ip)
 			rxb = (struct ioc3_erxbuf *) new_skb->data;
 			skb_reserve(new_skb, RX_OFFSET);
 
-			ip->stats.rx_packets++;		/* Statistics */
-			ip->stats.rx_bytes += len;
+			dev->stats.rx_packets++;		/* Statistics */
+			dev->stats.rx_bytes += len;
 		} else {
- 			/* The frame is invalid and the skb never
-                           reached the network layer so we can just
-                           recycle it.  */
- 			new_skb = skb;
- 			ip->stats.rx_errors++;
+			/* The frame is invalid and the skb never
+			   reached the network layer so we can just
+			   recycle it.  */
+			new_skb = skb;
+			dev->stats.rx_errors++;
 		}
 		if (err & ERXBUF_CRCERR)	/* Statistics */
-			ip->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		if (err & ERXBUF_FRAMERR)
-			ip->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 next:
 		ip->rx_skbs[n_entry] = new_skb;
 		rxr[n_entry] = cpu_to_be64(ioc3_map(rxb, 1));
@@ -681,8 +680,8 @@ static inline void ioc3_tx(struct ioc3_private *ip)
 		tx_entry = (etcir >> 7) & 127;
 	}
 
-	ip->stats.tx_packets += packets;
-	ip->stats.tx_bytes += bytes;
+	dev->stats.tx_packets += packets;
+	dev->stats.tx_bytes += bytes;
 	ip->txqlen -= packets;
 
 	if (ip->txqlen < 128)
-- 
1.7.0.4
