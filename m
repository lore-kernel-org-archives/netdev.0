From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] hso: remove some dead code
Date: Thu, 6 Feb 2014 15:53:19 +0300
Message-ID: <20140206125319.GC16998@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22279 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078AbaBFMx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 07:53:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems like this function was intended to have special handling for
urb statuses of -ENOENT and -ECONNRESET.  But now it just prints some
debugging and returns at the start of the function.

I have removed the dead code, it's still in the git history if anyone
wants to revive it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1a482344b3f5..660bd5ea9fc0 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1201,16 +1201,18 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 	struct hso_serial *serial = urb->context;
 	int status = urb->status;
 
+	D4("\n--- Got serial_read_bulk callback %02x ---", status);
+
 	/* sanity check */
 	if (!serial) {
 		D1("serial == NULL");
 		return;
-	} else if (status) {
+	}
+	if (status) {
 		handle_usb_error(status, __func__, serial->parent);
 		return;
 	}
 
-	D4("\n--- Got serial_read_bulk callback %02x ---", status);
 	D1("Actual length = %d\n", urb->actual_length);
 	DUMP1(urb->transfer_buffer, urb->actual_length);
 
@@ -1218,25 +1220,13 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 	if (serial->port.count == 0)
 		return;
 
-	if (status == 0) {
-		if (serial->parent->port_spec & HSO_INFO_CRC_BUG)
-			fix_crc_bug(urb, serial->in_endp->wMaxPacketSize);
-		/* Valid data, handle RX data */
-		spin_lock(&serial->serial_lock);
-		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
-		put_rxbuf_data_and_resubmit_bulk_urb(serial);
-		spin_unlock(&serial->serial_lock);
-	} else if (status == -ENOENT || status == -ECONNRESET) {
-		/* Unlinked - check for throttled port. */
-		D2("Port %d, successfully unlinked urb", serial->minor);
-		spin_lock(&serial->serial_lock);
-		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
-		hso_resubmit_rx_bulk_urb(serial, urb);
-		spin_unlock(&serial->serial_lock);
-	} else {
-		D2("Port %d, status = %d for read urb", serial->minor, status);
-		return;
-	}
+	if (serial->parent->port_spec & HSO_INFO_CRC_BUG)
+		fix_crc_bug(urb, serial->in_endp->wMaxPacketSize);
+	/* Valid data, handle RX data */
+	spin_lock(&serial->serial_lock);
+	serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
+	put_rxbuf_data_and_resubmit_bulk_urb(serial);
+	spin_unlock(&serial->serial_lock);
 }
 
 /*
