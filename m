From: "George Spelvin" <linux@horizon.com>
Subject: Re: v3.5: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: 1 Aug 2012 19:29:53 -0400
Message-ID: <20120801232953.3791.qmail@science.horizon.com>
References: <20120801192455.GA29755@electric-eye.fr.zoreil.com>
Cc: linux@horizon.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:21848 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751900Ab2HAX3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 19:29:55 -0400
In-Reply-To: <20120801192455.GA29755@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for the response!

> It's up to you but I suggest that you keep them until there is something
> better.

I was going to; I just wondered if they interfered with debugging or
something.

> As long as the device recovers, you may try and lower the watchdog timeout
> as well as increase the Tx ring size a bit (x2 or x4) to minimize the
> annoyances.

Out of curiosity, how does increasing the Tx ring size help?

But okay.  Just to make sure I'm doing it right (I'm pretty sure,
but scream if I'm making a mistake), I'm making the following edits to
drivers/net/ethernet/realtek/r8169.c

#define	NUM_TX_DESC	64	/* Number of Tx descriptor registers */

I'll double that to 128.

Now, since I am actually running at gigabit speed into a pretty capable
network that I don't expect to ever block me, I should be able to send
one 1500-byte frame in 12.3 microseconds (with all overhead, one 1500-byte
frame is 1538 bytes or 12304 bits), so 128 frames in 1.6 ms.

There is the issue of TSO, so one descriptor might send more than one
frame, but I think it's likely to break at 4K pages, the worst case is
128 * 4096 / 1500 = 350 frames in that Tx ring, which will take 4.3 ms.

Either way, I can drop the Tx timeout a *lot*.

#define	TL8169_TX_TIMEOUT	(6*HZ)

I want to drop that to HZ/100 or less.  Since I'm currently running with
CONFIG_HZ_100, and I'm not sure about the rounding (do I gain or lose
one tick due to ambiguity?) I'll bump HZ to 300 and change that to HZ/100.
That should give me a minimum of 2 ticks = 6.666 ms, which is still more
than it should take to transmit a full 

To make this short timeout actually work, I have to remove the "round
to nearest second" round_timer() calls in net/sched/sch_generic.c (there
are two that apply to dev->watchdog_timer), since I do want a sub-second
timeout granularity.
