From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v3 1/7] USB: adds comment on suspend callback
Date: Fri, 15 Mar 2013 12:08:53 +0800
Message-ID: <1363320539-23012-2-git-send-email-ming.lei@canonical.com>
References: <1363320539-23012-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363320539-23012-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case and let resume/reset_resume callback
handle the suspend failure if needed.

Also kerneldoc for usb_suspend_both() is updated with the
fact.

Acked-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/usb/core/driver.c |   11 ++++++++---
 include/linux/usb.h       |    7 ++++++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/core/driver.c b/drivers/usb/core/driver.c
index d938b2b..eb1d00a 100644
--- a/drivers/usb/core/driver.c
+++ b/drivers/usb/core/driver.c
@@ -1196,9 +1196,14 @@ done:
  *
  * This is the central routine for suspending USB devices.  It calls the
  * suspend methods for all the interface drivers in @udev and then calls
- * the suspend method for @udev itself.  If an error occurs at any stage,
- * all the interfaces which were suspended are resumed so that they remain
- * in the same state as the device.
+ * the suspend method for @udev itself.  When the routine is called in
+ * autosuspend, if an error occurs at any stage, all the interfaces
+ * which were suspended are resumed so that they remain in the same
+ * state as the device, but when called from system sleep, all error
+ * from suspend methods of interfaces and the non-root-hub device itself
+ * are simply ignored, so all suspended interfaces are only resumed
+ * to the device's state when @udev is root-hub and its suspend method
+ * returns failure.
  *
  * Autosuspend requests originating from a child device or an interface
  * driver may be made without the protection of @udev's device lock, but
diff --git a/include/linux/usb.h b/include/linux/usb.h
index 4d22d0f..f82ce57 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -978,7 +978,12 @@ struct usbdrv_wrap {
  *	the "usbfs" filesystem.  This lets devices provide ways to
  *	expose information to user space regardless of where they
  *	do (or don't) show up otherwise in the filesystem.
- * @suspend: Called when the device is going to be suspended by the system.
+ * @suspend: Called when the device is going to be suspended by the
+ *	system either from system sleep or runtime suspend context. The
+ *	return value will be ignored in system sleep context, so do NOT
+ *	try to continue using the device if suspend fails in this case.
+ *	Instead, let the resume or reset-resume routine recover from
+ *	the failure.
  * @resume: Called when the device is being resumed by the system.
  * @reset_resume: Called when the suspended device has been reset instead
  *	of being resumed.
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
