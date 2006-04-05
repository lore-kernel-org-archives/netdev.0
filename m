From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] IrDA: Support for Sigmatel STIR421x chip
Date: Thu, 6 Apr 2006 02:21:37 +0300
Message-ID: <20060405232137.GB377@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

Hi David,

This patch enables support for the Sigmatel's STIR421x IrDA chip.
Once patched with Sigmatel's firmware, this chip "almost" follows the USB-IrDA spec. Thus this patch is against irda-usb.[ch].

The code has been tested by Nick Fedchik on an STIR4210 chipset based dongle.

Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index 4026af4..4e12217 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -1,7 +1,7 @@
 /*****************************************************************************
  *
  * Filename:      irda-usb.h
- * Version:       0.9b
+ * Version:       0.10
  * Description:   IrDA-USB Driver
  * Status:        Experimental 
  * Author:        Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org>
@@ -9,6 +9,9 @@
  *	Copyright (C) 2001, Roman Weissgaerber <weissg-TVDPYGuBT+ReoWH0uzbU5w@public.gmane.org>
  *      Copyright (C) 2000, Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org>
  *      Copyright (C) 2001, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
+ *      Copyright (C) 2004, SigmaTel, Inc. <irquality-0iljnS1bRDtWk0Htik3J/w@public.gmane.org>
+ *      Copyright (C) 2005, Milan Beno <beno-Rm0zKEqwvD4@public.gmane.org>
+ *      Copyright (C) 2006, Nick FEdchik <nick-UvdXiu2sajOKBXSJ/Qx0JQ@public.gmane.org>
  *          
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License as published by
@@ -31,6 +34,9 @@
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>      /* struct irlap_cb */
 
+#define PATCH_FILE_SIZE_MAX     65536
+#define PATCH_FILE_SIZE_MIN     80
+
 #define RX_COPY_THRESHOLD 200
 #define IRDA_USB_MAX_MTU 2051
 #define IRDA_USB_SPEED_MTU 64		/* Weird, but work like this */
@@ -79,15 +85,16 @@
 /* Inbound header */
 #define MEDIA_BUSY    0x80
 
-#define SPEED_2400    0x01
-#define SPEED_9600    0x02
-#define SPEED_19200   0x03
-#define SPEED_38400   0x04
-#define SPEED_57600   0x05
-#define SPEED_115200  0x06
-#define SPEED_576000  0x07
-#define SPEED_1152000 0x08
-#define SPEED_4000000 0x09
+#define SPEED_2400     0x01
+#define SPEED_9600     0x02
+#define SPEED_19200    0x03
+#define SPEED_38400    0x04
+#define SPEED_57600    0x05
+#define SPEED_115200   0x06
+#define SPEED_576000   0x07
+#define SPEED_1152000  0x08
+#define SPEED_4000000  0x09
+#define SPEED_16000000 0x0a
 
 /* Basic capabilities */
 #define IUC_DEFAULT	0x00	/* Basic device compliant with 1.0 spec */
@@ -100,11 +107,14 @@
 #define IUC_SMALL_PKT	0x10	/* Device doesn't behave with big Rx packets */
 #define IUC_MAX_WINDOW	0x20	/* Device underestimate the Rx window */
 #define IUC_MAX_XBOFS	0x40	/* Device need more xbofs than advertised */
+#define IUC_STIR_4210	0x80	/* SigmaTel 4210/4220/4116 VFIR */
 
 /* USB class definitions */
-#define USB_IRDA_HEADER   0x01
-#define USB_CLASS_IRDA    0x02 /* USB_CLASS_APP_SPEC subclass */ 
-#define USB_DT_IRDA       0x21
+#define USB_IRDA_HEADER            0x01
+#define USB_CLASS_IRDA             0x02 /* USB_CLASS_APP_SPEC subclass */ 
+#define USB_DT_IRDA                0x21
+#define USB_IRDA_SIGMATEL_HEADER   0x03
+#define IU_SIGMATEL_MAX_RX_URBS    (IU_MAX_ACTIVE_RX_URBS + USB_IRDA_SIGMATEL_HEADER)
 
 struct irda_class_desc {
 	__u8  bLength;
@@ -123,6 +133,7 @@ struct irda_class_desc {
  * (6.2.5, USB-IrDA class spec 1.0) */
 
 #define IU_REQ_GET_CLASS_DESC	0x06
+#define STIR421X_MAX_PATCH_DOWNLOAD_SIZE 1023
 
 struct irda_usb_cb {
 	struct irda_class_desc *irda_desc;
@@ -136,7 +147,8 @@ struct irda_usb_cb {
 	__u16 bulk_out_mtu;		/* Max Tx packet size in bytes */
 	__u8  bulk_int_ep;		/* Interrupt Endpoint assignments */
 
-	struct urb *rx_urb[IU_MAX_RX_URBS];	/* URBs used to receive data frames */
+	__u8  max_rx_urb;
+	struct urb **rx_urb;	        /* URBs used to receive data frames */
 	struct urb *idle_rx_urb;	/* Pointer to idle URB in Rx path */
 	struct urb *tx_urb;		/* URB used to send data frames */
 	struct urb *speed_urb;		/* URB used to send speed commands */
@@ -156,6 +168,9 @@ struct irda_usb_cb {
 	__s16 new_xbofs;		/* xbofs we need to set */
 	__u32 speed;			/* Current speed */
 	__s32 new_speed;		/* speed we need to set */
+	
+	__u8 header_length;             /* USB-IrDA frame header size */
+	int needspatch;        		/* device needs firmware patch */
 
 	struct timer_list rx_defer_timer;	/* Wait for Rx error to clear */
 };
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 6e2ec56..390d23b 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1,7 +1,7 @@
 /*****************************************************************************
  *
  * Filename:      irda-usb.c
- * Version:       0.9b
+ * Version:       0.10
  * Description:   IrDA-USB Driver
  * Status:        Experimental 
  * Author:        Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org>
@@ -9,6 +9,9 @@
  *	Copyright (C) 2000, Roman Weissgaerber <weissg-TVDPYGuBT+ReoWH0uzbU5w@public.gmane.org>
  *      Copyright (C) 2001, Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org>
  *      Copyright (C) 2001, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
+ *      Copyright (C) 2004, SigmaTel, Inc. <irquality-0iljnS1bRDtWk0Htik3J/w@public.gmane.org>
+ *      Copyright (C) 2005, Milan Beno <beno-Rm0zKEqwvD4@public.gmane.org>
+ *      Copyright (C) 2006, Nick Fedchik <nick-UvdXiu2sajOKBXSJ/Qx0JQ@public.gmane.org>
  *          
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License as published by
@@ -61,6 +64,7 @@
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/usb.h>
+#include <linux/firmware.h>
 
 #include "irda-usb.h"
 
@@ -78,8 +82,12 @@ static struct usb_device_id dongles[] = 
 	{ USB_DEVICE(0x50f, 0x180), .driver_info = IUC_SPEED_BUG | IUC_NO_WINDOW },
 	/* Extended Systems, Inc.,  XTNDAccess IrDA USB (ESI-9685) */
 	{ USB_DEVICE(0x8e9, 0x100), .driver_info = IUC_SPEED_BUG | IUC_NO_WINDOW },
-	{ .match_flags = USB_DEVICE_ID_MATCH_INT_CLASS |
-	               USB_DEVICE_ID_MATCH_INT_SUBCLASS,
+	/* SigmaTel STIR4210/4220/4116 USB IrDA (VFIR) Bridge */
+	{ USB_DEVICE(0x66f, 0x4210), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
+	{ USB_DEVICE(0x66f, 0x4220), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
+	{ USB_DEVICE(0x66f, 0x4116), .driver_info = IUC_STIR_4210 | IUC_SPEED_BUG },
+	{ .match_flags = USB_DEVICE_ID_MATCH_INT_CLASS | 
+	  USB_DEVICE_ID_MATCH_INT_SUBCLASS,
 	  .bInterfaceClass = USB_CLASS_APP_SPEC,
 	  .bInterfaceSubClass = USB_CLASS_IRDA,
 	  .driver_info = IUC_DEFAULT, },
@@ -99,6 +107,7 @@ MODULE_DEVICE_TABLE(usb, dongles);
 
 /*------------------------------------------------------------------*/
 
+static void irda_usb_init_qos(struct irda_usb_cb *self) ;
 static struct irda_class_desc *irda_usb_find_class_desc(struct usb_interface *intf);
 static void irda_usb_disconnect(struct usb_interface *intf);
 static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self);
@@ -141,7 +150,24 @@ static void irda_usb_build_header(struct
 				  __u8 *header,
 				  int	force)
 {
-	/* Set the negotiated link speed */
+	/* Here we check if we have an STIR421x chip,
+	 * and if either speed or xbofs (or both) needs
+	 * to be changed.
+	 */
+	if (self->capability & IUC_STIR_4210 &&
+	    ((self->new_speed != -1) || (self->new_xbofs != -1))) {
+	
+		/* With STIR421x, speed and xBOFs must be set at the same
+		 * time, even if only one of them changes. 
+		 */
+		if (self->new_speed == -1)
+			self->new_speed = self->speed ;
+		
+		if (self->new_xbofs == -1)
+			self->new_xbofs = self->xbofs ;
+	}
+	
+	/* Set the link speed */
 	if (self->new_speed != -1) {
 		/* Hum... Ugly hack :-(
 		 * Some device are not compliant with the spec and change
@@ -191,7 +217,11 @@ static void irda_usb_build_header(struct
 		        *header = SPEED_4000000;
 			self->new_xbofs = 0;
 			break;
-		}
+		case 16000000:
+			*header = SPEED_16000000;
+  			self->new_xbofs = 0;
+  			break;
+  		}
 	} else
 		/* No change */
 		*header = 0;
@@ -235,6 +265,32 @@ static void irda_usb_build_header(struct
 	}
 }
 
+/*
+*   calculate turnaround time for SigmaTel header
+*/
+static __u8 get_turnaround_time(struct sk_buff *skb)
+{
+	int turnaround_time = irda_get_mtt(skb);
+
+	if ( turnaround_time == 0 )
+		return 0;
+	else if ( turnaround_time <= 10 )
+		return 1;
+	else if ( turnaround_time <= 50 )
+		return 2;
+	else if ( turnaround_time <= 100 )
+		return 3;
+	else if ( turnaround_time <= 500 )
+		return 4;
+	else if ( turnaround_time <= 1000 )
+		return 5;
+	else if ( turnaround_time <= 5000 )
+		return 6;
+	else
+		return 7;
+}
+
+
 /*------------------------------------------------------------------*/
 /*
  * Send a command to change the speed of the dongle
@@ -262,12 +318,18 @@ static void irda_usb_change_speed_xbofs(
 	/* Set the new speed and xbofs in this fake frame */
 	irda_usb_build_header(self, frame, 1);
 
+	if ( self->capability & IUC_STIR_4210 ) {
+		if (frame[0] == 0) return ; // do nothing if no change
+		frame[1] = 0; // other parameters don't change here
+		frame[2] = 0;
+	}
+
 	/* Submit the 0 length IrDA frame to trigger new speed settings */
         usb_fill_bulk_urb(urb, self->usbdev,
 		      usb_sndbulkpipe(self->usbdev, self->bulk_out_ep),
                       frame, IRDA_USB_SPEED_MTU,
                       speed_bulk_callback, self);
-	urb->transfer_buffer_length = USB_IRDA_HEADER;
+	urb->transfer_buffer_length = self->header_length;
 	urb->transfer_flags = 0;
 
 	/* Irq disabled -> GFP_ATOMIC */
@@ -383,16 +445,35 @@ static int irda_usb_hard_xmit(struct sk_
 	 * allocation will be done lower in skb_push().
 	 * Also, we don't use directly skb_cow(), because it require
 	 * headroom >= 16, which force unnecessary copies - Jean II */
-	if (skb_headroom(skb) < USB_IRDA_HEADER) {
+	if (skb_headroom(skb) < self->header_length) {
 		IRDA_DEBUG(0, "%s(), Insuficient skb headroom.\n", __FUNCTION__);
-		if (skb_cow(skb, USB_IRDA_HEADER)) {
+		if (skb_cow(skb, self->header_length)) {
 			IRDA_WARNING("%s(), failed skb_cow() !!!\n", __FUNCTION__);
 			goto drop;
 		}
 	}
 
 	/* Change setting for next frame */
-	irda_usb_build_header(self, skb_push(skb, USB_IRDA_HEADER), 0);
+
+	if ( self->capability & IUC_STIR_4210 ) {
+		__u8 turnaround_time;
+		__u8* frame;
+		turnaround_time = get_turnaround_time( skb );
+		frame= skb_push(skb, self->header_length);
+		irda_usb_build_header(self, frame, 0);
+		frame[2] = turnaround_time;
+		if ((skb->len != 0) &&
+		    ((skb->len % 128) == 0) &&
+		    ((skb->len % 512) != 0)) {
+			/* add extra byte for special SigmaTel feature */
+			frame[1] = 1;
+			skb_put(skb, 1);
+		} else {
+			frame[1] = 0;
+		}
+	} else {
+		irda_usb_build_header(self, skb_push(skb, self->header_length), 0);
+	}
 
 	/* FIXME: Make macro out of this one */
 	((struct irda_skb_cb *)skb->cb)->context = self;
@@ -795,7 +876,7 @@ static void irda_usb_receive(struct urb 
 	}
 	
 	/* Check for empty frames */
-	if (urb->actual_length <= USB_IRDA_HEADER) {
+	if (urb->actual_length <= self->header_length) {
 		IRDA_WARNING("%s(), empty frame!\n", __FUNCTION__);
 		goto done;
 	}
@@ -815,8 +896,12 @@ static void irda_usb_receive(struct urb 
 	 * called Rx-copy-break). Jean II */
 	docopy = (urb->actual_length < IRDA_RX_COPY_THRESHOLD);
 
-	/* Allocate a new skb */
-	newskb = dev_alloc_skb(docopy ? urb->actual_length : IRDA_SKB_MAX_MTU);
+	/* Allocate a new skb */	
+	if ( self->capability & IUC_STIR_4210 )
+		newskb = dev_alloc_skb(docopy ? urb->actual_length : IRDA_SKB_MAX_MTU + USB_IRDA_SIGMATEL_HEADER);
+	else
+		newskb = dev_alloc_skb(docopy ? urb->actual_length : IRDA_SKB_MAX_MTU);
+
 	if (!newskb)  {
 		self->stats.rx_dropped++;
 		/* We could deliver the current skb, but this would stall
@@ -845,7 +930,7 @@ static void irda_usb_receive(struct urb 
 
 	/* Set proper length on skb & remove USB-IrDA header */
 	skb_put(dataskb, urb->actual_length);
-	skb_pull(dataskb, USB_IRDA_HEADER);
+	skb_pull(dataskb, self->header_length);
 
 	/* Ask the networking layer to queue the packet for the IrDA stack */
 	dataskb->dev = self->netdev;
@@ -937,6 +1022,191 @@ static int irda_usb_is_receiving(struct 
 	return 0; /* For now */
 }
 
+
+#define STIR421X_PATCH_PRODUCT_VERSION_STR       "Product Version: "
+#define STIR421X_PATCH_COMPONENT_VERSION_STR     "Component Version: "
+#define STIR421X_PATCH_DATA_TAG_STR              "STMP"
+#define STIR421X_PATCH_FILE_VERSION_MAX_OFFSET   512     /* version info is before here */
+#define STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET     512     /* patch image starts before here */
+#define STIR421X_PATCH_FILE_END_OF_HEADER_TAG    0x1A    /* marks end of patch file header (PC DOS text file EOF character) */
+
+/* 
+ * Known firmware patches for STIR421x dongles
+ */
+static char * stir421x_patches[] = {
+	"42101001.sb",
+	"42101002.sb",
+};
+
+static int stir421x_get_patch_version(unsigned char * patch, const unsigned long patch_len)
+{
+	unsigned int version_offset;
+	unsigned long version_major, version_minor, version_build;
+	unsigned char * version_start;
+	int version_found = 0;
+
+	for (version_offset = 0; 
+	     version_offset < STIR421X_PATCH_FILE_END_OF_HEADER_TAG; 
+	     version_offset++) {
+		if (!memcmp(patch + version_offset,
+			    STIR421X_PATCH_PRODUCT_VERSION_STR, 
+			    sizeof(STIR421X_PATCH_PRODUCT_VERSION_STR) - 1)) {
+				    version_found = 1;
+				    version_start = patch + 
+					    version_offset + 
+					    sizeof(STIR421X_PATCH_PRODUCT_VERSION_STR) - 1;
+				    break;
+		}
+	}
+
+	/* We couldn't find a product version on this patch */
+	if (!version_found)
+		return -EINVAL;
+
+	/* Let's check if the product version is dotted */
+	if (version_start[3] != '.' || 
+	    version_start[7] != '.')
+		return -EINVAL;
+
+	version_major = simple_strtoul(version_start, NULL, 10);
+	version_minor = simple_strtoul(version_start + 4, NULL, 10);
+	version_build = simple_strtoul(version_start + 8, NULL, 10);
+	
+	IRDA_DEBUG(2, "%s(), Major: %ld Minor: %ld Build: %ld\n",
+		   __FUNCTION__,
+		   version_major, version_minor, version_build);
+	
+	return (((version_major) << 12) +
+		((version_minor) << 8) +
+		((version_build / 10) << 4) + 
+		(version_build % 10));
+
+}
+
+
+static int stir421x_upload_patch (struct irda_usb_cb *self,
+				  unsigned char * patch,
+				  const unsigned int patch_len)
+{
+    int retval = 0;
+    int actual_len;
+    unsigned int i = 0, download_amount = 0;
+    unsigned char * patch_chunk;
+    
+    IRDA_DEBUG (2, "%s(), Uploading STIR421x Patch\n", __FUNCTION__);
+
+    patch_chunk = kzalloc(STIR421X_MAX_PATCH_DOWNLOAD_SIZE, GFP_KERNEL);
+    if (patch_chunk == NULL)
+	    return -ENOMEM;
+    
+    /* break up patch into 1023-byte sections */
+    for (i = 0; retval >= 0 && i < patch_len; i += download_amount) {
+	    download_amount = patch_len - i;
+	    if (download_amount > STIR421X_MAX_PATCH_DOWNLOAD_SIZE)
+		    download_amount = STIR421X_MAX_PATCH_DOWNLOAD_SIZE;
+	    
+	    /* download the patch section */
+	    memcpy(patch_chunk, patch + i, download_amount);
+	    
+	    retval = usb_bulk_msg (self->usbdev,
+				   usb_sndbulkpipe (self->usbdev,
+						    self->bulk_out_ep),
+				   patch_chunk, download_amount,
+				   &actual_len, msecs_to_jiffies (500));
+	    IRDA_DEBUG (2, "%s(), Sent %u bytes\n", __FUNCTION__,
+			actual_len);
+	    if (retval == 0)
+		    mdelay(10);
+    }
+
+    kfree(patch_chunk);
+    
+    if (i != patch_len) {
+	    IRDA_ERROR ("%s(), Pushed %d bytes (!= patch_len (%d))\n", 
+		       __FUNCTION__, i, patch_len);
+	    retval = -EIO;
+    }
+    
+    if (retval < 0)
+	    /* todo - mark device as not ready */
+	    IRDA_ERROR ("%s(), STIR421x patch upload failed (%d)\n", 
+			__FUNCTION__, retval);
+    
+    return retval;
+}
+
+
+static int stir421x_patch_device(struct irda_usb_cb *self)
+{
+	unsigned int i, patch_found = 0, data_found = 0, data_offset;
+	int patch_version, ret = 0;
+	const struct firmware *fw_entry;
+
+	for (i = 0; i < ARRAY_SIZE(stir421x_patches); i++) {		
+		if(request_firmware(&fw_entry, stir421x_patches[i], &self->usbdev->dev) != 0) {
+			IRDA_ERROR( "%s(), Patch %s is not available\n", __FUNCTION__, stir421x_patches[i]);
+			continue;
+		}
+		
+                /* We found a patch from userspace */
+		patch_version = stir421x_get_patch_version (fw_entry->data, fw_entry->size);
+		
+		if (patch_version < 0) {				
+			/* Couldn't fetch a version, let's move on to the next file */
+			IRDA_ERROR("%s(), version parsing failed\n", __FUNCTION__);
+			ret = patch_version;
+			release_firmware(fw_entry);
+			continue;
+		}
+
+		if (patch_version != self->usbdev->descriptor.bcdDevice) {
+			/* Patch version and device don't match */
+			IRDA_ERROR ("%s(), wrong patch version (%d <-> %d)\n", 
+				    __FUNCTION__,
+				    patch_version, self->usbdev->descriptor.bcdDevice);
+			ret = -EINVAL;
+			release_firmware(fw_entry);
+			continue;
+		}
+		
+		/* If we're here, we've found a correct patch */
+		patch_found = 1;
+		break;
+
+	} 
+
+	/* We couldn't find a valid firmware, let's leave */
+	if (!patch_found)
+		return ret;
+	
+	/* The actual image starts after the "STMP" keyword */
+	for (data_offset = 0; data_offset < STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET; data_offset++) {
+		if (!memcmp(fw_entry->data + data_offset, 
+			    STIR421X_PATCH_DATA_TAG_STR, 
+			    sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET))) {
+			IRDA_DEBUG(2, "%s(), found patch data for STIR421x at offset %d\n", 
+				   __FUNCTION__, data_offset);
+			data_found = 1;
+			break;
+		}
+	}
+	
+	/* We couldn't find "STMP" from the header */
+	if (!data_found)
+		return -EINVAL;
+
+	/* Let's upload the patch to the target */
+	ret = stir421x_upload_patch(self, 
+				    &fw_entry->data[data_offset + sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET)],
+				    fw_entry->size - (data_offset + sizeof(STIR421X_PATCH_FILE_IMAGE_MAX_OFFSET)));
+
+	release_firmware(fw_entry);
+	
+	return ret;
+	
+}
+
+
 /********************** IRDA DEVICE CALLBACKS **********************/
 /*
  * Main calls from the IrDA/Network subsystem.
@@ -972,6 +1242,11 @@ static int irda_usb_net_open(struct net_
 		return -1;
 	}
 
+	if(self->needspatch) {
+		IRDA_WARNING("%s(), device needs patch\n", __FUNCTION__) ;
+		return -EIO ;
+	}
+
 	/* Initialise default speed and xbofs value
 	 * (IrLAP will change that soon) */
 	self->speed = -1;
@@ -1050,7 +1325,7 @@ static int irda_usb_net_close(struct net
 	del_timer(&self->rx_defer_timer);
 
 	/* Deallocate all the Rx path buffers (URBs and skb) */
-	for (i = 0; i < IU_MAX_RX_URBS; i++) {
+	for (i = 0; i < self->max_rx_urb; i++) {
 		struct urb *urb = self->rx_urb[i];
 		struct sk_buff *skb = (struct sk_buff *) urb->context;
 		/* Cancel the receive command */
@@ -1426,8 +1701,22 @@ static int irda_usb_probe(struct usb_int
 	spin_lock_init(&self->lock);
 	init_timer(&self->rx_defer_timer);
 
+	self->capability = id->driver_info;
+	self->needspatch = ((self->capability & IUC_STIR_4210) != 0) ;
+
 	/* Create all of the needed urbs */
-	for (i = 0; i < IU_MAX_RX_URBS; i++) {
+	if (self->capability & IUC_STIR_4210) {
+		self->max_rx_urb = IU_SIGMATEL_MAX_RX_URBS;
+		self->header_length = USB_IRDA_SIGMATEL_HEADER;
+	} else {
+		self->max_rx_urb = IU_MAX_RX_URBS;
+		self->header_length = USB_IRDA_HEADER;
+	}
+
+	self->rx_urb = kzalloc(self->max_rx_urb * sizeof(struct urb *),
+				GFP_KERNEL);
+
+	for (i = 0; i < self->max_rx_urb; i++) {
 		self->rx_urb[i] = usb_alloc_urb(0, GFP_KERNEL);
 		if (!self->rx_urb[i]) {
 			goto err_out_1;
@@ -1478,18 +1767,29 @@ static int irda_usb_probe(struct usb_int
 		ret = -EIO;
 		goto err_out_3;
 	}
+	
+	self->usbdev = dev;
 
 	/* Find IrDA class descriptor */
 	irda_desc = irda_usb_find_class_desc(intf);
 	ret = -ENODEV;
 	if (irda_desc == NULL)
 		goto err_out_3;
+	
+	if (self->needspatch) {
+		ret = usb_control_msg (self->usbdev, usb_sndctrlpipe (self->usbdev, 0),
+				       0x02, 0x40, 0, 0, 0, 0, msecs_to_jiffies(500));
+		if (ret < 0) {
+			IRDA_DEBUG (0, "usb_control_msg failed %d\n", ret);
+			goto err_out_3;
+		} else {
+			mdelay(10);
+		}	
+	}
 
 	self->irda_desc =  irda_desc;
 	self->present = 1;
 	self->netopen = 0;
-	self->capability = id->driver_info;
-	self->usbdev = dev;
 	self->usbintf = intf;
 
 	/* Allocate the buffer for speed changes */
@@ -1508,6 +1808,28 @@ static int irda_usb_probe(struct usb_int
 
 	IRDA_MESSAGE("IrDA: Registered device %s\n", net->name);
 	usb_set_intfdata(intf, self);
+
+	if (self->needspatch) {
+		/* Now we fetch and upload the firmware patch */
+		ret = stir421x_patch_device(self);
+		self->needspatch = (ret < 0);
+		if (ret < 0) {
+			printk("patch_device failed\n");
+			goto err_out_4;
+		}
+
+		/* replace IrDA class descriptor with what patched device is now reporting */
+		irda_desc = irda_usb_find_class_desc (self->usbintf);
+		if (irda_desc == NULL) {			
+			ret = -ENODEV;
+			goto err_out_4;
+		}
+		if (self->irda_desc)
+			kfree (self->irda_desc);
+		self->irda_desc = irda_desc;
+		irda_usb_init_qos(self);
+	}
+
 	return 0;
 
 err_out_4:
@@ -1518,7 +1840,7 @@ err_out_3:
 err_out_2:
 	usb_free_urb(self->tx_urb);
 err_out_1:
-	for (i = 0; i < IU_MAX_RX_URBS; i++) {
+	for (i = 0; i < self->max_rx_urb; i++) {
 		if (self->rx_urb[i])
 			usb_free_urb(self->rx_urb[i]);
 	}
@@ -1571,7 +1893,7 @@ static void irda_usb_disconnect(struct u
 		/*netif_device_detach(self->netdev);*/
 		netif_stop_queue(self->netdev);
 		/* Stop all the receive URBs. Must be synchronous. */
-		for (i = 0; i < IU_MAX_RX_URBS; i++)
+		for (i = 0; i < self->max_rx_urb; i++)
 			usb_kill_urb(self->rx_urb[i]);
 		/* Cancel Tx and speed URB.
 		 * Make sure it's synchronous to avoid races. */
@@ -1586,8 +1908,9 @@ static void irda_usb_disconnect(struct u
 	self->usbintf = NULL;
 
 	/* Clean up our urbs */
-	for (i = 0; i < IU_MAX_RX_URBS; i++)
+	for (i = 0; i < self->max_rx_urb; i++)
 		usb_free_urb(self->rx_urb[i]);
+	kfree(self->rx_urb);
 	/* Clean up Tx and speed URB */
 	usb_free_urb(self->tx_urb);
 	usb_free_urb(self->speed_urb);
@@ -1648,6 +1971,6 @@ module_exit(usb_irda_cleanup);
  */
 module_param(qos_mtt_bits, int, 0);
 MODULE_PARM_DESC(qos_mtt_bits, "Minimum Turn Time");
-MODULE_AUTHOR("Roman Weissgaerber <weissg-TVDPYGuBT+ReoWH0uzbU5w@public.gmane.org>, Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org> and Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>");
-MODULE_DESCRIPTION("IrDA-USB Dongle Driver"); 
+MODULE_AUTHOR("Roman Weissgaerber <weissg-TVDPYGuBT+ReoWH0uzbU5w@public.gmane.org>, Dag Brattli <dag-1K3ejsF8QZHR7s880joybQ@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org> and Nick Fedchik <nick-UvdXiu2sajOKBXSJ/Qx0JQ@public.gmane.org>");
+MODULE_DESCRIPTION("IrDA-USB Dongle Driver");
 MODULE_LICENSE("GPL");



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
