From: "Chris Carpinello" <chriscarpinello@hotmail.com>
Subject: Re: e1000 w/ NAPI + SMP = 99% CPU utilization
Date: Tue, 08 Jun 2004 14:14:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY1-F139xaq8HCdrWi0004e64b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>Padraig wrote:
>At what packet rate does it go to 100%?

I haven't narrowed down a threshold.  tcpstat reports bps=202737465
on eth3.  eth0 is a management interface (doesn't packet sniff).  eth1
and eth2 are ifconfig'd down.

>Anyway it's not much to worry about as
>it's in polling mode.

I'm concerned because when I ifconfig down eth3 the kernel panics.
Under high traffic loads, the box will panic as well.  Here's the oops,
which is hand copied from the console:

Oops: 0002 [#1]
SMP
CPU: 0
EIP: 0060:[<c0367896>] Not tainted
EFLAGS: 00010002 (2.6.5)
EIP is at net_rx_action+0x86/0x120
eax: 00200200 ebx: df22b0fc ecx: 0000009d edx: 00100100
esi: df22b000 edi: c1508840 ebp: fffe4c97 esp: dff8bf78
ds: 007b es: 007b ss: 0068
Process ksoftirqd/0 (pid: 3, threadinfo=dff8a000 task=dff90600)
Stack:
df22b000 df8bf80 000000ec 00000001 c04f1c18 0000000a 00000246 c0126a7a
c04f1c18 dff8a000 dff8a000 dff8a000 c0126f10 c0126f95 dff90600 00000013
dff8a000 dff93f74 00000000 c01367aa 00000000 00000003 00000000 fffffffc
Call Trace:
[<c0126a7a>] do_softirq+0xca/0xd0
[<c0126f10>] ksoftirqd+0x0/0xd0
[<c0126f95>] ksoftirqd+0x85/0xd0
[<c01367aa>] kthread+0xba/0xc0
[<c01366f0>] kthread+0x0/0xc0
[<c01072f5>] kernel_thread_helper+0x5/0x10
Code: 89 42 04 89 10 8d 57 1c c7 43 04 00 02 20 00 8b 42 04 89 13
<0> Kernel panic: Fatal exception in interrupt
  In interrupt handler - not syncing

>One thing which should help is to share
>the work across your CPUs. `cat /proc/interrupts`
>will show the interrupts for your nics.

# cat /proc/interrupts
           CPU0       CPU1
  0:    3758655    3223347    IO-APIC-edge  timer
  1:          2          7    IO-APIC-edge  i8042
  2:          0          0          XT-PIC  cascade
  8:          1          0    IO-APIC-edge  rtc
  9:          0          0   IO-APIC-level  acpi
14:         22          7    IO-APIC-edge  ide0
16:         11         11   IO-APIC-level  eth1
17:       5471       5475   IO-APIC-level  eth0
18:       1790       1794   IO-APIC-level  aic7xxx
19:         15         15   IO-APIC-level  aic7xxx
20:          2          1   IO-APIC-level  eth2
24:       1549       1349   IO-APIC-level  eth3
NMI:          0          0
LOC:    6982002    6982001
ERR:          0
MIS:          0

>Then you can bind the interrupt to a particular CPU like:
>
>echo 1 > /proc/irq/$num/smp_affinity
>echo 2 > /proc/irq/$num/smp_affinity
>echo 4 > /proc/irq/$num/smp_affinity
>echo 8 > /proc/irq/$num/smp_affinity

Setting the mask has no noticeable effect on ksoftirqd's
behavior.

- Chris
