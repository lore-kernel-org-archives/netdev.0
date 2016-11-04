From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 2/2] Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Fri, 4 Nov 2016 11:36:45 +0100
Message-ID: <1478255805-25823-3-git-send-email-allan.nielsen@microsemi.com>
References: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0078.outbound.protection.outlook.com ([104.47.40.78]:5690
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761240AbcKDKhO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:37:14 -0400
In-Reply-To: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Add ethtool get and set tunable to access PHY drivers.

Ethtool Help: ethtool -h for PHY tunables
    ethtool --set-phy-tunable DEVNAME      Set PHY tunable
                [ downshift on|off|%d ]
    ethtool --get-phy-tunable DEVNAME      Get PHY tunable
                [ downshift ]

Ethtool ex:
  ethtool --set-phy-tuanble eth0 downshift on
  ethtool --set-phy-tuanble eth0 downshift off
  ethtool --set-phy-tuanble eth0 downshift 2

  ethtool --get-phy-tunable eth0 downshift

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 ethtool.8.in | 27 ++++++++++++++++++
 ethtool.c    | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 9631847..e1fd51f 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -340,6 +340,14 @@ ethtool \- query or control network driver and hardware settings
 .B2 tx-lpi on off
 .BN tx-timer
 .BN advertise
+.HP
+.B ethtool \-\-set\-phy\-tunable
+.I devname
+.B3 downshift on off N
+.HP
+.B ethtool \-\-get\-phy\-tunable
+.I devname
+.RB [ downshift ]
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -947,6 +955,25 @@ Values are as for
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
+.TP
+.BI downshift \ N
+Sets the PHY downshift count.
+.RE
+.TP
+.B \-\-get\-phy\-tunable
+Gets the PHY tunable parameters.
+.RS 4
+.TP
+.B downshift
+Gets the PHY downshift count/status.
+.RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 49ac94e..c9a0a1d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4520,6 +4520,94 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_get_phy_tunable(struct cmd_context *ctx)
+{
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
+	int err, i;
+	u8 downshift_changed;
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
+static int do_set_phy_tunable(struct cmd_context *ctx)
+{
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
+	int err, i;
+	u8 downshift_changed, downshift_wanted = 0;
+
+	for (i = 0; i < argc; i++) {
+		if (!strcmp(argp[i], "downshift")) {
+			downshift_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "on"))
+				downshift_wanted = DOWNSHIFT_DEV_DEFAULT_COUNT;
+			else if (!strcmp(argp[i], "off"))
+				downshift_wanted = DOWNSHIFT_DEV_DISABLE;
+			else
+				downshift_wanted =
+					get_uint_range(argp[i], 0, 0xff);
+		} else  {
+			exit_bad_args();
+		}
+	}
+
+	if (downshift_changed) {
+		struct ethtool_tunable ds;
+		u8 count;
+
+		ds.cmd = ETHTOOL_PHY_STUNABLE;
+		ds.id = ETHTOOL_PHY_DOWNSHIFT;
+		ds.type_id = ETHTOOL_TUNABLE_U8;
+		ds.len = 1;
+		ds.data[0] = &count;
+		*((u8 *)&ds.data[0]) = downshift_wanted;
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
@@ -4681,6 +4769,10 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--set-phy-tunable", 1, do_set_phy_tunable, "Set PHY tunable",
+	  "		[ downshift on|off|%d ]\n"},
+	{ "--get-phy-tunable", 1, do_get_phy_tunable, "Get PHY tunable",
+	  "		[ downshift ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
2.7.3
