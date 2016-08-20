From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2] ip: route: fix multicast route dumps
Date: Sat, 20 Aug 2016 14:53:10 +0200
Message-ID: <1471697590-24466-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: sashok@cumulusnetworks.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36904 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbcHTMxc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 08:53:32 -0400
Received: by mail-wm0-f54.google.com with SMTP id i5so77756505wmg.0
        for <netdev@vger.kernel.org>; Sat, 20 Aug 2016 05:53:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have multicast routes and do ip route show table all we'll get the
following output:
 ...
 multicast ???/32 from ???/32  table default  proto static  iif eth0
The "???" are because the rtm_family is set to RTNL_FAMILY_IPMR instead
(or RTNL_FAMILY_IP6MR for ipv6). Add a simple workaround that returns the
real family based on the rtm_type (always RTN_MULTICAST for ipmr routes)
and the rtm_family. Similar workaround is already used in ipmroute, and
we can use this helper there as well.

After the patch the output is:
multicast 239.10.10.10/32 from 0.0.0.0/32  table default  proto static  iif eth0

Also fix a minor whitespace error and switch to tabs.

Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/utils.h |  1 +
 ip/ipmroute.c   |  2 +-
 ip/iproute.c    | 12 +++++++-----
 lib/utils.c     |  9 +++++++++
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 82f1aa7de16a..1b4f939cbd8c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -249,5 +249,6 @@ int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 
 char *int_to_str(int val, char *buf);
 int get_guid(__u64 *guid, const char *arg);
+int get_real_family(int rtm_type, int rtm_family);
 
 #endif /* __UTILS_H__ */
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 5d6922a23ae6..133367a2388d 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -112,7 +112,7 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			return 0;
 	}
 
-	family = r->rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+	family = get_real_family(r->rtm_type, r->rtm_family);
 
 	if (n->nlmsg_type == RTM_DELROUTE)
 		fprintf(fp, "Deleted ");
diff --git a/ip/iproute.c b/ip/iproute.c
index 3da23af9fdff..6af55dab1526 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -311,7 +311,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[RTA_MAX+1];
-	int host_len;
+	int host_len, family;
 	__u32 table;
 
 	SPRINT_BUF(b1);
@@ -363,13 +363,14 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "%s ", rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
 
 	if (tb[RTA_DST]) {
+		family = get_real_family(r->rtm_type, r->rtm_family);
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "%s/%u ",
-			        rt_addr_n2a_rta(r->rtm_family, tb[RTA_DST]),
+				rt_addr_n2a_rta(family, tb[RTA_DST]),
 			        r->rtm_dst_len);
 		} else {
 			fprintf(fp, "%s ",
-			        format_host_rta(r->rtm_family, tb[RTA_DST]));
+				format_host_rta(family, tb[RTA_DST]));
 		}
 	} else if (r->rtm_dst_len) {
 		fprintf(fp, "0/%d ", r->rtm_dst_len);
@@ -377,13 +378,14 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "default ");
 	}
 	if (tb[RTA_SRC]) {
+		family = get_real_family(r->rtm_type, r->rtm_family);
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ",
-			        rt_addr_n2a_rta(r->rtm_family, tb[RTA_SRC]),
+				rt_addr_n2a_rta(family, tb[RTA_SRC]),
 			        r->rtm_src_len);
 		} else {
 			fprintf(fp, "from %s ",
-			        format_host_rta(r->rtm_family, tb[RTA_SRC]));
+				format_host_rta(family, tb[RTA_SRC]));
 		}
 	} else if (r->rtm_src_len) {
 		fprintf(fp, "from 0/%u ", r->rtm_src_len);
diff --git a/lib/utils.c b/lib/utils.c
index 966047460af1..9ada7737f14d 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1156,3 +1156,12 @@ int get_guid(__u64 *guid, const char *arg)
 
 	return 0;
 }
+
+/* This is a necessary workaround for multicast route dumps */
+int get_real_family(int rtm_type, int rtm_family)
+{
+	if (rtm_type != RTN_MULTICAST)
+		return rtm_family;
+
+	return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+}
-- 
2.1.4
