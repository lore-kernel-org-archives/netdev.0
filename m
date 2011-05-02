From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Mon, 02 May 2011 03:24:42 +0100
Message-ID: <1304303082.2833.159.camel@localhost>
References: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-05-01 at 22:21 +0100, Daniel Drake wrote:
[...]
> Sometimes the TX queue is stopped and started from other places (e.g.
> while scanning for networks, which NetworkManager triggers every
> couple of minutes)
> 
> Thus the TX queue is stopped and started very often.
> 
> The libertas tx_timeout handler is being called quite a lot, and quite
> soon after boot we get this in the kernel logs (the first time it
> happens):
> 
> [   97.050101] ------------[ cut here ]------------
> [   97.054866] WARNING: at net/sched/sch_generic.c:258 dev_watchdog+0x102/0x17c
> [   97.062277] Hardware name: XO
> [   97.065335] NETDEV WATCHDOG: eth0 (libertas_sdio): transmit queue 0 timed out
> <snip large trace>
> 
> This message seems bogus - all the recent transmissions happened correctly.
> 
> What is this watchdog trying to detect exactly? Using what criteria?

I'll repeat my answer from the last time this was asked on netdev:

The watchdog fires when the software queue has been stopped *and* the
link has been reported as up for over dev->watchdog_timeo ticks.

The software queue should be stopped iff the hardware queue is full or
nearly full.  If the software queue remains stopped and the link is
still reported up, then one of these things is happening:

1. The link went down but the driver didn't notice
2. TX completions are not being indicated or handled correctly
3. The hardware TX path has locked up
4. The link is stalled by excessive pause frames or collisions
5. Timeout is too low and/or low watermark is too high
(there may be other explanations)

I think the watchdog is primarily meant to deal with case 3, though all
of cases 1-3 may be worked around by resetting the hardware.

And now, for the specific case of libertas:

It appears that libertas reports carrier off (link down) while scanning,
so that should mean the watchdog does not fire.  However:

1. The watchdog will only check the current link state, which might be
up again when it runs.
2. The watchdog assumes that TX queues only fill up in response to
packets sent by the TX scheduler.

[...]
> Is libertas doing something wrong, or is this a bug/oddity in the network layer?

Since the TX scheduler doesn't know about the extra packets you are
injecting to do channel scanning, I think you need to call
txq_trans_update() when you do that.  And I don't think it's a good idea
to call netif_carrier_off() there at all.  If it has any effect at all
(which I don't think it will, as channel scanning is being done under
RTNL lock and link change notifications also require that lock) it will
be to confuse userland.

> Also, while looking at this code, I spotted a bug in dev_watchdog():
> 				/*
> 				 * old device drivers set dev->trans_start
> 				 */
> 				trans_start = txq->trans_start ? : dev->trans_start;
> 
> i.e. it is trying to figure out whether to read trans_start from txq
> or dev. In both cases, trans_start is updated based on the value of
> jiffies, which will occasionally be 0 (as it wraps around). Therefore
> this line of code will occasionally make the wrong decision.

No, I don't think so.

If only dev->trans_start is being updated then the watchdog reads that.
If both txq->trans_start and dev->trans_start are being updated then it
doesn't matter much which the watchdog reads.
If only txq->trans_start is being updated then dev->trans_start is
always set to 0, so when txq->trans_start is 0 the watchdog still gets
0.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
