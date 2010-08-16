From: Alan Ott <alan@signal11.us>
Subject: [PATCH v4 1/2] HID: Add Support for Setting and Getting Feature Reports from hidraw
Date: Mon, 16 Aug 2010 16:20:58 -0400
Message-ID: <1281990059-3562-2-git-send-email-alan@signal11.us>
References: <1281442367.12579.206.camel@localhost.localdomain>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:46234 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756410Ab0HPUVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 16:21:49 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id 20D4C1CCAA4E
	for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 16:21:48 -0400 (EDT)
In-Reply-To: <1281442367.12579.206.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per the HID Specification, Feature reports must be sent and received on
the Configuration endpoint (EP 0) through the Set_Report/Get_Report
interfaces.  This patch adds two ioctls to hidraw to set and get feature
reports to and from the device.  Modifications were made to hidraw and
usbhid.

New hidraw ioctls:
  HIDIOCSFEATURE - Perform a Set_Report transfer of a Feature report.
  HIDIOCGFEATURE - Perform a Get_Report transfer of a Feature report.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 drivers/hid/hidraw.c          |  105 +++++++++++++++++++++++++++++++++++++++--
 drivers/hid/usbhid/hid-core.c |   37 ++++++++++++++-
 include/linux/hid.h           |    3 +
 include/linux/hidraw.h        |    3 +
 4 files changed, 142 insertions(+), 6 deletions(-)

diff --git a/drivers/hid/hidraw.c b/drivers/hid/hidraw.c
index 47d70c5..7df1310 100644
--- a/drivers/hid/hidraw.c
+++ b/drivers/hid/hidraw.c
@@ -101,14 +101,14 @@ out:
 }
 
 /* the first byte is expected to be a report number */
-static ssize_t hidraw_write(struct file *file, const char __user *buffer, size_t count, loff_t *ppos)
+/* This function is to be called with the minors_lock mutex held */
+static ssize_t hidraw_send_report(struct file *file, const char __user *buffer, size_t count, unsigned char report_type)
 {
 	unsigned int minor = iminor(file->f_path.dentry->d_inode);
 	struct hid_device *dev;
 	__u8 *buf;
 	int ret = 0;
 
-	mutex_lock(&minors_lock);
 	dev = hidraw_table[minor]->hid;
 
 	if (!dev->hid_output_raw_report) {
@@ -141,14 +141,92 @@ static ssize_t hidraw_write(struct file *file, const char __user *buffer, size_t
 		goto out_free;
 	}
 
-	ret = dev->hid_output_raw_report(dev, buf, count, HID_OUTPUT_REPORT);
+	ret = dev->hid_output_raw_report(dev, buf, count, report_type);
 out_free:
 	kfree(buf);
 out:
+	return ret;
+}
+
+/* the first byte is expected to be a report number */
+static ssize_t hidraw_write(struct file *file, const char __user *buffer, size_t count, loff_t *ppos)
+{
+	ssize_t ret;
+	mutex_lock(&minors_lock);
+	ret = hidraw_send_report(file, buffer, count, HID_OUTPUT_REPORT);
 	mutex_unlock(&minors_lock);
 	return ret;
 }
 
+
+/* This function performs a Get_Report transfer over the control endpoint
+   per section 7.2.1 of the HID specification, version 1.1.  The first byte
+   of buffer is the report number to request, or 0x0 if the defice does not
+   use numbered reports. The report_type parameter can be HID_FEATURE_REPORT
+   or HID_INPUT_REPORT.  This function is to be called with the minors_lock
+   mutex held.  */
+static ssize_t hidraw_get_report(struct file *file, char __user *buffer, size_t count, unsigned char report_type)
+{
+	unsigned int minor = iminor(file->f_path.dentry->d_inode);
+	struct hid_device *dev;
+	__u8 *buf;
+	int ret = 0, len;
+	unsigned char report_number;
+
+	dev = hidraw_table[minor]->hid;
+
+	if (!dev->hid_get_raw_report) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	if (count > HID_MAX_BUFFER_SIZE) {
+		printk(KERN_WARNING "hidraw: pid %d passed too large report\n",
+				task_pid_nr(current));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (count < 2) {
+		printk(KERN_WARNING "hidraw: pid %d passed too short report\n",
+				task_pid_nr(current));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	buf = kmalloc(count * sizeof(__u8), GFP_KERNEL);
+	if (!buf) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* Read the first byte from the user. This is the report number,
+	   which is passed to dev->hid_get_raw_report(). */
+	if (copy_from_user(&report_number, buffer, 1)) {
+		ret = -EFAULT;
+		goto out_free;
+	}
+
+	ret = dev->hid_get_raw_report(dev, report_number, buf, count, report_type);
+
+	if (ret < 0)
+		goto out_free;
+
+	len = (ret < count) ? ret : count;
+
+	if (copy_to_user(buffer, buf, len)) {
+		ret = -EFAULT;
+		goto out_free;
+	}
+
+	ret = len;
+
+out_free:
+	kfree(buf);
+out:
+	return ret;
+}
+
 static unsigned int hidraw_poll(struct file *file, poll_table *wait)
 {
 	struct hidraw_list *list = file->private_data;
@@ -281,7 +359,24 @@ static long hidraw_ioctl(struct file *file, unsigned int cmd,
 		default:
 			{
 				struct hid_device *hid = dev->hid;
-				if (_IOC_TYPE(cmd) != 'H' || _IOC_DIR(cmd) != _IOC_READ) {
+				if (_IOC_TYPE(cmd) != 'H') {
+					ret = -EINVAL;
+					break;
+				}
+
+				if (_IOC_NR(cmd) == _IOC_NR(HIDIOCSFEATURE(0))) {
+					int len = _IOC_SIZE(cmd);
+					ret = hidraw_send_report(file, user_arg, len, HID_FEATURE_REPORT);
+					break;
+				}
+				if (_IOC_NR(cmd) == _IOC_NR(HIDIOCGFEATURE(0))) {
+					int len = _IOC_SIZE(cmd);
+					ret = hidraw_get_report(file, user_arg, len, HID_FEATURE_REPORT);
+					break;
+				}
+
+				/* Begin Read-only ioctls. */
+				if (_IOC_DIR(cmd) != _IOC_READ) {
 					ret = -EINVAL;
 					break;
 				}
@@ -313,7 +408,7 @@ static long hidraw_ioctl(struct file *file, unsigned int cmd,
 						-EFAULT : len;
 					break;
 				}
-		}
+			}
 
 		ret = -ENOTTY;
 	}
diff --git a/drivers/hid/usbhid/hid-core.c b/drivers/hid/usbhid/hid-core.c
index b729c02..93db724 100644
--- a/drivers/hid/usbhid/hid-core.c
+++ b/drivers/hid/usbhid/hid-core.c
@@ -798,6 +798,40 @@ static int hid_alloc_buffers(struct usb_device *dev, struct hid_device *hid)
 	return 0;
 }
 
+static int usbhid_get_raw_report(struct hid_device *hid,
+		unsigned char report_number, __u8 *buf, size_t count,
+		unsigned char report_type)
+{
+	struct usbhid_device *usbhid = hid->driver_data;
+	struct usb_device *dev = hid_to_usb_dev(hid);
+	struct usb_interface *intf = usbhid->intf;
+	struct usb_host_interface *interface = intf->cur_altsetting;
+	int skipped_report_id = 0;
+	int ret;
+
+	/* Byte 0 is the report number. Report data starts at byte 1.*/
+	buf[0] = report_number;
+	if (report_number == 0x0) {
+		/* Offset the return buffer by 1, so that the report ID
+		   will remain in byte 0. */
+		buf++;
+		count--;
+		skipped_report_id = 1;
+	}
+	ret = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
+		HID_REQ_GET_REPORT,
+		USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
+		((report_type + 1) << 8) | report_number,
+		interface->desc.bInterfaceNumber, buf, count,
+		USB_CTRL_SET_TIMEOUT);
+
+	/* count also the report id */
+	if (ret > 0 && skipped_report_id)
+		ret++;
+
+	return ret;
+}
+
 static int usbhid_output_raw_report(struct hid_device *hid, __u8 *buf, size_t count,
 		unsigned char report_type)
 {
@@ -807,7 +841,7 @@ static int usbhid_output_raw_report(struct hid_device *hid, __u8 *buf, size_t co
 	struct usb_host_interface *interface = intf->cur_altsetting;
 	int ret;
 
-	if (usbhid->urbout) {
+	if (usbhid->urbout && report_type != HID_FEATURE_REPORT) {
 		int actual_length;
 		int skipped_report_id = 0;
 		if (buf[0] == 0x0) {
@@ -1149,6 +1183,7 @@ static int usbhid_probe(struct usb_interface *intf, const struct usb_device_id *
 
 	usb_set_intfdata(intf, hid);
 	hid->ll_driver = &usb_hid_driver;
+	hid->hid_get_raw_report = usbhid_get_raw_report;
 	hid->hid_output_raw_report = usbhid_output_raw_report;
 	hid->ff_init = hid_pidff_init;
 #ifdef CONFIG_USB_HIDDEV
diff --git a/include/linux/hid.h b/include/linux/hid.h
index 42a0f1d..1b95b0b 100644
--- a/include/linux/hid.h
+++ b/include/linux/hid.h
@@ -503,6 +503,9 @@ struct hid_device {							/* device report descriptor */
 				  struct hid_usage *, __s32);
 	void (*hiddev_report_event) (struct hid_device *, struct hid_report *);
 
+	/* handler for raw input (Get_Report) data, used by hidraw */
+	int (*hid_get_raw_report) (struct hid_device *, unsigned char, __u8 *, size_t, unsigned char);
+
 	/* handler for raw output data, used by hidraw */
 	int (*hid_output_raw_report) (struct hid_device *, __u8 *, size_t, unsigned char);
 
diff --git a/include/linux/hidraw.h b/include/linux/hidraw.h
index dd8d692..4b88e69 100644
--- a/include/linux/hidraw.h
+++ b/include/linux/hidraw.h
@@ -35,6 +35,9 @@ struct hidraw_devinfo {
 #define HIDIOCGRAWINFO		_IOR('H', 0x03, struct hidraw_devinfo)
 #define HIDIOCGRAWNAME(len)     _IOC(_IOC_READ, 'H', 0x04, len)
 #define HIDIOCGRAWPHYS(len)     _IOC(_IOC_READ, 'H', 0x05, len)
+/* The first byte of SFEATURE and GFEATURE is the report number */
+#define HIDIOCSFEATURE(len)    _IOC(_IOC_WRITE|_IOC_READ, 'H', 0x06, len)
+#define HIDIOCGFEATURE(len)    _IOC(_IOC_WRITE|_IOC_READ, 'H', 0x07, len)
 
 #define HIDRAW_FIRST_MINOR 0
 #define HIDRAW_MAX_DEVICES 64
-- 
1.7.0.4


