From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: pci core driver fixes
Date: Thu, 9 Aug 2007 12:10:19 +0200
Message-ID: <200708091210.20176.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Aurelien Jarno <aurelien@aurel32.net>, netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42227
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764363AbXHIKKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 06:10:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aurelien Jarno <aurelien@aurel32.net>

Fixes various things on the SSB
PCI core driver:
 - Correctly write the configuration register value in 
   ssb_extpci_write_config() for len = 1 or len = 2.
 - Set the PCI_LATENCY_TIMER to handle devices on the PCI bus.
 - Set the PCI arbiter control to internal.
 - Add some delay between the configuration of the PCI controller 
   and its registration.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -99,6 +99,9 @@
 
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
+
+	/* Make sure our latency is high enough to handle the devices behind us */
+	pci_write_config_byte(dev, PCI_LATENCY_TIMER, 0xa8);
 }
 DECLARE_PCI_FIXUP_EARLY(PCI_ANY_ID, PCI_ANY_ID, ssb_fixup_pcibridge);
 
@@ -230,7 +233,7 @@
 		val = *((const u32 *)buf);
 		break;
 	}
-	writel(*((const u32 *)buf), mmio);
+	writel(val, mmio);
 
 	err = 0;
 unmap:
@@ -311,6 +314,8 @@
 	udelay(150); /* Assertion time demanded by the PCI standard */
 	val |= SSB_PCICORE_CTL_RST; /* Deassert RST# */
 	pcicore_write32(pc, SSB_PCICORE_CTL, val);
+	val = SSB_PCICORE_ARBCTL_INTERN;
+	pcicore_write32(pc, SSB_PCICORE_ARBCTL, val);
 	udelay(1); /* Assertion time demanded by the PCI standard */
 
 	/*TODO cardbus mode */
@@ -340,6 +345,9 @@
 	 * The following needs change, if we want to port hostmode
 	 * to non-MIPS platform. */
 	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x04000000));
+	/* Give some time to the PCI controller to configure itself with the new
+	 * values. Not waiting at this point causes crashes of the machine. */
+	mdelay(10);
 	register_pci_controller(&ssb_pcicore_controller);
 }
 
