From: Andre Tomt <andre@tomt.net>
Subject: 3.12-git Intel e1000e hardware unit hang / tx queue timeouts
Date: Sat, 12 Oct 2013 15:25:17 +0200
Message-ID: <52594DBD.3070108@tomt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010000000408050002030606"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.ugh.no ([178.79.162.34]:45460 "EHLO mail1.ugh.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716Ab3JLNed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Oct 2013 09:34:33 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail1.ugh.no (Postfix) with ESMTP id CC8E926BF7E
	for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 15:25:24 +0200 (CEST)
Received: from mail1.ugh.no ([127.0.0.1])
	by localhost (catastrophix.ugh.no [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id t9C85DgWXMin for <netdev@vger.kernel.org>;
	Sat, 12 Oct 2013 15:25:18 +0200 (CEST)
Received: from [IPv6:2a02:fe0:cf17:31:a236:9fff:fe07:d8ab] (unknown [IPv6:2a02:fe0:cf17:31:a236:9fff:fe07:d8ab])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: andre@tomt.net)
	by mail.ugh.no (Postfix) with ESMTPSA id 514D326C576
	for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 15:25:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010000000408050002030606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

After some interesting commits in 3.12 I figured I'd try to run this 
system with the normal packet coalescing offloads enabled. Normally I 
disable them to get smoother packet scheduling. But some hours after 
turning GSO/GRO/TSO it is getting a bunch of tx timeouts and hardware 
unit hangs.

The port hanging is a 82579LM running with hfsc + fq_codel for egress, 
and redirecting ingress to a similarly configured ifb device. No 
ethernet flow control. This port is internet-facing. em2 in the dumps.

The internal port are only using fq_codel as root qdisc, no hfsc 
involved. Also an e1000e, 82574L. This port uses VLAN's, with one rarely 
used VLAN device on a bridge for KVM. The majority of traffic moves over 
a "clean" VLAN device. No ethernet flow control. em1 in the dumps.

Turning the offloads back off seems to cure it.

Kernel is linus git as of friday 11. oct (yesterday). I'm not sure when 
this surfaced as I've not been running with the offloads for a good 
while. The ports are on-board, motherboard is an Intel DQ77KB mini-itx. 
BIOS identifies as KBQ7710H.86A.0052.2013.0708.1336 (the latest one with 
the biosdevname fixes). More info is attached.

I'm going to boot 3.10.16 on it now, and see how it fares.

--------------010000000408050002030606
Content-Type: text/plain; charset=UTF-8;
 name="qdisc.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="qdisc.txt"

qdisc hfsc 1: dev em2 root refcnt 2 default 1 
 Sent 4292403330 bytes 8681499 pkt (dropped 0, overlimits 9296343 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq_codel 11: dev em2 parent 1:1 limit 10240p flows 10240 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 4292607782 bytes 8682049 pkt (dropped 12463, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 19682 drop_overlimit 0 new_flow_count 3266450 ecn_mark 0
  new_flows_len 1 old_flows_len 10
qdisc ingress ffff: dev em2 parent ffff:fff1 ---------------- 
 Sent 12904537302 bytes 12242216 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq_codel 8001: dev em1 root refcnt 2 limit 10240p flows 10240 quantum 1514 target 5.0ms interval 100.0ms 
 Sent 13164970709 bytes 12307838 pkt (dropped 0, overlimits 0 requeues 133) 
 backlog 0b 0p requeues 133 
  maxpacket 68130 drop_overlimit 0 new_flow_count 63 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc hfsc 1: dev ifb0 root refcnt 2 default 1 
 Sent 13083770698 bytes 12240435 pkt (dropped 0, overlimits 9774130 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq_codel 11: dev ifb0 parent 1:1 limit 10240p flows 10240 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 13083770698 bytes 12240435 pkt (dropped 2, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 18168 drop_overlimit 0 new_flow_count 4661681 ecn_mark 0
  new_flows_len 1 old_flows_len 9
qdisc mq 0: dev wlan0 root 
 Sent 513132 bytes 3250 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc mq 0: dev mon.wlan0 root 
 Sent 669000 bytes 3617 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: dev vnet0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 855142 bytes 6368 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: dev nat64 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

--------------010000000408050002030606
Content-Type: text/plain; charset=UTF-8;
 name="lspci.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="lspci.txt"

00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family DRAM Controller (rev 09)
	Subsystem: Intel Corporation Device 2036
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
00: 86 80 00 01 06 00 90 20 09 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00

00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09) (prog-if 00 [VGA controller])
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 50
	Region 0: Memory at f7800000 (64-bit, non-prefetchable) [size=4M]
	Region 2: Memory at e0000000 (64-bit, prefetchable) [size=256M]
	Region 4: I/O ports at f000 [size=64]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4172
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a4] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: i915
00: 86 80 02 01 07 04 90 00 09 00 00 03 00 00 00 00
10: 04 00 80 f7 00 00 00 00 0c 00 00 e0 00 00 00 00
20: 01 f0 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 90 00 00 00 00 00 00 00 0b 01 00 00

00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller (rev 04) (prog-if 30 [XHCI])
	Subsystem: Intel Corporation Device 2036
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 47
	Region 0: Memory at f7f20000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] MSI: Enable+ Count=1/8 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4142
	Kernel driver in use: xhci_hcd
00: 86 80 31 1e 06 04 90 02 04 30 03 0c 00 00 00 00
10: 04 00 f2 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 70 00 00 00 00 00 00 00 0b 01 00 00

00:16.0 Communication controller: Intel Corporation 7 Series/C210 Series Chipset Family MEI Controller #1 (rev 04)
	Subsystem: Intel Corporation Device 2036
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 49
	Region 0: Memory at f7f38000 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4162
	Kernel driver in use: mei_me
00: 86 80 3a 1e 06 04 10 00 04 00 80 07 00 00 80 00
10: 04 80 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00

00:16.3 Serial controller: Intel Corporation 7 Series/C210 Series Chipset Family KT Controller (rev 04) (prog-if 02 [16550])
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 0: I/O ports at f0e0 [size=8]
	Region 1: Memory at f7f36000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: serial
00: 86 80 3d 1e 07 00 b0 00 04 02 00 07 00 00 00 00
10: e1 f0 00 00 00 60 f3 f7 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0a 02 00 00

00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (rev 04)
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 43
	Region 0: Memory at f7f00000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f7f35000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at f080 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4192
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e
00: 86 80 02 15 07 04 10 00 04 00 00 02 00 00 00 00
10: 00 00 f0 f7 00 50 f3 f7 81 f0 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 c8 00 00 00 00 00 00 00 05 01 00 00

00:1a.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB Enhanced Host Controller #2 (rev 04) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Device 2036
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f7f34000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci-pci
00: 86 80 2d 1e 06 00 90 02 04 20 03 0c 00 00 00 00
10: 00 40 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00

00:1c.0 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 1 (rev c4) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	Memory behind bridge: f7e00000-f7efffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4161
	Capabilities: [90] Subsystem: Intel Corporation Device 2036
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport
00: 86 80 10 1e 07 04 10 00 c4 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 f0 00 00 00
20: e0 f7 e0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 10 00

00:1c.2 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 3 (rev c4) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	Memory behind bridge: f7d00000-f7dfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #2, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4181
	Capabilities: [90] Subsystem: Intel Corporation Device 2036
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport
00: 86 80 14 1e 07 04 10 00 c4 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 02 02 00 f0 00 00 00
20: d0 f7 d0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 03 03 10 00

00:1c.6 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 7 (rev c4) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: f7c00000-f7cfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #7, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #6, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4191
	Capabilities: [90] Subsystem: Intel Corporation Device 2036
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport
00: 86 80 1c 1e 07 04 10 00 c4 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 03 03 00 e0 e0 00 00
20: c0 f7 c0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 03 03 10 00

00:1d.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB Enhanced Host Controller #1 (rev 04) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Device 2036
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f7f33000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci-pci
00: 86 80 26 1e 06 00 90 02 04 20 03 0c 00 00 00 00
10: 00 30 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a4) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Intel Corporation Device 2036
00: 86 80 4e 24 07 00 10 00 a4 01 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 04 04 20 f0 00 80 22
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 10 00

00:1f.0 ISA bridge: Intel Corporation Q77 Express Chipset LPC Controller (rev 04)
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
	Kernel driver in use: lpc_ich
00: 86 80 47 1e 07 00 10 02 04 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00

00:1f.2 SATA controller: Intel Corporation 7 Series/C210 Series Chipset Family 6-port SATA Controller [AHCI mode] (rev 04) (prog-if 01 [AHCI 1.0])
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 48
	Region 0: I/O ports at f0d0 [size=8]
	Region 1: I/O ports at f0c0 [size=4]
	Region 2: I/O ports at f0b0 [size=8]
	Region 3: I/O ports at f0a0 [size=4]
	Region 4: I/O ports at f060 [size=32]
	Region 5: Memory at f7f32000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4152
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ahci
00: 86 80 02 1e 07 04 b0 02 04 01 06 01 00 00 00 00
10: d1 f0 00 00 c1 f0 00 00 b1 f0 00 00 a1 f0 00 00
20: 61 f0 00 00 00 20 f3 f7 00 00 00 00 86 80 36 20
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 02 00 00

00:1f.3 SMBus: Intel Corporation 7 Series/C210 Series Chipset Family SMBus Controller (rev 04)
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin C routed to IRQ 3
	Region 0: Memory at f7f31000 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at f040 [size=32]
00: 86 80 22 1e 03 00 80 02 04 00 05 0c 00 00 00 00
10: 04 10 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 41 f0 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 00 00 00 00 00 00 00 00 03 03 00 00

01:00.0 Network controller: Qualcomm Atheros AR93xx Wireless Network Adapter (rev 01)
	Subsystem: Qualcomm Atheros Device 3114
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f7e00000 (64-bit, non-prefetchable) [size=128K]
	Expansion ROM at f7e20000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [70] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <2us, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [300 v1] Device Serial Number 00-00-00-00-00-00-00-00
	Kernel driver in use: ath9k
00: 8c 16 30 00 07 00 10 00 01 00 80 02 10 00 00 00
10: 04 00 e0 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 8c 16 14 31
30: 00 00 e2 f7 40 00 00 00 00 00 00 00 0b 01 00 00

02:00.0 Network controller: Qualcomm Atheros AR9285 Wireless Network Adapter (PCI-Express) (rev 01)
	Subsystem: AzureWave Device 1d89
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f7d00000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [60] Express (v2) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-15-17-ff-ff-24-14-12
	Capabilities: [170 v1] Power Budgeting <?>
	Kernel driver in use: ath9k
00: 8c 16 2b 00 07 00 10 00 01 00 80 02 10 00 00 00
10: 04 00 d0 f7 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3b 1a 89 1d
30: 00 00 00 00 40 00 00 00 00 00 00 00 03 01 00 00

03:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f7c00000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at e000 [size=32]
	Region 3: Memory at f7c20000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
		Vector table: BAR=3 offset=00000000
		PBA: BAR=3 offset=00002000
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP+ BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140 v1] Device Serial Number 4c-72-b9-ff-ff-21-13-5b
	Kernel driver in use: e1000e
00: 86 80 d3 10 07 04 10 00 00 00 00 02 10 00 00 00
10: 00 00 c0 f7 00 00 00 00 01 e0 00 00 00 00 c2 f7
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
30: 00 00 00 00 c8 00 00 00 00 00 00 00 03 01 00 00


--------------010000000408050002030606
Content-Type: text/plain; charset=UTF-8;
 name="dmesg.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="dmesg.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12.0-1-server (atomt@pelle) (gcc version 4=
=2E8.1 (Ubuntu/Linaro 4.8.1-10ubuntu7) ) #1 SMP Fri Oct 11 00:03:47 UTC 2=
013 (Ato 3.12.0-1-server 3.12-rc4)
[    0.000000] Command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12.0-1-server r=
oot=3DUUID=3D1a1a37d9-7b1b-4145-b8a1-1be1444d16ae ro security=3Dapparmor
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000020200000-0x000000003fffffff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x0000000040000000-0x00000000401fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000040200000-0x00000000dbb1bfff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x00000000dbb1c000-0x00000000dc22dfff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000dc22e000-0x00000000dc23dfff] ACP=
I data
[    0.000000] BIOS-e820: [mem 0x00000000dc23e000-0x00000000dc35dfff] ACP=
I NVS
[    0.000000] BIOS-e820: [mem 0x00000000dc35e000-0x00000000dc67efff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000dc67f000-0x00000000dc67ffff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x00000000dc680000-0x00000000dc6c2fff] ACP=
I NVS
[    0.000000] BIOS-e820: [mem 0x00000000dc6c3000-0x00000000dcffffff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x00000000dd800000-0x00000000df9fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000021e5fffff] usa=
ble
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI:                  /DQ77KB, BIOS KBQ7710H.86A.0052.2013=
=2E0708.1336 07/08/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> re=
served
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x21e600 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask E00000000 write-back
[    0.000000]   1 base 200000000 mask FE0000000 write-back
[    0.000000]   2 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   3 base 0DE000000 mask FFE000000 uncachable
[    0.000000]   4 base 0DD800000 mask FFF800000 uncachable
[    0.000000]   5 base 21F000000 mask FFF000000 uncachable
[    0.000000]   6 base 21E800000 mask FFF800000 uncachable
[    0.000000]   7 base 21E600000 mask FFFE00000 uncachable
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600=
070106
[    0.000000] e820: update [mem 0xdd800000-0xffffffff] usable =3D=3D> re=
served
[    0.000000] e820: last_pfn =3D 0xdd000 max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd7a0-0x000fd7af] mapped a=
t [ffff8800000fd7a0]
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24=
576
[    0.000000] reserving inaccessible SNB gfx pages
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x017ef000, 0x017effff] PGTABLE
[    0.000000] BRK [0x017f0000, 0x017f0fff] PGTABLE
[    0.000000] BRK [0x017f1000, 0x017f1fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x21e400000-0x21e5fffff]
[    0.000000]  [mem 0x21e400000-0x21e5fffff] page 2M
[    0.000000] BRK [0x017f2000, 0x017f2fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x21c000000-0x21e3fffff]
[    0.000000]  [mem 0x21c000000-0x21e3fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x200000000-0x21bffffff]
[    0.000000]  [mem 0x200000000-0x21bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1fffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x1fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x20200000-0x3fffffff]
[    0.000000]  [mem 0x20200000-0x3fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x40200000-0xdbb1bfff]
[    0.000000]  [mem 0x40200000-0xdb9fffff] page 2M
[    0.000000]  [mem 0xdba00000-0xdbb1bfff] page 4k
[    0.000000] BRK [0x017f3000, 0x017f3fff] PGTABLE
[    0.000000] BRK [0x017f4000, 0x017f4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xdc67f000-0xdc67ffff]
[    0.000000]  [mem 0xdc67f000-0xdc67ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0xdc6c3000-0xdcffffff]
[    0.000000]  [mem 0xdc6c3000-0xdc7fffff] page 4k
[    0.000000]  [mem 0xdc800000-0xdcffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1ffffffff]
[    0.000000]  [mem 0x100000000-0x1ffffffff] page 2M
[    0.000000] RAMDISK: [mem 0x36602000-0x372f8fff]
[    0.000000] ACPI: RSDP 00000000000f0490 00024 (v02  INTEL)
[    0.000000] ACPI: XSDT 00000000dc232078 00074 (v01 INTEL  DQ77KB   000=
00034 AMI  00010013)
[    0.000000] ACPI: FACP 00000000dc23c480 0010C (v05 INTEL  DQ77KB   000=
00034 AMI  00010013)
[    0.000000] ACPI: DSDT 00000000dc232180 0A2FE (v02 INTEL  DQ77KB   000=
00034 INTL 20051117)
[    0.000000] ACPI: FACS 00000000dc35c080 00040
[    0.000000] ACPI: APIC 00000000dc23c590 00072 (v03 INTEL  DQ77KB   000=
00034 AMI  00010013)
[    0.000000] ACPI: FPDT 00000000dc23c608 00044 (v01 INTEL  DQ77KB   000=
00034 AMI  00010013)
[    0.000000] ACPI: TCPA 00000000dc23c650 00032 (v02 INTEL  DQ77KB   000=
00034 MSFT 01000013)
[    0.000000] ACPI: MCFG 00000000dc23c688 0003C (v01 INTEL  DQ77KB   000=
00034 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000dc23c6c8 00038 (v01 INTEL  DQ77KB   000=
00034 AMI. 00000005)
[    0.000000] ACPI: SSDT 00000000dc23c700 0036D (v01 INTEL  DQ77KB   000=
00034 INTL 20091112)
[    0.000000] ACPI: SSDT 00000000dc23ca70 00860 (v01 INTEL  DQ77KB   000=
00034 INTL 20051117)
[    0.000000] ACPI: SSDT 00000000dc23d2d0 00B22 (v01 INTEL  DQ77KB   000=
00034 INTL 20051117)
[    0.000000] ACPI: ASF! 00000000dc23ddf8 000A5 (v32 INTEL  DQ77KB   000=
00034 TFSM 000F4240)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000021e5ffff=
f]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x21e5fffff]
[    0.000000]   NODE_DATA [mem 0x21e5f4000-0x21e5f8fff]
[    0.000000]  [ffffea0000000000-ffffea00087fffff] PMD -> [ffff880215c00=
000-ffff88021dbfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x21e5fffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009cfff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
[    0.000000]   node   0: [mem 0x20200000-0x3fffffff]
[    0.000000]   node   0: [mem 0x40200000-0xdbb1bfff]
[    0.000000]   node   0: [mem 0xdc67f000-0xdc67ffff]
[    0.000000]   node   0: [mem 0xdc6c3000-0xdcffffff]
[    0.000000]   node   0: [mem 0x100000000-0x21e5fffff]
[    0.000000] On node 0 totalpages: 2074102
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 156 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14018 pages used for memmap
[    0.000000]   DMA32 zone: 897114 pages, LIFO batch:31
[    0.000000]   Normal zone: 18328 pages used for memmap
[    0.000000]   Normal zone: 1172992 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI =
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level=
)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0xdfa00000-0xf7ffffff] available for PCI device=
s
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:4 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 26 pages/cpu @ffff88021e200000 s75200 r81=
92 d23104 u524288
[    0.000000] pcpu-alloc: s75200 r8192 d23104 u524288 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 2041536
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12.0-1-s=
erver root=3DUUID=3D1a1a37d9-7b1b-4145-b8a1-1be1444d16ae ro security=3Dap=
parmor
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 8076520K/8296408K available (3431K kernel code, 46=
6K rwdata, 1768K rodata, 788K init, 700K bss, 219888K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D4,=
 Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D32 to nr_cpu_ids=3D4.=

[    0.000000] NR_IRQS:4352 nr_irqs:712 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 33554432 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't w=
ant memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 2594.125 MHz processor
[    0.000002] Calibrating delay loop (skipped), value calculated using t=
imer frequency.. 5188.25 BogoMIPS (lpj=3D10376500)
[    0.000006] pid_max: default: 32768 minimum: 301
[    0.000025] Security Framework initialized
[    0.000036] AppArmor: AppArmor initialized
[    0.000038] Yama: becoming mindful.
[    0.000505] Dentry cache hash table entries: 1048576 (order: 11, 83886=
08 bytes)
[    0.002074] Inode-cache hash table entries: 524288 (order: 10, 4194304=
 bytes)
[    0.002733] Mount-cache hash table entries: 256
[    0.002894] Initializing cgroup subsys memory
[    0.002903] Initializing cgroup subsys devices
[    0.002906] Initializing cgroup subsys freezer
[    0.002908] Initializing cgroup subsys blkio
[    0.002927] CPU: Physical Processor ID: 0
[    0.002929] CPU: Processor Core ID: 0
[    0.002934] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.002934] ENERGY_PERF_BIAS: View and update with x86_energy_perf_pol=
icy(8)
[    0.002939] mce: CPU supports 7 MCE banks
[    0.002950] CPU0: Thermal monitoring enabled (TM1)
[    0.002958] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    0.002958] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    0.002958] tlb_flushall_shift: 5
[    0.003063] Freeing SMP alternatives memory: 16K (ffffffff8173b000 - f=
fffffff8173f000)
[    0.003067] ACPI: Core revision 20130725
[    0.008072] ACPI: All ACPI Tables successfully acquired
[    0.009762] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.049473] smpboot: CPU0: Intel(R) Core(TM) i3-2120T CPU @ 2.60GHz (f=
am: 06, model: 2a, stepping: 07)
[    0.049483] TSC deadline timer enabled
[    0.049490] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge e=
vents, full-width counters, Intel PMU driver.
[    0.049499] ... version:                3
[    0.049501] ... bit width:              48
[    0.049503] ... generic registers:      4
[    0.049505] ... value mask:             0000ffffffffffff
[    0.049507] ... max period:             0000ffffffffffff
[    0.049509] ... fixed-purpose events:   3
[    0.049511] ... event mask:             000000070000000f
[    0.049661] smpboot: Booting Node   0, Processors  #   1 #   2 #   3 O=
K
[    0.089253] Brought up 4 CPUs
[    0.089258] smpboot: Total of 4 processors activated (20753.00 BogoMIP=
S)
[    0.091870] devtmpfs: initialized
[    0.095400] PM: Registering ACPI NVS region [mem 0xdc23e000-0xdc35dfff=
] (1179648 bytes)
[    0.095428] PM: Registering ACPI NVS region [mem 0xdc680000-0xdc6c2fff=
] (274432 bytes)
[    0.095539] pinctrl core: initialized pinctrl subsystem
[    0.095587] NET: Registered protocol family 16
[    0.095857] cpuidle: using governor ladder
[    0.095860] cpuidle: using governor menu
[    0.095884] ACPI FADT declares the system doesn't support PCIe ASPM, s=
o disable it
[    0.095887] ACPI: bus type PCI registered
[    0.095890] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.095987] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf80000=
00-0xfbffffff] (base 0xf8000000)
[    0.095992] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E=
820
[    0.099245] PCI: Using configuration type 1 for base access
[    0.101912] bio: create slab <bio-0> at 0
[    0.102092] ACPI: Added _OSI(Module Device)
[    0.102095] ACPI: Added _OSI(Processor Device)
[    0.102097] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.102099] ACPI: Added _OSI(Processor Aggregator Device)
[    0.103359] ACPI: EC: Look up EC in DSDT
[    0.104691] ACPI: Executed 1 blocks of module-level executable AML cod=
e
[    0.117635] ACPI: SSDT 00000000dc1db018 0083B (v01  PmRef  Cpu0Cst 000=
03001 INTL 20051117)
[    0.117958] ACPI: Dynamic OEM Table Load:
[    0.117961] ACPI: SSDT           (null) 0083B (v01  PmRef  Cpu0Cst 000=
03001 INTL 20051117)
[    0.129500] ACPI: SSDT 00000000dc1dca98 00303 (v01  PmRef    ApIst 000=
03000 INTL 20051117)
[    0.129849] ACPI: Dynamic OEM Table Load:
[    0.129852] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst 000=
03000 INTL 20051117)
[    0.141380] ACPI: SSDT 00000000dc1ddc18 00119 (v01  PmRef    ApCst 000=
03000 INTL 20051117)
[    0.141691] ACPI: Dynamic OEM Table Load:
[    0.141694] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 000=
03000 INTL 20051117)
[    0.153839] ACPI: Interpreter enabled
[    0.153846] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S1_] (20130725/hwxface-571)
[    0.153853] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S2_] (20130725/hwxface-571)
[    0.153864] ACPI: (supports S0 S3 S5)
[    0.153867] ACPI: Using IOAPIC for interrupt routing
[    0.153917] PCI: Using host bridge windows from ACPI; if necessary, us=
e "pci=3Dnocrs" and report a bug
[    0.154084] ACPI: No dock devices found.
[    0.162862] ACPI: Power Resource [FN00] (off)
[    0.162978] ACPI: Power Resource [FN01] (off)
[    0.163091] ACPI: Power Resource [FN02] (off)
[    0.163203] ACPI: Power Resource [FN03] (off)
[    0.163317] ACPI: Power Resource [FN04] (off)
[    0.163979] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.164233] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    0.164662] acpi PNP0A08:00: ACPI _OSC control (0x1d) granted
[    0.165183] ACPI: \_SB_.PCI0.TPMX: can't evaluate _ADR (0x5)
[    0.165333] ACPI: \_SB_.PCI0.PDRC: can't evaluate _ADR (0x5)
[    0.165336] ACPI: \_SB_.PCI0.ITPM: can't evaluate _ADR (0x5)
[    0.165339] ACPI: \_SB_.PCI0.DOCK: can't evaluate _ADR (0x5)
[    0.165342] PCI host bridge to bus 0000:00
[    0.165345] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.165348] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.165352] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.165355] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bf=
fff]
[    0.165358] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7=
fff]
[    0.165361] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000db=
fff]
[    0.165364] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000df=
fff]
[    0.165367] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3=
fff]
[    0.165370] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7=
fff]
[    0.165373] pci_bus 0000:00: root bus resource [mem 0xdfa00000-0xfeaff=
fff]
[    0.165382] pci 0000:00:00.0: [8086:0100] type 00 class 0x060000
[    0.165491] pci 0000:00:02.0: [8086:0102] type 00 class 0x030000
[    0.165501] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7bfffff 64b=
it]
[    0.165507] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64b=
it pref]
[    0.165511] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
[    0.165633] pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
[    0.165656] pci 0000:00:14.0: reg 0x10: [mem 0xf7f20000-0xf7f2ffff 64b=
it]
[    0.165728] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    0.165779] pci 0000:00:14.0: System wakeup disabled by ACPI
[    0.165834] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
[    0.165858] pci 0000:00:16.0: reg 0x10: [mem 0xf7f38000-0xf7f3800f 64b=
it]
[    0.165934] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.166034] pci 0000:00:16.3: [8086:1e3d] type 00 class 0x070002
[    0.166053] pci 0000:00:16.3: reg 0x10: [io  0xf0e0-0xf0e7]
[    0.166063] pci 0000:00:16.3: reg 0x14: [mem 0xf7f36000-0xf7f36fff]
[    0.166230] pci 0000:00:19.0: [8086:1502] type 00 class 0x020000
[    0.166248] pci 0000:00:19.0: reg 0x10: [mem 0xf7f00000-0xf7f1ffff]
[    0.166257] pci 0000:00:19.0: reg 0x14: [mem 0xf7f35000-0xf7f35fff]
[    0.166266] pci 0000:00:19.0: reg 0x18: [io  0xf080-0xf09f]
[    0.166328] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    0.166379] pci 0000:00:19.0: System wakeup disabled by ACPI
[    0.166434] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
[    0.166455] pci 0000:00:1a.0: reg 0x10: [mem 0xf7f34000-0xf7f343ff]
[    0.166543] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.166608] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.166659] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
[    0.166738] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.166793] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.166847] pci 0000:00:1c.2: [8086:1e14] type 01 class 0x060400
[    0.166924] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.166978] pci 0000:00:1c.2: System wakeup disabled by ACPI
[    0.167036] pci 0000:00:1c.6: [8086:1e1c] type 01 class 0x060400
[    0.167165] pci 0000:00:1c.6: PME# supported from D0 D3hot D3cold
[    0.167228] pci 0000:00:1c.6: System wakeup disabled by ACPI
[    0.167285] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
[    0.167307] pci 0000:00:1d.0: reg 0x10: [mem 0xf7f33000-0xf7f333ff]
[    0.167396] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.167460] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.167513] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.167605] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.167655] pci 0000:00:1f.0: [8086:1e47] type 00 class 0x060100
[    0.167851] pci 0000:00:1f.2: [8086:1e02] type 00 class 0x010601
[    0.167870] pci 0000:00:1f.2: reg 0x10: [io  0xf0d0-0xf0d7]
[    0.167878] pci 0000:00:1f.2: reg 0x14: [io  0xf0c0-0xf0c3]
[    0.167886] pci 0000:00:1f.2: reg 0x18: [io  0xf0b0-0xf0b7]
[    0.167894] pci 0000:00:1f.2: reg 0x1c: [io  0xf0a0-0xf0a3]
[    0.167902] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
[    0.167911] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f32000-0xf7f327ff]
[    0.167956] pci 0000:00:1f.2: PME# supported from D3hot
[    0.168049] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
[    0.168065] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f31000-0xf7f310ff 64b=
it]
[    0.168086] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
[    0.168293] pci 0000:01:00.0: [168c:0030] type 00 class 0x028000
[    0.168321] pci 0000:01:00.0: reg 0x10: [mem 0xf7e00000-0xf7e1ffff 64b=
it]
[    0.168384] pci 0000:01:00.0: reg 0x30: [mem 0xf7e20000-0xf7e2ffff pre=
f]
[    0.168451] pci 0000:01:00.0: supports D1
[    0.168453] pci 0000:01:00.0: PME# supported from D0 D1 D3hot
[    0.168485] pci 0000:01:00.0: System wakeup disabled by ACPI
[    0.173353] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.173366] pci 0000:00:1c.0:   bridge window [mem 0xf7e00000-0xf7efff=
ff]
[    0.173503] pci 0000:02:00.0: [168c:002b] type 00 class 0x028000
[    0.173539] pci 0000:02:00.0: reg 0x10: [mem 0xf7d00000-0xf7d0ffff 64b=
it]
[    0.173707] pci 0000:02:00.0: supports D1
[    0.173708] pci 0000:02:00.0: PME# supported from D0 D1 D3hot D3cold
[    0.173752] pci 0000:02:00.0: System wakeup disabled by ACPI
[    0.181370] pci 0000:00:1c.2: PCI bridge to [bus 02]
[    0.181389] pci 0000:00:1c.2:   bridge window [mem 0xf7d00000-0xf7dfff=
ff]
[    0.181610] pci 0000:03:00.0: [8086:10d3] type 00 class 0x020000
[    0.181646] pci 0000:03:00.0: reg 0x10: [mem 0xf7c00000-0xf7c1ffff]
[    0.181695] pci 0000:03:00.0: reg 0x18: [io  0xe000-0xe01f]
[    0.181722] pci 0000:03:00.0: reg 0x1c: [mem 0xf7c20000-0xf7c23fff]
[    0.181935] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    0.181993] pci 0000:03:00.0: System wakeup disabled by ACPI
[    0.189443] pci 0000:00:1c.6: PCI bridge to [bus 03]
[    0.189449] pci 0000:00:1c.6:   bridge window [io  0xe000-0xefff]
[    0.189454] pci 0000:00:1c.6:   bridge window [mem 0xf7c00000-0xf7cfff=
ff]
[    0.189548] pci 0000:00:1e.0: PCI bridge to [bus 04] (subtractive deco=
de)
[    0.189559] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (sub=
tractive decode)
[    0.189561] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (sub=
tractive decode)
[    0.189563] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bff=
ff] (subtractive decode)
[    0.189565] pci 0000:00:1e.0:   bridge window [mem 0x000d4000-0x000d7f=
ff] (subtractive decode)
[    0.189567] pci 0000:00:1e.0:   bridge window [mem 0x000d8000-0x000dbf=
ff] (subtractive decode)
[    0.189569] pci 0000:00:1e.0:   bridge window [mem 0x000dc000-0x000dff=
ff] (subtractive decode)
[    0.189571] pci 0000:00:1e.0:   bridge window [mem 0x000e0000-0x000e3f=
ff] (subtractive decode)
[    0.189573] pci 0000:00:1e.0:   bridge window [mem 0x000e4000-0x000e7f=
ff] (subtractive decode)
[    0.189574] pci 0000:00:1e.0:   bridge window [mem 0xdfa00000-0xfeafff=
ff] (subtractive decode)
[    0.189610] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsu=
pported)
[    0.190143] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14=
 15)
[    0.190195] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 11 12 14 =
15) *0, disabled.
[    0.190247] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 6 10 11 12 14=
 15)
[    0.190297] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14=
 15)
[    0.190347] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 10 11 12 14=
 15)
[    0.190396] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 =
15) *0, disabled.
[    0.190446] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 11 12 14 =
15) *0, disabled.
[    0.190500] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 10 *11 12 14=
 15)
[    0.190732] ACPI: Enabled 7 GPEs in block 00 to 3F
[    0.190740] ACPI: \_SB_.PCI0: notify handler is installed
[    0.190789] Found 1 acpi root devices
[    0.190919] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,ow=
ns=3Dio+mem,locks=3Dnone
[    0.190925] vgaarb: loaded
[    0.190927] vgaarb: bridge control possible 0000:00:02.0
[    0.191036] SCSI subsystem initialized
[    0.191122] libata version 3.00 loaded.
[    0.191239] PCI: Using ACPI for IRQ routing
[    0.192689] PCI: pci_cache_line_size set to 64 bytes
[    0.192748] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    0.192750] e820: reserve RAM buffer [mem 0xdbb1c000-0xdbffffff]
[    0.192751] e820: reserve RAM buffer [mem 0xdc680000-0xdfffffff]
[    0.192753] e820: reserve RAM buffer [mem 0xdd000000-0xdfffffff]
[    0.192754] e820: reserve RAM buffer [mem 0x21e600000-0x21fffffff]
[    0.192929] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.192936] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.194966] Switched to clocksource hpet
[    0.195022] AppArmor: AppArmor Filesystem Enabled
[    0.195061] pnp: PnP ACPI init
[    0.195070] ACPI: bus type PNP registered
[    0.195111] pnp 00:00: [dma 4]
[    0.195147] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)=

[    0.195186] pnp 00:01: Plug and Play ACPI device, IDs INT0800 (active)=

[    0.195290] pnp 00:02: Plug and Play ACPI device, IDs PNP0103 (active)=

[    0.195351] system 00:03: [io  0x0680-0x069f] has been reserved
[    0.195355] system 00:03: [io  0x1000-0x100f] has been reserved
[    0.195358] system 00:03: [io  0xffff] has been reserved
[    0.195361] system 00:03: [io  0xffff] has been reserved
[    0.195364] system 00:03: [io  0x0400-0x0453] could not be reserved
[    0.195367] system 00:03: [io  0x0458-0x047f] has been reserved
[    0.195371] system 00:03: [io  0x0500-0x057f] has been reserved
[    0.195374] system 00:03: [io  0x164e-0x164f] has been reserved
[    0.195378] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (acti=
ve)
[    0.195422] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)=

[    0.195483] system 00:05: [io  0x0454-0x0457] has been reserved
[    0.195487] system 00:05: Plug and Play ACPI device, IDs INT3f0d PNP0c=
02 (active)
[    0.195601] system 00:06: [io  0x0a30-0x0a4f] has been reserved
[    0.195605] system 00:06: [io  0x0a00-0x0a0f] has been reserved
[    0.195608] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (acti=
ve)
[    0.195693] system 00:07: [io  0x04d0-0x04d1] has been reserved
[    0.195697] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (acti=
ve)
[    0.195739] pnp 00:08: Plug and Play ACPI device, IDs PNP0c04 (active)=

[    0.195923] pnp 00:09: [dma 0 disabled]
[    0.195990] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)=

[    0.196047] pnp 00:0a: Plug and Play ACPI device, IDs PNP0c31 (active)=

[    0.196282] system 00:0b: [mem 0xfed1c000-0xfed1ffff] has been reserve=
d
[    0.196286] system 00:0b: [mem 0xfed10000-0xfed17fff] has been reserve=
d
[    0.196289] system 00:0b: [mem 0xfed18000-0xfed18fff] has been reserve=
d
[    0.196293] system 00:0b: [mem 0xfed19000-0xfed19fff] has been reserve=
d
[    0.196296] system 00:0b: [mem 0xf8000000-0xfbffffff] has been reserve=
d
[    0.196299] system 00:0b: [mem 0xfed20000-0xfed3ffff] has been reserve=
d
[    0.196303] system 00:0b: [mem 0xfed90000-0xfed93fff] has been reserve=
d
[    0.196306] system 00:0b: [mem 0xfed45000-0xfed8ffff] has been reserve=
d
[    0.196309] system 00:0b: [mem 0xff000000-0xffffffff] has been reserve=
d
[    0.196313] system 00:0b: [mem 0xfee00000-0xfeefffff] could not be res=
erved
[    0.196316] system 00:0b: [mem 0xdfa00000-0xdfa00fff] has been reserve=
d
[    0.196319] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (acti=
ve)
[    0.196499] system 00:0c: [mem 0x20000000-0x201fffff] has been reserve=
d
[    0.196503] system 00:0c: [mem 0x40000000-0x401fffff] has been reserve=
d
[    0.196506] system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (acti=
ve)
[    0.196525] pnp: PnP ACPI: found 13 devices
[    0.196527] ACPI: bus type PNP unregistered
[    0.203598] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.203607] pci 0000:00:1c.0:   bridge window [mem 0xf7e00000-0xf7efff=
ff]
[    0.203617] pci 0000:00:1c.2: PCI bridge to [bus 02]
[    0.203623] pci 0000:00:1c.2:   bridge window [mem 0xf7d00000-0xf7dfff=
ff]
[    0.203633] pci 0000:00:1c.6: PCI bridge to [bus 03]
[    0.203637] pci 0000:00:1c.6:   bridge window [io  0xe000-0xefff]
[    0.203644] pci 0000:00:1c.6:   bridge window [mem 0xf7c00000-0xf7cfff=
ff]
[    0.203654] pci 0000:00:1e.0: PCI bridge to [bus 04]
[    0.203666] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.203667] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.203669] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.203671] pci_bus 0000:00: resource 7 [mem 0x000d4000-0x000d7fff]
[    0.203673] pci_bus 0000:00: resource 8 [mem 0x000d8000-0x000dbfff]
[    0.203674] pci_bus 0000:00: resource 9 [mem 0x000dc000-0x000dffff]
[    0.203676] pci_bus 0000:00: resource 10 [mem 0x000e0000-0x000e3fff]
[    0.203678] pci_bus 0000:00: resource 11 [mem 0x000e4000-0x000e7fff]
[    0.203680] pci_bus 0000:00: resource 12 [mem 0xdfa00000-0xfeafffff]
[    0.203681] pci_bus 0000:01: resource 1 [mem 0xf7e00000-0xf7efffff]
[    0.203683] pci_bus 0000:02: resource 1 [mem 0xf7d00000-0xf7dfffff]
[    0.203685] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.203687] pci_bus 0000:03: resource 1 [mem 0xf7c00000-0xf7cfffff]
[    0.203689] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
[    0.203690] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
[    0.203692] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
[    0.203694] pci_bus 0000:04: resource 7 [mem 0x000d4000-0x000d7fff]
[    0.203696] pci_bus 0000:04: resource 8 [mem 0x000d8000-0x000dbfff]
[    0.203697] pci_bus 0000:04: resource 9 [mem 0x000dc000-0x000dffff]
[    0.203699] pci_bus 0000:04: resource 10 [mem 0x000e0000-0x000e3fff]
[    0.203701] pci_bus 0000:04: resource 11 [mem 0x000e4000-0x000e7fff]
[    0.203702] pci_bus 0000:04: resource 12 [mem 0xdfa00000-0xfeafffff]
[    0.203730] NET: Registered protocol family 2
[    0.203904] TCP established hash table entries: 65536 (order: 8, 10485=
76 bytes)
[    0.204095] TCP bind hash table entries: 65536 (order: 8, 1048576 byte=
s)
[    0.204221] TCP: Hash tables configured (established 65536 bind 65536)=

[    0.204242] TCP: reno registered
[    0.204257] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.204289] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)=

[    0.204351] NET: Registered protocol family 1
[    0.204619] pci 0000:00:02.0: BIOS left Intel GPU interrupts enabled; =
disabling
[    0.204634] pci 0000:00:02.0: Boot video device
[    0.247116] PCI: CLS 64 bytes, default 64
[    0.247152] Unpacking initramfs...
[    0.449126] Freeing initrd memory: 13276K (ffff880036602000 - ffff8800=
372f9000)
[    0.449134] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.449138] software IO TLB [mem 0xd7b1c000-0xdbb1c000] (64MB) mapped =
at [ffff8800d7b1c000-ffff8800dbb1bfff]
[    0.450020] audit: initializing netlink socket (disabled)
[    0.450031] type=3D2000 audit(1381534568.448:1): initialized
[    0.452631] zbud: loaded
[    0.452796] VFS: Disk quotas dquot_6.5.2
[    0.452849] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.452898] msgmni has been set to 15800
[    0.453125] Block layer SCSI generic (bsg) driver version 0.4 loaded (=
major 252)
[    0.453129] io scheduler noop registered
[    0.453131] io scheduler deadline registered
[    0.453171] io scheduler cfq registered (default)
[    0.453387] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    0.453555] pcieport 0000:00:1c.2: irq 41 for MSI/MSI-X
[    0.453720] pcieport 0000:00:1c.6: irq 42 for MSI/MSI-X
[    0.453856] pcieport 0000:00:1c.0: Signaling PME through PCIe PME inte=
rrupt
[    0.453860] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt=

[    0.453865] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme load=
ed
[    0.453884] pcieport 0000:00:1c.2: Signaling PME through PCIe PME inte=
rrupt
[    0.453887] pci 0000:02:00.0: Signaling PME through PCIe PME interrupt=

[    0.453892] pcie_pme 0000:00:1c.2:pcie01: service driver pcie_pme load=
ed
[    0.453910] pcieport 0000:00:1c.6: Signaling PME through PCIe PME inte=
rrupt
[    0.453913] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt=

[    0.453918] pcie_pme 0000:00:1c.6:pcie01: service driver pcie_pme load=
ed
[    0.453966] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.454035] pciehp: PCI Express Hot Plug Controller Driver version: 0.=
4
[    0.454062] intel_idle: MWAIT substates: 0x1120
[    0.454064] intel_idle: v0.4 model 0x2A
[    0.454065] intel_idle: lapic_timer_reliable_states 0xffffffff
[    0.454261] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0=
C0C:00/input/input0
[    0.454268] ACPI: Power Button [PWRB]
[    0.454326] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input1
[    0.454330] ACPI: Power Button [PWRF]
[    0.454430] ACPI: Fan [FAN0] (off)
[    0.454479] ACPI: Fan [FAN1] (off)
[    0.454530] ACPI: Fan [FAN2] (off)
[    0.454578] ACPI: Fan [FAN3] (off)
[    0.454629] ACPI: Fan [FAN4] (off)
[    0.454698] ACPI: Requesting acpi_cpufreq
[    0.463549] thermal LNXTHERM:00: registered as thermal_zone0
[    0.463553] ACPI: Thermal Zone [TZ00] (28 C)
[    0.463839] thermal LNXTHERM:01: registered as thermal_zone1
[    0.463844] ACPI: Thermal Zone [TZ01] (30 C)
[    0.464395] GHES: HEST is not enabled!
[    0.464574] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.485083] 00:09: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200=
) is a 16550A
[    0.505971] 0000:00:16.3: ttyS1 at I/O 0xf0e0 (irq =3D 19, base_baud =3D=
 115200) is a 16550A
[    0.506378] Linux agpgart interface v0.103
[    0.506590] i8042: PNP: No PS/2 controller found. Probing ports direct=
ly.
[    1.451797] tsc: Refined TSC clocksource calibration: 2594.104 MHz
[    1.544707] i8042: No controller found
[    1.544796] rtc_cmos 00:04: RTC can wake from S4
[    1.545000] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    1.545030] rtc_cmos 00:04: alarms up to one month, y3k, 242 bytes nvr=
am, hpet irqs
[    1.545097] Intel P-state driver initializing.
[    1.545106] Intel pstate controlling: cpu 0
[    1.545120] Intel pstate controlling: cpu 1
[    1.545130] Intel pstate controlling: cpu 2
[    1.545140] Intel pstate controlling: cpu 3
[    1.545342] TCP: cubic registered
[    1.545660] NET: Registered protocol family 10
[    1.545845] NET: Registered protocol family 17
[    1.545853] Key type dns_resolver registered
[    1.546259] registered taskstats version 1
[    1.546390] AppArmor: AppArmor sha1 policy hashing enabled
[    1.546739] rtc_cmos 00:04: setting system clock to 2013-10-11 23:36:0=
9 UTC (1381534569)
[    1.547216] Freeing unused kernel memory: 788K (ffffffff81676000 - fff=
fffff8173b000)
[    1.547220] Write protecting the kernel read-only data: 6144k
[    1.548526] Freeing unused kernel memory: 656K (ffff88000135c000 - fff=
f880001400000)
[    1.549053] Freeing unused kernel memory: 280K (ffff8800015ba000 - fff=
f880001600000)
[    1.558558] systemd-udevd[647]: starting version 204
[    1.576454] pps_core: LinuxPPS API ver. 1 registered
[    1.576460] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolf=
o Giometti <giometti@linux.it>
[    1.576617] PTP clock support registered
[    1.577149] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    1.577153] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    1.577186] ACPI: bus type USB registered
[    1.577219] usbcore: registered new interface driver usbfs
[    1.577235] usbcore: registered new interface driver hub
[    1.577296] e1000e 0000:00:19.0: setting latency timer to 64
[    1.577344] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) =
set to dynamic conservative mode
[    1.577365] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    1.577411] usbcore: registered new device driver usb
[    1.777101] e1000e 0000:00:19.0 eth0: registered PHC clock
[    1.777111] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) 4=
c:72:b9:21:13:59
[    1.777116] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connec=
tion
[    1.777156] e1000e 0000:00:19.0 eth0: MAC: 10, PHY: 11, PBA No: FFFFFF=
-0FF
[    1.777338] xhci_hcd 0000:00:14.0: setting latency timer to 64
[    1.777345] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    1.777355] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bu=
s number 1
[    1.777501] e1000e 0000:03:00.0: Interrupt Throttling Rate (ints/sec) =
set to dynamic conservative mode
[    1.777537] xhci_hcd 0000:00:14.0: cache line size of 64 is not suppor=
ted
[    1.777538] e1000e 0000:03:00.0: irq 44 for MSI/MSI-X
[    1.777544] e1000e 0000:03:00.0: irq 45 for MSI/MSI-X
[    1.777550] e1000e 0000:03:00.0: irq 46 for MSI/MSI-X
[    1.777570] xhci_hcd 0000:00:14.0: irq 47 for MSI/MSI-X
[    1.777740] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    1.777745] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[    1.777750] usb usb1: Product: xHCI Host Controller
[    1.777754] usb usb1: Manufacturer: Linux 3.12.0-1-server xhci_hcd
[    1.777757] usb usb1: SerialNumber: 0000:00:14.0
[    1.778014] hub 1-0:1.0: USB hub found
[    1.778042] hub 1-0:1.0: 4 ports detected
[    1.778605] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    1.778615] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bu=
s number 2
[    1.778804] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0003
[    1.778811] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[    1.778816] usb usb2: Product: xHCI Host Controller
[    1.778820] usb usb2: Manufacturer: Linux 3.12.0-1-server xhci_hcd
[    1.778824] usb usb2: SerialNumber: 0000:00:14.0
[    1.779037] hub 2-0:1.0: USB hub found
[    1.779063] hub 2-0:1.0: 4 ports detected
[    1.788067] ahci 0000:00:1f.2: version 3.0
[    1.788233] ahci 0000:00:1f.2: irq 48 for MSI/MSI-X
[    1.788297] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps =
0x1 impl SATA mode
[    1.788305] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum pa=
rt ems apst=20
[    1.788313] ahci 0000:00:1f.2: setting latency timer to 64
[    1.788963] scsi0 : ahci
[    1.789098] scsi1 : ahci
[    1.789188] scsi2 : ahci
[    1.789260] scsi3 : ahci
[    1.789334] scsi4 : ahci
[    1.789403] scsi5 : ahci
[    1.789448] ata1: SATA max UDMA/133 abar m2048@0xf7f32000 port 0xf7f32=
100 irq 48
[    1.789452] ata2: DUMMY
[    1.789454] ata3: DUMMY
[    1.789456] ata4: DUMMY
[    1.789458] ata5: DUMMY
[    1.789460] ata6: DUMMY
[    1.883997] e1000e 0000:03:00.0 eth1: registered PHC clock
[    1.884005] e1000e 0000:03:00.0 eth1: (PCI Express:2.5GT/s:Width x1) 4=
c:72:b9:21:13:5b
[    1.884011] e1000e 0000:03:00.0 eth1: Intel(R) PRO/1000 Network Connec=
tion
[    1.884099] e1000e 0000:03:00.0 eth1: MAC: 3, PHY: 8, PBA No: FFFFFF-0=
FF
[    2.112274] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.112870] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succ=
eeded
[    2.112876] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LO=
CK) filtered out
[    2.112883] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATI=
ON OVERLAY) filtered out
[    2.113352] ata1.00: ATA-9: M4-CT064M4SSD2, 0309, max UDMA/100
[    2.113360] ata1.00: 125045424 sectors, multi 16: LBA48 NCQ (depth 31/=
32), AA
[    2.114022] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succ=
eeded
[    2.114028] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LO=
CK) filtered out
[    2.114035] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATI=
ON OVERLAY) filtered out
[    2.114506] ata1.00: configured for UDMA/100
[    2.114706] scsi 0:0:0:0: Direct-Access     ATA      M4-CT064M4SSD2   =
0309 PQ: 0 ANSI: 5
[    2.117729] sd 0:0:0:0: [sda] 125045424 512-byte logical blocks: (64.0=
 GB/59.6 GiB)
[    2.117911] sd 0:0:0:0: [sda] Write Protect is off
[    2.117919] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.117956] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enable=
d, doesn't support DPO or FUA
[    2.118803]  sda: sda1 sda2 < sda5 sda6 >
[    2.119272] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.141398] device-mapper: uevent: version 1.0.3
[    2.141503] device-mapper: ioctl: 4.26.0-ioctl (2013-08-15) initialise=
d: dm-devel@redhat.com
[    2.148740] EXT4-fs (sda5): INFO: recovery required on readonly filesy=
stem
[    2.148748] EXT4-fs (sda5): write access will be enabled during recove=
ry
[    2.172431] bio: create slab <bio-1> at 1
[    2.353175] EXT4-fs (sda5): recovery complete
[    2.355075] EXT4-fs (sda5): mounted filesystem with ordered data mode.=
 Opts: (null)
[    2.452528] Switched to clocksource tsc
[    2.500595] EXT4-fs (sda5): re-mounted. Opts: errors=3Dremount-ro
[    2.551118] systemd-udevd[885]: starting version 204
[    2.571622] w83627ehf: Found NCT6776F chip at 0xa00
[    2.586414] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver=

[    2.586841] ehci-pci: EHCI PCI platform driver
[    2.587026] ehci-pci 0000:00:1a.0: setting latency timer to 64
[    2.587038] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    2.587047] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bu=
s number 3
[    2.587062] ehci-pci 0000:00:1a.0: debug port 2
[    2.590976] ehci-pci 0000:00:1a.0: cache line size of 64 is not suppor=
ted
[    2.591001] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7f34000
[    2.592967] tpm_tis 00:0a: 1.2 TPM (device-id 0xFE, rev-id 71)
[    2.600564] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    2.600828] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    2.600832] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[    2.600835] usb usb3: Product: EHCI Host Controller
[    2.600837] usb usb3: Manufacturer: Linux 3.12.0-1-server ehci_hcd
[    2.600840] usb usb3: SerialNumber: 0000:00:1a.0
[    2.601064] hub 3-0:1.0: USB hub found
[    2.601076] hub 3-0:1.0: 3 ports detected
[    2.601406] ehci-pci 0000:00:1d.0: setting latency timer to 64
[    2.601416] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    2.601423] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bu=
s number 4
[    2.601439] ehci-pci 0000:00:1d.0: debug port 2
[    2.603364] [drm] Initialized drm 1.1.0 20060810
[    2.605343] ehci-pci 0000:00:1d.0: cache line size of 64 is not suppor=
ted
[    2.605372] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7f33000
[    2.616618] cfg80211: Calling CRDA to update world regulatory domain
[    2.616650] cfg80211: World regulatory domain updated:
[    2.616652] cfg80211:   (start_freq - end_freq @ bandwidth), (max_ante=
nna_gain, max_eirp)
[    2.616655] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.616658] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.616660] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (600 =
mBi, 2700 mBm)
[    2.616663] cfg80211:   (5170000 KHz - 5835000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.616676] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    2.616741] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    2.616744] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[    2.616747] usb usb4: Product: EHCI Host Controller
[    2.616750] usb usb4: Manufacturer: Linux 3.12.0-1-server ehci_hcd
[    2.616752] usb usb4: SerialNumber: 0000:00:1d.0
[    2.617228] hub 4-0:1.0: USB hub found
[    2.617238] hub 4-0:1.0: 3 ports detected
[    2.617732] mei_me 0000:00:16.0: setting latency timer to 64
[    2.617774] mei_me 0000:00:16.0: irq 49 for MSI/MSI-X
[    2.634916] ACPI Warning: 0x0000000000000428-0x000000000000042f System=
IO conflicts with Region \PMIO 1 (20130725/utaddress-251)
[    2.634925] ACPI: If an ACPI driver is available for this device, you =
should use it instead of the native driver
[    2.634929] ACPI Warning: 0x0000000000000530-0x000000000000053f System=
IO conflicts with Region \GPIO 1 (20130725/utaddress-251)
[    2.634934] ACPI Warning: 0x0000000000000530-0x000000000000053f System=
IO conflicts with Region \_GPE.GPIO 2 (20130725/utaddress-251)
[    2.634939] ACPI Warning: 0x0000000000000530-0x000000000000053f System=
IO conflicts with Region \_GPE.GPS0 3 (20130725/utaddress-251)
[    2.634943] ACPI: If an ACPI driver is available for this device, you =
should use it instead of the native driver
[    2.634945] ACPI Warning: 0x0000000000000500-0x000000000000052f System=
IO conflicts with Region \GPIO 1 (20130725/utaddress-251)
[    2.634949] ACPI Warning: 0x0000000000000500-0x000000000000052f System=
IO conflicts with Region \_GPE.GPIO 2 (20130725/utaddress-251)
[    2.634953] ACPI Warning: 0x0000000000000500-0x000000000000052f System=
IO conflicts with Region \_GPE.GPS0 3 (20130725/utaddress-251)
[    2.634958] ACPI: If an ACPI driver is available for this device, you =
should use it instead of the native driver
[    2.634960] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    2.641618] [drm] Memory usable by graphics device =3D 2048M
[    2.641627] i915 0000:00:02.0: setting latency timer to 64
[    2.661473] i915 0000:00:02.0: irq 50 for MSI/MSI-X
[    2.661484] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010)=
=2E
[    2.661486] [drm] Driver supports precise vblank timestamp query.
[    2.694287] tpm_tis 00:0a: TPM is disabled/deactivated (0x7)
[    2.700940] [drm] Wrong MCH_SSKPD value: 0x16040307
[    2.700944] [drm] This can cause pipe underruns and display issues.
[    2.700945] [drm] Please upgrade your BIOS to fix this.
[    2.738379] device-mapper: multipath: version 1.5.1 loaded
[    2.743314] ath: EEPROM regdomain: 0x0
[    2.743318] ath: EEPROM indicates default country code should be used
[    2.743320] ath: doing EEPROM country->regdmn map search
[    2.743322] ath: country maps to regdmn code: 0x3a
[    2.743323] ath: Country alpha2 being used: US
[    2.743325] ath: Regpair used: 0x3a
[    2.752803] 8021q: 802.1Q VLAN Support v1.8
[    2.759184] ieee80211 phy0: Selected rate control algorithm 'minstrel_=
ht'
[    2.759537] ieee80211 phy0: Atheros AR9300 Rev:3 mem=3D0xffffc90004f00=
000, irq=3D16
[    2.765858] EXT4-fs (dm-2): mounted filesystem with ordered data mode.=
 Opts: errors=3Dremount-ro
[    2.772904] [drm] GMBUS [i915 gmbus vga] timed out, falling back to bi=
t banging on pin 2
[    2.808167] ath: phy1: Enable LNA combining
[    2.809765] ath: EEPROM regdomain: 0x60
[    2.809767] ath: EEPROM indicates we should expect a direct regpair ma=
p
[    2.809771] ath: Country alpha2 being used: 00
[    2.809772] ath: Regpair used: 0x60
[    2.845266] IPv6: ADDRCONF(NETDEV_UP): em1: link is not ready
[    2.845271] 8021q: adding VLAN 0 to HW filter on device em1
[    2.847012] ieee80211 phy1: Selected rate control algorithm 'minstrel_=
ht'
[    2.847352] ieee80211 phy1: Atheros AR9285 Rev:2 mem=3D0xffffc90005020=
000, irq=3D18
[    2.849964] cfg80211: Calling CRDA for country: US
[    2.850175] cfg80211: Regulatory domain changed to country: US
[    2.850178] cfg80211:   (start_freq - end_freq @ bandwidth), (max_ante=
nna_gain, max_eirp)
[    2.850181] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.850184] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.850186] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.850188] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.850190] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (600 =
mBi, 2700 mBm)
[    2.850192] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 =
mBi, 3000 mBm)
[    2.850194] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (=
N/A, 4000 mBm)
[    2.858076] cfg80211: Calling CRDA for country: NO
[    2.858111] cfg80211: Regulatory domain changed to country: NO
[    2.858113] cfg80211:   (start_freq - end_freq @ bandwidth), (max_ante=
nna_gain, max_eirp)
[    2.858115] cfg80211:   (2402000 KHz - 2482000 KHz @ 40000 KHz), (N/A,=
 2700 mBm)
[    2.858117] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (N/A,=
 2700 mBm)
[    2.858120] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (N/A,=
 2700 mBm)
[    2.858122] cfg80211:   (5490000 KHz - 5710000 KHz @ 40000 KHz), (N/A,=
 2700 mBm)
[    2.858124] cfg80211:   (57240000 KHz - 65880000 KHz @ 2160000 KHz), (=
N/A, 4000 mBm)
[    2.869252] [drm] GMBUS [i915 gmbus dpd] timed out, falling back to bi=
t banging on pin 6
[    2.914512] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[    2.914517] i915 0000:00:02.0: registered panic notifier
[    2.914521] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecode=
s=3Dio+mem,decodes=3Dio:owns=3Dio
[    2.920775] type=3D1400 audit(1381534570.869:2): apparmor=3D"STATUS" o=
peration=3D"profile_load" name=3D"/sbin/dhclient" pid=3D1606 comm=3D"appa=
rmor_parser"
[    2.920784] type=3D1400 audit(1381534570.869:3): apparmor=3D"STATUS" o=
peration=3D"profile_load" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.=
action" pid=3D1606 comm=3D"apparmor_parser"
[    2.920789] type=3D1400 audit(1381534570.869:4): apparmor=3D"STATUS" o=
peration=3D"profile_load" name=3D"/usr/lib/connman/scripts/dhclient-scrip=
t" pid=3D1606 comm=3D"apparmor_parser"
[    2.920799] type=3D1400 audit(1381534570.869:5): apparmor=3D"STATUS" o=
peration=3D"profile_replace" name=3D"/sbin/dhclient" pid=3D1591 comm=3D"a=
pparmor_parser"
[    2.920807] type=3D1400 audit(1381534570.869:6): apparmor=3D"STATUS" o=
peration=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-clie=
nt.action" pid=3D1591 comm=3D"apparmor_parser"
[    2.920813] type=3D1400 audit(1381534570.869:7): apparmor=3D"STATUS" o=
peration=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-sc=
ript" pid=3D1591 comm=3D"apparmor_parser"
[    2.920843] usb 3-1: new high-speed USB device number 2 using ehci-pci=

[    2.921455] type=3D1400 audit(1381534570.869:8): apparmor=3D"STATUS" o=
peration=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-clie=
nt.action" pid=3D1591 comm=3D"apparmor_parser"
[    2.921464] type=3D1400 audit(1381534570.869:9): apparmor=3D"STATUS" o=
peration=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-sc=
ript" pid=3D1591 comm=3D"apparmor_parser"
[    2.921474] type=3D1400 audit(1381534570.869:10): apparmor=3D"STATUS" =
operation=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-cli=
ent.action" pid=3D1606 comm=3D"apparmor_parser"
[    2.932191] acpi device:4a: registered as cooling_device9
[    2.932380] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post:=
 no)
[    2.932428] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08=
:00/LNXVIDEO:00/input/input2
[    2.932509] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on =
minor 0
[    2.979045] Bridge firewalling registered
[    2.980340] device em1.15 entered promiscuous mode
[    2.981817] device em1 entered promiscuous mode
[    2.981916] IPv6: ADDRCONF(NETDEV_UP): em1.15: link is not ready
[    3.053232] usb 3-1: New USB device found, idVendor=3D8087, idProduct=3D=
0024
[    3.053234] usb 3-1: New USB device strings: Mfr=3D0, Product=3D0, Ser=
ialNumber=3D0
[    3.053757] hub 3-1:1.0: USB hub found
[    3.053910] hub 3-1:1.0: 6 ports detected
[    3.136963] Console: switching to colour frame buffer device 210x65
[    3.164993] usb 4-1: new high-speed USB device number 2 using ehci-pci=

[    3.297378] usb 4-1: New USB device found, idVendor=3D8087, idProduct=3D=
0024
[    3.297383] usb 4-1: New USB device strings: Mfr=3D0, Product=3D0, Ser=
ialNumber=3D0
[    3.298110] hub 4-1:1.0: USB hub found
[    3.298441] hub 4-1:1.0: 8 ports detected
[    3.329225] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    3.433143] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    3.433375] IPv6: ADDRCONF(NETDEV_UP): em2: link is not ready
[    3.434487] IPv6: ADDRCONF(NETDEV_UP): brdmz: link is not ready
[    3.443234] IPv6: ADDRCONF(NETDEV_UP): em1.30: link is not ready
[    3.566402] device wlan0 entered promiscuous mode
[    3.566528] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[    3.576451] u32 classifier
[    3.576455]     Performance counters on
[    3.576456]     input device check on
[    3.576458]     Actions configured
[    3.578975] Mirror/redirect action on
[    3.679617] brwlan: port 1(wlan0) entered forwarding state
[    3.679624] brwlan: port 1(wlan0) entered forwarding state
[    3.719395] init: failsafe main process (1916) killed by TERM signal
[    3.805691] [drm] Enabling RC6 states: RC6 on, RC6p on, RC6pp on
[    3.841657] iTCO_vendor_support: vendor-support=3D0
[    3.842235] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    3.842273] iTCO_wdt: Found a Panther Point TCO device (Version=3D2, T=
COBASE=3D0x0460)
[    3.842360] iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)
[    3.845499] brwlan: port 1(wlan0) entered disabled state
[    4.078657] ip_tables: (C) 2000-2006 Netfilter Core Team
[    4.088316] nf_conntrack version 0.5.0 (65536 buckets, 524288 max)
[    4.102418] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    4.102971] Ebtables v2.0 registered
[    4.743283] tun: Universal TUN/TAP device driver, 1.6
[    4.743287] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    4.814103] device vnet0 entered promiscuous mode
[    4.838120] brdmz: port 2(vnet0) entered forwarding state
[    4.838131] brdmz: port 2(vnet0) entered forwarding state
[    4.838146] IPv6: ADDRCONF(NETDEV_CHANGE): brdmz: link becomes ready
[    4.865361] cgroup: libvirtd (3577) created nested cgroup for controll=
er "memory" which has incomplete hierarchy support. Nested cgroups may ch=
ange behavior in the future.
[    4.865364] cgroup: "memory" requires setting use_hierarchy to 1 on th=
e root.
[    4.898434] qemu-system-x86: sending ioctl 5326 to a partition!
[    4.898444] qemu-system-x86: sending ioctl 80200204 to a partition!
[    5.363450] e1000e: em1 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[    5.363814] IPv6: ADDRCONF(NETDEV_CHANGE): em1: link becomes ready
[    5.363971] IPv6: ADDRCONF(NETDEV_CHANGE): em1.15: link becomes ready
[    5.364007] brdmz: port 1(em1.15) entered forwarding state
[    5.364010] brdmz: port 1(em1.15) entered forwarding state
[    5.364020] IPv6: ADDRCONF(NETDEV_CHANGE): em1.30: link becomes ready
[    5.633101] IPv6: ADDRCONF(NETDEV_UP): nat64: link is not ready
[    5.636471] IPv6: ADDRCONF(NETDEV_CHANGE): nat64: link becomes ready
[    6.868396] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[    6.868436] IPv6: ADDRCONF(NETDEV_CHANGE): em2: link becomes ready
[    7.039524] ath: phy0: TX while HW is in FULL_SLEEP mode
[    7.085715] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[    7.085758] brwlan: port 1(wlan0) entered forwarding state
[    7.085765] brwlan: port 1(wlan0) entered forwarding state
[   22.121228] brwlan: port 1(wlan0) entered forwarding state
[  332.013347] UDP: bad checksum. From 91.114.185.148:65535 to 84.209.201=
=2E2:51413 ulen 73
[12022.589733] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12022.589733]   TDH                  <56>
[12022.589733]   TDT                  <68>
[12022.589733]   next_to_use          <68>
[12022.589733]   next_to_clean        <54>
[12022.589733] buffer_info[next_to_clean]:
[12022.589733]   time_stamp           <1002cadf8>
[12022.589733]   next_to_watch        <56>
[12022.589733]   jiffies              <1002cb041>
[12022.589733]   next_to_watch.status <0>
[12022.589733] MAC Status             <80083>
[12022.589733] PHY Status             <796d>
[12022.589733] PHY 1000BASE-T Status  <7800>
[12022.589733] PHY Extended Status    <3000>
[12022.589733] PCI Status             <10>
[12024.591047] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12024.591047]   TDH                  <56>
[12024.591047]   TDT                  <68>
[12024.591047]   next_to_use          <68>
[12024.591047]   next_to_clean        <54>
[12024.591047] buffer_info[next_to_clean]:
[12024.591047]   time_stamp           <1002cadf8>
[12024.591047]   next_to_watch        <56>
[12024.591047]   jiffies              <1002cb235>
[12024.591047]   next_to_watch.status <0>
[12024.591047] MAC Status             <80083>
[12024.591047] PHY Status             <796d>
[12024.591047] PHY 1000BASE-T Status  <7800>
[12024.591047] PHY Extended Status    <3000>
[12024.591047] PCI Status             <10>
[12026.592345] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12026.592345]   TDH                  <56>
[12026.592345]   TDT                  <68>
[12026.592345]   next_to_use          <68>
[12026.592345]   next_to_clean        <54>
[12026.592345] buffer_info[next_to_clean]:
[12026.592345]   time_stamp           <1002cadf8>
[12026.592345]   next_to_watch        <56>
[12026.592345]   jiffies              <1002cb429>
[12026.592345]   next_to_watch.status <0>
[12026.592345] MAC Status             <80083>
[12026.592345] PHY Status             <796d>
[12026.592345] PHY 1000BASE-T Status  <7800>
[12026.592345] PHY Extended Status    <3000>
[12026.592345] PCI Status             <10>
[12028.593592] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12028.593592]   TDH                  <56>
[12028.593592]   TDT                  <68>
[12028.593592]   next_to_use          <68>
[12028.593592]   next_to_clean        <54>
[12028.593592] buffer_info[next_to_clean]:
[12028.593592]   time_stamp           <1002cadf8>
[12028.593592]   next_to_watch        <56>
[12028.593592]   jiffies              <1002cb61d>
[12028.593592]   next_to_watch.status <0>
[12028.593592] MAC Status             <80083>
[12028.593592] PHY Status             <796d>
[12028.593592] PHY 1000BASE-T Status  <7800>
[12028.593592] PHY Extended Status    <3000>
[12028.593592] PCI Status             <10>
[12029.597520] ------------[ cut here ]------------
[12029.597532] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 dev_=
watchdog+0x185/0x1eb()
[12029.597543] NETDEV WATCHDOG: em2 (e1000e): transmit queue 0 timed out
[12029.597545] Modules linked in: vhost_net vhost macvtap macvlan tun xt_=
pkttype xt_CT iptable_raw ipt_MASQUERADE xt_nat iptable_nat nf_nat_ipv4 n=
f_nat ip6t_frag ip6t_ah ip6t_REJECT ebtable_nat ip6table_filter ebtables =
ip6_tables xt_LOG xt_limit ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt=
_tcpudp xt_conntrack nf_conntrack xt_multiport iptable_filter ip_tables x=
_tables iTCO_wdt iTCO_vendor_support act_mirred cls_u32 sch_ingress sch_h=
fsc sch_fq_codel bridge fbcon bitblit softcursor font tileblit 8021q arc4=
 garp stp mrp llc dm_multipath scsi_dh ath9k ath9k_common ath9k_hw ath co=
retemp x86_pkg_temp_thermal crct10dif_pclmul crct10dif_common mac80211 cr=
c32_pclmul cfg80211 crc32c_intel i915 ghash_clmulni_intel rfkill cryptd f=
irmware_class intel_agp intel_gtt drm_kms_helper drm lpc_ich mfd_core i2c=
_algo_bit i2c_core tpm_tis tpm mei_me tpm_bios mei ehci_pci ehci_hcd vide=
o evdev kvm_intel kvm ifb dummy w83627ehf hwmon_vid hwmon ext4 crc16 jbd2=
 mbcache dm_mod sd_mod ahci libahci xhci_hcd e1000e ptp usbcore pps_core =
usb_common
[12029.597624] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.12.0-1-server =
#1
[12029.597627] Hardware name:                  /DQ77KB, BIOS KBQ7710H.86A=
=2E0052.2013.0708.1336 07/08/2013
[12029.597629]  000000000001131c ffff88021e203da8 ffffffff81351680 ffff88=
021e203df0
[12029.597632]  ffff88021e203de0 ffffffff8103608b ffffffff812b61ab ffff88=
0036d7c000
[12029.597635]  ffff8802102ce600 0000000000000001 0000000000000000 ffff88=
021e203e40
[12029.597638] Call Trace:
[12029.597640]  <IRQ>  [<ffffffff81351680>] dump_stack+0x45/0x56
[12029.597648]  [<ffffffff8103608b>] warn_slowpath_common+0x75/0x8e
[12029.597652]  [<ffffffff812b61ab>] ? dev_watchdog+0x185/0x1eb
[12029.597654]  [<ffffffff810360eb>] warn_slowpath_fmt+0x47/0x49
[12029.597660]  [<ffffffff812b61ab>] dev_watchdog+0x185/0x1eb
[12029.597663]  [<ffffffff812b6026>] ? dev_graft_qdisc+0x69/0x69
[12029.597666]  [<ffffffff812b6026>] ? dev_graft_qdisc+0x69/0x69
[12029.597670]  [<ffffffff8103edbf>] call_timer_fn.isra.26+0x23/0x7b
[12029.597673]  [<ffffffff8103efc2>] run_timer_softirq+0x1ab/0x1d3
[12029.597677]  [<ffffffff81039c0c>] __do_softirq+0xbf/0x173
[12029.597682]  [<ffffffff81357abc>] call_softirq+0x1c/0x30
[12029.597687]  [<ffffffff81003bb6>] do_softirq+0x2e/0x69
[12029.597690]  [<ffffffff81039d8a>] irq_exit+0x3e/0x4c
[12029.597695]  [<ffffffff81024cfc>] smp_apic_timer_interrupt+0x3f/0x4b
[12029.597699]  [<ffffffff8135744a>] apic_timer_interrupt+0x6a/0x70
[12029.597701]  <EOI>  [<ffffffff812750a9>] ? cpuidle_enter_state+0x4d/0x=
9e
[12029.597709]  [<ffffffff812750a2>] ? cpuidle_enter_state+0x46/0x9e
[12029.597713]  [<ffffffff812751cc>] cpuidle_idle_call+0xd2/0x121
[12029.597717]  [<ffffffff81009824>] arch_cpu_idle+0x9/0x18
[12029.597722]  [<ffffffff81068125>] cpu_startup_entry+0xff/0x14b
[12029.597726]  [<ffffffff8134714e>] rest_init+0x72/0x74
[12029.597729]  [<ffffffff81689d06>] start_kernel+0x3d7/0x3e2
[12029.597732]  [<ffffffff8168973d>] ? repair_env_string+0x58/0x58
[12029.597735]  [<ffffffff8168947f>] x86_64_start_reservations+0x2a/0x2c
[12029.597738]  [<ffffffff81689548>] x86_64_start_kernel+0xc7/0xca
[12029.597741] ---[ end trace 1d228e82b7bb4922 ]---
[12029.597753] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
[12033.505100] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[12503.901159] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12503.901159]   TDH                  <d5>
[12503.901159]   TDT                  <e5>
[12503.901159]   next_to_use          <e5>
[12503.901159]   next_to_clean        <d3>
[12503.901159] buffer_info[next_to_clean]:
[12503.901159]   time_stamp           <1002e8448>
[12503.901159]   next_to_watch        <d5>
[12503.901159]   jiffies              <1002e85fb>
[12503.901159]   next_to_watch.status <0>
[12503.901159] MAC Status             <80083>
[12503.901159] PHY Status             <796d>
[12503.901159] PHY 1000BASE-T Status  <7800>
[12503.901159] PHY Extended Status    <3000>
[12503.901159] PCI Status             <10>
[12505.902504] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12505.902504]   TDH                  <d5>
[12505.902504]   TDT                  <e5>
[12505.902504]   next_to_use          <e5>
[12505.902504]   next_to_clean        <d3>
[12505.902504] buffer_info[next_to_clean]:
[12505.902504]   time_stamp           <1002e8448>
[12505.902504]   next_to_watch        <d5>
[12505.902504]   jiffies              <1002e87ef>
[12505.902504]   next_to_watch.status <0>
[12505.902504] MAC Status             <80083>
[12505.902504] PHY Status             <796d>
[12505.902504] PHY 1000BASE-T Status  <7800>
[12505.902504] PHY Extended Status    <3000>
[12505.902504] PCI Status             <10>
[12507.903798] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[12507.903798]   TDH                  <d5>
[12507.903798]   TDT                  <e5>
[12507.903798]   next_to_use          <e5>
[12507.903798]   next_to_clean        <d3>
[12507.903798] buffer_info[next_to_clean]:
[12507.903798]   time_stamp           <1002e8448>
[12507.903798]   next_to_watch        <d5>
[12507.903798]   jiffies              <1002e89e3>
[12507.903798]   next_to_watch.status <0>
[12507.903798] MAC Status             <80083>
[12507.903798] PHY Status             <796d>
[12507.903798] PHY 1000BASE-T Status  <7800>
[12507.903798] PHY Extended Status    <3000>
[12507.903798] PCI Status             <10>
[12508.915490] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
[12513.003165] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[22203.172722] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[22203.172722]   TDH                  <ce>
[22203.172722]   TDT                  <dc>
[22203.172722]   next_to_use          <dc>
[22203.172722]   next_to_clean        <cc>
[22203.172722] buffer_info[next_to_clean]:
[22203.172722]   time_stamp           <100537e80>
[22203.172722]   next_to_watch        <ce>
[22203.172722]   jiffies              <100537fcd>
[22203.172722]   next_to_watch.status <0>
[22203.172722] MAC Status             <80083>
[22203.172722] PHY Status             <796d>
[22203.172722] PHY 1000BASE-T Status  <7800>
[22203.172722] PHY Extended Status    <3000>
[22203.172722] PCI Status             <10>
[22205.174019] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[22205.174019]   TDH                  <ce>
[22205.174019]   TDT                  <dc>
[22205.174019]   next_to_use          <dc>
[22205.174019]   next_to_clean        <cc>
[22205.174019] buffer_info[next_to_clean]:
[22205.174019]   time_stamp           <100537e80>
[22205.174019]   next_to_watch        <ce>
[22205.174019]   jiffies              <1005381c1>
[22205.174019]   next_to_watch.status <0>
[22205.174019] MAC Status             <80083>
[22205.174019] PHY Status             <796d>
[22205.174019] PHY 1000BASE-T Status  <7800>
[22205.174019] PHY Extended Status    <3000>
[22205.174019] PCI Status             <10>
[22207.175339] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[22207.175339]   TDH                  <ce>
[22207.175339]   TDT                  <dc>
[22207.175339]   next_to_use          <dc>
[22207.175339]   next_to_clean        <cc>
[22207.175339] buffer_info[next_to_clean]:
[22207.175339]   time_stamp           <100537e80>
[22207.175339]   next_to_watch        <ce>
[22207.175339]   jiffies              <1005383b5>
[22207.175339]   next_to_watch.status <0>
[22207.175339] MAC Status             <80083>
[22207.175339] PHY Status             <796d>
[22207.175339] PHY 1000BASE-T Status  <7800>
[22207.175339] PHY Extended Status    <3000>
[22207.175339] PCI Status             <10>
[22209.176619] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[22209.176619]   TDH                  <ce>
[22209.176619]   TDT                  <dc>
[22209.176619]   next_to_use          <dc>
[22209.176619]   next_to_clean        <cc>
[22209.176619] buffer_info[next_to_clean]:
[22209.176619]   time_stamp           <100537e80>
[22209.176619]   next_to_watch        <ce>
[22209.176619]   jiffies              <1005385a9>
[22209.176619]   next_to_watch.status <0>
[22209.176619] MAC Status             <80083>
[22209.176619] PHY Status             <796d>
[22209.176619] PHY 1000BASE-T Status  <7800>
[22209.176619] PHY Extended Status    <3000>
[22209.176619] PCI Status             <10>
[22209.193475] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
[22213.119529] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[25837.524050] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[25837.524050]   TDH                  <ca>
[25837.524050]   TDT                  <e0>
[25837.524050]   next_to_use          <e0>
[25837.524050]   next_to_clean        <ca>
[25837.524050] buffer_info[next_to_clean]:
[25837.524050]   time_stamp           <100615924>
[25837.524050]   next_to_watch        <cc>
[25837.524050]   jiffies              <100615aad>
[25837.524050]   next_to_watch.status <0>
[25837.524050] MAC Status             <80083>
[25837.524050] PHY Status             <796d>
[25837.524050] PHY 1000BASE-T Status  <7800>
[25837.524050] PHY Extended Status    <3000>
[25837.524050] PCI Status             <10>
[25839.525242] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[25839.525242]   TDH                  <ca>
[25839.525242]   TDT                  <e0>
[25839.525242]   next_to_use          <e0>
[25839.525242]   next_to_clean        <ca>
[25839.525242] buffer_info[next_to_clean]:
[25839.525242]   time_stamp           <100615924>
[25839.525242]   next_to_watch        <cc>
[25839.525242]   jiffies              <100615ca1>
[25839.525242]   next_to_watch.status <0>
[25839.525242] MAC Status             <80083>
[25839.525242] PHY Status             <796d>
[25839.525242] PHY 1000BASE-T Status  <7800>
[25839.525242] PHY Extended Status    <3000>
[25839.525242] PCI Status             <10>
[25841.526433] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[25841.526433]   TDH                  <ca>
[25841.526433]   TDT                  <e0>
[25841.526433]   next_to_use          <e0>
[25841.526433]   next_to_clean        <ca>
[25841.526433] buffer_info[next_to_clean]:
[25841.526433]   time_stamp           <100615924>
[25841.526433]   next_to_watch        <cc>
[25841.526433]   jiffies              <100615e95>
[25841.526433]   next_to_watch.status <0>
[25841.526433] MAC Status             <80083>
[25841.526433] PHY Status             <796d>
[25841.526433] PHY 1000BASE-T Status  <7800>
[25841.526433] PHY Extended Status    <3000>
[25841.526433] PCI Status             <10>
[25843.527886] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[25843.527886]   TDH                  <ca>
[25843.527886]   TDT                  <e0>
[25843.527886]   next_to_use          <e0>
[25843.527886]   next_to_clean        <ca>
[25843.527886] buffer_info[next_to_clean]:
[25843.527886]   time_stamp           <100615924>
[25843.527886]   next_to_watch        <cc>
[25843.527886]   jiffies              <100616089>
[25843.527886]   next_to_watch.status <0>
[25843.527886] MAC Status             <80083>
[25843.527886] PHY Status             <796d>
[25843.527886] PHY 1000BASE-T Status  <7800>
[25843.527886] PHY Extended Status    <3000>
[25843.527886] PCI Status             <10>
[25845.529085] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[25845.529085]   TDH                  <ca>
[25845.529085]   TDT                  <e0>
[25845.529085]   next_to_use          <e0>
[25845.529085]   next_to_clean        <ca>
[25845.529085] buffer_info[next_to_clean]:
[25845.529085]   time_stamp           <100615924>
[25845.529085]   next_to_watch        <cc>
[25845.529085]   jiffies              <10061627d>
[25845.529085]   next_to_watch.status <0>
[25845.529085] MAC Status             <80083>
[25845.529085] PHY Status             <796d>
[25845.529085] PHY 1000BASE-T Status  <7800>
[25845.529085] PHY Extended Status    <3000>
[25845.529085] PCI Status             <10>
[25845.545921] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
[25849.415861] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[28287.108441] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[28287.108441]   TDH                  <a>
[28287.108441]   TDT                  <f>
[28287.108441]   next_to_use          <f>
[28287.108441]   next_to_clean        <8>
[28287.108441] buffer_info[next_to_clean]:
[28287.108441]   time_stamp           <1006aae9a>
[28287.108441]   next_to_watch        <a>
[28287.108441]   jiffies              <1006ab14d>
[28287.108441]   next_to_watch.status <0>
[28287.108441] MAC Status             <80083>
[28287.108441] PHY Status             <796d>
[28287.108441] PHY 1000BASE-T Status  <7800>
[28287.108441] PHY Extended Status    <3000>
[28287.108441] PCI Status             <10>
[28289.109747] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[28289.109747]   TDH                  <a>
[28289.109747]   TDT                  <f>
[28289.109747]   next_to_use          <f>
[28289.109747]   next_to_clean        <8>
[28289.109747] buffer_info[next_to_clean]:
[28289.109747]   time_stamp           <1006aae9a>
[28289.109747]   next_to_watch        <a>
[28289.109747]   jiffies              <1006ab341>
[28289.109747]   next_to_watch.status <0>
[28289.109747] MAC Status             <80083>
[28289.109747] PHY Status             <796d>
[28289.109747] PHY 1000BASE-T Status  <7800>
[28289.109747] PHY Extended Status    <3000>
[28289.109747] PCI Status             <10>
[28291.110944] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
[28291.110944]   TDH                  <a>
[28291.110944]   TDT                  <f>
[28291.110944]   next_to_use          <f>
[28291.110944]   next_to_clean        <8>
[28291.110944] buffer_info[next_to_clean]:
[28291.110944]   time_stamp           <1006aae9a>
[28291.110944]   next_to_watch        <a>
[28291.110944]   jiffies              <1006ab535>
[28291.110944]   next_to_watch.status <0>
[28291.110944] MAC Status             <80083>
[28291.110944] PHY Status             <796d>
[28291.110944] PHY 1000BASE-T Status  <7800>
[28291.110944] PHY Extended Status    <3000>
[28291.110944] PCI Status             <10>
[28291.127696] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
[28295.033841] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: None
[32613.337520] UDP: bad checksum. From 212.83.153.119:64436 to 84.209.201=
=2E2:51413 ulen 73

--------------010000000408050002030606--
