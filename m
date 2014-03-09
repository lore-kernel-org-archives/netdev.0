From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run calls
Date: Sun, 09 Mar 2014 18:53:38 -0400 (EDT)
Message-ID: <20140309.185338.2057082497431220324.davem@davemloft.net>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
	<20140306.160622.59358366688518505.davem@davemloft.net>
	<1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 09 Mar 2014 19:09:20 +0000

> On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote:
>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>> Date: Wed,  5 Mar 2014 00:49:47 +0100
>> 
>> > @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
>> >       /* Wait for outstanding qdisc_run calls. */
>> >       list_for_each_entry(dev, head, unreg_list)
>> >               while (some_qdisc_is_busy(dev))
>> > -                     yield();
>> > +                     msleep(1)
>> >  }
>> 
>> I don't understand this.
>> 
>> yield() should really _mean_ yield.
>> 
>> The intent of a yield() call, like this one here, is unambiguously
>> that the current thread cannot do anything until some other thread
>> gets onto the cpu and makes forward progress.
>>
>> Therefore it should allow lower priority threads to run, not just
>> equal or higher priority ones.
> 
> Until when?
> 
> yield() is not a sensible operation in a preemptive multitasking system,
> regardless of RT.

To me it means "I've got nothing to do if other tasks want to run right
now"  Yes, I even see it having this meaning when an RT task executes
it.

How else can you interpret the intent above?

If you change it to msleep(1), you're assigning an extra completely
arbitrary time limit to the yield.  The code doesn't want to sleep
for 1ms, that's not what it's asking for.

On the other hand, I do completely agree with other replies stating
that it would be better if we found a way for this code to wait on
something explicitly via a wait queue.

Unfortunately, that's undesirable from another perspective, in that it
would probably require making the fast paths of the qdiscs more
expensive.
