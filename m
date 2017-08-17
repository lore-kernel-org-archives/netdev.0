From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] about net: Fix inconsistent teardown and release of private
 netdev state.
Date: Thu, 17 Aug 2017 15:30:40 -0700
Message-ID: <1503009040.4936.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34013 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753271AbdHQWan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 18:30:43 -0400
Received: by mail-pg0-f67.google.com with SMTP id y192so11880656pgd.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 15:30:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

If I read correctly this commit :
cf124db566e6b036b8bcbe8decbed740bdfac8c6
("net: Fix inconsistent teardown and release of private netdev state.")

We have problems in drivers providing priv_destructor
and handling a failure in register_netdevice()

register_netdevice() might have called ->priv_destructor()
or not.

So we do not really know if we need to clean up or not.

Any idea how to fix the issue ?

(syzkaller got double frees when kfree(tun->security) was attempted a
2nd time)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 19cbbbb1b63bbd74fcf7e74faf6541b3b7472b65..57d6b9aa3f64954d4d8350c46662ef3810209889 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2078,7 +2078,12 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
        return 0;
 
 err_detach:
+       /* register_netdevice() failed but called our priv_destructor
+        * (tun_free_netdev()). But maybe not :(
+        */
        tun_detach_all(dev);
+       goto err_free_dev;
+
 err_free_flow:
        tun_flow_uninit(tun);
        security_tun_dev_free_security(tun->security);



syzkaller trace :

BUG: KASAN: double-free or invalid-free in selinux_tun_dev_free_security+0x15/0x20 security/selinux/hooks.c:5023

CPU: 0 PID: 2919 Comm: syzkaller227220 Not tainted 4.13.0-rc4+ #23
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 print_address_description+0x7f/0x260 mm/kasan/report.c:252
 kasan_report_double_free+0x55/0x80 mm/kasan/report.c:333
 kasan_slab_free+0xa0/0xc0 mm/kasan/kasan.c:514
 __cache_free mm/slab.c:3503 [inline]
 kfree+0xd3/0x260 mm/slab.c:3820
 selinux_tun_dev_free_security+0x15/0x20 security/selinux/hooks.c:5023
 security_tun_dev_free_security+0x48/0x80 security/security.c:1512
 tun_set_iff drivers/net/tun.c:1884 [inline]
 __tun_chr_ioctl+0x2ce6/0x3d50 drivers/net/tun.c:2064
 tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2309
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x443ff9
RSP: 002b:00007ffc34271f68 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00000000004002e0 RCX: 0000000000443ff9
RDX: 0000000020533000 RSI: 00000000400454ca RDI: 0000000000000003
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000217 R12: 0000000000401ce0
R13: 0000000000401d70 R14: 0000000000000000 R15: 0000000000000000

Allocated by task 2919:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:551
 kmem_cache_alloc_trace+0x101/0x6f0 mm/slab.c:3627
 kmalloc include/linux/slab.h:493 [inline]
 kzalloc include/linux/slab.h:666 [inline]
 selinux_tun_dev_alloc_security+0x49/0x170 security/selinux/hooks.c:5012
 security_tun_dev_alloc_security+0x6d/0xa0 security/security.c:1506
 tun_set_iff drivers/net/tun.c:1839 [inline]
 __tun_chr_ioctl+0x1730/0x3d50 drivers/net/tun.c:2064
 tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2309
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe

Freed by task 2919:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_slab_free+0x6e/0xc0 mm/kasan/kasan.c:524
 __cache_free mm/slab.c:3503 [inline]
 kfree+0xd3/0x260 mm/slab.c:3820
 selinux_tun_dev_free_security+0x15/0x20 security/selinux/hooks.c:5023
 security_tun_dev_free_security+0x48/0x80 security/security.c:1512
 tun_free_netdev+0x13b/0x1b0 drivers/net/tun.c:1563
 register_netdevice+0x8d0/0xee0 net/core/dev.c:7605
 tun_set_iff drivers/net/tun.c:1859 [inline]
 __tun_chr_ioctl+0x1caf/0x3d50 drivers/net/tun.c:2064
 tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2309
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe

The buggy address belongs to the object at ffff8801d2843b40
 which belongs to the cache kmalloc-32 of size 32
The buggy address is located 0 bytes inside of
 32-byte region [ffff8801d2843b40, ffff8801d2843b60)
The buggy address belongs to the page:
page:ffffea000660cea8 count:1 mapcount:0 mapping:ffff8801d2843000 index:0xffff8801d2843fc1
flags: 0x200000000000100(slab)
raw: 0200000000000100 ffff8801d2843000 ffff8801d2843fc1 000000010000003f
raw: ffffea0006626a40 ffffea00066141a0 ffff8801dbc00100
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff8801d2843a00: fb fb fb fb fc fc fc fc fb fb fb fb fc fc fc fc
 ffff8801d2843a80: 00 00 00 fc fc fc fc fc fb fb fb fb fc fc fc fc
>ffff8801d2843b00: 00 00 00 00 fc fc fc fc fb fb fb fb fc fc fc fc
                                           ^
 ffff8801d2843b80: fb fb fb fb fc fc fc fc fb fb fb fb fc fc fc fc
 ffff8801d2843c00: fb fb fb fb fc fc fc fc fb fb fb fb fc fc fc fc
==================================================================
