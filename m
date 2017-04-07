From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 14/14] usbnet: pegasus: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:39 +0200
Message-ID: <20170407081739.5243-15-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
Cc: Petko Manolov <petkan@nucleusys.com>, linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34538 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755164AbdDGIR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:58 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
pegasus, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function.

Cc: Petko Manolov <petkan@nucleusys.com>
Cc: linux-usb@vger.kernel.org
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/usb/pegasus.c | 36 +++++++++++++++---------------------
 drivers/net/usb/pegasus.h |  1 -
 2 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 321e059e13ae..6514c86f043e 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -501,13 +501,13 @@ static void read_bulk_callback(struct urb *urb)
 	if (rx_status & 0x1e) {
 		netif_dbg(pegasus, rx_err, net,
 			  "RX packet error %x\n", rx_status);
-		pegasus->stats.rx_errors++;
+		net->stats.rx_errors++;
 		if (rx_status & 0x06)	/* long or runt	*/
-			pegasus->stats.rx_length_errors++;
+			net->stats.rx_length_errors++;
 		if (rx_status & 0x08)
-			pegasus->stats.rx_crc_errors++;
+			net->stats.rx_crc_errors++;
 		if (rx_status & 0x10)	/* extra bits	*/
-			pegasus->stats.rx_frame_errors++;
+			net->stats.rx_frame_errors++;
 		goto goon;
 	}
 	if (pegasus->chip == 0x8513) {
@@ -535,8 +535,8 @@ static void read_bulk_callback(struct urb *urb)
 	skb_put(pegasus->rx_skb, pkt_len);
 	pegasus->rx_skb->protocol = eth_type_trans(pegasus->rx_skb, net);
 	netif_rx(pegasus->rx_skb);
-	pegasus->stats.rx_packets++;
-	pegasus->stats.rx_bytes += pkt_len;
+	net->stats.rx_packets++;
+	net->stats.rx_bytes += pkt_len;
 
 	if (pegasus->flags & PEGASUS_UNPLUG)
 		return;
@@ -670,13 +670,13 @@ static void intr_callback(struct urb *urb)
 		/* byte 0 == tx_status1, reg 2B */
 		if (d[0] & (TX_UNDERRUN|EXCESSIVE_COL
 					|LATE_COL|JABBER_TIMEOUT)) {
-			pegasus->stats.tx_errors++;
+			net->stats.tx_errors++;
 			if (d[0] & TX_UNDERRUN)
-				pegasus->stats.tx_fifo_errors++;
+				net->stats.tx_fifo_errors++;
 			if (d[0] & (EXCESSIVE_COL | JABBER_TIMEOUT))
-				pegasus->stats.tx_aborted_errors++;
+				net->stats.tx_aborted_errors++;
 			if (d[0] & LATE_COL)
-				pegasus->stats.tx_window_errors++;
+				net->stats.tx_window_errors++;
 		}
 
 		/* d[5].LINK_STATUS lies on some adapters.
@@ -685,7 +685,7 @@ static void intr_callback(struct urb *urb)
 		 */
 
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
-		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
+		net->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
 	}
 
 	res = usb_submit_urb(urb, GFP_ATOMIC);
@@ -701,7 +701,7 @@ static void pegasus_tx_timeout(struct net_device *net)
 	pegasus_t *pegasus = netdev_priv(net);
 	netif_warn(pegasus, timer, net, "tx timeout\n");
 	usb_unlink_urb(pegasus->tx_urb);
-	pegasus->stats.tx_errors++;
+	net->stats.tx_errors++;
 }
 
 static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
@@ -731,23 +731,18 @@ static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
 			netif_device_detach(pegasus->net);
 			break;
 		default:
-			pegasus->stats.tx_errors++;
+			net->stats.tx_errors++;
 			netif_start_queue(net);
 		}
 	} else {
-		pegasus->stats.tx_packets++;
-		pegasus->stats.tx_bytes += skb->len;
+		net->stats.tx_packets++;
+		net->stats.tx_bytes += skb->len;
 	}
 	dev_kfree_skb(skb);
 
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *pegasus_netdev_stats(struct net_device *dev)
-{
-	return &((pegasus_t *) netdev_priv(dev))->stats;
-}
-
 static inline void disable_net_traffic(pegasus_t *pegasus)
 {
 	__le16 tmp = cpu_to_le16(0);
@@ -1294,7 +1289,6 @@ static const struct net_device_ops pegasus_netdev_ops = {
 	.ndo_do_ioctl =			pegasus_ioctl,
 	.ndo_start_xmit =		pegasus_start_xmit,
 	.ndo_set_rx_mode =		pegasus_set_multicast,
-	.ndo_get_stats =		pegasus_netdev_stats,
 	.ndo_tx_timeout =		pegasus_tx_timeout,
 	.ndo_set_mac_address =		eth_mac_addr,
 	.ndo_validate_addr =		eth_validate_addr,
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index d15646244fdf..9b7ea9c9167d 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -83,7 +83,6 @@ typedef struct pegasus {
 	struct usb_device	*usb;
 	struct usb_interface	*intf;
 	struct net_device	*net;
-	struct net_device_stats	stats;
 	struct mii_if_info	mii;
 	unsigned		flags;
 	unsigned		features;
-- 
2.12.2
