From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip monitor: Allow to filter events by dev
Date: Mon, 20 Oct 2014 12:25:17 +0300
Message-ID: <1413797117-29532-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33748 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaJTJeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 05:34:14 -0400
Received: by mail-lb0-f180.google.com with SMTP id n15so3560713lbi.11
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 02:34:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 'dev' option to allow filtering events by device.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ip_common.h        | 13 ++++++++-----
 ip/ipaddress.c        |  5 +++--
 ip/ipmonitor.c        | 20 +++++++++++++++-----
 ip/ipmroute.c         |  5 +++--
 ip/ipneigh.c          |  5 +++--
 ip/ipnetconf.c        |  5 +++--
 ip/iproute.c          |  9 ++++++---
 man/man8/ip-monitor.8 |  9 +++++++++
 8 files changed, 50 insertions(+), 21 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 8351463..2fb3aa6 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -13,14 +13,17 @@ extern int print_ntable(const struct sockaddr_nl *who,
 			struct nlmsghdr *n, void *arg);
 extern int ipaddr_list(int argc, char **argv);
 extern int ipaddr_list_link(int argc, char **argv);
+void ipaddr_get_vf_rate(int, int *, int *, int);
 extern int iproute_monitor(int argc, char **argv);
 extern void iplink_usage(void) __attribute__((noreturn));
-extern void iproute_reset_filter(void);
-extern void ipmroute_reset_filter(void);
-void ipaddr_get_vf_rate(int, int *, int *, int);
-extern void ipaddr_reset_filter(int);
-extern void ipneigh_reset_filter(void);
+
+extern void iproute_reset_filter(int ifindex);
+extern void ipmroute_reset_filter(int ifindex);
+extern void ipaddr_reset_filter(int oneline, int ifindex);
+extern void ipneigh_reset_filter(int ifindex);
 extern void ipntable_reset_filter(void);
+extern void ipnetconf_reset_filter(int ifindex);
+
 extern int print_route(const struct sockaddr_nl *who,
 		       struct nlmsghdr *n, void *arg);
 extern int print_mroute(const struct sockaddr_nl *who,
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 45729d8..6708c2c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1135,7 +1135,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	char *filter_dev = NULL;
 	int no_link = 0;
 
-	ipaddr_reset_filter(oneline);
+	ipaddr_reset_filter(oneline, 0);
 	filter.showqueue = 1;
 
 	if (filter.family == AF_UNSPEC)
@@ -1380,10 +1380,11 @@ int ipaddr_list_link(int argc, char **argv)
 	return ipaddr_list_flush_or_save(argc, argv, IPADD_LIST);
 }
 
-void ipaddr_reset_filter(int oneline)
+void ipaddr_reset_filter(int oneline, int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
 	filter.oneline = oneline;
+	filter.ifindex = ifindex;
 }
 
 static int default_scope(inet_prefix *lcl)
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index b7b2d98..4cc75f4 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -29,7 +29,8 @@ int prefix_banner;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ] [ label ]\n");
+	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]"
+			"[ label ] [dev DEVICE]\n");
 	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
 	fprintf(stderr, "                 neigh | netconf\n");
 	fprintf(stderr, "FILE := file FILENAME\n");
@@ -162,12 +163,9 @@ int do_ipmonitor(int argc, char **argv)
 	int lprefix=0;
 	int lneigh=0;
 	int lnetconf=0;
+	int ifindex=0;
 
 	rtnl_close(&rth);
-	ipaddr_reset_filter(1);
-	iproute_reset_filter();
-	ipmroute_reset_filter();
-	ipneigh_reset_filter();
 
 	while (argc > 0) {
 		if (matches(*argv, "file") == 0) {
@@ -201,6 +199,12 @@ int do_ipmonitor(int argc, char **argv)
 			prefix_banner=1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
+		} else if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Device does not exist\n", *argv);
 		} else {
 			fprintf(stderr, "Argument \"%s\" is unknown, try \"ip monitor help\".\n", *argv);
 			exit(-1);
@@ -208,6 +212,12 @@ int do_ipmonitor(int argc, char **argv)
 		argc--;	argv++;
 	}
 
+	ipaddr_reset_filter(1, ifindex);
+	iproute_reset_filter(ifindex);
+	ipmroute_reset_filter(ifindex);
+	ipneigh_reset_filter(ifindex);
+	ipnetconf_reset_filter(ifindex);
+
 	if (llink)
 		groups |= nl_mgrp(RTNLGRP_LINK);
 	if (laddr) {
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index be93a98..b4ed9f1 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -174,11 +174,12 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-void ipmroute_reset_filter(void)
+void ipmroute_reset_filter(int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
 	filter.mdst.bitlen = -1;
 	filter.msrc.bitlen = -1;
+	filter.iif = ifindex;
 }
 
 static int mroute_list(int argc, char **argv)
@@ -186,7 +187,7 @@ static int mroute_list(int argc, char **argv)
 	char *id = NULL;
 	int family;
 
-	ipmroute_reset_filter();
+	ipmroute_reset_filter(0);
 	if (preferred_family == AF_UNSPEC)
 		family = AF_INET;
 	else
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 71a4100..6be79e1 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -313,10 +313,11 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-void ipneigh_reset_filter(void)
+void ipneigh_reset_filter(int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
 	filter.state = ~0;
+	filter.index = ifindex;
 }
 
 static int do_show_or_flush(int argc, char **argv, int flush)
@@ -325,7 +326,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 	int state_given = 0;
 	struct ndmsg ndm = { 0 };
 
-	ipneigh_reset_filter();
+	ipneigh_reset_filter(0);
 
 	if (!filter.family)
 		filter.family = preferred_family;
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 0e44cc8..aa31ead 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -123,9 +123,10 @@ int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-static void ipnetconf_reset_filter(void)
+void ipnetconf_reset_filter(int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
+	filter.ifindex = ifindex;
 }
 
 static int do_show(int argc, char **argv)
@@ -136,7 +137,7 @@ static int do_show(int argc, char **argv)
 		char			buf[1024];
 	} req;
 
-	ipnetconf_reset_filter();
+	ipnetconf_reset_filter(0);
 	filter.family = preferred_family;
 	if (filter.family == AF_UNSPEC)
 		filter.family = AF_INET;
diff --git a/ip/iproute.c b/ip/iproute.c
index d77b1e3..c9cf5d6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1137,7 +1137,7 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	} else
 		filter_fn = print_route;
 
-	iproute_reset_filter();
+	iproute_reset_filter(0);
 	filter.tb = RT_TABLE_MAIN;
 
 	if ((action == IPROUTE_FLUSH) && argc <= 0) {
@@ -1385,7 +1385,7 @@ static int iproute_get(int argc, char **argv)
 
 	memset(&req, 0, sizeof(req));
 
-	iproute_reset_filter();
+	iproute_reset_filter(0);
 	filter.cloned = 2;
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
@@ -1590,11 +1590,14 @@ static int iproute_showdump(void)
 	exit(rtnl_from_file(stdin, &show_handler, NULL));
 }
 
-void iproute_reset_filter(void)
+void iproute_reset_filter(int ifindex)
 {
 	memset(&filter, 0, sizeof(filter));
 	filter.mdst.bitlen = -1;
 	filter.msrc.bitlen = -1;
+	filter.oif = ifindex;
+	if (filter.oif > 0)
+		filter.oifmask = -1;
 }
 
 int do_iproute(int argc, char **argv)
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index b6e8d1d..68e83f1 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -11,6 +11,8 @@ ip-monitor, rtmon \- state monitoring
 .BR  "monitor" " [ " all " |"
 .IR OBJECT-LIST " ] ["
 .BI file " FILENAME "
+] [
+.BI dev " DEVICE "
 ]
 .sp
 
@@ -26,6 +28,8 @@ command is the first in the command line and then the object list follows:
 .BR "ip monitor" " [ " all " |"
 .IR OBJECT-LIST " ] ["
 .BI file " FILENAME "
+] [
+.BI dev " DEVICE "
 ]
 
 .I OBJECT-LIST
@@ -69,6 +73,11 @@ at any time.
 It prepends the history with the state snapshot dumped at the moment
 of starting.
 
+.P
+If the
+.BI dev
+option is given, the program prints only events related to this device.
+
 .SH SEE ALSO
 .br
 .BR ip (8)
-- 
2.1.0
