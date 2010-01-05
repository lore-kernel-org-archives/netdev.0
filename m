From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 2/6] hso: Fix for endian issues on big endian machines
Date: Tue, 5 Jan 2010 15:51:02 +0100
Message-ID: <20100105145102.GB19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:45268 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab0AEPBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:01:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Some fields are always little endian and have to be converted on big endian
machines.

Signed-off-by: Jan Dumon <j.dumon@option.com>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -1028,7 +1028,8 @@ static void read_bulk_callback(struct ur
 	if (odev->parent->port_spec & HSO_INFO_CRC_BUG) {
 		u32 rest;
 		u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
-		rest = urb->actual_length % odev->in_endp->wMaxPacketSize;
+		rest = urb->actual_length %
+			le16_to_cpu(odev->in_endp->wMaxPacketSize);
 		if (((rest == 5) || (rest == 6)) &&
 		    !memcmp(((u8 *) urb->transfer_buffer) +
 			    urb->actual_length - 4, crc_check, 4)) {
@@ -1234,7 +1235,7 @@ static void hso_std_serial_read_bulk_cal
 			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
 			rest =
 			    urb->actual_length %
-			    serial->in_endp->wMaxPacketSize;
+			    le16_to_cpu(serial->in_endp->wMaxPacketSize);
 			if (((rest == 5) || (rest == 6)) &&
 			    !memcmp(((u8 *) urb->transfer_buffer) +
 				    urb->actual_length - 4, crc_check, 4)) {
@@ -2843,8 +2844,9 @@ struct hso_shared_int *hso_create_shared
 		dev_err(&interface->dev, "Could not allocate intr urb?");
 		goto exit;
 	}
-	mux->shared_intr_buf = kzalloc(mux->intr_endp->wMaxPacketSize,
-				       GFP_KERNEL);
+	mux->shared_intr_buf =
+		kzalloc(le16_to_cpu(mux->intr_endp->wMaxPacketSize),
+			GFP_KERNEL);
 	if (!mux->shared_intr_buf) {
 		dev_err(&interface->dev, "Could not allocate intr buf?");
 		goto exit;
@@ -3241,7 +3243,7 @@ static int hso_mux_submit_intr_urb(struc
 			 usb_rcvintpipe(usb,
 				shared_int->intr_endp->bEndpointAddress & 0x7F),
 			 shared_int->shared_intr_buf,
-			 shared_int->intr_endp->wMaxPacketSize,
+			 1,
 			 intr_callback, shared_int,
 			 shared_int->intr_endp->bInterval);
 
