From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH 1/1 v2] Ethtool: Add EEE support
Date: Wed, 6 Jun 2012 22:15:24 +0300
Message-ID: <1339010124-23413-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, peppe.cavallaro@st.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2697 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757520Ab2FFTQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 15:16:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 2 new ethtool commands which can be
used to manipulate network interfaces' support in
EEE.

Output of 'get' has the following form:

	EEE Settings for p2p1:
		EEE status: enabled - active
		Tx LPI: 1000 (us)
		Supported EEE link modes:  10000baseT/Full
		Advertised EEE link modes:  10000baseT/Full
		Link partner advertised EEE link modes:  10000baseT/Full

Thanks goes to Giuseppe Cavallaro for his original patch.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 ethtool-copy.h |   31 +++++++++++++
 ethtool.8.in   |   32 +++++++++++++
 ethtool.c      |  137 +++++++++++++++++++++++++++++++++++++++++++++++--------
 test-cmdline.c |   11 +++++
 4 files changed, 191 insertions(+), 20 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 9e26a76..070f702 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -134,6 +134,35 @@ struct ethtool_eeprom {
 };
 
 /**
+ * struct ethtool_eee - Energy Efficient Ethernet information
+ * @cmd: ETHTOOL_{G,S}EEE
+ * @supported: Mask of %SUPPORTED_* flags for the speed/duplex combinations
+ *	for which there is EEE support.
+ * @advertised: Mask of %ADVERTISED_* flags for the speed/duplex combinations
+ *	advertised as eee capable.
+ * @lp_advertised: Mask of %ADVERTISED_* flags for the speed/duplex
+ *	combinations advertised by the link partner as eee capable.
+ * @eee_active: Result of the eee auto negotiation.
+ * @eee_enabled: EEE configured mode (enabled/disabled).
+ * @tx_lpi_enabled: Whether the interface should assert its tx lpi, given
+ *	that eee was negotiated.
+ * @tx_lpi_timer: Time in microseconds the interface delays prior to asserting
+ *	its tx lpi (after reaching 'idle' state). Effective only when eee
+ *	was negotiated and tx_lpi_enabled was set.
+ */
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
+/**
  * struct ethtool_modinfo - plugin module eeprom information
  * @cmd: %ETHTOOL_GMODULEINFO
  * @type: Standard the module information conforms to %ETH_MODULE_SFF_xxxx
@@ -848,6 +877,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 #define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
 #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
+#define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
+#define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8.in b/ethtool.8.in
index 523b737..b906d8e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -335,6 +335,16 @@ ethtool \- query or control network driver and hardware settings
 .I devname flag
 .A1 on off
 .RB ...
+.HP
+.B ethtool \-\-get\-eee
+.I devname
+.HP
+.B ethtool \-\-set\-eee
+.I devname
+.B2 eee on off
+.B2 tx-lpi on off
+.BN tx-timer
+.BN advertise
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -817,6 +827,28 @@ Sets the device's private flags as specified.
 .I flag
 .A1 on off
 Sets the state of the named private flag.
+.TP
+.B \-\-get\-eee
+Queries the specified network device for its support in Efficient Energy
+Ethernet (according to the IEEE 802.3az specifications)
+.TP
+.B \-\-set\-eee
+Sets the device EEE behaviour.
+.TP
+.A2 eee on off
+Enables/Disables the device support in EEE.
+.TP
+.A2 tx-lpi on off
+Determines whether the device should assert its tx lpi.
+.TP
+.BI advertise \ N
+Sets the speeds for which the device would advertise EEE capabliities.
+Values are as for
+.B \-\-change advertise
+.TP
+.BI tx-timer \ N
+Sets the amount of time the device should stay in idle mode prior to asserting
+its tx lpi (in microseconds). This has meaning only when tx lpi is on.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index f18f611..eacdf8f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -359,7 +359,8 @@ static int do_version(struct cmd_context *ctx)
 	return 0;
 }
 
-static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
+static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
+			   int link_mode_only);
 
 static void dump_supported(struct ethtool_cmd *ep)
 {
@@ -378,14 +379,15 @@ static void dump_supported(struct ethtool_cmd *ep)
 		fprintf(stdout, "FIBRE ");
 	fprintf(stdout, "]\n");
 
-	dump_link_caps("Supported", "Supports", mask);
+	dump_link_caps("Supported", "Supports", mask, 0);
 }
 
 /* Print link capability flags (supported, advertised or lp_advertised).
  * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
  */
 static void
-dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
+dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
+	       int link_mode_only)
 {
 	int indent;
 	int did1;
@@ -456,24 +458,26 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
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
+	if (!link_mode_only) {
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
@@ -481,10 +485,11 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	u32 speed;
 
 	dump_supported(ep);
-	dump_link_caps("Advertised", "Advertised", ep->advertising);
+	dump_link_caps("Advertised", "Advertised", ep->advertising, 0);
 	if (ep->lp_advertising)
 		dump_link_caps("Link partner advertised",
-			       "Link partner advertised", ep->lp_advertising);
+			       "Link partner advertised", ep->lp_advertising,
+			       0);
 
 	fprintf(stdout, "	Speed: ");
 	speed = ethtool_cmd_speed(ep);
@@ -1116,6 +1121,34 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+static void dump_eeecmd(struct ethtool_eee *ep)
+{
+
+	fprintf(stdout, "	EEE status: ");
+	if (!ep->supported) {
+		fprintf(stdout, "not supported\n");
+		return;
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
+		fprintf(stdout, " %d (us)\n", ep->tx_lpi_timer);
+	else
+		fprintf(stdout, " disabled\n");
+
+	dump_link_caps("Supported EEE", "", ep->supported, 1);
+	dump_link_caps("Advertised EEE", "", ep->advertised, 1);
+	dump_link_caps("Link partner advertised EEE", "", ep->lp_advertised, 1);
+}
+
 #define N_SOTS 7
 
 static char *so_timestamping_labels[N_SOTS] = {
@@ -3261,6 +3294,64 @@ static int do_getmodule(struct cmd_context *ctx)
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
+	dump_eeecmd(&eeecmd);
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
+	return 0;
+}
+
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
 #ifndef TEST_ETHTOOL
@@ -3423,6 +3514,12 @@ static const struct option {
 	  "		[ hex on|off ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n" },
+	{ "--get-eee", 1, do_geee, "Get EEE settings"},
+	{ "--set-eee", 1, do_seee, "Set EEE settings",
+	  "		[ eee on|off ]\n"
+	  "		[ advertise %x ]\n"
+	  "		[ tx-lpi on|off ]\n"
+	  "		[ tx-timer %d ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
diff --git a/test-cmdline.c b/test-cmdline.c
index c30b0e6..d072886 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -223,6 +223,17 @@ static struct test_case {
 	{ 0, "-m devname hex off" },
 	{ 1, "-m devname hex on raw on" },
 	{ 0, "-m devname offset 4 length 6" },
+	{ 1, "--get-eee" },
+	{ 0, "--get-eee devname" },
+	{ 0, "--get-eee devname foo" },
+	{ 1, "--set-eee" },
+	{ 1, "--set-eee devname" },
+	{ 0, "--set-eee devname eee on" },
+	{ 0, "--set-eee devname eee off" },
+	{ 0, "--set-eee devname tx-lpi on" },
+	{ 0, "--set-eee devname tx-lpi off" },
+	{ 1, "--set-eee devname tx-timer foo" },
+	{ 1, "--set-eee devname advertise foo" },
 	/* can't test --set-priv-flags yet */
 	{ 0, "-h" },
 	{ 0, "--help" },
-- 
1.7.9.rc2
