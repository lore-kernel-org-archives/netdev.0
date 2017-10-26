From: Christoph Paasch <cpaasch@apple.com>
Subject: [PATCH iproute2] ip: add fastopen_no_cookie option to ip route
Date: Thu, 26 Oct 2017 11:10:38 -0700
Message-ID: <20171026181038.23929-1-cpaasch@apple.com>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out7.apple.com ([17.151.62.29]:51167 "EHLO
        mail-in7.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932332AbdJZSKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 14:10:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
without a cookie on a per-route basis.

Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
cookie per socket and/or per route).

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Christoph Paasch <cpaasch@apple.com>
---
 include/uapi/linux/rtnetlink.h |  2 ++
 ip/iproute.c                   | 42 ++++++++++++++++++++++++++----------------
 man/man8/ip-route.8.in         |  6 ++++++
 3 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 813e9e0767d3..ff0eec7329c6 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -430,6 +430,8 @@ enum {
 #define RTAX_QUICKACK RTAX_QUICKACK
 	RTAX_CC_ALGO,
 #define RTAX_CC_ALGO RTAX_CC_ALGO
+	RTAX_FASTOPEN_NO_COOKIE,
+#define RTAX_FASTOPEN_NO_COOKIE RTAX_FASTOPEN_NO_COOKIE
 	__RTAX_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index e81bc05ec16c..eadf0394de7f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -41,21 +41,22 @@ enum list_action {
 	IPROUTE_SAVE,
 };
 static const char *mx_names[RTAX_MAX+1] = {
-	[RTAX_MTU]	= "mtu",
-	[RTAX_WINDOW]	= "window",
-	[RTAX_RTT]	= "rtt",
-	[RTAX_RTTVAR]	= "rttvar",
-	[RTAX_SSTHRESH] = "ssthresh",
-	[RTAX_CWND]	= "cwnd",
-	[RTAX_ADVMSS]	= "advmss",
-	[RTAX_REORDERING] = "reordering",
-	[RTAX_HOPLIMIT] = "hoplimit",
-	[RTAX_INITCWND] = "initcwnd",
-	[RTAX_FEATURES] = "features",
-	[RTAX_RTO_MIN]	= "rto_min",
-	[RTAX_INITRWND]	= "initrwnd",
-	[RTAX_QUICKACK]	= "quickack",
-	[RTAX_CC_ALGO]	= "congctl",
+	[RTAX_MTU]			= "mtu",
+	[RTAX_WINDOW]			= "window",
+	[RTAX_RTT]			= "rtt",
+	[RTAX_RTTVAR]			= "rttvar",
+	[RTAX_SSTHRESH]			= "ssthresh",
+	[RTAX_CWND]			= "cwnd",
+	[RTAX_ADVMSS]			= "advmss",
+	[RTAX_REORDERING]		= "reordering",
+	[RTAX_HOPLIMIT]			= "hoplimit",
+	[RTAX_INITCWND]			= "initcwnd",
+	[RTAX_FEATURES]			= "features",
+	[RTAX_RTO_MIN]			= "rto_min",
+	[RTAX_INITRWND]			= "initrwnd",
+	[RTAX_QUICKACK]			= "quickack",
+	[RTAX_CC_ALGO]			= "congctl",
+	[RTAX_FASTOPEN_NO_COOKIE]	= "fastopen_no_cookie"
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -89,7 +90,7 @@ static void usage(void)
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
 	fprintf(stderr, "           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n");
-	fprintf(stderr, "           [ pref PREF ] [ expires TIME ]\n");
+	fprintf(stderr, "           [ pref PREF ] [ expires TIME ] [ fastopen_no_cookie BOOL ]\n");
 	fprintf(stderr, "TYPE := { unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat }\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -1216,6 +1217,15 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 			addattr8(&req.n, sizeof(req), RTA_TTL_PROPAGATE,
 				 ttl_prop);
+		} else if (matches(*argv, "fastopen_no_cookie") == 0) {
+			unsigned int fastopen_no_cookie;
+
+			NEXT_ARG();
+			if (get_unsigned(&fastopen_no_cookie, *argv, 0))
+				invarg("\"fastopen_no_cookie\" value is invalid\n", *argv);
+			if (fastopen_no_cookie != 1 && fastopen_no_cookie != 0)
+				invarg("\"fastopen_no_cookie\" value should be 0 or 1\n", *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_FASTOPEN_NO_COOKIE, fastopen_no_cookie);
 		} else {
 			int type;
 			inet_prefix dst;
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 705ceb2054dc..a863769526f3 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -142,6 +142,8 @@ replace " } "
 .IR PREF " ] [ "
 .B  expires
 .IR TIME " ]"
+.B  fastopen_no_cookie
+.IR BOOL " ] [ "
 
 .ti -8
 .IR TYPE " := [ "
@@ -524,6 +526,10 @@ sysctl is set to 0.
 .BI quickack " BOOL " "(3.11+ only)"
 Enable or disable quick ack for connections to this destination.
 
+.TP
+.BI fastopen_no_cookie " BOOL " "(4.15+ only)"
+Enable TCP Fastopen without a cookie for connections to this destination.
+
 .TP
 .BI congctl " NAME " "(3.20+ only)"
 .TP
-- 
2.14.1
