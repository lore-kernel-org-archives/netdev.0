From: Ben Greear <greearb@candelatech.com>
Subject: Kernel crash in 3.7.5+
Date: Tue, 29 Jan 2013 12:52:56 -0800
Message-ID: <510836A8.2070205@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35525 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab3A2Uw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:52:56 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0TKquVL019248
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 12:52:56 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been seeing rtnl v/s rcu deadlocks in my hacked 3.7.4+ kernel,
so, I updated to 3.7.5 and applied a single patch to that to allow
over-riding the regulatory domain in ath9k (test case won't work without
being able to create AP in 5Ghz range..which needs the regulatory hack).

I saw several warnings similar to this, though I think this is a known
problem:

[   89.668284] ------------[ cut here ]------------
[   89.678807] WARNING: at /home/greearb/git/linux-3.7.dev.y/net/mac80211/agg-t)
[   89.701156] Hardware name: To Be Filled By O.E.M.
[   89.711078] Modules linked in: xt_CT iptable_raw nf_conntrack_ipv4 nf_defrag5
[   89.754335] Call Trace:
[   89.754356]  [<c04440dd>] warn_slowpath_common+0x6d/0xa0
[   89.754374]  [<f8b72aab>] ? ieee80211_start_tx_ba_cb+0xcb/0xd0 [mac80211]
[   89.754405]  [<f8b72aab>] ? ieee80211_start_tx_ba_cb+0xcb/0xd0 [mac80211]
[   89.754431]  [<c044412d>] warn_slowpath_null+0x1d/0x20
[   89.754441]  [<f8b72aab>] ieee80211_start_tx_ba_cb+0xcb/0xd0 [mac80211]
[   89.754469]  [<f8b7621f>] ieee80211_iface_work+0x1ff/0x300 [mac80211]
[   89.754496]  [<c0459327>] process_one_work+0x127/0x2f0
[   89.754507]  [<f8b76020>] ? ieee80211_netdev_select_queue+0x10/0x10 [mac8021]
[   89.754533]  [<c045bea2>] worker_thread+0x102/0x380
[   89.754541]  [<c045fedc>] kthread+0x9c/0xa0
[   89.754549]  [<c045bda0>] ? manage_workers+0x2b0/0x2b0
[   89.754555]  [<c0460000>] ? kthread_stop+0x10/0x70
[   89.754563]  [<c0917177>] ret_from_kernel_thread+0x1b/0x28
[   89.754571]  [<c045fe40>] ? kthread_freezable_should_stop+0x50/0x50
[   89.754582] ---[ end trace 055168695121df42 ]---
[   89.754753] ------------[ cut here ]------------

And then, it crashed hard.  Will be re-compiling with debugging symbols
next I suppose...


[  115.621178] sta3: send auth to 00:ab:87:60:10:10 (try 1/3)
[  116.033669] BUG: unable to handle kernel NULL pointer dereference at   (null)
[  116.034529] IP: [<c0458df9>] cwq_dec_nr_in_flight+0x69/0x130
[  116.034529] *pdpt = 0000000000000000 *pde = f000eef3f000eef3
[  116.034529] Oops: 0000 [#1] PREEMPT SMP
[  116.034529] Modules linked in: xt_CT iptable_raw nf_conntrack_ipv4 nf_defrag]
[  116.034529] Pid: 48, comm: kworker/u:2 Tainted: G        WC   3.7.5+ #35 To .
[  116.034529] EIP: 0060:[<c0458df9>] EFLAGS: 00010086 CPU: 0
[  116.034529] EIP is at cwq_dec_nr_in_flight+0x69/0x130
[  116.034529] EAX: f55efe00 EBX: 00000000 ECX: f1799880 EDX: f1799884
[  116.034529] ESI: f5469f00 EDI: c0c4b500 EBP: f5495eec ESP: f5495ec8
[  116.034529]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  116.034529] CR0: 8005003b CR2: 00000000 CR3: 00bfb000 CR4: 000007e0
[  116.034529] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  116.034529] DR6: ffff0ff0 DR7: 00000400
[  116.034529] Process kworker/u:2 (pid: 48, ti=f5494000 task=f543a5b0 task.ti=)
[  116.034529] Stack:
[  116.034529]  f53b38d0 00000000 00000008 00000004 f5168340 f1799884 f179d7bc 0
[  116.034529]  c0c4b500 f5495f2c c045938b c0b26a88 00000000 c0c4b60c c0c4b614 c
[  116.034529]  c0c4b500 f8b76020 c0c4b60c f55efe00 00000000 f55efe45 f5469f00 c
[  116.034529] Call Trace:
[  116.034529]  [<c045938b>] process_one_work+0x18b/0x2f0
[  116.034529]  [<f8b76020>] ? ieee80211_netdev_select_queue+0x10/0x10 [mac8021]
[  116.034529]  [<c045bea2>] worker_thread+0x102/0x380
[  116.034529]  [<c045fedc>] kthread+0x9c/0xa0
[  116.034529]  [<c045bda0>] ? manage_workers+0x2b0/0x2b0
[  116.034529]  [<c0460000>] ? kthread_stop+0x10/0x70
[  116.034529]  [<c0917177>] ret_from_kernel_thread+0x1b/0x28
[  116.034529]  [<c045fe40>] ? kthread_freezable_should_stop+0x50/0x50
[  116.034529] Code: 8d a4 00 00 00 8b 5d f0 8b 4d f0 8b 53 fc 83 e9 04 c7 45 ea
[  116.034529] EIP: [<c0458df9>] cwq_dec_nr_in_flight+0x69/0x130 SS:ESP 0068:f58
[  116.034529] CR2: 0000000000000000
[  116.034529] ---[ end trace 055168695121df49 ]---
[  116.034529] note: kworker/u:2[48] exited with preempt_count 1
[  116.684353] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu0
[  116.684353] Shutting down cpus with NMI
[  116.684353] panic occurred, switching back to text console
[  116.684353] Rebooting in 10 seconds..


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
