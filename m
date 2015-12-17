From: kan.liang@intel.com
Subject: [RFC 3/5] ethtool: introduce new ioctl for per queue setting
Date: Thu, 17 Dec 2015 06:53:04 +0000
Message-ID: <1450335186-3062-3-git-send-email-kan.liang@intel.com>
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
	id S1754190AbbLQSec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:34:32 -0500
In-Reply-To: <1450335186-3062-1-git-send-email-kan.liang@intel.com>
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
 ethtool-copy.h | 18 +++++++++++
 ethtool.c      | 94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 internal.h     |  2 ++
 3 files changed, 114 insertions(+)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..a76c1dc 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1108,6 +1108,22 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+#define MAX_QUEUE		4096
+#define MAX_QUEUE_MASK		(MAX_QUEUE / 64)
+
+/**
+ * struct ethtool_per_queue_op - apply sub command to the queues in mask.
+ * @cmd: ETHTOOL_PERQUEUE
+ * @queue_mask: Mask the queues which sub command apply to
+ * @sub_command: the sub command
+ * @data: parameters of the command
+ */
+struct ethtool_per_queue_op {
+	__u32	cmd;
+	__u64	queue_mask[MAX_QUEUE_MASK];
+	__u32	sub_command;
+	char	data[];
+};
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -1190,6 +1206,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
+#define ETHTOOL_PERQUEUE	0x0000004a /* Set per queue options */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/ethtool.c b/ethtool.c
index cb9e630..ea88c85 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3989,6 +3989,8 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_perqueue(struct cmd_context *ctx);
+
 #ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
@@ -4146,6 +4148,8 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--set-perqueue-command", 1, do_perqueue, "Set per queue command",
+	  "		[queue_mask %x] SUB_COMMAND\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
@@ -4197,6 +4201,96 @@ static int find_option(int argc, char **argp)
 	return -1;
 }
 
+static int set_queue_mask(u64 *queue_mask, char *str)
+{
+	int len = strlen(str);
+	int index = BITS_TO_U64((len * 4));
+	char tmp[17];
+	char *end = str + len;
+	int i, num;
+
+	if (len > MAX_QUEUE)
+		return -EINVAL;
+
+	for (i = 0; i < index; i++) {
+		num = end - str;
+		if (num >= 16) {
+			end -= 16;
+			num = 16;
+		} else {
+			end = str;
+		}
+		strncpy(tmp, end, num);
+		tmp[num] = '\0';
+
+		queue_mask[i] = strtoull(tmp, NULL, 16);
+	}
+
+	return 0;
+}
+
+#define MAX(x, y) (x > y ? x : y)
+
+static int find_max_queue_num(struct cmd_context *ctx)
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
+	__u64 queue_mask[MAX_QUEUE_MASK] = {0};
+	__u64 mask;
+	int i, queue_num = 0;
+
+	if (ctx->argc == 0)
+		exit_bad_args();
+
+	/* All queues will be applied if no queue_mask set */
+	if (strncmp(*ctx->argp, "queue_mask", 10)) {
+		queue_num = find_max_queue_num(ctx);
+		if (queue_num < 0) {
+			perror("Cannot get queue number");
+			return -EFAULT;
+		}
+		for (i = 0; i < queue_num / 64; i++)
+			queue_mask[i] = ~0;
+		queue_mask[i] = (1ULL << (queue_num - i * 64)) - 1;
+	} else {
+		ctx->argc--;
+		ctx->argp++;
+		if (set_queue_mask(queue_mask, *ctx->argp)) {
+			perror("Invalid queue mask");
+			return -EINVAL;
+		}
+		ctx->argc--;
+		ctx->argp++;
+
+		/* Get the masked queue number */
+		for (i = 0; i < MAX_QUEUE_MASK; i++) {
+			mask = queue_mask[i];
+			while (mask > 0) {
+				if (mask & 0x1)
+					queue_num++;
+				mask = mask >> 1;
+			}
+		}
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
diff --git a/internal.h b/internal.h
index b5ef646..6690d40 100644
--- a/internal.h
+++ b/internal.h
@@ -65,8 +65,10 @@ static inline u64 cpu_to_be64(u64 value)
 
 #define BITS_PER_BYTE		8
 #define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
+#define BITS_PER_LONG_LONG	(BITS_PER_BYTE * sizeof(unsigned long long))
 #define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
 #define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
+#define BITS_TO_U64(nr)		DIV_ROUND_UP(nr, BITS_PER_LONG_LONG)
 
 static inline void set_bit(unsigned int nr, unsigned long *addr)
 {
-- 
1.7.11.7
