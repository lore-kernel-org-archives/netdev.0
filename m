From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 2/2] tc, clsact: add clsact frontend
Date: Tue, 12 Jan 2016 01:42:20 +0100
Message-ID: <2fb3141072df9e1b418b029feb702b4b4f025c70.1452558352.git.daniel@iogearbox.net>
References: <cover.1452558352.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59863 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762341AbcALAmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 19:42:25 -0500
In-Reply-To: <cover.1452558352.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452558352.git.daniel@iogearbox.net>
References: <cover.1452558352.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the tc part for the kernel commit 1f211a1b929c ("net, sched: add
clsact qdisc"). Quoting example usage from that commit description:

  Example, adding qdisc:

  # tc qdisc add dev foo clsact
  # tc qdisc show dev foo
  qdisc mq 0: root
  qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  qdisc clsact ffff: parent ffff:fff1

  Adding filters (deleting, etc works analogous by specifying ingress/egress):

  # tc filter add dev foo ingress bpf da obj bar.o sec ingress
  # tc filter add dev foo egress  bpf da obj bar.o sec egress
  # tc filter show dev foo ingress
  filter protocol all pref 49152 bpf
  filter protocol all pref 49152 bpf handle 0x1 bar.o:[ingress] direct-action
  # tc filter show dev foo egress
  filter protocol all pref 49152 bpf
  filter protocol all pref 49152 bpf handle 0x1 bar.o:[egress] direct-action

The ingress parent alias can also be used with ingress qdisc.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/Makefile    |  1 +
 tc/q_clsact.c  | 34 ++++++++++++++++++++++++++++++++++
 tc/tc_filter.c | 46 ++++++++++++++++++++++++++++++++++++++--------
 tc/tc_qdisc.c  | 21 +++++++++++++++------
 4 files changed, 88 insertions(+), 14 deletions(-)
 create mode 100644 tc/q_clsact.c

diff --git a/tc/Makefile b/tc/Makefile
index 56acbaa..f5bea87 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -64,6 +64,7 @@ TCMODULES += q_fq_codel.o
 TCMODULES += q_fq.o
 TCMODULES += q_pie.o
 TCMODULES += q_hhf.o
+TCMODULES += q_clsact.o
 TCMODULES += e_bpf.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
diff --git a/tc/q_clsact.c b/tc/q_clsact.c
new file mode 100644
index 0000000..0c05dbd
--- /dev/null
+++ b/tc/q_clsact.c
@@ -0,0 +1,34 @@
+#include <stdio.h>
+#include <string.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... clsact\n");
+}
+
+static int clsact_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			    struct nlmsghdr *n)
+{
+	if (argc > 0) {
+		fprintf(stderr, "What is \"%s\"?\n", *argv);
+		explain();
+		return -1;
+	}
+
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	return 0;
+}
+
+static int clsact_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	return 0;
+}
+
+struct qdisc_util clsact_qdisc_util = {
+	.id		= "clsact",
+	.parse_qopt	= clsact_parse_opt,
+	.print_qopt	= clsact_print_opt,
+};
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index ff03db8..1a1082b 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -26,25 +26,21 @@
 #include "tc_util.h"
 #include "tc_common.h"
 
-static void usage(void);
-
 static void usage(void)
 {
 	fprintf(stderr, "Usage: tc filter [ add | del | change | replace | show ] dev STRING\n");
 	fprintf(stderr, "       [ pref PRIO ] protocol PROTO\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
-	fprintf(stderr, "       [ root | classid CLASSID ] [ handle FILTERID ]\n");
-	fprintf(stderr, "       [ [ FILTER_TYPE ] [ help | OPTIONS ] ]\n");
+	fprintf(stderr, "       [ root | ingress | egress | parent CLASSID ]\n");
+	fprintf(stderr, "       [ handle FILTERID ] [ [ FILTER_TYPE ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "       tc filter show [ dev STRING ] [ root | parent CLASSID ]\n");
+	fprintf(stderr, "       tc filter show [ dev STRING ] [ root | ingress | egress | parent CLASSID ]\n");
 	fprintf(stderr, "Where:\n");
 	fprintf(stderr, "FILTER_TYPE := { rsvp | u32 | bpf | fw | route | etc. }\n");
 	fprintf(stderr, "FILTERID := ... format depends on classifier, see there\n");
 	fprintf(stderr, "OPTIONS := ... try tc filter add <desired FILTER_KIND> help\n");
-	return;
 }
 
-
 static int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 {
 	struct {
@@ -87,6 +83,20 @@ static int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 				return -1;
 			}
 			req.t.tcm_parent = TC_H_ROOT;
+		} else if (strcmp(*argv, "ingress") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"ingress\" is duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_MAKE(TC_H_CLSACT,
+						     TC_H_MIN_INGRESS);
+		} else if (strcmp(*argv, "egress") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"egress\" is duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_MAKE(TC_H_CLSACT,
+						     TC_H_MIN_EGRESS);
 		} else if (strcmp(*argv, "parent") == 0) {
 			__u32 handle;
 			NEXT_ARG();
@@ -220,11 +230,16 @@ int print_filter(const struct sockaddr_nl *who,
 	if (!filter_parent || filter_parent != t->tcm_parent) {
 		if (t->tcm_parent == TC_H_ROOT)
 			fprintf(fp, "root ");
+		else if (t->tcm_parent == TC_H_MAKE(TC_H_CLSACT, TC_H_MIN_INGRESS))
+			fprintf(fp, "ingress ");
+		else if (t->tcm_parent == TC_H_MAKE(TC_H_CLSACT, TC_H_MIN_EGRESS))
+			fprintf(fp, "egress ");
 		else {
 			print_tc_classid(abuf, sizeof(abuf), t->tcm_parent);
 			fprintf(fp, "parent %s ", abuf);
 		}
 	}
+
 	if (t->tcm_info) {
 		f_proto = TC_H_MIN(t->tcm_info);
 		__u32 prio = TC_H_MAJ(t->tcm_info)>>16;
@@ -259,7 +274,6 @@ int print_filter(const struct sockaddr_nl *who,
 	return 0;
 }
 
-
 static int tc_filter_list(int argc, char **argv)
 {
 	struct tcmsg t;
@@ -284,6 +298,22 @@ static int tc_filter_list(int argc, char **argv)
 				return -1;
 			}
 			filter_parent = t.tcm_parent = TC_H_ROOT;
+		} else if (strcmp(*argv, "ingress") == 0) {
+			if (t.tcm_parent) {
+				fprintf(stderr, "Error: \"ingress\" is duplicate parent ID\n");
+				return -1;
+			}
+			filter_parent = TC_H_MAKE(TC_H_CLSACT,
+						  TC_H_MIN_INGRESS);
+			t.tcm_parent = filter_parent;
+		} else if (strcmp(*argv, "egress") == 0) {
+			if (t.tcm_parent) {
+				fprintf(stderr, "Error: \"egress\" is duplicate parent ID\n");
+				return -1;
+			}
+			filter_parent = TC_H_MAKE(TC_H_CLSACT,
+						  TC_H_MIN_EGRESS);
+			t.tcm_parent = filter_parent;
 		} else if (strcmp(*argv, "parent") == 0) {
 			__u32 handle;
 			NEXT_ARG();
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 96b8085..cb861e0 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -26,17 +26,15 @@
 #include "tc_util.h"
 #include "tc_common.h"
 
-static int usage(void);
-
 static int usage(void)
 {
 	fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | show ] dev STRING\n");
-	fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | parent CLASSID ]\n");
+	fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | clsact | parent CLASSID ]\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
 	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ingress]\n");
+	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ]\n");
 	fprintf(stderr, "Where:\n");
 	fprintf(stderr, "QDISC_KIND := { [p|b]fifo | tbf | prio | cbq | red | etc. }\n");
 	fprintf(stderr, "OPTIONS := ... try tc qdisc add <desired QDISC_KIND> help\n");
@@ -91,6 +89,17 @@ static int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 				return -1;
 			}
 			req.t.tcm_parent = TC_H_ROOT;
+		} else if (strcmp(*argv, "clsact") == 0) {
+			if (req.t.tcm_parent) {
+				fprintf(stderr, "Error: \"clsact\" is a duplicate parent ID\n");
+				return -1;
+			}
+			req.t.tcm_parent = TC_H_CLSACT;
+			strncpy(k, "clsact", sizeof(k) - 1);
+			q = get_qdisc_kind(k);
+			req.t.tcm_handle = TC_H_MAKE(TC_H_CLSACT, 0);
+			NEXT_ARG_FWD();
+			break;
 		} else if (strcmp(*argv, "ingress") == 0) {
 			if (req.t.tcm_parent) {
 				fprintf(stderr, "Error: \"ingress\" is a duplicate parent ID\n");
@@ -274,7 +283,6 @@ int print_qdisc(const struct sockaddr_nl *who,
 	return 0;
 }
 
-
 static int tc_qdisc_list(int argc, char **argv)
 {
 	struct tcmsg t;
@@ -288,7 +296,8 @@ static int tc_qdisc_list(int argc, char **argv)
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(d, *argv, sizeof(d)-1);
-                } else if (strcmp(*argv, "ingress") == 0) {
+                } else if (strcmp(*argv, "ingress") == 0 ||
+			   strcmp(*argv, "clsact") == 0) {
                              if (t.tcm_parent) {
                                      fprintf(stderr, "Duplicate parent ID\n");
                                      usage();
-- 
1.9.3
