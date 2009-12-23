From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH 0/3] increase skb size to prevent dma over skb boundary
Date: Tue, 22 Dec 2009 22:47:26 -0800
Message-ID: <20091223064725.GB12439@jenkins.home.ifup.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
 <EA929A9653AAE14F841771FB1DE5A1365FA93CD0DD@rrsmsx501.amr.corp.intel.com>
 <20091209152312.GA11983@hmsreliant.think-freely.org>
 <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:38983 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbZLWGsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 01:48:00 -0500
Received: by gxk3 with SMTP id 3so1170783gxk.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2009 22:47:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11:20 Thu 10 Dec 2009, Tantilov, Emil S wrote:
> >> I am trying to test the patches you submitted (thanks btw) and so
> >> far am not able to reproduce the panic you described. When MTU is at
> >> 1500 RCTL.LPE (bit 5) is set to 0 and the HW will not allow the
> >> reception of large packets (>1522 bytes, which is what rx_buffer_len
> >> is set to). This is basically what I am seeing in my tests - packets
> >> are discarded by the HW.     

I have a memory dump from an SLE10 SP3 machine that seems to reproduce
this issue. The testing environment was netperf with the MTU being
switched every minute from 9000 -> 1500 and it took 40 hours to hit
the bug. So, an overnight test, as you tried, may not be enough.

In the memory dump there are 6 skb's in the ring that have memory
overwritten from skb->data to skb->data + 2048. The machine ended up
oopsing in skb_release_data() from e1000_clean_all_rx_rings() from
e1000_change_mtu().

I will let you know if this patch ended up helping.

Cheers,

	Brandon

35:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)
        Subsystem: Intel Corporation PRO/1000 PT Quad Port LP Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 91
        Region 0: Memory at c9120000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at c9100000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at <unassigned>
        Expansion ROM at fda20000 [disabled] [size=128K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Mask- 64bit+ Count=1/1 Enable+
                Address: 00000000fee1d000  Data: 405b
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #2, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 <4us, L1 <64us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Kernel driver in use: e1000
        Kernel modules: e1000
