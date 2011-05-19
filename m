From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH v3 ethtool] ethtool: implement [GS]FEATURES calls
Date: Thu, 19 May 2011 15:25:59 +0200 (CEST)
Message-ID: <feef455dde958796b578892a48d26461e9d75fd9.1305811240.git.mirq-linux@rere.qmqm.pl>
References: <20110519091833.GA24484@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59634 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756960Ab1ESN0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 09:26:01 -0400
In-Reply-To: <20110519091833.GA24484@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is all-in-one PoC patch for [GS]FEATURES support and checking of
all feature changes when altering some.

Example result:

icybox:~# ./ethtool -K ge0 tx_checksum-ipv6 on
feature group tx is enabled (expected: disabled)
feature group sg is enabled (expected: disabled)
feature group gso is enabled (expected: disabled)
feature tx-scatter-gather is enabled (expected: disabled, saved: enable=
d)
feature tx-generic-segmentation is enabled (expected: disabled, saved: =
enabled)

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 ethtool.c |  583 +++++++++++++++++++++++++++++++++++++++++++++++++++--=
--------
 1 files changed, 494 insertions(+), 89 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 34fe107..40456bb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -33,6 +33,7 @@
 #include <limits.h>
 #include <ctype.h>
=20
+#include <unistd.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -83,6 +84,8 @@ static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
+static void parse_sfeatures_args(int argc, char **argp, int argi);
+static int do_gfeatures(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
@@ -196,7 +199,8 @@ static struct option {
 		"		[ txvlan on|off ]\n"
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
-    },
+		"		[ feature-name on|off [...] ]\n"
+		"		see --show-offload output for feature-name strings\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
 		"		[ raw on|off ]\n"
@@ -296,7 +300,6 @@ static void show_usage(void)
=20
 static char *devname =3D NULL;
=20
-static int goffload_changed =3D 0;
 static int off_csum_rx_wanted =3D -1;
 static int off_csum_tx_wanted =3D -1;
 static int off_sg_wanted =3D -1;
@@ -306,6 +309,9 @@ static int off_gso_wanted =3D -1;
 static u32 off_flags_wanted =3D 0;
 static u32 off_flags_mask =3D 0;
 static int off_gro_wanted =3D -1;
+static int n_feature_strings;
+static const char **feature_strings;
+static struct ethtool_sfeatures *features_req;
=20
 static struct ethtool_pauseparam epause;
 static int gpause_changed =3D 0;
@@ -851,10 +857,7 @@ static void parse_cmdline(int argc, char **argp)
 				break;
 			}
 			if (mode =3D=3D MODE_SOFFLOAD) {
-				parse_generic_cmdline(argc, argp, i,
-					&goffload_changed,
-			      		cmdline_offload,
-			      		ARRAY_SIZE(cmdline_offload));
+				parse_sfeatures_args(argc, argp, i);
 				i =3D argc;
 				break;
 			}
@@ -1788,9 +1791,15 @@ static int dump_coalesce(void)
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
+const char *const old_feature_names[] =3D {
+	"rx", "tx", "sg", "tso", "ufo", "gso", "gro", "lro", "rxvlan", "txvla=
n", "ntuple", "rxhash"
+};
+
+static int dump_offload(const struct offload_state *offload)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1805,18 +1814,18 @@ static int dump_offload(int rx, int tx, int sg,=
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
@@ -1867,21 +1876,33 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
=20
-static int doit(void)
-{
-	struct ifreq ifr;
-	int fd;
+static int control_fd =3D -1;
=20
+static int get_control_socket(struct ifreq *ifr)
+{
 	/* Setup our control structures. */
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, devname);
+	memset(ifr, 0, sizeof(*ifr));
+	strcpy(ifr->ifr_name, devname);
+
+	if (control_fd >=3D 0)
+		return control_fd;
=20
 	/* Open control socket. */
-	fd =3D socket(AF_INET, SOCK_DGRAM, 0);
-	if (fd < 0) {
+	control_fd =3D socket(AF_INET, SOCK_DGRAM, 0);
+	if (control_fd < 0)
 		perror("Cannot get control socket");
+
+	return control_fd;
+}
+
+static int doit(void)
+{
+	struct ifreq ifr;
+	int fd;
+
+	fd =3D get_control_socket(&ifr);
+	if (fd < 0)
 		return 70;
-	}
=20
 	/* all of these are expected to populate ifr->ifr_data as needed */
 	if (mode =3D=3D MODE_GDRV) {
@@ -2139,14 +2160,13 @@ static int do_scoalesce(int fd, struct ifreq *i=
fr)
 	return 0;
 }
=20
-static int do_goffload(int fd, struct ifreq *ifr)
+static int send_goffloads(int fd, struct ifreq *ifr,
+	struct offload_state *offload)
 {
 	struct ethtool_value eval;
-	int err, allfail =3D 1, rx =3D 0, tx =3D 0, sg =3D 0;
-	int tso =3D 0, ufo =3D 0, gso =3D 0, gro =3D 0, lro =3D 0, rxvlan =3D=
 0, txvlan =3D 0,
-	    ntuple =3D 0, rxhash =3D 0;
+	int err, allfail =3D 1;
=20
-	fprintf(stdout, "Offload parameters for %s:\n", devname);
+	memset(offload, 0, sizeof(*offload));
=20
 	eval.cmd =3D ETHTOOL_GRXCSUM;
 	ifr->ifr_data =3D (caddr_t)&eval;
@@ -2154,7 +2174,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device rx csum settings");
 	else {
-		rx =3D eval.data;
+		offload->rx =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2164,7 +2184,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device tx csum settings");
 	else {
-		tx =3D eval.data;
+		offload->tx =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2174,7 +2194,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device scatter-gather settings");
 	else {
-		sg =3D eval.data;
+		offload->sg =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2184,7 +2204,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device tcp segmentation offload settings");
 	else {
-		tso =3D eval.data;
+		offload->tso =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2194,7 +2214,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device udp large send offload settings");
 	else {
-		ufo =3D eval.data;
+		offload->ufo =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2204,7 +2224,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err)
 		perror("Cannot get device generic segmentation offload settings");
 	else {
-		gso =3D eval.data;
+		offload->gso =3D eval.data;
 		allfail =3D 0;
 	}
=20
@@ -2214,11 +2234,11 @@ static int do_goffload(int fd, struct ifreq *if=
r)
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
@@ -2228,130 +2248,515 @@ static int do_goffload(int fd, struct ifreq *=
ifr)
 	if (err)
 		perror("Cannot get device GRO settings");
 	else {
-		gro =3D eval.data;
+		offload->gro =3D eval.data;
 		allfail =3D 0;
 	}
=20
+	return -allfail;
+}
+
+static int do_goffload(int fd, struct ifreq *ifr)
+{
+	struct offload_state offload;
+	int err, allfail;
+
+	allfail =3D send_goffloads(fd, ifr, &offload);
+
+	if (!allfail) {
+		fprintf(stdout, "Offload parameters for %s:\n", devname);
+
+		dump_offload(&offload);
+	}
+
+	err =3D do_gfeatures(fd, ifr);
+	if (!err)
+		allfail =3D 0;
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
=20
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvl=
an,
-			    ntuple, rxhash);
+	return 0;
 }
=20
-static int do_soffload(int fd, struct ifreq *ifr)
+static int send_soffloads(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
 	int err, changed =3D 0;
=20
 	if (off_csum_rx_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SRXCSUM;
 		eval.data =3D (off_csum_rx_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device rx csum settings");
-			return 84;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_csum_tx_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_STXCSUM;
 		eval.data =3D (off_csum_tx_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device tx csum settings");
-			return 85;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_sg_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SSG;
 		eval.data =3D (off_sg_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_tso_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_STSO;
 		eval.data =3D (off_tso_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device tcp segmentation offload settings");
-			return 88;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_ufo_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SUFO;
 		eval.data =3D (off_ufo_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device udp large send offload settings");
-			return 89;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_gso_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SGSO;
 		eval.data =3D (off_gso_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
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
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
 			perror("Cannot get device flag settings");
-			return 91;
-		}
-
-		eval.cmd =3D ETHTOOL_SFLAGS;
-		eval.data =3D ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
-
-		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
+		} else {
+			eval.cmd =3D ETHTOOL_SFLAGS;
+			eval.data =3D ((eval.data & ~off_flags_mask) |
+				     off_flags_wanted);
+
+			err =3D ioctl(fd, SIOCETHTOOL, ifr);
+			if (err)
+				perror("Cannot set device flag settings");
+			else
+				changed =3D 1;
 		}
 	}
 	if (off_gro_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SGRO;
 		eval.data =3D (off_gro_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
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
+static int get_feature_strings(int fd, struct ifreq *ifr,
+	struct ethtool_gstrings **strs)
+{
+	struct ethtool_sset_info *sset_info;
+	struct ethtool_gstrings *strings;
+	int sz_str, n_strings, err;
+
+	sset_info =3D malloc(sizeof(struct ethtool_sset_info) + sizeof(u32));
+	sset_info->cmd =3D ETHTOOL_GSSET_INFO;
+	sset_info->sset_mask =3D (1ULL << ETH_SS_FEATURES);
+	ifr->ifr_data =3D (caddr_t)sset_info;
+	err =3D send_ioctl(fd, ifr);
+
+	n_strings =3D sset_info->data[0];
+	free(sset_info);
+
+	if ((err < 0) ||
+	    (!(sset_info->sset_mask & (1ULL << ETH_SS_FEATURES))) ||
+	    (n_strings =3D=3D 0)) {
+		return -100;
+	}
+
+	sz_str =3D n_strings * ETH_GSTRING_LEN;
+	strings =3D calloc(1, sz_str + sizeof(struct ethtool_gstrings));
+	if (!strings) {
+		fprintf(stderr, "no memory available\n");
+		exit(95);
+	}
+
+	strings->cmd =3D ETHTOOL_GSTRINGS;
+	strings->string_set =3D ETH_SS_FEATURES;
+	strings->len =3D n_strings;
+	ifr->ifr_data =3D (caddr_t) strings;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get feature strings information");
+		free(strings);
+		exit(96);
+	}
+
+	*strs =3D strings;
+	return n_strings;
+}
+
+static int init_feature_strings(void)
+{
+	struct ethtool_gstrings *strings;
+	struct ifreq ifr;
+	int fd, i, n;
+
+	if (feature_strings)
+		return n_feature_strings;
+
+	fd =3D get_control_socket(&ifr);
+	if (fd < 0)
+		exit(100);
+
+	n =3D get_feature_strings(fd, &ifr, &strings);
+
+	if (n < 0)
+		return n;
+
+	n_feature_strings =3D n;
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
+static void parse_sfeatures_args(int argc, char **argp, int argi)
+{
+	struct cmdline_info *cmdline_desc, *cp;
+	int sz_features, i;
+	int changed =3D 0;
+
+	if (init_feature_strings() < 0) {
+		/* ETHTOOL_GFEATURES unavailable */
+		parse_generic_cmdline(argc, argp, argi, &changed,
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
+	parse_generic_cmdline(argc, argp, argi, &changed,
+		cmdline_desc, cp - cmdline_desc);
+
+	free(cmdline_desc);
+
+	if (!changed) {
+		free(features_req);
+		features_req =3D NULL;
+	}
+}
+
+static int send_gfeatures(int fd, struct ifreq *ifr,
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
+	ifr->ifr_data =3D (caddr_t) features;
+	err =3D send_ioctl(fd, ifr);
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
+static int do_gfeatures(int fd, struct ifreq *ifr)
+{
+	struct ethtool_gfeatures *features;
+	int err, i;
+
+	err =3D init_feature_strings();
+	if (err < 0)
+		return -err;
+
+	err =3D send_gfeatures(fd, ifr, &features);
+	if (err)
+		return err;
+
+	fprintf(stdout, "\nFull offload state:  (feature-name: active,wanted,=
changable)\n");
+	for (i =3D 0; i < n_feature_strings; i++) {
+		if (!feature_strings[i])
+			continue;	/* empty */
+#define P_FLAG(f) \
+	(features->features[i / 32].f & (1 << (i % 32))) ? "yes" : " no"
+#define PA_FLAG(f) \
+	(features->features[i / 32].available & (1 << (i % 32))) ? P_FLAG(f) =
: "---"
+#define PN_FLAG(f) \
+	(features->features[i / 32].never_changed & (1 << (i % 32))) ? "---" =
: P_FLAG(f)
+		fprintf(stdout, "     %-*.*s %s,%s,%s\n",
+			ETH_GSTRING_LEN, ETH_GSTRING_LEN, feature_strings[i],
+			P_FLAG(active), PA_FLAG(requested), PN_FLAG(available));
+#undef P_FLAG
+#undef PA_FLAG
+#undef PN_FLAG
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
+		fprintf(stderr, "feature %.*s is %s (expected: %s, saved: %s)\n",
+			ETH_GSTRING_LEN, strings[i],
+			set->active & mask ? "enabled" : "disabled",
+			expected->active & mask ? "enabled" : "disabled",
+			!(set->available & mask) ? "not user-changeable" :
+				set->requested & mask ? "enabled" : "disabled"
+		);
+	}
+}
+
+static int get_offload_state(int fd, struct ifreq *ifr,
+	struct ethtool_gfeatures **features,
+	struct offload_state *offload)
+{
+	int err, allfail;
+
+	allfail =3D send_goffloads(fd, ifr, offload);
+
+	err =3D init_feature_strings();
+	if (err < 0)
+		return allfail ? err : 0;
+
+	err =3D send_gfeatures(fd, ifr, features);
+	if (err)
+		perror("Cannot read features");
+
+	return allfail ? -err : 0;
+}
+
+static int send_sfeatures(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	features_req->cmd =3D ETHTOOL_SFEATURES;
+	ifr->ifr_data =3D (caddr_t) features_req;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot change features");
+		return 97;
+	}
+
+	return 0;
+}
+
+static void compare_offload_state(struct offload_state *offload0,
+	struct offload_state *offload1)
+{
+	int *expected =3D (int *)offload0, *new =3D (int *)offload1;
+	int i;
+
+	if (off_csum_rx_wanted >=3D 0)
+		offload0->rx =3D off_csum_rx_wanted;
+
+	if (off_csum_tx_wanted >=3D 0)
+		offload0->tx =3D off_csum_tx_wanted;
+
+	if (off_sg_wanted >=3D 0)
+		offload0->sg =3D off_sg_wanted;
+
+	if (off_tso_wanted >=3D 0)
+		offload0->tso =3D off_tso_wanted;
+
+	if (off_ufo_wanted >=3D 0)
+		offload0->ufo =3D off_ufo_wanted;
+
+	if (off_gso_wanted >=3D 0)
+		offload0->gso =3D off_gso_wanted;
+
+	if (off_gro_wanted >=3D 0)
+		offload0->gro =3D off_gro_wanted;
+
+	if (off_flags_mask & ETH_FLAG_LRO)
+		offload0->lro =3D !!(off_flags_wanted & ETH_FLAG_LRO);
+
+	if (off_flags_mask & ETH_FLAG_RXVLAN)
+		offload0->rxvlan =3D !!(off_flags_wanted & ETH_FLAG_RXVLAN);
+
+	if (off_flags_mask & ETH_FLAG_TXVLAN)
+		offload0->txvlan =3D !!(off_flags_wanted & ETH_FLAG_TXVLAN);
+
+	if (off_flags_mask & ETH_FLAG_NTUPLE)
+		offload0->ntuple =3D !!(off_flags_wanted & ETH_FLAG_NTUPLE);
+
+	if (off_flags_mask & ETH_FLAG_RXHASH)
+		offload0->rxhash =3D !!(off_flags_wanted & ETH_FLAG_RXHASH);
+
+	for (i =3D 0; i < ARRAY_SIZE(old_feature_names); i++) {
+		if (expected[i] =3D=3D new[i])
+			continue;
+
+		fprintf(stderr, "feature group %s is %s (expected: %s)\n",
+			old_feature_names[i],
+			new[i] ? "enabled" : "disabled",
+			expected[i] ? "enabled" : "disabled"
+		);
+	}
+}
+
+static void compare_features(struct ethtool_gfeatures *features0,
+	struct ethtool_gfeatures *features1)
+{
+	int i;
+
+	/* make features0 .active what we expect to be set */
+	i =3D (n_feature_strings + 31) / 32;
+	while (i--) {
+		features0->features[i].active &=3D ~features_req->features[i].valid;
+		features0->features[i].active |=3D
+			features_req->features[i].requested &
+			features_req->features[i].valid;
+	}
+
+	for (i =3D 0; i < n_feature_strings; i +=3D 32)
+		print_gfeatures_diff(&features0->features[i / 32],
+			&features1->features[i / 32],
+			feature_strings + i,
+			n_feature_strings - i);
+}
+
+static int do_soffload(int fd, struct ifreq *ifr)
+{
+	struct ethtool_gfeatures *features_old, *features_new;
+	struct offload_state offload_old, offload_new;
+	int err, changed;
+
+	err =3D get_offload_state(fd, ifr, &features_old, &offload_old);
+	if (err)
+		return -err;
+
+	changed =3D send_soffloads(fd, ifr);
+
+	if (features_req) {
+		err =3D send_sfeatures(fd, ifr);
+		if (!err)
+			changed =3D 1;
+	}
+
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
+		return err;
+	}
+
+	err =3D get_offload_state(fd, ifr, &features_new, &offload_new);
+	if (err) {
+		perror("can't verify offload setting");
+		return 101;
+	}
+	if ((!features_old) ^ (!features_new)) {
+		fprintf(stderr, "can't compare features (one GFEATURES failed)\n");
+		features_old =3D NULL;
 	}
=20
+	compare_offload_state(&offload_old, &offload_new);
+	if (features_old)
+		compare_features(features_old, features_new);
+
 	return 0;
 }
=20

