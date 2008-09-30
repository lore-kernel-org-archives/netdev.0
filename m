From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 16:42:04 +0200
Message-ID: <20080930144203.GA2511@ami.dom.local>
References: <48E212FF.1060409@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:44790 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbYI3Ol6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:41:58 -0400
Received: by ik-out-1112.google.com with SMTP id c30so41173ika.5
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 07:41:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48E212FF.1060409@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote, On 09/30/2008 01:52 PM:

> Jarek Poplawski wrote:
>> On 29-09-2008 19:54, Benjamin Thery wrote:
...
>>>   Problem: it will never happens if dst_gc_task() was enqueued behind
>>>   linkwatch_event() in the "events" workqueue as the queue is now 
>>>   blocked.
>> ...
>>
>> If it's really like this, I wonder if this can happen without linkwatch
>> too in a non-preemptive config?
> 
> Um, not sure I fully understand what you mean... do you mean with
> CONFIG_PREEMPT_NONE=y?

Yes, but after rethinking I see this is irrelevant. Anyway, my main
concern is that it seems similar dependency might happen between other
than linkwatch work functions or processes waiting for each other.

>> So maybe this should be fixed somewhere
>> else? According to a comment above netdev_wait_allrefs() it seems
>> references should be rather put down on an UNREGISTER event, so this
>> dst_gc_task() scheduling shouldn't bother us, I guess.
> 
> I saw this comment too. In our case, the UNREGISTER event is sent,
> notifications are dispatched correctly, some routes are deleted
> (dst_free()) but not destroyed (dst_destroy()) and the garbage collector
> as to run to finish the work.
> 
> dst_entry's may hold a refcount on device until dst_destroy() is run on
> them. Unfortunately dst_gc_task() won't have a chance to run
> dst_destroy() on them later in this case because it is stuck in the
> "events" workqueue behind linkwatch_event() who is blocking everyone 
> else in the queue.
> 
> I'm still looking at why the first dst_free() on those particular routes 
> doesn't call dst_destroy() immediately but defers it (another refcount
> on the route itself).

Yes, finding/fixing this, if possible, in this place looks like the
most consistent with the way netdev_wait_allrefs() is handling this.

Thanks,
Jarek P.
