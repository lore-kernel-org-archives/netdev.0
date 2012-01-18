From: Richard Weinberger <rw@linutronix.de>
Subject: [PATCH 5/5] xt_RLOG: add userspace-components
Date: Wed, 18 Jan 2012 23:43:30 +0100
Message-ID: <1326926610-17830-6-git-send-email-rw@linutronix.de>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>


Signed-off-by: Richard Weinberger <richard@nod.at>
---
 extensions/libxt_RLOG.c   |  171 +++++++++++++++++++++++++++++++++++++++++++++
 extensions/libxt_RLOG.man |   17 +++++
 2 files changed, 188 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_RLOG.c
 create mode 100644 extensions/libxt_RLOG.man

diff --git a/extensions/libxt_RLOG.c b/extensions/libxt_RLOG.c
new file mode 100644
index 0000000..1a7d697
--- /dev/null
+++ b/extensions/libxt_RLOG.c
@@ -0,0 +1,171 @@
+#include <stdio.h>
+#include <string.h>
+#include <ctype.h>
+#include <xtables.h>
+#include <linux/netfilter_ipv4/ipt_LOG.h>
+
+#ifndef IPT_LOG_UID /* Old kernel */
+#define IPT_LOG_UID		0x08    /* Log UID owning local socket */
+#undef  IPT_LOG_MASK
+#define IPT_LOG_MASK		0x0f
+#endif
+
+#define RING_NAME_LEN		32
+#define DEFAULT_RING_SIZE       1024 /* in KiB */
+#define DEFAULT_RING_NAME	"default"
+
+struct rlog_tg_info {
+	char name[RING_NAME_LEN];
+	unsigned int size;
+	unsigned char logflags;
+	bool add_timestamp;
+};
+
+enum {
+	O_RLOG_RING_SIZE = 0,
+	O_RLOG_RING,
+	O_LOG_TCPSEQ,
+	O_LOG_TCPOPTS,
+	O_LOG_IPOPTS,
+	O_LOG_UID,
+	O_LOG_MAC,
+	O_ADD_TS
+};
+
+static void RLOG_help(void)
+{
+	printf(
+"RLOG target options:\n"
+" --ring NAME			Log messages into NAME.\n\n"
+" --log-tcp-sequence            Log TCP sequence numbers.\n\n"
+" --log-tcp-options             Log TCP options.\n\n"
+" --log-ip-options              Log IP options.\n\n"
+" --log-uid                     Log UID owning the local socket.\n\n"
+" --log-macdecode               Decode MAC addresses and protocol.\n\n"
+" --add-timestamp		Add a timestamp to each log message.\n\n");
+}
+
+#define s struct rlog_tg_info
+static const struct xt_option_entry RLOG_opts[] = {
+	{.name = "size", .id = O_RLOG_RING_SIZE, .type = XTTYPE_UINT32,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, size)},
+	{.name = "ring", .id = O_RLOG_RING, .type = XTTYPE_STRING,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, name), .min = 1, .max = RING_NAME_LEN},
+	{.name = "log-tcp-sequence", .id = O_LOG_TCPSEQ, .type = XTTYPE_NONE},
+	{.name = "log-tcp-options", .id = O_LOG_TCPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-ip-options", .id = O_LOG_IPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-uid", .id = O_LOG_UID, .type = XTTYPE_NONE},
+	{.name = "log-macdecode", .id = O_LOG_MAC, .type = XTTYPE_NONE},
+	{.name = "add-timestamp", .id = O_ADD_TS, .type = XTTYPE_NONE},
+	XTOPT_TABLEEND,
+};
+#undef s
+
+static void RLOG_init(struct xt_entry_target *t)
+{
+	struct rlog_tg_info *info = (struct rlog_tg_info *)t->data;
+
+	info->size = DEFAULT_RING_SIZE;
+	strcpy(info->name, DEFAULT_RING_NAME);
+	info->add_timestamp = false;
+	info->logflags = 0;
+}
+
+static void RLOG_parse(struct xt_option_call *cb)
+{
+	struct rlog_tg_info *info = cb->data;
+	int len, i;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_RLOG_RING:
+		len = strlen(cb->arg);
+
+		for (i = 0; i < len; i++)
+			if (!isalnum(cb->arg[i]))
+				xtables_error(PARAMETER_PROBLEM, "--ring allows only alphanumeric names!\n");
+		break;
+	case O_LOG_TCPSEQ:
+		info->logflags |= IPT_LOG_TCPSEQ;
+		break;
+	case O_LOG_TCPOPTS:
+		info->logflags |= IPT_LOG_TCPOPT;
+		break;
+	case O_LOG_IPOPTS:
+		info->logflags |= IPT_LOG_IPOPT;
+		break;
+	case O_LOG_UID:
+		info->logflags |= IPT_LOG_UID;
+		break;
+	case O_LOG_MAC:
+		info->logflags |= IPT_LOG_MACDECODE;
+		break;
+	case O_ADD_TS:
+		info->add_timestamp = true;
+		break;
+	}
+}
+
+static void RLOG_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct rlog_tg_info *info
+		= (const struct rlog_tg_info *)target->data;
+
+	if (strcmp(info->name, DEFAULT_RING_NAME) != 0)
+		printf(" --ring %s", info->name);
+	if (info->size != DEFAULT_RING_SIZE)
+		printf(" --size %u", info->size);
+	if (info->logflags & IPT_LOG_TCPSEQ)
+		printf(" --log-tcp-sequence");
+	if (info->logflags & IPT_LOG_TCPOPT)
+		printf(" --log-tcp-options");
+	if (info->logflags & IPT_LOG_IPOPT)
+		printf(" --log-ip-options");
+	if (info->logflags & IPT_LOG_UID)
+		printf(" --log-uid");
+	if (info->logflags & IPT_LOG_MACDECODE)
+		printf(" --log-macdecode");
+	if (info->add_timestamp)
+		printf(" --add-timestamp");
+}
+
+static void RLOG_print(const void *ip, const struct xt_entry_target *target,
+                      int numeric)
+{
+	printf(" RLOG");
+	RLOG_save(ip, target);
+}
+
+static struct xtables_target rlog_tg_regs[] = {
+	{
+		.name          = "RLOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct rlog_tg_info) + sizeof (void *)),
+		.userspacesize = XT_ALIGN(sizeof(struct rlog_tg_info)),
+		.help          = RLOG_help,
+		.init          = RLOG_init,
+		.print         = RLOG_print,
+		.save          = RLOG_save,
+		.x6_parse      = RLOG_parse,
+		.x6_options    = RLOG_opts,
+	},
+	{
+		.name          = "RLOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV6,
+		.size          = XT_ALIGN(sizeof(struct rlog_tg_info) + sizeof (void *)),
+		.userspacesize = XT_ALIGN(sizeof(struct rlog_tg_info)),
+		.help          = RLOG_help,
+		.init          = RLOG_init,
+		.print         = RLOG_print,
+		.save          = RLOG_save,
+		.x6_parse      = RLOG_parse,
+		.x6_options    = RLOG_opts,
+	}
+};
+
+void _init(void)
+{
+	xtables_register_targets(rlog_tg_regs, ARRAY_SIZE(rlog_tg_regs));
+}
diff --git a/extensions/libxt_RLOG.man b/extensions/libxt_RLOG.man
new file mode 100644
index 0000000..184c779
--- /dev/null
+++ b/extensions/libxt_RLOG.man
@@ -0,0 +1,17 @@
+Turn on kernel logging of matching packets. This target generates
+messages like LOG but instead of writing them into the kernel 
+syslog it writes them info one or more ring buffers
+Each ring buffer is represented as a file in 
+/proc/net/netfilter/xt_RLOG/.
+.TP
+\fB\-\-ring\fP \fIname\fP
+Write messages into ring buffer \fIname\fP.
+.TP
+\fB\-\-ring\fP \fIN\fP
+Make the ring buffer \fIN\fP KiB long.
+.TP
+\fB\-\-log\-tcp\-sequence\fP
+\fB\-\-log\-tcp\-options\fP
+\fB\-\-log\-ip\-options\fP
+\fB\-\-log\-uid\fP
+See LOG.
-- 
1.7.7
