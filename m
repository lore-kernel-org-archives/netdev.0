From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH ethtool 1/3] ethtool: Regularise offload feature
 settings
Date: Mon, 16 May 2011 16:57:34 +0100
Message-ID: <1305561454.2885.15.camel@bwh-desktop>
References: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24119 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247Ab1EPP5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 11:57:38 -0400
In-Reply-To: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
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
 ethtool-util.h |   24 ++++
 ethtool.c      |  321 ++++++++++++++++++-------------------------------------
 2 files changed, 129 insertions(+), 216 deletions(-)

diff --git a/ethtool-util.h b/ethtool-util.h
index 79be7f2..10b8c00 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -67,6 +67,30 @@ static inline u64 cpu_to_be64(u64 value)
 
 #define	RX_CLS_LOC_UNSPEC	0xffffffffUL
 
+#ifndef NETIF_F_SG
+#define NETIF_F_SG		(1 << 0)
+#define NETIF_F_IP_CSUM		(1 << 1)
+#define NETIF_F_NO_CSUM		(1 << 2)
+#define NETIF_F_HW_CSUM		(1 << 3)
+#define NETIF_F_IPV6_CSUM	(1 << 4)
+#define NETIF_F_HW_VLAN_TX	(1 << 7)
+#define NETIF_F_HW_VLAN_RX	(1 << 8)
+#define NETIF_F_HW_VLAN_FILTER	(1 << 9)
+#define NETIF_F_GSO		(1 << 11)
+#define NETIF_F_GRO		(1 << 14)
+#define NETIF_F_LRO		(1 << 15)
+#define NETIF_F_TSO		(1 << 16)
+#define NETIF_F_UFO		(1 << 17)
+#define NETIF_F_TSO_ECN		(1 << 19)
+#define NETIF_F_TSO6		(1 << 20)
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
index 34fe107..419f349 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -297,15 +297,8 @@ static void show_usage(void)
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
+static u32 off_features_wanted = 0;
+static u32 off_features_mask = 0;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -446,23 +439,30 @@ static struct cmdline_info cmdline_seeprom[] = {
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
+	{ "rx", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_RXCSUM, &off_features_mask },
+	{ "tx", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_ALL_CSUM, &off_features_mask },
+	{ "sg", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_SG, &off_features_mask },
+	{ "tso", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_ALL_TSO, &off_features_mask },
+	{ "ufo", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_UFO, &off_features_mask },
+	{ "gso", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_GSO, &off_features_mask },
+	{ "lro", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_LRO, &off_features_mask },
+	{ "gro", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_GRO, &off_features_mask },
+	{ "rxvlan", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features_mask },
+	{ "txvlan", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features_mask },
+	{ "ntuple", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_NTUPLE, &off_features_mask },
+	{ "rxhash", CMDL_FLAG, &off_features_wanted, NULL,
+	  NETIF_F_RXHASH, &off_features_mask },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1788,35 +1788,36 @@ static int dump_coalesce(void)
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
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		value = off_feature_def[i].value;
+		printf("%s: %s\n",
+		       off_feature_def[i].long_name,
+		       (active & value) ? "on" : "off");
+	}
 
 	return 0;
 }
@@ -2139,73 +2140,38 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
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
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
-	    ntuple = 0, rxhash = 0;
+	int err, allfail = 1;
+	u32 features = 0, value;
+	int i;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
-	eval.cmd = ETHTOOL_GRXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device rx csum settings");
-	else {
-		rx = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GTXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device tx csum settings");
-	else {
-		tx = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GSG;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device scatter-gather settings");
-	else {
-		sg = eval.data;
-		allfail = 0;
-	}
-
-	eval.cmd = ETHTOOL_GTSO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
-	if (err)
-		perror("Cannot get device tcp segmentation offload settings");
-	else {
-		tso = eval.data;
-		allfail = 0;
-	}
-
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
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		value = off_feature_def[i].value;
+		if (!off_feature_def[i].cmd)
+			continue;
+		eval.cmd = off_feature_def[i].cmd;
+		ifr->ifr_data = (caddr_t)&eval;
+		err = send_ioctl(fd, ifr);
+		if (err) {
+			fprintf(stderr,
+				"Cannot get device %s settings: %m\n",
+				off_feature_def[i].long_name);
+		} else {
+			if (eval.data)
+				features |= value;
+			allfail = 0;
+		}
 	}
 
 	eval.cmd = ETHTOOL_GFLAGS;
@@ -2214,21 +2180,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
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
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err)
-		perror("Cannot get device GRO settings");
-	else {
-		gro = eval.data;
+		features |= eval.data & flags_dup_features;
 		allfail = 0;
 	}
 
@@ -2237,86 +2189,33 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
-			    ntuple, rxhash);
+	return dump_offload(features);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
-	int err, changed = 0;
-
-	if (off_csum_rx_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SRXCSUM;
-		eval.data = (off_csum_rx_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
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
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
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
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
-		if (err) {
-			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
-	}
+	int err;
+	int i;
 
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
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		if (!off_feature_def[i].cmd)
+			continue;
+		if (off_features_mask & off_feature_def[i].value) {
+			eval.cmd = off_feature_def[i].cmd + 1;
+			eval.data = !!(off_features_wanted &
+				       off_feature_def[i].value);
+			ifr->ifr_data = (caddr_t)&eval;
+			err = send_ioctl(fd, ifr);
+			if (err) {
+				fprintf(stderr,
+					"Cannot set device %s settings: %m\n",
+					off_feature_def[i].long_name);
+				return 1;
+			}
 		}
 	}
-	if (off_flags_mask) {
-		changed = 1;
+	if (off_features_mask & flags_dup_features) {
 		eval.cmd = ETHTOOL_GFLAGS;
 		eval.data = 0;
 		ifr->ifr_data = (caddr_t)&eval;
@@ -2327,8 +2226,9 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		}
 
 		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
+		eval.data &= ~(off_features_mask & flags_dup_features);
+		eval.data |= (off_features_wanted &
+			      flags_dup_features);
 
 		err = ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
@@ -2336,19 +2236,8 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 92;
 		}
 	}
-	if (off_gro_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_SGRO;
-		eval.data = (off_gro_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device GRO settings");
-			return 93;
-		}
-	}
 
-	if (!changed) {
+	if (off_features_mask == 0) {
 		fprintf(stdout, "no offload settings changed\n");
 	}
 
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

