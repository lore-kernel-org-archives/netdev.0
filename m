From: Terry Lam <vtlam@google.com>
Subject: [PATCH] iproute2 support for Heavy Hitter Filter (HHF) qdisc.
Date: Thu,  9 Jan 2014 00:23:11 -0800
Message-ID: <1389255791-16964-1-git-send-email-vtlam@google.com>
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>,
	Terry Lam <vtlam@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:42629 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbaAIIXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 03:23:19 -0500
Received: by mail-pb0-f73.google.com with SMTP id rq2so383920pbb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 00:23:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$tc qdisc add dev eth0 hhf help
Usage: ... hhf [ limit PACKETS ] [ quantum BYTES]
               [ hh_limit NUMBER ]
               [ reset_timeout TIME ]
               [ admit_bytes BYTES ]
               [ evict_timeout TIME ]
               [ non_hh_weight NUMBER ]

$tc -s -d qdisc show dev eth0
qdisc hhf 8005: root refcnt 32 limit 1000p quantum 1514 hh_limit 2048
reset_timeout 40.0ms admit_bytes 131072 evict_timeout 1.0s non_hh_weight 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
    drop_overlimit 0 hh_overlimit 0 tot_hh 0 cur_hh 0

HHF qdisc parameters:
- limit: max number of packets in qdisc (default 1000)
- quantum: max deficit per RR round (default 1 MTU)
- hh_limit: max number of HHs to keep states (default 2048)
- reset_timeout: time to reset HHF counters (default 40ms)
- admit_bytes: counter thresh to classify as HH (default 128KB)
- evict_timeout: threshold to evict idle HHs (default 1s)
- non_hh_weight:  DRR weight for mice (default 2)

Signed-off-by: Terry Lam <vtlam@google.com>
---
 include/linux/pkt_sched.h |  23 ++++++
 tc/Makefile               |   1 +
 tc/q_hhf.c                | 199 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 223 insertions(+)
 create mode 100644 tc/q_hhf.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index a806687..ddd6577 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -790,4 +790,27 @@ struct tc_fq_qd_stats {
 	__u32	throttled_flows;
 	__u32	pad;
 };
+
+/* Heavy-Hitter Filter */
+
+enum {
+	TCA_HHF_UNSPEC,
+	TCA_HHF_BACKLOG_LIMIT,
+	TCA_HHF_QUANTUM,
+	TCA_HHF_HH_FLOWS_LIMIT,
+	TCA_HHF_RESET_TIMEOUT,
+	TCA_HHF_ADMIT_BYTES,
+	TCA_HHF_EVICT_TIMEOUT,
+	TCA_HHF_NON_HH_WEIGHT,
+	__TCA_HHF_MAX
+};
+
+#define TCA_HHF_MAX	(__TCA_HHF_MAX - 1)
+
+struct tc_hhf_xstats {
+	__u32	drop_overlimit; /* number of time qdisc packet limit was hit */
+	__u32	hh_overlimit;   /* number of time max heavy-hitters was hit */
+	__u32	hh_tot_count;   /* number of captured heavy-hitters so far */
+	__u32	hh_cur_count;   /* number of current heavy-hitters */
+};
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index 84215c0..7c6e66e 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -53,6 +53,7 @@ TCMODULES += q_mqprio.o
 TCMODULES += q_codel.o
 TCMODULES += q_fq_codel.o
 TCMODULES += q_fq.o
+TCMODULES += q_hhf.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
   ifeq ($(TC_CONFIG_XT), y)
diff --git a/tc/q_hhf.c b/tc/q_hhf.c
new file mode 100644
index 0000000..06ec8a2
--- /dev/null
+++ b/tc/q_hhf.c
@@ -0,0 +1,199 @@
+/* q_hhf.c		Heavy-Hitter Filter (HHF)
+ *
+ * Copyright (C) 2013 Terry Lam <vtlam@google.com>
+ */
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
+	fprintf(stderr, "Usage: ... hhf [ limit PACKETS ] [ quantum BYTES]\n");
+	fprintf(stderr, "               [ hh_limit NUMBER ]\n");
+	fprintf(stderr, "               [ reset_timeout TIME ]\n");
+	fprintf(stderr, "               [ admit_bytes BYTES ]\n");
+	fprintf(stderr, "               [ evict_timeout TIME ]\n");
+	fprintf(stderr, "               [ non_hh_weight NUMBER ]\n");
+}
+
+static int hhf_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	unsigned limit = 0;
+	unsigned quantum = 0;
+	unsigned hh_limit = 0;
+	unsigned reset_timeout = 0;
+	unsigned admit_bytes = 0;
+	unsigned evict_timeout = 0;
+	unsigned non_hh_weight = 0;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "quantum") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&quantum, *argv, 0)) {
+				fprintf(stderr, "Illegal \"quantum\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "hh_limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&hh_limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"hh_limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "reset_timeout") == 0) {
+			NEXT_ARG();
+			if (get_time(&reset_timeout, *argv)) {
+				fprintf(stderr, "Illegal \"reset_timeout\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "admit_bytes") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&admit_bytes, *argv, 0)) {
+				fprintf(stderr, "Illegal \"admit_bytes\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "evict_timeout") == 0) {
+			NEXT_ARG();
+			if (get_time(&evict_timeout, *argv)) {
+				fprintf(stderr, "Illegal \"evict_timeout\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "non_hh_weight") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&non_hh_weight, *argv, 0)) {
+				fprintf(stderr, "Illegal \"non_hh_weight\"\n");
+				return -1;
+			}
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
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (limit)
+		addattr_l(n, 1024, TCA_HHF_BACKLOG_LIMIT, &limit,
+			  sizeof(limit));
+	if (quantum)
+		addattr_l(n, 1024, TCA_HHF_QUANTUM, &quantum, sizeof(quantum));
+	if (hh_limit)
+		addattr_l(n, 1024, TCA_HHF_HH_FLOWS_LIMIT, &hh_limit,
+			  sizeof(hh_limit));
+	if (reset_timeout)
+		addattr_l(n, 1024, TCA_HHF_RESET_TIMEOUT, &reset_timeout,
+			  sizeof(reset_timeout));
+	if (admit_bytes)
+		addattr_l(n, 1024, TCA_HHF_ADMIT_BYTES, &admit_bytes,
+			  sizeof(admit_bytes));
+	if (evict_timeout)
+		addattr_l(n, 1024, TCA_HHF_EVICT_TIMEOUT, &evict_timeout,
+			  sizeof(evict_timeout));
+	if (non_hh_weight)
+		addattr_l(n, 1024, TCA_HHF_NON_HH_WEIGHT, &non_hh_weight,
+			  sizeof(non_hh_weight));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int hhf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_HHF_MAX + 1];
+	unsigned limit;
+	unsigned quantum;
+	unsigned hh_limit;
+	unsigned reset_timeout;
+	unsigned admit_bytes;
+	unsigned evict_timeout;
+	unsigned non_hh_weight;
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_HHF_MAX, opt);
+
+	if (tb[TCA_HHF_BACKLOG_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_BACKLOG_LIMIT]) >= sizeof(__u32)) {
+		limit = rta_getattr_u32(tb[TCA_HHF_BACKLOG_LIMIT]);
+		fprintf(f, "limit %up ", limit);
+	}
+	if (tb[TCA_HHF_QUANTUM] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_QUANTUM]) >= sizeof(__u32)) {
+		quantum = rta_getattr_u32(tb[TCA_HHF_QUANTUM]);
+		fprintf(f, "quantum %u ", quantum);
+	}
+	if (tb[TCA_HHF_HH_FLOWS_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_HH_FLOWS_LIMIT]) >= sizeof(__u32)) {
+		hh_limit = rta_getattr_u32(tb[TCA_HHF_HH_FLOWS_LIMIT]);
+		fprintf(f, "hh_limit %u ", hh_limit);
+	}
+	if (tb[TCA_HHF_RESET_TIMEOUT] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_RESET_TIMEOUT]) >= sizeof(__u32)) {
+		reset_timeout = rta_getattr_u32(tb[TCA_HHF_RESET_TIMEOUT]);
+		fprintf(f, "reset_timeout %s ", sprint_time(reset_timeout, b1));
+	}
+	if (tb[TCA_HHF_ADMIT_BYTES] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_ADMIT_BYTES]) >= sizeof(__u32)) {
+		admit_bytes = rta_getattr_u32(tb[TCA_HHF_ADMIT_BYTES]);
+		fprintf(f, "admit_bytes %u ", admit_bytes);
+	}
+	if (tb[TCA_HHF_EVICT_TIMEOUT] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_EVICT_TIMEOUT]) >= sizeof(__u32)) {
+		evict_timeout = rta_getattr_u32(tb[TCA_HHF_EVICT_TIMEOUT]);
+		fprintf(f, "evict_timeout %s ", sprint_time(evict_timeout, b1));
+	}
+	if (tb[TCA_HHF_NON_HH_WEIGHT] &&
+	    RTA_PAYLOAD(tb[TCA_HHF_NON_HH_WEIGHT]) >= sizeof(__u32)) {
+		non_hh_weight = rta_getattr_u32(tb[TCA_HHF_NON_HH_WEIGHT]);
+		fprintf(f, "non_hh_weight %u ", non_hh_weight);
+	}
+	return 0;
+}
+
+static int hhf_print_xstats(struct qdisc_util *qu, FILE *f,
+			    struct rtattr *xstats)
+{
+	struct tc_hhf_xstats *st;
+
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+
+	fprintf(f, "  drop_overlimit %u hh_overlimit %u tot_hh %u cur_hh %u",
+		st->drop_overlimit, st->hh_overlimit,
+		st->hh_tot_count, st->hh_cur_count);
+	return 0;
+}
+
+struct qdisc_util hhf_qdisc_util = {
+	.id		= "hhf",
+	.parse_qopt	= hhf_parse_opt,
+	.print_qopt	= hhf_print_opt,
+	.print_xstats	= hhf_print_xstats,
+};
-- 
1.8.5.1
