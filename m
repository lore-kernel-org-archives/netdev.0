From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/2] Use one func to print timestamp from nlmsg
Date: Tue, 13 Jan 2015 20:14:24 +0200
Message-ID: <1421172864-20853-3-git-send-email-vadim4j@gmail.com>
References: <1421172864-20853-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35129 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbAMSZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:25:00 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so4016037lbv.11
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:24:58 -0800 (PST)
In-Reply-To: <1421172864-20853-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/monitor.c | 14 ++------------
 include/utils.h  |  2 ++
 ip/ipmonitor.c   |  7 +------
 lib/utils.c      | 10 ++++++++++
 4 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/bridge/monitor.c b/bridge/monitor.c
index f00e0a6..9e1ed48 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -35,17 +35,6 @@ static void usage(void)
 	exit(-1);
 }
 
-static int show_mark(FILE *fp, const struct nlmsghdr *n)
-{
-	char *tstr;
-	time_t secs = ((__u32*)NLMSG_DATA(n))[0];
-	long usecs = ((__u32*)NLMSG_DATA(n))[1];
-	tstr = asctime(localtime(&secs));
-	tstr[strlen(tstr)-1] = 0;
-	fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
-	return 0;
-}
-
 static int accept_msg(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg)
 {
@@ -75,7 +64,8 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return print_mdb(who, n, arg);
 
 	case NLMSG_TSTAMP:
-		return show_mark(fp, n);
+		print_nlmsg_timestamp(fp, n);
+		return 0;
 
 	default:
 		return 0;
diff --git a/include/utils.h b/include/utils.h
index eecbc39..e1fe7cf 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -148,6 +148,7 @@ static inline __u32 nl_mgrp(__u32 group)
 
 
 int print_timestamp(FILE *fp);
+void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
@@ -160,4 +161,5 @@ struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
+
 #endif /* __UTILS_H__ */
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index f40daac..5ec8f41 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -126,12 +126,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return 0;
 	}
 	if (n->nlmsg_type == NLMSG_TSTAMP) {
-		char *tstr;
-		time_t secs = ((__u32*)NLMSG_DATA(n))[0];
-		long usecs = ((__u32*)NLMSG_DATA(n))[1];
-		tstr = asctime(localtime(&secs));
-		tstr[strlen(tstr)-1] = 0;
-		fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
+		print_nlmsg_timestamp(fp, n);
 		return 0;
 	}
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
diff --git a/lib/utils.c b/lib/utils.c
index 64915f3..f65ceaa 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -868,3 +868,13 @@ int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6)
 	else
 		return inet_pton(AF_INET, src, dst);
 }
+
+void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n)
+{
+	char *tstr;
+	time_t secs = ((__u32*)NLMSG_DATA(n))[0];
+	long usecs = ((__u32*)NLMSG_DATA(n))[1];
+	tstr = asctime(localtime(&secs));
+	tstr[strlen(tstr)-1] = 0;
+	fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
+}
-- 
2.1.3
