From: Christoph Paasch <cpaasch@apple.com>
Subject: [PATCH v2 iproute2] ip: add fastopen_no_cookie option to ip route
Date: Tue, 31 Oct 2017 14:54:52 -0700
Message-ID: <20171031215452.7580-1-cpaasch@apple.com>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out24.apple.com ([17.171.2.34]:62627 "EHLO
        mail-in24.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752473AbdJaVyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 17:54:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
without a cookie on a per-route basis.

Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
cookie per socket and/or per route).

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Christoph Paasch <cpaasch@apple.com>
---

Notes:
    resend: Rebase on top of origin/net-next

 ip/iproute.c           | 42 ++++++++++++++++++++++++++----------------
 man/man8/ip-route.8.in |  8 +++++++-
 2 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8b158e692f75..da017ef09926 100644
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
 
@@ -90,7 +91,7 @@ static void usage(void)
 		"           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n"
 		"           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n"
 		"           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n"
-		"           [ pref PREF ] [ expires TIME ]\n"
+		"           [ pref PREF ] [ expires TIME ] [ fastopen_no_cookie BOOL ]\n"
 		"TYPE := { unicast | local | broadcast | multicast | throw |\n"
 		"          unreachable | prohibit | blackhole | nat }\n"
 		"TABLE_ID := [ local | main | default | all | NUMBER ]\n"
@@ -1224,6 +1225,15 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 
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
index 705ceb2054dc..f9c92259f796 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -141,7 +141,9 @@ replace " } "
 .B  pref
 .IR PREF " ] [ "
 .B  expires
-.IR TIME " ]"
+.IR TIME " ] ["
+.B  fastopen_no_cookie
+.IR BOOL " ]"
 
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
