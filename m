From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE]: Introduce tc monitor
Date: Sun, 02 Jul 2006 13:20:48 -0400
Message-ID: <1151860849.5093.259.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-H1KGIFx3dhGMcuZus1XI"
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:52203 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751194AbWGBRVE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 13:21:04 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fx5d6-0000D4-5h
	for netdev@vger.kernel.org; Sun, 02 Jul 2006 13:21:08 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-H1KGIFx3dhGMcuZus1XI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Speaking of events reminded me of this.. Managed to get some quality
time, so heres a patch against current iproute2 git that adds something
useful.

Stephen, please apply.
 
cheers,
jamal

--=-H1KGIFx3dhGMcuZus1XI
Content-Disposition: attachment; filename=tcmon_p
Content-Type: text/plain; name=tcmon_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

This patch adds ability to monitor tc events similar to ipmonitor.
User runs "tc monitor" (without quotes) and watches events of
addition, deletion and updates from qdiscs, classes, filters and
actions as they happen.

---
commit 00f2ad46f0040769f0d4e4541fe0731f20164664
tree 0b2f8dc690d5fd90269a4c4fc34dbf7fc005f4bc
parent 8f8a36487119a3cd1afe86a9649704aca088567b
author Jamal Hadi Salim <hadi@jzny2.(none)> Sun, 02 Jul 2006 13:12:51 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Sun, 02 Jul 2006 13:12:51 -0400

 tc/Makefile     |    4 +-
 tc/m_action.c   |    8 ++--
 tc/tc.c         |    5 ++-
 tc/tc_class.c   |    2 +
 tc/tc_common.h  |    5 +++
 tc/tc_filter.c  |    2 +
 tc/tc_monitor.c |  110 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_qdisc.c   |    2 +
 8 files changed, 128 insertions(+), 10 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index 9d618ff..7640c58 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -1,6 +1,6 @@
 TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o \
-       m_police.o m_estimator.o m_action.o m_ematch.o \
-       emp_ematch.yacc.o emp_ematch.lex.o
+       tc_monitor.o m_police.o m_estimator.o m_action.o \
+       m_ematch.o emp_ematch.yacc.o emp_ematch.lex.o
 
 include ../Config
 
diff --git a/tc/m_action.c b/tc/m_action.c
index 2d2b0ed..a7efe72 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -293,7 +293,7 @@ tc_print_action(FILE * f, const struct r
 	return 0;
 }
 
-static int do_print_action(const struct sockaddr_nl *who,
+int print_action(const struct sockaddr_nl *who,
 			   struct nlmsghdr *n,
 			   void *arg)
 {
@@ -313,7 +313,7 @@ static int do_print_action(const struct 
 
 	if (NULL == tb[TCA_ACT_TAB]) {
 		if (n->nlmsg_type != RTM_GETACTION)
-			fprintf(stderr, "do_print_action: NULL kind\n");
+			fprintf(stderr, "print_action: NULL kind\n");
 		return -1;
 	}     
 
@@ -434,7 +434,7 @@ int tc_action_gd(int cmd, unsigned flags
 		return 1;
 	}
 
-	if (ans && do_print_action(NULL, &req.n, (void*)stdout) < 0) {
+	if (ans && print_action(NULL, &req.n, (void*)stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return 1;
 	}
@@ -536,7 +536,7 @@ #endif
 			perror("Cannot send dump request");
 			return 1;
 		}
-		ret = rtnl_dump_filter(&rth, do_print_action, stdout, NULL, NULL);
+		ret = rtnl_dump_filter(&rth, print_action, stdout, NULL, NULL);
 	}
 
 	if (event == RTM_DELACTION) { 
diff --git a/tc/tc.c b/tc/tc.c
index fa36ee0..789f6f6 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -181,7 +181,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }\n"
 			"       tc [-force] -batch file\n"
-	                "where  OBJECT := { qdisc | class | filter | action }\n"
+	                "where  OBJECT := { qdisc | class | filter | action | monitor }\n"
 	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -b[atch] [file] }\n");
 }
 
@@ -199,6 +199,9 @@ static int do_cmd(int argc, char **argv)
 	if (matches(*argv, "actions") == 0)
 		return do_action(argc-1, argv+1);
 
+	if (matches(*argv, "monitor") == 0)
+		return do_tcmonitor(argc-1, argv+1);
+
 	if (matches(*argv, "help") == 0) {
 		usage();
 		return 0;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 894caa1..049584e 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -147,7 +147,7 @@ int tc_class_modify(int cmd, unsigned fl
 int filter_ifindex;
 __u32 filter_qdisc;
 
-static int print_class(const struct sockaddr_nl *who, 
+int print_class(const struct sockaddr_nl *who, 
 		       struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
diff --git a/tc/tc_common.h b/tc/tc_common.h
index 7e13582..5bfc43e 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -6,6 +6,11 @@ extern int do_qdisc(int argc, char **arg
 extern int do_class(int argc, char **argv);
 extern int do_filter(int argc, char **argv);
 extern int do_action(int argc, char **argv);
+extern int do_tcmonitor(int argc, char **argv);
+extern int print_action(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+ extern int print_class(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 
 struct tc_estimator;
 extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator *est);
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index f6de840..3341b13 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -176,7 +176,7 @@ static int filter_ifindex;
 static __u32 filter_prio;
 static __u32 filter_protocol;
 
-static int print_filter(const struct sockaddr_nl *who,
+int print_filter(const struct sockaddr_nl *who,
 			struct nlmsghdr *n, 
 			void *arg)
 {
diff --git a/tc/tc_monitor.c b/tc/tc_monitor.c
new file mode 100644
index 0000000..1af6cf0
--- /dev/null
+++ b/tc/tc_monitor.c
@@ -0,0 +1,110 @@
+/*
+ * tc_monitor.c		"tc monitor".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jamal Hadi Salim
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <time.h>
+#include "rt_names.h"
+#include "utils.h"
+#include "tc_util.h"
+#include "tc_common.h"
+
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: tc monitor\n");
+	exit(-1);
+}
+
+
+int accept_tcmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+
+	if (n->nlmsg_type == RTM_NEWTFILTER || n->nlmsg_type == RTM_DELTFILTER) {
+		print_filter(who, n, arg);
+		return 0;
+	}
+	if (n->nlmsg_type == RTM_NEWTCLASS || n->nlmsg_type == RTM_DELTCLASS) {
+		print_class(who, n, arg);
+		return 0;
+	}
+	if (n->nlmsg_type == RTM_NEWQDISC || n->nlmsg_type == RTM_DELQDISC) {
+		print_qdisc(who, n, arg);
+		return 0;
+	}
+	if (n->nlmsg_type == RTM_GETACTION || n->nlmsg_type == RTM_NEWACTION ||
+	    n->nlmsg_type == RTM_DELACTION) {
+		print_action(who, n, arg);
+		return 0;
+	}
+	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
+	    n->nlmsg_type != NLMSG_DONE) {
+		fprintf(fp, "Unknown message: length %08d type %08x flags %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+	}
+	return 0;
+}
+
+int do_tcmonitor(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	char *file = NULL;
+	unsigned groups = RTMGRP_TC;
+
+	while (argc > 0) {
+		if (matches(*argv, "file") == 0) {
+			NEXT_ARG();
+			file = *argv;
+		} else {
+			if (matches(*argv, "help") == 0) {
+				usage();
+			} else {
+				fprintf(stderr, "Argument \"%s\" is unknown, try \"tc monitor help\".\n", *argv);
+				exit(-1);
+			}
+		}
+		argc--;	argv++;
+	}
+
+	if (file) {
+		FILE *fp;
+		fp = fopen(file, "r");
+		if (fp == NULL) {
+			perror("Cannot fopen");
+			exit(-1);
+		}
+		return rtnl_from_file(fp, accept_tcmsg, (void*)stdout);
+	}
+
+	if (rtnl_open(&rth, groups) < 0)
+		exit(1);
+
+	ll_init_map(&rth);
+
+	if (rtnl_listen(&rth, accept_tcmsg, (void*)stdout) < 0) {
+		rtnl_close(&rth);
+		exit(2);
+	}
+
+	rtnl_close(&rth);
+	exit(0);
+}
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index e9174ab..76c78f2 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -162,7 +162,7 @@ #endif
 
 static int filter_ifindex;
 
-static int print_qdisc(const struct sockaddr_nl *who, 
+int print_qdisc(const struct sockaddr_nl *who, 
 		       struct nlmsghdr *n, 
 		       void *arg)
 {

--=-H1KGIFx3dhGMcuZus1XI--

