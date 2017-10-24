From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: general protection fault in __list_del_entry_valid
Date: Tue, 24 Oct 2017 17:02:29 +0200
Message-ID: <CACT4Y+ZFWVLJ_TKw7RKAsybK8vBSpYhpmS=ObSSKn3s5azxn-Q@mail.gmail.com>
References: <f403043cb57c0ee302055c4c2e3c@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        syzkaller-bugs@googlegroups.com
To: syzbot
        <bot+b3b21cb3f2c95ba434f66810d52abd04c99b877e@syzkaller.appspotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:52615 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdJXPCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 11:02:51 -0400
Received: by mail-it0-f47.google.com with SMTP id j140so10425989itj.1
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 08:02:51 -0700 (PDT)
In-Reply-To: <f403043cb57c0ee302055c4c2e3c@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 4:59 PM, syzbot
<bot+b3b21cb3f2c95ba434f66810d52abd04c99b877e@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> aa69ff9e9c32db8aa84835baffea1b70c39e5112
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers

This also happened on more recent commits, including net-next
33ad61d0f799656e8987e9c80e6e15151bb857f3 (Oct 20), with similar
signature:

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 17 Comm: kworker/1:0 Not tainted 4.14.0-rc5+ #89
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Workqueue: events netlink_sock_destruct_work
task: ffff8801d9f94480 task.stack: ffff8801d9fa0000
RIP: 0010:__list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51
RSP: 0018:ffff8801d9fa70b8 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8801cb186b60 RDI: ffff8801cb186b68
RBP: ffff8801d9fa70d0 R08: ffffffff84248f02 R09: 0000000000000000
R10: ffff8801d9fa6f98 R11: ffff8801ca127a10 R12: 0000000000000000
R13: ffff8801d9fa7198 R14: ffff8801ca1279f8 R15: ffff8801cb186b68
FS:  0000000000000000(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020000000 CR3: 00000001c17a4000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 __list_del_entry include/linux/list.h:116 [inline]
 list_del include/linux/list.h:124 [inline]
 xfrm_policy_walk_done+0xfa/0x310 net/xfrm/xfrm_policy.c:1048
 xfrm_dump_policy_done+0x73/0xa0 net/xfrm/xfrm_user.c:1699
 netlink_sock_destruct+0xfa/0x3c0 net/netlink/af_netlink.c:362
 __sk_destruct+0xfd/0x910 net/core/sock.c:1560
 sk_destruct+0x47/0x80 net/core/sock.c:1595
 __sk_free+0x57/0x230 net/core/sock.c:1603
 sk_free+0x2a/0x40 net/core/sock.c:1614
 netlink_sock_destruct_work+0x19/0x20 net/netlink/af_netlink.c:384
 process_one_work+0xbf0/0x1bc0 kernel/workqueue.c:2119
 worker_thread+0x223/0x1860 kernel/workqueue.c:2253
 kthread+0x35e/0x430 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
Code: 00 00 00 00 ad de 49 39 c4 74 66 48 b8 00 02 00 00 00 00 ad de
48 89 da 48 39 c3 74 65 48 c1 ea 03 48 b8 00 00 00 00 00 fc ff df <80>
3c 02 00 75 7b 48 8b 13 48 39 f2 75 57 49 8d 7c 24 08 48 b8
RIP: __list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51 RSP: ffff8801d9fa70b8
---[ end trace 09c8fe297bb23e1f ]---


> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2922 comm=syzkaller860091
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2923 comm=syzkaller860091
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2924 comm=syzkaller860091
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 23 Comm: kworker/0:1 Not tainted 4.13.0-rc4+ #2
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Workqueue: events netlink_sock_destruct_work
> task: ffff8801da882600 task.stack: ffff8801da878000
> RIP: 0010:__list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51
> RSP: 0018:ffff8801da87f0b8 EFLAGS: 00010246
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff8801d198f1a0 RDI: ffff8801d198f1a8
> RBP: ffff8801da87f0d0 R08: ffffffff8630d808 R09: ffff8801da87ea18
> R10: ffff8801da87ef98 R11: 1ffff1003b51071b R12: 0000000000000000
> R13: ffff8801da87f198 R14: ffffffff855864b8 R15: ffff8801d198f1a8
> FS:  0000000000000000(0000) GS:ffff8801dc000000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007ffe339a7b84 CR3: 00000001d0304000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  __list_del_entry include/linux/list.h:116 [inline]
>  list_del include/linux/list.h:124 [inline]
>  xfrm_policy_walk_done+0xfa/0x310 net/xfrm/xfrm_policy.c:1049
>  xfrm_dump_policy_done+0x73/0xa0 net/xfrm/xfrm_user.c:1690
>  netlink_sock_destruct+0xfa/0x3c0 net/netlink/af_netlink.c:362
>  __sk_destruct+0xfd/0x910 net/core/sock.c:1570
>  sk_destruct+0x47/0x80 net/core/sock.c:1605
>  __sk_free+0x57/0x230 net/core/sock.c:1613
>  sk_free+0x2a/0x40 net/core/sock.c:1624
>  netlink_sock_destruct_work+0x19/0x20 net/netlink/af_netlink.c:384
>  process_one_work+0xbf3/0x1bc0 kernel/workqueue.c:2097
>  worker_thread+0x223/0x1860 kernel/workqueue.c:2231
>  kthread+0x35e/0x430 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:425
> Code: 00 00 00 00 ad de 49 39 c4 74 66 48 b8 00 02 00 00 00 00 ad de 48 89
> da 48 39 c3 74 65 48 c1 ea 03 48 b8 00 00 00 00 00 fc ff df <80> 3c 02 00 75
> 7b 48 8b 13 48 39 f2 75 57 49 8d 7c 24 08 48 b8
> RIP: __list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51 RSP:
> ffff8801da87f0b8
> ---[ end trace d2378690210613a6 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2925 comm=syzkaller860091
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2926 comm=syzkaller860091
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2927 comm=syzkaller860091
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2928 comm=syzkaller860091
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2929 comm=syzkaller860091
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=65535
> sclass=netlink_xfrm_socket pig=2930 comm=syzkaller860091
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/f403043cb57c0ee302055c4c2e3c%40google.com.
> For more options, visit https://groups.google.com/d/optout.
