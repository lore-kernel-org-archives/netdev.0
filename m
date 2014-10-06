From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool v2 2/3] ethtool: Add copybreak support
Date: Tue,  7 Oct 2014 04:42:20 +0530
Message-ID: <1412637141-3205-3-git-send-email-_govind@gmx.com>
References: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:62541 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbaJFXNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 19:13:17 -0400
In-Reply-To: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting/getting driver's rx_copybreak value.
copybreak is set/get using new ethtool tunable interface.

This was added to net-next in
commit: f0db9b073415848709dd59a6394969882f517da9

	ethtool: Add generic options for tunables

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool.c | 177 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 177 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index bf583f3..4045356 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -179,6 +179,12 @@ static const struct flag_info flags_msglvl[] = {
 	{ "wol",	NETIF_MSG_WOL },
 };
 
+static const char *tunable_name[] = {
+	[ETHTOOL_ID_UNSPEC]	= "Unspec",
+	[ETHTOOL_RX_COPYBREAK]	= "rx",
+	[ETHTOOL_TX_COPYBREAK]	= "tx",
+};
+
 struct off_flag_def {
 	const char *short_name;
 	const char *long_name;
@@ -1805,6 +1811,173 @@ static int do_gring(struct cmd_context *ctx)
 	return 0;
 }
 
+static int get_u32tunable(struct cmd_context *ctx, enum tunable_id id,
+			  __u32 *value)
+{
+	struct ethtool_tunable *etuna;
+	int ret;
+
+	etuna = calloc(sizeof(*etuna) + sizeof(__u32), 1);
+	if (!etuna)
+		return 1;
+	etuna->cmd = ETHTOOL_GTUNABLE;
+	etuna->id = id;
+	etuna->type_id = ETHTOOL_TUNABLE_U32;
+	etuna->len = sizeof(__u32);
+	ret = send_ioctl(ctx, etuna);
+	*value = *(__u32 *)((void *)etuna + sizeof(*etuna));
+	free(etuna);
+
+	return ret;
+}
+
+static int print_u32tunable(int err, enum tunable_id id, const __u32 value)
+{
+	if (err) {
+		switch (errno) {
+		/* Driver does not support this particular tunable
+		 * Usually displays 0
+		 */
+		case EINVAL:
+			goto print;
+		/* Driver does not support get tunables ops or no such device
+		 * No point in proceeding further
+		 */
+		case EOPNOTSUPP:
+		case ENODEV:
+			perror("Cannot get device settings");
+			exit(err);
+		default:
+			perror(tunable_name[id]);
+			return err;
+		}
+	}
+print:
+	fprintf(stdout, "%s: %u\n", tunable_name[id], value);
+
+	return 0;
+}
+
+static int do_gcopybreak(struct cmd_context *ctx)
+{
+	int err, anyerror = 0;
+	__u32 u32value;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	fprintf(stdout, "Copybreak settings for device %s\n", ctx->devname);
+
+	err = get_u32tunable(ctx, ETHTOOL_RX_COPYBREAK, &u32value);
+	err = print_u32tunable(err, ETHTOOL_RX_COPYBREAK, u32value);
+	if (err)
+		anyerror = err;
+
+	err = get_u32tunable(ctx, ETHTOOL_TX_COPYBREAK, &u32value);
+	err = print_u32tunable(err, ETHTOOL_TX_COPYBREAK, u32value);
+	if (err)
+		anyerror = err;
+
+	if (anyerror)
+		fprintf(stderr, "Failed to get all settings. displayed partial settings\n");
+
+	return anyerror;
+}
+
+static int set_u32tunable(struct cmd_context *ctx, enum tunable_id id,
+			  const __u32 value)
+{
+	struct ethtool_tunable *etuna;
+	int ret;
+	__u32 *data;
+
+	etuna = malloc(sizeof(*etuna) + sizeof(__u32));
+	if (!etuna) {
+		perror(tunable_name[id]);
+		return 1;
+	}
+	data = (void *)etuna + sizeof(*etuna);
+	*data = value;
+	etuna->cmd = ETHTOOL_STUNABLE;
+	etuna->id = id;
+	etuna->type_id = ETHTOOL_TUNABLE_U32;
+	etuna->len = sizeof(__u32);
+	ret = send_ioctl(ctx, etuna);
+	free(etuna);
+
+	return ret;
+}
+
+static int check_set_u32tunable(int err, enum tunable_id id)
+{
+	if (err) {
+		switch (errno) {
+		/* Driver does not support get tunables ops or no such device
+		 * No point in proceeding further
+		 */
+		case EOPNOTSUPP:
+		case ENODEV:
+			perror("Cannot set device settings");
+			exit(err);
+		default:
+			perror(tunable_name[id]);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static int do_scopybreak(struct cmd_context *ctx)
+{
+	int err, anyerr = 0;
+	int copybreak_changed = 0;
+	__u32 rx, tx;
+	s32 rx_seen = 0;
+	s32 tx_seen = 0;
+
+	struct cmdline_info cmdline_channels[] = {
+		{ .name = "rx",
+		  .type = CMDL_U32,
+		  .wanted_val = &rx,
+		  .seen_val = &rx_seen, },
+
+		{ .name = "tx",
+		  .type = CMDL_U32,
+		  .wanted_val = &tx,
+		  .seen_val = &tx_seen, },
+	};
+
+	parse_generic_cmdline(ctx, &copybreak_changed, cmdline_channels,
+			      ARRAY_SIZE(cmdline_channels));
+
+	if (!copybreak_changed) {
+		fprintf(stderr, "no copybreak parameters changed\n");
+		return 0;
+	}
+
+	if (rx_seen) {
+		err = set_u32tunable(ctx, ETHTOOL_RX_COPYBREAK, rx);
+		err = check_set_u32tunable(err, ETHTOOL_RX_COPYBREAK);
+		if (err)
+			anyerr = err;
+	}
+
+	if (tx_seen) {
+		err = set_u32tunable(ctx, ETHTOOL_TX_COPYBREAK, tx);
+		err = check_set_u32tunable(err, ETHTOOL_TX_COPYBREAK);
+		if (err)
+			anyerr = err;
+	}
+
+	if (anyerr) {
+		fprintf(stderr, "Failed to set all requested parameters\n");
+		return anyerr;
+	}
+
+	return 0;
+}
+
 static int do_schannels(struct cmd_context *ctx)
 {
 	struct ethtool_channels echannels;
@@ -4055,6 +4228,10 @@ static const struct option {
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
+	{ "-b|--show-copybreak", 1, do_gcopybreak, "Show copybreak values" },
+	{ "-B|--set-copybreak", 1, do_scopybreak, "Set copybreak values",
+	  "		[ rx N]\n"
+	  "		[ tx N]\n" },
 	{ "-k|--show-features|--show-offload", 1, do_gfeatures,
 	  "Get state of protocol offload and other features" },
 	{ "-K|--features|--offload", 1, do_sfeatures,
-- 
2.1.0
