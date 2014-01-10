From: Thomas Kear <thomas@kear.co.nz>
Subject: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Sat, 11 Jan 2014 08:56:29 +1300
Message-ID: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:62445 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbaAJT4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:56:50 -0500
Received: by mail-vb0-f50.google.com with SMTP id w18so3467404vbj.23
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:56:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

USB3 gigabit ethernet adapters with the ASIX AX88179 chipset (LevelOne
USB0401-V3, Plugable USB3-E1000, SIIG JU-NE0211-S1 and others) are
experiencing kernel panics in usb_hcd_map_urb_for_dma since 3.12.  The
issue does not seem to directly correlate with low or high network
activity, occurring seemingly at random.  Some panics occurred less
than 5 minutes from boot and tens of megabytes of network transfer,
while on other occasions it would be stable for multiple days with
tens to hundreds of gigabytes of line-rate throughput and several
sleep/resume cycles.

Both my Sony Vaio Pro 13 and another user reporting this issue on the
Arch forums [1] are Intel-based, my USB controller is an 8086:9c31
(Lynx Point LP), the other is reported as a C210/7 series (unknown
PID).  A third with a Haswell Dell XPS has attempted my workaround and
reports similar success.

I have a mediocre quality photo of my laptop's screen from one of
these panics [2], the call trace - which is similar but not identical
between my machine and that of the other user reporting the issue - is
as follows:

usb_hcd_map_urb_for_dma
usb_hcd_submit_urb
local_bh_enable_ip
selinux_parse_skb
usb_alloc_urb
__kmalloc
usbnet_start_xmit
usbnet_start_xmit
dev_hard_start_xmit
sch_direct_xmit
dev_queue_xmit
ip_finish_output2
ip_finish_output
ip_output
dst_output
ip_local_out
ip_queue_xmit
tcp_transmit_skb
tcp_write_xmit
__tcp_push_pending_frames
tcp_push
tcp_sendmsg
inet_sendmsg
__sock_sendmsg_nosec
sock_sendmsg
set_restore_sigmask
set_restore_sigmask
fget_light
SYSC_sendto
set_restore_sigmask
SyS_sendto
system_call_fastpath

So far as I can tell, the driver is unaffected as late as 3.11.6, but
problematic as of 3.12 (and still affected in 3.13-rc5).  The history
of drivers/net/usb/ax88179_178a.c for this time period yields this
patch, which at least in my somewhat limited understanding appeared a
likely candidate.  I've reverted this on my system - against several
linux-next builds from the last 3-4 weeks - and have had no issues
with this network controller since.

commit 3804fad45411b48233b48003e33a78f290d227c8
Author: Ming Lei <ming.lei@canonical.com>
Date:   Thu Aug 8 21:48:25 2013 +0800

    USBNET: ax88179_178a: enable tso if usb host supports sg dma

    This patch enables 'can_dma_sg' flag for ax88179_178a device
    if the attached host controller supports building packet from
    discontinuous buffers(DMA SG is possible), so TSO can be enabled
    and skb fragment buffers can be passed to usb stack via urb->sg
    directly.

    With the patch, system CPU utilization decreased ~50% and throughput
    increased by ~10% when doing iperf client test on one ARM A15 dual
    core board.

    Cc: Ben Hutchings <bhutchings@solarflare.com>
    Cc: Grant Grundler <grundler@google.com>
    Cc: Oliver Neukum <oneukum@suse.de>
    Cc: Alan Stern <stern@rowland.harvard.edu>
    Cc: Freddy Xin <freddy@asix.com.tw>
    Signed-off-by: Ming Lei <ming.lei@canonical.com>
    Acked-by: Eric Dumazet <edumazet@gmail.com>
    Acked-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Unfortunately I have not retained the built kernel from a broken 3.12
build, so the system information below reflects the patched linux-next
kernel I am running currently.

I understand this may be a somewhat obscure piece of hardware, I am
willing to assist by drop-shipping one to someone from Amazon (or
local country equivalent if the price is not extortionate) should it
be required.



System information:

ver_linux:
Linux neko 3.13.0-rc5-next-20131224+ #1 SMP Sat Dec 28 19:09:27 NZDT
2013 x86_64 Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz GenuineIntel
GNU/Linux

Gnu C                  4.7.3
Gnu make               4.0
binutils               2.24
util-linux             scripts/ver_linux: line 23: fdformat: command not found
mount                  assert
module-init-tools      16
e2fsprogs              1.42.9
jfsutils               1.1.15
reiserfsprogs          3.6.24
reiser4progs           1.0.7
xfsprogs               3.1.11
quota-tools            4.01.
PPP                    2.4.5
Linux C Library        2.17
Dynamic linker (ldd)   2.17
Procps                 3.3.9
Net-tools              1.60_p20130513023548
Kbd                    2.0.1
Sh-utils               8.22
Modules Loaded         bonding rndis_host cdc_ether tun snd_usb_audio
snd_usbmidi_lib snd_rawmidi cdc_acm ctr ccm hidp nfsd rfcomm bnep
iptable_nat nf_nat_ipv4 nf_nat uvcvideo btusb bluetooth hid_multitouch
videobuf2_vmalloc videobuf2_memops videobuf2_core uinput ax88179_178a
usbnet mii rtsx_pci_sdmmc rtsx_pci mmc_core fuse snd_hda_codec_realtek
iwlmvm kvm_intel snd_hda_codec_generic mac80211 kvm pn544_mei mei_phy
iwlwifi pn544 snd_hda_intel hci nfc snd_hda_codec snd_hwdep cfg80211
xhci_hcd

/proc/cpuinfo:
processor       : 3
vendor_id       : GenuineIntel
cpu family      : 6
model           : 69
model name      : Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz
stepping        : 1
microcode       : 0x10
cpu MHz         : 2968.125
cache size      : 4096 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 2
apicid          : 3
initial apicid  : 3
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq
dtes64 monitor ds_cpl vmx est tm2 ssse3 fma cx16 xtpr pdcm pcid sse4_1
sse4_2 movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand
lahf_lm abm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi
flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms
invpcid
bogomips        : 4788.92
clflush size    : 64
cache_alignment : 64
address sizes   : 39 bits physical, 48 bits virtual
power management:

PCI:
-[0000:00]-+-00.0  Intel Corporation Haswell-ULT DRAM Controller [8086:0a04]
           +-02.0  Intel Corporation Haswell-ULT Integrated Graphics
Controller [8086:0a16]
           +-03.0  Intel Corporation Device [8086:0a0c]
           +-14.0  Intel Corporation Lynx Point-LP USB xHCI HC [8086:9c31]
           +-16.0  Intel Corporation Lynx Point-LP HECI #0 [8086:9c3a]
           +-1b.0  Intel Corporation Lynx Point-LP HD Audio Controller
[8086:9c20]
           +-1c.0-[01]----00.0  Intel Corporation Wireless 7260 [8086:08b1]
           +-1c.3-[02]--
           +-1c.4-[03]----00.0  Samsung Electronics Co Ltd Device [144d:a800]
           +-1d.0  Intel Corporation Lynx Point-LP USB EHCI #1 [8086:9c26]
           +-1f.0  Intel Corporation Lynx Point-LP LPC Controller [8086:9c43]
           \-1f.3  Intel Corporation Lynx Point-LP SMBus Controller [8086:9c22]

USB:
Bus 001 Device 002: ID 8087:8000 Intel Corp.
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 003 Device 025: ID 0b95:1790 ASIX Electronics Corp.
Bus 003 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 002 Device 027: ID 8087:07dc Intel Corp.
Bus 002 Device 003: ID 04f2:b3be Chicony Electronics Co., Ltd
Bus 002 Device 002: ID 0eef:a108 D-WAV Scientific Co., Ltd
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

/proc/modules:
bonding 84837 0 - Live 0xffffffffc00d5000
rndis_host 5162 0 - Live 0xffffffffc0096000
cdc_ether 4324 1 rndis_host, Live 0xffffffffc006e000
tun 16811 0 - Live 0xffffffffc009e000
snd_usb_audio 102474 0 - Live 0xffffffffc007b000
snd_usbmidi_lib 16542 1 snd_usb_audio, Live 0xffffffffc0072000
snd_rawmidi 15891 1 snd_usbmidi_lib, Live 0xffffffffc0017000
cdc_acm 16166 0 - Live 0xffffffffc05ec000
ctr 3471 2 - Live 0xffffffffc05e8000
ccm 6977 2 - Live 0xffffffffc05e3000
hidp 12989 0 - Live 0xffffffffc05db000
nfsd 192979 13 - Live 0xffffffffc059b000
rfcomm 27704 12 - Live 0xffffffffc058e000
bnep 9055 2 - Live 0xffffffffc0587000
iptable_nat 2550 0 - Live 0xffffffffc0583000
nf_nat_ipv4 3118 1 iptable_nat, Live 0xffffffffc057f000
nf_nat 9984 2 iptable_nat,nf_nat_ipv4, Live 0xffffffffc0577000
uvcvideo 60542 0 - Live 0xffffffffc0562000
btusb 14182 0 - Live 0xffffffffc0519000
bluetooth 200149 23 hidp,rfcomm,bnep,btusb, Live 0xffffffffc04d8000
hid_multitouch 8791 0 - Live 0xffffffffc04d1000
videobuf2_vmalloc 2528 1 uvcvideo, Live 0xffffffffc04cd000
videobuf2_memops 1559 1 videobuf2_vmalloc, Live 0xffffffffc04c9000
videobuf2_core 22473 1 uvcvideo, Live 0xffffffffc04be000
uinput 6657 0 - Live 0xffffffffc04b9000
ax88179_178a 11352 0 - Live 0xffffffffc04b2000
usbnet 17066 3 rndis_host,cdc_ether,ax88179_178a, Live 0xffffffffc04a7000
mii 3427 2 ax88179_178a,usbnet, Live 0xffffffffc04a3000
rtsx_pci_sdmmc 8434 0 - Live 0xffffffffc049d000
rtsx_pci 24242 1 rtsx_pci_sdmmc, Live 0xffffffffc0490000
mmc_core 73734 1 rtsx_pci_sdmmc, Live 0xffffffffc0471000
fuse 65180 0 - Live 0xffffffffc0458000
snd_hda_codec_realtek 37786 1 - Live 0xffffffffc0448000
iwlmvm 99382 0 - Live 0xffffffffc03d9000
kvm_intel 119916 0 - Live 0xffffffffc033e000
snd_hda_codec_generic 39626 1 snd_hda_codec_realtek, Live 0xffffffffc032d000
mac80211 352537 1 iwlmvm, Live 0xffffffffc0239000
kvm 332678 1 kvm_intel, Live 0xffffffffc014f000
pn544_mei 1507 0 - Live 0xffffffffc014b000
mei_phy 1942 1 pn544_mei, Live 0xffffffffc0147000
iwlwifi 70257 1 iwlmvm, Live 0xffffffffc0129000
pn544 6215 1 pn544_mei, Live 0xffffffffc0124000
snd_hda_intel 29721 2 - Live 0xffffffffc0106000
hci 13343 2 mei_phy,pn544, Live 0xffffffffc00fd000
nfc 46459 2 pn544,hci, Live 0xffffffffc00c8000
snd_hda_codec 72588 3
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel, Live
0xffffffffc00a7000
snd_hwdep 5373 2 snd_usb_audio,snd_hda_codec, Live 0xffffffffc009b000
cfg80211 320801 3 iwlmvm,mac80211,iwlwifi, Live 0xffffffffc001e000
xhci_hcd 88348 0 - Live 0xffffffffc0000000

/proc/iomem:
00000000-00000fff : reserved
00001000-00057fff : System RAM
00058000-00058fff : reserved
00059000-0009dfff : System RAM
0009e000-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c3fff : PCI Bus 0000:00
000c4000-000c7fff : PCI Bus 0000:00
000c8000-000cbfff : PCI Bus 0000:00
000cc000-000cffff : PCI Bus 0000:00
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : PCI Bus 0000:00
000f0000-000fffff : System ROM
00100000-ca4b7fff : System RAM
  06000000-066753ba : Kernel code
  066753bb-06cc83ff : Kernel data
  06dc9000-06ecffff : Kernel bss
ca4b8000-ca4befff : ACPI Non-volatile Storage
ca4bf000-ca8e7fff : System RAM
ca8e8000-cac39fff : reserved
cac3a000-da89bfff : System RAM
da89c000-dab3ffff : reserved
dab40000-dab55fff : ACPI Tables
dab56000-dbaaafff : ACPI Non-volatile Storage
dbaab000-dbffefff : reserved
dbfff000-dbffffff : System RAM
dd000000-df1fffff : reserved
  dd200000-df1fffff : Graphics Stolen Memory
df200000-feafffff : PCI Bus 0000:00
  df200000-df3fffff : PCI Bus 0000:01
  e0000000-efffffff : 0000:00:02.0
    e0000000-e07e8fff : BOOTFB
  f0000000-f09fffff : PCI Bus 0000:03
  f0a00000-f13fffff : PCI Bus 0000:02
  f6400000-f67fffff : 0000:00:02.0
  f6800000-f71fffff : PCI Bus 0000:03
    f6800000-f680ffff : 0000:03:00.0
    f6810000-f6811fff : 0000:03:00.0
      f6810000-f6811fff : ahci
  f7200000-f7bfffff : PCI Bus 0000:02
  f7c00000-f7cfffff : PCI Bus 0000:01
    f7c00000-f7c01fff : 0000:01:00.0
      f7c00000-f7c01fff : iwlwifi
  f7d00000-f7d0ffff : 0000:00:14.0
    f7d00000-f7d0ffff : xhci_hcd
  f7d10000-f7d13fff : 0000:00:1b.0
    f7d10000-f7d13fff : ICH HD audio
  f7d14000-f7d17fff : 0000:00:03.0
  f7d19000-f7d190ff : 0000:00:1f.3
  f7d1a000-f7d1a3ff : 0000:00:1d.0
    f7d1a000-f7d1a3ff : ehci_hcd
  f7d1c000-f7d1c01f : 0000:00:16.0
    f7d1c000-f7d1c01f : mei_me
  f7fef000-f7feffff : pnp 00:0a
  f7ff0000-f7ffffff : pnp 00:0a
  f8000000-fbffffff : PCI MMCONFIG 0000 [bus 00-3f]
    f8000000-fbffffff : reserved
      f8000000-fbffffff : pnp 00:0a
fec00000-fec00fff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed03fff : reserved
  fed00000-fed003ff : HPET 0
fed10000-fed17fff : pnp 00:0a
fed18000-fed18fff : pnp 00:0a
fed19000-fed19fff : pnp 00:0a
fed1c000-fed1ffff : reserved
  fed1c000-fed1ffff : pnp 00:0a
    fed1f410-fed1f414 : iTCO_wdt
      fed1f410-fed1f414 : iTCO_wdt
fed20000-fed3ffff : pnp 00:0a
fed45000-fed8ffff : pnp 00:0a
fed90000-fed93fff : pnp 00:0a
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
ff000000-ffffffff : reserved
  ff000000-ffffffff : pnp 00:0a
100000000-21fdfffff : System RAM
21fe00000-21fffffff : RAM buffer

/proc/ioports:
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0062-0062 : EC data
  0064-0064 : keyboard
  0066-0066 : EC cmd
  0070-0077 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  04d0-04d1 : pnp 00:07
  0680-069f : pnp 00:04
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  164e-164f : pnp 00:04
  1800-1803 : ACPI PM1a_EVT_BLK
  1804-1805 : ACPI PM1a_CNT_BLK
  1808-180b : ACPI PM_TMR
  1810-1815 : ACPI CPU throttle
  1830-1833 : iTCO_wdt
    1830-1833 : iTCO_wdt
  1850-1850 : ACPI PM2_CNT_BLK
  1854-1857 : pnp 00:06
  1860-187f : iTCO_wdt
    1860-187f : iTCO_wdt
  1880-189f : ACPI GPE0_BLK
  1c00-1cfe : pnp 00:04
  1d00-1dfe : pnp 00:04
  1e00-1efe : pnp 00:04
  1f00-1ffe : pnp 00:04
  2008-200b : pnp 00:04
  3000-3fff : PCI Bus 0000:01
  d000-dfff : PCI Bus 0000:03
  e000-efff : PCI Bus 0000:02
  f000-f03f : 0000:00:02.0
  f040-f05f : 0000:00:1f.3
  ffff-ffff : pnp 00:04
    ffff-ffff : pnp 00:04


Regards,
Thomas

(my apologies for forgetting the plain-text requirement resulting in
this not reaching the list immediately)

[1] https://bbs.archlinux.org/viewtopic.php?pid=1350921
[2] http://i.imgur.com/NCanPUY.jpg
