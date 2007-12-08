From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH iproute2] rlim qdisc support.
Date: Fri, 7 Dec 2007 16:29:51 -0800
Message-ID: <20071207162951.6e17ccca@freepuppy.rosehill>
References: <20071207162618.35715892@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42006 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751578AbXLHAa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 19:30:58 -0500
In-Reply-To: <20071207162618.35715892@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setup code for new rlim qdisc. For use by anyone who wants to
test rlim before kernel inclusion.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/pkt_sched.h |    6 ++
 tc/Makefile               |    1 +
 tc/q_rlim.c               |  115 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 122 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_rlim.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 919af93..7973dc4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -475,4 +475,10 @@ struct tc_netem_corrupt
 
 #define NETEM_DIST_SCALE	8192
 
+struct tc_rlim_qopt
+{
+	__u32   limit;		/* fifo limit (packets) */
+	__u32	rate;		/* bits per sec */
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index a715566..e46954d 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -13,6 +13,7 @@ TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += q_rr.o
 TCMODULES += q_netem.o
+TCMODULES += q_rlim.o
 TCMODULES += f_rsvp.o
 TCMODULES += f_u32.o
 TCMODULES += f_route.o
diff --git a/tc/q_rlim.c b/tc/q_rlim.c
new file mode 100644
index 0000000..5f634a8
--- /dev/null
+++ b/tc/q_rlim.c
@@ -0,0 +1,115 @@
+/*
+ * q_rlim.c		RLIM.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@linux-foundation.org>
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
+	fprintf(stderr, "Usage: ... rlim limit PACKETS rate KBPS\n");
+}
+
+static void explain1(char *arg)
+{
+	fprintf(stderr, "Illegal \"%s\"\n", arg);
+}
+
+
+#define usage() return(-1)
+
+static int rlim_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tc_rlim_qopt opt;
+	unsigned x;
+
+	memset(&opt, 0, sizeof(opt));
+
+	while (argc > 0) {
+		if (matches(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (opt.limit) {
+				fprintf(stderr, "Double \"limit\" spec\n");
+				return -1;
+			}
+			if (get_size(&opt.limit, *argv)) {
+				explain1("limit");
+				return -1;
+			}
+		} else if (strcmp(*argv, "rate") == 0) {
+			NEXT_ARG();
+			if (opt.rate) {
+				fprintf(stderr, "Double \"rate\" spec\n");
+				return -1;
+			}
+
+			if (get_rate(&x, *argv)) {
+				explain1("rate");
+				return -1;
+			}
+			opt.rate = x;
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
+	if (opt.rate == 0) {
+		fprintf(stderr, "\"rate\" is required.\n");
+		return -1;
+	}
+
+	if (opt.limit == 0) {
+		fprintf(stderr, "\"limit\" is required.\n");
+		return -1;
+	}
+
+	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	return 0;
+}
+
+static int rlim_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct tc_rlim_qopt *qopt;
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(opt)  < sizeof(*qopt))
+		return -1;
+	qopt = RTA_DATA(opt);
+	fprintf(f, "limit %up rate %s", qopt->limit, sprint_rate(qopt->rate, b1));
+
+	return 0;
+}
+
+struct qdisc_util rlim_qdisc_util = {
+	.id		= "rlim",
+	.parse_qopt	= rlim_parse_opt,
+	.print_qopt	= rlim_print_opt,
+};
+
-- 
1.5.3.4

