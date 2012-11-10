From: Sasha Levin <sasha.levin@oracle.com>
Subject: net, batman: NULL ptr deref in batadv_iv_ogm_queue_add
Date: Fri, 09 Nov 2012 21:06:36 -0500
Message-ID: <509DB6AC.1030204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21442 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2KJCHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 21:07:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

While fuzzing with trinity in a KVM tools (lkvm) guest running latest -=
next
kernel, I've stumbled on the following:

[  469.854708] batman_adv: =EF=BF=BD,=EF=BF=BD]+: Removing interface: b=
ond0
[  469.890909] BUG: unable to handle kernel NULL pointer dereference at=
 0000000000000003
[  469.906428] IP: [<ffffffff839e3810>] batadv_iv_ogm_queue_add+0x20/0x=
700
[  469.906428] PGD 907c067 PUD 907b067 PMD 0
[  469.906428] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  469.906428] Dumping ftrace buffer:
[  469.921756]    (ftrace buffer empty)
[  469.921756] CPU 1
[  469.921756] Pid: 43, comm: kworker/u:1 Tainted: G        W    3.7.0-=
rc4-next-20121109-sasha-00013-g9407f3c #125
[  469.921756] RIP: 0010:[<ffffffff839e3810>]  [<ffffffff839e3810>] bat=
adv_iv_ogm_queue_add+0x20/0x700
[  469.921756] RSP: 0000:ffff880013361c08  EFLAGS: 00010292
[  469.921756] RAX: 0000000000000062 RBX: 0000000000000000 RCX: ffff880=
0622d2c00
[  469.921756] RDX: 000000000000001a RSI: 0000000000000000 RDI: 0000000=
000000064
[  469.921756] RBP: ffff880013361c88 R08: 0000000000000001 R09: 0000000=
1000042bf
[  469.921756] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000=
1000042bf
[  469.921756] R13: ffff8800088e8b00 R14: ffff8800088e8b00 R15: 0000000=
000000001
[  469.921756] FS:  0000000000000000(0000) GS:ffff880027800000(0000) kn=
lGS:0000000000000000
[  469.921756] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  469.921756] CR2: 0000000000000003 CR3: 000000000788e000 CR4: 0000000=
0000406e0
[  469.921756] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  469.921756] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  469.921756] Process kworker/u:1 (pid: 43, threadinfo ffff88001336000=
0, task ffff880013358000)
[  469.921756] Stack:
[  469.921756]  ffff880013361c28 ffffffff81135a74 ffff8800088e8b00 0000=
000000000000
[  469.921756]  ffff880013361c88 ffffffff839f32ed ffffffff839f3160 0000=
000000000000
[  469.921756]  ffff880021f0cae0 0000000000000000 ffff8800622d2c00 0000=
000000000000
[  469.921756] Call Trace:
[  469.921756]  [<ffffffff81135a74>] ? __rcu_read_unlock+0x44/0xb0
[  469.921756]  [<ffffffff839f32ed>] ? batadv_slide_own_bcast_window+0x=
1cd/0x1f0
[  469.921756]  [<ffffffff839f3160>] ? batadv_slide_own_bcast_window+0x=
40/0x1f0
[  469.921756]  [<ffffffff839e4196>] batadv_iv_ogm_schedule+0x2a6/0x300
[  469.921756]  [<ffffffff839e3ef0>] ? batadv_iv_ogm_queue_add+0x700/0x=
700
[  469.921756]  [<ffffffff811135cf>] ? local_bh_enable_ip+0xef/0x150
[  469.921756]  [<ffffffff839f6d90>] batadv_send_outstanding_bat_ogm_pa=
cket+0xd0/0xf0
[  469.921756]  [<ffffffff8112d539>] process_one_work+0x3b9/0x770
[  469.921756]  [<ffffffff8112d3e8>] ? process_one_work+0x268/0x770
[  469.921756]  [<ffffffff8117d3f2>] ? get_lock_stats+0x22/0x70
[  469.921756]  [<ffffffff839f6cc0>] ? batadv_add_bcast_packet_to_list+=
0x320/0x320
[  469.921756]  [<ffffffff8112deba>] worker_thread+0x2ba/0x3f0
[  469.921756]  [<ffffffff8112dc00>] ? rescuer_thread+0x2d0/0x2d0
[  469.921756]  [<ffffffff81138c23>] kthread+0xe3/0xf0
[  469.921756]  [<ffffffff8117d47e>] ? put_lock_stats.isra.16+0xe/0x40
[  469.921756]  [<ffffffff81138b40>] ? insert_kthread_work+0x90/0x90
[  469.921756]  [<ffffffff83be1fbc>] ret_from_fork+0x7c/0xb0
[  469.921756]  [<ffffffff81138b40>] ? insert_kthread_work+0x90/0x90
[  469.921756] Code: 16 7a fd e8 43 22 75 fd 5d c3 90 55 48 89 e5 41 57=
 41 56 41 55 49 89 fd bf 64 00 00 00 41 54 4d 89 cc 53 48
83 ec 58 48 89 75 b8 <0f> b6 5e 03 89 55 c0 48 89 4d b0 44 89 45 c4 e8 =
9c ec 72 fd 49
[  469.921756] RIP  [<ffffffff839e3810>] batadv_iv_ogm_queue_add+0x20/0=
x700
[  469.921756]  RSP <ffff880013361c08>
[  469.921756] CR2: 0000000000000003
[  470.016647] ---[ end trace 42fb97717ce977ba ]---


Thanks,
Sasha
