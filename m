From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iproute 2/2] ss: show socket memory stats for unix sockets if requested
Date: Sat, 23 Feb 2013 02:28:18 +0100
Message-ID: <20130223012818.GA6655@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51776 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757967Ab3BWB2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:28:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The output format is the same as for tcp sockets but only the following
fields are currently non-zero: sk_rcvbuf, sk_wmem_alloc and sk_sndbuf.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 misc/ss.c | 47 +++++++++++++++++++++++++++++++----------------
 1 file changed, 31 insertions(+), 16 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0de700a..e742aad 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1327,6 +1327,29 @@ static char *sprint_bw(char *buf, double bw)
 	return buf;
 }
 
+static void print_skmeminfo(struct rtattr *tb[], int attrtype)
+{
+	const __u32 *skmeminfo;
+	if (!tb[attrtype])
+		return;
+	skmeminfo = RTA_DATA(tb[attrtype]);
+
+	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
+	       skmeminfo[SK_MEMINFO_RMEM_ALLOC],
+	       skmeminfo[SK_MEMINFO_RCVBUF],
+	       skmeminfo[SK_MEMINFO_WMEM_ALLOC],
+	       skmeminfo[SK_MEMINFO_SNDBUF],
+	       skmeminfo[SK_MEMINFO_FWD_ALLOC],
+	       skmeminfo[SK_MEMINFO_WMEM_QUEUED],
+	       skmeminfo[SK_MEMINFO_OPTMEM]);
+
+	if (RTA_PAYLOAD(tb[attrtype]) >=
+		(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
+		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
+
+	printf(")");
+}
+
 static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 {
 	struct rtattr * tb[INET_DIAG_MAX+1];
@@ -1337,22 +1360,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[INET_DIAG_SKMEMINFO]) {
-		const __u32 *skmeminfo = RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
-
-		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
-			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
-			skmeminfo[SK_MEMINFO_RCVBUF],
-			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
-			skmeminfo[SK_MEMINFO_SNDBUF],
-			skmeminfo[SK_MEMINFO_FWD_ALLOC],
-			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
-			skmeminfo[SK_MEMINFO_OPTMEM]);
-
-		if (RTA_PAYLOAD(tb[INET_DIAG_SKMEMINFO]) >=
-			(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
-			printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
-
-		printf(")");
+		print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 	} else if (tb[INET_DIAG_MEMINFO]) {
 		const struct inet_diag_meminfo *minfo
 			= RTA_DATA(tb[INET_DIAG_MEMINFO]);
@@ -2188,6 +2196,11 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 			printf(" users:(%s)", ubuf);
 	}
 
+	if (show_mem) {
+		printf("\n\t");
+		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
+	}
+
 	printf("\n");
 
 	return 0;
@@ -2214,6 +2227,8 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 	req.r.sdiag_family = AF_UNIX;
 	req.r.udiag_states = f->states;
 	req.r.udiag_show = UDIAG_SHOW_NAME | UDIAG_SHOW_PEER | UDIAG_SHOW_RQLEN;
+	if (show_mem)
+		req.r.udiag_show |= UDIAG_SHOW_MEMINFO;
 
 	if (send(fd, &req, sizeof(req), 0) < 0) {
 		close(fd);
-- 
1.8.1.2
