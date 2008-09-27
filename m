From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug 11442] btusb suspend/resume bug...
Date: Sat, 27 Sep 2008 15:41:15 +0200
Message-ID: <200809271541.15963.rjw@sisk.pl>
References: <20080916.155123.181085856.davem@davemloft.net> <200809222342.46735.rjw@sisk.pl> <8C4643EC-E6D9-47D3-8A27-04A2B3CDC6CC@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8C4643EC-E6D9-47D3-8A27-04A2B3CDC6CC-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, 23 of September 2008, Marcel Holtmann wrote:
> Hi Rafael,
> 
> >>>> Marcel, others, please bring some kind of closure to this
> >>>> regression list entry:
> >>>>
> >>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
> >>>> Subject		: btusb hibernation/suspend breakage in current -git
> >>>> Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> >>>> Date		: 2008-08-25 11:37 (19 days old)
> >>>> References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
> >>>> Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> >>>> Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4
> >>>>
> >>>> There is a patch, it is tested, so the only course of action at
> >>>> this point is to merge the fix or declare that this really isn't
> >>>> a regression.
> >>>>
> >>>> My impression is the later, because the driver btusb is replacing
> >>>> doesn't handle suspend/resume either.  Isn't that right?
> >>>
> >>> the original patch that I had was expecting changes in the USB  
> >>> subsystem
> >>> that I deemed to much at this point. However Oliver got a patch that
> >>> would make it work without the USB changes. I am still testing it.
> >>>
> >>> Let me see if I get some free minutes during the PlumbersConf to get
> >>> this fully tested.
> >>
> >> so I took the patch apart and actually found a few more issues. I  
> >> am not
> >> sure if they should be applied this late in -rc phase.
> >>
> >> Rafael, can you pull from my tree and test the changes:
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/ 
> >> bluetooth-2.6.git
> >>
> >> It would be interesting if these fixes are enough.
> >
> > They appear to be enough.  I haven't had any suspend/resume failures  
> > with them
> > applied.
> 
> so it works _without_ applying patch-btusb-suspend.

Well, unfortunately I spoke too soon.

I'm still seeing post-hibernation crashes triggered by the bluetooth user land
trying to use the device handled by btusb.  They happen every second
hibernation, more or less, and apparently they are oopses in various code
paths not directly related to bluetooth, like ext3 (memory corruption or
what?).

With patch-btusb-suspend applied I don't see them (actually I have to use
a slightly modified version of the patch which is appended).

Interestingly enough, suspend to RAM works without any visible problems.

---
 drivers/bluetooth/btusb.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

Index: linux-2.6/drivers/bluetooth/btusb.c
===================================================================
--- linux-2.6.orig/drivers/bluetooth/btusb.c
+++ linux-2.6/drivers/bluetooth/btusb.c
@@ -193,6 +193,7 @@ struct btusb_data {
 	struct usb_endpoint_descriptor *isoc_rx_ep;
 
 	int isoc_altsetting;
+	int suspend_count;
 };
 
 static void btusb_intr_complete(struct urb *urb)
@@ -947,10 +948,71 @@ static void btusb_disconnect(struct usb_
 	hci_free_dev(hdev);
 }
 
+static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct btusb_data *data = usb_get_intfdata(intf);
+
+	BT_DBG("intf %p", intf);
+
+	if (data->suspend_count++)
+		return 0;
+
+	cancel_work_sync(&data->work);
+
+	usb_kill_anchored_urbs(&data->tx_anchor);
+
+	usb_kill_anchored_urbs(&data->isoc_anchor);
+	usb_kill_anchored_urbs(&data->bulk_anchor);
+	usb_kill_anchored_urbs(&data->intr_anchor);
+
+	return 0;
+}
+
+static int btusb_resume(struct usb_interface *intf)
+{
+	struct btusb_data *data = usb_get_intfdata(intf);
+	struct hci_dev *hdev = data->hdev;
+	int err;
+
+	BT_DBG("intf %p", intf);
+
+	if (--data->suspend_count)
+		return 0;
+
+	if (!test_bit(HCI_RUNNING, &hdev->flags))
+		return 0;
+
+	if (test_bit(BTUSB_INTR_RUNNING, &data->flags)) {
+		err = btusb_submit_intr_urb(hdev);
+		if (err < 0) {
+			clear_bit(BTUSB_INTR_RUNNING, &data->flags);
+			return err;
+		}
+	}
+
+	if (test_bit(BTUSB_BULK_RUNNING, &data->flags)) {
+		if (btusb_submit_bulk_urb(hdev) < 0)
+			clear_bit(BTUSB_BULK_RUNNING, &data->flags);
+		else
+			btusb_submit_bulk_urb(hdev);
+	}
+
+	if (test_bit(BTUSB_ISOC_RUNNING, &data->flags)) {
+		if (btusb_submit_isoc_urb(hdev) < 0)
+			clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+		else
+			btusb_submit_isoc_urb(hdev);
+	}
+
+	return 0;
+}
+
 static struct usb_driver btusb_driver = {
 	.name		= "btusb",
 	.probe		= btusb_probe,
 	.disconnect	= btusb_disconnect,
+	.suspend	= btusb_suspend,
+	.resume		= btusb_resume,
 	.id_table	= btusb_table,
 };
 
