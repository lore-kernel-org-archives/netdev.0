From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/2] ethtool: Add PHY statistics support
Date: Wed, 23 Dec 2015 12:58:31 +0100
Message-ID: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
References: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48597 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129AbbLWL6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 06:58:49 -0500
In-Reply-To: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for printing statistics from the network devices PHY.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 ethtool.8.in |  6 ++++++
 ethtool.c    | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index eeffa70..2316556 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -220,6 +220,9 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-S|\-\-statistics
 .I devname
 .HP
+.B ethtool \-I|\-\-phy-statistics
+.I devname
+.HP
 .B ethtool \-t|\-\-test
 .I devname
 .RI [\*(SD]
@@ -492,6 +495,9 @@ auto-negotiation is enabled.
 Queries the specified network device for NIC- and driver-specific
 statistics.
 .TP
+.B \-I \-\-phy\-statistics
+Queries the specified network device for PHY specific statistics.
+.TP
 .B \-t \-\-test
 Executes adapter selftest on the specified network device. Possible test modes are:
 .TP
diff --git a/ethtool.c b/ethtool.c
index 92c40b8..480c14c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2995,6 +2995,64 @@ static int do_gstats(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_gphystats(struct cmd_context *ctx)
+{
+	struct ethtool_gstrings *strings;
+	struct ethtool_stats *stats;
+	unsigned int n_stats, sz_stats, i;
+	int err;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	strings = get_stringset(ctx, ETH_SS_PHY_STATS,
+				offsetof(struct ethtool_drvinfo, n_stats),
+				0);
+	if (!strings) {
+		perror("Cannot get stats strings information");
+		return 96;
+	}
+
+	n_stats = strings->len;
+	if (n_stats < 1) {
+		fprintf(stderr, "no stats available\n");
+		free(strings);
+		return 94;
+	}
+
+	sz_stats = n_stats * sizeof(u64);
+
+	stats = calloc(1, sz_stats + sizeof(struct ethtool_stats));
+	if (!stats) {
+		fprintf(stderr, "no memory available\n");
+		free(strings);
+		return 95;
+	}
+
+	stats->cmd = ETHTOOL_GPHYSTATS;
+	stats->n_stats = n_stats;
+	err = send_ioctl(ctx, stats);
+	if (err < 0) {
+		perror("Cannot get stats information");
+		free(strings);
+		free(stats);
+		return 97;
+	}
+
+	/* todo - pretty-print the strings per-driver */
+	fprintf(stdout, "PHY statistics:\n");
+	for (i = 0; i < n_stats; i++) {
+		fprintf(stdout, "     %.*s: %llu\n",
+			ETH_GSTRING_LEN,
+			&strings->data[i * ETH_GSTRING_LEN],
+			stats->data[i]);
+	}
+	free(strings);
+	free(stats);
+
+	return 0;
+}
+
 static int do_srxntuple(struct cmd_context *ctx,
 			struct ethtool_rx_flow_spec *rx_rule_fs);
 
@@ -4078,6 +4136,8 @@ static const struct option {
 	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
 	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
+	{ "-I|--phy-statistics", 1, do_gphystats,
+	  "Show phy statistics" },
 	{ "-n|-u|--show-nfc|--show-ntuple", 1, do_grxclass,
 	  "Show Rx network flow classification options or rules",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-- 
2.1.4
