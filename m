From: Cong Wang <amwang@redhat.com>
Subject: [Patch iproute2] add quickack option to ip route
Date: Sat, 15 Jun 2013 09:39:19 +0800
Message-ID: <1371260359-5875-2-git-send-email-amwang@redhat.com>
References: <1371260359-5875-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285Ab3FOBkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 21:40:01 -0400
In-Reply-To: <1371260359-5875-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch adds quickack option to enable/disable TCP quick ack
mode for per-route.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 93370bd..248fdd3 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -386,6 +386,8 @@ enum {
 #define RTAX_RTO_MIN RTAX_RTO_MIN
 	RTAX_INITRWND,
 #define RTAX_INITRWND RTAX_INITRWND
+	RTAX_QUICKACK,
+#define RTAX_QUICKACK RTAX_QUICKACK
 	__RTAX_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index adef774..46710b2 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -52,6 +52,7 @@ static const char *mx_names[RTAX_MAX+1] = {
 	[RTAX_FEATURES] = "features",
 	[RTAX_RTO_MIN]	= "rto_min",
 	[RTAX_INITRWND]	= "initrwnd",
+	[RTAX_QUICKACK]	= "quickack",
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -79,6 +80,7 @@ static void usage(void)
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
+	fprintf(stderr, "           [ quickack BOOL ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -86,6 +88,7 @@ static void usage(void)
 	fprintf(stderr, "NHFLAGS := [ onlink | pervasive ]\n");
 	fprintf(stderr, "RTPROTO := [ kernel | boot | static | NUMBER ]\n");
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
+	fprintf(stderr, "BOOL := [1|0]\n");
 	exit(-1);
 }
 
@@ -885,6 +888,14 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (get_unsigned(&win, *argv, 0))
 				invarg("\"initrwnd\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_INITRWND, win);
+		} else if (matches(*argv, "quickack") == 0) {
+			unsigned quickack;
+			NEXT_ARG();
+			if (get_unsigned(&quickack, *argv, 0))
+				invarg("\"quickack\" value is invalid\n", *argv);
+			if (quickack != 1 && quickack != 0)
+				invarg("\"quickack\" value should be 0 or 1\n", *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_QUICKACK, quickack);
 		} else if (matches(*argv, "rttvar") == 0) {
 			unsigned win;
 			NEXT_ARG();
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 2c35a97..01997fa 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -111,6 +111,8 @@ replace " } "
 .IR NUMBER " ] [ "
 .B  initrwnd
 .IR NUMBER " ]"
+.B  quickack
+.IR BOOL " ]"
 
 .ti -8
 .IR TYPE " := [ "
@@ -401,6 +403,10 @@ Actual window size is this value multiplied by the MSS of the connection.
 The default value is zero, meaning to use Slow Start value.
 
 .TP
+.BI quickack " BOOL " "(3.11+ only)"
+Enable or disable quick ack for connections to this destination.
+
+.TP
 .BI advmss " NUMBER " "(2.3.15+ only)"
 the MSS ('Maximal Segment Size') to advertise to these
 destinations when establishing TCP connections.  If it is not given,
