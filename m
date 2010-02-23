From: jamal <hadi@cyberus.ca>
Subject: [iproute2 PATCH 3/3] xfrm: add support for SA by mark
Date: Tue, 23 Feb 2010 08:15:12 -0500
Message-ID: <1266930912-14640-3-git-send-email-hadi@cyberus.ca>
References: <xfrm-iproute-mark>
 <1266930912-14640-1-git-send-email-hadi@cyberus.ca>
 <1266930912-14640-2-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:61657 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab0BWNPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 08:15:24 -0500
Received: by mail-pw0-f46.google.com with SMTP id 8so3774506pwj.19
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 05:15:24 -0800 (PST)
In-Reply-To: <1266930912-14640-2-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Add support for SA manipulation by mark

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 ip/xfrm_state.c |   66 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 32238ab..38d4039 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -67,7 +67,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM_PROTO ]\n");
 	fprintf(stderr, "Usage: ip xfrm state count \n");
 
-	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
+	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ] [mark MARK [mask MASK]]\n");
 	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
 	fprintf(stderr, "XFRM_PROTO := [ ");
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
@@ -246,6 +246,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	char *aalgop = NULL;
 	char *calgop = NULL;
 	char *coap = NULL;
+	struct xfrm_mark mark = {0, 0};
 
 	memset(&req, 0, sizeof(req));
 	memset(&replay, 0, sizeof(replay));
@@ -264,6 +265,8 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		if (strcmp(*argv, "mode") == 0) {
 			NEXT_ARG();
 			xfrm_mode_parse(&req.xsinfo.mode, &argc, &argv);
+		} else if (strcmp(*argv, "mark") == 0) {
+			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "reqid") == 0) {
 			NEXT_ARG();
 			xfrm_reqid_parse(&req.xsinfo.reqid, &argc, &argv);
@@ -440,6 +443,15 @@ parse_algo:
 		exit(1);
 	}
 
+	if (mark.m & mark.v) {
+		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
+				  (void *)&mark, sizeof(mark));
+		if (r < 0) {
+			fprintf(stderr, "XFRMA_MARK failed\n");
+			exit(1);
+		}
+	}
+
 	switch (req.xsinfo.mode) {
 	case XFRM_MODE_TRANSPORT:
 	case XFRM_MODE_TUNNEL:
@@ -519,6 +531,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 	char *idp = NULL;
 	char *minp = NULL;
 	char *maxp = NULL;
+	struct xfrm_mark mark = {0, 0};
 	char res_buf[NLMSG_BUF_SIZE];
 	struct nlmsghdr *res_n = (struct nlmsghdr *)res_buf;
 
@@ -542,6 +555,8 @@ static int xfrm_state_allocspi(int argc, char **argv)
 		if (strcmp(*argv, "mode") == 0) {
 			NEXT_ARG();
 			xfrm_mode_parse(&req.xspi.info.mode, &argc, &argv);
+		} else if (strcmp(*argv, "mark") == 0) {
+			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "reqid") == 0) {
 			NEXT_ARG();
 			xfrm_reqid_parse(&req.xspi.info.reqid, &argc, &argv);
@@ -618,6 +633,15 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			req.xspi.max = 0xffff;
 	}
 
+	if (mark.m & mark.v) {
+		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
+				  (void *)&mark, sizeof(mark));
+		if (r < 0) {
+			fprintf(stderr, "XFRMA_MARK failed\n");
+			exit(1);
+		}
+	}
+
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
@@ -763,6 +787,7 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 	} req;
 	struct xfrm_id id;
 	char *idp = NULL;
+	struct xfrm_mark mark = {0, 0};
 
 	memset(&req, 0, sizeof(req));
 
@@ -774,26 +799,39 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 	while (argc > 0) {
 		xfrm_address_t saddr;
 
-		if (idp)
-			invarg("unknown", *argv);
-		idp = *argv;
+		if (strcmp(*argv, "mark") == 0) {
+			xfrm_parse_mark(&mark, &argc, &argv);
+		} else {
+			if (idp)
+				invarg("unknown", *argv);
+			idp = *argv;
 
-		/* ID */
-		memset(&id, 0, sizeof(id));
-		memset(&saddr, 0, sizeof(saddr));
-		xfrm_id_parse(&saddr, &id, &req.xsid.family, 0,
-			      &argc, &argv);
+			/* ID */
+			memset(&id, 0, sizeof(id));
+			memset(&saddr, 0, sizeof(saddr));
+			xfrm_id_parse(&saddr, &id, &req.xsid.family, 0,
+				      &argc, &argv);
 
-		memcpy(&req.xsid.daddr, &id.daddr, sizeof(req.xsid.daddr));
-		req.xsid.spi = id.spi;
-		req.xsid.proto = id.proto;
+			memcpy(&req.xsid.daddr, &id.daddr, sizeof(req.xsid.daddr));
+			req.xsid.spi = id.spi;
+			req.xsid.proto = id.proto;
 
-		addattr_l(&req.n, sizeof(req.buf), XFRMA_SRCADDR,
-			  (void *)&saddr, sizeof(saddr));
+			addattr_l(&req.n, sizeof(req.buf), XFRMA_SRCADDR,
+				  (void *)&saddr, sizeof(saddr));
+		}
 
 		argc--; argv++;
 	}
 
+	if (mark.m & mark.v) {
+		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
+				  (void *)&mark, sizeof(mark));
+		if (r < 0) {
+			fprintf(stderr, "XFRMA_MARK failed\n");
+			exit(1);
+		}
+	}
+
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
-- 
1.6.0.4

