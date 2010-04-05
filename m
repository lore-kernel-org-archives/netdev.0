From: Taylor Lewick <taylor.lewick@gmail.com>
Subject: Re: Increased Latencies when upgrading kernel version
Date: Mon, 5 Apr 2010 12:34:54 -0500
Message-ID: <m2jd585dc4f1004051034ka36301d6xdce95defe6388836@mail.gmail.com>
References: <o2vd585dc4f1004011212s65cc2beewed2f19321210a249@mail.gmail.com>
	 <1270156741.2192.14.camel@edumazet-laptop>
	 <r2pd585dc4f1004011853q405eaadcq14b50a9e7a4dcf21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f201.google.com ([209.85.221.201]:46140 "EHLO
	mail-qy0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab0DERmN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 13:42:13 -0400
In-Reply-To: <r2pd585dc4f1004011853q405eaadcq14b50a9e7a4dcf21@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay, don't know what to officially file this under, as a regression
with regards to performance or what, but here is the data.  Again,
I've noticed system and network latency appear to have worsened with
later kernel versions.

I was turned onto this problem via the following links:
http://www.kernel.org/pub/linux/kernel/people/christoph/ols2009/ols-200=
9-paper.pdf
and http://kerneltrap.org/mailarchive/linux-netdev/2009/4/16/5491284

So I set up a test on two servers with Identical hardware, servers,
nics, etc, and used hackbench, udpping, and an internally written app
to compare latency.

Here are just the hackbench results with just the averages across a 5
runs for two different hackbench tests.  The 2.6.16 and 2.6.27 kernels
as set up were configured with voluntary preemption, and 250 HZ, so I
just repeated that initially for 2.6.33.1 test.  I also tested no
preemption at same HZ setting of 250.

I ran 2.6.16.60 on one server, and the other kernel versions on
another server.  These tests are repeatable across different servers,
as in I verified I
don't have a bad server.

Kernel Version         HB1 (25 process 300)    HB2 (100 process 300)
2.6.16.60                 .5402                           1.8946
2.6.27.19                 .619                             2.6268
2.6.32.3-voluntary     .5636                           2.3484
2.6.33.1-voluntary     .5404                           2.2872
2.6.33.1-nopreempt   .5606                           2.3466

So 2.6.16.60 is fast, 2.6.27.19 is slow, and 2.6.33.1 with voluntary
preemption is the next best, but results didn't hold up well as
Hackbench tests used larger numbers of groups., for example, 2.6.16.60
and 2.6.33.1-voluntary were basically the same for HB1, but that
didn't hold when hackebnch tests used more groups.

At this point, I'm looking for ideas in kernel build to tweak, but I'm
not a developer.  So SLAB vs SLUB, sparse vs dense IRQ numbering, etc.
Running a -rt kernel isn't an option at this time.  I did test that as
well, and latencies were quite a bit worse, but I wasn't adjusting
code to take advantage of a real time OS.

I can make some changes or repeat tests.

Below is some hardware comparisons betweent the two machines.
Differences I noticed was more interrupts and CPU flags on later
kernel version.

HostA 2.6.16.60
cat /proc/interrupts
         CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
    CPU6       CPU7
  0:  108509762          0          0          0          0          0
         0          0    IO-APIC-edge  timer
  8:          1          0          0          0          0          0
         0          0    IO-APIC-edge  rtc
  9:          0          0          0          0          0          0
         0          0   IO-APIC-level  acpi
 58:        305          0    5157735        220    2980100       5927
      1187          0   IO-APIC-level  libata
162:          0          0          0          0          0          0
         0          0   IO-APIC-level  uhci_hcd:usb1
170:          0          0          0          0          0          0
         0          0   IO-APIC-level  uhci_hcd:usb2
177:       6326          0     229018          0     283720      35597
       367          0   IO-APIC-level  megasas
178:        122          0       1784       1103       3531         20
      1457          0   IO-APIC-level  uhci_hcd:usb3, ehci_hcd:usb6
186:          0          0          0          0          0          0
         0          0   IO-APIC-level  uhci_hcd:usb4
194:         22          0          0          0          0          0
         0          0   IO-APIC-level  ehci_hcd:usb5
210:    1790109        577          0          0          0          0
         0          0       PCI-MSI-X  eth4-0
218:     233811         93          0          0          0          0
         0          0       PCI-MSI-X  eth4-1
NMI:          0          0          0          0          0          0
         0          0
LOC:  108509683  108509662  108509637  108509614  108509588  108509566
 108509541  108509516
ERR:          7
MIS:          0

lspci
00:00.0 Host bridge: Intel Corporation QuickPath Architecture I/O Hub
to ESI Port (rev 13)
00:01.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
PCI Express Root Port 1 (rev 13)
00:03.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
PCI Express Root Port 3 (rev 13)
00:07.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
PCI Express Root Port 7 (rev 13)
00:09.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
PCI Express Root Port 9 (rev 13)
00:14.0 PIC: Intel Corporation QuickPath Architecture I/O Hub System
Management Registers (rev 13)
00:14.1 PIC: Intel Corporation QuickPath Architecture I/O Hub GPIO and
Scratch Pad Registers (rev 13)
00:14.2 PIC: Intel Corporation QuickPath Architecture I/O Hub Control
Status and RAS Registers (rev 13)
00:16.0 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.1 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.2 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.3 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.4 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.5 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.6 System peripheral: Intel Corporation DMA Engine (rev 13)
00:16.7 System peripheral: Intel Corporation DMA Engine (rev 13)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 1 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #2 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface
Controller (rev 02)
00:1f.2 IDE interface: Intel Corporation 82801IB (ICH9) 2 port SATA
IDE Controller (rev 02)
03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS
1078 (rev 04)
04:00.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
8018 (rev 0e)
05:02.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
8018 (rev 0e)
05:04.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
8018 (rev 0e)
06:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
06:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
07:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
07:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
08:00.0 Ethernet controller: Solarflare Communications Unknown device
0710 (rev 02)
09:03.0 VGA compatible controller: Matrox Graphics, Inc. Unknown
device 0532 (rev 0a)

cat /proc/cpuinfo (just showing first CPU for brevity)
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 26
model name      : Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz
stepping        : 5
cpu MHz         : 2926.090
cache size      : 8192 KB
physical id     : 1
siblings        : 4
core id         : 0
cpu cores       : 4
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall
nx rdtscp lm constant_tsc pni monitor d
s_cpl vmx est tm2 cx16 xtpr dca popcnt lahf_lm
bogomips        : 5857.34
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:

ethtool -c eth4
Coalesce parameters for eth4:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 0
rx-frames: 0
rx-usecs-irq: 60
rx-frames-irq: 0

tx-usecs: 0
tx-frames: 0
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0


HostB 2.6.33.1
    CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
CPU6       CPU7
   0:       8637          0          0          0          0
0          0          0   IO-APIC-edge      timer
   1:          2          0          0          0          0
0          0          0   IO-APIC-edge      i8042
   3:          2          0          0          0          0
0          0          0   IO-APIC-edge
   4:          2          0          0          0          0
0          0          0   IO-APIC-edge
   8:          1          0          0          0          0
0          0          0   IO-APIC-edge      rtc0
   9:          0          0          0          0          0
0          0          0   IO-APIC-fasteoi   acpi
  12:          4          0          0          0          0
0          0          0   IO-APIC-edge      i8042
  16:       7434        683          0          0          0
0          0          0   IO-APIC-fasteoi   megasas
  17:          0          0          0          0          0
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
  18:          0          0          0          0          0
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  19:         23          0          0          0          0
0          0          0   IO-APIC-fasteoi   ehci_hcd:usb1
  20:          0          0          0          0          0
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb6
  21:        129          0         15          0          0
0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2,
uhci_hcd:usb5
  23:        369          0          0          0          0
0          0          0   IO-APIC-fasteoi   ata_piix
  67:       2346        731          0          0          0
0          0          0   PCI-MSI-edge      eth4-0
  68:       1809        404          0          0          0
0          0          0   PCI-MSI-edge      eth4-1
 NMI:          0          0          0          0          0
0          0          0   Non-maskable interrupts
 LOC:      33071      38348      47397      23246      15715
11065       9004      10391   Local timer interrupts
 SPU:          0          0          0          0          0
0          0          0   Spurious interrupts
 PMI:          0          0          0          0          0
0          0          0   Performance monitoring interrupts
 PND:          0          0          0          0          0
0          0          0   Performance pending work
 RES:       2490       2124       4187       4974       1724
5548       1892       2871   Rescheduling interrupts
 CAL:        497       2166        141        115        133
144        140        144   Function call interrupts
 TLB:        243        244        928        945        289
187        134         93   TLB shootdowns
 TRM:          0          0          0          0          0
0          0          0   Thermal event interrupts
 THR:          0          0          0          0          0
0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0          0
0          0          0   Machine check exceptions
 MCP:          2          2          2          2          2
2          2          2   Machine check polls
 ERR:          7
 MIS:          0

lspci
00:00.0 Host bridge: Intel Corporation X58 I/O Hub to ESI Port (rev 13)
00:01.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
Port 1 (rev 13)
00:03.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
Port 3 (rev 13)
00:07.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
Port 7 (rev 13)
00:09.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
Port 9 (rev 13)
00:14.0 PIC: Intel Corporation X58 I/O Hub System Management Registers =
(rev 13)
00:14.1 PIC: Intel Corporation X58 I/O Hub GPIO and Scratch Pad
Registers (rev 13)
00:14.2 PIC: Intel Corporation X58 I/O Hub Control Status and RAS
Registers (rev 13)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 1 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #2 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface
Controller (rev 02)
00:1f.2 IDE interface: Intel Corporation 82801IB (ICH9) 2 port SATA
IDE Controller (rev 02)
03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS
1078 (rev 04)
04:00.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
Express Switch (rev 0e)
05:02.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
Express Switch (rev 0e)
05:04.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
Express Switch (rev 0e)
06:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
06:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
07:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
07:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Network
Connection (rev 02)
08:00.0 Ethernet controller: Solarflare Communications SFC4000 rev B
[Solarstorm] (rev 02)
09:03.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200eW
WPCM450 (rev 0a)

cat /proc/cpuinfo (just showing first CPU for brevity)
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 26
model name      : Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz
stepping        : 5
cpu MHz         : 2925.888
cache size      : 8192 KB
physical id     : 1
siblings        : 4
core id         : 0
cpu cores       : 4
apicid          : 16
initial apicid  : 16
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bt
s rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl
vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm ida
tpr_shadow vnmi flexpriority ept vpid
bogomips        : 5851.77
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:

ethtool -c eth4
Coalesce parameters for eth4:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 0
rx-frames: 0
rx-usecs-irq: 60
rx-frames-irq: 0

tx-usecs: 0
tx-frames: 0
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0



On Thu, Apr 1, 2010 at 8:53 PM, Taylor Lewick <taylor.lewick@gmail.com>=
 wrote:
> Okay. =A0I will get this info out to the list Monday. =A0Briefly, I'm
> using identical hardware (server), identical NICs, same drivers,
> connected to same switch, and using udpping, hackbench, and an
> internall written app to test latency. =A0Without exception the
> evolution has looked like the following.
>
> 2.6.16.60 latencies for system and network are fast. =A0Meaning
> hackbench and udpping win, and win by quite a bit.
>
> 2.6.27.19 was awful. =A02.6.32.1 and 2.6.331. were better for network=
ing
> (with some tweaks, i.e. disable netfilter, etc), and I was able to ge=
t
> networking latencies to within 1-3 microseconds of 2.6.16.60
> latencies, but the hackbench results are still pretty bad.
>
> Again, I'll post numbers and more detailed hardware info on Monday
> when I'm back at office...
>
> On Thu, Apr 1, 2010 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> Le jeudi 01 avril 2010 =E0 14:12 -0500, Taylor Lewick a =E9crit :
>>> For some time now we've been running an older kernel, 2.6.16.60. =A0=
When
>>> we tried to upgrade, first going to 2.6.27.19 and then to 2.6.32.1 =
and
>>> 2.6.33.1 we noticed that latencies increased. =A0At first we notice=
d it
>>> by doing network tests via udpping, netperf, etc. =A0We made some
>>> tweaks, and were able to get network latency to within 1 to 2
>>> microseconds of where we were previously on 2.6.16.60. =A0Then we d=
id
>>> some more testing, and noticed that system latency also seems highe=
r.
>>>
>>> We've done our tests on identical hardware servers, same NICs,
>>> connected through same network gear. =A0Basically, we've tried to k=
eep
>>> everything identical except the kernel versions, and we are unable =
to
>>> achieve the same performance for system latency on the newer kernel=
s,
>>> despite adjusting various kernel settings and recompiling.
>>>
>>> The latency differences are about 15 microseconds per transaction.
>>>
>>> At this point, I don't know what else to try. =A0I haven't played a=
round
>>> with the /proc/sys/kernel/sched_* paramaters under the newer kernel=
s
>>> yet. =A0Have tried changing pre-emption modes with little effect, i=
n
>>> fact, voluntary preemption seems to be peforming the best for us.
>>>
>>> At this time the realtime patch isn't really an option for us to
>>> consider, at least not yet.
>>>
>>> Any suggestions? =A0Is this a known issue when upgrading to more re=
cent
>>> kernel versions?
>>>
>>
>> Hi Taylor
>>
>> Well, this is bit difficult to generically answer to your generic
>> question. 15 us more latency per transaction seems pretty bad.
>>
>> Some inputs would be nice, describing your workload and
>> software/hardware architecture.
>>
>> lspci
>> cat /proc/cpuinfo
>> cat /proc/interrupts
>> dmesg
>> ethtool -S eth0
>> ethtool -c eth0
>>
>>
>>
>>
>
