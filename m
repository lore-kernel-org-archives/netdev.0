From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE]: Add flow classifier support
Date: Wed, 30 May 2007 11:42:01 +0200
Message-ID: <465D46E9.2000808@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070305000803080504050204"
Cc: jamal <hadi@cyberus.ca>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33849 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbXE3JmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 05:42:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070305000803080504050204
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The iproute patch for the flow classifier.



--------------070305000803080504050204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Add flow classifier support

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f338e298616e6680dc1ea3b1c61cf59a72bf0801
tree 857fc47789b2bf45e354c8c63f1ef78526b38ca5
parent b16621cafd599499fdbaa79236266d72a53106bb
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 05:17:28 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 05:17:28 +0200

 include/linux/pkt_cls.h |   37 ++++++++
 tc/Makefile             |    1 
 tc/f_flow.c             |  205 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 243 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index c3f01b3..0137591 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -328,6 +328,43 @@ enum
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+/* Flow filter */
+
+enum
+{
+	FLOW_KEY_SRC,
+	FLOW_KEY_DST,
+	FLOW_KEY_PROTO_SRC,
+	FLOW_KEY_PROTO_DST,
+	FLOW_KEY_PRIORITY,
+	FLOW_KEY_MARK,
+	FLOW_KEY_NFCT,
+	FLOW_KEY_NFCT_SRC,
+	FLOW_KEY_NFCT_DST,
+	FLOW_KEY_NFCT_PROTO_SRC,
+	FLOW_KEY_NFCT_PROTO_DST,
+	FLOW_KEY_RTIIF,
+	FLOW_KEY_RTCLASSID,
+	FLOW_KEY_SKUID,
+	FLOW_KEY_SKGID,
+	__FLOW_KEY_MAX,
+};
+
+#define FLOW_KEY_MAX	(__FLOW_KEY_MAX - 1)
+
+enum
+{
+	TCA_FLOW_UNSPEC,
+	TCA_FLOW_KEYS,
+	TCA_FLOW_BASECLASS,
+	TCA_FLOW_CLASSES,
+	TCA_FLOW_ACT,
+	TCA_FLOW_POLICE,
+	__TCA_FLOW_MAX
+};
+
+#define TCA_FLOW_MAX	(__TCA_FLOW_MAX - 1)
+
 /* Basic filter */
 
 enum
diff --git a/tc/Makefile b/tc/Makefile
index 7640c58..a105cb4 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -16,6 +16,7 @@ TCMODULES += f_u32.o
 TCMODULES += f_route.o
 TCMODULES += f_fw.o
 TCMODULES += f_basic.o
+TCMODULES += f_flow.o
 TCMODULES += q_dsmark.o
 TCMODULES += q_gred.o
 TCMODULES += f_tcindex.o
diff --git a/tc/f_flow.c b/tc/f_flow.c
new file mode 100644
index 0000000..40f5637
--- /dev/null
+++ b/tc/f_flow.c
@@ -0,0 +1,205 @@
+/*
+ * f_flow.c		Flow filter
+ *
+ * 		This program is free software; you can redistribute it and/or
+ * 		modify it under the terms of the GNU General Public License
+ * 		as published by the Free Software Foundation; either version
+ * 		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Patrick McHardy <kaber@trash.net>
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+"Usage: ... flow keys KEY-LIST [ baseclass ID ] [ classes NUM ]\n"
+"                              [ police POLICE_SPEC ] [ action ACTION_SPEC ]\n"
+"\n"
+"KEY-LIST := [ KEY-LIST , ] KEY\n"
+"KEY := [ src | dst | proto-src | proto-dst | priority | mark |\n"
+"         nfct | nfct-src | nfct-dst | nfct-proto-src | nfct-proto-dst |\n"
+"         rt-iif | rt-classid | sk-uid | sk-gid ]\n"
+"ID := X:Y\n"
+	);
+}
+
+static const char *flow_keys[FLOW_KEY_MAX+1] = {
+	[FLOW_KEY_SRC]			= "src",
+	[FLOW_KEY_DST]			= "dst",
+	[FLOW_KEY_PROTO_SRC]		= "proto-src",
+	[FLOW_KEY_PROTO_DST]		= "proto-dst",
+	[FLOW_KEY_PRIORITY]		= "priority",
+	[FLOW_KEY_MARK]			= "mark",
+	[FLOW_KEY_NFCT]			= "nfct",
+	[FLOW_KEY_NFCT_SRC]		= "nfct-src",
+	[FLOW_KEY_NFCT_DST]		= "nfct-dst",
+	[FLOW_KEY_NFCT_PROTO_SRC]	= "nfct-proto-src",
+	[FLOW_KEY_NFCT_PROTO_DST]	= "nfct-proto-dst",
+	[FLOW_KEY_RTIIF]		= "rt-iif",
+	[FLOW_KEY_RTCLASSID]		= "rt-classid",
+	[FLOW_KEY_SKUID]		= "sk-uid",
+	[FLOW_KEY_SKGID]		= "sk-gid",
+};
+
+static int flow_parse_keys(__u32 *keys, char *argv)
+{
+	char *s, *sep;
+	unsigned int i;
+
+	s = argv;
+	while (s != NULL) {
+		sep = strchr(s, ',');
+		if (sep)
+			*sep = '\0';
+
+		for (i = 0; i <= FLOW_KEY_MAX; i++) {
+			if (matches(s, flow_keys[i]) == 0) {
+				*keys |= 1 << i;
+				break;
+			}
+		}
+		if (i > FLOW_KEY_MAX) {
+			fprintf(stderr, "Unknown flow key \"%s\"\n", s);
+			return -1;
+		}
+		s = sep ? sep + 1 : NULL;
+	}
+	return 0;
+}
+
+static int flow_parse_opt(struct filter_util *fu, char *handle,
+			  int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tc_police tp;
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail;
+
+	memset(&tp, 0, sizeof(tp));
+
+	if (handle) {                                                              
+		if (get_u32(&t->tcm_handle, handle, 0)) {
+			fprintf(stderr, "Illegal \"handle\"\n");
+			return -1;
+		}
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 4096, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (matches(*argv, "keys") == 0) {
+			__u32 keymask = 0;
+
+			NEXT_ARG();
+			if (flow_parse_keys(&keymask, *argv))
+				return -1;
+			addattr_l(n, 4096, TCA_FLOW_KEYS, &keymask, 4);
+		} else if (matches(*argv, "baseclass") == 0) {
+			__u32 baseclass;
+
+			NEXT_ARG();
+			if (get_tc_classid(&baseclass, *argv) ||
+			    TC_H_MIN(baseclass) == 0) {
+				fprintf(stderr, "Illegal \"baseclass\"\n");
+				return -1;
+			}
+			addattr_l(n, 4096, TCA_FLOW_BASECLASS, &baseclass, 4);
+		} else if (matches(*argv, "classes") == 0) {
+			__u16 classes;
+
+			NEXT_ARG();
+			if (get_u16(&classes, *argv, 0)) {
+				fprintf(stderr, "Illegal \"classes\"\n");
+				return -1;
+			}
+			addattr_l(n, 4096, TCA_FLOW_CLASSES, &classes, 2);
+		} else if (matches(*argv, "police") == 0) {
+			NEXT_ARG();
+			if (parse_police(&argc, &argv, TCA_FLOW_POLICE, n)) {
+				fprintf(stderr, "Illegal \"police\"\n");
+				return -1;
+			}
+			continue;
+		} else if (matches(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (parse_action(&argc, &argv, TCA_FLOW_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argv++, argc--;
+	}
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+	return 0;
+}
+
+static int flow_print_opt(struct filter_util *fu, FILE *f, struct rtattr *opt,
+			  __u32 handle)
+{
+	struct rtattr *tb[TCA_FLOW_MAX+1];
+	SPRINT_BUF(b1);
+	unsigned int i;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	parse_rtattr_nested(tb, TCA_FLOW_MAX, opt);
+
+	fprintf(f, "handle 0x%x ", handle);
+
+	if (tb[TCA_FLOW_KEYS]) {
+		__u32 keymask = *(__u32 *)RTA_DATA(tb[TCA_FLOW_KEYS]);
+		char *sep = "";
+
+		fprintf(f, "keys ");
+		for (i = 0; i <= FLOW_KEY_MAX; i++) {
+			if (keymask & (1 << i)) {
+				fprintf(f, "%s%s", sep, flow_keys[i]);
+				sep = ",";
+			}
+		}
+		fprintf(f, " ");
+	}
+	if (tb[TCA_FLOW_BASECLASS]) {
+		__u32 baseclass = *(__u32 *)RTA_DATA(tb[TCA_FLOW_BASECLASS]);
+
+		fprintf(f, "baseclass %s ",
+			sprint_tc_classid(baseclass, b1));
+	}
+	if (tb[TCA_FLOW_CLASSES]) {
+		__u16 classes = *(__u16 *)RTA_DATA(tb[TCA_FLOW_CLASSES]);
+
+		fprintf(f, "classes %u ", classes);
+	}
+
+	if (tb[TCA_FLOW_POLICE])
+		tc_print_police(f, tb[TCA_FLOW_POLICE]);
+	if (tb[TCA_FLOW_ACT]) {
+		fprintf(f, "\n");
+		tc_print_action(f, tb[TCA_FLOW_ACT]);
+	}
+	return 0;
+}
+
+struct filter_util flow_filter_util = {
+	.id		= "flow",
+	.parse_fopt	= flow_parse_opt,
+	.print_fopt	= flow_print_opt,
+};

--------------070305000803080504050204--
