From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44: high ping times with wireless-dev
Date: Sun, 17 Jun 2007 12:55:39 +0200
Message-ID: <200706171255.40155.mb@bu3sch.de>
References: <200706162327.47413.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_sMRdGkaeTtd3/Dk"
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-wireless" <linux-wireless@vger.kernel.org>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41206
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759583AbXFQK6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 06:58:20 -0400
In-Reply-To: <200706162327.47413.maxi@daemonizer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_sMRdGkaeTtd3/Dk
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Saturday 16 June 2007 23:27:43 Maximilian Engelhardt wrote:
> [...]
> ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
> ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low) -> 
> IRQ 10
> ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
> b44.c:v2.0
> eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
> [...]

Ok, I prepared two debugging patches.

Please enable SonicsSiliconBackplane Debugging in the kernel kconfig,
so I can get more detail information about your card.
Device Drivers/Sonics Silicon Backplane/SSB debugging
(Must disable "No SSB kernel messages")

Please apply and test the attached debugging patches in a row.
So apply patch 1 and test if it works again. If not, apply
patch 2 and test if it works.
Always save complete dmesg log on each test run and send it to me.

Thanks for testing.
(This time it seems we are actually getting somewhere, when
dealing with sane people. :D )

-- 
Greetings Michael.

--Boundary-00=_sMRdGkaeTtd3/Dk
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="b44-irqs-test1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="b44-irqs-test1.patch"

Index: bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/ssb/driver_pcicore.c	2007-04-07 17:19:03.000000000 +0200
+++ bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c	2007-06-17 12:51:37.000000000 +0200
@@ -477,6 +477,7 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 		goto out;
 	bus = pdev->bus;
 
+printk("Enabling IRQ vectors\n");
 	/* Enable interrupts for this device. */
 	if (bus->host_pci &&
 	    ((pdev->id.revision >= 6) || (pdev->id.coreid == SSB_DEV_PCIE))) {
@@ -497,8 +498,10 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 
 		intvec = ssb_read32(pdev, SSB_INTVEC);
 		tmp = ssb_read32(dev, SSB_TPSFLAG);
+printk("Writing INTVEC. TPSFLAG is 0x%08X\n", tmp);
 		tmp &= SSB_TPSFLAG_BPFLAG;
-		intvec |= tmp;
+//		intvec |= tmp;
+intvec |= 0x00000002;
 		ssb_write32(pdev, SSB_INTVEC, intvec);
 	}
 

--Boundary-00=_sMRdGkaeTtd3/Dk
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="b44-irqs-test2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="b44-irqs-test2.patch"

Index: bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/ssb/driver_pcicore.c	2007-06-17 12:50:32.000000000 +0200
+++ bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c	2007-06-17 12:51:32.000000000 +0200
@@ -514,6 +514,8 @@ intvec |= 0x00000002;
 		tmp |= SSB_PCICORE_SBTOPCI_BURST;
 		pcicore_write32(pc, SSB_PCICORE_SBTOPCI2, tmp);
 
+printk("Wrote translation\n");
+#if 0
 		if (pdev->id.revision < 5) {
 			tmp = ssb_read32(pdev, SSB_IMCFGLO);
 			tmp &= ~SSB_IMCFGLO_SERTO;
@@ -527,6 +529,7 @@ intvec |= 0x00000002;
 			tmp |= SSB_PCICORE_SBTOPCI_MRM;
 			pcicore_write32(pc, SSB_PCICORE_SBTOPCI2, tmp);
 		}
+#endif
 	} else {
 		assert(pdev->id.coreid == SSB_DEV_PCIE);
 		//TODO: Better make defines for all these magic PCIE values.

--Boundary-00=_sMRdGkaeTtd3/Dk--
