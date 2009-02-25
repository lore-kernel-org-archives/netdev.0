From: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated and rx path
Date: Wed, 25 Feb 2009 13:39:59 +0100
Message-ID: <200902251340.02010.helmut.schaa@gmail.com>
References: <200901211734.48625.helmut.schaa@gmail.com> <200902241315.43128.helmut.schaa@gmail.com> <1235524696.6354.562.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <j@w1.fi>
To: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1235524696.6354.562.camel@debian>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 25. Februar 2009 schrieb Zhu Yi:
> Make sense. Whatever there is race here but either the driver or the
> user space is able to control and avoid it.
> 
> BTW, does wpa_supplicant start to receive EAPOL frames after it gets the
> association event?

Yep.

> [...]
> 
> > > But in wireless, 
> > > netif_carrier_on() is usually called after an association is succeeded.
> > > The driver has already some management frames transfered with AP. Now
> > > it's the time to open the data frame transmission. The driver requires
> > > to get the activate_dev() result (synchronously or via callback) because
> > > otherwise the driver has no idea when the Qdisc is ready and then it can
> > > start to deliver data frames to network stack and user space.
> > 
> > Exactly.
> 
> Looks like we didn't bring enough attention for netdev people on this.
> Should you change the title to remove ipw2100? It should be a generic
> issue for the current netif_carrier_on/dev_activate() implementation.

Argh! Just found out why dev_activate is called such late after
netif_carrier_on:

ipw2100 calls netif_carrier_on followed by netif_wake_queue when the driver
moves from associating to associated state. netif_carrier_on will then
call linkwatch_fire_event. However the carrier_on event is not treated as
urgent and as such the event is delayed (and thus dev_activate too).

An event is considered urgent if the netdev is running, has a carrier
_and_ any of the TX qdiscs changed. Since ipw2100 first calls carrier_on,
the last condition is not met and thus the event is not considered urgent
and gets delayed.

Just changing the order to first wake up the queues followed by the
carrier_on results in an urgent event. I ran a few tests with that change
(+ frame buffering patch) and wasn't able to trigger the race again.

I'll fold that into the frame buffer patch and send it to ipw2100-devel
once I finished the tests.

Helmut
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
