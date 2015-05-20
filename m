From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 5/6] ipmonitor: allows to monitor in several netns
Date: Wed, 20 May 2015 16:20:00 +0200
Message-ID: <1432131601-4641-6-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44045 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbbETOUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:11 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, it's now possible to listen in all netns that have an nsid
assigned into the netns where the socket is opened.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/libnetlink.h  |  4 ++++
 ip/ipmonitor.c        | 39 ++++++++++++++++++++++++++-------------
 lib/libnetlink.c      | 43 ++++++++++++++++++++++++++++++++++++++++++-
 man/man8/ip-monitor.8 | 17 +++++++++++++++++
 4 files changed, 89 insertions(+), 14 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 1b9c9255ce1d..bd9bde091abe 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -20,6 +20,8 @@ struct rtnl_handle
 	__u32			dump;
 	int			proto;
 	FILE		       *dump_fp;
+#define RTNL_HANDLE_F_LISTEN_ALL_NSID		0x01
+	int			flags;
 };
 
 extern int rcvbuf;
@@ -42,6 +44,7 @@ extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 	__attribute__((warn_unused_result));
 
 struct rtnl_ctrl_data {
+	int	nsid;
 };
 
 typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
@@ -125,6 +128,7 @@ static inline const char *rta_getattr_str(const struct rtattr *rta)
 	return (const char *)RTA_DATA(rta);
 }
 
+extern int rtnl_listen_all_nsid(struct rtnl_handle *);
 extern int rtnl_listen(struct rtnl_handle *, rtnl_listen_filter_t handler,
 		       void *jarg);
 extern int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index cae186d86153..8bcf8822b398 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -26,22 +26,30 @@
 
 static void usage(void) __attribute__((noreturn));
 int prefix_banner;
+int listen_all_nsid;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]"
-			"[ label ] [dev DEVICE]\n");
+	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ] "
+			"[ label ] [all-nsid] [dev DEVICE]\n");
 	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
 	fprintf(stderr, "                 neigh | netconf | rule | nsid\n");
 	fprintf(stderr, "FILE := file FILENAME\n");
 	exit(-1);
 }
 
-static void print_headers(FILE *fp, char *label)
+static void print_headers(FILE *fp, char *label, struct rtnl_ctrl_data *ctrl)
 {
 	if (timestamp)
 		print_timestamp(fp);
 
+	if (listen_all_nsid) {
+		if (ctrl == NULL || ctrl->nsid < 0)
+			fprintf(fp, "[nsid current]");
+		else
+			fprintf(fp, "[nsid %d]", ctrl->nsid);
+	}
+
 	if (prefix_banner)
 		fprintf(fp, "%s", label);
 }
@@ -66,11 +74,11 @@ static int accept_msg(const struct sockaddr_nl *who,
 
 		if (r->rtm_family == RTNL_FAMILY_IPMR ||
 		    r->rtm_family == RTNL_FAMILY_IP6MR) {
-			print_headers(fp, "[MROUTE]");
+			print_headers(fp, "[MROUTE]", ctrl);
 			print_mroute(who, n, arg);
 			return 0;
 		} else {
-			print_headers(fp, "[ROUTE]");
+			print_headers(fp, "[ROUTE]", ctrl);
 			print_route(who, n, arg);
 			return 0;
 		}
@@ -78,17 +86,17 @@ static int accept_msg(const struct sockaddr_nl *who,
 
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
-		print_headers(fp, "[LINK]");
+		print_headers(fp, "[LINK]", ctrl);
 		print_linkinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
-		print_headers(fp, "[ADDR]");
+		print_headers(fp, "[ADDR]", ctrl);
 		print_addrinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
-		print_headers(fp, "[ADDRLABEL]");
+		print_headers(fp, "[ADDRLABEL]", ctrl);
 		print_addrlabel(who, n, arg);
 		return 0;
 	}
@@ -101,22 +109,22 @@ static int accept_msg(const struct sockaddr_nl *who,
 				return 0;
 		}
 
-		print_headers(fp, "[NEIGH]");
+		print_headers(fp, "[NEIGH]", ctrl);
 		print_neigh(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWPREFIX) {
-		print_headers(fp, "[PREFIX]");
+		print_headers(fp, "[PREFIX]", ctrl);
 		print_prefix(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
-		print_headers(fp, "[RULE]");
+		print_headers(fp, "[RULE]", ctrl);
 		print_rule(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNETCONF) {
-		print_headers(fp, "[NETCONF]");
+		print_headers(fp, "[NETCONF]", ctrl);
 		print_netconf(who, ctrl, n, arg);
 		return 0;
 	}
@@ -125,7 +133,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNSID || n->nlmsg_type == RTM_DELNSID) {
-		print_headers(fp, "[NSID]");
+		print_headers(fp, "[NSID]", ctrl);
 		print_nsid(who, n, arg);
 		return 0;
 	}
@@ -178,6 +186,8 @@ int do_ipmonitor(int argc, char **argv)
 			file = *argv;
 		} else if (matches(*argv, "label") == 0) {
 			prefix_banner = 1;
+		} else if (matches(*argv, "all-nsid") == 0) {
+			listen_all_nsid = 1;
 		} else if (matches(*argv, "link") == 0) {
 			llink=1;
 			groups = 0;
@@ -284,6 +294,9 @@ int do_ipmonitor(int argc, char **argv)
 
 	if (rtnl_open(&rth, groups) < 0)
 		exit(1);
+	if (listen_all_nsid && rtnl_listen_all_nsid(&rth) < 0)
+		exit(1);
+
 	ll_init_map(&rth);
 	netns_map_init();
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 01b65cf806c0..424a5b6ffe8f 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -25,6 +25,10 @@
 
 #include "libnetlink.h"
 
+#ifndef SOL_NETLINK
+#define SOL_NETLINK 270
+#endif
+
 int rcvbuf = 1024 * 1024;
 
 void rtnl_close(struct rtnl_handle *rth)
@@ -418,6 +422,19 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 	}
 }
 
+int rtnl_listen_all_nsid(struct rtnl_handle *rth)
+{
+	unsigned int on = 1;
+
+	if (setsockopt(rth->fd, SOL_NETLINK, NETLINK_LISTEN_ALL_NSID, &on,
+		       sizeof(on)) < 0) {
+		perror("NETLINK_LISTEN_ALL_NSID");
+		return -1;
+	}
+	rth->flags |= RTNL_HANDLE_F_LISTEN_ALL_NSID;
+	return 0;
+}
+
 int rtnl_listen(struct rtnl_handle *rtnl,
 		rtnl_listen_filter_t handler,
 		void *jarg)
@@ -433,6 +450,12 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		.msg_iovlen = 1,
 	};
 	char   buf[16384];
+	char   cmsgbuf[BUFSIZ];
+
+	if (rtnl->flags & RTNL_HANDLE_F_LISTEN_ALL_NSID) {
+		msg.msg_control = &cmsgbuf;
+		msg.msg_controllen = sizeof(cmsgbuf);
+	}
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -441,6 +464,9 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 
 	iov.iov_base = buf;
 	while (1) {
+		struct rtnl_ctrl_data ctrl;
+		struct cmsghdr *cmsg;
+
 		iov.iov_len = sizeof(buf);
 		status = recvmsg(rtnl->fd, &msg, 0);
 
@@ -461,6 +487,21 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 			fprintf(stderr, "Sender address length == %d\n", msg.msg_namelen);
 			exit(1);
 		}
+
+		if (rtnl->flags & RTNL_HANDLE_F_LISTEN_ALL_NSID) {
+			memset(&ctrl, 0, sizeof(ctrl));
+			ctrl.nsid = -1;
+			for (cmsg = CMSG_FIRSTHDR(&msg); cmsg;
+			     cmsg = CMSG_NXTHDR(&msg, cmsg))
+				if (cmsg->cmsg_level == SOL_NETLINK &&
+				    cmsg->cmsg_type == NETLINK_LISTEN_ALL_NSID &&
+				    cmsg->cmsg_len == CMSG_LEN(sizeof(int))) {
+					int *data = (int *)CMSG_DATA(cmsg);
+
+					ctrl.nsid = *data;
+				}
+		}
+
 		for (h = (struct nlmsghdr*)buf; status >= sizeof(*h); ) {
 			int err;
 			int len = h->nlmsg_len;
@@ -475,7 +516,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 				exit(1);
 			}
 
-			err = handler(&nladdr, NULL, h, jarg);
+			err = handler(&nladdr, &ctrl, h, jarg);
 			if (err < 0)
 				return err;
 
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 3123b4014cc2..d2bd381a8c32 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -14,6 +14,8 @@ ip-monitor, rtmon \- state monitoring
 ] [
 .BI label
 ] [
+.BI all-nsid
+] [
 .BI dev " DEVICE "
 ]
 .sp
@@ -46,6 +48,8 @@ command is the first in the command line and then the object list follows:
 ] [
 .BI label
 ] [
+.BI all-nsid
+] [
 .BI dev " DEVICE "
 ]
 
@@ -76,6 +80,19 @@ show the family of the message. For example:
 
 .P
 If the
+.BI all-nsid
+option is set, the program listens to all network namespaces that have a
+nsid assigned into the network namespace were the program is running.
+A prefix is displayed to show the network namespace where the message
+originates. Example:
+.sp
+.in +2
+[nsid 0]10.16.0.112 dev eth0 lladdr 00:04:23:df:2f:d0 REACHABLE
+.in -2
+.sp
+
+.P
+If the
 .BI file
 option is given, the program does not listen on RTNETLINK,
 but opens the given file, and dumps its contents. The file
-- 
2.2.2
