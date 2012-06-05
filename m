From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH 1/2] Ethtool: Add EEE support
Date: Tue, 5 Jun 2012 09:41:09 +0300
Message-ID: <1338878470-24784-2-git-send-email-yuvalmin@broadcom.com>
References: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, peppe.cavallaro@st.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1390 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452Ab2FEGmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 02:42:50 -0400
In-Reply-To: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 2 new ethtool commands which can be
used to manipulate network interfaces' support in
EEE.

Output of 'get' has the following form:

	EEE Settings for p2p1:
		EEE status: enabled - active
		Tx LPI: 1000 (u)
		Supported EEE link modes:  10000baseT/Full
		Advertised EEE link modes:  10000baseT/Full
		Link partner advertised EEE link modes:  10000baseT/Full

Thanks goes to Giuseppe Cavallaro for his original patch.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 ethtool-copy.h |   15 ++++++
 ethtool.c      |  139 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 134 insertions(+), 20 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 9e26a76..1fcc799 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -133,6 +133,19 @@ struct ethtool_eeprom {
 	__u8	data[0];
 };
 
+/* EEE settings */
+struct ethtool_eee {
+	__u32	cmd;
+	__u32	supported;
+	__u32	advertised;
+	__u32	lp_advertised;
+	__u32	eee_active;
+	__u32	eee_enabled;
+	__u32	tx_lpi_enabled;
+	__u32	tx_lpi_timer;
+	__u32	reserved[2];
+};
+
 /**
  * struct ethtool_modinfo - plugin module eeprom information
  * @cmd: %ETHTOOL_GMODULEINFO
@@ -848,6 +861,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 #define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
 #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
+#define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
+#define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index f18f611..063e72b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -359,7 +359,8 @@ static int do_version(struct cmd_context *ctx)
 	return 0;
 }
 
-static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
+static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
+			    u8 all);
 
 static void dump_supported(struct ethtool_cmd *ep)
 {
@@ -378,14 +379,14 @@ static void dump_supported(struct ethtool_cmd *ep)
 		fprintf(stdout, "FIBRE ");
 	fprintf(stdout, "]\n");
 
-	dump_link_caps("Supported", "Supports", mask);
+	dump_link_caps("Supported", "Supports", mask, 1);
 }
 
 /* Print link capability flags (supported, advertised or lp_advertised).
  * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
  */
 static void
-dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
+dump_link_caps(const char *prefix, const char *an_prefix, u32 mask, u8 all)
 {
 	int indent;
 	int did1;
@@ -456,24 +457,26 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 		 fprintf(stdout, "Not reported");
 	fprintf(stdout, "\n");
 
-	fprintf(stdout, "	%s pause frame use: ", prefix);
-	if (mask & ADVERTISED_Pause) {
-		fprintf(stdout, "Symmetric");
-		if (mask & ADVERTISED_Asym_Pause)
-			fprintf(stdout, " Receive-only");
-		fprintf(stdout, "\n");
-	} else {
-		if (mask & ADVERTISED_Asym_Pause)
-			fprintf(stdout, "Transmit-only\n");
+	if (all) {
+		fprintf(stdout, "	%s pause frame use: ", prefix);
+		if (mask & ADVERTISED_Pause) {
+			fprintf(stdout, "Symmetric");
+			if (mask & ADVERTISED_Asym_Pause)
+				fprintf(stdout, " Receive-only");
+			fprintf(stdout, "\n");
+		} else {
+			if (mask & ADVERTISED_Asym_Pause)
+				fprintf(stdout, "Transmit-only\n");
+			else
+				fprintf(stdout, "No\n");
+		}
+
+		fprintf(stdout, "	%s auto-negotiation: ", an_prefix);
+		if (mask & ADVERTISED_Autoneg)
+			fprintf(stdout, "Yes\n");
 		else
 			fprintf(stdout, "No\n");
 	}
-
-	fprintf(stdout, "	%s auto-negotiation: ", an_prefix);
-	if (mask & ADVERTISED_Autoneg)
-		fprintf(stdout, "Yes\n");
-	else
-		fprintf(stdout, "No\n");
 }
 
 static int dump_ecmd(struct ethtool_cmd *ep)
@@ -481,10 +484,11 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	u32 speed;
 
 	dump_supported(ep);
-	dump_link_caps("Advertised", "Advertised", ep->advertising);
+	dump_link_caps("Advertised", "Advertised", ep->advertising, 1);
 	if (ep->lp_advertising)
 		dump_link_caps("Link partner advertised",
-			       "Link partner advertised", ep->lp_advertising);
+			       "Link partner advertised", ep->lp_advertising,
+			       1);
 
 	fprintf(stdout, "	Speed: ");
 	speed = ethtool_cmd_speed(ep);
@@ -1116,6 +1120,36 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+static int dump_eeecmd(struct ethtool_eee *ep)
+{
+
+	fprintf(stdout, "	EEE status: ");
+	if (!ep->supported) {
+		fprintf(stdout, "not supported\n");
+		return 0;
+	} else if (!ep->eee_enabled) {
+		fprintf(stdout, "disabled\n");
+	} else {
+		fprintf(stdout, "enabled - ");
+		if (ep->eee_active)
+			fprintf(stdout, "active\n");
+		else
+			fprintf(stdout, "inactive\n");
+	}
+
+	fprintf(stdout, "	Tx LPI:");
+	if (ep->tx_lpi_enabled)
+		fprintf(stdout, " %d (u)\n", ep->tx_lpi_timer);
+	else
+		fprintf(stdout, " disabled\n");
+
+	dump_link_caps("Supported EEE", "", ep->supported, 0);
+	dump_link_caps("Advertised EEE", "", ep->advertised, 0);
+	dump_link_caps("Link partner advertised EEE", "", ep->lp_advertised, 0);
+
+	return 0;
+}
+
 #define N_SOTS 7
 
 static char *so_timestamping_labels[N_SOTS] = {
@@ -3261,6 +3295,65 @@ static int do_getmodule(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_geee(struct cmd_context *ctx)
+{
+	struct ethtool_eee eeecmd;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	fprintf(stdout, "EEE Settings for %s:\n", ctx->devname);
+
+	eeecmd.cmd = ETHTOOL_GEEE;
+	if (send_ioctl(ctx, &eeecmd)) {
+		perror("Cannot get EEE settings");
+		return 1;
+	}
+
+	if (dump_eeecmd(&eeecmd))
+		return 1;
+
+	return 0;
+}
+
+static int do_seee(struct cmd_context *ctx)
+{
+	int adv_c = -1, lpi_c = -1, lpi_time_c = -1, eee_c = -1;
+	int change = -1, change2 = -1;
+	struct ethtool_eee eeecmd;
+	struct cmdline_info cmdline_eee[] = {
+		{ "advertise",    CMDL_U32,  &adv_c,       &eeecmd.advertised },
+		{ "tx-lpi",       CMDL_BOOL, &lpi_c,   &eeecmd.tx_lpi_enabled },
+		{ "tx-timer",	  CMDL_U32,  &lpi_time_c, &eeecmd.tx_lpi_timer},
+		{ "eee",	  CMDL_BOOL, &eee_c,	   &eeecmd.eee_enabled},
+	};
+
+	if (ctx->argc == 0)
+		exit_bad_args();
+
+	parse_generic_cmdline(ctx, &change, cmdline_eee,
+			      ARRAY_SIZE(cmdline_eee));
+
+	eeecmd.cmd = ETHTOOL_GEEE;
+	if (send_ioctl(ctx, &eeecmd)) {
+		perror("Cannot get EEE settings");
+		return 1;
+	}
+
+	do_generic_set(cmdline_eee, ARRAY_SIZE(cmdline_eee), &change2);
+
+	if (change2) {
+
+		eeecmd.cmd = ETHTOOL_SEEE;
+		if (send_ioctl(ctx, &eeecmd)) {
+			perror("Cannot set EEE settings");
+			return 1;
+		}
+	}
+
+	return 1;
+}
+
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
 #ifndef TEST_ETHTOOL
@@ -3423,6 +3516,12 @@ static const struct option {
 	  "		[ hex on|off ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n" },
+	{ "--get-eee", 1, do_geee, "Get EEE settings"},
+	{ "--set-eee", 1, do_seee, "Set EEE settings",
+	  "		[ eee on|off ]\n"
+	  "		[ advertise %x ]\n"
+	  "		[ tx-lpi on|off ]\n"
+	  "		[ tx-timer %x ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
1.7.9.rc2
