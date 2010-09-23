From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] de2104x: disable autonegotiation on broken hardware
Date: Thu, 23 Sep 2010 22:59:18 +0200
Message-ID: <201009232259.20261.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least on older 21041-AA chips (mine is rev. 11), TP duplex autonegotiation
causes the card not to work at all (link is up but no packets are transmitted).

de4x5 disables autonegotiation completely. But it seems to work on newer
(21041-PA rev. 21) so disable it only on rev<20 chips.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-orig/drivers/net/tulip/de2104x.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c	2010-09-24 00:27:41.000000000 +0200
@@ -364,6 +364,8 @@ static u16 t21040_csr15[] = { 0, 0, 0x00
 /* 21041 transceiver register settings: TP AUTO, BNC, AUI, TP, TP FD*/
 static u16 t21041_csr13[] = { 0xEF01, 0xEF09, 0xEF09, 0xEF01, 0xEF09, };
 static u16 t21041_csr14[] = { 0xFFFF, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, };
+/* If on-chip autonegotiation is broken, use half-duplex (FF3F) instead */
+static u16 t21041_csr14_brk[] = { 0xFF3F, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, };
 static u16 t21041_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 
 
@@ -1911,8 +1913,14 @@ fill_defaults:
 	for (i = 0; i < DE_MAX_MEDIA; i++) {
 		if (de->media[i].csr13 == 0xffff)
 			de->media[i].csr13 = t21041_csr13[i];
-		if (de->media[i].csr14 == 0xffff)
-			de->media[i].csr14 = t21041_csr14[i];
+		if (de->media[i].csr14 == 0xffff) {
+			/* autonegotiation is broken at least on some chip
+			   revisions - rev. 0x21 works, 0x11 does not */
+			if (de->pdev->revision < 0x20)
+				de->media[i].csr14 = t21041_csr14_brk[i];
+			else
+				de->media[i].csr14 = t21041_csr14[i];
+		}
 		if (de->media[i].csr15 == 0xffff)
 			de->media[i].csr15 = t21041_csr15[i];
 	}


-- 
Ondrej Zary
