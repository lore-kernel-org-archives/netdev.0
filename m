From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] codel: add ce_threshold support to codel & fc_codel
Date: Mon, 11 May 2015 10:44:55 -0700
Message-ID: <1431366295.566.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37854 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbEKRo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:44:58 -0400
Received: by igbsb11 with SMTP id sb11so77715539igb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:44:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

codel & fq_codel packet schedulers are now able to have a threshold
for CE marking packets, regardless of the drop/nodrop decision taken by
CoDel.

This is particularly useful for dctcp and variants, that do not use
traditional ECN.

Note that fq_codel users would have to specify noecn if ce_threshold is
used, otherwise results would be not very interesting, as ecn is default
on for fq_codel.

$ tc -s qdisc show dev eth1
qdisc codel 8002: root refcnt 45 limit 1000p target 5.0ms ce_threshold
1.0ms interval 100.0ms 
 Sent 4908469888317 bytes 3351813967 pkt (dropped 0, overlimits 0
requeues 21624365) 
 rate 37671Mbit 3231836pps backlog 4904740b 250p requeues 21624365 
  count 0 lastcount 0 ldelay 1.1ms drop_next 0us
  maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 410861803


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/pkt_sched.h |    4 ++++
 tc/q_codel.c              |   33 ++++++++++++++++++++++++++++-----
 tc/q_fq_codel.c           |   31 ++++++++++++++++++++++++++-----
 3 files changed, 58 insertions(+), 10 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 534b847..69d88b3 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -679,6 +679,7 @@ enum {
 	TCA_CODEL_LIMIT,
 	TCA_CODEL_INTERVAL,
 	TCA_CODEL_ECN,
+	TCA_CODEL_CE_THRESHOLD,
 	__TCA_CODEL_MAX
 };
 
@@ -695,6 +696,7 @@ struct tc_codel_xstats {
 	__u32	drop_overlimit; /* number of time max qdisc packet limit was hit */
 	__u32	ecn_mark;  /* number of packets we ECN marked instead of dropped */
 	__u32	dropping;  /* are we in dropping state ? */
+	__u32	ce_mark;   /* number of CE marked packets because of ce_threshold */
 };
 
 /* FQ_CODEL */
@@ -707,6 +709,7 @@ enum {
 	TCA_FQ_CODEL_ECN,
 	TCA_FQ_CODEL_FLOWS,
 	TCA_FQ_CODEL_QUANTUM,
+	TCA_FQ_CODEL_CE_THRESHOLD,
 	__TCA_FQ_CODEL_MAX
 };
 
@@ -730,6 +733,7 @@ struct tc_fq_codel_qd_stats {
 				 */
 	__u32	new_flows_len;	/* count of flows in new list */
 	__u32	old_flows_len;	/* count of flows in old list */
+	__u32	ce_mark;	/* packets above ce_threshold */
 };
 
 struct tc_fq_codel_cl_stats {
diff --git a/tc/q_codel.c b/tc/q_codel.c
index dc4b3f6..c24246c 100644
--- a/tc/q_codel.c
+++ b/tc/q_codel.c
@@ -4,7 +4,7 @@
  *  Copyright (C) 2011-2012 Kathleen Nichols <nichols@pollere.com>
  *  Copyright (C) 2011-2012 Van Jacobson <van@pollere.com>
  *  Copyright (C) 2012 Michael D. Taht <dave.taht@bufferbloat.net>
- *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2012,2015 Eric Dumazet <edumazet@google.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
@@ -55,6 +55,7 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME]\n");
 	fprintf(stderr, "                 [ interval TIME ] [ ecn | noecn ]\n");
+	fprintf(stderr, "                 [ ce_threshold TIME ]\n");
 }
 
 static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
@@ -63,6 +64,7 @@ static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned limit = 0;
 	unsigned target = 0;
 	unsigned interval = 0;
+	unsigned ce_threshold = ~0U;
 	int ecn = -1;
 	struct rtattr *tail;
 
@@ -79,6 +81,12 @@ static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"target\"\n");
 				return -1;
 			}
+		} else if (strcmp(*argv, "ce_threshold") == 0) {
+			NEXT_ARG();
+			if (get_time(&ce_threshold, *argv)) {
+				fprintf(stderr, "Illegal \"ce_threshold\"\n");
+				return -1;
+			}
 		} else if (strcmp(*argv, "interval") == 0) {
 			NEXT_ARG();
 			if (get_time(&interval, *argv)) {
@@ -110,6 +118,10 @@ static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_CODEL_TARGET, &target, sizeof(target));
 	if (ecn != -1)
 		addattr_l(n, 1024, TCA_CODEL_ECN, &ecn, sizeof(ecn));
+	if (ce_threshold != ~0U)
+		addattr_l(n, 1024, TCA_CODEL_CE_THRESHOLD,
+			  &ce_threshold, sizeof(ce_threshold));
+
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -121,6 +133,7 @@ static int codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	unsigned interval;
 	unsigned target;
 	unsigned ecn;
+	unsigned ce_threshold;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -138,6 +151,11 @@ static int codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		target = rta_getattr_u32(tb[TCA_CODEL_TARGET]);
 		fprintf(f, "target %s ", sprint_time(target, b1));
 	}
+	if (tb[TCA_CODEL_CE_THRESHOLD] &&
+	    RTA_PAYLOAD(tb[TCA_CODEL_CE_THRESHOLD]) >= sizeof(__u32)) {
+		ce_threshold = rta_getattr_u32(tb[TCA_CODEL_CE_THRESHOLD]);
+		fprintf(f, "ce_threshold %s ", sprint_time(ce_threshold, b1));
+	}
 	if (tb[TCA_CODEL_INTERVAL] &&
 	    RTA_PAYLOAD(tb[TCA_CODEL_INTERVAL]) >= sizeof(__u32)) {
 		interval = rta_getattr_u32(tb[TCA_CODEL_INTERVAL]);
@@ -156,16 +174,19 @@ static int codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 static int codel_print_xstats(struct qdisc_util *qu, FILE *f,
 			      struct rtattr *xstats)
 {
-	struct tc_codel_xstats *st;
+	struct tc_codel_xstats _st, *st;
 	SPRINT_BUF(b1);
 
 	if (xstats == NULL)
 		return 0;
 
-	if (RTA_PAYLOAD(xstats) < sizeof(*st))
-		return -1;
-
 	st = RTA_DATA(xstats);
+	if (RTA_PAYLOAD(xstats) < sizeof(*st)) {
+		memset(&_st, 0, sizeof(_st));
+		memcpy(&_st, st, RTA_PAYLOAD(xstats));
+		st = &_st;
+	}
+
 	fprintf(f, "  count %u lastcount %u ldelay %s",
 		st->count, st->lastcount, sprint_time(st->ldelay, b1));
 	if (st->dropping)
@@ -176,6 +197,8 @@ static int codel_print_xstats(struct qdisc_util *qu, FILE *f,
 		fprintf(f, " drop_next %s", sprint_time(st->drop_next, b1));
 	fprintf(f, "\n  maxpacket %u ecn_mark %u drop_overlimit %u",
 		st->maxpacket, st->ecn_mark, st->drop_overlimit);
+	if (st->ce_mark)
+		fprintf(f, " ce_mark %u", st->ce_mark);
 	return 0;
 
 }
diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
index 1d3bfa2..4f747eb 100644
--- a/tc/q_fq_codel.c
+++ b/tc/q_fq_codel.c
@@ -1,7 +1,7 @@
 /*
  * Fair Queue Codel
  *
- *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2012,2015 Eric Dumazet <edumazet@google.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
@@ -53,6 +53,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... fq_codel [ limit PACKETS ] [ flows NUMBER ]\n");
 	fprintf(stderr, "                    [ target TIME] [ interval TIME ]\n");
 	fprintf(stderr, "                    [ quantum BYTES ] [ [no]ecn ]\n");
+	fprintf(stderr, "                    [ ce_threshold TIME ]\n");
 }
 
 static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
@@ -63,6 +64,7 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned target = 0;
 	unsigned interval = 0;
 	unsigned quantum = 0;
+	unsigned ce_threshold = ~0U;
 	int ecn = -1;
 	struct rtattr *tail;
 
@@ -91,6 +93,12 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"target\"\n");
 				return -1;
 			}
+		} else if (strcmp(*argv, "ce_threshold") == 0) {
+			NEXT_ARG();
+			if (get_time(&ce_threshold, *argv)) {
+				fprintf(stderr, "Illegal \"ce_threshold\"\n");
+				return -1;
+			}
 		} else if (strcmp(*argv, "interval") == 0) {
 			NEXT_ARG();
 			if (get_time(&interval, *argv)) {
@@ -126,6 +134,9 @@ static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_FQ_CODEL_TARGET, &target, sizeof(target));
 	if (ecn != -1)
 		addattr_l(n, 1024, TCA_FQ_CODEL_ECN, &ecn, sizeof(ecn));
+	if (ce_threshold != ~0U)
+		addattr_l(n, 1024, TCA_FQ_CODEL_CE_THRESHOLD,
+			  &ce_threshold, sizeof(ce_threshold));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -139,6 +150,7 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 	unsigned target;
 	unsigned ecn;
 	unsigned quantum;
+	unsigned ce_threshold;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -166,6 +178,11 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 		target = rta_getattr_u32(tb[TCA_FQ_CODEL_TARGET]);
 		fprintf(f, "target %s ", sprint_time(target, b1));
 	}
+	if (tb[TCA_FQ_CODEL_CE_THRESHOLD] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_CE_THRESHOLD]) >= sizeof(__u32)) {
+		ce_threshold = rta_getattr_u32(tb[TCA_FQ_CODEL_CE_THRESHOLD]);
+		fprintf(f, "ce_threshold %s ", sprint_time(ce_threshold, b1));
+	}
 	if (tb[TCA_FQ_CODEL_INTERVAL] &&
 	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_INTERVAL]) >= sizeof(__u32)) {
 		interval = rta_getattr_u32(tb[TCA_FQ_CODEL_INTERVAL]);
@@ -184,22 +201,26 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 static int fq_codel_print_xstats(struct qdisc_util *qu, FILE *f,
 				 struct rtattr *xstats)
 {
-	struct tc_fq_codel_xstats *st;
+	struct tc_fq_codel_xstats _st, *st;
 	SPRINT_BUF(b1);
 
 	if (xstats == NULL)
 		return 0;
 
-	if (RTA_PAYLOAD(xstats) < sizeof(*st))
-		return -1;
-
 	st = RTA_DATA(xstats);
+	if (RTA_PAYLOAD(xstats) < sizeof(*st)) {
+		memset(&_st, 0, sizeof(_st));
+		memcpy(&_st, st, RTA_PAYLOAD(xstats));
+		st = &_st;
+	}
 	if (st->type == TCA_FQ_CODEL_XSTATS_QDISC) {
 		fprintf(f, "  maxpacket %u drop_overlimit %u new_flow_count %u ecn_mark %u",
 			st->qdisc_stats.maxpacket,
 			st->qdisc_stats.drop_overlimit,
 			st->qdisc_stats.new_flow_count,
 			st->qdisc_stats.ecn_mark);
+		if (st->qdisc_stats.ce_mark)
+			fprintf(f, " ce_mark %u", st->qdisc_stats.ce_mark);
 		fprintf(f, "\n  new_flows_len %u old_flows_len %u",
 			st->qdisc_stats.new_flows_len,
 			st->qdisc_stats.old_flows_len);
