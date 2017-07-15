From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH RFC,
 iproute2] tc/mqprio: Add support to configure bandwidth rate limit
 through mqprio
Date: Fri, 14 Jul 2017 18:26:13 -0700
Message-ID: <150008197300.6559.15065389482024982399.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        jeffrey.t.kirsher@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64188 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751329AbdGOB0n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 21:26:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support bandwidth rate limit information for a traffic
class in addition to the number of TCs and associated
queue configuration data. This is supported in the new
hardware offload mode in mqprio by setting the value of
'hw' option to 2. This new hardware offload mode in mqprio
makes full use of the mqprio options, the TCs, the
queue configurations and the bandwidth rates for the TCs.

# tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
  queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2

# tc qdisc show dev eth0

qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
             queues:(0:3) (4:7)
             min rates:0bit 0bit
             max rates:55Mbit 60Mbit

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/linux/pkt_sched.h |   12 ++++
 tc/q_mqprio.c             |  128 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 132 insertions(+), 8 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf55..bbad3ec 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -633,6 +633,18 @@ struct tc_mqprio_qopt {
 	__u16	offset[TC_QOPT_MAX_QUEUE];
 };
 
+#define TC_MQPRIO_F_MIN_RATE  0x1
+#define TC_MQPRIO_F_MAX_RATE  0x2
+
+enum {
+	TCA_MQPRIO_UNSPEC,
+	TCA_MQPRIO_MIN_RATE64,
+	TCA_MQPRIO_MAX_RATE64,
+	__TCA_MQPRIO_MAX,
+};
+
+#define TCA_MQPRIO_MAX (__TCA_MQPRIO_MAX - 1)
+
 /* SFB */
 
 enum {
diff --git a/tc/q_mqprio.c b/tc/q_mqprio.c
index fa1022b..b7826ac 100644
--- a/tc/q_mqprio.c
+++ b/tc/q_mqprio.c
@@ -26,7 +26,7 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]\n");
 	fprintf(stderr, "                  [queues count1@offset1 count2@offset2 ...] ");
-	fprintf(stderr, "[hw 1|0]\n");
+	fprintf(stderr, "[hw 2|1|0]\n");
 }
 
 static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
@@ -38,6 +38,10 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 				     {0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 1, 1, 3, 3, 3, 3},
 				     1,
 				    };
+	__u64 min_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	__u64 max_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	struct rtattr *tail;
+	__u32 flags = 0;
 
 	while (argc > 0) {
 		idx = 0;
@@ -83,6 +87,34 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 				free(tmp);
 				idx++;
 			}
+		} else if (strcmp(*argv, "min_rate") == 0) {
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				if (idx > opt.num_tc) {
+					fprintf(stderr, "Illegal number of min rates\n");
+					return -1;
+				}
+				NEXT_ARG();
+				if (get_rate64(&min_rate64[idx], *argv)) {
+					PREV_ARG();
+					break;
+				}
+				idx++;
+			}
+			flags |= TC_MQPRIO_F_MIN_RATE;
+		} else if (strcmp(*argv, "max_rate") == 0) {
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				if (idx > opt.num_tc) {
+					fprintf(stderr, "Illegal number of max rates\n");
+					return -1;
+				}
+				NEXT_ARG();
+				if (get_rate64(&max_rate64[idx], *argv)) {
+					PREV_ARG();
+					break;
+				}
+				idx++;
+			}
+			flags |= TC_MQPRIO_F_MAX_RATE;
 		} else if (strcmp(*argv, "hw") == 0) {
 			NEXT_ARG();
 			if (get_u8(&opt.hw, *argv, 10)) {
@@ -100,27 +132,107 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 		argc--; argv++;
 	}
 
+	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+
+	if (flags & TC_MQPRIO_F_MIN_RATE) {
+		struct rtattr *start;
+
+		start = addattr_nest(n, 1024,
+				     TCA_MQPRIO_MIN_RATE64 | NLA_F_NESTED);
+
+		for (idx = 0; idx < opt.num_tc; idx++)
+			addattr_l(n, 1024, TCA_MQPRIO_MIN_RATE64,
+				  &min_rate64[idx], sizeof(min_rate64[idx]));
+
+		addattr_nest_end(n, start);
+	}
+
+	if (flags & TC_MQPRIO_F_MAX_RATE) {
+		struct rtattr *start;
+
+		start = addattr_nest(n, 1024,
+				     TCA_MQPRIO_MAX_RATE64 | NLA_F_NESTED);
+
+		for (idx = 0; idx < opt.num_tc; idx++)
+			addattr_l(n, 1024, TCA_MQPRIO_MAX_RATE64,
+				  &max_rate64[idx], sizeof(max_rate64[idx]));
+
+		addattr_nest_end(n, start);
+	}
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+
 	return 0;
 }
 
 static int mqprio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	int i;
-	struct tc_mqprio_qopt *qopt;
+	struct tc_mqprio_qopt qopt;
+	__u64 min_rate64[TC_QOPT_MAX_QUEUE] = {0},
+					max_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	int len = RTA_PAYLOAD(opt) - RTA_ALIGN(sizeof(qopt));
+
+	SPRINT_BUF(b1);
 
 	if (opt == NULL)
 		return 0;
 
-	qopt = RTA_DATA(opt);
+	if (len < 0) {
+		fprintf(stderr, "options size error\n");
+		return -1;
+	}
+
+	memcpy(&qopt, RTA_DATA(opt), RTA_ALIGN(sizeof(qopt)));
+
+	if (len > 0) {
+		struct rtattr *tb[TCA_MQPRIO_MAX + 1];
+
+		parse_rtattr(tb, TCA_MQPRIO_MAX,
+			     RTA_DATA(opt) + RTA_ALIGN(sizeof(qopt)),
+			     len);
+
+		if (tb[TCA_MQPRIO_MIN_RATE64]) {
+			struct rtattr *i;
+			int rem = RTA_PAYLOAD(tb[TCA_MQPRIO_MIN_RATE64]);
+			__u64 *min = min_rate64;
+
+			for (i = RTA_DATA(tb[TCA_MQPRIO_MIN_RATE64]);
+			     RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+				if (i->rta_type != TCA_MQPRIO_MIN_RATE64)
+					return -1;
+				*(min++) = rta_getattr_u64(i);
+			}
+		}
+
+		if (tb[TCA_MQPRIO_MAX_RATE64]) {
+			struct rtattr *i;
+			int rem = RTA_PAYLOAD(tb[TCA_MQPRIO_MAX_RATE64]);
+			__u64 *max = max_rate64;
+
+			for (i = RTA_DATA(tb[TCA_MQPRIO_MAX_RATE64]);
+			     RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+				if (i->rta_type != TCA_MQPRIO_MAX_RATE64)
+					return -1;
+				*(max++) = rta_getattr_u64(i);
+			}
+		}
+	}
 
-	fprintf(f, " tc %u map ", qopt->num_tc);
+	fprintf(f, " tc %u map ", qopt.num_tc);
 	for (i = 0; i <= TC_PRIO_MAX; i++)
-		fprintf(f, "%u ", qopt->prio_tc_map[i]);
+		fprintf(f, "%u ", qopt.prio_tc_map[i]);
 	fprintf(f, "\n             queues:");
-	for (i = 0; i < qopt->num_tc; i++)
-		fprintf(f, "(%u:%u) ", qopt->offset[i],
-			qopt->offset[i] + qopt->count[i] - 1);
+	for (i = 0; i < qopt.num_tc; i++)
+		fprintf(f, "(%u:%u) ", qopt.offset[i],
+			qopt.offset[i] + qopt.count[i] - 1);
+	fprintf(f, "\n             min rates:");
+	for (i = 0; i < qopt.num_tc; i++)
+		fprintf(f, "%s ", sprint_rate(min_rate64[i], b1));
+	fprintf(f, "\n             max rates:");
+	for (i = 0; i < qopt.num_tc; i++)
+		fprintf(f, "%s ", sprint_rate(max_rate64[i], b1));
 	return 0;
 }
 
