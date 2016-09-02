From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 2/6] ip: merge together all save_xxx to save_nlmsg
Date: Fri,  2 Sep 2016 12:02:22 +0300
Message-ID: <1472806946-16575-3-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30501 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752419AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

want to reuse them in xfrm state/policy save

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/ip_common.h |  2 ++
 ip/ipaddress.c | 14 --------------
 ip/iproute.c   | 23 +++++++++++++++--------
 ip/iprule.c    | 16 +---------------
 4 files changed, 18 insertions(+), 37 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 8e7a2c9..69e028d 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -69,6 +69,8 @@ static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 
 extern int dump_write_magic(__u32 dump_magic);
 extern int dump_check_magic(__u32 dump_magic);
+extern int save_nlmsg(const struct sockaddr_nl *who,
+		struct nlmsghdr *n, void *arg);
 
 extern struct rtnl_handle rth;
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 995813e..8b2051c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1261,20 +1261,6 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 static __u32 ipadd_dump_magic = 0x47361222;
 
-static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		       void *arg)
-{
-	int ret;
-
-	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
-	if ((ret > 0) && (ret != n->nlmsg_len)) {
-		fprintf(stderr, "Short write while saving nlmsg\n");
-		ret = -EIO;
-	}
-
-	return ret == n->nlmsg_len ? 0 : ret;
-}
-
 static int show_handler(const struct sockaddr_nl *nl,
 			struct rtnl_ctrl_data *ctrl,
 			struct nlmsghdr *n, void *arg)
diff --git a/ip/iproute.c b/ip/iproute.c
index 3c24250..4f29739 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1309,10 +1309,23 @@ static int iproute_flush_cache(void)
 
 static __u32 route_dump_magic = 0x45311224;
 
+int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		       void *arg)
+{
+	int ret;
+
+	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
+	if ((ret > 0) && (ret != n->nlmsg_len)) {
+		fprintf(stderr, "Short write while saving nlmsg\n");
+		ret = -EIO;
+	}
+
+	return ret == n->nlmsg_len ? 0 : ret;
+}
+
 static int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		      void *arg)
 {
-	int ret;
 	int len = n->nlmsg_len;
 	struct rtmsg *r = NLMSG_DATA(n);
 	struct rtattr *tb[RTA_MAX+1];
@@ -1325,13 +1338,7 @@ static int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	if (!filter_nlmsg(n, tb, host_len))
 		return 0;
 
-	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
-	if ((ret > 0) && (ret != n->nlmsg_len)) {
-		fprintf(stderr, "Short write while saving nlmsg\n");
-		ret = -EIO;
-	}
-
-	return ret == n->nlmsg_len ? 0 : ret;
+	return save_nlmsg(who, n, arg);
 }
 
 int dump_write_magic(__u32 dump_magic)
diff --git a/ip/iprule.c b/ip/iprule.c
index 7de5abc..3a92416 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -211,20 +211,6 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 static __u32 rule_dump_magic = 0x71706986;
 
-static int save_rule(const struct sockaddr_nl *who,
-		     struct nlmsghdr *n, void *arg)
-{
-	int ret;
-
-	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
-	if ((ret > 0) && (ret != n->nlmsg_len)) {
-		fprintf(stderr, "Short write while saving nlmsg\n");
-		ret = -EIO;
-	}
-
-	return ret == n->nlmsg_len ? 0 : ret;
-}
-
 static int iprule_list_or_save(int argc, char **argv, int save)
 {
 	rtnl_filter_t filter = print_rule;
@@ -242,7 +228,7 @@ static int iprule_list_or_save(int argc, char **argv, int save)
 	if (save) {
 		if (dump_write_magic(rule_dump_magic))
 			return -1;
-		filter = save_rule;
+		filter = save_nlmsg;
 	}
 
 	if (rtnl_wilddump_request(&rth, af, RTM_GETRULE) < 0) {
-- 
2.5.5
