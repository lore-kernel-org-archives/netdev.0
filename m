From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: e1000 w/ NAPI + SMP = 99% CPU utilization
Date: Wed, 9 Jun 2004 09:51:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16582.49526.374109.580312@robur.slu.se>
References: <BAY1-F139xaq8HCdrWi0004e64b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: P@draigBrady.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chris Carpinello" <chriscarpinello@hotmail.com>
In-Reply-To: <BAY1-F139xaq8HCdrWi0004e64b@hotmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Chris Carpinello writes:

Hello!

Is seems like your network load @ ~202 Mbps gets you system into=20
continuing polling as we see very few interrupts on your eth3.
This means that rx_softirq reschedules itself do_softirq() kicks
ksoftird to prevent the rx_softirq from monopolize the system.
So now all the work gets accounted in ksoftird  And by design=20
->poll is strictly serialized per device to guarantee ordering and=20
avoid cache bouncing we only see one ksoftirq used as use only have=20
one input device.

P=E1draig suggest binding to separate CPU's. This is normally a good=20
thing but as you only have one input device it will not help.

And didn't we just see a fix for ifconfig down oops?

Cheers.
					--ro


 > >Padraig wrote:
 > >At what packet rate does it go to 100%?
 >=20
 > I haven't narrowed down a threshold.  tcpstat reports bps=3D202737465
 > on eth3.  eth0 is a management interface (doesn't packet sniff).  eth1
 > and eth2 are ifconfig'd down.
 >=20
 > >Anyway it's not much to worry about as
 > >it's in polling mode.
 >=20
 > I'm concerned because when I ifconfig down eth3 the kernel panics.
 > Under high traffic loads, the box will panic as well.  Here's the oops=
,
 > which is hand copied from the console:
 >=20
 > Oops: 0002 [#1]
 > SMP
 > CPU: 0
 > EIP: 0060:[<c0367896>] Not tainted
 > EFLAGS: 00010002 (2.6.5)
 > EIP is at net_rx_action+0x86/0x120
 > eax: 00200200 ebx: df22b0fc ecx: 0000009d edx: 00100100
 > esi: df22b000 edi: c1508840 ebp: fffe4c97 esp: dff8bf78
 > ds: 007b es: 007b ss: 0068
 > Process ksoftirqd/0 (pid: 3, threadinfo=3Ddff8a000 task=3Ddff90600)
 > Stack:
 > df22b000 df8bf80 000000ec 00000001 c04f1c18 0000000a 00000246 c0126a7a
 > c04f1c18 dff8a000 dff8a000 dff8a000 c0126f10 c0126f95 dff90600 0000001=
3
 > dff8a000 dff93f74 00000000 c01367aa 00000000 00000003 00000000 fffffff=
c
 > Call Trace:
 > [<c0126a7a>] do_softirq+0xca/0xd0
 > [<c0126f10>] ksoftirqd+0x0/0xd0
 > [<c0126f95>] ksoftirqd+0x85/0xd0
 > [<c01367aa>] kthread+0xba/0xc0
 > [<c01366f0>] kthread+0x0/0xc0
 > [<c01072f5>] kernel_thread_helper+0x5/0x10
 > Code: 89 42 04 89 10 8d 57 1c c7 43 04 00 02 20 00 8b 42 04 89 13
 > <0> Kernel panic: Fatal exception in interrupt
 >   In interrupt handler - not syncing
 >=20
 > >One thing which should help is to share
 > >the work across your CPUs. `cat /proc/interrupts`
 > >will show the interrupts for your nics.
 >=20
 > # cat /proc/interrupts
 >            CPU0       CPU1
 >   0:    3758655    3223347    IO-APIC-edge  timer
 >   1:          2          7    IO-APIC-edge  i8042
 >   2:          0          0          XT-PIC  cascade
 >   8:          1          0    IO-APIC-edge  rtc
 >   9:          0          0   IO-APIC-level  acpi
 > 14:         22          7    IO-APIC-edge  ide0
 > 16:         11         11   IO-APIC-level  eth1
 > 17:       5471       5475   IO-APIC-level  eth0
 > 18:       1790       1794   IO-APIC-level  aic7xxx
 > 19:         15         15   IO-APIC-level  aic7xxx
 > 20:          2          1   IO-APIC-level  eth2
 > 24:       1549       1349   IO-APIC-level  eth3
 > NMI:          0          0
 > LOC:    6982002    6982001
 > ERR:          0
 > MIS:          0
 >=20
 > >Then you can bind the interrupt to a particular CPU like:
 > >
 > >echo 1 > /proc/irq/$num/smp_affinity
 > >echo 2 > /proc/irq/$num/smp_affinity
 > >echo 4 > /proc/irq/$num/smp_affinity
 > >echo 8 > /proc/irq/$num/smp_affinity
 >=20
 > Setting the mask has no noticeable effect on ksoftirqd's
 > behavior.
 >=20
 > - Chris
 >=20
 >=20
