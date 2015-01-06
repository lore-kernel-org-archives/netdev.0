From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2 -next] ip: route: add congestion control metric
Date: Wed,  7 Jan 2015 00:52:37 +0100
Message-ID: <1420588357-17665-1-git-send-email-dborkman@redhat.com>
Cc: fw@strlen.de, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbbAFXwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 18:52:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds configuration and dumping of congestion control metric
for ip route, for example:

  ip route add <dst> dev foo congctl [lock] dctcp

Reference: http://thread.gmane.org/gmane.linux.network/344733
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/rtnetlink.h |  2 ++
 ip/iproute.c              | 24 +++++++++++++++++++++---
 man/man8/ip-route.8.in    | 19 ++++++++++++++++++-
 3 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 9aa5c2f..ac4af97 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -389,6 +389,8 @@ enum {
 #define RTAX_INITRWND RTAX_INITRWND
 	RTAX_QUICKACK,
 #define RTAX_QUICKACK RTAX_QUICKACK
+	RTAX_CC_ALGO,
+#define RTAX_CC_ALGO RTAX_CC_ALGO
 	__RTAX_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 5a496a9..705d4b5 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -53,6 +53,7 @@ static const char *mx_names[RTAX_MAX+1] = {
 	[RTAX_RTO_MIN]	= "rto_min",
 	[RTAX_INITRWND]	= "initrwnd",
 	[RTAX_QUICKACK]	= "quickack",
+	[RTAX_CC_ALGO]	= "congctl",
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -80,8 +81,7 @@ static void usage(void)
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
-	fprintf(stderr, "           [ features FEATURES ]\n");
-	fprintf(stderr, "           [ quickack BOOL ]\n");
+	fprintf(stderr, "           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -545,10 +545,12 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, " %s", mx_names[i]);
 			else
 				fprintf(fp, " metric %d", i);
+
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
+			if (i != RTAX_CC_ALGO)
+				val = *(unsigned*)RTA_DATA(mxrta[i]);
 
-			val = *(unsigned*)RTA_DATA(mxrta[i]);
 			switch (i) {
 			case RTAX_FEATURES:
 				print_rtax_features(fp, val);
@@ -573,6 +575,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					fprintf(fp, " %gs", val/1e3);
 				else
 					fprintf(fp, " %ums", val);
+				break;
+			case RTAX_CC_ALGO:
+				fprintf(fp, " %s", (char *)RTA_DATA(mxrta[i]));
+				break;
 			}
 		}
 	}
@@ -925,6 +931,18 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (quickack != 1 && quickack != 0)
 				invarg("\"quickack\" value should be 0 or 1\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_QUICKACK, quickack);
+		} else if (matches(*argv, "congctl") == 0) {
+			char cc[16];
+			NEXT_ARG();
+			memset(cc, 0, sizeof(cc));
+			if (strcmp(*argv, "lock") == 0) {
+				mxlock |= (1<<RTAX_CC_ALGO);
+				NEXT_ARG();
+			}
+			strncpy(cc, *argv, sizeof(cc) - 1);
+			if (strlen(cc) == 0)
+				invarg("\"conctl\" value must be an algorithm name\n", *argv);
+			rta_addattr_l(mxrta, sizeof(mxbuf), RTAX_CC_ALGO, cc, strlen(cc));
 		} else if (matches(*argv, "rttvar") == 0) {
 			unsigned win;
 			NEXT_ARG();
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 89960c1..9d32e2d 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -116,7 +116,9 @@ replace " } "
 .B  features
 .IR FEATURES " ] [ "
 .B  quickack
-.IR BOOL " ]"
+.IR BOOL " ] [ "
+.B  congctl
+.IR NAME " ]"
 
 .ti -8
 .IR TYPE " := [ "
@@ -433,6 +435,21 @@ sysctl is set to 0.
 Enable or disable quick ack for connections to this destination.
 
 .TP
+.BI congctl " NAME " "(3.20+ only)"
+.TP
+.BI "congctl lock" " NAME " "(3.20+ only)"
+Sets a specific TCP congestion control algorithm only for a given destination.
+If not specified, Linux keeps the current global default TCP congestion control
+algorithm, or the one set from the application. If the modifier
+.B lock
+is not used, an application may nevertheless overwrite the suggested congestion
+control algorithm for that destination. If the modifier
+.B lock
+is used, then an application is not allowed to overwrite the specified congestion
+control algorithm for that destination, thus it will be enforced/guaranteed to
+use the proposed algorithm.
+
+.TP
 .BI advmss " NUMBER " "(2.3.15+ only)"
 the MSS ('Maximal Segment Size') to advertise to these
 destinations when establishing TCP connections.  If it is not given,
-- 
1.9.0
