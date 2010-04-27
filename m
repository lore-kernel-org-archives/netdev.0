From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ipheth: potential null dereferences on error path
Date: Tue, 27 Apr 2010 11:20:12 +0200
Message-ID: <20100427092012.GA29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	=?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Diego Giagio <diego@giagio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:64932 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab0D0JVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 05:21:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calls to usb_free_buffer() dereference rx_urb and tx_urb in the
parameter list but those could be NULL.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index fd10331..418825d 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -122,25 +122,25 @@ static int ipheth_alloc_urbs(struct ipheth_device *iphone)
 
 	tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (tx_urb == NULL)
-		goto error;
+		goto error_nomem;
 
 	rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (rx_urb == NULL)
-		goto error;
+		goto free_tx_urb;
 
 	tx_buf = usb_buffer_alloc(iphone->udev,
 				  IPHETH_BUF_SIZE,
 				  GFP_KERNEL,
 				  &tx_urb->transfer_dma);
 	if (tx_buf == NULL)
-		goto error;
+		goto free_rx_urb;
 
 	rx_buf = usb_buffer_alloc(iphone->udev,
 				  IPHETH_BUF_SIZE,
 				  GFP_KERNEL,
 				  &rx_urb->transfer_dma);
 	if (rx_buf == NULL)
-		goto error;
+		goto free_tx_buf;
 
 
 	iphone->tx_urb = tx_urb;
@@ -149,13 +149,14 @@ static int ipheth_alloc_urbs(struct ipheth_device *iphone)
 	iphone->rx_buf = rx_buf;
 	return 0;
 
-error:
-	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, rx_buf,
-			rx_urb->transfer_dma);
+free_tx_buf:
 	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, tx_buf,
 			tx_urb->transfer_dma);
+free_rx_urb:
 	usb_free_urb(rx_urb);
+free_tx_urb:
 	usb_free_urb(tx_urb);
+error_nomem:
 	return -ENOMEM;
 }
 
