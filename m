From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 15/50] USB: serial: mos77840: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:38 +0800
Message-ID: <1373533573-12272-16-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54503 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170Ab3GKJIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:08:38 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/mos7840.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/mos7840.c b/drivers/usb/serial/mos7840.c
index 0a818b2..f21dcd0 100644
--- a/drivers/usb/serial/mos7840.c
+++ b/drivers/usb/serial/mos7840.c
@@ -788,17 +788,18 @@ static void mos7840_bulk_out_data_callback(struct urb *urb)
 	struct usb_serial_port *port;
 	int status = urb->status;
 	int i;
+	unsigned long flags;
 
 	mos7840_port = urb->context;
 	port = mos7840_port->port;
-	spin_lock(&mos7840_port->pool_lock);
+	spin_lock_irqsave(&mos7840_port->pool_lock, flags);
 	for (i = 0; i < NUM_URBS; i++) {
 		if (urb == mos7840_port->write_urb_pool[i]) {
 			mos7840_port->busy[i] = 0;
 			break;
 		}
 	}
-	spin_unlock(&mos7840_port->pool_lock);
+	spin_unlock_irqrestore(&mos7840_port->pool_lock, flags);
 
 	if (status) {
 		dev_dbg(&port->dev, "nonzero write bulk status received:%d\n", status);
-- 
1.7.9.5
