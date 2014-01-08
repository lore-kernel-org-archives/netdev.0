From: David Lamparter <equinox@diac24.net>
Subject: mlx4 w/ IOMMU broken, kernel 3.12.6
Date: Wed, 8 Jan 2014 14:49:17 +0100
Message-ID: <20140108134917.GC351037@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:40604 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756524AbaAHORy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 09:17:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


mlx4 is currently broken when an IOMMU is enabled, the driver does not
seem to set up regions correctly (and also, the card seems to access things
before its driver is loaded):

(This is the in-kernel driver.  The separately distributed 1.5.10
Mellanox driver does not seem to build against kernel 3.12.6.)

[    1.897271] IOMMU 0 0xfbffc000: using Queued invalidation
[    1.897569] IOMMU: Setting RMRR:
[    1.897872] IOMMU: Setting identity map for device 0000:00:1d.0 [0x7dea2000 - 0x7deaefff]
[    1.898415] IOMMU: Setting identity map for device 0000:00:1a.0 [0x7dea2000 - 0x7deaefff]
[    1.898930] IOMMU: Prepare 0-16MiB unity mapping for LPC
[    1.899217] IOMMU: Setting identity map for device 0000:00:1f.0 [0x0 - 0xffffff]
[    1.899726] PCI-DMA: Intel(R) Virtualization Technology for Directed I/O
[    1.902086] dmar: DRHD: handling fault status reg 2
[    1.902362] dmar: DMAR:[DMA Read] Request device [06:00.0] fault addr 72469000 
DMAR:[fault reason 01] Present bit in root entry is clear
(...)
[    3.299985] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
[    3.300247] mlx4_core: Initializing 0000:06:00.0
[    4.306091] dmar: DRHD: handling fault status reg 102
[    4.306359] dmar: DMAR:[DMA Read] Request device [06:00.0] fault addr 7236f000 
DMAR:[fault reason 06] PTE Read access is not set
[   14.309294] mlx4_core 0000:06:00.0: command 0x4 timed out (go bit not cleared)
[   14.309759] mlx4_core 0000:06:00.0: QUERY_FW command failed, aborting.
[   15.313896] mlx4_core: probe of 0000:06:00.0 failed with error -110

(PCI/IOMMU Host is an Intel Xeon E5-2630v2)

Since the driver hasn't been touched in net-next, I assume this issue
hasn't been fixed in the time since 3.12 was released;  my apologies if
this is incorrect.

Card information:
# lspci -vvnns 06:00.0
06:00.0 Ethernet controller [0200]: Mellanox Technologies MT27500 Family [ConnectX-3] [15b3:1003]
	Subsystem: Mellanox Technologies Device [15b3:0077]
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 42
	Region 0: Memory at fba00000 (64-bit, non-prefetchable) [size=1M]
	Region 2: Memory at 380fff000000 (64-bit, prefetchable) [size=8M]
	Expansion ROM at fb900000 [disabled] [size=1M]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [48] Vital Product Data
pcilib: sysfs_read_vpd: read failed: Connection timed out
		Not readable
	Capabilities: [9c] MSI-X: Enable- Count=128 Masked-
		Vector table: BAR=0 offset=0007c000
		PBA: BAR=0 offset=0007d000
	Capabilities: [60] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- FLReset-
			MaxPayload 256 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #8, Speed 8GT/s, Width x8, ASPM L0s, Exit Latency L0s unlimited, L1 unlimited
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 8GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Alternative Routing-ID Interpretation (ARI)
		ARICap:	MFVC- ACS-, Next Function: 0
		ARICtl:	MFVC- ACS-, Function Group: 0
	Capabilities: [148 v1] Device Serial Number 00-02-c9-03-00-ea-72-e0
	Capabilities: [154 v2] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [18c v1] #19

Cheers,

David
