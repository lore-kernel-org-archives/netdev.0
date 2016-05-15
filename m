From: kan.liang@intel.com
Subject: [PATCH 4/5] ethtool: support per queue sub command --show-coalesce
Date: Sun, 15 May 2016 00:14:35 -0700
Message-ID: <1463296476-32493-4-git-send-email-kan.liang@intel.com>
References: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738AbcEOOkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 10:40:40 -0400
In-Reply-To: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Get all masked queues' coalesce from kernel and dump them one by one.

Example:

 $ sudo ./ethtool --set-perqueue-command eth5 queue_mask 0x11
   --show-coalesce
 Queue: 0
 Adaptive RX: off  TX: off
 stats-block-usecs: 0
 sample-interval: 0
 pkt-rate-low: 0
 pkt-rate-high: 0

 rx-usecs: 222
 rx-frames: 0
 rx-usecs-irq: 0
 rx-frames-irq: 256

 tx-usecs: 222
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

 Queue: 4
 Adaptive RX: off  TX: off
 stats-block-usecs: 0
 sample-interval: 0
 pkt-rate-low: 0
 pkt-rate-high: 0

 rx-usecs: 222
 rx-frames: 0
 rx-usecs-irq: 0
 rx-frames-irq: 256

 tx-usecs: 222
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
 ethtool.8.in |  2 +-
 ethtool.c    | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 26d01cb..210ec8c 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -937,7 +937,7 @@ Sets the specific queues which the sub command is applied to.
 If queue_mask is not set, the sub command will be applied to all queues.
 .TP
 .B sub_command
-Sets the sub command.
+Sets the sub command. The supported sub commands include --show-coalesce.
 .RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
diff --git a/ethtool.c b/ethtool.c
index ba741f0..a966bf8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1219,6 +1219,29 @@ static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 	return 0;
 }
 
+void dump_per_queue_coalesce(struct ethtool_per_queue_op *per_queue_opt,
+			     __u32 *queue_mask)
+{
+	char *addr;
+	int i;
+
+	addr = (char *)per_queue_opt + sizeof(*per_queue_opt);
+	for (i = 0; i < __KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32); i++) {
+		int queue = i * 32;
+		__u32 mask = queue_mask[i];
+
+		while (mask > 0) {
+			if (mask & 0x1) {
+				fprintf(stdout, "Queue: %d\n", queue);
+				dump_coalesce((struct ethtool_coalesce *)addr);
+				addr += sizeof(struct ethtool_coalesce);
+			}
+			mask = mask >> 1;
+			queue++;
+		}
+	}
+}
+
 struct feature_state {
 	u32 off_flags;
 	struct ethtool_gfeatures features;
@@ -4198,7 +4221,8 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
-	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command",
+	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command. "
+	  "The supported sub commands include --show-coalesce",
 	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
@@ -4302,8 +4326,31 @@ static int find_max_num_queues(struct cmd_context *ctx)
 	return MAX(MAX(echannels.rx_count, echannels.tx_count), echannels.combined_count);
 }
 
+static struct ethtool_per_queue_op *
+get_per_queue_coalesce(struct cmd_context *ctx,
+		       __u32 *queue_mask, int n_queues)
+{
+	struct ethtool_per_queue_op *per_queue_opt;
+
+	per_queue_opt = malloc(sizeof(*per_queue_opt) + n_queues * sizeof(struct ethtool_coalesce));
+	if (!per_queue_opt)
+		return NULL;
+
+	memcpy(per_queue_opt->queue_mask, queue_mask, __KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32) * sizeof(__u32));
+	per_queue_opt->cmd = ETHTOOL_PERQUEUE;
+	per_queue_opt->sub_command = ETHTOOL_GCOALESCE;
+	if (send_ioctl(ctx, per_queue_opt)) {
+		free(per_queue_opt);
+		perror("Cannot get device per queue parameters");
+		return NULL;
+	}
+
+	return per_queue_opt;
+}
+
 static int do_perqueue(struct cmd_context *ctx)
 {
+	struct ethtool_per_queue_op *per_queue_opt;
 	__u32 queue_mask[__KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32)] = {0};
 	int i, n_queues = 0;
 
@@ -4342,7 +4389,18 @@ static int do_perqueue(struct cmd_context *ctx)
 	if (i < 0)
 		exit_bad_args();
 
-	/* no sub_command support yet */
+	if (strstr(args[i].opts, "--show-coalesce") != NULL) {
+		per_queue_opt = get_per_queue_coalesce(ctx, queue_mask, n_queues);
+		if (per_queue_opt == NULL) {
+			perror("Cannot get device per queue parameters");
+			return -EFAULT;
+		}
+		dump_per_queue_coalesce(per_queue_opt, queue_mask);
+		free(per_queue_opt);
+	} else {
+		perror("The subcommand is not supported yet");
+		return -EOPNOTSUPP;
+	}
 
 	return 0;
 }
-- 
2.5.0
