From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ss: Add option to suppress header line
Date: Fri, 15 Jul 2016 10:20:45 -0700
Message-ID: <1468603245-4947-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36029 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcGORUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 13:20:54 -0400
Received: by mail-pa0-f54.google.com with SMTP id pp5so34375338pac.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 10:20:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to suppress header line. When used the following line
is not shown:
"State  Recv-Q Send-Q     Local Address:Port  Peer Address:Port"

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 man/man8/ss.8 |  3 +++
 misc/ss.c     | 28 +++++++++++++++++++---------
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index d0e4217613a0..99945ff699a9 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -21,6 +21,9 @@ Show summary of options.
 .B \-V, \-\-version
 Output version information.
 .TP
+.B \-H, \-\-no-header
+Suppress header line.
+.TP
 .B \-n, \-\-numeric
 Do not try to resolve service names.
 .TP
diff --git a/misc/ss.c b/misc/ss.c
index 586275472a90..14f2774528ec 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -97,6 +97,7 @@ int show_tcpinfo;
 int show_bpf;
 int show_proc_ctx;
 int show_sock_ctx;
+int show_header = 1;
 /* If show_users & show_proc_ctx only do user_ent_hash_build() once */
 int user_ent_hash_build_init;
 int follow_events;
@@ -3637,6 +3638,7 @@ static void _usage(FILE *dest)
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
 "   -K, --kill          forcibly close sockets, display what was closed\n"
+"   -H, --no-header     Suppress header line\n"
 "\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
@@ -3730,6 +3732,7 @@ static const struct option long_opts[] = {
 	{ "contexts", 0, 0, 'z' },
 	{ "net", 1, 0, 'N' },
 	{ "kill", 0, 0, 'K' },
+	{ "no-header", 0, 0, 'H' },
 	{ 0 }
 
 };
@@ -3744,7 +3747,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:K",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KH",
 				 long_opts, NULL)) != EOF) {
 		switch (ch) {
 		case 'n':
@@ -3929,6 +3932,9 @@ int main(int argc, char *argv[])
 		case 'K':
 			current_filter.kill = 1;
 			break;
+		case 'H':
+			show_header = 0;
+			break;
 		case 'h':
 		case '?':
 			help();
@@ -4054,19 +4060,23 @@ int main(int argc, char *argv[])
 
 	addr_width = addrp_width - serv_width - 1;
 
-	if (netid_width)
-		printf("%-*s ", netid_width, "Netid");
-	if (state_width)
-		printf("%-*s ", state_width, "State");
-	printf("%-6s %-6s ", "Recv-Q", "Send-Q");
+	if (show_header) {
+		if (netid_width)
+			printf("%-*s ", netid_width, "Netid");
+		if (state_width)
+			printf("%-*s ", state_width, "State");
+		printf("%-6s %-6s ", "Recv-Q", "Send-Q");
+	}
 
 	/* Make enough space for the local/remote port field */
 	addr_width -= 13;
 	serv_width += 13;
 
-	printf("%*s:%-*s %*s:%-*s\n",
-	       addr_width, "Local Address", serv_width, "Port",
-	       addr_width, "Peer Address", serv_width, "Port");
+	if (show_header) {
+		printf("%*s:%-*s %*s:%-*s\n",
+		       addr_width, "Local Address", serv_width, "Port",
+		       addr_width, "Peer Address", serv_width, "Port");
+	}
 
 	fflush(stdout);
 
-- 
2.1.4
