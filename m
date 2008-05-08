From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 07 May 2008 20:26:06 -0700 (PDT)
Message-ID: <20080507.202606.242037993.davem@davemloft.net>
References: <20080507130548.GA26977@gondor.apana.org.au>
	<200805071548.06693.mb@bu3sch.de>
	<20080508032208.GA401@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080508032208.GA401-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Thu, 8 May 2008 11:22:08 +0800

> On Wed, May 07, 2008 at 03:48:06PM +0200, Michael Buesch wrote:
> >
> > So there's no way to actually fail in a TX handler? Drivers
> > are doomed to drop the packet, if they cannot handle it due to
> > ring overflow?
> 
> You're supposed to stop the queue before the ring overflows.

Right, and this is why drivers choose a TX wakeup threshold such
that they can accept an arbitrarily sized TSO frame.

For example, from drivers/net/tg3.c's ->hard_start_xmit():

	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
		netif_stop_queue(dev);
		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
			netif_wake_queue(tp->dev);
	}

The driver is responsible for stopping the queue _before_ it
enters a state where there is not enough space in the queue
to accept a packet.

This is why most drivers make the following kind of BUG check
at the start of their ->hard_start_xmit()

	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
		if (!netif_queue_stopped(dev)) {
			netif_stop_queue(dev);

			/* This is a hard error, log it. */
			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
			       "queue awake!\n", dev->name);
		}
		return NETDEV_TX_BUSY;
	}
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
