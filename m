From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: net/l2tp:BUG: KASAN: use-after-free in l2tp_ip6_close
Date: Wed, 16 Nov 2016 17:30:21 +0100
Message-ID: <20161116163021.tblhptv37r6byjvp@alphalink.fr>
References: <33b1f154-3f9a-55b6-63d3-cd28c0524ea6@gmail.com>
 <CAM_iQpWpf--gXPy7zD7ax4vt-foMCh_dw8Pbb3=y_gSgegeF3Q@mail.gmail.com>
 <76f028b3-cf56-5526-352f-ff4826933779@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:45180 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753320AbcKPQa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:30:27 -0500
Content-Disposition: inline
In-Reply-To: <76f028b3-cf56-5526-352f-ff4826933779@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 10:52:03PM +0800, Baozeng Ding wrote:
> This use-after-free seems to be triggered by some race. I use stress tool for this: 
> https://github.com/golang/tools/blob/master/cmd/stress/stress.go 
> If you have Go toolchain installed, then the following will do: 
> $ go get golang.org/x/tools/cmd/stress 
> $ stress ./a.out
> 
> =========================================================================
> #include <unistd.h>
> #include <stdint.h>
> #include <pthread.h>
> #include <stdio.h>
> #include <sys/socket.h>
> #include <linux/l2tp.h>
> 
> int fd;
> struct sockaddr_l2tpip sock_addr = {
>         .l2tp_family = AF_INET,
>         .l2tp_unused = 0,
>         .l2tp_addr = 0,
>         .l2tp_conn_id = 8,
>         .__pad = 0
> 
> };
> 
> void *thr(void *arg)
> {
>         switch ((long)arg) {
>         case 0:
>                 fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_L2TP);
>                 break;
>         case 1:
>                 bind(fd, (struct sockaddr*) &sock_addr, 0x10ul);
>                 break;
>         case 2:
>                 bind(fd, (struct sockaddr*)&sock_addr, 0x10ul);
>                 break;
>         case 3:
>                 connect(fd, (struct sockaddr*)&sock_addr, 0x10ul);
>                 break;
>         }
>         return 0;
> }
> 
> int main()
> {
>         long i;
>         pthread_t th[4];
>         int n;
>         for (i = 0; i < 4; i++) {
>                pthread_create(&th[i], 0, thr, (void*)i);
>                usleep(10000);
>         }
>         for (i = 0; i < 4; i++) {
>                pthread_create(&th[i], 0, thr, (void*)i);
>                if (i%2==0)
>                         usleep(10000);
>         }
>         usleep(100000);
>         return 0;
> }
> 
This program targets l2tp_ip while the call trace is about l2tp_ip6. But it
looks like we have the same issue in both modules anyway.

> On 2016/10/17 3:50, Cong Wang wrote:
> > On Sun, Oct 16, 2016 at 8:07 AM, Baozeng Ding <sploving1@gmail.com> wrote:
> >> Hello,
> >> While running syzkaller fuzzer I have got the following use-after-free
> >> bug in l2tp_ip6_close. The kernel version is 4.8.0+ (on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0).
> >>
> >> BUG: KASAN: use-after-free in l2tp_ip6_close+0x22e/0x290 at addr ffff8800081b0ed8
> >> Write of size 8 by task syz-executor/10987
> >> CPU: 0 PID: 10987 Comm: syz-executor Not tainted 4.8.0+ #39
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
> >>  ffff880031d97838 ffffffff829f835b ffff88001b5a1640 ffff8800081b0ec0
> >>  ffff8800081b15a0 ffff8800081b6d20 ffff880031d97860 ffffffff8174d3cc
> >>  ffff880031d978f0 ffff8800081b0e80 ffff88001b5a1640 ffff880031d978e0
> >> Call Trace:
> >>  [<ffffffff829f835b>] dump_stack+0xb3/0x118 lib/dump_stack.c:15
> >>  [<ffffffff8174d3cc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
> >>  [<     inline     >] print_address_description mm/kasan/report.c:194
> >>  [<ffffffff8174d666>] kasan_report_error+0x1f6/0x4d0 mm/kasan/report.c:283
> >>  [<     inline     >] kasan_report mm/kasan/report.c:303
> >>  [<ffffffff8174db7e>] __asan_report_store8_noabort+0x3e/0x40 mm/kasan/report.c:329
> >>  [<     inline     >] __write_once_size ./include/linux/compiler.h:249
> >>  [<     inline     >] __hlist_del ./include/linux/list.h:622
> >>  [<     inline     >] hlist_del_init ./include/linux/list.h:637
> >>  [<ffffffff8579047e>] l2tp_ip6_close+0x22e/0x290 net/l2tp/l2tp_ip6.c:239
> > 
> > 
> > This one looks pretty interesting, how the hell could we call ____fput() twice
> > on the same fd...
> > 
> > 
> >>  [<ffffffff850b2dfd>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:415
> >>  [<ffffffff851dc5a0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
> >>  [<ffffffff84c4581d>] sock_release+0x8d/0x1d0 net/socket.c:570
> >>  [<ffffffff84c45976>] sock_close+0x16/0x20 net/socket.c:1017
> >>  [<ffffffff817a108c>] __fput+0x28c/0x780 fs/file_table.c:208
> >>  [<ffffffff817a1605>] ____fput+0x15/0x20 fs/file_table.c:244
> >>  [<ffffffff813774f9>] task_work_run+0xf9/0x170
> >>  [<ffffffff81324aae>] do_exit+0x85e/0x2a00
> >>  [<ffffffff81326dc8>] do_group_exit+0x108/0x330
> >>  [<ffffffff81348cf7>] get_signal+0x617/0x17a0 kernel/signal.c:2307
> >>  [<ffffffff811b49af>] do_signal+0x7f/0x18f0
> >>  [<ffffffff810039bf>] exit_to_usermode_loop+0xbf/0x150 arch/x86/entry/common.c:156
> >>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
> >>  [<ffffffff81006060>] syscall_return_slowpath+0x1a0/0x1e0 arch/x86/entry/common.c:259
> >>  [<ffffffff85e4d726>] entry_SYSCALL_64_fastpath+0xc4/0xc6
> >> Object at ffff8800081b0ec0, in cache L2TP/IPv6 size: 1448
> >> Allocated:
> >> PID = 10987
> >>  [ 1116.897025] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
> >>  [ 1116.897025] [<ffffffff8174c736>] save_stack+0x46/0xd0
> >>  [ 1116.897025] [<ffffffff8174c9ad>] kasan_kmalloc+0xad/0xe0
> >>  [ 1116.897025] [<ffffffff8174cee2>] kasan_slab_alloc+0x12/0x20
> >>  [ 1116.897025] [<     inline     >] slab_post_alloc_hook mm/slab.h:417
> >>  [ 1116.897025] [<     inline     >] slab_alloc_node mm/slub.c:2708
> >>  [ 1116.897025] [<     inline     >] slab_alloc mm/slub.c:2716
> >>  [ 1116.897025] [<ffffffff817476a8>] kmem_cache_alloc+0xc8/0x2b0 mm/slub.c:2721
> >>  [ 1116.897025] [<ffffffff84c4f6a9>] sk_prot_alloc+0x69/0x2b0 net/core/sock.c:1326
> >>  [ 1116.897025] [<ffffffff84c58ac8>] sk_alloc+0x38/0xae0 net/core/sock.c:1388
> >>  [ 1116.897025] [<ffffffff851ddf67>] inet6_create+0x2d7/0x1000 net/ipv6/af_inet6.c:182
> >>  [ 1116.897025] [<ffffffff84c4af7b>] __sock_create+0x37b/0x640 net/socket.c:1153
> >>  [ 1116.897025] [<     inline     >] sock_create net/socket.c:1193
> >>  [ 1116.897025] [<     inline     >] SYSC_socket net/socket.c:1223
> >>  [ 1116.897025] [<ffffffff84c4b46f>] SyS_socket+0xef/0x1b0 net/socket.c:1203
> >>  [ 1116.897025] [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6
> >> Freed:
> >> PID = 10987
> >>  [ 1116.897025] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
> >>  [ 1116.897025] [<ffffffff8174c736>] save_stack+0x46/0xd0
> >>  [ 1116.897025] [<ffffffff8174cf61>] kasan_slab_free+0x71/0xb0
> >>  [ 1116.897025] [<     inline     >] slab_free_hook mm/slub.c:1352
> >>  [ 1116.897025] [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
> >>  [ 1116.897025] [<     inline     >] slab_free mm/slub.c:2951
> >>  [ 1116.897025] [<ffffffff81748b28>] kmem_cache_free+0xc8/0x330 mm/slub.c:2973
> >>  [ 1116.897025] [<     inline     >] sk_prot_free net/core/sock.c:1369
> >>  [ 1116.897025] [<ffffffff84c541eb>] __sk_destruct+0x32b/0x4f0 net/core/sock.c:1444
> >>  [ 1116.897025] [<ffffffff84c5aca4>] sk_destruct+0x44/0x80 net/core/sock.c:1452
> >>  [ 1116.897025] [<ffffffff84c5ad33>] __sk_free+0x53/0x220 net/core/sock.c:1460
> >>  [ 1116.897025] [<ffffffff84c5af23>] sk_free+0x23/0x30 net/core/sock.c:1471
> >>  [ 1116.897025] [<ffffffff84c5cb6c>] sk_common_release+0x28c/0x3e0 ./include/net/sock.h:1589
> >>  [ 1116.897025] [<ffffffff8579044e>] l2tp_ip6_close+0x1fe/0x290 net/l2tp/l2tp_ip6.c:243
> >>  [ 1116.897025] [<ffffffff850b2dfd>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:415
> >>  [ 1116.897025] [<ffffffff851dc5a0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
> >>  [ 1116.897025] [<ffffffff84c4581d>] sock_release+0x8d/0x1d0 net/socket.c:570
> >>  [ 1116.897025] [<ffffffff84c45976>] sock_close+0x16/0x20 net/socket.c:1017
> >>  [ 1116.897025] [<ffffffff817a108c>] __fput+0x28c/0x780 fs/file_table.c:208
> >>  [ 1116.897025] [<ffffffff817a1605>] ____fput+0x15/0x20 fs/file_table.c:244
> >>  [ 1116.897025] [<ffffffff813774f9>] task_work_run+0xf9/0x170
> >>  [ 1116.897025] [<ffffffff81324aae>] do_exit+0x85e/0x2a00
> >>  [ 1116.897025] [<ffffffff81326dc8>] do_group_exit+0x108/0x330
> >>  [ 1116.897025] [<ffffffff81348cf7>] get_signal+0x617/0x17a0 kernel/signal.c:2307
> >>  [ 1116.897025] [<ffffffff811b49af>] do_signal+0x7f/0x18f0
> >>  [ 1116.897025] [<ffffffff810039bf>] exit_to_usermode_loop+0xbf/0x150 arch/x86/entry/common.c:156
> >>  [ 1116.897025] [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
> >>  [ 1116.897025] [<ffffffff81006060>] syscall_return_slowpath+0x1a0/0x1e0 arch/x86/entry/common.c:259
> >>  [ 1116.897025] [<ffffffff85e4d726>] entry_SYSCALL_64_fastpath+0xc4/0xc6
> >> Memory state around the buggy address:
> >>  ffff8800081b0d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >>  ffff8800081b0e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >>> ffff8800081b0e80: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
> >>                                                     ^
> >>  ffff8800081b0f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >>  ffff8800081b0f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> ==================================================================
> >>

This looks very much like the one reported by Andrey a few days ago:
https://marc.info/?l=linux-netdev&m=147855869227527&w=2

The following patch should fix both l2tp_ip and l2tp_ip6:

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index fce25af..982f6c4 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -251,8 +251,6 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
        int ret;
        int chk_addr_ret;
 
-       if (!sock_flag(sk, SOCK_ZAPPED))
-               return -EINVAL;
        if (addr_len < sizeof(struct sockaddr_l2tpip))
                return -EINVAL;
        if (addr->l2tp_family != AF_INET)
@@ -267,6 +265,9 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
        read_unlock_bh(&l2tp_ip_lock);
 
        lock_sock(sk);
+       if (!sock_flag(sk, SOCK_ZAPPED))
+               goto out;
+
        if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_l2tpip))
                goto out;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index ad3468c..9978d01 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -269,8 +269,6 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
        int addr_type;
        int err;
 
-       if (!sock_flag(sk, SOCK_ZAPPED))
-               return -EINVAL;
        if (addr->l2tp_family != AF_INET6)
                return -EINVAL;
        if (addr_len < sizeof(*addr))
@@ -296,6 +294,9 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
        lock_sock(sk);
 
        err = -EINVAL;
+       if (!sock_flag(sk, SOCK_ZAPPED))
+               goto out_unlock;
+
        if (sk->sk_state != TCP_CLOSE)
                goto out_unlock;
