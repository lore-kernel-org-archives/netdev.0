From: Andre Tomt <andre@tomt.net>
Subject: e1000e 82574L related regression in 3.5, 3.6-rc (bisected)
Date: Sun, 26 Aug 2012 04:49:01 +0200
Message-ID: <50398E9D.3020607@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from catastrophix.ugh.no ([178.79.162.34]:33431 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab2HZCtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 22:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.5 broke the 82574L port on Intel DQ77KB motherboard.

Under a lot of loads the port will lock up for 1-2 seconds every few 
seconds. Bidirectional 100Mbps TCP w/ gigabit link speed seems to 
trigger it most often, especially when its traffic beeing forwarded. 
Also it does not happen when port is saturated.

On 3.5 it seems TSO/GRO made it less likely to happen, but on 3.6-rc it 
happens always and nearly instantly with the 100Mbps load.

The 82579LM port also driven by the same e1000e driver does not show 
this behaviour.

Bisection turned up this commit as the one triggering this behaviour:

> 2cb7a9cc008c25dc03314de563c00c107b3e5432 is the first bad commit
> commit 2cb7a9cc008c25dc03314de563c00c107b3e5432
> Author: Matthew Vick <matthew.vick@intel.com>
> Date:   Fri Mar 16 09:02:59 2012 +0000
>
>     e1000e: Enable DMA Burst Mode on 82574 by default.
>
>     Performance testing has shown that enabling DMA burst on 82574
>     improves performance on small packets, so enable it by default.
>
>     Signed-off-by: Matthew Vick <matthew.vick@intel.com>
>     Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> :040000 040000 c894e2494ef15bd75a403df542514e4575083e7a bb013897d6fd6efc40e89f8e5d6c05f735aac585 M	drivers

ifconfig/ethtool reports no dropped/errors. Packets just seem to get 
held for a bit.

> root@grr:~# lspci -vvvxxx
> 00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family DRAM Controller (rev 09)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
> 	Kernel driver in use: agpgart-intel
> 	Kernel modules: intel-agp
> 00: 86 80 00 01 06 00 90 20 09 00 00 06 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 90 d1 fe 00 00 00 00 01 00 d1 fe 00 00 00 00
> 50: 21 02 00 00 11 00 00 00 00 00 00 00 01 00 00 d7
> 60: 05 00 00 f8 00 00 00 00 01 80 d1 fe 00 00 00 00
> 70: 00 00 00 fe 01 00 00 00 00 0c 00 fe 7f 00 00 00
> 80: 10 11 11 00 00 00 11 00 1a 00 00 00 00 00 00 00
> 90: 01 00 00 fe 01 00 00 00 01 00 50 1e 02 00 00 00
> a0: 01 00 00 00 02 00 00 00 01 00 60 1e 02 00 00 00
> b0: 01 00 a0 d7 01 00 80 d7 01 00 00 d7 01 00 a0 df
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 09 00 0c 01 96 80 80 e2 90 00 00 14 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 b8 0f 06 00 00 00 00 00
>
> 00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09) (prog-if 00 [VGA controller])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 46
> 	Region 0: Memory at f7800000 (64-bit, non-prefetchable) [size=4M]
> 	Region 2: Memory at e0000000 (64-bit, prefetchable) [size=256M]
> 	Region 4: I/O ports at f000 [size=64]
> 	Expansion ROM at <unassigned> [disabled]
> 	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
> 		Address: fee0100c  Data: 4191
> 	Capabilities: [d0] Power Management version 2
> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [a4] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: i915
> 	Kernel modules: i915
> 00: 86 80 02 01 07 04 90 00 09 00 00 03 00 00 00 00
> 10: 04 00 80 f7 00 00 00 00 0c 00 00 e0 00 00 00 00
> 20: 01 f0 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 90 00 00 00 00 00 00 00 0b 01 00 00
> 40: 09 00 0c 01 96 80 80 e2 90 00 00 14 00 00 00 00
> 50: 21 02 00 00 11 00 00 00 00 00 00 00 01 00 a0 d7
> 60: 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 05 d0 01 00 0c 10 e0 fe 91 41 00 00 00 00 00 00
> a0: 00 00 00 00 13 00 06 03 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 01 a4 22 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 01 00 00 00 00 80 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 06 00 18 50 3d d6
>
> 00:14.0 USB controller: Intel Corporation Panther Point USB xHCI Host Controller (rev 04) (prog-if 30 [XHCI])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 45
> 	Region 0: Memory at f7f20000 (64-bit, non-prefetchable) [size=64K]
> 	Capabilities: [70] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [80] MSI: Enable+ Count=1/8 Maskable- 64bit+
> 		Address: 00000000fee0f00c  Data: 4189
> 	Kernel driver in use: xhci_hcd
> 	Kernel modules: xhci-hcd
> 00: 86 80 31 1e 06 04 90 02 04 30 03 0c 00 00 00 00
> 10: 04 00 f2 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 0b 01 00 00
> 40: fd 07 0e 80 39 c2 03 80 00 00 00 00 00 00 00 00
> 50: 17 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 30 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 80 c2 c1 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 00 87 00 0c f0 e0 fe 00 00 00 00 89 41 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 8f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 03 0c 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 0f 00 00 00 0f 00 00 00 0f 00 00 00 0f 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:16.0 Communication controller: Intel Corporation Panther Point MEI Controller #1 (rev 04)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at f7f3c000 (64-bit, non-prefetchable) [size=16]
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 00: 86 80 3a 1e 06 00 10 00 04 00 80 07 00 00 80 00
> 10: 04 c0 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00
> 40: 45 02 00 1e 20 00 01 80 06 01 00 6a e0 1f 00 10
> 50: 01 8c 03 c8 08 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 05 00 80 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 c0
> c0: 68 2d 2a 35 09 10 2d 24 d5 bf 74 0b e4 b8 67 08
> d0: 5a 0b 04 73 e6 4e 0c 52 d3 17 3a 9e 70 ad 84 d7
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>
> 00:16.3 Serial controller: Intel Corporation Panther Point KT Controller (rev 04) (prog-if 02 [16550])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 19
> 	Region 0: I/O ports at f0e0 [size=8]
> 	Region 1: Memory at f7f3a000 (32-bit, non-prefetchable) [size=4K]
> 	Capabilities: [c8] Power Management version 3
> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 	Kernel driver in use: serial
> 00: 86 80 3d 1e 07 00 b0 00 04 02 00 07 00 00 00 00
> 10: e1 f0 00 00 00 a0 f3 f7 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 c8 00 00 00 00 00 00 00 0a 02 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 01 d0 23 00 08 00 00 00
> d0: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>
> 00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (rev 04)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 40
> 	Region 0: Memory at f7f00000 (32-bit, non-prefetchable) [size=128K]
> 	Region 1: Memory at f7f39000 (32-bit, non-prefetchable) [size=4K]
> 	Region 2: I/O ports at f080 [size=32]
> 	Capabilities: [c8] Power Management version 2
> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 		Address: 00000000fee0800c  Data: 41a1
> 	Capabilities: [e0] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: e1000e
> 	Kernel modules: e1000e
> 00: 86 80 02 15 07 04 10 00 04 00 00 02 00 00 00 00
> 10: 00 00 f0 f7 00 90 f3 f7 81 f0 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 c8 00 00 00 00 00 00 00 05 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 01 d0 22 c8 00 20 00 07
> d0: 05 e0 81 00 0c 80 e0 fe 00 00 00 00 a1 41 00 00
> e0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>
> 00:1a.0 USB controller: Intel Corporation Panther Point USB Enhanced Host Controller #2 (rev 04) (prog-if 20 [EHCI])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 16
> 	Region 0: Memory at f7f38000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Debug port: BAR=1 offset=00a0
> 	Capabilities: [98] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: ehci_hcd
> 	Kernel modules: ehci-hcd
> 00: 86 80 2d 1e 06 00 90 02 04 20 03 0c 00 00 00 00
> 10: 00 80 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 58 c2 c9 00 00 00 00 0a 98 a0 20 00 00 00 00
> 60: 20 20 ff 07 00 00 00 00 01 00 00 01 00 00 00 40
> 70: 00 00 df 3f 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 80 00 11 88 0c 93 30 0d 00 24 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 13 00 06 03 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 aa ff 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 6f 08 82 30 08 00 00 80 88 19 03 01
> f0: 00 00 00 00 88 85 80 00 87 0f 04 08 08 17 5b 20
>
> 00:1b.0 Audio device: Intel Corporation Panther Point High Definition Audio Controller (rev 04)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 3
> 	Region 0: Memory at f7f30000 (64-bit, non-prefetchable) [size=16K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [60] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE- FLReset+
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
> 	Capabilities: [100 v1] Virtual Channel
> 		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
> 		Arb:	Fixed- WRR32- WRR64- WRR128-
> 		Ctrl:	ArbSelect=Fixed
> 		Status:	InProgress-
> 		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> 			Status:	NegoPending- InProgress-
> 		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=1 ArbSelect=Fixed TC/VC=22
> 			Status:	NegoPending- InProgress-
> 	Capabilities: [130 v1] Root Complex Link
> 		Desc:	PortNumber=0f ComponentID=00 EltType=Config
> 		Link0:	Desc:	TargetPort=00 TargetComponent=00 AssocRCRB- LinkType=MemMapped LinkValid+
> 			Addr:	00000000fed1c000
> 00: 86 80 20 1e 06 00 10 00 04 00 03 04 10 00 00 00
> 10: 04 00 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00
> 40: 01 00 00 05 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 60 42 c8 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 05 70 80 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 10 00 91 00 00 00 00 10 00 08 10 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 04 02 01 00 24 00 40 00 0c a3 82 10 00 33 02
> d0: 00 0c a3 02 10 00 33 02 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1c.0 PCI bridge: Intel Corporation Panther Point PCI Express Root Port 1 (rev c4) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: f7e00000-f7efffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #1, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
> 			ClockPM- Surprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB
> 	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [90] Subsystem: Intel Corporation Device 2036
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: pcieport
> 	Kernel modules: shpchp
> 00: 86 80 10 1e 07 00 10 00 c4 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 01 01 00 f0 00 00 00
> 20: e0 f7 e0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 10 00
> 40: 10 80 42 01 00 80 00 00 00 00 10 00 12 3c 12 01
> 50: 40 00 11 70 00 b2 04 00 00 00 40 00 00 00 00 00
> 60: 00 00 00 00 16 00 00 00 00 00 00 00 00 00 00 00
> 70: 02 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 0d a0 00 00 86 80 36 20 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 01 02 0b 00 00 00 80 11 81 00 00 00 00
> e0: 00 3f 00 00 00 00 00 00 01 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1c.2 PCI bridge: Intel Corporation Panther Point PCI Express Root Port 3 (rev c4) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: f7d00000-f7dfffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #3, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
> 			ClockPM- Surprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #2, PowerLimit 10.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB
> 	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [90] Subsystem: Intel Corporation Device 2036
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: pcieport
> 	Kernel modules: shpchp
> 00: 86 80 14 1e 07 00 10 00 c4 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 02 02 00 f0 00 00 00
> 20: d0 f7 d0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 03 10 00
> 40: 10 80 42 01 00 80 00 00 00 00 10 00 12 3c 12 03
> 50: 40 00 11 70 00 b2 14 00 00 00 40 00 00 00 00 00
> 60: 00 00 00 00 16 00 00 00 00 00 00 00 00 00 00 00
> 70: 02 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 0d a0 00 00 86 80 36 20 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 01 02 0b 00 00 00 80 11 81 00 00 00 00
> e0: 00 03 00 00 00 00 00 00 01 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1c.6 PCI bridge: Intel Corporation Panther Point PCI Express Root Port 7 (rev c4) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> 	I/O behind bridge: 0000e000-0000efff
> 	Memory behind bridge: f7c00000-f7cfffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #7, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <16us
> 			ClockPM- Surprise- LLActRep+ BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #6, PowerLimit 10.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB
> 	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [90] Subsystem: Intel Corporation Device 2036
> 	Capabilities: [a0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: pcieport
> 	Kernel modules: shpchp
> 00: 86 80 1c 1e 07 00 10 00 c4 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 03 03 00 e0 e0 00 00
> 20: c0 f7 c0 f7 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 03 10 00
> 40: 10 80 42 01 00 80 00 00 00 00 10 00 12 3c 12 07
> 50: 40 00 11 70 00 b2 34 00 00 00 40 00 00 00 00 00
> 60: 00 00 00 00 16 00 00 00 00 00 00 00 00 00 00 00
> 70: 02 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 90 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 0d a0 00 00 86 80 36 20 00 00 00 00 00 00 00 00
> a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 01 02 0b 00 00 00 80 11 81 00 00 00 00
> e0: 00 03 00 00 00 00 00 00 01 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1d.0 USB controller: Intel Corporation Panther Point USB Enhanced Host Controller #1 (rev 04) (prog-if 20 [EHCI])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 23
> 	Region 0: Memory at f7f37000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Debug port: BAR=1 offset=00a0
> 	Capabilities: [98] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: ehci_hcd
> 	Kernel modules: ehci-hcd
> 00: 86 80 26 1e 06 00 90 02 04 20 03 0c 00 00 00 00
> 10: 00 70 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 0a 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 58 c2 c9 00 00 00 00 0a 98 a0 20 00 00 00 00
> 60: 20 20 ff 07 00 00 00 00 01 00 00 01 00 00 08 40
> 70: 00 00 df 3f 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 80 00 11 88 0c 93 30 0d 00 24 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 13 00 06 03 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 aa ff 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 02 d0 80 02 00 80 08 00 90 84 78 61
> f0: 00 00 00 00 88 85 80 00 87 0f 04 08 08 17 5b 20
>
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a4) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: fff00000-000fffff
> 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Subsystem: Intel Corporation Device 2036
> 00: 86 80 4e 24 07 00 10 00 a4 01 04 06 00 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 04 04 00 f0 00 80 22
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 10 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 12 00 10
> 50: 0d 00 00 00 86 80 36 20 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1f.0 ISA bridge: Intel Corporation Panther Point LPC Controller (rev 04)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
> 	Kernel modules: iTCO_wdt
> 00: 86 80 47 1e 07 00 10 02 04 00 01 06 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 40: 01 04 00 00 80 00 00 00 01 05 00 00 10 00 00 00
> 50: f8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 8b 80 8b 8a 90 00 00 00 85 80 83 8a f8 f0 00 00
> 70: 78 f0 78 f0 78 f0 78 f0 78 f0 78 f0 78 f0 78 f0
> 80: 00 00 01 14 01 0a fc 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00
> a0: 18 0e 80 00 58 39 06 00 00 47 00 00 00 00 00 80
> b0: 00 00 00 00 00 00 00 00 80 0a 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 33 22 11 00 67 45 00 00 cf ff 00 00 2a 00 00 00
> e0: 09 00 0c 10 00 00 00 00 b1 02 e4 04 00 00 00 00
> f0: 01 c0 d1 fe 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1f.2 SATA controller: Intel Corporation Panther Point 6 port SATA Controller [AHCI mode] (rev 04) (prog-if 01 [AHCI 1.0])
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 41
> 	Region 0: I/O ports at f0d0 [size=8]
> 	Region 1: I/O ports at f0c0 [size=4]
> 	Region 2: I/O ports at f0b0 [size=8]
> 	Region 3: I/O ports at f0a0 [size=4]
> 	Region 4: I/O ports at f060 [size=32]
> 	Region 5: Memory at f7f36000 (32-bit, non-prefetchable) [size=2K]
> 	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> 		Address: fee0200c  Data: 4169
> 	Capabilities: [70] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
> 	Capabilities: [b0] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: ahci
> 	Kernel modules: ahci
> 00: 86 80 02 1e 07 04 b0 02 04 01 06 01 00 00 00 00
> 10: d1 f0 00 00 c1 f0 00 00 b1 f0 00 00 a1 f0 00 00
> 20: 61 f0 00 00 00 60 f3 f7 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 02 00 00
> 40: 00 80 00 80 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 01 a8 03 40 08 00 00 00 00 00 00 00 00 00 00 00
> 80: 05 70 01 00 0c 20 e0 fe 69 41 00 00 00 00 00 00
> 90: 60 3e 01 81 83 01 00 3e 08 42 5c 01 00 00 00 00
> a0: e0 00 00 00 39 00 00 00 12 b0 10 00 48 00 00 00
> b0: 13 00 06 03 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 00:1f.3 SMBus: Intel Corporation Panther Point SMBus Controller (rev 04)
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin C routed to IRQ 11
> 	Region 0: Memory at f7f35000 (64-bit, non-prefetchable) [size=256]
> 	Region 4: I/O ports at f040 [size=32]
> 	Kernel modules: i2c-i801
> 00: 86 80 22 1e 03 00 80 02 04 00 05 0c 00 00 00 00
> 10: 04 50 f3 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 41 f0 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 03 00 00
> 40: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 03 04 04 00 00 00 08 08 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 87 0f 04 08 00 00 00 00
>
> 01:00.0 Network controller: Atheros Communications Inc. AR9300 Wireless LAN adaptor (rev 01)
> 	Subsystem: Atheros Communications Inc. Device 3114
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 16
> 	Region 0: Memory at f7e00000 (64-bit, non-prefetchable) [size=128K]
> 	Expansion ROM at f7e20000 [disabled] [size=64K]
> 	Capabilities: [40] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
> 		Address: 0000000000000000  Data: 0000
> 		Masking: 00000000  Pending: 00000000
> 	Capabilities: [70] Express (v2) Endpoint, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <2us, L1 <64us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
> 	Capabilities: [140 v1] Virtual Channel
> 		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
> 		Arb:	Fixed- WRR32- WRR64- WRR128-
> 		Ctrl:	ArbSelect=Fixed
> 		Status:	InProgress-
> 		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> 			Status:	NegoPending- InProgress-
> 	Capabilities: [300 v1] Device Serial Number 00-00-00-00-00-00-00-00
> 	Kernel driver in use: ath9k
> 	Kernel modules: ath9k
> 00: 8c 16 30 00 07 00 10 00 01 00 80 02 10 00 00 00
> 10: 04 00 e0 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 8c 16 14 31
> 30: 00 00 e2 f7 40 00 00 00 00 00 00 00 0b 01 00 00
> 40: 01 50 c3 5b 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 05 70 84 01 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 10 00 02 00 00 87 90 05 00 20 00 00 11 5c 03 00
> 80: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>
> 02:00.0 Network controller: Atheros Communications Inc. AR9285 Wireless Network Adapter (PCI-Express) (rev 01)
> 	Subsystem: AzureWave Device 1d89
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at f7d00000 (64-bit, non-prefetchable) [size=64K]
> 	Capabilities: [40] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [60] Express (v2) Legacy Endpoint, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> 	Capabilities: [140 v1] Virtual Channel
> 		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
> 		Arb:	Fixed- WRR32- WRR64- WRR128-
> 		Ctrl:	ArbSelect=Fixed
> 		Status:	InProgress-
> 		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> 			Status:	NegoPending- InProgress-
> 	Capabilities: [160 v1] Device Serial Number 00-15-17-ff-ff-24-14-12
> 	Capabilities: [170 v1] Power Budgeting <?>
> 	Kernel driver in use: ath9k
> 	Kernel modules: ath9k
> 00: 8c 16 2b 00 07 00 10 00 01 00 80 02 10 00 00 00
> 10: 04 00 d0 f7 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 3b 1a 89 1d
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
> 40: 01 50 c3 db 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 05 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 10 00 12 00 c0 8c 90 05 00 20 10 00 11 3c 03 00
> 70: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>
> 03:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
> 	Subsystem: Intel Corporation Device 2036
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at f7c00000 (32-bit, non-prefetchable) [size=128K]
> 	Region 2: I/O ports at e000 [size=32]
> 	Region 3: Memory at f7c20000 (32-bit, non-prefetchable) [size=16K]
> 	Capabilities: [c8] Power Management version 2
> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 	Capabilities: [e0] Express (v1) Endpoint, MSI 00
> 		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
> 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend+
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 	Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
> 		Vector table: BAR=3 offset=00000000
> 		PBA: BAR=3 offset=00002000
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP+ BadDLLP- Rollover- Timeout- NonFatalErr-
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
> 	Capabilities: [140 v1] Device Serial Number 4c-72-b9-ff-ff-21-13-5b
> 	Kernel driver in use: e1000e
> 	Kernel modules: e1000e
> 00: 86 80 d3 10 07 04 10 00 00 00 00 02 10 00 00 00
> 10: 00 00 c0 f7 00 00 00 00 01 e0 00 00 00 00 c2 f7
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 36 20
> 30: 00 00 00 00 c8 00 00 00 00 00 00 00 0b 01 00 00
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 11 00 04 80 03 00 00 00 03 20 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 01 d0 22 c8 00 20 00 0f
> d0: 05 e0 80 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 10 a0 01 00 c1 8c 00 00 0f 28 10 00 11 1c 03 00
> f0: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
 >
> root@grr:~# dmidecode
> # dmidecode 2.11
> SMBIOS 2.7 present.
> 75 structures occupying 3185 bytes.
> Table at 0x000EC470.
>
> Handle 0x0000, DMI type 0, 24 bytes
> BIOS Information
> 	Vendor: Intel Corp.
> 	Version: KBQ7710H.86A.0042.2012.0726.2015
> 	Release Date: 07/26/2012
> 	Address: 0xF0000
> 	Runtime Size: 64 kB
> 	ROM Size: 12288 kB
> 	Characteristics:
> 		PCI is supported
> 		BIOS is upgradeable
> 		BIOS shadowing is allowed
> 		Boot from CD is supported
> 		Selectable boot is supported
> 		EDD is supported
> 		5.25"/1.2 MB floppy services are supported (int 13h)
> 		3.5"/720 kB floppy services are supported (int 13h)
> 		3.5"/2.88 MB floppy services are supported (int 13h)
> 		Print screen service is supported (int 5h)
> 		8042 keyboard services are supported (int 9h)
> 		Serial services are supported (int 14h)
> 		Printer services are supported (int 17h)
> 		ACPI is supported
> 		USB legacy is supported
> 		BIOS boot specification is supported
> 		Targeted content distribution is supported
> 		UEFI is supported
> 	BIOS Revision: 4.6
>
> Handle 0x0001, DMI type 1, 27 bytes
> System Information
> 	Manufacturer:
> 	Product Name:
> 	Version:
> 	Serial Number:
> 	UUID: FFEA2957-DEB0-E111-896B-505054503030
> 	Wake-up Type: Power Switch
> 	SKU Number: To be filled by O.E.M.
> 	Family: To be filled by O.E.M.
>
> Handle 0x0002, DMI type 2, 15 bytes
> Base Board Information
> 	Manufacturer: Intel Corporation
> 	Product Name: DQ77KB
> 	Version: AAG40294-401
> 	Serial Number: BTKB22301AS1
> 	Asset Tag: To be filled by O.E.M.
> 	Features:
> 		Board is a hosting board
> 		Board is replaceable
> 	Location In Chassis: To be filled by O.E.M.
> 	Chassis Handle: 0x0003
> 	Type: Motherboard
> 	Contained Object Handles: 0
>
> Handle 0x0003, DMI type 3, 22 bytes
> Chassis Information
> 	Manufacturer:
> 	Type: Desktop
> 	Lock: Not Present
> 	Version:
> 	Serial Number:
> 	Asset Tag:
> 	Boot-up State: Safe
> 	Power Supply State: Safe
> 	Thermal State: Safe
> 	Security Status: None
> 	OEM Information: 0x00000000
> 	Height: Unspecified
> 	Number Of Power Cords: 1
> 	Contained Elements: 0
> 	SKU Number: To be filled by O.E.M.
>
> Handle 0x0004, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J1A1
> 	Internal Connector Type: None
> 	External Reference Designator: PS2Mouse
> 	External Connector Type: PS/2
> 	Port Type: Mouse Port
>
> Handle 0x0005, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J1A1
> 	Internal Connector Type: None
> 	External Reference Designator: Keyboard
> 	External Connector Type: PS/2
> 	Port Type: Keyboard Port
>
> Handle 0x0006, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2A1
> 	Internal Connector Type: None
> 	External Reference Designator: TV Out
> 	External Connector Type: Mini Centronics Type-14
> 	Port Type: Other
>
> Handle 0x0007, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2A2A
> 	Internal Connector Type: None
> 	External Reference Designator: COM A
> 	External Connector Type: DB-9 male
> 	Port Type: Serial Port 16550A Compatible
>
> Handle 0x0008, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2A2B
> 	Internal Connector Type: None
> 	External Reference Designator: Video
> 	External Connector Type: DB-15 female
> 	Port Type: Video Port
>
> Handle 0x0009, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J3A1
> 	Internal Connector Type: None
> 	External Reference Designator: USB1
> 	External Connector Type: Access Bus (USB)
> 	Port Type: USB
>
> Handle 0x000A, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J3A1
> 	Internal Connector Type: None
> 	External Reference Designator: USB2
> 	External Connector Type: Access Bus (USB)
> 	Port Type: USB
>
> Handle 0x000B, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J3A1
> 	Internal Connector Type: None
> 	External Reference Designator: USB3
> 	External Connector Type: Access Bus (USB)
> 	Port Type: USB
>
> Handle 0x000C, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9A1 - TPM HDR
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x000D, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9C1 - PCIE DOCKING CONN
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x000E, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2B3 - CPU FAN
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x000F, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J6C2 - EXT HDMI
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0010, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J3C1 - GMCH FAN
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0011, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J1D1 - ITP
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0012, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9E2 - MDC INTPSR
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0013, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9E4 - MDC INTPSR
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0014, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9E3 - LPC HOT DOCKING
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0015, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9E1 - SCAN MATRIX
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0016, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J9G1 - LPC SIDE BAND
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0017, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J8F1 - UNIFIED
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0018, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J6F1 - LVDS
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x0019, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2F1 - LAI FAN
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x001A, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J2G1 - GFX VID
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x001B, DMI type 8, 9 bytes
> Port Connector Information
> 	Internal Reference Designator: J1G6 - AC JACK
> 	Internal Connector Type: Other
> 	External Reference Designator: Not Specified
> 	External Connector Type: None
> 	Port Type: Other
>
> Handle 0x001C, DMI type 9, 17 bytes
> System Slot Information
> 	Designation: PCIe_X4
> 	Type: x4 PCI Express 2 x4
> 	Current Usage: Available
> 	Length: Short
> 	ID: 0
> 	Characteristics:
> 		3.3 V is provided
> 		Opening is shared
> 		PME signal is supported
> 	Bus Address: 0000:00:01.0
>
> Handle 0x001D, DMI type 9, 17 bytes
> System Slot Information
> 	Designation: PCIe_X1
> 	Type: x1 PCI Express 2 x1
> 	Current Usage: Available
> 	Length: Short
> 	ID: 1
> 	Characteristics:
> 		3.3 V is provided
> 		Opening is shared
> 		PME signal is supported
> 	Bus Address: 0000:00:1c.0
>
> Handle 0x001E, DMI type 9, 17 bytes
> System Slot Information
> 	Designation: PCIe_X1
> 	Type: x1 PCI Express 2 x1
> 	Current Usage: Available
> 	Length: Short
> 	ID: 2
> 	Characteristics:
> 		3.3 V is provided
> 		Opening is shared
> 		PME signal is supported
> 	Bus Address: 0000:00:1c.2
>
> Handle 0x001F, DMI type 10, 12 bytes
> On Board Device 1 Information
> 	Type: Video
> 	Status: Enabled
> 	Description:  Intel(R) HD Graphics Device
> On Board Device 2 Information
> 	Type: Ethernet
> 	Status: Enabled
> 	Description:  Intel(R) 82579LM Gigabit Ethernet Device
> On Board Device 3 Information
> 	Type: Ethernet
> 	Status: Enabled
> 	Description:  Intel(R) 82574L Gigabit Ethernet Device
> On Board Device 4 Information
> 	Type: Sound
> 	Status: Enabled
> 	Description:  Intel(R) High Definition Audio Device
>
> Handle 0x0020, DMI type 11, 5 bytes
> OEM Strings
> 	String 1: To Be Filled By O.E.M.
>
> Handle 0x0021, DMI type 12, 5 bytes
> System Configuration Options
> 	Option 1: To Be Filled By O.E.M.
>
> Handle 0x0022, DMI type 32, 20 bytes
> System Boot Information
> 	Status: No errors detected
>
> Handle 0x0023, DMI type 34, 11 bytes
> Management Device
> 	Description: LM78-1
> 	Type: LM78
> 	Address: 0x00000000
> 	Address Type: I/O Port
>
> Handle 0x0024, DMI type 26, 22 bytes
> Voltage Probe
> 	Description: LM78A
> 	Location: <OUT OF SPEC>
> 	Status: <OUT OF SPEC>
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0025, DMI type 36, 16 bytes
> Management Device Threshold Data
> 	Lower Non-critical Threshold: 1
> 	Upper Non-critical Threshold: 2
> 	Lower Critical Threshold: 3
> 	Upper Critical Threshold: 4
> 	Lower Non-recoverable Threshold: 5
> 	Upper Non-recoverable Threshold: 6
>
> Handle 0x0026, DMI type 35, 11 bytes
> Management Device Component
> 	Description: To Be Filled By O.E.M.
> 	Management Device Handle: 0x0023
> 	Component Handle: 0x0023
> 	Threshold Handle: 0x0024
>
> Handle 0x0027, DMI type 28, 22 bytes
> Temperature Probe
> 	Description: LM78A
> 	Location: <OUT OF SPEC>
> 	Status: <OUT OF SPEC>
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0028, DMI type 36, 16 bytes
> Management Device Threshold Data
> 	Lower Non-critical Threshold: 1
> 	Upper Non-critical Threshold: 2
> 	Lower Critical Threshold: 3
> 	Upper Critical Threshold: 4
> 	Lower Non-recoverable Threshold: 5
> 	Upper Non-recoverable Threshold: 6
>
> Handle 0x0029, DMI type 35, 11 bytes
> Management Device Component
> 	Description: To Be Filled By O.E.M.
> 	Management Device Handle: 0x0023
> 	Component Handle: 0x0026
> 	Threshold Handle: 0x0027
>
> Handle 0x002A, DMI type 27, 15 bytes
> Cooling Device
> 	Temperature Probe Handle: 0x0027
> 	Type: <OUT OF SPEC>
> 	Status: <OUT OF SPEC>
> 	Cooling Unit Group: 1
> 	OEM-specific Information: 0x00000000
> 	Nominal Speed: Unknown Or Non-rotating
> 	Description: Cooling Dev 1
>
> Handle 0x002B, DMI type 36, 16 bytes
> Management Device Threshold Data
> 	Lower Non-critical Threshold: 1
> 	Upper Non-critical Threshold: 2
> 	Lower Critical Threshold: 3
> 	Upper Critical Threshold: 4
> 	Lower Non-recoverable Threshold: 5
> 	Upper Non-recoverable Threshold: 6
>
> Handle 0x002C, DMI type 35, 11 bytes
> Management Device Component
> 	Description: To Be Filled By O.E.M.
> 	Management Device Handle: 0x0023
> 	Component Handle: 0x0029
> 	Threshold Handle: 0x002A
>
> Handle 0x002D, DMI type 27, 15 bytes
> Cooling Device
> 	Temperature Probe Handle: 0x0027
> 	Type: <OUT OF SPEC>
> 	Status: <OUT OF SPEC>
> 	Cooling Unit Group: 1
> 	OEM-specific Information: 0x00000000
> 	Nominal Speed: Unknown Or Non-rotating
> 	Description: Not Specified
>
> Handle 0x002E, DMI type 36, 16 bytes
> Management Device Threshold Data
> 	Lower Non-critical Threshold: 1
> 	Upper Non-critical Threshold: 2
> 	Lower Critical Threshold: 3
> 	Upper Critical Threshold: 4
> 	Lower Non-recoverable Threshold: 5
> 	Upper Non-recoverable Threshold: 6
>
> Handle 0x002F, DMI type 35, 11 bytes
> Management Device Component
> 	Description: To Be Filled By O.E.M.
> 	Management Device Handle: 0x0023
> 	Component Handle: 0x002C
> 	Threshold Handle: 0x002D
>
> Handle 0x0030, DMI type 29, 22 bytes
> Electrical Current Probe
> 	Description: ABC
> 	Location: <OUT OF SPEC>
> 	Status: <OUT OF SPEC>
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0031, DMI type 36, 16 bytes
> Management Device Threshold Data
>
> Handle 0x0032, DMI type 35, 11 bytes
> Management Device Component
> 	Description: To Be Filled By O.E.M.
> 	Management Device Handle: 0x0023
> 	Component Handle: 0x002F
> 	Threshold Handle: 0x002D
>
> Handle 0x0033, DMI type 26, 22 bytes
> Voltage Probe
> 	Description: LM78A
> 	Location: Power Unit
> 	Status: OK
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0034, DMI type 28, 22 bytes
> Temperature Probe
> 	Description: LM78A
> 	Location: Power Unit
> 	Status: OK
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0035, DMI type 27, 15 bytes
> Cooling Device
> 	Temperature Probe Handle: 0x0034
> 	Type: Power Supply Fan
> 	Status: OK
> 	Cooling Unit Group: 1
> 	OEM-specific Information: 0x00000000
> 	Nominal Speed: Unknown Or Non-rotating
> 	Description: Cooling Dev 1
>
> Handle 0x0036, DMI type 29, 22 bytes
> Electrical Current Probe
> 	Description: ABC
> 	Location: Power Unit
> 	Status: OK
> 	Maximum Value: Unknown
> 	Minimum Value: Unknown
> 	Resolution: Unknown
> 	Tolerance: Unknown
> 	Accuracy: Unknown
> 	OEM-specific Information: 0x00000000
> 	Nominal Value: Unknown
>
> Handle 0x0037, DMI type 39, 22 bytes
> System Power Supply
> 	Power Unit Group: 1
> 	Location: To Be Filled By O.E.M.
> 	Name: To Be Filled By O.E.M.
> 	Manufacturer: To Be Filled By O.E.M.
> 	Serial Number: To Be Filled By O.E.M.
> 	Asset Tag: To Be Filled By O.E.M.
> 	Model Part Number: To Be Filled By O.E.M.
> 	Revision: To Be Filled By O.E.M.
> 	Max Power Capacity: Unknown
> 	Status: Present, OK
> 	Type: Switching
> 	Input Voltage Range Switching: Auto-switch
> 	Plugged: Yes
> 	Hot Replaceable: No
> 	Input Voltage Probe Handle: 0x0033
> 	Cooling Device Handle: 0x0035
> 	Input Current Probe Handle: 0x0036
>
> Handle 0x0038, DMI type 41, 11 bytes
> Onboard Device
> 	Reference Designation:  Intel(R) HD Graphics Device
> 	Type: Video
> 	Status: Enabled
> 	Type Instance: 1
> 	Bus Address: 0000:00:02.0
>
> Handle 0x0039, DMI type 41, 11 bytes
> Onboard Device
> 	Reference Designation:  Intel(R) 82579LM Gigabit Ethernet Device
> 	Type: Ethernet
> 	Status: Enabled
> 	Type Instance: 1
> 	Bus Address: 0000:00:19.0
>
> Handle 0x003A, DMI type 41, 11 bytes
> Onboard Device
> 	Reference Designation:  Intel(R) 82574LM Gigabit Ethernet Device
> 	Type: Ethernet
> 	Status: Enabled
> 	Type Instance: 1
> 	Bus Address: 0000:03:00.0
>
> Handle 0x003B, DMI type 41, 11 bytes
> Onboard Device
> 	Reference Designation:  Intel(R) High Definition Audio Device
> 	Type: Sound
> 	Status: Enabled
> 	Type Instance: 1
> 	Bus Address: 0000:00:1b.0
>
> Handle 0x003C, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: CPU Internal L2
> 	Configuration: Enabled, Not Socketed, Level 2
> 	Operational Mode: Write Through
> 	Location: Internal
> 	Installed Size: 512 kB
> 	Maximum Size: 512 kB
> 	Supported SRAM Types:
> 		Unknown
> 	Installed SRAM Type: Unknown
> 	Speed: Unknown
> 	Error Correction Type: Multi-bit ECC
> 	System Type: Unified
> 	Associativity: 8-way Set-associative
>
> Handle 0x003D, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: CPU Internal L1
> 	Configuration: Enabled, Not Socketed, Level 1
> 	Operational Mode: Write Through
> 	Location: Internal
> 	Installed Size: 128 kB
> 	Maximum Size: 128 kB
> 	Supported SRAM Types:
> 		Unknown
> 	Installed SRAM Type: Unknown
> 	Speed: Unknown
> 	Error Correction Type: Parity
> 	System Type: Data
> 	Associativity: 8-way Set-associative
>
> Handle 0x003E, DMI type 7, 19 bytes
> Cache Information
> 	Socket Designation: CPU Internal L3
> 	Configuration: Enabled, Not Socketed, Level 3
> 	Operational Mode: Write Back
> 	Location: Internal
> 	Installed Size: 3072 kB
> 	Maximum Size: 3072 kB
> 	Supported SRAM Types:
> 		Unknown
> 	Installed SRAM Type: Unknown
> 	Speed: Unknown
> 	Error Correction Type: Multi-bit ECC
> 	System Type: Unified
> 	Associativity: 12-way Set-associative
>
> Handle 0x003F, DMI type 16, 23 bytes
> Physical Memory Array
> 	Location: System Board Or Motherboard
> 	Use: System Memory
> 	Error Correction Type: None
> 	Maximum Capacity: 16 GB
> 	Error Information Handle: Not Provided
> 	Number Of Devices: 2
>
> Handle 0x0040, DMI type 4, 42 bytes
> Processor Information
> 	Socket Designation: CPU 1
> 	Type: Central Processor
> 	Family: Core i3
> 	Manufacturer: Intel(R) Corporation
> 	ID: A7 06 02 00 FF FB EB BF
> 	Signature: Type 0, Family 6, Model 42, Stepping 7
> 	Flags:
> 		FPU (Floating-point unit on-chip)
> 		VME (Virtual mode extension)
> 		DE (Debugging extension)
> 		PSE (Page size extension)
> 		TSC (Time stamp counter)
> 		MSR (Model specific registers)
> 		PAE (Physical address extension)
> 		MCE (Machine check exception)
> 		CX8 (CMPXCHG8 instruction supported)
> 		APIC (On-chip APIC hardware supported)
> 		SEP (Fast system call)
> 		MTRR (Memory type range registers)
> 		PGE (Page global enable)
> 		MCA (Machine check architecture)
> 		CMOV (Conditional move instruction supported)
> 		PAT (Page attribute table)
> 		PSE-36 (36-bit page size extension)
> 		CLFSH (CLFLUSH instruction supported)
> 		DS (Debug store)
> 		ACPI (ACPI supported)
> 		MMX (MMX technology supported)
> 		FXSR (FXSAVE and FXSTOR instructions supported)
> 		SSE (Streaming SIMD extensions)
> 		SSE2 (Streaming SIMD extensions 2)
> 		SS (Self-snoop)
> 		HTT (Multi-threading)
> 		TM (Thermal monitor supported)
> 		PBE (Pending break enabled)
> 	Version: Intel(R) Core(TM) i3-2120T CPU @ 2.60GHz
> 	Voltage: 6.6 V
> 	External Clock: 100 MHz
> 	Max Speed: 3800 MHz
> 	Current Speed: 2600 MHz
> 	Status: Populated, Enabled
> 	Upgrade: Socket BGA1155
> 	L1 Cache Handle: 0x003D
> 	L2 Cache Handle: 0x003C
> 	L3 Cache Handle: 0x003E
> 	Serial Number: Not Specified
> 	Asset Tag: Fill By OEM
> 	Part Number: Fill By OEM
> 	Core Count: 2
> 	Core Enabled: 2
> 	Thread Count: 4
> 	Characteristics:
> 		64-bit capable
>
> Handle 0x0041, DMI type 17, 34 bytes
> Memory Device
> 	Array Handle: 0x003F
> 	Error Information Handle: Not Provided
> 	Total Width: 64 bits
> 	Data Width: 64 bits
> 	Size: 4096 MB
> 	Form Factor: SODIMM
> 	Set: None
> 	Locator: SODIMM 1
> 	Bank Locator: CHANNEL A SLOT 0
> 	Type: DDR3
> 	Type Detail: Synchronous
> 	Speed: 1600 MHz
> 	Manufacturer: Kingston
> 	Serial Number: 4F0D0409
> 	Asset Tag: 9876543210
> 	Part Number: KHX1600C9S3/4GX
> 	Rank: 2
> 	Configured Clock Speed: 1600 MHz
>
> Handle 0x0042, DMI type 20, 35 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00000000000
> 	Ending Address: 0x000FFFFFFFF
> 	Range Size: 4 GB
> 	Physical Device Handle: 0x0041
> 	Memory Array Mapped Address Handle: 0x0045
> 	Partition Row Position: Unknown
> 	Interleave Position: 1
> 	Interleaved Data Depth: 1
>
> Handle 0x0043, DMI type 17, 34 bytes
> Memory Device
> 	Array Handle: 0x003F
> 	Error Information Handle: Not Provided
> 	Total Width: 64 bits
> 	Data Width: 64 bits
> 	Size: 4096 MB
> 	Form Factor: SODIMM
> 	Set: None
> 	Locator: SODIMM 2
> 	Bank Locator: CHANNEL B SLOT 0
> 	Type: DDR3
> 	Type Detail: Synchronous
> 	Speed: 1600 MHz
> 	Manufacturer: Kingston
> 	Serial Number: 4F0D6F1A
> 	Asset Tag: 9876543210
> 	Part Number: KHX1600C9S3/4GX
> 	Rank: 2
> 	Configured Clock Speed: 1600 MHz
>
> Handle 0x0044, DMI type 20, 35 bytes
> Memory Device Mapped Address
> 	Starting Address: 0x00100000000
> 	Ending Address: 0x001FFFFFFFF
> 	Range Size: 4 GB
> 	Physical Device Handle: 0x0043
> 	Memory Array Mapped Address Handle: 0x0045
> 	Partition Row Position: Unknown
> 	Interleave Position: 2
> 	Interleaved Data Depth: 1
>
> Handle 0x0045, DMI type 19, 31 bytes
> Memory Array Mapped Address
> 	Starting Address: 0x00000000000
> 	Ending Address: 0x001FFFFFFFF
> 	Range Size: 8 GB
> 	Physical Array Handle: 0x003F
> 	Partition Width: 2
>
> Handle 0x0055, DMI type 129, 8 bytes
> OEM-specific Type
> 	Header and Data:
> 		81 08 55 00 01 01 02 01
> 	Strings:
> 		Intel_ASF
> 		Intel_ASF_001
>
> Handle 0x0056, DMI type 130, 20 bytes
> OEM-specific Type
> 	Header and Data:
> 		82 14 56 00 24 41 4D 54 00 00 00 00 00 A5 2F 02
> 		00 00 00 00
>
> Handle 0x0057, DMI type 131, 64 bytes
> OEM-specific Type
> 	Header and Data:
> 		83 40 57 00 31 00 00 00 08 00 00 00 00 00 3F 00
> 		F8 00 47 1E FF FF FF FF 11 20 00 00 00 00 08 00
> 		DE 05 0D 00 00 00 00 00 C8 00 02 15 00 00 00 00
> 		00 00 00 00 66 00 00 00 76 50 72 6F 00 00 00 00
>
> Handle 0x0058, DMI type 13, 22 bytes
> BIOS Language Information
> 	Language Description Format: Long
> 	Installable Languages: 1
> 		en|US|iso8859-1
> 	Currently Installed Language: en|US|iso8859-1
>
> Handle 0x005C, DMI type 127, 4 bytes
> End Of Table
