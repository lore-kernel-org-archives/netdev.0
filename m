From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] red: Add adaptative algo
Date: Fri, 09 Dec 2011 19:30:59 +0100
Message-ID: <1323455459.4016.7.camel@edumazet-laptop>
References: <1323385900.2529.12.camel@edumazet-laptop>
	 <20111208164426.03248ca8@nehalam.linuxnetplumber.net>
	 <1323403837.2529.14.camel@edumazet-laptop>
	 <20111209093309.04b32e27@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61223 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab1LISbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 13:31:04 -0500
Received: by bkbzv3 with SMTP id zv3so3190350bkb.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 10:31:02 -0800 (PST)
In-Reply-To: <20111209093309.04b32e27@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable Adaptative RED algo, using :

tc qdisc  ... red limit BYTES ... adaptative ...

Support of high precision probability/max_p setting and reporting, with
support of old kernels.

With a new kernel, "Plog ..." is replaced in tc output by "probability
value" :

qdisc red 10: dev eth3 parent 1:1 limit 360Kb min 30Kb max 90Kb ecn ewma
5 probability 0.09 Scell_log 15

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/pkt_sched.h |   17 ++++++++++++-----
 tc/q_red.c                |   24 +++++++++++++++++++++---
 2 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index c533670..e41e0d4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -30,7 +30,7 @@
  */
 
 struct tc_stats {
-	__u64	bytes;			/* NUmber of enqueues bytes */
+	__u64	bytes;			/* Number of enqueued bytes */
 	__u32	packets;		/* Number of enqueued packets	*/
 	__u32	drops;			/* Packets dropped because of lack of resources */
 	__u32	overlimits;		/* Number of throttle events when this
@@ -181,6 +181,7 @@ enum {
 	TCA_RED_UNSPEC,
 	TCA_RED_PARMS,
 	TCA_RED_STAB,
+	TCA_RED_MAX_P,
 	__TCA_RED_MAX,
 };
 
@@ -194,8 +195,9 @@ struct tc_red_qopt {
 	unsigned char   Plog;		/* log(P_max/(qth_max-qth_min))	*/
 	unsigned char   Scell_log;	/* cell size for idle damping */
 	unsigned char	flags;
-#define TC_RED_ECN	1
-#define TC_RED_HARDDROP	2
+#define TC_RED_ECN		1
+#define TC_RED_HARDDROP		2
+#define TC_RED_ADAPTATIVE	4
 };
 
 struct tc_red_xstats {
@@ -297,7 +299,7 @@ struct tc_htb_glob {
 	__u32 debug;		/* debug flags */
 
 	/* stats */
-	__u32 direct_pkts; /* count of non shapped packets */
+	__u32 direct_pkts; /* count of non shaped packets */
 };
 enum {
 	TCA_HTB_UNSPEC,
@@ -465,6 +467,7 @@ enum {
 	TCA_NETEM_REORDER,
 	TCA_NETEM_CORRUPT,
 	TCA_NETEM_LOSS,
+	TCA_NETEM_RATE,
 	__TCA_NETEM_MAX,
 };
 
@@ -495,6 +498,10 @@ struct tc_netem_corrupt {
 	__u32	correlation;
 };
 
+struct tc_netem_rate {
+	__u32	rate;	/* byte/s */
+};
+
 enum {
 	NETEM_LOSS_UNSPEC,
 	NETEM_LOSS_GI,		/* General Intuitive - 4 state model */
@@ -503,7 +510,7 @@ enum {
 };
 #define NETEM_LOSS_MAX (__NETEM_LOSS_MAX - 1)
 
-/* State transition probablities for 4 state model */
+/* State transition probabilities for 4 state model */
 struct tc_netem_gimodel {
 	__u32	p13;
 	__u32	p31;
diff --git a/tc/q_red.c b/tc/q_red.c
index 18020d7..0e5d228 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -28,7 +28,8 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... red limit BYTES [min BYTES] [max BYTES] avpkt BYTES [burst PACKETS]\n");
-	fprintf(stderr, "               [probability PROBABILITY] bandwidth KBPS [ecn] [harddrop]\n");
+	fprintf(stderr, "               [adaptative] [probability PROBABILITY] bandwidth KBPS\n");
+	fprintf(stderr, "               [ecn] [harddrop]\n");
 }
 
 static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
@@ -40,6 +41,7 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	unsigned rate = 0;
 	int wlog;
 	__u8 sbuf[256];
+	__u32 max_P;
 	struct rtattr *tail;
 
 	memset(&opt, 0, sizeof(opt));
@@ -91,6 +93,8 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			opt.flags |= TC_RED_ECN;
 		} else if (strcmp(*argv, "harddrop") == 0) {
 			opt.flags |= TC_RED_HARDDROP;
+		} else if (strcmp(*argv, "adaptative") == 0) {
+			opt.flags |= TC_RED_ADAPTATIVE;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -141,6 +145,8 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 1024, TCA_RED_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 1024, TCA_RED_STAB, sbuf, 256);
+	max_P = probability * pow(2, 32);
+	addattr_l(n, 1024, TCA_RED_MAX_P, &max_P, sizeof(max_P));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -149,6 +155,7 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct rtattr *tb[TCA_RED_MAX + 1];
 	struct tc_red_qopt *qopt;
+	__u32 max_P = 0;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
@@ -163,6 +170,11 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	qopt = RTA_DATA(tb[TCA_RED_PARMS]);
 	if (RTA_PAYLOAD(tb[TCA_RED_PARMS])  < sizeof(*qopt))
 		return -1;
+
+	if (tb[TCA_RED_MAX_P] &&
+	    RTA_PAYLOAD(tb[TCA_RED_MAX_P]) >= sizeof(__u32))
+		max_P = *(__u32 *)RTA_DATA(tb[TCA_RED_MAX_P]);
+
 	fprintf(f, "limit %s min %s max %s ",
 		sprint_size(qopt->limit, b1),
 		sprint_size(qopt->qth_min, b2),
@@ -171,9 +183,15 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		fprintf(f, "ecn ");
 	if (qopt->flags & TC_RED_HARDDROP)
 		fprintf(f, "harddrop ");
+	if (qopt->flags & TC_RED_ADAPTATIVE)
+		fprintf(f, "adaptative ");
 	if (show_details) {
-		fprintf(f, "ewma %u Plog %u Scell_log %u",
-			qopt->Wlog, qopt->Plog, qopt->Scell_log);
+		fprintf(f, "ewma %u ", qopt->Wlog);
+		if (max_P)
+			fprintf(f, "probability %lg ", max_P / pow(2, 32));
+		else
+			fprintf(f, "Plog %u ", qopt->Plog);
+		fprintf(f, "Scell_log %u", qopt->Scell_log);
 	}
 	return 0;
 }
