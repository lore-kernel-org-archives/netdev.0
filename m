From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 02/02]: Add flow classifier support
Date: Thu, 31 Jan 2008 18:58:59 +0100
Message-ID: <47A20C63.6030806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020309040705080209050407"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55192 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763817AbYAaR7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:59:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020309040705080209050407
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020309040705080209050407
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[IPROUTE]: Add flow classifier support

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ac3df2d7e37826b06cc9093f50d829a9da1873a4
tree b33a2b29abdcea0267fe7a357d282a4c2f67124b
parent 196870f762ee393438c42115425f4af69e5b5186
author Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 18:52:47 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 18:52:47 +0100

 include/linux/pkt_cls.h |   50 +++++++
 tc/Makefile             |    1 
 tc/f_flow.c             |  347 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 398 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index afb79d0..16869c2 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -328,6 +328,56 @@ enum
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+/* Flow filter */
+
+enum
+{
+	FLOW_KEY_SRC,
+	FLOW_KEY_DST,
+	FLOW_KEY_PROTO,
+	FLOW_KEY_PROTO_SRC,
+	FLOW_KEY_PROTO_DST,
+	FLOW_KEY_IIF,
+	FLOW_KEY_PRIORITY,
+	FLOW_KEY_MARK,
+	FLOW_KEY_NFCT,
+	FLOW_KEY_NFCT_SRC,
+	FLOW_KEY_NFCT_DST,
+	FLOW_KEY_NFCT_PROTO_SRC,
+	FLOW_KEY_NFCT_PROTO_DST,
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
+	FLOW_MODE_MAP,
+	FLOW_MODE_HASH,
+};
+
+enum
+{
+	TCA_FLOW_UNSPEC,
+	TCA_FLOW_KEYS,
+	TCA_FLOW_MODE,
+	TCA_FLOW_BASECLASS,
+	TCA_FLOW_RSHIFT,
+	TCA_FLOW_ADDEND,
+	TCA_FLOW_MASK,
+	TCA_FLOW_XOR,
+	TCA_FLOW_DIVISOR,
+	TCA_FLOW_ACT,
+	TCA_FLOW_POLICE,
+	TCA_FLOW_EMATCHES,
+	__TCA_FLOW_MAX
+};
+
+#define TCA_FLOW_MAX	(__TCA_FLOW_MAX - 1)
+
 /* Basic filter */
 
 enum
diff --git a/tc/Makefile b/tc/Makefile
index 0facc88..7ece958 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -18,6 +18,7 @@ TCMODULES += f_u32.o
 TCMODULES += f_route.o
 TCMODULES += f_fw.o
 TCMODULES += f_basic.o
+TCMODULES += f_flow.o
 TCMODULES += q_dsmark.o
 TCMODULES += q_gred.o
 TCMODULES += f_tcindex.o
diff --git a/tc/f_flow.c b/tc/f_flow.c
new file mode 100644
index 0000000..eca05cd
--- /dev/null
+++ b/tc/f_flow.c
@@ -0,0 +1,347 @@
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
+#include "m_ematch.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+"Usage: ... flow ...\n"
+"\n"
+" [mapping mode]: map key KEY [ OPS ] ...\n"
+" [hashing mode]: hash keys KEY-LIST ...\n"
+"\n"
+"                 [ divisor NUM ] [ baseclass ID ] [ match EMATCH_TREE ]\n"
+"                 [ police POLICE_SPEC ] [ action ACTION_SPEC ]\n"
+"\n"
+"KEY-LIST := [ KEY-LIST , ] KEY\n"
+"KEY      := [ src | dst | proto | proto-src | proto-dst | iif | priority | \n"
+"              mark | nfct | nfct-src | nfct-dst | nfct-proto-src | \n"
+"              nfct-proto-dst | rt-classid | sk-uid | sk-gid ]\n"
+"OPS      := [ or NUM | and NUM | xor NUM | rshift NUM | addend NUM ]\n"
+"ID       := X:Y\n"
+	);
+}
+
+static const char *flow_keys[FLOW_KEY_MAX+1] = {
+	[FLOW_KEY_SRC]			= "src",
+	[FLOW_KEY_DST]			= "dst",
+	[FLOW_KEY_PROTO]		= "proto",
+	[FLOW_KEY_PROTO_SRC]		= "proto-src",
+	[FLOW_KEY_PROTO_DST]		= "proto-dst",
+	[FLOW_KEY_IIF]			= "iif",
+	[FLOW_KEY_PRIORITY]		= "priority",
+	[FLOW_KEY_MARK]			= "mark",
+	[FLOW_KEY_NFCT]			= "nfct",
+	[FLOW_KEY_NFCT_SRC]		= "nfct-src",
+	[FLOW_KEY_NFCT_DST]		= "nfct-dst",
+	[FLOW_KEY_NFCT_PROTO_SRC]	= "nfct-proto-src",
+	[FLOW_KEY_NFCT_PROTO_DST]	= "nfct-proto-dst",
+	[FLOW_KEY_RTCLASSID]		= "rt-classid",
+	[FLOW_KEY_SKUID]		= "sk-uid",
+	[FLOW_KEY_SKGID]		= "sk-gid",
+};
+
+static int flow_parse_keys(__u32 *keys, __u32 *nkeys, char *argv)
+{
+	char *s, *sep;
+	unsigned int i;
+
+	*keys = 0;
+	*nkeys = 0;
+	s = argv;
+	while (s != NULL) {
+		sep = strchr(s, ',');
+		if (sep)
+			*sep = '\0';
+
+		for (i = 0; i <= FLOW_KEY_MAX; i++) {
+			if (matches(s, flow_keys[i]) == 0) {
+				*keys |= 1 << i;
+				(*nkeys)++;
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
+static void transfer_bitop(__u32 *mask, __u32 *xor, __u32 m, __u32 x)
+{
+	*xor = x ^ (*xor & m);
+	*mask &= m;
+}
+
+static int get_addend(__u32 *addend, char *argv, __u32 keys)
+{
+	inet_prefix addr;
+	int sign = 0;
+	__u32 tmp;
+
+	if (*argv == '-') {
+		sign = 1;
+		argv++;
+	}
+
+	if (get_u32(&tmp, argv, 0) == 0)
+		goto out;
+
+	if (keys & (FLOW_KEY_SRC | FLOW_KEY_DST |
+		    FLOW_KEY_NFCT_SRC | FLOW_KEY_NFCT_DST) &&
+	    get_addr(&addr, argv, AF_UNSPEC) == 0) {
+		switch (addr.family) {
+		case AF_INET:
+			tmp = ntohl(addr.data[0]);
+			goto out;
+		case AF_INET6:
+			tmp = ntohl(addr.data[3]);
+			goto out;
+		}
+	}
+
+	return -1;
+out:
+	if (sign)
+		tmp = -tmp;
+	*addend = tmp;
+	return 0;
+}
+
+static int flow_parse_opt(struct filter_util *fu, char *handle,
+			  int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tc_police tp;
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail;
+	__u32 mask = ~0U, xor = 0;
+	__u32 keys = 0, nkeys = 0;
+	__u32 mode = FLOW_MODE_MAP;
+	__u32 tmp;
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
+		if (matches(*argv, "map") == 0) {
+			mode = FLOW_MODE_MAP;
+		} else if (matches(*argv, "hash") == 0) {
+			mode = FLOW_MODE_HASH;
+		} else if (matches(*argv, "keys") == 0) {
+			NEXT_ARG();
+			if (flow_parse_keys(&keys, &nkeys, *argv))
+				return -1;
+			addattr32(n, 4096, TCA_FLOW_KEYS, keys);
+		} else if (matches(*argv, "and") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"mask\"\n");
+				return -1;
+			}
+			transfer_bitop(&mask, &xor, tmp, 0);
+		} else if (matches(*argv, "or") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"or\"\n");
+				return -1;
+			}
+			transfer_bitop(&mask, &xor, ~tmp, tmp);
+		} else if (matches(*argv, "xor") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"xor\"\n");
+				return -1;
+			}
+			transfer_bitop(&mask, &xor, ~0, tmp);
+		} else if (matches(*argv, "rshift") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"rshift\"\n");
+				return -1;
+			}
+			addattr32(n, 4096, TCA_FLOW_RSHIFT, tmp);
+		} else if (matches(*argv, "addend") == 0) {
+			NEXT_ARG();
+			if (get_addend(&tmp, *argv, keys)) {
+				fprintf(stderr, "Illegal \"addend\"\n");
+				return -1;
+			}
+			addattr32(n, 4096, TCA_FLOW_ADDEND, tmp);
+		} else if (matches(*argv, "divisor") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"divisor\"\n");
+				return -1;
+			}
+			addattr32(n, 4096, TCA_FLOW_DIVISOR, tmp);
+		} else if (matches(*argv, "baseclass") == 0) {
+			NEXT_ARG();
+			if (get_tc_classid(&tmp, *argv) || TC_H_MIN(tmp) == 0) {
+				fprintf(stderr, "Illegal \"baseclass\"\n");
+				return -1;
+			}
+			addattr32(n, 4096, TCA_FLOW_BASECLASS, tmp);
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
+		} else if (matches(*argv, "match") == 0) {
+			NEXT_ARG();
+			if (parse_ematch(&argc, &argv, TCA_FLOW_EMATCHES, n)) {
+				fprintf(stderr, "Illegal \"ematch\"\n");
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
+	if (nkeys > 1 && mode != FLOW_MODE_HASH) {
+		fprintf(stderr, "Invalid mode \"map\" for multiple keys\n");
+		return -1;
+	}
+	addattr32(n, 4096, TCA_FLOW_MODE, mode);
+
+	if (mask != ~0 || xor != 0) {
+		addattr32(n, 4096, TCA_FLOW_MASK, mask);
+		addattr32(n, 4096, TCA_FLOW_XOR, xor);
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
+	__u32 mask = ~0, val = 0;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	parse_rtattr_nested(tb, TCA_FLOW_MAX, opt);
+
+	fprintf(f, "handle 0x%x ", handle);
+
+	if (tb[TCA_FLOW_MODE]) {
+		__u32 mode = *(__u32 *)RTA_DATA(tb[TCA_FLOW_MODE]);
+
+		switch (mode) {
+		case FLOW_MODE_MAP:
+			fprintf(f, "map ");
+			break;
+		case FLOW_MODE_HASH:
+			fprintf(f, "hash ");
+			break;
+		}
+	}
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
+
+	if (tb[TCA_FLOW_MASK])
+		mask = *(__u32 *)RTA_DATA(tb[TCA_FLOW_MASK]);
+	if (tb[TCA_FLOW_XOR])
+		val = *(__u32 *)RTA_DATA(tb[TCA_FLOW_XOR]);
+
+	if (mask != ~0 || val != 0) {
+		__u32 or = (mask & val) ^ val;
+		__u32 xor = mask & val;
+
+		if (mask != ~0)
+			fprintf(f, "and 0x%.8x ", mask);
+		if (xor != 0)
+			fprintf(f, "xor 0x%.8x ", xor);
+		if (or != 0)
+			fprintf(f, "or 0x%.8x ", or);
+	}
+
+	if (tb[TCA_FLOW_RSHIFT])
+		fprintf(f, "rshift %u ",
+			*(__u32 *)RTA_DATA(tb[TCA_FLOW_RSHIFT]));
+	if (tb[TCA_FLOW_ADDEND])
+		fprintf(f, "addend 0x%x ",
+			*(__u32 *)RTA_DATA(tb[TCA_FLOW_ADDEND]));
+
+	if (tb[TCA_FLOW_DIVISOR])
+		fprintf(f, "divisor %u ",
+			*(__u32 *)RTA_DATA(tb[TCA_FLOW_DIVISOR]));
+	if (tb[TCA_FLOW_BASECLASS])
+		fprintf(f, "baseclass %s ",
+			sprint_tc_classid(*(__u32 *)RTA_DATA(tb[TCA_FLOW_BASECLASS]), b1));
+
+	if (tb[TCA_FLOW_EMATCHES])
+		print_ematch(f, tb[TCA_FLOW_EMATCHES]);
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

--------------020309040705080209050407--
