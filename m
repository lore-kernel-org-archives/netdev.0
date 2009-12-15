From: chavey@google.com
Subject: [PATCH] Add initrwnd to iproute2
Date: Tue, 15 Dec 2009 15:05:15 -0800
Message-ID: <pvm8wd3alec.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com,
	eric.dumazet@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-239-44-51.google.com ([216.239.44.51]:8192 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761386AbZLOXFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 18:05:23 -0500
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id nBFN5L2E013371
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 15:05:22 -0800
Received: from yxe1 (yxe1.prod.google.com [10.190.2.1])
	by spaceape23.eur.corp.google.com with ESMTP id nBFN5Ijq031702
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 15:05:18 -0800
Received: by yxe1 with SMTP id 1so434450yxe.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 15:05:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initrwnd option parsing to iproute. This option uses the new
rtnetlink init_rcvwnd to set the TCP initial receive window size
advertised by passive and active TCP connections.

Signed-off-by: Laurent Chavey <chavey@google.com>
--
 doc/ip-cref.tex           |    5 +++++
 include/linux/rtnetlink.h |    2 ++
 ip/iproute.c              |   13 ++++++++++++-
 3 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index bb4eb78..2f6511a 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -1324,7 +1324,12 @@ peers are allowed to send to us.
     If it is not given, Linux uses the value selected with \verb|sysctl|
     variable \verb|net/ipv4/tcp_reordering|.
 
+\item \verb|initrwnd NUMBER|
 
+--- [2.6.33+ only] Initial receive window size for connections to 
+    this destination. The actual window size is this value multiplied
+    by the MSS (''Maximal Segment Size'') of the connection. The default
+    value is zero, meaning to use Slow Start value.
 
 \item \verb|nexthop NEXTHOP|
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 63d1c69..3373544 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -371,6 +371,8 @@ enum
 #define RTAX_FEATURES RTAX_FEATURES
 	RTAX_RTO_MIN,
 #define RTAX_RTO_MIN RTAX_RTO_MIN
+	RTAX_INITRWND,
+#define RTAX_INITRWND RTAX_INITRWND
 	__RTAX_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index bf0f31b..5df1eaf 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -51,6 +51,7 @@ static const char *mx_names[RTAX_MAX+1] = {
 	[RTAX_INITCWND] = "initcwnd",
 	[RTAX_FEATURES] = "features",
 	[RTAX_RTO_MIN]	= "rto_min",
+	[RTAX_INITRWND]	= "initrwnd",
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -73,7 +74,7 @@ static void usage(void)
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
-	fprintf(stderr, "           [ rto_min TIME ]\n");
+	fprintf(stderr, "           [ rto_min TIME ] [ initrwnd NUMBER ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -842,6 +843,16 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (get_unsigned(&win, *argv, 0))
 				invarg("\"initcwnd\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_INITCWND, win);
+		} else if (matches(*argv, "initrwnd") == 0) {
+			unsigned win;
+			NEXT_ARG();
+			if (strcmp(*argv, "lock") == 0) {
+				mxlock |= (1<<RTAX_INITRWND);
+				NEXT_ARG();
+			}
+			if (get_unsigned(&win, *argv, 0))
+				invarg("\"initrwnd\" value is invalid\n", *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_INITRWND, win);
 		} else if (matches(*argv, "rttvar") == 0) {
 			unsigned win;
 			NEXT_ARG();
