From: Christian Samsel <christian.samsel@rwth-aachen.de>
Subject: [PATCH 2/2] improve netem reorder flexibility
Date: Fri, 18 Dec 2009 14:18:38 +0100
Message-ID: <1261142318-26249-2-git-send-email-christian.samsel@rwth-aachen.de>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:35844 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbZLRNSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 08:18:51 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUU00MDUNNBBC50@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 18 Dec 2009 14:18:47 +0100 (CET)
In-reply-to: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

supplementary patch for iproute2 to match kernel behavior.

Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>
---
 include/linux/pkt_sched.h |   21 +++++++++------
 tc/q_netem.c              |   61 ++++++++++++++++++++++++++++++++------------
 2 files changed, 56 insertions(+), 26 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d51a2b3..2081195 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -473,19 +473,22 @@ enum
 
 struct tc_netem_qopt
 {
-	__u32	latency;	/* added delay (us) */
-	__u32   limit;		/* fifo limit (packets) */
-	__u32	loss;		/* random packet loss (0=none ~0=100%) */
-	__u32	gap;		/* re-ordering gap (0 for none) */
-	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
-	__u32	jitter;		/* random jitter in latency (us) */
+	__u32	latency;		/* added delay (us) */
+	__u32   limit;			/* fifo limit (packets) */
+	__u32	loss;			/* random packet loss (0=none ~0=100%) */
+	__u32	gap;			/* minimum re-ordering gap (0 for none) */
+	__u32   duplicate;		/* random packet dup  (0=none ~0=100%) */
+	__u32	jitter;			/* random jitter in latency (us) */
+	__u32   reorderdelay;   	/* delay for reordered packets (us) */
+	__u32	reorderdelayjitter;	/* random jitter for reordered packets (us) */
 };
 
 struct tc_netem_corr
 {
-	__u32	delay_corr;	/* delay correlation */
-	__u32	loss_corr;	/* packet loss correlation */
-	__u32	dup_corr;	/* duplicate correlation  */
+	__u32	delay_corr;		/* delay correlation */
+	__u32	reorderdelay_corr;	/* reorderdelay correlation */
+	__u32	loss_corr;		/* packet loss correlation */
+	__u32	dup_corr;		/* duplicate correlation  */
 };
 
 struct tc_netem_reorder
diff --git a/tc/q_netem.c b/tc/q_netem.c
index d06932e..eac9dc5 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -28,13 +28,14 @@
 static void explain(void)
 {
 	fprintf(stderr,
-"Usage: ... netem [ limit PACKETS ] \n" \
-"                 [ delay TIME [ JITTER [CORRELATION]]]\n" \
-"                 [ distribution {uniform|normal|pareto|paretonormal} ]\n" \
-"                 [ drop PERCENT [CORRELATION]] \n" \
-"                 [ corrupt PERCENT [CORRELATION]] \n" \
-"                 [ duplicate PERCENT [CORRELATION]]\n" \
-"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
+"Usage: ... netem [ limit PACKETS ]\n" \
+"                 [ delay TIME [JITTER [CORRELATION]] ]\n" \
+"                 [ distribution (uniform|normal|pareto|paretonormal) ]\n" \
+"                 [ drop PERCENT [CORRELATION] ]\n" \
+"                 [ corrupt PERCENT [CORRELATION] ]\n" \
+"                 [ duplicate PERCENT [CORRELATION] ]\n" \
+"                 [ ( reorder PRECENT [CORRELATION] | gap MINDISTANCE ) reorderdelay TIME [JITTER [CORRELATION]] ]\n" \
+);
 }
 
 static void explain1(const char *arg)
@@ -204,6 +205,29 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 					return -1;
 				}
 			}
+
+		} else if  (matches(*argv, "reorderdelay") == 0) {
+                        NEXT_ARG();
+                        if (get_ticks(&opt.reorderdelay, *argv)) {
+                                explain1("reorderdelay");
+                                return -1;
+                        }
+                        if (NEXT_IS_NUMBER()) {
+                                NEXT_ARG();
+                                if (get_ticks(&opt.reorderdelayjitter, *argv)) {
+                                        explain1("reorderdelay");
+                                        return -1;
+                                }
+				if (NEXT_IS_NUMBER()) {
+                                        NEXT_ARG();
+                                        ++present[TCA_NETEM_CORR];
+                                        if (get_percent(&cor.reorderdelay_corr, *argv)) {
+                                                explain1("reorderdelay");
+                                                return -1;
+                                        }
+                                }
+			}
+	
 		} else if (matches(*argv, "corrupt") == 0) {
 			NEXT_ARG();
 			present[TCA_NETEM_CORRUPT] = 1;
@@ -260,19 +284,18 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	tail = NLMSG_TAIL(n);
 
 	if (reorder.probability) {
-		if (opt.latency == 0) {
-			fprintf(stderr, "reordering not possible without specifying some delay\n");
-		}
 		if (opt.gap == 0)
-			opt.gap = 1;
-	} else if (opt.gap > 0) {
-		fprintf(stderr, "gap specified without reorder probability\n");
-		explain();
-		return -1;
+			opt.gap = 1; /* set minimum reorder gap to 1 */
+	} else {
+		if ( opt.gap == 0 && opt.reorderdelay > 0) {
+			fprintf(stderr, "reorderdelay specified without reorder probability or gap\n");
+			explain();
+			return -1;
+		}
 	}
 
-	if (dist_data && (opt.latency == 0 || opt.jitter == 0)) {
-		fprintf(stderr, "distribution specified but no latency and jitter values\n");
+	if (dist_data && opt.jitter == 0 && opt.reorderjitter == 0) {
+		fprintf(stderr, "distribution specified but no delay or reorderdelay jitter values\n");
 		explain();
 		return -1;
 	}
@@ -345,6 +368,10 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 
 	fprintf(f, "limit %d", qopt.limit);
 
+	if (qopt.reorderdelay) {
+		fprintf(f, " reorderdelay %s", sprint_ticks(qopt.reorderdelay, b1) );
+	}
+
 	if (qopt.latency) {
 		fprintf(f, " delay %s", sprint_ticks(qopt.latency, b1));
 
-- 
1.6.4.1

