From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Thu, 17 Apr 2008 16:32:12 +0200
Message-ID: <200804171632.12972.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804161543.23584.oliver@neukum.org> <48060536.60005@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:57908 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbYDQOXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 10:23:09 -0400
In-Reply-To: <48060536.60005@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 16. April 2008 15:55:02 schrieb Paulius Zaleckas:
> Oliver Neukum wrote:
> > Am Mittwoch, 16. April 2008 14:12:06 schrieb Paulius Zaleckas:
> >> I always get crash when closing serial terminal application. I will
> >> post dump in couple minutes.
> > 
> > Does this fix it?
> > 
> 
> Yes, it does! Thank you.

Hi,

can you test this one as well. The method used to determine whether
a device is asleep is racy. This introduces a private test.

	Regards
		Oliver

---

--- linux-2.6.25hso/drivers/net/usb/hso.c.alt2	2008-04-17 14:15:32.000000000 +0200
+++ linux-2.6.25hso/drivers/net/usb/hso.c	2008-04-17 16:11:50.000000000 +0200
@@ -242,6 +242,7 @@ struct hso_device {
 	u8 is_active;
 	u8 suspend_disabled;
 	u8 usb_gone;
+	u8 sleeping;
 	struct work_struct async_get_intf;
 	struct work_struct async_put_intf;
 
@@ -252,6 +253,7 @@ struct hso_device {
 	struct device *dev;
 	struct kref ref;
 	struct mutex mutex;
+	spinlock_t lock;
 
 	/* TODO: Not sure about the ones below */
 	struct proc_dir_entry *ourproc;
@@ -2184,6 +2186,7 @@ static struct hso_device *hso_create_dev
 	hso_dev->interface = intf;
 	kref_init(&hso_dev->ref);
 	mutex_init(&hso_dev->mutex);
+	spin_lock_init(&hso_dev->lock);
 
 	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
 	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
@@ -2757,12 +2760,16 @@ static void async_put_intf(struct work_s
 
 static int hso_get_activity(struct hso_device *hso_dev)
 {
-	if (hso_dev->usb->state == USB_STATE_SUSPENDED) {
+	unsigned long flags;
+
+	spin_lock_irqsave(&hso_dev->lock, flags);
+	if (hso_dev->sleeping) {
 		if (!hso_dev->is_active) {
 			hso_dev->is_active = 1;
 			schedule_work(&hso_dev->async_get_intf);
 		}
 	}
+	spin_unlock_irqrestore(&hso_dev->lock, flags);
 
 	if (hso_dev->usb->state != USB_STATE_CONFIGURED)
 		return -EAGAIN;
@@ -2774,22 +2781,32 @@ static int hso_get_activity(struct hso_d
 
 static int hso_put_activity(struct hso_device *hso_dev)
 {
-	if (hso_dev->usb->state != USB_STATE_SUSPENDED) {
+	unsigned long flags;
+
+	spin_lock_irqsave(&hso_dev->lock, flags);
+	if (hso_dev->sleeping) {
 		if (hso_dev->is_active) {
 			hso_dev->is_active = 0;
 			schedule_work(&hso_dev->async_put_intf);
+			spin_unlock_irqrestore(&hso_dev->lock, flags);
 			return -EAGAIN;
 		}
 	}
 	hso_dev->is_active = 0;
+	spin_unlock_irqrestore(&hso_dev->lock, flags);
 	return 0;
 }
 
 /* called by kernel when we need to suspend device */
 static int hso_suspend(struct usb_interface *iface, pm_message_t message)
 {
+	struct hso_device *hso_dev = usb_get_intfdata(iface);
 	int i, result = 0;
 
+	spin_lock_irq(&hso_dev->lock);
+	hso_dev->sleeping = 1;
+	spin_unlock_irq(&hso_dev->lock);
+
 	/* Stop all serial ports */
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i] && (serial_table[i]->interface == iface)) {
@@ -2816,9 +2833,14 @@ out:
 /* called by kernel when we need to resume device */
 static int hso_resume(struct usb_interface *iface)
 {
+	struct hso_device *hso_dev = usb_get_intfdata(iface);
 	int i, result = 0;
 	struct hso_net *hso_net;
 
+	spin_lock_irq(&hso_dev->lock);
+	hso_dev->sleeping = 0;
+	spin_unlock_irq(&hso_dev->lock);
+
 	/* Start all serial ports */
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i] && (serial_table[i]->interface == iface)) {

