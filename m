From: Kees van Reeuwijk <kees.van.reeuwijk@gmail.com>
Subject: [PATCH] iproute2: clearer error messages for fifo and tbf qdiscs
Date: Tue, 19 Feb 2013 18:46:04 +0100
Message-ID: <E1U7rGW-0001at-2Z@babylon.few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:41532 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933041Ab3BSRuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 12:50:22 -0500
Received: by mail-wg0-f47.google.com with SMTP id dr13so5586150wgb.26
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 09:50:20 -0800 (PST)
Received: from reeuwijk by babylon.few.vu.nl with local (Exim 4.72)
	(envelope-from <reeuwijk@few.vu.nl>)
	id 1U7rGW-0001at-2Z
	for netdev@vger.kernel.org; Tue, 19 Feb 2013 18:46:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Clearer error messages for fifo and tbf qdiscs:
- Say who is complaining
- Don't just say a parameter is bad, show the offending parameter
- Be clearer about duplicate parameters vs illegal pairs of parameters
- Try to give multiple error messages rather than let the user discover the errors one by one
- When there are parameter aliases, try to use the variant that was used, or at least mention them all

Note that in the old version an empty parameter list to tbf would just cause an explain() message
without a specific error message. By simply removing the relevant error check, the code now
handles this error more gracefully by printing an error message for all mandatory parameters.
It still prints the explain() message.




Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---

 q_fifo.c |    4 +-
 q_tbf.c  |   90 ++++++++++++++++++++++++++++++++++++++------------------------
 2 files changed, 57 insertions(+), 37 deletions(-)

diff --git a/tc/q_fifo.c b/tc/q_fifo.c
index 6242a98..c9ab123 100644
--- a/tc/q_fifo.c
+++ b/tc/q_fifo.c
@@ -38,7 +38,7 @@ static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			if (get_size(&opt.limit, *argv)) {
-				fprintf(stderr, "Illegal \"limit\"\n");
+				fprintf(stderr, "%s: Illegal value for \"limit\": \"%s\"\n", qu->id, *argv);
 				return -1;
 			}
 			ok++;
@@ -46,7 +46,7 @@ static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			fprintf(stderr, "%s: unknown parameter \"%s\"\n", qu->id, *argv);
 			explain();
 			return -1;
 		}
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index dc556fe..034dcf3 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -30,9 +30,9 @@ static void explain(void)
 	fprintf(stderr, "[ overhead BYTES ] [ linklayer TYPE ]\n");
 }

-static void explain1(char *arg)
+static void explain1(const char *arg, const char *val)
 {
-	fprintf(stderr, "Illegal \"%s\"\n", arg);
+	fprintf(stderr, "tbf: illegal value for \"%s\": \"%s\"\n", arg, val);
 }


@@ -53,129 +53,149 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	while (argc > 0) {
 		if (matches(*argv, "limit") == 0) {
 			NEXT_ARG();
-			if (opt.limit || latency) {
-				fprintf(stderr, "Double \"limit/latency\" spec\n");
+			if (opt.limit) {
+				fprintf(stderr, "tbf: duplicate \"limit\" specification\n");
+				return -1;
+			}
+			if (latency) {
+				fprintf(stderr, "tbf: specifying both \"latency\" and \"limit\" is not allowed\n");
 				return -1;
 			}
 			if (get_size(&opt.limit, *argv)) {
-				explain1("limit");
+				explain1("limit", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (matches(*argv, "latency") == 0) {
 			NEXT_ARG();
-			if (opt.limit || latency) {
-				fprintf(stderr, "Double \"limit/latency\" spec\n");
+			if (latency) {
+				fprintf(stderr, "tbf: duplicate \"latency\" specification\n");
+				return -1;
+			}
+			if (opt.limit) {
+				fprintf(stderr, "tbf: specifying both \"limit\" and \"/latency\" is not allowed\n");
 				return -1;
 			}
 			if (get_time(&latency, *argv)) {
-				explain1("latency");
+				explain1("latency", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (matches(*argv, "burst") == 0 ||
 			strcmp(*argv, "buffer") == 0 ||
 			strcmp(*argv, "maxburst") == 0) {
+			const char *parm_name = *argv;
 			NEXT_ARG();
 			if (buffer) {
-				fprintf(stderr, "Double \"buffer/burst\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"buffer/burst/maxburst\" specification\n");
 				return -1;
 			}
 			if (get_size_and_cell(&buffer, &Rcell_log, *argv) < 0) {
-				explain1("buffer");
+				explain1(parm_name, *argv);
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "mtu") == 0 ||
 			   strcmp(*argv, "minburst") == 0) {
+			const char *parm_name = *argv;
 			NEXT_ARG();
 			if (mtu) {
-				fprintf(stderr, "Double \"mtu/minburst\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"mtu/minburst\" specification\n");
 				return -1;
 			}
 			if (get_size_and_cell(&mtu, &Pcell_log, *argv) < 0) {
-				explain1("mtu");
+				explain1(parm_name, *argv);
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "mpu") == 0) {
 			NEXT_ARG();
 			if (mpu) {
-				fprintf(stderr, "Double \"mpu\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"mpu\" specification\n");
 				return -1;
 			}
 			if (get_size(&mpu, *argv)) {
-				explain1("mpu");
+				explain1("mpu", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "rate") == 0) {
 			NEXT_ARG();
 			if (opt.rate.rate) {
-				fprintf(stderr, "Double \"rate\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"rate\" specification\n");
 				return -1;
 			}
 			if (get_rate(&opt.rate.rate, *argv)) {
-				explain1("rate");
+				explain1("rate", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (matches(*argv, "peakrate") == 0) {
 			NEXT_ARG();
 			if (opt.peakrate.rate) {
-				fprintf(stderr, "Double \"peakrate\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"peakrate\" specification\n");
 				return -1;
 			}
 			if (get_rate(&opt.peakrate.rate, *argv)) {
-				explain1("peakrate");
+				explain1("peakrate", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (matches(*argv, "overhead") == 0) {
 			NEXT_ARG();
 			if (overhead) {
-				fprintf(stderr, "Double \"overhead\" spec\n");
+				fprintf(stderr, "tbf: duplicate \"overhead\" specification\n");
 				return -1;
 			}
 			if (get_u16(&overhead, *argv, 10)) {
-				explain1("overhead"); return -1;
+				explain1("overhead", *argv); return -1;
 			}
 		} else if (matches(*argv, "linklayer") == 0) {
 			NEXT_ARG();
 			if (get_linklayer(&linklayer, *argv)) {
-				explain1("linklayer"); return -1;
+				explain1("linklayer", *argv); return -1;
 			}
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			fprintf(stderr, "tbf: unknown parameter \"%s\"\n", *argv);
 			explain();
 			return -1;
 		}
 		argc--; argv++;
 	}

-	if (!ok) {
-		explain();
-		return -1;
-	}
+        int verdict = 0;

-	if (opt.rate.rate == 0 || !buffer) {
-		fprintf(stderr, "Both \"rate\" and \"burst\" are required.\n");
-		return -1;
+        /* Be nice to the user: try to emit all error messages in
+         * one go rather than reveal one more problem when a
+         * previous one has been fixed.
+         */
+	if (opt.rate.rate == 0) {
+		fprintf(stderr, "tbf: the \"rate\" parameter is mandatory.\n");
+		verdict = -1;
+	}
+	if (!buffer) {
+		fprintf(stderr, "tbf: the \"burst\" parameter is mandatory.\n");
+		verdict = -1;
 	}
 	if (opt.peakrate.rate) {
 		if (!mtu) {
-			fprintf(stderr, "\"mtu\" is required, if \"peakrate\" is requested.\n");
-			return -1;
+			fprintf(stderr, "tbf: when \"peakrate\" is specified, \"mtu\" must also be specified.\n");
+			verdict = -1;
 		}
 	}

 	if (opt.limit == 0 && latency == 0) {
-		fprintf(stderr, "Either \"limit\" or \"latency\" are required.\n");
-		return -1;
+		fprintf(stderr, "tbf: either \"limit\" or \"latency\" is required.\n");
+		verdict = -1;
 	}
+
+        if (verdict != 0) {
+                explain();
+                return verdict;
+        }

 	if (opt.limit == 0) {
 		double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
@@ -190,7 +210,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	opt.rate.mpu      = mpu;
 	opt.rate.overhead = overhead;
 	if (tc_calc_rtable(&opt.rate, rtab, Rcell_log, mtu, linklayer) < 0) {
-		fprintf(stderr, "TBF: failed to calculate rate table.\n");
+		fprintf(stderr, "tbf: failed to calculate rate table.\n");
 		return -1;
 	}
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
@@ -199,7 +219,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		opt.peakrate.mpu      = mpu;
 		opt.peakrate.overhead = overhead;
 		if (tc_calc_rtable(&opt.peakrate, ptab, Pcell_log, mtu, linklayer) < 0) {
-			fprintf(stderr, "TBF: failed to calculate peak rate table.\n");
+			fprintf(stderr, "tbf: failed to calculate peak rate table.\n");
 			return -1;
 		}
 		opt.mtu = tc_calc_xmittime(opt.peakrate.rate, mtu);
