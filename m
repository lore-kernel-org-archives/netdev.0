From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc: fq: support low_rate_threshold attribute
Date: Fri, 08 Sep 2017 14:12:59 -0700
Message-ID: <1504905179.15310.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34554 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756063AbdIHVNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:13:01 -0400
Received: by mail-pg0-f65.google.com with SMTP id v82so1801643pgb.1
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:13:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCA_FQ_LOW_RATE_THRESHOLD sch_fq attribute was added in linux-4.9

Tested:

lpaa5:/tmp# tc -qd add dev eth1 root fq
lpaa5:/tmp# tc -s qd sh dev eth1
qdisc fq 8003: root refcnt 5 limit 10000p flow_limit 1000p buckets 4096 \
 orphan_mask 4095 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3648 \
 initial_quantum 18240 low_rate_threshold 550Kbit refill_delay 40.0ms
 Sent 62139 bytes 395 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  116 flows (114 inactive, 0 throttled)
  1 gc, 0 highprio, 0 throttled
    
lpaa5:/tmp# ./netperf -H lpaa6 -t TCP_RR -l10 -- -q 500000 -r 300,300 -o P99_LATENCY
99th Percentile Latency Microseconds
7081
    
lpaa5:/tmp# tc qd replace dev eth1 root fq low_rate_threshold 10Mbit
lpaa5:/tmp# ./netperf -H lpaa6 -t TCP_RR -l10 -- -q 500000 -r 300,300 -o P99_LATENCY
99th Percentile Latency Microseconds
858


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_fq.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/tc/q_fq.c b/tc/q_fq.c
index c9efbfc4..45b2ffd9 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -55,6 +55,7 @@ static void explain(void)
 	fprintf(stderr, "              [ quantum BYTES ] [ initial_quantum BYTES ]\n");
 	fprintf(stderr, "              [ maxrate RATE  ] [ buckets NUMBER ]\n");
 	fprintf(stderr, "              [ [no]pacing ] [ refill_delay TIME ]\n");
+	fprintf(stderr, "              [ low_rate_threshold RATE ]\n");
 	fprintf(stderr, "              [ orphan_mask MASK]\n");
 }
 
@@ -79,6 +80,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned int initial_quantum;
 	unsigned int buckets = 0;
 	unsigned int maxrate;
+	unsigned int low_rate_threshold;
 	unsigned int defrate;
 	unsigned int refill_delay;
 	unsigned int orphan_mask;
@@ -90,6 +92,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	bool set_defrate = false;
 	bool set_refill_delay = false;
 	bool set_orphan_mask = false;
+	bool set_low_rate_threshold = false;
 	int pacing = -1;
 	struct rtattr *tail;
 
@@ -121,6 +124,13 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				return -1;
 			}
 			set_maxrate = true;
+		} else if (strcmp(*argv, "low_rate_threshold") == 0) {
+			NEXT_ARG();
+			if (get_rate(&low_rate_threshold, *argv)) {
+				fprintf(stderr, "Illegal \"low_rate_threshold\"\n");
+				return -1;
+			}
+			set_low_rate_threshold = true;
 		} else if (strcmp(*argv, "defrate") == 0) {
 			NEXT_ARG();
 			if (get_rate(&defrate, *argv)) {
@@ -196,6 +206,9 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (set_maxrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
 			  &maxrate, sizeof(maxrate));
+	if (set_low_rate_threshold)
+		addattr_l(n, 1024, TCA_FQ_LOW_RATE_THRESHOLD,
+			  &low_rate_threshold, sizeof(low_rate_threshold));
 	if (set_defrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
 			  &defrate, sizeof(defrate));
@@ -276,6 +289,13 @@ static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		if (rate != 0)
 			fprintf(f, "defrate %s ", sprint_rate(rate, b1));
 	}
+	if (tb[TCA_FQ_LOW_RATE_THRESHOLD] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_LOW_RATE_THRESHOLD]) >= sizeof(__u32)) {
+		rate = rta_getattr_u32(tb[TCA_FQ_LOW_RATE_THRESHOLD]);
+
+		if (rate != 0)
+			fprintf(f, "low_rate_threshold %s ", sprint_rate(rate, b1));
+	}
 	if (tb[TCA_FQ_FLOW_REFILL_DELAY] &&
 	    RTA_PAYLOAD(tb[TCA_FQ_FLOW_REFILL_DELAY]) >= sizeof(__u32)) {
 		refill_delay = rta_getattr_u32(tb[TCA_FQ_FLOW_REFILL_DELAY]);
