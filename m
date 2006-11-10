From: Thomas Graf <tgraf@suug.ch>
Subject: [IPROUTE2] Add rule notification support to ip monitor
Date: Fri, 10 Nov 2006 12:27:10 +0100
Message-ID: <20061110112710.GG8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5603 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1424390AbWKJL0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 06:26:50 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Index: iproute2.git/ip/ip_common.h
===================================================================
--- iproute2.git.orig/ip/ip_common.h	2006-11-10 12:22:46.000000000 +0100
+++ iproute2.git/ip/ip_common.h	2006-11-10 12:23:06.000000000 +0100
@@ -20,6 +20,8 @@
 		       struct nlmsghdr *n, void *arg);
 extern int print_prefix(const struct sockaddr_nl *who,
 			struct nlmsghdr *n, void *arg);
+extern int print_rule(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n, void *arg);
 extern int do_ipaddr(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
 extern int do_iprule(int argc, char **argv);
Index: iproute2.git/ip/ipmonitor.c
===================================================================
--- iproute2.git.orig/ip/ipmonitor.c	2006-11-10 12:21:00.000000000 +0100
+++ iproute2.git/ip/ipmonitor.c	2006-11-10 12:23:47.000000000 +0100
@@ -62,6 +62,10 @@
 		print_prefix(who, n, arg);
 		return 0;
 	}
+	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
+		print_rule(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type == 15) {
 		char *tstr;
 		time_t secs = ((__u32*)NLMSG_DATA(n))[0];
Index: iproute2.git/ip/iprule.c
===================================================================
--- iproute2.git.orig/ip/iprule.c	2006-11-10 12:21:55.000000000 +0100
+++ iproute2.git/ip/iprule.c	2006-11-10 12:24:46.000000000 +0100
@@ -46,8 +46,7 @@
 	exit(-1);
 }
 
-static int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n,
-		      void *arg)
+int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 	struct rtmsg *r = NLMSG_DATA(n);
@@ -58,7 +57,7 @@
 	char abuf[256];
 	SPRINT_BUF(b1);
 
-	if (n->nlmsg_type != RTM_NEWRULE)
+	if (n->nlmsg_type != RTM_NEWRULE && n->nlmsg_type != RTM_DELRULE)
 		return 0;
 
 	len -= NLMSG_LENGTH(sizeof(*r));
@@ -76,6 +75,9 @@
 	else if (r->rtm_family == AF_IPX)
 		host_len = 80;
 
+	if (n->nlmsg_type == RTM_DELRULE)
+		fprintf(fp, "Deleted ");
+
 	if (tb[RTA_PRIORITY])
 		fprintf(fp, "%u:\t", *(unsigned*)RTA_DATA(tb[RTA_PRIORITY]));
 	else
