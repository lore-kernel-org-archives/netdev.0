From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 4/6] hso: Attempt to recover from usb bus errors
Date: Tue, 5 Jan 2010 15:52:13 +0100
Message-ID: <20100105145213.GD19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:13558 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab0AEPCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:02:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Attempt to reset the usb device when we receive usb bus errors.

Signed-off-by: Jan Dumon <j.dumon@option.com>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -286,6 +286,7 @@ struct hso_device {
 	u8 usb_gone;
 	struct work_struct async_get_intf;
 	struct work_struct async_put_intf;
+	struct work_struct reset_device;
 
 	struct usb_device *usb;
 	struct usb_interface *interface;
@@ -332,7 +333,8 @@ static void hso_kick_transmit(struct hso
 /* Helper functions */
 static int hso_mux_submit_intr_urb(struct hso_shared_int *mux_int,
 				   struct usb_device *usb, gfp_t gfp);
-static void log_usb_status(int status, const char *function);
+static void handle_usb_error(int status, const char *function,
+			     struct hso_device *hso_dev);
 static struct usb_endpoint_descriptor *hso_get_ep(struct usb_interface *intf,
 						  int type, int dir);
 static int hso_get_mux_ports(struct usb_interface *intf, unsigned char *ports);
@@ -350,6 +352,7 @@ static void async_put_intf(struct work_s
 static int hso_put_activity(struct hso_device *hso_dev);
 static int hso_get_activity(struct hso_device *hso_dev);
 static void tiocmget_intr_callback(struct urb *urb);
+static void reset_device(struct work_struct *data);
 /*****************************************************************************/
 /* Helping functions                                                         */
 /*****************************************************************************/
@@ -664,8 +667,8 @@ static void set_serial_by_index(unsigned
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 }
 
-/* log a meaningful explanation of an USB status */
-static void log_usb_status(int status, const char *function)
+static void handle_usb_error(int status, const char *function,
+			     struct hso_device *hso_dev)
 {
 	char *explanation;
 
@@ -694,10 +697,20 @@ static void log_usb_status(int status, c
 	case -EMSGSIZE:
 		explanation = "internal error";
 		break;
+	case -EILSEQ:
+	case -EPROTO:
+	case -ETIME:
+	case -ETIMEDOUT:
+		explanation = "protocol error";
+		if (hso_dev)
+			schedule_work(&hso_dev->reset_device);
+		break;
 	default:
 		explanation = "unknown status";
 		break;
 	}
+
+	/* log a meaningful explanation of an USB status */
 	D1("%s: received USB status - %s (%d)", function, explanation, status);
 }
 
@@ -771,7 +784,7 @@ static void write_bulk_callback(struct u
 	/* log status, but don't act on it, we don't need to resubmit anything
 	 * anyhow */
 	if (status)
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, odev->parent);
 
 	hso_put_activity(odev->parent);
 
@@ -1007,7 +1020,7 @@ static void read_bulk_callback(struct ur
 
 	/* is al ok?  (Filip: Who's Al ?) */
 	if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, odev->parent);
 		return;
 	}
 
@@ -1217,7 +1230,7 @@ static void hso_std_serial_read_bulk_cal
 		D1("serial == NULL");
 		return;
 	} else if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, serial->parent);
 		return;
 	}
 
@@ -1523,7 +1536,7 @@ static void tiocmget_intr_callback(struc
 	if (!serial)
 		return;
 	if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, serial->parent);
 		return;
 	}
 	tiocmget = serial->tiocmget;
@@ -1898,7 +1911,7 @@ static void intr_callback(struct urb *ur
 
 	/* status check */
 	if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, NULL);
 		return;
 	}
 	D4("\n--- Got intr callback 0x%02X ---", status);
@@ -1968,7 +1981,7 @@ static void hso_std_serial_write_bulk_ca
 	tty = tty_kref_get(serial->tty);
 	spin_unlock(&serial->serial_lock);
 	if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, serial->parent);
 		tty_kref_put(tty);
 		return;
 	}
@@ -2024,7 +2037,7 @@ static void ctrl_callback(struct urb *ur
 	tty = tty_kref_get(serial->tty);
 	spin_unlock(&serial->serial_lock);
 	if (status) {
-		log_usb_status(status, __func__);
+		handle_usb_error(status, __func__, serial->parent);
 		tty_kref_put(tty);
 		return;
 	}
@@ -2401,6 +2414,7 @@ static struct hso_device *hso_create_dev
 
 	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
 	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
+	INIT_WORK(&hso_dev->reset_device, reset_device);
 
 	return hso_dev;
 }
@@ -3143,6 +3157,26 @@ out:
 	return result;
 }
 
+static void reset_device(struct work_struct *data)
+{
+	struct hso_device *hso_dev =
+	    container_of(data, struct hso_device, reset_device);
+	struct usb_device *usb = hso_dev->usb;
+	int result;
+
+	if (hso_dev->usb_gone) {
+		D1("No reset during disconnect\n");
+	} else {
+		result = usb_lock_device_for_reset(usb, hso_dev->interface);
+		if (result < 0)
+			D1("unable to lock device for reset: %d\n", result);
+		else {
+			usb_reset_device(usb);
+			usb_unlock_device(usb);
+		}
+	}
+}
+
 static void hso_serial_ref_free(struct kref *ref)
 {
 	struct hso_device *hso_dev = container_of(ref, struct hso_device, ref);
