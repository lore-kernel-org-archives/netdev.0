From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: KASAN: slab-out-of-bounds Read in tipc_nametbl_lookup_dst_nodes
Date: Tue, 24 Oct 2017 17:22:37 +0200
Message-ID: <CACT4Y+Y1NKRV7oxOtFOLg1Fi1bqVfCNKHfoFiVxB68fci_eZvg@mail.gmail.com>
References: <001a113ff33e3aa97d055c4c7cd8@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, syzkaller-bugs@googlegroups.com,
        tipc-discussion@lists.sourceforge.net,
        Ying Xue <ying.xue@windriver.com>
To: syzbot
        <bot+a9d6dccad76c3e1f6cad1031d8f2292c4f4f0e1a@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a113ff33e3aa97d055c4c7cd8@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 5:20 PM, syzbot
<bot+a9d6dccad76c3e1f6cad1031d8f2292c4f4f0e1a@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 80cee03bf1d626db0278271b505d7f5febb37bba
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers


This also happened on more recent commits, including linux-next
36ef71cae353f88fd6e095e2aaa3e5953af1685d (Oct 19), with a similar
signature:

==================================================================
BUG: KASAN: slab-out-of-bounds in
tipc_nametbl_lookup_dst_nodes+0x448/0x4b0 net/tipc/name_table.c:700
Read of size 4 at addr ffff8801c84aa050 by task syz-executor1/6930

CPU: 0 PID: 6930 Comm: syz-executor1 Not tainted 4.14.0-rc5-next-20171018+ #36
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 print_address_description+0x73/0x250 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351 [inline]
 kasan_report+0x25b/0x340 mm/kasan/report.c:409
 __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:429
 tipc_nametbl_lookup_dst_nodes+0x448/0x4b0 net/tipc/name_table.c:700
 tipc_sendmcast+0x794/0xe70 net/tipc/socket.c:791
 __tipc_sendmsg+0xebf/0x1b20 net/tipc/socket.c:1316
 tipc_sendmsg+0x50/0x70 net/tipc/socket.c:1250
 sock_sendmsg_nosec net/socket.c:632 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:642
 ___sys_sendmsg+0x755/0x890 net/socket.c:2048
 __sys_sendmsg+0xe5/0x210 net/socket.c:2082
 SYSC_sendmsg net/socket.c:2093 [inline]
 SyS_sendmsg+0x2d/0x50 net/socket.c:2089
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x452719
RSP: 002b:00007fe17302fbe8 EFLAGS: 00000212 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000758020 RCX: 0000000000452719
RDX: 0000000000000000 RSI: 0000000020316000 RDI: 0000000000000013
RBP: 0000000000000082 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000212 R12: 00000000006ef1b0
R13: 00000000ffffffff R14: 00007fe1730306d4 R15: 0000000000000000

Allocated by task 3449:
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 kmem_cache_alloc_trace+0x136/0x750 mm/slab.c:3614
 kmalloc include/linux/slab.h:502 [inline]
 kmalloc_array include/linux/slab.h:620 [inline]
 kcalloc include/linux/slab.h:632 [inline]
 tipc_subseq_alloc net/tipc/name_table.c:142 [inline]
 tipc_nameseq_create+0xe8/0x540 net/tipc/name_table.c:153
 tipc_nametbl_insert_publ+0xf77/0x17c0 net/tipc/name_table.c:477
 tipc_nametbl_publish+0x2aa/0x4f0 net/tipc/name_table.c:762
 tipc_net_start+0x26f/0x450 net/tipc/net.c:120
 tipc_nl_net_set+0x4cf/0x770 net/tipc/net.c:245
 __tipc_nl_compat_doit net/tipc/netlink_compat.c:316 [inline]
 tipc_nl_compat_doit+0x431/0x660 net/tipc/netlink_compat.c:335
 tipc_nl_compat_handle net/tipc/netlink_compat.c:1158 [inline]
 tipc_nl_compat_recv+0xbe8/0x18f0 net/tipc/netlink_compat.c:1201
 genl_family_rcv_msg+0x7b7/0xfb0 net/netlink/genetlink.c:598
 genl_rcv_msg+0xb2/0x140 net/netlink/genetlink.c:623
 netlink_rcv_skb+0x216/0x440 net/netlink/af_netlink.c:2409
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:634
 netlink_unicast_kernel net/netlink/af_netlink.c:1273 [inline]
 netlink_unicast+0x4e8/0x6f0 net/netlink/af_netlink.c:1299
 netlink_sendmsg+0xa4a/0xe60 net/netlink/af_netlink.c:1862
 sock_sendmsg_nosec net/socket.c:632 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:642
 sock_write_iter+0x31a/0x5d0 net/socket.c:911
 call_write_iter include/linux/fs.h:1770 [inline]
 new_sync_write fs/read_write.c:468 [inline]
 __vfs_write+0x684/0x970 fs/read_write.c:481
 vfs_write+0x189/0x510 fs/read_write.c:543
 SYSC_write fs/read_write.c:588 [inline]
 SyS_write+0xef/0x220 fs/read_write.c:580
 entry_SYSCALL_64_fastpath+0x1f/0xbe

Freed by task 1921:
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
 __cache_free mm/slab.c:3492 [inline]
 kfree+0xca/0x250 mm/slab.c:3807
 selinux_cred_free+0x48/0x70 security/selinux/hooks.c:3798
 security_cred_free+0x48/0x80 security/security.c:994
 put_cred_rcu+0x106/0x400 kernel/cred.c:117
 __rcu_reclaim kernel/rcu/rcu.h:172 [inline]
 rcu_do_batch kernel/rcu/tree.c:2676 [inline]
 invoke_rcu_callbacks kernel/rcu/tree.c:2930 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:2897 [inline]
 rcu_process_callbacks+0xd74/0x17d0 kernel/rcu/tree.c:2914
 __do_softirq+0x2d7/0xb85 kernel/softirq.c:284

The buggy address belongs to the object at ffff8801c84aa040
 which belongs to the cache kmalloc-32 of size 32
The buggy address is located 16 bytes inside of
 32-byte region [ffff8801c84aa040, ffff8801c84aa060)
The buggy address belongs to the page:
page:ffffea0007212a80 count:1 mapcount:0 mapping:ffff8801c84aa000
index:0xffff8801c84aafc1
flags: 0x200000000000100(slab)
raw: 0200000000000100 ffff8801c84aa000 ffff8801c84aafc1 000000010000003c
raw: ffffea000721cf60 ffffea00072f2ba0 ffff8801dac001c0 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff8801c84a9f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
 ffff8801c84a9f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>ffff8801c84aa000: fb fb fb fb fc fc fc fc 00 00 fc fc fc fc fc fc
                                                 ^
 ffff8801c84aa080: fb fb fb fb fc fc fc fc fb fb fb fb fc fc fc fc
 ffff8801c84aa100: fb fb fb fb fc fc fc fc fb fb fb fb fc fc fc fc
==================================================================




> BUG: KASAN: slab-out-of-bounds in tipc_nametbl_lookup_dst_nodes+0x4a3/0x4b0
> net/tipc/name_table.c:670
> Read of size 4 at addr ffff8801d3275f10 by task syzkaller601354/2981
>
> CPU: 1 PID: 2981 Comm: syzkaller601354 Not tainted 4.13.0+ #42
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x24e/0x340 mm/kasan/report.c:409
>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:429
>  tipc_nametbl_lookup_dst_nodes+0x4a3/0x4b0 net/tipc/name_table.c:670
>  tipc_sendmcast+0x704/0xe30 net/tipc/socket.c:767
>  __tipc_sendmsg+0xf49/0x1590 net/tipc/socket.c:971
>  __tipc_sendstream+0x8eb/0xc00 net/tipc/socket.c:1065
>  tipc_sendstream+0x50/0x70 net/tipc/socket.c:1039
>  tipc_send_packet+0x33/0x50 net/tipc/socket.c:1113
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  ___sys_sendmsg+0x75b/0x8a0 net/socket.c:2049
>  __sys_sendmsg+0xe5/0x210 net/socket.c:2083
>  SYSC_sendmsg net/socket.c:2094 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2090
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x43fd79
> RSP: 002b:00007ffcb61e8988 EFLAGS: 00000203 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fd79
> RDX: 0000000000000004 RSI: 00000000207ca000 RDI: 0000000000000003
> RBP: 0000000000000082 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000203 R12: 00000000004016e0
> R13: 0000000000401770 R14: 0000000000000000 R15: 0000000000000000
>
> Allocated by task 1:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  kmem_cache_alloc_trace+0x136/0x750 mm/slab.c:3627
>  kmalloc include/linux/slab.h:493 [inline]
>  kmalloc_array include/linux/slab.h:611 [inline]
>  kcalloc include/linux/slab.h:623 [inline]
>  tipc_subseq_alloc net/tipc/name_table.c:141 [inline]
>  tipc_nameseq_create+0xe8/0x540 net/tipc/name_table.c:152
>  tipc_nametbl_insert_publ+0xf77/0x17c0 net/tipc/name_table.c:476
>  tipc_nametbl_publish+0x2aa/0x4f0 net/tipc/name_table.c:701
>  tipc_sk_publish net/tipc/socket.c:2201 [inline]
>  tipc_bind+0x33a/0x700 net/tipc/socket.c:629
>  kernel_bind+0x62/0x80 net/socket.c:3285
>  tipc_create_listen_sock net/tipc/server.c:337 [inline]
>  tipc_open_listening_sock net/tipc/server.c:395 [inline]
>  tipc_server_start+0x3a1/0xb60 net/tipc/server.c:610
>  tipc_topsrv_start+0x64f/0x890 net/tipc/subscr.c:382
>  tipc_init_net+0x3cc/0x570 net/tipc/core.c:74
>  ops_init+0x10a/0x570 net/core/net_namespace.c:118
>  __register_pernet_operations net/core/net_namespace.c:879 [inline]
>  register_pernet_operations+0x45e/0x980 net/core/net_namespace.c:953
>  register_pernet_subsys+0x2a/0x40 net/core/net_namespace.c:995
>  tipc_init+0x83/0x104 net/tipc/core.c:136
>  do_one_initcall+0x9e/0x330 init/main.c:826
>  do_initcall_level init/main.c:892 [inline]
>  do_initcalls init/main.c:900 [inline]
>  do_basic_setup init/main.c:918 [inline]
>  kernel_init_freeable+0x469/0x521 init/main.c:1066
>  kernel_init+0x13/0x172 init/main.c:993
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> Freed by task 0:
> (stack is not available)
>
> The buggy address belongs to the object at ffff8801d3275f00
>  which belongs to the cache kmalloc-32 of size 32
> The buggy address is located 16 bytes inside of
>  32-byte region [ffff8801d3275f00, ffff8801d3275f20)
> The buggy address belongs to the page:
> page:ffffea00074c9d40 count:1 mapcount:0 mapping:ffff8801d3275000
> index:0xffff8801d3275fc1
> flags: 0x200000000000100(slab)
> raw: 0200000000000100 ffff8801d3275000 ffff8801d3275fc1 000000010000003f
> raw: ffffea00074c8920 ffffea00074cea20 ffff8801dac001c0 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff8801d3275e00: fb fb fb fb fc fc fc fc 00 00 00 fc fc fc fc fc
>  ffff8801d3275e80: 04 fc fc fc fc fc fc fc 00 00 00 fc fc fc fc fc
>>
>> ffff8801d3275f00: 00 00 fc fc fc fc fc fc 00 00 00 00 fc fc fc fc
>
>                          ^
>  ffff8801d3275f80: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8801d3276000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================
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
> https://groups.google.com/d/msgid/syzkaller-bugs/001a113ff33e3aa97d055c4c7cd8%40google.com.
> For more options, visit https://groups.google.com/d/optout.
