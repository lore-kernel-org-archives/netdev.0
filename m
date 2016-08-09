From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Tue, 9 Aug 2016 11:12:09 -0700
Message-ID: <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
 <1452684335-46107-4-git-send-email-hare@suse.de> <20160209210458.GB32530@localhost>
 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Helgaas <helgaas@kernel.org>, Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36017 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193AbcHISMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:12:10 -0400
In-Reply-To: <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 5:54 AM, Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
> On 10/02/16 08:04, Bjorn Helgaas wrote:
>> On Wed, Jan 13, 2016 at 12:25:34PM +0100, Hannes Reinecke wrote:
>>> PCI-2.2 VPD entries have a maximum size of 32k, but might actually
>>> be smaller than that. To figure out the actual size one has to read
>>> the VPD area until the 'end marker' is reached.
>>> Trying to read VPD data beyond that marker results in 'interesting'
>>> effects, from simple read errors to crashing the card. And to make
>>> matters worse not every PCI card implements this properly, leaving
>>> us with no 'end' marker or even completely invalid data.
>>> This path tries to determine the size of the VPD data.
>>> If no valid data can be read an I/O error will be returned when
>>> reading the sysfs attribute.
>
>
> I have a problem with this particular feature as today VFIO uses this
> pci_vpd_xxxx API to virtualize access to VPD and the existing code assumes
> there is just one VPD block with 0x2 start and 0xf end. However I have at
> least one device where this is not true - "10 Gigabit Ethernet-SR PCI
> Express Adapter" - it has 2 blocks (made a script to read/parse it as
> /sys/bus/pci/devices/0001\:03\:00.0/vpd shows it wrong):

The PCI spec is what essentially assumes that there is only one block.
If I am not mistaken in the case of this device the second block here
actually contains device configuration data, not actual VPD data.  The
issue here is that the second block is being accessed as VPD when it
isn't.

> #0000 Large item 42 bytes; name 0x2 Identifier String
> #002d Large item 74 bytes; name 0x10
> #007a Small item 1 bytes; name 0xf End Tag
> ---
> #0c00 Large item 16 bytes; name 0x2 Identifier String
> #0c13 Large item 234 bytes; name 0x10
> #0d00 Large item 252 bytes; name 0x11
> #0dff Small item 0 bytes; name 0xf End Tag

The second block here is driver proprietary setup bits.

> The cxgb3 driver is reading the second bit starting from 0xc00 but since
> the size is wrongly detected as 0x7c, VFIO blocks access beyond it and the
> guest driver fails to probe.
>
> I also cannot find a clause in the PCI 3.0 spec saying that there must be
> just a single block, is it there?

The problem is we need to be able to parse it.  The spec defines a
series of tags that can be used starting at offset 0.  That is how we
are supposed to get around through the VPD data.  The problem is we
can't have more than one end tag and what appears to be happening here
is that we are defining a second block of data which uses the same
formatting as VPD but is not VPD.

> What would the correct fix be? Scanning all 32k of VPD is not an option I
> suppose as this is what this patch is trying to avoid. Thanks.

I adding the current cxgb3 maintainer and netdev list to the Cc.  This
is something that can probably be addressed via a PCI quirk as what
needs to happen is that we need to extend the VPD in the case of this
part in order to include this second block.  As long as we can read
the VPD data all the way out to 0xdff odds are we could probably just
have the size arbitrarily increased to 0xe00 via the quirk and then
you would be able to access all of the VPD for the device.  We already
have code making other modifications to drivers/pci/quirks.c for
several Broadcom devices and probably just need something similar to
allow extended access in the case of these devices.

>
>
>
> This is the device:
>
> [aik@p81-p9 ~]$ sudo lspci -vvnns 0001:03:00.0
> 0001:03:00.0 Ethernet controller [0200]: Chelsio Communications Inc T310
> 10GbE Single Port Adapter [1425:0030]
>         Subsystem: IBM Device [1014:038c]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 494
>         Region 0: Memory at 3fe080880000 (64-bit, non-prefetchable) [size=4K]
>         Region 2: Memory at 3fe080000000 (64-bit, non-prefetchable) [size=8M]
>         Region 4: Memory at 3fe080881000 (64-bit, non-prefetchable) [size=4K]
>         [virtual] Expansion ROM at 3fe080800000 [disabled] [size=512K]
>         Capabilities: [40] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [48] MSI: Enable- Count=1/32 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [58] Express (v2) Endpoint, MSI 00
>                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 256 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s L1, Exit Latency L0s
> unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-
> ABWMgmt-
>                 DevCap2: Completion Timeout: Range ABC, TimeoutDis-, LTR-, OBFF Not Supported
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
>                          Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
>                          EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
>         Capabilities: [94] Vital Product Data
>                 Product Name: 10 Gigabit Ethernet-SR PCI Express Adapter
>                 Read-only fields:
>                         [EC] Engineering changes: D76809
>                         [FN] Unknown: 34 36 4b 37 38 39 37
>                         [PN] Part number: 46K7897
>                         [MN] Manufacture ID: 31 30 33 37
>                         [FC] Unknown: 35 37 36 39
>                         [SN] Serial number: YL102035603V
>                         [NA] Unknown: 30 30 31 34 35 45 39 39 32 45 44 31
>                 End
>         Capabilities: [9c] MSI-X: Enable+ Count=32 Masked-
>                 Vector table: BAR=4 offset=00000000
>                 PBA: BAR=4 offset=00000800
>         Capabilities: [100 v1] Device Serial Number 00-00-00-01-00-00-00-01
>         Capabilities: [300 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP-
> ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP-
> ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+
> ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>                 AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
>         Kernel driver in use: cxgb3
>         Kernel modules: cxgb3
>
>
