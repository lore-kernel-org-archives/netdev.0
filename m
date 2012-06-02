From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 7/7] Change -k/-K options to use
 ETHTOOL_{G,S}FEATURES
Date: Sat, 2 Jun 2012 01:40:31 +0100
Message-ID: <1338597631.2770.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35889 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760256Ab2FBAke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:40:34 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rewrite the offload get and set functions to use the generic features
API where available, while maintaining a similar output format.
Add the long options --show-features and --features as additional
aliases for -k and -K.

Where there is exactly one named feature corresponding to an old
offload name, show the feature using the old offload name.  Where
there are multiple features corresponding to an old offload name,
show the features as a group, indented underneath it.

Add some test cases to check that this works properly with or without
the generic features API.  (These may well be insufficient.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in    |   31 ++---
 ethtool.c       |  448 +++++++++++++++++++++++++++++++++++++++++++-----------
 test-cmdline.c  |    7 -
 test-features.c |  345 +++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 707 insertions(+), 124 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 523b737..70ae31d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -199,23 +199,13 @@ ethtool \- query or control network driver and hardware settings
 .BN length
 .BN value
 .HP
-.B ethtool \-k|\-\-show\-offload
+.B ethtool \-k|\-\-show\-features|\-\-show\-offload
 .I devname
 .HP
-.B ethtool \-K|\-\-offload
-.I devname
-.B2 rx on off
-.B2 tx on off
-.B2 sg on off
-.B2 tso on off
-.B2 ufo on off
-.B2 gso on off
-.B2 gro on off
-.B2 lro on off
-.B2 rxvlan on off
-.B2 txvlan on off
-.B2 ntuple on off
-.B2 rxhash on off
+.B ethtool \-K|\-\-features|\-\-offload
+.I devname feature
+.A1 on off
+.RB ...
 .HP
 .B ethtool \-p|\-\-identify
 .I devname
@@ -428,11 +418,14 @@ parameters allow writing to certain portions of the EEPROM.
 Because of the persistent nature of writing to the EEPROM, a device-specific
 magic key must be specified to prevent the accidental writing to the EEPROM.
 .TP
-.B \-k \-\-show\-offload
-Queries the specified network device for offload information.
+.B \-k \-\-show\-features \-\-show\-offload
+Queries the specified network device for the state of protocol
+offload and other features.
 .TP
-.B \-K \-\-offload
-Changes the offload parameters of the specified network device.
+.B \-K \-\-features \-\-offload
+Changes the offload parameters and other features of the specified
+network device.  The following feature names are built-in and others
+may be defined by the kernel.
 .TP
 .A2 rx on off
 Specifies whether RX checksumming should be enabled.
diff --git a/ethtool.c b/ethtool.c
index 1cb708f..984273b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -128,38 +128,63 @@ static const struct flag_info flags_msglvl[] = {
 	{ "wol",	NETIF_MSG_WOL },
 };
 
-static const struct {
+struct off_flag_def {
 	const char *short_name;
 	const char *long_name;
+	const char *kernel_name;
 	u32 get_cmd, set_cmd;
 	u32 value;
-} off_flag_def[] = {
-	{ "rx",     "rx-checksumming",
+};
+static const struct off_flag_def off_flag_def[] = {
+	{ "rx",     "rx-checksumming",		    "rx-checksum",
 	  ETHTOOL_GRXCSUM, ETHTOOL_SRXCSUM, ETH_FLAG_RXCSUM },
-	{ "tx",     "tx-checksumming",
+	{ "tx",     "tx-checksumming",		    "tx-checksum-*",
 	  ETHTOOL_GTXCSUM, ETHTOOL_STXCSUM, ETH_FLAG_TXCSUM },
-	{ "sg",     "scatter-gather",
+	{ "sg",     "scatter-gather",		    "tx-scatter-gather*",
 	  ETHTOOL_GSG,	   ETHTOOL_SSG,     ETH_FLAG_SG },
-	{ "tso",    "tcp-segmentation-offload",
+	{ "tso",    "tcp-segmentation-offload",	    "tx-tcp*-segmentation",
 	  ETHTOOL_GTSO,	   ETHTOOL_STSO,    ETH_FLAG_TSO },
-	{ "ufo",    "udp-fragmentation-offload",
+	{ "ufo",    "udp-fragmentation-offload",    "tx-udp-fragmentation",
 	  ETHTOOL_GUFO,	   ETHTOOL_SUFO,    ETH_FLAG_UFO },
-	{ "gso",    "generic-segmentation-offload",
+	{ "gso",    "generic-segmentation-offload", "tx-generic-segmentation",
 	  ETHTOOL_GGSO,	   ETHTOOL_SGSO,    ETH_FLAG_GSO },
-	{ "gro",    "generic-receive-offload",
+	{ "gro",    "generic-receive-offload",	    "rx-gro",
 	  ETHTOOL_GGRO,	   ETHTOOL_SGRO,    ETH_FLAG_GRO },
-	{ "lro",    "large-receive-offload",
+	{ "lro",    "large-receive-offload",	    "rx-lro",
 	  0,		   0,		    ETH_FLAG_LRO },
-	{ "rxvlan", "rx-vlan-offload",
+	{ "rxvlan", "rx-vlan-offload",		    "rx-vlan-hw-parse",
 	  0,		   0,		    ETH_FLAG_RXVLAN },
-	{ "txvlan", "tx-vlan-offload",
+	{ "txvlan", "tx-vlan-offload",		    "tx-vlan-hw-insert",
 	  0,		   0,		    ETH_FLAG_TXVLAN },
-	{ "ntuple", "ntuple-filters",
+	{ "ntuple", "ntuple-filters",		    "rx-ntuple-filter",
 	  0,		   0,		    ETH_FLAG_NTUPLE },
-	{ "rxhash", "receive-hashing",
+	{ "rxhash", "receive-hashing",		    "rx-hashing",
 	  0,		   0,		    ETH_FLAG_RXHASH },
 };
 
+struct feature_def {
+	char name[ETH_GSTRING_LEN];
+	int off_flag_index; /* index in off_flag_def; negative if none match */
+};
+
+struct feature_defs {
+	size_t n_features;
+	/* Number of features each offload flag is associated with */
+	unsigned int off_flag_matched[ARRAY_SIZE(off_flag_def)];
+	/* Name and offload flag index for each feature */
+	struct feature_def def[0];
+};
+
+#define FEATURE_BITS_TO_BLOCKS(n_bits)		DIV_ROUND_UP(n_bits, 32U)
+#define FEATURE_WORD(blocks, index, field)	((blocks)[(index) / 32U].field)
+#define FEATURE_FIELD_FLAG(index)		(1U << (index) % 32U)
+#define FEATURE_BIT_SET(blocks, index, field)			\
+	(FEATURE_WORD(blocks, index, field) |= FEATURE_FIELD_FLAG(index))
+#define FEATURE_BIT_CLEAR(blocks, index, field)			\
+	(FEATURE_WORD(blocks, index, filed) &= ~FEATURE_FIELD_FLAG(index))
+#define FEATURE_BIT_IS_SET(blocks, index, field)		\
+	(FEATURE_WORD(blocks, index, field) & FEATURE_FIELD_FLAG(index))
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -1069,21 +1094,84 @@ static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 	return 0;
 }
 
-static int dump_offload(u32 active, u32 mask)
+struct feature_state {
+	u32 off_flags;
+	struct ethtool_gfeatures features;
+};
+
+static void dump_one_feature(const char *indent, const char *name,
+			     const struct feature_state *state,
+			     const struct feature_state *ref_state,
+			     u32 index)
+{
+	if (ref_state &&
+	    !(FEATURE_BIT_IS_SET(state->features.features, index, active) ^
+	      FEATURE_BIT_IS_SET(ref_state->features.features, index, active)))
+		return;
+
+	printf("%s%s: %s%s\n",
+	       indent, name,
+	       FEATURE_BIT_IS_SET(state->features.features, index, active) ?
+	       "on" : "off",
+	       (!FEATURE_BIT_IS_SET(state->features.features, index, available)
+		|| FEATURE_BIT_IS_SET(state->features.features, index,
+				      never_changed))
+	       ? " [fixed]"
+	       : (FEATURE_BIT_IS_SET(state->features.features, index, requested)
+		  ^ FEATURE_BIT_IS_SET(state->features.features, index, active))
+	       ? (FEATURE_BIT_IS_SET(state->features.features, index, requested)
+		  ? " [requested on]" : " [requested off]")
+	       : "");
+}
+
+static void dump_features(const struct feature_defs *defs,
+			  const struct feature_state *state,
+			  const struct feature_state *ref_state)
 {
 	u32 value;
-	int i;
+	int indent;
+	int i, j;
 
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		value = off_flag_def[i].value;
-		if (!(mask & value))
-			continue;
-		printf("%s: %s\n",
-		       off_flag_def[i].long_name,
-		       (active & value) ? "on" : "off");
+
+		/* If this offload flag matches exactly one generic
+		 * feature then it's redundant to show the flag and
+		 * feature states separately.  Otherwise, show the
+		 * flag state first.
+		 */
+		if (defs->off_flag_matched[i] != 1 &&
+		    (!ref_state ||
+		     (state->off_flags ^ ref_state->off_flags) & value)) {
+			printf("%s: %s\n",
+			       off_flag_def[i].long_name,
+			       (state->off_flags & value) ? "on" : "off");
+			indent = 1;
+		} else {
+			indent = 0;
+		}
+
+		/* Show matching features */
+		for (j = 0; j < defs->n_features; j++) {
+			if (defs->def[j].off_flag_index != i)
+				continue;
+			if (defs->off_flag_matched[i] != 1)
+				/* Show all matching feature states */
+				dump_one_feature(indent ? "\t" : "",
+						 defs->def[j].name,
+						 state, ref_state, j);
+			else
+				/* Show full state with the old flag name */
+				dump_one_feature("", off_flag_def[i].long_name,
+						 state, ref_state, j);
+		}
 	}
 
-	return 0;
+	/* Show all unmatched features that have non-null names */
+	for (j = 0; j < defs->n_features; j++)
+		if (defs->def[j].off_flag_index < 0 && defs->def[j].name[0])
+			dump_one_feature("", defs->def[j].name,
+					 state, ref_state, j);
 }
 
 static int dump_rxfhash(int fhash, u64 val)
@@ -1259,6 +1347,72 @@ get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
 	return strings;
 }
 
+static struct feature_defs *get_feature_defs(struct cmd_context *ctx)
+{
+	struct ethtool_gstrings *names;
+	struct feature_defs *defs;
+	u32 n_features;
+	int i, j;
+
+	names = get_stringset(ctx, ETH_SS_FEATURES, 0);
+	if (names) {
+		n_features = names->len;
+	} else if (errno == EOPNOTSUPP || errno == EINVAL) {
+		/* Kernel doesn't support named features; not an error */
+		n_features = 0;
+	} else {
+		return NULL;
+	}
+
+	defs = malloc(sizeof(*defs) + sizeof(defs->def[0]) * n_features);
+	if (!defs)
+		return NULL;
+
+	defs->n_features = n_features;
+	memset(defs->off_flag_matched, 0, sizeof(defs->off_flag_matched));
+
+	/* Copy out feature names and find those associated with legacy flags */
+	for (i = 0; i < defs->n_features; i++) {
+		memcpy(defs->def[i].name, names->data + i * ETH_GSTRING_LEN,
+		       ETH_GSTRING_LEN);
+		defs->def[i].off_flag_index = -1;
+
+		for (j = 0;
+		     j < ARRAY_SIZE(off_flag_def) &&
+			     defs->def[i].off_flag_index < 0;
+		     j++) {
+			const char *pattern =
+				off_flag_def[j].kernel_name;
+			const char *name = defs->def[i].name;
+			for (;;) {
+				if (*pattern == '*') {
+					/* There is only one wildcard; so
+					 * switch to a suffix comparison */
+					size_t pattern_len =
+						strlen(pattern + 1);
+					size_t name_len = strlen(name);
+					if (name_len < pattern_len)
+						break; /* name is too short */
+					name += name_len - pattern_len;
+					++pattern;
+				} else if (*pattern != *name) {
+					break; /* mismatch */
+				} else if (*pattern == 0) {
+					defs->def[i].off_flag_index = j;
+					defs->off_flag_matched[j]++;
+					break;
+				} else {
+					++name;
+					++pattern;
+				}
+			}
+		}
+	}
+
+	free(names);
+	return defs;
+}
+
 static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
@@ -1649,14 +1803,22 @@ static int do_scoalesce(struct cmd_context *ctx)
 	return 0;
 }
 
-static int get_offload(struct cmd_context *ctx, u32 *flags)
+static struct feature_state *
+get_features(struct cmd_context *ctx, const struct feature_defs *defs)
 {
+	struct feature_state *state;
 	struct ethtool_value eval;
 	int err, allfail = 1;
 	u32 value;
 	int i;
 
-	*flags = 0; 
+	state = malloc(sizeof(*state) +
+		       FEATURE_BITS_TO_BLOCKS(defs->n_features) *
+		       sizeof(state->features.features[0]));
+	if (!state)
+		return NULL;
+
+	state->off_flags = 0;
 
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		value = off_flag_def[i].value;
@@ -1670,7 +1832,7 @@ static int get_offload(struct cmd_context *ctx, u32 *flags)
 				off_flag_def[i].long_name);
 		} else {
 			if (eval.data)
-				*flags |= value;
+				state->off_flags |= value;
 			allfail = 0;
 		}
 	}
@@ -1680,101 +1842,214 @@ static int get_offload(struct cmd_context *ctx, u32 *flags)
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
-		*flags |= eval.data & ETH_FLAG_EXT_MASK;
+		state->off_flags |= eval.data & ETH_FLAG_EXT_MASK;
 		allfail = 0;
 	}
 
-	return allfail;
+	if (defs->n_features) {
+		state->features.cmd = ETHTOOL_GFEATURES;
+		state->features.size = FEATURE_BITS_TO_BLOCKS(defs->n_features);
+		err = send_ioctl(ctx, &state->features);
+		if (err)
+			perror("Cannot get device generic features");
+		else
+			allfail = 0;
+	}
+
+	if (allfail) {
+		free(state);
+		return NULL;
+	}
+
+	return state;
 }
 
-static int do_goffload(struct cmd_context *ctx)
+static int do_gfeatures(struct cmd_context *ctx)
 {
-	u32 flags;
+	struct feature_defs *defs;
+	struct feature_state *features;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
+	defs = get_feature_defs(ctx);
+	if (!defs)
+		return 1;
+
+	fprintf(stdout, "Features for %s:\n", ctx->devname);
 
-	if (get_offload(ctx, &flags)) {
-		fprintf(stdout, "no offload info available\n");
-		return 83;
+	features = get_features(ctx, defs);
+	if (!features) {
+		fprintf(stdout, "no feature info available\n");
+		return 1;
 	}
 
-	return dump_offload(flags, ~(u32)0);
+	dump_features(defs, features, NULL);
+	return 0;
 }
 
-static int do_soffload(struct cmd_context *ctx)
+static int do_sfeatures(struct cmd_context *ctx)
 {
-	int goffload_changed = 0;
+	struct feature_defs *defs;
+	int any_changed = 0, any_mismatch = 0;
 	u32 off_flags_wanted = 0;
 	u32 off_flags_mask = 0;
-	struct cmdline_info cmdline_offload[ARRAY_SIZE(off_flag_def)];
-	u32 old_flags, new_flags, diff;
+	struct ethtool_sfeatures *efeatures;
+	struct cmdline_info *cmdline_features;
+	struct feature_state *old_state, *new_state;
 	struct ethtool_value eval;
 	int err;
-	int i;
+	int i, j;
+
+	defs = get_feature_defs(ctx);
+	if (!defs)
+		return 1;
+	if (defs->n_features) {
+		efeatures = malloc(sizeof(*efeatures) +
+				   FEATURE_BITS_TO_BLOCKS(defs->n_features) *
+				   sizeof(efeatures->features[0]));
+		if (!efeatures) {
+			perror("Cannot parse arguments");
+			return 1;
+		}
+		efeatures->cmd = ETHTOOL_SFEATURES;
+		efeatures->size = FEATURE_BITS_TO_BLOCKS(defs->n_features);
+		memset(efeatures->features, 0,
+		       FEATURE_BITS_TO_BLOCKS(defs->n_features) *
+		       sizeof(efeatures->features[0]));
+	} else {
+		efeatures = NULL;
+	}
 
+	/* Generate cmdline_info for legacy flags and kernel-named
+	 * features, and parse our arguments.
+	 */
+	cmdline_features = calloc(ARRAY_SIZE(off_flag_def) + defs->n_features,
+				  sizeof(cmdline_features[0]));
+	if (!cmdline_features) {
+		perror("Cannot parse arguments");
+		return 1;
+	}
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++)
 		flag_to_cmdline_info(off_flag_def[i].short_name,
 				     off_flag_def[i].value,
 				     &off_flags_wanted, &off_flags_mask,
-				     &cmdline_offload[i]);
-
-	parse_generic_cmdline(ctx, &goffload_changed,
-			      cmdline_offload, ARRAY_SIZE(cmdline_offload));
+				     &cmdline_features[i]);
+	for (i = 0; i < defs->n_features; i++)
+		flag_to_cmdline_info(
+			defs->def[i].name, FEATURE_FIELD_FLAG(i),
+			&FEATURE_WORD(efeatures->features, i, requested),
+			&FEATURE_WORD(efeatures->features, i, valid),
+			&cmdline_features[ARRAY_SIZE(off_flag_def) + i]);
+	parse_generic_cmdline(ctx, &any_changed, cmdline_features,
+			      ARRAY_SIZE(off_flag_def) + defs->n_features);
+	free(cmdline_features);
+
+	if (!any_changed) {
+		fprintf(stdout, "no features changed\n");
+		return 0;
+	}
 
-	if (get_offload(ctx, &old_flags)) {
-		fprintf(stderr, "no offload info available\n");
+	old_state = get_features(ctx, defs);
+	if (!old_state)
 		return 1;
-	}
 
+	/* For each offload that the user specified, update any
+	 * related features that the user did not specify and that
+	 * are not fixed.  Warn if all related features are fixed.
+	 */
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
-		if (!off_flag_def[i].set_cmd)
+		int fixed = 1;
+
+		if (!(off_flags_mask & off_flag_def[i].value))
 			continue;
-		if (off_flags_mask & off_flag_def[i].value) {
-			eval.cmd = off_flag_def[i].set_cmd;
-			eval.data = !!(off_flags_wanted &
-				       off_flag_def[i].value);
-			err = send_ioctl(ctx, &eval);
-			if (err) {
-				fprintf(stderr,
-					"Cannot set device %s settings: %m\n",
-					off_flag_def[i].long_name);
-				return 1;
+
+		for (j = 0; j < defs->n_features; j++) {
+			if (defs->def[j].off_flag_index != i ||
+			    !FEATURE_BIT_IS_SET(old_state->features.features,
+						j, available) ||
+			    FEATURE_BIT_IS_SET(old_state->features.features,
+					       j, never_changed))
+				continue;
+
+			fixed = 0;
+			if (!FEATURE_BIT_IS_SET(efeatures->features, j, valid)) {
+				FEATURE_BIT_SET(efeatures->features, j, valid);
+				if (off_flags_wanted & off_flag_def[i].value)
+					FEATURE_BIT_SET(efeatures->features, j,
+							requested);
 			}
 		}
+
+		if (fixed)
+			fprintf(stderr, "Cannot change %s\n",
+				off_flag_def[i].long_name);
 	}
-	if (off_flags_mask & ETH_FLAG_EXT_MASK) {
-		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = old_flags & ~off_flags_mask & ETH_FLAG_EXT_MASK;
-		eval.data |= off_flags_wanted & ETH_FLAG_EXT_MASK;
 
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
+	if (efeatures) {
+		err = send_ioctl(ctx, efeatures);
+		if (err < 0) {
+			perror("Cannot set device feature settings");
+			return 1;
+		}
+	} else {
+		for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+			if (!off_flag_def[i].set_cmd)
+				continue;
+			if (off_flags_mask & off_flag_def[i].value) {
+				eval.cmd = off_flag_def[i].set_cmd;
+				eval.data = !!(off_flags_wanted &
+					       off_flag_def[i].value);
+				err = send_ioctl(ctx, &eval);
+				if (err) {
+					fprintf(stderr,
+						"Cannot set device %s settings: %m\n",
+						off_flag_def[i].long_name);
+					return 1;
+				}
+			}
 		}
-	}
 
-	if (off_flags_mask == 0) {
-		fprintf(stdout, "no offload settings changed\n");
-		return 0;
+		if (off_flags_mask & ETH_FLAG_EXT_MASK) {
+			eval.cmd = ETHTOOL_SFLAGS;
+			eval.data = (old_state->off_flags & ~off_flags_mask &
+				     ETH_FLAG_EXT_MASK);
+			eval.data |= off_flags_wanted & ETH_FLAG_EXT_MASK;
+
+			err = send_ioctl(ctx, &eval);
+			if (err) {
+				perror("Cannot set device flag settings");
+				return 92;
+			}
+		}
 	}
 
 	/* Compare new state with requested state */
-	if (get_offload(ctx, &new_flags)) {
-		fprintf(stderr, "no offload info available\n");
+	new_state = get_features(ctx, defs);
+	if (!new_state)
 		return 1;
-	}
-	if (new_flags != ((old_flags & ~off_flags_mask) | off_flags_wanted)) {
-		if (new_flags == old_flags) {
+	any_changed = new_state->off_flags != old_state->off_flags;
+	any_mismatch = (new_state->off_flags !=
+			((old_state->off_flags & ~off_flags_mask) |
+			 off_flags_wanted));
+	for (i = 0; i < FEATURE_BITS_TO_BLOCKS(defs->n_features); i++) {
+		if (new_state->features.features[i].active !=
+		    old_state->features.features[i].active)
+			any_changed = 1;
+		if (new_state->features.features[i].active !=
+		    ((old_state->features.features[i].active &
+		      ~efeatures->features[i].valid) |
+		     efeatures->features[i].requested))
+			any_mismatch = 1;
+	}
+	if (any_mismatch) {
+		if (!any_changed) {
 			fprintf(stderr,
-				"Could not change any device offload settings\n");
+				"Could not change any device features\n");
 			return 1;
 		}
 		printf("Actual changes:\n");
-		dump_offload(new_flags, new_flags ^ old_flags);
+		dump_features(defs, new_state, old_state);
 	}
 
 	return 0;
@@ -3237,22 +3512,11 @@ static const struct option {
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
-	{ "-k|--show-offload", 1, do_goffload,
-	  "Get protocol offload information" },
-	{ "-K|--offload", 1, do_soffload, "Set protocol offload",
-	  "		[ rx on|off ]\n"
-	  "		[ tx on|off ]\n"
-	  "		[ sg on|off ]\n"
-	  "		[ tso on|off ]\n"
-	  "		[ ufo on|off ]\n"
-	  "		[ gso on|off ]\n"
-	  "		[ gro on|off ]\n"
-	  "		[ lro on|off ]\n"
-	  "		[ rxvlan on|off ]\n"
-	  "		[ txvlan on|off ]\n"
-	  "		[ ntuple on|off ]\n"
-	  "		[ rxhash on|off ]\n"
-	},
+	{ "-k|--show-features|--show-offload", 1, do_gfeatures,
+	  "Get state of protocol offload and other features" },
+	{ "-K|--features|--offload", 1, do_sfeatures,
+	  "Set protocol offload and other features",
+	  "		FEATURE on|off ...\n" },
 	{ "-i|--driver", 1, do_gdrv, "Show driver information" },
 	{ "-d|--register-dump", 1, do_gregs, "Do a register dump",
 	  "		[ raw on|off ]\n"
diff --git a/test-cmdline.c b/test-cmdline.c
index c62bb97..978c312 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -86,14 +86,7 @@ static struct test_case {
 	{ 1, "--set-ring devname rx" },
 	{ 1, "-G devname foo 1" },
 	{ 1, "-G" },
-	{ 0, "-k devname" },
-	{ 0, "--show-offload devname" },
 	{ 1, "-k" },
-	{ 0, "-K devname rx on tx off sg on tso off ufo on gso off gro on" },
-	{ 0, "--offload devname lro off rxvlan on txvlan off ntuple on rxhash off" },
-	{ 1, "-K devname rx foo" },
-	{ 1, "--offload devname rx" },
-	{ 1, "-K devname foo on" },
 	{ 1, "-K" },
 	{ 0, "-i devname" },
 	{ 0, "--driver devname" },
diff --git a/test-features.c b/test-features.c
index 409b3d2..a48c701 100644
--- a/test-features.c
+++ b/test-features.c
@@ -7,12 +7,19 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #define TEST_NO_WRAPPERS
 #include "internal.h"
 
+static const struct {
+	struct ethtool_sset_info cmd;
+	u32 data[1];
+}
+cmd_gssetinfo = { { ETHTOOL_GSSET_INFO, 0, 1ULL << ETH_SS_FEATURES }, 34 };
+
 static const struct ethtool_value
 cmd_grxcsum_off = { ETHTOOL_GRXCSUM, 0 },
 cmd_grxcsum_on = { ETHTOOL_GRXCSUM, 1 },
@@ -55,7 +62,13 @@ cmd_sflags_not_rxhash = { ETHTOOL_SFLAGS,
 			  ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN |
 			  ETH_FLAG_NTUPLE };
 
-static const struct cmd_expect cmd_expect_get_features_off[] = {
+static const struct cmd_expect cmd_expect_get_strings_old[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd), -EINVAL },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_get_features_off_old[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd), -EINVAL },
 	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
@@ -67,7 +80,8 @@ static const struct cmd_expect cmd_expect_get_features_off[] = {
 	{ 0, 0, 0, 0, 0 }
 };
 
-static const struct cmd_expect cmd_expect_set_features_off[] = {
+static const struct cmd_expect cmd_expect_set_features_off_old[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd), -EINVAL },
 	{ &cmd_grxcsum_on, 4, 0, &cmd_grxcsum_on, sizeof(cmd_grxcsum_on) },
 	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
 	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
@@ -95,7 +109,8 @@ static const struct cmd_expect cmd_expect_set_features_off[] = {
 	{ 0, 0, 0, 0, 0 }
 };
 
-static const struct cmd_expect cmd_expect_set_features_on[] = {
+static const struct cmd_expect cmd_expect_set_features_on_old[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd), -EINVAL },
 	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
@@ -123,16 +138,334 @@ static const struct cmd_expect cmd_expect_set_features_on[] = {
 	{ 0, 0, 0, 0, 0 }
 };
 
+static const struct cmd_expect cmd_expect_set_features_unsup_on_old[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd), -EINVAL },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_stxcsum_on, sizeof(cmd_stxcsum_on), -EOPNOTSUPP },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct {
+	struct ethtool_gstrings cmd;
+	u8 data[34][ETH_GSTRING_LEN];
+}
+cmd_gstrings = {
+	{ ETHTOOL_GSTRINGS, ETH_SS_FEATURES, 34 },
+	{
+		"tx-scatter-gather",
+		"tx-checksum-ipv4",
+		"",
+		"tx-checksum-ip-generic",
+		"tx-checksum-ipv6",
+		"highdma",
+		"tx-scatter-gather-fraglist",
+		"tx-vlan-hw-insert",
+		"rx-vlan-hw-parse",
+		"rx-vlan-filter",
+		"vlan-challenged",
+		"tx-generic-segmentation",
+		"tx-lockless",
+		"netns-local",
+		"rx-gro",
+		"rx-lro",
+		"tx-tcp-segmentation",
+		"tx-udp-fragmentation",
+		"tx-gso-robust",
+		"tx-tcp-ecn-segmentation",
+		"tx-tcp6-segmentation",
+		"tx-fcoe-segmentation",
+		"",
+		"",
+		"tx-checksum-fcoe-crc",
+		"tx-checksum-sctp",
+		"fcoe-mtu",
+		"rx-ntuple-filter",
+		"rx-hashing",
+		"rx-checksum",
+		"tx-nocache-copy",
+		"loopback",
+		"rx-fcs",
+		"rx-all",
+	}
+};
+
+static const struct {
+	struct ethtool_gfeatures cmd;
+	struct ethtool_get_features_block data[2];
+}
+			    /* available   requested   active   never_changed */
+/* minimal: only GRO and GSO are available (and GSO won't work) */
+cmd_gfeatures_min_off =   { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0x00004800, 0x00000000, 0x00000000, 0x00003400},
+			     { 0x00000000, 0x00000000, 0x00000000, 0x00000000}}
+},
+cmd_gfeatures_min_on =    { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0x00004800, 0x00004800, 0x00004000, 0x00003400},
+			     { 0x00000000, 0x00000000, 0x00000000, 0x00000000}}
+},
+/* maximal: everything that isn't never-changed is available */
+cmd_gfeatures_max_off =   { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0xffffcbff, 0x00000000, 0x00000000, 0x00003400 },
+			     { 0x00000003, 0x00000000, 0x00000000, 0x00000000 }}
+},
+cmd_gfeatures_max_on =    { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0xffffcbff, 0xffffcbff, 0xffffcbff, 0x00003400 },
+			     { 0x00000003, 0x00000003, 0x00000003, 0x00000000 }}
+},
+/* IPv4: GRO, GSO, SG and some IPv4-specific offloads are available */
+cmd_gfeatures_ipv4_off =  { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0x00014803, 0x00000000, 0x00000000, 0x00003400 },
+			     { 0x00000000, 0x00000000, 0x00000000, 0x00000000 }}
+},
+cmd_gfeatures_ipv4_on =   { { ETHTOOL_GFEATURES, 2 },
+			    {{ 0x00014803, 0x00014803, 0x00014803, 0x00003400 },
+			     { 0x00000000, 0x00000000, 0x00000000, 0x00000000 }}
+};
+
+static const struct {
+	struct ethtool_sfeatures cmd;
+	struct ethtool_set_features_block data[2];
+}
+			    /* valid       requested */
+cmd_sfeatures_min_on =   { { ETHTOOL_SFEATURES, 2 },
+			    {{ 0x00004800, 0x00004800 },
+			     { 0x00000000, 0x00000000 }} },
+cmd_sfeatures_min_off =  { { ETHTOOL_SFEATURES, 2 },
+			    {{ 0x00004800, 0x00000000 },
+			     { 0x00000000, 0x00000000 }} },
+cmd_sfeatures_noop =     { { ETHTOOL_SFEATURES, 2 },
+			    {{ 0x00000000, 0x00000000 },
+			     { 0x00000000, 0x00000000 }} },
+cmd_sfeatures_ipv4_on =  { { ETHTOOL_SFEATURES, 2 },
+			    {{ 0x00014803, 0x00014803 },
+			     { 0x00000000, 0x00000000 }} };
+
+static const struct cmd_expect cmd_expect_get_strings[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_get_features_min_off[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_get_features_max_on[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_on, 4, 0, &cmd_grxcsum_on, sizeof(cmd_grxcsum_on) },
+	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
+	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
+	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
+	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
+	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
+	{ &cmd_gfeatures_max_on, sizeof(cmd_gfeatures_max_on.cmd),
+	  0, &cmd_gfeatures_max_on, sizeof(cmd_gfeatures_max_on) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_set_features_min_off_min_on[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ &cmd_sfeatures_min_on, sizeof(cmd_sfeatures_min_on),
+	  ETHTOOL_F_WISH, 0, 0 },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_on, sizeof(cmd_gfeatures_min_on.cmd),
+	  0, &cmd_gfeatures_min_on, sizeof(cmd_gfeatures_min_on) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_set_features_min_off_min_off[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ &cmd_sfeatures_min_off, sizeof(cmd_sfeatures_min_off), 0, 0, 0 },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_set_features_min_on_min_off[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_on, sizeof(cmd_gfeatures_min_on.cmd),
+	  0, &cmd_gfeatures_min_on, sizeof(cmd_gfeatures_min_on) },
+	{ &cmd_sfeatures_min_off, sizeof(cmd_sfeatures_min_off), 0, 0, 0 },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_set_features_min_off_unsup_on[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ &cmd_sfeatures_noop, sizeof(cmd_sfeatures_noop), 0, 0, 0 },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off.cmd),
+	  0, &cmd_gfeatures_min_off, sizeof(cmd_gfeatures_min_off) },
+	{ 0, 0, 0, 0, 0 }
+};
+
+static const struct cmd_expect cmd_expect_set_features_ipv4_off_many_on[] = {
+	{ &cmd_gssetinfo, sizeof(cmd_gssetinfo.cmd),
+	  0, &cmd_gssetinfo, sizeof(cmd_gssetinfo) },
+	{ &cmd_gstrings, sizeof(cmd_gstrings.cmd),
+	  0, &cmd_gstrings, sizeof(cmd_gstrings) },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_ipv4_off, sizeof(cmd_gfeatures_ipv4_off.cmd),
+	  0, &cmd_gfeatures_ipv4_off, sizeof(cmd_gfeatures_ipv4_off) },
+	{ &cmd_sfeatures_ipv4_on, sizeof(cmd_sfeatures_ipv4_on), 0, 0, 0 },
+	{ &cmd_grxcsum_on, 4, 0, &cmd_grxcsum_on, sizeof(cmd_grxcsum_on) },
+	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
+	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
+	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
+	{ &cmd_gfeatures_ipv4_on, sizeof(cmd_gfeatures_ipv4_on.cmd),
+	  0, &cmd_gfeatures_ipv4_on, sizeof(cmd_gfeatures_ipv4_on) },
+	{ 0, 0, 0, 0, 0 }
+};
+
 static struct test_case {
 	int rc;
 	const char *args;
 	const struct cmd_expect *expect;
 } const test_cases[] = {
-	{ 0, "-k devname", cmd_expect_get_features_off },
+	{ 0, "-k devname", cmd_expect_get_features_off_old },
 	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off lro off rxvlan off txvlan off ntuple off rxhash off gro off",
-	  cmd_expect_set_features_off },
+	  cmd_expect_set_features_off_old },
 	{ 0, "-K devname rx on tx on sg on tso on ufo on gso on lro on rxvlan on txvlan on ntuple on rxhash on gro on",
-	  cmd_expect_set_features_on },
+	  cmd_expect_set_features_on_old },
+	{ 1, "-K devname tx on sg on", cmd_expect_set_features_unsup_on_old },
+	{ 0, "--show-offload devname", cmd_expect_get_features_min_off },
+	{ 0, "--show-features devname", cmd_expect_get_features_max_on },
+	{ 0, "-K devname rx on tx on sg on tso on ufo on gso on gro on",
+	  cmd_expect_set_features_min_off_min_on },
+	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off gro off",
+	  cmd_expect_set_features_min_off_min_off },
+	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off gro off",
+	  cmd_expect_set_features_min_on_min_off },
+	{ 1, "-K devname tx on sg on",
+	  cmd_expect_set_features_min_off_unsup_on },
+	{ 0, "--features devname rx on tx on sg on tso on gso on gro on",
+	  cmd_expect_set_features_ipv4_off_many_on },
+	{ 1, "-K devname rx foo", cmd_expect_get_strings_old },
+	{ 1, "-K devname rx foo", cmd_expect_get_strings },
+	{ 1, "--offload devname rx", cmd_expect_get_strings_old },
+	{ 1, "--features devname rx", cmd_expect_get_strings },
+	{ 1, "--features devname foo on", cmd_expect_get_strings_old },
+	{ 1, "--offload devname foo on", cmd_expect_get_strings },
 };
 
 static int expect_matched;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
