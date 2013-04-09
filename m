From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT PATCH 1/2 V2] btusb: Modify code for use with a similar driver
Date: Mon,  8 Apr 2013 19:57:47 -0500
Message-ID: <1365469068-4548-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, marcel@holtmann.org, gustavo@padovan.org,
	johan.hedberg@gmail.com, linux-bluetooth@vger.kernel.org,
	champion_chen@realsil.com.cn
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:38339 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936469Ab3DIA6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 20:58:15 -0400
In-Reply-To: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports some routines contained within this driver so that
they can be used by similar device that uses many of the same routines,
but which has a few special requirements that prevent using btusb in
its entirety.

To facilitate this usage, a new file btusb.h is created.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/bluetooth/btusb.c | 79 ++++++++++--------------------------------
 drivers/bluetooth/btusb.h | 88 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 60 deletions(-)
 create mode 100644 drivers/bluetooth/btusb.h

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 2cc5f77..5365cd1 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -27,6 +27,8 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 
+#include "btusb.h"
+
 #define VERSION "0.6"
 
 static bool ignore_dga;
@@ -39,15 +41,6 @@ static bool reset = 1;
 
 static struct usb_driver btusb_driver;
 
-#define BTUSB_IGNORE		0x01
-#define BTUSB_DIGIANSWER	0x02
-#define BTUSB_CSR		0x04
-#define BTUSB_SNIFFER		0x08
-#define BTUSB_BCM92035		0x10
-#define BTUSB_BROKEN_ISOC	0x20
-#define BTUSB_WRONG_SCO_MTU	0x40
-#define BTUSB_ATH3012		0x80
-
 static struct usb_device_id btusb_table[] = {
 	/* Generic Bluetooth USB device */
 	{ USB_DEVICE_INFO(0xe0, 0x01, 0x01) },
@@ -209,48 +202,6 @@ static struct usb_device_id blacklist_table[] = {
 	{ }	/* Terminating entry */
 };
 
-#define BTUSB_MAX_ISOC_FRAMES	10
-
-#define BTUSB_INTR_RUNNING	0
-#define BTUSB_BULK_RUNNING	1
-#define BTUSB_ISOC_RUNNING	2
-#define BTUSB_SUSPENDING	3
-#define BTUSB_DID_ISO_RESUME	4
-
-struct btusb_data {
-	struct hci_dev       *hdev;
-	struct usb_device    *udev;
-	struct usb_interface *intf;
-	struct usb_interface *isoc;
-
-	spinlock_t lock;
-
-	unsigned long flags;
-
-	struct work_struct work;
-	struct work_struct waker;
-
-	struct usb_anchor tx_anchor;
-	struct usb_anchor intr_anchor;
-	struct usb_anchor bulk_anchor;
-	struct usb_anchor isoc_anchor;
-	struct usb_anchor deferred;
-	int tx_in_flight;
-	spinlock_t txlock;
-
-	struct usb_endpoint_descriptor *intr_ep;
-	struct usb_endpoint_descriptor *bulk_tx_ep;
-	struct usb_endpoint_descriptor *bulk_rx_ep;
-	struct usb_endpoint_descriptor *isoc_tx_ep;
-	struct usb_endpoint_descriptor *isoc_rx_ep;
-
-	__u8 cmdreq_type;
-
-	unsigned int sco_num;
-	int isoc_altsetting;
-	int suspend_count;
-};
-
 static int inc_tx(struct btusb_data *data)
 {
 	unsigned long flags;
@@ -305,7 +256,7 @@ static void btusb_intr_complete(struct urb *urb)
 	}
 }
 
-static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
+int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 {
 	struct btusb_data *data = hci_get_drvdata(hdev);
 	struct urb *urb;
@@ -352,6 +303,7 @@ static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(btusb_submit_intr_urb);
 
 static void btusb_bulk_complete(struct urb *urb)
 {
@@ -393,7 +345,7 @@ static void btusb_bulk_complete(struct urb *urb)
 	}
 }
 
-static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
+int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 {
 	struct btusb_data *data = hci_get_drvdata(hdev);
 	struct urb *urb;
@@ -438,8 +390,9 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(btusb_submit_bulk_urb);
 
-static void btusb_isoc_complete(struct urb *urb)
+void btusb_isoc_complete(struct urb *urb)
 {
 	struct hci_dev *hdev = urb->context;
 	struct btusb_data *data = hci_get_drvdata(hdev);
@@ -507,7 +460,7 @@ static inline void __fill_isoc_descriptor(struct urb *urb, int len, int mtu)
 	urb->number_of_packets = i;
 }
 
-static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
+int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 {
 	struct btusb_data *data = hci_get_drvdata(hdev);
 	struct urb *urb;
@@ -557,6 +510,7 @@ static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(btusb_submit_isoc_urb);
 
 static void btusb_tx_complete(struct urb *urb)
 {
@@ -650,12 +604,13 @@ failed:
 	return err;
 }
 
-static void btusb_stop_traffic(struct btusb_data *data)
+void btusb_stop_traffic(struct btusb_data *data)
 {
 	usb_kill_anchored_urbs(&data->intr_anchor);
 	usb_kill_anchored_urbs(&data->bulk_anchor);
 	usb_kill_anchored_urbs(&data->isoc_anchor);
 }
+EXPORT_SYMBOL(btusb_stop_traffic);
 
 static int btusb_close(struct hci_dev *hdev)
 {
@@ -687,7 +642,7 @@ failed:
 	return 0;
 }
 
-static int btusb_flush(struct hci_dev *hdev)
+int btusb_flush(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hci_get_drvdata(hdev);
 
@@ -697,8 +652,9 @@ static int btusb_flush(struct hci_dev *hdev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(btusb_flush);
 
-static int btusb_send_frame(struct sk_buff *skb)
+int btusb_send_frame(struct sk_buff *skb)
 {
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btusb_data *data = hci_get_drvdata(hdev);
@@ -808,8 +764,9 @@ done:
 	usb_free_urb(urb);
 	return err;
 }
+EXPORT_SYMBOL_GPL(btusb_send_frame);
 
-static void btusb_notify(struct hci_dev *hdev, unsigned int evt)
+void btusb_notify(struct hci_dev *hdev, unsigned int evt)
 {
 	struct btusb_data *data = hci_get_drvdata(hdev);
 
@@ -820,6 +777,7 @@ static void btusb_notify(struct hci_dev *hdev, unsigned int evt)
 		schedule_work(&data->work);
 	}
 }
+EXPORT_SYMBOL_GPL(btusb_notify);
 
 static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
 {
@@ -914,7 +872,7 @@ static void btusb_work(struct work_struct *work)
 	}
 }
 
-static void btusb_waker(struct work_struct *work)
+void btusb_waker(struct work_struct *work)
 {
 	struct btusb_data *data = container_of(work, struct btusb_data, waker);
 	int err;
@@ -925,6 +883,7 @@ static void btusb_waker(struct work_struct *work)
 
 	usb_autopm_put_interface(data->intf);
 }
+EXPORT_SYMBOL_GPL(btusb_waker);
 
 static int btusb_probe(struct usb_interface *intf,
 				const struct usb_device_id *id)
diff --git a/drivers/bluetooth/btusb.h b/drivers/bluetooth/btusb.h
new file mode 100644
index 0000000..d9d7181
--- /dev/null
+++ b/drivers/bluetooth/btusb.h
@@ -0,0 +1,88 @@
+/*
+ *
+ *  Generic Bluetooth USB driver
+ *
+ *  Copyright (C) 2005-2008  Marcel Holtmann <marcel@holtmann.org>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef BTUSB_H
+#define BTUSB_H
+
+#define BTUSB_IGNORE		0x01
+#define BTUSB_DIGIANSWER	0x02
+#define BTUSB_CSR		0x04
+#define BTUSB_SNIFFER		0x08
+#define BTUSB_BCM92035		0x10
+#define BTUSB_BROKEN_ISOC	0x20
+#define BTUSB_WRONG_SCO_MTU	0x40
+#define BTUSB_ATH3012		0x80
+
+#define BTUSB_MAX_ISOC_FRAMES	10
+
+#define BTUSB_INTR_RUNNING	0
+#define BTUSB_BULK_RUNNING	1
+#define BTUSB_ISOC_RUNNING	2
+#define BTUSB_SUSPENDING	3
+#define BTUSB_DID_ISO_RESUME	4
+
+struct btusb_data {
+	struct hci_dev       *hdev;
+	struct usb_device    *udev;
+	struct usb_interface *intf;
+	struct usb_interface *isoc;
+
+	spinlock_t lock;
+
+	unsigned long flags;
+
+	struct work_struct work;
+	struct work_struct waker;
+
+	struct usb_anchor tx_anchor;
+	struct usb_anchor intr_anchor;
+	struct usb_anchor bulk_anchor;
+	struct usb_anchor isoc_anchor;
+	struct usb_anchor deferred;
+	int tx_in_flight;
+	spinlock_t txlock;
+
+	struct usb_endpoint_descriptor *intr_ep;
+	struct usb_endpoint_descriptor *bulk_tx_ep;
+	struct usb_endpoint_descriptor *bulk_rx_ep;
+	struct usb_endpoint_descriptor *isoc_tx_ep;
+	struct usb_endpoint_descriptor *isoc_rx_ep;
+
+	__u8 cmdreq_type;
+
+	unsigned int sco_num;
+	int isoc_altsetting;
+	int suspend_count;
+};
+
+int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags);
+int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags);
+void btusb_isoc_complete(struct urb *urb);
+int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags);
+void btusb_stop_traffic(struct btusb_data *data);
+int btusb_flush(struct hci_dev *hdev);
+int btusb_send_frame(struct sk_buff *skb);
+void btusb_notify(struct hci_dev *hdev, unsigned int evt);
+void btusb_waker(struct work_struct *work);
+
+#endif
-- 
1.8.1.4
