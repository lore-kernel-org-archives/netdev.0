From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: BUG? locking issue(networking?) with latest git
Date: Wed, 3 Sep 2008 14:22:24 +0300
Message-ID: <200809031422.24883.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:49847 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbYICLXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 07:23:55 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 094951310AA
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2008 14:24:13 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting strange lockup, all operations (tc, ifconfig,pppd) after few days running pppoe-server.

Programgs getting blocked very strange way, i am not able to kill them even.
Softlockup detection enabled, lock dependencies (except lock dependency engine debugging), 
RT mutexes and deadlock detection enabled too.

I notice this bug few weeks ago, even before latest patches, and seems it still remains.


Here is result of SysRQ +T:

Sep  3 14:14:59 194.146.153.99 kernel: lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b007b>] ? pci_bus_assign_resources+0x3f0/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8cc380     0  3060   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8f8e70 00000046 00000001 eb8cc380 eb8cc708 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8cc380 eb8cc4d4 c1b7b300 00000001 00000001 eb896080 00000046 eb8cc4d4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8cc380 00000000 eb8f8e58 c013c6ad eb8cc380 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8ccbf0     0  3065   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8fce70 00000046 00000001 eb8ccbf0 eb8ccf78 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8ccbf0 eb8ccd44 c1b7b300 00000001 c0926fb0 eb896300 00000046 eb8ccd44 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8ccbf0 00000000 eb8fce58 c013c6ad eb8ccbf0 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8cd460     0  3070   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb900e70 00000046 00000001 eb8cd460 eb8cd7e8 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8cd460 eb8cd5b4 c1b7b300 00000001 00000001 eb896580 00000046 eb8cd5b4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8cd460 00000000 eb900e58 c013c6ad eb8cd460 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D c013b569     0  3075   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb94ce70 00000046 00000001 c013b569 eb94ce20 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8cdcd0 eb8cde24 c1b7b300 00000001 eb94c000 eb896800 00000046 eb8cde24 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8cdcd0 00000000 eb94ce58 c013c6ad eb8cdcd0 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013b569>] ? trace_hardirqs_off+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8ce540     0  3080   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb956e70 00000046 00000001 eb8ce540 eb8ce8c8 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8ce540 eb8ce694 c1b7b300 00000001 c0926fb0 eb896a80 00000046 eb8ce694 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        07b1fe26 eb8ce540 00000000 eb956e58 c013c6ad eb8ce540 c013c850 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8cedb0     0  3085   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb96fe70 00000046 00000001 eb8cedb0 eb8cf138 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8cedb0 eb8cef04 c1b7b300 00000001 c0926fb0 eb896d00 00000046 eb8cef04 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8cedb0 00000000 eb96fe58 c013c6ad eb8cedb0 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [14
Sep  3 14:14:59 194.146.153.99 kernel: 1239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b0000>] ? pci_bus_assign_resources+0x375/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] pppd          D eb8cf620     0  3090   1503
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb925e70 00000046 00000001 eb8cf620 eb8cf9a8 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8cf620 eb8cf774 c1b7b300 00000001 c0926fb0 eb896f80 00000046 eb8cf774 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb8cf620 00000000 eb925e58 c013c6ad eb8cf620 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ? ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3619>] ppp_ioctl+0x1c7/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<f89c3452>] ? ppp_ioctl+0x0/0xc90 [ppp_generic]
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sh            S eccaa1f4     0  3095   1465
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb938f34 00000046 c1b71378 eccaa1f4 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ecca8870 ecca89c4 c1b7b300 00000001 c039b990 eb897200 eb938f18 ecca89c4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eccaa1c0 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S eb8408a4     0  3096   3095
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb93df34 00000046 c1b7b378 eb8408a4 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eccaa1c0 eccaa314 c1b71300 00000000 c039b990 ecc2e800 eb93df18 eccaa314 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb840870 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b007b>] ? pci_bus_assign_resources+0x3f0/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S c091d550     0  3097   3096
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb911f34 00000046 c1b7b378 c091d550 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb840870 eb8409c4 c1b7b300 00000001 c039b990 eb897700 00000000 eb8409c4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        07b46872 00000400 00000000 00000000 eb9c32a0 00000246 00000078 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b007b>] ? pci_bus_assign_resources+0x3f0/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] tc            D 00000082     0  4574   3097
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba6ad14 00000046 00000001 00000082 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c32a0 eb9c33f4 c1b71300 00000000 c0394510 ecc2e300 00000046 eb9c33f4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 eb9c32a0 00000000 eba6acfc c013c6ad eb9c32a0 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] ? rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0273eaa>] netlink_unicast+0x1a9/0x20a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027412d>] netlink_sendmsg+0x222/0x22f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255f45>] sock_sendmsg+0xca/0xe1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c015780b>] ? handle_mm_fault+0x235/0x6ab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256192>] sys_sendto+0xa4/0xc3
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0165cf9>] ? do_sync_read+0xab/0xe9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02561c9>] sys_send+0x18/0x1a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256e45>] sys_socketcall+0xc5/0x180
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sh            S eb9c4c24     0  4575   1465
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba4af34 00000046 c1b71378 eb9c4c24 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c0000 eb9c0154 c1b7b300 00000001 c039b990 eb9f0a00 eba4af18 eb9c0154 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb9c4bf0 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S eb9ef654     0  4576   4575
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba62f34 00000046 c1b7b378 eb9ef654 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c4bf0 eb9c4d44 c1b71300 00000000 c039b990 ecc2d900 eba62f18 eb9c4d44 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb9ef620 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S c091d550     0  4577   4576
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba58f34 00000046 c1b7b378 c091d550 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9ef620 eb9ef774 c1b7b300 00000001 c039b990 eb9f3700 00000000 eb9ef774 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        07eb55dd 00000400 00000000 00000000 eb9c5cd0 00000246 00000078 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b007b>] ? pci_bus_assign_resources+0x3f0/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] tc            D 00000082     0  6052   4577
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb8edd14 00000046 00000001 00000082 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c5cd0 eb9c5e24 c1b7b300 00000001 c0394510 eba7aa80 00000046 eb9c5e24 
Sep  3 14:14:59 194.146.153.99 kernel: [
Sep  3 14:14:59 194.146.153.99 kernel: 141239.346476]        07eb55e1 eb9c5cd0 00000000 eb8edcfc c013c6ad eb9c5cd0 c013c850 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] ? rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0273eaa>] netlink_unicast+0x1a9/0x20a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027412d>] netlink_sendmsg+0x222/0x22f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255f45>] sock_sendmsg+0xca/0xe1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c015780b>] ? handle_mm_fault+0x235/0x6ab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256192>] sys_sendto+0xa4/0xc3
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0165cf9>] ? do_sync_read+0xab/0xe9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02561c9>] sys_send+0x18/0x1a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256e45>] sys_socketcall+0xc5/0x180
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sh            S eb9c6de4     0  6053   1465
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebad3f34 00000046 c1b71378 eb9c6de4 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c5460 eb9c55b4 c1b7b300 00000001 c039b990 eb9f1180 ebad3f18 eb9c55b4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb9c6db0 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S eb9e9984     0  6054   6053
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9d6f34 00000046 c1b7b378 eb9e9984 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9c6db0 eb9c6f04 c1b71300 00000000 c039b990 eba79900 eb9d6f18 eb9c6f04 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb9e9950 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S c091d550     0  6055   6054
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaaef34 00000046 c1b7b378 c091d550 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9e9950 eb9e9aa4 c1b7b300 00000001 c039b990 eb9f1900 00000000 eb9e9aa4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        08224712 00000400 00000000 00000000 ebaf3b10 00000246 00000078 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] tc            D 00000082     0  7530   6055
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebac5d14 00000046 00000001 00000082 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf3b10 ebaf3c64 c1b71300 00000000 c0394510 eba7b480 00000046 ebaf3c64 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 ebaf3b10 00000000 ebac5cfc c013c6ad ebaf3b10 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] ? rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0273eaa>] netlink_unicast+0x1a9/0x20a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027412d>] netlink_sendmsg+0x222/0x22f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255f45>] sock_sendmsg+0xca/0xe1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c015780b>] ? handle_mm_fault+0x235/0x6ab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256192>] sys_sendto+0xa4/0xc3
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0165cf9>] ? do_sync_read+0xab/0xe9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02561c9>] sys_send+0x18/0x1a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256e45>] sys_socketcall+0xc5/0x180
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sh            S ebaf1984     0  7531   1465
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb946f34 00000046 c1b71378 ebaf1984 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf10e0 ebaf1234 c1b7b300 00000001 c039b990 eb9f2a80 eb946f18 ebaf1234 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 ebaf1950 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S eb9eaa64     0  7532   7531
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebac0f34 00000046 c1b7b378 eb9eaa64 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf1950 ebaf1aa4 c1b71300 00000000 c039b990 eba78c80 ebac0f18 ebaf1aa4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000002 00000002 00000000 00000000 eb9eaa30 00000246 00000001 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] apply_changes S c091d550     0  7533   7532
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaa0f34 00000046 c1b7b378 c091d550 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9eaa30 eb9eab84 c1b7b300 00000001 c039b990 eb9f2080 00000000 eb9eab84 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        0859384e 00000400 00000000 00000000 ebaf2a30 00000246 00000078 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] tc            D 00000082     0  9008   7533
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebad2d14 00000046 00000001 00000082 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf2a30 ebaf2b84 c1b71300 00000000 c0394510 eba7bc00 00000046 ebaf2b84 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 ebaf2a30 00000000 ebad2cfc c013c6ad ebaf2a30 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] ? rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0273eaa>] netlink_unicast+0x1a9/0x20a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027412d>] netlink_sendmsg+0x222/0x22f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255f45>] sock_sendmsg+0xca/0xe1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c015780b>] ? handle_mm_fault+0x235/0x6ab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256192>] sys_sendto+0xa4/0xc3
Sep  3 14:14:59 194.146.153.99 kernel: 
Sep  3 14:14:59 194.146.153.99 kernel: 4>[141239.346476]  [<c0165cf9>] ? do_sync_read+0xab/0xe9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02561c9>] sys_send+0x18/0x1a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256e45>] sys_socketcall+0xc5/0x180
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sh            S c091d550     0  9013   1494
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba88f34 00200046 c1b7b378 c091d550 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf6db0 ebaf6f04 c1b7b300 00000001 c039b990 eba7b980 00000000 ebaf6f04 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        08594100 00000400 00000000 00000000 ebaf6540 00200246 00000078 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123206>] do_wait+0x1af/0x285
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012335a>] sys_wait4+0x7e/0x94
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0123383>] sys_waitpid+0x13/0x15
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b007b>] ? pci_bus_assign_resources+0x3f0/0x3fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] ip            D 00200082     0  9014   9013
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba0bd14 00200046 00000001 00200082 00000000 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf6540 ebaf6694 c1b71300 00000000 c0394510 eba7af80 00200046 ebaf6694 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 ebaf6540 00000000 eba0bcfc c013c6ad ebaf6540 c013c850 00200246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] ? rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0268612>] rtnetlink_rcv+0x12/0x26
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0273eaa>] netlink_unicast+0x1a9/0x20a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027412d>] netlink_sendmsg+0x222/0x22f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255f45>] sock_sendmsg+0xca/0xe1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c015780b>] ? handle_mm_fault+0x235/0x6ab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256192>] sys_sendto+0xa4/0xc3
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02567b6>] ? move_addr_to_user+0x3b/0x52
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256add>] ? sys_getsockname+0x52/0x6f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02bb910>] ? _spin_unlock_bh+0x25/0x28
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0257a8e>] ? release_sock+0xa3/0xab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0257e6a>] ? sock_def_write_space+0x7e/0x83
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c025923d>] ? sock_setsockopt+0x4f1/0x4fb
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02561c9>] sys_send+0x18/0x1a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0256e45>] sys_socketcall+0xc5/0x180
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] ifconfig      D 00000088     0  9021      1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba01e84 00000046 00000001 00000088 00000002 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        ebaf21c0 ebaf2314 c1b71300 00000000 00000001 eba79680 00000046 ebaf2314 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        00000000 ebaf21c0 00000000 eba01e6c c013c6ad ebaf21c0 c013c850 00000246 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c824>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02ba6c6>] mutex_lock_nested+0x12a/0x204
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02685fe>] ? rtnl_lock+0xf/0x11
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02685fe>] rtnl_lock+0xf/0x11
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c029a877>] devinet_ioctl+0xe0/0x519
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c029b811>] inet_ioctl+0x8d/0xa6
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02557f2>] sock_ioctl+0x1d6/0x1fa
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c025561c>] ? sock_ioctl+0x0/0x1fa
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fa1e>] vfs_ioctl+0x22/0x69
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fc97>] do_vfs_ioctl+0x232/0x245
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02566b8>] ? sys_socket+0x43/0x5a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c016fcd6>] sys_ioctl+0x2c/0x46
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] sshd          S 00000001     0  9022   1540
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eba89b4c 00000046 00000002 00000001 eb9eb2a0 c0855fe4 c0859300 c0859300 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        eb9eb2a0 eb9eb3f4 c1b71300 00000000 c01dc490 eba78500 01318000 eb9eb3f4 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        c010393c eba89b54 c0128ba8 00000000 086b76b2 f2232b00 eba89b74 00000000 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c010393c>] ? restore_nocheck_notrace+0x0/0xe
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0128ba8>] ? __mod_timer+0x95/0xa0
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02b9fbe>] schedule_timeout+0x7f/0x9d
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01286b1>] ? process_timeout+0x0/0xa
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0170c47>] do_select+0x48e/0x4f1
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01712a4>] ? __pollwait+0x0/0xb4
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011c638>] ? default_wake_function+0x0/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0125044>] ? local_bh_enable+0xa7/0xab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027ed51>] ? ip_finish_output+0x1d1/0x209
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027ee07>] ? ip_output+0x7e/0x83
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c027e120>] ? ip_local_out+0x18/0x1b
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c6ad>] ? mark_held_locks+0x53/0x6a
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0128c1c>] ? mod_timer+0x21/0x27
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013d507>] ? __lock_acquire+0x59e/0x1185
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0257a8e>] ? release_sock+0xa3/0xab
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c013c850>] ? trace_hardirqs_on+0xb/0xd
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0124f99>] ? local_bh_enable_ip+0xa6/0xaa
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02bb910>] ? _spin_unlock_bh+0x25/0x28
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0170cd1>] ? core_sys_select+0x27/0x275
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0170e8f>] core_sys_select+0x1e5/0x275
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0255160>] ? sock_aio_write+0xeb/0xf8
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0165c10>] ? do_sync_write+0xab/0xe9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0217ff3>] ? read_chan+0x0/0x5b9
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01310d1>] ? autoremove_wake_function+0x0/0x33
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01711e4>] sys_select+0x88/0x148
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01dc490>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] ash           R running      0  9023   9022
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        c0121216 00000001 ffff8000 00000009 00000010 c088b597 00000001 eba5eebc 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        0000205d eba5ee8e 00000004 00000092 00000001 d9133546 0000001a 315b0004 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]        33323134 00000011 eba5ee8b eb9ebb10 eba5eea0 c02b9570 c033a34c eba5eeac 
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476] Call Trace:
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c012f6b1>] ? __kernel_text_address+0x34/0x3e
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0104ad4>] ? dump_trace+0xb1/0xe5
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01049e4>] ? print_trace_address+0x0/0x3f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0104b97>] show_stack_log_lvl+0x8f/0xa7
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0105992>] show_stack+0x25/0x2f
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011db1b>] sched_show_task+0x89/0x93
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c011db61>] show_state_filter+0x3c/0x81
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0224990>] sysrq_handle_showstate+0xa/0xc
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c02248df>] __handle_sysrq+0x9b/0x112
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c019592c>] ? write_sysrq_trigger+0x0/0x2d
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0195952>] write_sysrq_trigger+0x26/0x2d
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0190354>] proc_reg_write+0x60/0x74
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01902f4>] ? proc_reg_write+0x0/0x74
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01663a3>] vfs_write+0x86/0xf0
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c01664a6>] sys_write+0x3b/0x60
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  [<c0103875>] sysenter_do_call+0x12/0x35
Sep  3 14:14:59 194.146.153.99 kernel: [141239.346476]  =======================
Sep  3 14:14:59 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:14:59 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:00 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:00 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:00 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:00 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:01 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:01 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:02 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:02 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:03 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:04 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:04 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:04 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:04 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:05 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:05 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:05 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:05 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:06 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:06 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:06 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:06 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:08 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:08 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:08 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:08 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:09 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:09 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:10 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:11 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:13 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:13 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:13 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:13 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:14 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:14 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:14 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:14 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:15 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:16 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:16 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:18 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:20 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:20 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:20 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:20 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:21 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:22 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:22 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:22 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:22 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:23 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:23 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:25 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:26 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:26 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:27 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:27 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:28 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:28 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:29 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:29 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:29 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:29 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:30 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:30 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:30 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:30 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:31 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:31 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:32 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:32 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
Sep  3 14:15:32 194.146.153.99 pppoe-server[1496]: No free sessions available, keep silence
Sep  3 14:15:32 194.146.153.99 pppoe-server[1503]: No free sessions available, keep silence
