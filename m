From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 06:32:31 +0000
Message-ID: <20080930063231.GA4792@ff.dom.local>
References: <20080929175421.722037051@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:6309 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbYI3Gci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 02:32:38 -0400
Received: by mu-out-0910.google.com with SMTP id g7so2035288muf.1
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 23:32:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080929175421.722037051@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-09-2008 19:54, Benjamin Thery wrote:
> This patch proposes to replace the rtnl_unlock() call in 
> linkwatch_event() by __rtnl_unlock(). The difference between the two
> routines being that __rtnl_unlock() will not call netdev_run_todo()
> after it unlocks rtnl_mutex.
> 
> This is to fix a "deadlock" we observed when unregistering a net device.
> 
> In some circumstances, linkwatch_event() blocks the whole "events" 
> workqueue while blocking in rtnl_unlock().
> 
> Here is what happens:
> 
> 1. Unregister a device, the following routines are called:
> 
> -> unregister_netdev
>   -> rtnl_lock
>   -> unregister_netdevice
>   -> rtnl_unlock
>     -> netdev_run_todo
>       -> netdev_wait_allrefs
> 
> 2. In netdev_wait_allrefs(), the device's refcount is greater than 0
>   because there are still some routes to be garbage collected later.
> 
> 3. Also, some link watch events are pending. netdev_wait_allrefs()
>   will run the linkwatch event queue, calls linkwatch_run_queue().
> 
> 
> Both the route garbage collector dst_gc_task() and the linkwatch task
> linkwatch_event() are queued in the same generic workqueue: "events".
> 
> 
> 4. linkwatch_event() is enqueued earlier in the queue. It will grab
>   rtnl_lock(), deliver the link watch events pending, and then call
>   rtnl_unlock(). 
>   rtnl_unlock() will then call netdev_run_todo() and block on
>   mutex_lock(&net_todo_run_mutex).
> 
>   At this point, the workqueue "events" is _blocked_ until the
>   netdev_wait_allrefs() call above returns when the device refcount 
>   reaches 0.
> 
>   Problem: it will never happens if dst_gc_task() was enqueued behind
>   linkwatch_event() in the "events" workqueue as the queue is now 
>   blocked.
...

If it's really like this, I wonder if this can happen without linkwatch
too in a non-preemptive config? So maybe this should be fixed somewhere
else? According to a comment above netdev_wait_allrefs() it seems
references should be rather put down on an UNREGISTER event, so this
dst_gc_task() scheduling shouldn't bother us, I guess.

Jarek P.
