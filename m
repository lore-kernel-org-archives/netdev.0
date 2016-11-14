From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v2 2/2] Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Mon, 14 Nov 2016 10:29:47 +0100
Message-ID: <1479115787-1265-3-git-send-email-allan.nielsen@microsemi.com>
References: <1479115787-1265-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0057.outbound.protection.outlook.com ([104.47.32.57]:42640
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932784AbcKNJa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 04:30:29 -0500
In-Reply-To: <1479115787-1265-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Add ethtool get and set tunable to access PHY drivers.

Ethtool Help: ethtool -h for PHY tunables
    ethtool --set-phy-tunable DEVNAME      Set PHY tunable
                [ downshift on|off [count N] ]
    ethtool --get-phy-tunable DEVNAME      Get PHY tunable
                [ downshift ]

Ethtool ex:
  ethtool --set-phy-tuanble eth0 downshift on
  ethtool --set-phy-tuanble eth0 downshift off
  ethtool --set-phy-tuanble eth0 downshift on count 2

  ethtool --get-phy-tunable eth0 downshift

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 ethtool.8.in |  39 ++++++++++++++++
 ethtool.c    | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 183 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 9631847..2242e90 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -340,6 +340,18 @@ ethtool \- query or control network driver and hardware settings
 .B2 tx-lpi on off
 .BN tx-timer
 .BN advertise
+.HP
+.B ethtool \-\-set\-phy\-tunable
+.I devname
+.RB [
+.B downshift
+.A1 on off
+.BN count
+.RB ]
+.HP
+.B ethtool \-\-get\-phy\-tunable
+.I devname
+.RB [ downshift ]
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -947,6 +959,33 @@ Values are as for
 Sets the amount of time the device should stay in idle mode prior to asserting
 its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
 .RE
+.TP
+.B \-\-set\-phy\-tunable
+Sets the PHY tunable parameters.
+.RS 4
+.TP
+.A2 downshift on off
+Specifies whether downshift should be enabled
+.TS
+nokeep;
+lB	l.
+.BI count \ N
+Sets the PHY downshift re-tries count.
+.TE
+.PD
+.RE
+.TP
+.B \-\-get\-phy\-tunable
+Gets the PHY tunable parameters.
+.RS 4
+.TP
+.B downshift
+For operation in cabling environments that are incompatible with 1000BAST-T,
+PHY device provides an automatic link speed downshift operation.
+Link speed downshift after N failed 1000BASE-T auto-negotiation attempts.
+
+Gets the PHY downshift count/status.
+.RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 49ac94e..3b7ea4e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4520,6 +4520,146 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_get_phy_tunable(struct cmd_context *ctx)
+{
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
+	int err, i;
+	u8 downshift_changed = 0;
+
+	if (argc < 1)
+		exit_bad_args();
+	for (i = 0; i < argc; i++) {
+		if (!strcmp(argp[i], "downshift")) {
+			downshift_changed = 1;
+			i += 1;
+		} else  {
+			exit_bad_args();
+		}
+	}
+
+	if (downshift_changed) {
+		struct ethtool_tunable ds;
+		u8 count = 0;
+
+		ds.cmd = ETHTOOL_PHY_GTUNABLE;
+		ds.id = ETHTOOL_PHY_DOWNSHIFT;
+		ds.type_id = ETHTOOL_TUNABLE_U8;
+		ds.len = 1;
+		ds.data[0] = &count;
+		err = send_ioctl(ctx, &ds);
+		if (err < 0) {
+			perror("Cannot Get PHY downshift count");
+			err = 87;
+		}
+		count = *((u8 *)&ds.data[0]);
+		if (count)
+			fprintf(stdout, "  Downshift count: %d\n",
+				count);
+		else
+			fprintf(stdout, " Downshift disabled\n");
+	}
+
+	return err;
+}
+
+static int parse_named_bool(struct cmd_context *ctx, const char *name, u8 *on)
+{
+	if (ctx->argc < 2)
+		return 0;
+
+	if (strcmp(*ctx->argp, name))
+		return 0;
+
+	if (!strcmp(*(ctx->argp + 1), "on")) {
+		*on = 1;
+	} else if (!strcmp(*(ctx->argp + 1), "off")) {
+		*on = 0;
+	} else {
+		fprintf(stderr, "Invalid boolean\n");
+		exit_bad_args();
+	}
+
+	ctx->argc -= 2;
+	ctx->argp += 2;
+
+	return 1;
+}
+
+static int parse_named_u8(struct cmd_context *ctx, const char *name, u8 *val)
+{
+	if (ctx->argc < 2)
+		return 0;
+
+	if (strcmp(*ctx->argp, name))
+		return 0;
+
+	*val = get_uint_range(*(ctx->argp + 1), 0, 0xff);
+
+	ctx->argc -= 2;
+	ctx->argp += 2;
+
+	return 1;
+}
+
+static int do_set_phy_tunable(struct cmd_context *ctx)
+{
+	int err = 0;
+	u8 ds_cnt = DOWNSHIFT_DEV_DEFAULT_COUNT;
+	u8 ds_changed = 0, ds_has_cnt = 0, ds_enable = 0;
+
+	if (ctx->argc == 0)
+		exit_bad_args();
+
+	/* Parse arguments */
+	while (ctx->argc) {
+		if (parse_named_bool(ctx, "downshift", &ds_enable)) {
+			ds_changed = 1;
+			ds_has_cnt = parse_named_u8(ctx, "count", &ds_cnt);
+		} else {
+			exit_bad_args();
+		}
+	}
+
+	/* Validate parameters */
+	if (ds_changed) {
+		if (!ds_enable && ds_has_cnt) {
+			fprintf(stderr, "'count' may not be set when downshift "
+				        "is off.\n");
+			exit_bad_args();
+		}
+
+		if (ds_enable && ds_has_cnt && ds_cnt == 0) {
+			fprintf(stderr, "'count' may not be zero.\n");
+			exit_bad_args();
+		}
+
+		if (!ds_enable) {
+		    ds_cnt = DOWNSHIFT_DEV_DISABLE;
+		}
+	}
+
+	/* Do it */
+	if (ds_changed) {
+		struct ethtool_tunable ds;
+		u8 count;
+
+		ds.cmd = ETHTOOL_PHY_STUNABLE;
+		ds.id = ETHTOOL_PHY_DOWNSHIFT;
+		ds.type_id = ETHTOOL_TUNABLE_U8;
+		ds.len = 1;
+		ds.data[0] = &count;
+		*((u8 *)&ds.data[0]) = ds_cnt;
+		err = send_ioctl(ctx, &ds);
+		if (err < 0) {
+			perror("Cannot Set PHY downshift count");
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
@@ -4681,6 +4821,10 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--set-phy-tunable", 1, do_set_phy_tunable, "Set PHY tunable",
+	  "		[ downshift on|off [count N] ]\n"},
+	{ "--get-phy-tunable", 1, do_get_phy_tunable, "Get PHY tunable",
+	  "		[ downshift ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
2.7.3
