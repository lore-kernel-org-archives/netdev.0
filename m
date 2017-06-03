From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: icmp vs udp_poll race?
Date: Sat, 3 Jun 2017 07:53:25 -0700
Message-ID: <CANn89iKFcPwzVP_gfwkLND9ZTo-+PF8Ex1uePqaawTaLF=Qzmg@mail.gmail.com>
References: <20170603051742.m6jtztnn4b3me2co@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "pabeni@redhat.com" <pabeni@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170603051742.m6jtztnn4b3me2co@sasha-lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 10:17 PM, Levin, Alexander (Sasha Levin)
<alexander.levin@verizon.com> wrote:
> Hi all,
>
> On the latest linux-next I'm seeing issues that look like an icmp
> socket destruction racing with poll(). It manifests in two ways, first:
>
> BUG: KASAN: slab-out-of-bounds in skb_queue_empty include/linux/skbuff.h:1197 [inline]
> BUG: KASAN: slab-out-of-bounds in udp_poll+0x5fb/0x6f0 net/ipv4/udp.c:2443
> Read of size 8 at addr ffff88006941a200 by task syz-executor5/9052
>
> CPU: 2 PID: 9052 Comm: syz-executor5 Not tainted 4.12.0-rc3-next-20170601+ #47
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1 04/01/2014
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x115/0x1d1 lib/dump_stack.c:52
>  print_address_description+0xe7/0x370 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x1b0/0x450 mm/kasan/report.c:408
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:429
>  skb_queue_empty include/linux/skbuff.h:1197 [inline]
>  udp_poll+0x5fb/0x6f0 net/ipv4/udp.c:2443
>  sock_poll+0x169/0x410 net/socket.c:1101
>  do_pollfd fs/select.c:825 [inline]
>  do_poll fs/select.c:875 [inline]
>  do_sys_poll+0x7a7/0x13b0 fs/select.c:969
>  SYSC_poll fs/select.c:1027 [inline]
>  SyS_poll+0x106/0x460 fs/select.c:1015
>  do_syscall_64+0x275/0x810 arch/x86/entry/common.c:284
>  entry_SYSCALL64_slow_path+0x25/0x25
> RIP: 0033:0x451429
> RSP: 002b:00007fee2df0dc08 EFLAGS: 00000216 ORIG_RAX: 0000000000000007
> RAX: ffffffffffffffda RBX: 0000000020000fb0 RCX: 0000000000451429
> RDX: 000000000000001f RSI: 000000000000000a RDI: 0000000020000fb0
> RBP: 0000000000718000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000216 R12: 00000000ffffffff
> R13: 000000000000000a R14: 00000000000003c4 R15: 00007fee2df0e700
>
> Allocated by task 9052:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_kmalloc+0xae/0xe0 mm/kasan/kasan.c:617
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
>  slab_post_alloc_hook mm/slab.h:456 [inline]
>  slab_alloc_node mm/slub.c:2712 [inline]
>  slab_alloc mm/slub.c:2720 [inline]
>  kmem_cache_alloc+0x12f/0x610 mm/slub.c:2725
>  sk_prot_alloc+0x6e/0x300 net/core/sock.c:1422
>  sk_alloc+0x82/0x880 net/core/sock.c:1484
>  inet_create+0x519/0x11b0 net/ipv4/af_inet.c:318
>  __sock_create+0x52e/0xa50 net/socket.c:1249
>  sock_create net/socket.c:1289 [inline]
>  SYSC_socket net/socket.c:1319 [inline]
>  SyS_socket+0x105/0x260 net/socket.c:1299
>  do_syscall_64+0x275/0x810 arch/x86/entry/common.c:284
>  return_from_SYSCALL_64+0x0/0x7a
>
> Freed by task 8076:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:590
>  slab_free_hook mm/slub.c:1357 [inline]
>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>  slab_free mm/slub.c:2955 [inline]
>  kmem_cache_free+0xec/0x630 mm/slub.c:2977
>  sk_prot_free net/core/sock.c:1465 [inline]
>  __sk_destruct+0x6a1/0xb40 net/core/sock.c:1546
>  sk_destruct+0x57/0xb0 net/core/sock.c:1554
>  __sk_free+0x62/0x260 net/core/sock.c:1562
>  sk_free+0x28/0x40 net/core/sock.c:1573
>  sock_put include/net/sock.h:1655 [inline]
>  sk_common_release+0x241/0x3c0 net/core/sock.c:2902
>  ping_close+0x15/0x20 net/ipv4/ping.c:295
>  inet_release+0x108/0x240 net/ipv4/af_inet.c:425
>  sock_release+0x96/0x260 net/socket.c:597
>  SYSC_socketpair net/socket.c:1436 [inline]
>  SyS_socketpair+0x522/0x710 net/socket.c:1340
>  do_syscall_64+0x275/0x810 arch/x86/entry/common.c:284
>  return_from_SYSCALL_64+0x0/0x7a
>
> The buggy address belongs to the object at ffff880069419c40
>  which belongs to the cache PING of size 1392
> The buggy address is located 80 bytes to the right of
>  1392-byte region [ffff880069419c40, ffff88006941a1b0)
> The buggy address belongs to the page:
> page:ffffea0001a50600 count:1 mapcount:0 mapping:          (null) index:0xffff88006941d440 compound_mapcount: 0
> flags: 0x5fffc0000008100(slab|head)
> raw: 05fffc0000008100 0000000000000000 ffff88006941d440 0000000100120005
> raw: ffff88006c5ba490 ffff88006c5ba490 ffff88006b197c40 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff88006941a100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  ffff88006941a180: 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc
>>ffff88006941a200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>                    ^
>  ffff88006941a280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88006941a300: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>
> And second:
>
> INFO: trying to register non-static key.
> the code is fine but needs lockdep annotation.
> turning off the locking correctness validator.
> CPU: 3 PID: 12664 Comm: syz-executor7 Not tainted 4.12.0-rc3-next-20170601+ #47
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1 04/01/2014
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x115/0x1d1 lib/dump_stack.c:52
>  register_lock_class+0x5a5/0x2ce0 kernel/locking/lockdep.c:755
>  __lock_acquire+0x220/0x4f90 kernel/locking/lockdep.c:3255
>  lock_acquire+0x1f8/0x6e0 kernel/locking/lockdep.c:3855
>  __raw_spin_lock_bh include/linux/spinlock_api_smp.h:135 [inline]
>  _raw_spin_lock_bh+0x40/0x90 kernel/locking/spinlock.c:175
>  spin_lock_bh include/linux/spinlock.h:304 [inline]
>  first_packet_length+0xcf/0x7b0 net/ipv4/udp.c:1401
>  udp_poll+0x4c6/0x6f0 net/ipv4/udp.c:2450
>  sock_poll+0x169/0x410 net/socket.c:1101
>  do_pollfd fs/select.c:825 [inline]
>  do_poll fs/select.c:875 [inline]
>  do_sys_poll+0x7a7/0x13b0 fs/select.c:969
>  SYSC_ppoll fs/select.c:1078 [inline]
>  SyS_ppoll+0x22e/0x540 fs/select.c:1049
>  do_syscall_64+0x275/0x810 arch/x86/entry/common.c:284
>  entry_SYSCALL64_slow_path+0x25/0x25
> RIP: 0033:0x451429
> RSP: 002b:00007fa135ce5c08 EFLAGS: 00000216 ORIG_RAX: 000000000000010f
> RAX: ffffffffffffffda RBX: 0000000020001ff8 RCX: 0000000000451429
> RDX: 0000000020000000 RSI: 0000000000000001 RDI: 0000000020001ff8
> RBP: 0000000000718000 R08: 0000000000000008 R09: 0000000000000000
> R10: 0000000020005ff8 R11: 0000000000000216 R12: 00000000ffffffff
> R13: 0000000000000001 R14: 00000000000003c5 R15: 00007fa135ce6700
>
> Syzkaller reproduces these once in a while using:
>
> mmap(&(0x7f0000000000/0x6000)=nil, (0x6000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> r0 = socket$icmp6(0xa, 0x2, 0x3a)
> ppoll(&(0x7f0000002000-0x8)=[{r0, 0x201, 0x0}], 0x1, &(0x7f0000000000)={0x0, 0x989680}, &(0x7f0000006000-0x8)={0x101}, 0x8)
>
> --
>
> Thanks,
> Sasha


Thanks for the report.

For some weird reason, udp_poll() is also used from

struct proto_ops inet_dgram_ops
and
struct proto_ops inet6_dgram_ops

This is of course slightly wrong, since the socket is not always an UDP one.

Even before recent patches, fact that we were trying to validate UDP
checksum was already wrong

Bug was added in c319b4d76b9e583a5d88d6bf190e079c4e43213d
("net: ipv4: add IPPROTO_ICMP socket kind")

I will cook a patch, thanks again.
