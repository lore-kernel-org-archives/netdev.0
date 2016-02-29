From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 07:03:11 -0800
Message-ID: <56D45DAF.5070709@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35124 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbcB2PDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 10:03:15 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj10so24089087pad.2
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 07:03:15 -0800 (PST)
In-Reply-To: <1456721889.3488.67.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2016 08:58 PM, Mike Galbraith wrote:
> On Sun, 2016-02-28 at 18:01 +0100, Francois Romieu wrote:
>> Mike Galbraith <umgwanakikbuti@gmail.com> :
>> [...]
>>> Hrm, relatively new + tasklet woes rings a bell.  Ah, that..
>>>
>>>
>>> What's worse is that at the point where this code was written it was
>>> already well known that tasklets are a steaming pile of crap and
>>> should die.
>>>
>>>
>>> Source thereof https://lwn.net/Articles/588457/

Thanks but not applicable. tglx's POV has everything to do with the
tasklet interface and not the general concept of bottom-half interrupt
processing in a timely manner. In any event, the problem created by
Eric's change is not restricted to tasklets, but rather applies to
all softirq.


>> tasklets are ingrained in the dmaengine API (see Documentation/dmaengine/client.txt
>> and drivers/dma/virt-dma.h::vchan_cookie_complete).
>>
>> Moving everything to irq context or handling his own sub-{jiffy/ms} timer
>> while losing async dma doesn't exactly smell like roses either. :o(
> 
> https://lwn.net/Articles/239633/
> 
> If I'm listening properly, the root cause is that there is a timing
> constraint involved, which is being exposed because one softirq raises
> another (ew).

Not the case. The softirq is raised from interrupt.

Before Eric's change, when an interrupt raises a new softirq
while processing another softirq, the new softirq is immediately
processed *after the existing softirq completes*.

After Eric's change, when an interrupt raises a new softirq
while processing another softirq and _that softirq wakes a process_,
the new softirq is *deferred to normal process priority*.
This happens even if the new softirq is higher priority than the
one currently running, which is flat-out wrong.

The reason this happens repeatedly and regularly is because
1. The time window while NET_RX softirq is running is big.
2. NET_RX softirq will almost always wake a process for a received packet.

The reason why Eric's change is so effective for Eric's workload is
that it fixes the problem where NET_RX keeps getting new network packets
so it keeps looping, servicing more NET_RX softirq.

However, I'm pointing out that Eric's sledgehammer approach to fixing
the NET_RX softirq bug is having significant side-effects in other
subsystems.


> Processing timeout happens, freshly raised tasklet
> wanders off to SCHED_NORMAL kthread context where its constraint dies.
> 
> Given the dma stuff apparently works fine in -rt (or did, see below),
> timing constraints can't be super tight, so perhaps we could grow
> realtime workqueue support for the truly deserving.  The tricky bit
> would be being keeping everybody and his brother from abusing it.
> 
> WRT -rt: if dma tasklets really do have hard (ish) constraints, -rt
> recently "broke" in the same way.. of all softirqs which are deferred
> to kthread context, due to a recent change, only timer/hrtimer are
> executed at realtime priority by default.
> 
> 	-Mike
> 
