From: Daniel Drake <dsd@laptop.org>
Subject: Frequent spurious tx_timeouts for libertas
Date: Sun, 1 May 2011 22:21:58 +0100
Message-ID: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, libertas-dev@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48253 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab1EAVV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 17:21:59 -0400
Received: by ywj3 with SMTP id 3so1754976ywj.19
        for <netdev@vger.kernel.org>; Sun, 01 May 2011 14:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The libertas driver works as follows:

Once successfully connected to wifi, it enables the TX queue.
When the network layer calls hard_start_xmit, the driver stores the
packet in memory, stops the TX queue with netif_stop_queue(), and
returns NETDEV_TX_OK.
Some time later, the libertas kernel thread wakes up, sees the new
packet stored for delivery, sends it to the card, then runs
netif_wake_queue() to get things moving again.

Sometimes the TX queue is stopped and started from other places (e.g.
while scanning for networks, which NetworkManager triggers every
couple of minutes)

Thus the TX queue is stopped and started very often.

The libertas tx_timeout handler is being called quite a lot, and quite
soon after boot we get this in the kernel logs (the first time it
happens):

[   97.050101] ------------[ cut here ]------------
[   97.054866] WARNING: at net/sched/sch_generic.c:258 dev_watchdog+0x102/0x17c
[   97.062277] Hardware name: XO
[   97.065335] NETDEV WATCHDOG: eth0 (libertas_sdio): transmit queue 0 timed out
<snip large trace>

This message seems bogus - all the recent transmissions happened correctly.

What is this watchdog trying to detect exactly? Using what criteria?

I had a look at the code and it doesn't quite make sense to me - also
explaining why we get this bogus message. Here's what happens:

1. Kernel asks libertas to transmit a packet; libertas stops the TX
queue and puts the packet in memory
2. Very shortly after, libertas thread picks up the packet, transmits
it via the card, and restarts the tx queue. The packet is transmitted
correctly, and the queue is awake again.
3. Shortly after (with no further TX activity occuring in this time),
NetworkManager starts scanning for networks. This causes the TX queue
to be stopped and started a few times over the space of a few seconds,
and during this time the queue is stopped for quite a while.
4. The netdev watchdog wakes up in one of these times when the TX
queue is stopped, and uses its criteria (last TX was a few seconds
ago, queue is currently stopped) to determine that a transmit timeout
has occurred (???)

Is libertas doing something wrong, or is this a bug/oddity in the network layer?

Also, while looking at this code, I spotted a bug in dev_watchdog():
				/*
				 * old device drivers set dev->trans_start
				 */
				trans_start = txq->trans_start ? : dev->trans_start;

i.e. it is trying to figure out whether to read trans_start from txq
or dev. In both cases, trans_start is updated based on the value of
jiffies, which will occasionally be 0 (as it wraps around). Therefore
this line of code will occasionally make the wrong decision.

Daniel
