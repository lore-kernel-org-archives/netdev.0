From: David Ahern <dsa@cumulusnetworks.com>
Subject: panic in __inet_hash
Date: Wed, 6 Apr 2016 18:02:26 -0600
Message-ID: <5705A392.2000207@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37005 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbcDGAC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 20:02:29 -0400
Received: by mail-ig0-f173.google.com with SMTP id g8so56629223igr.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 17:02:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rebased to top of tree a few minutes ago to test v6 of the multipath 
patch. I hitting a panic in __inet_hash:

[   17.264247] BUG: unable to handle kernel paging request at 
ffffffffffffffa8
[   17.265015] IP: [<ffffffff816e2b3c>] __inet_hash+0x11c/0x1c0
[   17.265015] PGD 1e07067 PUD 1e09067 PMD 0
[   17.265015] Oops: 0000 [#1] SMP
[   17.265015] Modules linked in:
[   17.265015] CPU: 0 PID: 1488 Comm: zebra Not tainted 4.6.0-rc1+ #5
[   17.265015] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 
04/01/2014
[   17.265015] task: ffff880011010800 ti: ffff880017bb0000 task.ti: 
ffff880017bb0000
[   17.265015] RIP: 0010:[<ffffffff816e2b3c>]  [<ffffffff816e2b3c>] 
__inet_hash+0x11c/0x1c0
[   17.265015] RSP: 0018:ffff880017bb3e48  EFLAGS: 00010293
[   17.265015] RAX: 0000000000000002 RBX: 0000000000000004 RCX: 
0000000000000002
[   17.265015] RDX: 0000000000000000 RSI: ffff880011010fa0 RDI: 
ffff880011010800
[   17.265015] RBP: ffff880017bb3e88 R08: ffffffff8282b080 R09: 
ffffffffffffff98
[   17.265015] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffffffff82ea80c0
[   17.265015] R13: ffffffff82ea7f80 R14: 0000000000000000 R15: 
ffff88001b618000
[   17.265015] FS:  00007f947df9d740(0000) GS:ffff88001fc00000(0000) 
knlGS:0000000000000000
[   17.265015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   17.265015] CR2: ffffffffffffffa8 CR3: 00000000179d7000 CR4: 
00000000000006f0
[   17.265015] Stack:
[   17.265015]  ffffffff82e95150 0000006e00000005 ffffffff8170b540 
ffff88001b618000
[   17.265015]  0000000000000000 0000000000000003 0000000000000000 
00000000ffffffff
[   17.265015]  ffff880017bb3ea0 ffffffff816e2c19 ffff88001b618000 
ffff880017bb3ec0
[   17.265015] Call Trace:
[   17.265015]  [<ffffffff8170b540>] ? udp4_seq_show+0x150/0x150
[   17.265015]  [<ffffffff816e2c19>] inet_hash+0x39/0x60
[   17.265015]  [<ffffffff816e44dd>] inet_csk_listen_start+0x9d/0xc0
[   17.265015]  [<ffffffff81719c2c>] inet_listen+0x9c/0xe0
[   17.265015]  [<ffffffff8166b5ae>] SyS_listen+0x4e/0x80
[   17.265015]  [<ffffffff81002eac>] do_syscall_64+0x5c/0x2b0
[   17.265015]  [<ffffffff8181829a>] entry_SYSCALL64_slow_path+0x25/0x25
[   17.265015] Code: 4b 54 9e ff 41 f6 c6 01 74 13 e9 88 00 00 00 4d 8b 
36 e8 38 54 9e ff 41 f6 c6 01 75 7a 4d 8d 4e 98 4d 39 cf 74 e9 41 0f b7 
47 10 <66> 41 39 46 a8 75 dd 41 0f b6 46 ab 89 c2 41 32 57 13 83 e2 20
[   17.265015] RIP  [<ffffffff816e2b3c>] __inet_hash+0x11c/0x1c0
[   17.265015]  RSP <ffff880017bb3e48>
[   17.265015] CR2: ffffffffffffffa8
[   17.265015] ---[ end trace d7340320507851f4 ]---



git bisect points to:
dsa@kenny:~/kernel-2.git$ git bisect bad
3b24d854cb35383c30642116e5992fd619bdc9bc is the first bad commit
commit 3b24d854cb35383c30642116e5992fd619bdc9bc
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Apr 1 08:52:17 2016 -0700

     tcp/dccp: do not touch listener sk_refcnt under synflood

     When a SYNFLOOD targets a non SO_REUSEPORT listener, multiple
     cpus contend on sk->sk_refcnt and sk->sk_wmem_alloc changes.

     By letting listeners use SOCK_RCU_FREE infrastructure,
     we can relax TCP_LISTEN lookup rules and avoid touching sk_refcnt

     Note that we still use SLAB_DESTROY_BY_RCU rules for other sockets,
     only listeners are impacted by this change.

     Peak performance under SYNFLOOD is increased by ~33% :

     On my test machine, I could process 3.2 Mpps instead of 2.4 Mpps

     Most consuming functions are now skb_set_owner_w() and sock_wfree()
     contending on sk->sk_wmem_alloc when cooking SYNACK and freeing them.

     Signed-off-by: Eric Dumazet <edumazet@google.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 77d3f9ba3c3ec4c3443416f7536fe6d3ee9ec1a1 
b797845f7bbad79b5875bfa969ebfe9759c0b8b9 M	include
:040000 040000 0325378c93011f87012e5a6c064b09c2d59e052b 
32f90a3ec258f4625765c33d4718b2370e69e862 M	net
