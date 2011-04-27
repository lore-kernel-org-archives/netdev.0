From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 27 Apr 2011 06:24:00 +0200
Message-ID: <1303878240.2699.41.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201104250033.03401.maxi@daemonizer.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 25 avril 2011 =C3=A0 00:32 +0200, Maximilian Engelhardt a =C3=A9=
crit :
> Hello,
>=20
> some time ago we switched some of our servers to a new networking car=
d that=20
> uses the Intel igb driver. Since that time we see regular kernel cras=
hes.
> The crashes happen at very irregular intervals, sometimes after a wee=
k uptime,=20
> sometimes after a month or even more. They seem to be independent of =
the=20
> server load as they also happen in the night when there is low traffi=
c.
>=20
> The affected server is used as a NAT device with some iptables rules =
and serves=20
> about 2000 people.
>=20
> Attached are two logs of the crashes as well as the output of dmesg, =
lspci,=20
> and /proc/interrupts as well as the used kernel config.
>=20
> I have no idea what might be wrong but I think it is a kernel bug. Pe=
rhaps=20
> someone with more knowledge has a clue.
>=20
> If needed I can provide additional information or build different ker=
nels.
>=20
> Greetings,
> Maxi

Hello Maximilian

We had similar reports in the past that disappeared when adding
"slab_nomerge" to boot parameters. We suspect a memory corruption from
another part of kernel on 64bytes kmemcache objects.

In 2.6.37, inetpeer code uses 64bytes objects. Using slab_nomerge and
SLUB allocator (as you already do), makes sure inetpeer kmemcache wont
be shared by other 64bytes objects in kernel.

In 2.6.38 and up, inetpeer objects are now larger, so you also could tr=
y
latest linux-2.6 tree, just to make sure inetpeer code is not faulty.

Thanks

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
IP: [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
PGD 12d82a067 PUD 12ea49067 PMD 0
Oops: 0002 [#1] PREEMPT SMP
last sysfs file: /sys/devices/virtual/vc/vcsa5/uevent
CPU 0
Pid: 0, comm: swapper Not tainted 2.6.37.1 #1 Supermicro X7SB4/E/X7SB4/=
E
RIP: 0010:[<ffffffff8145ea9f>]  [<ffffffff8145ea9f>] cleanup_once+0x3f/=
0xa0
RSP: 0018:ffff8800cfc03e40  EFLAGS: 00010202
RAX: ffff880128167798 RBX: ffff880128167780 RCX: 0000000000000000
RDX: c398112e00026cf7 RSI: 00000000000001a2 RDI: ffffffff8166ce10
RBP: 0000000000024702 R08: 00000000003d0900 R09: 00040ea8ea5b7700
R10: ffffffff814f312d R11: 0000000000000010 R12: ffffffff8161ffd8
R13: 0000000000000102 R14: ffffffff8174b4e0 R15: ffffffff8161ffd8
=46S:  0000000000000000(0000) GS:ffff8800cfc00000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000012fe67000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff8161e000, task ffffffff8163=
8020)
Stack:
 ffff8800cfc11f00 0000000111034f87 0000000000024702 ffffffff8145ed68
 ffffffff8174a4c0 ffffffff8174a4c0 ffff8800cfc03eb0 ffffffff81044cb8
 ffffffff81034079 ffffffff8145ed30 0000000000000000 ffffffff8174b8e0
Call Trace:
 <IRQ>
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>
 [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7
Code: 00 48 8b 05 84 e3 20 00 48 3d 00 ce 66 81 74 5c 48 8d 58 e8 48 8b=
 15 31 5e 22 00 2b 53 28 48 39 ea 72 49 48 8b 4b 18 48 8b 53 20 <48> 89=
 51 08 48 89 0a 48 89 43 18 48 89 43 20 f0 ff 40 14 48 c7
RIP  [<ffffffff8145ea9f>] cleanup_once+0x3f/0xa0
 RSP <ffff8800cfc03e40>
CR2: 0000000000000008
---[ end trace 904f16191de0663c ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.37.1 #1
Call Trace:
 <IRQ>  [<ffffffff814e4152>] ? panic+0xa1/0x19e
 [<ffffffff810068eb>] ? oops_end+0x9b/0xa0
 [<ffffffff81024523>] ? no_context+0x103/0x270
 [<ffffffff81024d10>] ? do_page_fault+0x290/0x430
 [<ffffffff813eabd2>] ? __alloc_skb+0x72/0x160
 [<ffffffff81262f40>] ? swiotlb_dma_mapping_error+0x10/0x20
 [<ffffffff8133e168>] ? igb_alloc_rx_buffers_adv+0x208/0x3a0
 [<ffffffff814e780f>] ? page_fault+0x1f/0x30
 [<ffffffff8145ea9f>] ? cleanup_once+0x3f/0xa0
 [<ffffffff8145ed68>] ? peer_check_expire+0x38/0x110
 [<ffffffff81044cb8>] ? run_timer_softirq+0x138/0x250
 [<ffffffff81034079>] ? scheduler_tick+0xd9/0x2e0
 [<ffffffff8145ed30>] ? peer_check_expire+0x0/0x110
 [<ffffffff8103eb0d>] ? __do_softirq+0x9d/0x130
 [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100531d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103e9cd>] ? irq_exit+0x8d/0x90
 [<ffffffff8101d5ea>] ? smp_apic_timer_interrupt+0x6a/0xa0
 [<ffffffff81002cd3>] ? apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8100a93a>] ? mwait_idle+0x6a/0x80
 [<ffffffff81001528>] ? cpu_idle+0x58/0xb0
 [<ffffffff81698dd3>] ? start_kernel+0x334/0x33f
 [<ffffffff8169840d>] ? x86_64_start_kernel+0xf3/0xf7
