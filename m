From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 1/3] SFQ: Support changing depth and divisor.
Date: Mon, 29 Oct 2007 00:24:45 -0700
Message-ID: <1193642687-1272-2-git-send-email-bugfood-ml@fatooh.org>
References: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50398 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbXJ2HYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:24:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 9D44717C094
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:49 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ewFS6Ar+bXLb for <netdev@vger.kernel.org>;
	Mon, 29 Oct 2007 02:24:49 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id D01DF17C24F
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:48 -0500 (CDT)
In-Reply-To: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This can safely be applied either before or after the kernel
patches because the tc_sfq_qopt struct is unchanged:

- old kernels will ignore the new parameters from new iproute2
- new kernels will use the same defaults for the new parameters
---
 include/linux/pkt_sched.h |    9 ---------
 tc/q_sfq.c                |   20 +++++++++++++++++++-
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..9d41f63 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -148,15 +148,6 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
-/*
- *  NOTE: limit, divisor and flows are hardwired to code at the moment.
- *
- *	limit=flows=128, divisor=1024;
- *
- *	The only reason for this is efficiency, it is possible
- *	to change these parameters in compile time.
- */
-
 /* RED section */
 
 enum
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 05385cf..19e76ba 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -25,7 +25,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]\n");
+	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ depth FLOWS ] [ divisor HASHBITS ] [ perturb SECS ] [ quantum BYTES ]\n");
 }
 
 #define usage() return(-1)
@@ -63,6 +63,24 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 			ok++;
+		} else if (strcmp(*argv, "depth") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&opt.flows, *argv, 0)) {
+				fprintf(stderr, "Illegal \"depth\"\n");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "divisor") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&opt.divisor, *argv, 0)) {
+				fprintf(stderr, "Illegal \"divisor\"\n");
+				return -1;
+			}
+			if (opt.divisor >= 15) {
+				fprintf(stderr, "Illegal \"divisor\", must be < 15\n");
+				return -1;
+			}
+			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
1.5.3.4

