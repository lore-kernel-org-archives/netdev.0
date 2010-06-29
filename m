From: greearb@gmail.com
Subject: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than 10 times.
Date: Mon, 28 Jun 2010 22:55:59 -0700
Message-ID: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:38714 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab0F2F4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 01:56:07 -0400
Received: by pvg2 with SMTP id 2so2292455pvg.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 22:56:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The default remains at 10 for backwards compatibility.

For instance:
 # ip addr flush dev eth2
 *** Flush remains incomplete after 10 rounds. ***
 # ip -l 20 addr flush dev eth2
 *** Flush remains incomplete after 20 rounds. ***
 # ip -loops 0 addr flush dev eth2
 #

This is useful for getting rid of large numbers of IP
addresses in scripts.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 f7ef939... 3da6998... M	include/utils.h
:100644 100644 9f29533... b127d57... M	ip/ip.c
:100644 100644 3a411b1... 5f0789c... M	ip/ipaddress.c
:100644 100644 1a73efa... d0146a5... M	man/man8/ip.8
 include/utils.h |    1 +
 ip/ip.c         |   11 ++++++++++-
 ip/ipaddress.c  |    6 +++---
 man/man8/ip.8   |    6 ++++++
 4 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index f7ef939..3da6998 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -17,6 +17,7 @@ extern int resolve_hosts;
 extern int oneline;
 extern int timestamp;
 extern char * _SL_;
+extern int max_flush_loops;
 
 #ifndef IPPROTO_ESP
 #define IPPROTO_ESP	50
diff --git a/ip/ip.c b/ip/ip.c
index 9f29533..b127d57 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -32,6 +32,8 @@ int timestamp = 0;
 char * _SL_ = NULL;
 char *batch_file = NULL;
 int force = 0;
+int max_flush_loops = 10;
+
 struct rtnl_handle rth = { .fd = -1 };
 
 static void usage(void) __attribute__((noreturn));
@@ -45,6 +47,7 @@ static void usage(void)
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
+"                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
 "                    -rc[vbuf] [size]}\n");
 	exit(-1);
@@ -157,7 +160,13 @@ int main(int argc, char **argv)
 			break;
 		if (opt[1] == '-')
 			opt++;
-		if (matches(opt, "-family") == 0) {
+		if (matches(opt, "-loops") == 0) {
+			argc--;
+			argv++;
+			if (argc <= 1)
+				usage();
+                        max_flush_loops = atoi(argv[1]);
+                } else if (matches(opt, "-family") == 0) {
 			argc--;
 			argv++;
 			if (argc <= 1)
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3a411b1..5f0789c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -33,7 +33,6 @@
 #include "ll_map.h"
 #include "ip_common.h"
 
-#define MAX_ROUNDS 10
 
 static struct
 {
@@ -818,7 +817,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		while (round < MAX_ROUNDS) {
+		while ((max_flush_loops == 0) || (round < max_flush_loops)) {
 			const struct rtnl_dump_filter_arg a[3] = {
 				{
 					.filter = print_addrinfo_secondary,
@@ -867,7 +866,8 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
+		fflush(stderr);
 		return 1;
 	}
 
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1a73efa..d0146a5 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -730,6 +730,12 @@ appears twice or more, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
 .TP
+.BR "\-l" , " \-loops"
+Specify maximum number of loops the 'ip addr flush' logic
+will attempt before giving up.  The default is 10.
+Zero (0) means loop until all addresses are removed.
+
+.TP
 .BR "\-f" , " \-family"
 followed by protocol family identifier:
 .BR "inet" , " inet6"
-- 
1.7.0.1

