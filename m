From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2 -next] ip: route: add congestion control setting
Date: Fri,  5 Dec 2014 16:28:18 +0100
Message-ID: <1417793298-6439-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbaLEP27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 10:28:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds configuration and dumping of congestion control metric
for ip route, f.e.:  ip route add <dst> dev <dev> congctl [lock] <name>

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Stephen, this patch is already rebased on top of Florian's
 ECN patch [1]. Thanks!

   [1] http://patchwork.ozlabs.org/patch/407729/

 include/linux/rtnetlink.h |  2 ++
 ip/iproute.c              | 24 +++++++++++++++++++++---
 man/man8/ip-route.8.in    | 25 ++++++++++++++++++++++++-
 3 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ae23d94..0c68a1a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -390,6 +390,8 @@ enum {
 #define RTAX_INITRWND RTAX_INITRWND
 	RTAX_QUICKACK,
 #define RTAX_QUICKACK RTAX_QUICKACK
+	RTAX_CC_ALGO,
+#define RTAX_CC_ALGO RTAX_CC_ALGO
 	__RTAX_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 5a496a9..18f7de7 100644
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
+				invarg("\"conctl\" value must be a algorithm name\n", *argv);
+			rta_addattr_l(mxrta, sizeof(mxbuf), RTAX_CC_ALGO, cc, strlen(cc));
 		} else if (matches(*argv, "rttvar") == 0) {
 			unsigned win;
 			NEXT_ARG();
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 89960c1..6e4b94c 100644
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
@@ -433,6 +435,27 @@ sysctl is set to 0.
 Enable or disable quick ack for connections to this destination.
 
 .TP
+.BI congctl " NAME " "(3.19+ only)"
+.TP
+.BI "congctl lock" " NAME " "(3.19+ only)"
+Sets a specific TCP congestion control algorithm only for a given destination.
+If not specified, Linux keeps the current global default TCP congestion control
+algorithm, or the one set from the application. If the modifier
+.B lock
+is not used, an application may nevertheless overwrite the suggested congestion
+control algorithm for that destination. If the modifier
+.B lock
+is used, then an application is not allowed to overwrite the specified congestion
+control algorithm for that destination, thus it will be enforced/guaranteed to
+use the proposed algorithm. Should a congestion control module be unloaded, the
+specified congestion control algorithm will fall back to the current global
+default on connection establishment. In case the same congestion control module
+will be reloaded at a later point in time into the kernel and the congctl route
+attribute has not been modified until then, new connections for that destination
+will make use of it again. Note that the kernel will not try to autoload non-present
+congestion control modules.
+
+.TP
 .BI advmss " NUMBER " "(2.3.15+ only)"
 the MSS ('Maximal Segment Size') to advertise to these
 destinations when establishing TCP connections.  If it is not given,
-- 
1.9.3
