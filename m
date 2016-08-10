From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Wed, 10 Aug 2016 10:03:29 +1000
Message-ID: <1470787409.3015.81.camel@kernel.crashing.org>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	 <1452684335-46107-4-git-send-email-hare@suse.de>
	 <20160209210458.GB32530@localhost>
	 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bjorn Helgaas <helgaas@kernel.org>, Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-09 at 11:12 -0700, Alexander Duyck wrote:
> 
> The PCI spec is what essentially assumes that there is only one block.
> If I am not mistaken in the case of this device the second block here
> actually contains device configuration data, not actual VPD data.  The
> issue here is that the second block is being accessed as VPD when it
> isn't.

Devices do funny things with config space, film at 11. VFIO trying to
be the middle man and intercept/interpret things is broken, cannot work,
will never work, will just results in lots and lots of useless code, but
I've been singing that song for too long and nobody seems to care...

> > > #0000 Large item 42 bytes; name 0x2 Identifier String
> > #002d Large item 74 bytes; name 0x10
> > #007a Small item 1 bytes; name 0xf End Tag
> > ---
> > #0c00 Large item 16 bytes; name 0x2 Identifier String
> > #0c13 Large item 234 bytes; name 0x10
> > #0d00 Large item 252 bytes; name 0x11
> > #0dff Small item 0 bytes; name 0xf End Tag
> 
> The second block here is driver proprietary setup bits.

Right. They happen to be in VPD on this device. They an be elsewhere on
other devices. In between capabilities on some, in vendor caps on others...

> > > The cxgb3 driver is reading the second bit starting from 0xc00 but since
> > the size is wrongly detected as 0x7c, VFIO blocks access beyond it and the
> > guest driver fails to probe.
> >
> > I also cannot find a clause in the PCI 3.0 spec saying that there must be
> > just a single block, is it there?
> 
> > The problem is we need to be able to parse it.

We can parse the standard part for generic stuff like inventory tools
or lsvpd, but we shouldn't get in the way of the driver poking at its
device.

>   The spec defines a
> series of tags that can be used starting at offset 0.  That is how we
> are supposed to get around through the VPD data.  The problem is we
> can't have more than one end tag and what appears to be happening here
> is that we are defining a second block of data which uses the same
> formatting as VPD but is not VPD.
> 
> > What would the correct fix be? Scanning all 32k of VPD is not an option I
> > suppose as this is what this patch is trying to avoid. Thanks.
> 
> I adding the current cxgb3 maintainer and netdev list to the Cc.  This
> is something that can probably be addressed via a PCI quirk as what
> needs to happen is that we need to extend the VPD in the case of this
> part in order to include this second block.  As long as we can read
> the VPD data all the way out to 0xdff odds are we could probably just
> have the size arbitrarily increased to 0xe00 via the quirk and then
> you would be able to access all of the VPD for the device.  We already
> have code making other modifications to drivers/pci/quirks.c for
> several Broadcom devices and probably just need something similar to
> allow extended access in the case of these devices.


> > >
> >
> >
> > This is the device:
> >
> > > [aik@p81-p9 ~]$ sudo lspci -vvnns 0001:03:00.0
> > 0001:03:00.0 Ethernet controller [0200]: Chelsio Communications Inc T310
> > 10GbE Single Port Adapter [1425:0030]
> >         Subsystem: IBM Device [1014:038c]
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> > Stepping- SERR- FastB2B- DisINTx+
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> > <MAbort- >SERR- <PERR- INTx-
> >         Latency: 0
> >         Interrupt: pin A routed to IRQ 494
> >         Region 0: Memory at 3fe080880000 (64-bit, non-prefetchable) [size=4K]
> >         Region 2: Memory at 3fe080000000 (64-bit, non-prefetchable) [size=8M]
> >         Region 4: Memory at 3fe080881000 (64-bit, non-prefetchable) [size=4K]
> >         [virtual] Expansion ROM at 3fe080800000 [disabled] [size=512K]
> >         Capabilities: [40] Power Management version 3
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
> >                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> >         Capabilities: [48] MSI: Enable- Count=1/32 Maskable- 64bit+
> >                 Address: 0000000000000000  Data: 0000
> >         Capabilities: [58] Express (v2) Endpoint, MSI 00
> >                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> >                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> >                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
> >                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> >                         MaxPayload 256 bytes, MaxReadReq 512 bytes
> >                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> >                 LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s L1, Exit Latency L0s
> > unlimited, L1 unlimited
> >                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
> >                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> >                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> >                 LnkSta: Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-
> > ABWMgmt-
> >                 DevCap2: Completion Timeout: Range ABC, TimeoutDis-, LTR-, OBFF Not Supported
> >                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> >                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> >                          Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> > ComplianceSOS-
> >                          Compliance De-emphasis: -6dB
> >                 LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> > EqualizationPhase1-
> >                          EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> >         Capabilities: [94] Vital Product Data
> >                 Product Name: 10 Gigabit Ethernet-SR PCI Express Adapter
> >                 Read-only fields:
> >                         [EC] Engineering changes: D76809
> >                         [FN] Unknown: 34 36 4b 37 38 39 37
> >                         [PN] Part number: 46K7897
> >                         [MN] Manufacture ID: 31 30 33 37
> >                         [FC] Unknown: 35 37 36 39
> >                         [SN] Serial number: YL102035603V
> >                         [NA] Unknown: 30 30 31 34 35 45 39 39 32 45 44 31
> >                 End
> >         Capabilities: [9c] MSI-X: Enable+ Count=32 Masked-
> >                 Vector table: BAR=4 offset=00000000
> >                 PBA: BAR=4 offset=00000800
> >         Capabilities: [100 v1] Device Serial Number 00-00-00-01-00-00-00-01
> >         Capabilities: [300 v1] Advanced Error Reporting
> >                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP-
> > ECRC- UnsupReq- ACSViol-
> >                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP-
> > ECRC- UnsupReq- ACSViol-
> >                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+
> > ECRC- UnsupReq- ACSViol-
> >                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> >                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> >                 AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> >         Kernel driver in use: cxgb3
> >         Kernel modules: cxgb3
> >
> >
