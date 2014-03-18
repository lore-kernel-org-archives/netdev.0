From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: usbnet OOM handling - possible CPU starvation?
Date: Tue, 18 Mar 2014 10:59:20 +0100
Message-ID: <87ppljketj.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48643 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860AbaCRJ7b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 05:59:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Oliver & other clueful gurus!

I started looking at how to improve the OOM handling in usbnet, but hav=
e
to admit that this is way over my head. I don't think I dare touching
it...

I've seen a few reports clearly showing that we do have a problem. One
example is here: http://forums.whirlpool.net.au/forum-replies.cfm?t=3D2=
207038&p=3D57#r1122

Although all the reports I've seen are from users of cdc_ncm, I don't
think this problem is specific to any particualar minidriver. But it is
of course easier to trigger it using a minidriver with (too?)  large
buffers, like the cdc_ncm minidriver family.

To recall: The NCM and MBIM protocols aggregate packets before
transission over the USB link, requiring USB buffers with multiple
ethernet/IP packets.  Common code used by both cdc_mbim and cdc_ncm
currently cap the buffers at 32768 bytes (hard coded limit), which is
still too high for some embedded hosts.  This results in failures to
allocate buffers in rx_submit (flags =3D=3D GFP_ATOMIC when it is calle=
d
from the URB callback):

	skb =3D __netdev_alloc_skb_ip_align(dev->net, size, flags);
	if (!skb) {
		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
		usb_free_urb (urb);
		return -ENOMEM;
	}

The deferred event ends up retrying the same allocation with
flags =3D=3D GFP_KERNEL :

	/* tasklet could resubmit itself forever if memory is tight */
	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
		struct urb	*urb =3D NULL;
		int resched =3D 1;

		if (netif_running (dev->net))
			urb =3D usb_alloc_urb (0, GFP_KERNEL);
		else
			clear_bit (EVENT_RX_MEMORY, &dev->flags);
		if (urb !=3D NULL) {
			clear_bit (EVENT_RX_MEMORY, &dev->flags);
			status =3D usb_autopm_get_interface(dev->intf);
			if (status < 0) {
				usb_free_urb(urb);
				goto fail_lowmem;
			}
			if (rx_submit (dev, urb, GFP_KERNEL) =3D=3D -ENOLINK)
				resched =3D 0;
			usb_autopm_put_interface(dev->intf);
fail_lowmem:
			if (resched)
				tasklet_schedule (&dev->bh);
		}
	}



But what if this still fails with -ENOMEM? The scheduled tasklet then
runs this:

	// or are we maybe short a few urbs?
	} else if (netif_running (dev->net) &&
		   netif_device_present (dev->net) &&
		   netif_carrier_ok(dev->net) &&
		   !timer_pending (&dev->delay) &&
		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
		int	temp =3D dev->rxq.qlen;

		if (temp < RX_QLEN(dev)) {
			if (rx_alloc_submit(dev, GFP_ATOMIC) =3D=3D -ENOLINK)
				return;
			if (temp !=3D dev->rxq.qlen)
				netif_dbg(dev, link, dev->net,
					  "rxqlen %d --> %d\n",
					  temp, dev->rxq.qlen);
			if (dev->rxq.qlen < RX_QLEN(dev))
				tasklet_schedule (&dev->bh);
		}
		if (dev->txq.qlen < TX_QLEN (dev))
			netif_wake_queue (dev->net);
	}

which is going to reschedule itself infinitely, without any delays at
all, as long as dev->rxq.qlen < RX_QLEN(dev).  So this depends on
rx_alloc_submit being able to allocate RX_QLEN(dev) buffers, or it is
going to lock up one CPU forever in a tight loop.

But rx_alloc_submit is just going to repeat the rx_submit() call over
and over again, with flags =3D=3D GFP_ATOMIC:

static int rx_alloc_submit(struct usbnet *dev, gfp_t flags)
{
	struct urb	*urb;
	int		i;
	int		ret =3D 0;

	/* don't refill the queue all at once */
	for (i =3D 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) {
		urb =3D usb_alloc_urb(0, flags);
		if (urb !=3D NULL) {
			ret =3D rx_submit(dev, urb, flags);
			if (ret)
				goto err;
		} else {
			ret =3D -ENOMEM;
			goto err;
		}
	}
err:
	return ret;
}


And quite frankly: That is pretty much guaranteed to fail if we ended u=
p
going through that route in the first place, isn't it?  So rx_submit
tries to defer the allocation again, and we're back where we started.
Except that we are now already rescheduling the tasklet infinitely.

So we are going to spin here forever, unless something magically frees
up some memory for us.  Which of course is much less likely to happen
when we spin like this.  There are users with severely limited OpenWRT
based embedded systems hitting this, with a single CPU core and not muc=
h
memory at all...

One visibly symptom of this state, in addition to the CPU spinning, is
that the log will be full of "kevent 2 may have been dropped" messages.
rx_submit tries to defer the allocation every time it fails, and with a
high enough failure rate then schedule_work is called much faster than
the work queue is processed.

But how should this be fixed?  Running a delay timer for each time the
tasklet reschedules might help giving up the CPU.  Maybe we should also
break out at some point, either failing the device or trying to reduce
RX_QLEN(dev)?  If the deferred GFP_KERNEL allocation ever fails, then I
think it's time for the driver to stop and reconsider its strategies.

Another idea I've played is that we could try to dynamically reduce the
rx buffer size.  This might be possible with NCM/MBIM.  The current har=
d
coded ceiling is arbitrary and could be set at runtime instead.  We
could add a usbnet callback requesting the minidriver to reduce its rx
buffer size.

Help and/or ideas are appreciated.

I will try to add code to cdc_ncm allowing userspace to change the
buffer ceilings at runtime, which should help with the immediate
problem. But it will require user interaction, which of course isn't as
good as an automatic solution.

[1]=20


Bj=C3=B8rn
