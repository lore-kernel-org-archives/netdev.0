From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 4/5] cdc-wdm: use the common CDC parser
Date: Thu, 14 Jul 2016 15:41:33 +0200
Message-ID: <1468503694-9482-5-git-send-email-oneukum@suse.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>, Oliver Neukum <ONeukum@suse.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, gregKH@linuxfoundation.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37009 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbcGNNpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 09:45:54 -0400
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the common parser resides in USB core, it can
be used for CDC-WDM.

Signed-off-by: Oliver Neukum <ONeukum@suse.com>
---
 drivers/usb/class/cdc-wdm.c | 30 +++++-------------------------
 1 file changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/usb/class/cdc-wdm.c b/drivers/usb/class/cdc-wdm.c
index 61ea879..337948c 100644
--- a/drivers/usb/class/cdc-wdm.c
+++ b/drivers/usb/class/cdc-wdm.c
@@ -875,38 +875,18 @@ static int wdm_probe(struct usb_interface *intf, const struct usb_device_id *id)
 	int rv = -EINVAL;
 	struct usb_host_interface *iface;
 	struct usb_endpoint_descriptor *ep;
-	struct usb_cdc_dmm_desc *dmhd;
+	struct usb_cdc_parsed_header hdr;
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
+	cdc_parse_cdc_header(&hdr, intf, buffer, buflen);
+
+	if (hdr.usb_cdc_dmm_desc)
+		maxcom = le16_to_cpu(hdr.usb_cdc_dmm_desc->wMaxCommand);
 
 	iface = intf->cur_altsetting;
 	if (iface->desc.bNumEndpoints != 1)
-- 
2.1.4
