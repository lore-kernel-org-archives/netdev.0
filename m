From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v5] tilegx network driver: initial support
Date: Sun, 20 May 2012 12:35:01 -0400
Message-ID: <4FB91D35.3040000@tilera.com>
References: <201205011759.q41HxR21020043@farm-0012.internal.tilera.com>  <20120503.014156.149171097979026872.davem@davemloft.net>  <201205031936.q43Ja9Xb031644@lab-41.internal.tilera.com>  <20120504.024216.1730395431103337434.davem@davemloft.net>  <201205091452.q49EqcO7005975@farm-0027.internal.tilera.com> <1336744445.2874.57.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <arnd@arndb.de>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:51847 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab2ETQfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 12:35:05 -0400
In-Reply-To: <1336744445.2874.57.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/2012 9:54 AM, Ben Hutchings wrote:
> Here's another very incomplete review for you.

Thanks, I (we) appreciate it!

>> +/* Define to support GSO. */
>> +#undef TILE_NET_GSO
> GSO is always enabled by the networking core.
>
>> +/* Define to support TSO. */
>> +#define TILE_NET_TSO
> No, put NETIF_F_TSO in hw_features so it can be switched at run-time.

We already had that; the TSO define was just to decide whether the driver
would even offer TSO support at all.  But on reflection it seems pointless
not to offer TSO, so I've made it true unconditionally and deleted the
define.  Similarly I got rid of the (totally pointless) GSO define and let
the core control whether it switches GSO on or not.

We are looking at GRO support for a following change, but obviously we need
to set up ethtool_ops for that first, so we'll be doing that as well.

>> +/* Use 3000 to enable the Linux Traffic Control (QoS) layer, else 0. */
>> +#define TILE_NET_TX_QUEUE_LEN 0
> This can be changed through sysfs, so there is no need for a compile-
> time option.

Fair enough, and in practice we don't change this default anyway, so I
eliminated it.

>> +/* Define to dump packets (prints out the whole packet on tx and rx). */
>> +#undef TILE_NET_DUMP_PACKETS
> Should really be controlled through a 'debug' module parameter (see
> netif_msg_init(), netif_msg_pktdata(), etc.)

We almost never use this functionality anyway, so for now, I've just
removed it.  If we want to reintroduce something like it, we'll use the
netif_msg stuff.

>> +	/* Reserve slots, or return NETDEV_TX_BUSY if "full". */
>> +	slot = gxio_mpipe_equeue_try_reserve(equeue, num_frags);
>> +	if (slot < 0) {
>> +		local_irq_restore(irqflags);
>> +		/* ISSUE: "Virtual device xxx asks to queue packet". */
>> +		return NETDEV_TX_BUSY;
>> +	}
> You're supposed to stop queues when they're full.  And since that state
> appears to be per-CPU, I think this device needs to be multiqueue with
> one TX queue per CPU and ndo_select_queue defined accordingly.
>
> [...]
>
> I'm not convinced you should be processing completions here at all.  But
> certainly you should have stopped the queue earlier rather than having
> to wait here.

This is a larger issue.  We are working on improving performance in the
driver overall, and how we handle per-cpu or global queueing, how we stop
and restart the driver, etc., will be part of it.  (The underlying mpipe
resources are not per-cpu, so it may or may not make sense to have the
driver believe it's multiqueue.)  I added some placeholder comments and a
reference to our internal bug ID on this issue.

> You mustn't treat random fields to atomic_t.  For one thing, atomic_t
> contains an int while stats are unsigned long...
>
> Also, you're adding cache contention between all your CPUs here.  You
> should maintain these stats per-CPU and then sum them in
> tile_net_get_stats().  Then you can just use ordinary additions.

Oops, you're right that atomic_t is the wrong size.  What I've done is
switch to atomic_long_t, but moved the cast to a separate
tile_net_stats_add() function that has a BUILD_BUG_ON() to validate that
the sizes match, and also a long comment explaining why tilegx's memory
network architecture makes atomic adds exactly the right kind of thing to
do here.  It's easy to forget that 99% of the world has a model of atomics
based on the Intel architecture.

> [...]
>> +/* Ioctl commands. */
>> +static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>> +{
>> +	return -EOPNOTSUPP;
>> +}
> So why define it at all?

Because a following patch (not yet posted to LKML) adds support for
SIOCSHWTSTAMP and the ioctl was originally written that way to put the
framework in place.

The few suggestions I didn't respond to directly where pretty
straightforward and I just implemented them as you suggested.

Thanks again!  The revised patch will follow momentarily.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
