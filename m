From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/6] can: kvaser_usb: Avoid double free on URB submission failures
Date: Mon,  9 Mar 2015 10:36:18 +0100
Message-ID: <1425893781-10867-4-git-send-email-mkl@pengutronix.de>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Upon a URB submission failure, the driver calls usb_free_urb()
but then manually frees the URB buffer by itself.  Meanwhile
usb_free_urb() has alredy freed out that transfer buffer since
we're the only code path holding a reference to this URB.

Remove two of such invalid manual free().

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 2928f7003041..d986fe83c40d 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -787,7 +787,6 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 		netdev_err(netdev, "Error transmitting URB\n");
 		usb_unanchor_urb(urb);
 		usb_free_urb(urb);
-		kfree(buf);
 		return err;
 	}
 
@@ -1615,8 +1614,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	struct urb *urb;
 	void *buf;
 	struct kvaser_msg *msg;
-	int i, err;
-	int ret = NETDEV_TX_OK;
+	int i, err, ret = NETDEV_TX_OK;
 	u8 *msg_tx_can_flags = NULL;		/* GCC */
 
 	if (can_dropped_invalid_skb(netdev, skb))
@@ -1634,7 +1632,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	if (!buf) {
 		stats->tx_dropped++;
 		dev_kfree_skb(skb);
-		goto nobufmem;
+		goto freeurb;
 	}
 
 	msg = buf;
@@ -1681,8 +1679,10 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	/* This should never happen; it implies a flow control bug */
 	if (!context) {
 		netdev_warn(netdev, "cannot find free context\n");
+
+		kfree(buf);
 		ret =  NETDEV_TX_BUSY;
-		goto releasebuf;
+		goto freeurb;
 	}
 
 	context->priv = priv;
@@ -1719,16 +1719,12 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 		else
 			netdev_warn(netdev, "Failed tx_urb %d\n", err);
 
-		goto releasebuf;
+		goto freeurb;
 	}
 
-	usb_free_urb(urb);
-
-	return NETDEV_TX_OK;
+	ret = NETDEV_TX_OK;
 
-releasebuf:
-	kfree(buf);
-nobufmem:
+freeurb:
 	usb_free_urb(urb);
 	return ret;
 }
-- 
2.1.4

