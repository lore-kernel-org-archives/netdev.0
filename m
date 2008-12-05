From: Thomas Renninger <trenn@suse.de>
Subject: Identified: PCIe ASPM causes machine (HP Compaq 6735s) to sometimes hang in endless loop
Date: Fri, 5 Dec 2008 13:41:42 +0100
Message-ID: <200812051341.43806.trenn@suse.de>
References: <200811281328.55259.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, shaohua.li@intel.com,
	Rafael Wysocki <rwysocki@suse.de>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:58293 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbYLEMlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 07:41:46 -0500
In-Reply-To: <200811281328.55259.trenn@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I got it. It is and endless loop in drivers/pci/pcie/aspm.c:

On Friday 28 November 2008 13:28:54 Thomas Renninger wrote:
> Hi,
>
> The hang does not always happen.
> On latest vanilla 2.6.28-rc6 it nearly always hangs, on a .27 SUSE kernel
> maybe 1 out for 3 times.
>
> I very much expect (I am pretty sure now) it is PCIE ASPM.
>
> I tried to compile out:
> CONFIG_PCIEAER=y
> CONFIG_PCIEASPM=y
>
> Both disabled survived a reasonable amount of reboots, but when enabling
> CONFIG_PCIEASPM it did not boot anymore on the second try.
>
> The machine is hanging at the network card's PCI initialization rather
> early, here is a photo of the hang:
> ftp.suse.com/pub/people/trenn/HP_pci_aspm_hang.jpg

First, I'd like to know whether I could have solved that easier.
The machine is a laptop without firewire and serial console.
It has an PCIe slot.

sysrq did not work at this point, because the keyboard is not functional
yet. Via serial console it probably would have been possible to trigger
a backtrace, you see the function where it loops -> found in 10 minutes,
but as said this machine has no serial port.

Did I miss some nice debug functionality/trick which could have found
that easier?

After I knew it is PCIe ASPM, I went through the code, found the loop,
added a printk there and some more at other places and got it...

At the end is some info for people who know more about PCI than me.
It would be great if the root cause is found/fixed.
I will provide a patch in a follow up mail to workaround the hang which
IMO (if reviewed) should go into stable kernels back to when ASPM was
added (was that .26?).

Thanks,

      Thomas
In case the machine boots fine I get:
--------
pci 0000:00:04.0: Writing 0x63 to 104
pci 0000:00:04.0: Reading 0x7011 at 106
PCI: bridge 0000:00:04.0 io port: [3000, 4fff]
PCI: bridge 0000:00:04.0 32bit mmio: [93100000, 941fffff]
PCI: bridge 0000:00:04.0 64bit mmio pref: [90000000, 90ffffff]
PCI: bridge 0000:00:07.0 io port: [2000, 2fff]
PCI: bridge 0000:00:07.0 32bit mmio: [92100000, 930fffff]
PCI: bridge 0000:00:07.0 64bit mmio pref: [91000000, 91ffffff]
PCI: 0000:06:00.0 reg 10 64bit mmio: [92000000, 92003fff]
--------

If the machine hangs I get:
--------
pci 0000:00:04.0: Writing 0x63 to 104
pci 0000:00:04.0: Reading 0x7811 at 106
pci 0000:00:04.0: Reading 0x7811 at 106
pci 0000:00:04.0: Reading 0x7811 at 106
pci 0000:00:04.0: Reading 0x7811 at 106
pci 0000:00:04.0: Reading 0x7811 at 106
....
pci 0000:00:04.0: Could not configure ASPM
PCI: bridge 0000:00:04.0 io port: [3000, 4fff]
PCI: bridge 0000:00:04.0 32bit mmio: [93100000, 941fffff]
PCI: bridge 0000:00:04.0 64bit mmio pref: [90000000, 90ffffff]
PCI: bridge 0000:00:07.0 io port: [2000, 2fff]
PCI: bridge 0000:00:07.0 32bit mmio: [92100000, 930fffff]
PCI: bridge 0000:00:07.0 64bit mmio pref: [91000000, 91ffffff]
PCI: 0000:06:00.0 reg 10 64bit mmio: [92000000, 92003fff]
--------

This is the patch for above output:
---
 drivers/pci/pcie/aspm.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: linux-2.6.27/drivers/pci/pcie/aspm.c
===================================================================
--- linux-2.6.27.orig/drivers/pci/pcie/aspm.c
+++ linux-2.6.27/drivers/pci/pcie/aspm.c
@@ -165,6 +165,7 @@ static void pcie_aspm_configure_common_c
 	u16 reg16 = 0;
 	struct pci_dev *child_dev;
 	int same_clock = 1;
+	int loop_count = 0;
 
 	/*
 	 * all functions of a slot should have the same Slot Clock
@@ -210,14 +211,21 @@ static void pcie_aspm_configure_common_c
 	/* retrain link */
 	reg16 |= PCI_EXP_LNKCTL_RL;
 	pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);
+	dev_printk (KERN_INFO, &pdev->dev, "Writing 0x%x to %d\n",
+		    reg16, pos + PCI_EXP_LNKCTL);
 
 	/* Wait for link training end */
-	while (1) {
+	while (loop_count < 100) {
 		pci_read_config_word(pdev, pos + PCI_EXP_LNKSTA, &reg16);
+		dev_printk (KERN_INFO, &pdev->dev, "Reading 0x%x at %d\n",
+			    reg16, pos + PCI_EXP_LNKSTA);
 		if (!(reg16 & PCI_EXP_LNKSTA_LT))
 			break;
 		cpu_relax();
+		loop_count++;
 	}
+	if (loop_count == 100)
+		dev_printk (KERN_WARNING, &pdev->dev, "Could not configure ASPM\n");
 }
 
 /*

=======================================================

Here the lspci -nn -vv output of the bridge (ASPM poking on that one makes
the machine hang)

00:04.0 PCI bridge [0604]: Advanced Micro Devices [AMD] RS780 PCI to PCI bridge (PCIE port 0) [1022:9604] (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00003000-00004fff
	Memory behind bridge: 93100000-941fffff
	Prefetchable memory behind bridge: 0000000090000000-0000000090ffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag+ RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #1, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <64ns, L1 <1us
			ClockPM- Suprise- LLActRep+ BwNot+
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  4, PowerLimit 25.000000; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis- ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [a0] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable+
		Address: fee0300c  Data: 4151
	Capabilities: [b0] Subsystem: Hewlett-Packard Company Device [103c:30e4]
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100] Vendor Specific Information <?>
	Capabilities: [110] Virtual Channel <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
