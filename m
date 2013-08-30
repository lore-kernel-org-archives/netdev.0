From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [iproute2 PATCH] iproute2: linklayer interface between kernel and
 tc/userspace
Date: Fri, 30 Aug 2013 14:02:10 +0200
Message-ID: <20130830120210.1510.80733.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab3H3MCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 08:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This iproute2 tc patch is connected to the kernel
 - commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)

The rate table calculated by tc, have gotten replaced in the kernel
and is no-longer used for lookups.

This happened in kernel release v3.8 caused by kernel
 - commit 56b765b79 ("htb: improved accuracy at high rates").
This change unfortunately caused breakage of tc overhead and
linklayer parameters.

 Kernel overhead handling got fixed in kernel v3.10 by
 - commit 01cb71d2d47 (net_sched: restore "overhead xxx" handling)

 Kernel linklayer handling got fixed in kernel v3.11 by
 - commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)

The linklayer fix introduced a struct change, that allow the linklayer
attribute to be transferred between tc and kernel. This patch make use
of this linklayer attribute.

The linklayer setting is transfer to the kernel.  And linklayer
setting received from the kernel is printed with a prefixed
"linklayer" when listing current configuration.  The default
TC_LINKLAYER_ETHERNET is only printed in detailed output mode.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/pkt_sched.h |   10 +++++++++-
 tc/m_police.c             |    5 +++++
 tc/q_cbq.c                |    5 +++++
 tc/q_htb.c                |    5 +++++
 tc/q_tbf.c                |    5 +++++
 tc/tc_core.c              |   16 ++++++++++++++++
 6 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbd71b0..09d62b9 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -73,9 +73,17 @@ struct tc_estimator {
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 
+/* Need to corrospond to iproute2 tc/tc_core.h "enum link_layer" */
+enum tc_link_layer {
+	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
+	TC_LINKLAYER_ETHERNET,
+	TC_LINKLAYER_ATM,
+};
+#define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
+
 struct tc_ratespec {
 	unsigned char	cell_log;
-	unsigned char	__reserved;
+	__u8		linklayer; /* lower 4 bits */
 	unsigned short	overhead;
 	short		cell_align;
 	unsigned short	mpu;
diff --git a/tc/m_police.c b/tc/m_police.c
index 53cbefc..300287e 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -322,9 +322,11 @@ int
 print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 {
 	SPRINT_BUF(b1);
+	SPRINT_BUF(b2);
 	struct tc_police *p;
 	struct rtattr *tb[TCA_POLICE_MAX+1];
 	unsigned buffer;
+	unsigned int linklayer;
 
 	if (arg == NULL)
 		return 0;
@@ -360,6 +362,9 @@ print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 	} else
 		fprintf(f, " ");
 	fprintf(f, "overhead %ub ", p->rate.overhead);
+	linklayer = (p->rate.linklayer & TC_LINKLAYER_MASK);
+	if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
+		fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b2));
 	fprintf(f, "\nref %d bind %d\n",p->refcnt, p->bindcnt);
 
 	return 0;
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index 3c5e72c..d76600c 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -442,7 +442,9 @@ static int cbq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct tc_cbq_wrropt *wrr = NULL;
 	struct tc_cbq_fopt *fopt = NULL;
 	struct tc_cbq_ovl *ovl = NULL;
+	unsigned int linklayer;
 	SPRINT_BUF(b1);
+	SPRINT_BUF(b2);
 
 	if (opt == NULL)
 		return 0;
@@ -486,6 +488,9 @@ static int cbq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		char buf[64];
 		print_rate(buf, sizeof(buf), r->rate);
 		fprintf(f, "rate %s ", buf);
+		linklayer = (r->linklayer & TC_LINKLAYER_MASK);
+		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
+			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b2));
 		if (show_details) {
 			fprintf(f, "cell %ub ", 1<<r->cell_log);
 			if (r->mpu)
diff --git a/tc/q_htb.c b/tc/q_htb.c
index 9321c0a..7b6f908 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -244,9 +244,11 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct tc_htb_opt *hopt;
 	struct tc_htb_glob *gopt;
 	double buffer,cbuffer;
+	unsigned int linklayer;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
+	SPRINT_BUF(b4);
 
 	if (opt == NULL)
 		return 0;
@@ -268,6 +270,9 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		buffer = tc_calc_xmitsize(hopt->rate.rate, hopt->buffer);
 		fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
 		cbuffer = tc_calc_xmitsize(hopt->ceil.rate, hopt->cbuffer);
+		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
+		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
+			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
 		if (show_details) {
 			fprintf(f, "burst %s/%u mpu %s overhead %s ",
 				sprint_size(buffer, b1),
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 72cfff6..34784a4 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -239,10 +239,12 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct rtattr *tb[TCA_TBF_PTAB+1];
 	struct tc_tbf_qopt *qopt;
+	unsigned int linklayer;
 	double buffer, mtu;
 	double latency;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
+	SPRINT_BUF(b3);
 
 	if (opt == NULL)
 		return 0;
@@ -294,6 +296,9 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (qopt->rate.overhead) {
 		fprintf(f, "overhead %d", qopt->rate.overhead);
 	}
+	linklayer = (qopt->rate.linklayer & TC_LINKLAYER_MASK);
+	if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
+		fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b3));
 
 	return 0;
 }
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 85b072e..a524337 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -102,6 +102,21 @@ static unsigned tc_adjust_size(unsigned sz, unsigned mpu, enum link_layer linkla
 	}
 }
 
+/* Notice, the rate table calculated here, have gotten replaced in the
+ * kernel and is no-longer used for lookups.
+ *
+ * This happened in kernel release v3.8 caused by kernel
+ *  - commit 56b765b79 ("htb: improved accuracy at high rates").
+ * This change unfortunately caused breakage of tc overhead and
+ * linklayer parameters.
+ *
+ * Kernel overhead handling got fixed in kernel v3.10 by
+ * - commit 01cb71d2d47 (net_sched: restore "overhead xxx" handling)
+ *
+ * Kernel linklayer handling got fixed in kernel v3.11 by
+ * - commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
+ */
+
 /*
    rtab[pkt_len>>cell_log] = pkt_xmit_time
  */
@@ -131,6 +146,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 
 	r->cell_align=-1; // Due to the sz calc
 	r->cell_log=cell_log;
+	r->linklayer = (linklayer & TC_LINKLAYER_MASK);
 	return cell_log;
 }
 
