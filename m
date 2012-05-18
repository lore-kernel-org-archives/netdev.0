From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [PATCH 1/3] ethtool: Split out printing of hex data
Date: Fri, 18 May 2012 15:58:24 +0100
Message-ID: <4FB66390.2010704@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Yaniv Rosner <yanivr@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58869 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750835Ab2ERO61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 10:58:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split out printing of hex data to common function from
dump_regs and dump_eeprom. Ready for use by module
eeprom dumping.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
 ethtool.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index e80b38b..fdc21de 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -787,6 +787,20 @@ static const struct {
 	{ "st_gmac", st_gmac_dump_regs },
 };
 
+static void dump_hex(__u8 *data, int len, int offset)
+{
+	int i;
+
+	fprintf(stdout, "Offset\tValues\n");
+	fprintf(stdout, "--------\t-----");
+	for (i = 0; i < len; i++) {
+		if (i%16 == 0)
+			fprintf(stdout, "\n0x%04x:\t", i + offset);
+		fprintf(stdout, " %02x", data[i]);
+	}
+	fprintf(stdout, "\n\n");
+}
+
 static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
 		     const char *gregs_dump_file,
 		     struct ethtool_drvinfo *info, struct ethtool_regs *regs)
@@ -820,22 +834,14 @@ static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
 				     ETHTOOL_BUSINFO_LEN))
 				return driver_list[i].func(info, regs);
 
-	fprintf(stdout, "Offset\tValues\n");
-	fprintf(stdout, "--------\t-----");
-	for (i = 0; i < regs->len; i++) {
-		if (i%16 == 0)
-			fprintf(stdout, "\n%03x:\t", i);
-		fprintf(stdout, " %02x", regs->data[i]);
-	}
-	fprintf(stdout, "\n\n");
+	dump_hex(regs->data, regs->len, 0);
+
 	return 0;
 }
 
 static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 		       struct ethtool_eeprom *ee)
 {
-	int i;
-
 	if (geeprom_dump_raw) {
 		fwrite(ee->data, 1, ee->len, stdout);
 		return 0;
@@ -847,13 +853,8 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 		return tg3_dump_eeprom(info, ee);
 	}
 
-	fprintf(stdout, "Offset\t\tValues\n");
-	fprintf(stdout, "------\t\t------");
-	for (i = 0; i < ee->len; i++) {
-		if(!(i%16)) fprintf(stdout, "\n0x%04x\t\t", i + ee->offset);
-		fprintf(stdout, "%02x ", ee->data[i]);
-	}
-	fprintf(stdout, "\n");
+	dump_hex(ee->data, ee->len, ee->offset);
+
 	return 0;
 }
 
-- 
1.7.7.6
