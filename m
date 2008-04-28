From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 28 Apr 2008 18:37:46 +0300
Message-ID: <4815EF4A.4040608@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt> <480DED38.3080900@teltonika.lt> <480F3C41.10908@teltonika.lt> <4811CF33.8040007@teltonika.lt> <4811DA4F.30209@teltonika.lt> <4815AC9D.7080009@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030002080505030008000900"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4815AC9D.7080009-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030002080505030008000900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- Oliver patch for rfkill crash (introduced rfkill/mem leak)
- Create rfkill only for network device (fixed rfkill/mem leak)
- Make driver work even if rfkill initialization fails

Greg: What do you think about unified patch?

--------------030002080505030008000900
Content-Type: text/x-patch;
 name="hso_rfkill_network.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_rfkill_network.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-28 12:34:23.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-28 18:02:23.000000000 +0300
@@ -151,6 +151,7 @@ struct hso_shared_int {
 struct hso_net {
 	struct hso_device *parent;
 	struct net_device *net;
+	struct rfkill *rfkill;
 
 	struct usb_endpoint_descriptor *in_endp;
 	struct usb_endpoint_descriptor *out_endp;
@@ -227,7 +228,6 @@ struct hso_device {
 
 	struct usb_device *usb;
 	struct usb_interface *interface;
-	struct rfkill *rfkill;
 
 	struct device *dev;
 	struct kref ref;
@@ -2097,6 +2097,58 @@ static int add_net_device(struct hso_dev
 	return 0;
 }
 
+static int hso_radio_toggle(void *data, enum rfkill_state state)
+{
+	struct hso_device *hso_dev = data;
+	int enabled = (state == RFKILL_STATE_ON);
+	int rv;
+
+	mutex_lock(&hso_dev->mutex);
+	if (hso_dev->usb_gone)
+		rv = 0;
+	else
+		rv = usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
+				       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
+				       USB_CTRL_SET_TIMEOUT);
+	mutex_unlock(&hso_dev->mutex);
+	return rv;
+}
+
+/* Creates and sets up everything for rfkill */
+static void hso_create_rfkill(struct hso_device *hso_dev,
+			     struct usb_interface *interface)
+{
+	struct hso_net *hso_net = dev2net(hso_dev);
+	struct device *dev = hso_dev->dev;
+	char *rfkn;
+
+	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
+				 RFKILL_TYPE_WLAN);
+	if (!hso_net->rfkill) {
+		dev_err(dev, "%s - Out of memory", __func__);
+		return;
+	}
+	rfkn = kzalloc(20, GFP_KERNEL);
+	if (!rfkn) {
+		rfkill_free(hso_net->rfkill);
+		dev_err(dev, "%s - Out of memory", __func__);
+		return;
+	}
+	snprintf(rfkn, 20, "hso-%d",
+		 interface->altsetting->desc.bInterfaceNumber);
+	hso_net->rfkill->name = rfkn;
+	hso_net->rfkill->state = RFKILL_STATE_ON;
+	hso_net->rfkill->data = hso_dev;
+	hso_net->rfkill->toggle_radio = hso_radio_toggle;
+	if (rfkill_register(hso_net->rfkill) < 0) {
+		kfree(rfkn);
+		hso_net->rfkill->name = NULL;
+		rfkill_free(hso_net->rfkill);
+		dev_err(dev, "%s - Failed to register rfkill", __func__);
+		return;
+	}
+}
+
 /* Creates our network device */
 static struct hso_device *hso_create_net_device(struct usb_interface *interface)
 {
@@ -2183,6 +2235,8 @@ static struct hso_device *hso_create_net
 
 	hso_log_port(hso_dev);
 
+	hso_create_rfkill(hso_dev, interface);
+
 	return hso_dev;
 exit:
 	hso_free_net_device(hso_dev);
@@ -2467,30 +2521,12 @@ static int hso_get_config_data(struct us
 	return result;
 }
 
-static int hso_radio_toggle(void *data, enum rfkill_state state)
-{
-	struct hso_device *hso_dev = data;
-	int enabled = (state == RFKILL_STATE_ON);
-	int rv;
-
-	mutex_lock(&hso_dev->mutex);
-	if (hso_dev->usb_gone)
-		rv = 0;
-	else
-		rv = usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
-				       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
-				       USB_CTRL_SET_TIMEOUT);
-	mutex_unlock(&hso_dev->mutex);
-	return rv;
-}
-
 /* called once for each interface upon device insertion */
 static int hso_probe(struct usb_interface *interface,
 		     const struct usb_device_id *id)
 {
 	int mux, i, if_num, port_spec;
 	unsigned char port_mask;
-	char *rfkn;
 	struct hso_device *hso_dev = NULL;
 	struct hso_shared_int *shared_int;
 	struct hso_device *tmp_dev = NULL;
@@ -2563,27 +2599,6 @@ static int hso_probe(struct usb_interfac
 		goto exit;
 	}
 
-	hso_dev->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
-					  RFKILL_TYPE_WLAN);
-	if (!hso_dev->rfkill)
-		goto exit;
-	rfkn = kzalloc(20, GFP_KERNEL);
-	if (!rfkn) {
-		rfkill_free(hso_dev->rfkill);
-		goto exit;
-	}
-	snprintf(rfkn, 20, "hso-%d", if_num);
-	hso_dev->rfkill->name = rfkn;
-	hso_dev->rfkill->state = RFKILL_STATE_ON;
-	hso_dev->rfkill->data = hso_dev;
-	hso_dev->rfkill->toggle_radio = hso_radio_toggle;
-	if (rfkill_register(hso_dev->rfkill) < 0) {
-		kfree(rfkn);
-		hso_dev->rfkill->name = NULL;
-		rfkill_free(hso_dev->rfkill);
-		goto exit;
-	}
-
 	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
 
 	/* save our data pointer in this device */
@@ -2591,7 +2606,6 @@ static int hso_probe(struct usb_interfac
 
 	/* done */
 	return 0;
-
 exit:
 	hso_free_interface(interface);
 	return -ENODEV;
@@ -2600,16 +2614,8 @@ exit:
 /* device removed, cleaning up */
 static void hso_disconnect(struct usb_interface *interface)
 {
-	struct hso_device *hso_dev = usb_get_intfdata(interface);
-
 	hso_free_interface(interface);
 
-	if (hso_dev) {
-		cancel_work_sync(&hso_dev->async_put_intf);
-		cancel_work_sync(&hso_dev->async_get_intf);
-		rfkill_unregister(hso_dev->rfkill);
-	}
--------------030002080505030008000900--
