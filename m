From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH] SSB PCI core driver fixes
Date: Thu, 9 Aug 2007 02:23:53 +0200
Message-ID: <20070809002353.GA4594@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:33546 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763827AbXHIAXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 20:23:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below against 2.6.23-rc1-mm2 fixes various things on the SSB
PCI core driver:
 - Correctly write the configuration register value in 
   ssb_extpci_write_config() for len = 1 or len = 2.
 - Set the PCI latency timer to handle devices on the PCI bus.
 - Set the PCI arbiter control to internal.
 - Add some delay between the configuration of the PCI controller 
   and its registration.

Note: this is the latest SSB patch from my local tree. Next ones are 
only BCM947xx or CFE related.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

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
@@ -340,6 +345,7 @@
 	 * The following needs change, if we want to port hostmode
 	 * to non-MIPS platform. */
 	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x04000000));
+	mdelay(300);
 	register_pci_controller(&ssb_pcicore_controller);
 }

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
