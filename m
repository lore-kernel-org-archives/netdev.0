From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Subject: [PATCH 2/2] Stochastic Fair Blue queue discipline, take two
Date: Wed, 09 Apr 2008 21:52:27 +0200
Message-ID: <87fxtuajr8.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from witko.kerneis.info ([213.186.56.95]:40494 "EHLO
	witko.kerneis.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbYDITw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 15:52:28 -0400
Received: from [2001:660:3301:8061:402a:ada5:712c:69d6] (helo=ip6-localhost)
	by witko.kerneis.info with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <jch@pps.jussieu.fr>)
	id 1JjgLL-0005m6-Oq
	for netdev@vger.kernel.org; Wed, 09 Apr 2008 21:52:27 +0200
Received: from jch by ip6-localhost with local (Exim 4.69)
	(envelope-from <jch@pirx.pps.jussieu.fr>)
	id 1JjgLL-0000pz-D3
	for netdev@vger.kernel.org; Wed, 09 Apr 2008 21:52:27 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch to iproute.  After applying this, you will need to manually copy
over sfb.h from your kernel tree into include/.

                                        Juliusz
diff --git a/tc/Makefile b/tc/Makefile
index bf2df00..9939c4a 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -8,6 +8,7 @@ TCMODULES :=
 TCMODULES += q_fifo.o
 TCMODULES += q_sfq.o
 TCMODULES += q_red.o
+TCMODULES += q_sfb.o
 TCMODULES += q_prio.o
 TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
diff --git a/tc/q_sfb.c b/tc/q_sfb.c
new file mode 100644
index 0000000..70b3d6e
--- /dev/null
+++ b/tc/q_sfb.c
@@ -0,0 +1,237 @@
+/*
+ * q_red.c	Stochastic Fair Blue.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
+ *
+ */
+
+
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
+#include "sfb.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... sfb "
+		"hashes N buckets N hash-type TYPE rehash SECS db SECS\n"
+		"	    limit PACKETS max PACKETS target PACKETS\n"
+		"	    increment FLOAT decrement FLOAT\n"
+		"	    penalty_rate PPS penalty_burst PACKETS\n");
+}
+
+static int get_prob(__u16 *val, const char *arg)
+{
+	double d;
+	char *ptr;
+
+	if(!arg || !*arg)
+		return -1;
+	d = strtod(arg, &ptr);
+	if(!ptr || ptr == arg || d < 0.0 || d > 1.0)
+		return -1;
+	*val = (__u16)(d * SFB_MAX_PROB + 0.5);
+	return 0;
+}
+
+static char *
+hash_type(__u8 val)
+{
+	switch(val) {
+	case SFB_HASH_FLOW: return "flow";
+	case SFB_HASH_SOURCE: return "source";
+	case SFB_HASH_DEST: return "dest";
+	case SFB_HASH_SOURCE_DEST: return "source-dest";
+	default: return "???";
+	}
+}
+
+static int get_hash_type(__u8 *val, const char *arg)
+{
+	if(strcmp(arg, "flow") == 0)
+		*val = SFB_HASH_FLOW;
+	else if(strcmp(arg, "source") == 0)
+		*val = SFB_HASH_SOURCE;
+	else if(strcmp(arg, "dest") == 0)
+		*val = SFB_HASH_DEST;
+	else if(strcmp(arg, "source-dest") == 0)
+		*val = SFB_HASH_SOURCE_DEST;
+	else
+		return -1;
+
+	return 0;
+}
+
+static int sfb_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	struct tc_sfb_qopt opt;
+	struct rtattr *tail;
+
+	memset(&opt, 0, sizeof(opt));
+	opt.rehash_interval = 600;
+	opt.db_interval = 60;
+	opt.penalty_rate = 10;
+	opt.penalty_burst = 20;
+	opt.increment = (SFB_MAX_PROB + 500) / 1000;
+	opt.decrement = (SFB_MAX_PROB + 3000) / 6000;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "hash-type") == 0) {
+			NEXT_ARG();
+			if (get_hash_type(&opt.hash_type, *argv)) {
+				fprintf(stderr, "Illegal \"hash-type\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "rehash") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.rehash_interval, *argv, 0)) {
+				fprintf(stderr, "Illegal \"rehash\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "db") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.db_interval, *argv, 0)) {
+				fprintf(stderr, "Illegal \"db\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "max") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.max, *argv, 0)) {
+				fprintf(stderr, "Illegal \"max\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "target") == 0) {
+			NEXT_ARG();
+			if (get_u16(&opt.target, *argv, 0)) {
+				fprintf(stderr, "Illegal \"target\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "increment") == 0) {
+			NEXT_ARG();
+			if (get_prob(&opt.increment, *argv)) {
+				fprintf(stderr, "Illegal \"increment\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "decrement") == 0) {
+			NEXT_ARG();
+			if (get_prob(&opt.decrement, *argv)) {
+				fprintf(stderr, "Illegal \"decrement\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "penalty_rate") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.penalty_rate, *argv, 0)) {
+				fprintf(stderr, "Illegal \"penalty_rate\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "penalty_burst") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.penalty_burst, *argv, 0)) {
+				fprintf(stderr, "Illegal \"penalty_burst\"\n");
+				return -1;
+			}
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	if(opt.max == 0) {
+		if(opt.target >= 1)
+			opt.max = (opt.target * 11 + 9) / 10;
+		else
+			opt.max = 22;
+	}
+	if(opt.target == 0)
+		opt.target = (opt.max * 10 + 10) / 11;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	addattr_l(n, 1024, TCA_SFB_PARMS, &opt, sizeof(opt));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int sfb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[__TCA_SFB_MAX];
+	struct tc_sfb_qopt *qopt;
+
+	if(opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_SFB_MAX, opt);
+	if(tb[TCA_SFB_PARMS] == NULL)
+		return -1;
+	qopt = RTA_DATA(tb[TCA_SFB_PARMS]);
+	if(RTA_PAYLOAD(tb[TCA_SFB_PARMS]) < sizeof(*qopt))
+		return -1;
+
+	fprintf(f,
+		"hash %s limit %d max %d target %d\n"
+		"  increment %.5f decrement %.5f penalty rate %d burst %d "
+		"(%ds %ds)",
+		hash_type(qopt->hash_type),
+		qopt->limit, qopt->max, qopt->target,
+		(double)qopt->increment / SFB_MAX_PROB,
+		(double)qopt->decrement / SFB_MAX_PROB,
+		qopt->penalty_rate, qopt->penalty_burst,
+		qopt->rehash_interval, qopt->db_interval);
+
+	return 0;
+}
+
+static int sfb_print_xstats(struct qdisc_util *qu, FILE *f,
+			    struct rtattr *xstats)
+{
+    struct tc_sfb_xstats *st;
+
+    if(xstats == NULL)
+	    return 0;
+
+    if(RTA_PAYLOAD(xstats) < sizeof(*st))
+	    return -1;
+
+    st = RTA_DATA(xstats);
+    fprintf(f,
+	    "  earlydrop %u penaltydrop %u bucketdrop %u queuedrop %u marked %u\n"
+	    "  maxqlen %u maxprob %.5f",
+	    st->earlydrop, st->penaltydrop, st->bucketdrop, st->queuedrop,
+	    st->marked,
+	    st->maxqlen, (double)st->maxprob / SFB_MAX_PROB);
+
+    return 0;
+}
+
+struct qdisc_util sfb_qdisc_util = {
+	.id		= "sfb",
+	.parse_qopt	= sfb_parse_opt,
+	.print_qopt	= sfb_print_opt,
+	.print_xstats	= sfb_print_xstats,
+};
