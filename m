From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195807] New: general protection fault in ping_v4_sendmsg
Date: Thu, 18 May 2017 07:51:48 -0700
Message-ID: <20170518075148.27ffb243@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34321 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756536AbdEROv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:51:57 -0400
Received: by mail-pf0-f177.google.com with SMTP id 9so25045417pfj.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 07:51:57 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id 63sm13538256pfg.35.2017.05.18.07.51.56
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 May 2017 07:51:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 18 May 2017 03:36:33 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195807] New: general protection fault in ping_v4_sendmsg


https://bugzilla.kernel.org/show_bug.cgi?id=195807

            Bug ID: 195807
           Summary: general protection fault in ping_v4_sendmsg
           Product: Networking
           Version: 2.5
    Kernel Version: 4.4 to 4.10-rc7
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: youwei@ruc.edu.cn
        Regression: No

Created attachment 256607
  --> https://bugzilla.kernel.org/attachment.cgi?id=256607&action=edit  
poc and kernel config

I got a general protection fault (use after free) when fuzzing the bpf system
call.
Attached is the PoC that can reproduce this issue in kernel version from 4.4 to
4.10-rc7.

Following is the dmesg output when executing the PoC on kernel version 4.10-rc7
[   32.949367] kasan: CONFIG_KASAN_INLINE enabled
[   32.949915] kasan: GPF could be caused by NULL-ptr deref or user memory
access
[   32.950602] general protection fault: 0000 [#1] SMP KASAN
[   32.951089] Dumping ftrace buffer:
[   32.951396]    (ftrace buffer empty)
[   32.951579] Modules linked in:
[   32.951579] CPU: 0 PID: 4145 Comm: poc-NB1 Not tainted 4.10.0-rc7 #1
[   32.951579] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
[   32.951579] task: ffff880064f51bc0 task.stack: ffff880056568000
[   32.951579] RIP: 0010:ping_v4_sendmsg+0xcbd/0x1240
[   32.951579] RSP: 0018:ffff88005656f9b8 EFLAGS: 00010206
[   32.951579] RAX: dffffc0000000000 RBX: ffff88005656fc20 RCX:
1ffff1000a9ad033
[   32.951579] RDX: 0000000000000018 RSI: 0000000000000008 RDI:
00000000000000c2
[   32.951579] RBP: ffff88005656fc48 R08: 0000000000000008 R09:
0000000000000000
[   32.951579] R10: 000000000100007f R11: 0000000000000000 R12:
ffff880054d68040
[   32.951579] R13: 0000000000000000 R14: ffff88005656fb40 R15:
ffff88005656fac0
[   32.951579] FS:  00007fc22df907c0(0000) GS:ffff88006ca00000(0000)
knlGS:0000000000000000
[   32.951579] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   32.951579] CR2: 0000000020007000 CR3: 00000000656e0000 CR4:
00000000000006f0
[   32.951579] Call Trace:
[   32.951579]  ? ping_queue_rcv_skb+0x60/0x60
[   32.951579]  ? depot_save_stack+0x133/0x4a0
[   32.951579]  ? save_stack+0xb1/0xd0
[   32.951579]  ? save_stack_trace+0x16/0x20
[   32.951579]  ? save_stack+0x46/0xd0
[   32.951579]  ? __anon_vma_prepare+0x30e/0x570
[   32.951579]  ? handle_mm_fault+0xdb0/0x1e30
[   32.951579]  ? __do_page_fault+0x5b9/0xc50
[   32.951579]  ? do_page_fault+0x2a/0x30
[   32.951579]  ? page_fault+0x22/0x30
[   32.951579]  ? ip4_datagram_release_cb+0xf3/0x6e0
[   32.951579]  ? _raw_write_unlock_bh+0x3c/0x50
[   32.951579]  ? ping_get_port+0x37d/0x5e0
[   32.951579]  ? _raw_spin_unlock_bh+0x3c/0x50
[   32.951579]  ? release_sock+0x194/0x1d0
[   32.951579]  inet_sendmsg+0x141/0x3e0
[   32.951579]  ? inet_recvmsg+0x430/0x430
[   32.951579]  sock_sendmsg+0xde/0x120
[   32.951579]  SYSC_sendto+0x23f/0x3a0
[   32.951579]  ? SYSC_connect+0x320/0x320
[   32.951579]  ? __page_set_anon_rmap+0x1cc/0x2b0
[   32.951579]  ? __lru_cache_add+0x114/0x1a0
[   32.951579]  ? handle_mm_fault+0x6ff/0x1e30
[   32.951579]  ? get_unused_fd_flags+0xd0/0xd0
[   32.951579]  ? find_vma+0x3f/0x190
[   32.951579]  ? __do_page_fault+0x3ae/0xc50
[   32.951579]  SyS_sendto+0x4a/0x60
[   32.951579]  entry_SYSCALL_64_fastpath+0x13/0x94
[   32.951579] RIP: 0033:0x7fc22dac6b79
[   32.951579] RSP: 002b:00007ffc4ecef988 EFLAGS: 00000206 ORIG_RAX:
000000000000002c
[   32.951579] RAX: ffffffffffffffda RBX: 0000000000000000 RCX:
00007fc22dac6b79
[   32.951579] RDX: 0000000000000008 RSI: 0000000020004ff5 RDI:
0000000000000003
[   32.951579] RBP: 00007ffc4ecefa00 R08: 0000000020007000 R09:
0000000000000010
[   32.951579] R10: 400000000000083c R11: 0000000000000206 R12:
0000000000400b20
[   32.951579] R13: 00007ffc4ecefb30 R14: 0000000000000000 R15:
0000000000000000
[   32.951579] Code: ff c1 e2 10 66 31 c0 01 d0 15 ff ff 00 00 f7 d0 48 89 fa
c1 e8 10 48 c1 ea 03 66 89 83 a2 fe ff ff 48 b8 00 00 00 00 00 fc ff df <0f> b6
14 02 48 89 f8 83 e0 07 83 c0 01 38 d0 7c 08 84 d2 0f 85
[   32.951579] RIP: ping_v4_sendmsg+0xcbd/0x1240 RSP: ffff88005656f9b8
[   32.978078] ---[ end trace 3d206c2ba5fde6a4 ]---
[   32.978505] Kernel panic - not syncing: Fatal exception
[   32.979052] Dumping ftrace buffer:
[   32.979052]    (ftrace buffer empty)
[   32.979052] Kernel Offset: disabled
[   32.979052] Rebooting in 86400 seconds..

-- 
You are receiving this mail because:
You are the assignee for the bug.
