From: Ed Swierk <eswierk@skyportsystems.com>
Subject: [PATCH v2] ethtool: Include SFP serial number and date in EEPROM dump
Date: Fri,  3 Apr 2015 06:44:57 -0700
Message-ID: <1428068697-67747-1-git-send-email-eswierk@skyportsystems.com>
Cc: Ed Swierk <eswierk@skyportsystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33681 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbDCNpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 09:45:09 -0400
Received: by pdbnk13 with SMTP id nk13so42188893pdb.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 06:45:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool -m currently omits the serial number, date code, and other useful
EEPROM fields defined in INF-8074, which is part of the SFF-8079 standard.
This patch adds them.

It also trims space characters from the end of ASCII text fields.

$ ethtool -m eth0
...
	Option values                             : 0x00 0x10
	Option                                    : TX_DISABLE implemented
	BR margin, max                            : 0%
	BR margin, min                            : 0%
	Vendor SN                                 : AGC143953079
	Date code                                 : 140926

Signed-off-by: Ed Swierk <eswierk@skyportsystems.com>
---
 sfpid.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/sfpid.c b/sfpid.c
index 4f88aa2..b1a5044 100644
--- a/sfpid.c
+++ b/sfpid.c
@@ -355,6 +355,8 @@ static void sff8079_show_ascii(const __u8 *id, unsigned int first_reg,
 	unsigned int reg, val;
 
 	printf("\t%-41s : ", name);
+	while (first_reg <= last_reg && id[last_reg] == ' ')
+		last_reg--;
 	for (reg = first_reg; reg <= last_reg; reg++) {
 		val = id[reg];
 		putchar(((val >= 32) && (val <= 126)) ? val : '_');
@@ -362,6 +364,40 @@ static void sff8079_show_ascii(const __u8 *id, unsigned int first_reg,
 	printf("\n");
 }
 
+static void sff8079_show_options(const __u8 *id)
+{
+	static const char *pfx =
+		"\tOption                                    :";
+
+	printf("\t%-41s : 0x%02x 0x%02x\n", "Option values", id[64], id[65]);
+	if (id[65] & (1 << 1))
+		printf("%s RX_LOS implemented\n", pfx);
+	if (id[65] & (1 << 2))
+		printf("%s RX_LOS implemented, inverted\n", pfx);
+	if (id[65] & (1 << 3))
+		printf("%s TX_FAULT implemented\n", pfx);
+	if (id[65] & (1 << 4))
+		printf("%s TX_DISABLE implemented\n", pfx);
+	if (id[65] & (1 << 5))
+		printf("%s RATE_SELECT implemented\n", pfx);
+	if (id[65] & (1 << 6))
+		printf("%s Tunable transmitter technology\n", pfx);
+	if (id[65] & (1 << 7))
+		printf("%s Receiver decision threshold implemented\n", pfx);
+	if (id[64] & (1 << 0))
+		printf("%s Linear receiver output implemented\n", pfx);
+	if (id[64] & (1 << 1))
+		printf("%s Power level 2 requirement\n", pfx);
+	if (id[64] & (1 << 2))
+		printf("%s Cooled transceiver implemented\n", pfx);
+	if (id[64] & (1 << 3))
+		printf("%s Retimer or CDR implemented\n", pfx);
+	if (id[64] & (1 << 4))
+		printf("%s Paging implemented\n", pfx);
+	if (id[64] & (1 << 5))
+		printf("%s Power level 3 requirement\n", pfx);
+}
+
 void sff8079_show_all(const __u8 *id)
 {
 	sff8079_show_identifier(id);
@@ -385,5 +421,10 @@ void sff8079_show_all(const __u8 *id)
 		sff8079_show_oui(id);
 		sff8079_show_ascii(id, 40, 55, "Vendor PN");
 		sff8079_show_ascii(id, 56, 59, "Vendor rev");
+		sff8079_show_options(id);
+		sff8079_show_value_with_unit(id, 66, "BR margin, max", 1, "%");
+		sff8079_show_value_with_unit(id, 67, "BR margin, min", 1, "%");
+		sff8079_show_ascii(id, 68, 83, "Vendor SN");
+		sff8079_show_ascii(id, 84, 91, "Date code");
 	}
 }
-- 
1.9.1
