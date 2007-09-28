From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 3/3] Use nested compat attributes for passing parameters to the kernel.
Date: Fri, 28 Sep 2007 15:54:57 -0700
Message-ID: <11910200984017-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42972 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbXI1WzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:55:07 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
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
index c9fcc53..5bb3eb7 100644
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
@@ -81,6 +89,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 			opt.divisor = 1<<opt.divisor;
+			addattr32(n, 1024, TCA_SFQ_DIVISOR, opt.divisor);
 			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
@@ -93,8 +102,13 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
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
1.5.3

