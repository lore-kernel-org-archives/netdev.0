From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Thu, 19 Mar 2009 09:58:42 -0700
Message-ID: <20090319165842.GA10819@xw6200.broadcom.net>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
 <20090315143214.90c71fb7.akpm@linux-foundation.org>
 <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4444 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758162AbZCSQ6z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 12:58:55 -0400
In-Reply-To: <49C01F7F.9030306@birkenwald.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bernhard.  I talked to Michael about this and we'd like you to try
two things.

1) Can you disable iLo2 and see if you can still reproduce the problem?
2) Can you apply the following patch to get more information on when
   MMIO gets disabled?


diff -Nrup 1/drivers/net/tg3.c 2/drivers/net/tg3.c
--- 1/drivers/net/tg3.c	2009-02-20 14:41:27.000000000 -0800
+++ 2/drivers/net/tg3.c	2009-03-19 09:51:17.000000000 -0700
@@ -7799,6 +7799,12 @@ static void tg3_timer(unsigned long __op
 
 	/* This part only runs once per second. */
 	if (!--tp->timer_counter) {
+		u16 pci_cmd;
+
+		pci_read_config_word(tp->pdev, PCI_COMMAND, &pci_cmd);
+		if (!(pci_cmd & PCI_COMMAND_MEMORY))
+			printk( KERN_WARNING "PCI Memory Mapped IO Disabled!!!!\n" );
+
 		if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
 			tg3_periodic_fetch_stats(tp);
 

On Tue, Mar 17, 2009 at 03:09:03PM -0700, Bernhard Schmidt wrote:
> On 16.03.2009 22:23, Michael Chan wrote:
> > On Sun, 2009-03-15 at 14:32 -0700, Andrew Morton wrote:
> >>> [784063.389142] tg3: eth0: transmit timed out, resetting
> >>> [784063.447106] tg3: DEBUG: MAC_TX_STATUS[ffffffff] MAC_RX_STATUS[ffffffff]
> >>> [784063.524104] tg3: DEBUG: RDMAC_STATUS[ffffffff] WDMAC_STATUS[ffffffff]
> >
> > At the time of tx timeout, the registers all return 0xffffffff.  Does
> > the subsequent reset bring the device back?  If the device is brought
> > back, there should be a link up message and traffic should resume.  If
> > not, please provide lspci -vvvxxx on the eth0 device after the failure.
> 
> Attached, both after the crash (tg3.crashed) and after I reloaded the 
> module (tg3.reloaded). Additional info, ifdown/ifup does not fix the 
> situation, both take pretty long
> 
> # ifdown eth0
> tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not clear 
> MAC_TX_MODE=ffffffff
> # ifup eth0
> tg3 0000:03:04.0: irq 1272 for MSI/MSI-X
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> 
> and it stays dead.
> 
> # rmmod tg3
> tg3 0000:03:04.1: PCI INT B disabled
> tg3 0000:03:04.0: PCI INT A disabled
> # modprobe tg3
> tg3.c:v3.94 (August 14, 2008)
> tg3 0000:03:04.0: enabling device (0000 -> 0002)
> tg3 0000:03:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> eth0: Tigon3 [partno(N/A) rev 9003 PHY(5714)] (PCIX:133MHz:64-bit) 
> 10/100/1000Base-T Ethernet 00:21:5a:99:0a:28
> eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] WireSpeed[1] TSOcap[1]
> eth0: dma_rwctrl[76148000] dma_mask[40-bit]
> tg3 0000:03:04.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> eth1: Tigon3 [partno(N/A) rev 9003 PHY(5714)] (PCIX:133MHz:64-bit) 
> 10/100/1000Base-T Ethernet 00:21:5a:99:0a:29
> eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
> eth1: dma_rwctrl[76148000] dma_mask[40-bit]
> # ifup eth0
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> device eth0 entered promiscuous mode
> tg3: eth0: Link is up at 100 Mbps, full duplex.
> tg3: eth0: Flow control is off for TX and off for RX.
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 
> and I'm up and running again.
> 
> > Also, when one ethernet port fails, does the other port (from the same
> > dual port device) function ok?
> 
> Still no clue about that, I need to find someone who can connect 
> something there.
> 
> Bernhard

Content-Description: tg3.crashed
> 00:00.0 Host bridge: Intel Corporation 3200/3210 Chipset DRAM Controller (rev 01)
> 	Subsystem: Hewlett-Packard Company Device 31f9
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information <?>
> 00: 86 80 f0 29 46 01 90 20 01 00 00 06 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 f9 31
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 90 d1 fe 00 00 00 00 01 40 d1 fe 00 00 00 00
> 50: 00 00 02 00 03 20 00 00 00 00 00 00 00 00 00 00
> 60: 01 00 00 e0 00 00 00 00 01 80 d1 fe 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 30 11 31 13 11 31 33 00 ff 03 00 00 00 0a 38 00
> a0: 30 00 00 0c 00 00 00 c0 00 00 00 c0 00 00 00 c0
> b0: 00 c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00
> d0: 00 00 00 00 00 00 00 00 49 00 00 00 00 00 00 8c
> e0: 09 00 0c 91 64 c8 fc c0 43 44 0b 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 90 0f 01 00 00 00 00 00
> 
> 00:01.0 PCI bridge: Intel Corporation 3200/3210 Chipset Host-Primary PCI Express Bridge (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=15, subordinate=1a, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [88] Subsystem: Hewlett-Packard Company Device 31f9
> 	Capabilities: [80] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4169
> 	Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <512ns, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
> 			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [140] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 f1 29 47 05 10 00 01 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 15 1a 00 f0 00 00 00
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 88 00 00 00 00 00 00 00 ff 01 03 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02
> 80: 01 90 03 c8 08 00 00 00 0d 80 00 00 3c 10 f9 31
> 90: 05 a0 01 00 0c 30 e0 fe 69 41 00 00 00 00 00 00
> a0: 10 00 42 01 00 80 00 00 06 00 00 00 01 3d 21 02
> b0: 40 00 01 10 00 00 04 00 00 00 00 00 0e 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 01 00 03 e1 3f 80 90 0f 01 00 00 f0 00 f0
> 
> 00:06.0 PCI bridge: Intel Corporation 3210 Chipset Host-Secondary PCI Express Bridge (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=12, subordinate=14, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [88] Subsystem: Hewlett-Packard Company Device 31f9
> 	Capabilities: [80] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4171
> 	Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #3, Speed 2.5GT/s, Width x8, ASPM L0s L1, Latency L0 <512ns, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
> 			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [140] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 f9 29 47 05 10 00 01 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 12 14 00 f0 00 00 00
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 88 00 00 00 00 00 00 00 ff 01 03 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02
> 80: 01 90 03 c8 08 00 00 00 0d 80 00 00 3c 10 f9 31
> 90: 05 a0 01 00 0c 30 e0 fe 71 41 00 00 00 00 00 00
> a0: 10 00 42 01 00 80 00 00 06 00 00 00 81 3c 21 03
> b0: 40 00 01 10 00 00 04 00 00 00 00 00 0e 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 01 00 03 e1 3f 80 90 0f 01 00 00 00 00 00
> 
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=03, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fdf00000-fdffffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #1, Speed 2.5GT/s, Width x2, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4179
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 40 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 02 03 00 f0 00 00 20
> 20: f0 fd f0 fd f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 21 4c 11 01
> 50: 00 00 21 30 60 00 00 00 00 00 48 01 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 79 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 3 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=04, subordinate=06, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4181
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 44 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 04 06 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 03 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 03
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 81 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 4 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=07, subordinate=09, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4189
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 46 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 07 09 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 04 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 04
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 89 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 5 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=0a, subordinate=0c, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4191
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 48 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 0a 0c 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 05
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 91 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 6 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=0d, subordinate=11, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #6, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4199
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 4a 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 0d 11 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 02 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 06
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 99 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 21
> 	Region 4: I/O ports at 1000 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 34 29 05 00 90 02 02 00 03 0c 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 01 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 21
> 	Region 4: I/O ports at 1020 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 35 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 21 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 02 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 21
> 	Region 4: I/O ports at 1040 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 36 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 41 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 03 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.3 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin D routed to IRQ 21
> 	Region 4: I/O ports at 1060 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 39 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 61 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 04 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 21
> 	Region 0: Memory at fdcf0000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Debug port: BAR=1 offset=00a0
> 	Capabilities: [98] PCIe advanced features <?>
> 	Kernel driver in use: ehci_hcd
> 	Kernel modules: ehci-hcd
> 00: 86 80 3a 29 46 01 90 02 02 20 03 0c 00 00 00 00
> 10: 00 00 cf fd 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 58 c2 c9 00 00 00 00 0a 98 a0 20 00 00 00 00
> 60: 20 20 ff 01 00 00 00 00 01 00 00 01 00 00 08 c0
> 70: 00 00 cf 3f 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 13 00 06 03 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 aa ff 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 88 85 40 00 86 0f 02 00 06 17 02 20
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
> 	I/O behind bridge: 00002000-00003fff
> 	Memory behind bridge: fdd00000-fdefffff
> 	Prefetchable memory behind bridge: 00000000d8000000-00000000dfffffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Subsystem: Hewlett-Packard Company Device 31fe
> 00: 86 80 4e 24 47 01 10 00 92 01 04 06 00 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 01 01 40 20 30 80 22
> 20: d0 fd e0 fd 01 d8 f1 df 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 0b 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 12 00 00
> 50: 0d 00 00 00 3c 10 fe 31 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface Controller (rev 02)
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information <?>
> 00: 86 80 16 29 47 01 10 02 02 00 01 06 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 09 00 00 80 00 00 00 01 08 00 00 10 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 8b 8a 80 80 d0 00 00 00 87 85 8a 8b f8 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 09 34 01 03 0c 00 01 06 7c 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 02 00 00 08 02 00 00 13 00 00 00 00 03 00 00
> b0: 00 00 f0 00 00 00 00 00 00 40 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 67 45 00 00 cf ff 00 00 01 00 00 00
> e0: 09 00 0c 10 00 00 c4 02 60 00 00 00 00 00 00 00
> f0: 01 c0 d1 fe 44 f2 0e 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.2 IDE interface: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 4 port SATA IDE Controller (rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 20
> 	Region 0: I/O ports at 1080 [size=8]
> 	Region 1: I/O ports at 1088 [size=4]
> 	Region 2: I/O ports at 1090 [size=8]
> 	Region 3: I/O ports at 1098 [size=4]
> 	Region 4: I/O ports at 10a0 [size=16]
> 	Region 5: I/O ports at 10b0 [size=16]
> 	Capabilities: [70] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [b0] PCIe advanced features <?>
> 	Kernel driver in use: ata_piix
> 	Kernel modules: ide-pci-generic, ata_generic, ata_piix
> 00: 86 80 20 29 47 00 b0 02 02 8f 01 01 00 00 00 00
> 10: 81 10 00 00 89 10 00 00 91 10 00 00 99 10 00 00
> 20: a1 10 00 00 b1 10 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 07 02 00 00
> 40: 00 80 00 80 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 b0 03 00 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 0f 03 80 01 80 00 00 00 00 00 00 00 00 00
> a0: ac 00 00 00 0a 00 12 00 00 00 00 00 00 00 00 00
> b0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.5 IDE interface: Intel Corporation 82801I (ICH9 Family) 2 port SATA IDE Controller (rev 02) (prog-if 85 [Master SecO PriO])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 20
> 	Region 0: I/O ports at 10c0 [size=8]
> 	Region 1: I/O ports at 10c8 [size=4]
> 	Region 2: I/O ports at 10d0 [size=8]
> 	Region 3: I/O ports at 10d8 [size=4]
> 	Region 4: I/O ports at 10e0 [size=16]
> 	Region 5: I/O ports at 10f0 [size=16]
> 	Capabilities: [70] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [b0] PCIe advanced features <?>
> 	Kernel driver in use: ata_piix
> 	Kernel modules: ide-pci-generic, ata_generic, ata_piix
> 00: 86 80 26 29 47 00 b0 02 02 85 01 01 00 00 00 00
> 10: c1 10 00 00 c9 10 00 00 d1 10 00 00 d9 10 00 00
> 20: e1 10 00 00 f1 10 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 07 02 00 00
> 40: 00 80 00 80 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 b0 03 00 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 01:02.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02) (prog-if 00 [VGA controller])
> 	Subsystem: Hewlett-Packard Company Device 31fb
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (2000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 5
> 	Region 0: Memory at d8000000 (32-bit, prefetchable) [size=128M]
> 	Region 1: I/O ports at 3000 [size=256]
> 	Region 2: Memory at fdef0000 (32-bit, non-prefetchable) [size=64K]
> 	[virtual] Expansion ROM at fdd00000 [disabled] [size=128K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 00: 02 10 5e 51 87 01 90 02 02 00 00 03 10 40 00 00
> 10: 08 00 00 d8 01 30 00 00 00 00 ef fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fb 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 08 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fb 31
> 50: 01 00 02 06 00 00 00 00 02 50 20 00 00 02 00 2f
> 60: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.0 System peripheral: Compaq Computer Corporation Integrated Lights Out Controller (rev 03)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: I/O ports at 2800 [size=256]
> 	Region 1: Memory at fdee0000 (32-bit, non-prefetchable) [size=512]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: hpwdt
> 	Kernel modules: hpwdt
> 00: 11 0e 03 b2 03 01 90 02 03 00 80 08 00 00 80 00
> 10: 01 28 00 00 00 00 ee fd 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0a 01 00 00
> 40: 67 fd 00 00 11 00 00 00 00 00 00 00 06 02 06 02
> 50: 00 00 00 00 00 00 00 00 ef 39 fd 77 01 00 00 5a
> 60: 00 ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 06 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 1a 00 88 03 43 50 51 00
> 90: 30 00 00 00 02 00 00 5f 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 02 00 00 00 00 00 04 04 c1 02
> b0: 00 0a 00 00 00 00 00 00 b7 01 10 51 84 00 03 09
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 01 00 00 00 00 13 21 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.2 System peripheral: Compaq Computer Corporation Integrated Lights Out  Processor (rev 03)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 23
> 	BIST result: 00
> 	Region 0: I/O ports at 3400 [size=256]
> 	Region 1: Memory at fded0000 (32-bit, non-prefetchable) [size=2K]
> 	Region 2: Memory at fdec0000 (32-bit, non-prefetchable) [size=16K]
> 	Region 3: Memory at fde00000 (32-bit, non-prefetchable) [size=512K]
> 	[virtual] Expansion ROM at fdd20000 [disabled] [size=64K]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: hpilo
> 	Kernel modules: hpilo
> 00: 11 0e 04 b2 17 01 90 02 03 00 80 08 10 40 80 80
> 10: 01 34 00 00 00 00 ed fd 00 00 ec fd 00 00 e0 fd
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0b 02 00 00
> 40: 04 0d 00 00 00 00 00 00 00 00 00 00 0a 01 15 12
> 50: 03 e0 ff 00 05 00 40 00 04 00 00 00 00 00 e0 00
> 60: 00 00 00 00 00 00 00 00 8b 60 56 05 59 28 82 f8
> 70: 00 08 00 01 03 03 c0 00 00 00 00 00 00 00 00 00
> 80: fe 01 00 00 62 6a 06 00 6b 63 9b 14 88 48 00 00
> 90: 00 00 00 00 03 03 00 00 00 00 00 00 00 00 00 00
> a0: 14 03 02 00 80 00 00 00 20 00 00 00 00 00 00 00
> b0: 10 00 00 00 00 00 e7 81 ff fd 0e 0d 00 00 00 00
> c0: a3 0c 00 00 00 00 07 00 a5 0c 00 00 00 c0 07 00
> d0: 00 00 00 00 00 00 00 00 9a 17 00 00 00 00 00 00
> e0: 00 00 00 00 0b 00 00 00 00 00 00 00 0b 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.4 USB Controller: Hewlett-Packard Company Proliant iLO2 virtual USB controller (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64
> 	Interrupt: pin B routed to IRQ 23
> 	Region 4: I/O ports at 3800 [size=32]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 3c 10 00 33 45 01 90 02 00 00 03 0c 00 40 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 01 38 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0b 02 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.6 IPMI SMIC interface: Hewlett-Packard Company Proliant iLO2 virtual UART (prog-if 01)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: Memory at fddf0000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: ipmi_si
> 	Kernel modules: ipmi_si
> 00: 3c 10 02 33 02 00 90 02 00 01 07 0c 00 00 80 00
> 10: 00 00 df fd 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0a 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 02:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev b5) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=02, secondary=03, subordinate=03, sec-latency=64
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fdf00000-fdffffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [60] Express (v1) PCI/PCI-X Bridge, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 <16us
> 			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0 <4us, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 	Capabilities: [90] PCI-X bridge device
> 		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=133MHz
> 		Status: Dev=02:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
> 		Upstream: Capacity=0 CommitmentLimit=0
> 		Downstream: Capacity=0 CommitmentLimit=0
> 	Capabilities: [b0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Advanced Error Reporting <?>
> 	Capabilities: [14c] Power Budgeting <?>
> 	Kernel modules: shpchp
> 00: 66 11 03 01 47 01 10 00 b5 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 02 03 03 40 f1 01 00 22
> 20: f0 fd f0 fd f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 60 00 00 00 00 00 00 00 60 00 03 00
> 40: 00 00 00 00 00 00 00 01 00 00 0c 20 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 c0 00 00 c0
> 60: 10 90 71 00 a0 09 00 00 06 00 10 00 41 6c 01 00
> 70: 00 00 21 10 44 08 00 00 00 00 00 00 00 00 00 00
> 80: 01 00 00 00 20 20 30 2b 92 08 18 20 02 60 00 fb
> 90: 07 b0 c3 00 00 02 00 00 00 00 00 00 00 00 00 00
> a0: 90 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 01 00 c2 c9 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 03:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
> 	Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Server Adapter
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 1272
> 	Region 0: Memory at fdff0000 (64-bit, non-prefetchable) [disabled] [size=64K]
> 	Region 2: Memory at fdfe0000 (64-bit, non-prefetchable) [disabled] [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [40] PCI-X non-bridge device
> 		Command: DPERE- ERO- RBC=512 OST=1
> 		Status: Dev=03:04.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data <?>
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable+
> 		Address: 00000000fee0300c  Data: 41d1
> 	Kernel driver in use: tg3
> 	Kernel modules: tg3
> 00: e4 14 78 16 00 00 b0 02 a3 00 00 02 10 40 80 00
> 10: 04 00 ff fd 00 00 00 00 04 00 fe fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 3e 70
> 30: 00 00 e3 82 40 00 00 00 00 00 00 00 0b 01 40 00
> 40: 07 48 00 00 20 03 43 04 01 50 02 c0 00 21 00 64
> 50: 03 58 04 00 3f 61 00 10 05 00 87 00 0c 30 e0 fe
> 60: 00 00 00 00 d1 41 00 00 9a 02 03 90 00 00 00 00
> 70: 6a 10 00 00 c7 00 00 00 50 00 00 00 00 00 00 00
> 80: 03 58 04 00 40 00 00 40 00 00 01 00 fe d0 08 00
> 90: 01 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 03:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
> 	Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Server Adapter
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fdfd0000 (64-bit, non-prefetchable) [size=64K]
> 	Region 2: Memory at fdfc0000 (64-bit, non-prefetchable) [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [40] PCI-X non-bridge device
> 		Command: DPERE- ERO- RBC=512 OST=1
> 		Status: Dev=03:04.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data <?>
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable-
> 		Address: 00000000fee0300c  Data: 41c9
> 	Kernel driver in use: tg3
> 	Kernel modules: tg3
> 00: e4 14 78 16 46 01 b0 02 a3 00 00 02 10 40 80 00
> 10: 04 00 fd fd 00 00 00 00 04 00 fc fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 3e 70
> 30: 00 00 6f ba 40 00 00 00 00 00 00 00 0a 02 40 00
> 40: 07 48 00 00 21 03 43 04 01 50 02 c0 00 20 00 64
> 50: 03 58 e8 00 6b ee 9b 7d 05 00 86 00 0c 30 e0 fe
> 60: 00 00 00 00 c9 41 00 00 9a 02 03 90 00 80 14 76
> 70: ea 10 00 00 c7 00 00 00 14 04 00 00 00 00 00 00
> 80: 29 0a 99 5a 2a 00 00 00 34 00 00 00 fe d0 08 04
> 90: 01 07 00 09 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 

Content-Description: tg3.reloaded
> 00:00.0 Host bridge: Intel Corporation 3200/3210 Chipset DRAM Controller (rev 01)
> 	Subsystem: Hewlett-Packard Company Device 31f9
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information <?>
> 00: 86 80 f0 29 46 01 90 20 01 00 00 06 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 f9 31
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 90 d1 fe 00 00 00 00 01 40 d1 fe 00 00 00 00
> 50: 00 00 02 00 03 20 00 00 00 00 00 00 00 00 00 00
> 60: 01 00 00 e0 00 00 00 00 01 80 d1 fe 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 30 11 31 13 11 31 33 00 ff 03 00 00 00 0a 38 00
> a0: 30 00 00 0c 00 00 00 c0 00 00 00 c0 00 00 00 c0
> b0: 00 c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00
> d0: 00 00 00 00 00 00 00 00 49 00 00 00 00 00 00 8c
> e0: 09 00 0c 91 64 c8 fc c0 43 44 0b 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 90 0f 01 00 00 00 00 00
> 
> 00:01.0 PCI bridge: Intel Corporation 3200/3210 Chipset Host-Primary PCI Express Bridge (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=15, subordinate=1a, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [88] Subsystem: Hewlett-Packard Company Device 31f9
> 	Capabilities: [80] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4169
> 	Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <512ns, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
> 			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [140] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 f1 29 47 05 10 00 01 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 15 1a 00 f0 00 00 00
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 88 00 00 00 00 00 00 00 ff 01 03 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02
> 80: 01 90 03 c8 08 00 00 00 0d 80 00 00 3c 10 f9 31
> 90: 05 a0 01 00 0c 30 e0 fe 69 41 00 00 00 00 00 00
> a0: 10 00 42 01 00 80 00 00 06 00 00 00 01 3d 21 02
> b0: 40 00 01 10 00 00 04 00 00 00 00 00 0e 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 01 00 03 e1 3f 80 90 0f 01 00 00 f0 00 f0
> 
> 00:06.0 PCI bridge: Intel Corporation 3210 Chipset Host-Secondary PCI Express Bridge (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=12, subordinate=14, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [88] Subsystem: Hewlett-Packard Company Device 31f9
> 	Capabilities: [80] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4171
> 	Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #3, Speed 2.5GT/s, Width x8, ASPM L0s L1, Latency L0 <512ns, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
> 			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [140] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 f9 29 47 05 10 00 01 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 12 14 00 f0 00 00 00
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 88 00 00 00 00 00 00 00 ff 01 03 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02
> 80: 01 90 03 c8 08 00 00 00 0d 80 00 00 3c 10 f9 31
> 90: 05 a0 01 00 0c 30 e0 fe 71 41 00 00 00 00 00 00
> a0: 10 00 42 01 00 80 00 00 06 00 00 00 81 3c 21 03
> b0: 40 00 01 10 00 00 04 00 00 00 00 00 0e 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 01 00 03 e1 3f 80 90 0f 01 00 00 00 00 00
> 
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=03, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fdf00000-fdffffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #1, Speed 2.5GT/s, Width x2, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4179
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 40 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 02 03 00 f0 00 00 20
> 20: f0 fd f0 fd f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 21 4c 11 01
> 50: 00 00 21 30 60 00 00 00 00 00 48 01 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 79 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 3 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=04, subordinate=06, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4181
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 44 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 04 06 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 03 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 03
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 81 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 4 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=07, subordinate=09, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4189
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 46 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 07 09 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 04 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 04
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 89 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 5 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=0a, subordinate=0c, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4191
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 48 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 0a 0c 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 05
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 91 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 6 (rev 02) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=0d, subordinate=11, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #6, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> 			ClockPM- Suprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+ CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> 		Address: fee0300c  Data: 4199
> 	Capabilities: [90] Subsystem: Gammagraphx, Inc. Device 0000
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Virtual Channel <?>
> 	Capabilities: [180] Root Complex Link <?>
> 	Kernel driver in use: pcieport-driver
> 	Kernel modules: shpchp
> 00: 86 80 4a 29 47 05 10 00 02 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 0d 11 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 02 03 00
> 40: 10 80 41 00 00 80 00 00 06 00 10 00 11 4c 11 06
> 50: 00 00 01 10 60 00 00 00 00 00 40 00 0e 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 01 00 0c 30 e0 fe 99 41 00 00 00 00 00 00
> 90: 0d a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 11 08 00 00 00 00
> e0: 00 00 c7 00 06 07 08 00 30 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 21
> 	Region 4: I/O ports at 1000 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 34 29 05 00 90 02 02 00 03 0c 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 01 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 21
> 	Region 4: I/O ports at 1020 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 35 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 21 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 02 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 21
> 	Region 4: I/O ports at 1040 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 36 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 41 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 03 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.3 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin D routed to IRQ 21
> 	Region 4: I/O ports at 1060 [size=32]
> 	Capabilities: [50] PCIe advanced features <?>
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 86 80 39 29 05 00 90 02 02 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 61 10 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 04 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 2f 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 21
> 	Region 0: Memory at fdcf0000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Debug port: BAR=1 offset=00a0
> 	Capabilities: [98] PCIe advanced features <?>
> 	Kernel driver in use: ehci_hcd
> 	Kernel modules: ehci-hcd
> 00: 86 80 3a 29 46 01 90 02 02 20 03 0c 00 00 00 00
> 10: 00 00 cf fd 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 58 c2 c9 00 00 00 00 0a 98 a0 20 00 00 00 00
> 60: 20 20 ff 01 00 00 00 00 01 00 00 01 00 00 08 c0
> 70: 00 00 cf 3f 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 13 00 06 03 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 aa ff 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 88 85 40 00 86 0f 02 00 06 17 02 20
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
> 	I/O behind bridge: 00002000-00003fff
> 	Memory behind bridge: fdd00000-fdefffff
> 	Prefetchable memory behind bridge: 00000000d8000000-00000000dfffffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Subsystem: Hewlett-Packard Company Device 31fe
> 00: 86 80 4e 24 47 01 10 00 92 01 04 06 00 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 01 01 40 20 30 80 22
> 20: d0 fd e0 fd 01 d8 f1 df 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 0b 00
> 40: 00 00 00 00 00 00 00 00 01 00 00 00 00 12 00 00
> 50: 0d 00 00 00 3c 10 fe 31 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface Controller (rev 02)
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information <?>
> 00: 86 80 16 29 47 01 10 02 02 00 01 06 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 09 00 00 80 00 00 00 01 08 00 00 10 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 8b 8a 80 80 d0 00 00 00 87 85 8a 8b f8 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 09 34 01 03 0c 00 01 06 7c 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 02 00 00 08 02 00 00 13 00 00 00 00 03 00 00
> b0: 00 00 f0 00 00 00 00 00 00 40 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 67 45 00 00 cf ff 00 00 01 00 00 00
> e0: 09 00 0c 10 00 00 c4 02 60 00 00 00 00 00 00 00
> f0: 01 c0 d1 fe 44 f2 0e 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.2 IDE interface: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 4 port SATA IDE Controller (rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 20
> 	Region 0: I/O ports at 1080 [size=8]
> 	Region 1: I/O ports at 1088 [size=4]
> 	Region 2: I/O ports at 1090 [size=8]
> 	Region 3: I/O ports at 1098 [size=4]
> 	Region 4: I/O ports at 10a0 [size=16]
> 	Region 5: I/O ports at 10b0 [size=16]
> 	Capabilities: [70] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [b0] PCIe advanced features <?>
> 	Kernel driver in use: ata_piix
> 	Kernel modules: ide-pci-generic, ata_generic, ata_piix
> 00: 86 80 20 29 47 00 b0 02 02 8f 01 01 00 00 00 00
> 10: 81 10 00 00 89 10 00 00 91 10 00 00 99 10 00 00
> 20: a1 10 00 00 b1 10 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 07 02 00 00
> 40: 00 80 00 80 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 b0 03 00 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 0f 03 80 01 80 00 00 00 00 00 00 00 00 00
> a0: ac 00 00 00 0a 00 12 00 00 00 00 00 00 00 00 00
> b0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 00:1f.5 IDE interface: Intel Corporation 82801I (ICH9 Family) 2 port SATA IDE Controller (rev 02) (prog-if 85 [Master SecO PriO])
> 	Subsystem: Hewlett-Packard Company Device 31fe
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 20
> 	Region 0: I/O ports at 10c0 [size=8]
> 	Region 1: I/O ports at 10c8 [size=4]
> 	Region 2: I/O ports at 10d0 [size=8]
> 	Region 3: I/O ports at 10d8 [size=4]
> 	Region 4: I/O ports at 10e0 [size=16]
> 	Region 5: I/O ports at 10f0 [size=16]
> 	Capabilities: [70] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [b0] PCIe advanced features <?>
> 	Kernel driver in use: ata_piix
> 	Kernel modules: ide-pci-generic, ata_generic, ata_piix
> 00: 86 80 26 29 47 00 b0 02 02 85 01 01 00 00 00 00
> 10: c1 10 00 00 c9 10 00 00 d1 10 00 00 d9 10 00 00
> 20: e1 10 00 00 f1 10 00 00 00 00 00 00 3c 10 fe 31
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 07 02 00 00
> 40: 00 80 00 80 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 b0 03 00 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 86 0f 02 00 00 00 00 00
> 
> 01:02.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02) (prog-if 00 [VGA controller])
> 	Subsystem: Hewlett-Packard Company Device 31fb
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (2000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 5
> 	Region 0: Memory at d8000000 (32-bit, prefetchable) [size=128M]
> 	Region 1: I/O ports at 3000 [size=256]
> 	Region 2: Memory at fdef0000 (32-bit, non-prefetchable) [size=64K]
> 	[virtual] Expansion ROM at fdd00000 [disabled] [size=128K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 00: 02 10 5e 51 87 01 90 02 02 00 00 03 10 40 00 00
> 10: 08 00 00 d8 01 30 00 00 00 00 ef fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fb 31
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 08 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 fb 31
> 50: 01 00 02 06 00 00 00 00 02 50 20 00 00 02 00 2f
> 60: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.0 System peripheral: Compaq Computer Corporation Integrated Lights Out Controller (rev 03)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: I/O ports at 2800 [size=256]
> 	Region 1: Memory at fdee0000 (32-bit, non-prefetchable) [size=512]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: hpwdt
> 	Kernel modules: hpwdt
> 00: 11 0e 03 b2 03 01 90 02 03 00 80 08 00 00 80 00
> 10: 01 28 00 00 00 00 ee fd 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0a 01 00 00
> 40: 67 fd 00 00 11 00 00 00 00 00 00 00 06 02 06 02
> 50: 00 00 00 00 00 00 00 00 fa 39 fd 77 01 00 00 5a
> 60: 00 ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 06 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 1a 00 88 03 43 50 51 00
> 90: 30 00 00 00 02 00 00 5f 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 02 00 00 00 00 00 04 04 c1 02
> b0: 00 0a 00 00 00 00 00 00 b7 01 10 51 84 00 03 09
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 00 00 00 00 00 00 00 01 00 00 00 00 13 21 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.2 System peripheral: Compaq Computer Corporation Integrated Lights Out  Processor (rev 03)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 23
> 	BIST result: 00
> 	Region 0: I/O ports at 3400 [size=256]
> 	Region 1: Memory at fded0000 (32-bit, non-prefetchable) [size=2K]
> 	Region 2: Memory at fdec0000 (32-bit, non-prefetchable) [size=16K]
> 	Region 3: Memory at fde00000 (32-bit, non-prefetchable) [size=512K]
> 	[virtual] Expansion ROM at fdd20000 [disabled] [size=64K]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: hpilo
> 	Kernel modules: hpilo
> 00: 11 0e 04 b2 17 01 90 02 03 00 80 08 10 40 80 80
> 10: 01 34 00 00 00 00 ed fd 00 00 ec fd 00 00 e0 fd
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0b 02 00 00
> 40: 04 0d 00 00 00 00 00 00 00 00 00 00 0a 01 15 12
> 50: 03 e0 ff 00 05 00 40 00 04 00 00 00 00 00 e0 00
> 60: 00 00 00 00 00 00 00 00 8b 60 56 05 59 28 82 f8
> 70: 00 08 00 01 03 03 c0 00 00 00 00 00 00 00 00 00
> 80: bb 03 00 00 57 39 06 00 73 08 4c c5 8e 48 00 00
> 90: 00 00 00 00 03 03 00 00 00 00 00 00 00 00 00 00
> a0: 14 03 02 00 80 00 00 00 20 00 00 00 00 00 00 00
> b0: 10 00 00 00 00 00 e7 81 ff fd 0e 0d 00 00 00 00
> c0: a3 0c 00 00 00 00 07 00 a5 0c 00 00 00 c0 07 00
> d0: 00 00 00 00 00 00 00 00 9a 17 00 00 00 00 00 00
> e0: 00 00 00 00 0b 00 00 00 00 00 00 00 0b 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.4 USB Controller: Hewlett-Packard Company Proliant iLO2 virtual USB controller (prog-if 00 [UHCI])
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64
> 	Interrupt: pin B routed to IRQ 23
> 	Region 4: I/O ports at 3800 [size=32]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: uhci_hcd
> 	Kernel modules: uhci-hcd
> 00: 3c 10 00 33 45 01 90 02 00 00 03 0c 00 40 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 01 38 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0b 02 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 01:04.6 IPMI SMIC interface: Hewlett-Packard Company Proliant iLO2 virtual UART (prog-if 01)
> 	Subsystem: Hewlett-Packard Company Device 3305
> 	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: Memory at fddf0000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [f0] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: ipmi_si
> 	Kernel modules: ipmi_si
> 00: 3c 10 02 33 02 00 90 02 00 01 07 0c 00 00 80 00
> 10: 00 00 df fd 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 05 33
> 30: 00 00 00 00 f0 00 00 00 00 00 00 00 0a 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 01 00 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 
> 02:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev b5) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=02, secondary=03, subordinate=03, sec-latency=64
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fdf00000-fdffffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [60] Express (v1) PCI/PCI-X Bridge, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 <16us
> 			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0 <4us, L1 <4us
> 			ClockPM- Suprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 	Capabilities: [90] PCI-X bridge device
> 		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=133MHz
> 		Status: Dev=02:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
> 		Upstream: Capacity=0 CommitmentLimit=0
> 		Downstream: Capacity=0 CommitmentLimit=0
> 	Capabilities: [b0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [100] Advanced Error Reporting <?>
> 	Capabilities: [14c] Power Budgeting <?>
> 	Kernel modules: shpchp
> 00: 66 11 03 01 47 01 10 00 b5 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 02 03 03 40 f1 01 00 22
> 20: f0 fd f0 fd f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 60 00 00 00 00 00 00 00 60 00 03 00
> 40: 00 00 00 00 00 00 00 01 00 00 0c 20 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 c0 00 00 c0
> 60: 10 90 71 00 a0 09 00 00 06 00 10 00 41 6c 01 00
> 70: 00 00 21 10 44 08 00 00 00 00 00 00 00 00 00 00
> 80: 01 00 00 00 20 20 30 2b 92 08 18 20 02 60 00 fb
> 90: 07 b0 c3 00 00 02 00 00 00 00 00 00 00 00 00 00
> a0: 90 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 01 00 c2 c9 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 03:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
> 	Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Server Adapter
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 1272
> 	Region 0: Memory at fdff0000 (64-bit, non-prefetchable) [size=64K]
> 	Region 2: Memory at fdfe0000 (64-bit, non-prefetchable) [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [40] PCI-X non-bridge device
> 		Command: DPERE- ERO- RBC=512 OST=1
> 		Status: Dev=03:04.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data <?>
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable+
> 		Address: 00000000fee0300c  Data: 41e1
> 	Kernel driver in use: tg3
> 	Kernel modules: tg3
> 00: e4 14 78 16 06 00 b0 02 a3 00 00 02 10 40 80 00
> 10: 04 00 ff fd 00 00 00 00 04 00 fe fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 3e 70
> 30: 00 00 e3 82 40 00 00 00 00 00 00 00 0b 01 40 00
> 40: 07 48 00 00 20 03 43 04 01 50 02 c0 00 21 00 64
> 50: 03 58 04 00 3f 61 00 10 05 00 87 00 0c 30 e0 fe
> 60: 00 00 00 00 e1 41 00 00 98 02 03 90 00 80 14 76
> 70: ea 10 00 00 c7 00 00 00 50 00 00 00 00 00 00 00
> 80: 03 58 04 00 d0 00 00 c0 34 00 13 04 82 d0 08 04
> 90: 09 97 00 01 00 00 00 00 00 00 00 00 bf 00 00 00
> a0: 00 00 00 00 f7 01 00 00 00 00 00 00 a2 00 00 00
> b0: 00 00 00 00 00 00 00 65 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 03:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
> 	Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Server Adapter
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fdfd0000 (64-bit, non-prefetchable) [size=64K]
> 	Region 2: Memory at fdfc0000 (64-bit, non-prefetchable) [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [40] PCI-X non-bridge device
> 		Command: DPERE- ERO- RBC=512 OST=1
> 		Status: Dev=03:04.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data <?>
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable-
> 		Address: 00000000fee0300c  Data: 41c9
> 	Kernel driver in use: tg3
> 	Kernel modules: tg3
> 00: e4 14 78 16 46 01 b0 02 a3 00 00 02 10 40 80 00
> 10: 04 00 fd fd 00 00 00 00 04 00 fc fd 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 3e 70
> 30: 00 00 6f ba 40 00 00 00 00 00 00 00 0a 02 40 00
> 40: 07 48 00 00 21 03 43 04 01 50 02 c0 00 20 00 64
> 50: 03 58 e8 00 6b ee 9b 7d 05 00 86 00 0c 30 e0 fe
> 60: 00 00 00 00 c9 41 00 00 9a 02 03 90 00 80 14 76
> 70: ea 10 00 00 c7 00 00 00 14 04 00 00 00 00 00 00
> 80: 29 0a 99 5a 2a 00 00 00 34 00 00 00 fe d0 08 04
> 90: 01 07 00 09 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 


