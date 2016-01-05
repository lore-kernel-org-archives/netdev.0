From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 2/2] tipc: add peer remove
	functionality
Date: Tue, 5 Jan 2016 10:57:40 +0100
Message-ID: <1451987860-17696-2-git-send-email-richard.alpe@ericsson.com>
References: <1451987860-17696-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1451987860-17696-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This enables a user to remove an offline peer from the kernel data
structures. This could for example be useful when deliberately scaling
in peer nodes in a cloud environment.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/tipc_netlink.h |  1 +
 man/man8/tipc-bearer.8       |  1 +
 man/man8/tipc-link.8         |  1 +
 man/man8/tipc-media.8        |  1 +
 man/man8/tipc-nametable.8    |  1 +
 man/man8/tipc-node.8         |  1 +
 man/man8/tipc-peer.8         | 52 +++++++++++++++++++++++++
 man/man8/tipc.8              |  1 +
 tipc/Makefile                |  2 +-
 tipc/peer.c                  | 93 ++++++++++++++++++++++++++++++++++++++++++++
 tipc/peer.h                  | 21 ++++++++++
 tipc/tipc.c                  |  3 ++
 12 files changed, 177 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tipc-peer.8
 create mode 100644 tipc/peer.c
 create mode 100644 tipc/peer.h

diff --git a/include/linux/tipc_netlink.h b/include/linux/tipc_netlink.h
index d4c8f14..25eb645 100644
--- a/include/linux/tipc_netlink.h
+++ b/include/linux/tipc_netlink.h
@@ -56,6 +56,7 @@ enum {
 	TIPC_NL_NET_GET,
 	TIPC_NL_NET_SET,
 	TIPC_NL_NAME_TABLE_GET,
+	TIPC_NL_PEER_REMOVE,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
index 50a1ed2..565ee01 100644
--- a/man/man8/tipc-bearer.8
+++ b/man/man8/tipc-bearer.8
@@ -218,6 +218,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-media (8),
 .BR tipc-nametable (8),
 .BR tipc-node (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/man/man8/tipc-link.8 b/man/man8/tipc-link.8
index 3be8c9a..2ee03a0 100644
--- a/man/man8/tipc-link.8
+++ b/man/man8/tipc-link.8
@@ -213,6 +213,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-bearer (8),
 .BR tipc-nametable (8),
 .BR tipc-node (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/man/man8/tipc-media.8 b/man/man8/tipc-media.8
index 6c6e2b1..4689cb3 100644
--- a/man/man8/tipc-media.8
+++ b/man/man8/tipc-media.8
@@ -74,6 +74,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-link (8),
 .BR tipc-nametable (8),
 .BR tipc-node (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/man/man8/tipc-nametable.8 b/man/man8/tipc-nametable.8
index d3397f9..4bcefe4 100644
--- a/man/man8/tipc-nametable.8
+++ b/man/man8/tipc-nametable.8
@@ -87,6 +87,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-link (8),
 .BR tipc-media (8),
 .BR tipc-node (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/man/man8/tipc-node.8 b/man/man8/tipc-node.8
index ef32ec7..a72a409 100644
--- a/man/man8/tipc-node.8
+++ b/man/man8/tipc-node.8
@@ -59,6 +59,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-link (8),
 .BR tipc-media (8),
 .BR tipc-nametable (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/man/man8/tipc-peer.8 b/man/man8/tipc-peer.8
new file mode 100644
index 0000000..430651f
--- /dev/null
+++ b/man/man8/tipc-peer.8
@@ -0,0 +1,52 @@
+.TH TIPC-PEER 8 "04 Dec 2015" "iproute2" "Linux"
+
+.\" For consistency, please keep padding right aligned.
+.\" For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-peer \- modify peer information
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+.B tipc peer remove address
+.IR ADDRESS
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc peer --help
+will show peer help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+.SH DESCRIPTION
+
+.SS Peer remove
+Remove an offline peer node from the local data structures. The peer is
+identified by its
+.B address
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-bearer (8),
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc.8 b/man/man8/tipc.8
index c116552..32943fa 100644
--- a/man/man8/tipc.8
+++ b/man/man8/tipc.8
@@ -87,6 +87,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR tipc-media (8),
 .BR tipc-nametable (8),
 .BR tipc-node (8),
+.BR tipc-peer (8),
 .BR tipc-socket (8)
 .br
 .SH REPORTING BUGS
diff --git a/tipc/Makefile b/tipc/Makefile
index bc5ecfd..f06dcb1 100644
--- a/tipc/Makefile
+++ b/tipc/Makefile
@@ -6,7 +6,7 @@ TIPCOBJ=bearer.o \
     media.o misc.o \
     msg.o nametable.o \
     node.o socket.o \
-    tipc.o
+    peer.o tipc.o
 
 include ../Config
 
diff --git a/tipc/peer.c b/tipc/peer.c
new file mode 100644
index 0000000..de0c73c
--- /dev/null
+++ b/tipc/peer.c
@@ -0,0 +1,93 @@
+/*
+ * peer.c	TIPC peer functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "misc.h"
+#include "peer.h"
+
+static int cmd_peer_rm_addr(struct nlmsghdr *nlh, const struct cmd *cmd,
+			    struct cmdl *cmdl, void *data)
+{
+	char *str;
+	uint32_t addr;
+	struct nlattr *nest;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if ((cmdl->argc != cmdl->optind + 1) || help_flag) {
+		fprintf(stderr, "Usage: %s peer remove address ADDRESS\n",
+			cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	str = shift_cmdl(cmdl);
+	addr = str2addr(str);
+	if (!addr)
+		return -1;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_PEER_REMOVE))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_NET);
+	mnl_attr_put_u32(nlh, TIPC_NLA_NET_ADDR, addr);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static void cmd_peer_rm_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s peer remove address ADDRESS\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_peer_rm(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "address",	cmd_peer_rm_addr,	cmd_peer_rm_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+void cmd_peer_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s peer COMMAND [ARGS] ...\n\n"
+		"COMMANDS\n"
+		" remove                - Remove an offline peer node\n",
+		cmdl->argv[0]);
+}
+
+int cmd_peer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data)
+{
+	const struct cmd cmds[] = {
+		{ "remove",	cmd_peer_rm,	cmd_peer_rm_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/peer.h b/tipc/peer.h
new file mode 100644
index 0000000..8972261
--- /dev/null
+++ b/tipc/peer.h
@@ -0,0 +1,21 @@
+/*
+ * peer.h	TIPC peer functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_PEER_H
+#define _TIPC_PEER_H
+
+extern int help_flag;
+
+int cmd_peer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data);
+void cmd_peer_help(struct cmdl *cmdl);
+
+#endif
diff --git a/tipc/tipc.c b/tipc/tipc.c
index 4439805..600d5e2 100644
--- a/tipc/tipc.c
+++ b/tipc/tipc.c
@@ -20,6 +20,7 @@
 #include "socket.h"
 #include "media.h"
 #include "node.h"
+#include "peer.h"
 #include "cmdl.h"
 
 int help_flag;
@@ -39,6 +40,7 @@ static void about(struct cmdl *cmdl)
 		" media                 - Show or modify media\n"
 		" nametable             - Show nametable\n"
 		" node                  - Show or modify node related parameters\n"
+		" peer                  - Peer related operations\n"
 		" socket                - Show sockets\n",
 		cmdl->argv[0]);
 }
@@ -59,6 +61,7 @@ int main(int argc, char *argv[])
 		{ "media",	cmd_media,	cmd_media_help},
 		{ "nametable",	cmd_nametable,	cmd_nametable_help},
 		{ "node",	cmd_node,	cmd_node_help},
+		{ "peer",	cmd_peer,	cmd_peer_help},
 		{ "socket",	cmd_socket,	cmd_socket_help},
 		{ NULL }
 	};
-- 
2.1.4


------------------------------------------------------------------------------
