From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 7/8] libnetlink: Add variant of rtnl_talk that does not display RTNETLINK answers error
Date: Sun, 11 Dec 2016 16:53:14 -0800
Message-ID: <1481503995-24825-8-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:32876 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754070AbcLLAx2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:28 -0500
Received: by mail-pg0-f45.google.com with SMTP id 3so29061697pgd.0
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:27 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iplink_vrf has 2 functions used to validate a user given device name is
a VRF device and to return the table id. If the user string is not a
device name ip commands with a vrf keyword show a confusing error
message: "RTNETLINK answers: No such device".

Add a variant of rtnl_talk that does not display the "RTNETLINK answers"
message and update iplink_vrf to use it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h |  3 +++
 ip/iplink_vrf.c      | 14 +++++++++++---
 lib/libnetlink.c     | 20 +++++++++++++++++---
 3 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 751ebf186dd4..bd0267dfcc02 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -81,6 +81,9 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
+int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+				   struct nlmsghdr *answer, size_t len)
+	__attribute__((warn_unused_result));
 int rtnl_send(struct rtnl_handle *rth, const void *buf, int)
 	__attribute__((warn_unused_result));
 int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int)
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index c101ed770f87..917630e85337 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -13,6 +13,7 @@
 #include <string.h>
 #include <sys/socket.h>
 #include <linux/if_link.h>
+#include <errno.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -126,8 +127,14 @@ __u32 ipvrf_get_table(const char *name)
 
 	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
-	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
-		return 0;
+	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n,
+					   &answer.n, sizeof(answer)) < 0) {
+		/* special case "default" vrf to be the main table */
+		if (errno == ENODEV && !strcmp(name, "default"))
+			rtnl_rttable_a2n(&tb_id, "main");
+
+		return tb_id;
+	}
 
 	ifi = NLMSG_DATA(&answer.n);
 	len = answer.n.nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
@@ -186,7 +193,8 @@ int name_is_vrf(const char *name)
 
 	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
-	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
+	if (rtnl_talk_suppress_rtnl_errmsg(&rth, &req.n,
+					   &answer.n, sizeof(answer)) < 0)
 		return 0;
 
 	ifi = NLMSG_DATA(&answer.n);
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index a5db168e50eb..9d7e89aebbd0 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -12,6 +12,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <stdbool.h>
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
@@ -397,8 +398,9 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 	return rtnl_dump_filter_l(rth, a);
 }
 
-int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-	      struct nlmsghdr *answer, size_t maxlen)
+static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+		       struct nlmsghdr *answer, size_t maxlen,
+		       bool show_rtnl_err)
 {
 	int status;
 	unsigned int seq;
@@ -485,7 +487,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					return 0;
 				}
 
-				if (rtnl->proto != NETLINK_SOCK_DIAG)
+				if (rtnl->proto != NETLINK_SOCK_DIAG && show_rtnl_err)
 					fprintf(stderr,
 						"RTNETLINK answers: %s\n",
 						strerror(-err->error));
@@ -517,6 +519,18 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	}
 }
 
+int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+	      struct nlmsghdr *answer, size_t maxlen)
+{
+	return __rtnl_talk(rtnl, n, answer, maxlen, true);
+}
+
+int rtnl_talk_suppress_rtnl_errmsg(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+				   struct nlmsghdr *answer, size_t maxlen)
+{
+	return __rtnl_talk(rtnl, n, answer, maxlen, false);
+}
+
 int rtnl_listen_all_nsid(struct rtnl_handle *rth)
 {
 	unsigned int on = 1;
-- 
2.1.4
