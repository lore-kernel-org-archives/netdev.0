From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2 -next v3] ip: route: add congestion control metric
Date: Fri,  9 Jan 2015 00:13:06 +0100
Message-ID: <1420758786-32666-1-git-send-email-dborkman@redhat.com>
Cc: fw@strlen.de, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbbAHXNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 18:13:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds configuration and dumping of congestion control metric
for ip route, for example:

  ip route add <dst> dev foo congctl [lock] dctcp

Reference: http://thread.gmane.org/gmane.linux.network/344733
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v2->v3:
  - use rta_getattr_u32 et al helpers
  - regarding discussed mx(un)lock, I'll do a follow-up for
    all users inside iproute_modify() if that is wished
 v1->v2:
  - adapted mxlock setting to kernel style
  - use arg directly in rta_addattr_l

 include/linux/rtnetlink.h |  2 ++
 ip/iproute.c              | 22 ++++++++++++++++++----
 man/man8/ip-route.8.in    | 19 ++++++++++++++++++-
 3 files changed, 38 insertions(+), 5 deletions(-)

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
index 5a496a9..76d8e36 100644
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
@@ -536,7 +536,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			mxlock = *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
 
 		for (i=2; i<= RTAX_MAX; i++) {
-			unsigned val;
+			__u32 val;
 
 			if (mxrta[i] == NULL)
 				continue;
@@ -545,10 +545,12 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, " %s", mx_names[i]);
 			else
 				fprintf(fp, " metric %d", i);
+
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
+			if (i != RTAX_CC_ALGO)
+				val = rta_getattr_u32(mxrta[i]);
 
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
+				fprintf(fp, " %s", rta_getattr_str(mxrta[i]));
+				break;
 			}
 		}
 	}
@@ -925,6 +931,14 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (quickack != 1 && quickack != 0)
 				invarg("\"quickack\" value should be 0 or 1\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_QUICKACK, quickack);
+		} else if (matches(*argv, "congctl") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "lock") == 0) {
+				mxlock |= 1 << RTAX_CC_ALGO;
+				NEXT_ARG();
+			}
+			rta_addattr_l(mxrta, sizeof(mxbuf), RTAX_CC_ALGO, *argv,
+				      strlen(*argv));
 		} else if (matches(*argv, "rttvar") == 0) {
 			unsigned win;
 			NEXT_ARG();
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 89960c1..2b1583d 100644
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
