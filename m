From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 07:54:26 -0800
Message-ID: <56D469B2.2070707@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
 <1456759153.648.61.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34789 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbcB2Pya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 10:54:30 -0500
Received: by mail-pf0-f178.google.com with SMTP id 4so16106714pfd.1
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 07:54:30 -0800 (PST)
In-Reply-To: <1456759153.648.61.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/29/2016 07:19 AM, Eric Dumazet wrote:
> On lun., 2016-02-29 at 07:03 -0800, Peter Hurley wrote:
> 
>> Not the case. The softirq is raised from interrupt.
>>
>> Before Eric's change, when an interrupt raises a new softirq
>> while processing another softirq, the new softirq is immediately
>> processed *after the existing softirq completes*.
>>
>> After Eric's change, when an interrupt raises a new softirq
>> while processing another softirq and _that softirq wakes a process_,
>> the new softirq is *deferred to normal process priority*.
> 
> For the last time, this is not true.
> 
> My patch changed the probability for this to happen.

There is a huge difference between
1. heavy i/o load forcing ksoftirqd to battle out i/o with regular
   sched processes *as a fallback to avoid 100% softirq* and
2. always deferring new softirq just because a process was woken


> It will happen even if you revert it.

I think there is a happy medium where finer constraints on
softirq looping will get us both what we want.

For example, an accumulating mask of softirq already run would
keep one softirq level from looping over-and-over. Or a per-softirq
limiting counter. Or relying on the hard limit that was added later
of a fixed number of softirq loops. Or a combination of those.


> linux never claimed that softirq could steal all cpu time.

That's not the problem observed here.

In fact, what your patch triggers is exactly the opposite:
although cpu load is initially very light because DMA is used to perform
device i/o, once DMA is not being serviced in a timely manner, the
driver fallbacks to purely interrupt-driven i/o which dramatically
increases the real cpu load at those line rates.

> Are by any chance still running a HZ=100 kernel ?

The current kernel is HZ=250 but this would occur on HZ=1000 as well.

Regards,
Peter Hurley
