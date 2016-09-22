From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 1/2] ip rule: merge ip rule flush and list, save together
Date: Thu, 22 Sep 2016 14:28:48 +0800
Message-ID: <1474525729-2845-2-git-send-email-liuhangbin@gmail.com>
References: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35474 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754482AbcIVG3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:29:18 -0400
Received: by mail-pf0-f195.google.com with SMTP id 6so3349952pfl.2
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 23:29:17 -0700 (PDT)
In-Reply-To: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iprule_flush() and iprule_list_or_save() both call function
rtnl_wilddump_request() and rtnl_dump_filter(). So merge them
together just like other files do.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iprule.c | 121 +++++++++++++++++++++++++++---------------------------------
 1 file changed, 54 insertions(+), 67 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 70562c5..e18505f 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -27,6 +27,12 @@
 #include "utils.h"
 #include "ip_common.h"
 
+enum list_action {
+	IPRULE_LIST,
+	IPRULE_FLUSH,
+	IPRULE_SAVE,
+};
+
 extern struct rtnl_handle rth;
 
 static void usage(void) __attribute__((noreturn));
@@ -243,24 +249,61 @@ static int save_rule(const struct sockaddr_nl *who,
 	return ret == n->nlmsg_len ? 0 : ret;
 }
 
-static int iprule_list_or_save(int argc, char **argv, int save)
+static int flush_rule(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		      void *arg)
+{
+	struct rtnl_handle rth2;
+	struct rtmsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr *tb[FRA_MAX+1];
+
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr(tb, FRA_MAX, RTM_RTA(r), len);
+
+	if (tb[FRA_PRIORITY]) {
+		n->nlmsg_type = RTM_DELRULE;
+		n->nlmsg_flags = NLM_F_REQUEST;
+
+		if (rtnl_open(&rth2, 0) < 0)
+			return -1;
+
+		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
+			return -2;
+
+		rtnl_close(&rth2);
+	}
+
+	return 0;
+}
+
+static int iprule_list_flush_or_save(int argc, char **argv, int action)
 {
-	rtnl_filter_t filter = print_rule;
+	rtnl_filter_t filter_fn;
 	int af = preferred_family;
 
 	if (af == AF_UNSPEC)
 		af = AF_INET;
 
 	if (argc > 0) {
-		fprintf(stderr, "\"ip rule %s\" does not take any arguments.\n",
-				save ? "save" : "show");
+		fprintf(stderr,
+			"\"ip rule list/flush/save\" does not take any arguments\n");
 		return -1;
 	}
 
-	if (save) {
+	switch (action) {
+	case IPRULE_SAVE:
 		if (save_rule_prep())
 			return -1;
-		filter = save_rule;
+		filter_fn = save_rule;
+		break;
+	case IPRULE_FLUSH:
+		filter_fn = flush_rule;
+		break;
+	default:
+		filter_fn = print_rule;
 	}
 
 	if (rtnl_wilddump_request(&rth, af, RTM_GETRULE) < 0) {
@@ -268,7 +311,7 @@ static int iprule_list_or_save(int argc, char **argv, int save)
 		return 1;
 	}
 
-	if (rtnl_dump_filter(&rth, filter, stdout) < 0) {
+	if (rtnl_dump_filter(&rth, filter_fn, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return 1;
 	}
@@ -511,72 +554,16 @@ static int iprule_modify(int cmd, int argc, char **argv)
 	return 0;
 }
 
-
-static int flush_rule(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
-{
-	struct rtnl_handle rth2;
-	struct rtmsg *r = NLMSG_DATA(n);
-	int len = n->nlmsg_len;
-	struct rtattr *tb[FRA_MAX+1];
-
-	len -= NLMSG_LENGTH(sizeof(*r));
-	if (len < 0)
-		return -1;
-
-	parse_rtattr(tb, FRA_MAX, RTM_RTA(r), len);
-
-	if (tb[FRA_PRIORITY]) {
-		n->nlmsg_type = RTM_DELRULE;
-		n->nlmsg_flags = NLM_F_REQUEST;
-
-		if (rtnl_open(&rth2, 0) < 0)
-			return -1;
-
-		if (rtnl_talk(&rth2, n, NULL, 0) < 0)
-			return -2;
-
-		rtnl_close(&rth2);
-	}
-
-	return 0;
-}
-
-static int iprule_flush(int argc, char **argv)
-{
-	int af = preferred_family;
-
-	if (af == AF_UNSPEC)
-		af = AF_INET;
-
-	if (argc > 0) {
-		fprintf(stderr, "\"ip rule flush\" does not allow arguments\n");
-		return -1;
-	}
-
-	if (rtnl_wilddump_request(&rth, af, RTM_GETRULE) < 0) {
-		perror("Cannot send dump request");
-		return 1;
-	}
-
-	if (rtnl_dump_filter(&rth, flush_rule, NULL) < 0) {
-		fprintf(stderr, "Flush terminated\n");
-		return 1;
-	}
-
-	return 0;
-}
-
 int do_iprule(int argc, char **argv)
 {
 	if (argc < 1) {
-		return iprule_list_or_save(0, NULL, 0);
+		return iprule_list_flush_or_save(0, NULL, IPRULE_LIST);
 	} else if (matches(argv[0], "list") == 0 ||
 		   matches(argv[0], "lst") == 0 ||
 		   matches(argv[0], "show") == 0) {
-		return iprule_list_or_save(argc-1, argv+1, 0);
+		return iprule_list_flush_or_save(argc-1, argv+1, IPRULE_LIST);
 	} else if (matches(argv[0], "save") == 0) {
-		return iprule_list_or_save(argc-1, argv+1, 1);
+		return iprule_list_flush_or_save(argc-1, argv+1, IPRULE_SAVE);
 	} else if (matches(argv[0], "restore") == 0) {
 		return iprule_restore();
 	} else if (matches(argv[0], "add") == 0) {
@@ -584,7 +571,7 @@ int do_iprule(int argc, char **argv)
 	} else if (matches(argv[0], "delete") == 0) {
 		return iprule_modify(RTM_DELRULE, argc-1, argv+1);
 	} else if (matches(argv[0], "flush") == 0) {
-		return iprule_flush(argc-1, argv+1);
+		return iprule_list_flush_or_save(argc-1, argv+1, IPRULE_FLUSH);
 	} else if (matches(argv[0], "help") == 0)
 		usage();
 
-- 
2.5.5
