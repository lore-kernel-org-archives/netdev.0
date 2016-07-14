From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 5/5] cdc-acm: beautify probe()
Date: Thu, 14 Jul 2016 15:41:34 +0200
Message-ID: <1468503694-9482-6-git-send-email-oneukum@suse.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregKH-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This removes some overly long lines by renaming variables and giving
them local scope.

Signed-off-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/usb/class/cdc-acm.c | 44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index 1857fad..369bde0 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -1146,8 +1146,7 @@ static int acm_probe(struct usb_interface *intf,
 		     const struct usb_device_id *id)
 {
 	struct usb_cdc_union_desc *union_header = NULL;
-	struct usb_cdc_country_functional_desc *cfd = NULL;
-	struct usb_cdc_call_mgmt_descriptor *cmd = NULL;
+	struct usb_cdc_call_mgmt_descriptor *cmgmd = NULL;
 	unsigned char *buffer = intf->altsetting->extra;
 	int buflen = intf->altsetting->extralen;
 	struct usb_interface *control_interface;
@@ -1156,13 +1155,13 @@ static int acm_probe(struct usb_interface *intf,
 	struct usb_endpoint_descriptor *epread = NULL;
 	struct usb_endpoint_descriptor *epwrite = NULL;
 	struct usb_device *usb_dev = interface_to_usbdev(intf);
-	struct usb_cdc_parsed_header hdr;
+	struct usb_cdc_parsed_header h;
 	struct acm *acm;
 	int minor;
 	int ctrlsize, readsize;
 	u8 *buf;
-	int call_interface_num = -1;
-	int data_interface_num = -1;
+	int call_intf_num = -1;
+	int data_intf_num = -1;
 	unsigned long quirks;
 	int num_rx_buf;
 	int i;
@@ -1209,20 +1208,22 @@ static int acm_probe(struct usb_interface *intf,
 		}
 	}
 
-	cdc_parse_cdc_header(&hdr, intf, buffer, buflen);
-	union_header = hdr.usb_cdc_union_desc;
-	cmd = hdr.usb_cdc_call_mgmt_descriptor;
-	if (cmd)
-		call_interface_num = cmd->bDataInterface;
+	cdc_parse_cdc_header(&h, intf, buffer, buflen);
+	union_header = h.usb_cdc_union_desc;
+	cmgmd = h.usb_cdc_call_mgmt_descriptor;
+	if (cmgmd)
+		call_intf_num = cmgmd->bDataInterface;
 
 	if (!union_header) {
-		if (call_interface_num > 0) {
+		if (call_intf_num > 0) {
 			dev_dbg(&intf->dev, "No union descriptor, using call management descriptor\n");
 			/* quirks for Droids MuIn LCD */
-			if (quirks & NO_DATA_INTERFACE)
+			if (quirks & NO_DATA_INTERFACE) {
 				data_interface = usb_ifnum_to_if(usb_dev, 0);
-			else
-				data_interface = usb_ifnum_to_if(usb_dev, (data_interface_num = call_interface_num));
+			} else {
+				data_intf_num = call_intf_num;
+				data_interface = usb_ifnum_to_if(usb_dev, data_intf_num);
+			}
 			control_interface = intf;
 		} else {
 			if (intf->cur_altsetting->desc.bNumEndpoints != 3) {
@@ -1236,8 +1237,9 @@ static int acm_probe(struct usb_interface *intf,
 			}
 		}
 	} else {
+		data_intf_num = union_header->bSlaveInterface0;
 		control_interface = usb_ifnum_to_if(usb_dev, union_header->bMasterInterface0);
-		data_interface = usb_ifnum_to_if(usb_dev, (data_interface_num = union_header->bSlaveInterface0));
+		data_interface = usb_ifnum_to_if(usb_dev, data_intf_num);
 	}
 
 	if (!control_interface || !data_interface) {
@@ -1245,7 +1247,7 @@ static int acm_probe(struct usb_interface *intf,
 		return -ENODEV;
 	}
 
-	if (data_interface_num != call_interface_num)
+	if (data_intf_num != call_intf_num)
 		dev_dbg(&intf->dev, "Separate call control interface. That is not fully supported.\n");
 
 	if (control_interface == data_interface) {
@@ -1340,8 +1342,8 @@ made_compressed_probe:
 	acm->data = data_interface;
 	acm->minor = minor;
 	acm->dev = usb_dev;
-	if (hdr.usb_cdc_acm_descriptor)
-		acm->ctrl_caps = hdr.usb_cdc_acm_descriptor->bmCapabilities;
+	if (h.usb_cdc_acm_descriptor)
+		acm->ctrl_caps = h.usb_cdc_acm_descriptor->bmCapabilities;
 	if (quirks & NO_CAP_LINE)
 		acm->ctrl_caps &= ~USB_CDC_CAP_LINE;
 	acm->ctrlsize = ctrlsize;
@@ -1435,8 +1437,10 @@ made_compressed_probe:
 	if (i < 0)
 		goto alloc_fail7;
 
-	cfd = hdr.usb_cdc_country_functional_desc;
-	if (cfd) { /* export the country data */
+	if (h.usb_cdc_country_functional_desc) { /* export the country data */
+		struct usb_cdc_country_functional_desc * cfd =
+					h.usb_cdc_country_functional_desc;
+
 		acm->country_codes = kmalloc(cfd->bLength - 4, GFP_KERNEL);
 		if (!acm->country_codes)
 			goto skip_countries;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
