From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net-next 2/5] be2net: use common method to check for
 sriov function type
Date: Thu, 07 Apr 2011 14:37:39 +0100
Message-ID: <1302183459.2878.7.camel@bwh-desktop>
References: <20110407040801.GA4199@akhaparde-VBox>
	 ,<1302164041.5282.3.camel@localhost>
	 <49395329523DD64492581B505F80C86D5A5BCD3946@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit.Khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25046 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab1DGNhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 09:37:42 -0400
In-Reply-To: <49395329523DD64492581B505F80C86D5A5BCD3946@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-07 at 05:34 -0700, Ajit.Khaparde@Emulex.Com wrote:
> ________________________________________
> > From: Ben Hutchings [bhutchings@solarflare.com]
> > Sent: Thursday, April 07, 2011 3:14 AM
> > To: Khaparde, Ajit
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH net-next 2/5] be2net: use common method to check for sriov function type
> 
> > On Wed, 2011-04-06 at 23:08 -0500, Ajit Khaparde wrote:
> >> Lancer and BE can both use SLI_INTF_REG to check a VF or a PF.
> > [...]
> 
> > This seems pretty unreliable (both in the previous and the current
> > version).  You cannot rely on the whole of PCI config space being mapped
> > to a VM guest.  KVM certainly didn't do this when I used PCI pass-
> > through.
> 
> That's interesting. I have been using the new method for a while now.
> And the older one has worked pretty well for a long time.
> Can you give some details about the adapter used?
> Let's start with the firmware version, lspci output.

I've tried this with PFs on Solarflare adapters.

This is how the PF looks in the KVM host:

# lspci -vv -xxx -s 06:00.1
06:00.1 Ethernet controller: Solarflare Communications SFC9020 [Solarstorm]
	Subsystem: Solarflare Communications SFN5122F-R5
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 95
	Region 0: I/O ports at 2400 [size=256]
	Region 2: Memory at dd000000 (64-bit, non-prefetchable) [size=16M]
	Region 4: Memory at de010000 (64-bit, non-prefetchable) [size=64K]
	Expansion ROM at de420000 [size=128K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/5 Enable+
		Address: 00000000fee0f00c  Data: 41d6
	Capabilities: [70] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <8us
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
		Link: Supported Speed unknown, Width x8, ASPM L0s L1, Port 0
		Link: Latency L0s <512ns, L1 <64us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed unknown, Width x8
	Capabilities: [b0] MSI-X: Enable- Mask- TabSize=32
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00008000
	Capabilities: [d0] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Device Serial Number 88-3c-01-ff-ff-53-0f-00
	Capabilities: [150] Unknown (14)
	Capabilities: [160] Unknown (16)
00: 24 19 03 08 07 04 10 00 00 00 00 02 08 00 80 00
10: 01 24 00 00 00 00 00 00 04 00 00 dd 00 00 00 00
20: 04 00 01 de 00 00 00 00 00 00 00 00 24 19 05 62
30: 01 00 42 de 40 00 00 00 00 00 00 00 0b 02 00 00
40: 01 50 03 48 08 00 00 00 00 00 00 00 00 00 00 00
50: 05 70 8b 01 0c f0 e0 fe 00 00 00 00 d6 41 00 00
60: fe ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
70: 10 b0 02 00 01 86 00 10 30 20 00 00 82 3c 03 00
80: 40 00 82 10 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 1f 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 11 d0 1f 00 04 00 00 00 04 80 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

This is how it looks in the guest:

# lspci -vv -xxx -d 1924:
00:03.0 Ethernet controller: Solarflare Communications SFC9020 [Solarstorm]
	Subsystem: Solarflare Communications SFN5122F-R5
	Physical Slot: 3
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 11
	Region 0: I/O ports at c100 [size=256]
	Region 2: Memory at f3000000 (32-bit, non-prefetchable) [size=16M]
	Region 4: Memory at f4000000 (32-bit, non-prefetchable) [size=64K]
	Expansion ROM at f4020000 [disabled] [size=128K]
	Capabilities: [40] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [50] MSI-X: Enable- Count=32 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00008000
00: 24 19 03 08 03 04 10 00 00 00 00 02 08 00 80 00
10: 01 c1 00 00 00 00 00 00 00 00 00 f3 00 00 00 00
20: 00 00 00 f4 00 00 00 00 00 00 00 00 24 19 05 62
30: 00 00 02 f4 40 00 00 00 00 00 00 00 0b 02 00 00
40: 05 50 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 11 00 1f 00 04 00 00 00 04 80 00 00 28 41 00 00
60: fe ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
70: 10 b0 02 00 01 86 00 10 30 20 00 00 82 3c 03 00
80: 40 00 82 10 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 1f 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 11 d0 1f 00 04 00 00 00 04 80 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

The capability list is significantly changed.  The hex dump seems to
show that config space beyond about offset 0x60 is still passed through
unchanged, but I wouldn't want to rely on that remaining true.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

