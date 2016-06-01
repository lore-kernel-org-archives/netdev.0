From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] fq_codel: add per queue memory limit
Date: Wed, 01 Jun 2016 07:23:31 -0700
Message-ID: <1464791011.5939.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33942 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbcFAOXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 10:23:35 -0400
Received: by mail-pf0-f194.google.com with SMTP id c84so4027972pfc.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 07:23:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch adds support for TCA_FQ_CODEL_MEMORY_LIMIT attribute.

# tc qd replace dev eth1 root est 1sec 4sec fq_codel memory_limit 4M
..
# tc -s -d qd sh dev eth1
qdisc fq_codel 8008: root refcnt 257 limit 10240p flows 1024
 quantum 1514 target 5.0ms interval 100.0ms memory_limit 4Mb ecn
 Sent 2083566791363 bytes 1376214889 pkt (dropped 4994406, overlimits 0
requeues 21705223)
 rate 9841Mbit 812549pps backlog 3906120b 376p requeues 21705223
  maxpacket 68130 drop_overlimit 4994406 new_flow_count 28855414
  ecn_mark 0 memory_used 4190048 drop_overmemory 4994406
new_flows_len 1 old_flows_len 177

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_fq_codel.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
index 4f747eb..c0137a7 100644
--- a/tc/q_fq_codel.c
+++ b/tc/q_fq_codel.c
@@ -65,6 +65,7 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned interval = 0;
 	unsigned quantum = 0;
 	unsigned ce_threshold = ~0U;
+	unsigned memory = ~0U;
 	int ecn = -1;
 	struct rtattr *tail;
 
@@ -99,6 +100,12 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"ce_threshold\"\n");
 				return -1;
 			}
+		} else if (strcmp(*argv, "memory_limit") == 0) {
+			NEXT_ARG();
+			if (get_size(&memory, *argv)) {
+				fprintf(stderr, "Illegal \"memory_limit\"\n");
+				return -1;
+			}
 		} else if (strcmp(*argv, "interval") == 0) {
 			NEXT_ARG();
 			if (get_time(&interval, *argv)) {
@@ -137,6 +144,10 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (ce_threshold != ~0U)
 		addattr_l(n, 1024, TCA_FQ_CODEL_CE_THRESHOLD,
 			  &ce_threshold, sizeof(ce_threshold));
+	if (memory != ~0U)
+		addattr_l(n, 1024, TCA_FQ_CODEL_MEMORY_LIMIT,
+			  &memory, sizeof(memory));
+
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -151,6 +162,7 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 	unsigned ecn;
 	unsigned quantum;
 	unsigned ce_threshold;
+	unsigned memory_limit;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -188,6 +200,12 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 		interval = rta_getattr_u32(tb[TCA_FQ_CODEL_INTERVAL]);
 		fprintf(f, "interval %s ", sprint_time(interval, b1));
 	}
+	if (tb[TCA_FQ_CODEL_MEMORY_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_MEMORY_LIMIT]) >= sizeof(__u32)) {
+		memory_limit = rta_getattr_u32(tb[TCA_FQ_CODEL_MEMORY_LIMIT]);
+
+		fprintf(f, "memory_limit %s ", sprint_size(memory_limit, b1));
+	}
 	if (tb[TCA_FQ_CODEL_ECN] &&
 	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_ECN]) >= sizeof(__u32)) {
 		ecn = rta_getattr_u32(tb[TCA_FQ_CODEL_ECN]);
@@ -221,6 +239,10 @@ static int fq_codel_print_xstats(struct qdisc_util *qu, FILE *f,
 			st->qdisc_stats.ecn_mark);
 		if (st->qdisc_stats.ce_mark)
 			fprintf(f, " ce_mark %u", st->qdisc_stats.ce_mark);
+		if (st->qdisc_stats.memory_usage)
+			fprintf(f, " memory_used %u", st->qdisc_stats.memory_usage);
+		if (st->qdisc_stats.drop_overmemory)
+			fprintf(f, " drop_overmemory %u", st->qdisc_stats.drop_overmemory);
 		fprintf(f, "\n  new_flows_len %u old_flows_len %u",
 			st->qdisc_stats.new_flows_len,
 			st->qdisc_stats.old_flows_len);
