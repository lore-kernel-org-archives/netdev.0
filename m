From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ax25: don't free pointers to statically allocated data
Date: Tue, 14 Aug 2007 23:30:38 +0400
Message-ID: <20070814193038.GA5873@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: akpm@osdl.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:14791 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759993AbXHNTan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 15:30:43 -0400
Received: by el-out-1112.google.com with SMTP id j27so341622elf
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 12:30:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8d5cf596d10d740b69b5f4bbdb54b85abf75810d started to add statically
allocated ax25_protocol's to list. However kfree() was still in place waiting
for unsuspecting ones on module removal.

Steps to reproduce:

	modprobe netrom
	rmmod netrom

P.S.: code would benefit greatly from list_add/list_del usage

kernel BUG at mm/slab.c:592!
invalid opcode: 0000 [1] PREEMPT SMP 
CPU 0 
Modules linked in: netrom ax25 af_packet usbcore rtc_cmos rtc_core rtc_lib
Pid: 4477, comm: rmmod Not tainted 2.6.23-rc3-bloat #2
RIP: 0010:[<ffffffff802ac646>]  [<ffffffff802ac646>] kfree+0x1c6/0x260
RSP: 0000:ffff810079a05e48  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff81000000c000
RDX: ffff81007e552458 RSI: 0000000000000000 RDI: 000000000000805d
RBP: ffff810079a05e88 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffffffff8805d080
R13: ffffffff8805d080 R14: 0000000000000000 R15: 0000000000000282
FS:  00002b73fc98aae0(0000) GS:ffffffff805dc000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000053f3b8 CR3: 0000000079ff2000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rmmod (pid: 4477, threadinfo ffff810079a04000, task ffff8100775aa480)
Stack:  ffff810079a05e68 0000000000000246 ffffffff8804eca0 0000000000000000
 ffffffff8805d080 00000000000000cf 0000000000000000 0000000000000880
 ffff810079a05eb8 ffffffff8803ec90 ffff810079a05eb8 0000000000000000
Call Trace:
 [<ffffffff8803ec90>] :ax25:ax25_protocol_release+0xa0/0xb0
 [<ffffffff88056ecb>] :netrom:nr_exit+0x6b/0xf0
 [<ffffffff80268bf0>] sys_delete_module+0x170/0x1f0
 [<ffffffff8025da35>] trace_hardirqs_on+0xd5/0x170
 [<ffffffff804835aa>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff8020c13e>] system_call+0x7e/0x83


Code: 0f 0b eb fe 66 66 90 66 66 90 48 8b 52 10 48 8b 02 25 00 40 
RIP  [<ffffffff802ac646>] kfree+0x1c6/0x260
 RSP <ffff810079a05e48>
Kernel panic - not syncing: Fatal exception

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ax25/ax25_iface.c |    2 --
 1 file changed, 2 deletions(-)

--- a/net/ax25/ax25_iface.c
+++ b/net/ax25/ax25_iface.c
@@ -69,7 +69,6 @@ void ax25_protocol_release(unsigned int pid)
 	if (protocol->pid == pid) {
 		protocol_list = protocol->next;
 		write_unlock_bh(&protocol_list_lock);
-		kfree(protocol);
 		return;
 	}
 
@@ -78,7 +77,6 @@ void ax25_protocol_release(unsigned int pid)
 			s = protocol->next;
 			protocol->next = protocol->next->next;
 			write_unlock_bh(&protocol_list_lock);
-			kfree(s);
 			return;
 		}
 

