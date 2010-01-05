From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 3/6] hso: don't change the state of a closed port
Date: Tue, 5 Jan 2010 15:51:28 +0100
Message-ID: <20100105145127.GC19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:46230 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727Ab0AEPBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:01:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Don't change the state of a port if it's not open. This fixes an issue where a
port sometimes has to be opened twice before data can be received.

Signed-off-by: Jan Dumon <j.dumon@option.com>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -1915,18 +1915,18 @@ static void intr_callback(struct urb *ur
 			if (serial != NULL) {
 				D1("Pending read interrupt on port %d\n", i);
 				spin_lock(&serial->serial_lock);
-				if (serial->rx_state == RX_IDLE) {
+				if (serial->rx_state == RX_IDLE &&
+					serial->open_count > 0) {
 					/* Setup and send a ctrl req read on
 					 * port i */
-				if (!serial->rx_urb_filled[0]) {
+					if (!serial->rx_urb_filled[0]) {
 						serial->rx_state = RX_SENT;
 						hso_mux_serial_read(serial);
 					} else
 						serial->rx_state = RX_PENDING;
-
 				} else {
-					D1("Already pending a read on "
-					   "port %d\n", i);
+					D1("Already a read pending on "
+					   "port %d or port not open\n", i);
 				}
 				spin_unlock(&serial->serial_lock);
 			}
