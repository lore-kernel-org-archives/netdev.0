From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TC]: Add NAT action
Date: Fri, 12 Oct 2007 17:08:40 +0800
Message-ID: <20071012090840.GA25147@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2977 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759769AbXJLJIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 05:08:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen:

Here's a patch to add support for the nat action which is now
in the kernel.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/tc/Makefile b/tc/Makefile
index 22cd437..cd5a69e 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -26,6 +26,7 @@ TCMODULES += q_htb.o
 TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
 TCMODULES += m_ipt.o
+TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
diff --git a/tc/m_nat.c b/tc/m_nat.c
new file mode 100644
index 0000000..6e7fd05
--- /dev/null
+++ b/tc/m_nat.c
@@ -0,0 +1,213 @@
+/*
+ * m_nat.c		NAT module
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Herbert Xu <herbert@gondor.apana.org.au>
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
+#include <dlfcn.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_nat.h>
+
+static void
+explain(void)
+{
+	fprintf(stderr, "Usage: ... nat NAT\n"
+			"NAT := DIRECTION OLD NEW\n"
+			"DIRECTION := { ingress | egress }\n"
+			"OLD := PREFIX\n"
+			"NEW := ADDRESS\n");
+}
+
+static void
+usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int
+parse_nat_args(int *argc_p, char ***argv_p,struct tc_nat *sel)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	inet_prefix addr;
+
+	if (argc <= 0)
+		return -1;
+
+	if (matches(*argv, "egress") == 0)
+		sel->flags |= TCA_NAT_FLAG_EGRESS;
+	else if (matches(*argv, "ingress") != 0)
+		goto bad_val;
+
+	NEXT_ARG();
+
+	if (get_prefix_1(&addr, *argv, AF_INET))
+		goto bad_val;
+
+	sel->old_addr = addr.data[0];
+	sel->mask = htonl(~0u << (32 - addr.bitlen));
+
+	NEXT_ARG();
+
+	if (get_prefix_1(&addr, *argv, AF_INET))
+		goto bad_val;
+
+	sel->new_addr = addr.data[0];
+
+	argc--;
+	argv++;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+
+bad_val:
+	return -1;
+}
+
+static int
+parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+	struct tc_nat sel;
+
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0;
+	struct rtattr *tail;
+
+	memset(&sel, 0, sizeof(sel));
+
+	while (argc > 0) {
+		if (matches(*argv, "nat") == 0) {
+			NEXT_ARG();
+			if (parse_nat_args(&argc, &argv, &sel)) {
+				fprintf(stderr, "Illegal nat construct (%s) \n",
+					*argv);
+				explain();
+				return -1;
+			}
+			ok++;
+			continue;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+
+	}
+
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			sel.action = TC_ACT_RECLASSIFY;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pipe") == 0) {
+			sel.action = TC_ACT_PIPE;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "drop") == 0 ||
+			matches(*argv, "shot") == 0) {
+			sel.action = TC_ACT_SHOT;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "continue") == 0) {
+			sel.action = TC_ACT_UNSPEC;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pass") == 0) {
+			sel.action = TC_ACT_OK;
+			argc--;
+			argv++;
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&sel.index, *argv, 10)) {
+				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_NAT_PARMS, &sel, sizeof(sel));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int
+print_nat(struct action_util *au,FILE * f, struct rtattr *arg)
+{
+	struct tc_nat *sel;
+	struct rtattr *tb[TCA_NAT_MAX + 1];
+	char buf1[256];
+	char buf2[256];
+	SPRINT_BUF(buf3);
+	int len;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_NAT_MAX, arg);
+
+	if (tb[TCA_NAT_PARMS] == NULL) {
+		fprintf(f, "[NULL nat parameters]");
+		return -1;
+	}
+	sel = RTA_DATA(tb[TCA_NAT_PARMS]);
+
+	len = ffs(sel->mask);
+	len = len ? 33 - len : 0;
+
+	fprintf(f, " nat %s %s/%d %s %s", sel->flags & TCA_NAT_FLAG_EGRESS ?
+					  "egress" : "ingress",
+		format_host(AF_INET, 4, &sel->old_addr, buf1, sizeof(buf1)),
+		len,
+		format_host(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)),
+		action_n2a(sel->action, buf3, sizeof (buf3)));
+
+	if (show_stats) {
+		if (tb[TCA_NAT_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_NAT_TM]);
+			print_tm(f,tm);
+		}
+	}
+
+	return 0;
+}
+
+struct action_util nat_action_util = {
+	.id = "nat",
+	.parse_aopt = parse_nat,
+	.print_aopt = print_nat,
+};
