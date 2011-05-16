From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH ethtool] ethtool: implement G/SFEATURES calls
Date: Mon, 16 May 2011 22:54:20 +0200 (CEST)
Message-ID: <feef455dde958796b578892a48d26461e9d75fd9.1305576698.git.mirq-linux@rere.qmqm.pl>
References: <20110516205137.GA7667@rere.qmqm.pl>
	<20110516121339.GA1094@rere.qmqm.pl>
        <1305335142.2851.70.camel@bwh-desktop>
        <20110514103539.GA5214@rere.qmqm.pl>
        <1305513923.19966.20.camel@localhost>
        <20110516132807.1A89F13A6A@rere.qmqm.pl>
        <1305553066.19966.32.camel@localhost>
        <20110516142340.GA2980@rere.qmqm.pl>
        <1305557597.2885.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43184 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755859Ab1EPUyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 16:54:22 -0400
In-Reply-To: <20110516205137.GA7667@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 ethtool.c |  299 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++--
 1 files changed, 293 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 34fe107..86a5a8b 100644
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
@@ -83,6 +84,9 @@ static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
+static void parse_sfeatures_args(int argc, char **argp, int argi);
+static int do_gfeatures(int fd, struct ifreq *ifr);
+static int do_sfeatures(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
@@ -119,6 +123,8 @@ static enum {
 	MODE_SRING,
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
+	MODE_GFEATURES,
+	MODE_SFEATURES,
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
@@ -197,6 +203,10 @@ static struct option {
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
     },
+    { "-w", "--show-features", MODE_GFEATURES, "Get offload status" },
+    { "-W", "--request-features", MODE_SFEATURES, "Set requested offlo=
ad",
+		"		[ feature-name on|off [...] ]\n"
+		"		see --show-features output for feature-name strings\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
 		"		[ raw on|off ]\n"
@@ -768,6 +778,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode =3D=3D MODE_SRING) ||
 			    (mode =3D=3D MODE_GOFFLOAD) ||
 			    (mode =3D=3D MODE_SOFFLOAD) ||
+			    (mode =3D=3D MODE_GFEATURES) ||
+			    (mode =3D=3D MODE_SFEATURES) ||
 			    (mode =3D=3D MODE_GSTATS) ||
 			    (mode =3D=3D MODE_GNFC) ||
 			    (mode =3D=3D MODE_SNFC) ||
@@ -858,6 +870,11 @@ static void parse_cmdline(int argc, char **argp)
 				i =3D argc;
 				break;
 			}
+			if (mode =3D=3D MODE_SFEATURES) {
+				parse_sfeatures_args(argc, argp, i);
+				i =3D argc;
+				break;
+			}
 			if (mode =3D=3D MODE_SCLSRULE) {
 				if (!strcmp(argp[i], "flow-type")) {
 					i +=3D 1;
@@ -1867,21 +1884,30 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
=20
-static int doit(void)
+static int get_control_socket(struct ifreq *ifr)
 {
-	struct ifreq ifr;
 	int fd;
=20
 	/* Setup our control structures. */
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, devname);
+	memset(ifr, 0, sizeof(*ifr));
+	strcpy(ifr->ifr_name, devname);
=20
 	/* Open control socket. */
 	fd =3D socket(AF_INET, SOCK_DGRAM, 0);
-	if (fd < 0) {
+	if (fd < 0)
 		perror("Cannot get control socket");
+
+	return fd;
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
@@ -1918,6 +1944,10 @@ static int doit(void)
 		return do_goffload(fd, &ifr);
 	} else if (mode =3D=3D MODE_SOFFLOAD) {
 		return do_soffload(fd, &ifr);
+	} else if (mode =3D=3D MODE_GFEATURES) {
+		return do_gfeatures(fd, &ifr);
+	} else if (mode =3D=3D MODE_SFEATURES) {
+		return do_sfeatures(fd, &ifr);
 	} else if (mode =3D=3D MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
 	} else if (mode =3D=3D MODE_GNFC) {
@@ -2355,6 +2385,263 @@ static int do_soffload(int fd, struct ifreq *if=
r)
 	return 0;
 }
=20
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
+	if ((err < 0) ||
+	    (!(sset_info->sset_mask & (1ULL << ETH_SS_FEATURES)))) {
+		perror("Cannot get driver strings info");
+		return -100;
+	}
+
+	n_strings =3D sset_info->data[0];
+	free(sset_info);
+	sz_str =3D n_strings * ETH_GSTRING_LEN;
+
+	strings =3D calloc(1, sz_str + sizeof(struct ethtool_gstrings));
+	if (!strings) {
+		fprintf(stderr, "no memory available\n");
+		return -95;
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
+		return -96;
+	}
+
+	*strs =3D strings;
+	return n_strings;
+}
+
+struct ethtool_sfeatures *features_req;
+
+static void parse_sfeatures_args(int argc, char **argp, int argi)
+{
+	struct cmdline_info *cmdline_desc, *cp;
+	struct ethtool_gstrings *strings;
+	struct ifreq ifr;
+	int n_strings, sz_features, i;
+	int fd, changed =3D 0;
+
+	fd =3D get_control_socket(&ifr);
+	if (fd < 0)
+		exit(100);
+
+	n_strings =3D get_feature_strings(fd, &ifr, &strings);
+	if (n_strings < 0)
+		exit(-n_strings);
+
+	sz_features =3D sizeof(*features_req->features) * ((n_strings + 31) /=
 32);
+
+	cp =3D cmdline_desc =3D calloc(n_strings, sizeof(*cmdline_desc));
+	features_req =3D calloc(1, sizeof(*features_req) + sz_features);
+	if (!cmdline_desc || !features_req) {
+		fprintf(stderr, "no memory available\n");
+		exit(95);
+	}
+
+	features_req->size =3D (n_strings + 31) / 32;
+
+	for (i =3D 0; i < n_strings; ++i) {
+		if (!strings->data[i*ETH_GSTRING_LEN])
+			continue;
+
+		strings->data[i*ETH_GSTRING_LEN + ETH_GSTRING_LEN-1] =3D 0;
+		cp->name =3D (const char *)strings->data + i * ETH_GSTRING_LEN;
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
+	free(strings);
+	close(fd);
+
+	if (!changed) {
+		free(features_req);
+		features_req =3D NULL;
+	}
+}
+
+static int send_gfeatures(int fd, struct ifreq *ifr, int n_strings,
+	struct ethtool_gfeatures **features_p)
+{
+	struct ethtool_gfeatures *features;
+	int err, sz_features;
+
+	sz_features =3D sizeof(*features->features) * ((n_strings + 31) / 32)=
;
+	features =3D calloc(1, sz_features + sizeof(*features));
+	if (!features) {
+		fprintf(stderr, "no memory available\n");
+		return 95;
+	}
+
+	features->cmd =3D ETHTOOL_GFEATURES;
+	features->size =3D (n_strings + 31) / 32;
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
+	struct ethtool_gstrings *strings;
+	struct ethtool_gfeatures *features;
+	int n_strings, err, i;
+
+	n_strings =3D get_feature_strings(fd, ifr, &strings);
+	if (n_strings < 0)
+		return -n_strings;
+
+	err =3D send_gfeatures(fd, ifr, n_strings, &features);
+	if (err) {
+		free(strings);
+		return err;
+	}
+
+	fprintf(stdout, "Offload state:  (name: enabled,wanted,changable)\n")=
;
+	for (i =3D 0; i < n_strings; i++) {
+		if (!strings->data[i * ETH_GSTRING_LEN])
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
+			ETH_GSTRING_LEN, ETH_GSTRING_LEN,
+			&strings->data[i * ETH_GSTRING_LEN],
+			P_FLAG(active), PA_FLAG(requested), PN_FLAG(available));
+#undef P_FLAG
+#undef PA_FLAG
+#undef PN_FLAG
+	}
+	free(strings);
+	free(features);
+
+	return 0;
+}
+
+static void print_gfeatures_diff(
+	const struct ethtool_get_features_block *expected,
+	const struct ethtool_get_features_block *set,
+	const char *strings, int n_strings)
+{
+	int i;
+
+	if (n_strings > 32)
+		n_strings =3D 32;
+
+	for (i =3D 0; i < n_strings; ++i) {
+		const char *name =3D &strings[i * ETH_GSTRING_LEN];
+		u32 mask =3D 1 << i;
+
+		if (!((expected->active ^ set->active) & mask))
+			continue;
+
+		fprintf(stderr, "feature %.*s is %s (expected: %s, saved: %s)\n",
+			ETH_GSTRING_LEN, name,
+			set->active & mask ? "enabled" : "disabled",
+			expected->active & mask ? "enabled" : "disabled",
+			!(set->available & mask) ? "not user-changeable" :
+				set->requested & mask ? "enabled" : "disabled"
+		);
+	}
+}
+
+static int do_sfeatures(int fd, struct ifreq *ifr)
+{
+	struct ethtool_gstrings *strings;
+	struct ethtool_gfeatures *features0, *features1;
+	int n_strings, err, i;
+
+	if (!features_req) {
+		fprintf(stderr, "no features changed\n");
+		return 97;
+	}
+
+	n_strings =3D get_feature_strings(fd, ifr, &strings);
+	if (n_strings < 0) {
+		free(features_req);
+		return -n_strings;
+	}
+
+	err =3D send_gfeatures(fd, ifr, n_strings, &features0);
+	if (err) {
+		perror("Cannot read features");
+		goto free_strings;
+	}
+
+	features_req->cmd =3D ETHTOOL_SFEATURES;
+	ifr->ifr_data =3D (caddr_t) features_req;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot change features");
+		err =3D 97;
+		goto free_features;
+	}
+
+	err =3D send_gfeatures(fd, ifr, n_strings, &features1);
+	if (err) {
+		perror("Cannot verify features");
+		goto free_features;
+	}
+
+	/* make features0 .active what we expect to be set */
+	i =3D (n_strings + 31) / 32;
+	while (i--) {
+		features0->features[i].active &=3D ~features_req->features[i].valid;
+		features0->features[i].active |=3D
+			features_req->features[i].requested &
+			features_req->features[i].valid;
+	}
+
+	for (i =3D 0; i < n_strings; i +=3D 32)
+		print_gfeatures_diff(&features0->features[i / 32],
+			&features1->features[i / 32],
+			(char *)&strings->data[i * ETH_GSTRING_LEN],
+			n_strings - i);
+
+	free(features1);
+free_features:
+	free(features0);
+free_strings:
+	free(strings);
+	free(features_req);
+	return err;
+}
+
+
 static int do_gset(int fd, struct ifreq *ifr)
 {
 	int err;
--=20
1.7.2.5

