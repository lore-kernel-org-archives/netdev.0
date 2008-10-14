From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Tue, 14 Oct 2008 19:00:54 +0200
Message-ID: <20081014170054.GB20815@postel.suug.ch>
References: <20081013155715.GZ20815@postel.suug.ch> <loom.20081014T115257-383@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chei-yol Kim <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41349 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbYJNRAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 13:00:34 -0400
Content-Disposition: inline
In-Reply-To: <loom.20081014T115257-383@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Chei-yol Kim <gauri@etri.re.kr> 2008-10-14 11:56
> Thomas Graf <tgraf <at> suug.ch> writes:
> 
> > 
> > This patch implements a very basic cgroup subsystem which allows
> > assigning classids to cgroups. It also adds a trivial classifier
> > to filter packets based on that classid and map them to classes.
> > 
> 
> In order to test your patch, I need more programs such as iproute-x.x.x 
> package modified for using your cgroup classifier.
> You seem to test your code now. Please send me additional code and patch for 
> testing environments.

Of course, this is the patch required for iproute2.

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 99efbed..e6aa848 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -374,6 +374,7 @@ enum
 	TCA_FLOW_ACT,
 	TCA_FLOW_POLICE,
 	TCA_FLOW_EMATCHES,
+	TCA_FLOW_PERTURB,
 	__TCA_FLOW_MAX
 };
 
@@ -393,6 +394,20 @@ enum
 
 #define TCA_BASIC_MAX (__TCA_BASIC_MAX - 1)
 
+
+/* Cgroup classifier */
+
+enum
+{
+	TCA_CGROUP_UNSPEC,
+	TCA_CGROUP_ACT,
+	TCA_CGROUP_POLICE,
+	TCA_CGROUP_EMATCHES,
+	__TCA_CGROUP_MAX,
+};
+
+#define TCA_CGROUP_MAX (__TCA_CGROUP_MAX - 1)
+
 /* Extended Matches */
 
 struct tcf_ematch_tree_hdr
diff --git a/tc/Makefile b/tc/Makefile
index 4116983..1a4459a 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -19,6 +19,7 @@ TCMODULES += f_route.o
 TCMODULES += f_fw.o
 TCMODULES += f_basic.o
 TCMODULES += f_flow.o
+TCMODULES += f_cgroup.o
 TCMODULES += q_dsmark.o
 TCMODULES += q_gred.o
 TCMODULES += f_tcindex.o
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
new file mode 100644
index 0000000..1a36d7f
--- /dev/null
+++ b/tc/f_cgroup.c
@@ -0,0 +1,115 @@
+/*
+ * f_cgroup.c		Control Group Classifier
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include "utils.h"
+#include "tc_util.h"
+#include "m_ematch.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... cgroup [ match EMATCH_TREE ] [ police POLICE_SPEC ]\n");
+	fprintf(stderr, "                 [ action ACTION_SPEC ]\n");
+}
+
+static int cgroup_parse_opt(struct filter_util *qu, char *handle,
+			   int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail;
+	long h = 0;
+
+	if (handle) {
+		h = strtol(handle, NULL, 0);
+		if (h == LONG_MIN || h == LONG_MAX) {
+			fprintf(stderr, "Illegal handle \"%s\", must be numeric.\n",
+			    handle);
+			return -1;
+		}
+	}
+
+	t->tcm_handle = h;
+
+	tail = (struct rtattr*)(((void*)n)+NLMSG_ALIGN(n->nlmsg_len));
+	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (matches(*argv, "match") == 0) {
+			NEXT_ARG();
+			if (parse_ematch(&argc, &argv, TCA_CGROUP_EMATCHES, n)) {
+				fprintf(stderr, "Illegal \"ematch\"\n");
+				return -1;
+			}
+			continue;
+		} else if (matches(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (parse_action(&argc, &argv, TCA_CGROUP_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
+
+		} else if (matches(*argv, "police") == 0) {
+			NEXT_ARG();
+			if (parse_police(&argc, &argv, TCA_CGROUP_POLICE, n)) {
+				fprintf(stderr, "Illegal \"police\"\n");
+				return -1;
+			}
+			continue;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	tail->rta_len = (((void*)n)+n->nlmsg_len) - (void*)tail;
+	return 0;
+}
+
+static int cgroup_print_opt(struct filter_util *qu, FILE *f,
+			   struct rtattr *opt, __u32 handle)
+{
+	struct rtattr *tb[TCA_CGROUP_MAX+1];
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CGROUP_MAX, opt);
+
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
+	if (tb[TCA_CGROUP_EMATCHES])
+		print_ematch(f, tb[TCA_CGROUP_EMATCHES]);
+
+	if (tb[TCA_CGROUP_POLICE]) {
+		fprintf(f, "\n");
+		tc_print_police(f, tb[TCA_CGROUP_POLICE]);
+	}
+
+	if (tb[TCA_CGROUP_ACT])
+		tc_print_action(f, tb[TCA_CGROUP_ACT]);
+
+	return 0;
+}
+
+struct filter_util cgroup_filter_util = {
+	.id = "cgroup",
+	.parse_fopt = cgroup_parse_opt,
+	.print_fopt = cgroup_print_opt,
+};
