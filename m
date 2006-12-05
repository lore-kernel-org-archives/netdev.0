From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 6/7] [IP] XFRM: support report message by monitor.
Date: Tue,  5 Dec 2006 19:16:05 +0900
Message-ID: <11653137651812-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38933 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S967930AbWLEKQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:16:34 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/xfrm.h         |    2 ++
 ip/xfrm_monitor.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/ip/xfrm.h b/ip/xfrm.h
index 51ffa4b..d33ff94 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -52,6 +52,8 @@ #define XFRMACQ_RTA(x)	((struct rtattr*)
 #define XFRMEXP_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_user_expire))))
 #define XFRMPEXP_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))))
 
+#define XFRMREP_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_user_report))))
+
 #define XFRM_FLAG_PRINT(fp, flags, f, s) \
 	do { \
 		if (flags & f) { \
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index baa4610..b4fda02 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -108,6 +108,48 @@ static int xfrm_acquire_print(const stru
 	return 0;
 }
 
+static int xfrm_report_print(const struct sockaddr_nl *who,
+			     struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct xfrm_user_report *xrep = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[XFRMA_MAX+1];
+	__u16 family;
+
+	if (n->nlmsg_type != XFRM_MSG_REPORT) {
+		fprintf(stderr, "Not a report: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
+	}
+
+	len -= NLMSG_LENGTH(sizeof(*xrep));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	family = xrep->sel.family;
+	if (family == AF_UNSPEC)
+		family = preferred_family;
+
+	fprintf(fp, "report ");
+
+	fprintf(fp, "proto %s ", strxf_xfrmproto(xrep->proto));
+	fprintf(fp, "%s", _SL_);
+
+	xfrm_selector_print(&xrep->sel, family, fp, "  sel ");
+
+	parse_rtattr(tb, XFRMA_MAX, XFRMREP_RTA(xrep), len);
+
+	xfrm_xfrma_print(tb, family, fp, "  ");
+
+	if (oneline)
+		fprintf(fp, "\n");
+
+	return 0;
+}
+
 static int xfrm_accept_msg(const struct sockaddr_nl *who,
 			   struct nlmsghdr *n, void *arg)
 {
@@ -144,6 +186,10 @@ static int xfrm_accept_msg(const struct 
 		fprintf(fp, "Flushed policy\n");
 		return 0;
 	}
+	if (n->nlmsg_type == XFRM_MSG_REPORT) {
+		xfrm_report_print(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: %08d 0x%08x 0x%08x\n",
@@ -162,6 +208,7 @@ int do_xfrm_monitor(int argc, char **arg
 	int lexpire=0;
 	int lpolicy=0;
 	int lsa=0;
+	int lreport=0;
 
 	rtnl_close(&rth);
 
@@ -181,6 +228,9 @@ int do_xfrm_monitor(int argc, char **arg
 		} else if (matches(*argv, "policy") == 0) {
 			lpolicy=1;
 			groups = 0;
+		} else if (matches(*argv, "report") == 0) {
+			lreport=1;
+			groups = 0;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -198,6 +248,8 @@ int do_xfrm_monitor(int argc, char **arg
 		groups |= XFRMGRP_SA;
 	if (lpolicy)
 		groups |= XFRMGRP_POLICY;
+	if (lreport)
+		groups |= XFRMGRP_REPORT;
 
 	if (file) {
 		FILE *fp;
-- 
1.4.2

