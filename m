From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 4/7] [IP] XFRM: sub policy support.
Date: Tue,  5 Dec 2006 19:15:38 +0900
Message-ID: <11653137383219-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38927 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S967930AbWLEKQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:16:08 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipxfrm.c      |   27 ++++++++++
 ip/xfrm.h        |    4 +
 ip/xfrm_policy.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 164 insertions(+), 17 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 4bcd2f3..79fc133 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -709,6 +709,7 @@ void xfrm_policy_info_print(struct xfrm_
 			    const char *title)
 {
 	char buf[STRBUF_SIZE];
+	__u8 ptype = XFRM_POLICY_TYPE_MAIN;
 
 	memset(buf, '\0', sizeof(buf));
 
@@ -752,6 +753,32 @@ void xfrm_policy_info_print(struct xfrm_
 	if (show_stats)
 		fprintf(fp, "index %u ", xpinfo->index);
 	fprintf(fp, "priority %u ", xpinfo->priority);
+
+	fprintf(fp, "ptype ");
+
+	if (tb[XFRMA_POLICY_TYPE]) {
+		struct xfrm_userpolicy_type *upt;
+
+		if (RTA_PAYLOAD(tb[XFRMA_POLICY_TYPE]) < sizeof(*upt))
+			fprintf(fp, "(ERROR truncated)");
+
+		upt = (struct xfrm_userpolicy_type *)RTA_DATA(tb[XFRMA_POLICY_TYPE]);
+		ptype = upt->type;
+	}
+
+	switch (ptype) {
+	case XFRM_POLICY_TYPE_MAIN:
+		fprintf(fp, "main");
+		break;
+	case XFRM_POLICY_TYPE_SUB:
+		fprintf(fp, "sub");
+		break;
+	default:
+		fprintf(fp, "%u", ptype);
+		break;
+	}
+	fprintf(fp, " ");
+
 	if (show_stats > 0) {
 		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
 		fprintf(fp, "flag 0x%s", strxf_mask8(xpinfo->flags));
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 4833b36..7a53e59 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -92,6 +92,10 @@ struct xfrm_filter {
 	__u32 index_mask;
 	__u8 action_mask;
 	__u32 priority_mask;
+
+	__u8 ptype;
+	__u8 ptype_mask;
+
 };
 #define XFRM_FILTER_MASK_FULL (~0)
 
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index abca713..6be7bfd 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -53,12 +53,14 @@ static void usage(void) __attribute__((n
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] \n");
+	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] [ ptype PTYPE ]\n");
 	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy flush\n");
+	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
+
+	fprintf(stderr, "PTYPE := [ main | sub ](default=main)\n");
 	fprintf(stderr, "DIR := [ in | out | fwd ]\n");
 
 	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
@@ -114,6 +116,24 @@ static int xfrm_policy_dir_parse(__u8 *d
 	return 0;
 }
 
+static int xfrm_policy_ptype_parse(__u8 *ptype, int *argcp, char ***argvp)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	if (strcmp(*argv, "main") == 0)
+		*ptype = XFRM_POLICY_TYPE_MAIN;
+	else if (strcmp(*argv, "sub") == 0)
+		*ptype = XFRM_POLICY_TYPE_SUB;
+	else
+		invarg("\"PTYPE\" is invalid", *argv);
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
 static int xfrm_tmpl_parse(struct xfrm_user_tmpl *tmpl,
 			   int *argcp, char ***argvp)
 {
@@ -174,10 +194,13 @@ static int xfrm_policy_modify(int cmd, u
 	} req;
 	char *dirp = NULL;
 	char *selp = NULL;
+	char *ptypep = NULL;
+	struct xfrm_userpolicy_type upt;
 	char tmpls_buf[XFRM_TMPLS_BUF_SIZE];
 	int tmpls_len = 0;
 
 	memset(&req, 0, sizeof(req));
+	memset(&upt, 0, sizeof(upt));
 	memset(&tmpls_buf, 0, sizeof(tmpls_buf));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpinfo));
@@ -208,6 +231,16 @@ static int xfrm_policy_modify(int cmd, u
 
 			filter.index_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "ptype") == 0) {
+			if (ptypep)
+				duparg("ptype", *argv);
+			ptypep = *argv;
+
+			NEXT_ARG();
+			xfrm_policy_ptype_parse(&upt.type, &argc, &argv);
+
+			filter.dir_mask = XFRM_FILTER_MASK_FULL;
+
 		} else if (strcmp(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "allow") == 0)
@@ -265,6 +298,11 @@ static int xfrm_policy_modify(int cmd, u
 		exit(1);
 	}
 
+	if (ptypep) {
+		addattr_l(&req.n, sizeof(req), XFRMA_POLICY_TYPE,
+			  (void *)&upt, sizeof(upt));
+	}
+
 	if (tmpls_len > 0) {
 		addattr_l(&req.n, sizeof(req), XFRMA_TMPL,
 			  (void *)tmpls_buf, tmpls_len);
@@ -284,7 +322,8 @@ static int xfrm_policy_modify(int cmd, u
 	return 0;
 }
 
-static int xfrm_policy_filter_match(struct xfrm_userpolicy_info *xpinfo)
+static int xfrm_policy_filter_match(struct xfrm_userpolicy_info *xpinfo,
+				    __u8 ptype)
 {
 	if (!filter.use)
 		return 1;
@@ -292,6 +331,9 @@ static int xfrm_policy_filter_match(stru
 	if ((xpinfo->dir^filter.xpinfo.dir)&filter.dir_mask)
 		return 0;
 
+	if ((ptype^filter.ptype)&filter.ptype_mask)
+		return 0;
+
 	if (filter.sel_src_mask) {
 		if (xfrm_addr_match(&xpinfo->sel.saddr, &filter.xpinfo.sel.saddr,
 				    filter.sel_src_mask))
@@ -340,6 +382,7 @@ int xfrm_policy_print(const struct socka
 	struct xfrm_userpolicy_info *xpinfo = NULL;
 	struct xfrm_user_polexpire *xpexp = NULL;
 	struct xfrm_userpolicy_id *xpid = NULL;
+	__u8 ptype = XFRM_POLICY_TYPE_MAIN;
 	FILE *fp = (FILE*)arg;
 	int len = n->nlmsg_len;
 
@@ -370,16 +413,6 @@ int xfrm_policy_print(const struct socka
 		return -1;
 	}
 
-	if (xpinfo && !xfrm_policy_filter_match(xpinfo))
-		return 0;
-
-	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
-		fprintf(fp, "Deleted ");
-	else if (n->nlmsg_type == XFRM_MSG_UPDPOLICY)
-		fprintf(fp, "Updated ");
-	else if (n->nlmsg_type == XFRM_MSG_POLEXPIRE)
-		fprintf(fp, "Expired ");
-
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
 		rta = XFRMPID_RTA(xpid);
 	else if (n->nlmsg_type == XFRM_MSG_POLEXPIRE)
@@ -389,6 +422,27 @@ int xfrm_policy_print(const struct socka
 
 	parse_rtattr(tb, XFRMA_MAX, rta, len);
 
+	if (tb[XFRMA_POLICY_TYPE]) {
+		struct xfrm_userpolicy_type *upt;
+
+		if (RTA_PAYLOAD(tb[XFRMA_POLICY_TYPE]) < sizeof(*upt)) {
+			fprintf(stderr, "too short XFRMA_POLICY_TYPE len\n");
+			return -1;
+		}
+		upt = (struct xfrm_userpolicy_type *)RTA_DATA(tb[XFRMA_POLICY_TYPE]);
+		ptype = upt->type;
+	}
+
+	if (xpinfo && !xfrm_policy_filter_match(xpinfo, ptype))
+		return 0;
+
+	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
+		fprintf(fp, "Deleted ");
+	else if (n->nlmsg_type == XFRM_MSG_UPDPOLICY)
+		fprintf(fp, "Updated ");
+	else if (n->nlmsg_type == XFRM_MSG_POLEXPIRE)
+		fprintf(fp, "Expired ");
+
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY) {
 		//xfrm_policy_id_print();
 		if (!tb[XFRMA_POLICY]) {
@@ -424,12 +478,16 @@ static int xfrm_policy_get_or_delete(int
 	struct {
 		struct nlmsghdr			n;
 		struct xfrm_userpolicy_id	xpid;
+		char				buf[RTA_BUF_SIZE];
 	} req;
 	char *dirp = NULL;
 	char *selp = NULL;
 	char *indexp = NULL;
+	char *ptypep = NULL;
+	struct xfrm_userpolicy_type upt;
 
 	memset(&req, 0, sizeof(req));
+	memset(&upt, 0, sizeof(upt));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpid));
 	req.n.nlmsg_flags = NLM_F_REQUEST;
@@ -453,6 +511,14 @@ static int xfrm_policy_get_or_delete(int
 			if (get_u32(&req.xpid.index, *argv, 0))
 				invarg("\"INDEX\" is invalid", *argv);
 
+		} else if (strcmp(*argv, "ptype") == 0) {
+			if (ptypep)
+				duparg("ptype", *argv);
+			ptypep = *argv;
+
+			NEXT_ARG();
+			xfrm_policy_ptype_parse(&upt.type, &argc, &argv);
+
 		} else {
 			if (selp)
 				invarg("unknown", *argv);
@@ -471,6 +537,10 @@ static int xfrm_policy_get_or_delete(int
 		fprintf(stderr, "Not enough information: \"DIR\" is required.\n");
 		exit(1);
 	}
+	if (ptypep) {
+		addattr_l(&req.n, sizeof(req), XFRMA_POLICY_TYPE,
+			  (void *)&upt, sizeof(upt));
+	}
 	if (!selp && !indexp) {
 		fprintf(stderr, "Not enough information: either \"SELECTOR\" or \"INDEX\" is required.\n");
 		exit(1);
@@ -526,6 +596,8 @@ static int xfrm_policy_keep(const struct
 	struct rtnl_handle *rth = xb->rth;
 	struct xfrm_userpolicy_info *xpinfo = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
+	struct rtattr *tb[XFRMA_MAX+1];
+	__u8 ptype = XFRM_POLICY_TYPE_MAIN;
 	struct nlmsghdr *new_n;
 	struct xfrm_userpolicy_id *xpid;
 
@@ -541,7 +613,20 @@ static int xfrm_policy_keep(const struct
 		return -1;
 	}
 
-	if (!xfrm_policy_filter_match(xpinfo))
+	parse_rtattr(tb, XFRMA_MAX, XFRMP_RTA(xpinfo), len);
+
+	if (tb[XFRMA_POLICY_TYPE]) {
+		struct xfrm_userpolicy_type *upt;
+
+		if (RTA_PAYLOAD(tb[XFRMA_POLICY_TYPE]) < sizeof(*upt)) {
+			fprintf(stderr, "too short XFRMA_POLICY_TYPE len\n");
+			return -1;
+		}
+		upt = (struct xfrm_userpolicy_type *)RTA_DATA(tb[XFRMA_POLICY_TYPE]);
+		ptype = upt->type;
+	}
+
+	if (!xfrm_policy_filter_match(xpinfo, ptype))
 		return 0;
 
 	if (xb->offset > xb->size) {
@@ -589,6 +674,12 @@ static int xfrm_policy_list_or_deleteall
 
 			filter.index_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "ptype") == 0) {
+			NEXT_ARG();
+			xfrm_policy_ptype_parse(&filter.ptype, &argc, &argv);
+
+			filter.ptype_mask = XFRM_FILTER_MASK_FULL;
+
 		} else if (strcmp(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "allow") == 0)
@@ -682,19 +773,44 @@ static int xfrm_policy_list_or_deleteall
 	exit(0);
 }
 
-static int xfrm_policy_flush(void)
+static int xfrm_policy_flush(int argc, char **argv)
 {
 	struct rtnl_handle rth;
 	struct {
 		struct nlmsghdr	n;
+		char		buf[RTA_BUF_SIZE];
 	} req;
+	char *ptypep = NULL;
+	struct xfrm_userpolicy_type upt;
 
 	memset(&req, 0, sizeof(req));
+	memset(&upt, 0, sizeof(upt));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(0); /* nlmsg data is nothing */
 	req.n.nlmsg_flags = NLM_F_REQUEST;
 	req.n.nlmsg_type = XFRM_MSG_FLUSHPOLICY;
 
+	while (argc > 0) {
+		if (strcmp(*argv, "ptype") == 0) {
+			if (ptypep)
+				duparg("ptype", *argv);
+			ptypep = *argv;
+
+			NEXT_ARG();
+			xfrm_policy_ptype_parse(&upt.type, &argc, &argv);
+
+			filter.dir_mask = XFRM_FILTER_MASK_FULL;
+		} else
+			invarg("unknown", *argv);
+
+		argc--; argv++;
+	}
+
+	if (ptypep) {
+		addattr_l(&req.n, sizeof(req), XFRMA_POLICY_TYPE,
+			  (void *)&upt, sizeof(upt));
+	}
+
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
@@ -730,7 +846,7 @@ int do_xfrm_policy(int argc, char **argv
 	if (matches(*argv, "get") == 0)
 		return xfrm_policy_get(argc-1, argv+1);
 	if (matches(*argv, "flush") == 0)
-		return xfrm_policy_flush();
+		return xfrm_policy_flush(argc-1, argv+1);
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm policy help\".\n", *argv);
-- 
1.4.2

