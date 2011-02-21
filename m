From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/3] ethtool: Regularise handling of offload flags
Date: Mon, 21 Feb 2011 16:59:08 +0000
Message-ID: <1298307548.2608.50.camel@bwh-desktop>
References: <1298307282.2608.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56881 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab1BUQ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:59:10 -0500
In-Reply-To: <1298307282.2608.47.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new ETHTOOL_{G,S}FEATURES operations where available, and
use the new structure and netif feature flags in any case.

Replace repetitive code for getting/setting offload flags with data-
driven loops.

This changes error messages to use the same long names for offload
flags as in dump_offload(), and changes various exit codes to 1.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
NEITF_F_* flags are copied into ethtool-util.h for now.  I think in
future they should be exposed from <linux/netdevice.h> (hence the
#ifndef).

Ben.

 ethtool-util.h |   30 ++++
 ethtool.c      |  441 +++++++++++++++++++++++++++-----------------------------
 2 files changed, 243 insertions(+), 228 deletions(-)

diff --git a/ethtool-util.h b/ethtool-util.h
index f053028..a118202 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -40,6 +40,36 @@ static inline u32 cpu_to_be32(u32 value)
 }
 #endif
 
+#ifndef NETIF_F_SG
+#define NETIF_F_SG		(1 << 0)
+#define NETIF_F_IP_CSUM		(1 << 1)
+#define NETIF_F_NO_CSUM		(1 << 2)
+#define NETIF_F_HW_CSUM		(1 << 3)
+#define NETIF_F_IPV6_CSUM	(1 << 4)
+#define NETIF_F_FRAGLIST	(1 << 6)
+#define NETIF_F_HW_VLAN_TX	(1 << 7)
+#define NETIF_F_HW_VLAN_RX	(1 << 8)
+#define NETIF_F_HW_VLAN_FILTER	(1 << 9)
+#define NETIF_F_GSO		(1 << 11)
+#define NETIF_F_GRO		(1 << 14)
+#define NETIF_F_LRO		(1 << 15)
+#define NETIF_F_TSO		(1 << 16)
+#define NETIF_F_UFO		(1 << 17)
+#define NETIF_F_GSO_ROBUST	(1 << 18)
+#define NETIF_F_TSO_ECN		(1 << 19)
+#define NETIF_F_TSO6		(1 << 20)
+#define NETIF_F_FSO		(1 << 21)
+#define NETIF_F_FCOE_CRC	(1 << 24)
+#define NETIF_F_SCTP_CSUM	(1 << 25)
+#define NETIF_F_FCOE_MTU	(1 << 26)
+#define NETIF_F_NTUPLE		(1 << 27)
+#define NETIF_F_RXHASH		(1 << 28)
+#define NETIF_F_RXCSUM		(1 << 29)
+#define NETIF_F_ALL_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM | \
+				 NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+#endif
+
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,
diff --git a/ethtool.c b/ethtool.c
index f680b6d..25601a5 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -299,15 +299,7 @@ static void show_usage(int badarg)
 static char *devname = NULL;
 
 static int goffload_changed = 0;
-static int off_csum_rx_wanted = -1;
-static int off_csum_tx_wanted = -1;
-static int off_sg_wanted = -1;
-static int off_tso_wanted = -1;
-static int off_ufo_wanted = -1;
-static int off_gso_wanted = -1;
-static u32 off_flags_wanted = 0;
-static u32 off_flags_mask = 0;
-static int off_gro_wanted = -1;
+struct ethtool_set_features_block off_features;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -463,23 +455,30 @@ static struct cmdline_info cmdline_seeprom[] = {
 };
 
 static struct cmdline_info cmdline_offload[] = {
-	{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
-	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
-	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
-	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
-	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
-	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
-	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_LRO, &off_flags_mask },
-	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
-	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXVLAN, &off_flags_mask },
-	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_TXVLAN, &off_flags_mask },
-	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_NTUPLE, &off_flags_mask },
-	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXHASH, &off_flags_mask },
+	{ "rx", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_RXCSUM, &off_features.valid },
+	{ "tx", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_ALL_CSUM, &off_features.valid },
+	{ "sg", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_SG, &off_features.valid },
+	{ "tso", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_ALL_TSO, &off_features.valid },
+	{ "ufo", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_UFO, &off_features.valid },
+	{ "gso", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_GSO, &off_features.valid },
+	{ "lro", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_LRO, &off_features.valid },
+	{ "gro", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_GRO, &off_features.valid },
+	{ "rxvlan", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features.valid },
+	{ "txvlan", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features.valid },
+	{ "ntuple", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_NTUPLE, &off_features.valid },
+	{ "rxhash", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_RXHASH, &off_features.valid },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1872,35 +1871,39 @@ static int dump_coalesce(void)
 	return 0;
 }
 
-static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro, int rxvlan, int txvlan, int ntuple,
-			int rxhash)
+static const struct {
+	const char *long_name;
+	u32 cmd;
+	u32 value;
+} off_feature_def[] = {
+	{ "rx-checksumming",		  ETHTOOL_GRXCSUM, NETIF_F_RXCSUM },
+	{ "tx-checksumming",		  ETHTOOL_GTXCSUM, NETIF_F_ALL_CSUM },
+	{ "scatter-gather",		  ETHTOOL_GSG,	   NETIF_F_SG },
+	{ "tcp-segmentation-offload",	  ETHTOOL_GTSO,	   NETIF_F_ALL_TSO },
+	{ "udp-fragmentation-offload",	  ETHTOOL_GUFO,	   NETIF_F_UFO },
+	{ "generic-segmentation-offload", ETHTOOL_GGSO,	   NETIF_F_GSO },
+	{ "generic-receive-offload",	  ETHTOOL_GGRO,	   NETIF_F_GRO },
+	{ "large-receive-offload",	  0,		   NETIF_F_LRO },
+	{ "rx-vlan-offload",		  0,		   NETIF_F_HW_VLAN_RX },
+	{ "tx-vlan-offload",		  0,		   NETIF_F_HW_VLAN_TX },
+	{ "ntuple-filters",		  0,		   NETIF_F_NTUPLE },
+	{ "receive-hashing",		  0,		   NETIF_F_RXHASH },
+};
+
+static int dump_offload(const struct ethtool_get_features_block *features)
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
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		value = off_feature_def[i].value;
+		printf("%s: %s%s%s\n",
+		       off_feature_def[i].long_name,
+		       (features->active & value) ? "on" : "off",
+		       (features->requested & ~features->active & value) ?
+		       " [requested on]" : "",
+		       (~features->available & value) ? " [unchangeable]" : "");
+	}
 
 	return 0;
 }
@@ -2219,97 +2222,72 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+/* the following list of flags are the same as their associated
+ * NETIF_F_xxx values in include/linux/netdevice.h
+ */
+static const u32 flags_dup_features =
+	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
+	 ETH_FLAG_RXHASH);
+
 static int do_goffload(int fd, struct ifreq *ifr)
 {
+	struct {
+		struct ethtool_gfeatures cmd;
+		struct ethtool_get_features_block data[1];
+	} features;
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
-	    ntuple = 0, rxhash = 0;
+	int err, allfail = 1;
+	u32 value;
+	int i;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
-	eval.cmd = ETHTOOL_GRXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device rx csum settings");
-	else {
-		rx = eval.data;
+	features.cmd.cmd = ETHTOOL_GFEATURES;
+	features.cmd.size = ARRAY_SIZE(features.data);
+	ifr->ifr_data = (caddr_t)&features;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err == 0) {
 		allfail = 0;
-	}
+	} else if (errno != EOPNOTSUPP && errno != EPERM) {
+		perror("Cannot get device offload settings");
+	} else {
+		memset(&features.data, 0, sizeof(features.data));
 
-	eval.cmd = ETHTOOL_GTXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device tx csum settings");
-	else {
-		tx = eval.data;
-		allfail = 0;
-	}
+		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+			value = off_feature_def[i].value;
 
-	eval.cmd = ETHTOOL_GSG;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device scatter-gather settings");
-	else {
-		sg = eval.data;
-		allfail = 0;
-	}
+			/* Assume that anything we can get is changeable */
+			features.data[0].available |= value;
 
-	eval.cmd = ETHTOOL_GTSO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device tcp segmentation offload settings");
-	else {
-		tso = eval.data;
-		allfail = 0;
-	}
+			if (!off_feature_def[i].cmd)
+				continue;
 
-	eval.cmd = ETHTOOL_GUFO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err)
-		perror("Cannot get device udp large send offload settings");
-	else {
-		ufo = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GGSO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err)
-		perror("Cannot get device generic segmentation offload settings");
-	else {
-		gso = eval.data;
-		allfail = 0;
-	}
+			eval.cmd = off_feature_def[i].cmd;
+			ifr->ifr_data = (caddr_t)&eval;
+			err = send_ioctl(fd, ifr);
+			if (err) {
+				fprintf(stderr,
+					"Cannot get device %s settings: %m\n",
+					off_feature_def[i].long_name);
+			} else {
+				if (eval.data)
+					features.data[0].active |= value;
+				allfail = 0;
+			}
+		}
 
-	eval.cmd = ETHTOOL_GFLAGS;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err) {
-		perror("Cannot get device flags");
-	} else {
-		lro = (eval.data & ETH_FLAG_LRO) != 0;
-		rxvlan = (eval.data & ETH_FLAG_RXVLAN) != 0;
-		txvlan = (eval.data & ETH_FLAG_TXVLAN) != 0;
-		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
-		rxhash = (eval.data & ETH_FLAG_RXHASH) != 0;
-		allfail = 0;
-	}
+		eval.cmd = ETHTOOL_GFLAGS;
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot get device flags");
+		} else {
+			features.data[0].active |=
+				eval.data & flags_dup_features;
+			allfail = 0;
+		}
 
-	eval.cmd = ETHTOOL_GGRO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err)
-		perror("Cannot get device GRO settings");
-	else {
-		gro = eval.data;
-		allfail = 0;
+		features.data[0].requested = features.data[0].active;
 	}
 
 	if (allfail) {
@@ -2317,114 +2295,121 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
-			    ntuple, rxhash);
+	return dump_offload(features.data);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
 {
+	struct {
+		struct ethtool_gfeatures cmd;
+		struct ethtool_get_features_block data[1];
+	} get_features;
+	struct {
+		struct ethtool_sfeatures cmd;
+		struct ethtool_set_features_block data[1];
+	} set_features;
 	struct ethtool_value eval;
 	int err, changed = 0;
+	u32 value;
+	int i;
 
-	if (off_csum_rx_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SRXCSUM;
-		eval.data = (off_csum_rx_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
-		if (err) {
-			perror("Cannot set device rx csum settings");
-			return 84;
+	get_features.cmd.cmd = ETHTOOL_GFEATURES;
+	get_features.cmd.size = ARRAY_SIZE(get_features.data);
+	ifr->ifr_data = (caddr_t)&get_features;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err == 0) {
+		set_features.cmd.cmd = ETHTOOL_SFEATURES;
+		set_features.cmd.size = ARRAY_SIZE(set_features.data);
+		set_features.data[0] = off_features;
+
+		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+			value = off_feature_def[i].value;
+			if (!(off_features.valid & value))
+				continue;
+			if (!(get_features.data[0].available & value)) {
+				/* None of these features can be changed */
+				fprintf(stderr,
+					"Cannot set device %s settings: "
+					"Operation not supported\n",
+					off_feature_def[i].long_name);
+			} else if (off_features.requested & value) {
+				/* Some of these features can be
+				 * enabled; mask out any that cannot
+				 */
+				set_features.data[0].requested &=
+					~(value &
+					  ~get_features.data[0].available);
+			}
 		}
-	}
 
-	if (off_csum_tx_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_STXCSUM;
-		eval.data = (off_csum_tx_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
-		if (err) {
-			perror("Cannot set device tx csum settings");
-			return 85;
+		ifr->ifr_data = (caddr_t)&set_features;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0) {
+			perror("Cannot set device offload settings");
+			return 1;
 		}
-	}
 
-	if (off_sg_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SSG;
-		eval.data = (off_sg_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
-		if (err) {
-			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
-	}
+		changed = !!set_features.data[0].valid;
 
-	if (off_tso_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_STSO;
-		eval.data = (off_tso_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
-		if (err) {
-			perror("Cannot set device tcp segmentation offload settings");
-			return 88;
-		}
-	}
-	if (off_ufo_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SUFO;
-		eval.data = (off_ufo_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device udp large send offload settings");
-			return 89;
-		}
-	}
-	if (off_gso_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SGSO;
-		eval.data = (off_gso_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device generic segmentation offload settings");
-			return 90;
-		}
-	}
-	if (off_flags_mask) {
-		changed = 1;
-		eval.cmd = ETHTOOL_GFLAGS;
-		eval.data = 0;
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot get device flag settings");
-			return 91;
+		if (err & ETHTOOL_F_WISH)
+			fprintf(stderr,
+				"Cannot set device offload settings: "
+				"Some requested features depend on others "
+				"that are not currently enabled\n");
+
+		/* ETHTOOL_F_UNSUPPORTED should never be set as we
+		 * checked for unsupported flags above.  Treat any
+		 * other warning flags as unknown.
+		 */
+		if (err & ~ETHTOOL_F_WISH)
+			fprintf(stderr,
+				"Cannot set device offload settings: "
+				"warning flags %#x",
+				err & ~ETHTOOL_F_WISH);
+	} else if (errno != EOPNOTSUPP && errno != EPERM) {
+		perror("Cannot get device offload settings");
+		return 1;
+	} else {
+		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+			if (!off_feature_def[i].cmd)
+				continue;
+			if (off_features.valid & off_feature_def[i].value) {
+				changed = 1;
+				eval.cmd = off_feature_def[i].cmd + 1;
+				eval.data = !!(off_features.requested &
+					       off_feature_def[i].value);
+				ifr->ifr_data = (caddr_t)&eval;
+				err = send_ioctl(fd, ifr);
+				if (err) {
+					fprintf(stderr,
+						"Cannot set device %s settings: %m\n",
+						off_feature_def[i].long_name);
+					return 1;
+				}
+			}
 		}
 
-		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
+		if (off_features.valid & flags_dup_features) {
+			changed = 1;
+			eval.cmd = ETHTOOL_GFLAGS;
+			eval.data = 0;
+			ifr->ifr_data = (caddr_t)&eval;
+			err = ioctl(fd, SIOCETHTOOL, ifr);
+			if (err) {
+				perror("Cannot get device flag settings");
+				return 91;
+			}
 
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
-		}
-	}
-	if (off_gro_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SGRO;
-		eval.data = (off_gro_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device GRO settings");
-			return 93;
+			eval.cmd = ETHTOOL_SFLAGS;
+			eval.data &= ~(off_features.valid & flags_dup_features);
+			eval.data |= (off_features.requested &
+				      flags_dup_features);
+
+			err = ioctl(fd, SIOCETHTOOL, ifr);
+			if (err) {
+				perror("Cannot set device flag settings");
+				return 92;
+			}
 		}
 	}
 
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

