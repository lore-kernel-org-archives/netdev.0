From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated
 and rx path
Date: Fri, 27 Feb 2009 08:55:39 +0800
Message-ID: <1235696139.6354.584.camel@debian>
References: <200901211734.48625.helmut.schaa@gmail.com>
	 <200902241315.43128.helmut.schaa@gmail.com>
	 <1235524696.6354.562.camel@debian>
	 <200902251340.02010.helmut.schaa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <j@w1.fi>
To: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200902251340.02010.helmut.schaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-02-25 at 20:39 +0800, Helmut Schaa wrote:
> Argh! Just found out why dev_activate is called such late after
> netif_carrier_on:
> 
> ipw2100 calls netif_carrier_on followed by netif_wake_queue when the
> driver
> moves from associating to associated state. netif_carrier_on will then
> call linkwatch_fire_event. However the carrier_on event is not treated
> as
> urgent and as such the event is delayed (and thus dev_activate too).
> 
> An event is considered urgent if the netdev is running, has a carrier
> _and_ any of the TX qdiscs changed. Since ipw2100 first calls
> carrier_on,
> the last condition is not met and thus the event is not considered
> urgent and gets delayed.

Calling netif_wake_queue() before netif_carrier_on() is not correct in
semantics. Even it works, it looks like a workaround hack. I still think
making a sync version of netif_carrier_on is the way to go.

> Just changing the order to first wake up the queues followed by the
> carrier_on results in an urgent event. I ran a few tests with that
> change
> (+ frame buffering patch) and wasn't able to trigger the race again.
> 
> I'll fold that into the frame buffer patch and send it to
> ipw2100-devel
> once I finished the tests.

Sounds good.

Thanks,
-yi

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
