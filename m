From: Phil Sutter <phil@nwl.cc>
Subject: [iproute2 PATCH] tc: fq: allow setting and retrieving flow refill delay
Date: Thu, 10 Sep 2015 16:25:47 +0200
Message-ID: <1441895147-18388-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fw@strlen.de
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45734 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289AbbIJOZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 10:25:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code to parse and export this tuneable via netlink is already present in
sched_fq.c of the kernel, so not making it accessible for users would be
a waste of resources.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/q_fq.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/tc/q_fq.c b/tc/q_fq.c
index e7288c2..7ad3801 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -54,7 +54,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... fq [ limit PACKETS ] [ flow_limit PACKETS ]\n");
 	fprintf(stderr, "              [ quantum BYTES ] [ initial_quantum BYTES ]\n");
 	fprintf(stderr, "              [ maxrate RATE  ] [ buckets NUMBER ]\n");
-	fprintf(stderr, "              [ [no]pacing ]\n");
+	fprintf(stderr, "              [ [no]pacing ] [ refill_delay TIME ]\n");
 }
 
 static unsigned int ilog2(unsigned int val)
@@ -79,12 +79,14 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned int buckets = 0;
 	unsigned int maxrate;
 	unsigned int defrate;
+	unsigned int refill_delay;
 	bool set_plimit = false;
 	bool set_flow_plimit = false;
 	bool set_quantum = false;
 	bool set_initial_quantum = false;
 	bool set_maxrate = false;
 	bool set_defrate = false;
+	bool set_refill_delay = false;
 	int pacing = -1;
 	struct rtattr *tail;
 
@@ -137,6 +139,13 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				return -1;
 			}
 			set_initial_quantum = true;
+		} else if (strcmp(*argv, "refill_delay") == 0) {
+			NEXT_ARG();
+			if (get_time(&refill_delay, *argv)) {
+				fprintf(stderr, "Illegal \"refill_delay\"\n");
+				return -1;
+			}
+			set_refill_delay = true;
 		} else if (strcmp(*argv, "pacing") == 0) {
 			pacing = 1;
 		} else if (strcmp(*argv, "nopacing") == 0) {
@@ -180,6 +189,9 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (set_defrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
 			  &defrate, sizeof(defrate));
+	if (set_refill_delay)
+		addattr_l(n, 1024, TCA_FQ_FLOW_REFILL_DELAY,
+		          &refill_delay, sizeof(refill_delay));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -191,6 +203,7 @@ static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	unsigned int buckets_log;
 	int pacing;
 	unsigned int rate, quantum;
+	unsigned int refill_delay;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -243,6 +256,11 @@ static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		if (rate != 0)
 			fprintf(f, "defrate %s ", sprint_rate(rate, b1));
 	}
+	if (tb[TCA_FQ_FLOW_REFILL_DELAY] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_FLOW_REFILL_DELAY]) >= sizeof(__u32)) {
+		refill_delay = rta_getattr_u32(tb[TCA_FQ_FLOW_REFILL_DELAY]);
+		fprintf(f, "refill_delay %s ", sprint_time(refill_delay, b1));
+	}
 
 	return 0;
 }
-- 
2.1.2
