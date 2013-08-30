From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 29 Aug 2013 19:30:36 -0700
Message-ID: <1377829836.8277.59.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	 <20130829.214730.2158572637993114547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:59173 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab3H3Cak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 22:30:40 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so1244825pbc.31
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 19:30:39 -0700 (PDT)
In-Reply-To: <20130829.214730.2158572637993114547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Support for FQ packet scheduler

$ tc qd add dev eth0 root fq help
Usage: ... fq [ limit PACKETS ] [ flow_limit PACKETS ]
              [ quantum BYTES ] [ initial_quantum BYTES ]
              [ maxrate RATE  ] [ buckets NUMBER ]
              [ [no]pacing ]

$ tc -s -d qd
qdisc fq 8002: dev eth0 root refcnt 32 limit 10000p flow_limit 100p
buckets 256 quantum 3028 initial_quantum 15140
 Sent 216532416 bytes 148395 pkt (dropped 0, overlimits 0 requeues 14)
 backlog 0b 0p requeues 14
  511 flows (511 inactive, 0 throttled)
  110 gc, 0 highprio, 0 retrans, 1143 throttled, 0 flows_plimit


limit	: max number of packets on whole Qdisc (default 10000)

flow_limit : max number of packets per flow (default 100)

quantum : the max deficit per RR round (default is 2 MTU)

initial_quantum : initial credit for new flows (default is 10 MTU)

maxrate : max per flow rate (default : unlimited)

buckets : number of RB trees (default : 1024) in hash table.
               (consumes 8 bytes per bucket)

[no]pacing : disable/enable pacing (default is enable)


Usage :

tc qdisc add dev $ETH root fq


tc qdisc del dev $ETH root 2>/dev/null
tc qdisc add dev $ETH root handle 1: mq 
for i in `seq 1 4`
do
  tc qdisc add dev $ETH parent 1:$i est 1sec 4sec fq
done



Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/pkt_sched.h |   51 ++++++
 tc/Makefile               |    1 
 tc/q_fq.c                 |  279 ++++++++++++++++++++++++++++++++++++
 3 files changed, 330 insertions(+), 1 deletion(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbd71b0..9b82913 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -73,9 +73,17 @@ struct tc_estimator {
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 
+/* Need to corrospond to iproute2 tc/tc_core.h "enum link_layer" */
+enum tc_link_layer {
+	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
+	TC_LINKLAYER_ETHERNET,
+	TC_LINKLAYER_ATM,
+};
+#define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
+
 struct tc_ratespec {
 	unsigned char	cell_log;
-	unsigned char	__reserved;
+	__u8		linklayer; /* lower 4 bits */
 	unsigned short	overhead;
 	short		cell_align;
 	unsigned short	mpu;
@@ -736,4 +744,45 @@ struct tc_fq_codel_xstats {
 	};
 };
 
+/* FQ */
+
+enum {
+	TCA_FQ_UNSPEC,
+
+	TCA_FQ_PLIMIT,		/* limit of total number of packets in queue */
+
+	TCA_FQ_FLOW_PLIMIT,	/* limit of packets per flow */
+
+	TCA_FQ_QUANTUM,		/* RR quantum */
+
+	TCA_FQ_INITIAL_QUANTUM,		/* RR quantum for new flow */
+
+	TCA_FQ_RATE_ENABLE,	/* enable/disable rate limiting */
+
+	TCA_FQ_FLOW_DEFAULT_RATE,/* for sockets with unspecified sk_rate,
+				  * use the following rate
+				  */
+
+	TCA_FQ_FLOW_MAX_RATE,	/* per flow max rate */
+
+	TCA_FQ_BUCKETS_LOG,	/* log2(number of buckets) */
+	__TCA_FQ_MAX
+};
+
+#define TCA_FQ_MAX	(__TCA_FQ_MAX - 1)
+
+struct tc_fq_qd_stats {
+	__u64	gc_flows;
+	__u64	highprio_packets;
+	__u64	tcp_retrans;
+	__u64	throttled;
+	__u64	flows_plimit;
+	__u64	pkts_too_long;
+	__u64	allocation_errors;
+	__s64	time_next_delayed_flow;
+	__u32	flows;
+	__u32	inactive_flows;
+	__u32	throttled_flows;
+	__u32	pad;
+};
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index f26e764..1eeabd8 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -50,6 +50,7 @@ TCMODULES += em_meta.o
 TCMODULES += q_mqprio.o
 TCMODULES += q_codel.o
 TCMODULES += q_fq_codel.o
+TCMODULES += q_fq.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
   ifeq ($(TC_CONFIG_XT), y)
diff --git a/tc/q_fq.c b/tc/q_fq.c
new file mode 100644
index 0000000..c0bcdb9
--- /dev/null
+++ b/tc/q_fq.c
@@ -0,0 +1,279 @@
+/*
+ * Fair Queue
+ *
+ *  Copyright (C) 2013 Eric Dumazet <edumazet@google.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, and the following disclaimer,
+ *    without modification.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The names of the authors may not be used to endorse or promote products
+ *    derived from this software without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
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
+	fprintf(stderr, "Usage: ... fq [ limit PACKETS ] [ flow_limit PACKETS ]\n");
+	fprintf(stderr, "              [ quantum BYTES ] [ initial_quantum BYTES ]\n");
+	fprintf(stderr, "              [ maxrate RATE  ] [ buckets NUMBER ]\n");
+	fprintf(stderr, "              [ [no]pacing ]\n"); 
+}
+
+static unsigned int ilog2(unsigned int val)
+{
+	unsigned int res = 0;
+
+	val--;
+	while (val) {
+		res++;
+		val >>= 1;
+	}
+	return res;
+}
+
+static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			struct nlmsghdr *n)
+{
+	unsigned int plimit = ~0U;
+	unsigned int flow_plimit = ~0U;
+	unsigned int quantum = ~0U;
+	unsigned int initial_quantum = ~0U;
+	unsigned int buckets = 0;
+	unsigned int maxrate = ~0U;
+	unsigned int defrate = ~0U;
+	int pacing = -1;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&plimit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "flow_limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&flow_plimit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"flow_limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "buckets") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&buckets, *argv, 0)) {
+				fprintf(stderr, "Illegal \"buckets\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "maxrate") == 0) {
+			NEXT_ARG();
+			if (get_rate(&maxrate, *argv)) {
+				fprintf(stderr, "Illegal \"maxrate\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "defrate") == 0) {
+			NEXT_ARG();
+			if (get_rate(&defrate, *argv)) {
+				fprintf(stderr, "Illegal \"defrate\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "quantum") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&quantum, *argv, 0)) {
+				fprintf(stderr, "Illegal \"quantum\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "initial_quantum") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&initial_quantum, *argv, 0)) {
+				fprintf(stderr, "Illegal \"initial_quantum\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "pacing") == 0) {
+			pacing = 1;
+		} else if (strcmp(*argv, "nopacing") == 0) {
+			pacing = 0;
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
+	if (buckets) {
+		unsigned int log = ilog2(buckets);
+
+		addattr_l(n, 1024, TCA_FQ_BUCKETS_LOG,
+			  &log, sizeof(log));
+	}
+	if (plimit != ~0U)
+		addattr_l(n, 1024, TCA_FQ_PLIMIT,
+			  &plimit, sizeof(plimit));
+	if (flow_plimit != ~0U)
+		addattr_l(n, 1024, TCA_FQ_FLOW_PLIMIT,
+			  &flow_plimit, sizeof(flow_plimit));
+	if (quantum != ~0U)
+		addattr_l(n, 1024, TCA_FQ_QUANTUM, &quantum, sizeof(quantum));
+	if (initial_quantum != ~0U)
+		addattr_l(n, 1024, TCA_FQ_INITIAL_QUANTUM,
+			  &initial_quantum, sizeof(initial_quantum));
+	if (pacing != -1)
+		addattr_l(n, 1024, TCA_FQ_RATE_ENABLE,
+			  &pacing, sizeof(pacing));
+	if (maxrate != ~0U)
+		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
+			  &maxrate, sizeof(maxrate));
+	if (defrate != ~0U)
+		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
+			  &defrate, sizeof(defrate));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_FQ_MAX + 1];
+	unsigned int plimit, flow_plimit;
+	unsigned int buckets_log;
+	int pacing;
+	unsigned int rate, quantum;
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_FQ_MAX, opt);
+
+	if (tb[TCA_FQ_PLIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_PLIMIT]) >= sizeof(__u32)) {
+		plimit = rta_getattr_u32(tb[TCA_FQ_PLIMIT]);
+		fprintf(f, "limit %up ", plimit);
+	}
+	if (tb[TCA_FQ_FLOW_PLIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_FLOW_PLIMIT]) >= sizeof(__u32)) {
+		flow_plimit = rta_getattr_u32(tb[TCA_FQ_FLOW_PLIMIT]);
+		fprintf(f, "flow_limit %up ", flow_plimit);
+	}
+	if (tb[TCA_FQ_BUCKETS_LOG] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_BUCKETS_LOG]) >= sizeof(__u32)) {
+		buckets_log = rta_getattr_u32(tb[TCA_FQ_BUCKETS_LOG]);
+		fprintf(f, "buckets %u ", 1U << buckets_log);
+	}
+	if (tb[TCA_FQ_RATE_ENABLE] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_RATE_ENABLE]) >= sizeof(int)) {
+		pacing = rta_getattr_u32(tb[TCA_FQ_RATE_ENABLE]);
+		if (pacing == 0)
+			fprintf(f, "nopacing ");
+	}
+	if (tb[TCA_FQ_QUANTUM] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_QUANTUM]) >= sizeof(__u32)) {
+		quantum = rta_getattr_u32(tb[TCA_FQ_QUANTUM]);
+		fprintf(f, "quantum %u ", quantum);
+	}
+	if (tb[TCA_FQ_INITIAL_QUANTUM] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_INITIAL_QUANTUM]) >= sizeof(__u32)) {
+		quantum = rta_getattr_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
+		fprintf(f, "initial_quantum %u ", quantum);
+	}
+	if (tb[TCA_FQ_FLOW_MAX_RATE] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_FLOW_MAX_RATE]) >= sizeof(__u32)) {
+		rate = rta_getattr_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
+
+		if (rate != ~0U)
+			fprintf(f, "maxrate %s ", sprint_rate(rate, b1));
+	}
+	if (tb[TCA_FQ_FLOW_DEFAULT_RATE] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_FLOW_DEFAULT_RATE]) >= sizeof(__u32)) {
+		rate = rta_getattr_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
+
+		if (rate != 0)
+			fprintf(f, "defrate %s ", sprint_rate(rate, b1));
+	}
+
+	return 0;
+}
+
+static int fq_print_xstats(struct qdisc_util *qu, FILE *f,
+			   struct rtattr *xstats)
+{
+	struct tc_fq_qd_stats *st;
+
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+
+	fprintf(f, "  %u flows (%u inactive, %u throttled)",
+		st->flows, st->inactive_flows, st->throttled_flows);
+
+	if (st->time_next_delayed_flow > 0)
+		fprintf(f, ", next packet delay %llu ns", st->time_next_delayed_flow);
+
+	fprintf(f, "\n  %llu gc, %llu highprio",
+		st->gc_flows, st->highprio_packets);
+
+	if (st->tcp_retrans)
+		fprintf(f, ", %llu retrans", st->tcp_retrans);
+
+	fprintf(f, ", %llu throttled", st->throttled);
+
+	if (st->flows_plimit)
+		fprintf(f, ", %llu flows_plimit", st->flows_plimit);
+
+	if (st->pkts_too_long || st->allocation_errors)
+		fprintf(f, "\n  %llu too long pkts, %llu alloc errors\n",
+			st->pkts_too_long, st->allocation_errors);
+
+	return 0;
+}
+
+struct qdisc_util fq_qdisc_util = {
+	.id		= "fq",
+	.parse_qopt	= fq_parse_opt,
+	.print_qopt	= fq_print_opt,
+	.print_xstats	= fq_print_xstats,
+};
