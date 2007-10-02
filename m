From: Mirko Parthey <mirko.parthey@informatik.tu-chemnitz.de>
Subject: PROBLEM: system freezes on starting a sky2 + ne2k-pci bridge
Date: Tue, 2 Oct 2007 16:12:17 +0200
Message-ID: <20071002141217.GA23610@stilzchen.informatik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:59924 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbXJBOqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:46:23 -0400
Received: from haendel.informatik.tu-chemnitz.de ([134.109.192.132])
	by john.hrz.tu-chemnitz.de with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.66)
	(envelope-from <mirko.parthey@informatik.tu-chemnitz.de>)
	id 1IciTx-0006Zp-GC
	for netdev@vger.kernel.org; Tue, 02 Oct 2007 16:12:17 +0200
Received: from [134.109.192.209] (helo=stilzchen.informatik.tu-chemnitz.de ident=Debian-exim)
	by haendel.informatik.tu-chemnitz.de with esmtp (Exim 4.63)
	(envelope-from <mpa@stilzchen.informatik.tu-chemnitz.de>)
	id 1IciU0-0001dT-Tx
	for netdev@vger.kernel.org; Tue, 02 Oct 2007 16:12:20 +0200
Received: from mpa by stilzchen.informatik.tu-chemnitz.de with local (Exim 4.63)
	(envelope-from <mpa@stilzchen.informatik.tu-chemnitz.de>)
	id 1IciTx-0006AD-CZ
	for netdev@vger.kernel.org; Tue, 02 Oct 2007 16:12:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a machine running Debian testing, I get complete lockups
(Num lock LED not responding anymore)
when I try to use the network in the following configuration:

eth0: Marvell 8056 Gigabit LAN Controller, sky2 driver;
      the driver reports: Yukon EC Ultra (0xb4) rev 2
eth1: Compex ReadyLink 2000 (BNC+TP), ne2k-pci driver
br0: bridge comprising eth0 and eth1

Kernel versions tried (all of them show this problem):
- linux-image-2.6.18-5-amd64 (Debian etch)
- linux-image-2.6.22-2-amd64 (Debian testing)
- plain kernel.org 2.6.23-rc8-git4 (with allmodconfig and ATKBD=y)

The 2.6.18 kernel sometimes prints
  Losing some ticks ... checking if CPU frequency changed.
  Your time source seems to be instable or some driver is hogging
  interrupts.
  rip __do_softirq + 0x53/0xd5
before freezing.

The lockups can be reproduced fairly reliably as follows:
- power cycle the machine (shutdown with ACPI power off suffices,
  no need to use the switch on the power supply)
- switch to runlevel 1 (optional)
- eth0: has a gigabit link partner
- eth1: network cable disconnected
    (the driver will complain: Tx timed out, cable problem?)
- run the Debian-specific command
  $ ifup br0
  to start the bridge and its member interfaces
  br0 is configured in /etc/network/interfaces as follows:
    iface br0 inet static
      address 192.168.1.17
      netmask 255.255.255.0
      broadcast 192.168.1.255
      gateway 192.168.1.99
      bridge_ports eth0 eth1
      bridge_stp off
      bridge_fd 1

The lockup will occur while br0 is being brought up,
or soon afterwards.  If the system doesn't freeze within a minute,
I can transfer hundreds of MB of data without problems. For further
attempts at reproducing the problem, I then need to power cycle.

The Debian command "ifup br0" essentially does the following:
  brctl addbr br0
  brctl addif br0 eth0
  ifconfig eth0 0.0.0.0 up
  # sleep 2
  brctl addif br0 eth1
  ifconfig eth1 0.0.0.0 up
  # sleep 2
  brctl setfd br0 1
  brctl stp br0 off
  ifconfig br0 0.0.0.0 up
  # sleep 2
  ifconfig br0 192.168.1.17 netmask 255.255.255.0 broadcast 192.168.1.255 up
  # sleep 2
  route add default gw 192.168.1.99 br0

After adding the sleep commands, I could reproduce the problem
with the above shell script (without using Debian-specific commands),
although less reliably than with "ifup br0".

Finally some environment information. Please let me know if you need further
information, or if I should do further experiments.

# lspci
00:00.0 Host bridge: Intel Corporation P965/G965 Memory Controller Hub (rev 02)
00:01.0 PCI bridge: Intel Corporation P965/G965 PCI Express Root Port (rev 02)
00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI #2 (rev 02)
00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 02)
00:1c.3 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 4 (rev 02)
00:1c.4 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 5 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev f2)
00:1f.0 ISA bridge: Intel Corporation 82801HB/HR (ICH8/R) LPC Interface Controller (rev 02)
00:1f.2 IDE interface: Intel Corporation 82801H (ICH8 Family) 4 port SATA IDE Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 02)
00:1f.5 IDE interface: Intel Corporation 82801H (ICH8 Family) 2 port SATA IDE Controller (rev 02)
01:00.0 VGA compatible controller: ATI Technologies Inc RV370 5B60 [Radeon X300 (PCIE)]
01:00.1 Display controller: ATI Technologies Inc RV370 [Radeon X300SE]
03:00.0 SATA controller: JMicron Technologies, Inc. JMicron 20360/20363 AHCI Controller (rev 02)
03:00.1 IDE interface: JMicron Technologies, Inc. JMicron 20360/20363 AHCI Controller (rev 02)
04:00.0 Ethernet controller: Marvell Technology Group Ltd. Unknown device 4364 (rev 12)
05:00.0 Multimedia video controller: Brooktree Corporation Bt878 Video Capture (rev 02)
05:00.1 Multimedia controller: Brooktree Corporation Bt878 Audio Capture (rev 02)
05:01.0 Ethernet controller: Compex ReadyLink 2000 (rev 0a)

# lspci -s 4:0 -vvv
04:00.0 Ethernet controller: Marvell Technology Group Ltd. Unknown device 4364 (rev 12)
        Subsystem: Giga-byte Technology Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 58
        Region 0: Memory at ef000000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at 8000 [size=256]
        [virtual] Expansion ROM at 80000000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
                Address: 00000000fee00000  Data: 403a
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

# lspci -s 5:1 -vvv
05:01.0 Ethernet controller: Compex ReadyLink 2000 (rev 0a)
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin A routed to IRQ 177
        Region 0: I/O ports at 9000 [size=32]
        [virtual] Expansion ROM at f1108000 [disabled] [size=32K]

Regards,
Mirko
