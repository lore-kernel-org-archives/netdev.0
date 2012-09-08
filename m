From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2/2] iproute2: use libgenl in ipl2tp
Date: Sat,  8 Sep 2012 12:48:25 +0300
Message-ID: <1347097705-2906-3-git-send-email-ja@ssi.bg>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47836 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab2IHJpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 05:45:43 -0400
In-Reply-To: <1347097705-2906-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Use the common code from libgenl.c to parse family.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ip/ipl2tp.c |   65 ++--------------------------------------------------------
 1 files changed, 3 insertions(+), 62 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 1cbed8d..c69091d 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -25,6 +25,7 @@
 
 #include <linux/genetlink.h>
 #include <linux/l2tp.h>
+#include "libgenl.h"
 
 #include "utils.h"
 #include "ip_common.h"
@@ -747,67 +748,6 @@ static int do_show(int argc, char **argv)
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
-- 
1.7.3.4
