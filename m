From: Florian Zwoch <zwoch@backendmedia.com>
Subject: e1000 -> 82540EM on linux 2.6.0-test[45] very slow in one direction
Date: Fri, 19 Sep 2003 12:25:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <bkeli5$8l2$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,
this has been discussed very roughly before. but unfortunately no real 
solution has been brought up so far (or i have not read it yet).

problem in short: the 82540EM intel gigabit adapter became very slow as 
of 2.6.0-test4. maybe earlier versions were als affected aswell, but i 
noticed this behaviour on test4 and later. the 'slowness' of the adapter 
only affects a certain data direction. i performed the following tests 
to show you what is wrong.

dummy data file was 34257856 bytes (34.3MB).
test machines were a pentium4 with the intel adapter, and a pentium2 266 
with a lowcost realtek card (runs linux 2.4).

SCP:
   e1000 -> 8139too	28.6KB/s
   e1000 <- 8139too	4.6MB/s

SMB:
   e1000 -> 8139too	3.0MB/s
   e1000 <- 8139too	3.3MB/s

FTP
   e1000 -> 8139too	54KB/s
   e1000 <- 8139too	9.4MB/s

as you can see reveiving data is no problem at all (maybe another 
protocol can create some problems in this case?). but sending data is 
awesome slow! exception is the samba protocol. why is that? i thought 
that samba may use udp instead of tcp. but iptraf did not show any udp 
packets going around so i guess i was wrong.

the problem gets worse while trying to test things over the internet. 
scp stalls incredibly often on my 256kbit/s upstream. so does ftp and 
irc dcc protocol. irc dcc ends up with sending 0.3KB/s on a megabyte 
sized file.

before people again trying to tell me that some duplex settings could be 
messed up - then tell me why this should happen. when i boot into 2.4 
kernel with that test machine the nic works without problems. so IF 
duplex stuff is the reason for the hickups something must be wrong with 
the duplex detection code in the new driver/kernel?

i tried vanilla 2.6.0-test5, 2.6.0-test5-mm2 and mm3 + 2.6.0-test5-bk4. 
none of these gave any difference regarding network performance.

any suggestions or patches will be appreaciated. thanks!

Florian Zwoch

following some systeminfo:

ethtool -i eth0
   driver: e1000
   version: 5.2.16-k1
   firmware-version: N/A
   bus-info: 0000:02:0e.0

ethtool -d eth0
   MAC Registers
   -------------
   0x00000: CTRL (Device control register)  0x18340249
         Duplex:                            full
         Endian mode (buffers):             little
         Link reset:                        reset
         Set link up:                       1
         Invert Loss-Of-Signal:             no
         Receive flow control:              enabled
         Transmit flow control:             enabled
         VLAN mode:                         disabled
         Auto speed detect:                 disabled
         Speed select:                      1000Mb/s
         Force speed:                       no
         Force duplex:                      no
   0x00008: STATUS (Device status register) 0x0000C343
         Duplex:                            full
         Link up:                           link config
         TBI mode:                          disabled
         Link speed:                        100Mb/s
   0x00100: RCTL (Receive control register) 0x00008002
         Receiver:                          enabled
         Store bad packets:                 disabled
         Unicast promiscuous:               disabled
         Multicast promiscuous:             disabled
         Long packet:                       disabled
         Descriptor minimum threshold size: 1/2
         Broadcast accept mode:             accept
         VLAN filter:                       disabled
         Cononical form indicator:          disabled
         Discard pause frames:              filtered
         Pass MAC control frames:           don't pass
         Receive buffer size:               2048
   0x02808: RDLEN (Receive desc length)     0x00001000
   0x02810: RDH   (Receive desc head)       0x00000005
   0x02818: RDT   (Receive desc tail)       0x00000000
   0x02820: RDTR  (Receive delay timer)     0x00000000
   0x00400: TCTL (Transmit ctrl register)   0x0004010A
         Transmitter:                       enabled
         Pad short packets:                 enabled
         Software XOFF Transmission:        disabled
         Re-transmit on late collision:     disabled
   0x03808: TDLEN (Transmit desc length)    0x00001000
   0x03810: TDH   (Transmit desc head)      0x000000B4
   0x03818: TDT   (Transmit desc tail)      0x000000B4
   0x03820: TIDV  (Transmit delay timer)    0x00000040

pci -vvv
00:00.0 Host bridge: Intel Corp. 82850 850 (Tehama) Chipset Host Bridge 
(MCH) (rev 04)
	Subsystem: Asustek Computer, Inc.: Unknown device 8030
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort+ >SERR- <PERR-
	Latency: 0
	Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
	Capabilities: [a0] AGP version 2.0
		Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- 
FW+ AGP3- Rate=x1,x2,x4
		Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP+ GART64- 64bit- FW+ Rate=x4

00:01.0 PCI bridge: Intel Corp. 82850 850 (Tehama) Chipset AGP Bridge 
(rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	I/O behind bridge: 0000e000-0000dfff
	Memory behind bridge: ea000000-eb5fffff
	Prefetchable memory behind bridge: eb700000-efffffff
	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev 04) 
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
	I/O behind bridge: 0000b000-0000dfff
	Memory behind bridge: e7800000-e9ffffff
	Prefetchable memory behind bridge: eb600000-eb6fffff
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801BA ISA Bridge (LPC) (rev 04)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:1f.1 IDE interface: Intel Corp. 82801BA IDE U100 (rev 04) (prog-if 80 
[Master])
	Subsystem: Asustek Computer, Inc.: Unknown device 8028
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 4: I/O ports at a800 [size=16]

00:1f.2 USB Controller: Intel Corp. 82801BA/BAM USB (Hub #1) (rev 04) 
(prog-if 00 [UHCI])
	Subsystem: Asustek Computer, Inc.: Unknown device 8028
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 4: I/O ports at a400 [size=32]

00:1f.3 SMBus: Intel Corp. 82801BA/BAM SMBus (rev 04)
	Subsystem: Asustek Computer, Inc.: Unknown device 8028
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 17
	Region 4: I/O ports at e800 [size=16]

00:1f.4 USB Controller: Intel Corp. 82801BA/BAM USB (Hub #2) (rev 04) 
(prog-if 00 [UHCI])
	Subsystem: Asustek Computer, Inc.: Unknown device 8028
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin C routed to IRQ 23
	Region 4: I/O ports at a000 [size=32]

01:00.0 VGA compatible controller: nVidia Corporation NV25 [GeForce4 Ti 
4200] (rev a3) (prog-if 00 [VGA])
	Subsystem: Asustek Computer, Inc.: Unknown device 803f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 248 (1250ns min, 250ns max)
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at ea000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: Memory at ec000000 (32-bit, prefetchable) [size=64M]
	Region 2: Memory at eb800000 (32-bit, prefetchable) [size=512K]
	Expansion ROM at eb7e0000 [disabled] [size=128K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [44] AGP version 2.0
		Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- 
FW+ AGP3- Rate=x1,x2,x4
		Command: RQ=32 ArqSz=0 Cal=0 SBA+ AGP+ GART64- 64bit- FW+ Rate=x4

02:03.0 Multimedia audio controller: C-Media Electronics Inc CM8738 (rev 10)
	Subsystem: Asustek Computer, Inc. CMI8738 6ch-MX
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (500ns min, 6000ns max)
	Interrupt: pin A routed to IRQ 21
	Region 0: I/O ports at d800 [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:04.0 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: Unknown device 807d:0035
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (250ns min, 10500ns max), cache line size 08
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at e9800000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:04.1 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: Unknown device 807d:0035
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (250ns min, 10500ns max), cache line size 08
	Interrupt: pin B routed to IRQ 255
	Region 0: Memory at e9000000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:04.2 USB Controller: NEC Corporation USB 2.0 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Unknown device 807d:1043
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (4000ns min, 8500ns max), cache line size 20
	Interrupt: pin C routed to IRQ 23
	Region 0: Memory at e8800000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:0c.0 Multimedia audio controller: IC Ensemble Inc ICE1724 [Envy24HT] 
(rev 01)
	Subsystem: TERRATEC Electronic GmbH: Unknown device 1147
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Interrupt: pin A routed to IRQ 20
	Region 0: I/O ports at d400 [size=32]
	Region 1: I/O ports at d000 [size=128]
	Capabilities: [80] Power Management version 1
		Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:0e.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet 
Controller (rev 02)
	Subsystem: Intel Corp. PRO/1000 MT Desktop Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (63750ns min), cache line size 08
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at e8000000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at e7800000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at b800 [size=64]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, 
DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-	Capabilities: [f0] Message Signalled 
Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
