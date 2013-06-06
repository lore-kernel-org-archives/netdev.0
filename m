From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: RFC: Proposed fix for tc linklayer calc broken after commit
 56b765b79 (htb: improved accuracy at high rates)
Date: Thu, 6 Jun 2013 15:55:04 +0200
Message-ID: <20130606155504.0eb6570a@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264Ab3FFNzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 09:55:41 -0400
In-Reply-To: <20130529151330.22c5c89e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Requesting comments.

So, bacically commit 56b765b79 (htb: improved accuracy at high rates),
broke the "linklayer atm" handling.  As it didn't update the iproute tc util.

Treating this as a regression fix, this is the smallest and least
intrusive solution I could come up with.

I'm basically restoring the "linklayer atm" handling, by using the
__reserved field in struct tc_ratespec, to convey the chosen
linklayer option.


KERNEL patch:
=============

[PATCH RFC] net_sched: restore "linklayer atm" handling

From: Jesper Dangaard Brouer <brouer@redhat.com>

commit 56b765b79 ("htb: improved accuracy at high rates")
broke the "linklayer atm" handling.

 tc class add ... htb rate X ceil Y linklayer atm

This patch restores the "linklayer atm" handling, by using the
__reserved field in struct tc_ratespec, to convey the choosen
linklayer option.

This requires a corrosponding iproute2 tc fix, that updates this
field.  Older tc binaries can be detected by the kernel, as the
field would be zero.

Request-For-Comments-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/sch_generic.h      |    8 +++++++-
 include/uapi/linux/pkt_sched.h |   11 ++++++++++-
 net/sched/sch_generic.c        |    4 ++++
 3 files changed, 21 insertions(+), 2 deletions(-)


diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e7f4e21..c9916b1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -682,13 +682,18 @@ struct psched_ratecfg {
 	u64	rate_bps;
 	u32	mult;
 	u16	overhead;
+	u8	linklayer;
 	u8	shift;
 };
 
 static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 				unsigned int len)
 {
-	return ((u64)(len + r->overhead) * r->mult) >> r->shift;
+	u64 pkt_len = len + r->overhead;
+
+	if (r->linklayer == TC_LINKLAYER_ATM)
+		pkt_len = DIV_ROUND_UP(pkt_len,48)*53;
+	return (pkt_len * r->mult) >> r->shift;
 }
 
 extern void psched_ratecfg_precompute(struct psched_ratecfg *r, const struct tc_ratespec *conf);
@@ -699,6 +704,7 @@ static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 	memset(res, 0, sizeof(*res));
 	res->rate = r->rate_bps >> 3;
 	res->overhead = r->overhead;
+	res->linklayer = r->linklayer;
 }
 
 #endif
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index dbd71b0..71e1463 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -73,9 +73,18 @@ struct tc_estimator {
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 
+/* NOTES: Move to another .h file???
+ * NOTES: Need to corrospond to iproute2 tc/tc_core.h "enum link_layer".
+ */
+enum tc_link_layer {
+	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
+	TC_LINKLAYER_ETHERNET,
+	TC_LINKLAYER_ATM,
+};
+
 struct tc_ratespec {
 	unsigned char	cell_log;
-	unsigned char	__reserved;
+	__u8		linklayer;
 	unsigned short	overhead;
 	short		cell_align;
 	unsigned short	mpu;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2022408..8ff9a5e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -908,6 +908,10 @@ void psched_ratecfg_precompute(struct psched_ratecfg *r,
 	memset(r, 0, sizeof(*r));
 	r->overhead = conf->overhead;
 	r->rate_bps = (u64)conf->rate << 3;
+	r->linklayer = conf->linklayer;
+	/* We could add a warn once here:
+	 *  if (r->linklayer == TC_LINKLAYER_UNAWARE)
+	 */
 	r->mult = 1;
 	/*
 	 * Calibrate mult, shift so that token counting is accurate



IPROUTE2 patch
==============
tc: convey linklayer information to the kernel

From: Jesper Dangaard Brouer <brouer@redhat.com>


---

 include/linux/pkt_sched.h |    8 +++++++-
 tc/q_htb.c                |    2 ++
 tc/tc_core.c              |    1 +
 3 files changed, 10 insertions(+), 1 deletions(-)


diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbd71b0..8abdae6 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -73,9 +73,15 @@ struct tc_estimator {
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 
+enum tc_link_layer {
+	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
+	TC_LINKLAYER_ETHERNET,
+	TC_LINKLAYER_ATM,
+};
+
 struct tc_ratespec {
 	unsigned char	cell_log;
-	unsigned char	__reserved;
+	__u8		linklayer;
 	unsigned short	overhead;
 	short		cell_align;
 	unsigned short	mpu;
diff --git a/tc/q_htb.c b/tc/q_htb.c
index caa47c2..9b17412 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -267,6 +267,8 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	    buffer = tc_calc_xmitsize(hopt->rate.rate, hopt->buffer);
 	    fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
 	    cbuffer = tc_calc_xmitsize(hopt->ceil.rate, hopt->cbuffer);
+	    // TODO: ADD print statements for linklayer
+
 	    if (show_details) {
 		fprintf(f, "burst %s/%u mpu %s overhead %s ",
 			sprint_size(buffer, b1),
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 85b072e..9383fdc 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -129,6 +129,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
 
+	r->linklayer = linklayer;
 	r->cell_align=-1; // Due to the sz calc
 	r->cell_log=cell_log;
 	return cell_log;
