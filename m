From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] ethtool: Uncook tg3 regdump output
Date: Wed, 31 Aug 2011 19:02:37 -0700
Message-ID: <1314842557-32247-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4964 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994Ab1HaWN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 18:13:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3 devices have changed a lot since the bcm5700 days.  Register blocks
have been added, removed and redefined.  The existing tg3 register dump
code has not kept up.

This patch changes the tg3_dump_regs() function to be more simplistic.
Rather than attempting to locate where meaningful data is, it will
instead print the registers as 32-bit values, omitting all registers
that have a value of zero.  By performing the output this way, we hope
to future-proof the interface.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 tg3.c |   30 +++++++-----------------------
 1 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/tg3.c b/tg3.c
index 1ce07a8..4868504 100644
--- a/tg3.c
+++ b/tg3.c
@@ -26,32 +26,16 @@ tg3_dump_eeprom(struct ethtool_drvinfo *info, struct ethtool_eeprom *ee)
 int
 tg3_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
-	int i, j;
-	int reg_boundaries[] = { 0x015c, 0x0200, 0x0400, 0x0400, 0x08f0, 0x0c00,
-	       			 0x0ce0, 0x1000, 0x1004, 0x1400, 0x1480, 0x1800,
-				 0x1848, 0x1c00, 0x1c04, 0x2000, 0x225c, 0x2400,
-				 0x24c4, 0x2800, 0x2804, 0x2c00, 0x2c20, 0x3000,
-				 0x3014, 0x3400, 0x3408, 0x3800, 0x3808, 0x3c00,
-				 0x3d00, 0x4000, 0x4010, 0x4400, 0x4458, 0x4800,
-				 0x4808, 0x4c00, 0x4c08, 0x5000, 0x5280, 0x5400,
-				 0x5680, 0x5800, 0x5a10, 0x5c00, 0x5d20, 0x6000,
-				 0x600c, 0x6800, 0x6848, 0x7000, 0x7034, 0x7c00,
-				 0x7e40, 0x8000 };
+	int i;
+	u32 reg;
 
 	fprintf(stdout, "Offset\tValue\n");
 	fprintf(stdout, "------\t----------\n");
-	for (i = 0, j = 0; i < regs->len; ) {
-		u32 reg;
-
-		memcpy(&reg, &regs->data[i], 4);
-		fprintf(stdout, "0x%04x\t0x%08x\n", i, reg);
-
-		i += 4;
-		if (i == reg_boundaries[j]) {
-			i = reg_boundaries[j + 1];
-			j += 2;
-			fprintf(stdout, "\n");
-		}
+	for (i = 0; i < regs->len; i += sizeof(reg)) {
+		memcpy(&reg, &regs->data[i], sizeof(reg));
+		if (reg)
+			fprintf(stdout, "0x%04x\t0x%08x\n", i, reg);
+
 	}
 	fprintf(stdout, "\n");
 	return 0;
-- 
1.7.3.4
