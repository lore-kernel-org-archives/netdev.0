From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] sky2: fix ram buffer allocation settings
Date: Fri, 23 Feb 2007 15:10:43 -0800
Message-ID: <20070223231353.141448000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40966 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933267AbXBWXRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:25 -0500
Content-Disposition: inline; filename=sky2-ramset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different chipsets have different amount of ram buffer (some have none),
so need to make sure that driver does proper setup for all cases from 0 on
to 48K, in units of 1K.

This is a backport of the code from 2.6.19 or later

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:38:11.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:44:46.000000000 -0800
@@ -670,12 +670,13 @@
  * start and end are in units of 4k bytes
  * ram registers are in units of 64bit words
  */
-static void sky2_ramset(struct sky2_hw *hw, u16 q, u8 startk, u8 endk)
+static void sky2_ramset(struct sky2_hw *hw, u16 q, u32 start, u32 space)
 {
-	u32 start, end;
+	u32 end;
 
-	start = startk * 4096/8;
-	end = (endk * 4096/8) - 1;
+	start *= 1024/8;
+	space *= 1024/8;
+	end = start + space - 1;
 
 	sky2_write8(hw, RB_ADDR(q, RB_CTRL), RB_RST_CLR);
 	sky2_write32(hw, RB_ADDR(q, RB_START), start);
@@ -684,7 +685,6 @@
 	sky2_write32(hw, RB_ADDR(q, RB_RP), start);
 
 	if (q == Q_R1 || q == Q_R2) {
-		u32 space = (endk - startk) * 4096/8;
 		u32 tp = space - space/4;
 
 		/* On receive queue's set the thresholds
@@ -1081,23 +1081,21 @@
 
 	sky2_mac_init(hw, port);
 
-	/* Determine available ram buffer space (in 4K blocks).
-	 * Note: not sure about the FE setting below yet
-	 */
-	if (hw->chip_id == CHIP_ID_YUKON_FE)
-		ramsize = 4;
-	else
-		ramsize = sky2_read8(hw, B2_E_0);
-
-	/* Give transmitter one third (rounded up) */
-	rxspace = ramsize - (ramsize + 2) / 3;
+	/* Determine available ram buffer space (in 4K blocks). */
+	ramsize = sky2_read8(hw, B2_E_0) * 4;
+	if (ramsize != 0) {
+		if (ramsize < 16)
+			rxspace = ramsize / 2;
+		else
+			rxspace = 8 + (2*(ramsize - 16))/3;
 
-	sky2_ramset(hw, rxqaddr[port], 0, rxspace);
-	sky2_ramset(hw, txqaddr[port], rxspace, ramsize);
+		sky2_ramset(hw, rxqaddr[port], 0, rxspace);
+		sky2_ramset(hw, txqaddr[port], rxspace, ramsize - rxspace);
 
-	/* Make sure SyncQ is disabled */
-	sky2_write8(hw, RB_ADDR(port == 0 ? Q_XS1 : Q_XS2, RB_CTRL),
-		    RB_RST_SET);
+		/* Make sure SyncQ is disabled */
+		sky2_write8(hw, RB_ADDR(port == 0 ? Q_XS1 : Q_XS2, RB_CTRL),
+			    RB_RST_SET);
+	}
 
 	sky2_qset(hw, txqaddr[port]);
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

