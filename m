From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 12/50] USB: serial: io_edgeport: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:35 +0800
Message-ID: <1373533573-12272-13-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Johan Hovold <jhovold@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41015 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:08:15 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/io_edgeport.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/serial/io_edgeport.c b/drivers/usb/serial/io_edgeport.c
index dc2803b..af2f7d8 100644
--- a/drivers/usb/serial/io_edgeport.c
+++ b/drivers/usb/serial/io_edgeport.c
@@ -569,6 +569,7 @@ static void edge_interrupt_callback(struct urb *urb)
 	int portNumber;
 	int result;
 	int status = urb->status;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -594,7 +595,7 @@ static void edge_interrupt_callback(struct urb *urb)
 		if (length > 1) {
 			bytes_avail = data[0] | (data[1] << 8);
 			if (bytes_avail) {
-				spin_lock(&edge_serial->es_lock);
+				spin_lock_irqsave(&edge_serial->es_lock, flags);
 				edge_serial->rxBytesAvail += bytes_avail;
 				dev_dbg(dev,
 					"%s - bytes_avail=%d, rxBytesAvail=%d, read_in_progress=%d\n",
@@ -617,7 +618,7 @@ static void edge_interrupt_callback(struct urb *urb)
 						edge_serial->read_in_progress = false;
 					}
 				}
-				spin_unlock(&edge_serial->es_lock);
+				spin_unlock_irqrestore(&edge_serial->es_lock, flags);
 			}
 		}
 		/* grab the txcredits for the ports if available */
@@ -630,9 +631,9 @@ static void edge_interrupt_callback(struct urb *urb)
 				port = edge_serial->serial->port[portNumber];
 				edge_port = usb_get_serial_port_data(port);
 				if (edge_port->open) {
-					spin_lock(&edge_port->ep_lock);
+					spin_lock_irqsave(&edge_port->ep_lock, flags);
 					edge_port->txCredits += txCredits;
-					spin_unlock(&edge_port->ep_lock);
+					spin_unlock_irqrestore(&edge_port->ep_lock, flags);
 					dev_dbg(dev, "%s - txcredits for port%d = %d\n",
 						__func__, portNumber,
 						edge_port->txCredits);
@@ -673,6 +674,7 @@ static void edge_bulk_in_callback(struct urb *urb)
 	int			retval;
 	__u16			raw_data_length;
 	int status = urb->status;
+	unsigned long flags;
 
 	if (status) {
 		dev_dbg(&urb->dev->dev, "%s - nonzero read bulk status received: %d\n",
@@ -692,7 +694,7 @@ static void edge_bulk_in_callback(struct urb *urb)
 
 	usb_serial_debug_data(dev, __func__, raw_data_length, data);
 
-	spin_lock(&edge_serial->es_lock);
+	spin_lock_irqsave(&edge_serial->es_lock, flags);
 
 	/* decrement our rxBytes available by the number that we just got */
 	edge_serial->rxBytesAvail -= raw_data_length;
@@ -716,7 +718,7 @@ static void edge_bulk_in_callback(struct urb *urb)
 		edge_serial->read_in_progress = false;
 	}
 
-	spin_unlock(&edge_serial->es_lock);
+	spin_unlock_irqrestore(&edge_serial->es_lock, flags);
 }
 
 
-- 
1.7.9.5
