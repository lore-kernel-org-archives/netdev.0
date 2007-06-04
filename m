From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] iproute2: Added support for RR qdisc (sch_rr)
Date: Mon, 04 Jun 2007 14:42:26 -0700
Message-ID: <20070604214226.1546.28051.stgit@localhost.localdomain>
References: <20070604214221.1546.88862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38188 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752857AbXFDVm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:42:28 -0400
In-Reply-To: <20070604214221.1546.88862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add tc support for the sch_rr qdisc.  This qdisc supports multiple queues
    on hardware.  The syntax for sch_rr is the same as sch_prio.

    Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/pkt_sched.h |   11 ++++
 tc/Makefile               |    1 
 tc/q_rr.c                 |  113 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..907412b 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -22,6 +22,7 @@
 #define TC_PRIO_CONTROL			7
 
 #define TC_PRIO_MAX			15
+#define TC_RR_MAX			15
 
 /* Generic queue statistics, available for all the elements.
    Particular schedulers may have also their private records.
@@ -90,6 +91,16 @@ struct tc_fifo_qopt
 	__u32	limit;	/* Queue length: bytes for bfifo, packets for pfifo */
 };
 
+/* RR section */
+#define TCQ_RR_BANDS	16
+#define TCQ_MIN_RR_BANDS 2
+
+struct tc_rr_qopt
+{
+	int	bands;
+	__u8	priomap[TC_RR_MAX + 1];
+};
+
 /* PRIO section */
 
 #define TCQ_PRIO_BANDS	16
diff --git a/tc/Makefile b/tc/Makefile
index 9d618ff..62e2697 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -9,6 +9,7 @@ TCMODULES += q_fifo.o
 TCMODULES += q_sfq.o
 TCMODULES += q_red.o
 TCMODULES += q_prio.o
+TCMODULES += q_rr.o
 TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += f_rsvp.o
diff --git a/tc/q_rr.c b/tc/q_rr.c
new file mode 100644
index 0000000..8eecac9
--- /dev/null
+++ b/tc/q_rr.c
@@ -0,0 +1,113 @@
+/*
+ * q_rr.c		RR.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	PJ Waskiewicz, <peter.p.waskiewicz.jr@intel.com>
+ * Original Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru> (from PRIO)
+ *
+ * Changes:
+ *
+ * Ole Husgaard <sparre@login.dknet.dk>: 990513: prio2band map was always reset.
+ * J Hadi Salim <hadi@cyberus.ca>: 990609: priomap fix.
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
+	fprintf(stderr, "Usage: ... rr bands NUMBER priomap P1 P2...\n");
+}
+
+#define usage() return(-1)
+
+static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+{
+	int ok = 0;
+	int pmap_mode = 0;
+	int idx = 0;
+	struct tc_rr_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
+
+	while (argc > 0) {
+		if (strcmp(*argv, "bands") == 0) {
+			if (pmap_mode)
+				explain();
+			NEXT_ARG();
+			if (get_integer(&opt.bands, *argv, 10)) {
+				fprintf(stderr, "Illegal \"bands\"\n");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "priomap") == 0) {
+			if (pmap_mode) {
+				fprintf(stderr, "Error: duplicate priomap\n");
+				return -1;
+			}
+			pmap_mode = 1;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			unsigned band;
+			if (!pmap_mode) {
+				fprintf(stderr, "What is \"%s\"?\n", *argv);
+				explain();
+				return -1;
+			}
+			if (get_unsigned(&band, *argv, 10)) {
+				fprintf(stderr, "Illegal \"priomap\" element\n");
+				return -1;
+			}
+			if (band > opt.bands) {
+				fprintf(stderr, "\"priomap\" element is out of bands\n");
+				return -1;
+			}
+			if (idx > TC_RR_MAX) {
+				fprintf(stderr, "\"priomap\" index > TC_RR_MAX=%u\n", TC_RR_MAX);
+				return -1;
+			}
+			opt.priomap[idx++] = band;
+		}
+		argc--; argv++;
+	}
+
+	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	return 0;
+}
+
+int rr_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	int i;
+	struct tc_rr_qopt *qopt;
+
+	if (opt == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(opt)  < sizeof(*qopt))
+		return -1;
+	qopt = RTA_DATA(opt);
+	fprintf(f, "bands %u priomap ", qopt->bands);
+	for (i=0; i <= TC_RR_MAX; i++)
+		fprintf(f, " %d", qopt->priomap[i]);
+	return 0;
+}
+
+struct qdisc_util rr_qdisc_util = {
+	.id	 	= "rr",
+	.parse_qopt	= rr_parse_opt,
+	.print_qopt	= rr_print_opt,
+};
