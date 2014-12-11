From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip lib: Added shorter timestamp option
Date: Thu, 11 Dec 2014 10:12:06 +0200
Message-ID: <1418285526-28859-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:37664 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311AbaLKIV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 03:21:58 -0500
Received: by mail-lb0-f174.google.com with SMTP id 10so3781594lbg.33
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 00:21:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added another timestamp format to look like more logging info:

[Dec 01 01:46:20.675589] 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
    link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/utils.h       |  1 +
 ip/ip.c               |  5 ++++-
 lib/utils.c           | 15 ++++++++++++---
 man/man8/ip-monitor.8 | 13 +++++++++++++
 4 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index eef9c42..eecbc39 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -19,6 +19,7 @@ extern int show_raw;
 extern int resolve_hosts;
 extern int oneline;
 extern int timestamp;
+extern int timestamp_short;
 extern char * _SL_;
 extern int max_flush_loops;
 extern int batch_mode;
diff --git a/ip/ip.c b/ip/ip.c
index 5f759d5..9b90707 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -53,7 +53,7 @@ static void usage(void)
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
-"                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
+"                    -o[neline] | -t[imestamp] | -t[short] | -b[atch] [filename] |\n"
 "                    -rc[vbuf] [size]}\n");
 	exit(-1);
 }
@@ -232,6 +232,9 @@ int main(int argc, char **argv)
 			++oneline;
 		} else if (matches(opt, "-timestamp") == 0) {
 			++timestamp;
+		} else if (matches(opt, "-tshort") == 0) {
+			++timestamp;
+			++timestamp_short;
 #if 0
 		} else if (matches(opt, "-numeric") == 0) {
 			rtnl_names_numeric++;
diff --git a/lib/utils.c b/lib/utils.c
index 987377b..3102920 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -32,6 +32,8 @@
 
 #include "utils.h"
 
+int timestamp_short = 0;
+
 int get_integer(int *val, const char *arg, int base)
 {
 	long res;
@@ -773,13 +775,20 @@ int print_timestamp(FILE *fp)
 {
 	struct timeval tv;
 	char *tstr;
+	char tshort[40] = {};
 
 	memset(&tv, 0, sizeof(tv));
 	gettimeofday(&tv, NULL);
 
-	tstr = asctime(localtime(&tv.tv_sec));
-	tstr[strlen(tstr)-1] = 0;
-	fprintf(fp, "Timestamp: %s %ld usec\n", tstr, (long)tv.tv_usec);
+	if (timestamp_short) {
+		strftime(tshort, sizeof(tshort), "%b %d %H:%M:%S", localtime(&tv.tv_sec));
+		fprintf(fp, "[%s.%-6ld] ", tshort, (long)tv.tv_usec);
+	} else {
+		tstr = asctime(localtime(&tv.tv_sec));
+		tstr[strlen(tstr)-1] = 0;
+		fprintf(fp, "Timestamp: %s %ld usec\n", tstr, (long)tv.tv_usec);
+	}
+
 	return 0;
 }
 
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 68e83f1..c131ae7 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -16,6 +16,19 @@ ip-monitor, rtmon \- state monitoring
 ]
 .sp
 
+.SH OPTIONS
+
+.TP
+.BR "\-t" , " \-timestamp"
+Prints timestamp before the event message on the separated line in format:
+    Timestamp: <Day> <Month> <day> <HH:MM:SS> <YYYY> <usecs> usec
+    EVENT
+
+.TP
+.BR "\-ts" , " \-tshort"
+Prints short timestamp before the event message on the same line in format:
+    [<Month> <day> <HH:MM:SS>.usecs ] EVENT
+
 .SH DESCRIPTION
 The
 .B ip
-- 
2.1.3
