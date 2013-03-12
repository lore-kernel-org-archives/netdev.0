From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH] qmi_wwan: set correct altsetting for Gobi 1K devices
Date: Tue, 12 Mar 2013 14:40:05 -0500
Message-ID: <1363117205.9644.17.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With Gobi 1K devices, USB interface #3's altsetting is 0 by default, but
altsetting 0 only provides one interrupt endpoint and is not sufficent
for QMI.  Altsetting 1 provides all 3 endpoints required for qmi_wwan
and works with QMI.

IIRC the altsetting used to be set by qcserial back before we made
qcserial stop touching interfaces that qmi_wwan was going to use.  But
now that qcserial only touches the modem interface, we need qmi_wwan to
set the correct altsetting on the QMI interface.

The attached patch works for my Gobi1K (and should work for all other
1Ks too) but seems somewhat ugly.  What approach should we take?
Basically, we need to know that a device is Gobi1K at probe time so we
can set the right altsetting on it.

Gobi 1K layout for intf#3 is:

    Interface Descriptor:  255/255/255
      bInterfaceNumber        3
      bAlternateSetting       0
      Endpoint Descriptor:  Interrupt IN
    Interface Descriptor:  255/255/255
      bInterfaceNumber        3
      bAlternateSetting       1
      Endpoint Descriptor:  Interrupt IN
      Endpoint Descriptor:  Bulk IN
      Endpoint Descriptor:  Bulk OUT

Dan

---
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index efb5c7c..50e1b7c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -43,6 +43,9 @@
  * commands on a serial interface
  */
 
+/* Quirks for the usbnet 'struct driver_info' data field */
+#define QUIRK_GOBI_1K  (1 << 0)   /* QMI interface requires altsetting 1 */
+
 /* driver specific data */
 struct qmi_wwan_state {
 	struct usb_driver *subdriver;
@@ -326,6 +329,15 @@ static const struct driver_info	qmi_wwan_info = {
 	.manage_power	= qmi_wwan_manage_power,
 };
 
+static const struct driver_info	gobi1k_info = {
+	.description	= "WWAN/QMI device",
+	.flags		= FLAG_WWAN,
+	.bind		= qmi_wwan_bind,
+	.unbind		= qmi_wwan_unbind,
+	.manage_power	= qmi_wwan_manage_power,
+	.data           = QUIRK_GOBI_1K,
+};
+
 #define HUAWEI_VENDOR_ID	0x12D1
 
 /* map QMI/wwan function by a fixed interface number */
@@ -335,7 +347,8 @@ static const struct driver_info	qmi_wwan_info = {
 
 /* Gobi 1000 QMI/wwan interface number is 3 according to qcserial */
 #define QMI_GOBI1K_DEVICE(vend, prod) \
-	QMI_FIXED_INTF(vend, prod, 3)
+	USB_DEVICE_INTERFACE_NUMBER(vend, prod, 3), \
+	.driver_info = (unsigned long)&gobi1k_info
 
 /* Gobi 2000/3000 QMI/wwan interface number is 0 according to qcserial */
 #define QMI_GOBI_DEVICE(vend, prod) \
@@ -541,6 +554,9 @@ MODULE_DEVICE_TABLE(usb, products);
 static int qmi_wwan_probe(struct usb_interface *intf, const struct usb_device_id *prod)
 {
 	struct usb_device_id *id = (struct usb_device_id *)prod;
+	struct driver_info *info;
+	u8 intf_num = intf->cur_altsetting->desc.bInterfaceNumber;
+	int retval;
 
 	/* Workaround to enable dynamic IDs.  This disables usbnet
 	 * blacklisting functionality.  Which, if required, can be
@@ -552,6 +568,20 @@ static int qmi_wwan_probe(struct usb_interface *intf, const struct usb_device_id
 		id->driver_info = (unsigned long)&qmi_wwan_info;
 	}
 
+	info = (struct driver_info *) id->driver_info;
+	if (info->data & QUIRK_GOBI_1K) {
+		/* Gobi 1K's QMI interface is always USB interface #3 */
+		BUG_ON(intf_num != 3);
+
+		retval = usb_set_interface(interface_to_usbdev (intf),
+					   intf_num, 1);
+		if (retval < 0) {
+			dev_err(&intf->dev, "Failed to set altsetting 1: %d\n",
+			        retval);
+			return -ENODEV;
+		}
+	}
+
 	return usbnet_probe(intf, id);
 }
 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
