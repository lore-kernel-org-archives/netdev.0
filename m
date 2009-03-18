From: Vernon Mauery <vernux@us.ibm.com>
Subject: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 10:24:52 -0700
Message-ID: <49C12E64.1000301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35760 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773AbZCRRY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 13:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been beating on network throughput in the -rt kernel for some time
now.  After digging down through the send path of UDP packets, I found
that the sk_buff_head.lock is under some very high contention.  This lock
is acquired each time a packet is enqueued on a qdisc and then acquired
again to dequeue the packet.  Under high networking loads, the enqueueing
processes are not only contending among each other for the lock, but also
with the net-tx soft irq.  This makes for some very high contention on this
one lock.  My testcase is running varying numbers of concurrent netperf
instances pushing UDP traffic to another machine.  As the count goes from
1 to 2, the network performance increases.  But from 2 to 4 and from 4 to 8,
we see a big decline, with 8 instances pushing about half of what a single
thread can do.

Running 2.6.29-rc6-rt3 on an 8-way machine with a 10GbE card (I have tried
both NetXen and Broadcom, with very similar results), I can only push about
1200 Mb/s.  Whereas with the mainline 2.6.29-rc8 kernel, I can push nearly
6000 Mb/s. But still not as much as I think is possible.  I was curious and
decided to see if the mainline kernel was hitting the same lock, and using
/proc/lock_stat, it is hitting the sk_buff_head.lock as well (it was the
number one contended lock).

So while this issue really hits -rt kernels hard, it has a real effect on
mainline kernels as well.  The contention of the spinlocks is amplified
when they get turned into rt-mutexes, which causes a double context switch.

Below is the top of the lock_stat for 2.6.29-rc8.  This was captured from
a 1 minute network stress test.  The next high contender had 2 orders of
magnitude fewer contentions.  Think of the throughput increase if we could
ease this contention a bit.  We might even be able to saturate a 10GbE
link.

lock_stat version 0.3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
       class name    con-bounces    contentions   waittime-min   waittime-max   waittime-total    acq-bounces   acquisitions   holdtime-min  holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    &list->lock#3:      24517307       24643791           0.71        1286.62      56516392.42       34834296       44904018           0.60        164.79    31314786.02
     -------------
    &list->lock#3       15596927    [<ffffffff812474da>] dev_queue_xmit+0x2ea/0x468
    &list->lock#3        9046864    [<ffffffff812546e9>] __qdisc_run+0x11b/0x1ef
     -------------
    &list->lock#3        6525300    [<ffffffff812546e9>] __qdisc_run+0x11b/0x1ef
    &list->lock#3       18118491    [<ffffffff812474da>] dev_queue_xmit+0x2ea/0x468


The story is the same for -rt kernels, only the waittime and holdtime are both
orders of magnitude greater.

I am not exactly clear on the solution, but if I understand correctly, in the
past there has been some discussion of batched enqueueing and dequeueing.  Is
anyone else working on this problem right now who has just not yet posted
anything for review?  Questions, comments, flames?

--Vernon

