From: William Dauchy <wdauchy@gmail.com>
Subject: NULL dereference on v4.1.x while enabling VF
Date: Mon, 2 May 2016 22:25:33 +0200
Message-ID: <CAJ75kXZV32hLzYY-dynYAj6NHm2xNoq89inmSSbqUyxPvUazEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alex Duyck <aduyck@mirantis.com>
To: NETDEV <netdev@vger.kernel.org>, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35109 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbcEBUZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 16:25:55 -0400
Received: by mail-lf0-f68.google.com with SMTP id u64so25728985lff.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 13:25:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am getting a NULL dereference on v4.1.x while enabling VF on a ixgbe
( Intel Corporation 82599ES 10-Gigabit) card during boot.
It seems to be related to a race since I don't have the issue if I
test it a few seconds after boot. I had the same issue while testing
on v4.5.x
What can I do to help debug the issue?

ip link set dev eth0 up
echo 32 > /sys/class/net/eth0/device/sriov_numvfs

part of the dmesg:
ixgbe 0000:82:00.1: removed PHC on eth1
ixgbe 0000:82:00.1: Multiqueue Enabled: Rx Queue count = 2, Tx Queue count = 2
ixgbe 0000:82:00.1: registered PHC device on eth1
ixgbe 0000:82:00.1 eth1: detected SFP+: 4
ixgbe 0000:82:00.1 eth1: NIC Link is Up 10 Gbps, Flow Control: RX/TX
ixgbevf: Could not enable Tx Queue 0
ixgbevf: Could not enable Tx Queue 1
8021q: adding VLAN 0 to HW filter on device eth2
ixgbe 0000:82:00.0 eth0: VF Reset msg received from vf 0
ixgbe 0000:82:00.0: VF 0 has no MAC address assigned, you may have to
assign one manually
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
ixgbevf: Could not enable Tx Queue 0
ixgbevf: Could not enable Tx Queue 1
IP: [<ffffffff813d3873>] ixgbevf_alloc_rx_buffers+0x53/0x170
PGD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in:
CPU: 8 PID: 1034 Comm: kworker/8:1 Tainted: G        W       4.1.23 #1
Workqueue: events ixgbevf_service_task
task: ffff882021558000 ti: ffff882021554000 task.ti: ffff882021554000
RIP: 0010:[<ffffffff813d3873>]  [<ffffffff813d3873>]
ixgbevf_alloc_rx_buffers+0x53/0x170
RSP: 0018:ffff882021557c58  EFLAGS: 00010246
RAX: 0000000000000200 RBX: ffff88201ccc09c0 RCX: 0000000000000000
RDX: ffffc9000e860000 RSI: 00000000000001ff RDI: ffff88201ccc09c0
RBP: ffff882021557c98 R08: 0000000000000001 R09: 0000000000000001
R10: ffff882021558000 R11: 000000000000017e R12: 0000000000000000
R13: 00000000fffffe00 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88207fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000008 CR3: 0000000001a08000 CR4: 00000000001406e0
Stack:
 ffff88201d630940 01ff00000000000a ffff882021557c78 ffff88201d630c28
 ffff88201d630940 0000000000000009 ffff88201ccc09c0 0000000000000000
 ffff882021557d18 ffffffff813d54b8 0000102800001028 0000000000000000
Call Trace:
 [<ffffffff813d54b8>] ixgbevf_configure+0x50d/0x54e
 [<ffffffff813d6a11>] ? ixgbevf_down+0x2ba/0x2cb
 [<ffffffff813d6687>] ixgbevf_up+0x13/0x1f
 [<ffffffff813d6a85>] ixgbevf_reinit_locked+0x63/0x6c
 [<ffffffff813d76c9>] ixgbevf_service_task+0xe5/0x2dc
 [<ffffffff810743b7>] process_one_work+0x275/0x4f2
 [<ffffffff81074ae1>] worker_thread+0x1f5/0x2a9
 [<ffffffff810748ec>] ? rescuer_thread+0x289/0x289
 [<ffffffff810748ec>] ? rescuer_thread+0x289/0x289
 [<ffffffff81079775>] kthread+0xc5/0xcd
 [<ffffffff81577e9f>] ? _raw_spin_unlock_irq+0x2d/0x4c
 [<ffffffff810796b0>] ? __kthread_parkme+0x87/0x87
 [<ffffffff81578a82>] ret_from_fork+0x42/0x70
 [<ffffffff810796b0>] ? __kthread_parkme+0x87/0x87
Code: 0f 84 33 01 00 00 44 0f b7 67 2e 48 89 fb 0f b7 47 2c 4d 89 e5
4d 89 e6 4d 6b e4 18 49 c1 e6 04 4c 03 77 18 41 29 c5 4c 03 67 38 <49>
83 7c 24 08 00 0f 85 9e 00 00 00 65 8b 05 2a dc c3 7e 48 98
RIP  [<ffffffff813d3873>] ixgbevf_alloc_rx_buffers+0x53/0x170
 RSP <ffff882021557c58>
CR2: 0000000000000008
---[ end trace 6e4d9e7fa97d4fca ]---
BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:21
in_atomic(): 0, irqs_disabled(): 1, pid: 1034, name: kworker/8:1
INFO: lockdep is turned off.
irq event stamp: 43238
hardirqs last  enabled at (43237): [<ffffffff81577efd>]
_raw_spin_unlock_irqrestore+0x3f/0x60
hardirqs last disabled at (43238): [   41.225859] 8021q: adding VLAN 0
to HW filter on device eth3

[<ffffffff8157a4b3>] error_sti+0x5/0x6


Thanks,
-- 
William
