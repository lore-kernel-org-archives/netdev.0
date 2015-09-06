From: Felix Kaiser <felix.kaiser@fxkr.net>
Subject: [PATCH] ip link/addr show: add empty line between interfaces
Date: Sun,  6 Sep 2015 13:01:09 +0200
Message-ID: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net>
Cc: Felix Kaiser <felix.kaiser@fxkr.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35415 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbIFLBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 07:01:46 -0400
Received: by wicge5 with SMTP id ge5so55901935wic.0
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2015 04:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves the readability of the output.

Signed-off-by: Felix Kaiser <felix.kaiser@fxkr.net>
---
 ip/ip_common.h |  3 ++-
 ip/ipaddress.c | 11 +++++++++--
 ip/iplink.c    |  2 +-
 ip/ipmonitor.c |  2 +-
 4 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index f74face..c39601d 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -1,7 +1,8 @@
 extern int get_operstate(const char *name);
 extern int print_linkinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
-			  void *arg);
+			  void *arg,
+			  int nitem);
 extern int print_linkinfo_brief(const struct sockaddr_nl *who,
 				struct nlmsghdr *n,
 				void *arg);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 2aa5fbf..8b696fd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -682,7 +682,7 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 }
 
 int print_linkinfo(const struct sockaddr_nl *who,
-		   struct nlmsghdr *n, void *arg)
+		   struct nlmsghdr *n, void *arg, int nitem)
 {
 	FILE *fp = (FILE*)arg;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
@@ -736,6 +736,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		}
 	}
 
+	if (nitem > 0) {
+		fprintf(fp, "\n"); // empty line
+	}
+
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
 
@@ -1638,6 +1642,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		ipaddr_filter(&linfo, &ainfo);
 	}
 
+	int nitem = 0;
 	for (l = linfo.head; l; l = l->next) {
 		int res = 0;
 		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
@@ -1649,12 +1654,14 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 								ainfo.head,
 								stdout);
 		} else if (no_link ||
-			 (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
+			 (res = print_linkinfo(NULL, &l->h, stdout, nitem)) >= 0) {
 			if (filter.family != AF_PACKET)
 				print_selected_addrinfo(ifi,
 							ainfo.head, stdout);
 			if (res > 0 && !do_link && show_stats)
 				print_link_stats(stdout, &l->h);
+			if (res > 0)
+				nitem++;
 		}
 	}
 	fflush(stdout);
diff --git a/ip/iplink.c b/ip/iplink.c
index 97f46cd..da4697c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -847,7 +847,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	if (brief)
 		print_linkinfo_brief(NULL, &answer.n, stdout);
 	else
-		print_linkinfo(NULL, &answer.n, stdout);
+		print_linkinfo(NULL, &answer.n, stdout, 0);
 
 	return 0;
 }
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 8bcf882..c95568e 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -87,7 +87,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
 		print_headers(fp, "[LINK]", ctrl);
-		print_linkinfo(who, n, arg);
+		print_linkinfo(who, n, arg, 0);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
-- 
2.4.3
