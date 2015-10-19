From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 1/3] cdc-acm: use the common parser for all CDC drivers
Date: Mon, 19 Oct 2015 13:48:39 +0200
Message-ID: <1445255321-13029-2-git-send-email-oneukum@suse.com>
References: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.de>, Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	gregKH@linuxfoundation.org, linuxusb-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45100 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbbJSLuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 07:50:25 -0400
In-Reply-To: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>

Use the common parser in CDC-ACM for code depuplication

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/usb/class/cdc-acm.c | 66 +++++++--------------------------------------
 1 file changed, 9 insertions(+), 57 deletions(-)

diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index b30e742..d30e942 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -1075,6 +1075,7 @@ static int acm_write_buffers_alloc(struct acm *acm)
 static int acm_probe(struct usb_interface *intf,
 		     const struct usb_device_id *id)
 {
+	struct usb_cdc_parsed_header header;
 	struct usb_cdc_union_desc *union_header = NULL;
 	struct usb_cdc_country_functional_desc *cfd = NULL;
 	unsigned char *buffer = intf->altsetting->extra;
@@ -1090,13 +1091,12 @@ static int acm_probe(struct usb_interface *intf,
 	int ctrlsize, readsize;
 	u8 *buf;
 	u8 ac_management_function = 0;
-	u8 call_management_function = 0;
+	u8 call_management_function;
 	int call_interface_num = -1;
 	int data_interface_num = -1;
 	unsigned long quirks;
 	int num_rx_buf;
 	int i;
-	unsigned int elength = 0;
 	int combined_interfaces = 0;
 	struct device *tty_dev;
 	int rv = -ENOMEM;
@@ -1137,61 +1137,13 @@ static int acm_probe(struct usb_interface *intf,
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
+	cdc_parse_cdc_header(&header, intf, buffer, buflen);
+	union_header = header.usb_cdc_union_desc;
+	call_management_function = header.usb_cdc_call_mgmt_descriptor->bmCapabilities;
+	if (call_management_function)
+		call_interface_num = header.usb_cdc_call_mgmt_descriptor->bDataInterface;
+	ac_management_function = header.usb_cdc_acm_descriptor->bmCapabilities;
+	cfd = header.usb_cdc_country_functional_desc;
 
 	if (!union_header) {
 		if (call_interface_num > 0) {
-- 
2.1.4
