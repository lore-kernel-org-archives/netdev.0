From: Dison River <pwn2river@gmail.com>
Subject: kernel 3.18.57 :WARNING in dev_watchdog
Date: Wed, 21 Jun 2017 17:04:32 +0800
Message-ID: <CAJsXRPHr6gthu+6MT0dNKdmMhKJ6VytmiLOyh1virkfi5naWZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: syzkaller@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:
I've got the following error report while fuzzing the kernel with
syzkaller on linux-3.18.57.

I'd submitted a similar bug On June 15th:
https://mail.google.com/mail/#inbox/15c9ae21d9300405?compose=3D15cc9df0658a=
7669

But this time i got some reproducer in linux-3.18.57(no kov)

---------------------

Syzkaller hit 'WARNING in dev_watchdog' bug on commit .

The guilty file is: net/sched/sch_generic.c.

------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:306
dev_watchdog+0x61b/0x860
/home/river/git_new/linux-stable/net/sched/sch_generic.c:305()
NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
Kernel panic - not syncing: panic_on_warn set ...

CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.1.40 #4
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
 ffffffff8332a160 ffff88003ed07a78 ffffffff82e9d411 ffffffff8303be80
 ffff88003eb72660 ffff88003ed07b38 ffffffff82e99dc6 0000000041b58ab3
 ffffffff83552ae6 ffffffff82e99c53 00000000ffffffff ffff880000000008
Call Trace:
 <IRQ>  [<ffffffff82e9d411>] __dump_stack
/home/river/git_new/linux-stable/lib/dump_stack.c:15 [inline]
 <IRQ>  [<ffffffff82e9d411>] dump_stack+0x68/0x92
/home/river/git_new/linux-stable/lib/dump_stack.c:51
 [<ffffffff82e99dc6>] panic+0x173/0x2c8
/home/river/git_new/linux-stable/kernel/panic.c:112
 [<ffffffff810f08be>] warn_slowpath_common+0x10e/0x120
/home/river/git_new/linux-stable/kernel/panic.c:454
 [<ffffffff810f095b>] warn_slowpath_fmt+0x8b/0xb0
/home/river/git_new/linux-stable/kernel/panic.c:470
 [<ffffffff827780fb>] dev_watchdog+0x61b/0x860
/home/river/git_new/linux-stable/net/sched/sch_generic.c:305
 [<ffffffff812338ee>] call_timer_fn+0x17e/0x8c0
/home/river/git_new/linux-stable/kernel/time/timer.c:1153
 [<ffffffff812345d3>] __run_timers
/home/river/git_new/linux-stable/kernel/time/timer.c:1225 [inline]
 [<ffffffff812345d3>] run_timer_softirq+0x5a3/0xbb0
/home/river/git_new/linux-stable/kernel/time/timer.c:1415
 [<ffffffff810ffb47>] __do_softirq+0x247/0xc40
/home/river/git_new/linux-stable/kernel/softirq.c:273
 [<ffffffff8110080d>] invoke_softirq
/home/river/git_new/linux-stable/kernel/softirq.c:350 [inline]
 [<ffffffff8110080d>] irq_exit+0x16d/0x1a0
/home/river/git_new/linux-stable/kernel/softirq.c:391
 [<ffffffff810a93cb>] exiting_irq
/home/river/git_new/linux-stable/./arch/x86/include/asm/apic.h:649
[inline]
 [<ffffffff810a93cb>] smp_apic_timer_interrupt+0x7b/0xa0
/home/river/git_new/linux-stable/arch/x86/kernel/apic/apic.c:922
 [<ffffffff82ebae20>] apic_timer_interrupt+0x70/0x80
/home/river/git_new/linux-stable/arch/x86/kernel/entry_64.S:921
 <EOI>  [<ffffffff81022c72>] ? native_safe_halt
/home/river/git_new/linux-stable/./arch/x86/include/asm/irqflags.h:49
[inline]
 <EOI>  [<ffffffff81022c72>] ? arch_safe_halt
/home/river/git_new/linux-stable/./arch/x86/include/asm/irqflags.h:91
[inline]
 <EOI>  [<ffffffff81022c72>] ? default_idle+0x52/0x510
/home/river/git_new/linux-stable/arch/x86/kernel/process.c:341
 [<ffffffff81024e7a>] arch_cpu_idle+0xa/0x10
/home/river/git_new/linux-stable/arch/x86/kernel/process.c:332
 [<ffffffff811c451b>] cpuidle_idle_call
/home/river/git_new/linux-stable/kernel/sched/idle.c:195 [inline]
 [<ffffffff811c451b>] cpu_idle_loop
/home/river/git_new/linux-stable/kernel/sched/idle.c:249 [inline]
 [<ffffffff811c451b>] cpu_startup_entry+0x60b/0x9d0
/home/river/git_new/linux-stable/kernel/sched/idle.c:297
 [<ffffffff810a3466>] start_secondary+0x2c6/0x370
/home/river/git_new/linux-stable/arch/x86/kernel/smpboot.c:269
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled


Syzkaller reproducer:
# {Threaded:true Collide:true Repeat:true Procs:4 Sandbox:setuid
Fault:false FaultCall:-1 FaultNth:0 EnableTun:true UseTmpDir:true
HandleSegv:true WaitRepeat:true Debug:true Repro:false}
mmap(&(0x7f0000000000/0x7000)=3Dnil, (0x7000), 0x3, 0x32, 0xfffffffffffffff=
f, 0x0)
prctl$setname(0xf, &(0x7f0000e79000-0x9)=3D"766d6e6574312a5c00")
r0 =3D openat$sequencer(0xffffffffffffff9c,
&(0x7f0000001000-0xf)=3D"2f6465762f73657175656e63657200", 0x2000, 0x0)
getsockopt$inet6_tcp_buf(r0, 0x6, 0xb, &(0x7f0000008000-0x3)=3D"000000",
&(0x7f0000000000)=3D0x3)
setsockopt$inet6_dccp_int(r0, 0x21, 0x1f, &(0x7f0000000000)=3D0x8, 0x4)
setsockopt$netrom_NETROM_T1(r0, 0x103, 0x1, &(0x7f0000001000-0x1)=3D0x400, =
0x4)
restart_syscall()
sendmsg(r0, &(0x7f0000001000)=3D{&(0x7f0000000000)=3D@nfc_llcp=3D{0x27, 0x2=
,
0x1f, 0x7, 0x400000000, 0x8,
"2e43ffe8a1efff7082966d59dc63fb7b038d0b301ad968c049e6eab68531ffd09895f1252a=
3c3449d67112ac2d73e28a2e8c45e700a0be61cf7cbc415309d9",
0x4896aa2e}, 0x60,
&(0x7f0000002000-0x60)=3D[{&(0x7f0000002000-0x77)=3D"3c724a66b29ea0e9f68525=
3f3c68885f88112c31f498f7f289d24a2df7cf7cb6fb9bde0a48e14cb82092031fdedfc77da=
56691b466e4824a3533eeb40e8159af04ba3eb84c6e13cacf4bfc2139e4cac6f7a0e6343b95=
007d88f2b928c180f321b734e40fd851ccf81d489cea5f5092518e8f39baceb427",
0x77}, {&(0x7f0000000000)=3D"656cbe5176961c6ce6b7d0113c76a6e9d4b6ba612f984d=
9d3f051c8eb6e64fcdcb2546346b4f75382dd42873ab49a710289bbd1da08b9e84071fe0169=
013c420c323292e02f2b10912c7c44fff1ff47dae6d1fc72cd92b3e4282a86b54f6d924f124=
301219b2fc56cedb1e233bf3fc80bdf8decf4bdaf1bba90187ddaad0d241b9cb520d3692766=
904cece5ff7f4363ad5c3f27adf170e2a5e7136a1",
0x9c}, {&(0x7f0000001000+0x139)=3D"7a8577da4015fcff617fdc873cddf4427756e2b7=
d9dee85ac483ffd38595245dae73b838b96c8c30d38865d62062681875d97a2e91079544555=
f7fd7ca",
0x3d}, {&(0x7f0000000000)=3D"d43897b4293a22cb65ac4bf96e938d978a3f84331ed2c9=
235eb70793dfd9990288ea6e01d266c8d2948efd654671486e8adad99333289c422d2fa4d1d=
db820754873382214cbc4195d74127b69ca8007e67da45e515d50fbb04d8f30b64eb0f063f4=
c42a65",
0x65}, {&(0x7f0000000000)=3D"aad73d321062a25e3c0e2ceda79edab2feb8a42240efea=
41ebd6fcf0c795c67f0870afefc2ff1b37a4e7e9f446aa761a9d4f3b811b72da68bd7c10c63=
a42ed28d31146bdf3f0aa31a5ad04b66f4ff665b8d1431dcfdedb9212b76aa1507b69a4395f=
28310aa9da11ad91f086a919bb86b4655524845599640c759fac84a091e765a019f0c7c1127=
e9315a0893b6352ff6afcdcec15ec79f8ba33e43e5504fd09ee397e49c10e9105",
0xa8}, {&(0x7f0000001000)=3D"f51692a41a76258e297695886580d7f25b267d95e75b5c=
7e00933c5153831d9cfcc1489c7fbef67503ad422647a7fef7e83f4e69889ba4b0c05c7daec=
e229154b7d28636926e8b82b4ebf556f52b4a7b98989aace0c308dd3f291dc279522b51e8ea=
f50e16958ea9a77f0e44f4de3e2a1e44c386b4720552d83c8881f1f38aa7aee4944a2db6e35=
b12755364790f5c9f8f518643380c5822a6115f6fdd5c27564d070decf73a75bfe6a1b4446c=
7253b58f44741426f00a4aa80919d5945fd5f646558d",
0xc3}], 0x6, &(0x7f0000002000-0x50)=3D[{0x50, 0x10e, 0xfff,
"43ac4324705e46550d0efc7d565472d2a131f326265a387c8361e4008030998dd42eef57cc=
2dfaa4572b69863f39f4754769bff62402238d048eaf88"}],
0x1, 0x40000}, 0x48000)
ioctl$LOOP_SET_FD(r0, 0x4c00, r0)
getsockopt$inet_sctp_SCTP_GET_ASSOC_NUMBER(r0, 0x84, 0x1c,
&(0x7f0000001000-0x4)=3D0x0, &(0x7f0000002000)=3D0x4)
setsockopt$inet_sctp6_SCTP_FRAGMENT_INTERLEAVE(r0, 0x84, 0x12,
&(0x7f0000004000-0x4)=3D0x3, 0x4)
ioctl$sock_inet_SIOCGIFPFLAGS(r0, 0x8935,
&(0x7f0000004000)=3D{@generic=3D"53c1980984f9f331d708455db9641d7f",
@ifru_flags=3D0x0})
ioctl$PIO_FONTRESET(r0, 0x4b6d, 0x0)
syz_open_dev$usbmon(&(0x7f0000006000-0xd)=3D"2f6465762f7573626d6f6e2300",
0x5, 0x0)
