From: Michael Buesch <mb@bu3sch.de>
Subject: b44-ssb: Fix an invalid pointer casting
Date: Mon, 28 May 2007 00:32:07 +0200
Message-ID: <200705280032.07365.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Maximilian Engelhardt <maxi@daemonizer.de>,
	Gary Zambrano <zambrano@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46769
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbXE0Wee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 18:34:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a bug introduced by me with the ssb porting.
A u32 integer is casted to a u16* pointer, which
is gonna break, obviously.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: bu3sch-wireless-dev/drivers/net/b44.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/b44.c	2007-05-28 00:30:00.000000000 +0200
+++ bu3sch-wireless-dev/drivers/net/b44.c	2007-05-28 00:31:32.000000000 +0200
@@ -1568,6 +1568,22 @@ static void b44_setup_pseudo_magicp(stru
 
 }
 
+#ifdef CONFIG_B44_PCI
+static void b44_setup_wol_pci(struct b44 *bp)
+{
+	u16 val;
+
+	if (bp->sdev->bus->bustype != SSB_BUSTYPE_SSB) {
+		val = br32(bp, SSB_TMSLOW);
+		bw32(bp, SSB_TMSLOW, val | SSB_TMSLOW_PE);
+		pci_read_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, &val);
+		pci_write_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, val | SSB_PE);
+	}
+}
+#else
+static inline void b44_setup_wol_pci(struct b44 *bp) { }
+#endif /* CONFIG_B44_PCI */
+
 static void b44_setup_wol(struct b44 *bp)
 {
 	u32 val;
@@ -1594,15 +1610,7 @@ static void b44_setup_wol(struct b44 *bp
  	} else {
  		b44_setup_pseudo_magicp(bp);
  	}
-
-#ifdef CONFIG_B44_PCI
-	if (bp->sdev->bus->bustype != SSB_BUSTYPE_SSB) {
-		val = br32(bp, SSB_TMSLOW);
-		bw32(bp, SSB_TMSLOW, val | SSB_TMSLOW_PE);
-	}
-	pci_read_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, (u16 *)(&val));
-	pci_write_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, val | SSB_PE);
-#endif /* CONFIG_B44_PCI */
+	b44_setup_wol_pci(bp);
 }
 
 static int b44_close(struct net_device *dev)


-- 
Greetings Michael.
