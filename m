From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 2/5] cdc-acm: use the common parser
Date: Thu, 14 Jul 2016 15:41:31 +0200
Message-ID: <1468503694-9482-3-git-send-email-oneukum@suse.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregKH-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This introduces the common parser for extra CDC headers now that it no longer
depends on usbnet.

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/usb/class/cdc-acm.c | 69 +++++++--------------------------------------
 1 file changed, 10 insertions(+), 59 deletions(-)

diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index 94a14f5..70bd642 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -1147,6 +1147,7 @@ static int acm_probe(struct usb_interface *intf,
 {
 	struct usb_cdc_union_desc *union_header = NULL;
 	struct usb_cdc_country_functional_desc *cfd = NULL;
+	struct usb_cdc_call_mgmt_descriptor *cmd = NULL;
 	unsigned char *buffer = intf->altsetting->extra;
 	int buflen = intf->altsetting->extralen;
 	struct usb_interface *control_interface;
@@ -1155,18 +1156,16 @@ static int acm_probe(struct usb_interface *intf,
 	struct usb_endpoint_descriptor *epread = NULL;
 	struct usb_endpoint_descriptor *epwrite = NULL;
 	struct usb_device *usb_dev = interface_to_usbdev(intf);
+	struct usb_cdc_parsed_header hdr;
 	struct acm *acm;
 	int minor;
 	int ctrlsize, readsize;
 	u8 *buf;
-	u8 ac_management_function = 0;
-	u8 call_management_function = 0;
 	int call_interface_num = -1;
 	int data_interface_num = -1;
 	unsigned long quirks;
 	int num_rx_buf;
 	int i;
-	unsigned int elength = 0;
 	int combined_interfaces = 0;
 	struct device *tty_dev;
 	int rv = -ENOMEM;
@@ -1210,61 +1209,11 @@ static int acm_probe(struct usb_interface *intf,
 		}
 	}
 
-	while (buflen > 0) {
-		elength = buffer[0];
-		if (!elength) {
-			dev_err(&intf->dev, "skipping garbage byte\n");
-			elength = 1;
-			goto next_desc;
-		}
-		if (buffer[1] != USB_DT_CS_INTERFACE) {
-			dev_err(&intf->dev, "skipping garbage\n");
-			goto next_desc;
-		}
-
-		switch (buffer[2]) {
-		case USB_CDC_UNION_TYPE: /* we've found it */
-			if (elength < sizeof(struct usb_cdc_union_desc))
-				goto next_desc;
-			if (union_header) {
-				dev_err(&intf->dev, "More than one "
-					"union descriptor, skipping ...\n");
-				goto next_desc;
-			}
-			union_header = (struct usb_cdc_union_desc *)buffer;
-			break;
-		case USB_CDC_COUNTRY_TYPE: /* export through sysfs*/
-			if (elength < sizeof(struct usb_cdc_country_functional_desc))
-				goto next_desc;
-			cfd = (struct usb_cdc_country_functional_desc *)buffer;
-			break;
-		case USB_CDC_HEADER_TYPE: /* maybe check version */
-			break; /* for now we ignore it */
-		case USB_CDC_ACM_TYPE:
-			if (elength < 4)
-				goto next_desc;
-			ac_management_function = buffer[3];
-			break;
-		case USB_CDC_CALL_MANAGEMENT_TYPE:
-			if (elength < 5)
-				goto next_desc;
-			call_management_function = buffer[3];
-			call_interface_num = buffer[4];
-			break;
-		default:
-			/*
-			 * there are LOTS more CDC descriptors that
-			 * could legitimately be found here.
-			 */
-			dev_dbg(&intf->dev, "Ignoring descriptor: "
-					"type %02x, length %ud\n",
-					buffer[2], elength);
-			break;
-		}
-next_desc:
-		buflen -= elength;
-		buffer += elength;
-	}
+	cdc_parse_cdc_header(&hdr, intf, buffer, buflen);
+	union_header = hdr.usb_cdc_union_desc;
+	cmd = hdr.usb_cdc_call_mgmt_descriptor;
+	if (cmd)
+		call_interface_num = cmd->bDataInterface;
 
 	if (!union_header) {
 		if (call_interface_num > 0) {
@@ -1394,7 +1343,8 @@ made_compressed_probe:
 	acm->data = data_interface;
 	acm->minor = minor;
 	acm->dev = usb_dev;
-	acm->ctrl_caps = ac_management_function;
+	if (hdr.usb_cdc_acm_descriptor)
+		acm->ctrl_caps = hdr.usb_cdc_acm_descriptor->bmCapabilities;
 	if (quirks & NO_CAP_LINE)
 		acm->ctrl_caps &= ~USB_CDC_CAP_LINE;
 	acm->ctrlsize = ctrlsize;
@@ -1488,6 +1438,7 @@ made_compressed_probe:
 	if (i < 0)
 		goto alloc_fail7;
 
+	cfd = hdr.usb_cdc_country_functional_desc;
 	if (cfd) { /* export the country data */
 		acm->country_codes = kmalloc(cfd->bLength - 4, GFP_KERNEL);
 		if (!acm->country_codes)
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
