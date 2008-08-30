From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED] [NET-NEXT PATCH 1/2] IPROUTE: add support formultiq qdisc
Date: Sat, 30 Aug 2008 00:26:38 -0700
Message-ID: <20080830072626.7871.46628.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:62468 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbYH3H0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 03:26:40 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1181779rvb.1
        for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 00:26:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add support for multiq qdisc
	This patch adds the ability to configure the multiq qdisc.  Since the qdisc does not require any input it will pull the number of bands directly from the device that it is added to the root of.

usage: tc qdisc add dev <DEV> root handle <HANDLE> multiq

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/pkt_sched.h |    6 +++
 tc/Makefile               |    1 +
 tc/q_multiq.c             |   79 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_multiq.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..8e31e79 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -112,6 +112,12 @@ enum
 
 #define TCA_PRIO_MAX    (__TCA_PRIO_MAX - 1)
 
+/* MULTIQ section */
+
+struct tc_multiq_qopt {
+	int	bands;			/* Number of bands */
+};
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/tc/Makefile b/tc/Makefile
index 4116983..2f3c1ea 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -12,6 +12,7 @@ TCMODULES += q_prio.o
 TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += q_rr.o
+TCMODULES += q_multiq.o
 TCMODULES += q_netem.o
 TCMODULES += f_rsvp.o
 TCMODULES += f_u32.o
diff --git a/tc/q_multiq.c b/tc/q_multiq.c
new file mode 100644
index 0000000..34ba179
--- /dev/null
+++ b/tc/q_multiq.c
@@ -0,0 +1,79 @@
+/*
+ * q_multiq.c		MULTIQ.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Author: Alexander Duyck <alexander.h.duyck@intel.com>
+ *
+ * Original Authors:	PJ Waskiewicz, <peter.p.waskiewicz.jr@intel.com> (RR)
+ * 			Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru> (from PRIO)
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
+	fprintf(stderr, "Usage: ... multiq [help]\n");
+}
+
+#define usage() return(-1)
+
+static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			    struct nlmsghdr *n)
+{
+	int ok = 0;
+	struct tc_multiq_qopt opt;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "help") == 0) {
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
+	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	return 0;
+}
+
+int multiq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct tc_multiq_qopt *qopt;
+	struct rtattr *tb[TCA_PRIO_MAX + 1];
+
+	if (opt == NULL)
+		return 0;
+	if (RTA_PAYLOAD(opt) < sizeof(*qopt))
+		return 0;
+
+	qopt = RTA_DATA(opt);
+
+	fprintf(f, "bands %u ", qopt->bands);
+
+	return 0;
+}
+
+struct qdisc_util multiq_qdisc_util = {
+	.id	 	= "multiq",
+	.parse_qopt	= multiq_parse_opt,
+	.print_qopt	= multiq_print_opt,
+};

