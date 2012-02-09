From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/2] iptables: Merge libip6t_LOG and libipt_LOG into libxt_LOG
Date: Thu,  9 Feb 2012 22:54:48 +0100
Message-ID: <1328824493-4136-2-git-send-email-richard@nod.at>
References: <1328824493-4136-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jengelh@medozas.de, rostedt@goodmis.org,
	pablo@netfilter.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328824493-4136-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

libip6t_LOG and libipt_LOG share a lot of common code, merge them
to recude duplicate code.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 extensions/libip6t_LOG.c         |  184 ----------------------------------
 extensions/libip6t_LOG.man       |   31 ------
 extensions/libipt_LOG.c          |  186 -----------------------------------
 extensions/libipt_LOG.man        |   31 ------
 extensions/libxt_LOG.c           |  201 ++++++++++++++++++++++++++++++++++++++
 extensions/libxt_LOG.man         |   31 ++++++
 include/linux/netfilter/xt_LOG.h |   19 ++++
 7 files changed, 251 insertions(+), 432 deletions(-)
 delete mode 100644 extensions/libip6t_LOG.c
 delete mode 100644 extensions/libip6t_LOG.man
 delete mode 100644 extensions/libipt_LOG.c
 delete mode 100644 extensions/libipt_LOG.man
 create mode 100644 extensions/libxt_LOG.c
 create mode 100644 extensions/libxt_LOG.man
 create mode 100644 include/linux/netfilter/xt_LOG.h

diff --git a/extensions/libip6t_LOG.c b/extensions/libip6t_LOG.c
deleted file mode 100644
index 2b1ae28..0000000
--- a/extensions/libip6t_LOG.c
+++ /dev/null
@@ -1,184 +0,0 @@
-#include <stdio.h>
-#include <string.h>
-#include <syslog.h>
-#include <xtables.h>
-#include <linux/netfilter_ipv6/ip6t_LOG.h>
-
-#ifndef IP6T_LOG_UID	/* Old kernel */
-#define IP6T_LOG_UID	0x08
-#undef  IP6T_LOG_MASK
-#define IP6T_LOG_MASK	0x0f
-#endif
-
-#define LOG_DEFAULT_LEVEL LOG_WARNING
-
-enum {
-	O_LOG_LEVEL = 0,
-	O_LOG_PREFIX,
-	O_LOG_TCPSEQ,
-	O_LOG_TCPOPTS,
-	O_LOG_IPOPTS,
-	O_LOG_UID,
-	O_LOG_MAC,
-};
-
-static void LOG_help(void)
-{
-	printf(
-"LOG target options:\n"
-" --log-level level		Level of logging (numeric or see syslog.conf)\n"
-" --log-prefix prefix		Prefix log messages with this prefix.\n"
-" --log-tcp-sequence		Log TCP sequence numbers.\n"
-" --log-tcp-options		Log TCP options.\n"
-" --log-ip-options		Log IP options.\n"
-" --log-uid			Log UID owning the local socket.\n"
-" --log-macdecode		Decode MAC addresses and protocol.\n");
-}
-
-#define s struct ip6t_log_info
-static const struct xt_option_entry LOG_opts[] = {
-	{.name = "log-level", .id = O_LOG_LEVEL, .type = XTTYPE_SYSLOGLEVEL,
-	 .flags = XTOPT_PUT, XTOPT_POINTER(s, level)},
-	{.name = "log-prefix", .id = O_LOG_PREFIX, .type = XTTYPE_STRING,
-	 .flags = XTOPT_PUT, XTOPT_POINTER(s, prefix), .min = 1},
-	{.name = "log-tcp-sequence", .id = O_LOG_TCPSEQ, .type = XTTYPE_NONE},
-	{.name = "log-tcp-options", .id = O_LOG_TCPOPTS, .type = XTTYPE_NONE},
-	{.name = "log-ip-options", .id = O_LOG_IPOPTS, .type = XTTYPE_NONE},
-	{.name = "log-uid", .id = O_LOG_UID, .type = XTTYPE_NONE},
-	{.name = "log-macdecode", .id = O_LOG_MAC, .type = XTTYPE_NONE},
-	XTOPT_TABLEEND,
-};
-#undef s
-
-static void LOG_init(struct xt_entry_target *t)
-{
-	struct ip6t_log_info *loginfo = (struct ip6t_log_info *)t->data;
-
-	loginfo->level = LOG_DEFAULT_LEVEL;
-
-}
-
-struct ip6t_log_names {
-	const char *name;
-	unsigned int level;
-};
-
-static const struct ip6t_log_names ip6t_log_names[]
-= { { .name = "alert",   .level = LOG_ALERT },
-    { .name = "crit",    .level = LOG_CRIT },
-    { .name = "debug",   .level = LOG_DEBUG },
-    { .name = "emerg",   .level = LOG_EMERG },
-    { .name = "error",   .level = LOG_ERR },		/* DEPRECATED */
-    { .name = "info",    .level = LOG_INFO },
-    { .name = "notice",  .level = LOG_NOTICE },
-    { .name = "panic",   .level = LOG_EMERG },		/* DEPRECATED */
-    { .name = "warning", .level = LOG_WARNING }
-};
-
-static void LOG_parse(struct xt_option_call *cb)
-{
-	struct ip6t_log_info *info = cb->data;
-
-	xtables_option_parse(cb);
-	switch (cb->entry->id) {
-	case O_LOG_PREFIX:
-		if (strchr(cb->arg, '\n') != NULL)
-			xtables_error(PARAMETER_PROBLEM,
-				   "Newlines not allowed in --log-prefix");
-		break;
-	case O_LOG_TCPSEQ:
-		info->logflags |= IP6T_LOG_TCPSEQ;
-		break;
-	case O_LOG_TCPOPTS:
-		info->logflags |= IP6T_LOG_TCPOPT;
-		break;
-	case O_LOG_IPOPTS:
-		info->logflags |= IP6T_LOG_IPOPT;
-		break;
-	case O_LOG_UID:
-		info->logflags |= IP6T_LOG_UID;
-		break;
-	case O_LOG_MAC:
-		info->logflags |= IP6T_LOG_MACDECODE;
-		break;
-	}
-}
-
-static void LOG_print(const void *ip, const struct xt_entry_target *target,
-                      int numeric)
-{
-	const struct ip6t_log_info *loginfo
-		= (const struct ip6t_log_info *)target->data;
-	unsigned int i = 0;
-
-	printf(" LOG");
-	if (numeric)
-		printf(" flags %u level %u",
-		       loginfo->logflags, loginfo->level);
-	else {
-		for (i = 0; i < ARRAY_SIZE(ip6t_log_names); ++i)
-			if (loginfo->level == ip6t_log_names[i].level) {
-				printf(" level %s", ip6t_log_names[i].name);
-				break;
-			}
-		if (i == ARRAY_SIZE(ip6t_log_names))
-			printf(" UNKNOWN level %u", loginfo->level);
-		if (loginfo->logflags & IP6T_LOG_TCPSEQ)
-			printf(" tcp-sequence");
-		if (loginfo->logflags & IP6T_LOG_TCPOPT)
-			printf(" tcp-options");
-		if (loginfo->logflags & IP6T_LOG_IPOPT)
-			printf(" ip-options");
-		if (loginfo->logflags & IP6T_LOG_UID)
-			printf(" uid");
-		if (loginfo->logflags & IP6T_LOG_MACDECODE)
-			printf(" macdecode");
-		if (loginfo->logflags & ~(IP6T_LOG_MASK))
-			printf(" unknown-flags");
-	}
-
-	if (strcmp(loginfo->prefix, "") != 0)
-		printf(" prefix \"%s\"", loginfo->prefix);
-}
-
-static void LOG_save(const void *ip, const struct xt_entry_target *target)
-{
-	const struct ip6t_log_info *loginfo
-		= (const struct ip6t_log_info *)target->data;
-
-	if (strcmp(loginfo->prefix, "") != 0)
-		printf(" --log-prefix \"%s\"", loginfo->prefix);
-
-	if (loginfo->level != LOG_DEFAULT_LEVEL)
-		printf(" --log-level %d", loginfo->level);
-
-	if (loginfo->logflags & IP6T_LOG_TCPSEQ)
-		printf(" --log-tcp-sequence");
-	if (loginfo->logflags & IP6T_LOG_TCPOPT)
-		printf(" --log-tcp-options");
-	if (loginfo->logflags & IP6T_LOG_IPOPT)
-		printf(" --log-ip-options");
-	if (loginfo->logflags & IP6T_LOG_UID)
-		printf(" --log-uid");
-	if (loginfo->logflags & IP6T_LOG_MACDECODE)
-		printf(" --log-macdecode");
-}
-
-static struct xtables_target log_tg6_reg = {
-	.name          = "LOG",
-	.version       = XTABLES_VERSION,
-	.family        = NFPROTO_IPV6,
-	.size          = XT_ALIGN(sizeof(struct ip6t_log_info)),
-	.userspacesize = XT_ALIGN(sizeof(struct ip6t_log_info)),
-	.help          = LOG_help,
-	.init          = LOG_init,
-	.print         = LOG_print,
-	.save          = LOG_save,
-	.x6_parse      = LOG_parse,
-	.x6_options    = LOG_opts,
-};
-
-void _init(void)
-{
-	xtables_register_target(&log_tg6_reg);
-}
diff --git a/extensions/libip6t_LOG.man b/extensions/libip6t_LOG.man
deleted file mode 100644
index b7803fe..0000000
--- a/extensions/libip6t_LOG.man
+++ /dev/null
@@ -1,31 +0,0 @@
-Turn on kernel logging of matching packets.  When this option is set
-for a rule, the Linux kernel will print some information on all
-matching packets (like most IPv6 IPv6-header fields) via the kernel log
-(where it can be read with
-.I dmesg
-or 
-.IR syslogd (8)).
-This is a "non-terminating target", i.e. rule traversal continues at
-the next rule.  So if you want to LOG the packets you refuse, use two
-separate rules with the same matching criteria, first using target LOG
-then DROP (or REJECT).
-.TP
-\fB\-\-log\-level\fP \fIlevel\fP
-Level of logging (numeric or see \fIsyslog.conf\fP(5)).
-.TP
-\fB\-\-log\-prefix\fP \fIprefix\fP
-Prefix log messages with the specified prefix; up to 29 letters long,
-and useful for distinguishing messages in the logs.
-.TP
-\fB\-\-log\-tcp\-sequence\fP
-Log TCP sequence numbers. This is a security risk if the log is
-readable by users.
-.TP
-\fB\-\-log\-tcp\-options\fP
-Log options from the TCP packet header.
-.TP
-\fB\-\-log\-ip\-options\fP
-Log options from the IPv6 packet header.
-.TP
-\fB\-\-log\-uid\fP
-Log the userid of the process which generated the packet.
diff --git a/extensions/libipt_LOG.c b/extensions/libipt_LOG.c
deleted file mode 100644
index 77f16d1..0000000
--- a/extensions/libipt_LOG.c
+++ /dev/null
@@ -1,186 +0,0 @@
-#include <stdio.h>
-#include <string.h>
-#include <syslog.h>
-#include <xtables.h>
-#include <linux/netfilter_ipv4/ipt_LOG.h>
-
-#define LOG_DEFAULT_LEVEL LOG_WARNING
-
-#ifndef IPT_LOG_UID /* Old kernel */
-#define IPT_LOG_UID	0x08	/* Log UID owning local socket */
-#undef  IPT_LOG_MASK
-#define IPT_LOG_MASK	0x0f
-#endif
-
-enum {
-	O_LOG_LEVEL = 0,
-	O_LOG_PREFIX,
-	O_LOG_TCPSEQ,
-	O_LOG_TCPOPTS,
-	O_LOG_IPOPTS,
-	O_LOG_UID,
-	O_LOG_MAC,
-};
-
-static void LOG_help(void)
-{
-	printf(
-"LOG target options:\n"
-" --log-level level		Level of logging (numeric or see syslog.conf)\n"
-" --log-prefix prefix		Prefix log messages with this prefix.\n\n"
-" --log-tcp-sequence		Log TCP sequence numbers.\n\n"
-" --log-tcp-options		Log TCP options.\n\n"
-" --log-ip-options		Log IP options.\n\n"
-" --log-uid			Log UID owning the local socket.\n\n"
-" --log-macdecode		Decode MAC addresses and protocol.\n\n");
-}
-
-#define s struct ipt_log_info
-static const struct xt_option_entry LOG_opts[] = {
-	{.name = "log-level", .id = O_LOG_LEVEL, .type = XTTYPE_SYSLOGLEVEL,
-	 .flags = XTOPT_PUT, XTOPT_POINTER(s, level)},
-	{.name = "log-prefix", .id = O_LOG_PREFIX, .type = XTTYPE_STRING,
-	 .flags = XTOPT_PUT, XTOPT_POINTER(s, prefix), .min = 1},
-	{.name = "log-tcp-sequence", .id = O_LOG_TCPSEQ, .type = XTTYPE_NONE},
-	{.name = "log-tcp-options", .id = O_LOG_TCPOPTS, .type = XTTYPE_NONE},
-	{.name = "log-ip-options", .id = O_LOG_IPOPTS, .type = XTTYPE_NONE},
-	{.name = "log-uid", .id = O_LOG_UID, .type = XTTYPE_NONE},
-	{.name = "log-macdecode", .id = O_LOG_MAC, .type = XTTYPE_NONE},
-	XTOPT_TABLEEND,
-};
-#undef s
-
-static void LOG_init(struct xt_entry_target *t)
-{
-	struct ipt_log_info *loginfo = (struct ipt_log_info *)t->data;
-
-	loginfo->level = LOG_DEFAULT_LEVEL;
-
-}
-
-struct ipt_log_names {
-	const char *name;
-	unsigned int level;
-};
-
-static const struct ipt_log_names ipt_log_names[]
-= { { .name = "alert",   .level = LOG_ALERT },
-    { .name = "crit",    .level = LOG_CRIT },
-    { .name = "debug",   .level = LOG_DEBUG },
-    { .name = "emerg",   .level = LOG_EMERG },
-    { .name = "error",   .level = LOG_ERR },		/* DEPRECATED */
-    { .name = "info",    .level = LOG_INFO },
-    { .name = "notice",  .level = LOG_NOTICE },
-    { .name = "panic",   .level = LOG_EMERG },		/* DEPRECATED */
-    { .name = "warning", .level = LOG_WARNING }
-};
-
-static void LOG_parse(struct xt_option_call *cb)
-{
-	struct ipt_log_info *info = cb->data;
-
-	xtables_option_parse(cb);
-	switch (cb->entry->id) {
-	case O_LOG_PREFIX:
-		if (strchr(cb->arg, '\n') != NULL)
-			xtables_error(PARAMETER_PROBLEM,
-				   "Newlines not allowed in --log-prefix");
-		break;
-	case O_LOG_TCPSEQ:
-		info->logflags |= IPT_LOG_TCPSEQ;
-		break;
-	case O_LOG_TCPOPTS:
-		info->logflags |= IPT_LOG_TCPOPT;
-		break;
-	case O_LOG_IPOPTS:
-		info->logflags |= IPT_LOG_IPOPT;
-		break;
-	case O_LOG_UID:
-		info->logflags |= IPT_LOG_UID;
-		break;
-	case O_LOG_MAC:
-		info->logflags |= IPT_LOG_MACDECODE;
-		break;
-	}
-}
-
-static void LOG_print(const void *ip, const struct xt_entry_target *target,
-                      int numeric)
-{
-	const struct ipt_log_info *loginfo
-		= (const struct ipt_log_info *)target->data;
-	unsigned int i = 0;
-
-	printf(" LOG");
-	if (numeric)
-		printf(" flags %u level %u",
-		       loginfo->logflags, loginfo->level);
-	else {
-		for (i = 0; i < ARRAY_SIZE(ipt_log_names); ++i)
-			if (loginfo->level == ipt_log_names[i].level) {
-				printf(" level %s", ipt_log_names[i].name);
-				break;
-			}
-		if (i == ARRAY_SIZE(ipt_log_names))
-			printf(" UNKNOWN level %u", loginfo->level);
-		if (loginfo->logflags & IPT_LOG_TCPSEQ)
-			printf(" tcp-sequence");
-		if (loginfo->logflags & IPT_LOG_TCPOPT)
-			printf(" tcp-options");
-		if (loginfo->logflags & IPT_LOG_IPOPT)
-			printf(" ip-options");
-		if (loginfo->logflags & IPT_LOG_UID)
-			printf(" uid");
-		if (loginfo->logflags & IPT_LOG_MACDECODE)
-			printf(" macdecode");
-		if (loginfo->logflags & ~(IPT_LOG_MASK))
-			printf(" unknown-flags");
-	}
-
-	if (strcmp(loginfo->prefix, "") != 0)
-		printf(" prefix \"%s\"", loginfo->prefix);
-}
-
-static void LOG_save(const void *ip, const struct xt_entry_target *target)
-{
-	const struct ipt_log_info *loginfo
-		= (const struct ipt_log_info *)target->data;
-
-	if (strcmp(loginfo->prefix, "") != 0) {
-		printf(" --log-prefix");
-		xtables_save_string(loginfo->prefix);
-	}
-
-	if (loginfo->level != LOG_DEFAULT_LEVEL)
-		printf(" --log-level %d", loginfo->level);
-
-	if (loginfo->logflags & IPT_LOG_TCPSEQ)
-		printf(" --log-tcp-sequence");
-	if (loginfo->logflags & IPT_LOG_TCPOPT)
-		printf(" --log-tcp-options");
-	if (loginfo->logflags & IPT_LOG_IPOPT)
-		printf(" --log-ip-options");
-	if (loginfo->logflags & IPT_LOG_UID)
-		printf(" --log-uid");
-	if (loginfo->logflags & IPT_LOG_MACDECODE)
-		printf(" --log-macdecode");
-}
-
-static struct xtables_target log_tg_reg = {
-	.name          = "LOG",
-	.version       = XTABLES_VERSION,
-	.family        = NFPROTO_IPV4,
-	.size          = XT_ALIGN(sizeof(struct ipt_log_info)),
-	.userspacesize = XT_ALIGN(sizeof(struct ipt_log_info)),
-	.help          = LOG_help,
-	.init          = LOG_init,
-	.print         = LOG_print,
-	.save          = LOG_save,
-	.x6_parse      = LOG_parse,
-	.x6_options    = LOG_opts,
-};
-
-void _init(void)
-{
-	xtables_register_target(&log_tg_reg);
-}
diff --git a/extensions/libipt_LOG.man b/extensions/libipt_LOG.man
deleted file mode 100644
index 47c35e0..0000000
--- a/extensions/libipt_LOG.man
+++ /dev/null
@@ -1,31 +0,0 @@
-Turn on kernel logging of matching packets.  When this option is set
-for a rule, the Linux kernel will print some information on all
-matching packets (like most IP header fields) via the kernel log
-(where it can be read with
-.I dmesg
-or 
-.IR syslogd (8)).
-This is a "non-terminating target", i.e. rule traversal continues at
-the next rule.  So if you want to LOG the packets you refuse, use two
-separate rules with the same matching criteria, first using target LOG
-then DROP (or REJECT).
-.TP
-\fB\-\-log\-level\fP \fIlevel\fP
-Level of logging (numeric or see \fIsyslog.conf\fP(5)).
-.TP
-\fB\-\-log\-prefix\fP \fIprefix\fP
-Prefix log messages with the specified prefix; up to 29 letters long,
-and useful for distinguishing messages in the logs.
-.TP
-\fB\-\-log\-tcp\-sequence\fP
-Log TCP sequence numbers. This is a security risk if the log is
-readable by users.
-.TP
-\fB\-\-log\-tcp\-options\fP
-Log options from the TCP packet header.
-.TP
-\fB\-\-log\-ip\-options\fP
-Log options from the IP packet header.
-.TP
-\fB\-\-log\-uid\fP
-Log the userid of the process which generated the packet.
diff --git a/extensions/libxt_LOG.c b/extensions/libxt_LOG.c
new file mode 100644
index 0000000..a4c11b6
--- /dev/null
+++ b/extensions/libxt_LOG.c
@@ -0,0 +1,201 @@
+#include <stdio.h>
+#include <string.h>
+#include <syslog.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_LOG.h>
+
+#define LOG_DEFAULT_LEVEL LOG_WARNING
+
+#ifndef XT_LOG_UID /* Old kernel */
+#define XT_LOG_UID	0x08	/* Log UID owning local socket */
+#undef  XT_LOG_MASK
+#define XT_LOG_MASK	0x0f
+#endif
+
+enum {
+	O_LOG_LEVEL = 0,
+	O_LOG_PREFIX,
+	O_LOG_TCPSEQ,
+	O_LOG_TCPOPTS,
+	O_LOG_IPOPTS,
+	O_LOG_UID,
+	O_LOG_MAC,
+};
+
+static void LOG_help(void)
+{
+	printf(
+"LOG target options:\n"
+" --log-level level		Level of logging (numeric or see syslog.conf)\n"
+" --log-prefix prefix		Prefix log messages with this prefix.\n\n"
+" --log-tcp-sequence		Log TCP sequence numbers.\n\n"
+" --log-tcp-options		Log TCP options.\n\n"
+" --log-ip-options		Log IP options.\n\n"
+" --log-uid			Log UID owning the local socket.\n\n"
+" --log-macdecode		Decode MAC addresses and protocol.\n\n");
+}
+
+#define s struct xt_log_info
+static const struct xt_option_entry LOG_opts[] = {
+	{.name = "log-level", .id = O_LOG_LEVEL, .type = XTTYPE_SYSLOGLEVEL,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, level)},
+	{.name = "log-prefix", .id = O_LOG_PREFIX, .type = XTTYPE_STRING,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, prefix), .min = 1},
+	{.name = "log-tcp-sequence", .id = O_LOG_TCPSEQ, .type = XTTYPE_NONE},
+	{.name = "log-tcp-options", .id = O_LOG_TCPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-ip-options", .id = O_LOG_IPOPTS, .type = XTTYPE_NONE},
+	{.name = "log-uid", .id = O_LOG_UID, .type = XTTYPE_NONE},
+	{.name = "log-macdecode", .id = O_LOG_MAC, .type = XTTYPE_NONE},
+	XTOPT_TABLEEND,
+};
+#undef s
+
+static void LOG_init(struct xt_entry_target *t)
+{
+	struct xt_log_info *loginfo = (struct xt_log_info *)t->data;
+
+	loginfo->level = LOG_DEFAULT_LEVEL;
+
+}
+
+struct ipt_log_names {
+	const char *name;
+	unsigned int level;
+};
+
+static const struct ipt_log_names ipt_log_names[]
+= { { .name = "alert",   .level = LOG_ALERT },
+    { .name = "crit",    .level = LOG_CRIT },
+    { .name = "debug",   .level = LOG_DEBUG },
+    { .name = "emerg",   .level = LOG_EMERG },
+    { .name = "error",   .level = LOG_ERR },		/* DEPRECATED */
+    { .name = "info",    .level = LOG_INFO },
+    { .name = "notice",  .level = LOG_NOTICE },
+    { .name = "panic",   .level = LOG_EMERG },		/* DEPRECATED */
+    { .name = "warning", .level = LOG_WARNING }
+};
+
+static void LOG_parse(struct xt_option_call *cb)
+{
+	struct xt_log_info *info = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_LOG_PREFIX:
+		if (strchr(cb->arg, '\n') != NULL)
+			xtables_error(PARAMETER_PROBLEM,
+				   "Newlines not allowed in --log-prefix");
+		break;
+	case O_LOG_TCPSEQ:
+		info->logflags |= XT_LOG_TCPSEQ;
+		break;
+	case O_LOG_TCPOPTS:
+		info->logflags |= XT_LOG_TCPOPT;
+		break;
+	case O_LOG_IPOPTS:
+		info->logflags |= XT_LOG_IPOPT;
+		break;
+	case O_LOG_UID:
+		info->logflags |= XT_LOG_UID;
+		break;
+	case O_LOG_MAC:
+		info->logflags |= XT_LOG_MACDECODE;
+		break;
+	}
+}
+
+static void LOG_print(const void *ip, const struct xt_entry_target *target,
+                      int numeric)
+{
+	const struct xt_log_info *loginfo
+		= (const struct xt_log_info *)target->data;
+	unsigned int i = 0;
+
+	printf(" LOG");
+	if (numeric)
+		printf(" flags %u level %u",
+		       loginfo->logflags, loginfo->level);
+	else {
+		for (i = 0; i < ARRAY_SIZE(ipt_log_names); ++i)
+			if (loginfo->level == ipt_log_names[i].level) {
+				printf(" level %s", ipt_log_names[i].name);
+				break;
+			}
+		if (i == ARRAY_SIZE(ipt_log_names))
+			printf(" UNKNOWN level %u", loginfo->level);
+		if (loginfo->logflags & XT_LOG_TCPSEQ)
+			printf(" tcp-sequence");
+		if (loginfo->logflags & XT_LOG_TCPOPT)
+			printf(" tcp-options");
+		if (loginfo->logflags & XT_LOG_IPOPT)
+			printf(" ip-options");
+		if (loginfo->logflags & XT_LOG_UID)
+			printf(" uid");
+		if (loginfo->logflags & XT_LOG_MACDECODE)
+			printf(" macdecode");
+		if (loginfo->logflags & ~(XT_LOG_MASK))
+			printf(" unknown-flags");
+	}
+
+	if (strcmp(loginfo->prefix, "") != 0)
+		printf(" prefix \"%s\"", loginfo->prefix);
+}
+
+static void LOG_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_log_info *loginfo
+		= (const struct xt_log_info *)target->data;
+
+	if (strcmp(loginfo->prefix, "") != 0) {
+		printf(" --log-prefix");
+		xtables_save_string(loginfo->prefix);
+	}
+
+	if (loginfo->level != LOG_DEFAULT_LEVEL)
+		printf(" --log-level %d", loginfo->level);
+
+	if (loginfo->logflags & XT_LOG_TCPSEQ)
+		printf(" --log-tcp-sequence");
+	if (loginfo->logflags & XT_LOG_TCPOPT)
+		printf(" --log-tcp-options");
+	if (loginfo->logflags & XT_LOG_IPOPT)
+		printf(" --log-ip-options");
+	if (loginfo->logflags & XT_LOG_UID)
+		printf(" --log-uid");
+	if (loginfo->logflags & XT_LOG_MACDECODE)
+		printf(" --log-macdecode");
+}
+
+static struct xtables_target log_tg_regs[] = {
+	{
+		.name          = "LOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct xt_log_info)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_log_info)),
+		.help          = LOG_help,
+		.init          = LOG_init,
+		.print         = LOG_print,
+		.save          = LOG_save,
+		.x6_parse      = LOG_parse,
+		.x6_options    = LOG_opts,
+	},
+	{
+		.name          = "LOG",
+		.version       = XTABLES_VERSION,
+		.family        = NFPROTO_IPV6,
+		.size          = XT_ALIGN(sizeof(struct xt_log_info)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_log_info)),
+		.help          = LOG_help,
+		.init          = LOG_init,
+		.print         = LOG_print,
+		.save          = LOG_save,
+		.x6_parse      = LOG_parse,
+		.x6_options    = LOG_opts,
+	},
+};
+
+void _init(void)
+{
+	xtables_register_targets(log_tg_regs, ARRAY_SIZE(log_tg_regs));
+}
diff --git a/extensions/libxt_LOG.man b/extensions/libxt_LOG.man
new file mode 100644
index 0000000..47c35e0
--- /dev/null
+++ b/extensions/libxt_LOG.man
@@ -0,0 +1,31 @@
+Turn on kernel logging of matching packets.  When this option is set
+for a rule, the Linux kernel will print some information on all
+matching packets (like most IP header fields) via the kernel log
+(where it can be read with
+.I dmesg
+or 
+.IR syslogd (8)).
+This is a "non-terminating target", i.e. rule traversal continues at
+the next rule.  So if you want to LOG the packets you refuse, use two
+separate rules with the same matching criteria, first using target LOG
+then DROP (or REJECT).
+.TP
+\fB\-\-log\-level\fP \fIlevel\fP
+Level of logging (numeric or see \fIsyslog.conf\fP(5)).
+.TP
+\fB\-\-log\-prefix\fP \fIprefix\fP
+Prefix log messages with the specified prefix; up to 29 letters long,
+and useful for distinguishing messages in the logs.
+.TP
+\fB\-\-log\-tcp\-sequence\fP
+Log TCP sequence numbers. This is a security risk if the log is
+readable by users.
+.TP
+\fB\-\-log\-tcp\-options\fP
+Log options from the TCP packet header.
+.TP
+\fB\-\-log\-ip\-options\fP
+Log options from the IP packet header.
+.TP
+\fB\-\-log\-uid\fP
+Log the userid of the process which generated the packet.
diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
new file mode 100644
index 0000000..cac0790
--- /dev/null
+++ b/include/linux/netfilter/xt_LOG.h
@@ -0,0 +1,19 @@
+#ifndef _XT_LOG_H
+#define _XT_LOG_H
+
+/* make sure not to change this without changing nf_log.h:NF_LOG_* (!) */
+#define XT_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
+#define XT_LOG_TCPOPT		0x02	/* Log TCP options */
+#define XT_LOG_IPOPT		0x04	/* Log IP options */
+#define XT_LOG_UID		0x08	/* Log UID owning local socket */
+#define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
+#define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
+#define XT_LOG_MASK		0x2f
+
+struct xt_log_info {
+	unsigned char level;
+	unsigned char logflags;
+	char prefix[30];
+};
+
+#endif /* _XT_LOG_H */
-- 
1.7.7.3
