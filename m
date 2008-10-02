From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Thu, 02 Oct 2008 17:23:30 +0200
Message-ID: <48E4E772.2020208@bull.net>
References: <48E24341.5050609@bull.net> <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com> <20081001233152.GA2411@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42440 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbYJBPXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 11:23:45 -0400
In-Reply-To: <20081001233152.GA2411@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 01, 2008 at 11:06:22PM +0200, Daniel Lezcano wrote:
>> Jarek Poplawski wrote:
>>> On Wed, Oct 01, 2008 at 04:14:35PM +0200, Benjamin Thery wrote:
> ...
>>>> --- net-next-2.6.orig/net/core/dst.c
>>>> +++ net-next-2.6/net/core/dst.c
>>>> @@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
>>>>  			dst_ifdown(dst, dev, event != NETDEV_DOWN);
>>>>  		}
>>>>  		mutex_unlock(&dst_gc_mutex);
>>>> +
>>>> +		if (event == NETDEV_UNREGISTER &&
>>>> +		    cancel_delayed_work(&dst_gc_work))
>>>> +			dst_gc_task(&dst_gc_work.work);
>>> Hmm... It seems this shouldn't work yet: cancel_delayed_work() can only
>>> kill this while on timer, but not when queued and maybe blocked already.

You're right.

> 
> Hmm#2... Then maybe something like this?:
> 
> 		if (event == NETDEV_UNREGISTER &&
> 	    	    (cancel_delayed_work(&dst_gc_work) ||
> 		     delayed_work_pending(&dst_gc_work)))
> 			dst_gc_task(&dst_gc_work.work);

Hmmm... I'm not sure I understand what this change do?

OK, I see this ensure we will run dst_gc_task() even if
cancel_delayed_work() failed and the work is still pending (ie. the 
timer has expired and dst_gc_work is already in the queue).

But what if the work was not pending at all at beginning?
We still need to run dst_gc_task().

Is something like this better?
(code expanded to be more readable)

	if (event == NETDEV_UNREGISTER) {
	    if (!delayed_work_pending(&dst_gc_work))
	        /* work is not scheduled (no timer, not in queue) */
		dst_gc_task(&dst_gc_work.work);
	    else if (cancel_delayed_work(&dst_gc_work) ||
  	             delayed_work_pending(&dst_gc_work)))
                 /* work was scheduled (and may be blocked) */
  	        dst_gc_task(&dst_gc_work.work);
	    else
                 /* dst_gc_task() is running, do nothing */
	}

Benjamin



> 
> 
> Jarek P.
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
