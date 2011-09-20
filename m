From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH ethtool 3/3] ethtool: add ETHTOOL_{G,S}CHANNEL support.
Date: Tue, 20 Sep 2011 03:31:35 -0700
Message-ID: <1316514695-17157-4-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:20467 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab1ITKml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 06:42:41 -0400
In-Reply-To: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used to configure number of rx and tx rings.
Reqd. man page changes are included.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 ethtool.8.in |   28 ++++++++++++++
 ethtool.c    |  116 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 144 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index efc6098..64e1b70 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -307,6 +307,16 @@ ethtool \- query or control network driver and hardware settings
 .BN action
 .BN loc
 .RB ]
+.HP
+.B ethtool \-l|\-\-show\-channels
+.I ethX
+.HP
+.B ethtool \-L|\-\-set\-channels
+.I ethX
+.BN rx_count
+.BN tx_count
+.BN other_count
+.BN combined_count
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -754,6 +764,24 @@ lB	l.
 Specify the location/ID to insert the rule. This will overwrite
 any rule present in that location and will not go through any
 of the rule ordering process.
+.TP
+.B \-l \-\-show\-channels
+Queries the specified network device for channel parameter information.
+.TP
+.B \-L \-\-set\-channels
+Changes the channel parameters of the specified network device.
+.TP
+.BI rx_count \ N
+Changes the number of rx channels.
+.TP
+.BI tx_count \ N
+Changes the number of tx channels.
+.TP
+.BI other_count \ N
+Changes the number of other channels. Eg: link interrupts, SRIOV co-ordination etc.
+.TP
+.BI combined_count \ N
+Changes set of channel (RX, TX or other).
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index d7d2d58..79c37e4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -80,6 +80,8 @@ static int do_gpause(int fd, struct ifreq *ifr);
 static int do_spause(int fd, struct ifreq *ifr);
 static int do_gring(int fd, struct ifreq *ifr);
 static int do_sring(int fd, struct ifreq *ifr);
+static int do_schannels(int fd, struct ifreq *ifr);
+static int do_gchannels(int fd, struct ifreq *ifr);
 static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
@@ -133,6 +135,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_GCHANNELS,
+	MODE_SCHANNELS
 } mode = MODE_GSET;
 
 static struct option {
@@ -266,6 +270,12 @@ static struct option {
     { "-W", "--set-dump", MODE_SET_DUMP,
 		"Set dump flag of the device",
 		"		N\n"},
+    { "-l", "--show-channels", MODE_GCHANNELS, "Query Channels" },
+    { "-L", "--set-channels", MODE_SCHANNELS, "Set Channels",
+		"               [ rx_count N ]\n"
+		"               [ tx_count N ]\n"
+		"               [ other_count N ]\n"
+		"               [ combined_count N ]\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -331,6 +341,13 @@ static s32 ring_rx_mini_wanted = -1;
 static s32 ring_rx_jumbo_wanted = -1;
 static s32 ring_tx_wanted = -1;
 
+static struct ethtool_channels echannels;
+static int gchannels_changed;
+static s32 channels_rx_wanted = -1;
+static s32 channels_tx_wanted = -1;
+static s32 channels_other_wanted = -1;
+static s32 channels_combined_wanted = -1;
+
 static struct ethtool_coalesce ecoal;
 static int gcoalesce_changed = 0;
 static s32 coal_stats_wanted = -1;
@@ -495,6 +512,13 @@ static struct cmdline_info cmdline_ring[] = {
 	{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
 };
 
+static struct cmdline_info cmdline_channels[] = {
+	{ "rx_count", CMDL_S32, &channels_rx_wanted, &echannels.rx_count },
+	{ "tx_count", CMDL_S32, &channels_tx_wanted, &echannels.tx_count },
+	{ "other_count", CMDL_S32, &channels_other_wanted, &echannels.other_count },
+	{ "combined_count", CMDL_S32, &channels_combined_wanted, &echannels.combined_count },
+};
+
 static struct cmdline_info cmdline_coalesce[] = {
 	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
 	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
@@ -787,6 +811,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GCOALESCE) ||
 			    (mode == MODE_SCOALESCE) ||
 			    (mode == MODE_GRING) ||
+			    (mode == MODE_GCHANNELS) ||
+			    (mode == MODE_SCHANNELS) ||
 			    (mode == MODE_SRING) ||
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
@@ -871,6 +897,14 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SCHANNELS) {
+				parse_generic_cmdline(argc, argp, i,
+					&gchannels_changed,
+					cmdline_channels,
+					ARRAY_SIZE(cmdline_ring));
+				i = argc;
+				break;
+			}
 			if (mode == MODE_SCOALESCE) {
 				parse_generic_cmdline(argc, argp, i,
 					&gcoalesce_changed,
@@ -1751,6 +1785,32 @@ static int dump_ring(void)
 	return 0;
 }
 
+static int dump_channels(void)
+{
+	fprintf(stdout,
+		"Re-set maximums:\n"
+		"Max RX:		%u\n"
+		"Max TX:		%u\n"
+		"Max Other:	%u\n"
+		"Max Combined:	%u\n",
+		echannels.max_rx, echannels.max_tx,
+		echannels.max_other,
+		echannels.max_combined);
+
+	fprintf(stdout,
+		"Current hardware settings:\n"
+		"RX Count:	%u\n"
+		"TX Count:	%u\n"
+		"Other Count:	%u\n"
+		"Combined Count:	%u\n",
+		echannels.rx_count, echannels.tx_count,
+		echannels.other_count,
+		echannels.combined_count);
+
+	fprintf(stdout, "\n");
+	return 0;
+}
+
 static int dump_coalesce(void)
 {
 	fprintf(stdout, "Adaptive RX: %s  TX: %s\n",
@@ -1937,6 +1997,10 @@ static int doit(void)
 		return do_gring(fd, &ifr);
 	} else if (mode == MODE_SRING) {
 		return do_sring(fd, &ifr);
+	} else if (mode == MODE_GCHANNELS) {
+		return do_gchannels(fd, &ifr);
+	} else if (mode == MODE_SCHANNELS) {
+		return do_schannels(fd, &ifr);
 	} else if (mode == MODE_GOFFLOAD) {
 		return do_goffload(fd, &ifr);
 	} else if (mode == MODE_SOFFLOAD) {
@@ -2114,6 +2178,58 @@ static int do_gring(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_schannels(int fd, struct ifreq *ifr)
+{
+	int err, changed = 0;
+
+	echannels.cmd = ETHTOOL_GCHANNELS;
+	ifr->ifr_data = (caddr_t)&echannels;
+	err = send_ioctl(fd, ifr);
+	if (err) {
+		perror("Cannot get device channels settings");
+		return 1;
+	}
+
+	do_generic_set(cmdline_channels, ARRAY_SIZE(cmdline_channels),
+			&changed);
+
+	if (!changed) {
+		fprintf(stderr, "no channels parameters changed, aborting\n");
+		return 1;
+	}
+
+	echannels.cmd = ETHTOOL_SCHANNELS;
+	ifr->ifr_data = (caddr_t)&echannels;
+	err = send_ioctl(fd, ifr);
+	if (err) {
+		perror("Cannot set device channels parameters");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int do_gchannels(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	fprintf(stdout, "Channels parameters for %s:\n", devname);
+
+	echannels.cmd = ETHTOOL_GCHANNELS;
+	ifr->ifr_data = (caddr_t)&echannels;
+	err = send_ioctl(fd, ifr);
+	if (err == 0) {
+		err = dump_channels();
+		if (err)
+			return err;
+	} else {
+		perror("Cannot get device channels\n");
+		return 1;
+	}
+	return 0;
+
+}
+
 static int do_gcoalesce(int fd, struct ifreq *ifr)
 {
 	int err;
-- 
1.6.3.3
