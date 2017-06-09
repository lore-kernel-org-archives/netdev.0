From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fix an intermittent pr_emerg warning about lo
 becoming free.
Date: Fri, 09 Jun 2017 12:28:33 -0400 (EDT)
Message-ID: <20170609.122833.1884115657212884867.davem@davemloft.net>
References: <20170608201238.GC2553@templeofstupid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: kjlx@templeofstupid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdFIQ2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:28:35 -0400
In-Reply-To: <20170608201238.GC2553@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krister Johansen <kjlx@templeofstupid.com>
Date: Thu, 8 Jun 2017 13:12:38 -0700

> It looks like this:
> 
> Message from syslogd@flamingo at Apr 26 00:45:00 ...
>  kernel:unregister_netdevice: waiting for lo to become free. Usage count = 4
> 
> They seem to coincide with net namespace teardown.
> 
> The message is emitted by netdev_wait_allrefs().
> 
> Forced a kdump in netdev_run_todo, but found that the refcount on the lo
> device was already 0 at the time we got to the panic.
> 
> Used bcc to check the blocking in netdev_run_todo.  The only places
> where we're off cpu there are in the rcu_barrier() and msleep() calls.
> That behavior is expected.  The msleep time coincides with the amount of
> time we spend waiting for the refcount to reach zero; the rcu_barrier()
> wait times are not excessive.
> 
> After looking through the list of callbacks that the netdevice notifiers
> invoke in this path, it appears that the dst_dev_event is the most
> interesting.  The dst_ifdown path places a hold on the loopback_dev as
> part of releasing the dev associated with the original dst cache entry.
> Most of our notifier callbacks are straight-forward, but this one a)
> looks complex, and b) places a hold on the network interface in
> question.
> 
> I constructed a new bcc script that watches various events in the
> liftime of a dst cache entry.  Note that dst_ifdown will take a hold on
> the loopback device until the invalidated dst entry gets freed.
 ...
> The way this works is that if there's still a reference on the dst entry
> at the time we try to free it, it gets placed in the gc list by
> __dst_free and the dst_destroy() call is invoked by the gc task once the
> refcount is 0.  If the gc task processes a 10th or less of its entries
> on a single pass, it inreases the amount of time it waits between gc
> intervals.
> 
> Looking at the gc_task intervals, they started at 663ms when we invoked
> __dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
> 10751, and 14848.  The release that set the refcnt to 0 on our dst entry
> occurred after the gc_task was enqueued for 14 second interval so we had
> to wait longer than the warning time in wait_allrefs in order for the
> dst entry to get free'd and the hold on 'lo' to be released.
> 
> A simple solution to this problem is to have dst_dev_event() reset the
> gc timer, which causes us to process this list shortly after the
> gc_mutex is relased when dst_dev_event() completes.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>

Yeah this is one of the more unsatisfying areas of dst and device handling
in the tree, thanks for working on this.

Applied and queued up for -stable, thanks again.
