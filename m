From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH iproute2] ip route: support RFC4191 router preference
Date: Mon, 16 Mar 2015 16:01:47 +0100
Message-ID: <1426518107-26461-1-git-send-email-lkundrak@v3.sk>
Cc: Stephen Hemminger <shemming@brocade.com>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555AbbCPPCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 11:02:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows querying and setting the route preference. It's usually set from
the IPv6 Neighbor Discovery Router Advertisement messages.

Introduced in "ipv6: expose RFC4191 route preference via rtnetlink", enqueued
for Linux 4.1.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---

This may need some discussion and changes: "pref" was previously accepted as 
short for "preference" which is for some reason an alternative mnemonics for 
"metric" or "priority." I, however, doubt anyone uses it and it does not seem
to have been documented.

Alternative spellings might be "rtpref" or "rt_pref"?

 doc/ip-cref.tex           | 11 +++++++++++
 include/linux/rtnetlink.h |  1 +
 ip/iproute.c              | 35 ++++++++++++++++++++++++++++++++++-
 man/man8/ip-route.8.in    | 28 ++++++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index e7a79a5..ea14795 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -1432,6 +1432,17 @@ database.
 even if it does not match any interface prefix. One application of this
 option may be found in~\cite{IP-TUNNELS}.
 
+\item \verb|pref PREF|
+
+--- the IPv6 route preference.
+\verb|PREF| PREF is a string specifying the route preference as defined in
+RFC4191 for Router Discovery messages. Namely:
+\begin{itemize}
+\item \verb|low| --- the route has a lowest priority.
+\item \verb|medium| --- the route has a default priority.
+\item \verb|high| --- the route has a highest priority.
+\end{itemize}
+
 \end{itemize}
 
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3eb7810..fb0f7ac 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -303,6 +303,7 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_PREF,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index b32025f..5a3a516 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -23,6 +23,7 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <linux/in_route.h>
+#include <linux/icmpv6.h>
 #include <errno.h>
 
 #include "rt_names.h"
@@ -82,12 +83,14 @@ static void usage(void)
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
 	fprintf(stderr, "           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n");
+	fprintf(stderr, "           [ pref PREF ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
 	fprintf(stderr, "SCOPE := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "NHFLAGS := [ onlink | pervasive ]\n");
 	fprintf(stderr, "RTPROTO := [ kernel | boot | static | NUMBER ]\n");
+	fprintf(stderr, "PREF := [ low | medium | high ]\n");
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
 	fprintf(stderr, "BOOL := [1|0]\n");
 	fprintf(stderr, "FEATURES := ecn\n");
@@ -629,6 +632,24 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			nh = RTNH_NEXT(nh);
 		}
 	}
+	if (tb[RTA_PREF]) {
+		unsigned int pref = rta_getattr_u8(tb[RTA_PREF]);
+		fprintf(fp, " pref ");
+
+		switch (pref) {
+		case ICMPV6_ROUTER_PREF_LOW:
+			fprintf(fp, "low");
+			break;
+		case ICMPV6_ROUTER_PREF_MEDIUM:
+			fprintf(fp, "medium");
+			break;
+		case ICMPV6_ROUTER_PREF_HIGH:
+			fprintf(fp, "high");
+			break;
+		default:
+			fprintf(fp, "%u", pref);
+		}
+	}
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
@@ -782,7 +803,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			req.r.rtm_tos = tos;
 		} else if (matches(*argv, "metric") == 0 ||
 			   matches(*argv, "priority") == 0 ||
-			   matches(*argv, "preference") == 0) {
+			   strcmp(*argv, "preference") == 0) {
 			__u32 metric;
 			NEXT_ARG();
 			if (get_u32(&metric, *argv, 0))
@@ -979,6 +1000,18 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			   strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
 			d = *argv;
+		} else if (matches(*argv, "pref") == 0) {
+			__u8 pref;
+			NEXT_ARG();
+			if (strcmp(*argv, "low") == 0)
+				pref = ICMPV6_ROUTER_PREF_LOW;
+			else if (strcmp(*argv, "medium") == 0)
+				pref = ICMPV6_ROUTER_PREF_MEDIUM;
+			else if (strcmp(*argv, "high") == 0)
+				pref = ICMPV6_ROUTER_PREF_HIGH;
+			else if (get_u8(&pref, *argv, 0))
+				invarg("\"pref\" value is invalid\n", *argv);
+			addattr8(&req.n, sizeof(req), RTA_PREF, pref);
 		} else {
 			int type;
 			inet_prefix dst;
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 2b1583d..e587fc1 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -119,6 +119,8 @@ replace " } "
 .IR BOOL " ] [ "
 .B  congctl
 .IR NAME " ]"
+.B  pref
+.IR PREF " ]"
 
 .ti -8
 .IR TYPE " := [ "
@@ -148,6 +150,10 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR FEATURES " := [ "
 .BR ecn " | ]"
 
+.ti -8
+.IR PREF " := [ "
+.BR low " | " medium " | " high " ]"
+
 
 .SH DESCRIPTION
 .B ip route
@@ -551,6 +557,28 @@ to assign (or not to assign) protocol tags.
 .B onlink
 pretend that the nexthop is directly attached to this link,
 even if it does not match any interface prefix.
+
+.TP
+.BI pref " PREF"
+the IPv6 route preference.
+.I PREF
+is a string specifying the route preference as defined in RFC4191 for Router
+Discovery messages. Namely:
+
+.in +8
+.B low
+- the route has a lowest priority
+.sp
+
+.B medium
+- the route has a default priority
+.sp
+
+.B high
+- the route has a highest priority
+.sp
+
+.in -8
 .RE
 
 .TP
-- 
2.1.0
