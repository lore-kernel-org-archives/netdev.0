From: Joy Latten <jml@austin.ibm.com>
Subject: [iproute2 PATCH 3/3]: xfrm security context support
Date: Wed, 02 Feb 2011 17:32:59 -0600
Message-ID: <201102022332.p12NWxXP029398@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:33324 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab1BBX77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:59:59 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p12Nnldo019095
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:49:47 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p12NxwY3122226
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:59:58 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12Nxwrt029491
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:59:58 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds security context support to ip xfrm state.

Signed-off-by: Joy Latten <latten@austin.ibm.com>
---
 ip/xfrm_state.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 38d4039..165888d 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -50,12 +50,13 @@
 #define NLMSG_BUF_SIZE 4096
 #define RTA_BUF_SIZE 2048
 #define XFRM_ALGO_KEY_BUF_SIZE 512
+#define CTX_BUF_SIZE 256
 
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ mode MODE ]\n");
+	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ ctx SEC_CTX ] [ mode MODE ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ replay-seq SEQ ]\n");
 	fprintf(stderr, "        [ replay-oseq SEQ ] [ LIMIT-LIST ]\n");
@@ -246,10 +247,16 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	char *aalgop = NULL;
 	char *calgop = NULL;
 	char *coap = NULL;
+	char *sctxp = NULL;
 	struct xfrm_mark mark = {0, 0};
+	struct {
+		struct xfrm_user_sec_ctx sctx;
+		char    str[CTX_BUF_SIZE];
+	} ctx;
 
 	memset(&req, 0, sizeof(req));
 	memset(&replay, 0, sizeof(replay));
+	memset(&ctx, 0, sizeof(ctx));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
@@ -333,6 +340,19 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			addattr_l(&req.n, sizeof(req.buf), XFRMA_COADDR,
 				  (void *)&xcoa, sizeof(xcoa));
+		} else if (strcmp(*argv, "ctx") == 0) {
+			char *context;
+
+			if (sctxp)
+				duparg("ctx", *argv);
+			sctxp = *argv;
+
+			NEXT_ARG();
+			context = *argv;
+
+			xfrm_sctx_parse((char *)&ctx.str, context, &ctx.sctx);
+			addattr_l(&req.n, sizeof(req.buf), XFRMA_SEC_CTX,
+				  (void *)&ctx, ctx.sctx.len);
 		} else {
 			/* try to assume ALGO */
 			int type = xfrm_algotype_getbyname(*argv);
-- 
1.5.5.6

