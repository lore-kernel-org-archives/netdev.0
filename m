From: Joy Latten <jml@austin.ibm.com>
Subject: [iproute2 PATCH 2/3]: xfrm security context support
Date: Wed, 02 Feb 2011 17:32:18 -0600
Message-ID: <201102022332.p12NWI6o029385@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:33201 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab1BBX7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:59:18 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p12Nn7Fv018632
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:49:07 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p12NxIqJ179876
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:59:18 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12NxHjl028315
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:59:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds security context support to ip xfrm policy.

Signed-off-by: Joy Latten <latten@austin.ibm.com>
---
 ip/xfrm_policy.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index dcb3da4..9ef5c09 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -48,14 +48,15 @@
 #define NLMSG_BUF_SIZE 4096
 #define RTA_BUF_SIZE 2048
 #define XFRM_TMPLS_BUF_SIZE 1024
+#define CTX_BUF_SIZE 256
 
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] [ ptype PTYPE ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ ctx SEC_CTX ][ index INDEX ] [ ptype PTYPE ]\n");
 	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ] [ LIMIT-LIST ] [ TMPL-LIST ] [mark MARK [mask MASK]]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ptype PTYPE ] [mark MARK [mask MASK]]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ctx SEC_CTX ][ ptype PTYPE ] [mark MARK [mask MASK]]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]  [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
@@ -222,6 +223,23 @@ static int xfrm_tmpl_parse(struct xfrm_user_tmpl *tmpl,
 	return 0;
 }
 
+int xfrm_sctx_parse(char *ctxstr, char *s,
+			   struct xfrm_user_sec_ctx *sctx)
+{
+	int slen;
+
+	slen = strlen(s) + 1;
+
+	sctx->exttype = XFRMA_SEC_CTX;
+	sctx->ctx_doi = 1;
+	sctx->ctx_alg = 1;
+	sctx->ctx_len = slen;
+	sctx->len = sizeof(struct xfrm_user_sec_ctx) + slen;
+	memcpy(ctxstr, s, slen);
+
+	return 0;
+}
+
 static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -233,14 +251,20 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 	char *dirp = NULL;
 	char *selp = NULL;
 	char *ptypep = NULL;
+	char *sctxp = NULL;
 	struct xfrm_userpolicy_type upt;
 	char tmpls_buf[XFRM_TMPLS_BUF_SIZE];
 	int tmpls_len = 0;
 	struct xfrm_mark mark = {0, 0};
+	struct {
+		struct xfrm_user_sec_ctx sctx;
+		char	str[CTX_BUF_SIZE];
+	} ctx;
 
 	memset(&req, 0, sizeof(req));
 	memset(&upt, 0, sizeof(upt));
 	memset(&tmpls_buf, 0, sizeof(tmpls_buf));
+	memset(&ctx, 0, sizeof(ctx));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpinfo));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
@@ -260,6 +284,15 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpinfo.dir, &argc, &argv);
+		} else if (strcmp(*argv, "ctx") == 0) {
+			char *context;
+
+			if (sctxp)
+				duparg("ctx", *argv);
+			sctxp = *argv;
+			NEXT_ARG();
+			context = *argv;
+			xfrm_sctx_parse((char *)&ctx.str, context, &ctx.sctx);
 		} else if (strcmp(*argv, "mark") == 0) {
 			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "index") == 0) {
@@ -347,6 +380,10 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
+	if (sctxp) {
+		addattr_l(&req.n, sizeof(req), XFRMA_SEC_CTX,
+			  (void *)&ctx, ctx.sctx.len);
+	}
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
@@ -528,11 +565,18 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 	char *selp = NULL;
 	char *indexp = NULL;
 	char *ptypep = NULL;
+	char *sctxp = NULL;
 	struct xfrm_userpolicy_type upt;
 	struct xfrm_mark mark = {0, 0};
+	struct {
+		struct xfrm_user_sec_ctx sctx;
+		char    str[CTX_BUF_SIZE];
+	} ctx;
+
 
 	memset(&req, 0, sizeof(req));
 	memset(&upt, 0, sizeof(upt));
+	memset(&ctx, 0, sizeof(ctx));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpid));
 	req.n.nlmsg_flags = NLM_F_REQUEST;
@@ -547,6 +591,15 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpid.dir, &argc, &argv);
 
+		} else if (strcmp(*argv, "ctx") == 0) {
+			char *context;
+
+			if (sctxp)
+				duparg("ctx", *argv);
+			sctxp = *argv;
+			NEXT_ARG();
+			context = *argv;
+			xfrm_sctx_parse((char *)&ctx.str, context, &ctx.sctx);
 		} else if (strcmp(*argv, "mark") == 0) {
 			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "index") == 0) {
@@ -610,6 +663,11 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 		}
 	}
 
+	if (sctxp) {
+		addattr_l(&req.n, sizeof(req), XFRMA_SEC_CTX,
+			  (void *)&ctx, ctx.sctx.len);
+	}
+
 	if (rtnl_talk(&rth, &req.n, 0, 0, res_nlbuf, NULL, NULL) < 0)
 		exit(2);
 
-- 
1.5.5.6

