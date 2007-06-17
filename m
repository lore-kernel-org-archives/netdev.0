From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44-ssb: Fix IRQ routing bits on the backplane
Date: Sun, 17 Jun 2007 14:52:38 +0200
Message-ID: <200706171452.38383.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Maximilian Engelhardt <maxi@daemonizer.de>,
	Gary Zambrano <zambrano@broadcom.com>
To: John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56697
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133AbXFQM7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 08:59:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The backplane on the b44 chip seems to have a silicon bug
in the IRQ routing. The ethernet core IRQ routing does not work
with the routing bit returned from the backplaneflag register.
This patch adds a workaround for the b44 chip to use a hardcoded
constant. This constant was also used in the old b44 driver.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: Maximilian Engelhardt <maxi@daemonizer.de>
Cc: Gary Zambrano <zambrano@broadcom.com>

Index: bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/ssb/driver_pcicore.c	2007-06-17 13:35:45.000000000 +0200
+++ bu3sch-wireless-dev/drivers/ssb/driver_pcicore.c	2007-06-17 14:19:05.000000000 +0200
@@ -496,9 +496,15 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 		u32 intvec;
 
 		intvec = ssb_read32(pdev, SSB_INTVEC);
-		tmp = ssb_read32(dev, SSB_TPSFLAG);
-		tmp &= SSB_TPSFLAG_BPFLAG;
-		intvec |= tmp;
+		if ((bus->chip_id & 0xFF00) == 0x4400) {
+			/* Workaround: On the BCM44XX the BPFLAG routing
+			 * bit is wrong. Use a hardcoded constant. */
+			intvec |= 0x00000002;
+		} else {
+			tmp = ssb_read32(dev, SSB_TPSFLAG);
+			tmp &= SSB_TPSFLAG_BPFLAG;
+			intvec |= tmp;
+		}
 		ssb_write32(pdev, SSB_INTVEC, intvec);
 	}

 
Please apply this to wireless-dev.
This is also most likely the bug Uwe Bugla was
bullshitting about^W^Wreporting.

-- 
Greetings Michael.
