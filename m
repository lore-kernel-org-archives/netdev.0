From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 3/3] Use nested compat attributes for passing parameters to the kernel.
Date: Mon, 29 Oct 2007 00:24:47 -0700
Message-ID: <1193642687-1272-4-git-send-email-bugfood-ml@fatooh.org>
References: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50400 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbXJ2HYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:24:50 -0400
In-Reply-To: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note that I have left sfq_print_opt() alone. At this point, there
can be no difference between the data in the nested rtattrs and the
data in the compat rtattr, and I didn't want to add clutter that
isn't useful. Let me know if I should do differently.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |   14 ++++++++++++++
 tc/q_sfq.c                |   18 ++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index fb04a89..aad04eb 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -148,6 +148,20 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+enum
+{
+	TCA_SFQ_UNSPEC,
+	TCA_SFQ_COMPAT,
+	TCA_SFQ_QUANTUM,
+	TCA_SFQ_PERTURB,
+	TCA_SFQ_LIMIT,
+	TCA_SFQ_DIVISOR,
+	TCA_SFQ_FLOWS,
+	__TCA_SFQ_MAX,
+};
+
+#define TCA_SFQ_MAX (__TCA_SFQ_MAX - 1)
+
 /* RED section */
 
 enum
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 83c8a54..69f17c8 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -34,9 +34,13 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 {
 	int ok=0;
 	struct tc_sfq_qopt opt;
+	struct rtattr *nest;
 
 	memset(&opt, 0, sizeof(opt));
 
+	/* put blank data in rtattr so there is a "hole" to fill later */
+	nest = addattr_nest_compat(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+
 	while (argc > 0) {
 		if (strcmp(*argv, "quantum") == 0) {
 			NEXT_ARG();
@@ -44,6 +48,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"limit\"\n");
 				return -1;
 			}
+			addattr32(n, 1024, TCA_SFQ_QUANTUM, opt.quantum);
 			ok++;
 		} else if (strcmp(*argv, "perturb") == 0) {
 			NEXT_ARG();
@@ -51,6 +56,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"perturb\"\n");
 				return -1;
 			}
+			addattr32(n, 1024, TCA_SFQ_PERTURB, opt.perturb_period);
 			ok++;
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
@@ -62,6 +68,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"limit\", must be > 1\n");
 				return -1;
 			}
+			addattr32(n, 1024, TCA_SFQ_LIMIT, opt.limit);
 			ok++;
 		} else if (strcmp(*argv, "depth") == 0) {
 			NEXT_ARG();
@@ -69,6 +76,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"depth\"\n");
 				return -1;
 			}
+			addattr32(n, 1024, TCA_SFQ_FLOWS, opt.flows);
 			ok++;
 		} else if (strcmp(*argv, "divisor") == 0) {
 			NEXT_ARG();
@@ -80,6 +88,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"divisor\", must be < 15\n");
 				return -1;
 			}
+			addattr32(n, 1024, TCA_SFQ_DIVISOR, opt.divisor);
 			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
@@ -92,8 +101,13 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		argc--; argv++;
 	}
 
-	if (ok)
-		addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	if (ok) {
+		/* fill the "hole" we left earlier with real compat data */
+		memcpy(RTA_DATA(nest), &opt, sizeof(opt));
+		addattr_nest_compat_end(n, nest);
+	}
+	else
+		nest->rta_len = 0;
 	return 0;
 }
 
-- 
1.5.3.4

