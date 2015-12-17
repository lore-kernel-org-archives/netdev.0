From: kan.liang@intel.com
Subject: [RFC 5/5] ethtool: support per queue sub command --coalesce
Date: Thu, 17 Dec 2015 06:53:06 +0000
Message-ID: <1450335186-3062-5-git-send-email-kan.liang@intel.com>
References: <1450335186-3062-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, ben@decadent.org.uk,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59491 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571AbbLQSet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:34:49 -0500
In-Reply-To: <1450335186-3062-1-git-send-email-kan.liang@intel.com>
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
 ethtool.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 57 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index e7becc9..43eaa86 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4172,7 +4172,7 @@ static const struct option {
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
 	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command. "
-	  "The supported sub commands include --show-coalesce",
+	  "The supported sub commands include --show-coalesce, --coalesce",
 	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
@@ -4287,6 +4287,52 @@ get_per_queue_coalesce(struct cmd_context *ctx,
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
+	__u64 *queue_mask = per_queue_opt->queue_mask;
+	char *addr = (char *)per_queue_opt + sizeof(*per_queue_opt);
+	int gcoalesce_changed = 0;
+	int i;
+
+	parse_generic_cmdline(ctx, &gcoalesce_changed,
+			      cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce));
+
+	for (i = 0; i < MAX_QUEUE_MASK; i++) {
+		int queue = i * 64;
+		__u64 mask = queue_mask[i];
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
@@ -4340,6 +4386,16 @@ static int do_perqueue(struct cmd_context *ctx)
 		}
 		dump_per_queue_coalesce(per_queue_opt, queue_mask);
 		free(per_queue_opt);
+	} else if (strstr(args[i].opts, "--coalesce") != NULL) {
+		ctx->argc--;
+		ctx->argp++;
+		per_queue_opt = get_per_queue_coalesce(ctx, queue_mask, queue_num);
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
1.7.11.7
