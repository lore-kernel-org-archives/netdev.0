From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] irda-usb.c: STIR421x cleanups
Date: Mon, 12 Jun 2006 09:12:35 +0300
Message-ID: <20060612061235.GB3736@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Nick Fedchik <nfedchik@atlantic-link.com.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:17068 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S1751126AbWFKXBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 19:01:53 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is for the net-2.6.18 tree.
It cleans the STIR421x part of the irda-usb code. We also no longer try to
load all existing firmwares but only the matching one (according to the USB
id we get from the dongle).

Signed-off-by: Nick Fedchik <nfedchik@atlantic-link.com.ua>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>


---

 drivers/net/irda/irda-usb.c |  327 +++++++++++++++++++------------------------
 drivers/net/irda/irda-usb.h |   10 +
 2 files changed, 145 insertions(+), 192 deletions(-)

946837ac4e7bb301a1fcef0046b2a72e8e81b57c
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index cd87593..844fa74 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -83,9 +83,9 @@ static struct usb_device_id dongles[] = 
 	/* Extended Systems, Inc.,  XTNDAccess IrDA USB (ESI-9685) */
 	{ USB_DEVICE(0x8e9, 0x100), .driver_info = IUC_SPEED_BUG | IUC_NO_WINDOW },
 	/* SigmaTel STIR4210/4220/4116 USB IrDA (VFIR) Bridge */
-	{ USB_DEVICE(0x66f, 0x4210), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
-	{ USB_DEVICE(0x66f, 0x4220), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
-	{ USB_DEVICE(0x66f, 0x4116), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
+	{ USB_DEVICE(0x66f, 0x4210), .driver_info = IUC_STIR421X | IUC_SPEED_BUG },
+	{ USB_DEVICE(0x66f, 0x4220), .driver_info = IUC_STIR421X | IUC_SPEED_BUG },
+	{ USB_DEVICE(0x66f, 0x4116), .driver_info = IUC_STIR421X | IUC_SPEED_BUG },
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_CLASS |
 	  USB_DEVICE_ID_MATCH_INT_SUBCLASS,
 	  .bInterfaceClass = USB_CLASS_APP_SPEC,
@@ -154,7 +154,7 @@ static void irda_usb_build_header(struct
 	 * and if either speed or xbofs (or both) needs
 	 * to be changed.
 	 */
-	if (self->capability & IUC_STIR_4210 &&
+	if (self->capability & IUC_STIR421X &&
 	    ((self->new_speed != -1) || (self->new_xbofs != -1))) {
 
 		/* With STIR421x, speed and xBOFs must be set at the same
@@ -318,7 +318,7 @@ static void irda_usb_change_speed_xbofs(
 	/* Set the new speed and xbofs in this fake frame */
 	irda_usb_build_header(self, frame, 1);
 
-	if ( self->capability & IUC_STIR_4210 ) {
+	if (self->capability & IUC_STIR421X) {
 		if (frame[0] == 0) return ; // do nothing if no change
 		frame[1] = 0; // other parameters don't change here
 		frame[2] = 0;
@@ -455,7 +455,7 @@ static int irda_usb_hard_xmit(struct sk_
 
 	/* Change setting for next frame */
 
-	if ( self->capability & IUC_STIR_4210 ) {
+	if (self->capability & IUC_STIR421X) {
 		__u8 turnaround_time;
 		__u8* frame;
 		turnaround_time = get_turnaround_time( skb );
@@ -897,10 +897,13 @@ static void irda_usb_receive(struct urb 
 	docopy = (urb->actual_length < IRDA_RX_COPY_THRESHOLD);
 
 	/* Allocate a new skb */
-	if ( self->capability & IUC_STIR_4210 )
-		newskb = dev_alloc_skb(docopy ? urb->actual_length : IRDA_SKB_MAX_MTU + USB_IRDA_SIGMATEL_HEADER);
+	if (self->capability & IUC_STIR421X)
+		newskb = dev_alloc_skb(docopy ? urb->actual_length :
+				       IRDA_SKB_MAX_MTU +
+				       USB_IRDA_STIR421X_HEADER);
 	else
-		newskb = dev_alloc_skb(docopy ? urb->actual_length : IRDA_SKB_MAX_MTU);
+		newskb = dev_alloc_skb(docopy ? urb->actual_length :
+				       IRDA_SKB_MAX_MTU);
 
 	if (!newskb)  {
 		self->stats.rx_dropped++;
@@ -1022,188 +1025,140 @@ static int irda_usb_is_receiving(struct 
 	return 0; /* For now */
 }
 
-
-#define STIR421X_PATCH_PRODUCT_VERSION_STR       "Product Version: "
-#define STIR421X_PATCH_COMPONENT_VERSION_STR     "Component Version: "
-#define STIR421X_PATCH_DATA_TAG_STR              "STMP"
-#define STIR421X_PATCH_FILE_VERSION_MAX_OFFSET   512     /* version info is before here */
-#define STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET     512     /* patch image starts before here */
-#define STIR421X_PATCH_FILE_END_OF_HEADER_TAG    0x1A    /* marks end of patch file header (PC DOS text file EOF character) */
+#define STIR421X_PATCH_PRODUCT_VER     "Product Version: "
+#define STIR421X_PATCH_STMP_TAG        "STMP"
+#define STIR421X_PATCH_CODE_OFFSET     512 /* patch image starts before here */
+/* marks end of patch file header (PC DOS text file EOF character) */
+#define STIR421X_PATCH_END_OF_HDR_TAG  0x1A
+#define STIR421X_PATCH_BLOCK_SIZE      1023
 
 /*
- * Known firmware patches for STIR421x dongles
+ * Function stir421x_fwupload (struct irda_usb_cb *self,
+ *                             unsigned char *patch,
+ *                             const unsigned int patch_len)
+ *
+ *   Upload firmware code to SigmaTel 421X IRDA-USB dongle
  */
-static char * stir421x_patches[] = {
-	"42101001.sb",
-	"42101002.sb",
-};
-
-static int stir421x_get_patch_version(unsigned char * patch, const unsigned long patch_len)
+static int stir421x_fw_upload(struct irda_usb_cb *self,
+			     unsigned char *patch,
+			     const unsigned int patch_len)
 {
-	unsigned int version_offset;
-	unsigned long version_major, version_minor, version_build;
-	unsigned char * version_start;
-	int version_found = 0;
-
-	for (version_offset = 0;
-	     version_offset < STIR421X_PATCH_FILE_END_OF_HEADER_TAG;
-	     version_offset++) {
-		if (!memcmp(patch + version_offset,
-			    STIR421X_PATCH_PRODUCT_VERSION_STR,
-			    sizeof(STIR421X_PATCH_PRODUCT_VERSION_STR) - 1)) {
-				    version_found = 1;
-				    version_start = patch +
-					    version_offset +
-					    sizeof(STIR421X_PATCH_PRODUCT_VERSION_STR) - 1;
-				    break;
-		}
+        int ret = -ENOMEM;
+        int actual_len = 0;
+        unsigned int i;
+        unsigned int block_size = 0;
+        unsigned char *patch_block;
+
+        patch_block = kzalloc(STIR421X_PATCH_BLOCK_SIZE, GFP_KERNEL);
+	if (patch_block == NULL)
+		return -ENOMEM;
+
+	/* break up patch into 1023-byte sections */
+	for (i = 0; i < patch_len; i += block_size) {
+		block_size = patch_len - i;
+
+		if (block_size > STIR421X_PATCH_BLOCK_SIZE)
+			block_size = STIR421X_PATCH_BLOCK_SIZE;
+
+		/* upload the patch section */
+		memcpy(patch_block, patch + i, block_size);
+
+		ret = usb_bulk_msg(self->usbdev,
+				   usb_sndbulkpipe(self->usbdev,
+						   self->bulk_out_ep),
+				   patch_block, block_size,
+				   &actual_len, msecs_to_jiffies(500));
+		IRDA_DEBUG(3,"%s(): Bulk send %u bytes, ret=%d\n",
+			   __FUNCTION__, actual_len, ret);
+
+		if (ret < 0)
+			break;
 	}
 
-	/* We couldn't find a product version on this patch */
-	if (!version_found)
-		return -EINVAL;
-
-	/* Let's check if the product version is dotted */
-	if (version_start[3] != '.' ||
-	    version_start[7] != '.')
-		return -EINVAL;
-
-	version_major = simple_strtoul(version_start, NULL, 10);
-	version_minor = simple_strtoul(version_start + 4, NULL, 10);
-	version_build = simple_strtoul(version_start + 8, NULL, 10);
-
-	IRDA_DEBUG(2, "%s(), Major: %ld Minor: %ld Build: %ld\n",
-		   __FUNCTION__,
-		   version_major, version_minor, version_build);
-
-	return (((version_major) << 12) +
-		((version_minor) << 8) +
-		((version_build / 10) << 4) +
-		(version_build % 10));
-
-}
-
-
-static int stir421x_upload_patch (struct irda_usb_cb *self,
-				  unsigned char * patch,
-				  const unsigned int patch_len)
-{
-    int retval = 0;
-    int actual_len;
-    unsigned int i = 0, download_amount = 0;
-    unsigned char * patch_chunk;
-
-    IRDA_DEBUG (2, "%s(), Uploading STIR421x Patch\n", __FUNCTION__);
-
-    patch_chunk = kzalloc(STIR421X_MAX_PATCH_DOWNLOAD_SIZE, GFP_KERNEL);
-    if (patch_chunk == NULL)
-	    return -ENOMEM;
-
-    /* break up patch into 1023-byte sections */
-    for (i = 0; retval >= 0 && i < patch_len; i += download_amount) {
-	    download_amount = patch_len - i;
-	    if (download_amount > STIR421X_MAX_PATCH_DOWNLOAD_SIZE)
-		    download_amount = STIR421X_MAX_PATCH_DOWNLOAD_SIZE;
-
-	    /* download the patch section */
-	    memcpy(patch_chunk, patch + i, download_amount);
-
-	    retval = usb_bulk_msg (self->usbdev,
-				   usb_sndbulkpipe (self->usbdev,
-						    self->bulk_out_ep),
-				   patch_chunk, download_amount,
-				   &actual_len, msecs_to_jiffies (500));
-	    IRDA_DEBUG (2, "%s(), Sent %u bytes\n", __FUNCTION__,
-			actual_len);
-	    if (retval == 0)
-		    mdelay(10);
-    }
-
-    kfree(patch_chunk);
-
-    if (i != patch_len) {
-	    IRDA_ERROR ("%s(), Pushed %d bytes (!= patch_len (%d))\n",
-		       __FUNCTION__, i, patch_len);
-	    retval = -EIO;
-    }
-
-    if (retval < 0)
-	    /* todo - mark device as not ready */
-	    IRDA_ERROR ("%s(), STIR421x patch upload failed (%d)\n",
-			__FUNCTION__, retval);
-
-    return retval;
-}
+	kfree(patch_block);
 
+        return ret;
+ }
 
+/*
+ * Function stir421x_patch_device(struct irda_usb_cb *self)
+ *
+ * Get a firmware code from userspase using hotplug request_firmware() call
+  */
 static int stir421x_patch_device(struct irda_usb_cb *self)
 {
-	unsigned int i, patch_found = 0, data_found = 0, data_offset;
-	int patch_version, ret = 0;
-	const struct firmware *fw_entry;
-
-	for (i = 0; i < ARRAY_SIZE(stir421x_patches); i++) {
-		if(request_firmware(&fw_entry, stir421x_patches[i], &self->usbdev->dev) != 0) {
-			IRDA_ERROR( "%s(), Patch %s is not available\n", __FUNCTION__, stir421x_patches[i]);
-			continue;
-		}
-
-                /* We found a patch from userspace */
-		patch_version = stir421x_get_patch_version (fw_entry->data, fw_entry->size);
-
-		if (patch_version < 0) {
-			/* Couldn't fetch a version, let's move on to the next file */
-			IRDA_ERROR("%s(), version parsing failed\n", __FUNCTION__);
-			ret = patch_version;
-			release_firmware(fw_entry);
-			continue;
-		}
-
-		if (patch_version != self->usbdev->descriptor.bcdDevice) {
-			/* Patch version and device don't match */
-			IRDA_ERROR ("%s(), wrong patch version (%d <-> %d)\n",
-				    __FUNCTION__,
-				    patch_version, self->usbdev->descriptor.bcdDevice);
-			ret = -EINVAL;
-			release_firmware(fw_entry);
-			continue;
-		}
-
-		/* If we're here, we've found a correct patch */
-		patch_found = 1;
-		break;
-
-	}
-
-	/* We couldn't find a valid firmware, let's leave */
-	if (!patch_found)
-		return ret;
-
-	/* The actual image starts after the "STMP" keyword */
-	for (data_offset = 0; data_offset < STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET; data_offset++) {
-		if (!memcmp(fw_entry->data + data_offset,
-			    STIR421X_PATCH_DATA_TAG_STR,
-			    sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET))) {
-			IRDA_DEBUG(2, "%s(), found patch data for STIR421x at offset %d\n",
-				   __FUNCTION__, data_offset);
-			data_found = 1;
-			break;
-		}
-	}
-
-	/* We couldn't find "STMP" from the header */
-	if (!data_found)
-		return -EINVAL;
-
-	/* Let's upload the patch to the target */
-	ret = stir421x_upload_patch(self,
-				    &fw_entry->data[data_offset + sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET)],
-				    fw_entry->size - (data_offset + sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET)));
-
-	release_firmware(fw_entry);
-
-	return ret;
-
+        unsigned int i;
+        int ret;
+        char stir421x_fw_name[11];
+        const struct firmware *fw;
+        unsigned char *fw_version_ptr; /* pointer to version string */
+	unsigned long fw_version = 0;
+
+        /*
+         * Known firmware patch file names for STIR421x dongles
+         * are "42101001.sb" or "42101002.sb"
+         */
+        sprintf(stir421x_fw_name, "4210%4X.sb",
+                self->usbdev->descriptor.bcdDevice);
+        ret = request_firmware(&fw, stir421x_fw_name, &self->usbdev->dev);
+        if (ret < 0)
+                return ret;
+
+        /* We get a patch from userspace */
+        IRDA_MESSAGE("%s(): Received firmware %s (%u bytes)\n",
+                     __FUNCTION__, stir421x_fw_name, fw->size);
+
+        ret = -EINVAL;
+
+	/* Get the bcd product version */
+        if (!memcmp(fw->data, STIR421X_PATCH_PRODUCT_VER,
+                    sizeof(STIR421X_PATCH_PRODUCT_VER) - 1)) {
+                fw_version_ptr = fw->data +
+			sizeof(STIR421X_PATCH_PRODUCT_VER) - 1;
+
+                /* Let's check if the product version is dotted */
+                if (fw_version_ptr[3] == '.' &&
+		    fw_version_ptr[7] == '.') {
+			unsigned long major, minor, build;
+			major = simple_strtoul(fw_version_ptr, NULL, 10);
+			minor = simple_strtoul(fw_version_ptr + 4, NULL, 10);
+			build = simple_strtoul(fw_version_ptr + 8, NULL, 10);
+
+			fw_version = (major << 12)
+				+ (minor << 8)
+				+ ((build / 10) << 4)
+				+ (build % 10);
+
+			IRDA_DEBUG(3, "%s(): Firmware Product version %ld\n",
+                                   __FUNCTION__, fw_version);
+                }
+        }
+
+        if (self->usbdev->descriptor.bcdDevice == fw_version) {
+                /*
+		 * If we're here, we've found a correct patch
+                 * The actual image starts after the "STMP" keyword
+                 * so forward to the firmware header tag
+                 */
+                for (i = 0; (fw->data[i] != STIR421X_PATCH_END_OF_HDR_TAG)
+			     && (i < fw->size); i++) ;
+                /* here we check for the out of buffer case */
+                if ((STIR421X_PATCH_END_OF_HDR_TAG == fw->data[i])
+                    && (i < STIR421X_PATCH_CODE_OFFSET)) {
+                        if (!memcmp(fw->data + i + 1, STIR421X_PATCH_STMP_TAG,
+                                    sizeof(STIR421X_PATCH_STMP_TAG) - 1)) {
+
+				/* We can upload the patch to the target */
+				i += sizeof(STIR421X_PATCH_STMP_TAG);
+                                ret = stir421x_fw_upload(self, &fw->data[i],
+							 fw->size - i);
+                        }
+                }
+        }
+
+        release_firmware(fw);
+
+        return ret;
 }
 
 
@@ -1702,12 +1657,12 @@ static int irda_usb_probe(struct usb_int
 	init_timer(&self->rx_defer_timer);
 
 	self->capability = id->driver_info;
-	self->needspatch = ((self->capability & IUC_STIR_4210) != 0) ;
+	self->needspatch = ((self->capability & IUC_STIR421X) != 0);
 
 	/* Create all of the needed urbs */
-	if (self->capability & IUC_STIR_4210) {
+	if (self->capability & IUC_STIR421X) {
 		self->max_rx_urb = IU_SIGMATEL_MAX_RX_URBS;
-		self->header_length = USB_IRDA_SIGMATEL_HEADER;
+		self->header_length = USB_IRDA_STIR421X_HEADER;
 	} else {
 		self->max_rx_urb = IU_MAX_RX_URBS;
 		self->header_length = USB_IRDA_HEADER;
@@ -1813,8 +1768,8 @@ static int irda_usb_probe(struct usb_int
 		/* Now we fetch and upload the firmware patch */
 		ret = stir421x_patch_device(self);
 		self->needspatch = (ret < 0);
-		if (ret < 0) {
-			printk("patch_device failed\n");
+		if (self->needspatch) {
+			IRDA_ERROR("STIR421X: Couldn't upload patch\n");
 			goto err_out_5;
 		}
 
diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index d833db5..6b2271f 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -34,9 +34,6 @@ #include <linux/time.h>
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>      /* struct irlap_cb */
 
-#define PATCH_FILE_SIZE_MAX     65536
-#define PATCH_FILE_SIZE_MIN     80
-
 #define RX_COPY_THRESHOLD 200
 #define IRDA_USB_MAX_MTU 2051
 #define IRDA_USB_SPEED_MTU 64		/* Weird, but work like this */
@@ -107,14 +104,15 @@ #define IUC_SIR_ONLY	0x08	/* Device does
 #define IUC_SMALL_PKT	0x10	/* Device doesn't behave with big Rx packets */
 #define IUC_MAX_WINDOW	0x20	/* Device underestimate the Rx window */
 #define IUC_MAX_XBOFS	0x40	/* Device need more xbofs than advertised */
-#define IUC_STIR_4210	0x80	/* SigmaTel 4210/4220/4116 VFIR */
+#define IUC_STIR421X	0x80	/* SigmaTel 4210/4220/4116 VFIR */
 
 /* USB class definitions */
 #define USB_IRDA_HEADER            0x01
 #define USB_CLASS_IRDA             0x02 /* USB_CLASS_APP_SPEC subclass */
 #define USB_DT_IRDA                0x21
-#define USB_IRDA_SIGMATEL_HEADER   0x03
-#define IU_SIGMATEL_MAX_RX_URBS    (IU_MAX_ACTIVE_RX_URBS + USB_IRDA_SIGMATEL_HEADER)
+#define USB_IRDA_STIR421X_HEADER   0x03
+#define IU_SIGMATEL_MAX_RX_URBS    (IU_MAX_ACTIVE_RX_URBS + \
+                                    USB_IRDA_STIR421X_HEADER)
 
 struct irda_class_desc {
 	__u8  bLength;
-- 
1.3.3
