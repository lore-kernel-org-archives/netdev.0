From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH v2] ethtool: implement [GS]FEATURES handling
Date: Sat, 28 Jan 2012 09:37:14 +0100 (CET)
Message-ID: <08e06fc4d7b6e4dba466422a7cc93b2e2630c978.1327739670.git.mirq-linux@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	<1297107597.4077.8.camel@bwh-desktop>
	<1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1327419002.5400.27.camel@deadeye>
	<20120124190513.GC19993@rere.qmqm.pl>
	<e16a98ed4f9d1f0dece8bdae3ebccb7222047671.1327739037.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43477 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025Ab2A1IhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jan 2012 03:37:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: fix missing change CMDL_FLAG -> CMDL_BOOL for old offloads parsing

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 ethtool.c |  613 ++++++++++++++++++++++++++++++++++++++++++++++++-----=
-------
 1 files changed, 490 insertions(+), 123 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d0cc7d4..8df2ce8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1036,9 +1036,15 @@ static int dump_coalesce(const struct ethtool_co=
alesce *ecoal)
 	return 0;
 }
=20
-static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int =
gso,
-			int gro, int lro, int rxvlan, int txvlan, int ntuple,
-			int rxhash)
+struct offload_state {
+	int rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan, ntuple, rxha=
sh;
+};
+
+static const char *const old_feature_names[] =3D {
+	"rx", "tx", "sg", "tso", "ufo", "gso", "gro", "lro", "rxvlan", "txvla=
n", "ntuple", "rxhash"
+};
+
+static int dump_offload(const struct offload_state *offload)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1053,18 +1059,18 @@ static int dump_offload(int rx, int tx, int sg,=
 int tso, int ufo, int gso,
 		"tx-vlan-offload: %s\n"
 		"ntuple-filters: %s\n"
 		"receive-hashing: %s\n",
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
+		offload->rx ? "on" : "off",
+		offload->tx ? "on" : "off",
+		offload->sg ? "on" : "off",
+		offload->tso ? "on" : "off",
+		offload->ufo ? "on" : "off",
+		offload->gso ? "on" : "off",
+		offload->gro ? "on" : "off",
+		offload->lro ? "on" : "off",
+		offload->rxvlan ? "on" : "off",
+		offload->txvlan ? "on" : "off",
+		offload->ntuple ? "on" : "off",
+		offload->rxhash ? "on" : "off");
=20
 	return 0;
 }
@@ -1547,24 +1553,20 @@ static int do_scoalesce(struct cmd_context *ctx=
)
 	return 0;
 }
=20
-static int do_goffload(struct cmd_context *ctx)
+static int send_goffloads(struct cmd_context *ctx,
+	struct offload_state *offload)
 {
 	struct ethtool_value eval;
-	int err, allfail =3D 1, rx =3D 0, tx =3D 0, sg =3D 0;
-	int tso =3D 0, ufo =3D 0, gso =3D 0, gro =3D 0, lro =3D 0, rxvlan =3D=
 0, txvlan =3D 0,
-	    ntuple =3D 0, rxhash =3D 0;
-
-	if (ctx->argc !=3D 0)
-		exit_bad_args();
+	int err, allfail =3D 1;
=20
-	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
+	memset(offload, 0, sizeof(*offload));
=20
 	eval.cmd =3D ETHTOOL_GRXCSUM;
 	err =3D send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device rx csum settings");
 	else {
-		rx =3D eval.data;
+		offload->rx =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1573,7 +1575,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device tx csum settings");
 	else {
-		tx =3D eval.data;
+		offload->tx =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1582,7 +1584,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device scatter-gather settings");
 	else {
-		sg =3D eval.data;
+		offload->sg =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1591,7 +1593,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device tcp segmentation offload settings");
 	else {
-		tso =3D eval.data;
+		offload->tso =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1600,7 +1602,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device udp large send offload settings");
 	else {
-		ufo =3D eval.data;
+		offload->ufo =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1609,7 +1611,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device generic segmentation offload settings");
 	else {
-		gso =3D eval.data;
+		offload->gso =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1618,11 +1620,11 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
-		lro =3D (eval.data & ETH_FLAG_LRO) !=3D 0;
-		rxvlan =3D (eval.data & ETH_FLAG_RXVLAN) !=3D 0;
-		txvlan =3D (eval.data & ETH_FLAG_TXVLAN) !=3D 0;
-		ntuple =3D (eval.data & ETH_FLAG_NTUPLE) !=3D 0;
-		rxhash =3D (eval.data & ETH_FLAG_RXHASH) !=3D 0;
+		offload->lro =3D (eval.data & ETH_FLAG_LRO) !=3D 0;
+		offload->rxvlan =3D (eval.data & ETH_FLAG_RXVLAN) !=3D 0;
+		offload->txvlan =3D (eval.data & ETH_FLAG_TXVLAN) !=3D 0;
+		offload->ntuple =3D (eval.data & ETH_FLAG_NTUPLE) !=3D 0;
+		offload->rxhash =3D (eval.data & ETH_FLAG_RXHASH) !=3D 0;
 		allfail =3D 0;
 	}
=20
@@ -1631,7 +1633,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err)
 		perror("Cannot get device GRO settings");
 	else {
-		gro =3D eval.data;
+		offload->gro =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -1640,144 +1642,509 @@ static int do_goffload(struct cmd_context *ct=
x)
 		return 83;
 	}
=20
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvl=
an,
-			    ntuple, rxhash);
+	return 0;
 }
=20
-static int do_soffload(struct cmd_context *ctx)
+static int send_soffloads(struct cmd_context *ctx,
+	const struct offload_state *wanted)
 {
-	int goffload_changed =3D 0;
-	int off_csum_rx_wanted =3D -1;
-	int off_csum_tx_wanted =3D -1;
-	int off_sg_wanted =3D -1;
-	int off_tso_wanted =3D -1;
-	int off_ufo_wanted =3D -1;
-	int off_gso_wanted =3D -1;
+	struct ethtool_value eval;
+	int changed =3D 0, err;
 	u32 off_flags_wanted =3D 0;
 	u32 off_flags_mask =3D 0;
-	int off_gro_wanted =3D -1;
-	struct cmdline_info cmdline_offload[] =3D {
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
-	struct ethtool_value eval;
-	int err, changed =3D 0;
=20
-	parse_generic_cmdline(ctx, &goffload_changed,
-			      cmdline_offload, ARRAY_SIZE(cmdline_offload));
+	if (wanted->lro >=3D 0) {
+		off_flags_mask |=3D ETH_FLAG_LRO;
+		if (wanted->lro)
+			off_flags_wanted |=3D ETH_FLAG_LRO;
+	}
+
+	if (wanted->rxvlan >=3D 0) {
+		off_flags_mask |=3D ETH_FLAG_RXVLAN;
+		if (wanted->rxvlan)
+			off_flags_wanted |=3D ETH_FLAG_RXVLAN;
+	}
=20
-	if (off_csum_rx_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->txvlan >=3D 0) {
+		off_flags_mask |=3D ETH_FLAG_TXVLAN;
+		if (wanted->txvlan)
+			off_flags_wanted |=3D ETH_FLAG_TXVLAN;
+	}
+
+	if (wanted->ntuple >=3D 0) {
+		off_flags_mask |=3D ETH_FLAG_NTUPLE;
+		if (wanted->ntuple)
+			off_flags_wanted |=3D ETH_FLAG_NTUPLE;
+	}
+
+	if (wanted->rxhash >=3D 0) {
+		off_flags_mask |=3D ETH_FLAG_RXHASH;
+		if (wanted->rxhash)
+			off_flags_wanted |=3D ETH_FLAG_RXHASH;
+	}
+
+	if (wanted->rx >=3D 0) {
 		eval.cmd =3D ETHTOOL_SRXCSUM;
-		eval.data =3D (off_csum_rx_wanted =3D=3D 1);
+		eval.data =3D !!wanted->rx;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device rx csum settings");
-			return 84;
-		}
+		else
+			changed =3D 1;
 	}
=20
-	if (off_csum_tx_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->tx >=3D 0) {
 		eval.cmd =3D ETHTOOL_STXCSUM;
-		eval.data =3D (off_csum_tx_wanted =3D=3D 1);
+		eval.data =3D !!wanted->tx;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device tx csum settings");
-			return 85;
-		}
+		else
+			changed =3D 1;
 	}
=20
-	if (off_sg_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->sg >=3D 0) {
 		eval.cmd =3D ETHTOOL_SSG;
-		eval.data =3D (off_sg_wanted =3D=3D 1);
+		eval.data =3D !!wanted->sg;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
+		else
+			changed =3D 1;
 	}
=20
-	if (off_tso_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->tso >=3D 0) {
 		eval.cmd =3D ETHTOOL_STSO;
-		eval.data =3D (off_tso_wanted =3D=3D 1);
+		eval.data =3D !!wanted->tso;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device tcp segmentation offload settings");
-			return 88;
-		}
+		else
+			changed =3D 1;
 	}
-	if (off_ufo_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->ufo >=3D 0) {
 		eval.cmd =3D ETHTOOL_SUFO;
-		eval.data =3D (off_ufo_wanted =3D=3D 1);
+		eval.data =3D !!wanted->ufo;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device udp large send offload settings");
-			return 89;
-		}
+		else
+			changed =3D 1;
 	}
-	if (off_gso_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->gso >=3D 0) {
 		eval.cmd =3D ETHTOOL_SGSO;
-		eval.data =3D (off_gso_wanted =3D=3D 1);
+		eval.data =3D !!wanted->gso;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device generic segmentation offload settings");
-			return 90;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_flags_mask) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_GFLAGS;
 		eval.data =3D 0;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot get device flag settings");
-			return 91;
-		}
-
-		eval.cmd =3D ETHTOOL_SFLAGS;
-		eval.data =3D ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
-
-		err =3D send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
+		else {
+			eval.cmd =3D ETHTOOL_SFLAGS;
+			eval.data =3D ((eval.data & ~off_flags_mask) |
+				     off_flags_wanted);
+
+			err =3D send_ioctl(ctx, &eval);
+			if (err)
+				perror("Cannot set device flag settings");
+			else
+				changed =3D 1;
 		}
 	}
-	if (off_gro_wanted >=3D 0) {
-		changed =3D 1;
+	if (wanted->gro >=3D 0) {
 		eval.cmd =3D ETHTOOL_SGRO;
-		eval.data =3D (off_gro_wanted =3D=3D 1);
+		eval.data =3D !!wanted->gro;
 		err =3D send_ioctl(ctx, &eval);
-		if (err) {
+		if (err)
 			perror("Cannot set device GRO settings");
-			return 93;
+		else
+			changed =3D 1;
+	}
+
+	return changed;
+}
+
+static int n_feature_strings;
+static const char **feature_strings;
+
+static int init_feature_strings(struct cmd_context *ctx)
+{
+	struct ethtool_gstrings *strings;
+	int i, n;
+
+	if (feature_strings)
+		return n_feature_strings;
+
+	strings =3D get_stringset(ctx, ETH_SS_FEATURES, 0);
+	if (!strings)
+		return -100;
+
+	n =3D n_feature_strings =3D strings->len;
+	feature_strings =3D calloc(n, sizeof(*feature_strings));
+	if (!feature_strings) {
+		fprintf(stderr, "no memory available for string table [size=3D%d]\n"=
, n);
+		exit(95);
+	}
+
+	for (i =3D 0; i < n; ++i) {
+		if (!strings->data[i*ETH_GSTRING_LEN])
+			continue;
+
+		feature_strings[i] =3D strndup(
+			(const char *)&strings->data[i * ETH_GSTRING_LEN],
+			ETH_GSTRING_LEN);
+
+		if (!feature_strings[i]) {
+			fprintf(stderr, "no memory available for a string\n");
+			exit(95);
 		}
 	}
=20
+	free(strings);
+	return n;
+}
+
+static void parse_sfeatures_args(struct cmd_context *ctx,
+	struct offload_state *offload,
+	struct ethtool_sfeatures **features_req_p)
+{
+	struct ethtool_sfeatures *features_req;
+	struct cmdline_info *cmdline_desc, *cp;
+	int sz_features, i;
+	int changed =3D 0;
+
+	struct cmdline_info cmdline_offload[] =3D {
+		{ "rx", CMDL_BOOL, &offload->rx, NULL },
+		{ "tx", CMDL_BOOL, &offload->tx, NULL },
+		{ "sg", CMDL_BOOL, &offload->sg, NULL },
+		{ "tso", CMDL_BOOL, &offload->tso, NULL },
+		{ "ufo", CMDL_BOOL, &offload->ufo, NULL },
+		{ "gso", CMDL_BOOL, &offload->gso, NULL },
+		{ "lro", CMDL_BOOL, &offload->lro, NULL },
+		{ "gro", CMDL_BOOL, &offload->gro, NULL },
+		{ "rxvlan", CMDL_BOOL, &offload->rxvlan, NULL },
+		{ "txvlan", CMDL_BOOL, &offload->txvlan, NULL },
+		{ "ntuple", CMDL_BOOL, &offload->ntuple, NULL },
+		{ "rxhash", CMDL_BOOL, &offload->rxhash, NULL },
+	};
+
+	for (i =3D 0; i < ARRAY_SIZE(old_feature_names); ++i)
+		((int *)offload)[i] =3D -1;
+	*features_req_p =3D NULL;
+
+	if (init_feature_strings(ctx) < 0) {
+		/* ETHTOOL_GFEATURES unavailable */
+		parse_generic_cmdline(ctx, &changed,
+			cmdline_offload, ARRAY_SIZE(cmdline_offload));
+		return;
+	}
+
+	sz_features =3D sizeof(*features_req->features) * ((n_feature_strings=
 + 31) / 32);
+
+	cp =3D cmdline_desc =3D calloc(n_feature_strings + ARRAY_SIZE(cmdline=
_offload),
+		sizeof(*cmdline_desc));
+	memcpy(cp, cmdline_offload, sizeof(cmdline_offload));
+	cp +=3D ARRAY_SIZE(cmdline_offload);
+
+	features_req =3D calloc(1, sizeof(*features_req) + sz_features);
+	if (!cmdline_desc || !features_req) {
+		fprintf(stderr, "no memory available\n");
+		exit(95);
+	}
+
+	features_req->size =3D (n_feature_strings + 31) / 32;
+
+	for (i =3D 0; i < n_feature_strings; ++i) {
+		if (!feature_strings[i])
+			continue;
+
+		cp->name =3D feature_strings[i];
+		cp->type =3D CMDL_FLAG;
+		cp->flag_val =3D 1 << (i % 32);
+		cp->wanted_val =3D &features_req->features[i / 32].requested;
+		cp->seen_val =3D &features_req->features[i / 32].valid;
+		++cp;
+	}
+
+	parse_generic_cmdline(ctx, &changed, cmdline_desc, cp - cmdline_desc)=
;
+
+	free(cmdline_desc);
+
+	if (changed)
+		*features_req_p =3D features_req;
+	else
+		free(features_req);
+}
+
+static int send_gfeatures(struct cmd_context *ctx,
+	struct ethtool_gfeatures **features_p)
+{
+	struct ethtool_gfeatures *features;
+	int err, sz_features;
+
+	sz_features =3D sizeof(*features->features) * ((n_feature_strings + 3=
1) / 32);
+	features =3D calloc(1, sz_features + sizeof(*features));
+	if (!features) {
+		fprintf(stderr, "no memory available\n");
+		return 95;
+	}
+
+	features->cmd =3D ETHTOOL_GFEATURES;
+	features->size =3D (n_feature_strings + 31) / 32;
+	err =3D send_ioctl(ctx, features);
+
+	if (err < 0) {
+		perror("Cannot get feature status");
+		free(features);
+		return 97;
+	}
+
+	*features_p =3D features;
+	return 0;
+}
+
+static const char *get_feature_state(struct ethtool_get_features_block=
 *gfb,
+	uint32_t bit)
+{
+	if (gfb->never_changed & bit)
+		return "fixed";
+	if (!(gfb->available & bit))
+		return "driver-controlled";
+
+	if ((gfb->active ^ gfb->requested) & bit)
+		return (gfb->requested & bit) ? "requested on" : "requested off";
+	else
+		return "changeable";
+}
+
+static int do_gfeatures(struct cmd_context *ctx)
+{
+	struct ethtool_get_features_block *gfb;
+	struct ethtool_gfeatures *features;
+	uint32_t bit;
+	int err, i;
+
+	err =3D init_feature_strings(ctx);
+	if (err < 0)
+		return -err;
+
+	err =3D send_gfeatures(ctx, &features);
+	if (err)
+		return err;
+
+	fprintf(stdout, "\nExtended offload state for %s:\n", ctx->devname);
+	for (i =3D 0; i < n_feature_strings; i++) {
+		if (!feature_strings[i])
+			continue;	/* empty */
+
+		gfb =3D features->features + i / 32;
+		bit =3D 1 << (i % 32);
+
+		fprintf(stdout, "%s: %s (%s)\n", feature_strings[i],
+			(gfb->active & bit) ? "on" : "off",
+			get_feature_state(gfb, bit));
+	}
+	free(features);
+
+	return 0;
+}
+
+static void print_gfeatures_diff(
+	const struct ethtool_get_features_block *expected,
+	const struct ethtool_get_features_block *set,
+	const char **strings, int n_strings)
+{
+	int i;
+
+	if (n_strings > 32)
+		n_strings =3D 32;
+
+	for (i =3D 0; i < n_strings; ++i) {
+		u32 mask =3D 1 << i;
+
+		if (!strings[i])
+			continue;
+
+		if (!((expected->active ^ set->active) & mask))
+			continue;
+
+		fprintf(stdout, "feature %.*s is %s (expected: %s, saved: %s)\n",
+			ETH_GSTRING_LEN, strings[i],
+			set->active & mask ? "enabled" : "disabled",
+			expected->active & mask ? "enabled" : "disabled",
+			!(set->available & mask) ? "not user-changeable" :
+				set->requested & mask ? "enabled" : "disabled"
+		);
+	}
+}
+
+static int get_offload_state(struct cmd_context *ctx,
+	struct ethtool_gfeatures **features,
+	struct offload_state *offload)
+{
+	int err, allfail;
+
+	if (ctx->argc !=3D 0)
+		exit_bad_args();
+
+	allfail =3D send_goffloads(ctx, offload);
+
+	err =3D init_feature_strings(ctx);
+	if (err < 0)
+		return allfail ? err : 0;
+
+	err =3D send_gfeatures(ctx, features);
+	if (err)
+		perror("Cannot read features");
+
+	return allfail ? -err : 0;
+}
+
+static int send_sfeatures(struct cmd_context *ctx,
+	struct ethtool_sfeatures *features)
+{
+	int err;
+
+	features->cmd =3D ETHTOOL_SFEATURES;
+	err =3D send_ioctl(ctx, features);
+	if (err < 0) {
+		perror("Cannot change features");
+		return 97;
+	}
+
+	return 0;
+}
+
+static void compare_offload_state(struct offload_state *offload0,
+	struct offload_state *offload_req, struct offload_state *offload1)
+{
+	int *old =3D (int *)offload0;
+	int *req =3D (int *)offload_req;
+	int *new =3D (int *)offload1;
+	int i;
+
+	for (i =3D 0; i < ARRAY_SIZE(old_feature_names); i++) {
+		if (req[i] < 0)
+			req[i] =3D old[i];
+		if (req[i] =3D=3D new[i])
+			continue;
+
+		fprintf(stdout, "feature group %s is %s (expected: %s)\n",
+			old_feature_names[i],
+			new[i] ? "enabled" : "disabled",
+			req[i] ? "enabled" : "disabled"
+		);
+	}
+}
+
+static void compare_features(struct ethtool_gfeatures *features0,
+	struct ethtool_sfeatures *features_req,
+	struct ethtool_gfeatures *features1)
+{
+	int i;
+
+	if (features_req) {
+		/* make features0 .active what we expect to be set */
+		i =3D (n_feature_strings + 31) / 32;
+		while (i--) {
+			features0->features[i].active &=3D ~features_req->features[i].valid=
;
+			features0->features[i].active |=3D
+				features_req->features[i].requested &
+				features_req->features[i].valid;
+		}
+	}
+
+	for (i =3D 0; i < n_feature_strings; i +=3D 32)
+		print_gfeatures_diff(&features0->features[i / 32],
+			&features1->features[i / 32],
+			feature_strings + i,
+			n_feature_strings - i);
+}
+
+static int do_goffload(struct cmd_context *ctx)
+{
+	struct offload_state offload;
+	int err, allfail;
+
+	allfail =3D send_goffloads(ctx, &offload);
+
+	if (!allfail) {
+		fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
+
+		dump_offload(&offload);
+	}
+
+	err =3D do_gfeatures(ctx);
+	if (!err)
+		allfail =3D 0;
+
+	if (allfail) {
+		fprintf(stdout, "no offload info available\n");
+		return 83;
+	}
+
+	return 0;
+}
+
+static int do_soffload(struct cmd_context *ctx)
+{
+	struct ethtool_gfeatures *features_old, *features_new;
+	struct ethtool_sfeatures *features_req;
+	struct offload_state offload_old, offload_new, offload_req;
+	int err, changed;
+
+	parse_sfeatures_args(ctx, &offload_req, &features_req);
+
+	err =3D get_offload_state(ctx, &features_old, &offload_old);
+	if (err)
+		return -err;
+
+	changed =3D send_soffloads(ctx, &offload_req);
+
+	if (features_req) {
+		err =3D send_sfeatures(ctx, features_req);
+		if (!err)
+			changed =3D 1;
+	}
+
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
+		return err;
+	}
+
+	err =3D get_offload_state(ctx, &features_new, &offload_new);
+	if (err) {
+		perror("can't verify offload setting");
+		return 101;
+	}
+
+	if ((!features_old) ^ (!features_new)) {
+		fprintf(stderr, "can't compare features (one GFEATURES failed)\n");
+		if (features_old) {
+			free(features_old);
+			features_old =3D NULL;
+		}
+		if (features_new) {
+			free(features_new);
+			features_new =3D NULL;
+		}
+	}
+
+	compare_offload_state(&offload_old, &offload_req, &offload_new);
+	if (features_old) {
+		compare_features(features_old, features_req, features_new);
+		free(features_old);
+		free(features_new);
 	}
+	if (features_req)
+		free(features_req);
=20
 	return 0;
 }
--=20
1.7.8.3
