From: - <kd6lvw@yahoo.com>
Subject: PROBLEM: SIS900 Driver change in Linux Kernel 2.6.21 causes kernel panic.
Date: Wed, 16 May 2007 14:33:18 -0700 (PDT)
Message-ID: <577536.90963.qm@web84207.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Neil Horman <nhorman@tuxdriver.com>, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web84207.mail.re3.yahoo.com ([216.252.111.7]:42140 "HELO
	web84207.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758918AbXEPVkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 17:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel version 2.6.20.4 works.  What I'm experiencing is a kernel panic as
soon as the first received packet comes in via the sis900 ethernet
interface.  The machine is locked up and part of the kernel panic message
is lost as it has scrolled off the screen and the virtual terminal has
crashed as well (the kernel appears to have done a permanent halt - the
keyboard LEDs are flashing).  The only way I could get the machine to boot
without this problem was to unplug the ethernet cable - but it would
appear as soon as the the first packet was received after plugging the
cable back in.  That's not good since the machine in question is a server
in a co-location facility (I can't print the screen either).  The kernel
panic was repeatable without fail.  As this usually happens before "init"
is called, the only "program" running is the kernel itself.  I don't have
any syslog/dmesg message recorded to disk for the event.  I've rolled back
to version 2.6.20.4 in the meantime.

Hardware:  Motherboard is a PC Chips M810LR Revision 5.0 with an AMD
Athlon T-bird series 1100/200FSB CPU and 1Gb of PC133 SDRAM.  (Yes, it's
an older machine, but its load isn't that great).  I compiled the kernel
from a full source tar-ball, not from a patched source based on a prior
version.

What I could get from the kernel symbol traceback is that the first symbol
happens to be "sis900_rxbuf" (or something like that) - which confirms to
me that it is definently this driver that has the problem.  I compile the
driver directly into the kernel - I'm not using it as a module.  Whatever
changes were done, it's obvious that the driver is receiving a packet
before some data structure is ready to handle it and the kernel is fatally
exiting as a result.

Although there are two changes (2.6.20.4 -> 2.6.21), I suspect that the
first one is the cause of the problem.
---------------------------------------------------------------------------
http://www.kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.21

commit b748d9e3b80dc7e6ce6bf7399f57964b99a4104c
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Fri Apr 20 09:54:58 2007 -0400

    sis900: Allocate rx replacement buffer before rx operation
    
    	The sis900 driver appears to have a bug in which the receive routine
    passes the skbuff holding the received frame to the network stack
before
    refilling the buffer in the rx ring.  If a new skbuff cannot be
allocated, the
    driver simply leaves a hole in the rx ring, which causes the driver to
stop
    receiving frames and become non-recoverable without an rmmod/insmod
according to
    reporters.  This patch reverses that order, attempting to allocate a
replacement
    buffer first, and receiving the new frame only if one can be
allocated.  If no
    skbuff can be allocated, the current skbuf in the rx ring is recycled,
dropping
    the current frame, but keeping the NIC operational.
    
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit f3be97427172856d6865ddfedea84fa3a9f33227
Author: Andrew Morton <akpm@linux-foundation.org>
Date:   Tue Mar 6 02:41:55 2007 -0800

    sis900 warning fixes
    
    drivers/net/sis900.c: In function 'sis900_reset_phy':
    drivers/net/sis900.c:972: warning: 'status' may be used uninitialized
in this function
    drivers/net/sis900.c: In function 'sis900_check_mode':
    drivers/net/sis900.c:1431: warning: 'status' may be used uninitialized
in this function
    drivers/net/sis900.c: In function 'sis900_timer':
    drivers/net/sis900.c:1467: warning: 'status' may be used uninitialized
in this function
    
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>
---------------------------------------------------------------------------
!sh /usr/src/linux/scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux snarked.org 2.6.20.4 #1 Mon May 7 22:52:04 UTC 2007 i686 unknown
unknown GNU/Linux
 
Gnu C                  3.3.6
Gnu make               3.80
binutils               2.17.50.0.6
util-linux             2.12r
mount                  2.12r
module-init-tools      implemented
e2fsprogs              1.38
jfsutils               1.1.8
reiserfsprogs          3.6.19
xfsprogs               2.6.13
pcmcia-cs              3.2.8
quota-tools            3.12.
PPP                    2.4.1
nfs-utils              1.0.7
Linux C Library        2.3.5
Dynamic linker (ldd)   2.3.5
Linux C++ Library      5.0.7
Procps                 3.2.5
Net-tools              1.60
Kbd                    1.12
oprofile               0.9.1
Sh-utils               5.2.1
udev                   064
Modules Loaded         
  (none)

!lspci -vvv 
00:00.0 0600: 1039:0730 (rev 02)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
        Latency: 32
        Region 0: Memory at d0000000 (32-bit, non-prefetchable) [size=64M]
        Capabilities: [c0] AGP version 2.0
                Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64-
HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
Rate=<none>

00:00.1 0101: 1039:5513 (rev d0) (prog-if 80)
        Subsystem: 1039:5513
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 16
        Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)
[disabled] [size=8]
        Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
[disabled] [size=1]
        Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)
[disabled] [size=8]
        Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
[disabled] [size=1]
        Region 4: I/O ports at ff00 [size=16]

00:01.0 0601: 1039:0018
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:01.1 0200: 1039:0900 (rev 82)
        Subsystem: 1039:0900
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (13000ns min, 2750ns max)
        Interrupt: pin C routed to IRQ 3
        Region 0: I/O ports at d400 [size=256]
        Region 1: Memory at cfff7000 (32-bit, non-prefetchable) [size=4K]
        Expansion ROM at cffc0000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=160mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:01.2 0c03: 1039:7001 (rev 07) (prog-if 10)
        Subsystem: 1039:7001
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (20000ns max), Cache Line Size 08
        Interrupt: pin D routed to IRQ 5
        Region 0: Memory at cfffc000 (32-bit, non-prefetchable) [size=4K]

00:01.3 0c03: 1039:7001 (rev 07) (prog-if 10)
        Subsystem: 1039:7000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (20000ns max), Cache Line Size 08
        Interrupt: pin D routed to IRQ 5
        Region 0: Memory at cfffd000 (32-bit, non-prefetchable) [size=4K]

00:01.4 0401: 1039:7018 (rev 02)
        Subsystem: 1039:7018
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (500ns min, 6000ns max)
        Interrupt: pin B routed to IRQ 11
        Region 0: I/O ports at d800 [size=256]
        Region 1: Memory at cfffe000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=55mA
PME(D0-,D1-,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:02.0 0604: 1039:0001
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+
ParErr- Stepping- SERR+ FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 0000b000-0000bfff
        Memory behind bridge: cfe00000-cfefffff
        Prefetchable memory behind bridge: bfc00000-cfcfffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

01:00.0 0300: 1039:6300 (rev 31)
        Subsystem: 1039:6300
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        BIST result: 00
        Region 0: Memory at c0000000 (32-bit, prefetchable) [size=128M]
        Region 1: Memory at cfee0000 (32-bit, non-prefetchable)
[size=128K]
        Region 2: I/O ports at bc00 [size=128]
        Capabilities: [40] Power Management version 1
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] AGP version 2.0
                Status: RQ=16 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64-
HTrans- 64bit- FW- AGP3- Rate=x1,x2,x4
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
Rate=<none>

!cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 4
model name      : AMD Athlon(tm) Processor
stepping        : 2
cpu MHz         : 1095.960
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
cmov pat pse36 mmx fxsr syscall mmxext 3dnowext 3dnow
bogomips        : 2193.07
clflush size    : 32

!cat /proc/iomem
00000000-0009fbff : System RAM
0009fc00-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000cbfff : Video ROM
000f0000-000fffff : System ROM
00100000-3efeffff : System RAM
  00100000-00287490 : Kernel code
  00287491-003183f7 : Kernel data
3eff0000-3eff7fff : ACPI Tables
3eff8000-3effffff : ACPI Non-volatile Storage
bfc00000-cfcfffff : PCI Bus #01
  c0000000-c7ffffff : 0000:01:00.0
cfe00000-cfefffff : PCI Bus #01
  cfee0000-cfefffff : 0000:01:00.0
cffc0000-cffdffff : 0000:00:01.1
cfff7000-cfff7fff : 0000:00:01.1
  cfff7000-cfff7fff : sis900
cfffc000-cfffcfff : 0000:00:01.2
cfffd000-cfffdfff : 0000:00:01.3
cfffe000-cfffefff : 0000:00:01.4
d0000000-d3ffffff : 0000:00:00.0
fffc0000-ffffffff : reserved

!cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:00.1
  0170-0177 : ide1
01f0-01f7 : 0000:00:00.1
  01f0-01f7 : ide0
0290-0297 : it87-isa
0376-0376 : 0000:00:00.1
  0376-0376 : ide1
03c0-03df : vga+
03f6-03f6 : 0000:00:00.1
  03f6-03f6 : ide0
0cf8-0cff : PCI conf1
5080-5093 : sis630_smbus
b000-bfff : PCI Bus #01
  bc00-bc7f : 0000:01:00.0
d400-d4ff : 0000:00:01.1
  d400-d4ff : sis900
d800-d8ff : 0000:00:01.4
ff00-ff0f : 0000:00:00.1
  ff00-ff07 : ide0
  ff08-ff0f : ide1

