From: mirko.parthey@informatik.tu-chemnitz.de (Mirko Parthey)
Subject: Re: PROBLEM: system freezes on starting ne2k-pci + bridge
Date: Thu, 4 Oct 2007 20:27:38 +0200
Message-ID: <20071004182738.GA4191@augustus.informatik.tu-chemnitz.de>
References: <20071002141217.GA23610@stilzchen.informatik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:40769 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbXJDS1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 14:27:40 -0400
Received: from augustus.informatik.tu-chemnitz.de ([134.109.193.33])
	by lana.hrz.tu-chemnitz.de with esmtp (Exim 4.66)
	(envelope-from <mirko.parthey@informatik.tu-chemnitz.de>)
	id 1IdVQA-0004bA-SZ
	for netdev@vger.kernel.org; Thu, 04 Oct 2007 20:27:39 +0200
Content-Disposition: inline
In-Reply-To: <20071002141217.GA23610@stilzchen.informatik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 04:12:17PM +0200, I wrote:
> On a machine running Debian testing, I get complete lockups
> (Num lock LED not responding anymore)
> 
> Kernel versions tried (all of them show this problem):
> - linux-image-2.6.18-5-amd64 (Debian etch)
> - linux-image-2.6.22-2-amd64 (Debian testing)
> - plain kernel.org 2.6.23-rc8-git4 (with allmodconfig and ATKBD=y)
> 
> The 2.6.18 kernel sometimes prints
>   Losing some ticks ... checking if CPU frequency changed.
>   Your time source seems to be instable or some driver is hogging
>   interrupts.
>   rip __do_softirq + 0x53/0xd5
> before freezing.

I was able to narrow this down a bit - the problem can be reproduced with 
the ne2k-pci driver alone, sky2 is not needed.
Powering off isn't necessary, either.

Hardware preparation:
- eth0: Compex ReadyLink 2000 (BNC+TP), ne2k-pci driver,
  network cable disconnected

How to reproduce the problem:

brctl addbr br0
brctl addif br0 eth0
ifconfig eth0 0 up
ifconfig br0 192.168.1.17 up
sync
find / >/dev/null &
ping -b 192.168.1.255

This will lock up my system, usually within a few seconds.

Some additional information:
- I could not reproduce the problem when using eth0 directly,
  without a bridge.
- Booting with "maxcpus=1" does not help, the problem remains.
  My system doesn't boot with "nosmp", otherwise I would have
  tried this too.

- Mainboard: Gigabyte GA-965P-S3

- /proc/cpuinfo:
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 15
model name	: Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz
stepping	: 6
cpu MHz		: 2133.394
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm constant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
bogomips	: 4269.87
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 15
model name	: Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz
stepping	: 6
cpu MHz		: 2133.394
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 1
cpu cores	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm constant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
bogomips	: 4267.07
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

- /proc/interrupts:
           CPU0       CPU1       
  0:      46738          0   IO-APIC-edge      timer
  1:        690          0   IO-APIC-edge      i8042
  7:          0          0   IO-APIC-edge      parport0
  8:          0          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          4          0   IO-APIC-edge      i8042
 16:      25552          0   IO-APIC-fasteoi   uhci_hcd:usb1, ide0, radeon@pci:0000:01:00.0
 18:          2          0   IO-APIC-fasteoi   uhci_hcd:usb5, ehci_hcd:usb6
 19:      15146          0   IO-APIC-fasteoi   uhci_hcd:usb4, libata, libata, ahci, eth0
 20:          3          0   IO-APIC-fasteoi   bttv0, Bt87x audio
 21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
 22:        192          0   IO-APIC-fasteoi   HDA Intel
 23:       5009          0   IO-APIC-fasteoi   uhci_hcd:usb3, ehci_hcd:usb7
NMI:          0          0 
LOC:      46261      46240 
ERR:          0

- /proc/ioports:
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0378-037a : parport0
03c0-03df : vga+
03f8-03ff : serial
0400-047f : 0000:00:1f.0
  0400-0403 : ACPI PM1a_EVT_BLK
  0404-0405 : ACPI PM1a_CNT_BLK
  0408-040b : ACPI PM_TMR
  0410-0415 : ACPI CPU throttle
  0428-042f : ACPI GPE0_BLK
  0460-047f : iTCO_wdt
0480-04bf : 0000:00:1f.0
0500-051f : 0000:00:1f.3
  0500-051f : i801_smbus
0778-077a : parport0
0cf8-0cff : PCI conf1
4000-4fff : PCI Bus #02
5000-5fff : PCI Bus #01
  5000-50ff : 0000:01:00.0
6000-7fff : PCI Bus #03
  6000-6007 : 0000:03:00.1
    6000-6007 : ide0
  6400-6403 : 0000:03:00.1
    6402-6402 : ide0
  6800-6807 : 0000:03:00.1
  6c00-6c03 : 0000:03:00.1
  7000-700f : 0000:03:00.1
    7000-7007 : ide0
    7008-700f : ide1
8000-8fff : PCI Bus #04
  8000-80ff : 0000:04:00.0
9000-9fff : PCI Bus #05
  9000-901f : 0000:05:01.0
    9000-901f : ne2k-pci
  9400-947f : 0000:05:02.0
a000-a01f : 0000:00:1a.1
  a000-a01f : uhci_hcd
a400-a41f : 0000:00:1d.0
  a400-a41f : uhci_hcd
a800-a81f : 0000:00:1d.1
  a800-a81f : uhci_hcd
ac00-ac1f : 0000:00:1d.2
  ac00-ac1f : uhci_hcd
b000-b01f : 0000:00:1a.0
  b000-b01f : uhci_hcd
b400-b407 : 0000:00:1f.2
  b400-b407 : libata
b800-b803 : 0000:00:1f.2
  b800-b803 : libata
bc00-bc07 : 0000:00:1f.2
  bc00-bc07 : libata
c000-c003 : 0000:00:1f.2
  c000-c003 : libata
c400-c40f : 0000:00:1f.2
  c400-c40f : libata
c800-c80f : 0000:00:1f.2
d000-d007 : 0000:00:1f.5
  d000-d007 : libata
d400-d403 : 0000:00:1f.5
  d400-d403 : libata
d800-d807 : 0000:00:1f.5
  d800-d807 : libata
dc00-dc03 : 0000:00:1f.5
  dc00-dc03 : libata
e000-e00f : 0000:00:1f.5
  e000-e00f : libata
e400-e40f : 0000:00:1f.5

- /proc/iomem:
00000000-0009f7ff : System RAM
  00000000-00000000 : Crash kernel
0009f800-0009ffff : reserved
000d2800-000d3fff : pnp 00:0b
000f0000-000fffff : reserved
00100000-7fedffff : System RAM
  00200000-003f6749 : Kernel code
  003f674a-004e2b7f : Kernel data
7fee0000-7fee2fff : ACPI Non-volatile Storage
7fee3000-7feeffff : ACPI Tables
7fef0000-7fefffff : reserved
80000000-800fffff : PCI Bus #04
  80000000-8001ffff : 0000:04:00.0
e0000000-e7ffffff : PCI Bus #01
  e0000000-e7ffffff : 0000:01:00.0
e8000000-ebffffff : reserved
ec000000-edffffff : PCI Bus #01
  ec000000-ec01ffff : 0000:01:00.0
  ed000000-ed00ffff : 0000:01:00.0
  ed010000-ed01ffff : 0000:01:00.1
ee000000-efffffff : PCI Bus #04
  ef000000-ef003fff : 0000:04:00.0
f0000000-f1ffffff : PCI Bus #05
  f1000000-f100007f : 0000:05:02.0
f2000000-f20fffff : PCI Bus #03
  f2000000-f2001fff : 0000:03:00.0
    f2000000-f2001fff : ahci
f2100000-f21fffff : PCI Bus #05
  f2100000-f2100fff : 0000:05:00.0
    f2100000-f2100fff : bttv0
  f2101000-f2101fff : 0000:05:00.1
    f2101000-f2101fff : Bt87x audio
  f2108000-f210ffff : 0000:05:01.0
  f2120000-f213ffff : 0000:05:02.0
f2200000-f2203fff : 0000:00:1b.0
  f2200000-f2203fff : ICH HD audio
f2204000-f22043ff : 0000:00:1a.7
  f2204000-f22043ff : ehci_hcd
f2205000-f22053ff : 0000:00:1d.7
  f2205000-f22053ff : ehci_hcd
f2206000-f22060ff : 0000:00:1f.3
fec00000-fec00fff : IOAPIC 0
fee00000-fee00fff : Local APIC

- # lspci -s 5:1 -vvv
05:01.0 Ethernet controller: Compex ReadyLink 2000 (rev 0a)
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at 9000 [size=32]
        [virtual] Expansion ROM at f2108000 [disabled] [size=32K]

- ver_linux output:
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux guitar2 2.6.22-2-amd64 #1 SMP Thu Aug 30 23:43:59 UTC 2007 x86_64 GNU/Linux

Gnu C                  4.2.1
Gnu make               3.81
binutils               Binutils
util-linux             2.12r
mount                  2.12r
module-init-tools      3.3-pre11
e2fsprogs              1.40.2
Linux C Library        6.1
Dynamic linker (ldd)   2.6.1
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   114
wireless-tools         29
Modules Loaded         radeon drm nfsd exportfs ppdev lp button ac battery cpufreq_powersave cpufreq_ondemand cpufreq_userspace cpufreq_conservative cpufreq_stats freq_table nfs lockd nfs_acl sunrpc ipv6 bridge ext2 nls_iso8859_1 nls_cp437 vfat fat loop snd_bt87x bt878 snd_hda_intel snd_pcm_oss snd_pcm snd_mixer_oss tuner snd_seq_dummy tvaudio msp3400 snd_seq_oss bttv snd_seq_midi video_buf firmware_class snd_rawmidi ir_common snd_seq_midi_event compat_ioctl32 i2c_algo_bit i2c_i801 btcx_risc iTCO_wdt snd_seq tveeprom parport_pc parport videodev i2c_core serio_raw psmouse snd_timer snd_seq_device v4l2_common v4l1_compat pcspkr snd soundcore snd_page_alloc intel_agp tsdev evdev ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_cd cdrom sd_mod usbhid hid generic usb_storage jmicron ide_core a
 hci ne2k_pci 8390 ata_piix ata_generic libata scsi_mod ehci_hcd uhci_hcd thermal processor fan

Regards,
Mirko
