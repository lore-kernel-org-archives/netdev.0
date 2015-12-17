From: kan.liang@intel.com
Subject: [RFC 4/5] ethtool: support per queue sub command --show-coalesce
Date: Thu, 17 Dec 2015 06:53:05 +0000
Message-ID: <1450335186-3062-4-git-send-email-kan.liang@intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:15482 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754435AbbLQSed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:34:33 -0500
In-Reply-To: <1450335186-3062-1-git-send-email-kan.liang@intel.com>
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
 ethtool.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 59 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index ea88c85..e7becc9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1236,6 +1236,29 @@ static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 	return 0;
 }
 
+void dump_per_queue_coalesce(struct ethtool_per_queue_op *per_queue_opt,
+			     __u64 *queue_mask)
+{
+	char *addr;
+	int i;
+
+	addr = (char *)per_queue_opt + sizeof(*per_queue_opt);
+	for (i = 0; i < MAX_QUEUE_MASK; i++) {
+		int queue = i * 64;
+		__u64 mask = queue_mask[i];
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
@@ -4148,7 +4171,8 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
-	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command",
+	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command. "
+	  "The supported sub commands include --show-coalesce",
 	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
@@ -4242,8 +4266,30 @@ static int find_max_queue_num(struct cmd_context *ctx)
 	return MAX(MAX(echannels.rx_count, echannels.tx_count), echannels.combined_count);
 }
 
+static struct ethtool_per_queue_op *
+get_per_queue_coalesce(struct cmd_context *ctx,
+		       __u64 *queue_mask, int queue_num)
+{
+	struct ethtool_per_queue_op *per_queue_opt;
+
+	per_queue_opt = malloc(sizeof(*per_queue_opt) + queue_num * sizeof(struct ethtool_coalesce));
+	if (!per_queue_opt)
+		return NULL;
+	memcpy(per_queue_opt->queue_mask, queue_mask, MAX_QUEUE_MASK * sizeof(__u64));
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
 	__u64 queue_mask[MAX_QUEUE_MASK] = {0};
 	__u64 mask;
 	int i, queue_num = 0;
@@ -4286,7 +4332,18 @@ static int do_perqueue(struct cmd_context *ctx)
 	if (i < 0)
 		exit_bad_args();
 
-	/* no sub_command support yet */
+	if (strstr(args[i].opts, "--show-coalesce") != NULL) {
+		per_queue_opt = get_per_queue_coalesce(ctx, queue_mask, queue_num);
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
1.7.11.7
