From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/2] ethtool: Add --phy_pkt_gen command
Date: Wed, 17 Feb 2016 21:37:16 +0100
Message-ID: <1455741436-25728-3-git-send-email-andrew@lunn.ch>
References: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50623 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965578AbcBQUha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:37:30 -0500
In-Reply-To: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command is used to cause the PHY to generate packets. The count
of packets must always be given. Optionally, the length of the packet,
if the packet should contain random or fixed data, if errored packets should
be sent and the inter packet gap can be configured. However not all PHYs
are expected to support all options.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 ethtool.8.in | 30 ++++++++++++++++++++++++++++++
 ethtool.c    | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 2316556..ec5ca80 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -339,6 +339,14 @@ ethtool \- query or control network driver and hardware settings
 .B2 tx-lpi on off
 .BN tx-timer
 .BN advertise
+.HP
+.B ethtool \-\-phy\-pkt\-gen
+.I devname
+.I count
+.B2 random on off
+.BN len
+.B2 error off on
+.BN ipg
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -885,6 +893,28 @@ Values are as for
 .BI tx-timer \ N
 Sets the amount of time the device should stay in idle mode prior to asserting
 its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
+.TP
+.B \-\-phy\-pkt\-get\-eee
+Cause the PHY to generate packets using its in built packet
+generator. PHYs may not support all options and may differ on
+supported packet size, packet contents, etc.
+.TP
+.I count
+Number of packets to send. Typically this can be between 1 and 255.
+.TP
+.A2 random on off
+Send packets with random contents, or fixed. Fixed content packets
+often contain 0x5a,0xa5,0x5a,0xa5,... but may have different contents.
+.TP
+.BI len \ N
+Length of the packet to send, typically 64 or 1518 bytes, but other
+lengths may be supported.
+.TP
+.A2 error off on
+Generate packets with errors.
+.TP
+.BI ipg \ N
+Set the inter packet gap length, in bytes.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 480c14c..448395f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4046,6 +4046,44 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_phy_pkt_gen(struct cmd_context *ctx)
+{
+	struct ethtool_phy_pkt_gen cmd;
+	int random, error, changed;
+	struct cmdline_info cmdline_phy_pkt_gen[] = {
+		{ "random",	CMDL_BOOL,	&random,	NULL },
+		{ "len",	CMDL_U32,	&cmd.len,	NULL },
+		{ "error",	CMDL_BOOL,	&error,		NULL },
+		{ "ipg",	CMDL_U32,	&cmd.ipg,	NULL },
+	};
+
+	if (ctx->argc < 1)
+		exit_bad_args();
+
+	memset(&cmd, 0, sizeof(cmd));
+
+	cmd.count = get_uint_range(ctx->argp[0], 0, 0xffffffff);
+	ctx->argc--;
+	ctx->argp++;
+
+	parse_generic_cmdline(ctx, &changed, cmdline_phy_pkt_gen,
+			      ARRAY_SIZE(cmdline_phy_pkt_gen));
+
+	cmd.cmd = ETHTOOL_PHY_PKT_GEN;
+	cmd.flags = 0;
+	if (error)
+		cmd.flags |= ETH_PKT_ERROR;
+	if (random)
+		cmd.flags |= ETH_PKT_RANDOM;
+
+	if (send_ioctl(ctx, &cmd)) {
+		perror("Cannot perform PHY packet generation");
+		return 1;
+	}
+
+	return 0;
+}
+
 #ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
@@ -4205,6 +4243,12 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--phy-pkt-gen", 1, do_phy_pkt_gen, "PHY packet generation",
+	  "		count\n"
+	  "		[ random on|off ]\n"
+	  "		[ len N ]\n"
+	  "		[ error off|on ]\n"
+	  "		[ ipg N ]\n" },
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
2.1.4
