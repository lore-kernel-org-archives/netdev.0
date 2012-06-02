From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 5/7] Regularise offload feature settings
Date: Sat, 2 Jun 2012 01:38:40 +0100
Message-ID: <1338597520.2770.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35846 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933023Ab2FBAin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:38:43 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is partly preparation for use of the new net device features API,
but is useful in its own right.

Replace repetitive code for getting/setting offload flags with data-
driven loops.

This changes error messages to use the same long names for offload
flags as in dump_offload(), and changes various exit codes to 1.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c       |  291 +++++++++++++++++--------------------------------------
 internal.h      |   18 ++++
 test-features.c |    6 +-
 3 files changed, 110 insertions(+), 205 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 9d42ca8..34d8b90 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -128,6 +128,38 @@ static const struct flag_info flags_msglvl[] = {
 	{ "wol",	NETIF_MSG_WOL },
 };
 
+static const struct {
+	const char *short_name;
+	const char *long_name;
+	u32 get_cmd, set_cmd;
+	u32 value;
+} off_flag_def[] = {
+	{ "rx",     "rx-checksumming",
+	  ETHTOOL_GRXCSUM, ETHTOOL_SRXCSUM, ETH_FLAG_RXCSUM },
+	{ "tx",     "tx-checksumming",
+	  ETHTOOL_GTXCSUM, ETHTOOL_STXCSUM, ETH_FLAG_TXCSUM },
+	{ "sg",     "scatter-gather",
+	  ETHTOOL_GSG,	   ETHTOOL_SSG,     ETH_FLAG_SG },
+	{ "tso",    "tcp-segmentation-offload",
+	  ETHTOOL_GTSO,	   ETHTOOL_STSO,    ETH_FLAG_TSO },
+	{ "ufo",    "udp-fragmentation-offload",
+	  ETHTOOL_GUFO,	   ETHTOOL_SUFO,    ETH_FLAG_UFO },
+	{ "gso",    "generic-segmentation-offload",
+	  ETHTOOL_GGSO,	   ETHTOOL_SGSO,    ETH_FLAG_GSO },
+	{ "gro",    "generic-receive-offload",
+	  ETHTOOL_GGRO,	   ETHTOOL_SGRO,    ETH_FLAG_GRO },
+	{ "lro",    "large-receive-offload",
+	  0,		   0,		    ETH_FLAG_LRO },
+	{ "rxvlan", "rx-vlan-offload",
+	  0,		   0,		    ETH_FLAG_RXVLAN },
+	{ "txvlan", "tx-vlan-offload",
+	  0,		   0,		    ETH_FLAG_TXVLAN },
+	{ "ntuple", "ntuple-filters",
+	  0,		   0,		    ETH_FLAG_NTUPLE },
+	{ "rxhash", "receive-hashing",
+	  0,		   0,		    ETH_FLAG_RXHASH },
+};
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -1037,35 +1069,17 @@ static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 	return 0;
 }
 
-static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro, int rxvlan, int txvlan, int ntuple,
-			int rxhash)
+static int dump_offload(u32 active)
 {
-	fprintf(stdout,
-		"rx-checksumming: %s\n"
-		"tx-checksumming: %s\n"
-		"scatter-gather: %s\n"
-		"tcp-segmentation-offload: %s\n"
-		"udp-fragmentation-offload: %s\n"
-		"generic-segmentation-offload: %s\n"
-		"generic-receive-offload: %s\n"
-		"large-receive-offload: %s\n"
-		"rx-vlan-offload: %s\n"
-		"tx-vlan-offload: %s\n"
-		"ntuple-filters: %s\n"
-		"receive-hashing: %s\n",
-		rx ? "on" : "off",
-		tx ? "on" : "off",
-		sg ? "on" : "off",
-		tso ? "on" : "off",
-		ufo ? "on" : "off",
-		gso ? "on" : "off",
-		gro ? "on" : "off",
-		lro ? "on" : "off",
-		rxvlan ? "on" : "off",
-		txvlan ? "on" : "off",
-		ntuple ? "on" : "off",
-		rxhash ? "on" : "off");
+	u32 value;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+		value = off_flag_def[i].value;
+		printf("%s: %s\n",
+		       off_flag_def[i].long_name,
+		       (active & value) ? "on" : "off");
+	}
 
 	return 0;
 }
@@ -1636,67 +1650,30 @@ static int do_scoalesce(struct cmd_context *ctx)
 static int do_goffload(struct cmd_context *ctx)
 {
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
-	    ntuple = 0, rxhash = 0;
+	int err, allfail = 1;
+	u32 flags = 0, value;
+	int i;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
 
 	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
 
-	eval.cmd = ETHTOOL_GRXCSUM;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device rx csum settings");
-	else {
-		rx = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GTXCSUM;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device tx csum settings");
-	else {
-		tx = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GSG;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device scatter-gather settings");
-	else {
-		sg = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GTSO;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device tcp segmentation offload settings");
-	else {
-		tso = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GUFO;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device udp large send offload settings");
-	else {
-		ufo = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GGSO;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device generic segmentation offload settings");
-	else {
-		gso = eval.data;
-		allfail = 0;
+	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+		value = off_flag_def[i].value;
+		if (!off_flag_def[i].get_cmd)
+			continue;
+		eval.cmd = off_flag_def[i].get_cmd;
+		err = send_ioctl(ctx, &eval);
+		if (err) {
+			fprintf(stderr,
+				"Cannot get device %s settings: %m\n",
+				off_flag_def[i].long_name);
+		} else {
+			if (eval.data)
+				flags |= value;
+			allfail = 0;
+		}
 	}
 
 	eval.cmd = ETHTOOL_GFLAGS;
@@ -1704,20 +1681,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
-		lro = (eval.data & ETH_FLAG_LRO) != 0;
-		rxvlan = (eval.data & ETH_FLAG_RXVLAN) != 0;
-		txvlan = (eval.data & ETH_FLAG_TXVLAN) != 0;
-		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
-		rxhash = (eval.data & ETH_FLAG_RXHASH) != 0;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GGRO;
-	err = send_ioctl(ctx, &eval);
-	if (err)
-		perror("Cannot get device GRO settings");
-	else {
-		gro = eval.data;
+		flags |= eval.data & ETH_FLAG_EXT_MASK;
 		allfail = 0;
 	}
 
@@ -1726,112 +1690,45 @@ static int do_goffload(struct cmd_context *ctx)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
-			    ntuple, rxhash);
+	return dump_offload(flags);
 }
 
 static int do_soffload(struct cmd_context *ctx)
 {
 	int goffload_changed = 0;
-	int off_csum_rx_wanted = -1;
-	int off_csum_tx_wanted = -1;
-	int off_sg_wanted = -1;
-	int off_tso_wanted = -1;
-	int off_ufo_wanted = -1;
-	int off_gso_wanted = -1;
 	u32 off_flags_wanted = 0;
 	u32 off_flags_mask = 0;
-	int off_gro_wanted = -1;
-	struct cmdline_info cmdline_offload[] = {
-		{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
-		{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
-		{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
-		{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
-		{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
-		{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
-		{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
-		  ETH_FLAG_LRO, &off_flags_mask },
-		{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
-		{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-		  ETH_FLAG_RXVLAN, &off_flags_mask },
-		{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-		  ETH_FLAG_TXVLAN, &off_flags_mask },
-		{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
-		  ETH_FLAG_NTUPLE, &off_flags_mask },
-		{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
-		  ETH_FLAG_RXHASH, &off_flags_mask },
-	};
+	struct cmdline_info cmdline_offload[ARRAY_SIZE(off_flag_def)];
 	struct ethtool_value eval;
-	int err, changed = 0;
+	int err;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++)
+		flag_to_cmdline_info(off_flag_def[i].short_name,
+				     off_flag_def[i].value,
+				     &off_flags_wanted, &off_flags_mask,
+				     &cmdline_offload[i]);
 
 	parse_generic_cmdline(ctx, &goffload_changed,
 			      cmdline_offload, ARRAY_SIZE(cmdline_offload));
 
-	if (off_csum_rx_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SRXCSUM;
-		eval.data = (off_csum_rx_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device rx csum settings");
-			return 84;
-		}
-	}
-
-	if (off_csum_tx_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_STXCSUM;
-		eval.data = (off_csum_tx_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device tx csum settings");
-			return 85;
-		}
-	}
-
-	if (off_sg_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SSG;
-		eval.data = (off_sg_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
-	}
-
-	if (off_tso_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_STSO;
-		eval.data = (off_tso_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device tcp segmentation offload settings");
-			return 88;
-		}
-	}
-	if (off_ufo_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SUFO;
-		eval.data = (off_ufo_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device udp large send offload settings");
-			return 89;
-		}
-	}
-	if (off_gso_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SGSO;
-		eval.data = (off_gso_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device generic segmentation offload settings");
-			return 90;
+	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+		if (!off_flag_def[i].set_cmd)
+			continue;
+		if (off_flags_mask & off_flag_def[i].value) {
+			eval.cmd = off_flag_def[i].set_cmd;
+			eval.data = !!(off_flags_wanted &
+				       off_flag_def[i].value);
+			err = send_ioctl(ctx, &eval);
+			if (err) {
+				fprintf(stderr,
+					"Cannot set device %s settings: %m\n",
+					off_flag_def[i].long_name);
+				return 1;
+			}
 		}
 	}
-	if (off_flags_mask) {
-		changed = 1;
+	if (off_flags_mask & ETH_FLAG_EXT_MASK) {
 		eval.cmd = ETHTOOL_GFLAGS;
 		eval.data = 0;
 		err = send_ioctl(ctx, &eval);
@@ -1841,8 +1738,8 @@ static int do_soffload(struct cmd_context *ctx)
 		}
 
 		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
+		eval.data &= ~(off_flags_mask & ETH_FLAG_EXT_MASK);
+		eval.data |= off_flags_wanted & ETH_FLAG_EXT_MASK;
 
 		err = send_ioctl(ctx, &eval);
 		if (err) {
@@ -1850,18 +1747,8 @@ static int do_soffload(struct cmd_context *ctx)
 			return 92;
 		}
 	}
-	if (off_gro_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SGRO;
-		eval.data = (off_gro_wanted == 1);
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device GRO settings");
-			return 93;
-		}
-	}
 
-	if (!changed) {
+	if (off_flags_mask == 0) {
 		fprintf(stdout, "no offload settings changed\n");
 	}
 
diff --git a/internal.h b/internal.h
index 0fff2a5..deb7868 100644
--- a/internal.h
+++ b/internal.h
@@ -91,6 +91,24 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 #define SIOCETHTOOL     0x8946
 #endif
 
+/* Internal values for old-style offload flags.  Values and names
+ * must not clash with the flags defined for ETHTOOL_{G,S}FLAGS.
+ */
+#define ETH_FLAG_RXCSUM		(1 << 0)
+#define ETH_FLAG_TXCSUM		(1 << 1)
+#define ETH_FLAG_SG		(1 << 2)
+#define ETH_FLAG_TSO		(1 << 3)
+#define ETH_FLAG_UFO		(1 << 4)
+#define ETH_FLAG_GSO		(1 << 5)
+#define ETH_FLAG_GRO		(1 << 6)
+#define ETH_FLAG_INT_MASK	(ETH_FLAG_RXCSUM | ETH_FLAG_TXCSUM |	\
+				 ETH_FLAG_SG | ETH_FLAG_TSO | ETH_FLAG_UFO | \
+				 ETH_FLAG_GSO | ETH_FLAG_GRO),
+/* Mask of all flags defined for ETHTOOL_{G,S}FLAGS. */
+#define ETH_FLAG_EXT_MASK	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN |	\
+				 ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |	\
+				 ETH_FLAG_RXHASH)
+
 /* Context for sub-commands */
 struct cmd_context {
 	const char *devname;	/* net device name */
diff --git a/test-features.c b/test-features.c
index 4d8680a..349bc23 100644
--- a/test-features.c
+++ b/test-features.c
@@ -62,8 +62,8 @@ static const struct cmd_expect cmd_expect_get_features_off[] = {
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
 	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
-	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
 	{ 0, 0, 0, 0, 0 }
 };
 
@@ -74,9 +74,9 @@ static const struct cmd_expect cmd_expect_set_features_off[] = {
 	{ &cmd_stso_off, sizeof(cmd_stso_off), 0, 0, 0 },
 	{ &cmd_sufo_off, sizeof(cmd_sufo_off), 0, 0, 0 },
 	{ &cmd_sgso_off, sizeof(cmd_sgso_off), 0, 0, 0 },
+	{ &cmd_sgro_off, sizeof(cmd_sgro_off), 0, 0, 0 },
 	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
 	{ &cmd_sflags_off, sizeof(cmd_sflags_off), 0, 0, 0 },
-	{ &cmd_sgro_off, sizeof(cmd_sgro_off), 0, 0, 0 },
 	{ 0, 0, 0, 0, 0 }
 };
 
@@ -87,9 +87,9 @@ static const struct cmd_expect cmd_expect_set_features_on[] = {
 	{ &cmd_stso_on, sizeof(cmd_stso_on), 0, 0, 0 },
 	{ &cmd_sufo_on, sizeof(cmd_sufo_on), 0, 0, 0 },
 	{ &cmd_sgso_on, sizeof(cmd_sgso_on), 0, 0, 0 },
+	{ &cmd_sgro_on, sizeof(cmd_sgro_on), 0, 0, 0 },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_off) },
 	{ &cmd_sflags_on, sizeof(cmd_sflags_on), 0, 0, 0 },
-	{ &cmd_sgro_on, sizeof(cmd_sgro_on), 0, 0, 0 },
 	{ 0, 0, 0, 0, 0 }
 };
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
