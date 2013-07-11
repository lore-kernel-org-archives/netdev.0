From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 13/50] USB: serial: io_ti: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:36 +0800
Message-ID: <1373533573-12272-14-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41757 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140Ab3GKJIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:08:22 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/io_ti.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/io_ti.c b/drivers/usb/serial/io_ti.c
index 60054e7..4943194 100644
--- a/drivers/usb/serial/io_ti.c
+++ b/drivers/usb/serial/io_ti.c
@@ -1615,6 +1615,7 @@ static void edge_bulk_in_callback(struct urb *urb)
 	int retval = 0;
 	int port_number;
 	int status = urb->status;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -1663,13 +1664,13 @@ static void edge_bulk_in_callback(struct urb *urb)
 
 exit:
 	/* continue read unless stopped */
-	spin_lock(&edge_port->ep_lock);
+	spin_lock_irqsave(&edge_port->ep_lock, flags);
 	if (edge_port->ep_read_urb_state == EDGE_READ_URB_RUNNING)
 		retval = usb_submit_urb(urb, GFP_ATOMIC);
 	else if (edge_port->ep_read_urb_state == EDGE_READ_URB_STOPPING)
 		edge_port->ep_read_urb_state = EDGE_READ_URB_STOPPED;
 
-	spin_unlock(&edge_port->ep_lock);
+	spin_unlock_irqrestore(&edge_port->ep_lock, flags);
 	if (retval)
 		dev_err(dev, "%s - usb_submit_urb failed with result %d\n", __func__, retval);
 }
-- 
1.7.9.5
