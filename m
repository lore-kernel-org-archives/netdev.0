From: pgs@synerway.com
Subject: Re: need some help on a backport of r8169
Date: Wed, 28 Feb 2007 17:01:33 +0100
Message-ID: <20070228160133.GA8014@venus.synerway.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com> <20070227110243.GA15657@venus.synerway.com> <20070227212400.GA12760@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:35716 "EHLO
	stargate.synerway.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbXB1QBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 11:01:36 -0500
Received: from kamino.synerway.com (kamino [172.16.1.21])
	by stargate.synerway.com (Postfix) with ESMTP id 0BFA075C170
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 17:36:53 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070227212400.GA12760@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu a =E9crit, le Tue 27 Feb 2007 =E0 10:24:00PM :
> Please don't do > 80 columns line again. I am not a tty.
Sorry. I turn on auto-fill-mode.

> > > There are 59 r8169 related patches between 2.6.12 and current. On=
ly a few
> > > of those break the API. I'll give it a try tomorrow evening.
> > Hmm... you wrote this mail at 00 h 48 this morning, what did you me=
an by
> > tomorrow evening?
>=20
> 1. I mean now. See:
>    http://www.fr.zoreil.com/people/francois/backport/r8169/20070227-0=
0
>    (big patch or serie of 54 pieces).
>=20
> 2. Compiled, untested. You know what you have to do.
>=20
> 3. Due to the changes in the driver, one could hope that the link wil=
l be
>    autocorrectly set. Please give it a try before using ethtool/mii-t=
ool.
>=20
> 4. The patchkit does not include the latest changes/bugfixes. They ar=
e
>    still experimental but some users have a poor 8168 experience with=
out
>    them. YMMV. Please send a complete dmesg, lspci -vvx and the brand=
 of
>    the motherboard if the driver stops working randomly.

Thank you Fran=E7ois.
Ok, I tried it, had to modify it a little because it was against
2.6.11 kernel and not 2.6.11.11, anyway I had not a big work to do for
this.

I also rebuilt completely my kernel instead of just doing "make
modules", and I fixed some bugs that I previously introduced myself
for the motherboard chipset.

The result is as follows :
I boot my new kernel : the r8169 driver is automatically loaded and
find the network card and gives me an eth0.
I do a ifconfig, eth0 is up, with an IP and RX and TX are not 0.
The problem comes here, I do a ping and it seems to have just the time
to make the DNS resolution but not further. When I do a new ifconfig,
the TX dropped is not 0 anymore. Then I can turn up and down my
interface, I won't be able to ping anything.

Ah... poor me who thought that the RTL8168 was just like the RTL8169 wi=
th
a pci express interface... It seems that a PCI-Express RTL8169 also
exist right?

Ok, one more precision, I didn't allow pci-express in my kernel, I
just noticed it. I'm recompiling my kernel with it to see if it makes
any change, but, with the 2.6.20 kernel, everything works well, I can
ping what I want and pci-express is also not picked up.

My kernel is compiled, with pci-express enabled, no changes.


Do you think my problem is the one you mentionned above, without the
experimental patches?

Ok, here are my hardware informations :

my motherboard uses an ICH7 chipset, i velieve it's an I945G or
something like that.

To make it work completely, I use the following patch (cannot put it
anymore on an URL, I'm sorry) :

--- ./drivers/ide/pci/piix.c.orig	2005-05-27 07:06:46.000000000 +0200
+++ ./drivers/ide/pci/piix.c	2007-02-28 16:18:37.241527210 +0100
@@ -133,7 +133,9 @@
 		case PCI_DEVICE_ID_INTEL_82801EB_11:
 		case PCI_DEVICE_ID_INTEL_ESB_2:
 		case PCI_DEVICE_ID_INTEL_ICH6_19:
+		case PCI_DEVICE_ID_INTEL_ICH6_3:
 		case PCI_DEVICE_ID_INTEL_ICH7_21:
+		case PCI_DEVICE_ID_INTEL_ICH7_2:
 			mode =3D 3;
 			break;
 		/* UDMA 66 capable */
@@ -446,7 +448,9 @@
 		case PCI_DEVICE_ID_INTEL_82801E_11:
 		case PCI_DEVICE_ID_INTEL_ESB_2:
 		case PCI_DEVICE_ID_INTEL_ICH6_19:
+		case PCI_DEVICE_ID_INTEL_ICH6_3:
 		case PCI_DEVICE_ID_INTEL_ICH7_21:
+		case PCI_DEVICE_ID_INTEL_ICH7_2:
 		{
 			unsigned int extra =3D 0;
 			pci_read_config_dword(dev, 0x54, &extra);
@@ -572,6 +576,8 @@
 	/* 20 */ DECLARE_PIIX_DEV("ICH6"),
 	/* 21 */ DECLARE_PIIX_DEV("ICH7"),
 	/* 22 */ DECLARE_PIIX_DEV("ICH4"),
+	/* 23 */ DECLARE_PIIX_DEV("ICH6"),
+	/* 24 */ DECLARE_PIIX_DEV("ICH7"),
 };
=20
 /**
@@ -647,6 +653,8 @@
 	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_ICH6_19, PCI_ANY_ID, PCI_A=
NY_ID, 0, 0, 20},
 	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_ICH7_21, PCI_ANY_ID, PCI_A=
NY_ID, 0, 0, 21},
 	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801DB_1, PCI_ANY_ID, PCI=
_ANY_ID, 0, 0, 22},
+	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_ICH6_3, PCI_ANY_ID, PCI_AN=
Y_ID, 0, 0, 23},
+	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_ICH7_2, PCI_ANY_ID, PCI_AN=
Y_ID, 0, 0, 24},
 	{ 0, },
 };
 MODULE_DEVICE_TABLE(pci, piix_pci_tbl);


And next you can find my lspci, dmesg, and even dmidecode outputs.

Thank you again for your help.

lspci:

00:00.0 Host bridge: Intel Corp.: Unknown device 2770 (rev 02)
	Subsystem: Unknown device 1631:e015
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort+ >SERR- <PERR-
	Latency: 0
	Capabilities: [e0] #09 [7109]
00: 86 80 70 27 06 00 90 20 02 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00

00:02.0 VGA compatible controller: Intel Corp.: Unknown device 2772 (re=
v 02) (prog-if 00 [VGA])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at ffa80000 (32-bit, non-prefetchable) [size=3D512K]
	Region 1: I/O ports at ec00 [size=3D8]
	Region 2: Memory at e0000000 (32-bit, prefetchable) [size=3D256M]
	Region 3: Memory at ffa40000 (32-bit, non-prefetchable) [size=3D256K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] Message Signalled Interrupts: 64bit- Queue=3D0/0 En=
able-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
00: 86 80 72 27 07 00 90 00 02 00 00 03 00 00 00 00
10: 00 00 a8 ff 01 ec 00 00 08 00 00 e0 00 00 a4 ff
20: 00 00 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 90 00 00 00 00 00 00 00 0a 01 00 00

00:1c.0 PCI bridge: Intel Corp.: Unknown device 27d0 (rev 01) (prog-if =
00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR-
	Latency: 0, cache line size 08
	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: ff700000-ff7fffff
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] #10 [0141]
	Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=3D0/0 En=
able-
		Address: 00000000  Data: 0000
	Capabilities: [90] #0d [0000]
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
00: 86 80 d0 27 07 01 10 00 01 00 04 06 08 00 81 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 c0 c0 00 20
20: 70 ff 70 ff f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 02 00

00:1d.0 USB Controller: Intel Corp.: Unknown device 27c8 (rev 01) (prog=
-if 00 [UHCI])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 4: I/O ports at e880 [size=3D32]
00: 86 80 c8 27 05 00 80 02 01 00 03 0c 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 81 e8 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00

00:1d.1 USB Controller: Intel Corp.: Unknown device 27c9 (rev 01) (prog=
-if 00 [UHCI])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 3
	Region 4: I/O ports at e800 [size=3D32]
00: 86 80 c9 27 05 00 80 02 01 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e8 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 00 00 00 00 00 00 00 00 03 02 00 00

00:1d.2 USB Controller: Intel Corp.: Unknown device 27ca (rev 01) (prog=
-if 00 [UHCI])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin C routed to IRQ 10
	Region 4: I/O ports at e480 [size=3D32]
00: 86 80 ca 27 05 00 80 02 01 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 81 e4 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 03 00 00

00:1d.3 USB Controller: Intel Corp.: Unknown device 27cb (rev 01) (prog=
-if 00 [UHCI])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin D routed to IRQ 10
	Region 4: I/O ports at e400 [size=3D32]
00: 86 80 cb 27 05 00 80 02 01 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e4 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 04 00 00

00:1d.7 USB Controller: Intel Corp.: Unknown device 27cc (rev 01) (prog=
-if 20 [EHCI])
	Subsystem: Unknown device 1631:e015
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at ffa3fc00 (32-bit, non-prefetchable) [size=3D1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA PME(D0+,D1-,D2-,D3hot+=
,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] #0a [20a0]
00: 86 80 cc 27 06 00 90 02 01 20 03 0c 00 00 00 00
10: 00 fc a3 ff 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 00 00

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA PCI Bridge (rev e1) (prog-if=
 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D32
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: ff800000-ff8fffff
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] #0d [0000]
00: 86 80 4e 24 07 01 10 00 e1 01 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 02 02 20 d0 d0 80 22
20: 80 ff 80 ff f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 02 00

00:1f.0 ISA bridge: Intel Corp.: Unknown device 27b8 (rev 01)
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Capabilities: [e0] #09 [100c]
00: 86 80 b8 27 07 00 10 02 01 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00

00:1f.2 IDE interface: Intel Corp.: Unknown device 27c0 (rev 01) (prog-=
if 80 [Master])
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 3
	Region 0: I/O ports at <unassigned>
	Region 1: I/O ports at <unassigned>
	Region 2: I/O ports at <unassigned>
	Region 3: I/O ports at <unassigned>
	Region 4: I/O ports at ffa0 [size=3D16]
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D=
3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
00: 86 80 c0 27 05 00 b8 02 01 80 01 01 00 00 00 00
10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
20: a1 ff 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 70 00 00 00 00 00 00 00 00 02 00 00

00:1f.3 SMBus: Intel Corp.: Unknown device 27da (rev 01)
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 3
	Region 4: I/O ports at 0400 [size=3D32]
00: 86 80 da 27 01 00 80 02 01 00 05 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 04 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 00 00 00 00 00 00 00 00 00 00 03 02 00 00

01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown d=
evice 8168 (rev 01)
	Subsystem: Unknown device 1631:e015
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at c800 [size=3D256]
	Region 2: Memory at ff7ff000 (64-bit, non-prefetchable) [size=3D4K]
	Expansion ROM at ff7c0000 [disabled] [size=3D128K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0-,D1+,D2+,D3hot+=
,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [48] Vital Product Data
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=3D0/1 En=
able-
		Address: 0000000000000000  Data: 0000
	Capabilities: [60] #10 [0001]
	Capabilities: [84] #09 [014c]
00: ec 10 68 81 03 00 10 00 01 00 00 02 20 00 00 00
10: 01 c8 00 00 00 00 00 00 04 f0 7f ff 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 31 16 15 e0
30: 00 00 7c ff 40 00 00 00 00 00 00 00 0a 01 00 00

02:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8=
139C (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR-
	Latency: 64 (8000ns min, 16000ns max)
	Interrupt: pin A routed to IRQ 3
	Region 0: I/O ports at d800 [size=3D256]
	Region 1: Memory at ff8ffc00 (32-bit, non-prefetchable) [size=3D256]
	Expansion ROM at ff8e0000 [disabled] [size=3D64K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0-,D1+,D2+,D3hot+=
,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
00: ec 10 39 81 07 00 90 02 10 00 00 02 00 40 00 00
10: 01 d8 00 00 00 fc 8f ff 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 39 81
30: 00 00 8e ff 50 00 00 00 00 00 00 00 03 01 20 40



dmesg:

Linux version 2.6.11.11 (swdmpsu@proto26) (gcc version 3.4.2) #5 Wed Fe=
b 28 16:40:59 CET 2007
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001f7c0000 (usable)
 BIOS-e820: 000000001f7c0000 - 000000001f7ce000 (ACPI data)
 BIOS-e820: 000000001f7ce000 - 000000001f800000 (ACPI NVS)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffb80000 - 0000000100000000 (reserved)
0MB HIGHMEM available.
503MB LOWMEM available.
On node 0 totalpages: 128960
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 124864 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI: RSDP (v000 ACPIAM                                ) @ 0x000f7b20
ACPI: RSDT (v001 A M I  OEMRSDT  0x11000608 MSFT 0x00000097) @ 0x1f7c00=
00
ACPI: FADT (v002 A M I  OEMFACP  0x11000608 MSFT 0x00000097) @ 0x1f7c02=
00
ACPI: MADT (v001 A M I  OEMAPIC  0x11000608 MSFT 0x00000097) @ 0x1f7c03=
90
ACPI: MCFG (v001 A M I  OEMMCFG  0x11000608 MSFT 0x00000097) @ 0x1f7c04=
00
ACPI: SLIC (v001 A M I  OEMSLIC  0x11000608 MSFT 0x00000097) @ 0x1f7c04=
40
ACPI: OEMB (v001 A M I  AMI_OEM  0x11000608 MSFT 0x00000097) @ 0x1f7ce0=
40
ACPI: DSDT (v001  945G1 945G1108 0x00000108 INTL 0x02002026) @ 0x000000=
00
Allocating PCI resources starting at 1f800000 (gap: 1f800000:df600000)
Built 1 zonelists
Kernel command line: auto BOOT_IMAGE=3Dlinux ro root=3D301
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 32768 bytes)
Detected 3326.317 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 507268k/515840k available (2643k kernel code, 8140k reserved, 6=
65k data, 180k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode..=
=2E Ok.
Calibrating delay loop... 6553.60 BogoMIPS (lpj=3D3276800)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 =
0000e41d 00000000 00000001
CPU: After vendor identify, caps: bfebfbff 20100000 00000000 00000000 0=
000e41d 00000000 00000001
monitor/mwait feature present.
using mwait in idle threads.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 512K
CPU: After all inits, caps: bfebfbff 20100000 00000000 00000080 0000e41=
d 00000000 00000001
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (24) available
CPU: Intel(R) Celeron(R) D CPU 3.33GHz stepping 04
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
ACPI: setting ELCR to 0200 (from 0c08)
NET: Registered protocol family 16
PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=3D2
PCI: Using MMCONFIG
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20050211
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.2
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, dis=
abled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, dis=
abled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, dis=
abled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, dis=
abled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11 12 14 15)
SCSI subsystem initialized
PCI: Using ACPI for IRQ routing
** PCI interrupts are no longer routed automatically.  If this
** causes a device to stop working, it is probably because the
** driver failed to call pci_enable_device().  As a temporary
** workaround, the "pci=3Drouteirq" argument restores the old
** behavior.  If this argument makes the device work again,
** please email the output of "lspci" to bjorn.helgaas@hp.com
** so I can fix the driver.
apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
apm: overridden by ACPI.
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
SGI XFS with ACLs, security attributes, large block numbers, no debug e=
nabled
SGI XFS Quota Management subsystem
Initializing Cryptographic API
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI interrupt 0000:00:1c.0[A] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[pcie00]
Allocate Port Service[pcie02]
Allocate Port Service[pcie03]
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 8 ports, IRQ sharing enable=
d
ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebu=
s=3Dxx
ICH7: IDE controller at PCI slot 0000:00:1f.2
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 3
PCI: setting IRQ 3 as level-triggered
ACPI: PCI interrupt 0000:00:1f.2[B] -> GSI 3 (level, low) -> IRQ 3
ICH7: chipset revision 1
ICH7: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
hda: HDS722580VLSA80, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: Optiarc DVD RW AD-5170A, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide2...
Probing IDE interface ide3...
Probing IDE interface ide4...
Probing IDE interface ide5...
hda: max request size: 1024KiB
hda: 160836480 sectors (82348 MB) w/7938KiB Cache, CHS=3D16383/255/63, =
UDMA(33)
hda: cache flushes supported
 hda: hda1 hda2 hda3
ide-floppy driver 0.99.newide
3ware Storage Controller device driver for Linux v1.26.02.000.
3ware 9000 Storage Controller device driver for Linux v2.26.02.001.
=46usion MPT base driver 3.01.18
Copyright (c) 1999-2004 LSI Logic Corporation
=46usion MPT SCSI Host driver 3.01.18
=46usion MPT misc device (ioctl) driver 3.01.18
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=3D10,220)
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard on isa0060/serio0
md: md driver 0.90.1 MAX_MD_DEVS=3D256, MD_SB_DISKS=3D27
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 4, 65536 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
ACPI wakeup devices:=20
P0P2 P0P1 LAN1 PS2K UAR1 EUSB MC97 P0P4 P0P5 P0P6 P0P7 P0P8 P0P9 USB0 U=
SB1 USB2 USB3=20
ACPI: (supports S0 S1 S3 S4 S5)
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
XFS mounting filesystem hda1
Ending clean XFS mount for filesystem: hda1
VFS: Mounted root (xfs filesystem) readonly.
=46reeing unused kernel memory: 180k freed
XFS mounting filesystem hda3
Ending clean XFS mount for filesystem: hda3
usbcore: registered new driver hub
Adding 1464836k swap on /dev/hda2.  Priority:-1 extents:1
i8xx TCO timer: heartbeat value must be 2<heartbeat<39, using 30
i8xx TCO timer: initialized (0x0860). heartbeat=3D30 sec (nowayout=3D0)
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 10 (level, low) -> IRQ 10
PCI: Setting latency timer of device 0000:01:00.0 to 64
eth0: RTL8168b/8111b at 0xe0010000, 00:16:ec:8f:2f:af, IRQ 10
8139too Fast Ethernet driver 0.9.27
ACPI: PCI interrupt 0000:02:02.0[A] -> GSI 3 (level, low) -> IRQ 3
eth1: RealTek RTL8139 at 0xd800, 00:e0:4c:e2:33:03, IRQ 3
eth1:  Identified 8139 chip type 'RTL-8139C'
8139cp: 10/100 PCI Ethernet driver v1.2 (Mar 22, 2004)
hdc: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048kB Cache, UDMA(66)
Uniform CD-ROM driver Revision: 3.20
Warning: /proc/ide/hd?/settings interface is obsolete, and will be remo=
ved soon!
st: Version 20041025, fixed bufsize 32768, s/g segs 256
r8169: eth0: link up
r8169: eth0: link up
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
8139too Fast Ethernet driver 0.9.27
ACPI: PCI interrupt 0000:02:02.0[A] -> GSI 3 (level, low) -> IRQ 3
eth0: RealTek RTL8139 at 0xd800, 00:e0:4c:e2:33:03, IRQ 3
eth0:  Identified 8139 chip type 'RTL-8139C'
eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1


dmidecode:

# dmidecode 2.7
SMBIOS 2.3 present.
50 structures occupying 1880 bytes.
Table at 0x000FC310.

Handle 0x0000, DMI type 0, 24 bytes.
BIOS Information
	Vendor: American Megatrends Inc.
	Version: 080013=20
	Release Date: 11/08/2006
	Address: 0xF0000
	Runtime Size: 64 kB
	ROM Size: 512 kB
	Characteristics:
		ISA is supported
		PCI is supported
		PNP is supported
		APM is supported
		BIOS is upgradeable
		BIOS shadowing is allowed
		ESCD support is available
		Boot from CD is supported
		Selectable boot is supported
		BIOS ROM is socketed
		EDD is supported
		5.25"/1.2 MB floppy services are supported (int 13h)
		3.5"/720 KB floppy services are supported (int 13h)
		3.5"/2.88 MB floppy services are supported (int 13h)
		Print screen service is supported (int 5h)
		8042 keyboard services are supported (int 9h)
		Serial services are supported (int 14h)
		Printer services are supported (int 17h)
		CGA/mono video services are supported (int 10h)
		ACPI is supported
		USB legacy is supported
		LS-120 boot is supported
		ATAPI Zip drive boot is supported
		BIOS boot specification is supported
		Function key-initiated network boot is supported
	BIOS Revision: 8.13

Handle 0x0001, DMI type 1, 27 bytes.
System Information
	Manufacturer: NEC COMPUTERS INTERNATIONAL
	Product Name: ECS-945G
	Version: 1.0
	Serial Number: =20
	UUID: 00020003-0004-0005-0006-000700080009
	Wake-up Type: Power Switch
	SKU Number: To Be Filled By O.E.M.
	Family: To Be Filled By O.E.M.

Handle 0x0002, DMI type 2, 15 bytes.
Base Board Information
	Manufacturer: NEC COMPUTERS INTERNATIONAL
	Product Name: ECS-945G
	Version: 1.0
	Serial Number: =20
	Asset Tag: To Be Filled By O.E.M.
	Features:
		Board is a hosting board
		Board is replaceable
	Location In Chassis: To Be Filled By O.E.M.
	Chassis Handle: 0x0003
	Type: Motherboard
	Contained Object Handles: 0

Handle 0x0003, DMI type 3, 21 bytes.
Chassis Information
	Manufacturer: To Be Filled By O.E.M.
	Type: Desktop
	Lock: Not Present
	Version: To Be Filled By O.E.M.
	Serial Number: To Be Filled By O.E.M.
	Asset Tag: To Be Filled By O.E.M.
	Boot-up State: Safe
	Power Supply State: Safe
	Thermal State: Safe
	Security Status: None
	OEM Information: 0x00000000
	Heigth: Unspecified
	Number Of Power Cords: 1
	Contained Elements: 0

Handle 0x0004, DMI type 4, 35 bytes.
Processor Information
	Socket Designation: CPU 1
	Type: Central Processor
	Family: Unknown
	Manufacturer: Intel           =20
	ID: 64 0F 00 00 FF FB EB BF
	Version: Intel(R) Celeron(R) D CPU 3.33GHz                  =20
	Voltage: 1.3 V
	External Clock: 133 MHz
	Max Speed: 3325 MHz
	Current Speed: 3325 MHz
	Status: Populated, Enabled
	Upgrade: Other
	L1 Cache Handle: 0x0005
	L2 Cache Handle: 0x0006
	L3 Cache Handle: 0x0007
	Serial Number: To Be Filled By O.E.M.
	Asset Tag: To Be Filled By O.E.M.
	Part Number: To Be Filled By O.E.M.

Handle 0x0005, DMI type 7, 19 bytes.
Cache Information
	Socket Designation: L1-Cache
	Configuration: Enabled, Not Socketed, Level 1
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 16 KB
	Maximum Size: 16 KB
	Supported SRAM Types:
		Other
	Installed SRAM Type: Other
	Speed: Unknown
	Error Correction Type: Parity
	System Type: Data
	Associativity: 8-way Set-associative

Handle 0x0006, DMI type 7, 19 bytes.
Cache Information
	Socket Designation: L2-Cache
	Configuration: Enabled, Not Socketed, Level 2
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 512 KB
	Maximum Size: 512 KB
	Supported SRAM Types:
		Other
	Installed SRAM Type: Other
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Unified
	Associativity: 8-way Set-associative

Handle 0x0007, DMI type 7, 19 bytes.
Cache Information
	Socket Designation: L3-Cache
	Configuration: Disabled, Not Socketed, Level 3
	Operational Mode: Unknown
	Location: Internal
	Installed Size: 0 KB
	Maximum Size: 0 KB
	Supported SRAM Types:
		Unknown
	Installed SRAM Type: Unknown
	Speed: Unknown
	Error Correction Type: Unknown
	System Type: Unknown
	Associativity: Unknown

Handle 0x0008, DMI type 5, 24 bytes.
Memory Controller Information
	Error Detecting Method: 64-bit ECC
	Error Correcting Capabilities:
		None
	Supported Interleave: One-way Interleave
	Current Interleave: One-way Interleave
	Maximum Memory Module Size: 4096 MB
	Maximum Total Memory Size: 16384 MB
	Supported Speeds:
		Other
	Supported Memory Types:
		DIMM
		SDRAM
	Memory Module Voltage: 3.3 V
	Associated Memory Slots: 4
		0x0009
		0x000A
		0x000B
		0x000C
	Enabled Error Correcting Capabilities:
		None

Handle 0x0009, DMI type 6, 12 bytes.
Memory Module Information
	Socket Designation: DIMM0
	Bank Connections: 0 1
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: 512 MB (Single-bank Connection)
	Enabled Size: 512 MB (Single-bank Connection)
	Error Status: OK

Handle 0x000A, DMI type 6, 12 bytes.
Memory Module Information
	Socket Designation: DIMM1
	Bank Connections: 2 3
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: Not Installed
	Enabled Size: Not Installed
	Error Status: OK

Handle 0x000B, DMI type 6, 12 bytes.
Memory Module Information
	Socket Designation: DIMM2
	Bank Connections: 4 5
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: Not Installed
	Enabled Size: Not Installed
	Error Status: OK

Handle 0x000C, DMI type 6, 12 bytes.
Memory Module Information
	Socket Designation: DIMM3
	Bank Connections: 6 7
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: Not Installed
	Enabled Size: Not Installed
	Error Status: OK

Handle 0x000D, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J1A1
	Internal Connector Type: None
	External Reference Designator: PS2Mouse
	External Connector Type: PS/2
	Port Type: Mouse Port

Handle 0x000E, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J1A1
	Internal Connector Type: None
	External Reference Designator: Keyboard
	External Connector Type: PS/2
	Port Type: Keyboard Port

Handle 0x000F, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J2A2
	Internal Connector Type: None
	External Reference Designator: USB1
	External Connector Type: Access Bus (USB)
	Port Type: USB

Handle 0x0010, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J2A2
	Internal Connector Type: None
	External Reference Designator: USB2
	External Connector Type: Access Bus (USB)
	Port Type: USB

Handle 0x0011, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J4A1
	Internal Connector Type: None
	External Reference Designator: LPT 1
	External Connector Type: DB-25 male
	Port Type: Parallel Port ECP/EPP

Handle 0x0012, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J6B1 - AUX IN
	Internal Connector Type: On Board Sound Input From CD-ROM
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Audio Port

Handle 0x0013, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J6B2 - CDIN
	Internal Connector Type: On Board Sound Input From CD-ROM
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Audio Port

Handle 0x0014, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J6J2 - PRI IDE
	Internal Connector Type: On Board IDE
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0015, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J6J1 - SEC IDE
	Internal Connector Type: On Board IDE
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0016, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J4J1 - FLOPPY
	Internal Connector Type: On Board Floppy
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0017, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J9H1 - FRONT PNL
	Internal Connector Type: 9 Pin Dual Inline (pin 10 cut)
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0018, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J1B1 - CHASSIS REAR FAN
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0019, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J2F1 - CPU FAN
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x001A, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J8B4 - FRONT FAN
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x001B, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J9G2 - FNT USB
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x001C, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J6C3 - FP AUD
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x001D, DMI type 8, 9 bytes.
Port Connector Information
	Internal Reference Designator: J9G1 - CONFIG
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x001E, DMI type 9, 13 bytes.
System Slot Information
	Designation: AGP
	Type: 32-bit AGP 4x
	Current Usage: Available
	Length: Short
	ID: 0
	Characteristics:
		3.3 V is provided
		Opening is shared
		PME signal is supported

Handle 0x001F, DMI type 9, 13 bytes.
System Slot Information
	Designation: PCI1
	Type: 32-bit PCI
	Current Usage: Available
	Length: Short
	ID: 1
	Characteristics:
		3.3 V is provided
		Opening is shared
		PME signal is supported

Handle 0x0020, DMI type 9, 13 bytes.
System Slot Information
	Designation: PCI2
	Type: 32-bit PCI
	Current Usage: In Use
	Length: Short
	ID: 2
	Characteristics:
		3.3 V is provided
		Opening is shared
		PME signal is supported

Handle 0x0021, DMI type 9, 13 bytes.
System Slot Information
	Designation: PCI3
	Type: 32-bit PCI
	Current Usage: Available
	Length: Short
	ID: 3
	Characteristics:
		3.3 V is provided
		Opening is shared
		PME signal is supported

Handle 0x0022, DMI type 10, 6 bytes.
On Board Device Information
	Type: Video
	Status: Enabled
	Description:   To Be Filled By O.E.M.

Handle 0x0023, DMI type 10, 6 bytes.
On Board Device Information
	Type: SCSI Controller
	Status: Disabled
	Description:  To Be Filled By O.E.M.

Handle 0x0024, DMI type 10, 6 bytes.
On Board Device Information
	Type: Ethernet
	Status: Enabled
	Description: To Be Filled By O.E.M.

Handle 0x0025, DMI type 13, 22 bytes.
BIOS Language Information
	Installable Languages: 1
		en|US|iso8859-1
	Currently Installed Language: en|US|iso8859-1

Handle 0x0026, DMI type 16, 15 bytes.
Physical Memory Array
	Location: System Board Or Motherboard
	Use: System Memory
	Error Correction Type: None
	Maximum Capacity: 4 GB
	Error Information Handle: Not Provided
	Number Of Devices: 4

Handle 0x0027, DMI type 19, 15 bytes.
Memory Array Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x0001FFFFFFF
	Range Size: 512 MB
	Physical Array Handle: 0x0026
	Partition Width: 0

Handle 0x0028, DMI type 17, 27 bytes.
Memory Device
	Array Handle: 0x0026
	Error Information Handle: Not Provided
	Total Width: 64 bits
	Data Width: 64 bits
	Size: 512 MB
	Form Factor: DIMM
	Set: None
	Locator: DIMM0
	Bank Locator: BANK0
	Type: SDRAM
	Type Detail: Synchronous
	Speed: Unknown
	Manufacturer: Manufacturer0
	Serial Number: SerNum0
	Asset Tag: AssetTagNum0
	Part Number: PartNum0

Handle 0x0029, DMI type 20, 19 bytes.
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x0001FFFFFFF
	Range Size: 512 MB
	Physical Device Handle: 0x0028
	Memory Array Mapped Address Handle: 0x0027
	Partition Row Position: 1
	Interleaved Data Depth: 1

Handle 0x002A, DMI type 17, 27 bytes.
Memory Device
	Array Handle: 0x0026
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: No Module Installed
	Form Factor: DIMM
	Set: None
	Locator: DIMM1
	Bank Locator: BANK1
	Type: Unknown
	Type Detail: Unknown
	Speed: Unknown
	Manufacturer: Manufacturer1
	Serial Number: SerNum1
	Asset Tag: AssetTagNum1
	Part Number: PartNum1

Handle 0x002B, DMI type 20, 19 bytes.
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000000003FF
	Range Size: 1 kB
	Physical Device Handle: 0x002A
	Memory Array Mapped Address Handle: 0x0027
	Partition Row Position: 1
	Interleaved Data Depth: 1

Handle 0x002C, DMI type 17, 27 bytes.
Memory Device
	Array Handle: 0x0026
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: No Module Installed
	Form Factor: DIMM
	Set: None
	Locator: DIMM2
	Bank Locator: BANK2
	Type: Unknown
	Type Detail: Unknown
	Speed: Unknown
	Manufacturer: Manufacturer2
	Serial Number: SerNum2
	Asset Tag: AssetTagNum2
	Part Number: PartNum2

Handle 0x002D, DMI type 20, 19 bytes.
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000000003FF
	Range Size: 1 kB
	Physical Device Handle: 0x002C
	Memory Array Mapped Address Handle: 0x0027
	Partition Row Position: 1
	Interleaved Data Depth: 1

Handle 0x002E, DMI type 17, 27 bytes.
Memory Device
	Array Handle: 0x0026
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: No Module Installed
	Form Factor: DIMM
	Set: None
	Locator: DIMM3
	Bank Locator: BANK3
	Type: Unknown
	Type Detail: Unknown
	Speed: Unknown
	Manufacturer: Manufacturer3
	Serial Number: SerNum3
	Asset Tag: AssetTagNum3
	Part Number: PartNum3

Handle 0x002F, DMI type 20, 19 bytes.
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000000003FF
	Range Size: 1 kB
	Physical Device Handle: 0x002E
	Memory Array Mapped Address Handle: 0x0027
	Partition Row Position: 1
	Interleaved Data Depth: 1

Handle 0x0030, DMI type 32, 20 bytes.
System Boot Information
	Status: No errors detected

Handle 0x0031, DMI type 127, 4 bytes.
End Of Table




>=20
> --=20
> Ueimor
