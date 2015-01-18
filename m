From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/3] ss: Make meminfo look little bit more readable
Date: Sun, 18 Jan 2015 22:43:33 +0200
Message-ID: <1421613815-6635-2-git-send-email-vadim4j@gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:57143 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbbARUyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 15:54:13 -0500
Received: by mail-we0-f173.google.com with SMTP id q58so28296807wes.4
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 12:54:10 -0800 (PST)
In-Reply-To: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/utils.h |  3 +++
 ip/ipaddress.c  | 31 ++--------------------
 lib/utils.c     | 40 +++++++++++++++++++++++++++-
 misc/ss.c       | 82 ++++++++++++++++++++++++++++++++++-----------------------
 4 files changed, 93 insertions(+), 63 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index e1fe7cf..6b0b76c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -5,6 +5,7 @@
 #include <asm/types.h>
 #include <resolv.h>
 #include <stdlib.h>
+#include <stdbool.h>
 
 #include "libnetlink.h"
 #include "ll_map.h"
@@ -162,4 +163,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
 
+char *sprint_num(char *str, uint64_t num, bool use_iec);
+
 #endif /* __UTILS_H__ */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d5e863d..5a2a956 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -362,41 +362,14 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 
 static void print_num(FILE *fp, unsigned width, uint64_t count)
 {
-	const char *prefix = "kMGTPE";
-	const unsigned int base = use_iec ? 1024 : 1000;
-	uint64_t powi = 1;
-	uint16_t powj = 1;
-	uint8_t precision = 2;
 	char buf[64];
 
-	if (!human_readable || count < base) {
+	if (!human_readable) {
 		fprintf(fp, "%-*"PRIu64" ", width, count);
 		return;
 	}
 
-	/* increase value by a factor of 1000/1024 and print
-	 * if result is something a human can read */
-	for(;;) {
-		powi *= base;
-		if (count / base < powi)
-			break;
-
-		if (!prefix[1])
-			break;
-		++prefix;
-	}
-
-	/* try to guess a good number of digits for precision */
-	for (; precision > 0; precision--) {
-		powj *= 10;
-		if (count / powi < powj)
-			break;
-	}
-
-	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
-		(double) count / powi, *prefix, use_iec ? "i" : "");
-
-	fprintf(fp, "%-*s ", width, buf);
+	fprintf(fp, "%-*s ", width, sprint_num(buf, count, use_iec));
 }
 
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
diff --git a/lib/utils.c b/lib/utils.c
index f65ceaa..21e2e78 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -28,7 +28,7 @@
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
-
+#include <inttypes.h>
 
 #include "utils.h"
 
@@ -878,3 +878,41 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n)
 	tstr[strlen(tstr)-1] = 0;
 	fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
 }
+
+char *sprint_num(char *str, uint64_t num, bool use_iec)
+{
+	const char *prefix = "kMGTPE";
+	const unsigned int base = use_iec ? 1024 : 1000;
+	uint64_t powi = 1;
+	uint16_t powj = 1;
+	uint8_t precision = 2;
+
+	if (num < base) {
+		sprintf(str, "%"PRIu64, num);
+		return str;
+	}
+
+	/* increase value by a factor of 1000/1024 and print
+	 * if result is something a human can read */
+	for(;;) {
+		powi *= base;
+		if (num / base < powi)
+			break;
+
+		if (!prefix[1])
+			break;
+		++prefix;
+	}
+
+	/* try to guess a good number of digits for precision */
+	for (; precision > 0; precision--) {
+		powj *= 10;
+		if (num / powi < powj)
+			break;
+	}
+
+	sprintf(str, "%.*f%c%s", precision,
+		(double) num / powi, *prefix, use_iec ? "i" : "");
+
+	return str;
+}
diff --git a/misc/ss.c b/misc/ss.c
index f434f57..c5995ab 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -26,6 +26,7 @@
 #include <fnmatch.h>
 #include <getopt.h>
 #include <stdbool.h>
+#include <inttypes.h>
 
 #include "utils.h"
 #include "rt_names.h"
@@ -96,6 +97,7 @@ int show_tcpinfo = 0;
 int show_bpf = 0;
 int show_proc_ctx = 0;
 int show_sock_ctx = 0;
+bool show_human = 0;
 /* If show_users & show_proc_ctx only do user_ent_hash_build() once */
 int user_ent_hash_build_init = 0;
 
@@ -1598,37 +1600,56 @@ outerr:
 	return ferror(fp) ? -1 : 0;
 }
 
-static char *sprint_bw(char *buf, double bw)
+static char *sprint_bandw(char *buf, double bw)
 {
-	if (bw > 1000000.)
-		sprintf(buf,"%.1fM", bw / 1000000.);
-	else if (bw > 1000.)
-		sprintf(buf,"%.1fK", bw / 1000.);
-	else
-		sprintf(buf, "%g", bw);
+	return sprint_num(buf, bw, false);
+}
 
-	return buf;
+static char *sprint_bytes(char *buf, uint64_t bytes)
+{
+	if (!show_human) {
+		sprintf(buf, "%"PRIu64, bytes);
+		return buf;
+	}
+
+	return sprint_num(buf, bytes, false);
 }
 
 static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 {
+	char buf[64];
 	const __u32 *skmeminfo;
-	if (!tb[attrtype])
+
+	if (!tb[attrtype]) {
+		if (attrtype == INET_DIAG_SKMEMINFO) {
+			if (!tb[INET_DIAG_MEMINFO])
+				return;
+
+			const struct inet_diag_meminfo *minfo =
+				RTA_DATA(tb[INET_DIAG_MEMINFO]);
+
+			printf(" mem:(rd=%s,", sprint_bytes(buf, minfo->idiag_rmem));
+			printf("wr=%s,", sprint_bytes(buf, minfo->idiag_tmem));
+			printf("fwd=%s,", sprint_bytes(buf, minfo->idiag_fmem));
+			printf("wr_queue=%s)", sprint_bytes(buf, minfo->idiag_wmem));
+		}
 		return;
+	}
+
 	skmeminfo = RTA_DATA(tb[attrtype]);
 
-	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
-	       skmeminfo[SK_MEMINFO_RMEM_ALLOC],
-	       skmeminfo[SK_MEMINFO_RCVBUF],
-	       skmeminfo[SK_MEMINFO_WMEM_ALLOC],
-	       skmeminfo[SK_MEMINFO_SNDBUF],
-	       skmeminfo[SK_MEMINFO_FWD_ALLOC],
-	       skmeminfo[SK_MEMINFO_WMEM_QUEUED],
-	       skmeminfo[SK_MEMINFO_OPTMEM]);
+	printf(" skmem:(");
+	printf("rd=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_RMEM_ALLOC]));
+	printf("rcv_buf=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_RCVBUF]));
+	printf("wr=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_WMEM_ALLOC]));
+	printf("snd_buf=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_SNDBUF]));
+	printf("fwd=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_FWD_ALLOC]));
+	printf("wr_queue=%s,", sprint_bytes(buf, skmeminfo[SK_MEMINFO_WMEM_QUEUED]));
+	printf("oth=%s", sprint_bytes(buf, skmeminfo[SK_MEMINFO_OPTMEM]));
 
 	if (RTA_PAYLOAD(tb[attrtype]) >=
 		(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
-		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
+		printf(",bklog=%s", sprint_bytes(buf, skmeminfo[SK_MEMINFO_BACKLOG]));
 
 	printf(")");
 }
@@ -1639,17 +1660,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	char b1[64];
 	double rtt = 0;
 
-	if (tb[INET_DIAG_SKMEMINFO]) {
-		print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
-	} else if (tb[INET_DIAG_MEMINFO]) {
-		const struct inet_diag_meminfo *minfo
-			= RTA_DATA(tb[INET_DIAG_MEMINFO]);
-		printf(" mem:(r%u,w%u,f%u,t%u)",
-		       minfo->idiag_rmem,
-		       minfo->idiag_wmem,
-		       minfo->idiag_fmem,
-		       minfo->idiag_tmem);
-	}
+	print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 
 	if (tb[INET_DIAG_INFO]) {
 		struct tcp_info *info;
@@ -1723,7 +1734,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 
 		if (rtt > 0 && info->tcpi_snd_mss && info->tcpi_snd_cwnd) {
 			printf(" send %sbps",
-			       sprint_bw(b1, (double) info->tcpi_snd_cwnd *
+			       sprint_bandw(b1, (double) info->tcpi_snd_cwnd *
 					 (double) info->tcpi_snd_mss * 8000000.
 					 / rtt));
 		}
@@ -1740,12 +1751,12 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		if (info->tcpi_pacing_rate &&
 		    info->tcpi_pacing_rate != ~0ULL) {
 			printf(" pacing_rate %sbps",
-				sprint_bw(b1, info->tcpi_pacing_rate * 8.));
+				sprint_bandw(b1, info->tcpi_pacing_rate * 8.));
 
 			if (info->tcpi_max_pacing_rate &&
 			    info->tcpi_max_pacing_rate != ~0ULL)
 				printf("/%sbps",
-					sprint_bw(b1, info->tcpi_max_pacing_rate * 8.));
+					sprint_bandw(b1, info->tcpi_max_pacing_rate * 8.));
 		}
 		if (info->tcpi_unacked)
 			printf(" unacked:%u", info->tcpi_unacked);
@@ -3207,6 +3218,7 @@ static void _usage(FILE *dest)
 "   -b, --bpf           show bpf filter socket information\n"
 "   -Z, --context       display process SELinux security contexts\n"
 "   -z, --contexts      display process and socket SELinux security contexts\n"
+"   -H, --human         display info in human readable format\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
@@ -3306,6 +3318,7 @@ static const struct option long_opts[] = {
 	{ "help", 0, 0, 'h' },
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
+	{ "human", 0, 0, 'H' },
 	{ 0 }
 
 };
@@ -3321,7 +3334,7 @@ int main(int argc, char *argv[])
 	struct filter dbs_filter = {};
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZ",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZH",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3493,6 +3506,9 @@ int main(int argc, char *argv[])
 			show_proc_ctx++;
 			user_ent_hash_build();
 			break;
+		case 'H':
+			show_human = true;
+			break;
 		case 'h':
 		case '?':
 			help();
-- 
2.1.3
