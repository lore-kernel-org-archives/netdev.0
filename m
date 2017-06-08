From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH net] Fix an intermittent pr_emerg warning about lo becoming
 free.
Date: Thu, 8 Jun 2017 13:12:38 -0700
Message-ID: <20170608201238.GC2553@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:59408 "EHLO
        homiemail-a57.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751550AbdFHUMk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:12:40 -0400
Received: from homiemail-a57.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a57.g.dreamhost.com (Postfix) with ESMTP id 996FD6004D18
        for <netdev@vger.kernel.org>; Thu,  8 Jun 2017 13:12:39 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a57.g.dreamhost.com (Postfix) with ESMTPSA id 6241B6004D0C
        for <netdev@vger.kernel.org>; Thu,  8 Jun 2017 13:12:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like this:

Message from syslogd@flamingo at Apr 26 00:45:00 ...
 kernel:unregister_netdevice: waiting for lo to become free. Usage count = 4

They seem to coincide with net namespace teardown.

The message is emitted by netdev_wait_allrefs().

Forced a kdump in netdev_run_todo, but found that the refcount on the lo
device was already 0 at the time we got to the panic.

Used bcc to check the blocking in netdev_run_todo.  The only places
where we're off cpu there are in the rcu_barrier() and msleep() calls.
That behavior is expected.  The msleep time coincides with the amount of
time we spend waiting for the refcount to reach zero; the rcu_barrier()
wait times are not excessive.

After looking through the list of callbacks that the netdevice notifiers
invoke in this path, it appears that the dst_dev_event is the most
interesting.  The dst_ifdown path places a hold on the loopback_dev as
part of releasing the dev associated with the original dst cache entry.
Most of our notifier callbacks are straight-forward, but this one a)
looks complex, and b) places a hold on the network interface in
question.

I constructed a new bcc script that watches various events in the
liftime of a dst cache entry.  Note that dst_ifdown will take a hold on
the loopback device until the invalidated dst entry gets freed.

[      __dst_free] on DST: ffff883ccabb7900 IF tap1008300eth0 invoked at 1282115677036183
    __dst_free
    rcu_nocb_kthread
    kthread
    ret_from_fork
---
[     dst_gc_task] completed in          4: start: 1282115783057516 end 1282115783062462
[     dst_gc_task] completed in          5: start: 1282116447054101 end 1282116447059392
[     dst_gc_task] completed in          5: start: 1282118111030391 end 1282118111036041
[     dst_gc_task] completed in          6: start: 1282121247074938 end 1282121247081141
[     dst_gc_task] completed in          5: start: 1282126815053252 end 1282126815058751
[     dst_gc_task] completed in          6: start: 1282135007055673 end 1282135007061877
[     dst_gc_task] completed in          6: start: 1282145759021745 end 1282145759027830
[     dst_release] on DST: ffff883ccabb7900 IF tap1008300eth0 invoked at 1282147838674257
    dst_release
    ip_queue_xmit
    tcp_transmit_skb
    tcp_write_xmit
    __tcp_push_pending_frames
    tcp_send_fin
    tcp_close
    inet_release
    sock_release
    sock_close
    __fput
    ____fput
    task_work_run
    do_exit
    do_group_exit
    SyS_exit_group
    do_syscall_64
    return_from_SYSCALL_64
[      dst_ifdown] on DST: ffff883ccabb7900 IF tap1008300eth0 invoked at 1282148067377680
    dst_ifdown
    notifier_call_chain
    raw_notifier_call_chain
    call_netdevice_notifiers_info
    netdev_run_todo
    kretprobe_trampoline
    default_device_exit_batch
    ops_exit_list.isra.4
    cleanup_net
    process_one_work
    worker_thread
    kthread
    ret_from_fork
---
[      dst_ifdown] on DST: ffff883ccabb7900 IF lo invoked at 1282148067411269
    dst_ifdown
    notifier_call_chain
    raw_notifier_call_chain
    call_netdevice_notifiers_info
    netdev_run_todo
    kretprobe_trampoline
    default_device_exit_batch
    ops_exit_list.isra.4
    cleanup_net
    process_one_work
    worker_thread
    kthread
    ret_from_fork
---
<...>
[     dst_destroy] on DST: ffff883ccabb7900 IF lo invoked at 1282160607074022
    dst_destroy
    kretprobe_trampoline
    worker_thread
    kthread
    ret_from_fork
---
[     dst_gc_task] completed in         30: start: 1282160607047161 end 1282160607077572

The way this works is that if there's still a reference on the dst entry
at the time we try to free it, it gets placed in the gc list by
__dst_free and the dst_destroy() call is invoked by the gc task once the
refcount is 0.  If the gc task processes a 10th or less of its entries
on a single pass, it inreases the amount of time it waits between gc
intervals.

Looking at the gc_task intervals, they started at 663ms when we invoked
__dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
10751, and 14848.  The release that set the refcnt to 0 on our dst entry
occurred after the gc_task was enqueued for 14 second interval so we had
to wait longer than the warning time in wait_allrefs in order for the
dst entry to get free'd and the hold on 'lo' to be released.

A simple solution to this problem is to have dst_dev_event() reset the
gc timer, which causes us to process this list shortly after the
gc_mutex is relased when dst_dev_event() completes.

Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 net/core/dst.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/core/dst.c b/net/core/dst.c
index 6192f11..13ba4a0 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -469,6 +469,20 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
 		spin_lock_bh(&dst_garbage.lock);
 		dst = dst_garbage.list;
 		dst_garbage.list = NULL;
+		/* The code in dst_ifdown places a hold on the loopback device.
+		 * If the gc entry processing is set to expire after a lengthy
+		 * interval, this hold can cause netdev_wait_allrefs() to hang
+		 * out and wait for a long time -- until the the loopback
+		 * interface is released.  If we're really unlucky, it'll emit
+		 * pr_emerg messages to console too.  Reset the interval here,
+		 * so dst cleanups occur in a more timely fashion.
+		 */
+		if (dst_garbage.timer_inc > DST_GC_INC) {
+			dst_garbage.timer_inc = DST_GC_INC;
+			dst_garbage.timer_expires = DST_GC_MIN;
+			mod_delayed_work(system_wq, &dst_gc_work,
+					 dst_garbage.timer_expires);
+		}
 		spin_unlock_bh(&dst_garbage.lock);
 
 		if (last)
-- 
2.7.4
