From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] net: deadlock during net device unregistration - V2
Date: Wed, 01 Oct 2008 16:14:35 +0200
Message-ID: <20081001141432.470106980@theryb.frec.bull.fr>
References: <48E24341.5050609@bull.net>
 <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com>
 <20081001.031243.255655293.davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:47958 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbYJAOSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:18:36 -0400
In-Reply-To: 20081001.031243.255655293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second version of a patch aimed at fixing a deadlock that
can occur when unregistering net devices. 

This new version of the patch ensures the garbage collector 
dst_gc_task() is run when waiting in netdev_wait_allrefs(), by calling
it in the netdevice notifier dst_dev_event() when receiving a 
NETDEV_UNREGISTER event.

Thanks to Jarek Poplawski for proposing this fix.

(The previous version proposed to replace in linkwatch_event()
the call to rntl_unlock() by __rtnl_lock())

Short description of the deadlock
- - - - - - - - - - - - - - - - -

When reaching netdev_wait_allrefs() some routes may still hold the 
device refcount. dst_gc_task() should 'garbage collect' them soon 
(and decrease the refcount). dst_gc_task() is scheduled with a delay in
the "events" workqueue.
But, as some linkwatch events are also pending, netdev_wait_allrefs()
schedules (without delay) a linkwatch_event() in the same workqueue.
linkwatch_event runs before dst_gc_task() and blocks in  netdev_run_todo
(called by rtnl_unlock()), blocking the whole "events" workqueue.

netdev_wait_allrefs() waiting for           dt_gc_task() waiting
dst_gc_task() to decrease the device -----> linkwatch_event() to return
refcount. It holds the mutex                and unblock the "events" 
netdev_run_todo_mutex                       workqueue
       ^                                        |
       |                                        |
       |                                        |
       |                                        |
       |        linkwatch_event() waiting for <-+
       +------- net_dev_run_todo (who called 
                netdev_wait_allrefs()) to release 
                netdev_run_todo_mutex

Long description:
- - - - - - - - -

In some circumstances, linkwatch_event() blocks the whole "events" 
workqueue while blocking in rtnl_unlock(), and prevent dst_gc_task() 
(enqueued in the same workqueue) to be run:

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

Benjamin

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/core/dst.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: net-next-2.6/net/core/dst.c
===================================================================
--- net-next-2.6.orig/net/core/dst.c
+++ net-next-2.6/net/core/dst.c
@@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
 			dst_ifdown(dst, dev, event != NETDEV_DOWN);
 		}
 		mutex_unlock(&dst_gc_mutex);
+
+		if (event == NETDEV_UNREGISTER &&
+		    cancel_delayed_work(&dst_gc_work))
+			dst_gc_task(&dst_gc_work.work);
 		break;
 	}
 	return NOTIFY_DONE;

-- 
