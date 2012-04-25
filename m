From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 2/2] ss: implement -M option to get all memory information
Date: Wed, 25 Apr 2012 15:15:27 +0800
Message-ID: <4F97A48F.4010109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>, xemul@parallels.com,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51562 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab2DYHOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 03:14:40 -0400
Received: by pbbro12 with SMTP id ro12so1092350pbb.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 00:14:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

INET_DIAG_SKMEMINFO is used to monitor socket memory information
which contains more information than INET_DIAG_MEMINFO.

-m option is retained for old kernel that don't surpport INET_DIAG_SKMEMINFO.


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 misc/ss.c |   27 +++++++++++++++++++++++++--
 1 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 5f70a26..3c8befd 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -45,6 +45,7 @@ int show_options = 0;
 int show_details = 0;
 int show_users = 0;
 int show_mem = 0;
+int show_skmem = 0;
 int show_tcpinfo = 0;
 
 int netid_width;
@@ -1410,6 +1411,19 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 			printf(" rcv_space:%d", info->tcpi_rcv_space);
 
 	}
+
+	if (tb[INET_DIAG_SKMEMINFO]) {
+		const unsigned int *skmeminfo =  RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
+		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u)",
+			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
+			skmeminfo[SK_MEMINFO_RCVBUF],
+			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
+			skmeminfo[SK_MEMINFO_SNDBUF],
+			skmeminfo[SK_MEMINFO_FWD_ALLOC],
+			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
+			skmeminfo[SK_MEMINFO_OPTMEM]);
+	}
+
 }
 
 static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
@@ -1466,7 +1480,7 @@ static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
 			printf("%08x", r->id.idiag_cookie[1]);
  		printf("%08x", r->id.idiag_cookie[0]);
 	}
-	if (show_mem || show_tcpinfo) {
+	if (show_mem || show_tcpinfo || show_skmem) {
 		printf("\n\t");
 		tcp_show_info(nlh, r);
 	}
@@ -1508,6 +1522,9 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 	if (show_mem)
 		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
 
+	if (show_skmem)
+		req.r.idiag_ext |= (1<<(INET_DIAG_SKMEMINFO-1));
+
 	if (show_tcpinfo) {
 		req.r.idiag_ext |= (1<<(INET_DIAG_INFO-1));
 		req.r.idiag_ext |= (1<<(INET_DIAG_VEGASINFO-1));
@@ -2581,6 +2598,8 @@ static void _usage(FILE *dest)
 "   -o, --options       show timer information\n"
 "   -e, --extended      show detailed socket information\n"
 "   -m, --memory        show socket memory usage\n"
+"   -M, --skmem         show socket memory information.\n"
+"                       this option which will replace -m, is valid since Linux 3.3.\n"
 "   -p, --processes	show process using socket\n"
 "   -i, --info		show internal TCP information\n"
 "   -s, --summary	show socket usage summary\n"
@@ -2652,6 +2671,7 @@ static const struct option long_opts[] = {
 	{ "options", 0, 0, 'o' },
 	{ "extended", 0, 0, 'e' },
 	{ "memory", 0, 0, 'm' },
+	{ "skmem", 0, 0, 'M'}
 	{ "info", 0, 0, 'i' },
 	{ "processes", 0, 0, 'p' },
 	{ "dccp", 0, 0, 'd' },
@@ -2690,7 +2710,7 @@ int main(int argc, char *argv[])
 
 	current_filter.states = default_filter.states;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spf:miA:D:F:vV",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spf:mMiA:D:F:vV",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -2709,6 +2729,9 @@ int main(int argc, char *argv[])
 		case 'm':
 			show_mem = 1;
 			break;
+		case 'M':
+			show_skmem = 1;
+			break;
 		case 'i':
 			show_tcpinfo = 1;
 			break;
-- 
1.7.1
