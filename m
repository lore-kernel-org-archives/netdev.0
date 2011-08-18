From: Alan Stern <stern@rowland.harvard.edu>
Subject: [PATCH] PM: add macro to test for runtime PM events
Date: Thu, 18 Aug 2011 16:06:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1108181600020.1628-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux-pm mailing list <linux-pm@lists.linux-foundation.org>,
	USB list <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-bluetooth@vger.kernel.org>, <linux-input@vger.kernel.org>,
	Takashi Iwai <tiwai@suse.de>
To: Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch (as1482) adds a macro for testing whether or not a
pm_message value represents an autosuspend or autoresume (i.e., a
runtime PM) event.  Encapsulating this notion seems preferable to
open-coding the test all over the place.

Signed-off-by: Alan Stern <stern@rowland.harvard.edu>

---

This is a minor change in the PM API, but most of the affected files 
are in the USB subsystem.  Therefore either Rafael or Greg might prefer 
to accept this patch.



 Documentation/usb/power-management.txt |    8 ++++----
 drivers/bluetooth/btusb.c              |    2 +-
 drivers/hid/hid-picolcd.c              |    2 +-
 drivers/hid/usbhid/hid-core.c          |    7 +++----
 drivers/net/usb/usbnet.c               |    2 +-
 drivers/net/wimax/i2400m/usb.c         |    4 ++--
 drivers/usb/class/cdc-acm.c            |    2 +-
 drivers/usb/class/cdc-wdm.c            |    6 +++---
 drivers/usb/core/driver.c              |    9 ++++-----
 drivers/usb/core/hcd.c                 |    4 ++--
 drivers/usb/core/hub.c                 |   10 +++++-----
 drivers/usb/serial/sierra.c            |    2 +-
 drivers/usb/serial/usb_wwan.c          |    2 +-
 include/linux/pm.h                     |    2 ++
 sound/usb/card.c                       |    2 +-
 15 files changed, 32 insertions(+), 32 deletions(-)

Index: usb-3.1/include/linux/pm.h
===================================================================
--- usb-3.1.orig/include/linux/pm.h
+++ usb-3.1/include/linux/pm.h
@@ -366,6 +366,8 @@ extern struct dev_pm_ops generic_subsys_
 #define PMSG_AUTO_RESUME	((struct pm_message) \
 					{ .event = PM_EVENT_AUTO_RESUME, })
 
+#define PMSG_IS_AUTO(msg)	(((msg).event & PM_EVENT_AUTO) != 0)
+
 /**
  * Device run-time power management status.
  *
Index: usb-3.1/Documentation/usb/power-management.txt
===================================================================
--- usb-3.1.orig/Documentation/usb/power-management.txt
+++ usb-3.1/Documentation/usb/power-management.txt
@@ -439,10 +439,10 @@ cause autosuspends to fail with -EBUSY i
 device.
 
 External suspend calls should never be allowed to fail in this way,
-only autosuspend calls.  The driver can tell them apart by checking
-the PM_EVENT_AUTO bit in the message.event argument to the suspend
-method; this bit will be set for internal PM events (autosuspend) and
-clear for external PM events.
+only autosuspend calls.  The driver can tell them apart by applying
+the PMSG_IS_AUTO() macro to the message argument to the suspend
+method; it will return True for internal PM events (autosuspend) and
+False for external PM events.
 
 
 	Mutual exclusion
Index: usb-3.1/drivers/net/usb/usbnet.c
===================================================================
--- usb-3.1.orig/drivers/net/usb/usbnet.c
+++ usb-3.1/drivers/net/usb/usbnet.c
@@ -1470,7 +1470,7 @@ int usbnet_suspend (struct usb_interface
 	if (!dev->suspend_count++) {
 		spin_lock_irq(&dev->txq.lock);
 		/* don't autosuspend while transmitting */
-		if (dev->txq.qlen && (message.event & PM_EVENT_AUTO)) {
+		if (dev->txq.qlen && PMSG_IS_AUTO(message)) {
 			spin_unlock_irq(&dev->txq.lock);
 			return -EBUSY;
 		} else {
Index: usb-3.1/drivers/net/wimax/i2400m/usb.c
===================================================================
--- usb-3.1.orig/drivers/net/wimax/i2400m/usb.c
+++ usb-3.1/drivers/net/wimax/i2400m/usb.c
@@ -599,7 +599,7 @@ void i2400mu_disconnect(struct usb_inter
  *
  *    As well, the device might refuse going to sleep for whichever
  *    reason. In this case we just fail. For system suspend/hibernate,
- *    we *can't* fail. We check PM_EVENT_AUTO to see if the
+ *    we *can't* fail. We check PMSG_IS_AUTO to see if the
  *    suspend call comes from the USB stack or from the system and act
  *    in consequence.
  *
@@ -615,7 +615,7 @@ int i2400mu_suspend(struct usb_interface
 	struct i2400m *i2400m = &i2400mu->i2400m;
 
 #ifdef CONFIG_PM
-	if (pm_msg.event & PM_EVENT_AUTO)
+	if (PMSG_IS_AUTO(pm_msg))
 		is_autosuspend = 1;
 #endif
 
Index: usb-3.1/sound/usb/card.c
===================================================================
--- usb-3.1.orig/sound/usb/card.c
+++ usb-3.1/sound/usb/card.c
@@ -628,7 +628,7 @@ static int usb_audio_suspend(struct usb_
 	if (chip == (void *)-1L)
 		return 0;
 
-	if (!(message.event & PM_EVENT_AUTO)) {
+	if (!PMSG_IS_AUTO(message)) {
 		snd_power_change_state(chip->card, SNDRV_CTL_POWER_D3hot);
 		if (!chip->num_suspended_intf++) {
 			list_for_each(p, &chip->pcm_list) {
Index: usb-3.1/drivers/bluetooth/btusb.c
===================================================================
--- usb-3.1.orig/drivers/bluetooth/btusb.c
+++ usb-3.1/drivers/bluetooth/btusb.c
@@ -1103,7 +1103,7 @@ static int btusb_suspend(struct usb_inte
 		return 0;
 
 	spin_lock_irq(&data->txlock);
-	if (!((message.event & PM_EVENT_AUTO) && data->tx_in_flight)) {
+	if (!(PMSG_IS_AUTO(message) && data->tx_in_flight)) {
 		set_bit(BTUSB_SUSPENDING, &data->flags);
 		spin_unlock_irq(&data->txlock);
 	} else {
Index: usb-3.1/drivers/hid/hid-picolcd.c
===================================================================
--- usb-3.1.orig/drivers/hid/hid-picolcd.c
+++ usb-3.1/drivers/hid/hid-picolcd.c
@@ -2409,7 +2409,7 @@ static int picolcd_raw_event(struct hid_
 #ifdef CONFIG_PM
 static int picolcd_suspend(struct hid_device *hdev, pm_message_t message)
 {
-	if (message.event & PM_EVENT_AUTO)
+	if (PMSG_IS_AUTO(message))
 		return 0;
 
 	picolcd_suspend_backlight(hid_get_drvdata(hdev));
Index: usb-3.1/drivers/hid/usbhid/hid-core.c
===================================================================
--- usb-3.1.orig/drivers/hid/usbhid/hid-core.c
+++ usb-3.1/drivers/hid/usbhid/hid-core.c
@@ -1332,7 +1332,7 @@ static int hid_suspend(struct usb_interf
 	struct usbhid_device *usbhid = hid->driver_data;
 	int status;
 
-	if (message.event & PM_EVENT_AUTO) {
+	if (PMSG_IS_AUTO(message)) {
 		spin_lock_irq(&usbhid->lock);	/* Sync with error handler */
 		if (!test_bit(HID_RESET_PENDING, &usbhid->iofl)
 		    && !test_bit(HID_CLEAR_HALT, &usbhid->iofl)
@@ -1367,7 +1367,7 @@ static int hid_suspend(struct usb_interf
 			return -EIO;
 	}
 
-	if (!ignoreled && (message.event & PM_EVENT_AUTO)) {
+	if (!ignoreled && PMSG_IS_AUTO(message)) {
 		spin_lock_irq(&usbhid->lock);
 		if (test_bit(HID_LED_ON, &usbhid->iofl)) {
 			spin_unlock_irq(&usbhid->lock);
@@ -1380,8 +1380,7 @@ static int hid_suspend(struct usb_interf
 	hid_cancel_delayed_stuff(usbhid);
 	hid_cease_io(usbhid);
 
-	if ((message.event & PM_EVENT_AUTO) &&
-			test_bit(HID_KEYS_PRESSED, &usbhid->iofl)) {
+	if (PMSG_IS_AUTO(message) && test_bit(HID_KEYS_PRESSED, &usbhid->iofl)) {
 		/* lost race against keypresses */
 		status = hid_start_in(hid);
 		if (status < 0)
Index: usb-3.1/drivers/usb/class/cdc-acm.c
===================================================================
--- usb-3.1.orig/drivers/usb/class/cdc-acm.c
+++ usb-3.1/drivers/usb/class/cdc-acm.c
@@ -1305,7 +1305,7 @@ static int acm_suspend(struct usb_interf
 	struct acm *acm = usb_get_intfdata(intf);
 	int cnt;
 
-	if (message.event & PM_EVENT_AUTO) {
+	if (PMSG_IS_AUTO(message)) {
 		int b;
 
 		spin_lock_irq(&acm->write_lock);
Index: usb-3.1/drivers/usb/class/cdc-wdm.c
===================================================================
--- usb-3.1.orig/drivers/usb/class/cdc-wdm.c
+++ usb-3.1/drivers/usb/class/cdc-wdm.c
@@ -798,11 +798,11 @@ static int wdm_suspend(struct usb_interf
 	dev_dbg(&desc->intf->dev, "wdm%d_suspend\n", intf->minor);
 
 	/* if this is an autosuspend the caller does the locking */
-	if (!(message.event & PM_EVENT_AUTO))
+	if (!PMSG_IS_AUTO(message))
 		mutex_lock(&desc->lock);
 	spin_lock_irq(&desc->iuspin);
 
-	if ((message.event & PM_EVENT_AUTO) &&
+	if (PMSG_IS_AUTO(message) &&
 			(test_bit(WDM_IN_USE, &desc->flags)
 			|| test_bit(WDM_RESPONDING, &desc->flags))) {
 		spin_unlock_irq(&desc->iuspin);
@@ -815,7 +815,7 @@ static int wdm_suspend(struct usb_interf
 		kill_urbs(desc);
 		cancel_work_sync(&desc->rxwork);
 	}
-	if (!(message.event & PM_EVENT_AUTO))
+	if (!PMSG_IS_AUTO(message))
 		mutex_unlock(&desc->lock);
 
 	return rv;
Index: usb-3.1/drivers/usb/core/driver.c
===================================================================
--- usb-3.1.orig/drivers/usb/core/driver.c
+++ usb-3.1/drivers/usb/core/driver.c
@@ -1046,8 +1046,7 @@ static int usb_resume_device(struct usb_
 	/* Non-root devices on a full/low-speed bus must wait for their
 	 * companion high-speed root hub, in case a handoff is needed.
 	 */
-	if (!(msg.event & PM_EVENT_AUTO) && udev->parent &&
-			udev->bus->hs_companion)
+	if (!PMSG_IS_AUTO(msg) && udev->parent && udev->bus->hs_companion)
 		device_pm_wait_for_dev(&udev->dev,
 				&udev->bus->hs_companion->root_hub->dev);
 
@@ -1075,7 +1074,7 @@ static int usb_suspend_interface(struct 
 
 	if (driver->suspend) {
 		status = driver->suspend(intf, msg);
-		if (status && !(msg.event & PM_EVENT_AUTO))
+		if (status && !PMSG_IS_AUTO(msg))
 			dev_err(&intf->dev, "%s error %d\n",
 					"suspend", status);
 	} else {
@@ -1189,7 +1188,7 @@ static int usb_suspend_both(struct usb_d
 			status = usb_suspend_interface(udev, intf, msg);
 
 			/* Ignore errors during system sleep transitions */
-			if (!(msg.event & PM_EVENT_AUTO))
+			if (!PMSG_IS_AUTO(msg))
 				status = 0;
 			if (status != 0)
 				break;
@@ -1199,7 +1198,7 @@ static int usb_suspend_both(struct usb_d
 		status = usb_suspend_device(udev, msg);
 
 		/* Again, ignore errors during system sleep transitions */
-		if (!(msg.event & PM_EVENT_AUTO))
+		if (!PMSG_IS_AUTO(msg))
 			status = 0;
 	}
 
Index: usb-3.1/drivers/usb/core/hcd.c
===================================================================
--- usb-3.1.orig/drivers/usb/core/hcd.c
+++ usb-3.1/drivers/usb/core/hcd.c
@@ -1960,7 +1960,7 @@ int hcd_bus_suspend(struct usb_device *r
 	int		old_state = hcd->state;
 
 	dev_dbg(&rhdev->dev, "bus %s%s\n",
-			(msg.event & PM_EVENT_AUTO ? "auto-" : ""), "suspend");
+			(PMSG_IS_AUTO(msg) ? "auto-" : ""), "suspend");
 	if (HCD_DEAD(hcd)) {
 		dev_dbg(&rhdev->dev, "skipped %s of dead bus\n", "suspend");
 		return 0;
@@ -1996,7 +1996,7 @@ int hcd_bus_resume(struct usb_device *rh
 	int		old_state = hcd->state;
 
 	dev_dbg(&rhdev->dev, "usb %s%s\n",
-			(msg.event & PM_EVENT_AUTO ? "auto-" : ""), "resume");
+			(PMSG_IS_AUTO(msg) ? "auto-" : ""), "resume");
 	if (HCD_DEAD(hcd)) {
 		dev_dbg(&rhdev->dev, "skipped %s of dead bus\n", "resume");
 		return 0;
Index: usb-3.1/drivers/usb/core/hub.c
===================================================================
--- usb-3.1.orig/drivers/usb/core/hub.c
+++ usb-3.1/drivers/usb/core/hub.c
@@ -2342,7 +2342,7 @@ int usb_port_suspend(struct usb_device *
 			dev_dbg(&udev->dev, "won't remote wakeup, status %d\n",
 					status);
 			/* bail if autosuspend is requested */
-			if (msg.event & PM_EVENT_AUTO)
+			if (PMSG_IS_AUTO(msg))
 				return status;
 		}
 	}
@@ -2367,12 +2367,12 @@ int usb_port_suspend(struct usb_device *
 				USB_CTRL_SET_TIMEOUT);
 
 		/* System sleep transitions should never fail */
-		if (!(msg.event & PM_EVENT_AUTO))
+		if (!PMSG_IS_AUTO(msg))
 			status = 0;
 	} else {
 		/* device has up to 10 msec to fully suspend */
 		dev_dbg(&udev->dev, "usb %ssuspend\n",
-				(msg.event & PM_EVENT_AUTO ? "auto-" : ""));
+				(PMSG_IS_AUTO(msg) ? "auto-" : ""));
 		usb_set_device_state(udev, USB_STATE_SUSPENDED);
 		msleep(10);
 	}
@@ -2523,7 +2523,7 @@ int usb_port_resume(struct usb_device *u
 	} else {
 		/* drive resume for at least 20 msec */
 		dev_dbg(&udev->dev, "usb %sresume\n",
-				(msg.event & PM_EVENT_AUTO ? "auto-" : ""));
+				(PMSG_IS_AUTO(msg) ? "auto-" : ""));
 		msleep(25);
 
 		/* Virtual root hubs can trigger on GET_PORT_STATUS to
@@ -2625,7 +2625,7 @@ static int hub_suspend(struct usb_interf
 		udev = hdev->children [port1-1];
 		if (udev && udev->can_submit) {
 			dev_warn(&intf->dev, "port %d nyet suspended\n", port1);
-			if (msg.event & PM_EVENT_AUTO)
+			if (PMSG_IS_AUTO(msg))
 				return -EBUSY;
 		}
 	}
Index: usb-3.1/drivers/usb/serial/sierra.c
===================================================================
--- usb-3.1.orig/drivers/usb/serial/sierra.c
+++ usb-3.1/drivers/usb/serial/sierra.c
@@ -1009,7 +1009,7 @@ static int sierra_suspend(struct usb_ser
 	struct sierra_intf_private *intfdata;
 	int b;
 
-	if (message.event & PM_EVENT_AUTO) {
+	if (PMSG_IS_AUTO(message)) {
 		intfdata = serial->private;
 		spin_lock_irq(&intfdata->susp_lock);
 		b = intfdata->in_flight;
Index: usb-3.1/drivers/usb/serial/usb_wwan.c
===================================================================
--- usb-3.1.orig/drivers/usb/serial/usb_wwan.c
+++ usb-3.1/drivers/usb/serial/usb_wwan.c
@@ -651,7 +651,7 @@ int usb_wwan_suspend(struct usb_serial *
 
 	dbg("%s entered", __func__);
 
-	if (message.event & PM_EVENT_AUTO) {
+	if (PMSG_IS_AUTO(message)) {
 		spin_lock_irq(&intfdata->susp_lock);
 		b = intfdata->in_flight;
 		spin_unlock_irq(&intfdata->susp_lock);

