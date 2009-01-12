From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000 tx Unit hang on 2.6.28 and patch that works...
Date: Mon, 12 Jan 2009 10:27:55 -0800
Message-ID: <9929d2390901121027n4c435130h73ad9d337bcd87bb@mail.gmail.com>
References: <007e01c972a3$db2301b0$91690510$@net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: "Doug Bazarnic" <kernel@bazarnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:64990 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbZALS16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 13:27:58 -0500
In-Reply-To: <007e01c972a3$db2301b0$91690510$@net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2009 at 1:47 PM, Doug Bazarnic <kernel@bazarnic.net> wrote:
> Asus P5k, Intel Q9450, 8gb ram, x86_64, running 2.6.28.   The on board eth0
> atl1 never has a problem, only eth1 intel e1000, plugged into a pci slot.
>
> On a couple of machines, the way I got it to stop, was to use 8.0.6 intel
> e1000 driver with the patch below.  (works on same hardware, running 2.6.27
> kernels)
> I can't remember where I downloaded this patch from, but I haven't had an
> issue yet with it.
>
> [root@web6 SCRIPTS]# cat e1000-8-0-6-stepfix.patch
>>diff -up e1000-8-0-6base/src/e1000_main.c
> e1000-8-0-6stepfix/src/e1000_main.c
>>--- e1000-8-0-6base/src/e1000_main.c    2008-10-29 17:38:38.000000000 -0700
>>+++ e1000-8-0-6stepfix/src/e1000_main.c 2008-10-29 17:43:52.000000000 -0700
>>@@ -65,7 +65,7 @@ static char e1000_driver_string[] = "Int
>>
>> #define DRV_HW_PERF
>>
>>-#define DRV_VERSION "8.0.6" DRV_NAPI DRV_DEBUG DRV_HW_PERF
>>+#define DRV_VERSION "8.0.6a" DRV_NAPI DRV_DEBUG DRV_HW_PERF
>> const char e1000_driver_version[] = DRV_VERSION;
>> static const char e1000_copyright[] = "Copyright (c) 1999-2008 Intel
> Corporation.";
>>
>>@@ -2364,8 +2364,8 @@ link_up:
>>        if (!netif_carrier_ok(netdev)) {
>>                for (i = 0 ; i < adapter->num_tx_queues ; i++) {
>>                        tx_ring = &adapter->tx_ring[i];
>>-                       tx_pending |= (E1000_DESC_UNUSED(tx_ring) + 1 <
>>-
> tx_ring->count);
>>+                       tx_pending |= (E1000_DESC_UNUSED(tx_ring) +
>>+                                     tx_ring->step  < tx_ring->count);
>>                }
>>                if (tx_pending) {
>>                        /* We've lost link, so the controller stops DMA,
>>@@ -2892,7 +2892,7 @@ static int __e1000_maybe_stop_tx(struct
>>
>>        /* We need to check again in a case another CPU has just
>>         * made room available. */
>>-       if (likely(E1000_DESC_UNUSED(tx_ring) < size))
>>+       if (likely(E1000_DESC_UNUSED(tx_ring) < ((size) * tx_ring->step)))
>>                return -EBUSY;
>>
>>        /* A reprieve! */
>>@@ -2909,7 +2909,7 @@ static int __e1000_maybe_stop_tx(struct
>> static int e1000_maybe_stop_tx(struct net_device *netdev,
>>                                struct e1000_tx_ring *tx_ring, int size)
>> {
>>-       if (likely(E1000_DESC_UNUSED(tx_ring) >= size))
>>+       if (likely(E1000_DESC_UNUSED(tx_ring) >= ((size) * tx_ring->step)))
>>                return 0;
>>        return __e1000_maybe_stop_tx(netdev, tx_ring, size);
>> }
>
> ---------------------------------
>
> This has been an ongoing problem on over 20 identical machines.
>
> Jan  7 13:26:41 web2 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx
> Unit Hang
> Jan  7 13:26:41 web2 kernel:   Tx Queue             <0>
> Jan  7 13:26:41 web2 kernel:   TDH                  <2a>
> Jan  7 13:26:41 web2 kernel:   TDT                  <2d>
> Jan  7 13:26:41 web2 kernel:   next_to_use          <2d>
> Jan  7 13:26:41 web2 kernel:   next_to_clean        <2a>
> Jan  7 13:26:41 web2 kernel: buffer_info[next_to_clean]
> Jan  7 13:26:41 web2 kernel:   time_stamp           <103105c76>
> Jan  7 13:26:41 web2 kernel:   next_to_watch        <2a>
> Jan  7 13:26:41 web2 kernel:   jiffies              <103106770>
> Jan  7 13:26:41 web2 kernel:   next_to_watch.status <0>
> Jan  7 13:26:43 web2 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx
> Unit Hang
> Jan  7 13:26:43 web2 kernel:   Tx Queue             <0>
> Jan  7 13:26:43 web2 kernel:   TDH                  <2a>
> Jan  7 13:26:43 web2 kernel:   TDT                  <2d>
> Jan  7 13:26:43 web2 kernel:   next_to_use          <2d>
> Jan  7 13:26:43 web2 kernel:   next_to_clean        <2a>
> Jan  7 13:26:43 web2 kernel: buffer_info[next_to_clean]
> Jan  7 13:26:43 web2 kernel:   time_stamp           <103105c76>
> Jan  7 13:26:43 web2 kernel:   next_to_watch        <2a>
> Jan  7 13:26:43 web2 kernel:   jiffies              <103106f41>
> Jan  7 13:26:43 web2 kernel:   next_to_watch.status <0>
> Jan  7 13:26:45 web2 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx
> Unit Hang
> Jan  7 13:26:45 web2 kernel:   Tx Queue             <0>
> Jan  7 13:26:45 web2 kernel:   TDH                  <2a>
> Jan  7 13:26:45 web2 kernel:   TDT                  <2d>
> Jan  7 13:26:45 web2 kernel:   next_to_use          <2d>
> Jan  7 13:26:45 web2 kernel:   next_to_clean        <2a>
> Jan  7 13:26:45 web2 kernel: buffer_info[next_to_clean]
> Jan  7 13:26:45 web2 kernel:   time_stamp           <103105c76>
> Jan  7 13:26:45 web2 kernel:   next_to_watch        <2a>
> Jan  7 13:26:45 web2 kernel:   jiffies              <103107711>
> Jan  7 13:26:45 web2 kernel:   next_to_watch.status <0>
> Jan  7 13:26:47 web2 kernel: ------------[ cut here ]------------
> Jan  7 13:26:47 web2 kernel: WARNING: at net/sched/sch_generic.c:226
> dev_watchdog+0x206/0x220()
> Jan  7 13:26:47 web2 kernel: NETDEV WATCHDOG: eth1 (e1000): transmit timed
> out
> Jan  7 13:26:47 web2 kernel: Modules linked in: nfs lockd nfs_acl sunrpc
> dm_mirror dm_region_hash dm_log dm_multipath dm_mod serio_raw e1000
> pata_jmicron pcspkr
> Jan  7 13:26:47 web2 kernel: Pid: 0, comm: swapper Not tainted 2.6.28 #1
> Jan  7 13:26:47 web2 kernel: Call Trace:
> Jan  7 13:26:47 web2 kernel:  <IRQ>  [<ffffffff802361fc>]
> warn_slowpath+0x10c/0x150
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8022f4c1>]
> enqueue_task_fair+0xf1/0x110
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8022c217>] source_load+0x37/0x70
> Jan  7 13:26:47 web2 kernel:  [<ffffffff803c9a6a>] __next_cpu+0x1a/0x30
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8022d99c>]
> find_busiest_group+0x18c/0x820
> Jan  7 13:26:47 web2 kernel:  [<ffffffff802116c9>] read_tsc+0x9/0x20
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8024fc71>] getnstimeofday+0x41/0xc0
> Jan  7 13:26:47 web2 kernel:  [<ffffffff803cf20e>] strlcpy+0x4e/0x80
> Jan  7 13:26:47 web2 kernel:  [<ffffffff80532cd6>] dev_watchdog+0x206/0x220
> Jan  7 13:26:47 web2 kernel:  [<ffffffff802116c9>] read_tsc+0x9/0x20
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8024fc71>] getnstimeofday+0x41/0xc0
> Jan  7 13:26:47 web2 kernel:  [<ffffffff80532ad0>] dev_watchdog+0x0/0x220
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8023fadf>]
> run_timer_softirq+0x15f/0x1c0
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8021b165>]
> lapic_next_event+0x15/0x20
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8023b40c>] __do_softirq+0x9c/0x170
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8020c87c>] call_softirq+0x1c/0x30
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8020d975>] do_softirq+0x35/0x70
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8021bb05>]
> smp_apic_timer_interrupt+0x85/0xd0
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8020c2cb>]
> apic_timer_interrupt+0x6b/0x70
> Jan  7 13:26:47 web2 kernel:  <EOI>  [<ffffffff80212511>]
> mwait_idle+0x41/0x50
> Jan  7 13:26:47 web2 kernel:  [<ffffffff8020a2da>] cpu_idle+0x3a/0x70
> Jan  7 13:26:47 web2 kernel: ---[ end trace 06fe492fa8302a12 ]---
> Jan  7 13:26:50 web2 kernel: e1000: eth1: e1000_watchdog: NIC Link is Up
> 1000 Mbps Full Duplex, Flow Control: RX/TX
>
>
>
> 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM
> Controller (rev 02)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8276
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information
>
> 00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Express
> Integrated Graphics Controller (rev 02) (prog-if 00 [VGA])
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8276
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 11
>         Region 0: Memory at fe800000 (32-bit, non-prefetchable) [size=512K]
>         Region 1: I/O ports at cc00 [size=8]
>         Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
>         Region 3: Memory at fe700000 (32-bit, non-prefetchable) [size=1M]
>         Capabilities: [90] Message Signalled Interrupts: 64bit- Queue=0/0
> Enable-
>                 Address: 00000000  Data: 0000
>         Capabilities: [d0] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 00:02.1 Display controller: Intel Corporation 82G33/G31 Express Integrated
> Graphics Controller (rev 02)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8276
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Region 0: Memory at fe880000 (32-bit, non-prefetchable) [size=512K]
>         Capabilities: [d0] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port
> 1 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: fff00000-000fffff
>         Prefetchable memory behind bridge: 00000000fdf00000-00000000fdf00000
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
> ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1, Port 1
>                 Link: Latency L0s <1us, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x0
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+
> Surpise+
>                 Slot: Number 0, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0
> Enable+
>                 Address: fee0f00c  Data: 4159
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port
> 5 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: fea00000-feafffff
>         Prefetchable memory behind bridge: 00000000fff00000-0000000000000000
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
> ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 5
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+
> Surpise+
>                 Slot: Number 0, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0
> Enable+
>                 Address: fee0f00c  Data: 4161
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port
> 6 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: fe900000-fe9fffff
>         Prefetchable memory behind bridge: 00000000fff00000-0000000000000000
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
> ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 6
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+
> Surpise+
>                 Slot: Number 0, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0
> Enable+
>                 Address: fee0f00c  Data: 4169
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog-if 01
> [Subtractive decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: feb00000-febfffff
>         Prefetchable memory behind bridge: 00000000f0000000-00000000f0000000
>         Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [50] #0d [0000]
>
> 00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface
> Controller (rev 02)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8277
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information
>
> 00:1f.2 IDE interface: Intel Corporation 82801IB (ICH9) 2 port SATA IDE
> Controller (rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8277
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 22
>         Region 0: I/O ports at b880 [size=8]
>         Region 1: I/O ports at b800 [size=4]
>         Region 2: I/O ports at b480 [size=8]
>         Region 3: I/O ports at b400 [size=4]
>         Region 4: I/O ports at b080 [size=16]
>         Region 5: I/O ports at b000 [size=16]
>         Capabilities: [70] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [b0] Vendor Specific Information
>
> 00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev
> 02)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8277
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin C routed to IRQ 5
>         Region 0: Memory at fe6fbc00 (64-bit, non-prefetchable) [size=256]
>         Region 4: I/O ports at 0400 [size=32]
>
> 00:1f.5 IDE interface: Intel Corporation 82801I (ICH9 Family) 2 port SATA
> IDE Controller (rev 02) (prog-if 85 [Master SecO PriO])
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8277
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 22
>         Region 0: I/O ports at c880 [size=8]
>         Region 1: I/O ports at c800 [size=4]
>         Region 2: I/O ports at c480 [size=8]
>         Region 3: I/O ports at c400 [size=4]
>         Region 4: I/O ports at c080 [size=16]
>         Region 5: I/O ports at c000 [size=16]
>         Capabilities: [70] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [b0] Vendor Specific Information
>
> 01:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit Ethernet
> Adapter (rev b0)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8226
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 27
>         Region 0: Memory at fe9c0000 (64-bit, non-prefetchable) [size=256K]
>         Expansion ROM at fe9a0000 [disabled] [size=128K]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/0
> Enable+
>                 Address: 00000000fee0200c  Data: 4179
>         Capabilities: [58] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
> ExtTag-
>                 Device: Latency L0s <4us, L1 unlimited
>                 Device: AtnBtn+ AtnInd+ PwrInd+
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
>                 Link: Latency L0s unlimited, L1 unlimited
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>         Capabilities: [100] Advanced Error Reporting
>
> 02:00.0 SATA controller: JMicron Technologies, Inc. JMicron 20360/20363 AHCI
> Controller (rev 03) (prog-if 01 [AHCI 1.0])
>         Subsystem: ASUSTeK Computer Inc. Unknown device 824f
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 16
>         Region 5: Memory at feafe000 (32-bit, non-prefetchable) [size=8K]
>         Expansion ROM at feae0000 [disabled] [size=64K]
>         Capabilities: [68] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Express Legacy Endpoint IRQ 1
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
> ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 1
>                 Link: Latency L0s <1us, L1 <16us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>
> 02:00.1 IDE interface: JMicron Technologies, Inc. JMicron 20360/20363 AHCI
> Controller (rev 03) (prog-if 85 [Master SecO PriO])
>         Subsystem: ASUSTeK Computer Inc. Unknown device 824f
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 17
>         Region 0: I/O ports at dc00 [size=8]
>         Region 1: I/O ports at d880 [size=4]
>         Region 2: I/O ports at d800 [size=8]
>         Region 3: I/O ports at d480 [size=4]
>         Region 4: I/O ports at d400 [size=16]
>         Capabilities: [68] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 04:01.0 Ethernet controller: Intel Corporation 82541PI Gigabit Ethernet
> Controller (rev 05)
>         Subsystem: Intel Corporation PRO/1000 GT Desktop Adapter
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (63750ns min), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 17
>         Region 0: Memory at febe0000 (32-bit, non-prefetchable) [size=128K]
>         Region 1: Memory at febc0000 (32-bit, non-prefetchable) [size=128K]
>         Region 2: I/O ports at ec00 [size=64]
>         Expansion ROM at f0000000 [disabled] [size=128K]
>         Capabilities: [dc] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [e4] PCI-X non-bridge device
>                 Command: DPERE- ERO+ RBC=512 OST=1
>                 Status: Dev=00:00.0 64bit- 133MHz- SCD- USC- DC=simple
> DMMRBC=2048 DMOST=1 DMCRS=8 RSCEM- 266MHz- 533MHz-
>
>
> Doug Bazarnic
>
> --

Adding netdev and e1000-devel ml's.


-- 
Cheers,
Jeff
