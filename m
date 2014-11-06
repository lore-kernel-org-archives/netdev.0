From: Florian Westphal <fw@strlen.de>
Subject: [PATCH iproute2 next] ip route: enable per-route ecn settings via 'features' option
Date: Thu,  6 Nov 2014 22:15:32 +0100
Message-ID: <1415308532-4785-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54525 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbaKFVPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:15:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This permits to selectively enable explicit congestion notification via
the routing table.

If this ecn feature is not set, the kernel will use the tcp_ecn sysctl
to decide wheter to use ECN when establising a TCP connection.

At the time of this writing, the kernel supports ecn and allfrags, but
allfrags is of dubious value and not implemented here.

Example:

ip route change 192.168.2.0/24 dev eth0 features ecn

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 ip/iproute.c           | 32 ++++++++++++++++++++++++++++++++
 man/man8/ip-route.8.in | 18 ++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index d77b1e3..ad1cbab 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -80,6 +80,7 @@ static void usage(void)
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
+	fprintf(stderr, "           [ features FEATURES ]\n");
 	fprintf(stderr, "           [ quickack BOOL ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
@@ -89,6 +90,7 @@ static void usage(void)
 	fprintf(stderr, "RTPROTO := [ kernel | boot | static | NUMBER ]\n");
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
 	fprintf(stderr, "BOOL := [1|0]\n");
+	fprintf(stderr, "FEATURES := ecn\n");
 	exit(-1);
 }
 
@@ -280,6 +282,19 @@ static int calc_host_len(const struct rtmsg *r)
 		return -1;
 }
 
+static void print_rtax_features(FILE *fp, unsigned int features)
+{
+	unsigned int of = features;
+
+	if (features & RTAX_FEATURE_ECN) {
+		fprintf(fp, " ecn");
+		features &= ~RTAX_FEATURE_ECN;
+	}
+
+	if (features)
+		fprintf(fp, " 0x%x", of);
+}
+
 int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
@@ -535,6 +550,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 			val = *(unsigned*)RTA_DATA(mxrta[i]);
 			switch (i) {
+			case RTAX_FEATURES:
+				print_rtax_features(fp, val);
+				break;
 			case RTAX_HOPLIMIT:
 				if ((int)val == -1)
 					val = 0;
@@ -885,6 +903,20 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (get_unsigned(&win, *argv, 0))
 				invarg("\"initrwnd\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_INITRWND, win);
+		} else if (matches(*argv, "features") == 0) {
+			unsigned int features = 0;
+
+			while (argc > 0) {
+				NEXT_ARG();
+
+				if (strcmp(*argv, "ecn") == 0)
+					features |= RTAX_FEATURE_ECN;
+				else
+					invarg("\"features\" value not valid\n", *argv);
+				break;
+			}
+
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_FEATURES, features);
 		} else if (matches(*argv, "quickack") == 0) {
 			unsigned quickack;
 			NEXT_ARG();
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 79bc7f1..89960c1 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -113,6 +113,8 @@ replace " } "
 .IR NUMBER " ] [ "
 .B  initrwnd
 .IR NUMBER " ] [ "
+.B  features
+.IR FEATURES " ] [ "
 .B  quickack
 .IR BOOL " ]"
 
@@ -140,6 +142,10 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .BR kernel " | " boot " | " static " |"
 .IR NUMBER " ]"
 
+.ti -8
+.IR FEATURES " := [ "
+.BR ecn " | ]"
+
 
 .SH DESCRIPTION
 .B ip route
@@ -411,6 +417,18 @@ Actual window size is this value multiplied by the MSS of the connection.
 The default value is zero, meaning to use Slow Start value.
 
 .TP
+.BI features " FEATURES " (3.18+ only)
+Enable or disable per-route features.  Only available feature at this
+time is
+.B ecn
+to enable explicit congestion notification when initiating connections to the
+given destination network.
+When responding to a connection request from the given network, ecn will
+also be used even if the
+.B net.ipv4.tcp_ecn
+sysctl is set to 0.
+
+.TP
 .BI quickack " BOOL " "(3.11+ only)"
 Enable or disable quick ack for connections to this destination.
 
-- 
2.0.4
