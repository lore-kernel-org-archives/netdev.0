From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH] [iproute2] SFQ: Support changing depth and divisor.
Date: Sun, 29 Jul 2007 00:08:55 -0700
Message-ID: <1185692936761-git-send-email-bugfood-ml@fatooh.org>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
 <11856929353322-git-send-email-bugfood-ml@fatooh.org>
 <11856929352132-git-send-email-bugfood-ml@fatooh.org>
 <11856929352115-git-send-email-bugfood-ml@fatooh.org>
 <11856929362692-git-send-email-bugfood-ml@fatooh.org>
 <1185692936660-git-send-email-bugfood-ml@fatooh.org>
 <11856929364083-git-send-email-bugfood-ml@fatooh.org>
 <1185692936479-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:60053 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757307AbXG2HIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 03:08:54 -0400
In-Reply-To: <1185692936479-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This can safely be applied either before or after the kernel
patches because the tc_sfq_qopt struct is unchanged:

- old kernels will ignore the parameters from new iproute2
- new kernels will use the same default parameters
---
 include/linux/pkt_sched.h |    9 ---------
 tc/q_sfq.c                |   21 ++++++++++++++++++++-
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..37946d4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -139,15 +139,6 @@ struct tc_sfq_qopt
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
index 05385cf..7754db7 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -25,7 +25,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]\n");
+	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ depth FLOWS ] [ divisor HASHBITS ] [ perturb SECS ] [ quantum BYTES ]\n");
 }
 
 #define usage() return(-1)
@@ -63,6 +63,25 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
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
+			opt.divisor = 1<<opt.divisor;
+			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
1.5.2.4

