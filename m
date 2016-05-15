From: kan.liang@intel.com
Subject: [PATCH 3/5] ethtool: introduce new ioctl for per queue setting
Date: Sun, 15 May 2016 00:14:34 -0700
Message-ID: <1463296476-32493-3-git-send-email-kan.liang@intel.com>
References: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59592 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbcEOOkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 10:40:40 -0400
In-Reply-To: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Introduce a new ioctl for per queue parameters setting.
Users can apply commands to specific queues by setting SUB_COMMAND and
queue_mask as following command.

 ethtool --set-perqueue-command DEVNAME [queue_mask %x] SUB_COMMAND

If queue_mask is not set, the SUB_COMMAND will be applied to all queues.

The following patches will enable SUB_COMMANDs for per queue setting.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 ethtool.8.in |  19 ++++++++++++
 ethtool.c    | 100 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 009711d..26d01cb 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -339,6 +339,13 @@ ethtool \- query or control network driver and hardware settings
 .B2 tx-lpi on off
 .BN tx-timer
 .BN advertise
+.HP
+.B ethtool \-\-set\-perqueue\-command
+.I devname
+.RB [ queue_mask
+.IR %x ]
+.I sub_command
+.RB ...
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -920,6 +927,18 @@ Values are as for
 Sets the amount of time the device should stay in idle mode prior to asserting
 its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
 .RE
+.TP
+.B \-\-set\-perqueue\-command
+Sets sub command to specific queues.
+.RS 4
+.TP
+.B queue_mask %x
+Sets the specific queues which the sub command is applied to.
+If queue_mask is not set, the sub command will be applied to all queues.
+.TP
+.B sub_command
+Sets the sub command.
+.RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 86724a2..ba741f0 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4037,6 +4037,8 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_perqueue(struct cmd_context *ctx);
+
 #ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
@@ -4196,6 +4198,8 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command",
+	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
@@ -4247,6 +4251,102 @@ static int find_option(int argc, char **argp)
 	return -1;
 }
 
+static int set_queue_mask(u32 *queue_mask, char *str)
+{
+	int len = strlen(str);
+	int index = __KERNEL_DIV_ROUND_UP(len * 4, 32);
+	char tmp[9];
+	char *end = str + len;
+	int i, num;
+	__u32 mask;
+	int n_queues = 0;
+
+	if (len > MAX_NUM_QUEUE)
+		return -EINVAL;
+
+	for (i = 0; i < index; i++) {
+		num = end - str;
+
+		if (num >= 8) {
+			end -= 8;
+			num = 8;
+		} else {
+			end = str;
+		}
+		strncpy(tmp, end, num);
+		tmp[num] = '\0';
+
+		queue_mask[i] = strtoul(tmp, NULL, 16);
+
+		mask = queue_mask[i];
+		while (mask > 0) {
+			if (mask & 0x1)
+				n_queues++;
+			mask = mask >> 1;
+		}
+	}
+
+	return n_queues;
+}
+
+#define MAX(x, y) (x > y ? x : y)
+
+static int find_max_num_queues(struct cmd_context *ctx)
+{
+	struct ethtool_channels echannels;
+
+	echannels.cmd = ETHTOOL_GCHANNELS;
+	if (send_ioctl(ctx, &echannels))
+		return -1;
+
+	return MAX(MAX(echannels.rx_count, echannels.tx_count), echannels.combined_count);
+}
+
+static int do_perqueue(struct cmd_context *ctx)
+{
+	__u32 queue_mask[__KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32)] = {0};
+	int i, n_queues = 0;
+
+	if (ctx->argc == 0)
+		exit_bad_args();
+
+	/*
+	 * The sub commands will be applied to
+	 * all queues if no queue_mask set
+	 */
+	if (strncmp(*ctx->argp, "queue_mask", 10)) {
+		n_queues = find_max_num_queues(ctx);
+		if (n_queues < 0) {
+			perror("Cannot get number of queues");
+			return -EFAULT;
+		}
+		for (i = 0; i < n_queues / 32; i++)
+			queue_mask[i] = ~0;
+		queue_mask[i] = (1 << (n_queues - i * 32)) - 1;
+		fprintf(stdout, "The sub commands will be applied"
+				" to all %d queues\n", n_queues);
+	} else {
+		ctx->argc--;
+		ctx->argp++;
+		n_queues = set_queue_mask(queue_mask, *ctx->argp);
+		if (n_queues < 0) {
+			perror("Invalid queue mask");
+			return n_queues;
+		}
+		ctx->argc--;
+		ctx->argp++;
+
+	}
+
+	i = find_option(ctx->argc, ctx->argp);
+	if (i < 0)
+		exit_bad_args();
+
+	/* no sub_command support yet */
+
+	return 0;
+}
+
 int main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
-- 
2.5.0
