From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: hso has a very nice race between hard_start_xmit and resume
Date: Fri, 19 Dec 2008 11:21:21 +0100
Message-ID: <200812191121.22860.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, "Greg Kroah-Hartman" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this one is beautiful. The hso driver has a race condition between
hard_start_xmit and resume, caused by using a workqueue. It starts here:

static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
{
	struct hso_net *odev = netdev_priv(net);
	int result;

	/* Tell the kernel, "No more frames 'til we are done with this one." */
	netif_stop_queue(net);
	if (hso_get_activity(odev->parent) == -EAGAIN) {

here's the window

		odev->skb_tx_buf = skb;
		return 0;
	}

hso_get_activity() schedules work which will call usb_autopm_get_interface.
It may run any time after that. In particular it may run before
odev->skb_tx_buf is set. If that happens resume will not submit
mux_bulk_tx_buf. Thus netif_start_queue() will not be called from
write_bulk_callback. Later on a timeout will strike which will do nothing
because the URB has never been submitted.

This will need some interesting locking because you cannot assume that
the driver's usb_autopm_get_interface will cause resume to run. Somebody
may be running lsusb causing an earlier resumption. So simply setting
odev->skb_tx_buf before you call hso_get_activity does not solve the problem.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
