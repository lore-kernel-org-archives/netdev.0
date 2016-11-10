From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: net/l2tp: use-after-free write in l2tp_ip6_close
Date: Thu, 10 Nov 2016 18:44:29 +0100
Message-ID: <20161110174429.dmqgov4k6tgg2fsc@alphalink.fr>
References: <CAAeHK+wThP9rwA7ecbpTPLaj7BR6+qwTy_N=Zh3Jf+AsO_Njbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Wei Wang <weiwan@google.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+wThP9rwA7ecbpTPLaj7BR6+qwTy_N=Zh3Jf+AsO_Njbw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2016 at 11:35:26PM +0100, Andrey Konovalov wrote:
> Hi,
> 
> I've got the following error report while running the syzkaller fuzzer:
> 
> ==================================================================
> BUG: KASAN: use-after-free in l2tp_ip6_close+0x239/0x2a0 at addr
> ffff8800677276d8
> Write of size 8 by task a.out/8668
> CPU: 0 PID: 8668 Comm: a.out Not tainted 4.9.0-rc4+ #354
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800694d7b00 ffffffff81b46a64 ffff88006adb5780 ffff8800677276c0
>  ffff880067727c68 ffff8800677276c0 ffff8800694d7b28 ffffffff8150a86c
>  ffff8800694d7bb8 ffff88006adb5780 ffff8800e77276d8 ffff8800694d7ba8
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46a64>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff8150a86c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
>  [<     inline     >] print_address_description mm/kasan/report.c:194
>  [<ffffffff8150ab07>] kasan_report_error+0x1f7/0x4d0 mm/kasan/report.c:283
>  [<     inline     >] kasan_report mm/kasan/report.c:303
>  [<ffffffff8150b01e>] __asan_report_store8_noabort+0x3e/0x40
> mm/kasan/report.c:329
>  [<     inline     >] __write_once_size ./include/linux/compiler.h:272
>  [<     inline     >] __hlist_del ./include/linux/list.h:622
>  [<     inline     >] hlist_del_init ./include/linux/list.h:637
>  [<ffffffff83825f49>] l2tp_ip6_close+0x239/0x2a0 net/l2tp/l2tp_ip6.c:239
>  [<ffffffff8316b31f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:415
>  [<ffffffff832cd4d0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
>  [<ffffffff82b6d89e>] sock_release+0x8e/0x1d0 net/socket.c:570
>  [<ffffffff82b6d9f6>] sock_close+0x16/0x20 net/socket.c:1017
>  [<ffffffff81524bdd>] __fput+0x29d/0x720 fs/file_table.c:208
>  [<ffffffff815250e5>] ____fput+0x15/0x20 fs/file_table.c:244
>  [<ffffffff81172928>] task_work_run+0xf8/0x170 kernel/task_work.c:116
>  [<     inline     >] exit_task_work ./include/linux/task_work.h:21
>  [<ffffffff8111bda3>] do_exit+0x883/0x2ac0 kernel/exit.c:828
>  [<ffffffff8112234e>] do_group_exit+0x10e/0x340 kernel/exit.c:931
>  [<     inline     >] SYSC_exit_group kernel/exit.c:942
>  [<ffffffff8112259d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:940
>  [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Object at ffff8800677276c0, in cache L2TP/IPv6 size: 1448
> Allocated:
> PID = 8692
> [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
> [<ffffffff81509bd6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
> [<     inline     >] set_track mm/kasan/kasan.c:507
> [<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0 mm/kasan/kasan.c:598
> [<ffffffff8150a3b2>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:537
> [<     inline     >] slab_post_alloc_hook mm/slab.h:417
> [<     inline     >] slab_alloc_node mm/slub.c:2708
> [<     inline     >] slab_alloc mm/slub.c:2716
> [<ffffffff81505064>] kmem_cache_alloc+0xb4/0x270 mm/slub.c:2721
> [<ffffffff82b77ca9>] sk_prot_alloc+0x69/0x2b0 net/core/sock.c:1327
> [<ffffffff82b80898>] sk_alloc+0x38/0xaf0 net/core/sock.c:1389
> [<ffffffff832cef05>] inet6_create+0x2e5/0xf60 net/ipv6/af_inet6.c:182
> [<ffffffff82b7301f>] __sock_create+0x37f/0x640 net/socket.c:1153
> [<     inline     >] sock_create net/socket.c:1193
> [<     inline     >] SYSC_socket net/socket.c:1223
> [<ffffffff82b73510>] SyS_socket+0xf0/0x1b0 net/socket.c:1203
> [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Freed:
> PID = 8668
> [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
> [<ffffffff81509bd6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
> [<     inline     >] set_track mm/kasan/kasan.c:507
> [<ffffffff8150a433>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
> [<     inline     >] slab_free_hook mm/slub.c:1352
> [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
> [<     inline     >] slab_free mm/slub.c:2951
> [<ffffffff81506263>] kmem_cache_free+0xb3/0x2c0 mm/slub.c:2973
> [<     inline     >] sk_prot_free net/core/sock.c:1370
> [<ffffffff82b7c669>] __sk_destruct+0x319/0x480 net/core/sock.c:1445
> [<ffffffff82b82b94>] sk_destruct+0x44/0x80 net/core/sock.c:1453
> [<ffffffff82b82c24>] __sk_free+0x54/0x230 net/core/sock.c:1461
> [<ffffffff82b82e23>] sk_free+0x23/0x30 net/core/sock.c:1472
> [<     inline     >] sock_put ./include/net/sock.h:1591
> [<ffffffff82b84b04>] sk_common_release+0x294/0x3e0 net/core/sock.c:2745
> [<ffffffff83825f19>] l2tp_ip6_close+0x209/0x2a0 net/l2tp/l2tp_ip6.c:243
> [<ffffffff8316b31f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:415
> [<ffffffff832cd4d0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
> [<ffffffff82b6d89e>] sock_release+0x8e/0x1d0 net/socket.c:570
> [<ffffffff82b6d9f6>] sock_close+0x16/0x20 net/socket.c:1017
> [<ffffffff81524bdd>] __fput+0x29d/0x720 fs/file_table.c:208
> [<ffffffff815250e5>] ____fput+0x15/0x20 fs/file_table.c:244
> [<ffffffff81172928>] task_work_run+0xf8/0x170 kernel/task_work.c:116
> [<     inline     >] exit_task_work ./include/linux/task_work.h:21
> [<ffffffff8111bda3>] do_exit+0x883/0x2ac0 kernel/exit.c:828
> [<ffffffff8112234e>] do_group_exit+0x10e/0x340 kernel/exit.c:931
> [<     inline     >] SYSC_exit_group kernel/exit.c:942
> [<ffffffff8112259d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:940
> [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Memory state around the buggy address:
>  ffff880067727580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880067727600: fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc
> >ffff880067727680: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>                                                     ^
>  ffff880067727700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880067727780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
> 
> To reproduce run the attached program in a tight parallel loop using
> stress (https://godoc.org/golang.org/x/tools/cmd/stress):
> $ gcc -lpthread tmp.c
> $ ./stress ./a.out
> 
> On commit bc33b0ca11e3df467777a4fa7639ba488c9d4911 (Nov 5).
> 

Thanks for the report. It looks like l2tp_ip6_bind() is racy.
Can you try the following patch?

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
