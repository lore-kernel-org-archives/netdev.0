From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/kcm: use-after-free in kcm_wq
Date: Fri, 3 Mar 2017 12:07:04 +0100
Message-ID: <CACT4Y+ZvRXetNwosM_4oCU93SU35Xdey9ZOrLBM-6JBi0+gyAw@mail.gmail.com>
References: <CACT4Y+ZsaUAbTHdtP7BmZ+dsOTVA+f1jc8Mt=41H+8mwpkbRpA@mail.gmail.com>
 <CACT4Y+Zwk_82rKowdW3tLaZQC_q73swNoZ6mj5kvapHAGztaMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Zwk_82rKowdW3tLaZQC_q73swNoZ6mj5kvapHAGztaMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 11:11 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Mar 3, 2017 at 11:09 AM, Dmitry Vyukov <dvyukov@google.com> wrote=
:
>> Hello,
>>
>> I am getting the following use-after-free reports while running
>> syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. Seems
>> that work items are not properly cancelled.
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> BUG: KASAN: use-after-free in worker_thread+0x190f/0x1990
>> kernel/workqueue.c:2228 at addr ffff880063de5a20
>> Read of size 8 by task kworker/u8:0/5
>> CPU: 1 PID: 5 Comm: kworker/u8:0 Not tainted 4.10.0+ #260
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/=
2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
>>  print_address_description mm/kasan/report.c:204 [inline]
>>  kasan_report_error mm/kasan/report.c:288 [inline]
>>  kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
>>  kasan_report mm/kasan/report.c:331 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
>>  worker_thread+0x190f/0x1990 kernel/workqueue.c:2228
>>  kthread+0x326/0x3f0 kernel/kthread.c:227
>>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
>> Object at ffff880063de5900, in cache kcm_psock_cache size: 616
>> Allocated:
>> PID =3D 11085
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
>>  kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
>>  kmem_cache_zalloc include/linux/slab.h:653 [inline]
>>  kcm_attach net/kcm/kcmsock.c:1384 [inline]
>>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>>  kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
>>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>>  vfs_ioctl fs/ioctl.c:43 [inline]
>>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>>  SYSC_ioctl fs/ioctl.c:698 [inline]
>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> Freed:
>> PID =3D 11095
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
>>  __cache_free mm/slab.c:3513 [inline]
>>  kmem_cache_free+0x71/0x240 mm/slab.c:3773
>>  kcm_unattach+0xee7/0x1520 net/kcm/kcmsock.c:1558
>>  kcm_unattach_ioctl net/kcm/kcmsock.c:1603 [inline]
>>  kcm_ioctl+0xfae/0x1800 net/kcm/kcmsock.c:1700
>>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>>  vfs_ioctl fs/ioctl.c:43 [inline]
>>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>>  SYSC_ioctl fs/ioctl.c:698 [inline]
>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> Memory state around the buggy address:
>>  ffff880063de5900: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff880063de5980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>ffff880063de5a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>                                ^
>>  ffff880063de5a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff880063de5b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> BUG: KASAN: use-after-free in worker_thread+0x190f/0x1990
>> kernel/workqueue.c:2228 at addr ffff88005378ed20
>> Read of size 8 by task kworker/u8:2/6942
>> CPU: 3 PID: 6942 Comm: kworker/u8:2 Not tainted 4.10.0+ #260
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/=
2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
>>  print_address_description mm/kasan/report.c:204 [inline]
>>  kasan_report_error mm/kasan/report.c:288 [inline]
>>  kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
>>  kasan_report mm/kasan/report.c:331 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
>>  worker_thread+0x190f/0x1990 kernel/workqueue.c:2228
>>  kthread+0x326/0x3f0 kernel/kthread.c:227
>>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
>> Object at ffff88005378ec00, in cache kcm_psock_cache size: 616
>> Allocated:
>> PID =3D 3023
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
>>  kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
>>  kmem_cache_zalloc include/linux/slab.h:653 [inline]
>>  kcm_attach net/kcm/kcmsock.c:1384 [inline]
>>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>>  kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
>>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>>  vfs_ioctl fs/ioctl.c:43 [inline]
>>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>>  SYSC_ioctl fs/ioctl.c:698 [inline]
>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> Freed:
>> PID =3D 6942
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
>>  __cache_free mm/slab.c:3513 [inline]
>>  kmem_cache_free+0x71/0x240 mm/slab.c:3773
>>  unreserve_psock+0x585/0x760 net/kcm/kcmsock.c:545
>>  kcm_write_msgs+0xbba/0x1b90 net/kcm/kcmsock.c:588
>>  kcm_tx_work+0x2e/0x190 net/kcm/kcmsock.c:729
>>  process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
>>  worker_thread+0x223/0x1990 kernel/workqueue.c:2230
>>  kthread+0x326/0x3f0 kernel/kthread.c:227
>>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
>> Memory state around the buggy address:
>>  ffff88005378ec00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff88005378ec80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>ffff88005378ed00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>                                ^
>>  ffff88005378ed80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff88005378ee00: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>
>
> Also like this one:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> BUG: KASAN: use-after-free in atomic_long_read
> include/linux/compiler.h:254 [inline] at addr ffff8800538aba60
> BUG: KASAN: use-after-free in get_work_pool+0x2f2/0x340
> kernel/workqueue.c:709 at addr ffff8800538aba60
> Read of size 8 by task syz-executor6/7965
> CPU: 2 PID: 7965 Comm: syz-executor6 Not tainted 4.10.0+ #248
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2=
011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
>  print_address_description mm/kasan/report.c:204 [inline]
>  kasan_report_error mm/kasan/report.c:288 [inline]
>  kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
>  kasan_report mm/kasan/report.c:331 [inline]
>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
>  atomic_long_read include/linux/compiler.h:254 [inline]
>  get_work_pool+0x2f2/0x340 kernel/workqueue.c:709
>  __queue_work+0x2b3/0x1210 kernel/workqueue.c:1401
>  queue_work_on+0x2e9/0x330 kernel/workqueue.c:1486
>  queue_work include/linux/workqueue.h:487 [inline]
>  strp_check_rcv+0x25/0x30 net/strparser/strparser.c:494
>  kcm_attach net/kcm/kcmsock.c:1434 [inline]
>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>  kcm_ioctl+0x8bb/0x1800 net/kcm/kcmsock.c:1690
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007f1dce9d1b58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000024 RCX: 00000000004458d9
> RDX: 0000000020b68000 RSI: 00000000000089e0 RDI: 0000000000000024
> RBP: 00000000006e0220 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 00000000007080a8
> R13: 0000000000000000 R14: 00007f1dce9d29c0 R15: 00007f1dce9d2700
> Object at ffff8800538ab940, in cache kcm_psock_cache size: 616
> Allocated:
> PID =3D 7965
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514 [inline]
>  kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
>  kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
>  kmem_cache_zalloc include/linux/slab.h:653 [inline]
>  kcm_attach net/kcm/kcmsock.c:1384 [inline]
>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>  kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID =3D 7982
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514 [inline]
>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
>  __cache_free mm/slab.c:3513 [inline]
>  kmem_cache_free+0x71/0x240 mm/slab.c:3773
>  kcm_unattach+0xee7/0x1520 net/kcm/kcmsock.c:1558
>  kcm_unattach_ioctl net/kcm/kcmsock.c:1603 [inline]
>  kcm_ioctl+0xfae/0x1800 net/kcm/kcmsock.c:1700
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Memory state around the buggy address:
>  ffff8800538ab900: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>  ffff8800538ab980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>ffff8800538aba00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                                        ^
>  ffff8800538aba80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8800538abb00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D



FTR, this is reproducible by running the following syzkaller program:

mmap(&(0x7f0000000000/0xfbb000)=3Dnil, (0xfbb000), 0x3, 0x32,
0xffffffffffffffff, 0x0)
r0 =3D socket(0x0, 0x0, 0x0)
r1 =3D socket(0xa, 0x1, 0x0)
setsockopt$NETROM_N2(r1, 0x103, 0x3, &(0x7f000072a000)=3D0x7, 0x4)
r2 =3D bpf$PROG_LOAD(0x5, &(0x7f0000b50000-0x30)=3D{0x1, 0x2,
&(0x7f0000b4f000)=3D[@generic=3D{0xffffffffffffffb7, 0x0, 0x0, 0x0},
@generic=3D{0x9595, 0x0, 0x0, 0x0}], &(0x7f000015a000)=3D"008b", 0x9,
0x80, &(0x7f0000b4f000)=3D"000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000000000000000000=
0000000000000000000000000000000000000000000000000000000000",
0x0}, 0x30)
pread64(r1, &(0x7f0000fb8000)=3D"", 0x0, 0x38)
mmap(&(0x7f0000fbb000/0x1000)=3Dnil, (0x1000), 0x3, 0x32, 0xfffffffffffffff=
f, 0x0)
setsockopt$SCTP_AUTO_ASCONF(r1, 0x84, 0x1e, &(0x7f0000fbc000-0x4)=3D0x7, 0x=
4)
r3 =3D dup3(r0, r1, 0x0)
ioctl$UFFDIO_API(r2, 0xc018aa3f, &(0x7f000073d000)=3D{0xaa, 0x0, 0x0})
recvmsg$kcm(r3, &(0x7f0000fb9000)=3D{0x0, 0x0,
&(0x7f0000fba000-0x40)=3D[{&(0x7f00001c0000)=3D"", 0x0},
{&(0x7f0000fba000-0x43)=3D"", 0x0}, {&(0x7f00009ec000)=3D"", 0x0},
{&(0x7f0000fb9000)=3D"", 0x0}], 0x4, &(0x7f0000fba000-0xd6)=3D"", 0x0,
0x7}, 0x2)
bpf$PROG_LOAD(0x5, &(0x7f0000fb8000)=3D{0x80, 0x1,
&(0x7f0000302000-0x28)=3D[@generic=3D{0x0, 0xc00000, 0x0, 0x0}],
&(0x7f0000a85000)=3D"008b", 0x0, 0x0, &(0x7f0000fb5000)=3D"", 0x9}, 0x30)
r4 =3D socket$kcm(0x29, 0x5, 0x0)
write(r4, &(0x7f0000fb3000-0xe9)=3D"", 0x0)
ioctl$SIOCSIFHWADDR(r3, 0x8924,
&(0x7f00008d8000)=3D{"4682049c0228afcdfa4945e37a244a3a",
@data=3D"ecefff20cec4768429383ab454036dad"})
ioctl$TUNSETPERSIST(r3, 0x400454cb, &(0x7f0000fbb000-0x4)=3D0x1)
mmap(&(0x7f0000fbc000/0x1000)=3Dnil, (0x1000), 0x3, 0x32, 0xfffffffffffffff=
f, 0x0)
mmap(&(0x7f0000fbc000/0x1000)=3Dnil, (0x1000), 0x3, 0x32, 0xfffffffffffffff=
f, 0x0)
getsockopt$dccp6_int(r3, 0x21, 0x1, &(0x7f0000fbc000)=3D0x0,
&(0x7f0000fbd000-0x4)=3D0x4)
ioctl$SIOCKCMATTACH(r4, 0x89e0, &(0x7f0000b5c000)=3D{r1, r2})
ioctl$SIOCKCMUNATTACH(r4, 0x89e1, &(0x7f0000fb5000)=3D{r1})
