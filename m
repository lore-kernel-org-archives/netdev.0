From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Wed, 16 Apr 2008 15:43:21 +0200
Message-ID: <200804161543.23584.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804161403.20955.oliver@neukum.org> <4805ED16.3080104@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4805ED16.3080104-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 16. April 2008 14:12:06 schrieb Paulius Zaleckas:
> I always get crash when closing serial terminal application. I will
> post dump in couple minutes.

Does this fix it?

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

---

--- linux-2.6.25-hso/drivers/net/usb/hso.c.alt3	2008-04-16 14:01:22.000000000 +0200
+++ linux-2.6.25-hso/drivers/net/usb/hso.c	2008-04-16 15:39:24.000000000 +0200
@@ -156,7 +156,7 @@ struct hso_shared_int {
 	struct usb_device *usb;
 	int use_count;
 	int ref_count;
-	spinlock_t shared_int_lock;
+	struct mutex shared_int_lock;
 };
 
 struct hso_net {
@@ -2040,14 +2040,14 @@ static int hso_start_serial_device(struc
 			}
 		}
 	} else {
-		spin_lock_bh(&serial->shared_int->shared_int_lock);
+		mutex_lock(&serial->shared_int->shared_int_lock);
 		if (!serial->shared_int->use_count) {
 			result =
 			    hso_mux_submit_intr_urb(serial->shared_int,
-						    hso_dev->usb, GFP_ATOMIC);
+						    hso_dev->usb, flags);
 		}
 		serial->shared_int->use_count++;
-		spin_unlock_bh(&serial->shared_int->shared_int_lock);
+		mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
 
 	return result;
@@ -2070,7 +2070,7 @@ static int hso_stop_serial_device(struct
 		usb_kill_urb(serial->rx_urb[i]);
 
 	if (serial->shared_int) {
-		spin_lock_bh(&serial->shared_int->shared_int_lock);
+		mutex_lock(&serial->shared_int->shared_int_lock);
 		if (serial->shared_int->use_count &&
 		    (--serial->shared_int->use_count == 0)) {
 			struct urb *urb;
@@ -2079,7 +2079,7 @@ static int hso_stop_serial_device(struct
 			if (urb)
 				usb_kill_urb(urb);
 		}
-		spin_unlock_bh(&serial->shared_int->shared_int_lock);
+		mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
 
 	return 0;
@@ -2352,10 +2352,10 @@ static void hso_free_serial_device(struc
 	hso_serial_common_free(serial);
 
 	if (serial->shared_int) {
-		spin_lock_bh(&serial->shared_int->shared_int_lock);
+		mutex_lock(&serial->shared_int->shared_int_lock);
 		if (--serial->shared_int->ref_count == 0)
 			hso_free_shared_int(serial->shared_int);
-		spin_unlock_bh(&serial->shared_int->shared_int_lock);
+		mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
 	kfree(serial);
 	hso_free_device(hso_dev);
@@ -2468,9 +2468,9 @@ struct hso_device *hso_create_mux_serial
 	serial->write_data = hso_mux_serial_write_data;
 
 	serial->shared_int = mux;
-	spin_lock_bh(&serial->shared_int->shared_int_lock);
+	mutex_lock(&serial->shared_int->shared_int_lock);
 	serial->shared_int->ref_count++;
-	spin_unlock_bh(&serial->shared_int->shared_int_lock);
+	mutex_unlock(&serial->shared_int->shared_int_lock);
 
 	/* and record this serial */
 	set_serial_by_index(serial->minor, serial);
@@ -2535,7 +2535,7 @@ struct hso_shared_int *hso_create_shared
 		goto exit;
 	}
 
-	spin_lock_init(&mux->shared_int_lock);
+	mutex_init(&mux->shared_int_lock);
 
 	return mux;
 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
