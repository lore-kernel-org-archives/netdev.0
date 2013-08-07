From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 2/2] net/usb: catc: allocate URB transfer_buffers as
 separate buffers
Date: Wed, 07 Aug 2013 16:26:34 +0300
Message-ID: <20130807132634.14001.85339.stgit@localhost6.localdomain6>
References: <20130807132629.14001.2370.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from saarni.dnainternet.net ([83.102.40.136]:48082 "EHLO
	saarni.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932921Ab3HGN0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:26:41 -0400
In-Reply-To: <20130807132629.14001.2370.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

URB transfer_buffer must not be allocated as part of larger structure
because DMA coherence issues.

Patch changes catc to allocate tx_buf, rx_buf, irq_buf and ctrl_buf members
as separate buffers.

Patch is only compile tested.

Cc: <stable@vger.kernel.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 drivers/net/usb/catc.c |   30 +++++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index a7d3c1b..26039d6 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -169,10 +169,10 @@ struct catc {
 	unsigned int ctrl_head, ctrl_tail;
 	spinlock_t tx_lock, ctrl_lock;
 
-	u8 tx_buf[2][TX_MAX_BURST * (PKT_SZ + 2)];
-	u8 rx_buf[RX_MAX_BURST * (PKT_SZ + 2)];
-	u8 irq_buf[2];
-	u8 ctrl_buf[64];
+	u8 *tx_buf[2];
+	u8 *rx_buf;
+	u8 *irq_buf;
+	u8 *ctrl_buf;
 	struct usb_ctrlrequest *ctrl_dr;
 
 	struct timer_list timer;
@@ -794,9 +794,15 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	catc = netdev_priv(netdev);
 
 	catc->ctrl_dr = kzalloc(sizeof(*catc->ctrl_dr), GFP_KERNEL);
-	if (!catc->ctrl_dr) {
+	catc->tx_buf[0] = kzalloc(TX_MAX_BURST * (PKT_SZ + 2), GFP_KERNEL);
+	catc->tx_buf[1] = kzalloc(TX_MAX_BURST * (PKT_SZ + 2), GFP_KERNEL);
+	catc->rx_buf = kzalloc(RX_MAX_BURST * (PKT_SZ + 2), GFP_KERNEL);
+	catc->irq_buf = kzalloc(2, GFP_KERNEL);
+	catc->ctrl_buf = kzalloc(64, GFP_KERNEL);
+	if (!catc->ctrl_dr || !catc->ctrl_buf || !catc->tx_buf[0] ||
+	    !catc->tx_buf[1] || !catc->rx_buf || !catc->irq_buf) {
 		err = -ENOMEM;
-		goto err_free_dev;
+		goto err_free_buf;
 	}
 
 	netdev->netdev_ops = &catc_netdev_ops;
@@ -930,8 +936,13 @@ err_free:
 	usb_free_urb(catc->tx_urb);
 	usb_free_urb(catc->rx_urb);
 	usb_free_urb(catc->irq_urb);
+err_free_buf:
+	kfree(catc->ctrl_buf);
+	kfree(catc->irq_buf);
+	kfree(catc->rx_buf);
+	kfree(catc->tx_buf[1]);
+	kfree(catc->tx_buf[0]);
 	kfree(catc->ctrl_dr);
-err_free_dev:
 	free_netdev(netdev);
 
 	return err;
@@ -948,6 +959,11 @@ static void catc_disconnect(struct usb_interface *intf)
 		usb_free_urb(catc->tx_urb);
 		usb_free_urb(catc->rx_urb);
 		usb_free_urb(catc->irq_urb);
+		kfree(catc->ctrl_buf);
+		kfree(catc->irq_buf);
+		kfree(catc->rx_buf);
+		kfree(catc->tx_buf[1]);
+		kfree(catc->tx_buf[0]);
 		kfree(catc->ctrl_dr);
 		free_netdev(catc->netdev);
 	}
