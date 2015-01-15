From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/8] can: kvaser_usb: Don't free packets when tight on URBs
Date: Thu, 15 Jan 2015 17:11:20 +0100
Message-ID: <1421338283-12417-6-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Flooding the Kvaser CAN to USB dongle with multiple reads and
writes in high frequency caused seemingly-random panics in the
kernel.

On further inspection, it seems the driver erroneously freed the
to-be-transmitted packet upon getting tight on URBs and returning
NETDEV_TX_BUSY, leading to invalid memory writes and double frees
at a later point in time.

Note:

Finding no more URBs/transmit-contexts and returning NETDEV_TX_BUSY
is a driver bug in and out of itself: it means that our start/stop
queue flow control is broken.

This patch only fixes the (buggy) error handling code; the root
cause shall be fixed in a later commit.

Acked-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 541fb7a05625..2e7d513a7c11 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1294,12 +1294,14 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	if (!urb) {
 		netdev_err(netdev, "No memory left for URBs\n");
 		stats->tx_dropped++;
-		goto nourbmem;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
 	if (!buf) {
 		stats->tx_dropped++;
+		dev_kfree_skb(skb);
 		goto nobufmem;
 	}
 
@@ -1334,6 +1336,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* This should never happen; it implies a flow control bug */
 	if (!context) {
 		netdev_warn(netdev, "cannot find free context\n");
 		ret =  NETDEV_TX_BUSY;
@@ -1364,9 +1367,6 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	if (unlikely(err)) {
 		can_free_echo_skb(netdev, context->echo_index);
 
-		skb = NULL; /* set to NULL to avoid double free in
-			     * dev_kfree_skb(skb) */
-
 		atomic_dec(&priv->active_tx_urbs);
 		usb_unanchor_urb(urb);
 
@@ -1388,8 +1388,6 @@ releasebuf:
 	kfree(buf);
 nobufmem:
 	usb_free_urb(urb);
-nourbmem:
-	dev_kfree_skb(skb);
 	return ret;
 }
 
-- 
2.1.4
