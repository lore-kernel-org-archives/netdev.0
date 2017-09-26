From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [iproute2 net-next 2/3] tc: Add support for the CBS qdisc
Date: Tue, 26 Sep 2017 16:39:57 -0700
Message-ID: <20170926233958.12027-2-vinicius.gomes@intel.com>
References: <20170926233958.12027-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41230 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032684AbdIZXkF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 19:40:05 -0400
In-Reply-To: <20170926233958.12027-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Credit Based Shaper (CBS) queueing discipline allows bandwidth
reservation with sub-milisecond precision. It is defined by the
802.1Q-2014 specification (section 8.6.8.2 and Annex L).

The syntax is:

tc qdisc add dev DEV parent NODE cbs locredit <LOCREDIT>
   		hicredit <HICREDIT> sendslope <SENDSLOPE>
		idleslope <IDLESLOPE>

(The order is not important)

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 tc/Makefile |   1 +
 tc/q_cbs.c  | 134 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+)
 create mode 100644 tc/q_cbs.c

diff --git a/tc/Makefile b/tc/Makefile
index 777de5e6..24bd3e2e 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -69,6 +69,7 @@ TCMODULES += q_hhf.o
 TCMODULES += q_clsact.o
 TCMODULES += e_bpf.o
 TCMODULES += f_matchall.o
+TCMODULES += q_cbs.o
 
 TCSO :=
 ifeq ($(TC_CONFIG_ATM),y)
diff --git a/tc/q_cbs.c b/tc/q_cbs.c
new file mode 100644
index 00000000..80dd599a
--- /dev/null
+++ b/tc/q_cbs.c
@@ -0,0 +1,134 @@
+/*
+ * q_cbs.c		CBS.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Vinicius Costa Gomes <vinicius.gomes@intel.com>
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
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... cbs hicredit BYTES locredit BYTES sendslope BPS idleslope BPS\n");
+}
+
+static void explain1(const char *arg, const char *val)
+{
+	fprintf(stderr, "cbs: illegal value for \"%s\": \"%s\"\n", arg, val);
+}
+
+static int cbs_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+{
+	int ok = 0;
+	struct tc_cbs_qopt opt = {};
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (matches(*argv, "hicredit") == 0) {
+			NEXT_ARG();
+			if (opt.hicredit) {
+				fprintf(stderr, "cbs: duplicate \"hicredit\" specification\n");
+				return -1;
+			}
+			if (get_s32(&opt.hicredit, *argv, 0)) {
+				explain1("hicredit", *argv);
+				return -1;
+			}
+			ok++;
+		} else if (matches(*argv, "locredit") == 0) {
+			NEXT_ARG();
+			if (opt.locredit) {
+				fprintf(stderr, "cbs: duplicate \"locredit\" specification\n");
+				return -1;
+			}
+			if (get_s32(&opt.locredit, *argv, 0)) {
+				explain1("locredit", *argv);
+				return -1;
+			}
+			ok++;
+		} else if (matches(*argv, "sendslope") == 0) {
+			NEXT_ARG();
+			if (opt.sendslope) {
+				fprintf(stderr, "cbs: duplicate \"sendslope\" specification\n");
+				return -1;
+			}
+			if (get_s32(&opt.sendslope, *argv, 0)) {
+				explain1("sendslope", *argv);
+				return -1;
+			}
+			ok++;
+		} else if (matches(*argv, "idleslope") == 0) {
+			NEXT_ARG();
+			if (opt.idleslope) {
+				fprintf(stderr, "cbs: duplicate \"idleslope\" specification\n");
+				return -1;
+			}
+			if (get_s32(&opt.idleslope, *argv, 0)) {
+				explain1("idleslope", *argv);
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "cbs: unknown parameter \"%s\"\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	addattr_l(n, 2024, TCA_CBS_PARMS, &opt, sizeof(opt));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int cbs_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_CBS_MAX+1];
+	struct tc_cbs_qopt *qopt;
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CBS_MAX, opt);
+
+	if (tb[TCA_CBS_PARMS] == NULL)
+		return -1;
+
+	qopt = RTA_DATA(tb[TCA_CBS_PARMS]);
+	if (RTA_PAYLOAD(tb[TCA_CBS_PARMS])  < sizeof(*qopt))
+		return -1;
+
+	fprintf(f, "hicredit %d ", qopt->hicredit);
+	fprintf(f, "locredit %d ", qopt->locredit);
+	fprintf(f, "sendslope %d ", qopt->sendslope);
+	fprintf(f, "idleslope %d ", qopt->idleslope);
+
+	return 0;
+}
+
+struct qdisc_util cbs_qdisc_util = {
+	.id		= "cbs",
+	.parse_qopt	= cbs_parse_opt,
+	.print_qopt	= cbs_print_opt,
+};
-- 
2.14.2
