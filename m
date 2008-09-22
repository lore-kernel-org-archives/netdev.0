From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: btusb suspend/resume bug...
Date: Mon, 22 Sep 2008 08:24:11 +0200
Message-ID: <1222064651.13064.6.camel@californication>
References: <20080916.155123.181085856.davem@davemloft.net>
	 <1221668269.6782.8.camel@californication>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NIVSJe9GUQc89e+5JPQt"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1221668269.6782.8.camel@californication>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-NIVSJe9GUQc89e+5JPQt
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Dave,

> > Marcel, others, please bring some kind of closure to this
> > regression list entry:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
> > Subject		: btusb hibernation/suspend breakage in current -git
> > Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> > Date		: 2008-08-25 11:37 (19 days old)
> > References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
> > Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> > Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4
> > 
> > There is a patch, it is tested, so the only course of action at
> > this point is to merge the fix or declare that this really isn't
> > a regression.
> > 
> > My impression is the later, because the driver btusb is replacing
> > doesn't handle suspend/resume either.  Isn't that right?
> 
> the original patch that I had was expecting changes in the USB subsystem
> that I deemed to much at this point. However Oliver got a patch that
> would make it work without the USB changes. I am still testing it.
> 
> Let me see if I get some free minutes during the PlumbersConf to get
> this fully tested.

so I took the patch apart and actually found a few more issues. I am not
sure if they should be applied this late in -rc phase.

Rafael, can you pull from my tree and test the changes:

git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

It would be interesting if these fixes are enough. Or if you need the
attached suspend/resume patch.

Regards

Marcel



--=-NIVSJe9GUQc89e+5JPQt
Content-Disposition: attachment; filename=patch-btusb-suspend
Content-Type: text/x-patch; name=patch-btusb-suspend; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 6e455ac..0e9451b 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -193,6 +193,7 @@ struct btusb_data {
 	struct usb_endpoint_descriptor *isoc_rx_ep;
 
 	int isoc_altsetting;
+	int suspend_count;
 };
 
 static void btusb_intr_complete(struct urb *urb)
@@ -946,10 +947,71 @@ static void btusb_disconnect(struct usb_interface *intf)
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
+		err = btusb_submit_intr_urb(hdev, GFP_NOIO);
+		if (err < 0) {
+			clear_bit(BTUSB_INTR_RUNNING, &data->flags);
+			return err;
+		}
+	}
+
+	if (test_bit(BTUSB_BULK_RUNNING, &data->flags)) {
+		if (btusb_submit_bulk_urb(hdev, GFP_NOIO) < 0)
+			clear_bit(BTUSB_BULK_RUNNING, &data->flags);
+		else
+			btusb_submit_bulk_urb(hdev, GFP_NOIO);
+	}
+
+	if (test_bit(BTUSB_ISOC_RUNNING, &data->flags)) {
+		if (btusb_submit_isoc_urb(hdev, GFP_NOIO) < 0)
+			clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+		else
+			btusb_submit_isoc_urb(hdev, GFP_NOIO);
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
 

--=-NIVSJe9GUQc89e+5JPQt--
