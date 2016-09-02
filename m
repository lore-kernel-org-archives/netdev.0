From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 3/6] ip xfrm state: add save/restore
Date: Fri,  2 Sep 2016 12:02:23 +0300
Message-ID: <1472806946-16575-4-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26240 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752507AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds save and restore commands to "ip xfrm state"
similar to commit 2f4e171f7df2 and commit f4ff11e3e298 for
"ip rule" and "ip route" respectively.

The feature is useful in checkpoint/restore for container
migration.

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/xfrm_state.c    | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 man/man8/ip-xfrm.8 |  8 ++++++++
 2 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 0357a43..56d9f22 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -31,6 +31,7 @@
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
+#include <errno.h>
 
 /* #define NLMSG_DELETEALL_BUF_SIZE (4096-512) */
 #define NLMSG_DELETEALL_BUF_SIZE 8192
@@ -65,6 +66,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "Usage: ip xfrm state { save | restore }\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM-PROTO ]\n");
 	fprintf(stderr, "Usage: ip xfrm state count\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM-PROTO ] [ spi SPI ]\n");
@@ -1073,7 +1075,9 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
+static __u32 state_dump_magic = 0x71706987;
+
+static int xfrm_state_list_deleteall_or_save(int argc, char **argv, int deleteall, int save)
 {
 	char *idp = NULL;
 	struct rtnl_handle rth;
@@ -1171,6 +1175,13 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 		}
 
 	} else {
+		rtnl_filter_t rtnl_filter = xfrm_state_print;
+		if (save) {
+			if (dump_write_magic(state_dump_magic))
+				return -1;
+			rtnl_filter = save_nlmsg;
+		}
+
 		struct xfrm_address_filter addrfilter = {
 			.saddr = filter.xsinfo.saddr,
 			.daddr = filter.xsinfo.id.daddr,
@@ -1199,7 +1210,7 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 			exit(1);
 		}
 
-		if (rtnl_dump_filter(&rth, xfrm_state_print, stdout) < 0) {
+		if (rtnl_dump_filter(&rth, rtnl_filter, stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
@@ -1210,6 +1221,35 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 	exit(0);
 }
 
+static int restore_handler(const struct sockaddr_nl *nl,
+			   struct rtnl_ctrl_data *ctrl,
+			   struct nlmsghdr *n, void *arg)
+{
+	struct rtnl_handle *rth = (struct rtnl_handle *)arg;
+	int ret;
+
+	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+
+	ret = rtnl_talk(rth, n, n, sizeof(*n));
+	if ((ret < 0) && (errno == EEXIST))
+		ret = 0;
+
+	return ret;
+}
+
+static int xfrm_state_restore(void)
+{
+	struct rtnl_handle rth;
+
+	if (dump_check_magic(state_dump_magic))
+		exit(-1);
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	exit(rtnl_from_file(stdin, &restore_handler, (void *)&rth));
+}
+
 static int print_sadinfo(struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE *)arg;
@@ -1338,7 +1378,7 @@ static int xfrm_state_flush(int argc, char **argv)
 int do_xfrm_state(int argc, char **argv)
 {
 	if (argc < 1)
-		return xfrm_state_list_or_deleteall(0, NULL, 0);
+		return xfrm_state_list_deleteall_or_save(0, NULL, 0, 0);
 
 	if (matches(*argv, "add") == 0)
 		return xfrm_state_modify(XFRM_MSG_NEWSA, 0,
@@ -1351,10 +1391,14 @@ int do_xfrm_state(int argc, char **argv)
 	if (matches(*argv, "delete") == 0)
 		return xfrm_state_get_or_delete(argc-1, argv+1, 1);
 	if (matches(*argv, "deleteall") == 0 || matches(*argv, "delall") == 0)
-		return xfrm_state_list_or_deleteall(argc-1, argv+1, 1);
+		return xfrm_state_list_deleteall_or_save(argc-1, argv+1, 1, 0);
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
-		return xfrm_state_list_or_deleteall(argc-1, argv+1, 0);
+		return xfrm_state_list_deleteall_or_save(argc-1, argv+1, 0, 0);
+	if (matches(*argv, "save") == 0)
+		return xfrm_state_list_deleteall_or_save(argc-1, argv+1, 0, 1);
+	if (matches(*argv, "restore") == 0)
+		return xfrm_state_restore();
 	if (matches(*argv, "get") == 0)
 		return xfrm_state_get_or_delete(argc-1, argv+1, 0);
 	if (matches(*argv, "flush") == 0)
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 11f7104..803ac3f 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -104,6 +104,12 @@ ip-xfrm \- transform configuration
 .BR "ip xfrm state count"
 
 .ti -8
+.BR "ip xfrm state save"
+
+.ti -8
+.BR "ip xfrm state restore"
+
+.ti -8
 .IR ID " :="
 .RB "[ " src
 .IR ADDR " ]"
@@ -414,6 +420,8 @@ ip xfrm state deleteall	delete all existing state in xfrm
 ip xfrm state list	print out the list of existing state in xfrm
 ip xfrm state flush	flush all state in xfrm
 ip xfrm state count	count all existing state in xfrm
+ip xfrm state save	save xfrm states table information to stdout
+ip xfrm state restore	restore xfrm states table from stdin
 .TE
 
 .TP
-- 
2.5.5
