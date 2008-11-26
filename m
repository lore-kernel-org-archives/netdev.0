From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 29/39] i2400m/USB: handling of notifications from the device
Date: Wed, 26 Nov 2008 14:40:48 -0800
Message-ID: <5a1e98b08ecae0835161d3072efb9a630da9cf28.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:63114 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752904AbYKZWlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:40 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device has anything for the host (namely when there is data
ready to be read or when it resets), it sends a notification to the
host; this is the code that receives and deals with them, passing
reads to i2400m_rx() or handling resets with
i2400m_dev_reset_handle().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb-notif.c |  263 ++++++++++++++++++++++++++++++++++
 1 files changed, 263 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/usb-notif.c

diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
new file mode 100644
index 0000000..2715d58
--- /dev/null
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -0,0 +1,263 @@
+/*
+ * Intel Wireless WiMAX Connection 2400m over USB
+ * Notification handling
+ *
+ *
+ * Copyright (C) 2007-2008 Intel Corporation. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *   * Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *   * Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in
+ *     the documentation and/or other materials provided with the
+ *     distribution.
+ *   * Neither the name of Intel Corporation nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * Intel Corporation <linux-wimax@intel.com>
+ * Yanir Lubetkin <yanirx.lubetkin@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *  - Initial implementation
+ *
+ *
+ * The notification endpoint is active when the device is not in boot
+ * mode; in here we just read and get notifications; based on those,
+ * we act to either reinitialize the device after a reboot or to
+ * submit a RX request.
+ *
+ * ROADMAP
+ *
+ * i2400mu_usb_notification_setup()
+ *
+ * i2400mu_usb_notification_release()
+ *
+ * i2400mu_usb_notification_cb()	Called when a URB is ready
+ *   i2400mu_notif_grok()
+ *     i2400m_dev_reset_handle()
+ *     i2400mu_rx_kick()
+ */
+#include <linux/usb.h>
+#include "i2400m-usb.h"
+
+
+#define D_SUBMODULE notif
+#include "usb-debug-levels.h"
+
+
+static const
+__le32 i2400m_ZERO_BARKER[4] = { 0, 0, 0, 0 };
+
+
+/*
+ * Process a received notification
+ *
+ * In normal operation mode, we can only receive two types of payloads
+ * on the notification endpoint:
+ *
+ *   - a reboot barker, we do a bootstrap (the device has reseted).
+ *
+ *   - a block of zeroes: there is pending data in the IN endpoint
+ */
+static
+int i2400mu_notification_grok(struct i2400mu *i2400mu, const void *buf,
+				 size_t buf_len)
+{
+	int ret;
+	struct device *dev = &i2400mu->usb_iface->dev;
+	struct i2400m *i2400m = &i2400mu->i2400m;
+
+	d_fnstart(4, dev, "(i2400m %p buf %p buf_len %zu)\n",
+		  i2400mu, buf, buf_len);
+	ret = -EIO;
+	if (buf_len < sizeof(i2400m_NBOOT_BARKER))
+		/* Not a bug, just ignore */
+		goto error_bad_size;
+	if (!memcmp(i2400m_NBOOT_BARKER, buf, sizeof(i2400m_NBOOT_BARKER))
+	    || !memcmp(i2400m_SBOOT_BARKER, buf, sizeof(i2400m_SBOOT_BARKER)))
+		ret = i2400m_dev_reset_handle(i2400m);
+	else if (!memcmp(i2400m_ZERO_BARKER, buf, sizeof(i2400m_ZERO_BARKER))) {
+		i2400mu_rx_kick(i2400mu);
+		ret = 0;
+	} else {	/* Unknown or unexpected data in the notif message */
+		char prefix[64];
+		ret = -EIO;
+		dev_err(dev, "HW BUG? Unknown/unexpected data in notification "
+			"message (%zu bytes)\n", buf_len);
+		snprintf(prefix, sizeof(prefix), "%s %s: ",
+			 dev_driver_string(dev) , dev->bus_id);
+		if (buf_len > 64) {
+			print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
+				       8, 4, buf, 64, 0);
+			printk(KERN_ERR "%s... (only first 64 bytes "
+			       "dumped)\n", prefix);
+		} else
+			print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
+				       8, 4, buf, buf_len, 0);
+	}
+error_bad_size:
+	d_fnend(4, dev, "(i2400m %p buf %p buf_len %zu) = %d\n",
+		i2400mu, buf, buf_len, ret);
+	return ret;
+}
+
+
+/*
+ * URB callback for the notification endpoint
+ *
+ * @urb: the urb received from the notification endpoint
+ *
+ * This function will just process the USB side of the transaction,
+ * checking everything is fine, pass the processing to
+ * i2400m_notification_grok() and resubmit the URB.
+ */
+static
+void i2400mu_notification_cb(struct urb *urb)
+{
+	int ret;
+	struct i2400mu *i2400mu = urb->context;
+	struct device *dev = &i2400mu->usb_iface->dev;
+
+	d_fnstart(4, dev, "(urb %p status %d actual_length %d)\n",
+		  urb, urb->status, urb->actual_length);
+	ret = urb->status;
+	switch (ret) {
+	case 0:
+		ret = i2400mu_notification_grok(i2400mu, urb->transfer_buffer,
+						urb->actual_length);
+		if (ret == -EIO && edc_inc(&i2400mu->urb_edc, EDC_MAX_ERRORS,
+					   EDC_ERROR_TIMEFRAME))
+			goto error_exceeded;
+		if (ret == -ENOMEM)	/* uff...power cycle? shutdown? */
+			goto error_exceeded;
+		break;
+	case -EINVAL:			/* while removing driver */
+	case -ENODEV:			/* dev disconnect ... */
+	case -ENOENT:			/* ditto */
+	case -ESHUTDOWN:		/* URB killed */
+	case -ECONNRESET:		/* disconnection */
+		goto out;		/* Notify around */
+	default:			/* Some error? */
+		if (edc_inc(&i2400mu->urb_edc,
+			    EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME))
+			goto error_exceeded;
+		dev_err(dev, "notification: URB error %d, retrying\n",
+			urb->status);
+	}
+	usb_mark_last_busy(i2400mu->usb_dev);
+	ret = usb_submit_urb(i2400mu->notif_urb, GFP_ATOMIC);
+	if (ret != 0) {
+		dev_err(dev, "notification: cannot submit URB: %d\n", ret);
+		goto error_submit;
+	}
+
+	d_fnend(4, dev, "(urb %p status %d actual_length %d) = void\n",
+		urb, urb->status, urb->actual_length);
+	return;
+
+error_exceeded:
+	dev_err(dev, "maximum errors in notification URB exceeded; "
+		"resetting device\n");
+error_submit:
+	usb_queue_reset_device(i2400mu->usb_iface);
+out:
+	d_fnend(4, dev, "(urb %p status %d actual_length %d) = void\n",
+		urb, urb->status, urb->actual_length);
+	return;
+}
+
+
+/*
+ * setup the notification endpoint
+ *
+ * @i2400m: device descriptor
+ *
+ * This procedure prepares the notification urb and handler for receiving
+ * unsolicited barkers from the device.
+ */
+int i2400mu_notification_setup(struct i2400mu *i2400mu)
+{
+	struct device *dev = &i2400mu->usb_iface->dev;
+	int usb_pipe, ret = 0;
+	struct usb_endpoint_descriptor *epd;
+	char *buf;
+
+	d_fnstart(4, dev, "(i2400m %p)\n", i2400mu);
+	buf = kmalloc(I2400MU_MAX_NOTIFICATION_LEN, GFP_KERNEL | GFP_DMA);
+	if (buf == NULL) {
+		dev_err(dev, "notification: buffer allocation failed\n");
+		ret = -ENOMEM;
+		goto error_buf_alloc;
+	}
+
+	i2400mu->notif_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!i2400mu->notif_urb) {
+		ret = -ENOMEM;
+		dev_err(dev, "notification: cannot allocate URB\n");
+		goto error_alloc_urb;
+	}
+	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_NOTIFICATION);
+	usb_pipe = usb_rcvintpipe(i2400mu->usb_dev, epd->bEndpointAddress);
+	usb_fill_int_urb(i2400mu->notif_urb, i2400mu->usb_dev, usb_pipe,
+			 buf, I2400MU_MAX_NOTIFICATION_LEN,
+			 i2400mu_notification_cb, i2400mu, epd->bInterval);
+	ret = usb_submit_urb(i2400mu->notif_urb, GFP_KERNEL);
+	if (ret != 0) {
+		dev_err(dev, "notification: cannot submit URB: %d\n", ret);
+		goto error_submit;
+	}
+	d_fnend(4, dev, "(i2400m %p) = %d\n", i2400mu, ret);
+	return ret;
+
+error_submit:
+	usb_free_urb(i2400mu->notif_urb);
+error_alloc_urb:
+	kfree(buf);
+error_buf_alloc:
+	d_fnend(4, dev, "(i2400m %p) = %d\n", i2400mu, ret);
+	return ret;
+}
+
+
+/*
+ * Tear down of the notification mechanism
+ *
+ * @i2400m: device descriptor
+ *
+ * Kill the interrupt endpoint urb, free any allocated resources.
+ *
+ * We need to check if we have done it before as for example,
+ * _suspend() call this; if after a suspend() we get a _disconnect()
+ * (as the case is when hibernating), nothing bad happens.
+ */
+void i2400mu_notification_release(struct i2400mu *i2400mu)
+{
+	struct device *dev = &i2400mu->usb_iface->dev;
+
+	d_fnstart(4, dev, "(i2400mu %p)\n", i2400mu);
+	if (i2400mu->notif_urb != NULL) {
+		usb_kill_urb(i2400mu->notif_urb);
+		kfree(i2400mu->notif_urb->transfer_buffer);
+		usb_free_urb(i2400mu->notif_urb);
+		i2400mu->notif_urb = NULL;
+	}
+	d_fnend(4, dev, "(i2400mu %p)\n", i2400mu);
+}
+
-- 
1.5.6.5

