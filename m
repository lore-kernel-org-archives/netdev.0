From: Hans Nieser <hnsr@xs4all.nl>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Mon, 21 Feb 2011 12:56:48 +0100
Message-ID: <1298289408.13286.53.camel@krikkit>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu wrote:
> Seblu <seblu@seblu.net> :
> [...]
> > I've applyed your patch on 2.6.38-rc5. Host have rebooted 2mn after=
 udp start.
> > After this reboot, host is still on after 2 hour under a 1Gbit/s ud=
p flow.
>=20
> Thanks for testing.
>=20
> > I attached a dmesg output before reboot. Do you need anything else?
>=20
> Mostly :
> 1. .config
> 2. the size of the udp packets and the mtu
>=20
> As an option :
> 3. a few seconds of 'vmstat 1' from the host under test
> 4. an 'ethtool -s eth0' from the host under test
> 5. /proc/interrupts from the host under test
> 6. lspci -tv=20
>=20
> Can you apply the two attached patches on top of the previous ones an=
d
> give it a try ? The debug should not be too verbose if things are sta=
tionary
> enough.
>=20

<...>

Hi there, I just wanted to chime in on the discussion as I've been havi=
ng similar
problems with similar hardware; I have a Gigabyte P55-USB3 motherboard
with an on-board Realtek NIC:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
r8169 0000:03:00.0: setting latency timer to 64
r8169 0000:03:00.0: (unregistered net_device): unknown MAC, using famil=
y default
r8169 0000:03:00.0: irq 46 for MSI/MSI-X
r8169 0000:03:00.0: eth0: RTL8168b/8111b at 0xffffc9000001a000, 1c:6f:6=
5:28:2f:2a, XID 0c100000 IRQ 46

A few days ago I noticed my machine had locked up while I was copying
some backup archives over the local gbit LAN over sftp. I then found ou=
t
that any kind of high-speed transfer to my machine would cause it to
lock up rather quickly (within seconds), wether that was via sftp, samb=
a
or simply http (wget) from a webserver on my LAN. Slow(ish) transfers o=
f
at most 120mbps don't seem to cause any issues, as I've been able to
download packages via my internet connection for updating my Gentoo
system for months without trouble.

I also found that on dmesg I would get hundreds of "r8169 0000:03:00.0:
eth0: link up" in the few seconds before my machine locks up (or
sometimes it just reboots - but never shutdowns unlike S=C3=A9bastien).

I have managed to reproduce the hangs/reboots with the following
kernels:

2.6.38-rc5 (also including all three patches you posted in this thread)
2.6.37
2.6.36

With 2.6.36 it seems to take a bit longer to reproduce the hang/reboot
than it does with 2.6.37 and 2.6.38-rc5, and at some point I even got a
backtrace before it locked up (I suppose some stuff has scrolled off th=
e
screen though, not sure how useful this is):

  [<ffffffff814a3f8f>] page_fault+0x1f/0x30
  [<ffffffff812c529a>] ? ahci_interrupt+0xea/0x700
  [<ffffffff813b6901>] ? skb_checksum+0x51/0x2f0
  [<ffffffff8108006a>] handle_IRQ_event+0x3a/0xd0
  [<ffffffff8108211e>] handle_edge_irq+0xbe/0x170
  [<ffffffff810052cd>] handle_irq+0x1d/0x30
  [<ffffffff810047e7>] do_IRQ+0x67/0xf0
  [<ffffffff814a3d53>] ret_from_intr+0x0/0xa
  [<ffffffff8120110b>] ? memcpy+0xb/0xb0
  [<ffffffff8120ce7e>] ? swiotlb_bounce+0x1e/0x40
  [<ffffffff8120cedb>] ? swiotlb_tbl_sync_single+0x3b/0x70
  [<ffffffff8120cf6b>] ? swiotlb_sync_single+0x5b/0x80
  [<ffffffff8120d08c>] ? swiotlb_sync_single_for_cpu+0xc/0x10
  [<ffffffff812c85da>] ? rtl8169_rx_interrupt+0x25a/0x550
  [<ffffffff81046c9d>] ? update_process_times+0x5d/0x70
  [<ffffffff812cb828>] ? rtl8169_poll+0x38/0x260
  [<ffffffff813c0f0e>] ? net_rx_action+0x8e/0x1a0
  [<ffffffff812caab1>] ? rtl8169_interrupt+0x101/0x350
  [<ffffffff810404a6>] ? __do_softirq+0xa6/0x130
  [<ffffffff8100320c>] ? call_softirq+0x1c/0x30
  [<ffffffff8100527d>] ? do_softirq+0x4d/0x80
  [<ffffffff8103fdad>] ? irq_exit+0x4d/0x50
  [<ffffffff810047f0>] ? do_IRQ+0x70/0xf0
  [<ffffffff814a3d53>] ? ret_from_intr+0x0/0xa
  <EOI>

  (I had to manually type this over so there may be typos in there)

On all the kernel versions on which I was able to reproduce the problem
my transer speed was also much slower than expected; somewhere around
10-20MiB/s (it seems to start out at 20MiB/s, then go down a bit to
<10MiB/s before the machine finally locks up, or sometimes the reverse
of this).

I was not able to reproduce the problem on 2.6.35.9, and managed to get
consistent transfer speeds of around 107MiB/s (using wget) with that
kernel. While I haven't spent too much time trying to reproduce it (jus=
t
a couple dozen of transfers of a 1GB file), at the very least it is muc=
h
harder to reproduce than on the newer kernels. There were also much les=
s
'link up' messages on dmesg with this kernel, just one every few second=
s
instead of dozens per second.

I'm not sure if it's worth the effort to try and git bisect between
2.6.35 and 2.6.36, but let me know if you think it is and I'll give it =
a
shot.

One other thing I observed (not sure if it's relevant, but just in case=
)
was that for all the kernels that I was able to reproduce the problem
with, the MSI irq was 46, while with 2.6.35.9 the MSI irq was 50.

I'll spend some more time this evening or tomorrow doing some more
testing and getting the other things you requested from S=C3=A9bastien =
if you
think that useful to know in my case as well

Here is at least the output of lspci -tv:

  lspci -tv:

    -[0000:00]-+-00.0  Intel Corporation Core Processor DMI
               +-03.0-[01]--+-00.0  ATI Technologies Inc Cypress [Radeo=
n HD 5800 Series]
               |            \-00.1  ATI Technologies Inc Cypress HDMI A=
udio [Radeon HD 5800 Series]
               +-08.0  Intel Corporation Core Processor System Manageme=
nt Registers
               +-08.1  Intel Corporation Core Processor Semaphore and S=
cratchpad Registers
               +-08.2  Intel Corporation Core Processor System Control =
and Status Registers
               +-08.3  Intel Corporation Core Processor Miscellaneous R=
egisters
               +-10.0  Intel Corporation Core Processor QPI Link
               +-10.1  Intel Corporation Core Processor QPI Routing and=
 Protocol Registers
               +-1a.0  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1a.1  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1a.2  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1a.7  Intel Corporation 5 Series/3400 Series Chipset U=
SB2 Enhanced Host Controller
               +-1b.0  Intel Corporation 5 Series/3400 Series Chipset H=
igh Definition Audio
               +-1c.0-[02]--+-00.0  JMicron Technology Corp. JMB362/JMB=
363 Serial ATA Controller
               |            \-00.1  JMicron Technology Corp. JMB362/JMB=
363 Serial ATA Controller
               +-1c.1-[03]----00.0  Realtek Semiconductor Co., Ltd. RTL=
8111/8168B PCI Express Gigabit Ethernet controller
               +-1c.2-[04]----00.0  NEC Corporation Device 0194
               +-1d.0  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1d.1  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1d.2  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1d.3  Intel Corporation 5 Series/3400 Series Chipset U=
SB Universal Host Controller
               +-1d.7  Intel Corporation 5 Series/3400 Series Chipset U=
SB2 Enhanced Host Controller
               +-1e.0-[05]----04.0  Texas Instruments TSB12LV23 IEEE-13=
94 Controller
               +-1f.0  Intel Corporation 5 Series Chipset LPC Interface=
 Controller
               +-1f.2  Intel Corporation 5 Series/3400 Series Chipset 6=
 port SATA AHCI Controller
               \-1f.3  Intel Corporation 5 Series/3400 Series Chipset S=
MBus Controller

  and lspci -vvxxx for my device (the motherboard reported is incorrect=
, it's definitely a GA-P55-USB3):

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/81=
68B PCI Express Gigabit Ethernet controller (rev 06)
        Subsystem: Giga-byte Technology GA-EP45-DS5 Motherboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 46
        Region 0: I/O ports at de00 [size=3D256]
        Region 2: Memory at fbeff000 (64-bit, prefetchable) [size=3D4K]
        Region 4: Memory at fbef8000 (64-bit, prefetchable) [size=3D16K=
]
        [virtual] Expansion ROM at fbe00000 [disabled] [size=3D128K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,=
D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
                Address: 00000000fee0f00c  Data: 4189
        Capabilities: [70] Express (v2) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s =
<512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- U=
nsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr=
+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, =
Latency L0 <512ns, L1 <64us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- =
CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+=
 DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Not Supported, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [b0] MSI-X: Enable- Count=3D4 Masked-
                Vector table: BAR=3D4 offset=3D00000000
                PBA: BAR=3D4 offset=3D00000800
        Capabilities: [d0] Vital Product Data
                Unknown small resource type 00, will not decode more.
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmp=
lt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonF=
atalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonF=
atalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap=
+ ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=3DFixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=3D00 MaxTimeSlots=3D1 RejSnoo=
pTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- W=
RR256-
                        Ctrl:   Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D=
ff
                        Status: NegoPending- InProgress-
        Capabilities: [160 v1] Device Serial Number 12-34-56-78-12-34-5=
6-78
        Kernel driver in use: r8169
00: ec 10 68 81 07 04 10 00 06 00 00 02 10 00 00 00
10: 01 de 00 00 00 00 00 00 0c f0 ef fb 00 00 00 00
20: 0c 80 ef fb 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
40: 01 50 c3 ff 08 00 00 00 00 00 00 00 00 00 00 00
50: 05 70 81 00 0c f0 e0 fe 00 00 00 00 89 41 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 10 b0 02 02 c1 8c 28 00 10 50 11 00 11 3c 07 00
80: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 11 d0 03 00 04 00 00 00 04 08 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 03 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
