From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 2/2] Ethtool: Implements PHY Loopback
Date: Mon, 28 Nov 2016 14:25:12 +0100
Message-ID: <1480339512-5882-3-git-send-email-allan.nielsen@microsemi.com>
References: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linville@tuxdriver.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0088.outbound.protection.outlook.com ([104.47.42.88]:16126
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932464AbcK1NZx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:53 -0500
In-Reply-To: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Add loopback in ethtool tunables to access PHY drivers.

Ethtool Help: ethtool -h for PHY tunables
    ethtool --set-phy-tunable DEVNAME      Set PHY tunable
                [ loopback off|near|far|extn ]
    ethtool --get-phy-tunable DEVNAME      Get PHY tunable
                [ loopback ]

Ethtool ex:
  ethtool --set-phy-tunable eth0 loopback near
  ethtool --set-phy-tunable eth0 loopback far
  ethtool --set-phy-tunable eth0 loopback extn
  ethtool --set-phy-tunable eth0 loopback off

  ethtool --get-phy-tunable eth0 loopback

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 ethtool.8.in |  49 +++++++++++++++++++++
 ethtool.c    | 139 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 188 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 9631847..83e6b97 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -340,6 +340,15 @@ ethtool \- query or control network driver and hardware settings
 .B2 tx-lpi on off
 .BN tx-timer
 .BN advertise
+.HP
+.B ethtool \-\-set\-phy\-tunable
+.I devname
+.B4 loopback off near far extn
+.HP
+.B ethtool \-\-get\-phy\-tunable
+.I devname
+.RB [ loopback ]
+.HP
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -947,6 +956,46 @@ Values are as for
 Sets the amount of time the device should stay in idle mode prior to asserting
 its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
 .RE
+.TP
+.B \-\-set\-phy\-tunable
+Sets the PHY tunable parameters.
+.RS 4
+.TP
+.A4 loopback off near far extn
+Specifies whether the type of loopback should be enabled
+.RE
+.TP
+.B \-\-get\-phy\-tunable
+Gets the PHY tunable parameters.
+.RS 4
+.TP
+.B loopback
+PHY supports 3 types of the Loopbacks. i.e near, far and external.
+
+Near-End Loopback:
+Transmitted data (TXD) is looped back in the PCS block onto the receive data
+signal (RXD). When Near-End loopback enable, no data is transmitted over
+the network. no data receive from the network.
+
+Far-End Loopback:
+This loopback is a special test mode to allow testing the PHY from link
+partner side. In this mode data that is received from the link partner pass
+through the PHY's receiver, looped back on the MII and transmitted back to
+the link partner.
+
+External Loopback:
+An RJ45 loopback cable can be used to route the transmit signals an the
+output of the trnsformer back to the receiver inputs and this loopback will
+work at either 10 or 100 or 1000 Mbps speed.
+RJ45 Loopback cable created by conncting pin 1 to pin 3 and connecting pin
+2 to pin 6.
+
+Gets the PHY Loopback status.
+.TS
+.PD
+.RE
+.TE
+.RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 62f86ef..a4e6c0d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4522,6 +4522,141 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_get_phy_tunable(struct cmd_context *ctx)
+{
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
+	int err = 0, i;
+	u8 lpbk_changed = 0;
+	struct ethtool_tunable tunable;
+
+	if (argc < 1)
+		exit_bad_args();
+	for (i = 0; i < argc; i++) {
+		if (!strcmp(argp[i], "loopback")) {
+			lpbk_changed = 1;
+			i += 1;
+			if (i < argc)
+				exit_bad_args();
+		} else  {
+			exit_bad_args();
+		}
+	}
+
+	if (lpbk_changed) {
+		u8 type;
+
+		tunable.cmd = ETHTOOL_PHY_GTUNABLE;
+		tunable.id = ETHTOOL_PHY_LOOPBACK;
+		tunable.type_id = ETHTOOL_TUNABLE_U8;
+		tunable.len = 1;
+		tunable.data[0] = &type;
+		err = send_ioctl(ctx, &tunable);
+		if (err < 0) {
+			perror("Cannot Get PHY Loopback status");
+			return 87;
+		}
+		type = *((u8 *)&tunable.data[0]);
+		switch (type) {
+		case ETHTOOL_PHY_LOOPBACK_NEAR:
+			fprintf(stdout, "Near-end Loopback enabled\n");
+			break;
+		case ETHTOOL_PHY_LOOPBACK_FAR:
+			fprintf(stdout, "Far-end Loopback enabled\n");
+			break;
+		case ETHTOOL_PHY_LOOPBACK_EXTN:
+			fprintf(stdout, "External Loopback enabled\n");
+			break;
+		case ETHTOOL_PHY_LOOPBACK_DISABLE:
+			fprintf(stdout, "All PHY Loopbacks disabled\n");
+			break;
+		default:
+			fprintf(stdout, "Invalid Loopback type\n");
+			break;
+		}
+	}
+
+	return err;
+}
+
+static int parse_named_flag(struct cmd_context *ctx, const char *name,
+			    const struct flag_info *flags, size_t size,
+			    u8 *type)
+{
+	size_t idx;
+	int found = 0;
+
+	if (ctx->argc < 2)
+		return 0;
+
+	if (strcmp(*ctx->argp, name))
+		return 0;
+	ctx->argc -= 1;
+	ctx->argp += 1;
+
+	for (idx = 0; idx < size; idx++) {
+		if (!strcmp(flags[idx].name, *ctx->argp)) {
+			*type = flags[idx].value;
+			ctx->argc -= 1;
+			ctx->argp += 1;
+			found = 1;
+			break;
+		}
+	}
+
+	if (!found)
+		exit_bad_args();
+
+	return 1;
+}
+
+static const struct flag_info lpbk_flags[] = {
+	{ "off", ETHTOOL_PHY_LOOPBACK_DISABLE },
+	{ "near", ETHTOOL_PHY_LOOPBACK_NEAR },
+	{ "far",  ETHTOOL_PHY_LOOPBACK_FAR },
+	{ "extn",  ETHTOOL_PHY_LOOPBACK_EXTN },
+};
+
+static int do_set_phy_tunable(struct cmd_context *ctx)
+{
+	int err = 0;
+	u8 lpbk_changed = 0, lpbk_type = ETHTOOL_PHY_LOOPBACK_DISABLE;
+	struct ethtool_tunable tunable;
+
+	if (ctx->argc == 0)
+		exit_bad_args();
+
+	/* Parse arguments */
+	while (ctx->argc) {
+		if (parse_named_flag(ctx, "loopback", lpbk_flags,
+					    ARRAY_SIZE(lpbk_flags),
+					    &lpbk_type)) {
+			lpbk_changed = 1;
+		} else {
+			exit_bad_args();
+		}
+	}
+
+	/* Do it */
+	if (lpbk_changed) {
+		u8 type;
+
+		tunable.cmd = ETHTOOL_PHY_STUNABLE;
+		tunable.id = ETHTOOL_PHY_LOOPBACK;
+		tunable.type_id = ETHTOOL_TUNABLE_U8;
+		tunable.len = sizeof(type);
+		tunable.data[0] = &type;
+		*((u8 *)&tunable.data[0]) = lpbk_type;
+		err = send_ioctl(ctx, &tunable);
+		if (err < 0) {
+			perror("Cannot Set PHY Loopback");
+			err = 87;
+		}
+	}
+
+	return err;
+}
+
 #ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
@@ -4683,6 +4818,10 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--set-phy-tunable", 1, do_set_phy_tunable, "Set PHY tunable",
+	  "		[ loopback off|near|far|extn ]\n"},
+	{ "--get-phy-tunable", 1, do_get_phy_tunable, "Get PHY tunable",
+	  "		[ loopback ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
2.7.3
