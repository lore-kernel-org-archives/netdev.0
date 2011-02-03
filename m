From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] ethtool: implement G/SFEATURES calls
Date: Thu,  3 Feb 2011 15:21:22 +0100 (CET)
Message-ID: <1e5582f1c332160fa03e6a19c26b87b52757e0fa.1296741540.git.mirq-linux@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34561 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222Ab1BCOV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 09:21:26 -0500
In-Reply-To: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Changes from v1:
 - removed deprecation of -k/-K
 - mark never-changeable features in userspace

---

 ethtool-copy.h |   89 +++++++++++++++++++++++-
 ethtool.c      |  215 ++++++++++++++++++++++++++++++++++++++++++++++++=
++++++--
 2 files changed, 296 insertions(+), 8 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..6430dbd 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -251,6 +251,7 @@ enum ethtool_stringset {
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
 	ETH_SS_NTUPLE_FILTERS,
+	ETH_SS_FEATURES,
 };
=20
 /* for passing string sets for data tagging */
@@ -523,6 +524,87 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
=20
+/* for returning and changing feature sets */
+
+/**
+ * struct ethtool_get_features_block - block with state of 32 features
+ * @available: mask of changeable features
+ * @requested: mask of features requested to be enabled if possible
+ * @active: mask of currently enabled features
+ * @never_changed: mask of features not changeable for any device
+ */
+struct ethtool_get_features_block {
+	__u32	available;
+	__u32	requested;
+	__u32	active;
+	__u32	never_changed;
+};
+
+/**
+ * struct ethtool_gfeatures - command to get state of device's feature=
s
+ * @cmd: command number =3D %ETHTOOL_GFEATURES
+ * @size: in: number of elements in the features[] array;
+ *       out: number of elements in features[] needed to hold all feat=
ures
+ * @features: state of features
+ */
+struct ethtool_gfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_get_features_block features[0];
+};
+
+/**
+ * struct ethtool_set_features_block - block with request for 32 featu=
res
+ * @valid: mask of features to be changed
+ * @requested: values of features to be changed
+ */
+struct ethtool_set_features_block {
+	__u32	valid;
+	__u32	requested;
+};
+
+/**
+ * struct ethtool_sfeatures - command to request change in device's fe=
atures
+ * @cmd: command number =3D %ETHTOOL_SFEATURES
+ * @size: array size of the features[] array
+ * @features: feature change masks
+ */
+struct ethtool_sfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_set_features_block features[0];
+};
+
+/*
+ * %ETHTOOL_SFEATURES changes features present in features[].valid to =
the
+ * values of corresponding bits in features[].requested. Bits in .requ=
ested
+ * not set in .valid or not changeable are ignored.
+ *
+ * Returns %EINVAL when .valid contains undefined or never-changable b=
its
+ * or size is not equal to required number of features words (32-bit b=
locks).
+ * Returns >=3D 0 if request was completed; bits set in the value mean=
:
+ *   %ETHTOOL_F_UNSUPPORTED - there were bits set in .valid that are n=
ot
+ *	changeable (not present in %ETHTOOL_GFEATURES' features[].available=
)
+ *	those bits were ignored.
+ *   %ETHTOOL_F_WISH - some or all changes requested were recorded but=
 the
+ *      resulting state of bits masked by .valid is not equal to .requ=
ested.
+ *      Probably there are other device-specific constraints on some f=
eatures
+ *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is cons=
idered
+ *      here as though ignored bits were cleared.
+ *
+ * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (n=
umber of
+ * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS c=
ommands
+ * for ETH_SS_FEATURES string set. First entry in the table correspond=
s to least
+ * significant bit in features[0] fields. Empty strings mark undefined=
 features.
+ */
+enum ethtool_sfeatures_retval_bits {
+	ETHTOOL_F_UNSUPPORTED__BIT,
+	ETHTOOL_F_WISH__BIT,
+};
+
+#define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
+#define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
+
=20
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -534,7 +616,9 @@ struct ethtool_flash {
 #define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
 #define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
-#define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) *=
/
+/* Get link status for host, i.e. whether the interface *and* the
+ * physical port (if there is one) are up (ethtool_value). */
+#define ETHTOOL_GLINK		0x0000000a
 #define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
 #define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
@@ -585,6 +669,9 @@ struct ethtool_flash {
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n tabl=
e */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n tabl=
e */
=20
+#define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
+#define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings=
 */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/ethtool.c b/ethtool.c
index 1afdfe4..af43e47 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -39,6 +39,7 @@
 #include <limits.h>
 #include <ctype.h>
=20
+#include <unistd.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -97,6 +98,9 @@ static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
+static void parse_sfeatures_args(int argc, char **argp, int argi);
+static int do_gfeatures(int fd, struct ifreq *ifr);
+static int do_sfeatures(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
@@ -133,6 +137,8 @@ static enum {
 	MODE_SRING,
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
+	MODE_GFEATURES,
+	MODE_SFEATURES,
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
@@ -211,6 +217,10 @@ static struct option {
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
@@ -743,8 +753,10 @@ static void parse_generic_cmdline(int argc, char *=
*argp,
 				break;
 			}
 		}
-		if( !found)
+		if( !found) {
+			fprintf(stdout, "bad param: %s\n", argp[i]);
 			show_usage(1);
+		}
 	}
 }
=20
@@ -829,6 +841,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode =3D=3D MODE_SRING) ||
 			    (mode =3D=3D MODE_GOFFLOAD) ||
 			    (mode =3D=3D MODE_SOFFLOAD) ||
+			    (mode =3D=3D MODE_GFEATURES) ||
+			    (mode =3D=3D MODE_SFEATURES) ||
 			    (mode =3D=3D MODE_GSTATS) ||
 			    (mode =3D=3D MODE_GNFC) ||
 			    (mode =3D=3D MODE_SNFC) ||
@@ -919,6 +933,11 @@ static void parse_cmdline(int argc, char **argp)
 				i =3D argc;
 				break;
 			}
+			if (mode =3D=3D MODE_SFEATURES) {
+				parse_sfeatures_args(argc, argp, i);
+				i =3D argc;
+				break;
+			}
 			if (mode =3D=3D MODE_SNTUPLE) {
 				if (!strcmp(argp[i], "flow-type")) {
 					i +=3D 1;
@@ -1947,21 +1966,30 @@ static int dump_rxfhash(int fhash, u64 val)
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
@@ -1998,6 +2026,10 @@ static int doit(void)
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
@@ -2435,6 +2467,175 @@ static int do_soffload(int fd, struct ifreq *if=
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
+static int do_gfeatures(int fd, struct ifreq *ifr)
+{
+	struct ethtool_gstrings *strings;
+	struct ethtool_gfeatures *features;
+	int n_strings, sz_features, err, i;
+
+	n_strings =3D get_feature_strings(fd, ifr, &strings);
+	if (n_strings < 0)
+		return -n_strings;
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
+	if (err < 0) {
+		perror("Cannot get feature status");
+		free(strings);
+		free(features);
+		return 97;
+	}
+
+	fprintf(stdout, "Offload state:  (name: enabled,wanted,changable)\n")=
;
+	for (i =3D 0; i < n_strings; i++) {
+		if (!strings->data[i * ETH_GSTRING_LEN])
+			continue;	/* empty */
+#define P_FLAG(f) \
+	(features->features[i / 32].f & (1 << (i % 32))) ? "yes" : " no"
+#define PN_FLAG(f) \
+	(features->features[i / 32].never_changed & (1 << (i % 32))) ? "---" =
: P_FLAG(f)
+		fprintf(stdout, "     %-*.*s %s,%s,%s\n",
+			ETH_GSTRING_LEN, ETH_GSTRING_LEN,
+			&strings->data[i * ETH_GSTRING_LEN],
+			P_FLAG(active), PN_FLAG(requested), PN_FLAG(available));
+#undef P_FLAG
+	}
+	free(strings);
+	free(features);
+
+	return 0;
+}
+
+static int do_sfeatures(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	if (!features_req) {
+		fprintf(stderr, "no features changed\n");
+		return 97;
+	}
+
+	features_req->cmd =3D ETHTOOL_SFEATURES;
+	ifr->ifr_data =3D (caddr_t) features_req;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot change features");
+		free(features_req);
+		return 97;
+	}
+
+	return 0;
+}
+
+
 static int do_gset(int fd, struct ifreq *ifr)
 {
 	int err;
--=20
1.7.2.3

