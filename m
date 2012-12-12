From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] iproute2: add support to monitor mdb entries too
Date: Wed, 12 Dec 2012 16:23:10 +0800
Message-ID: <1355300590-2390-4-git-send-email-amwang@redhat.com>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8005 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab2LLIXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 03:23:36 -0500
In-Reply-To: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch implements `bridge monitor mdb`.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 bridge/br_common.h        |    2 ++
 bridge/mdb.c              |    4 ++--
 bridge/monitor.c          |   14 ++++++++++++++
 include/linux/rtnetlink.h |    2 ++
 4 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 892fb76..10f6ce9 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -3,6 +3,8 @@ extern int print_linkinfo(const struct sockaddr_nl *who,
 			  void *arg);
 extern int print_fdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
+extern int print_mdb(const struct sockaddr_nl *who,
+		     struct nlmsghdr *n, void *arg);
 
 extern int do_fdb(int argc, char **argv);
 extern int do_mdb(int argc, char **argv);
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 4d8a896..121ce9c 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -82,8 +82,8 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int len = n->nlmsg_len;
 	struct rtattr * tb[MDBA_MAX+1];
 
-	if (n->nlmsg_type != RTM_GETMDB) {
-		fprintf(stderr, "Not RTM_GETMDB: %08x %08x %08x\n",
+	if (n->nlmsg_type != RTM_GETMDB && n->nlmsg_type != RTM_NEWMDB && n->nlmsg_type != RTM_DELMDB) {
+		fprintf(stderr, "Not RTM_GETMDB, RTM_NEWMDB or RTM_DELMDB: %08x %08x %08x\n",
 			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
 
 		return 0;
diff --git a/bridge/monitor.c b/bridge/monitor.c
index 2f60655..44e14d8 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -68,6 +68,12 @@ int accept_msg(const struct sockaddr_nl *who,
 			fprintf(fp, "[NEIGH]");
 		return print_fdb(who, n, arg);
 
+	case RTM_NEWMDB:
+	case RTM_DELMDB:
+		if (prefix_banner)
+			fprintf(fp, "[MDB]");
+		return print_mdb(who, n, arg);
+
 	case 15:
 		return show_mark(fp, n);
 
@@ -84,6 +90,7 @@ int do_monitor(int argc, char **argv)
 	unsigned groups = ~RTMGRP_TC;
 	int llink=0;
 	int lneigh=0;
+	int lmdb=0;
 
 	rtnl_close(&rth);
 
@@ -97,6 +104,9 @@ int do_monitor(int argc, char **argv)
 		} else if (matches(*argv, "fdb") == 0) {
 			lneigh = 1;
 			groups = 0;
+		} else if (matches(*argv, "mdb") == 0) {
+			lmdb = 1;
+			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
 			prefix_banner=1;
@@ -116,6 +126,10 @@ int do_monitor(int argc, char **argv)
 		groups |= nl_mgrp(RTNLGRP_NEIGH);
 	}
 
+	if (lmdb) {
+		groups |= nl_mgrp(RTNLGRP_MDB);
+	}
+
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3ea85dc..87452b4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -609,6 +609,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV4_NETCONF	RTNLGRP_IPV4_NETCONF
 	RTNLGRP_IPV6_NETCONF,
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
+	RTNLGRP_MDB,
+#define RTNLGRP_MDB		RTNLGRP_MDB
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
-- 
1.7.7.6
