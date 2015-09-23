From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc : add timestamps to tc monitor
Date: Wed, 23 Sep 2015 16:40:04 -0700
Message-ID: <1443051604.29850.144.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36192 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbbIWXkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:40:06 -0400
Received: by pacgz1 with SMTP id gz1so4169201pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:40:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Support -timestamp and -tshort options for tc monitor like ip monitor.


# tc -tshort monitor
[2015-09-23T16:39:11.260555] qdisc fq 8003: dev eth0 root refcnt 2 limit
10000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140
refill_delay 40.0ms 


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc.c         |    6 ++++++
 tc/tc_monitor.c |    5 ++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/tc/tc.c b/tc/tc.c
index 46ff3714a2e9..17078676f631 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -36,6 +36,7 @@ int show_details = 0;
 int show_raw = 0;
 int show_pretty = 0;
 int show_graph = 0;
+int timestamp;
 
 int batch_mode = 0;
 int resolve_hosts = 0;
@@ -311,6 +312,11 @@ int main(int argc, char **argv)
 				matches(argv[1], "-conf") == 0) {
 			NEXT_ARG();
 			conf_file = argv[1];
+		} else if (matches(argv[1], "-timestamp") == 0) {
+			timestamp++;
+		} else if (matches(argv[1], "-tshort") == 0) {
+			++timestamp;
+			++timestamp_short;
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"tc -help\".\n", argv[1]);
 			return -1;
diff --git a/tc/tc_monitor.c b/tc/tc_monitor.c
index cae3616145c8..097068e91e51 100644
--- a/tc/tc_monitor.c
+++ b/tc/tc_monitor.c
@@ -30,7 +30,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tc monitor\n");
+	fprintf(stderr, "Usage: tc [-timestamp [-tshort] monitor\n");
 	exit(-1);
 }
 
@@ -41,6 +41,9 @@ static int accept_tcmsg(const struct sockaddr_nl *who,
 {
 	FILE *fp = (FILE*)arg;
 
+	if (timestamp)
+		print_timestamp(fp);
+
 	if (n->nlmsg_type == RTM_NEWTFILTER || n->nlmsg_type == RTM_DELTFILTER) {
 		print_filter(who, n, arg);
 		return 0;
