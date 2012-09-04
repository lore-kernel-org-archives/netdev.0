From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v3 3/3] iproute2: use libgenl for ipl2tp
Date: Wed,  5 Sep 2012 00:03:17 +0300
Message-ID: <1346792597-2427-4-git-send-email-ja@ssi.bg>
References: <1346792597-2427-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34426 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757738Ab2IDVAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 17:00:25 -0400
In-Reply-To: <1346792597-2427-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Use the common code from libgenl.c

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp iproute2-3.5.1-tcp_metrics/ip/ipl2tp.c iproute2-3.5.1-ipl2tp-genl/ip/ipl2tp.c
--- iproute2-3.5.1-tcp_metrics/ip/ipl2tp.c	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-ipl2tp-genl/ip/ipl2tp.c	2012-09-04 01:40:55.775000653 +0300
@@ -25,6 +25,7 @@
 
 #include <linux/genetlink.h>
 #include <linux/l2tp.h>
+#include "libgenl.h"
 
 #include "utils.h"
 #include "ip_common.h"
@@ -747,67 +748,6 @@ static int do_show(int argc, char **argv
 	return 0;
 }
 
-static int genl_parse_getfamily(struct nlmsghdr *nlh)
-{
-	struct rtattr *tb[CTRL_ATTR_MAX + 1];
-	struct genlmsghdr *ghdr = NLMSG_DATA(nlh);
-	int len = nlh->nlmsg_len;
-	struct rtattr *attrs;
-
-	if (nlh->nlmsg_type != GENL_ID_CTRL) {
-		fprintf(stderr, "Not a controller message, nlmsg_len=%d "
-			"nlmsg_type=0x%x\n", nlh->nlmsg_len, nlh->nlmsg_type);
-		return -1;
-	}
-
-	if (ghdr->cmd != CTRL_CMD_NEWFAMILY) {
-		fprintf(stderr, "Unknown controller command %d\n", ghdr->cmd);
-		return -1;
-	}
-
-	len -= NLMSG_LENGTH(GENL_HDRLEN);
-
-	if (len < 0) {
-		fprintf(stderr, "wrong controller message len %d\n", len);
-		return -1;
-	}
-
-	attrs = (struct rtattr *) ((char *) ghdr + GENL_HDRLEN);
-	parse_rtattr(tb, CTRL_ATTR_MAX, attrs, len);
-
-	if (tb[CTRL_ATTR_FAMILY_ID] == NULL) {
-		fprintf(stderr, "Missing family id TLV\n");
-		return -1;
-	}
-
-	return rta_getattr_u16(tb[CTRL_ATTR_FAMILY_ID]);
-}
-
-int genl_ctrl_resolve_family(const char *family)
-{
-	struct {
-		struct nlmsghdr         n;
-		struct genlmsghdr	g;
-		char                    buf[1024];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = GENL_ID_CTRL;
-	req.g.cmd = CTRL_CMD_GETFAMILY;
-
-	addattr_l(&req.n, 1024, CTRL_ATTR_FAMILY_NAME,
-		  family, strlen(family) + 1);
-
-	if (rtnl_talk(&genl_rth, &req.n, 0, 0, &req.n) < 0) {
-		fprintf(stderr, "Error talking to the kernel\n");
-		return -2;
-	}
-
-	return genl_parse_getfamily(&req.n);
-}
-
 int do_ipl2tp(int argc, char **argv)
 {
 	if (genl_family < 0) {
@@ -816,7 +756,8 @@ int do_ipl2tp(int argc, char **argv)
 			exit(1);
 		}
 
-		genl_family = genl_ctrl_resolve_family(L2TP_GENL_NAME);
+		genl_family = libgenl_resolve_family(&genl_rth,
+						     L2TP_GENL_NAME);
 		if (genl_family < 0)
 			exit(1);
 	}
