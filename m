From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc: fq: allow setting and retrieving orphan_mask
Date: Thu, 24 Sep 2015 04:43:26 -0700
Message-ID: <1443095006.29850.149.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35495 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbbIXLn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 07:43:28 -0400
Received: by pacfv12 with SMTP id fv12so72327158pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 04:43:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

linux-3.19 fq packet scheduler got a new attribute, controlling
number of 'flows' holding packets not attached to a socket
(forwarding usage)

kernel commit is 06eb395fa9856b5a87cf7d80baee2a0ed3cdb9d7
("pkt_sched: fq: better control of DDOS traffic")

This patch adds corresponding code to tc command.

tc qd replace dev eth0 root fq orphan_mask 511

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_fq.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/tc/q_fq.c b/tc/q_fq.c
index 7ad3801474ce..97b46a524fa6 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -1,7 +1,7 @@
 /*
  * Fair Queue
  *
- *  Copyright (C) 2013 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2013-2015 Eric Dumazet <edumazet@google.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
@@ -55,6 +55,7 @@ static void explain(void)
 	fprintf(stderr, "              [ quantum BYTES ] [ initial_quantum BYTES ]\n");
 	fprintf(stderr, "              [ maxrate RATE  ] [ buckets NUMBER ]\n");
 	fprintf(stderr, "              [ [no]pacing ] [ refill_delay TIME ]\n");
+	fprintf(stderr, "              [ orphan_mask MASK]\n");
 }
 
 static unsigned int ilog2(unsigned int val)
@@ -80,6 +81,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned int maxrate;
 	unsigned int defrate;
 	unsigned int refill_delay;
+	unsigned int orphan_mask;
 	bool set_plimit = false;
 	bool set_flow_plimit = false;
 	bool set_quantum = false;
@@ -87,6 +89,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	bool set_maxrate = false;
 	bool set_defrate = false;
 	bool set_refill_delay = false;
+	bool set_orphan_mask = false;
 	int pacing = -1;
 	struct rtattr *tail;
 
@@ -139,6 +142,13 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				return -1;
 			}
 			set_initial_quantum = true;
+		} else if (strcmp(*argv, "orphan_mask") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&orphan_mask, *argv, 0)) {
+				fprintf(stderr, "Illegal \"initial_quantum\"\n");
+				return -1;
+			}
+			set_orphan_mask = true;
 		} else if (strcmp(*argv, "refill_delay") == 0) {
 			NEXT_ARG();
 			if (get_time(&refill_delay, *argv)) {
@@ -192,6 +202,9 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (set_refill_delay)
 		addattr_l(n, 1024, TCA_FQ_FLOW_REFILL_DELAY,
 		          &refill_delay, sizeof(refill_delay));
+	if (set_orphan_mask)
+		addattr_l(n, 1024, TCA_FQ_ORPHAN_MASK,
+		          &orphan_mask, sizeof(refill_delay));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -204,6 +217,7 @@ static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	int pacing;
 	unsigned int rate, quantum;
 	unsigned int refill_delay;
+	unsigned int orphan_mask;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -226,6 +240,11 @@ static int fq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		buckets_log = rta_getattr_u32(tb[TCA_FQ_BUCKETS_LOG]);
 		fprintf(f, "buckets %u ", 1U << buckets_log);
 	}
+	if (tb[TCA_FQ_ORPHAN_MASK] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_ORPHAN_MASK]) >= sizeof(__u32)) {
+		orphan_mask = rta_getattr_u32(tb[TCA_FQ_ORPHAN_MASK]);
+		fprintf(f, "orphan_mask %u ", orphan_mask);
+	}
 	if (tb[TCA_FQ_RATE_ENABLE] &&
 	    RTA_PAYLOAD(tb[TCA_FQ_RATE_ENABLE]) >= sizeof(int)) {
 		pacing = rta_getattr_u32(tb[TCA_FQ_RATE_ENABLE]);
