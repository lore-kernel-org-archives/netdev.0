From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC,
 iproute2 PATCH v2] tc/mqprio: Offload mode and shaper options in
 mqprio
Date: Thu, 07 Sep 2017 04:03:47 -0700
Message-ID: <150478222784.24794.2140314459685193340.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, amritha.nambiar@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61588 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753927AbdIGLEx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 07:04:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds new mqprio options for 'mode' and 'shaper'. The mode
option can take values for offload modes such as 'dcb' (default),
'channel' with the 'hw' option set to 1. The 'shaper' option is
to support HW shapers ('dcb' default) and takes the value
'bw_rlimit' for bandwidth rate limiting. The parameters to the
bw_rlimit shaper are minimum and maximum bandwidth rates.
New HW shapers in future can be supported through the shaper
attribute.

# tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
  queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
  min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit

# tc qdisc show dev eth0

qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
             queues:(0:3) (4:7)
             mode:channel
             shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gbit

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/linux/pkt_sched.h |   32 ++++++++
 tc/q_mqprio.c             |  191 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 216 insertions(+), 7 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf55..e95b5c9 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -625,6 +625,22 @@ enum {
 
 #define TC_MQPRIO_HW_OFFLOAD_MAX (__TC_MQPRIO_HW_OFFLOAD_MAX - 1)
 
+enum {
+	TC_MQPRIO_MODE_DCB,
+	TC_MQPRIO_MODE_CHANNEL,
+	__TC_MQPRIO_MODE_MAX
+};
+
+#define __TC_MQPRIO_MODE_MAX (__TC_MQPRIO_MODE_MAX - 1)
+
+enum {
+	TC_MQPRIO_SHAPER_DCB,
+	TC_MQPRIO_SHAPER_BW_RATE,	/* Add new shapers below */
+	__TC_MQPRIO_SHAPER_MAX
+};
+
+#define __TC_MQPRIO_SHAPER_MAX (__TC_MQPRIO_SHAPER_MAX - 1)
+
 struct tc_mqprio_qopt {
 	__u8	num_tc;
 	__u8	prio_tc_map[TC_QOPT_BITMASK + 1];
@@ -633,6 +649,22 @@ struct tc_mqprio_qopt {
 	__u16	offset[TC_QOPT_MAX_QUEUE];
 };
 
+#define TC_MQPRIO_F_MODE		0x1
+#define TC_MQPRIO_F_SHAPER		0x2
+#define TC_MQPRIO_F_MIN_RATE		0x4
+#define TC_MQPRIO_F_MAX_RATE		0x8
+
+enum {
+	TCA_MQPRIO_UNSPEC,
+	TCA_MQPRIO_MODE,
+	TCA_MQPRIO_SHAPER,
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
index d6718fb..5fec63d 100644
--- a/tc/q_mqprio.c
+++ b/tc/q_mqprio.c
@@ -27,6 +27,10 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]\n");
 	fprintf(stderr, "                  [queues count1@offset1 count2@offset2 ...] ");
 	fprintf(stderr, "[hw 1|0]\n");
+	fprintf(stderr, "                  [mode dcb|channel]\n");
+	fprintf(stderr, "                  [shaper bw_rlimit SHAPER_PARAMS]\n"
+		"Where: SHAPER_PARAMS := { min_rate MIN_RATE1 MIN_RATE2 ...|\n"
+		"                          max_rate MAX_RATE1 MAX_RATE2 ... }\n");
 }
 
 static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
@@ -40,6 +44,12 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 		.count = { },
 		.offset = { },
 	};
+	__u64 min_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	__u64 max_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	__u16 shaper = TC_MQPRIO_SHAPER_DCB;
+	__u16 mode = TC_MQPRIO_MODE_DCB;
+	struct rtattr *tail;
+	__u32 flags = 0;
 
 	while (argc > 0) {
 		idx = 0;
@@ -92,6 +102,68 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 				return -1;
 			}
 			idx++;
+		} else if (opt.hw && strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "dcb") == 0) {
+				mode = TC_MQPRIO_MODE_DCB;
+			} else if (matches(*argv, "channel") == 0) {
+				mode = TC_MQPRIO_MODE_CHANNEL;
+			}  else {
+				fprintf(stderr, "Illegal mode (%s)\n",
+					*argv);
+				return -1;
+			}
+			if (mode != TC_MQPRIO_MODE_DCB)
+				flags |= TC_MQPRIO_F_MODE;
+			idx++;
+		} else if (opt.hw && strcmp(*argv, "shaper") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "dcb") == 0) {
+				shaper = TC_MQPRIO_SHAPER_DCB;
+			} else if (matches(*argv, "bw_rlimit") == 0) {
+				shaper = TC_MQPRIO_SHAPER_BW_RATE;
+				if (!NEXT_ARG_OK()) {
+					fprintf(stderr, "Incomplete shaper arguments\n");
+					return -1;
+				}
+			}  else {
+				fprintf(stderr, "Illegal shaper (%s)\n",
+					*argv);
+				return -1;
+			}
+			if (shaper != TC_MQPRIO_SHAPER_DCB)
+				flags |= TC_MQPRIO_F_SHAPER;
+			idx++;
+		} else if ((shaper == TC_MQPRIO_SHAPER_BW_RATE) &&
+			   strcmp(*argv, "min_rate") == 0) {
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				NEXT_ARG();
+				if (get_rate64(&min_rate64[idx], *argv)) {
+					PREV_ARG();
+					break;
+				}
+				idx++;
+			}
+			if ((idx < opt.num_tc) && !NEXT_ARG_OK()) {
+				fprintf(stderr, "Incomplete arguments, min_rate values expected\n");
+				return -1;
+			}
+			flags |= TC_MQPRIO_F_MIN_RATE;
+		} else if ((shaper == TC_MQPRIO_SHAPER_BW_RATE) &&
+			   strcmp(*argv, "max_rate") == 0) {
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				NEXT_ARG();
+				if (get_rate64(&max_rate64[idx], *argv)) {
+					PREV_ARG();
+					break;
+				}
+				idx++;
+			}
+			if ((idx < opt.num_tc) && !NEXT_ARG_OK()) {
+				fprintf(stderr, "Incomplete arguments, max_rate values expected\n");
+				return -1;
+			}
+			flags |= TC_MQPRIO_F_MAX_RATE;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -102,27 +174,132 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 		argc--; argv++;
 	}
 
+	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+
+	if (flags & TC_MQPRIO_F_MODE)
+		addattr_l(n, 1024, TCA_MQPRIO_MODE,
+			  &mode, sizeof(mode));
+	if (flags & TC_MQPRIO_F_SHAPER)
+		addattr_l(n, 1024, TCA_MQPRIO_SHAPER,
+			  &shaper, sizeof(shaper));
+
+	if (flags & TC_MQPRIO_F_MIN_RATE) {
+		struct rtattr *start;
+
+		start = addattr_nest(n, 1024,
+				     TCA_MQPRIO_MIN_RATE64 | NLA_F_NESTED);
+
+		for (idx = 0; idx < TC_QOPT_MAX_QUEUE; idx++)
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
+		for (idx = 0; idx < TC_QOPT_MAX_QUEUE; idx++)
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
+	__u64 min_rate64[TC_QOPT_MAX_QUEUE] = {0};
+	__u64 max_rate64[TC_QOPT_MAX_QUEUE] = {0};
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
+
+	if (len > 0) {
+		struct rtattr *tb[TCA_MQPRIO_MAX + 1];
+
+		parse_rtattr(tb, TCA_MQPRIO_MAX,
+			     RTA_DATA(opt) + RTA_ALIGN(sizeof(qopt)),
+			     len);
+
+		if (tb[TCA_MQPRIO_MODE]) {
+			__u16 *mode = RTA_DATA(tb[TCA_MQPRIO_MODE]);
+
+			if (*mode == TC_MQPRIO_MODE_CHANNEL)
+				fprintf(f, "\n             mode:channel");
+		} else {
+			fprintf(f, "\n             mode:dcb");
+		}
+
+		if (tb[TCA_MQPRIO_SHAPER]) {
+			__u16 *shaper = RTA_DATA(tb[TCA_MQPRIO_SHAPER]);
+
+			if (*shaper == TC_MQPRIO_SHAPER_BW_RATE)
+				fprintf(f, "\n             shaper:bw_rlimit");
+		} else {
+			fprintf(f, "\n             shaper:dcb");
+		}
+
+		if (tb[TCA_MQPRIO_MIN_RATE64]) {
+			struct rtattr *r;
+			int rem = RTA_PAYLOAD(tb[TCA_MQPRIO_MIN_RATE64]);
+			__u64 *min = min_rate64;
+
+			for (r = RTA_DATA(tb[TCA_MQPRIO_MIN_RATE64]);
+			     RTA_OK(r, rem); r = RTA_NEXT(r, rem)) {
+				if (r->rta_type != TCA_MQPRIO_MIN_RATE64)
+					return -1;
+				*(min++) = rta_getattr_u64(r);
+			}
+			fprintf(f, "	min_rate:");
+			for (i = 0; i < qopt.num_tc; i++)
+				fprintf(f, "%s ", sprint_rate(min_rate64[i], b1));
+		}
+
+		if (tb[TCA_MQPRIO_MAX_RATE64]) {
+			struct rtattr *r;
+			int rem = RTA_PAYLOAD(tb[TCA_MQPRIO_MAX_RATE64]);
+			__u64 *max = max_rate64;
+
+			for (r = RTA_DATA(tb[TCA_MQPRIO_MAX_RATE64]);
+			     RTA_OK(r, rem); r = RTA_NEXT(r, rem)) {
+				if (r->rta_type != TCA_MQPRIO_MAX_RATE64)
+					return -1;
+				*(max++) = rta_getattr_u64(r);
+			}
+			fprintf(f, "	max_rate:");
+			for (i = 0; i < qopt.num_tc; i++)
+				fprintf(f, "%s ", sprint_rate(max_rate64[i], b1));
+		}
+	}
 	return 0;
 }
 
