From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v2 2/4] can: kvaser_usb: Reset all URB tx contexts upon
 channel close
Date: Thu, 25 Dec 2014 01:59:54 +0200
Message-ID: <20141224235954.GA24302@vivalin-002>
References: <20141223154654.GB6460@vivalin-002>
 <20141224235644.GA3778@vivalin-002>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux-stable <stable@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141224235644.GA3778@vivalin-002>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

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
---
 drivers/net/can/usb/kvaser_usb.c | 3 +++
 1 file changed, 3 insertions(+)

 (Marc, Greg, this also should be added to -stable?)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 6479a2b..598e251 100644
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
 
