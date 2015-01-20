From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 11/11] usb: core: fix a race with usb_queue_reset_device()
Date: Tue, 20 Jan 2015 13:29:38 +0100
Message-ID: <1421756978-4093-12-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
 <1421756978-4093-7-git-send-email-olivier@sobrie.be>
 <1421756978-4093-8-git-send-email-olivier@sobrie.be>
 <1421756978-4093-9-git-send-email-olivier@sobrie.be>
 <1421756978-4093-10-git-send-email-olivier@sobrie.be>
 <1421756978-4093-11-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-11-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When usb_queue_reset() is called it schedules a work in view of
resetting the usb interface. When the reset work is running, it
can be scheduled again (e.g. by the usb disconnect method of
the driver).

Consider that the reset work is queued again while the reset work
is running and that this work leads to a forced unbinding of the
usb interface (e.g. because a driver is bound to the interface
and has no pre/post_reset methods - see usb_reset_device()).
In such condition, usb_unbind_interface() gets called and this
function calls usb_cancel_queued_reset() which does nothing
because the flag "reset_running" is set to 1. The second reset
work that has been scheduled is therefore not cancelled.
Later, the usb_reset_device() tries to rebind the interface.
If it fails, then the usb interface context which contain the
reset work struct is freed and it most likely crash when the
second reset work tries to be run.

The following flow shows the problem:
* usb_queue_reset_device()
* __usb_queue_reset_device() <- If the reset work is queued after here, then
    reset_running = 1           it will never be cancelled.
    usb_reset_device()
      usb_forced_unbind_intf()
        usb_driver_release_interface()
          usb_unbind_interface()
            driver->disconnect()
              usb_queue_reset_device() <- second reset
            usb_cancel_queued_reset() <- does nothing because
                                         the flag reset_running
                                         is set
      usb_unbind_and_rebind_marked_interfaces()
        usb_rebind_intf()
          device_attach()
            driver->probe() <- fails (no more drivers hold a reference to
				      the usb interface)
    reset_running = 0
* hub_event()
    usb_disconnect()
      usb_disable_device()
        kobject_release()
          device_release()
            usb_release_interface()
              kfree(intf) <- usb interface context is released
                             while we still have a pending reset
                             work that should be run

To avoid this problem, we use a delayed work so that if the reset
work is currently run, we can avoid further call to
__usb_queue_reset_device() work by using cancel_delayed_work().
Unfortunately it increases the size of the usb_interface structure...

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/usb/core/driver.c  | 4 +++-
 drivers/usb/core/hub.c     | 4 ++--
 drivers/usb/core/message.c | 4 ++--
 include/linux/usb.h        | 2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/core/driver.c b/drivers/usb/core/driver.c
index 9bffd26..c93fbbbb 100644
--- a/drivers/usb/core/driver.c
+++ b/drivers/usb/core/driver.c
@@ -287,7 +287,9 @@ static int usb_unbind_device(struct device *dev)
 static void usb_cancel_queued_reset(struct usb_interface *iface)
 {
 	if (iface->reset_running == 0)
-		cancel_work_sync(&iface->reset_ws);
+		cancel_delayed_work_sync(&iface->reset_ws);
+	else
+		cancel_delayed_work(&iface->reset_ws);
 }
 
 /* called from driver core with dev locked */
diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index b649fef..52fba97 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -5604,13 +5604,13 @@ EXPORT_SYMBOL_GPL(usb_reset_device);
  * NOTE: We don't do any reference count tracking because it is not
  *     needed. The lifecycle of the work_struct is tied to the
  *     usb_interface. Before destroying the interface we cancel the
- *     work_struct, so the fact that work_struct is queued and or
+ *     delayed_work, so the fact that delayed_work is queued and or
  *     running means the interface (and thus, the device) exist and
  *     are referenced.
  */
 void usb_queue_reset_device(struct usb_interface *iface)
 {
-	schedule_work(&iface->reset_ws);
+	schedule_delayed_work(&iface->reset_ws, 0);
 }
 EXPORT_SYMBOL_GPL(usb_queue_reset_device);
 
diff --git a/drivers/usb/core/message.c b/drivers/usb/core/message.c
index f7b7713..d9f3f68 100644
--- a/drivers/usb/core/message.c
+++ b/drivers/usb/core/message.c
@@ -1650,7 +1650,7 @@ static void __usb_queue_reset_device(struct work_struct *ws)
 {
 	int rc;
 	struct usb_interface *iface =
-		container_of(ws, struct usb_interface, reset_ws);
+		container_of(ws, struct usb_interface, reset_ws.work);
 	struct usb_device *udev = interface_to_usbdev(iface);
 
 	rc = usb_lock_device_for_reset(udev, iface);
@@ -1847,7 +1847,7 @@ free_interfaces:
 		intf->dev.type = &usb_if_device_type;
 		intf->dev.groups = usb_interface_groups;
 		intf->dev.dma_mask = dev->dev.dma_mask;
-		INIT_WORK(&intf->reset_ws, __usb_queue_reset_device);
+		INIT_DELAYED_WORK(&intf->reset_ws, __usb_queue_reset_device);
 		intf->minor = -1;
 		device_initialize(&intf->dev);
 		pm_runtime_no_callbacks(&intf->dev);
diff --git a/include/linux/usb.h b/include/linux/usb.h
index 447a7e2..ffb3da1 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -187,7 +187,7 @@ struct usb_interface {
 	struct device dev;		/* interface specific device info */
 	struct device *usb_dev;
 	atomic_t pm_usage_cnt;		/* usage counter for autosuspend */
-	struct work_struct reset_ws;	/* for resets in atomic context */
+	struct delayed_work reset_ws;	/* for resets in atomic context */
 };
 #define	to_usb_interface(d) container_of(d, struct usb_interface, dev)
 
-- 
2.2.0
