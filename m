From: Phil Hord <hordp@cisco.com>
Subject: [BUG/PATCH] ppp_mppe discards 50% of packets from some servers
Date: Fri, 04 May 2012 18:28:25 -0400
Message-ID: <4FA45809.2020003@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-1.cisco.com ([173.37.86.72]:50986 "EHLO
	rcdn-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760484Ab2EDWki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 18:40:38 -0400
Received: from [64.100.104.141] (dhcp-64-100-104-141.cisco.com [64.100.104.141])
	by rcdn-core2-1.cisco.com (8.14.5/8.14.5) with ESMTP id q44MSPbO010159
	for <netdev@vger.kernel.org>; Fri, 4 May 2012 22:28:25 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BUG] ppp_mppe discards 50% of packets from some servers

[2.] Full description of the problem/report:

When I connect to a server using MPPE, I receive about every other
packet with the FLUSHED bit turned off. These packets are dropped by
ppp_mppe.c just like the SPEC says they should be. I am not able to
maintain tcp connections through the VPN with these packets being discarded.

I found a patch discussed here:
http://ubuntuforums.org/showthread.php?t=1095189

When I stop dropping those packets (by making this change to the driver;
see patch at end), the problem went away.

When I connect to a different server, I do not have this problem.

WhenI connect using Windows XP or Windows 7 clients, I do not have any
packet loss on either server, though I have not confirmed whether every
other packet still has the FLUSHED bit turned off.

I could see the symptom clearly by pinging a machine on the VPN. Every
other ping packet is lost with the old driver. Once I installed the new
driver, every ping is responded correctly.

I do not know any details about the two servers (one that works and one
that doesn't) except both are managed by the same mega-company but in
different countries (China and Czech).

--- /etc/ppp/peers/server1
pty "pptp remote-server1 --nolaunchpppd"
name "username"
remotename PPTP
require-mppe-128
file /etc/ppp/options.pptp

--- /etc/ppp/options.pptp:
lock
noauth
refuse-pap
refuse-eap
refuse-chap
refuse-mschap
nobsdcomp
nodeflate



[3.] Keywords (i.e., modules, networking, kernel):
ppp_mppe.ko, networking, kernel, mppe

[4.] Kernel information
[4.1.] Kernel version (from /proc/version):
Linux version 3.0.0-14-generic (buildd@allspice) (gcc version 4.6.1
(Ubuntu/Linaro 4.6.1-9ubuntu3) ) #23-Ubuntu SMP Mon Nov 21 20:28:43 UTC 2011


[4.2.] Kernel .config file:
*shrug*

[5.] Most recent kernel version which did not have the bug:

I have never seen a version able to connect to the failing server reliably.

[6.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)

N/A


[7.] A small shell script or example program which triggers the
     problem (if possible)

$ sudo pon server2
$ ping some-machine.server2
...
^C
20 packets transmitted, 10 received, 50% packet loss



[8.] Environment
[8.1.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux iptv-lnx-hordp 3.0.0-14-generic #23-Ubuntu SMP Mon Nov 21 20:28:43
UTC 2011 x86_64 x86_64 x86_64 GNU/Linux
 
Gnu C                  4.6.1
Gnu make               3.81
binutils               2.21.53.20110810
util-linux             2.19.1
mount                  support
module-init-tools      3.16
e2fsprogs              1.41.14
pcmciautils            015
PPP                    2.4.5
Linux C Library        2.13
Dynamic linker (ldd)   2.13
Procps                 3.2.8
Net-tools              1.60
Kbd                    1.15.2
Sh-utils               8.5
wireless-tools         30
Modules Loaded         ppp_mppe des_generic md4 nls_utf8 cifs ppp_async
crc_ccitt usb_storage uas mos7840 asix usbserial usbnet hid_logitech
ff_memless bnep rfcomm pci_stub vboxpci vboxnetadp vboxnetflt vboxdrv
kvm_intel kvm parport_pc ppdev autofs4 binfmt_misc dm_crypt
snd_hda_codec_hdmi nvidia uvcvideo videodev arc4 v4l2_compat_ioctl32
joydev btusb bluetooth snd_hda_codec_conexant iwlagn thinkpad_acpi
snd_seq_midi snd_hda_intel snd_rawmidi mac80211 snd_hda_codec psmouse
snd_hwdep snd_seq_midi_event serio_raw cfg80211 snd_seq snd_pcm
snd_seq_device snd_timer snd nvram tpm_tis video soundcore
snd_page_alloc wmi mei lp parport usbhid hid mmc_block ahci sdhci_pci
sdhci libahci xhci_hcd e1000e

[8.2.] Processor information (from /proc/cpuinfo):
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 0
cpu cores       : 4
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.69
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 0
cpu cores       : 4
apicid          : 1
initial apicid  : 1
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.17
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 2
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 1
cpu cores       : 4
apicid          : 2
initial apicid  : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4785.08
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 3
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 1
cpu cores       : 4
apicid          : 3
initial apicid  : 3
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.56
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 4
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 2
cpu cores       : 4
apicid          : 4
initial apicid  : 4
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.34
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 5
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 2
cpu cores       : 4
apicid          : 5
initial apicid  : 5
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.48
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 6
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 3
cpu cores       : 4
apicid          : 6
initial apicid  : 6
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.48
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 7
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2760QM CPU @ 2.40GHz
stepping        : 7
cpu MHz         : 800.000
cache size      : 6144 KB
physical id     : 0
siblings        : 8
core id         : 3
cpu cores       : 4
apicid          : 7
initial apicid  : 7
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 x2apic popcnt aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dts tpr_shadow vnmi flexpriority
ept vpid
bogomips        : 4784.52
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:


[8.3.] Module information (from /proc/modules):
ppp_mppe 13035 4 - Live 0xffffffffa0fbe000
des_generic 21415 0 - Live 0xffffffffa0fc9000
md4 12595 0 - Live 0xffffffffa0fb9000
nls_utf8 12557 1 - Live 0xffffffffa0fc4000
cifs 273872 2 - Live 0xffffffffa0f75000
ppp_async 17539 2 - Live 0xffffffffa0f6f000
crc_ccitt 12667 1 ppp_async, Live 0xffffffffa0ef5000
usb_storage 57901 0 - Live 0xffffffffa0f5f000
uas 18027 0 - Live 0xffffffffa0f47000
mos7840 36023 0 - Live 0xffffffffa0f55000
asix 22704 0 - Live 0xffffffffa0f4e000
usbserial 47107 1 mos7840, Live 0xffffffffa0f3a000
usbnet 26212 1 asix, Live 0xffffffffa0f00000
hid_logitech 17677 0 - Live 0xffffffffa0efa000
ff_memless 13097 1 hid_logitech, Live 0xffffffffa0ee9000
bnep 18436 2 - Live 0xffffffffa0eef000
rfcomm 47946 12 - Live 0xffffffffa0e85000
pci_stub 12622 1 - Live 0xffffffffa0e02000
vboxpci 23200 0 - Live 0xffffffffa0e7e000
vboxnetadp 13382 0 - Live 0xffffffffa0251000
vboxnetflt 23441 0 - Live 0xffffffffa0e77000
vboxdrv 282548 3 vboxpci,vboxnetadp,vboxnetflt, Live 0xffffffffa0ea3000
kvm_intel 61643 0 - Live 0xffffffffa0e92000
kvm 383781 1 kvm_intel, Live 0xffffffffa0e18000
parport_pc 36962 0 - Live 0xffffffffa0e0d000
ppdev 17113 0 - Live 0xffffffffa0e07000
autofs4 37024 3 - Live 0xffffffffa0df7000
binfmt_misc 17540 1 - Live 0xffffffffa0df1000
dm_crypt 23199 0 - Live 0xffffffffa0de6000
snd_hda_codec_hdmi 32040 4 - Live 0xffffffffa0fec000
nvidia 11713772 45 - Live 0xffffffffa02b9000 (P)
uvcvideo 72711 0 - Live 0xffffffffa0ff5000
videodev 92992 1 uvcvideo, Live 0xffffffffa0fd4000
arc4 12529 6 - Live 0xffffffffa0242000
v4l2_compat_ioctl32 17083 1 videodev, Live 0xffffffffa021a000
joydev 17693 0 - Live 0xffffffffa0214000
btusb 18600 2 - Live 0xffffffffa023c000
bluetooth 166112 23 bnep,rfcomm,btusb, Live 0xffffffffa0f0b000
snd_hda_codec_conexant 62197 1 - Live 0xffffffffa0203000
iwlagn 314213 0 - Live 0xffffffffa0256000
thinkpad_acpi 81819 0 - Live 0xffffffffa02a4000
snd_seq_midi 13324 0 - Live 0xffffffffa0166000
snd_hda_intel 33390 5 - Live 0xffffffffa0247000
snd_rawmidi 30547 1 snd_seq_midi, Live 0xffffffffa015d000
mac80211 462092 1 iwlagn, Live 0xffffffffa0191000
snd_hda_codec 104802 3
snd_hda_codec_hdmi,snd_hda_codec_conexant,snd_hda_intel, Live
0xffffffffa0221000
psmouse 73882 0 - Live 0xffffffffa017d000
snd_hwdep 13668 1 snd_hda_codec, Live 0xffffffffa00fb000
snd_seq_midi_event 14899 1 snd_seq_midi, Live 0xffffffffa010d000
serio_raw 13166 0 - Live 0xffffffffa00e1000
cfg80211 199587 2 iwlagn,mac80211, Live 0xffffffffa012b000
snd_seq 61896 2 snd_seq_midi,snd_seq_midi_event, Live 0xffffffffa016c000
snd_pcm 96714 4 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, Live
0xffffffffa0112000
snd_seq_device 14540 3 snd_seq_midi,snd_rawmidi,snd_seq, Live
0xffffffffa00d6000
snd_timer 29991 3 snd_seq,snd_pcm, Live 0xffffffffa0104000
snd 68266 19
snd_hda_codec_hdmi,snd_hda_codec_conexant,thinkpad_acpi,snd_hda_intel,snd_rawmidi,snd_hda_codec,snd_hwdep,snd_seq,snd_pcm,snd_seq_device,snd_timer,
Live 0xffffffffa00e9000
nvram 14413 1 thinkpad_acpi, Live 0xffffffffa00b1000
tpm_tis 18546 0 - Live 0xffffffffa00db000
video 19412 0 - Live 0xffffffffa00d0000
soundcore 12680 1 snd, Live 0xffffffffa007a000
snd_page_alloc 18529 2 snd_hda_intel,snd_pcm, Live 0xffffffffa00ca000
wmi 19256 0 - Live 0xffffffffa00b6000
mei 41480 0 - Live 0xffffffffa00a5000 (C)
lp 17799 0 - Live 0xffffffffa004a000
parport 46562 3 parport_pc,ppdev,lp, Live 0xffffffffa0098000
usbhid 47198 1 hid_logitech, Live 0xffffffffa00bd000
hid 95463 2 hid_logitech,usbhid, Live 0xffffffffa007f000
mmc_block 22923 0 - Live 0xffffffffa0029000
ahci 26002 4 - Live 0xffffffffa0072000
sdhci_pci 14032 0 - Live 0xffffffffa0069000
sdhci 32166 1 sdhci_pci, Live 0xffffffffa005c000
libahci 26861 1 ahci, Live 0xffffffffa0050000
xhci_hcd 82820 0 - Live 0xffffffffa0034000
e1000e 160582 0 - Live 0xffffffffa0000000

[8.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
 cat /proc/ioports /proc/iomem
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0062-0062 : EC data
  0064-0064 : keyboard
  0066-0066 : EC cmd
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  03c0-03df : vga+
  0400-047f : pnp 00:02
    0400-0403 : ACPI PM1a_EVT_BLK
    0404-0405 : ACPI PM1a_CNT_BLK
    0408-040b : ACPI PM_TMR
    0410-0415 : ACPI CPU throttle
    0420-042f : ACPI GPE0_BLK
    0450-0450 : ACPI PM2_CNT_BLK
  0500-057f : pnp 00:02
  0800-080f : pnp 00:02
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  15e0-15ef : pnp 00:02
  1600-167f : pnp 00:02
  3000-3fff : PCI Bus 0000:0d
  4000-4fff : PCI Bus 0000:05
  5000-5fff : PCI Bus 0000:01
    5000-507f : 0000:01:00.0
  6020-603f : 0000:00:1f.2
    6020-603f : ahci
  6040-605f : 0000:00:19.0
  6060-6067 : 0000:00:1f.2
    6060-6067 : ahci
  6068-606f : 0000:00:1f.2
    6068-606f : ahci
  6070-6077 : 0000:00:16.3
    6070-6077 : serial
  6078-607b : 0000:00:1f.2
    6078-607b : ahci
  607c-607f : 0000:00:1f.2
    607c-607f : ahci
  efa0-efbf : 0000:00:1f.3
00000000-0000ffff : reserved
00010000-0009d7ff : System RAM
0009d800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000c8000-000cbfff : pnp 00:00
000cc000-000cffff : pnp 00:00
000d0000-000d3fff : pnp 00:00
000d4000-000d7fff : pnp 00:00
000d8000-000dbfff : pnp 00:00
000dc000-000dffff : pnp 00:00
000e0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-bf19efff : System RAM
  01000000-015f753e : Kernel code
  015f753f-01aba6ff : Kernel data
  01bb9000-01d0bfff : Kernel bss
bf19f000-bf69efff : reserved
bf69f000-bf79efff : ACPI Non-volatile Storage
bf79f000-bf7fefff : ACPI Tables
bf7ff000-bf7fffff : System RAM
bf800000-bfffffff : reserved
c0000000-febfffff : PCI Bus 0000:00
  c0000000-d1ffffff : PCI Bus 0000:01
    c0000000-cfffffff : 0000:01:00.0
    d0000000-d1ffffff : 0000:01:00.0
  d2000000-d30fffff : PCI Bus 0000:01
    d2000000-d2ffffff : 0000:01:00.0
      d2000000-d2ffffff : nvidia
    d3000000-d3003fff : 0000:01:00.1
      d3000000-d3003fff : ICH HD audio
    d3080000-d30fffff : 0000:01:00.0
  d3100000-d38fffff : PCI Bus 0000:05
  d3900000-d40fffff : PCI Bus 0000:0d
  d4100000-d41fffff : PCI Bus 0000:0e
    d4100000-d4101fff : 0000:0e:00.0
      d4100000-d4101fff : xhci_hcd
  d4200000-d49fffff : PCI Bus 0000:0d
    d4200000-d42000ff : 0000:0d:00.0
      d4200000-d42000ff : mmc0
  d4a00000-d51fffff : PCI Bus 0000:05
  d5200000-d52fffff : PCI Bus 0000:03
    d5200000-d5201fff : 0000:03:00.0
      d5200000-d5201fff : iwlagn
  d5300000-d531ffff : 0000:00:19.0
    d5300000-d531ffff : e1000e
  d5320000-d5323fff : 0000:00:1b.0
    d5320000-d5323fff : ICH HD audio
  d5324000-d53240ff : 0000:00:1f.3
  d5325000-d532500f : 0000:00:16.0
    d5325000-d532500f : mei
  d5328000-d53287ff : 0000:00:1f.2
    d5328000-d53287ff : ahci
  d5329000-d53293ff : 0000:00:1d.0
    d5329000-d53293ff : ehci_hcd
  d532a000-d532a3ff : 0000:00:1a.0
    d532a000-d532a3ff : ehci_hcd
  d532b000-d532bfff : 0000:00:19.0
    d532b000-d532bfff : e1000e
  d532c000-d532cfff : 0000:00:16.3
  f8000000-fbffffff : PCI MMCONFIG 0000 [bus 00-3f]
    f8000000-fbffffff : reserved
      f8000000-fbffffff : pnp 00:02
fec00000-fec00fff : reserved
fed00000-fed003ff : HPET 0
fed08000-fed08fff : reserved
fed10000-fed19fff : reserved
  fed10000-fed13fff : pnp 00:02
  fed18000-fed18fff : pnp 00:02
  fed19000-fed19fff : pnp 00:02
fed1c000-fed1ffff : reserved
  fed1c000-fed1ffff : pnp 00:02
fed40000-fed4bfff : PCI Bus 0000:00
  fed45000-fed4bfff : pnp 00:02
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
ffd20000-ffffffff : reserved
100000000-43dffffff : System RAM
43e000000-43fffffff : RAM buffer

[X.] Other notes, patches, fixes, workarounds:


Patch follows:

-->8--

Subject: [PATCH] ppp_mppe: Don't discard non-FLUSHED-bit packets

In mppe_decompress, packets without the FLUSHED bit set
are discarded.  Some servers clear this bit on every other
packet and so streams are impossible to maintain.

Fix this by keeping these packets with the FLUSHED bit set.

This may turn out to be the wrong way to fix this, but it
has worked for me so far.  I only connect to three servers,
though.

Signed-off-by: Phil Hord <hordp@cisco.com>
---
 drivers/net/ppp/ppp_mppe.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 9a1849a..765c28a 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -517,12 +517,6 @@ mppe_decompress(void *arg, unsigned char *ibuf, int
isize, unsigned char *obuf,
                state->sanity_errors += 100;
                sanity = 1;
        }
-       if (!state->stateful && !flushed) {
-               printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not
set in "
-                      "stateless mode!\n", state->unit);
-               state->sanity_errors += 100;
-               sanity = 1;
-       }
        if (state->stateful && ((ccount & 0xff) == 0xff) && !flushed) {
                printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not
set on "
                       "flag packet!\n", state->unit);
-- 
1.7.10.509.g991919
