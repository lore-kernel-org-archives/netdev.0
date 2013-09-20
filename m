From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no devices are unregistering
Date: Fri, 20 Sep 2013 09:34:47 -0700
Message-ID: <1379694887-24525-1-git-send-email-fruggeri@aristanetworks.com>
References: <871u4mh781.fsf@tw-ebiederman.twitter.com>
Cc: edumazet@google.com, jiri@resnulli.us, alexander.h.duyck@intel.com,
	amwang@redhat.com, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:64498 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab3ITQf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:35:29 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so910201pab.8
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:35:28 -0700 (PDT)
In-Reply-To: <871u4mh781.fsf@tw-ebiederman.twitter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just an update.
I have been testing this patch in 3.4 (that is the environment where I can
stress things a bit more) and I have also manually tested cases that were
causing problems before.
This is essentially Eric's patch except that it maintains per-namespace
counters and wait queues to avoid unnecessary wakeup calls.
Everything seems to be working fine.
We just started using lockdep and I did see a couple of warnings though.
They do not seem to be related to the patch to me, but I am attaching them
to see what you think.

Index: linux-3.4.x86_64/include/net/net_namespace.h
===================================================================
--- linux-3.4.x86_64.orig/include/net/net_namespace.h
+++ linux-3.4.x86_64/include/net/net_namespace.h
@@ -68,6 +68,8 @@ struct net {
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
 	unsigned int		dev_base_seq;	/* protected by rtnl_mutex */
+	int			dev_unregistering; /* protected by rtnl_mutex */
+	wait_queue_head_t	dev_unregistering_wait;
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
Index: linux-3.4.x86_64/net/core/net_namespace.c
===================================================================
--- linux-3.4.x86_64.orig/net/core/net_namespace.c
+++ linux-3.4.x86_64/net/core/net_namespace.c
@@ -153,6 +153,8 @@ static __net_init int setup_net(struct n
 	atomic_set(&net->count, 1);
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
+	net->dev_unregistering = 0;
+	init_waitqueue_head(&net->dev_unregistering_wait);
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
Index: linux-3.4.x86_64/net/core/dev.c
===================================================================
--- linux-3.4.x86_64.orig/net/core/dev.c
+++ linux-3.4.x86_64/net/core/dev.c
@@ -5191,6 +5191,7 @@ static LIST_HEAD(net_todo_list);
 static void net_set_todo(struct net_device *dev)
 {
 	list_add_tail(&dev->todo_list, &net_todo_list);
+	dev_net(dev)->dev_unregistering++;
 }
 
 static void rollback_registered_many(struct list_head *head)
@@ -5815,6 +5816,12 @@ void netdev_run_todo(void)
 		if (dev->destructor)
 			dev->destructor(dev);
 
+		rtnl_lock();
+		BUG_ON(dev_net(dev)->dev_unregistering <= 0);
+		if (--dev_net(dev)->dev_unregistering == 0)
+			wake_up(&dev_net(dev)->dev_unregistering_wait);
+		__rtnl_unlock();
+
 		/* Free network device */
 		kobject_put(&dev->dev.kobj);
 	}
@@ -6478,6 +6485,26 @@ static void __net_exit default_device_ex
 	rtnl_unlock();
 }
 
+static void netdev_wait_unregistering_and_lock(struct list_head *net_list)
+{
+	struct net *net;
+
+retry:
+	/* Wait until any devices in namespaces in net_list that were
+	   unregistered by other processes are destroyed */
+	list_for_each_entry(net, net_list, exit_list) {
+		wait_event(net->dev_unregistering_wait,
+			   net->dev_unregistering == 0);
+	}
+	rtnl_lock();
+	list_for_each_entry(net, net_list, exit_list) {
+		if (net->dev_unregistering) {
+			__rtnl_unlock();
+			goto retry;
+		}
+	}
+}
+
 static void __net_exit default_device_exit_batch(struct list_head *net_list)
 {
 	/* At exit all network devices most be removed from a network
@@ -6489,7 +6516,7 @@ static void __net_exit default_device_ex
 	struct net *net;
 	LIST_HEAD(dev_kill_list);
 
-	rtnl_lock();
+	netdev_wait_unregistering_and_lock(net_list);
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
 			if (dev->rtnl_link_ops)
================== LOCKDEP:
Sep 19 01:48:46 bs341 kernel: ===============================
Sep 19 01:48:46 bs341 kernel: [ INFO: suspicious RCU usage. ]
Sep 19 01:48:46 bs341 kernel: 3.4.43-1432884.2010AroraNoureddine.7.fc14.x86_64 #1 Not tainted
Sep 19 01:48:46 bs341 kernel: -------------------------------
Sep 19 01:48:46 bs341 kernel: drivers/net/macvtap.c:97 suspicious rcu_dereference_check() usage!
Sep 19 01:48:46 bs341 kernel:
Sep 19 01:48:46 bs341 kernel: other info that might help us debug this:
Sep 19 01:48:46 bs341 kernel:
Sep 19 01:48:46 bs341 kernel:
Sep 19 01:48:46 bs341 kernel: rcu_scheduler_active = 1, debug_locks = 1
Sep 19 01:48:46 bs341 kernel: 1 lock held by libvirtd/29791:
Sep 19 01:48:46 bs341 kernel: #0:  (macvtap_lock){+.+...}, at: [<ffffffffa033000a>] macvtap_open+0x157/0x1f3 [macvtap]
Sep 19 01:48:46 bs341 kernel:
Sep 19 01:48:46 bs341 kernel: stack backtrace:
Sep 19 01:48:46 bs341 kernel: Pid: 29791, comm: libvirtd Not tainted 3.4.43-1432884.2010AroraNoureddine.7.fc14.x86_64 #1
Sep 19 01:48:46 bs341 kernel: Call Trace:
Sep 19 01:48:46 bs341 kernel: [<ffffffff8106e3e4>] lockdep_rcu_suspicious+0xfc/0x105
Sep 19 01:48:46 bs341 kernel: [<ffffffffa032f51d>] get_slot+0x5f/0x7f [macvtap]
Sep 19 01:48:46 bs341 kernel: [<ffffffffa033001e>] macvtap_open+0x16b/0x1f3 [macvtap]
Sep 19 01:48:46 bs341 kernel: [<ffffffff81105f38>] chrdev_open+0x12b/0x154
Sep 19 01:48:46 bs341 kernel: [<ffffffff81105e0d>] ? cdev_put+0x23/0x23
Sep 19 01:48:46 bs341 kernel: [<ffffffff81100b58>] __dentry_open+0x176/0x29f
Sep 19 01:48:46 bs341 kernel: [<ffffffff8110191f>] nameidata_to_filp+0x63/0x6a
Sep 19 01:48:46 bs341 kernel: [<ffffffff8110e690>] do_last+0x569/0x596
Sep 19 01:48:46 bs341 kernel: [<ffffffff8110edee>] path_openat+0xce/0x348
Sep 19 01:48:46 bs341 kernel: [<ffffffff81008765>] ? native_sched_clock+0x35/0x37
Sep 19 01:48:46 bs341 kernel: [<ffffffff81008770>] ? sched_clock+0x9/0xd
Sep 19 01:48:46 bs341 kernel: [<ffffffff8110f156>] do_filp_open+0x38/0x84
Sep 19 01:48:46 bs341 kernel: [<ffffffff81488775>] ? _raw_spin_unlock+0x26/0x2a
Sep 19 01:48:46 bs341 kernel: [<ffffffff81119d82>] ? alloc_fd+0x173/0x185
Sep 19 01:48:46 bs341 kernel: [<ffffffff81101996>] do_sys_open+0x70/0x102
Sep 19 01:48:46 bs341 kernel: [<ffffffff81141c29>] compat_sys_open+0x16/0x18
Sep 19 01:48:46 bs341 kernel: [<ffffffff814908a6>] sysenter_dispatch+0x7/0x26
Sep 19 01:48:46 bs341 kernel: [<ffffffff812467de>] ? trace_hardirqs_on_thunk+0x3a/0x3f

Sep 19 02:00:40 bs341 kernel: ======================================================
Sep 19 02:00:40 bs341 kernel: [ INFO: possible circular locking dependency detected ]
Sep 19 02:00:40 bs341 kernel: 3.4.43-1432884.2010AroraNoureddine.7.fc14.x86_64 #1 Not tainted
Sep 19 02:00:40 bs341 kernel: -------------------------------------------------------
Sep 19 02:00:40 bs341 kernel: [manager]/6158 is trying to acquire lock:
Sep 19 02:00:40 bs341 kernel: (rtnl_mutex){+.+.+.}, at: [<ffffffff813bccfe>] rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: but task is already holding lock:
Sep 19 02:00:40 bs341 kernel: (&mm->mmap_sem){++++++}, at: [<ffffffff810e3702>] vm_munmap+0x35/0x5c
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: which lock already depends on the new lock.
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: the existing dependency chain (in reverse order) is:
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: -> #1 (&mm->mmap_sem){++++++}:
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8107222b>] lock_acquire+0xbe/0x101
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810dcbef>] might_fault+0x68/0x8b
Sep 19 02:00:40 bs341 kernel:       [<ffffffff813abdbd>] copy_from_user+0x19/0x2c
Sep 19 02:00:40 bs341 kernel:       [<ffffffff813b1375>] dev_ioctl+0x57/0x683
Sep 19 02:00:40 bs341 kernel:       [<ffffffff81399ef5>] sock_do_ioctl+0x38/0x43
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8139a320>] sock_ioctl+0x20e/0x21d
Sep 19 02:00:40 bs341 kernel:       [<ffffffff811115a2>] do_vfs_ioctl+0x488/0x4c9
Sep 19 02:00:40 bs341 kernel:       [<ffffffff81111634>] sys_ioctl+0x51/0x75
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8148f2b9>] system_call_fastpath+0x16/0x1b
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: -> #0 (rtnl_mutex){+.+.+.}:
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810719fa>] __lock_acquire+0xb41/0xe50
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8107222b>] lock_acquire+0xbe/0x101
Sep 19 02:00:40 bs341 kernel:       [<ffffffff814862c2>] __mutex_lock_common+0x4c/0x392
Sep 19 02:00:40 bs341 kernel:       [<ffffffff81486667>] mutex_lock_nested+0x16/0x18
Sep 19 02:00:40 bs341 kernel:       [<ffffffff813bccfe>] rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel:       [<ffffffff814684f8>] packet_release+0xd7/0x267
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8139c429>] sock_release+0x1a/0x77
Sep 19 02:00:40 bs341 kernel:       [<ffffffff8139c4a8>] sock_close+0x22/0x26
Sep 19 02:00:40 bs341 kernel:       [<ffffffff81103c65>] fput+0xff/0x1d4
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810e26ee>] remove_vma+0x37/0x6c
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810e36b4>] do_munmap+0x2ed/0x306
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810e3710>] vm_munmap+0x43/0x5c
Sep 19 02:00:40 bs341 kernel:       [<ffffffff810e3851>] sys_munmap+0x21/0x2a
Sep 19 02:00:40 bs341 kernel:       [<ffffffff814908a6>] sysenter_dispatch+0x7/0x26
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: other info that might help us debug this:
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: Possible unsafe locking scenario:
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel:       CPU0                    CPU1
Sep 19 02:00:40 bs341 kernel:       ----                    ----
Sep 19 02:00:40 bs341 kernel:  lock(&mm->mmap_sem);
Sep 19 02:00:40 bs341 kernel:                               lock(rtnl_mutex);
Sep 19 02:00:40 bs341 kernel:                               lock(&mm->mmap_sem);
Sep 19 02:00:40 bs341 kernel:  lock(rtnl_mutex);
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: *** DEADLOCK ***
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: 1 lock held by [manager]/6158:
Sep 19 02:00:40 bs341 kernel: #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810e3702>] vm_munmap+0x35/0x5c
Sep 19 02:00:40 bs341 kernel:
Sep 19 02:00:40 bs341 kernel: stack backtrace:
Sep 19 02:00:40 bs341 kernel: Pid: 6158, comm: [manager] Not tainted 3.4.43-1432884.2010AroraNoureddine.7.fc14.x86_64 #1
Sep 19 02:00:40 bs341 kernel: Call Trace:
Sep 19 02:00:40 bs341 kernel: [<ffffffff8106e906>] print_circular_bug+0x1f8/0x209
Sep 19 02:00:40 bs341 kernel: [<ffffffff810719fa>] __lock_acquire+0xb41/0xe50
Sep 19 02:00:40 bs341 kernel: [<ffffffff8100d93c>] ? save_stack_trace+0x2a/0x47
Sep 19 02:00:40 bs341 kernel: [<ffffffff813bccfe>] ? rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel: [<ffffffff8107222b>] lock_acquire+0xbe/0x101
Sep 19 02:00:40 bs341 kernel: [<ffffffff813bccfe>] ? rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel: [<ffffffff814862c2>] __mutex_lock_common+0x4c/0x392
Sep 19 02:00:40 bs341 kernel: [<ffffffff813bccfe>] ? rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel: [<ffffffff8106da2a>] ? trace_hardirqs_off+0xd/0xf
Sep 19 02:00:40 bs341 kernel: [<ffffffff8105c972>] ? local_clock+0x36/0x4d
Sep 19 02:00:40 bs341 kernel: [<ffffffff813bccfe>] ? rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel: [<ffffffff81072144>] ? lock_release+0x1d8/0x201
Sep 19 02:00:40 bs341 kernel: [<ffffffff81486667>] mutex_lock_nested+0x16/0x18
Sep 19 02:00:40 bs341 kernel: [<ffffffff813bccfe>] rtnl_lock+0x12/0x14
Sep 19 02:00:40 bs341 kernel: [<ffffffff814684f8>] packet_release+0xd7/0x267
Sep 19 02:00:40 bs341 kernel: [<ffffffff8139c429>] sock_release+0x1a/0x77
Sep 19 02:00:40 bs341 kernel: [<ffffffff8139c4a8>] sock_close+0x22/0x26
Sep 19 02:00:40 bs341 kernel: [<ffffffff81103c65>] fput+0xff/0x1d4
Sep 19 02:00:40 bs341 kernel: [<ffffffff810e26ee>] remove_vma+0x37/0x6c
Sep 19 02:00:40 bs341 kernel: [<ffffffff810e36b4>] do_munmap+0x2ed/0x306
Sep 19 02:00:40 bs341 kernel: [<ffffffff810e3710>] vm_munmap+0x43/0x5c
Sep 19 02:00:40 bs341 kernel: [<ffffffff810e3851>] sys_munmap+0x21/0x2a
Sep 19 02:00:40 bs341 kernel: [<ffffffff814908a6>] sysenter_dispatch+0x7/0x26
Sep 19 02:00:40 bs341 kernel: [<ffffffff812467de>] ? trace_hardirqs_on_thunk+0x3a/0x3f
