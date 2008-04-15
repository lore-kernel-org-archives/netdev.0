From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 15:55:06 +0200
Message-ID: <200804151555.06698.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Filip Aben <f.aben@option.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:33212 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759657AbYDONzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 09:55:33 -0400
In-Reply-To: <20080414213238.GB28833@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> Hi all,
> 
> Here's a patch that I have cleaned up for context only from Option that
> is a USB serial / network device all in one.
> 
> I'd like to see this go into 2.6.26, so any review comments by anyone
> who wishes to review any portion of this would be greatly apprecited.

This patch removes a creative abuse of in_interrupt(). Locking
is always done with a mutex now. No need for atomic operations.

Signed-off-by: Oliver Neukum <oneukum@suse.de>

---

--- linux-2.6.25-rc7-work/drivers/net/usb/hso.c.alt2	2008-04-15 15:21:25.000000000 +0200
+++ linux-2.6.25-rc7-work/drivers/net/usb/hso.c	2008-04-15 15:29:17.000000000 +0200
@@ -2201,21 +2201,13 @@ static int hso_stop_serial_device(struct
 		return -ENODEV;
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
-		if (serial->rx_urb[i]
-		    && (serial->rx_urb[i]->status == -EINPROGRESS)) {
-			if (in_interrupt())
-				usb_unlink_urb(serial->rx_urb[i]);
-			else
+		if (serial->rx_urb[i])
 				usb_kill_urb(serial->rx_urb[i]);
-		}
 	}
 
-	if (serial->tx_urb && (serial->tx_urb->status == -EINPROGRESS)) {
-		if (in_interrupt())
-			usb_unlink_urb(serial->tx_urb);
-		else
-			usb_kill_urb(serial->rx_urb[i]);
-	}
+	if (serial->tx_urb)
+		usb_kill_urb(serial->rx_urb[i]);
+
 	if (serial->shared_int) {
 		spin_lock_bh(&serial->shared_int->shared_int_lock);
 		if (serial->shared_int->use_count &&
@@ -2223,12 +2215,8 @@ static int hso_stop_serial_device(struct
 			struct urb *urb;
 
 			urb = serial->shared_int->shared_intr_urb;
-			if ((urb) && (urb->status == -EINPROGRESS)) {
-				if (in_interrupt())
-					usb_unlink_urb(urb);
-				else
-					usb_kill_urb(urb);
-			}
+			if (urb)
+				usb_kill_urb(urb);
 		}
 		spin_unlock_bh(&serial->shared_int->shared_int_lock);
 	}

