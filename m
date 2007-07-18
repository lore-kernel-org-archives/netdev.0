From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: updated tcatm patches for kernel/iproute 2.6.22
Date: Thu, 19 Jul 2007 00:06:38 +0300
Message-ID: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="maltfndb4q6t3pi2"
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:36084 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758133AbXGRWP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:15:56 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout3-sn1.fre.skanova.net (7.2.075)
        id 46758C53001155EA for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:06:41 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--maltfndb4q6t3pi2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I got tired of getting 15% packet loss [1] when doing
lots of DNS lookups on my ADSL link...
And that was even when limiting outgoing DNS traffic
to 200 Kbit/s (ADSL modem upstream speed is 512 Kbit/s).

I had used tcatm patch with 2.6.16 kernel and I was
happy with it.
Now I patched Linux kernel 2.6.22 and iproute-2.6.22
for tcatm.  Seems to work (TM).  Only HTB tested.

Now I get 0% packet loss when doing lots of DNS queries
(270pps) and DNS traffic is limited with
HTB/ESFQ to 504Kbit/s.  I used "tc class add ... atm overhead 20"
but I am not sure is it really 20 (Sonera in Finland).
Without tcatm I had to have there 420Kbit and it still sucked.

I keep patches at
http://safari.iki.fi/tcatm/

I read one thread from this year where there were objections
about tcatm's some parts and then discussion petered out...
I and probably Russell Stuart would probably like to get
these patches fixed so that everyone is pleased
and these can be incorporated into kernel some year,
because I believe ADSL is very popular nowadays ( =) )
and people would probably like if traffic control was
actually usable for them ( =) )...

[1] ping -A 80.223.96.1

-- 
Do what you love because life is too short for anything else.


--maltfndb4q6t3pi2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6.22-tcatm-1.0.patch"

#
# include/linux/pkt_sched.h |    5 +++--
# include/net/sch_generic.h |   15 +++++++++++++++
# net/sched/act_police.c    |    4 ++--
# net/sched/sch_cbq.c       |    2 +-
# net/sched/sch_htb.c       |    9 ++++-----
# net/sched/sch_tbf.c       |    4 ++--
# 6 files changed, 27 insertions(+), 12 deletions(-)
#
--- linux-2.6.22/include/linux/pkt_sched.h.bak	2007-07-09 21:58:23.559346000 +0300
+++ linux-2.6.22/include/linux/pkt_sched.h	2007-07-18 21:46:00.084770053 +0300
@@ -77,8 +77,9 @@ struct tc_ratespec
 {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
-	unsigned short	feature;
-	short		addend;
+	unsigned short	feature;	/* Always 0 in pre-atm patch kernels */
+	char		cell_align;	/* Always 0 in pre-atm patch kernels */
+	unsigned char	__reserved2;
 	unsigned short	mpu;
 	__u32		rate;
 };
--- linux-2.6.22/include/net/sch_generic.h.bak	2007-07-09 02:32:17.000000000 +0300
+++ linux-2.6.22/include/net/sch_generic.h	2007-07-18 21:44:40.024580754 +0300
@@ -302,4 +302,19 @@ drop:
 	return NET_XMIT_DROP;
 }
 
+/* Lookup a qdisc_rate_table to determine how long it will take to send a
+ * packet given its size.
+ */
+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
+{
+	int slot = pktlen + rtab->rate.cell_align;
+
+	if (slot < 0)
+		slot = 0;
+	slot >>= rtab->rate.cell_log;
+	if (slot > 255)
+		return rtab->data[255] + 1;
+	return rtab->data[slot];
+}
+
 #endif
--- linux-2.6.22/net/sched/act_police.c.bak	2007-07-09 02:32:17.000000000 +0300
+++ linux-2.6.22/net/sched/act_police.c	2007-07-18 21:42:49.275936447 +0300
@@ -32,8 +32,8 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
-#define L2T(p,L)   ((p)->tcfp_R_tab->data[(L)>>(p)->tcfp_R_tab->rate.cell_log])
-#define L2T_P(p,L) ((p)->tcfp_P_tab->data[(L)>>(p)->tcfp_P_tab->rate.cell_log])
+#define L2T(p,L)   qdisc_l2t((p)->tcfp_R_tab,L)
+#define L2T_P(p,L) qdisc_l2t((p)->tcfp_P_tab,L)
 
 #define POL_TAB_MASK     15
 static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
--- linux-2.6.22/net/sched/sch_cbq.c.bak	2007-07-09 02:32:17.000000000 +0300
+++ linux-2.6.22/net/sched/sch_cbq.c	2007-07-18 21:51:12.794420373 +0300
@@ -192,7 +192,7 @@ struct cbq_sched_data
 };
 
 
-#define L2T(cl,len)	((cl)->R_tab->data[(len)>>(cl)->R_tab->rate.cell_log])
+#define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
 
 
 static __inline__ unsigned cbq_hash(u32 h)
--- linux-2.6.22/net/sched/sch_htb.c.bak	2007-07-09 21:17:53.417438000 +0300
+++ linux-2.6.22/net/sched/sch_htb.c	2007-07-18 21:50:08.602465126 +0300
@@ -157,12 +157,11 @@ struct htb_class {
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 			   int size)
 {
-	int slot = size >> rate->rate.cell_log;
-	if (slot > 255) {
+	long result = qdisc_l2t(rate, size);
+
+	if (result > rate->data[255])
 		cl->xstats.giants++;
-		slot = 255;
-	}
-	return rate->data[slot];
+	return result;
 }
 
 struct htb_sched {
--- linux-2.6.22/net/sched/sch_tbf.c.bak	2007-07-09 02:32:17.000000000 +0300
+++ linux-2.6.22/net/sched/sch_tbf.c	2007-07-18 21:52:10.665281840 +0300
@@ -132,8 +132,8 @@ struct tbf_sched_data
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
-#define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
-#define L2T_P(q,L) ((q)->P_tab->data[(L)>>(q)->P_tab->rate.cell_log])
+#define L2T(q,L)	qdisc_l2t((q)->R_tab,L)
+#define L2T_P(q,L)	qdisc_l2t((q)->P_tab,L)
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {

--maltfndb4q6t3pi2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="iproute-2.6.22-tcatm.patch"

#
# include/linux/pkt_sched.h |    5 +-
# tc/m_police.c             |   37 +++++++++------
# tc/q_cbq.c                |   52 ++++++++++++++-------
# tc/q_htb.c                |   39 +++++++---------
# tc/q_tbf.c                |   53 ++++++++++++++--------
# tc/tc_core.c              |  109 ++++++++++++++++++++++++++++++++++++++++++----
# tc/tc_core.h              |    7 ++
# 7 files changed, 217 insertions(+), 85 deletions(-)
#
--- iproute-2.6.22/include/linux/pkt_sched.h.bak	2007-07-13 20:33:32.760700000 +0300
+++ iproute-2.6.22/include/linux/pkt_sched.h	2007-07-18 22:11:55.408999963 +0300
@@ -77,8 +77,9 @@ struct tc_ratespec
 {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
-	unsigned short	feature;
-	short		addend;
+	unsigned short	feature;	/* Always 0 in pre-atm patch kernels */
+	char		cell_align;	/* Always 0 in pre-atm patch kernels */
+	unsigned char   __reserved2;
 	unsigned short	mpu;
 	__u32		rate;
 };
--- iproute-2.6.22/tc/m_police.c.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/m_police.c	2007-07-18 22:48:35.435620446 +0300
@@ -35,7 +35,7 @@ struct action_util police_action_util = 
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
-	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ]\n");
+	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ] [ overhead OVERHEAD ] [ atm ]\n");
 	fprintf(stderr, "                [ ACTIONTERM ]\n");
 	fprintf(stderr, "Old Syntax ACTIONTERM := action <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n");
@@ -132,7 +132,10 @@ int act_parse_police(struct action_util 
 	__u32 ptab[256];
 	__u32 avrate = 0;
 	int presult = 0;
-	unsigned buffer=0, mtu=0, mpu=0;
+	unsigned buffer=0, mtu=0;
+	__u8 mpu=0;
+	__s8 overhead=0;
+	int atm=0;
 	int Rcell_log=-1, Pcell_log = -1;
 	struct rtattr *tail;
 
@@ -182,7 +185,7 @@ int act_parse_police(struct action_util 
 				fprintf(stderr, "Double \"mpu\" spec\n");
 				return -1;
 			}
-			if (get_size(&mpu, *argv)) {
+			if (get_u8(&mpu, *argv, 10)) {
 				explain1("mpu");
 				return -1;
 			}
@@ -196,6 +199,18 @@ int act_parse_police(struct action_util 
 				explain1("rate");
 				return -1;
 			}
+		} else if (strcmp(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (p.rate.rate) {
+				fprintf(stderr, "Double \"overhead\" spec\n");
+				return -1;
+			}
+			if (get_s8(&overhead, *argv, 10)) {
+				explain1("overhead");
+				return -1;
+			}
+		} else if (strcmp(*argv, "atm") == 0) {
+			atm = 1;
 		} else if (strcmp(*argv, "avrate") == 0) {
 			NEXT_ARG();
 			if (avrate) {
@@ -261,22 +276,14 @@ int act_parse_police(struct action_util 
 	}
 
 	if (p.rate.rate) {
-		if ((Rcell_log = tc_calc_rtable(p.rate.rate, rtab, Rcell_log, mtu, mpu)) < 0) {
-			fprintf(stderr, "TBF: failed to calculate rate table.\n");
-			return -1;
-		}
+		tc_calc_ratespec(&p.rate, rtab, p.rate.rate, Rcell_log,
+				 mtu, mpu, atm, overhead);
 		p.burst = tc_calc_xmittime(p.rate.rate, buffer);
-		p.rate.cell_log = Rcell_log;
-		p.rate.mpu = mpu;
 	}
 	p.mtu = mtu;
 	if (p.peakrate.rate) {
-		if ((Pcell_log = tc_calc_rtable(p.peakrate.rate, ptab, Pcell_log, mtu, mpu)) < 0) {
-			fprintf(stderr, "POLICE: failed to calculate peak rate table.\n");
-			return -1;
-		}
-		p.peakrate.cell_log = Pcell_log;
-		p.peakrate.mpu = mpu;
+		tc_calc_ratespec(&p.peakrate, ptab, p.peakrate.rate, Pcell_log,
+				 mtu, mpu, atm, overhead);
 	}
 
 	tail = NLMSG_TAIL(n);
--- iproute-2.6.22/tc/q_cbq.c.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/q_cbq.c	2007-07-18 22:50:27.207791135 +0300
@@ -32,6 +32,7 @@ static void explain_class(void)
 	fprintf(stderr, "               [ prio NUMBER ] [ cell BYTES ] [ ewma LOG ]\n");
 	fprintf(stderr, "               [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "               [ split CLASSID ] [ defmap MASK/CHANGE ]\n");
+	fprintf(stderr, "               [ overhead BYTES ] [ atm ]\n");
 }
 
 static void explain(void)
@@ -52,7 +53,10 @@ static int cbq_parse_opt(struct qdisc_ut
 	struct tc_ratespec r;
 	struct tc_cbq_lssopt lss;
 	__u32 rtab[256];
-	unsigned mpu=0, avpkt=0, allot=0;
+	unsigned avpkt=0, allot=0;
+	__u8 mpu=0;
+	__s8 overhead=0;
+	int atm=0;
 	int cell_log=-1;
 	int ewma_log=-1;
 	struct rtattr *tail;
@@ -102,7 +106,7 @@ static int cbq_parse_opt(struct qdisc_ut
 			}
 		} else if (strcmp(*argv, "mpu") == 0) {
 			NEXT_ARG();
-			if (get_size(&mpu, *argv)) {
+			if (get_u8(&mpu, *argv, 10)) {
 				explain1("mpu");
 				return -1;
 			}
@@ -113,6 +117,14 @@ static int cbq_parse_opt(struct qdisc_ut
 				explain1("allot");
 				return -1;
 			}
+		} else if (strcmp(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_s8(&overhead, *argv, 10)) {
+				explain1("overhead");
+				return -1;
+			}
+		} else if (strcmp(*argv, "atm") == 0) {
+			atm = 1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -137,12 +149,7 @@ static int cbq_parse_opt(struct qdisc_ut
 	if (allot < (avpkt*3)/2)
 		allot = (avpkt*3)/2;
 
-	if ((cell_log = tc_calc_rtable(r.rate, rtab, cell_log, allot, mpu)) < 0) {
-		fprintf(stderr, "CBQ: failed to calculate rate table.\n");
-		return -1;
-	}
-	r.cell_log = cell_log;
-	r.mpu = mpu;
+	tc_calc_ratespec(&r, rtab, r.rate, cell_log, allot, mpu, atm, overhead);
 
 	if (ewma_log < 0)
 		ewma_log = TC_CBQ_DEF_EWMA;
@@ -175,7 +182,9 @@ static int cbq_parse_class_opt(struct qd
 	struct tc_cbq_fopt fopt;
 	struct tc_cbq_ovl ovl;
 	__u32 rtab[256];
-	unsigned mpu=0;
+	__u8 mpu=0;
+	__s8 overhead = 0;
+	int atm = 0;
 	int cell_log=-1;
 	int ewma_log=-1;
 	unsigned bndw = 0;
@@ -289,10 +298,18 @@ static int cbq_parse_class_opt(struct qd
 			lss.change |= TCF_CBQ_LSS_AVPKT;
 		} else if (strcmp(*argv, "mpu") == 0) {
 			NEXT_ARG();
-			if (get_size(&mpu, *argv)) {
+			if (get_u8(&mpu, *argv, 10)) {
 				explain1("mpu");
 				return -1;
 			}
+		} else if (strcmp(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_s8(&overhead, *argv, 10)) {
+				explain1("overhead");
+				return -1;
+			}
+		} else if (strcmp(*argv, "atm") == 0) {
+			atm = 1;
 		} else if (strcmp(*argv, "weight") == 0) {
 			NEXT_ARG();
 			if (get_size(&wrr.weight, *argv)) {
@@ -336,12 +353,7 @@ static int cbq_parse_class_opt(struct qd
 		unsigned pktsize = wrr.allot;
 		if (wrr.allot < (lss.avpkt*3)/2)
 			wrr.allot = (lss.avpkt*3)/2;
-		if ((cell_log = tc_calc_rtable(r.rate, rtab, cell_log, pktsize, mpu)) < 0) {
-			fprintf(stderr, "CBQ: failed to calculate rate table.\n");
-			return -1;
-		}
-		r.cell_log = cell_log;
-		r.mpu = mpu;
+		tc_calc_ratespec(&r, rtab, r.rate, cell_log, pktsize, mpu, atm, overhead);
 	}
 	if (ewma_log < 0)
 		ewma_log = TC_CBQ_DEF_EWMA;
@@ -464,8 +476,12 @@ static int cbq_print_opt(struct qdisc_ut
 		fprintf(f, "rate %s ", buf);
 		if (show_details) {
 			fprintf(f, "cell %ub ", 1<<r->cell_log);
-			if (r->mpu)
-				fprintf(f, "mpu %ub ", r->mpu);
+			if (r->mpu & 0xff)
+				fprintf(f, "mpu %ub ", (__u8)r->mpu);
+			if ((r->mpu >> 8))
+				fprintf(f, "overhead %db ", (__s8)(r->mpu >> 8));
+			if (r->feature & 0x0001)
+				fprintf(f, "atm ");
 		}
 	}
 	if (lss && lss->flags) {
--- iproute-2.6.22/tc/q_htb.c.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/q_htb.c	2007-07-18 22:32:14.140392445 +0300
@@ -34,14 +34,14 @@ static void explain(void)
 		" default  minor id of class to which unclassified packets are sent {0}\n"
 		" r2q      DRR quantums are computed as rate in Bps/r2q {10}\n"
 		" debug    string of 16 numbers each 0-3 {0}\n\n"
-		"... class add ... htb rate R1 [burst B1] [mpu B] [overhead O]\n"
+		"... class add ... htb rate R1 [burst B1] [mpu B] [overhead O] [atm]\n"
 		"                      [prio P] [slot S] [pslot PS]\n"
 		"                      [ceil R2] [cburst B2] [mtu MTU] [quantum Q]\n"
 		" rate     rate allocated to this class (class can still borrow)\n"
 		" burst    max bytes burst which can be accumulated during idle period {computed}\n"
 		" mpu      minimum packet size used in rate computations\n"
 		" overhead per-packet size overhead used in rate computations\n"
-
+		" atm      include atm cell tax in rate computations\n"
 		" ceil     definite upper class rate (no borrows) {rate}\n"
 		" cburst   burst but for ceil {computed}\n"
 		" mtu      max packet size we create rate map for {1600}\n"
@@ -107,8 +107,10 @@ static int htb_parse_class_opt(struct qd
 	__u32 rtab[256],ctab[256];
 	unsigned buffer=0,cbuffer=0;
 	int cell_log=-1,ccell_log = -1;
-	unsigned mtu, mpu;
-	unsigned char mpu8 = 0, overhead = 0;
+	unsigned mtu;
+	__u8 mpu8=0;
+	__s8 overhead=0;
+	int atm=0;
 	struct rtattr *tail;
 
 	memset(&opt, 0, sizeof(opt)); mtu = 1600; /* eth packet len */
@@ -132,9 +134,11 @@ static int htb_parse_class_opt(struct qd
 			}
 		} else if (matches(*argv, "overhead") == 0) {
 			NEXT_ARG();
-			if (get_u8(&overhead, *argv, 10)) {
+			if (get_s8(&overhead, *argv, 10)) {
 				explain1("overhead"); return -1;
 			}
+		} else if (matches(*argv, "atm") == 0) {
+			atm = 1;
 		} else if (matches(*argv, "quantum") == 0) {
 			NEXT_ARG();
 			if (get_u32(&opt.quantum, *argv, 10)) {
@@ -206,23 +210,12 @@ static int htb_parse_class_opt(struct qd
 	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
 	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
 
-/* encode overhead and mpu, 8 bits each, into lower 16 bits */
-	mpu = (unsigned)mpu8 | (unsigned)overhead << 8;
-	opt.ceil.mpu = mpu; opt.rate.mpu = mpu;
+	/* encode overhead and mpu, 8 bits each, into lower 16 bits */
+	tc_calc_ratespec(&opt.rate, rtab, opt.rate.rate, cell_log, mtu, mpu8, atm, overhead);
+	tc_calc_ratespec(&opt.ceil, ctab, opt.ceil.rate, cell_log, mtu, mpu8, atm, overhead);
 
-	if ((cell_log = tc_calc_rtable(opt.rate.rate, rtab, cell_log, mtu, mpu)) < 0) {
-		fprintf(stderr, "htb: failed to calculate rate table.\n");
-		return -1;
-	}
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
-	opt.rate.cell_log = cell_log;
-
-	if ((ccell_log = tc_calc_rtable(opt.ceil.rate, ctab, cell_log, mtu, mpu)) < 0) {
-		fprintf(stderr, "htb: failed to calculate ceil rate table.\n");
-		return -1;
-	}
 	opt.cbuffer = tc_calc_xmittime(opt.ceil.rate, cbuffer);
-	opt.ceil.cell_log = ccell_log;
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
@@ -267,12 +260,16 @@ static int htb_print_opt(struct qdisc_ut
 			sprint_size(buffer, b1),
 			1<<hopt->rate.cell_log,
 			sprint_size(hopt->rate.mpu&0xFF, b2),
-			sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
+			sprint_size((__s8)(hopt->rate.mpu>>8), b3));
+		if (hopt->rate.feature & 0x0001)
+			fprintf(f, "atm ");
 		fprintf(f, "cburst %s/%u mpu %s overhead %s ",
 			sprint_size(cbuffer, b1),
 			1<<hopt->ceil.cell_log,
 			sprint_size(hopt->ceil.mpu&0xFF, b2),
-			sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
+			sprint_size((__s8)(hopt->ceil.mpu>>8), b3));
+		if (hopt->ceil.feature & 0x0001)
+			fprintf(f, "atm ");
 		fprintf(f, "level %d ", (int)hopt->level);
 	    } else {
 		fprintf(f, "burst %s ", sprint_size(buffer, b1));
--- iproute-2.6.22/tc/q_tbf.c.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/q_tbf.c	2007-07-18 22:38:36.990372046 +0300
@@ -26,7 +26,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu BYTES[/BYTES] ]\n");
-	fprintf(stderr, "               [ peakrate KBPS ] [ latency TIME ]\n");
+	fprintf(stderr, "               [ peakrate KBPS ] [ latency TIME ] [ overhead OVERHEAD ] [ atm ]\n");
 }
 
 static void explain1(char *arg)
@@ -43,7 +43,10 @@ static int tbf_parse_opt(struct qdisc_ut
 	struct tc_tbf_qopt opt;
 	__u32 rtab[256];
 	__u32 ptab[256];
-	unsigned buffer=0, mtu=0, mpu=0, latency=0;
+	unsigned buffer=0, mtu=0, latency=0;
+	__u8 mpu=0;
+	__s8 overhead=0;
+	int atm=0;
 	int Rcell_log=-1, Pcell_log = -1;
 	struct rtattr *tail;
 
@@ -103,7 +106,7 @@ static int tbf_parse_opt(struct qdisc_ut
 				fprintf(stderr, "Double \"mpu\" spec\n");
 				return -1;
 			}
-			if (get_size(&mpu, *argv)) {
+			if (get_u8(&mpu, *argv, 10)) {
 				explain1("mpu");
 				return -1;
 			}
@@ -119,6 +122,20 @@ static int tbf_parse_opt(struct qdisc_ut
 				return -1;
 			}
 			ok++;
+		} else if (strcmp(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (overhead) {
+				fprintf(stderr, "Double \"overhead\" spec\n");
+				return -1;
+			}
+			if (get_s8(&overhead, *argv, 10)) {
+				explain1("overhead");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "atm") == 0) {
+			atm = 1;
+			ok++;
 		} else if (matches(*argv, "peakrate") == 0) {
 			NEXT_ARG();
 			if (opt.peakrate.rate) {
@@ -170,21 +187,11 @@ static int tbf_parse_opt(struct qdisc_ut
 		opt.limit = lim;
 	}
 
-	if ((Rcell_log = tc_calc_rtable(opt.rate.rate, rtab, Rcell_log, mtu, mpu)) < 0) {
-		fprintf(stderr, "TBF: failed to calculate rate table.\n");
-		return -1;
-	}
+	tc_calc_ratespec(&opt.rate, rtab, opt.rate.rate, Rcell_log, mtu, mpu, atm, overhead);
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
-	opt.rate.cell_log = Rcell_log;
-	opt.rate.mpu = mpu;
 	if (opt.peakrate.rate) {
-		if ((Pcell_log = tc_calc_rtable(opt.peakrate.rate, ptab, Pcell_log, mtu, mpu)) < 0) {
-			fprintf(stderr, "TBF: failed to calculate peak rate table.\n");
-			return -1;
-		}
+		tc_calc_ratespec(&opt.peakrate, ptab, opt.peakrate.rate, Pcell_log, mtu, mpu, atm, overhead);
 		opt.mtu = tc_calc_xmittime(opt.peakrate.rate, mtu);
-		opt.peakrate.cell_log = Pcell_log;
-		opt.peakrate.mpu = mpu;
 	}
 
 	tail = NLMSG_TAIL(n);
@@ -220,8 +227,12 @@ static int tbf_print_opt(struct qdisc_ut
 	fprintf(f, "rate %s ", sprint_rate(qopt->rate.rate, b1));
 	buffer = tc_calc_xmitsize(qopt->rate.rate, qopt->buffer);
 	if (show_details) {
-		fprintf(f, "burst %s/%u mpu %s ", sprint_size(buffer, b1),
-			1<<qopt->rate.cell_log, sprint_size(qopt->rate.mpu, b2));
+		fprintf(f, "burst %s/%u mpu %s overhead %d ", sprint_size(buffer, b1),
+			1<<qopt->rate.cell_log,
+			sprint_size(qopt->rate.mpu & 0xFF, b2),
+			(__s8)(qopt->rate.mpu >> 8));
+		if (qopt->rate.feature & 0x0001)
+			fprintf(f, "atm ");
 	} else {
 		fprintf(f, "burst %s ", sprint_size(buffer, b1));
 	}
@@ -232,8 +243,12 @@ static int tbf_print_opt(struct qdisc_ut
 		if (qopt->mtu || qopt->peakrate.mpu) {
 			mtu = tc_calc_xmitsize(qopt->peakrate.rate, qopt->mtu);
 			if (show_details) {
-				fprintf(f, "mtu %s/%u mpu %s ", sprint_size(mtu, b1),
-					1<<qopt->peakrate.cell_log, sprint_size(qopt->peakrate.mpu, b2));
+				fprintf(f, "mtu %s/%u mpu %s overhead %d ", sprint_size(mtu, b1),
+					1<<qopt->peakrate.cell_log,
+					sprint_size(qopt->peakrate.mpu & 0xFF, b2),
+					(__s8)(qopt->peakrate.mpu >> 8));
+				if (qopt->peakrate.feature & 0x0001)
+					fprintf(f, "atm ");
 			} else {
 				fprintf(f, "minburst %s ", sprint_size(mtu, b1));
 			}
--- iproute-2.6.22/tc/tc_core.c.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/tc_core.c	2007-07-18 22:46:04.381040136 +0300
@@ -66,33 +66,124 @@ unsigned tc_calc_xmitsize(unsigned rate,
 }
 
 /*
-   rtab[pkt_len>>cell_log] = pkt_xmit_time
+ * Calculate the ATM cell overhead.  ATM sends each packet in 48 byte
+ * chunks, the last chunk being padded if necessary.  Each chunk carries
+ * an additional 5 byte overhead - the ATM header.
  */
 
-int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu,
-		   unsigned mpu)
+static int tc_align_to_cells(int size) 
+{
+	int cells;
+
+	cells = size / ATM_CELL_PAYLOAD;
+	if (size % ATM_CELL_PAYLOAD != 0)
+		cells++;
+	return cells * ATM_CELL_SIZE;
+}
+
+/*
+ * The number this function calculates is subtle.  Ignore it and just believe
+ * it works if you have a choice, otherwise ..
+ *
+ * If there we are calculating the ATM cell overhead the kernel calculations
+ * will be out sometimes if the range of packet sizes spanned by one
+ * rate table element crosses an ATM cell boundary.  Consider these three
+ * senarios:
+ *    (a) the packet is sent across the ATM link without addition
+ *        overheads the kernel doesn't know about, and
+ *    (b) a packet that has 1 byte of additional overhead the kernel
+ *        doesn't know about.  Here
+ *    (c) a packet that has 2 bytes of additional overhead the
+ *        kernel doesn't know about.
+ * The table below presents what happens.  Each row is for a single rate
+ * table element.  The "Sizes" column shows what packet sizes the rate table
+ * element will be used for.  This packet size includes the "unknown to
+ * kernel" overhead, but does not include overhead incurred by breaking the
+ * packet up into ATM cells. This ATM cell overhead consists of the 5 byte
+ * header per ATM cell, plus the padding in the last cell.  The "ATM" column
+ * shows how many bytes are actually sent across the ATM link, ie it does
+ * include the ATM cell overhead.
+ *
+ *   RateTable Entry  Sizes(a) ATM(a)    Sizes(b) ATM(b)   Sizes(c) ATM(c)
+ *      ratetable[0]    0..7    53        1..8     53        2..9    53
+ *      ratetable[1]    8..15   53        9..16    53        2..17   53
+ *      ratetable[2]   16..23   53       17..24    53       18..25   53
+ *      ratetable[3]   24..31   53       25..32    53       26..33   53
+ *      ratetable[4]   32..39   53       33..40    53       34..41   53
+ *      ratetable[5]   40..47   53       41..48    53       42..49   53,106
+ *      ratetable[6]   48..55   53,106   49..56   106       50..57  106
+ *
+ * For senario (a), the ratetable[6] entry covers two cases: one were a single
+ * ATM cell is needed to transmit the data, and one where two ATM cells are
+ * required.  It can't be right for both.  Unfortunately the error is large.
+ * The same problem arises in senario (c) for ratetable[5].  The problem
+ * doesn't happen for senario (b), because the boundary between rate table
+ * entries happens to match the boundary between ATM cells.
+ *
+ * What we would like to do is ensure that ratetable boundaries always match
+ * the ATM cells.  If we do this the error goes away.  The solution is to make
+ * the kernel add a small bias to the packet size.  (Small because the bias
+ * will always be smaller than cell_log.)  Adding this small bias will in
+ * effect slide the ratetable along a bit, so the boundaries match.  The code
+ * below calculates that bias.  Provided the MTU is less than 4092, doing
+ * this can always eliminate the error.
+ *
+ * Old kernels won't add this bias, so they will have the error described above
+ * in most cases.  In the worst case senario, considering all possible ATM cell
+ * sizes (1..48), for 7 of these sizes the old kernel will calculate the rate
+ * wrongly - ie, be out by 53 bytes.
+ */
+static int tc_calc_cell_align(int atm_cell_tax, char overhead, int cell_log)
+{
+       int cell_size;
+
+       if (!atm_cell_tax)
+               return 0;
+       cell_size = 1 << cell_log;
+       return (overhead + cell_size - 2) % cell_size - cell_size + 1;
+}
+
+/*
+ * A constructor for a tc_ratespec.
+ */
+void tc_calc_ratespec(struct tc_ratespec* spec, __u32* rtab, unsigned bps,
+		      int cell_log, unsigned mtu, unsigned char mpu,
+		      int atm_cell_tax, char overhead)
 {
 	int i;
-	unsigned overhead = (mpu >> 8) & 0xFF;
-	mpu = mpu & 0xFF;
 
 	if (mtu == 0)
 		mtu = 2047;
 
+	/* rtab[pkt_len>>cell_log] = pkt_xmit_time */
 	if (cell_log < 0) {
 		cell_log = 0;
 		while ((mtu>>cell_log) > 255)
 			cell_log++;
 	}
+
 	for (i=0; i<256; i++) {
-		unsigned sz = (i<<cell_log);
-		if (overhead)
-			sz += overhead;
+		/*
+		 * sz is the length of packet we will use for this ratetable
+		 * entry.  The time taken to send a packet of this length will
+		 * be used for all packet lengths this ratetable entry applies
+		 * to.  As underestimating how long it will take to transmit a
+		 * packet is a worse error than overestimating it, the longest
+		 * packet this rate table entry applies to is used.
+		 */
+		int sz = ((i+1)<<cell_log) - 1 + overhead;
 		if (sz < mpu)
 			sz = mpu;
+		if (atm_cell_tax)
+			sz = tc_align_to_cells(sz);
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
-	return cell_log;
+
+	spec->cell_align = tc_calc_cell_align(atm_cell_tax, overhead, cell_log);
+	spec->cell_log = cell_log;
+	spec->feature = 0x8000 | (atm_cell_tax ? 1 : 0);
+	spec->mpu = mpu | (unsigned)(overhead << 8);
+	spec->rate = bps;
 }
 
 int tc_core_init()
--- iproute-2.6.22/tc/tc_core.h.bak	2007-07-11 04:34:14.000000000 +0300
+++ iproute-2.6.22/tc/tc_core.h	2007-07-18 22:47:53.289179306 +0300
@@ -6,6 +6,9 @@
 
 #define TIME_UNITS_PER_SEC	1000000
 
+#define ATM_CELL_SIZE		53
+#define ATM_CELL_PAYLOAD	48
+
 int  tc_core_time2big(long time);
 long tc_core_time2tick(long time);
 long tc_core_tick2time(long tick);
@@ -13,7 +16,9 @@ long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
-int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
+void tc_calc_ratespec(struct tc_ratespec* spec, __u32* rtab, unsigned bps,
+		      int cell_log, unsigned mtu, unsigned char mpu,
+		      int atm_cell_tax, char overhead);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
 

--maltfndb4q6t3pi2--
