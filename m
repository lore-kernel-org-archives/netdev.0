From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 2/3] cdc-wdm: use common CDC parser
Date: Mon, 19 Oct 2015 13:48:40 +0200
Message-ID: <1445255321-13029-3-git-send-email-oneukum@suse.com>
References: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.de>, Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	gregKH@linuxfoundation.org, linuxusb-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45107 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbbJSLu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 07:50:27 -0400
In-Reply-To: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>

cdc-wdm can use the common parser for the CDC extra header.
Code duplication is reduced.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/usb/class/cdc-wdm.c | 29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

diff --git a/drivers/usb/class/cdc-wdm.c b/drivers/usb/class/cdc-wdm.c
index 61ea879..2177069 100644
--- a/drivers/usb/class/cdc-wdm.c
+++ b/drivers/usb/class/cdc-wdm.c
@@ -875,38 +875,17 @@ static int wdm_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	int rv = -EINVAL;
 	struct usb_host_interface *iface;
 	struct usb_endpoint_descriptor *ep;
-	struct usb_cdc_dmm_desc *dmhd;
+	struct usb_cdc_parsed_header header;
 	u8 *buffer = intf->altsetting->extra;
 	int buflen = intf->altsetting->extralen;
 	u16 maxcom = WDM_DEFAULT_BUFSIZE;
 
 	if (!buffer)
 		goto err;
-	while (buflen > 2) {
-		if (buffer[1] != USB_DT_CS_INTERFACE) {
-			dev_err(&intf->dev, "skipping garbage\n");
-			goto next_desc;
-		}
 
-		switch (buffer[2]) {
-		case USB_CDC_HEADER_TYPE:
-			break;
-		case USB_CDC_DMM_TYPE:
-			dmhd = (struct usb_cdc_dmm_desc *)buffer;
-			maxcom = le16_to_cpu(dmhd->wMaxCommand);
-			dev_dbg(&intf->dev,
-				"Finding maximum buffer length: %d", maxcom);
-			break;
-		default:
-			dev_err(&intf->dev,
-				"Ignoring extra header, type %d, length %d\n",
-				buffer[2], buffer[0]);
-			break;
-		}
-next_desc:
-		buflen -= buffer[0];
-		buffer += buffer[0];
-	}
+	cdc_parse_cdc_header(&header, intf, buffer, buflen);
+	if (header.usb_cdc_dmm_desc)
+		maxcom = le16_to_cpu(header.usb_cdc_dmm_desc->wMaxCommand);
 
 	iface = intf->cur_altsetting;
 	if (iface->desc.bNumEndpoints != 1)
-- 
2.1.4
