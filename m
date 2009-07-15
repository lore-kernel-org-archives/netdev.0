From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe:  schedule while atomic bug during dev_disable_lro  2.6.31-rc3
Date: Wed, 15 Jul 2009 16:00:26 -0700
Message-ID: <4A5E5F8A.308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54959 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050AbZGOXA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 19:00:26 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6FN0QVd032061
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 16:00:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just got a fancy new 10G NIC and tried it out in a (patched elsewhere, but stock ixgbe driver) 2.6.31-rc3) kernel.

First of all, it runs very fast:  sustained 9.5Gbps tx + rx on two ports concurrently (using modified pktgen),
with 1500 byte pkts.

I did see a warning in the boot logs though.

Here is the lspci for one of these ports:

03:00.1 Ethernet controller: Intel Corporation Device 10fb (rev 01)
	Subsystem: Device 0083:000c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f9680000 (64-bit, prefetchable) [size=512K]
	Region 2: I/O ports at e880 [size=32]
	Region 4: Memory at f9778000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] MSI: Mask+ 64bit+ Count=1/1 Enable-
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [70] MSI-X: Enable+ Mask- TabSize=64
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00002000
	Capabilities: [a0] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 5GT/s, Width x8, ASPM unknown, Latency L0 <1us, L1 <8us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140] Device Serial Number 00-00-00-ff-ff-00-00-00
	Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
		ARICap:	MFVC- ACS-, Next Function: 0
		ARICtl:	MFVC- ACS-, Function Group: 0
	Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
		IOVCap:	Migration-, Interrupt Message Number: 000
		IOVCtl:	Enable- Migration- Interrupt- MSE- ARIHierarchy-
		IOVSta:	Migration-
		Initial VFs: 64, Total VFs: 64, Number of VFs: 64, Function Dependency Link: 01
		VF offset: 128, stride: 2, Device ID: 10d8
		Supported Page Size: 00000553, System Page Size: 00000001
		VF Migration: offset: 00000000, BIR: 0
	Kernel driver in use: ixgbe
	Kernel modules: ixgbe


selected dmesg output:

ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.34-k2
ixgbe: Copyright (c) 1999-2009 Intel Corporation.
ixgbe 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ixgbe 0000:03:00.0: setting latency timer to 64
   alloc irq_desc for 35 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 35 for MSI/MSI-X
   alloc irq_desc for 36 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 36 for MSI/MSI-X
   alloc irq_desc for 37 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 37 for MSI/MSI-X
   alloc irq_desc for 38 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 38 for MSI/MSI-X
   alloc irq_desc for 39 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 39 for MSI/MSI-X
   alloc irq_desc for 40 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 40 for MSI/MSI-X
   alloc irq_desc for 41 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 41 for MSI/MSI-X
   alloc irq_desc for 42 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 42 for MSI/MSI-X
   alloc irq_desc for 43 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 43 for MSI/MSI-X
   alloc irq_desc for 44 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 44 for MSI/MSI-X
   alloc irq_desc for 45 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 45 for MSI/MSI-X
   alloc irq_desc for 46 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 46 for MSI/MSI-X
   alloc irq_desc for 47 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 47 for MSI/MSI-X
   alloc irq_desc for 48 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 48 for MSI/MSI-X
   alloc irq_desc for 49 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 49 for MSI/MSI-X
   alloc irq_desc for 50 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 50 for MSI/MSI-X
   alloc irq_desc for 51 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.0: irq 51 for MSI/MSI-X
ixgbe: 0000:03:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x8) 00:0c:bd:00:90:1a
ixgbe 0000:03:00.0: MAC: 2, PHY: 9, SFP+: 5, PBA No: e57138-000
ixgbe 0000:03:00.0: This device is a pre-production adapter/LOM.  Please be aware there may be issues associated with your hardware.  If you are experiencing 
problems please contact your Intel or hardware representative who provided you with this hardware.
ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
   alloc irq_desc for 17 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ixgbe 0000:03:00.1: setting latency timer to 64
   alloc irq_desc for 52 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 52 for MSI/MSI-X
   alloc irq_desc for 53 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 53 for MSI/MSI-X
   alloc irq_desc for 54 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 54 for MSI/MSI-X
   alloc irq_desc for 55 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 55 for MSI/MSI-X
   alloc irq_desc for 56 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 56 for MSI/MSI-X
   alloc irq_desc for 57 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 57 for MSI/MSI-X
   alloc irq_desc for 58 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 58 for MSI/MSI-X
   alloc irq_desc for 59 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 59 for MSI/MSI-X
   alloc irq_desc for 60 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 60 for MSI/MSI-X
   alloc irq_desc for 61 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 61 for MSI/MSI-X
   alloc irq_desc for 62 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 62 for MSI/MSI-X
   alloc irq_desc for 63 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 63 for MSI/MSI-X
   alloc irq_desc for 64 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 64 for MSI/MSI-X
   alloc irq_desc for 65 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 65 for MSI/MSI-X
   alloc irq_desc for 66 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 66 for MSI/MSI-X
   alloc irq_desc for 67 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 67 for MSI/MSI-X
   alloc irq_desc for 68 on node 0
   alloc kstat_irqs on node 0
ixgbe 0000:03:00.1: irq 68 for MSI/MSI-X
ixgbe: 0000:03:00.1: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
ixgbe 0000:03:00.1: (PCI Express:5.0Gb/s:Width x8) 00:0c:bd:00:90:1b
ixgbe 0000:03:00.1: MAC: 2, PHY: 9, SFP+: 5, PBA No: e57138-000
ixgbe 0000:03:00.1: This device is a pre-production adapter/LOM.  Please be aware there may be issues associated with your hardware.  If you are experiencing 
problems please contact your Intel or hardware representative who provided you with this hardware.
ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection

....

BUG: scheduling while atomic: S99lanforge/2133/0x00000002
Modules linked in: sco stp llc bnep l2cap bluetooth nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 dm_multipath uinput ixgbe i2c_i801 i2c_core dca mdio 
e1000e iTCO_wdt iTCO_vendor_support pcspkr ata_generic pata_acpi [last unloaded: bridge]
Pid: 2133, comm: S99lanforge Not tainted 2.6.31-rc3 #2
Call Trace:
  [<ffffffff81042456>] __schedule_bug+0x5c/0x60
  [<ffffffff813e6712>] schedule+0xc1/0x85e
  [<ffffffff8104488a>] ? check_preempt_wakeup+0x2d/0x1b7
  [<ffffffff813e880b>] ? _spin_unlock_irqrestore+0x37/0x42
  [<ffffffff813e7182>] schedule_timeout+0x97/0xbb
  [<ffffffff8105857e>] ? process_timeout+0x0/0xb
  [<ffffffff813e71bf>] schedule_timeout_uninterruptible+0x19/0x1b
  [<ffffffff81058a25>] msleep+0x16/0x1d
  [<ffffffffa005e160>] ixgbe_stop_adapter_generic+0x38/0x97 [ixgbe]
  [<ffffffffa0063e5a>] ixgbe_reset_hw_82599+0x13/0x1a4 [ixgbe]
  [<ffffffffa005cfc3>] ixgbe_init_hw_generic+0xf/0x1d [ixgbe]
  [<ffffffffa0056f04>] ixgbe_reset+0x1e/0xef [ixgbe]
  [<ffffffffa005ee71>] ixgbe_set_flags+0x5c/0x66 [ixgbe]
  [<ffffffff81343fe2>] dev_disable_lro+0x4d/0x69
  [<ffffffff81398191>] devinet_sysctl_forward+0xd7/0x1a4
  [<ffffffff81136111>] proc_sys_call_handler+0x8d/0xb7
  [<ffffffff8113614a>] proc_sys_write+0xf/0x11
  [<ffffffff810e856d>] vfs_write+0xa9/0x106
  [<ffffffff810e8680>] sys_write+0x45/0x69
  [<ffffffff81011b42>] system_call_fastpath+0x16/0x1b

More info available if needed.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

