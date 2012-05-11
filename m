From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 iproute2] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 21:49:50 +0200
Message-ID: <1336765790.31653.280.camel@edumazet-glaptop>
References: <1336744796.31653.164.camel@edumazet-glaptop>
	 <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
	 <1336749810.31653.176.camel@edumazet-glaptop>
	 <1336752516.31653.196.camel@edumazet-glaptop>
	 <1336764650.31653.277.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64420 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab2EKTt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 15:49:58 -0400
Received: by wibhn6 with SMTP id hn6so611159wib.1
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 12:49:56 -0700 (PDT)
In-Reply-To: <1336764650.31653.277.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

=46air Queue Codel packet scheduler

Principles :

- Packets are classified (internal classifier or external) on flows.
- This is a Stochastic model (as we use a hash, several flows might
                              be hashed on same slot)
- Each flow has a CoDel managed queue.
- Flows are linked onto two (Round Robin) lists,
  so that new flows have priority on old ones.

- For a given flow, packets are not reordered (CoDel uses a FIFO)
- head drops only.
- ECN capability is on by default.
- Very low memory footprint (64 bytes per flow)

tc qdisc ... fq_codel [ limit PACKETS ] [ flows number ]
                      [ target TIME ] [ interval TIME ] [ noecn ]
                      [ quantum BYTES ]

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Kathleen Nichols <nichols@pollere.com>
Cc: Van Jacobson <van@pollere.net>
Cc: Tom Herbert <therbert@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/pkt_sched.h |   54 ++++++++
 tc/Makefile               |    1=20
 tc/q_fq_codel.c           |  232 ++++++++++++++++++++++++++++++++++++
 3 files changed, 287 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index cde56c2..32aef0a 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -681,4 +681,58 @@ struct tc_codel_xstats {
 	__u32	dropping;  /* are we in dropping state ? */
 };
=20
+/* FQ_CODEL */
+
+enum {
+	TCA_FQ_CODEL_UNSPEC,
+	TCA_FQ_CODEL_TARGET,
+	TCA_FQ_CODEL_LIMIT,
+	TCA_FQ_CODEL_INTERVAL,
+	TCA_FQ_CODEL_ECN,
+	TCA_FQ_CODEL_FLOWS,
+	TCA_FQ_CODEL_QUANTUM,
+	__TCA_FQ_CODEL_MAX
+};
+
+#define TCA_FQ_CODEL_MAX	(__TCA_FQ_CODEL_MAX - 1)
+
+enum {
+	TCA_FQ_CODEL_XSTATS_QDISC,
+	TCA_FQ_CODEL_XSTATS_CLASS,
+};
+
+struct tc_fq_codel_qd_stats {
+	__u32	maxpacket;	/* largest packet we've seen so far */
+	__u32	drop_overlimit; /* number of time max qdisc
+				 * packet limit was hit
+				 */
+	__u32	ecn_mark;	/* number of packets we ECN marked
+				 * instead of being dropped
+				 */
+	__u32	new_flow_count; /* number of time packets
+				 * created a 'new flow'
+				 */
+	__u32	new_flows_len;	/* count of flows in new list */
+	__u32	old_flows_len;	/* count of flows in old list */
+};
+
+struct tc_fq_codel_cl_stats {
+	__s32	deficit;
+	__u32	ldelay;		/* in-queue delay seen by most recently
+				 * dequeued packet
+				 */
+	__u32	count;
+	__u32	lastcount;
+	__u32	dropping;
+	__s32	drop_next;
+};
+
+struct tc_fq_codel_xstats {
+	__u32	type;
+	union {
+		struct tc_fq_codel_qd_stats qdisc_stats;
+		struct tc_fq_codel_cl_stats class_stats;
+	};
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index 8a7cc8d..64d93ad 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -48,6 +48,7 @@ TCMODULES +=3D em_u32.o
 TCMODULES +=3D em_meta.o
 TCMODULES +=3D q_mqprio.o
 TCMODULES +=3D q_codel.o
+TCMODULES +=3D q_fq_codel.o
=20
 TCSO :=3D
 ifeq ($(TC_CONFIG_ATM),y)
diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
new file mode 100644
index 0000000..3b3b074
--- /dev/null
+++ b/tc/q_fq_codel.c
@@ -0,0 +1,232 @@
+/*
+ * Fair Queue Codel
+ *
+ *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, and the following disclaimer,
+ *    without modification.
+ * 2. Redistributions in binary form must reproduce the above copyrigh=
t
+ *    notice, this list of conditions and the following disclaimer in =
the
+ *    documentation and/or other materials provided with the distribut=
ion.
+ * 3. The names of the authors may not be used to endorse or promote p=
roducts
+ *    derived from this software without specific prior written permis=
sion.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of t=
he
+ * GPL apply INSTEAD OF those given above.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS F=
OR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGH=
T
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTA=
L,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON A=
NY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE U=
SE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... fq_codel [ limit PACKETS ] [ flows NUMBER=
 ]\n");
+	fprintf(stderr, "                    [ target TIME] [ interval TIME ]=
\n");
+	fprintf(stderr, "                    [ quantum BYTES ] [ [no]ecn ]\n"=
);
+}
+
+static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **=
argv,
+			      struct nlmsghdr *n)
+{
+	unsigned limit =3D 0;
+	unsigned flows =3D 0;
+	unsigned target =3D 0;
+	unsigned interval =3D 0;
+	unsigned quantum =3D 0;
+	int ecn =3D -1;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_unsigned(&limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "flows") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_unsigned(&flows, *argv, 0)) {
+				fprintf(stderr, "Illegal \"flows\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "quantum") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_unsigned(&quantum, *argv, 0)) {
+				fprintf(stderr, "Illegal \"quantum\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "target") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_time(&target, *argv)) {
+				fprintf(stderr, "Illegal \"target\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "interval") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_time(&interval, *argv)) {
+				fprintf(stderr, "Illegal \"interval\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "ecn") =3D=3D 0) {
+			ecn =3D 1;
+		} else if (strcmp(*argv, "noecn") =3D=3D 0) {
+			ecn =3D 0;
+		} else if (strcmp(*argv, "help") =3D=3D 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	tail =3D NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (limit)
+		addattr_l(n, 1024, TCA_FQ_CODEL_LIMIT, &limit, sizeof(limit));
+	if (flows)
+		addattr_l(n, 1024, TCA_FQ_CODEL_FLOWS, &flows, sizeof(flows));
+	if (quantum)
+		addattr_l(n, 1024, TCA_FQ_CODEL_QUANTUM, &quantum, sizeof(quantum));
+	if (interval)
+		addattr_l(n, 1024, TCA_FQ_CODEL_INTERVAL, &interval, sizeof(interval=
));
+	if (target)
+		addattr_l(n, 1024, TCA_FQ_CODEL_TARGET, &target, sizeof(target));
+	if (ecn !=3D -1)
+		addattr_l(n, 1024, TCA_FQ_CODEL_ECN, &ecn, sizeof(ecn));
+	tail->rta_len =3D (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct r=
tattr *opt)
+{
+	struct rtattr *tb[TCA_FQ_CODEL_MAX + 1];
+	unsigned limit;
+	unsigned flows;
+	unsigned interval;
+	unsigned target;
+	unsigned ecn;
+	unsigned quantum;
+	SPRINT_BUF(b1);
+
+	if (opt =3D=3D NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_FQ_CODEL_MAX, opt);
+
+	if (tb[TCA_FQ_CODEL_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_LIMIT]) >=3D sizeof(__u32)) {
+		limit =3D rta_getattr_u32(tb[TCA_FQ_CODEL_LIMIT]);
+		fprintf(f, "limit %up ", limit);
+	}
+	if (tb[TCA_FQ_CODEL_FLOWS] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_FLOWS]) >=3D sizeof(__u32)) {
+		flows =3D rta_getattr_u32(tb[TCA_FQ_CODEL_FLOWS]);
+		fprintf(f, "flows %u ", flows);
+	}
+	if (tb[TCA_FQ_CODEL_QUANTUM] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_QUANTUM]) >=3D sizeof(__u32)) {
+		quantum =3D rta_getattr_u32(tb[TCA_FQ_CODEL_QUANTUM]);
+		fprintf(f, "quantum %u ", quantum);
+	}
+	if (tb[TCA_FQ_CODEL_TARGET] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_TARGET]) >=3D sizeof(__u32)) {
+		target =3D rta_getattr_u32(tb[TCA_FQ_CODEL_TARGET]);
+		fprintf(f, "target %s ", sprint_time(target, b1));
+	}
+	if (tb[TCA_FQ_CODEL_INTERVAL] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_INTERVAL]) >=3D sizeof(__u32)) {
+		interval =3D rta_getattr_u32(tb[TCA_FQ_CODEL_INTERVAL]);
+		fprintf(f, "interval %s ", sprint_time(interval, b1));
+	}
+	if (tb[TCA_FQ_CODEL_ECN] &&
+	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_ECN]) >=3D sizeof(__u32)) {
+		ecn =3D rta_getattr_u32(tb[TCA_FQ_CODEL_ECN]);
+		if (ecn)
+			fprintf(f, "ecn ");
+	}
+
+	return 0;
+}
+
+static int fq_codel_print_xstats(struct qdisc_util *qu, FILE *f,
+				 struct rtattr *xstats)
+{
+	struct tc_fq_codel_xstats *st;
+	SPRINT_BUF(b1);
+
+	if (xstats =3D=3D NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st =3D RTA_DATA(xstats);
+	if (st->type =3D=3D TCA_FQ_CODEL_XSTATS_QDISC) {
+		fprintf(f, "  maxpacket %u drop_overlimit %u new_flow_count %u ecn_m=
ark %u",
+			st->qdisc_stats.maxpacket,
+			st->qdisc_stats.drop_overlimit,
+			st->qdisc_stats.new_flow_count,
+			st->qdisc_stats.ecn_mark);
+		fprintf(f, "\n  new_flows_len %u old_flows_len %u",
+			st->qdisc_stats.new_flows_len,
+			st->qdisc_stats.old_flows_len);
+	}
+	if (st->type =3D=3D TCA_FQ_CODEL_XSTATS_CLASS) {
+		fprintf(f, "  deficit %d count %u lastcount %u ldelay %s",
+			st->class_stats.deficit,
+			st->class_stats.count,
+			st->class_stats.lastcount,
+			sprint_time(st->class_stats.ldelay, b1));
+		if (st->class_stats.dropping) {
+			fprintf(f, " dropping");
+			if (st->class_stats.drop_next < 0)
+				fprintf(f, " drop_next -%s",
+					sprint_time(-st->class_stats.drop_next, b1));
+			else
+				fprintf(f, " drop_next %s",
+					sprint_time(st->class_stats.drop_next, b1));
+		}
+	}
+	return 0;
+
+}
+
+struct qdisc_util fq_codel_qdisc_util =3D {
+	.id		=3D "fq_codel",
+	.parse_qopt	=3D fq_codel_parse_opt,
+	.print_qopt	=3D fq_codel_print_opt,
+	.print_xstats	=3D fq_codel_print_xstats,
+};
