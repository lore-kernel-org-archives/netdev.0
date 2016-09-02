From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 1/6] ip: merge together all save_xxx_preps and xxx_dump_check_magics
Date: Fri,  2 Sep 2016 12:02:21 +0300
Message-ID: <1472806946-16575-2-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30682 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752425AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

want to reuse them in xfrm state/policy save

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/ip_common.h |  3 +++
 ip/ipaddress.c | 43 +++----------------------------------------
 ip/iproute.c   | 18 +++++++++---------
 ip/iprule.c    | 42 ++----------------------------------------
 4 files changed, 17 insertions(+), 89 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 93ff5bc..8e7a2c9 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -67,6 +67,9 @@ static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 	return table;
 }
 
+extern int dump_write_magic(__u32 dump_magic);
+extern int dump_check_magic(__u32 dump_magic);
+
 extern struct rtnl_handle rth;
 
 #include <stdbool.h>
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 76bd7b3..995813e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1261,43 +1261,6 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 static __u32 ipadd_dump_magic = 0x47361222;
 
-static int ipadd_save_prep(void)
-{
-	int ret;
-
-	if (isatty(STDOUT_FILENO)) {
-		fprintf(stderr, "Not sending a binary stream to stdout\n");
-		return -1;
-	}
-
-	ret = write(STDOUT_FILENO, &ipadd_dump_magic, sizeof(ipadd_dump_magic));
-	if (ret != sizeof(ipadd_dump_magic)) {
-		fprintf(stderr, "Can't write magic to dump file\n");
-		return -1;
-	}
-
-	return 0;
-}
-
-static int ipadd_dump_check_magic(void)
-{
-	int ret;
-	__u32 magic = 0;
-
-	if (isatty(STDIN_FILENO)) {
-		fprintf(stderr, "Can't restore address dump from a terminal\n");
-		return -1;
-	}
-
-	ret = fread(&magic, sizeof(magic), 1, stdin);
-	if (magic != ipadd_dump_magic) {
-		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n", ret, magic);
-		return -1;
-	}
-
-	return 0;
-}
-
 static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		       void *arg)
 {
@@ -1325,7 +1288,7 @@ static int show_handler(const struct sockaddr_nl *nl,
 
 static int ipaddr_showdump(void)
 {
-	if (ipadd_dump_check_magic())
+	if (dump_check_magic(ipadd_dump_magic))
 		exit(-1);
 
 	exit(rtnl_from_file(stdin, &show_handler, NULL));
@@ -1350,7 +1313,7 @@ static int restore_handler(const struct sockaddr_nl *nl,
 
 static int ipaddr_restore(void)
 {
-	if (ipadd_dump_check_magic())
+	if (dump_check_magic(ipadd_dump_magic))
 		exit(-1);
 
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
@@ -1670,7 +1633,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		return ipaddr_flush();
 
 	if (action == IPADD_SAVE) {
-		if (ipadd_save_prep())
+		if (dump_write_magic(ipadd_dump_magic))
 			exit(1);
 
 		if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETADDR) < 0) {
diff --git a/ip/iproute.c b/ip/iproute.c
index 0bc0136..3c24250 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1334,7 +1334,7 @@ static int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return ret == n->nlmsg_len ? 0 : ret;
 }
 
-static int save_route_prep(void)
+int dump_write_magic(__u32 dump_magic)
 {
 	int ret;
 
@@ -1343,8 +1343,8 @@ static int save_route_prep(void)
 		return -1;
 	}
 
-	ret = write(STDOUT_FILENO, &route_dump_magic, sizeof(route_dump_magic));
-	if (ret != sizeof(route_dump_magic)) {
+	ret = write(STDOUT_FILENO, &dump_magic, sizeof(dump_magic));
+	if (ret != sizeof(dump_magic)) {
 		fprintf(stderr, "Can't write magic to dump file\n");
 		return -1;
 	}
@@ -1361,7 +1361,7 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	rtnl_filter_t filter_fn;
 
 	if (action == IPROUTE_SAVE) {
-		if (save_route_prep())
+		if (dump_write_magic(route_dump_magic))
 			return -1;
 
 		filter_fn = save_route;
@@ -1835,18 +1835,18 @@ static int restore_handler(const struct sockaddr_nl *nl,
 	return ret;
 }
 
-static int route_dump_check_magic(void)
+int dump_check_magic(__u32 dump_magic)
 {
 	int ret;
 	__u32 magic = 0;
 
 	if (isatty(STDIN_FILENO)) {
-		fprintf(stderr, "Can't restore route dump from a terminal\n");
+		fprintf(stderr, "Can't restore dump from a terminal\n");
 		return -1;
 	}
 
 	ret = fread(&magic, sizeof(magic), 1, stdin);
-	if (magic != route_dump_magic) {
+	if (magic != dump_magic) {
 		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n", ret, magic);
 		return -1;
 	}
@@ -1858,7 +1858,7 @@ static int iproute_restore(void)
 {
 	int pos, prio;
 
-	if (route_dump_check_magic())
+	if (dump_check_magic(route_dump_magic))
 		exit(-1);
 
 	pos = ftell(stdin);
@@ -1885,7 +1885,7 @@ static int show_handler(const struct sockaddr_nl *nl,
 
 static int iproute_showdump(void)
 {
-	if (route_dump_check_magic())
+	if (dump_check_magic(route_dump_magic))
 		exit(-1);
 
 	exit(rtnl_from_file(stdin, &show_handler, NULL));
diff --git a/ip/iprule.c b/ip/iprule.c
index 70562c5..7de5abc 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -211,24 +211,6 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 static __u32 rule_dump_magic = 0x71706986;
 
-static int save_rule_prep(void)
-{
-	int ret;
-
-	if (isatty(STDOUT_FILENO)) {
-		fprintf(stderr, "Not sending a binary stream to stdout\n");
-		return -1;
-	}
-
-	ret = write(STDOUT_FILENO, &rule_dump_magic, sizeof(rule_dump_magic));
-	if (ret != sizeof(rule_dump_magic)) {
-		fprintf(stderr, "Can't write magic to dump file\n");
-		return -1;
-	}
-
-	return 0;
-}
-
 static int save_rule(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg)
 {
@@ -258,7 +240,7 @@ static int iprule_list_or_save(int argc, char **argv, int save)
 	}
 
 	if (save) {
-		if (save_rule_prep())
+		if (dump_write_magic(rule_dump_magic))
 			return -1;
 		filter = save_rule;
 	}
@@ -276,26 +258,6 @@ static int iprule_list_or_save(int argc, char **argv, int save)
 	return 0;
 }
 
-static int rule_dump_check_magic(void)
-{
-	int ret;
-	__u32 magic = 0;
-
-	if (isatty(STDIN_FILENO)) {
-		fprintf(stderr, "Can't restore rule dump from a terminal\n");
-		return -1;
-	}
-
-	ret = fread(&magic, sizeof(magic), 1, stdin);
-	if (magic != rule_dump_magic) {
-		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n",
-			ret, magic);
-		return -1;
-	}
-
-	return 0;
-}
-
 static int restore_handler(const struct sockaddr_nl *nl,
 			   struct rtnl_ctrl_data *ctrl,
 			   struct nlmsghdr *n, void *arg)
@@ -316,7 +278,7 @@ static int restore_handler(const struct sockaddr_nl *nl,
 
 static int iprule_restore(void)
 {
-	if (rule_dump_check_magic())
+	if (dump_check_magic(rule_dump_magic))
 		exit(-1);
 
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
-- 
2.5.5
