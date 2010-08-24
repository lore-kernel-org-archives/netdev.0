From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: kernel hangs when removing a dummy netdev with an attached macvlan
Date: Tue, 24 Aug 2010 18:32:25 +0200
Message-ID: <4C73F419.2050204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:43563 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633Ab0HXQc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 12:32:28 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id o7OGWRph021094
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 16:32:27 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7OGWQoB4034744
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 18:32:26 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o7OGWQ1U011210
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 18:32:26 +0200
Received: from smtp.lab.toulouse-stg.fr.ibm.com (smtp.lab.toulouse-stg.fr.ibm.com [9.101.4.108])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id o7OGWQLe011204
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 18:32:26 +0200
Received: from [9.101.17.154] (mai.toulouse-stg.fr.ibm.com [9.101.17.154])
	by smtp.lab.toulouse-stg.fr.ibm.com (Postfix) with ESMTP id 1EB3C2A8051
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 18:32:26 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I noticed the kernel hangs when we create a dummy interface, assign a 
macvlan on it and then delete the dummy interface.

How to reproduce:

  ip link add dummy0 type dummy
  ip link add mc0 link dummy0 type macvlan
  ip link del dummy0

That triggers:

Call Trace:
Code: 8b 84 24 08 08 00 00 49 81 c4 08 08 00 00 48 83 e8 08 48 8b 58 08 
48 83 eb 08 eb 1a 48 8b 38 31 f6 48 8b 87 c8 05 00 00 ff 50 50 <48> 8b 
53 08 48 89 d8 48 8d 5a f8 48 8d 50 08 49 39 d4 75 dd 5a
Kernel panic - not syncing: softlockup: hung tasks
------------[ cut here ]------------
WARNING: at kernel/lockdep.c:2322 trace_hardirqs_on_caller+0xb8/0x13b()
Hardware name: Bochs
Modules linked in:
Pid: 3915, comm: ip Not tainted 2.6.34 #468
Call Trace:
<IRQ>  [<ffffffff8102b2c0>] warn_slowpath_common+0x77/0x8f
  [<ffffffff814002dd>] ? panic+0xda/0xe7
  [<ffffffff8102b2e7>] warn_slowpath_null+0xf/0x11
  [<ffffffff81051b9f>] trace_hardirqs_on_caller+0xb8/0x13b
  [<ffffffff81051c2f>] trace_hardirqs_on+0xd/0xf
  [<ffffffff814002dd>] panic+0xda/0xe7
  [<ffffffff81076538>] softlockup_tick+0x164/0x16d
  [<ffffffff81038334>] run_local_timers+0x18/0x1a
  [<ffffffff81038357>] update_process_times+0x21/0x47
  [<ffffffff8104ec6f>] T.289+0x63/0x65
  [<ffffffff8104ec80>] tick_handle_periodic+0xf/0x57
  [<ffffffff8101330e>] smp_apic_timer_interrupt+0x74/0x86
  [<ffffffff81003493>] apic_timer_interrupt+0x13/0x20
<EOI>  [<ffffffff812fd7c4>] ? macvlan_device_event+0x101/0x11f
  [<ffffffff812fd7c4>] ? macvlan_device_event+0x101/0x11f
  [<ffffffff81405d7b>] notifier_call_chain+0x32/0x5e
  [<ffffffff81048ad8>] raw_notifier_call_chain+0xf/0x11
  [<ffffffff81339942>] call_netdevice_notifiers+0x16/0x18
  [<ffffffff8133a22c>] rollback_registered_many+0x11b/0x205
  [<ffffffff8133a393>] rollback_registered+0x2c/0x33
  [<ffffffff8133a3f7>] unregister_netdevice_queue+0x5d/0x7c
  [<ffffffff81342b17>] rtnl_dellink+0xab/0xc0
  [<ffffffff8134433c>] rtnetlink_rcv_msg+0x1c1/0x1de
  [<ffffffff8134417b>] ? rtnetlink_rcv_msg+0x0/0x1de
  [<ffffffff813536e3>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff81344174>] rtnetlink_rcv+0x21/0x28
  [<ffffffff81353403>] netlink_unicast+0x226/0x29c
  [<ffffffff81353ea8>] netlink_sendmsg+0x269/0x278
  [<ffffffff813287fa>] sock_sendmsg+0xd3/0xf4
  [<ffffffff810ae5b8>] ? might_fault+0x4c/0x9c
  [<ffffffff810ae5b8>] ? might_fault+0x4c/0x9c
  [<ffffffff810ae601>] ? might_fault+0x95/0x9c
  [<ffffffff810ae5b8>] ? might_fault+0x4c/0x9c
  [<ffffffff81332622>] ? verify_iovec+0x59/0x97
  [<ffffffff81328a61>] sys_sendmsg+0x209/0x273
  [<ffffffff8104823c>] ? up_read+0x1e/0x36
  [<ffffffff81405d0c>] ? do_page_fault+0x329/0x366
  [<ffffffff810b5921>] ? do_brk+0x23f/0x322
  [<ffffffff81051bf8>] ? trace_hardirqs_on_caller+0x111/0x13b
  [<ffffffff81402643>] ? trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff81002ae8>] system_call_fastpath+0x16/0x1b
---[ end trace 34536d0c9f1bbf5b ]---

