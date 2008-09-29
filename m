From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] net: deadlock during net device unregistration
Date: Mon, 29 Sep 2008 19:54:22 +0200
Message-ID: <20080929175421.722037051@theryb.frec.bull.fr>
References: <20080929175412.866679567@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50340 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbYI2R4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 13:56:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch proposes to replace the rtnl_unlock() call in 
linkwatch_event() by __rtnl_unlock(). The difference between the two
routines being that __rtnl_unlock() will not call netdev_run_todo()
after it unlocks rtnl_mutex.

This is to fix a "deadlock" we observed when unregistering a net device.

In some circumstances, linkwatch_event() blocks the whole "events" 
workqueue while blocking in rtnl_unlock().

Here is what happens:

1. Unregister a device, the following routines are called:

-> unregister_netdev
  -> rtnl_lock
  -> unregister_netdevice
  -> rtnl_unlock
    -> netdev_run_todo
      -> netdev_wait_allrefs

2. In netdev_wait_allrefs(), the device's refcount is greater than 0
  because there are still some routes to be garbage collected later.

3. Also, some link watch events are pending. netdev_wait_allrefs()
  will run the linkwatch event queue, calls linkwatch_run_queue().


Both the route garbage collector dst_gc_task() and the linkwatch task
linkwatch_event() are queued in the same generic workqueue: "events".


4. linkwatch_event() is enqueued earlier in the queue. It will grab
  rtnl_lock(), deliver the link watch events pending, and then call
  rtnl_unlock(). 
  rtnl_unlock() will then call netdev_run_todo() and block on
  mutex_lock(&net_todo_run_mutex).

  At this point, the workqueue "events" is _blocked_ until the
  netdev_wait_allrefs() call above returns when the device refcount 
  reaches 0.

  Problem: it will never happens if dst_gc_task() was enqueued behind
  linkwatch_event() in the "events" workqueue as the queue is now 
  blocked.


Thread foo                            Thread "events"
----------                            ---------------

free IPv6 routes                    |
-> schedule_delayed_work(dst_gc_task)
...                                 |
unregister_netdev                   |
 -> rtln_unlock                     | 
   -> netdev_run_todo               | ...
     -> grab net_todo_run_mutex     |
     -> netdev_wait_allrefs (loop)  | -> run__workqueue()
        ->  linkwatch_run_queue()   | ....
            enqueue linkwatch_event |
            in "events"             |
                                    | -> run_workqueue()
        "BLOCKED"                   |   -> linkwatch_event()
                                    |     -> rtnl_lock()
                                    |     -> __linkwatch_run_queue 
                                    |     ->rtnl_unlock()
                                    |       -> netdev_run_todo
                                    |          -> try to grab net_todo_run_mutex
                                               BLOCKED

Deadlock: 
  
# BLOCKED waiting for dst_gc_task()  # BLOCKED waiting for netdev_wait_allrefs
to decrement the device refcnt         to release net_todo_run_mutex

                  # dst_gst_task() waiting to be run by "events"


This deadlock can be observed sometimes when the loopback is 
unregistered when a network namespaces exits.

Our tests showed no regression so far with this modification done in 
linkwatch_event(), but we aren't sure we understood all the subtleties
in net device unregistration yet. :)

Benjamin

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/core/link_watch.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next-2.6/net/core/link_watch.c
===================================================================
--- net-next-2.6.orig/net/core/link_watch.c
+++ net-next-2.6/net/core/link_watch.c
@@ -207,7 +207,7 @@ static void linkwatch_event(struct work_
 {
 	rtnl_lock();
 	__linkwatch_run_queue(time_after(linkwatch_nextevent, jiffies));
-	rtnl_unlock();
+	__rtnl_unlock();
 }
 
 

-- 
