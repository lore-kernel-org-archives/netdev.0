From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/8] can: kvaser_usb: Reset all URB tx contexts upon channel close
Date: Thu, 15 Jan 2015 17:11:21 +0100
Message-ID: <1421338283-12417-7-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Flooding the Kvaser CAN to USB dongle with multiple reads and
writes in very high frequency (*), closing the CAN channel while
all the transmissions are on (#), opening the device again (@),
then sending a small number of packets would make the driver
enter an almost infinite loop of:

[....]
[15959.853988] kvaser_usb 4-3:1.0 can0: cannot find free context
[15959.853990] kvaser_usb 4-3:1.0 can0: cannot find free context
[15959.853991] kvaser_usb 4-3:1.0 can0: cannot find free context
[15959.853993] kvaser_usb 4-3:1.0 can0: cannot find free context
[15959.853994] kvaser_usb 4-3:1.0 can0: cannot find free context
[15959.853995] kvaser_usb 4-3:1.0 can0: cannot find free context
[....]

_dragging the whole system down_ in the process due to the
excessive logging output.

Initially, this has caused random panics in the kernel due to a
buggy error recovery path.  That got fixed in an earlier commit.(%)
This patch aims at solving the root cause. -->

16 tx URBs and contexts are allocated per CAN channel per USB
device. Such URBs are protected by:

a) A simple atomic counter, up to a value of MAX_TX_URBS (16)
b) A flag in each URB context, stating if it's free
c) The fact that ndo_start_xmit calls are themselves protected
   by the networking layers higher above

After grabbing one of the tx URBs, if the driver noticed that all
of them are now taken, it stops the netif transmission queue.
Such queue is worken up again only if an acknowedgment was received
from the firmware on one of our earlier-sent frames.

Meanwhile, upon channel close (#), the driver sends a CMD_STOP_CHIP
to the firmware, effectively closing all further communication.  In
the high traffic case, the atomic counter remains at MAX_TX_URBS,
and all the URB contexts remain marked as active.  While opening
the channel again (@), it cannot send any further frames since no
more free tx URB contexts are available.

Reset all tx URB contexts upon CAN channel close.

(*) 50 parallel instances of `cangen0 -g 0 -ix`
(#) `ifconfig can0 down`
(@) `ifconfig can0 up`
(%) "can: kvaser_usb: Don't free packets when tight on URBs"

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 2e7d513a7c11..9accc8272c27 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1246,6 +1246,9 @@ static int kvaser_usb_close(struct net_device *netdev)
 	if (err)
 		netdev_warn(netdev, "Cannot stop device, error %d\n", err);
 
+	/* reset tx contexts */
+	kvaser_usb_unlink_tx_urbs(priv);
+
 	priv->can.state = CAN_STATE_STOPPED;
 	close_candev(priv->netdev);
 
-- 
2.1.4

