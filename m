From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 1/5] usbnet: move the CDC parser into USB core
Date: Thu, 14 Jul 2016 15:41:30 +0200
Message-ID: <1468503694-9482-2-git-send-email-oneukum@suse.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>, Oliver Neukum <ONeukum@suse.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, gregKH@linuxfoundation.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37015 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbcGNNpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 09:45:54 -0400
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dependencies were impossible to handle preventing
drivers for CDC devices not which are not network drivers
from using the common parser.

Signed-off-by: Oliver Neukum <ONeukum@suse.com>
---
 drivers/net/usb/usbnet.c   | 138 ----------------------------------------
 drivers/usb/core/message.c | 153 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 153 insertions(+), 138 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 61ba464..b56d78a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -42,7 +42,6 @@
 #include <linux/mii.h>
 #include <linux/usb.h>
 #include <linux/usb/usbnet.h>
-#include <linux/usb/cdc.h>
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/pm_runtime.h>
@@ -1968,143 +1967,6 @@ out:
 	return err;
 }
 
-int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
-				struct usb_interface *intf,
-				u8 *buffer,
-				int buflen)
-{
-	/* duplicates are ignored */
-	struct usb_cdc_union_desc *union_header = NULL;
-
-	/* duplicates are not tolerated */
-	struct usb_cdc_header_desc *header = NULL;
-	struct usb_cdc_ether_desc *ether = NULL;
-	struct usb_cdc_mdlm_detail_desc *detail = NULL;
-	struct usb_cdc_mdlm_desc *desc = NULL;
-
-	unsigned int elength;
-	int cnt = 0;
-
-	memset(hdr, 0x00, sizeof(struct usb_cdc_parsed_header));
-	hdr->phonet_magic_present = false;
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
-				dev_err(&intf->dev, "More than one union descriptor, skipping ...\n");
-				goto next_desc;
-			}
-			union_header = (struct usb_cdc_union_desc *)buffer;
-			break;
-		case USB_CDC_COUNTRY_TYPE:
-			if (elength < sizeof(struct usb_cdc_country_functional_desc))
-				goto next_desc;
-			hdr->usb_cdc_country_functional_desc =
-				(struct usb_cdc_country_functional_desc *)buffer;
-			break;
-		case USB_CDC_HEADER_TYPE:
-			if (elength != sizeof(struct usb_cdc_header_desc))
-				goto next_desc;
-			if (header)
-				return -EINVAL;
-			header = (struct usb_cdc_header_desc *)buffer;
-			break;
-		case USB_CDC_ACM_TYPE:
-			if (elength < sizeof(struct usb_cdc_acm_descriptor))
-				goto next_desc;
-			hdr->usb_cdc_acm_descriptor =
-				(struct usb_cdc_acm_descriptor *)buffer;
-			break;
-		case USB_CDC_ETHERNET_TYPE:
-			if (elength != sizeof(struct usb_cdc_ether_desc))
-				goto next_desc;
-			if (ether)
-				return -EINVAL;
-			ether = (struct usb_cdc_ether_desc *)buffer;
-			break;
-		case USB_CDC_CALL_MANAGEMENT_TYPE:
-			if (elength < sizeof(struct usb_cdc_call_mgmt_descriptor))
-				goto next_desc;
-			hdr->usb_cdc_call_mgmt_descriptor =
-				(struct usb_cdc_call_mgmt_descriptor *)buffer;
-			break;
-		case USB_CDC_DMM_TYPE:
-			if (elength < sizeof(struct usb_cdc_dmm_desc))
-				goto next_desc;
-			hdr->usb_cdc_dmm_desc =
-				(struct usb_cdc_dmm_desc *)buffer;
-			break;
-		case USB_CDC_MDLM_TYPE:
-			if (elength < sizeof(struct usb_cdc_mdlm_desc *))
-				goto next_desc;
-			if (desc)
-				return -EINVAL;
-			desc = (struct usb_cdc_mdlm_desc *)buffer;
-			break;
-		case USB_CDC_MDLM_DETAIL_TYPE:
-			if (elength < sizeof(struct usb_cdc_mdlm_detail_desc *))
-				goto next_desc;
-			if (detail)
-				return -EINVAL;
-			detail = (struct usb_cdc_mdlm_detail_desc *)buffer;
-			break;
-		case USB_CDC_NCM_TYPE:
-			if (elength < sizeof(struct usb_cdc_ncm_desc))
-				goto next_desc;
-			hdr->usb_cdc_ncm_desc = (struct usb_cdc_ncm_desc *)buffer;
-			break;
-		case USB_CDC_MBIM_TYPE:
-			if (elength < sizeof(struct usb_cdc_mbim_desc))
-				goto next_desc;
-
-			hdr->usb_cdc_mbim_desc = (struct usb_cdc_mbim_desc *)buffer;
-			break;
-		case USB_CDC_MBIM_EXTENDED_TYPE:
-			if (elength < sizeof(struct usb_cdc_mbim_extended_desc))
-				break;
-			hdr->usb_cdc_mbim_extended_desc =
-				(struct usb_cdc_mbim_extended_desc *)buffer;
-			break;
-		case CDC_PHONET_MAGIC_NUMBER:
-			hdr->phonet_magic_present = true;
-			break;
-		default:
-			/*
-			 * there are LOTS more CDC descriptors that
-			 * could legitimately be found here.
-			 */
-			dev_dbg(&intf->dev, "Ignoring descriptor: type %02x, length %ud\n",
-					buffer[2], elength);
-			goto next_desc;
-		}
-		cnt++;
-next_desc:
-		buflen -= elength;
-		buffer += elength;
-	}
-	hdr->usb_cdc_union_desc = union_header;
-	hdr->usb_cdc_header_desc = header;
-	hdr->usb_cdc_mdlm_detail_desc = detail;
-	hdr->usb_cdc_mdlm_desc = desc;
-	hdr->usb_cdc_ether_desc = ether;
-	return cnt;
-}
-
-EXPORT_SYMBOL(cdc_parse_cdc_header);
-
 /*
  * The function can't be called inside suspend/resume callback,
  * otherwise deadlock will be caused.
diff --git a/drivers/usb/core/message.c b/drivers/usb/core/message.c
index ea681f1..0406a59 100644
--- a/drivers/usb/core/message.c
+++ b/drivers/usb/core/message.c
@@ -12,6 +12,7 @@
 #include <linux/nls.h>
 #include <linux/device.h>
 #include <linux/scatterlist.h>
+#include <linux/usb/cdc.h>
 #include <linux/usb/quirks.h>
 #include <linux/usb/hcd.h>	/* for usbcore internals */
 #include <asm/byteorder.h>
@@ -2023,3 +2024,155 @@ int usb_driver_set_configuration(struct usb_device *udev, int config)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usb_driver_set_configuration);
+
+/**
+ * cdc_parse_cdc_header - parse the extra headers present in CDC devices
+ * @hdr: the place to put the results of the parsing
+ * @intf: the interface for which parsing is requested
+ * @buffer: pointer to the extra headers to be parsed
+ * @buflen: length of the extra headers
+ *
+ * This evaluates the extra headers present in CDC devices which
+ * bind the interfaces for data and control and provide details
+ * about the capabilities of the device.
+ *
+ * Return: number of descriptors parsed or -EINVAL
+ * if the header is contradictory beyond salvage
+ */
+
+int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
+				struct usb_interface *intf,
+				u8 *buffer,
+				int buflen)
+{
+	/* duplicates are ignored */
+	struct usb_cdc_union_desc *union_header = NULL;
+
+	/* duplicates are not tolerated */
+	struct usb_cdc_header_desc *header = NULL;
+	struct usb_cdc_ether_desc *ether = NULL;
+	struct usb_cdc_mdlm_detail_desc *detail = NULL;
+	struct usb_cdc_mdlm_desc *desc = NULL;
+
+	unsigned int elength;
+	int cnt = 0;
+
+	memset(hdr, 0x00, sizeof(struct usb_cdc_parsed_header));
+	hdr->phonet_magic_present = false;
+	while (buflen > 0) {
+		elength = buffer[0];
+		if (!elength) {
+			dev_err(&intf->dev, "skipping garbage byte\n");
+			elength = 1;
+			goto next_desc;
+		}
+		if (buffer[1] != USB_DT_CS_INTERFACE) {
+			dev_err(&intf->dev, "skipping garbage\n");
+			goto next_desc;
+		}
+
+		switch (buffer[2]) {
+		case USB_CDC_UNION_TYPE: /* we've found it */
+			if (elength < sizeof(struct usb_cdc_union_desc))
+				goto next_desc;
+			if (union_header) {
+				dev_err(&intf->dev, "More than one union descriptor, skipping ...\n");
+				goto next_desc;
+			}
+			union_header = (struct usb_cdc_union_desc *)buffer;
+			break;
+		case USB_CDC_COUNTRY_TYPE:
+			if (elength < sizeof(struct usb_cdc_country_functional_desc))
+				goto next_desc;
+			hdr->usb_cdc_country_functional_desc =
+				(struct usb_cdc_country_functional_desc *)buffer;
+			break;
+		case USB_CDC_HEADER_TYPE:
+			if (elength != sizeof(struct usb_cdc_header_desc))
+				goto next_desc;
+			if (header)
+				return -EINVAL;
+			header = (struct usb_cdc_header_desc *)buffer;
+			break;
+		case USB_CDC_ACM_TYPE:
+			if (elength < sizeof(struct usb_cdc_acm_descriptor))
+				goto next_desc;
+			hdr->usb_cdc_acm_descriptor =
+				(struct usb_cdc_acm_descriptor *)buffer;
+			break;
+		case USB_CDC_ETHERNET_TYPE:
+			if (elength != sizeof(struct usb_cdc_ether_desc))
+				goto next_desc;
+			if (ether)
+				return -EINVAL;
+			ether = (struct usb_cdc_ether_desc *)buffer;
+			break;
+		case USB_CDC_CALL_MANAGEMENT_TYPE:
+			if (elength < sizeof(struct usb_cdc_call_mgmt_descriptor))
+				goto next_desc;
+			hdr->usb_cdc_call_mgmt_descriptor =
+				(struct usb_cdc_call_mgmt_descriptor *)buffer;
+			break;
+		case USB_CDC_DMM_TYPE:
+			if (elength < sizeof(struct usb_cdc_dmm_desc))
+				goto next_desc;
+			hdr->usb_cdc_dmm_desc =
+				(struct usb_cdc_dmm_desc *)buffer;
+			break;
+		case USB_CDC_MDLM_TYPE:
+			if (elength < sizeof(struct usb_cdc_mdlm_desc *))
+				goto next_desc;
+			if (desc)
+				return -EINVAL;
+			desc = (struct usb_cdc_mdlm_desc *)buffer;
+			break;
+		case USB_CDC_MDLM_DETAIL_TYPE:
+			if (elength < sizeof(struct usb_cdc_mdlm_detail_desc *))
+				goto next_desc;
+			if (detail)
+				return -EINVAL;
+			detail = (struct usb_cdc_mdlm_detail_desc *)buffer;
+			break;
+		case USB_CDC_NCM_TYPE:
+			if (elength < sizeof(struct usb_cdc_ncm_desc))
+				goto next_desc;
+			hdr->usb_cdc_ncm_desc = (struct usb_cdc_ncm_desc *)buffer;
+			break;
+		case USB_CDC_MBIM_TYPE:
+			if (elength < sizeof(struct usb_cdc_mbim_desc))
+				goto next_desc;
+
+			hdr->usb_cdc_mbim_desc = (struct usb_cdc_mbim_desc *)buffer;
+			break;
+		case USB_CDC_MBIM_EXTENDED_TYPE:
+			if (elength < sizeof(struct usb_cdc_mbim_extended_desc))
+				break;
+			hdr->usb_cdc_mbim_extended_desc =
+				(struct usb_cdc_mbim_extended_desc *)buffer;
+			break;
+		case CDC_PHONET_MAGIC_NUMBER:
+			hdr->phonet_magic_present = true;
+			break;
+		default:
+			/*
+			 * there are LOTS more CDC descriptors that
+			 * could legitimately be found here.
+			 */
+			dev_dbg(&intf->dev, "Ignoring descriptor: type %02x, length %ud\n",
+					buffer[2], elength);
+			goto next_desc;
+		}
+		cnt++;
+next_desc:
+		buflen -= elength;
+		buffer += elength;
+	}
+	hdr->usb_cdc_union_desc = union_header;
+	hdr->usb_cdc_header_desc = header;
+	hdr->usb_cdc_mdlm_detail_desc = detail;
+	hdr->usb_cdc_mdlm_desc = desc;
+	hdr->usb_cdc_ether_desc = ether;
+	return cnt;
+}
+
+EXPORT_SYMBOL(cdc_parse_cdc_header);
-- 
2.1.4
