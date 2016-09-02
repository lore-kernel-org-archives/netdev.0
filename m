From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 4/6] ip xfrm policy: add save/restore
Date: Fri,  2 Sep 2016 12:02:24 +0300
Message-ID: <1472806946-16575-5-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15531 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752478AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds save and restore commands to "ip xfrm policy"
similar to commit 2f4e171f7df2 and commit f4ff11e3e298 for
"ip rule" and "ip route" respectively. Mind that we can not
restore socket policies these way, so silently skip them.

The feature is useful in checkpoint/restore for container
migration.

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/xfrm_policy.c   | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 man/man8/ip-xfrm.8 |  8 ++++++
 2 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index cc9c0f1..2f1ce4b 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -32,6 +32,7 @@
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
+#include <errno.h>
 
 /* #define NLMSG_DELETEALL_BUF_SIZE (4096-512) */
 #define NLMSG_DELETEALL_BUF_SIZE 8192
@@ -61,6 +62,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ SELECTOR ] [ dir DIR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { save | restore }\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy count\n");
 	fprintf(stderr, "Usage: ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]\n");
@@ -754,7 +756,9 @@ static int xfrm_policy_keep(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
+static __u32 policy_dump_magic = 0x71706988;
+
+static int xfrm_policy_list_or_deleteall_or_save(int argc, char **argv, int deleteall, int save)
 {
 	char *selp = NULL;
 	struct rtnl_handle rth;
@@ -877,6 +881,13 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 			xb.nlmsg_count = 0;
 		}
 	} else {
+		rtnl_filter_t rtnl_filter = xfrm_policy_print;
+		if (save) {
+			if (dump_write_magic(policy_dump_magic))
+				return -1;
+			rtnl_filter = save_nlmsg;
+		}
+
 		struct {
 			struct nlmsghdr n;
 			char buf[NLMSG_BUF_SIZE];
@@ -892,7 +903,7 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 			exit(1);
 		}
 
-		if (rtnl_dump_filter(&rth, xfrm_policy_print, stdout) < 0) {
+		if (rtnl_dump_filter(&rth, rtnl_filter, stdout) < 0) {
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
@@ -903,6 +914,54 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 	exit(0);
 }
 
+static int restore_handler(const struct sockaddr_nl *nl,
+			   struct rtnl_ctrl_data *ctrl,
+			   struct nlmsghdr *n, void *arg)
+{
+	struct rtnl_handle *rth = (struct rtnl_handle *)arg;
+	int ret;
+	struct xfrm_userpolicy_info *xpinfo;
+	int len = n->nlmsg_len;
+
+	if (n->nlmsg_type != XFRM_MSG_NEWPOLICY) {
+		fprintf(stderr, "BUG: wrong nlmsg_type: %08x\n",
+			n->nlmsg_type);
+		return -1;
+	}
+
+	xpinfo = NLMSG_DATA(n);
+	len -= NLMSG_SPACE(sizeof(*xpinfo));
+
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	/* We can not restore socket policies here - skip them */
+	if (xpinfo->dir >= XFRM_POLICY_MAX)
+		return 0;
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
+static int xfrm_policy_restore(void)
+{
+	struct rtnl_handle rth;
+	if (dump_check_magic(policy_dump_magic))
+		exit(-1);
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	exit(rtnl_from_file(stdin, &restore_handler, (void *)&rth));
+}
+
 static int print_spdinfo(struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE *)arg;
@@ -1136,7 +1195,7 @@ static int xfrm_policy_flush(int argc, char **argv)
 int do_xfrm_policy(int argc, char **argv)
 {
 	if (argc < 1)
-		return xfrm_policy_list_or_deleteall(0, NULL, 0);
+		return xfrm_policy_list_or_deleteall_or_save(0, NULL, 0, 0);
 
 	if (matches(*argv, "add") == 0)
 		return xfrm_policy_modify(XFRM_MSG_NEWPOLICY, 0,
@@ -1147,10 +1206,14 @@ int do_xfrm_policy(int argc, char **argv)
 	if (matches(*argv, "delete") == 0)
 		return xfrm_policy_delete(argc-1, argv+1);
 	if (matches(*argv, "deleteall") == 0 || matches(*argv, "delall") == 0)
-		return xfrm_policy_list_or_deleteall(argc-1, argv+1, 1);
+		return xfrm_policy_list_or_deleteall_or_save(argc-1, argv+1, 1, 0);
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
-		return xfrm_policy_list_or_deleteall(argc-1, argv+1, 0);
+		return xfrm_policy_list_or_deleteall_or_save(argc-1, argv+1, 0, 0);
+	if (matches(*argv, "save") == 0)
+		return xfrm_policy_list_or_deleteall_or_save(argc-1, argv+1, 0, 1);
+	if (matches(*argv, "restore") == 0)
+		return xfrm_policy_restore();
 	if (matches(*argv, "get") == 0)
 		return xfrm_policy_get(argc-1, argv+1);
 	if (matches(*argv, "flush") == 0)
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 803ac3f..f5b8290 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -274,6 +274,12 @@ ip-xfrm \- transform configuration
 .B "ip xfrm policy count"
 
 .ti -8
+.BR "ip xfrm policy save"
+
+.ti -8
+.BR "ip xfrm policy restore"
+
+.ti -8
 .B "ip xfrm policy set"
 .RB "[ " hthresh4
 .IR LBITS " " RBITS " ]"
@@ -555,6 +561,8 @@ ip xfrm policy get	get an existing policy
 ip xfrm policy deleteall	delete all existing xfrm policies
 ip xfrm policy list	print out the list of xfrm policies
 ip xfrm policy flush	flush policies
+ip xfrm policy save	save xfrm policies table information to stdout
+ip xfrm policy restore	restore xfrm policies table from stdin
 .TE
 
 .TP
-- 
2.5.5
