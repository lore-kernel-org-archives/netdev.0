From: Oliver Neukum <oliver@neukum.org>
Subject: hso driver
Date: Wed, 16 Apr 2008 16:24:27 +0200
Message-ID: <200804161624.28582.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:35529 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757896AbYDPOUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 10:20:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this fixes a locking bug Paulius reported.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum@suse.de>

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
 
