From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
	problems
Date: Tue, 3 Jun 2008 08:16:19 +0200
Message-ID: <20080603061618.GB9301@yamamaya.is-a-geek.org>
References: <20080601074935.GA2529@yamamaya.is-a-geek.org> <Pine.LNX.4.44L0.0806021706130.17236-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	linux-acpi@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:43330 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364AbYFCGQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 02:16:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0806021706130.17236-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:
> On Sun, 1 Jun 2008, Tobias Diedrich wrote:
>=20
> > > > (BTW I first thought the 'immediate reboot because of usb wake'=
 effect is
> > > > caused by the optical mouse generating a wake event, but it rat=
her
> > > > seems to be a problem with a flaky secondary usb host controlle=
r,
> > > > which sees a connected device where nothing is attached)
> > >=20
> > > Can you provide debugging information (i.e., CONFIG_USB_DEBUG) wi=
th the=20
> > > details on this bogus wakeup?
> >=20
> > Sure.
> > Here is the complete log of one boot and two s2disk_platform cycles
> > captured using the serial console (in the first s2disk I forgot to
> > remove the 'turn off /sys/bus/usb/device/usb?/power/wakeup' part).
> >=20
> > Interestingly even with power/wakeup disabled for usb1 and usb2,
> > which I assume to be the usb root ports, I could wake up the system
> > by pressing a key on my keyboard (which didn't work before turning
> > on CONFIG_USB_SUSPEND).
> >=20
> > On the second suspend the system rebooted immediately as expected
> > (I power/wakeup for usb1 and usb2 back on and disabled the part in
> > the script).
> >=20
> > I think this might be some general usb hw flakiness, since it seems
> > to detect (and has so for a long time) a non-existing device:
> >=20
> > lsusb output:
> > Bus 002 Device 003: ID 045e:00db Microsoft Corp. Natural Ergonomic =
Keyboard 4000 V1.0
> > Bus 002 Device 002: ID 045e:0040 Microsoft Corp. Wheel Mouse Optica=
l
> > Bus 002 Device 001: ID 1d6b:0001 =20
> > Bus 001 Device 001: ID 1d6b:0002 =20
> >=20
> > bogus device?:
> > [14316046.469949] usb 2-4: new full speed USB device using ohci_hcd=
 and address 12
> > [14316046.679951] usb 2-4: device descriptor read/64, error -62
> > [14316046.986619] usb 2-4: device descriptor read/64, error -62
> > [14316047.263284] usb 2-4: new full speed USB device using ohci_hcd=
 and address 13
> > [14316047.476614] usb 2-4: device descriptor read/64, error -62
> > [14316047.786618] usb 2-4: device descriptor read/64, error -62
> > [14316048.063282] usb 2-4: new full speed USB device using ohci_hcd=
 and address 14
> > [14316048.499945] usb 2-4: device not accepting address 14, error -=
62
> > [14316048.669950] usb 2-4: new full speed USB device using ohci_hcd=
 and address 15
> > [14316049.106612] usb 2-4: device not accepting address 15, error -=
62
> > [14316049.112960] hub 2-0:1.0: unable to enumerate USB device on po=
rt 4
>=20
> It's possible.  Maybe there's a builtin broken USB device, or maybe t=
he=20
> D+ pin on port 4 is wired to a positive voltage source.

One of the ports on the back of the board seems to be broken (Maybe
esd?), the other three work fine, but nothing happens when I plug a
device into that one, so I guess that's the culprit.

> The log didn't reveal anything.  Perhaps you can learn more by lookin=
g=20
> at the "registers" file for that OHCI controller in debugfs.

Ok, I can try that this evening...

> Also, you should run "lspci -vv" as root to see what wakeup signals t=
he=20
> USB controllers are issuing.

00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a1)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [44] HyperTransport: Slave or Primary Interface
		Command: BaseUnitID=3D0 UnitCnt=3D15 MastHost- DefDir- DUL-
		Link Control 0: CFlE+ CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=3D0 =
IsocEn- LSEn+ ExtCTL- 64b-
		Link Config 0: MLWI=3D16bit DwFcIn- MLWO=3D16bit DwFcOut- LWI=3D16bit=
 DwFcInEn- LWO=3D16bit DwFcOutEn-
		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=3D0 =
IsocEn- LSEn- ExtCTL- 64b-
		Link Config 1: MLWI=3D8bit DwFcIn- MLWO=3D8bit DwFcOut- LWI=3D8bit Dw=
=46cInEn- LWO=3D8bit DwFcOutEn-
		Revision ID: 1.03
		Link Frequency 0: 1.0GHz
		Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 0: 200MHz+ 300MHz+ 400MHz+ 500MHz+ 600MHz+ =
800MHz+ 1.0GHz+ 1.2GHz- 1.4GHz- 1.6GHz- Vend-
		Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD-
		Link Frequency 1: 200MHz
		Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz- =
800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
		Error Handling: PFlE+ OFlE+ PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF- =
RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
		Prefetchable memory behind bridge Upper: 00-00
		Bus Number: 00
	Capabilities: [e0] #00 [fee0]

00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a2)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a2)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at fc00 [size=3D64]
	Region 4: I/O ports at 1c00 [size=3D64]
	Region 5: I/O ports at 1c40 [size=3D64]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: nForce2_smbus

00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1=
) (prog-if 10 [OHCI])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at fe02f000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: ohci_hcd

00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2=
) (prog-if 20 [EHCI])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin B routed to IRQ 20
	Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=3D256]
	Capabilities: [44] Debug port: BAR=3D1 offset=3D0098
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME+
	Kernel driver in use: ehci_hcd

00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1) (prog-if 8=
a [Master SecP PriP])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [dis=
abled] [size=3D8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [dis=
abled] [size=3D1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [dis=
abled] [size=3D8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [dis=
abled] [size=3D1]
	Region 4: I/O ports at f000 [size=3D16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: pata_amd
	Kernel modules: pata_amd

00:05.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2=
) (prog-if 85 [Master SecO PriO])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin A routed to IRQ 23
	Region 0: I/O ports at 09f0 [size=3D8]
	Region 1: I/O ports at 0bf0 [size=3D4]
	Region 2: I/O ports at 0970 [size=3D8]
	Region 3: I/O ports at 0b70 [size=3D4]
	Region 4: I/O ports at dc00 [size=3D16]
	Region 5: Memory at fe02d000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: sata_nv

00:05.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2=
) (prog-if 85 [Master SecO PriO])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin B routed to IRQ 22
	Region 0: I/O ports at 09e0 [size=3D8]
	Region 1: I/O ports at 0be0 [size=3D4]
	Region 2: I/O ports at 0960 [size=3D8]
	Region 3: I/O ports at 0b60 [size=3D4]
	Region 4: I/O ports at c800 [size=3D16]
	Region 5: Memory at fe02c000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: sata_nv

00:05.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2=
) (prog-if 85 [Master SecO PriO])
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (750ns min, 250ns max)
	Interrupt: pin C routed to IRQ 21
	Region 0: I/O ports at c400 [size=3D8]
	Region 1: I/O ports at c000 [size=3D4]
	Region 2: I/O ports at bc00 [size=3D8]
	Region 3: I/O ports at b800 [size=3D4]
	Region 4: I/O ports at b400 [size=3D16]
	Region 5: Memory at fe02b000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/2 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [cc] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: sata_nv

00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2) (prog-=
if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D32
	I/O behind bridge: 00009000-00009fff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr+ DiscTmrStat- DiscTmrSERREn+
	Capabilities: [b8] Subsystem: nVidia Corporation Unknown device cb84
	Capabilities: [8c] HyperTransport: MSI Mapping Enable+ Fixed-
		Mapping Address Base: 00000000fee00000

00:06.1 Audio device: nVidia Corporation MCP55 High Definition Audio (r=
ev a2)
	Subsystem: ASUSTeK Computer Inc. Unknown device 81f6
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (500ns min, 1250ns max)
	Interrupt: pin B routed to IRQ 22
	Region 0: Memory at fe020000 (32-bit, non-prefetchable) [size=3D16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Queue=3D=
0/0 Enable-
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [6c] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: HDA Intel
	Kernel modules: snd-hda-intel

00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at fe02a000 (32-bit, non-prefetchable) [size=3D4K]
	Region 1: I/O ports at b000 [size=3D8]
	Region 2: Memory at fe029000 (32-bit, non-prefetchable) [size=3D256]
	Region 3: Memory at fe028000 (32-bit, non-prefetchable) [size=3D16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable+ DSel=3D0 DScale=3D0 PME-
	Capabilities: [70] MSI-X: Enable- Mask- TabSize=3D8
		Vector table: BAR=3D2 offset=3D00000000
		PBA: BAR=3D3 offset=3D00000000
	Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Queue=3D=
0/3 Enable-
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [6c] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: forcedeth
	Kernel modules: forcedeth

00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at fe027000 (32-bit, non-prefetchable) [size=3D4K]
	Region 1: I/O ports at ac00 [size=3D8]
	Region 2: Memory at fe026000 (32-bit, non-prefetchable) [size=3D256]
	Region 3: Memory at fe025000 (32-bit, non-prefetchable) [size=3D16]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable+ DSel=3D0 DScale=3D0 PME-
	Capabilities: [70] MSI-X: Enable- Mask- TabSize=3D8
		Vector table: BAR=3D2 offset=3D00000000
		PBA: BAR=3D3 offset=3D00000000
	Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Queue=3D=
0/3 Enable-
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [6c] HyperTransport: MSI Mapping Enable+ Fixed+
	Kernel driver in use: forcedeth
	Kernel modules: forcedeth

00:0a.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2=
) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
	I/O behind bridge: 00008000-00008fff
	Memory behind bridge: fde00000-fdefffff
	Prefetchable memory behind bridge: 00000000e8000000-00000000efffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/1 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [60] HyperTransport: MSI Mapping Enable+ Fixed-
		Mapping Address Base: 00000000fee00000
	Capabilities: [80] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <4u=
s
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x8, ASPM L0s L1, Latency L0 <51=
2ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive+ BWM=
gmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkCh=
g-
			Control: AttnInd Off, PwrInd On, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisibl=
e-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Kernel driver in use: pcieport-driver

00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2=
) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D0
	I/O behind bridge: 00006000-00007fff
	Memory behind bridge: fdd00000-fddfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/1 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [60] HyperTransport: MSI Mapping Enable+ Fixed-
		Mapping Address Base: 00000000fee00000
	Capabilities: [80] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <4u=
s
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <51=
2ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled+ Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWM=
gmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkCh=
g-
			Control: AttnInd Off, PwrInd On, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisibl=
e-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Kernel driver in use: pcieport-driver

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=3D0
		Link Config: MLWI=3D16bit MLWO=3D16bit LWI=3D16bit LWO=3D16bit
		Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [f0] Secure device <?>
	Kernel driver in use: k8temp
	Kernel modules: k8temp

01:08.0 Multimedia audio controller: Creative Labs SB Live! EMU10k1 (re=
v 07)
	Subsystem: Creative Labs SBLive! 5.1 Model SB0100
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (500ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at 9c00 [size=3D32]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: EMU10K1_Audigy
	Kernel modules: snd-emu10k1

01:08.1 Input device controller: Creative Labs SB Live! Game Port (rev =
07)
	Subsystem: Creative Labs Gameport Joystick
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR- INTx-
	Latency: 32
	Region 0: I/O ports at 9800 [size=3D8]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: Emu10k1_gameport
	Kernel modules: emu10k1-gp

02:00.0 VGA compatible controller: ATI Technologies Inc RV370 5B60 [Rad=
eon X300 (PCIE)] (prog-if 00 [VGA controller])
	Subsystem: Hightech Information System Ltd. Unknown device 201e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at e8000000 (32-bit, prefetchable) [size=3D128M]
	Region 1: I/O ports at 8c00 [size=3D256]
	Region 2: Memory at fdef0000 (32-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at fdec0000 [disabled] [size=3D128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <128ns, L1 <2u=
s
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <1=
28ns, L1 <1us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWM=
gmt- ABWMgmt-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Kernel modules: radeonfb

02:00.1 Display controller: ATI Technologies Inc RV370 [Radeon X300SE]
	Subsystem: Hightech Information System Ltd. Unknown device 201f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Region 0: Memory at fdee0000 (32-bit, non-prefetchable) [size=3D64K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <128ns, L1 <2u=
s
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <1=
28ns, L1 <1us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWM=
gmt- ABWMgmt-

HTH,

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
