From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 iproute2] ss: Add option to suppress header line
Date: Fri, 15 Jul 2016 15:45:39 -0700
Message-ID: <1468622739-26410-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33490 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGOWpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:45:45 -0400
Received: by mail-pa0-f45.google.com with SMTP id ks6so43051470pab.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:45:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to suppress header line. When used the following line
is not shown:
"State  Recv-Q Send-Q     Local Address:Port  Peer Address:Port"

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- rebased to master branch

 man/man8/ss.8 |  3 +++
 misc/ss.c     | 28 +++++++++++++++++++---------
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 758460c27c95..8911976faa35 100644
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
index abece96c0946..38205b0e8c28 100644
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
@@ -3669,6 +3670,7 @@ static void _usage(FILE *dest)
 "       FAMILY := {inet|inet6|link|unix|netlink|help}\n"
 "\n"
 "   -K, --kill          forcibly close sockets, display what was closed\n"
+"   -H, --no-header     Suppress header line\n"
 "\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
@@ -3762,6 +3764,7 @@ static const struct option long_opts[] = {
 	{ "contexts", 0, 0, 'z' },
 	{ "net", 1, 0, 'N' },
 	{ "kill", 0, 0, 'K' },
+	{ "no-header", 0, 0, 'H' },
 	{ 0 }
 
 };
@@ -3776,7 +3779,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:K",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KH",
 				 long_opts, NULL)) != EOF) {
 		switch (ch) {
 		case 'n':
@@ -3961,6 +3964,9 @@ int main(int argc, char *argv[])
 		case 'K':
 			current_filter.kill = 1;
 			break;
+		case 'H':
+			show_header = 0;
+			break;
 		case 'h':
 			help();
 		case '?':
@@ -4086,19 +4092,23 @@ int main(int argc, char *argv[])
 
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
