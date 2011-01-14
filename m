From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] ethtool : Add option -L | --set-common to set common flags.
Date: Thu, 13 Jan 2011 16:11:32 -0800
Message-ID: <1294963892-11997-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:15339 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab1ANALv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 19:11:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds -L | --set-common option to add / remove common flags which
includes loopback flag. The -l | --show-common displays the current values
for these common flags.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 ethtool-copy.h |    1 +
 ethtool.8      |   16 ++++++++++
 ethtool.c      |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 105 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..5fd18c7 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -309,6 +309,7 @@ struct ethtool_perm_addr {
  * flag differs from the read-only value.
  */
 enum ethtool_flags {
+	ETH_FLAG_LOOPBACK	= (1 << 2),	/* Loopback enable / disable */
 	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
 	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
diff --git a/ethtool.8 b/ethtool.8
index 1760924..cf7128f 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -174,6 +174,13 @@ ethtool \- Display or change ethernet card settings
 .B2 txvlan on off
 .B2 rxhash on off
 
+.B ethtool \-l|\-\-show\-common
+.I ethX
+
+.B ethtool \-L|\-\-set\-common
+.I ethX
+.B2 loopback on off
+
 .B ethtool \-p|\-\-identify
 .I ethX
 .RI [ N ]
@@ -406,6 +413,15 @@ Specifies whether TX VLAN acceleration should be enabled
 .A2 rxhash on off
 Specifies whether receive hashing offload should be enabled
 .TP
+.B \-l \-\-show\-common
+Queries the specified ethernet device for common flag settings.
+.TP
+.B \-L \-\-set\-common
+Changes the common parameters of the specified ethernet device.
+.TP
+.A2 loopback on off
+Specifies whether loopback should be enabled.
+.TP
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
diff --git a/ethtool.c b/ethtool.c
index 63e0ead..1a0c10c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -97,6 +97,8 @@ static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
+static int do_gcommon(int fd, struct ifreq *ifr);
+static int do_scommon(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
@@ -142,6 +144,8 @@ static enum {
 	MODE_GNTUPLE,
 	MODE_FLASHDEV,
 	MODE_PERMADDR,
+	MODE_GCOMMON,
+	MODE_SCOMMON,
 } mode = MODE_GSET;
 
 static struct option {
@@ -211,6 +215,10 @@ static struct option {
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
     },
+    { "-l", "--show-common", MODE_GCOMMON, "Get common flags information" },
+    { "-L", "--set-common", MODE_SCOMMON, "Set common flags",
+		"               [ loopback on|off ]\n"
+    },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
 		"		[ raw on|off ]\n"
@@ -309,6 +317,10 @@ static u32 off_flags_wanted = 0;
 static u32 off_flags_mask = 0;
 static int off_gro_wanted = -1;
 
+static int gcommon_changed = 0;
+static u32 common_flags_wanted = 0;
+static u32 common_flags_mask = 0;
+
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
 static int pause_autoneg_wanted = -1;
@@ -482,6 +494,11 @@ static struct cmdline_info cmdline_offload[] = {
 	  ETH_FLAG_RXHASH, &off_flags_mask },
 };
 
+static struct cmdline_info cmdline_commonflags[] = {
+	{ "loopback", CMDL_FLAG, &common_flags_wanted, NULL,
+	  ETH_FLAG_LOOPBACK, &common_flags_mask },
+};
+
 static struct cmdline_info cmdline_pause[] = {
 	{ "autoneg", CMDL_BOOL, &pause_autoneg_wanted, &epause.autoneg },
 	{ "rx", CMDL_BOOL, &pause_rx_wanted, &epause.rx_pause },
@@ -829,6 +846,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_SRING) ||
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
+			    (mode == MODE_GCOMMON) ||
+			    (mode == MODE_SCOMMON) ||
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
@@ -919,6 +938,14 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SCOMMON) {
+				parse_generic_cmdline(argc, argp, i,
+					&gcommon_changed,
+			      		cmdline_commonflags,
+			      		ARRAY_SIZE(cmdline_offload));
+				i = argc;
+				break;
+			}
 			if (mode == MODE_SNTUPLE) {
 				if (!strcmp(argp[i], "flow-type")) {
 					i += 1;
@@ -1905,6 +1932,13 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 	return 0;
 }
 
+static int dump_common_flags(int loopback)
+{
+	fprintf(stdout, "loopback: %s\n", loopback ? "on" : "off");
+
+	return 0;
+}
+
 static int dump_rxfhash(int fhash, u64 val)
 {
 	switch (fhash) {
@@ -1998,6 +2032,10 @@ static int doit(void)
 		return do_goffload(fd, &ifr);
 	} else if (mode == MODE_SOFFLOAD) {
 		return do_soffload(fd, &ifr);
+	} else if (mode == MODE_GCOMMON) {
+		return do_gcommon(fd, &ifr);
+	} else if (mode == MODE_SCOMMON) {
+		return do_scommon(fd, &ifr);
 	} else if (mode == MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
 	} else if (mode == MODE_GNFC) {
@@ -2219,6 +2257,53 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_gcommon(int fd, struct ifreq *ifr)
+{
+	struct ethtool_value eval;
+	int loopback = 0;
+
+	fprintf(stdout, "Common flags for %s:\n", devname);
+
+	eval.cmd = ETHTOOL_GFLAGS;
+	ifr->ifr_data = (caddr_t)&eval;
+	if (ioctl(fd, SIOCETHTOOL, ifr)) {
+		perror("Cannot get device flags");
+	} else {
+		loopback = (eval.data & ETH_FLAG_LOOPBACK) != 0;
+	}
+
+	return dump_common_flags(loopback);
+}
+
+static int do_scommon(int fd, struct ifreq *ifr)
+{
+	struct ethtool_value eval;
+
+	if (common_flags_mask) {
+		eval.cmd = ETHTOOL_GFLAGS;
+		eval.data = 0;
+		ifr->ifr_data = (caddr_t)&eval;
+		if (ioctl(fd, SIOCETHTOOL, ifr)) {
+			perror("Cannot get device common flags");
+			return 1;
+		}
+
+		eval.cmd = ETHTOOL_SFLAGS;
+		eval.data =
+		    ((eval.data & ~(common_flags_mask | off_flags_mask)) |
+		     (common_flags_wanted | off_flags_wanted));
+
+		if (ioctl(fd, SIOCETHTOOL, ifr)) {
+			perror("Cannot set device common flags");
+			return 1;
+		}
+	} else {
+		fprintf(stdout, "No common settings changed\n");
+	}
+
+	return 0;
+}
+
 static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
@@ -2407,8 +2492,9 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		}
 
 		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
+		eval.data =
+		    ((eval.data & ~(off_flags_mask | common_flags_mask)) |
+		     (off_flags_wanted | common_flags_wanted));
 
 		err = ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
-- 
1.7.3.1

