From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/2] IPROUTE: add support for multiq qdisc
Date: Fri, 05 Dec 2008 14:16:42 -0800
Message-ID: <20081205221635.7949.93413.stgit@gitlost.lost>
References: <20081205221609.7949.26787.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: shemminger@vyatta.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:42742 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755809AbYLEWRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 17:17:01 -0500
In-Reply-To: <20081205221609.7949.26787.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add support for multiq qdisc
	This patch adds the ability to configure the multiq qdisc.  Since the qdisc does not require any input it will pull the number of bands directly from the device that it is added to the root of.

usage: tc qdisc add dev <DEV> root handle <HANDLE> multiq

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/pkt_sched.h |    7 ++++
 tc/Makefile               |    1 +
 tc/q_multiq.c             |   87 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 95 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_multiq.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e5de421..5d921fa 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -123,6 +123,13 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+/* MULTIQ section */
+
+struct tc_multiq_qopt {
+	__u16	bands;			/* Number of bands */
+	__u16	max_bands;		/* Maximum number of queues */
+};
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/tc/Makefile b/tc/Makefile
index 2fdfdc8..bd9b833 100644
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
index 0000000..306e170
--- /dev/null
+++ b/tc/q_multiq.c
@@ -0,0 +1,87 @@
+/*
+ * q_multiq.c		Multiqueue aware qdisc
+ *
+ * Copyright (c) 2008, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
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
+	struct tc_multiq_qopt opt;
+
+	if (argc > 0) {
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
+
+	if (opt == NULL)
+		return 0;
+	if (RTA_PAYLOAD(opt) < sizeof(*qopt))
+		return 0;
+
+	qopt = RTA_DATA(opt);
+
+	fprintf(f, "bands %u/%u ", qopt->bands, qopt->max_bands);
+
+	return 0;
+}
+
+struct qdisc_util multiq_qdisc_util = {
+	.id	 	= "multiq",
+	.parse_qopt	= multiq_parse_opt,
+	.print_qopt	= multiq_print_opt,
+};

