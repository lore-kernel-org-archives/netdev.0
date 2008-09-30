From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 13:52:31 +0200
Message-ID: <48E212FF.1060409@bull.net>
References: <20080930063231.GA4792@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50080 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbYI3Lwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 07:52:45 -0400
In-Reply-To: <20080930063231.GA4792@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 29-09-2008 19:54, Benjamin Thery wrote:
>> This patch proposes to replace the rtnl_unlock() call in 
>> linkwatch_event() by __rtnl_unlock(). The difference between the two
>> routines being that __rtnl_unlock() will not call netdev_run_todo()
>> after it unlocks rtnl_mutex.
>>
>> This is to fix a "deadlock" we observed when unregistering a net device.
>>
>> In some circumstances, linkwatch_event() blocks the whole "events" 
>> workqueue while blocking in rtnl_unlock().
>>
>> Here is what happens:
>>
>> 1. Unregister a device, the following routines are called:
>>
>> -> unregister_netdev
>>   -> rtnl_lock
>>   -> unregister_netdevice
>>   -> rtnl_unlock
>>     -> netdev_run_todo
>>       -> netdev_wait_allrefs
>>
>> 2. In netdev_wait_allrefs(), the device's refcount is greater than 0
>>   because there are still some routes to be garbage collected later.
>>
>> 3. Also, some link watch events are pending. netdev_wait_allrefs()
>>   will run the linkwatch event queue, calls linkwatch_run_queue().
>>
>>
>> Both the route garbage collector dst_gc_task() and the linkwatch task
>> linkwatch_event() are queued in the same generic workqueue: "events".
>>
>>
>> 4. linkwatch_event() is enqueued earlier in the queue. It will grab
>>   rtnl_lock(), deliver the link watch events pending, and then call
>>   rtnl_unlock(). 
>>   rtnl_unlock() will then call netdev_run_todo() and block on
>>   mutex_lock(&net_todo_run_mutex).
>>
>>   At this point, the workqueue "events" is _blocked_ until the
>>   netdev_wait_allrefs() call above returns when the device refcount 
>>   reaches 0.
>>
>>   Problem: it will never happens if dst_gc_task() was enqueued behind
>>   linkwatch_event() in the "events" workqueue as the queue is now 
>>   blocked.
> ...
> 
> If it's really like this, I wonder if this can happen without linkwatch
> too in a non-preemptive config?

Um, not sure I fully understand what you mean... do you mean with
CONFIG_PREEMPT_NONE=y?

> So maybe this should be fixed somewhere
> else? According to a comment above netdev_wait_allrefs() it seems
> references should be rather put down on an UNREGISTER event, so this
> dst_gc_task() scheduling shouldn't bother us, I guess.

I saw this comment too. In our case, the UNREGISTER event is sent,
notifications are dispatched correctly, some routes are deleted
(dst_free()) but not destroyed (dst_destroy()) and the garbage collector
as to run to finish the work.

dst_entry's may hold a refcount on device until dst_destroy() is run on
them. Unfortunately dst_gc_task() won't have a chance to run
dst_destroy() on them later in this case because it is stuck in the
"events" workqueue behind linkwatch_event() who is blocking everyone 
else in the queue.

I'm still looking at why the first dst_free() on those particular routes 
doesn't call dst_destroy() immediately but defers it (another refcount
on the route itself).

BTW, in the past (last year) dst_gc_task() was run as a timer handler 
and this situation (deadlock with linkwatch_event()) couldn't occur.

Thanks,
Benjamin

> 
> Jarek P.
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
