From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [6/7] usbnet: Use netdev stats structure
Date: Tue, 30 Jun 2009 10:53:28 +0800
Message-ID: <20090630025328.GE14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42774 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760124AbZF3Cxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:53:30 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet: Use netdev stats structure

Now that netdev has its own stats structure we should use that
instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f3a2fce..f27ad07 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -203,8 +203,8 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	int	status;
 
 	skb->protocol = eth_type_trans (skb, dev->net);
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += skb->len;
+	dev->net->stats.rx_packets++;
+	dev->net->stats.rx_bytes += skb->len;
 
 	if (netif_msg_rx_status (dev))
 		devdbg (dev, "< rx, len %zu, type 0x%x",
@@ -366,7 +366,7 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 		if (netif_msg_rx_err (dev))
 			devdbg (dev, "drop");
 error:
-		dev->stats.rx_errors++;
+		dev->net->stats.rx_errors++;
 		skb_queue_tail (&dev->done, skb);
 	}
 }
@@ -389,8 +389,8 @@ static void rx_complete (struct urb *urb)
 	case 0:
 		if (skb->len < dev->net->hard_header_len) {
 			entry->state = rx_cleanup;
-			dev->stats.rx_errors++;
-			dev->stats.rx_length_errors++;
+			dev->net->stats.rx_errors++;
+			dev->net->stats.rx_length_errors++;
 			if (netif_msg_rx_err (dev))
 				devdbg (dev, "rx length %d", skb->len);
 		}
@@ -402,7 +402,7 @@ static void rx_complete (struct urb *urb)
 	 * storm, recovering as needed.
 	 */
 	case -EPIPE:
-		dev->stats.rx_errors++;
+		dev->net->stats.rx_errors++;
 		usbnet_defer_kevent (dev, EVENT_RX_HALT);
 		// FALLTHROUGH
 
@@ -420,7 +420,7 @@ static void rx_complete (struct urb *urb)
 	case -EPROTO:
 	case -ETIME:
 	case -EILSEQ:
-		dev->stats.rx_errors++;
+		dev->net->stats.rx_errors++;
 		if (!timer_pending (&dev->delay)) {
 			mod_timer (&dev->delay, jiffies + THROTTLE_JIFFIES);
 			if (netif_msg_link (dev))
@@ -434,12 +434,12 @@ block:
 
 	/* data overrun ... flush fifo? */
 	case -EOVERFLOW:
-		dev->stats.rx_over_errors++;
+		dev->net->stats.rx_over_errors++;
 		// FALLTHROUGH
 
 	default:
 		entry->state = rx_cleanup;
-		dev->stats.rx_errors++;
+		dev->net->stats.rx_errors++;
 		if (netif_msg_rx_err (dev))
 			devdbg (dev, "rx status %d", urb_status);
 		break;
@@ -552,8 +552,8 @@ int usbnet_stop (struct net_device *net)
 
 	if (netif_msg_ifdown (dev))
 		devinfo (dev, "stop stats: rx/tx %ld/%ld, errs %ld/%ld",
-			dev->stats.rx_packets, dev->stats.tx_packets,
-			dev->stats.rx_errors, dev->stats.tx_errors
+			net->stats.rx_packets, net->stats.tx_packets,
+			net->stats.rx_errors, net->stats.tx_errors
 			);
 
 	// ensure there are no more active urbs
@@ -860,10 +860,10 @@ static void tx_complete (struct urb *urb)
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
-		dev->stats.tx_packets++;
-		dev->stats.tx_bytes += entry->length;
+		dev->net->stats.tx_packets++;
+		dev->net->stats.tx_bytes += entry->length;
 	} else {
-		dev->stats.tx_errors++;
+		dev->net->stats.tx_errors++;
 
 		switch (urb->status) {
 		case -EPIPE:
@@ -989,7 +989,7 @@ int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 			devdbg (dev, "drop, code %d", retval);
 drop:
 		retval = NET_XMIT_SUCCESS;
-		dev->stats.tx_dropped++;
+		dev->net->stats.tx_dropped++;
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
