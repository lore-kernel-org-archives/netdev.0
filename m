From: David Lang <david@lang.hm>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run calls
Date: Sun, 9 Mar 2014 16:28:16 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1403091625110.8854@nftneq.ynat.uz>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>  <20140306.160622.59358366688518505.davem@davemloft.net>  <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>  <20140309.185338.2057082497431220324.davem@davemloft.net>
 <1394407072.15968.81.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, mkl@pengutronix.de,
	linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394407072.15968.81.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 9 Mar 2014, Ben Hutchings wrote:

> On Sun, 2014-03-09 at 18:53 -0400, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Sun, 09 Mar 2014 19:09:20 +0000
>>
>>> On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote:
>>>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>>>> Date: Wed,  5 Mar 2014 00:49:47 +0100
>>>>
>>>>> @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
>>>>>       /* Wait for outstanding qdisc_run calls. */
>>>>>       list_for_each_entry(dev, head, unreg_list)
>>>>>               while (some_qdisc_is_busy(dev))
>>>>> -                     yield();
>>>>> +                     msleep(1)
>>>>>  }
>>>>
>>>> I don't understand this.
>>>>
>>>> yield() should really _mean_ yield.
>>>>
>>>> The intent of a yield() call, like this one here, is unambiguously
>>>> that the current thread cannot do anything until some other thread
>>>> gets onto the cpu and makes forward progress.
>>>>
>>>> Therefore it should allow lower priority threads to run, not just
>>>> equal or higher priority ones.
>>>
>>> Until when?
>>>
>>> yield() is not a sensible operation in a preemptive multitasking system,
>>> regardless of RT.
>>
>> To me it means "I've got nothing to do if other tasks want to run right
>> now"  Yes, I even see it having this meaning when an RT task executes
>> it.
>>
>> How else can you interpret the intent above?
>
> The problem is that 'I've got nothing to do ... now' is information
> about a *point* in time, which gives the scheduler no clue as to when
> this task might be ready again.  So far as task *state* goes, it never
> ceases to be ready.
>
>> If you change it to msleep(1), you're assigning an extra completely
>> arbitrary time limit to the yield.  The code doesn't want to sleep
>> for 1ms, that's not what it's asking for.
> [...]
>
> I think you want to give up a 'time slice' to any task that's available.
> But that's not a meaningful concept for all schedulers.  If your task is
> highest priority and is ready, it must run.  You could drop priority
> temporarily, but then you need it to somehow be bumped up again at some
> time in the future.  Well, sleeping effectively does that.
>
> I do understand that unconditionally sleeping also isn't ideal - the
> task that unblocks this one might already be running on another CPU and
> able to finish sooner than the sleep timeout.
>
> Maybe the answer is a yield_for(time) which sleeps for the given time or
> until there's an idle CPU, whichever is sooner.  But I don't know how
> hard that would be to implement or how widely useful it would be.

what is msleep(0) defined to do? would it be any better?

David Lang
