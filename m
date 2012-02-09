From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/2] iptables: xt_LOG: Add ring buffer support
Date: Thu,  9 Feb 2012 22:54:50 +0100
Message-ID: <1328824493-4136-4-git-send-email-richard@nod.at>
References: <1328824493-4136-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jengelh@medozas.de, rostedt@goodmis.org,
	pablo@netfilter.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1328824493-4136-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds "--ring" and "--ring-size" to xt_LOG.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 extensions/libxt_LOG.c           |  129 ++++++++++++++++++++++++++++++++++++++
 extensions/libxt_LOG.man         |    9 +++
 include/linux/netfilter/xt_LOG.h |   13 ++++-
 3 files changed, 150 insertions(+), 1 deletions(-)

diff --git a/extensions/libxt_LOG.c b/extensions/libxt_LOG.c
index a4c11b6..a9afbb5 100644
--- a/extensions/libxt_LOG.c
+++ b/extensions/libxt_LOG.c
@@ -1,10 +1,12 @@
 #include <stdio.h>
 #include <string.h>
+#include <ctype.h>
 #include <syslog.h>
 #include <xtables.h>
 #include <linux/netfilter/xt_LOG.h>
 
 #define LOG_DEFAULT_LEVEL LOG_WARNING
+#define DEFAULT_RING_SIZE 1024
 
 #ifndef XT_LOG_UID /* Old kernel */
 #define XT_LOG_UID	0x08	/* Log UID owning local socket */
@@ -20,6 +22,9 @@ enum {
 	O_LOG_IPOPTS,
 	O_LOG_UID,
 	O_LOG_MAC,
+	O_LOG_TIMESTAMP,
+	O_LOG_RING_NAME,
+	O_LOG_RING_SIZE,
 };
 
 static void LOG_help(void)
@@ -35,6 +40,17 @@ static void LOG_help(void)
 " --log-macdecode		Decode MAC addresses and protocol.\n\n");
 }
 
+static void LOG_help_v1(void)
+{
+	LOG_help();
+
+	printf(
+" --log-timestamp		Add the current time to the log message.\n\n"
+" --ring NAME			Log messages into a ring buffer NAME instead of kernel syslog.\n\n"
+" --ring-size SIZE		Size of the ring buffer in KiB.\n\n"
+);
+}
+
 #define s struct xt_log_info
 static const struct xt_option_entry LOG_opts[] = {
 	{.name = "log-level", .id = O_LOG_LEVEL, .type = XTTYPE_SYSLOGLEVEL,
@@ -50,6 +66,26 @@ static const struct xt_option_entry LOG_opts[] = {
 };
 #undef s
 
+#define s struct xt_log_info_v1
+static const struct xt_option_entry LOG_opts_v1[] = {
+	{.name = "log-level", .id = O_LOG_LEVEL, .type = XTTYPE_SYSLOGLEVEL,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, level)},
+	{.name = "log-prefix", .id = O_LOG_PREFIX, .type = XTTYPE_STRING,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, prefix), .min = 1},
+	{.name = "log-tcp-sequence", .id = O_LOG_TCPSEQ, .type = XTTYPE_NONE},
+	{.name = "log-tcp-options", .id = O_LOG_TCPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-ip-options", .id = O_LOG_IPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-uid", .id = O_LOG_UID, .type = XTTYPE_NONE},
+	{.name = "log-macdecode", .id = O_LOG_MAC, .type = XTTYPE_NONE},
+	{.name = "log-timestamp", .id = O_LOG_TIMESTAMP, .type = XTTYPE_NONE},
+	{.name = "ring", .id = O_LOG_RING_NAME, .type = XTTYPE_STRING,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, ring_name), .min = 1},
+	{.name = "ring-size", .id = O_LOG_RING_SIZE, .type = XTTYPE_UINT64,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, ring_size)},
+	XTOPT_TABLEEND,
+};
+#undef s
+
 static void LOG_init(struct xt_entry_target *t)
 {
 	struct xt_log_info *loginfo = (struct xt_log_info *)t->data;
@@ -104,6 +140,29 @@ static void LOG_parse(struct xt_option_call *cb)
 	}
 }
 
+static void LOG_parse_v1(struct xt_option_call *cb)
+{
+	struct xt_log_info_v1 *info = cb->data;
+	int i;
+
+	LOG_parse(cb);
+
+	switch (cb->entry->id) {
+	case O_LOG_TIMESTAMP:
+		info->logflags |= XT_LOG_ADD_TIMESTAMP;
+		break;	
+	case O_LOG_RING_NAME:
+		if (!info->ring_size)
+			info->ring_size = DEFAULT_RING_SIZE;
+
+		for (i = 0; i < strlen(info->ring_name); i++)
+			if (!isalnum(cb->arg[i]))
+				xtables_error(PARAMETER_PROBLEM,
+				"Ring name is not alphanumeric");
+		break;
+	}
+}
+
 static void LOG_print(const void *ip, const struct xt_entry_target *target,
                       int numeric)
 {
@@ -141,6 +200,27 @@ static void LOG_print(const void *ip, const struct xt_entry_target *target,
 		printf(" prefix \"%s\"", loginfo->prefix);
 }
 
+static void LOG_print_v1(const void *ip, const struct xt_entry_target *target,
+		         int numeric)
+{
+	const struct xt_log_info_v1 *loginfo
+		= (const struct xt_log_info_v1 *)target->data;
+
+	LOG_print(ip, target, numeric);
+
+	if (!numeric) {
+		if (loginfo->logflags & XT_LOG_ADD_TIMESTAMP)
+			printf(" log-timestamp");	
+	}
+
+	if (loginfo->ring_name[0]) {
+		printf(" ring \"%s\"", loginfo->ring_name);
+
+		if (loginfo->ring_size != DEFAULT_RING_SIZE)
+			printf(" ring-size %lu", (unsigned long)loginfo->ring_size);
+	}
+}
+
 static void LOG_save(const void *ip, const struct xt_entry_target *target)
 {
 	const struct xt_log_info *loginfo
@@ -166,6 +246,25 @@ static void LOG_save(const void *ip, const struct xt_entry_target *target)
 		printf(" --log-macdecode");
 }
 
+static void LOG_save_v1(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_log_info_v1 *loginfo
+		= (const struct xt_log_info_v1 *)target->data;
+
+	LOG_save(ip, target);
+
+	if (loginfo->logflags & XT_LOG_ADD_TIMESTAMP)
+		printf(" --log-timestamp");
+
+	if (loginfo->ring_name[0]) {
+		printf(" --ring");
+		xtables_save_string(loginfo->ring_name);
+
+		if (loginfo->ring_size != DEFAULT_RING_SIZE)
+			printf(" --ring-size %lu", (unsigned long)loginfo->ring_size);
+	}
+}
+
 static struct xtables_target log_tg_regs[] = {
 	{
 		.name          = "LOG",
@@ -176,6 +275,7 @@ static struct xtables_target log_tg_regs[] = {
 		.help          = LOG_help,
 		.init          = LOG_init,
 		.print         = LOG_print,
+		.revision      = 0,
 		.save          = LOG_save,
 		.x6_parse      = LOG_parse,
 		.x6_options    = LOG_opts,
@@ -189,10 +289,39 @@ static struct xtables_target log_tg_regs[] = {
 		.help          = LOG_help,
 		.init          = LOG_init,
 		.print         = LOG_print,
+		.revision      = 0,
 		.save          = LOG_save,
 		.x6_parse      = LOG_parse,
 		.x6_options    = LOG_opts,
 	},
+	{
+		.name          = "LOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct xt_log_info_v1)),
+		.userspacesize = offsetof(struct xt_log_info_v1, rctx),
+		.help          = LOG_help_v1,
+		.init          = LOG_init,
+		.print         = LOG_print_v1,
+		.revision      = 1,
+		.save          = LOG_save_v1,
+		.x6_parse      = LOG_parse_v1,
+		.x6_options    = LOG_opts_v1,
+	},
+	{
+		.name          = "LOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV6,
+		.size          = XT_ALIGN(sizeof(struct xt_log_info_v1)),
+		.userspacesize = offsetof(struct xt_log_info_v1, rctx),
+		.help          = LOG_help_v1,
+		.init          = LOG_init,
+		.print         = LOG_print_v1,
+		.revision      = 1,
+		.save          = LOG_save_v1,
+		.x6_parse      = LOG_parse_v1,
+		.x6_options    = LOG_opts_v1,
+	},
 };
 
 void _init(void)
diff --git a/extensions/libxt_LOG.man b/extensions/libxt_LOG.man
index 47c35e0..2f0b2ff 100644
--- a/extensions/libxt_LOG.man
+++ b/extensions/libxt_LOG.man
@@ -29,3 +29,12 @@ Log options from the IP packet header.
 .TP
 \fB\-\-log\-uid\fP
 Log the userid of the process which generated the packet.
+\fB\-\-log\-timestamp\fP
+Add a timestamp to each log message.
+\fB\-\-ring\fP \fIname\fP
+Log all messages into a ring buffer identified by \fIname\fP.
+Each ring buffer is represented as file in 
+/proc/net/netfilter/xt_LOG_ring/.
+\fB\-\-ring\-size\fP \fIsize\fP
+Set the ring buffer size in KiB.
+Default is 1024 KiB.
diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
index cac0790..d84710c 100644
--- a/include/linux/netfilter/xt_LOG.h
+++ b/include/linux/netfilter/xt_LOG.h
@@ -8,7 +8,8 @@
 #define XT_LOG_UID		0x08	/* Log UID owning local socket */
 #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
 #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
-#define XT_LOG_MASK		0x2f
+#define XT_LOG_ADD_TIMESTAMP	0x40	/* Add a timestamp */
+#define XT_LOG_MASK		0x6f
 
 struct xt_log_info {
 	unsigned char level;
@@ -16,4 +17,14 @@ struct xt_log_info {
 	char prefix[30];
 };
 
+struct xt_log_info_v1 {
+	unsigned char level;
+	unsigned char logflags;
+	char prefix[30];
+
+	char ring_name[30];
+	__aligned_u64 ring_size;
+	struct xt_LOG_ring_ctx *rctx __attribute__((aligned(8)));
+};
+
 #endif /* _XT_LOG_H */
-- 
1.7.7.3

