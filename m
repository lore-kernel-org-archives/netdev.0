From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: sky2: only 10Mb/s
Date: Thu, 3 Nov 2011 16:51:35 +0400
Message-ID: <20111103125135.GA11449@tugrik.mns.mnsspb.ru>
References: <201110171434.50436.pavel@netsafe.cz> <20111017085647.346a37cb@nehalam.linuxnetplumber.net> <201110172253.39948.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel =?utf-8?Q?Mat=C4=9Bja?= <pavel@netsafe.cz>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:35847 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932995Ab1KCNLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Nov 2011 09:11:25 -0400
Content-Disposition: inline
In-Reply-To: <201110172253.39948.pavel@netsafe.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 10:53:39PM +0200, Pavel Mat=C4=9Bja wrote:
> > > Hi,
> > > I tested new kernel and I have found out I have only 10Mb/s link =
instead
> > > of 100Mb/s to my router.
> > > If I did the git bisect right it was caused by commit
> > > 4fb99cd6ac4fe6d03a334a6f4ebb2bbfc4b479ed which was submitted by y=
ou.
> > >=20
> > > My card is (lspci -v):
> > > 05:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon =
Optima
> > > 88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)
> > >=20
> > >         Subsystem: ASUSTeK Computer Inc. Device 8439
> > >         Flags: bus master, fast devsel, latency 0, IRQ 80
> > >         Memory at fe6fc000 (64-bit, non-prefetchable) [size=3D16K=
]
> > >         I/O ports at b800 [size=3D256]
> > >         Expansion ROM at fe6c0000 [disabled] [size=3D128K]
> > >         Capabilities: [48] Power Management version 3
> > >         Capabilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64b=
it+
> > >         Capabilities: [c0] Express Legacy Endpoint, MSI 00
> > >         Capabilities: [100] Advanced Error Reporting
> > >         Capabilities: [130] Device Serial Number a5-89-6d-ff-ff-3=
0-cf-20
> > >         Kernel driver in use: sky2
> > >=20
> > > I'm quite sure it's related to Yukon Optima because "Ethernet con=
troller:
> > > Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Cont=
roller"
> > > in my work computer has 100Mb/s with the same kernel and driver.
> > >=20
> > > I got no response on netdev@vger.kernel.org.
> > > Can you help me?
> >=20
> > What is output of dmesg for sky2.
> >  dmesg | grep sky2
>=20
> sky2: driver version 1.28
> sky2 0000:05:00.0: PCI INT A -> GSI 51 (level, low) -> IRQ 51
> sky2 0000:05:00.0: setting latency timer to 64
> sky2 0000:05:00.0: Yukon-2 Optima chip revision 1
> sky2 0000:05:00.0: irq 80 for MSI/MSI-X
> sky2 0000:05:00.0: eth0: addr 20:cf:30:6d:89:a5
> sky2 0000:05:00.0: eth0: enabling interface
> sky2 0000:05:00.0: eth0: Link is up at 10 Mbps, full duplex, flow con=
trol both

Similar problem here with 3.1.0 kernel:

# dmesg |grep sky2      (on 3.1.0)
[    2.417340] sky2: driver version 1.29
[    2.419844] sky2 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> I=
RQ 19
[    2.422393] sky2 0000:02:00.0: setting latency timer to 64
[    2.422444] sky2 0000:02:00.0: Yukon-2 Optima chip revision 1
[    2.425414] sky2 0000:02:00.0: irq 42 for MSI/MSI-X
[    2.426144] sky2 0000:02:00.0: eth0: addr 1c:c1:de:ae:73:8a
[   10.836737] sky2 0000:02:00.0: eth0: enabling interface
[   12.710240] sky2 0000:02:00.0: eth0: Link is up at 10 Mbps, full dup=
lex, flow control rx

it used to setup the link to switch at 1 Gbps with Linux 3.0:

# dmesg |grep sky2      (on 3.0.0)
[    2.442283] sky2: driver version 1.28
[    2.444818] sky2 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> I=
RQ 19
[    2.447345] sky2 0000:02:00.0: setting latency timer to 64
[    2.447397] sky2 0000:02:00.0: Yukon-2 Optima chip revision 1
[    2.450062] sky2 0000:02:00.0: irq 42 for MSI/MSI-X
[    2.450712] sky2 0000:02:00.0: eth0: addr 1c:c1:de:ae:73:8a
[   11.352480] sky2 0000:02:00.0: eth0: enabling interface
[   13.824540] sky2 0000:02:00.0: eth0: Link is up at 1000 Mbps, full d=
uplex, flow control rx
[   13.827178] sky2 0000:02:00.0: eth0: Link is up at 1000 Mbps, full d=
uplex, flow control rx

(strangely it puts 2 lines about "link is up")


Reverting 8dc47b9c2c9e9f607268f6bf3e85408123a36bca "sky2: support for
new Optima chipsets (EXPERIMENTAL)" helps.




# lspci -vv -s 02:00.0  (same with both 3.1.0 and 3.0.0)
02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8059 PCI-=
E Gigabit Ethernet Controller (rev 11)
        Subsystem: Hewlett-Packard Company Device 1608
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 42
        Region 0: Memory at 50100000 (64-bit, non-prefetchable) [size=3D=
16K]
        Region 2: I/O ports at 2000 [size=3D256]
        Expansion ROM at 50600000 [disabled] [size=3D128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [50] Vital Product Data
                Product Name: Marvell Yukon 88E8059 Gigabit Ethernet Co=
ntroller
                Read-only fields:
                        [PN] Part number: Yukon 88E8059
                        [EC] Engineering changes: Rev. 1.0
                        [MN] Manufacture ID: 4d 61 72 76 65 6c 6c
                        [SN] Serial number: AbCdEfGAE738A
                        [CP] Extended capability: 01 10 cc 03
                        [RV] Reserved: checksum good, 9 byte(s) reserve=
d
                Read/write fields:
                        [RW] Read-write area: 121 byte(s) free
                End
        Capabilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 4169
        Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s =
unlimited, L1 unlimited
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- U=
nsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr=
+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, =
Latency L0 <1us, L1 <32us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain-=
 CommClk-
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
        Kernel driver in use: sky2





Thanks beforehand,
Kirill
