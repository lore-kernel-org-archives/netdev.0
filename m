From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2/net-next RFC] tc: Implement filter block sharing to ingress and clsact qdiscs
Date: Mon, 10 Jul 2017 20:52:32 +0200
Message-ID: <20170710185232.3266-1-jiri@resnulli.us>
References: <20170710185110.3180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, stephen@networkplumber.org, jbenc@redhat.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        john.fastabend@gmail.com, alexander.h.duyck@intel.com,
        daniel@iogearbox.net, ogerlitz@mellanox.com, mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34494 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754155AbdGJSwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:52:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id k67so26776889wrc.1
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:52:34 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/pkt_sched.h | 12 +++++++++++
 tc/q_clsact.c             | 54 ++++++++++++++++++++++++++++++++++++++++++-----
 tc/q_ingress.c            | 32 +++++++++++++++++++++++++---
 3 files changed, 90 insertions(+), 8 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf55..a684087 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -871,4 +871,16 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* Ingress/clsact */
+
+enum {
+	TCA_CLSACT_UNSPEC,
+	TCA_CLSACT_INGRESS_BLOCK,
+	TCA_CLSACT_EGRESS_BLOCK,
+	__TCA_CLSACT_MAX
+};
+
+#define TCA_CLSACT_MAX	(__TCA_CLSACT_MAX - 1)
+
 #endif
diff --git a/tc/q_clsact.c b/tc/q_clsact.c
index e2a1a71..0ecaa63 100644
--- a/tc/q_clsact.c
+++ b/tc/q_clsact.c
@@ -6,23 +6,67 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... clsact\n");
+	fprintf(stderr, "Usage: ... clsact [ingress_block BLOCK_INDEX] [egress_block BLOCK_INDEX]\n");
 }
 
 static int clsact_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
-	if (argc > 0) {
-		fprintf(stderr, "What is \"%s\"?\n", *argv);
-		explain();
-		return -1;
+	struct rtattr *tail;
+	unsigned int ingress_block;
+	unsigned int egress_block;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "ingress_block") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&ingress_block, *argv, 0)) {
+				fprintf(stderr, "Illegal \"ingress_block\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "egress_block") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&egress_block, *argv, 0)) {
+				fprintf(stderr, "Illegal \"egress_block\"\n");
+				return -1;
+			}
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		NEXT_ARG_FWD();
 	}
 
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (ingress_block)
+		addattr32(n, 1024, TCA_CLSACT_INGRESS_BLOCK, ingress_block);
+	if (egress_block)
+		addattr32(n, 1024, TCA_CLSACT_EGRESS_BLOCK, egress_block);
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
 
 static int clsact_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
+	struct rtattr *tb[TCA_CLSACT_MAX + 1];
+	unsigned int block;
+
+	if (!opt)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CLSACT_MAX, opt);
+
+	if (tb[TCA_CLSACT_INGRESS_BLOCK] &&
+	    RTA_PAYLOAD(tb[TCA_CLSACT_INGRESS_BLOCK]) >= sizeof(__u32)) {
+		block = rta_getattr_u32(tb[TCA_CLSACT_INGRESS_BLOCK]);
+		fprintf(f, "ingress_block %u ", block);
+	}
+	if (tb[TCA_CLSACT_EGRESS_BLOCK] &&
+	    RTA_PAYLOAD(tb[TCA_CLSACT_EGRESS_BLOCK]) >= sizeof(__u32)) {
+		block = rta_getattr_u32(tb[TCA_CLSACT_EGRESS_BLOCK]);
+		fprintf(f, "egress_block %u ", block);
+	}
 	return 0;
 }
 
diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index 31699a8..b973e1b 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -17,30 +17,56 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... ingress\n");
+	fprintf(stderr, "Usage: ... ingress [block BLOCK_INDEX]\n");
 }
 
 static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			     struct nlmsghdr *n)
 {
+	struct rtattr *tail;
+	unsigned int block;
+
 	while (argc > 0) {
 		if (strcmp(*argv, "handle") == 0) {
 			NEXT_ARG();
-			argc--; argv++;
+		} else if (strcmp(*argv, "block") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&block, *argv, 0)) {
+				fprintf(stderr, "Illegal \"block\"\n");
+				return -1;
+			}
 		} else {
 			fprintf(stderr, "What is \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
+		NEXT_ARG_FWD();
 	}
 
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (block)
+		addattr32(n, 1024, TCA_CLSACT_INGRESS_BLOCK, block);
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
 
 static int ingress_print_opt(struct qdisc_util *qu, FILE *f,
 			     struct rtattr *opt)
 {
-	fprintf(f, "---------------- ");
+	struct rtattr *tb[TCA_CLSACT_MAX + 1];
+	unsigned int block;
+
+	if (!opt)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CLSACT_MAX, opt);
+
+	if (tb[TCA_CLSACT_INGRESS_BLOCK] &&
+	    RTA_PAYLOAD(tb[TCA_CLSACT_INGRESS_BLOCK]) >= sizeof(__u32)) {
+		block = rta_getattr_u32(tb[TCA_CLSACT_INGRESS_BLOCK]);
+		fprintf(f, "block %u ", block);
+	}
 	return 0;
 }
 
-- 
2.9.3
