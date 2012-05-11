From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc_codel: Controlled Delay AQM
Date: Fri, 11 May 2012 08:22:35 +0200
Message-ID: <1336717355.31653.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63629 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758289Ab2EKGWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 02:22:40 -0400
Received: by weyu7 with SMTP id u7so166315wey.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 23:22:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

An implementation of CoDel AQM, from Kathleen Nichols and Van Jacobson. 

http://queue.acm.org/detail.cfm?id=2209336 

This AQM main input is no longer queue size in bytes or packets, but the
delay packets stay in (FIFO) queue.

As we don't have infinite memory, we still can drop packets in enqueue()
in case of massive load, but mean of CoDel is to drop packets in
dequeue(), using a control law based on two simple parameters :

target : target sojourn time (default 5ms)
interval : width of moving time window (default 100ms)

Selected packets are dropped, unless ECN is enabled and packets can get
ECN mark instead.

Usage: tc qdisc ... codel [ limit PACKETS ] [ target TIME ]
                          [ interval TIME ] [ ecn ]

qdisc codel 10: parent 1:1 limit 2000p target 3.0ms interval 60.0ms ecn 
 Sent 13347099587 bytes 8815805 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 202365Kbit 16708pps backlog 113550b 75p requeues 0 
  count 116 lastcount 98 ldelay 4.3ms dropping drop_next 816us
  maxpacket 1514 ecn_mark 84399 drop_overlimit 0

CoDel must be seen as a base module, and should be used keeping in mind
there is still a FIFO queue. So a typical setup will probably need a
hierarchy of several qdiscs and packet classifiers to be able to meet
whatever constraints a user might have.

One possible example would be to use fq_codel, which combines Fair
Queueing and CoDel, in replacement of sfq / sfq_red.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
---
Notes :
1) : Dave Taht will send a nice man-page for this stuff.
2) : the TCA_NETEM_ECN bit is because of include/linux/pkt_sched.h sync
with net-next
     (I'll send a separate patch for netem)

      * 
 include/linux/pkt_sched.h |   27 +++++
 tc/Makefile               |    1 
 tc/q_codel.c              |  188 ++++++++++++++++++++++++++++++++++++
 3 files changed, 216 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 410b33d..cde56c2 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -509,6 +509,7 @@ enum {
 	TCA_NETEM_CORRUPT,
 	TCA_NETEM_LOSS,
 	TCA_NETEM_RATE,
+	TCA_NETEM_ECN,
 	__TCA_NETEM_MAX,
 };
 
@@ -654,4 +655,30 @@ struct tc_qfq_stats {
 	__u32 lmax;
 };
 
+/* CODEL */
+
+enum {
+	TCA_CODEL_UNSPEC,
+	TCA_CODEL_TARGET,
+	TCA_CODEL_LIMIT,
+	TCA_CODEL_INTERVAL,
+	TCA_CODEL_ECN,
+	__TCA_CODEL_MAX
+};
+
+#define TCA_CODEL_MAX	(__TCA_CODEL_MAX - 1)
+
+struct tc_codel_xstats {
+	__u32	maxpacket; /* largest packet we've seen so far */
+	__u32	count;	   /* how many drops we've done since the last time we
+			    * entered dropping state
+			    */
+	__u32	lastcount; /* count at entry to dropping state */
+	__u32	ldelay;    /* in-queue delay seen by most recently dequeued packet */
+	__s32	drop_next; /* time to drop next packet */
+	__u32	drop_overlimit; /* number of time max qdisc packet limit was hit */
+	__u32	ecn_mark;  /* number of packets we ECN marked instead of dropped */
+	__u32	dropping;  /* are we in dropping state ? */
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index be8cd5a..8a7cc8d 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -47,6 +47,7 @@ TCMODULES += em_cmp.o
 TCMODULES += em_u32.o
 TCMODULES += em_meta.o
 TCMODULES += q_mqprio.o
+TCMODULES += q_codel.o
 
 TCSO :=
 ifeq ($(TC_CONFIG_ATM),y)
diff --git a/tc/q_codel.c b/tc/q_codel.c
new file mode 100644
index 0000000..9f40046
--- /dev/null
+++ b/tc/q_codel.c
@@ -0,0 +1,188 @@
+/*
+ * Codel - The Controlled-Delay Active Queue Management algorithm
+ *
+ *  Copyright (C) 2011-2012 Kathleen Nichols <nichols@pollere.com>
+ *  Copyright (C) 2011-2012 Van Jacobson <van@pollere.com>
+ *  Copyright (C) 2012 Michael D. Taht <dave.taht@bufferbloat.net>
+ *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, and the following disclaimer,
+ *    without modification.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The names of the authors may not be used to endorse or promote products
+ *    derived from this software without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
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
+	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME]\n");
+	fprintf(stderr, "                 [ interval TIME ] [ ecn ]\n");
+}
+
+static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			   struct nlmsghdr *n)
+{
+	unsigned limit = 0;
+	unsigned target = 0;
+	unsigned interval = 0;
+	int ecn = -1;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "target") == 0) {
+			NEXT_ARG();
+			if (get_time(&target, *argv)) {
+				fprintf(stderr, "Illegal \"target\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "interval") == 0) {
+			NEXT_ARG();
+			if (get_time(&interval, *argv)) {
+				fprintf(stderr, "Illegal \"interval\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "ecn") == 0) {
+			ecn = 1;
+		} else if (strcmp(*argv, "noecn") == 0) {
+			ecn = 0;
+		} else if (strcmp(*argv, "help") == 0) {
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
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (limit)
+		addattr_l(n, 1024, TCA_CODEL_LIMIT, &limit, sizeof(limit));
+	if (interval)
+		addattr_l(n, 1024, TCA_CODEL_INTERVAL, &interval, sizeof(interval));
+	if (target)
+		addattr_l(n, 1024, TCA_CODEL_TARGET, &target, sizeof(target));
+	if (ecn != -1)
+		addattr_l(n, 1024, TCA_CODEL_ECN, &ecn, sizeof(ecn));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_CODEL_MAX + 1];
+	unsigned limit;
+	unsigned interval;
+	unsigned target;
+	unsigned ecn;
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CODEL_MAX, opt);
+
+	if (tb[TCA_CODEL_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_CODEL_LIMIT]) >= sizeof(__u32)) {
+		limit = rta_getattr_u32(tb[TCA_CODEL_LIMIT]);
+		fprintf(f, "limit %up ", limit);
+	}
+	if (tb[TCA_CODEL_TARGET] &&
+	    RTA_PAYLOAD(tb[TCA_CODEL_TARGET]) >= sizeof(__u32)) {
+		target = rta_getattr_u32(tb[TCA_CODEL_TARGET]);
+		fprintf(f, "target %s ", sprint_time(target, b1));
+	}
+	if (tb[TCA_CODEL_INTERVAL] &&
+	    RTA_PAYLOAD(tb[TCA_CODEL_INTERVAL]) >= sizeof(__u32)) {
+		interval = rta_getattr_u32(tb[TCA_CODEL_INTERVAL]);
+		fprintf(f, "interval %s ", sprint_time(interval, b1));
+	}
+	if (tb[TCA_CODEL_ECN] &&
+	    RTA_PAYLOAD(tb[TCA_CODEL_ECN]) >= sizeof(__u32)) {
+		ecn = rta_getattr_u32(tb[TCA_CODEL_ECN]);
+		if (ecn)
+			fprintf(f, "ecn ");
+	}
+
+	return 0;
+}
+
+static int codel_print_xstats(struct qdisc_util *qu, FILE *f,
+			      struct rtattr *xstats)
+{
+	struct tc_codel_xstats *st;
+	SPRINT_BUF(b1);
+
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+	fprintf(f, "  count %u lastcount %u ldelay %s",
+		st->count, st->lastcount, sprint_time(st->ldelay, b1));
+	if (st->dropping)
+		fprintf(f, " dropping");
+	if (st->drop_next < 0)
+		fprintf(f, " drop_next -%s", sprint_time(-st->drop_next, b1));
+	else
+		fprintf(f, " drop_next %s", sprint_time(st->drop_next, b1));
+	fprintf(f, "\n  maxpacket %u ecn_mark %u drop_overlimit %u",
+		st->maxpacket, st->ecn_mark, st->drop_overlimit); 
+	return 0;
+
+}
+
+struct qdisc_util codel_qdisc_util = {
+	.id		= "codel",
+	.parse_qopt	= codel_parse_opt,
+	.print_qopt	= codel_print_opt,
+	.print_xstats	= codel_print_xstats,
+};
