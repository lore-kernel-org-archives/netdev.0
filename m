From: kan.liang@intel.com
Subject: [RFC 1/1] ethtool: support per queue coalesce options
Date: Tue,  8 Dec 2015 04:44:21 +0000
Message-ID: <1449549861-12513-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53422 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932402AbbLHQ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 11:26:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Intruduce new coalesce option "queue" to get/set coalesce value to
specific queue. If the queue is set to -1, the value will be applied to
all queues.

Example,

 [ethtool]$ sudo ./ethtool -C eth5 queue 4 rx-usecs 10 tx-usecs 20

 [ethtool]$ sudo ./ethtool -C eth5 queue 8 rx-usecs 60 tx-usecs 120

 [ethtool]$ sudo ./ethtool -c eth5 queue 4
 Coalesce parameters for eth5:
 Queue: 4
 Adaptive RX: on  TX: on
 stats-block-usecs: 0
 sample-interval: 0
 pkt-rate-low: 0
 pkt-rate-high: 0

 rx-usecs: 10
 rx-frames: 0
 rx-usecs-irq: 0
 rx-frames-irq: 256

 tx-usecs: 20
 tx-frames: 0
 tx-usecs-irq: 0
 tx-frames-irq: 256

 rx-usecs-low: 0
 rx-frame-low: 0
 tx-usecs-low: 0
 tx-frame-low: 0

 rx-usecs-high: 0
 rx-frame-high: 0
 tx-usecs-high: 0
 tx-frame-high: 0

 [ethtool]$ sudo ./ethtool -c eth5 queue 8
 Coalesce parameters for eth5:
 Queue: 8
 Adaptive RX: on  TX: on
 stats-block-usecs: 0
 sample-interval: 0
 pkt-rate-low: 0
 pkt-rate-high: 0

 rx-usecs: 60
 rx-frames: 0
 rx-usecs-irq: 0
 rx-frames-irq: 256

 tx-usecs: 120
 tx-frames: 0
 tx-usecs-irq: 0
 tx-frames-irq: 256

 rx-usecs-low: 0
 rx-frame-low: 0
 tx-usecs-low: 0
 tx-frame-low: 0

 rx-usecs-high: 0
 rx-frame-high: 0
 tx-usecs-high: 0
 tx-frame-high: 0

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 ethtool-copy.h |  2 ++
 ethtool.c      | 31 +++++++++++++++++++++++++++----
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..ad4060d 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -379,6 +379,7 @@ struct ethtool_modinfo {
  *	a TX interrupt, when the packet rate is above @pkt_rate_high.
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
+ * @queue: The specific queue which coalescing parameters apply to.
  *
  * Each pair of (usecs, max_frames) fields specifies that interrupts
  * should be coalesced until
@@ -429,6 +430,7 @@ struct ethtool_coalesce {
 	__u32	tx_coalesce_usecs_high;
 	__u32	tx_max_coalesced_frames_high;
 	__u32	rate_sample_interval;
+	__s32	queue;
 };
 
 /**
diff --git a/ethtool.c b/ethtool.c
index 92c40b8..7c644db 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1178,6 +1178,12 @@ static int dump_channels(const struct ethtool_channels *echannels)
 
 static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 {
+	if (ecoal->queue < 0)
+		fprintf(stdout, "Queue: All\n");
+	else
+		fprintf(stdout, "Queue: %d\n",
+			ecoal->queue);
+
 	fprintf(stdout, "Adaptive RX: %s  TX: %s\n",
 		ecoal->use_adaptive_rx_coalesce ? "on" : "off",
 		ecoal->use_adaptive_tx_coalesce ? "on" : "off");
@@ -1669,7 +1675,7 @@ static void do_generic_set1(struct cmdline_info *info, int *changed_out)
 	v1 = info->wanted_val;
 	wanted = *v1;
 
-	if (wanted < 0)
+	if ((wanted < 0) || !strcmp("queue", info->name))
 		return;
 
 	v2 = info->ioctl_val;
@@ -1879,14 +1885,24 @@ static int do_gchannels(struct cmd_context *ctx)
 static int do_gcoalesce(struct cmd_context *ctx)
 {
 	struct ethtool_coalesce ecoal;
+	char **argp = ctx->argp;
 	int err;
 
-	if (ctx->argc != 0)
+	if ((ctx->argc == 1) || (ctx->argc > 2))
+		exit_bad_args();
+
+	if ((ctx->argc == 2) && strcmp("queue", argp[0]))
 		exit_bad_args();
 
 	fprintf(stdout, "Coalesce parameters for %s:\n", ctx->devname);
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
+	if (ctx->argc == 0)
+		ecoal.queue = -1;
+	else
+		ecoal.queue = get_int_range(argp[1], 0,
+					    -0x80000000LL,
+					    0x7fffffff);
 	err = send_ioctl(ctx, &ecoal);
 	if (err == 0) {
 		err = dump_coalesce(&ecoal);
@@ -1926,6 +1942,7 @@ static int do_scoalesce(struct cmd_context *ctx)
 	s32 coal_rx_frames_high_wanted = -1;
 	s32 coal_tx_usec_high_wanted = -1;
 	s32 coal_tx_frames_high_wanted = -1;
+	s32 coal_queue = -1;
 	struct cmdline_info cmdline_coalesce[] = {
 		{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
 		  &ecoal.use_adaptive_rx_coalesce },
@@ -1971,6 +1988,8 @@ static int do_scoalesce(struct cmd_context *ctx)
 		  &ecoal.tx_coalesce_usecs_high },
 		{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
 		  &ecoal.tx_max_coalesced_frames_high },
+		{ "queue", CMDL_S32, &coal_queue,
+		  &ecoal.queue },
 	};
 	int err, changed = 0;
 
@@ -1978,6 +1997,8 @@ static int do_scoalesce(struct cmd_context *ctx)
 			      cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce));
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
+	if (coal_queue > 0)
+		ecoal.queue = coal_queue;
 	err = send_ioctl(ctx, &ecoal);
 	if (err) {
 		perror("Cannot get device coalesce settings");
@@ -4022,7 +4043,8 @@ static const struct option {
 	  "		[ autoneg on|off ]\n"
 	  "		[ rx on|off ]\n"
 	  "		[ tx on|off ]\n" },
-	{ "-c|--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
+	{ "-c|--show-coalesce", 1, do_gcoalesce, "Show coalesce options",
+	  "		[queue N]\n" },
 	{ "-C|--coalesce", 1, do_scoalesce, "Set coalesce options",
 	  "		[adaptive-rx on|off]\n"
 	  "		[adaptive-tx on|off]\n"
@@ -4045,7 +4067,8 @@ static const struct option {
 	  "		[rx-frames-high N]\n"
 	  "		[tx-usecs-high N]\n"
 	  "		[tx-frames-high N]\n"
-	  "		[sample-interval N]\n" },
+	  "		[sample-interval N]\n"
+	  "		[queue N]\n" },
 	{ "-g|--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
 	{ "-G|--set-ring", 1, do_sring, "Set RX/TX ring parameters",
 	  "		[ rx N ]\n"
-- 
1.7.11.7
