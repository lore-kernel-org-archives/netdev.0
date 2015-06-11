From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH ethtool V3 1/2] ethtool: Add copybreak support
Date: Thu, 11 Jun 2015 15:15:27 +0300
Message-ID: <1434024928-33177-2-git-send-email-hadarh@mellanox.com>
References: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, _govind@gmx.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49600 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754423AbbFKMQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 08:16:16 -0400
In-Reply-To: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>

Add support for setting/getting driver's tx/rx_copybreak value.

Copybreak is handled through a new ethtool tunable interface.

The kernel support was added in 3.18, commit f0db9b07341 "ethtool:
Add generic options for tunables"

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 ethtool-copy.h |   1 +
 ethtool.c      | 227 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 228 insertions(+)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..f92743b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -545,6 +545,7 @@ enum ethtool_stringset {
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 	ETH_SS_RSS_HASH_FUNCS,
+	ETH_SS_TUNABLES,
 };
 
 /**
diff --git a/ethtool.c b/ethtool.c
index 01b13a6..16b5c41 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -145,6 +145,12 @@ struct cmdline_info {
 	void *seen_val;
 };
 
+struct ethtool_stunable {
+	cmdline_type_t type;
+	__u32 u32_val;
+	int seen_val;
+};
+
 struct flag_info {
 	const char *name;
 	u32 value;
@@ -1800,6 +1806,223 @@ static int do_gring(struct cmd_context *ctx)
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
+static int print_u32tunable(int err, struct ethtool_gstrings *tunables,
+			    enum tunable_id id, const __u32 value)
+{
+	char *tunable_name = (char *)tunables->data + id * ETH_GSTRING_LEN;
+
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
+			perror(tunable_name);
+			return err;
+		}
+	}
+print:
+	fprintf(stdout, "%s: %u\n", tunable_name, value);
+
+	return 0;
+}
+
+static int do_gtunables(struct cmd_context *ctx)
+{
+	int err, anyerror = 0;
+	__u32 u32value = 0;
+	struct ethtool_gstrings *tunables;
+	int idx;
+	__u32 n_tunables;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	tunables = get_stringset(ctx, ETH_SS_TUNABLES, 0, 1);
+	if (!tunables) {
+		perror("Cannot get tunables names");
+		return 1;
+	}
+	if (tunables->len == 0) {
+		fprintf(stderr, "No tunables defined\n");
+		return 1;
+	}
+	n_tunables = tunables->len;
+
+	fprintf(stdout, "Tunables settings for device %s\n", ctx->devname);
+
+	for (idx = 0; idx < n_tunables; idx++) {
+		switch(idx) {
+		case ETHTOOL_ID_UNSPEC:
+			break;
+		case ETHTOOL_RX_COPYBREAK:
+		case ETHTOOL_TX_COPYBREAK:
+			err = get_u32tunable(ctx, idx, &u32value);
+			err = print_u32tunable(err, tunables, idx, u32value);
+			if (err)
+				anyerror = err;
+			break;
+		default:
+			anyerror = EINVAL;
+		}
+	}
+	if (anyerror)
+		fprintf(stderr, "Failed to get all settings. displayed partial settings\n");
+
+	free(tunables);
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
+		perror("Set tunable:");
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
+			perror("Check set tunable");
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static int do_stunables(struct cmd_context *ctx)
+{
+	int err, anyerr = 0;
+	int tunable_changed = 0;
+	struct ethtool_gstrings *tunables;
+	struct cmdline_info *cmd_tunables = NULL;
+	struct ethtool_stunable *set_tunables = NULL;
+	int idx;
+	__u32 n_tunables;
+
+	tunables = get_stringset(ctx, ETH_SS_TUNABLES, 0, 1);
+	if (!tunables) {
+		perror("Cannot get tunables names");
+		return 1;
+	}
+	if (tunables->len == 0) {
+		fprintf(stderr, "No tunables defined\n");
+		return 1;
+	}
+	n_tunables = tunables->len;
+
+	cmd_tunables = calloc(n_tunables, sizeof(*cmd_tunables));
+	set_tunables = calloc(n_tunables, sizeof(*set_tunables));
+	if (!cmd_tunables || !set_tunables) {
+		anyerr = 1;
+		goto err;
+	}
+
+	for (idx = 0; idx < n_tunables; idx++) {
+		cmd_tunables[idx].name =
+			(char *)tunables->data + idx * ETH_GSTRING_LEN;
+		cmd_tunables[idx].seen_val = &set_tunables[idx].seen_val;
+
+		switch(idx) {
+		case ETHTOOL_ID_UNSPEC:
+			break;
+		case ETHTOOL_RX_COPYBREAK:
+		case ETHTOOL_TX_COPYBREAK:
+			cmd_tunables[idx].wanted_val = &set_tunables[idx].u32_val;
+			cmd_tunables[idx].type = CMDL_U32;
+			break;
+		default:
+			anyerr = EINVAL;
+			goto err;
+		}
+	}
+
+	parse_generic_cmdline(ctx, &tunable_changed, cmd_tunables, n_tunables);
+
+	for (idx = 0; idx < n_tunables; idx++) {
+		if (set_tunables[idx].seen_val) {
+			switch(idx) {
+			case ETHTOOL_ID_UNSPEC:
+				break;
+			case ETHTOOL_RX_COPYBREAK:
+			case ETHTOOL_TX_COPYBREAK:
+				err = set_u32tunable(ctx, idx, set_tunables[idx].u32_val);
+				err = check_set_u32tunable(err, idx);
+				if (err)
+					anyerr = err;
+				break;
+			default:
+				anyerr = EINVAL;
+				goto err;
+			}
+		}
+	}
+
+	if (anyerr)
+		fprintf(stderr, "Failed to set requested parameters\n");
+err:
+	free(tunables);
+	free(cmd_tunables);
+	free(set_tunables);
+	return anyerr;
+}
+
 static int do_schannels(struct cmd_context *ctx)
 {
 	struct ethtool_channels echannels;
@@ -4050,6 +4273,10 @@ static const struct option {
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
+	{ "-b|--show-tunable", 1, do_gtunables, "Show tunable values" },
+	{ "-B|--set-tunable", 1, do_stunables, "Set tunable values",
+	  "		[ rx-copybreak N]\n"
+	  "		[ tx-copybreak N]\n" },
 	{ "-k|--show-features|--show-offload", 1, do_gfeatures,
 	  "Get state of protocol offload and other features" },
 	{ "-K|--features|--offload", 1, do_sfeatures,
-- 
1.8.3.1
