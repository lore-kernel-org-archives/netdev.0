From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 1/2] TProxy: added IPv6 support for socket match
Date: Fri, 28 Aug 2009 07:56:39 +0200
Message-ID: <1253548039.12519.15.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch also adds userspace support for the --transparent mode
of matching, which the kernel already supports, but the iptables userspace
doesn't.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 extensions/libxt_socket.c           |  103 ++++++++++++++++++++++++++++++++---
 extensions/libxt_socket.man         |    6 ++-
 include/linux/netfilter/xt_socket.h |   12 ++++
 3 files changed, 112 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/netfilter/xt_socket.h

diff --git a/extensions/libxt_socket.c b/extensions/libxt_socket.c
index 1490473..b1e2a4c 100644
--- a/extensions/libxt_socket.c
+++ b/extensions/libxt_socket.c
@@ -1,19 +1,106 @@
 /*
  * Shared library add-on to iptables to add early socket matching support.
  *
- * Copyright (C) 2007 BalaBit IT Ltd.
+ * Copyright (C) 2007, 2009 BalaBit IT Ltd.
  */
+#include <stdio.h>
+#include <getopt.h>
 #include <xtables.h>
+#include <linux/netfilter/xt_socket.h>
 
-static struct xtables_match socket_mt_reg = {
-	.name	       = "socket",
-	.version       = XTABLES_VERSION,
-	.family	       = NFPROTO_IPV4,
-	.size	       = XT_ALIGN(0),
-	.userspacesize = XT_ALIGN(0),
+static void socket_mt_help_v0(void)
+{
+	printf("socket match has no options.\n\n");
+}
+
+static void socket_mt_help_v1(void)
+{
+	printf("socket match options:\n"
+"--transparent      Matches only if the socket's transparent option is set\n");
+}
+
+static const struct option socket_opts_v1[] = {
+	{ "transparent", 0, NULL, '1' },
+	{ }
+};
+
+static int socket_mt_parse_v0(int c, char **argv, int invert,
+			      unsigned int *flags, const void *entry,
+			      struct xt_entry_match **match)
+{
+	return 0;
+}
+
+static int socket_mt_parse_v1(int c, char **argv, int invert,
+			      unsigned int *flags, const void *entry,
+			      struct xt_entry_match **match)
+{
+	struct xt_socket_match_info1 *info = (void *) (*match)->data;
+
+	switch (c) {
+	case '1':
+		if (*flags)
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can't specify multiple --transparent");
+		info->transparent = 1;
+		*flags = 1;
+		break;
+	default:
+		return 0;
+	}
+	return 1;
+}
+
+static void socket_mt_check(unsigned int flags)
+{
+}
+
+static void socket_mt_print_v1(const void *ip,
+			       const struct xt_entry_match *match,
+			       int numeric)
+{
+	const struct xt_socket_match_info1 *info = (const void *)match->data;
+	printf("socket ");
+	if (info->transparent)
+		printf("transparent ");
+}
+
+static void socket_mt_save_v1(const void *ip,
+			      const struct xt_entry_match *match)
+{
+	const struct xt_socket_match_info1 *info = (const void *)match->data;
+
+	if (info->transparent)
+		printf("--transparent ");
+}
+
+static struct xtables_match socket_matches[] = {
+        {
+		.name		= "socket",
+		.revision	= 0,
+		.version	= XTABLES_VERSION,
+		.family		= NFPROTO_IPV4,
+		.parse		= socket_mt_parse_v0,
+		.final_check	= socket_mt_check,
+		.help		= socket_mt_help_v0,
+	},
+	{
+		.name		= "socket",
+		.version	= XTABLES_VERSION,
+		.revision	= 1,
+		.family		= NFPROTO_UNSPEC,
+		.size		= XT_ALIGN(sizeof(struct xt_socket_match_info1)),
+		.userspacesize	= XT_ALIGN(sizeof(struct xt_socket_match_info1)),
+		.parse		= socket_mt_parse_v1,
+		.print		= socket_mt_print_v1,
+		.save		= socket_mt_save_v1,
+		.final_check	= socket_mt_check,
+		.help		= socket_mt_help_v1,
+		.extra_opts	= socket_opts_v1,
+	}
 };
 
 void _init(void)
 {
-	xtables_register_match(&socket_mt_reg);
+	xtables_register_matches(socket_matches, ARRAY_SIZE(socket_matches));
 }
diff --git a/extensions/libxt_socket.man b/extensions/libxt_socket.man
index 50c8854..edc9d75 100644
--- a/extensions/libxt_socket.man
+++ b/extensions/libxt_socket.man
@@ -1,2 +1,6 @@
 This matches if an open socket can be found by doing a socket lookup on the
-packet.
+packet which doesn\'t listen on the \'any\' IP address (0.0.0.0).
+.TP
+.BI "\-\-transparent"
+Enables additional check, that the actual socket's transparent socket option
+has to be set.
diff --git a/include/linux/netfilter/xt_socket.h b/include/linux/netfilter/xt_socket.h
new file mode 100644
index 0000000..6f475b8
--- /dev/null
+++ b/include/linux/netfilter/xt_socket.h
@@ -0,0 +1,12 @@
+#ifndef _XT_SOCKET_H
+#define _XT_SOCKET_H
+
+enum {
+	XT_SOCKET_TRANSPARENT = 1 << 0,
+};
+
+struct xt_socket_mtinfo1 {
+	__u8 flags;
+};
+
+#endif /* _XT_SOCKET_H */
-- 
1.6.0.4

