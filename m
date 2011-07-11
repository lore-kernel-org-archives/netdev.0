From: Ben Greear <greearb@candelatech.com>
Subject: Crash in e1000e driver, 3.0-rc6+
Date: Mon, 11 Jul 2011 11:10:27 -0700
Message-ID: <4E1B3C93.7050400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46906 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758438Ab1GKSK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 14:10:27 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p6BIAR0l032028
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 11:10:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is lightly patched with some NFS related patches.  This was
shortly after boot..I don't think we had even done any real NFS
work yet.

The warning we see fairly often..the crash below is new.

I just pulled and re-built, so it's possible that the code listings
below are not 100% accurate.


Reading symbols from /home/greearb/kernel/2.6/linux-3.0.x64-dbg-nfs/drivers/net/e1000e/e1000e.ko...done.
(gdb) l *(e1000e_reinit_locked+0x5f)
0x11696 is in e1000_reset_task (/home/greearb/git/linux-3.0-nfs/drivers/net/e1000e/netdev.c:4933).
4928		adapter->tx_timeout_count++;
4929		schedule_work(&adapter->reset_task);
4930	}
4931	
4932	static void e1000_reset_task(struct work_struct *work)
4933	{
4934		struct e1000_adapter *adapter;
4935		adapter = container_of(work, struct e1000_adapter, reset_task);
4936	
4937		/* don't run the task if already down */
(gdb) l *(e1000_alloc_rx_buffers+0x58)
0x12ab6 is in e1000_alloc_rx_buffers (/home/greearb/git/linux-3.0-nfs/drivers/net/e1000e/netdev.c:540).
535	
536		i = rx_ring->next_to_use;
537		buffer_info = &rx_ring->buffer_info[i];
538	
539		while (cleaned_count--) {
540			skb = buffer_info->skb;
541			if (skb) {
542				skb_trim(skb, 0);
543				goto map_skb;
544			}
(gdb)


------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.0-nfs/drivers/net/e1000e/netdev.c:3723 e1000_close+0x3a/0x107 [e1000e]()
Hardware name: X7DBU
Modules linked in: macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi fuse ip6table_filter ip6_tables ebtable_nat ]
Pid: 2404, comm: ip Not tainted 3.0.0-rc6+ #20
Call Trace:
  [<ffffffff81049f72>] warn_slowpath_common+0x80/0x98
  [<ffffffff81049f9f>] warn_slowpath_null+0x15/0x17
  [<ffffffffa024e25e>] e1000_close+0x3a/0x107 [e1000e]
  [<ffffffff813c30e9>] __dev_close_many+0x9b/0xcc
  [<ffffffff813c3149>] __dev_close+0x2f/0x44
  [<ffffffff813c154a>] __dev_change_flags+0xb9/0x13c
  [<ffffffff813c39b3>] dev_change_flags+0x1c/0x51
  [<ffffffff813d1071>] do_setlink+0x2b8/0x78b
  [<ffffffff810c57fe>] ? __perf_event_task_sched_out+0x30b/0x33e
  [<ffffffff813d186f>] rtnl_newlink+0x261/0x4b2
  [<ffffffff813d16ac>] ? rtnl_newlink+0x9e/0x4b2
  [<ffffffff8147d801>] ? __mutex_lock_common+0x3bc/0x46d
  [<ffffffff81041b91>] ? get_parent_ip+0x11/0x41
  [<ffffffff81481c8d>] ? sub_preempt_count+0x92/0xa6
  [<ffffffff813d0ad5>] rtnetlink_rcv_msg+0x1cf/0x1ec
  [<ffffffff813d0906>] ? rtnetlink_rcv+0x28/0x28
  [<ffffffff813e49b4>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff813d08ff>] rtnetlink_rcv+0x21/0x28
  [<ffffffff813e478f>] netlink_unicast+0xe9/0x152
  [<ffffffff813e4f56>] netlink_sendmsg+0x240/0x25e
  [<ffffffff813b4716>] ? rcu_read_unlock+0x21/0x23
  [<ffffffff813af67a>] __sock_sendmsg_nosec+0x58/0x61
  [<ffffffff813b0db5>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813b1631>] sock_sendmsg+0xa3/0xbc
  [<ffffffff8107b06e>] ? lock_release_non_nested+0x9d/0x227
  [<ffffffff810e646f>] ? might_fault+0x4e/0x9e
  [<ffffffff810e64b8>] ? might_fault+0x97/0x9e
  [<ffffffff813baf02>] ? copy_from_user+0x2a/0x2c
  [<ffffffff813bb2d4>] ? verify_iovec+0x4f/0xa3
  [<ffffffff813b1e03>] __sys_sendmsg+0x1d8/0x243
  [<ffffffff8106b7f0>] ? up_read+0x1e/0x36
  [<ffffffff8111a3c6>] ? fcheck_files+0xb7/0xee
  [<ffffffff8111a4e9>] ? fget_light+0x35/0xac
  [<ffffffff813b1fc6>] sys_sendmsg+0x3d/0x5b
  [<ffffffff81484d52>] system_call_fastpath+0x16/0x1b
---[ end trace cddc6b4ca68ac6e8 ]---
e1000e: eth3 NIC Link is Down
e1000e: eth10 NIC Link is Down
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffffa024ea92>] e1000_alloc_rx_buffers+0x58/0x14a [e1000e]
PGD 0
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU 0
Modules linked in: macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi fuse ip6table_filter ip6_tables ebtable_nat ]

Pid: 2367, comm: kworker/0:2 Tainted: G        W   3.0.0-rc6+ #20 Supermicro X7DBU/X7DBU
RIP: 0010:[<ffffffffa024ea92>]  [<ffffffffa024ea92>] e1000_alloc_rx_buffers+0x58/0x14a [e1000e]
RSP: 0018:ffff8801143ddc70  EFLAGS: 00010206
RAX: ffff880128b08090 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000100 RSI: 00000000000000ff RDI: ffff880122d3c900
RBP: ffff8801143ddcc0 R08: ffff8801143ddb80 R09: ffff8801143ddbe0
R10: dead000000200200 R11: dead000000100100 R12: ffff880122d3c900
R13: 0000000000000000 R14: ffff880122818558 R15: 00000000000000ff
FS:  0000000000000000(0000) GS:ffff88012fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000001a03000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:2 (pid: 2367, threadinfo ffff8801143dc000, task ffff8801259267e0)
Stack:
  ffff880122d3c900 ffff880122d3c000 000005f222818558 ffff880128b08090
  ffff8801143ddca0 ffff880122d3c900 ffff880122818558 0000000000001000
  0000000004008002 ffffffffa024d672 ffff8801143ddcf0 ffffffffa024a795
Call Trace:
  [<ffffffffa024d672>] ? e1000e_reinit_locked+0x5f/0x5f [e1000e]
  [<ffffffffa024a795>] e1000_configure+0x507/0x510 [e1000e]
  [<ffffffffa024a7af>] e1000e_up+0x11/0xc9 [e1000e]
  [<ffffffffa024d665>] e1000e_reinit_locked+0x52/0x5f [e1000e]
  [<ffffffffa024dd0e>] e1000_reset_task+0x69c/0x6ab [e1000e]
  [<ffffffff8106128e>] ? process_one_work+0x17b/0x41d
  [<ffffffff81041b91>] ? get_parent_ip+0x11/0x41
  [<ffffffffa024d672>] ? e1000e_reinit_locked+0x5f/0x5f [e1000e]
  [<ffffffff81061343>] process_one_work+0x230/0x41d
  [<ffffffff8106128e>] ? process_one_work+0x17b/0x41d
  [<ffffffff8106379f>] worker_thread+0x133/0x217
  [<ffffffff8106366c>] ? manage_workers+0x191/0x191
  [<ffffffff81066f9c>] kthread+0x7d/0x85
  [<ffffffff81485ee4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147f0d8>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066f1f>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485ee0>] ? gs_change+0x13/0x13
Code: 00 00 89 45 c4 41 0f b7 5e 18 48 8b 87 28 05 00 00 41 89 dd 48 05 90 00 00 00 4d 6b ed 28 4d 03 6e 20 48 89 45 c8 e9 d5 00 00
  8b 45 08 48 85 c0 74 14 48 89 c7 31 f6 48 89 45 b0 e8 29 85
RIP  [<ffffffffa024ea92>] e1000_alloc_rx_buffers+0x58/0x14a [e1000e]
  RSP <ffff8801143ddc70>
CR2: 0000000000000008
---[ end trace cddc6b4ca68ac6e9 ]---

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

