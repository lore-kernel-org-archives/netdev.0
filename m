From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 1/2] net/usb: hso: allocate URB setup_packets as separate
 buffers
Date: Wed, 07 Aug 2013 16:29:02 +0300
Message-ID: <20130807132902.14451.37517.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jan Dumon <j.dumon@option.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirokuusama.dnainternet.net ([83.102.40.133]:49573 "EHLO
	sirokuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933018Ab3HGN3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:29:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

URB setup packets must not be allocated as part of larger structure because
DMA coherence issues.

Patch changes hso to allocate ctrl_req_[tr]x members of 'struct hso_serial'
as separate buffers.

Patch is only compile tested.

Cc: <stable@vger.kernel.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 drivers/net/usb/hso.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index cba1d46..fc082c0 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -237,8 +237,8 @@ struct hso_serial {
 	u16 tx_data_length;	/* should contain allocated length */
 	u16 tx_data_count;
 	u16 tx_buffer_count;
-	struct usb_ctrlrequest ctrl_req_tx;
-	struct usb_ctrlrequest ctrl_req_rx;
+	struct usb_ctrlrequest *ctrl_req_tx;
+	struct usb_ctrlrequest *ctrl_req_rx;
 
 	struct usb_endpoint_descriptor *in_endp;
 	struct usb_endpoint_descriptor *out_endp;
@@ -1847,7 +1847,7 @@ static int hso_mux_serial_read(struct hso_serial *serial)
 				  USB_CDC_GET_ENCAPSULATED_RESPONSE,
 				  serial->parent->port_spec & HSO_PORT_MASK,
 				  serial->rx_urb[0],
-				  &serial->ctrl_req_rx,
+				  serial->ctrl_req_rx,
 				  serial->rx_data[0], serial->rx_data_length);
 }
 
@@ -1916,7 +1916,7 @@ static int hso_mux_serial_write_data(struct hso_serial *serial)
 				  USB_CDC_SEND_ENCAPSULATED_COMMAND,
 				  serial->parent->port_spec & HSO_PORT_MASK,
 				  serial->tx_urb,
-				  &serial->ctrl_req_tx,
+				  serial->ctrl_req_tx,
 				  serial->tx_data, serial->tx_data_count);
 }
 
@@ -2264,6 +2264,10 @@ static void hso_serial_common_free(struct hso_serial *serial)
 	usb_free_urb(serial->tx_urb);
 	kfree(serial->tx_data);
 	tty_port_destroy(&serial->port);
+
+	/* free control URB setup packet buffers */
+	kfree(serial->ctrl_req_tx);
+	kfree(serial->ctrl_req_rx);
 }
 
 static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
@@ -2292,6 +2296,12 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 	spin_lock_init(&serial->serial_lock);
 	serial->num_rx_urbs = num_urbs;
 
+	/* allocate control URB setup packet buffers */
+	serial->ctrl_req_tx = kzalloc(sizeof(*serial->ctrl_req_tx), GFP_KERNEL);
+	serial->ctrl_req_rx = kzalloc(sizeof(*serial->ctrl_req_rx), GFP_KERNEL);
+	if (!serial->ctrl_req_tx || !serial->ctrl_req_rx)
+		goto exit;
+
 	/* RX, allocate urb and initialize */
 
 	/* prepare our RX buffer */
