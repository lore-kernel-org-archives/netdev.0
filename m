From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v3 1/2] realtek: convert to per-chip mask
Date: Thu, 25 Jul 2013 15:36:30 +0200
Message-ID: <1374759391-16916-2-git-send-email-lekensteyn@gmail.com>
References: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:52091 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab3GYNgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:36:43 -0400
Received: by mail-wi0-f172.google.com with SMTP id c10so5624195wiw.17
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:36:41 -0700 (PDT)
In-Reply-To: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous HW_REVID macro did not make identifiers more readable
(compared to hex values like 0x12345678) and only allowed for one static
mask. To make it easier to update the chips list, let's use similar
structures as r8169 and remove HW_REVID.

Names are removed and separated from the table and separated because the
mac_version does not have to be unique.

While at it, change "RTL-xxxx" to "RTLxxxx" to match the names of
Realtek and r8169 driver. Besides that, the only output change is when
a chip is not recognized in which case "TxConfig" is now mentioned
instead of "mask". Since the mask can be anything, the displayed word is
not masked either.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 realtek.c | 108 ++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 63 insertions(+), 45 deletions(-)

diff --git a/realtek.c b/realtek.c
index c3d7ae5..6365a96 100644
--- a/realtek.c
+++ b/realtek.c
@@ -5,13 +5,8 @@
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
-#define HW_REVID(b31, b30, b29, b28, b27, b26, b23, b22) \
-	(b31<<31 | b30<<30 | b29<<29 | b28<<28 | \
-	 b27<<27 | b26<<26 | b23<<23 | b22<<22)
-
 enum chip_type {
-	RTLNONE,
-	RTL8139,
+	RTL8139 = 1,
 	RTL8139_K,
 	RTL8139A,
 	RTL8139A_G,
@@ -22,6 +17,8 @@ enum chip_type {
 	RTL8100B_8139D,
 	RTL8139Cp,
 	RTL8101,
+
+	/* chips not handled by 8139too/8139cp module */
 	RTL8169,
 	RTL8169S,
 	RTL8110S,
@@ -35,36 +32,62 @@ enum chip_type {
 	RTL8100E2,
 };
 
-enum {
-	chip_type_mask = HW_REVID(1, 1, 1, 1, 1, 1, 1, 1)
+static const char * const chip_names[] = {
+	[RTL8139] =		"8139",
+	[RTL8139_K] =		"8139-K",
+	[RTL8139A] =		"8139A",
+	[RTL8139A_G] =		"8139A-G",
+	[RTL8139B] =		"8139B",
+	[RTL8130] =		"8130",
+	[RTL8139C] =		"8139C",
+	[RTL8100] =		"8100",
+	[RTL8100B_8139D] =	"8100B/8139D",
+	[RTL8139C] =		"8139C+",
+	[RTL8101] =		"8101",
+
+	/* chips not handled by 8139too/8139cp module */
+	[RTL8169] =		"8169",
+	[RTL8169S] =		"8169S",
+	[RTL8110S] =		"8110S",
+	[RTL8169_8110SB] =	"8169/8110SB",
+	[RTL8169_8110SCd] =	"8169/8110SCd",
+	[RTL8169_8110SCe] =	"8169/8110SCe",
+	[RTL8168_8111Bb] =	"8168/8111Bb",
+	[RTL8168_8111Bef] =	"8168/8111Bef",
+	[RTL8101Ebc] =		"8101Ebc",
+	[RTL8100E1] =		"8100E(1)",
+	[RTL8100E2] =		"8100E(2)",
 };
 
 static struct chip_info {
-	const char *name;
 	u32 id_mask;
+	u32 id_val;
+	int mac_version;
 } rtl_info_tbl[] = {
-	{ "RTL-8139",		HW_REVID(0, 1, 0, 0, 0, 0, 0, 0) },
-	{ "RTL-8139-K",		HW_REVID(0, 1, 1, 0, 0, 0, 0, 0) },
-	{ "RTL-8139A",		HW_REVID(0, 1, 1, 1, 0, 0, 0, 0) },
-	{ "RTL-8139A-G",	HW_REVID(0, 1, 1, 1, 0, 0, 1, 0) },
-	{ "RTL-8139B",		HW_REVID(0, 1, 1, 1, 1, 0, 0, 0) },
-	{ "RTL-8130",		HW_REVID(0, 1, 1, 1, 1, 1, 0, 0) },
-	{ "RTL-8139C",		HW_REVID(0, 1, 1, 1, 0, 1, 0, 0) },
-	{ "RTL-8100",		HW_REVID(0, 1, 1, 1, 1, 0, 1, 0) },
-	{ "RTL-8100B/8139D",	HW_REVID(0, 1, 1, 1, 0, 1, 0, 1) },
-	{ "RTL-8139C+",		HW_REVID(0, 1, 1, 1, 0, 1, 1, 0) },
-	{ "RTL-8101",		HW_REVID(0, 1, 1, 1, 0, 1, 1, 1) },
-	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0, 0) },
-	{ "RTL-8169S",		HW_REVID(0, 0, 0, 0, 0, 0, 1, 0) },
-	{ "RTL-8110S",		HW_REVID(0, 0, 0, 0, 0, 1, 0, 0) },
-	{ "RTL-8169/8110SB",	HW_REVID(0, 0, 0, 1, 0, 0, 0, 0) },
-	{ "RTL-8169/8110SCd",	HW_REVID(0, 0, 0, 1, 1, 0, 0, 0) },
-	{ "RTL-8169/8110SCe",	HW_REVID(1, 0, 0, 1, 1, 0, 0, 0) },
-	{ "RTL-8168/8111Bb",	HW_REVID(0, 0, 1, 1, 0, 0, 0, 0) },
-	{ "RTL-8168/8111Bef",	HW_REVID(0, 0, 1, 1, 1, 0, 0, 0) },
-	{ "RTL-8101Ebc",	HW_REVID(0, 0, 1, 1, 0, 1, 0, 0) },
-	{ "RTL-8100E(1)",	HW_REVID(0, 0, 1, 1, 0, 0, 1, 0) },
-	{ "RTL-8100E(2)",	HW_REVID(0, 0, 1, 1, 1, 0, 1, 0) },
+	{ 0xfcc00000, 0x40000000,	RTL8139 },
+	{ 0xfcc00000, 0x60000000,	RTL8139_K },
+	{ 0xfcc00000, 0x70000000,	RTL8139A },
+	{ 0xfcc00000, 0x70800000,	RTL8139A_G },
+	{ 0xfcc00000, 0x78000000,	RTL8139B },
+	{ 0xfcc00000, 0x7c000000,	RTL8130 },
+	{ 0xfcc00000, 0x74000000,	RTL8139C },
+	{ 0xfcc00000, 0x78800000,	RTL8100 },
+	{ 0xfcc00000, 0x74400000,	RTL8100B_8139D },
+	{ 0xfcc00000, 0x74800000,	RTL8139C },
+	{ 0xfcc00000, 0x74c00000,	RTL8101 },
+
+	/* chips not handled by 8139too/8139cp module */
+	{ 0xfcc00000, 0x00000000,	RTL8169 },
+	{ 0xfcc00000, 0x00800000,	RTL8169S },
+	{ 0xfcc00000, 0x04000000,	RTL8110S },
+	{ 0xfcc00000, 0x10000000,	RTL8169_8110SB },
+	{ 0xfcc00000, 0x18000000,	RTL8169_8110SCd },
+	{ 0xfcc00000, 0x68000000,	RTL8169_8110SCe },
+	{ 0xfcc00000, 0x30000000,	RTL8168_8111Bb },
+	{ 0xfcc00000, 0x38000000,	RTL8168_8111Bef },
+	{ 0xfcc00000, 0x34000000,	RTL8101Ebc },
+	{ 0xfcc00000, 0x30800000,	RTL8100E1 },
+	{ 0xfcc00000, 0x38800000,	RTL8100E2 },
 	{ }
 };
 
@@ -93,31 +116,26 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	u8 *data8 = (u8 *) regs->data;
 	u32 v;
 	struct chip_info *ci;
-	unsigned int board_type = RTLNONE, i;
+	unsigned int board_type;
 
-	v = data[0x40 >> 2] & chip_type_mask;
+	v = data[0x40 >> 2]; /* TxConfig */
 
 	ci = &rtl_info_tbl[0];
-	while (ci->name) {
-		if (v == ci->id_mask)
+	while (ci->mac_version) {
+		if ((v & ci->id_mask) == ci->id_val)
 			break;
 		ci++;
 	}
-	if (v != ci->id_mask) {
-		fprintf(stderr, "Unknown RealTek chip (mask: 0x%08x)\n", v);
+	board_type = ci->mac_version;
+	if (!board_type) {
+		fprintf(stderr, "Unknown RealTek chip (TxConfig: 0x%08x)\n", v);
 		return 91;
 	}
-	for (i = 0; i < ARRAY_SIZE(rtl_info_tbl); i++) {
-		if (ci == &rtl_info_tbl[i])
-			board_type = i + 1;
-	}
-	if (board_type == RTLNONE)
-		abort();
 
 	fprintf(stdout,
-		"RealTek %s registers:\n"
+		"RealTek RTL%s registers:\n"
 		"--------------------------------------------------------\n",
-		ci->name);
+		chip_names[board_type]);
 
 	fprintf(stdout,
 		"0x00: MAC Address                      %02x:%02x:%02x:%02x:%02x:%02x\n",
-- 
1.8.3.3
