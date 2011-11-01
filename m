From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 15/21] Convert cmdline_msglvl into array of named
 flags; convert back at run-time
Date: Tue, 1 Nov 2011 23:19:40 +0000
Message-ID: <1320189580.2758.45.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38491 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:19:44 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cmdline_msglvl is used both in do_gset() and do_sset(), but it refers
to variables only used in do_sset().  I want to get rid of the global
variables without duplicating the flag definitions.  So separate out
the flag definitions into a new structure and generate cmdline_msglvl
from that at run-time.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   79 ++++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 44 insertions(+), 35 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 7bdf173..438fc26 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -426,6 +426,11 @@ struct cmdline_info {
 	void *seen_val;
 };
 
+struct flag_info {
+	const char *name;
+	u32 value;
+};
+
 static struct cmdline_info cmdline_gregs[] = {
 	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
 	{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
@@ -511,37 +516,22 @@ static struct cmdline_info cmdline_coalesce[] = {
 	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
-static struct cmdline_info cmdline_msglvl[] = {
-	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_DRV, &msglvl_mask },
-	{ "probe", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PROBE, &msglvl_mask },
-	{ "link", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_LINK, &msglvl_mask },
-	{ "timer", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TIMER, &msglvl_mask },
-	{ "ifdown", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFDOWN, &msglvl_mask },
-	{ "ifup", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFUP, &msglvl_mask },
-	{ "rx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_ERR, &msglvl_mask },
-	{ "tx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_ERR, &msglvl_mask },
-	{ "tx_queued", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_QUEUED, &msglvl_mask },
-	{ "intr", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_INTR, &msglvl_mask },
-	{ "tx_done", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_DONE, &msglvl_mask },
-	{ "rx_status", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_STATUS, &msglvl_mask },
-	{ "pktdata", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PKTDATA, &msglvl_mask },
-	{ "hw", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_HW, &msglvl_mask },
-	{ "wol", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_WOL, &msglvl_mask },
+static const struct flag_info flags_msglvl[] = {
+	{ "drv",	NETIF_MSG_DRV },
+	{ "probe",	NETIF_MSG_PROBE },
+	{ "link",	NETIF_MSG_LINK },
+	{ "timer",	NETIF_MSG_TIMER },
+	{ "ifdown",	NETIF_MSG_IFDOWN },
+	{ "ifup",	NETIF_MSG_IFUP },
+	{ "rx_err",	NETIF_MSG_RX_ERR },
+	{ "tx_err",	NETIF_MSG_TX_ERR },
+	{ "tx_queued",	NETIF_MSG_TX_QUEUED },
+	{ "intr",	NETIF_MSG_INTR },
+	{ "tx_done",	NETIF_MSG_TX_DONE },
+	{ "rx_status",	NETIF_MSG_RX_STATUS },
+	{ "pktdata",	NETIF_MSG_PKTDATA },
+	{ "hw",		NETIF_MSG_HW },
+	{ "wol",	NETIF_MSG_WOL },
 };
 
 static long long
@@ -694,16 +684,28 @@ static void parse_generic_cmdline(struct cmd_context *ctx,
 	}
 }
 
+static void flag_to_cmdline_info(const char *name, u32 value,
+				 u32 *wanted, u32 *mask,
+				 struct cmdline_info *cli)
+{
+	memset(cli, 0, sizeof(*cli));
+	cli->name = name;
+	cli->type = CMDL_FLAG;
+	cli->flag_val = value;
+	cli->wanted_val = wanted;
+	cli->seen_val = mask;
+}
+
 static void
-print_flags(const struct cmdline_info *info, unsigned int n_info, u32 value)
+print_flags(const struct flag_info *info, unsigned int n_info, u32 value)
 {
 	const char *sep = "";
 
 	while (n_info) {
-		if (info->type == CMDL_FLAG && value & info->flag_val) {
+		if (value & info->value) {
 			printf("%s%s", sep, info->name);
 			sep = " ";
-			value &= ~info->flag_val;
+			value &= ~info->value;
 		}
 		++info;
 		--n_info;
@@ -2037,7 +2039,7 @@ static int do_gset(struct cmd_context *ctx)
 		fprintf(stdout, "	Current message level: 0x%08x (%d)\n"
 			"			       ",
 			edata.data, edata.data);
-		print_flags(cmdline_msglvl, ARRAY_SIZE(cmdline_msglvl),
+		print_flags(flags_msglvl, ARRAY_SIZE(flags_msglvl),
 			    edata.data);
 		fprintf(stdout, "\n");
 		allfail = 0;
@@ -2064,11 +2066,18 @@ static int do_gset(struct cmd_context *ctx)
 
 static int do_sset(struct cmd_context *ctx)
 {
+	struct cmdline_info cmdline_msglvl[ARRAY_SIZE(flags_msglvl)];
 	int argc = ctx->argc;
 	char **argp = ctx->argp;
 	int i;
 	int err;
 
+	for (i = 0; i < ARRAY_SIZE(flags_msglvl); i++)
+		flag_to_cmdline_info(flags_msglvl[i].name,
+				     flags_msglvl[i].value,
+				     &msglvl_wanted, &msglvl_mask,
+				     &cmdline_msglvl[i]);
+
 	for (i = 0; i < argc; i++) {
 		if (!strcmp(argp[i], "speed")) {
 			gset_changed = 1;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
