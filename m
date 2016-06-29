From: soohoon.lee@f5.com
Subject: [PATCH net v2.3] usbnet: Stop RX Q on MTU change
Date: Wed, 29 Jun 2016 14:34:35 -0400
Message-ID: <577414bb.o1qSY2+aiAIlmqij%soohoon.lee@f5.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.f5.com ([208.85.209.139]:13468 "EHLO mail.f5.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbcF2Skt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 14:40:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



When MTU is changed unlink_urbs() flushes RX Q but mean while usbnet_bh() can fill up the Q at the same time.
Depends on which HCD is down there unlink takes long time then the flush never ends.

Signed-off-by: Soohoon Lee <soohoon.lee@f5.com>
Reviewed-by: Kimball Murray <kmurray@f5.com>

---
 drivers/net/usb/usbnet.c |    6 +++++-
  1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 61ba464..ce72dd0 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -395,8 +395,11 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 	if (dev->rx_urb_size == old_hard_mtu) {
 		dev->rx_urb_size = dev->hard_mtu;
-		if (dev->rx_urb_size > old_rx_urb_size)
+		if (dev->rx_urb_size > old_rx_urb_size) {
+			usbnet_pause_rx(dev);
 			usbnet_unlink_rx_urbs(dev);
+			usbnet_resume_rx(dev);
+		}
 	}
 
 	/* max qlen depend on hard_mtu and rx_urb_size */
@@ -1509,6 +1512,7 @@ static void usbnet_bh (unsigned long param)
 		   netif_device_present (dev->net) &&
 		   netif_carrier_ok(dev->net) &&
 		   !timer_pending (&dev->delay) &&
+		   !test_bit (EVENT_RX_PAUSED, &dev->flags) &&
 		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
 
