From: kan.liang@intel.com
Subject: [PATCH 5/5] ethtool: support per queue sub command --coalesce
Date: Sun, 15 May 2016 00:14:36 -0700
Message-ID: <1463296476-32493-5-git-send-email-kan.liang@intel.com>
References: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327AbcEOOkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 10:40:41 -0400
In-Reply-To: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch uses a similar way as do_scoalesce to set coalesce per queue.
It reads the current settings, change them, and write them back to the
kernel for each masked queue.

Example:

 $ sudo ./ethtool --set-perqueue-command eth5 queue_mask 0x1 --coalesce
 rx-usecs 10 tx-usecs 5
 $ sudo ./ethtool --set-perqueue-command eth5 queue_mask 0x1
 --show-coalesce

 Queue: 0
 Adaptive RX: on  TX: on
 stats-block-usecs: 0
 sample-interval: 0
 pkt-rate-low: 0
 pkt-rate-high: 0

 rx-usecs: 10
 rx-frames: 0
 rx-usecs-irq: 0
 rx-frames-irq: 256

 tx-usecs: 5
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
 ethtool.c    | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 210ec8c..0e42180 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -937,7 +937,7 @@ Sets the specific queues which the sub command is applied to.
 If queue_mask is not set, the sub command will be applied to all queues.
 .TP
 .B sub_command
-Sets the sub command. The supported sub commands include --show-coalesce.
+Sets the sub command. The supported sub commands include --show-coalesce and --coalesce.
 .RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
diff --git a/ethtool.c b/ethtool.c
index a966bf8..55ba26c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4222,7 +4222,7 @@ static const struct option {
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
 	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command. "
-	  "The supported sub commands include --show-coalesce",
+	  "The supported sub commands include --show-coalesce, --coalesce",
 	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
@@ -4348,6 +4348,52 @@ get_per_queue_coalesce(struct cmd_context *ctx,
 	return per_queue_opt;
 }
 
+static void __set_per_queue_coalesce(int queue)
+{
+	int changed = 0;
+
+	do_generic_set(cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce),
+		       &changed);
+
+	if (!changed)
+		fprintf(stderr, "Queue %d, no coalesce parameters changed\n", queue);
+}
+
+static void set_per_queue_coalesce(struct cmd_context *ctx,
+				   struct ethtool_per_queue_op *per_queue_opt)
+{
+	__u32 *queue_mask = per_queue_opt->queue_mask;
+	char *addr = (char *)per_queue_opt + sizeof(*per_queue_opt);
+	int gcoalesce_changed = 0;
+	int i;
+
+	parse_generic_cmdline(ctx, &gcoalesce_changed,
+			      cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce));
+
+	for (i = 0; i < __KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32); i++) {
+		int queue = i * 32;
+		__u32 mask = queue_mask[i];
+
+		while (mask > 0) {
+			if (mask & 0x1) {
+				memcpy(&s_ecoal, addr, sizeof(struct ethtool_coalesce));
+				__set_per_queue_coalesce(queue);
+				memcpy(addr, &s_ecoal, sizeof(struct ethtool_coalesce));
+				addr += sizeof(struct ethtool_coalesce);
+			}
+			mask = mask >> 1;
+			queue++;
+		}
+	}
+
+	per_queue_opt->cmd = ETHTOOL_PERQUEUE;
+	per_queue_opt->sub_command = ETHTOOL_SCOALESCE;
+
+	if (send_ioctl(ctx, per_queue_opt))
+		perror("Cannot set device per queue parameters");
+
+}
+
 static int do_perqueue(struct cmd_context *ctx)
 {
 	struct ethtool_per_queue_op *per_queue_opt;
@@ -4397,6 +4443,16 @@ static int do_perqueue(struct cmd_context *ctx)
 		}
 		dump_per_queue_coalesce(per_queue_opt, queue_mask);
 		free(per_queue_opt);
+	} else if (strstr(args[i].opts, "--coalesce") != NULL) {
+		ctx->argc--;
+		ctx->argp++;
+		per_queue_opt = get_per_queue_coalesce(ctx, queue_mask, n_queues);
+		if (per_queue_opt == NULL) {
+			perror("Cannot get device per queue parameters");
+			return -EFAULT;
+		}
+		set_per_queue_coalesce(ctx, per_queue_opt);
+		free(per_queue_opt);
 	} else {
 		perror("The subcommand is not supported yet");
 		return -EOPNOTSUPP;
-- 
2.5.0
