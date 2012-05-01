From: "Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
Subject: skb_under_panic bug
Date: Tue, 1 May 2012 17:08:08 +0000
Message-ID: <2A35EA60C3C77D438915767F458D65684817FFC9@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab2EARI2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:08:28 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've seen the following stack trace several times recently, and was wondering if anyone else has ran into this. This occurs during bi-directional TCP/UDP traffic (netperf) on multiple platforms/devices. Whatever is occurring also seems to invoke hdparm.  I'm running 3.4.0-rc4 (recent net-next pull) with CONFIG_PREEMPT=y:

skb_under_panic: text:ffffffff8130d538 len:120 put:14 head:ffff880128c89800 data:ffff880128c897f4 tail:0x6c end:0xc0 dev:eth0
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:145!
invalid opcode: 0000 [#1] PREEMPT SMP 
CPU 4 
Modules linked in: nfsd lockd exportfs sunrpc e1000e [last unloaded: scsi_wait_scan]

Pid: 5030, comm: netperf Not tainted 3.4.0-rc2-net-next-e1000e-queue_20120423 #2                  /DQ57TM
RIP: 0010:[<ffffffff812ef1b4>]  [<ffffffff812ef1b4>] skb_push+0x72/0x7b
RSP: 0018:ffff8801283459d8  EFLAGS: 00010292
RAX: 0000000000000084 RBX: ffff880127ffc000 RCX: 00000000fffffff3
RDX: 00000000000000d6 RSI: 0000000000000046 RDI: ffffffff8162375a
RBP: ffff8801283459f8 R08: 0000000000008d0a R09: ffff88012f019000
R10: 0000000000000001 R11: 0000000000000078 R12: ffff880128ff6ca0
R13: 0000000000000800 R14: 0000000000000212 R15: ffff880128ff6c98
FS:  00007fc4c3feb700(0000) GS:ffff88012fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffff600400 CR3: 0000000127e81000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process netperf (pid: 5030, threadinfo ffff880128344000, task ffff8801279859d0)
Stack:
000000000000006c 00000000000000c0 ffff880127ffc000 ffff880128ff6ca0
ffff880128345a38 ffffffff8130d538 ffff88010000006a 0000000000000000
ffffffff81300cd5 ffff88011dfad9c0 ffff880128ff6c00 ffff880127ffc000
Call Trace:
[<ffffffff8130d538>] eth_header+0x28/0xb4
[<ffffffff81300cd5>] ? neigh_resolve_output+0x14d/0x19a
[<ffffffff81300cd7>] neigh_resolve_output+0x14f/0x19a
[<ffffffff8131c35a>] ip_finish_output+0x22f/0x271
[<ffffffff8131c3d9>] ip_output+0x3d/0x3f
[<ffffffff81319dd4>] ip_local_out+0x62/0x64
[<ffffffff81319ddf>] ip_send_skb+0x9/0x2c
[<ffffffff81337a85>] udp_send_skb+0x250/0x2aa
[<ffffffff81338fa2>] udp_sendmsg+0x4e3/0x6f8
[<ffffffff8131b345>] ? ip_append_page+0x4b2/0x4b2
[<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
[<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
[<ffffffff8133f654>] inet_sendmsg+0x93/0x9c
[<ffffffff812e741d>] sock_sendmsg+0xbb/0xd4
[<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
[<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
[<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
[<ffffffff813a5516>] ? retint_kernel+0x26/0x30
[<ffffffff812e748f>] ? sockfd_lookup_light+0x1b/0x54
[<ffffffff812e7b3f>] sys_sendto+0xfa/0x122
[<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
[<ffffffff813a97a2>] system_call_fastpath+0x16/0x1b
Code: 8b 57 68 48 89 44 24 10 8b 87 b0 00 00 00 48 89 44 24 08 31 c0 8b bf ac 00 00 00 48 89 3c 24 48 c7 c7 b7 6d 4c 81 e8 26 37 0b 00 <0f> 0b eb fe 4c 89 c8 c9 c3 55 89 f1 48 89 e5 48 83 ec 20 4c 8b 
RIP  [<ffffffff812ef1b4>] skb_push+0x72/0x7b
RSP <ffff8801283459d8>
---[ end trace 35a690c4aebb4bd0 ]---
hdparm: sending ioctl 330 to a partition!
hdparm: sending ioctl 330 to a partition!
hdparm: sending ioctl 330 to a partition!
hdparm: sending ioctl 330 to a partition!

Thanks in advance,

Jeff Pieper
