From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 21/50] hid: usbhid: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:44 +0800
Message-ID: <1373533573-12272-22-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Jiri Kosina <jkosina@suse.cz>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:64331 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259Ab3GKJJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:25 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Jiri Kosina <jkosina@suse.cz>
Cc: linux-input@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/hid/usbhid/hid-core.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/hid/usbhid/hid-core.c b/drivers/hid/usbhid/hid-core.c
index 9941828..e1d8518 100644
--- a/drivers/hid/usbhid/hid-core.c
+++ b/drivers/hid/usbhid/hid-core.c
@@ -489,8 +489,9 @@ static void hid_ctrl(struct urb *urb)
 	struct hid_device *hid = urb->context;
 	struct usbhid_device *usbhid = hid->driver_data;
 	int unplug = 0, status = urb->status;
+	unsigned long flags;
 
-	spin_lock(&usbhid->lock);
+	spin_lock_irqsave(&usbhid->lock, flags);
 
 	switch (status) {
 	case 0:			/* success */
@@ -525,7 +526,7 @@ static void hid_ctrl(struct urb *urb)
 	}
 
 	clear_bit(HID_CTRL_RUNNING, &usbhid->iofl);
-	spin_unlock(&usbhid->lock);
+	spin_unlock_irqrestore(&usbhid->lock, flags);
 	usb_autopm_put_interface_async(usbhid->intf);
 	wake_up(&usbhid->wait);
 }
-- 
1.7.9.5
