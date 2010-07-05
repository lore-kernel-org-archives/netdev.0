From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] ioc3-eth: Use the instance of net_device_stats from net_device.
Date: Mon, 5 Jul 2010 13:59:38 +0100
Message-ID: <20100705125938.GB28849@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kulikov Vasiliy <segooon@gmail.com>,
	Kernel Janitors <kernel-janitors@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats, we can remove the
instance of this from the adapter structure.

Based on original patch by Kulikov Vasiliy.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

 drivers/net/ioc3-eth.c |   49 ++++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index e3b5e94..0b3f6df 100644
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
@@ -576,8 +575,9 @@ static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
-static inline void ioc3_rx(struct ioc3_private *ip)
+static inline void ioc3_rx(struct net_device *dev)
 {
+	struct ioc3_private *ip = netdev_priv(dev);
 	struct sk_buff *skb, *new_skb;
 	struct ioc3 *ioc3 = ip->regs;
 	int rx_entry, n_entry, len;
@@ -598,13 +598,13 @@ static inline void ioc3_rx(struct ioc3_private *ip)
 		if (err & ERXBUF_GOODPKT) {
 			len = ((w0 >> ERXBUF_BYTECNT_SHIFT) & 0x7ff) - 4;
 			skb_trim(skb, len);
-			skb->protocol = eth_type_trans(skb, priv_netdev(ip));
+			skb->protocol = eth_type_trans(skb, dev);
 
 			new_skb = ioc3_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
 			if (!new_skb) {
 				/* Ouch, drop packet and just recycle packet
 				   to keep the ring filled.  */
-				ip->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				new_skb = skb;
 				goto next;
 			}
@@ -622,19 +622,19 @@ static inline void ioc3_rx(struct ioc3_private *ip)
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
@@ -652,8 +652,9 @@ next:
 	ip->rx_ci = rx_entry;
 }
 
-static inline void ioc3_tx(struct ioc3_private *ip)
+static inline void ioc3_tx(struct net_device *dev)
 {
+	struct ioc3_private *ip = netdev_priv(dev);
 	unsigned long packets, bytes;
 	struct ioc3 *ioc3 = ip->regs;
 	int tx_entry, o_entry;
@@ -681,12 +682,12 @@ static inline void ioc3_tx(struct ioc3_private *ip)
 		tx_entry = (etcir >> 7) & 127;
 	}
 
-	ip->stats.tx_packets += packets;
-	ip->stats.tx_bytes += bytes;
+	dev->stats.tx_packets += packets;
+	dev->stats.tx_bytes += bytes;
 	ip->txqlen -= packets;
 
 	if (ip->txqlen < 128)
-		netif_wake_queue(priv_netdev(ip));
+		netif_wake_queue(dev);
 
 	ip->tx_ci = o_entry;
 	spin_unlock(&ip->ioc3_lock);
@@ -699,9 +700,9 @@ static inline void ioc3_tx(struct ioc3_private *ip)
  * with such error interrupts if something really goes wrong, so we might
  * also consider to take the interface down.
  */
-static void ioc3_error(struct ioc3_private *ip, u32 eisr)
+static void ioc3_error(struct net_device *dev, u32 eisr)
 {
-	struct net_device *dev = priv_netdev(ip);
+	struct ioc3_private *ip = netdev_priv(dev);
 	unsigned char *iface = dev->name;
 
 	spin_lock(&ip->ioc3_lock);
@@ -747,11 +748,11 @@ static irqreturn_t ioc3_interrupt(int irq, void *_dev)
 
 	if (eisr & (EISR_RXOFLO | EISR_RXBUFOFLO | EISR_RXMEMERR |
 	            EISR_RXPARERR | EISR_TXBUFUFLO | EISR_TXMEMERR))
-		ioc3_error(ip, eisr);
+		ioc3_error(dev, eisr);
 	if (eisr & EISR_RXTIMERINT)
-		ioc3_rx(ip);
+		ioc3_rx(dev);
 	if (eisr & EISR_TXEXPLICIT)
-		ioc3_tx(ip);
+		ioc3_tx(dev);
 
 	return IRQ_HANDLED;
 }
