From: Xin Long <lucien.xin@gmail.com>
Subject: Re: net/sctp: use-after-free in sctp_hash_transport
Date: Tue, 28 Feb 2017 00:27:02 +0800
Message-ID: <CADvbK_e=EiYYz_2_PqGG-40CtG9aEmj4DunTM95Uro8QBTYKVQ@mail.gmail.com>
References: <CAAeHK+yDV7ivdDCZ3Q0cOt0O+0e40BEuj4v8=_Onbt7WO8hRZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yDV7ivdDCZ3Q0cOt0O+0e40BEuj4v8=_Onbt7WO8hRZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 11:45 PM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570 (Feb 26).
>
> A reproducer and .config are attached.
>
> ===============================
> [ ERR: suspicious RCU usage.  ]
> 4.10.0+ #54 Not tainted
> -------------------------------
> ./include/linux/rhashtable.h:602 suspicious rcu_dereference_check() usage!
>
> other info that might help us debug this:
>
>
> rcu_scheduler_active = 2, debug_locks = 0
> 1 lock held by a.out/4189:
>  #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84510c78>]
> sctp_setsockopt+0x318/0x5f10
>
> stack backtrace:
> CPU: 1 PID: 4189 Comm: a.out Not tainted 4.10.0+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15
>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>  lockdep_rcu_suspicious+0x139/0x180 kernel/locking/lockdep.c:4452
>  __rhashtable_lookup ./include/linux/rhashtable.h:602
>  rhltable_lookup ./include/linux/rhashtable.h:690
>  sctp_hash_transport+0x826/0xcc0 net/sctp/input.c:887
>  sctp_assoc_add_peer+0xd0b/0x1470 net/sctp/associola.c:716
>  __sctp_connect+0x26d/0xdb0 net/sctp/socket.c:1184
>  __sctp_setsockopt_connectx+0x197/0x200 net/sctp/socket.c:1338
>  sctp_setsockopt_connectx net/sctp/socket.c:1370
>  sctp_setsockopt+0x15fa/0x5f10 net/sctp/socket.c:3936
>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>  SYSC_setsockopt net/socket.c:1786
>  SyS_setsockopt+0x270/0x3a0 net/socket.c:1765
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7f3e27a55b79
> RSP: 002b:00007f3e2296fd98 EFLAGS: 00000206 ORIG_RAX: 0000000000000036
> RAX: ffffffffffffffda RBX: 00007f3e229709c0 RCX: 00007f3e27a55b79
> RDX: 000000000000006e RSI: 0000000000000084 RDI: 0000000000000003
> RBP: 00007f3e27f21220 R08: 0000000000000010 R09: 0000000000000000
> R10: 0000000020004000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007f3e229709c0 R14: 00007f3e2834c040 R15: 0000000000000003
> ==================================================================
> BUG: KASAN: use-after-free in sctp_hash_transport+0x855/0xcc0 at addr
> ffff8800671e1f8c
> Read of size 4 by task a.out/4189
> CPU: 1 PID: 4189 Comm: a.out Not tainted 4.10.0+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15
>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>  print_address_description mm/kasan/report.c:200
>  kasan_report_error mm/kasan/report.c:289
>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>  kasan_report mm/kasan/report.c:331
>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:331
>  rht_key_hashfn ./include/linux/rhashtable.h:254
>  __rhashtable_lookup ./include/linux/rhashtable.h:604
>  rhltable_lookup ./include/linux/rhashtable.h:690
>  sctp_hash_transport+0x855/0xcc0 net/sctp/input.c:887
>  sctp_assoc_add_peer+0xd0b/0x1470 net/sctp/associola.c:716
>  __sctp_connect+0x26d/0xdb0 net/sctp/socket.c:1184
>  __sctp_setsockopt_connectx+0x197/0x200 net/sctp/socket.c:1338
>  sctp_setsockopt_connectx net/sctp/socket.c:1370
>  sctp_setsockopt+0x15fa/0x5f10 net/sctp/socket.c:3936
>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>  SYSC_setsockopt net/socket.c:1786
>  SyS_setsockopt+0x270/0x3a0 net/socket.c:1765
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7f3e27a55b79
> RSP: 002b:00007f3e2296fd98 EFLAGS: 00000206 ORIG_RAX: 0000000000000036
> RAX: ffffffffffffffda RBX: 00007f3e229709c0 RCX: 00007f3e27a55b79
> RDX: 000000000000006e RSI: 0000000000000084 RDI: 0000000000000003
> RBP: 00007f3e27f21220 R08: 0000000000000010 R09: 0000000000000000
> R10: 0000000020004000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007f3e229709c0 R14: 00007f3e2834c040 R15: 0000000000000003
> Object at ffff8800671e1f80, in cache kmalloc-1024 size: 1024
> Allocated:
> PID = 1
> save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
>  __kmalloc+0xa0/0x2d0 mm/slub.c:3745
>  kmalloc ./include/linux/slab.h:495
>  kzalloc ./include/linux/slab.h:663
>  bucket_table_alloc+0x618/0x930 lib/rhashtable.c:224
>  rhashtable_init+0x5f8/0xc60 lib/rhashtable.c:1006
>  rhltable_init+0x53/0xa0 lib/rhashtable.c:1037
>  sctp_transport_hashtable_init+0x1c/0x20 net/sctp/input.c:865
>  sctp_init+0x62c/0x88f net/sctp/protocol.c:1486
>  do_one_initcall+0xf3/0x390 init/main.c:788
>  do_initcall_level init/main.c:854
>  do_initcalls init/main.c:862
>  do_basic_setup init/main.c:880
>  kernel_init_freeable+0x5cc/0x6a6 init/main.c:1031
>  kernel_init+0x13/0x180 init/main.c:955
>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
> Freed:
> PID = 0
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514
>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
>  slab_free_hook mm/slub.c:1357
>  slab_free_freelist_hook mm/slub.c:1379
>  slab_free mm/slub.c:2961
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  kvfree+0x36/0x60 mm/util.c:335
>  bucket_table_free+0xd7/0x260 lib/rhashtable.c:152
>  bucket_table_free_rcu+0x16/0x20 lib/rhashtable.c:157
>  __rcu_reclaim kernel/rcu/rcu.h:118
>  rcu_do_batch.isra.64+0x94c/0xcc0 kernel/rcu/tree.c:2877
>  invoke_rcu_callbacks kernel/rcu/tree.c:3140
>  __rcu_process_callbacks kernel/rcu/tree.c:3107
>  rcu_process_callbacks+0x2cc/0xb90 kernel/rcu/tree.c:3124
>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
> Memory state around the buggy address:
>  ffff8800671e1e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8800671e1f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff8800671e1f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                       ^
>  ffff8800671e2000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8800671e2080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
>
> ...
> ...
> ...
>
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4189 Comm: a.out Tainted: G    B           4.10.0+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880069111600 task.stack: ffff880068638000
> RIP: 0010:rht_bucket_nested+0x18e/0x560 lib/rhashtable.c:1126
> RSP: 0018:ffff88006863eda8 EFLAGS: 00010246
> RAX: dffffc0000000000 RBX: 000000006be18a80 RCX: 1ffff1000d0c7dbf
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffff85a5ee80
> RBP: ffff88006863ee60 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: dffffc0000000000 R12: 0000000000000001
> R13: ffff8800671e1f84 R14: ffff8800671e1f80 R15: dffffc0000000000
> FS:  00007f3e22970700(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f3e2216ef38 CR3: 0000000065589000 CR4: 00000000000006e0
> Call Trace:
>  rht_bucket ./include/linux/rhashtable.h:404
>  __rhashtable_lookup ./include/linux/rhashtable.h:605
>  rhltable_lookup ./include/linux/rhashtable.h:690
>  sctp_hash_transport+0xaa9/0xcc0 net/sctp/input.c:887
>  sctp_assoc_add_peer+0xd0b/0x1470 net/sctp/associola.c:716
>  __sctp_connect+0x26d/0xdb0 net/sctp/socket.c:1184
>  __sctp_setsockopt_connectx+0x197/0x200 net/sctp/socket.c:1338
>  sctp_setsockopt_connectx net/sctp/socket.c:1370
>  sctp_setsockopt+0x15fa/0x5f10 net/sctp/socket.c:3936
>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>  SYSC_setsockopt net/socket.c:1786
>  SyS_setsockopt+0x270/0x3a0 net/socket.c:1765
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7f3e27a55b79
> RSP: 002b:00007f3e2296fd98 EFLAGS: 00000206 ORIG_RAX: 0000000000000036
> RAX: ffffffffffffffda RBX: 00007f3e229709c0 RCX: 00007f3e27a55b79
> RDX: 000000000000006e RSI: 0000000000000084 RDI: 0000000000000003
> RBP: 00007f3e27f21220 R08: 0000000000000010 R09: 0000000000000000
> R10: 0000000020004000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007f3e229709c0 R14: 00007f3e2834c040 R15: 0000000000000003
> Code: 34 14 97 03 00 0f 84 a4 01 00 00 e8 9d e2 4b ff 8b 85 70 ff ff
> ff 4d 8d 24 c4 48 b8 00 00 00 00 00 fc ff df 4c 89 e2 48 c1 ea 03 <80>
> 3c 02 00 0f 85 b1 03 00 00 4c 89 ea 48 b8 00 00 00 00 00 fc
> RIP: rht_bucket_nested+0x18e/0x560 RSP: ffff88006863eda8
> ---[ end trace 9d36cf16fcdf072c ]--

Just notice that rhltable_lookup doesn't call rcu_read_lock inside, unlike
rhltable_insert_key().

will post a fix it soon.

Thanks.
