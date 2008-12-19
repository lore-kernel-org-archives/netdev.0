From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: another race in hso
Date: Fri, 19 Dec 2008 11:45:30 +0100
Message-ID: <200812191145.31556.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, "Greg Kroah-Hartman" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

there is another race.

static int hso_get_activity(struct hso_device *hso_dev)
{
	if (hso_dev->usb->state == USB_STATE_SUSPENDED) {
		if (!hso_dev->is_active) {
			hso_dev->is_active = 1;
			schedule_work(&hso_dev->async_get_intf);
		}
	}

	if (hso_dev->usb->state != USB_STATE_CONFIGURED)
		return -EAGAIN;

here's the window.

	usb_mark_last_busy(hso_dev->usb);

	return 0;
}

CPU A							CPU B

run until the window
								autosuspend of device
submitting URB to suspended device

You get an unnecessary error.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
