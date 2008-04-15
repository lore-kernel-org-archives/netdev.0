From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 15:06:19 +0200
Message-ID: <200804151506.21856.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> Hi all,
> 
> Here's a patch that I have cleaned up for context only from Option that
> is a USB serial / network device all in one.
> 
> I'd like to see this go into 2.6.26, so any review comments by anyone
> who wishes to review any portion of this would be greatly apprecited.

This incremental patch fixes a race where write can mess with
an URB while it isn't yet returned.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

---

--- linux-2.6.25-rc7-work/drivers/net/usb/hso.c.alt	2008-04-15 13:59:21.000000000 +0200
+++ linux-2.6.25-rc7-work/drivers/net/usb/hso.c	2008-04-15 14:44:45.000000000 +0200
@@ -220,6 +220,7 @@ struct hso_serial {
 	unsigned long flags;
 	u8 rts_state;
 	u8 dtr_state;
+	int tx_urb_used:1;
 
 	/* from usb_serial_port */
 	struct tty_struct *tty;
@@ -1521,12 +1522,13 @@ static void hso_kick_transmit(struct hso
 {
 	u8 *temp = NULL;
 	unsigned long flags;
+	int res;
 
 	spin_lock_irqsave(&serial->serial_lock, flags);
 	if (!serial->tx_buffer_count)
 		goto out;
 
-	if (serial->tx_urb->status == -EINPROGRESS)
+	if (serial->tx_urb_used)
 		goto out;
 
 	/* Wakeup USB interface if necessary */
@@ -1540,10 +1542,13 @@ static void hso_kick_transmit(struct hso
 	serial->tx_data_count = serial->tx_buffer_count;
 	serial->tx_buffer_count = 0;
 
-out:
 	/* If temp is set, it means we switched buffers */
-	if (temp && serial->write_data)
-		serial->write_data(serial);
+	if (temp && serial->write_data) {
+		res = serial->write_data(serial);
+		if (res >= 0)
+			serial->tx_urb_used = 1;
+	}
+out:
 	spin_unlock_irqrestore(&serial->serial_lock, flags);
 }
 
@@ -1783,6 +1788,9 @@ static void ctrl_callback(struct urb *ur
 	if (!serial)
 		return;
 
+	spin_lock(&serial->serial_lock);
+	serial->tx_urb_used = 0;
+	spin_unlock(&serial->serial_lock);
 	if (status) {
 		log_usb_status(status, __func__);
 		return;
@@ -1914,6 +1922,9 @@ static void hso_std_serial_write_bulk_ca
 		return;
 	}
 
+	spin_lock(&serial->serial_lock);
+	serial->tx_urb_used = 0;
+	spin_unlock(&serial->serial_lock);
 	if (status) {
 		log_usb_status(status, __func__);
 		return;
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
