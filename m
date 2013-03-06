From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 3/7] USBHID: don't recover device if suspend fails in system sleep
Date: Wed,  6 Mar 2013 18:25:52 +0800
Message-ID: <1362565557-15884-4-git-send-email-ming.lei@canonical.com>
References: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If suspend callback fails in system sleep context, usb core will
ignore the failure and let the system sleep go ahead further, so this
patch doesn't recover device under this situation, otherwise
may cause resume() confused.

Cc: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/hid/usbhid/hid-core.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/hid/usbhid/hid-core.c b/drivers/hid/usbhid/hid-core.c
index 8e0c4bf94..1f9e56b 100644
--- a/drivers/hid/usbhid/hid-core.c
+++ b/drivers/hid/usbhid/hid-core.c
@@ -1493,7 +1493,7 @@ static int hid_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct hid_device *hid = usb_get_intfdata(intf);
 	struct usbhid_device *usbhid = hid->driver_data;
-	int status;
+	int status = 0;
 	bool driver_suspended = false;
 
 	if (PMSG_IS_AUTO(message)) {
@@ -1520,19 +1520,15 @@ static int hid_suspend(struct usb_interface *intf, pm_message_t message)
 		}
 
 	} else {
-		if (hid->driver && hid->driver->suspend) {
+		/* TODO: resume() might need to handle suspend failure */
+		if (hid->driver && hid->driver->suspend)
 			status = hid->driver->suspend(hid, message);
-			if (status < 0)
-				return status;
-		}
 		driver_suspended = true;
 		spin_lock_irq(&usbhid->lock);
 		set_bit(HID_SUSPENDED, &usbhid->iofl);
 		spin_unlock_irq(&usbhid->lock);
-		if (usbhid_wait_io(hid) < 0) {
+		if (usbhid_wait_io(hid) < 0)
 			status = -EIO;
-			goto failed;
-		}
 	}
 
 	hid_cancel_delayed_stuff(usbhid);
@@ -1544,7 +1540,7 @@ static int hid_suspend(struct usb_interface *intf, pm_message_t message)
 		goto failed;
 	}
 	dev_dbg(&intf->dev, "suspend\n");
-	return 0;
+	return status;
 
  failed:
 	hid_resume_common(hid, driver_suspended);
-- 
1.7.9.5

