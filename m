From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: [BUG] NULL pointer dereference in skb_dequeue
Date: Fri, 1 Aug 2008 16:40:04 -0700
Message-ID: <9929d2390808011640o58453023s623faa8930064505@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Emil Tantilov" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:23442 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbYHAXkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 19:40:05 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1763824wfd.4
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2008 16:40:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to change the MTU size during traffic, we get a kernel
panic with the latest net-2.6 tree.

Steps to reproduce:

1. Load the driver, bring network up.
2. Start traffic (in my case on all 4 ports mixed TCP/UDP IPv4/6).
3. Reset the port (ethtool -r) or change the MTU (ifconfig eth0 mtu 9216)

NOTES:
ethtool -r doesn't always panic, you may have to do it multiple times.
Changing MTU seems to always trigger the panic.

Here is the kernel trace:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff8047b8f3>] __skb_dequeue+0x2d/0x35
PGD 0
Oops: 0002 [1] SMP
CPU 2
Modules linked in: igb nfsd lockd exportfs sunrpc pci_slot inet_lro
[last unloaded: igb]
Pid: 13, comm: events/2 Not tainted 2.6.27-rc1-igb #1
RIP: 0010:[<ffffffff8047b8f3>]  [<ffffffff8047b8f3>] __skb_dequeue+0x2d/0x35
RSP: 0018:ffff8801af949de8  EFLAGS: 00010202
RAX: ffff8801af92e8f8 RBX: ffff8801af92e8f8 RCX: ffff88019b4f3280
RDX: 0000000000000000 RSI: ffff88019e1c6cc0 RDI: ffff8801af92e8f8
RBP: ffff8801af92e800 R08: 0000000000000000 R09: ffff880028055be0
R10: ffff88019e1c6cc0 R11: ffffffff8047bab5 R12: ffff8801abdd2440
R13: ffffffff80671500 R14: ffffffff806bb200 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801af8686c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000019b522000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process events/2 (pid: 13, threadinfo ffff8801af948000, task ffff8801af947710)
Stack:  ffffffff8047bad4 00000000ffffc553 ffff8801af92e85c ffff8801af92e800
 ffffffff8047bbbb 0000000000000000 ffff88019e1f0000 0000000000000004
 ffffffff80671500 ffffffff8047bb89 ffffffff8047b928 0000000000000000
Call Trace:
 [<ffffffff8047bad4>] ? pfifo_fast_reset+0x1f/0x4c
 [<ffffffff8047bbbb>] ? dev_deactivate_queue+0x32/0x4a
 [<ffffffff8047bb89>] ? dev_deactivate_queue+0x0/0x4a
 [<ffffffff8047b928>] ? netdev_for_each_tx_queue+0x2d/0x42
 [<ffffffff8047bf3e>] ? dev_deactivate+0x17/0xb1
 [<ffffffff80477d0b>] ? __linkwatch_run_queue+0x149/0x184
 [<ffffffff80477d46>] ? linkwatch_event+0x0/0x30
 [<ffffffff80477d70>] ? linkwatch_event+0x2a/0x30
 [<ffffffff8023eaeb>] ? run_workqueue+0x81/0x10a
 [<ffffffff8023f3e7>] ? worker_thread+0xd3/0xde
 [<ffffffff80241bbe>] ? autoremove_wake_function+0x0/0x2e
 [<ffffffff8023f314>] ? worker_thread+0x0/0xde
 [<ffffffff80241a57>] ? kthread+0x47/0x74
 [<ffffffff8022c410>] ? schedule_tail+0x28/0x60
 [<ffffffff8020c229>] ? child_rip+0xa/0x11
 [<ffffffff80241a10>] ? kthread+0x0/0x74
 [<ffffffff8020c21f>] ? child_rip+0x0/0x11


Code: 0f 48 39 f9 75 04 31 c9 eb 25 48 85 c9 74 20 ff 4f 10 48 8b 11
48 8b 41 08 48 c7 01 00 00 00 00 48 c7 41 08 00 00 00 00 48 89 10 <48>
89 42 08 48 89 c8 c3 41 55 49 89 f5 41 54 49 89 d4 55 31 ed
RIP  [<ffffffff8047b8f3>] __skb_dequeue+0x2d/0x35
 RSP <ffff8801af949de8>
CR2: 0000000000000008
---[ end trace 01618db2121afa07 ]---


-- 
Cheers,
Jeff
