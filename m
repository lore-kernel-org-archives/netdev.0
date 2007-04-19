From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: sky2 X86-64 PCI synchronization problems
Date: Thu, 19 Apr 2007 13:12:49 -0700
Message-ID: <20070419131249.3482e6df@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>, Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:57633 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767018AbXDSUNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am testing a Gigabyte 965P-S3 motherboard with onboard Marvell
88E8056 Ethernet controller (sky2 driver). The CPU is a Core-2 Duo.
Strange errors occur under moderate load with X86-64 kernel.
Surprisingly, with i386 kernel the controller runs fine without errors.

These look bus/PCI related because:
* there is also 88E8052 on an PCI-E X1 card, it has no problem.
  Similar chip but different bus interface internally (no ram buffer).

* the errors look like the controller didn't access memory correctly:
	1. receive status arrives but data buffer not updated
	2. transmit descriptor errors, implying that controller read
           a non-initialized memory.
  the command blocks look okay, it's like the device didn't read them.

It looks like a PCI bus synchronization issue. Any ideas for driver
workarounds?

This is the working controller:

03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8052 PCI-E ASF Gigabit Ethernet Controller (rev 22)
	Subsystem: Marvell Technology Group Ltd. Marvell RDK-8052
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 217
	Region 0: Memory at f8000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 7000 [size=256]
	[virtual] Expansion ROM at 80000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0300c  Data: 417a
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 60 43 07 04 10 00 22 00 00 02 08 00 00 00
10: 04 00 00 f8 00 00 00 00 01 70 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ab 11 21 52
30: 00 00 00 00 48 00 00 00 00 00 00 00 0b 01 00 00


This is the non-working controller:

05:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 12)
	Subsystem: Giga-byte Technology Unknown device e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 216
	Region 0: Memory at fa000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at a000 [size=256]
	[virtual] Expansion ROM at 80100000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 4182
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 04 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 fa 00 00 00 00 01 a0 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0e 01 00 00

