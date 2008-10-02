From: "Benjamin Thery " <Benjamin.Thery@bull.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Thu, 02 Oct 2008 21:55:02 +0200
Message-ID: <20081002215502.q9and4a6kg4cs0o8@intran0x.frec.bull.fr>
References: <48E24341.5050609@bull.net>
	<20081001.025935.257260146.davem@davemloft.net>
	<48E34C82.2040306@fr.ibm.com>
	<20081001.031243.255655293.davem@davemloft.net>
	<20081001141432.470106980@theryb.frec.bull.fr>
	<20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com>
	<20081001233152.GA2411@ami.dom.local> <48E4E772.2020208@bull.net>
	<20081002183819.GA2664@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59370 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092AbYJBTzO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 15:55:14 -0400
In-Reply-To: <20081002183819.GA2664@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Jarek Poplawski <jarkao2@gmail.com>:

> On Thu, Oct 02, 2008 at 05:23:30PM +0200, Benjamin Thery wrote:
>> Jarek Poplawski wrote:
>>> On Wed, Oct 01, 2008 at 11:06:22PM +0200, Daniel Lezcano wrote:
>>>> Jarek Poplawski wrote:
>>>>> On Wed, Oct 01, 2008 at 04:14:35PM +0200, Benjamin Thery wrote:
>>> ...
>>>>>> --- net-next-2.6.orig/net/core/dst.c
>>>>>> +++ net-next-2.6/net/core/dst.c
>>>>>> @@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
>>>>>>  			dst_ifdown(dst, dev, event != NETDEV_DOWN);
>>>>>>  		}
>>>>>>  		mutex_unlock(&dst_gc_mutex);
>>>>>> +
>>>>>> +		if (event == NETDEV_UNREGISTER &&
>>>>>> +		    cancel_delayed_work(&dst_gc_work))
>>>>>> +			dst_gc_task(&dst_gc_work.work);
>>>>> Hmm... It seems this shouldn't work yet: cancel_delayed_work() can only
>>>>> kill this while on timer, but not when queued and maybe blocked already.
>>
>> You're right.
>>
>>>
>>> Hmm#2... Then maybe something like this?:
>>>
>>> 		if (event == NETDEV_UNREGISTER &&
>>> 	    	    (cancel_delayed_work(&dst_gc_work) ||
>>> 		     delayed_work_pending(&dst_gc_work)))
>>> 			dst_gc_task(&dst_gc_work.work);
>>
>> Hmmm... I'm not sure I understand what this change do?
>>
>> OK, I see this ensure we will run dst_gc_task() even if
>> cancel_delayed_work() failed and the work is still pending (ie. the
>> timer has expired and dst_gc_work is already in the queue).
>
> I think, this covers exactly the case of blocking you described, plus
> more... (the work is queued but not blocked).
>
>>
>> But what if the work was not pending at all at beginning?
>> We still need to run dst_gc_task().
>
> Maybe I miss something, but if this is really needed here then it
> looks like we are fixing more than "the blocking" bug BTW.
>
>>
>> Is something like this better?
>> (code expanded to be more readable)
>>
>> 	if (event == NETDEV_UNREGISTER) {
>> 	    if (!delayed_work_pending(&dst_gc_work))
>> 	        /* work is not scheduled (no timer, not in queue) */
>
> 		/* may be running too */
>
>> 		dst_gc_task(&dst_gc_work.work);
>> 	    else if (cancel_delayed_work(&dst_gc_work) ||
>>  	             delayed_work_pending(&dst_gc_work)))
>>                 /* work was scheduled (and may be blocked) */
>
> 		/* actually could be both running and pending here:
> 		 * if it's after rearming
> 		 */
>
>>  	        dst_gc_task(&dst_gc_work.work);
>> 	    else
>>                 /* dst_gc_task() is running, do nothing */
>
> So again !delayed_work_pending() - there could be the change of state
> while checking - but then looks a bit inconsistent. I think this should
> be OK too.
>
> As a matter of fact I've thought about something even simpler, which
> probably should help for all above concerns too:
>
> 	if (event == NETDEV_UNREGISTER)
>   	        dst_gc_task(&dst_gc_work.work);
>
> dst_gc_task() locking allows for this, and running this two times in
> a row could be even faster than trying to cancel the unnecessary run.

I've thought a bit more about my last proposal and come to the same
conclusion as you, hmm, almost. I thought we could call
cancel_delayed_work() unconditionally and then dst_gc_task().

  	if (event == NETDEV_UNREGISTER) {
                 cancel_delayed_work(&dst_gc_work);
    	        dst_gc_task(&dst_gc_work.work);
         }

But, you're right, calling only dst_gc_task() seems fine to me.

I'll run some tests tomorrow and send a new patch.

Do we agree that this fix (calling dst_gc_task() in dst_dev_event())
is better/more appropriate than the first one (replacing rtnl_unlock()
by the non-blocking __rtnl_unlock() in linkwatch_event())?

Thanks,
Benjamin

>
> Jarek P.
>
>



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

