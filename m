From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool -E rejects magic >= 80000000
Date: Mon, 06 Jun 2011 11:50:36 +0100
Message-ID: <1307357436.2765.20.camel@bwh-desktop>
References: <4DECA785.7070207@LiPPERTEmbedded.de>
	 <1307355820.2765.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Zkt6kqnQ/H0fyPBHCfK3"
Cc: Martin Hein <MHein@LiPPERTEmbedded.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38992 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab1FFKuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 06:50:39 -0400
In-Reply-To: <1307355820.2765.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--=-Zkt6kqnQ/H0fyPBHCfK3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Please can you test the attached patch on top of the git repository
<git://git.kernel.org/pub/scm/network/ethtool/ethtool.git> or ethtool
2.6.39.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-Zkt6kqnQ/H0fyPBHCfK3
Content-Disposition: attachment; filename*0=0001-Correct-parameter-types-for-ethtool-e-and-ethtool-E.patc; filename*1=h
Content-Type: text/x-patch; name="0001-Correct-parameter-types-for-ethtool-e-and-ethtool-E.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From ed7fba4e03c39365affbae4ec4f6401b55cfd80b Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 6 Jun 2011 11:35:19 +0100
Subject: [PATCH ethtool] Correct parameter types for ethtool -e and ethtool
 -E
To: netdev@vger.kernel.org
Cc: linux-net-drivers@solarflare.com

All parameters to the underlying ethtool commands are unsigned, not
signed.  In particular, the 'magic' parameter to ethtool -E often has
the most significant bit set and users should not have to provide it
as a negative number.

For ethtool -E, the value to be written is 8-bit, not 32-bit.

Reported-by: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index edfbe3d..288b93f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -365,13 +365,14 @@ static int gregs_dump_hex = 0;
 static char *gregs_dump_file = NULL;
 static int geeprom_changed = 0;
 static int geeprom_dump_raw = 0;
-static s32 geeprom_offset = 0;
-static s32 geeprom_length = -1;
+static u32 geeprom_offset = 0;
+static u32 geeprom_length = -1;
 static int seeprom_changed = 0;
-static s32 seeprom_magic = 0;
-static s32 seeprom_length = -1;
-static s32 seeprom_offset = 0;
-static s32 seeprom_value = EOF;
+static u32 seeprom_magic = 0;
+static u32 seeprom_length = -1;
+static u32 seeprom_offset = 0;
+static u8 seeprom_value = 0;
+static int seeprom_value_seen = 0;
 static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
@@ -400,6 +401,7 @@ typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
 	CMDL_S32,
+	CMDL_U8,
 	CMDL_U16,
 	CMDL_U32,
 	CMDL_U64,
@@ -433,16 +435,17 @@ static struct cmdline_info cmdline_gregs[] = {
 };
 
 static struct cmdline_info cmdline_geeprom[] = {
-	{ "offset", CMDL_S32, &geeprom_offset, NULL },
-	{ "length", CMDL_S32, &geeprom_length, NULL },
+	{ "offset", CMDL_U32, &geeprom_offset, NULL },
+	{ "length", CMDL_U32, &geeprom_length, NULL },
 	{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
 };
 
 static struct cmdline_info cmdline_seeprom[] = {
-	{ "magic", CMDL_S32, &seeprom_magic, NULL },
-	{ "offset", CMDL_S32, &seeprom_offset, NULL },
-	{ "length", CMDL_S32, &seeprom_length, NULL },
-	{ "value", CMDL_S32, &seeprom_value, NULL },
+	{ "magic", CMDL_U32, &seeprom_magic, NULL },
+	{ "offset", CMDL_U32, &seeprom_offset, NULL },
+	{ "length", CMDL_U32, &seeprom_length, NULL },
+	{ "value", CMDL_U8, &seeprom_value, NULL,
+	  0, &seeprom_value_seen },
 };
 
 static struct cmdline_info cmdline_offload[] = {
@@ -614,6 +617,11 @@ static void parse_generic_cmdline(int argc, char **argp,
 							   0x7fffffff);
 					break;
 				}
+				case CMDL_U8: {
+					u8 *p = info[idx].wanted_val;
+					*p = get_uint_range(argp[i], 0, 0xff);
+					break;
+				}
 				case CMDL_U16: {
 					u16 *p = info[idx].wanted_val;
 					*p = get_uint_range(argp[i], 0, 0xffff);
@@ -2626,7 +2634,7 @@ static int do_geeprom(int fd, struct ifreq *ifr)
 		return 74;
 	}
 
-	if (geeprom_length <= 0)
+	if (geeprom_length == -1)
 		geeprom_length = drvinfo.eedump_len;
 
 	if (drvinfo.eedump_len < geeprom_offset + geeprom_length)
@@ -2667,10 +2675,10 @@ static int do_seeprom(int fd, struct ifreq *ifr)
 		return 74;
 	}
 
-	if (seeprom_value != EOF)
+	if (seeprom_value_seen)
 		seeprom_length = 1;
 
-	if (seeprom_length <= 0)
+	if (seeprom_length == -1)
 		seeprom_length = drvinfo.eedump_len;
 
 	if (drvinfo.eedump_len < seeprom_offset + seeprom_length)
@@ -2689,7 +2697,7 @@ static int do_seeprom(int fd, struct ifreq *ifr)
 	eeprom->data[0] = seeprom_value;
 
 	/* Multi-byte write: read input from stdin */
-	if (seeprom_value == EOF)
+	if (!seeprom_value_seen)
 		eeprom->len = fread(eeprom->data, 1, eeprom->len, stdin);
 
 	ifr->ifr_data = (caddr_t)eeprom;
-- 
1.7.4.4


--=-Zkt6kqnQ/H0fyPBHCfK3--

