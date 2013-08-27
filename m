From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: pcie_get_minimum_link returns 0 width
Date: Tue, 27 Aug 2013 07:57:20 -0600
Message-ID: <CAErSpo6pCzw6Gjn+SCFhu7PnBpHkUz0oqO+tGmmOH8NxoMiH6g@mail.gmail.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD13D0C@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo68LaevaBG8rJD0aj+oy-cp_f2ZsQVEhXL=oUyyRiYwZw@mail.gmail.com> <979A8436335E3744ADCD3A9F2A2B68A52AD13FB9@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jiang Liu <jiang.liu@huawei.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64992 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab3H0N5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 09:57:40 -0400
Received: by mail-ie0-f179.google.com with SMTP id m16so4342428ieq.24
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 06:57:40 -0700 (PDT)
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AD13FB9@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Jiang]

On Tue, Aug 27, 2013 at 1:40 AM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
>> On Mon, Aug 26, 2013 at 5:36 PM, Yuval Mintz <yuvalmin@broadcom.com>
>> wrote:
>> >> > Hi,
>> >> >
>> >> > I tried adding support for the newly added 'pcie_get_minimum_link' into
>> >> the
>> >> > bnx2x driver, but found out the some of my devices started showing
>> width
>> >> x0.
>> >> >
>> >> > By adding debug prints, I've found out there were devices up the chain
>> that
>> >> > Showed 0 when their PCI_EXP_LNKSTA was read by said function.
>> >> > However, when I tried looking via lspci the output claimed the width was
>> >> x4.
>> Looking at its implementation, one obvious difference is that
>> pcie_get_minimum_link() traverses up the hierarchy and keeps track of
>> the minimum values it finds.  lspci, on the other hand, just reads
>> PCI_EXP_LNKSTA from a single device and decodes it.
>>
>> You said lspci reports x4 for every device from the Root Port all the
>> way down to your NIC, so I would think the minimum from
>> pcie_get_minimum_link() would be x4.  But apparently it's not.  Maybe
>> there's a bug in it.  Can you post the complete "lspci -vv" output
>> along with your debug patch and output?
>>
>> Bjorn
>
> Here's the patch:
> ---
>  drivers/pci/pci.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index c71e78c..72cb87b 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -3601,13 +3601,19 @@ int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
>                 enum pcie_link_width next_width;
>
>                 ret = pcie_capability_read_word(dev, PCI_EXP_LNKSTA, &lnksta);
> -               if (ret)
> +               if (ret) {
> +                       printk(KERN_ERR "Failed to Read LNKSTA\n");
>                         return ret;
> +               }
>
>                 next_speed = pcie_link_speed[lnksta & PCI_EXP_LNKSTA_CLS];
>                 next_width = (lnksta & PCI_EXP_LNKSTA_NLW) >>
>                         PCI_EXP_LNKSTA_NLW_SHIFT;
>
> +               printk(KERN_ERR "LnkSta %04x [%04x:%02x.%02x]\n",
> +                      lnksta, dev->bus->number, PCI_SLOT(dev->devfn),
> +                      PCI_FUNC(dev->devfn));

I think pcie_cap_has_lnkctl() is incorrect: it currently thinks only
Root Ports, Endpoints, and Legacy Endpoints have link registers.  But
I think switch ports (Upstream Ports and Downstream Ports) also have
link registers (PCIe spec r3.0, sec 7.8).  Jiang?

>                 if (next_speed < *speed)
>                         *speed = next_speed;
>
> --
> 1.7.1
>
> And here are the lscpi results for 09:00.0 and 0a:01.0
> (The two devices for which the loop returns 0 width):
>
> Sysfs do read [Pos 0, len 64]
> 09:00.0 Class 0604: Device 8086:3500 (rev 01)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=09, secondary=0a, subordinate=11, sec-latency=0
>         Memory behind bridge: fb800000-fd7fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: Sysfs do read [Pos 68, len 4]
> [44] Express (v1) Upstream Port, MSI 00
> Sysfs do read [Pos 72, len 16]
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-SlotPowerLimit 0.000W
>                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 256 bytes, MaxReadReq 4096 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>         Capabilities: Sysfs do read [Pos 112, len 4]
> [70] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Sysfs do read [Pos 116, len 4]
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: Sysfs do read [Pos 128, len 4]
> [80] Sysfs do read [Pos 132, len 4]
> Subsystem: Device 0000:0000
> Sysfs do read [Pos 256, len 4]
>         Capabilities: [100 v1] Advanced Error Reporting
> Sysfs do read [Pos 260, len 24]
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                 UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>                 CEMsk:  RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr-
>                 AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
>
> Sysfs do read [Pos 0, len 64]
> 0a:01.0 Class 0604: Device 8086:3514 (rev 01)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=0a, secondary=0e, subordinate=10, sec-latency=0
>         Memory behind bridge: fb800000-fd7fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: Sysfs do read [Pos 68, len 4]
> [44] Express (v1) Downstream Port (Slot-), MSI 00
> Sysfs do read [Pos 72, len 16]
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- RBE- FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 256 bytes, MaxReadReq 4096 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
>                 LnkCap: Port #2, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>         Capabilities: Sysfs do read [Pos 96, len 4]
> [60] MSI: Enable- Count=1/1 Maskable- 64bit+
> Sysfs do read [Pos 100, len 10]
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: Sysfs do read [Pos 112, len 4]
> [70] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Sysfs do read [Pos 116, len 4]
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: Sysfs do read [Pos 128, len 4]
> [80] Sysfs do read [Pos 132, len 4]
> Subsystem: Device 0000:0000
> Sysfs do read [Pos 256, len 4]
>         Capabilities: [100 v1] Advanced Error Reporting
> Sysfs do read [Pos 260, len 24]
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                 UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>                 CEMsk:  RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr-
>                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
>
> Thanks,
> Yuval
>
