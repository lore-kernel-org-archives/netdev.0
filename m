From: alexander.levin@verizon.com
Subject: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Mon, 10 Apr 2017 19:03:30 +0000
Message-ID: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Content-ID: <276106CB9514E24A81986E474023EA8F@vzwcorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I seem to be hitting this use-after-free on a -next kernel using trinity:

[  531.036054] BUG: KASAN: use-after-free in prb_retire_rx_blk_timer_expire=
d (net/packet/af_packet.c:688)                                             =
        [  531.036961] Read of size 8 at addr ffff88038c1fb0e8 by task swap=
per/1/0                                                                    =
                [  531.037727]                                             =
                                                                           =
                        [  531.037928] CPU: 1 PID: 0 Comm: swapper/1 Not ta=
inted 4.11.0-rc5-next-20170407-dirty #24
[  531.038862] Call Trace:
[  531.039163]  <IRQ>
[  531.039447] dump_stack (lib/dump_stack.c:54)=20
[  531.041612] print_address_description (mm/kasan/report.c:253)=20
[  531.042809] kasan_report (mm/kasan/report.c:352 mm/kasan/report.c:408)=20
[  531.043263] __asan_report_load8_noabort (mm/kasan/report.c:429)=20
[  531.043829] prb_retire_rx_blk_timer_expired (net/packet/af_packet.c:688)=
=20
[  531.048298] call_timer_fn.isra.15 (./arch/x86/include/asm/preempt.h:22 k=
ernel/time/timer.c:1246)=20
[  531.048805] __run_timers (./include/linux/spinlock.h:324 kernel/time/tim=
er.c:1308 kernel/time/timer.c:1601)=20
[  531.055404] run_timer_softirq (kernel/time/timer.c:1614)=20
[  531.055883] __do_softirq (./arch/x86/include/asm/preempt.h:22 kernel/sof=
tirq.c:286)=20
[  531.057507] irq_exit (kernel/softirq.c:364 kernel/softirq.c:405)=20
[  531.057893] smp_apic_timer_interrupt (arch/x86/kernel/apic/apic.c:965)=20
[  531.058446] apic_timer_interrupt (arch/x86/entry/entry_64.S:704)=20
[  531.058951] RIP: 0010:native_safe_halt (??:?)=20
[  531.059718] RSP: 0018:ffff88039aa8fe88 EFLAGS: 00000246 ORIG_RAX: ffffff=
ffffffff10
[  531.060593] RAX: 0000000000080000 RBX: ffff88039aa68fc0 RCX: 00000000000=
00000
[  531.061411] RDX: 1ffff1007354d1f8 RSI: 0000000000000000 RDI: 00000000000=
00000
[  531.062203] RBP: ffff88039aa8fe88 R08: ffff880376251bc0 R09: 00000000000=
00001
[  531.063001] R10: ffff88038e0f7838 R11: 0000000000000001 R12: ffff88039aa=
68fc0
[  531.064007] R13: ffffffff83df0028 R14: 0000000000000000 R15: ffff88039aa=
68fc0
[  531.064811]  </IRQ>
[  531.065886] default_idle (./arch/x86/include/asm/paravirt.h:98 arch/x86/=
kernel/process.c:341)=20
[  531.066284] arch_cpu_idle (arch/x86/kernel/process.c:333)=20
[  531.066692] default_idle_call (kernel/sched/idle.c:101)=20
[  531.067151] do_idle (kernel/sched/idle.c:156 kernel/sched/idle.c:245)=20
[  531.067537] cpu_startup_entry (kernel/sched/idle.c:350 (discriminator 1)=
)=20
[  531.067992] start_secondary (arch/x86/kernel/smpboot.c:276)=20
[  531.068444] secondary_startup_64 (arch/x86/kernel/verify_cpu.S:37)=20
[  531.068924]                                                             =
                                                                           =
        [  531.069109] Allocated by task 18982:                            =
                                                                           =
                [  531.069522] save_stack_trace (arch/x86/kernel/stacktrace=
.c:60)                                                                     =
                        [  531.069965] save_stack (mm/kasan/kasan.c:493 mm/=
kasan/kasan.c:514)=20
[  531.070347] kasan_kmalloc (mm/kasan/kasan.c:525 mm/kasan/kasan.c:617)=20
[  531.070757] __kmalloc (mm/slub.c:3747)=20
[  531.071153] packet_set_ring (net/packet/af_packet.c:4130 net/packet/af_p=
acket.c:4218)=20
[  531.072024] packet_setsockopt (net/packet/af_packet.c:3617)=20
[  531.072525] SyS_setsockopt (net/socket.c:1797 net/socket.c:1777)=20
[  531.072968] do_syscall_64 (arch/x86/entry/common.c:284)=20
[  531.073405] return_from_SYSCALL_64 (arch/x86/entry/entry_64.S:249)=20
[  531.073893]=20
[  531.074076] Freed by task 7019:
[  531.074443] save_stack_trace (arch/x86/kernel/stacktrace.c:60)=20
[  531.074882] save_stack (mm/kasan/kasan.c:493 mm/kasan/kasan.c:514)
[  531.075275] kasan_slab_free (mm/kasan/kasan.c:525 mm/kasan/kasan.c:590)=
=20
[  531.075705] kfree (mm/slub.c:2966 mm/slub.c:3882)=20
[  531.076052] free_pg_vec (net/packet/af_packet.c:4096)=20
[  531.076448] packet_set_ring (net/packet/af_packet.c:4298)=20
[  531.076922] packet_setsockopt (net/packet/af_packet.c:3617)=20
[  531.077406] SyS_setsockopt (net/socket.c:1797 net/socket.c:1777)=20
[  531.077848] do_syscall_64 (arch/x86/entry/common.c:284)=20
[  531.078285] return_from_SYSCALL_64 (arch/x86/entry/entry_64.S:249)=20
[  531.078773]=20
[  531.078956] The buggy address belongs to the object at ffff88038c1fb0e8
[  531.078956]  which belongs to the cache kmalloc-8 of size 8
[  531.080341] The buggy address is located 0 bytes inside of
[  531.080341]  8-byte region [ffff88038c1fb0e8, ffff88038c1fb0f0)
[  531.081600] The buggy address belongs to the page:
[  531.082150] page:ffffea000e307e80 count:1 mapcount:0 mapping:          (=
null) index:0xffff88038c1fbd90 compound_mapcount: 0
[  531.083613] flags: 0x2fffc0000008100(slab|head)
[  531.084139] raw: 02fffc0000008100 0000000000000000 ffff88038c1fbd90 0000=
000100160015
[  531.085010] raw: ffffea000e417ea0 ffffea000e421520 ffff88039c4103c0 0000=
000000000000
[  531.085875] page dumped because: kasan: bad access detected
[  531.086504]=20
[  531.086686] Memory state around the buggy address:
[  531.087242]  ffff88038c1faf80: fb fc fc fc fc fc fc fc fc fc fc fc fc fc=
 fc fc
[  531.088054]  ffff88038c1fb000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc=
 fc fc
[  531.088873] >ffff88038c1fb080: fc fc fc fc fc fc fc fc fc fc fc fc fc fb=
 fc fc
[  531.089679]                                                           ^
[  531.090425]  ffff88038c1fb100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc=
 fc fc
[  531.091433]  ffff88038c1fb180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc=
 fc fc
[  531.092240] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  531.093054] Disabling lock debugging due to kernel taint
[  533.819741] ODEBUG: free active (active state 0) object type: timer_list=
 hint: prb_retire_rx_blk_timer_expired (net/packet/af_packet.c:679)=20
[  533.822564] ------------[ cut here ]------------
[  533.823119] WARNING: CPU: 7 PID: 1226 at lib/debugobjects.c:289 debug_pr=
int_object (lib/debugobjects.c:286)=20
[  533.824111] Modules linked in:
[  533.824471] CPU: 7 PID: 1226 Comm: trinity-main Tainted: G    B         =
  4.11.0-rc5-next-20170407-dirty #24
[  533.825558] task: ffff880395cedd40 task.stack: ffff880395e90000
[  533.826235] RIP: 0010:debug_print_object (??:?)=20
[  533.826788] RSP: 0018:ffff880395e974d0 EFLAGS: 00010082
[  533.827375] RAX: 000000000000006c RBX: 0000000000000003 RCX: 00000000000=
00000
[  533.828171] RDX: 000000000000006c RSI: 1ffff10072bd2e39 RDI: ffffed0072b=
d2e90
[  533.828963] RBP: ffff880395e974f8 R08: 203a47554245444f R09: 65657266203=
a4755
[  533.829779] R10: ffffed0072bd2ec9 R11: 0000000000001638 R12: ffffffff834=
59660
[  533.830576] R13: ffffffff82fd2b20 R14: 0000000000000000 R15: dffffc00000=
00000
[  533.831395] FS:  00007fec989f4700(0000) GS:ffff88039cbc0000(0000) knlGS:=
0000000000000000
[  533.832296] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  533.832941] CR2: 0000000000000008 CR3: 0000000395ea2000 CR4: 00000000000=
406a0
[  533.833736] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[  533.834523] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00600
[  533.835351] Call Trace:
[  533.835642] debug_check_no_obj_freed (lib/debugobjects.c:744 lib/debugob=
jects.c:772)=20
[  533.840679] kfree (mm/slub.c:1357 mm/slub.c:1379 mm/slub.c:2961 mm/slub.=
c:3882)=20
[  533.841025] __sk_destruct (net/core/sock.c:1458 net/core/sock.c:1536)=20
[  533.845132] sk_destruct (net/core/sock.c:1545)=20
[  533.845527] __sk_free (net/core/sock.c:1553)=20
[  533.845919] sk_free (net/core/sock.c:1564)=20
[  533.846274] packet_release (net/packet/af_packet.c:2941)=20
[  533.850968] sock_release (net/socket.c:598)=20
[  533.851813] sock_close (net/socket.c:1074)=20
[  533.852195] __fput (fs/file_table.c:210)=20
[  533.853779] ____fput (fs/file_table.c:246)=20
[  533.854143] task_work_run (kernel/task_work.c:118 (discriminator 1))=20
[  533.855516] exit_to_usermode_loop (./include/linux/tracehook.h:193 arch/=
x86/entry/common.c:161)=20
[  533.856803] do_syscall_64 (./arch/x86/include/asm/current.h:14 arch/x86/=
entry/common.c:208 arch/x86/entry/common.c:263 arch/x86/entry/common.c:289)=
=20
[  533.860762] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:249)=20
[  533.861294] RIP: 0033:0x7fec982f9d10
[  533.861703] RSP: 002b:00007ffffc92d5a8 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000003
[  533.862536] RAX: 0000000000000000 RBX: 0000000002cb2cf0 RCX: 00007fec982=
f9d10
[  533.863349] RDX: 000000000000000d RSI: 0000000000000002 RDI: 00000000000=
00179
[  533.864149] RBP: 0000000000000179 R08: 0000000000000008 R09: 00007fec989=
f4700
[  533.864930] R10: 00007ffffc92d5b0 R11: 0000000000000246 R12: 00000000000=
00000
[  533.865729] R13: 00007fec989ef1a0 R14: 0000000000000000 R15: 00000000000=
00000                                                                      =
        [ 533.866521] Code: 0d 48 89 75 d8 e8 20 01 8b ff 48 8b 75 d8 48 8b=
 14 dd 40 8f 51 83 4d 89 e9 4d 89 e0 44 89 f1 48 c7 c7 e0 85 51 83 e8 d3 29=
 75 ff <0f> ff 83 05 2a 1e 16 02 01 48 83 c4 08 5b 41 5c 41 5d 41 5e 5d=20
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   0d 48 89 75 d8          or     $0xd8758948,%eax
   5:   e8 20 01 8b ff          callq  0xffffffffff8b012a
   a:   48 8b 75 d8             mov    -0x28(%rbp),%rsi
   e:   48 8b 14 dd 40 8f 51    mov    -0x7cae70c0(,%rbx,8),%rdx
  15:   83=20
  16:   4d 89 e9                mov    %r13,%r9
  19:   4d 89 e0                mov    %r12,%r8
  1c:   44 89 f1                mov    %r14d,%ecx
  1f:   48 c7 c7 e0 85 51 83    mov    $0xffffffff835185e0,%rdi
  26:   e8 d3 29 75 ff          callq  0xffffffffff7529fe
  2b:*  0f ff                   (bad)           <-- trapping instruction
  2d:   83 05 2a 1e 16 02 01    addl   $0x1,0x2161e2a(%rip)        # 0x2161=
e5e
  34:   48 83 c4 08             add    $0x8,%rsp
  38:   5b                      pop    %rbx
  39:   41 5c                   pop    %r12
  3b:   41 5d                   pop    %r13
  3d:   41 5e                   pop    %r14
  3f:   5d                      pop    %rbp
        ...

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:   0f ff                   (bad) =20
   2:   83 05 2a 1e 16 02 01    addl   $0x1,0x2161e2a(%rip)        # 0x2161=
e33
   9:   48 83 c4 08             add    $0x8,%rsp
   d:   5b                      pop    %rbx
   e:   41 5c                   pop    %r12
  10:   41 5d                   pop    %r13
  12:   41 5e                   pop    %r14
  14:   5d                      pop    %rbp
        ...
[  533.868922] ---[ end trace eb76f4e0fb42fae2 ]---
--=20

Thanks,
Sasha=
