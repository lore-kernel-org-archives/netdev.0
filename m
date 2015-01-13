From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [3.19-rc3] tg3: BUG: sleeping function called from invalid context
Date: Tue, 13 Jan 2015 07:47:48 -0500
Message-ID: <54B513F4.5020403@hurleysoftware.com>
References: <54B46DD5.9050802@hurleysoftware.com> <1421131762.7208.31.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421131762.7208.31.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/2015 01:49 AM, Michael Chan wrote:
> On Mon, 2015-01-12 at 19:59 -0500, Peter Hurley wrote: 
>> [   17.203009] BUG: sleeping function called from invalid context at /home/peter/src/kernels/mainline/kernel/irq/manage.c:104
>> [   17.203067] in_atomic(): 1, irqs_disabled(): 0, pid: 1106, name: ip
>> [   17.203092] 2 locks held by ip/1106:
>> [   17.205255]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816adf1f>] rtnetlink_rcv+0x1f/0x40
>> [   17.207445]  #1:  (&(&tp->lock)->rlock){+.....}, at: [<ffffffffa01073e6>] tg3_start+0xc06/0x11f0 [tg3]
>> [   17.209725] CPU: 2 PID: 1106 Comm: ip Not tainted 3.19.0-rc3+wip-xeon+lockdep #rc3+wip
>> [   17.211900] Hardware name: Dell Inc. Precision WorkStation T5400  /0RW203, BIOS A11 04/30/2012
>> [   17.214086]  0000000000000068 ffff8802ac823498 ffffffff817af7e8 0000000000000005
>> [   17.216265]  ffffffff81a9be78 ffff8802ac8234a8 ffffffff810998a5 ffff8802ac8234d8
>> [   17.218446]  ffffffff8109991a ffff8802ac8234c8 ffff8802af0aae00 ffffffffa00ed000
>> [   17.220636] Call Trace:
>> [   17.222743]  [<ffffffff817af7e8>] dump_stack+0x4f/0x7b
>> [   17.224808]  [<ffffffff810998a5>] ___might_sleep+0x105/0x140
>> [   17.226842]  [<ffffffff8109991a>] __might_sleep+0x3a/0xa0
>> [   17.228869]  [<ffffffffa00ed000>] ? 0xffffffffa00ed000
>> [   17.230939]  [<ffffffff810d7d78>] synchronize_irq+0x38/0xa0
>> [   17.232967]  [<ffffffffa00ed000>] ? 0xffffffffa00ed000
>> [   17.234991]  [<ffffffffa010105f>] tg3_chip_reset+0x13f/0x9c0 [tg3]
>> [   17.236988]  [<ffffffffa01020ae>] tg3_reset_hw+0x7e/0x2d20 [tg3] 
> 
> tp->lock is held in this code path.  If synchronize_irq() sleeps in
> wait_event(desc->wait_for_threads, ...), we'll get the warning.
> 
> The synchronize_irq() call is to wait for any tg3 irq handler to finish
> so that it is guaranteed that next time it will see the CHIP_RESETTING
> flag and do nothing.
> 
> Not sure if we can drop the tp->lock before we call synchronize_irq()
> and then take it again after synchronize_irq().

Well, this device [1] is using MSI (INTx disabled) so if the synchronize_irq()
is _only_ for the CHIP_RESETTING logic then it would seem ok to skip it (the
synchronize_irq()).

Regards,
Peter Hurley


[1] lspci -vv

08:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5754 Gigabit Ethernet PCI Express (rev 02)
	Subsystem: Dell Precision T5400
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 31
	Region 0: Memory at d3ff0000 (64-bit, non-prefetchable) [size=64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetLink Gigabit Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95754
			[EC] Engineering changes: 106679-15
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 34 65 34
			[RV] Reserved: checksum good, 30 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: XYZ01234567
			[RW] Read-write area: 107 byte(s) free
		End
	Capabilities: [58] Vendor Specific Information: Len=78 <?>
	Capabilities: [e8] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0400c  Data: 41a2
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exit Latency L0s <4us, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr+ BadTLP- BadDLLP+ Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number xx-xx-xx-xx-xx-xx-xx-xx
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: tg3
