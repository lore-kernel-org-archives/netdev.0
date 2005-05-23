From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Netem] [PATCH] (3/3) netem: allow random reordering
Date: Mon, 23 May 2005 10:25:17 -0700
Message-ID: <20050523102517.1903f5f2@dxpl.pdx.osdl.net>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	<682bc30a050520132819b66fee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julio Kriger <juliokriger@gmail.com>
In-Reply-To: <682bc30a050520132819b66fee@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 May 2005 20:28:40 +0000
Julio Kriger <juliokriger@gmail.com> wrote:

> Hi!
> How do I use this feature? Shouldn't tc be modified to accept this new feature?
> Regards,
> 
> Julio

Use this (it will be in the next version of iproute2).
Also, you need to specify a delay because that is how netem does the reordering.

diff -X dontdiff -urN iproute2-2.6.11-050330/include/linux/pkt_sched.h iproute2-netem/include/linux/pkt_sched.h
--- iproute2-2.6.11-050330/include/linux/pkt_sched.h	2005-04-01 11:58:11.000000000 -0800
+++ iproute2-netem/include/linux/pkt_sched.h	2005-05-04 11:31:14.000000000 -0700
@@ -427,6 +427,7 @@
 	TCA_NETEM_UNSPEC,
 	TCA_NETEM_CORR,
 	TCA_NETEM_DELAY_DIST,
+	TCA_NETEM_REORDER,
 	__TCA_NETEM_MAX,
 };
 
@@ -437,7 +438,7 @@
 	__u32	latency;	/* added delay (us) */
 	__u32   limit;		/* fifo limit (packets) */
 	__u32	loss;		/* random packet loss (0=none ~0=100%) */
-	__u32	gap;		/* re-ordering gap (0 for delay all) */
+	__u32	gap;		/* re-ordering gap (0 for none) */
 	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
 	__u32	jitter;		/* random jitter in latency (us) */
 };
@@ -449,6 +450,12 @@
 	__u32	dup_corr;	/* duplicate correlation  */
 };
 
+struct tc_netem_reorder
+{
+	__u32	probability;
+	__u32	correlation;
+};
+
 #define NETEM_DIST_SCALE	8192
 
 #endif
diff -X dontdiff -urN iproute2-2.6.11-050330/tc/q_netem.c iproute2-netem/tc/q_netem.c
--- iproute2-2.6.11-050330/tc/q_netem.c	2005-04-01 11:58:11.000000000 -0800
+++ iproute2-netem/tc/q_netem.c	2005-05-04 13:31:25.000000000 -0700
@@ -29,11 +29,11 @@
 {
 	fprintf(stderr, 
 "Usage: ... netem [ limit PACKETS ] \n" \
-"		  [ delay TIME [ JITTER [CORRELATION]]]\n" \
+"                 [ delay TIME [ JITTER [CORRELATION]]]\n" \
+"                 [ distribution {uniform|normal|pareto|paretonormal} ]\n" \
 "                 [ drop PERCENT [CORRELATION]] \n" \
 "                 [ duplicate PERCENT [CORRELATION]]\n" \
-"		  [ distribution {uniform|normal|pareto|paretonormal} ]\n" \
-"                 [ gap PACKETS ]\n");
+"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
 }
 
 static void explain1(const char *arg)
@@ -127,11 +127,13 @@
 	struct rtattr *tail;
 	struct tc_netem_qopt opt;
 	struct tc_netem_corr cor;
+	struct tc_netem_reorder reorder;
 	__s16 dist_data[MAXDIST];
 
 	memset(&opt, 0, sizeof(opt));
 	opt.limit = 1000;
 	memset(&cor, 0, sizeof(cor));
+	memset(&reorder, 0, sizeof(reorder));
 
 	while (argc > 0) {
 		if (matches(*argv, "limit") == 0) {
@@ -178,6 +180,19 @@
 					return -1;
 				}
 			}
+		} else if (matches(*argv, "reorder") == 0) {
+			NEXT_ARG();
+			if (get_percent(&reorder.probability, *argv)) {
+				explain1("reorder");
+				return -1;
+			}
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				if (get_percent(&reorder.correlation, *argv)) {
+					explain1("reorder");
+					return -1;
+				}
+			}
 		} else if (matches(*argv, "gap") == 0) {
 			NEXT_ARG();
 			if (get_u32(&opt.gap, *argv, 0)) {
@@ -215,8 +230,27 @@
 
 	tail = NLMSG_TAIL(n);
 
+	if (reorder.probability) {
+		if (opt.latency == 0) {
+			fprintf(stderr, "reordering not possible without specifying some delay\n");
+		}
+		if (opt.gap == 0)
+			opt.gap = 1;
+	} else if (opt.gap > 0) {
+		fprintf(stderr, "gap specified without reorder probability\n");
+		explain();
+		return -1;
+	}
+
+	if (dist_size > 0 && (opt.latency == 0 || opt.jitter == 0)) {
+		fprintf(stderr, "distribution specified but no latency and jitter values\n");
+		explain();
+		return -1;
+	}
+
 	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
 	addattr_l(n, 1024, TCA_NETEM_CORR, &cor, sizeof(cor));
+	addattr_l(n, 1024, TCA_NETEM_REORDER, &reorder, sizeof(reorder));
 
 	if (dist_size > 0) {
 		addattr_l(n, 32768, TCA_NETEM_DELAY_DIST,
@@ -229,6 +263,7 @@
 static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	const struct tc_netem_corr *cor = NULL;
+	const struct tc_netem_reorder *reorder = NULL;
 	struct tc_netem_qopt qopt;
 	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
 	SPRINT_BUF(b1);
@@ -252,6 +287,11 @@
 				return -1;
 			cor = RTA_DATA(tb[TCA_NETEM_CORR]);
 		}
+		if (tb[TCA_NETEM_REORDER]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_REORDER]) < sizeof(*reorder))
+				return -1;
+			reorder = RTA_DATA(tb[TCA_NETEM_REORDER]);
+		}
 	}
 
 	fprintf(f, "limit %d", qopt.limit);
@@ -278,10 +318,19 @@
 		if (cor && cor->dup_corr)
 			fprintf(f, " %s", sprint_percent(cor->dup_corr, b1));
 	}
+			
+	if (reorder && reorder->probability) {
+		fprintf(f, " reorder %s", 
+			sprint_percent(reorder->probability, b1));
+		if (reorder->correlation)
+			fprintf(f, " %s", 
+				sprint_percent(reorder->correlation, b1));
+	}
 
 	if (qopt.gap)
 		fprintf(f, " gap %lu", (unsigned long)qopt.gap);
 
+
 	return 0;
 }
 
