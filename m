From: Michael Mueller <malware@t-online.de>
Subject: [PATCH] Making de2104x working with BNC connection on 21040 chipset
Date: Thu, 12 Jan 2012 23:52:11 +0100
Message-ID: <4F0F641B.5090407@t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010406050508040906050906"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout07.t-online.de ([194.25.134.83]:59207 "EHLO
	mailout07.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab2ALWwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 17:52:16 -0500
Received: from debian.malware.de ([192.168.2.4])
	by gateway.malware.de with esmtp (Exim 3.36 #1 (Debian))
	id 1RlTVE-0004AD-00
	for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:52:12 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010406050508040906050906
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi,

while I recently updated an older machine to the latest Debian
distribution which included updating the kernel from 2.4.x to 3.0 the
tulip driver did stop working for my network card. The replacement
driver de2104x did initialize the network interfaces but no transmission
was possible.

Digging into it I found the de2104x driver just assumes there is no BNC
transceiver on a card using the 21040 chipset. So I extracted the
correct configuration values from the old tulip driver and removed some
sanity checking which denied setting the transceiver to BNC. Now I can
use the driver by just setting the correct transceiver using ethtool.

A patch against 3.0 is appended. It should apply against more recent
versions too since there was not the lot happening for this old driver,
but for the relocation of the files from drivers/net/tulip to
drivers/net/ethernet/dec/tulip.


Michael


--------------010406050508040906050906
Content-Type: text/x-patch;
 name="de21040_bnc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="de21040_bnc.patch"

--- drivers/net/tulip/de2104x.c.orig	2012-01-12 23:12:31.000000000 +0100
+++ drivers/net/tulip/de2104x.c	2012-01-12 23:15:52.000000000 +0100
@@ -358,10 +358,10 @@
 };
 
 /* 21040 transceiver register settings:
- * TP AUTO(unused), BNC(unused), AUI, TP, TP FD*/
-static u16 t21040_csr13[] = { 0, 0, 0x8F09, 0x8F01, 0x8F01, };
-static u16 t21040_csr14[] = { 0, 0, 0x0705, 0xFFFF, 0xFFFD, };
-static u16 t21040_csr15[] = { 0, 0, 0x0006, 0x0000, 0x0000, };
+ * TP AUTO(unused), BNC, AUI, TP, TP FD*/
+static u16 t21040_csr13[] = { 0, 0x8F0D, 0x8F09, 0x8F01, 0x8F01, };
+static u16 t21040_csr14[] = { 0, 0x0705, 0x0705, 0xFFFF, 0xFFFD, };
+static u16 t21040_csr15[] = { 0, 0x0006, 0x0006, 0x0000, 0x0000, };
 
 /* 21041 transceiver register settings: TP AUTO, BNC, AUI, TP, TP FD*/
 static u16 t21041_csr13[] = { 0xEF01, 0xEF09, 0xEF09, 0xEF01, 0xEF09, };
@@ -975,7 +975,7 @@
 	carrier = (status & NetCxnErr) ? 0 : 1;
 
 	if (carrier) {
-		if (de->media_type != DE_MEDIA_AUI && (status & LinkFailStatus))
+		if (de->media_type != DE_MEDIA_AUI && de->media_type != DE_MEDIA_BNC && (status & LinkFailStatus))
 			goto no_link_yet;
 
 		de->media_timer.expires = jiffies + DE_TIMER_LINK;
@@ -1536,8 +1536,6 @@
 		return -EINVAL;
 	if (ecmd->port != PORT_TP && ecmd->port != PORT_AUI && ecmd->port != PORT_BNC)
 		return -EINVAL;
-	if (de->de21040 && ecmd->port == PORT_BNC)
-		return -EINVAL;
 	if (ecmd->transceiver != XCVR_INTERNAL)
 		return -EINVAL;
 	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
@@ -1731,12 +1729,14 @@
 
 	de->media_type = DE_MEDIA_TP;
 	de->media_supported |= SUPPORTED_TP | SUPPORTED_10baseT_Full |
-			       SUPPORTED_10baseT_Half | SUPPORTED_AUI;
+			       SUPPORTED_10baseT_Half | SUPPORTED_AUI |
+			       SUPPORTED_BNC;
 	de->media_advertise = de->media_supported;
 
 	for (i = 0; i < DE_MAX_MEDIA; i++) {
 		switch (i) {
 		case DE_MEDIA_AUI:
+		case DE_MEDIA_BNC:
 		case DE_MEDIA_TP:
 		case DE_MEDIA_TP_FD:
 			de->media[i].type = i;

--------------010406050508040906050906--
