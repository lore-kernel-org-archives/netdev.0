From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Wed, 11 May 2011 13:47:27 -0400 (EDT)
Message-ID: <20110511.134727.957370621658043260.davem@davemloft.net>
References: <Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org>
	<20110509084649.127ec0da@nehalam>
	<201105111937.47448.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105111937.47448.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Wed, 11 May 2011 19:37:47 +0200

> How is the frequency NAPI uses to poll determined? We could abuse
> this and resubmit the rx URBs only at poll time, but this feels dirty,
> because we would still leave interrupts enabled.

It's not a frequency determined internally by the networking.

It is purely event based (meaning triggered by the device's interrupt).

Control flow is:

IRQ --> irq_handler()
	my_netdevice_disable_device_irq();
	napi_schedule();
		--> schedule POLL soft irq
SOFTIRQ --> net_rx_action()
	budget = netdev_budget;
	for_each_net_device_needing_polling() {
		...
		weight = napi_state->weight;
		...
		work = n->poll(n, weight);
		...
		budget -= work;
		...
	}

That's the general idea.

Basically once you take you interrupt, and disable device interrupts,
the generic net device layer calls your ->poll() routing with a "weight"
You should not process more RX packets than this value.

If you have less than "weight" work to do, you should do a napi_complete(),
which takes you out of the polling group, and re-enable device interrupts.

So the idea is that you keep getting ->poll()'d until there is no more
RX work to do.

The "weight" argument implements fairness amongst competing, actively
polling, devices on the same CPU.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
