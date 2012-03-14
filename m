From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] iproute: allow changing gretap parameters
Date: Wed, 14 Mar 2012 10:30:34 -0700
Message-ID: <20120314103034.451cf3a9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42721 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760076Ab2CNRah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 13:30:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the order of evaluation of ip link type arguements to allow
changing parameters of gre tunnels.

The following wouldn't work:
 # ip li add mytunnel type gretap remote 1.1.1.1 key 3
 # ip li set mytunnel type gretap key 9
---
 ip/iplink.c |   60 +++++++++++++++++++++++++++++-----------------------------
 1 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 6b051b6..8481514 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -490,36 +490,6 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	ll_init_map(&rth);
 
-	if (type) {
-		struct rtattr *linkinfo = NLMSG_TAIL(&req.n);
-		addattr_l(&req.n, sizeof(req), IFLA_LINKINFO, NULL, 0);
-		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
-			 strlen(type));
-
-		lu = get_link_kind(type);
-		if (lu && argc) {
-			struct rtattr * data = NLMSG_TAIL(&req.n);
-			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);
-
-			if (lu->parse_opt &&
-			    lu->parse_opt(lu, argc, argv, &req.n))
-				return -1;
-
-			data->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)data;
-		} else if (argc) {
-			if (matches(*argv, "help") == 0)
-				usage();
-			fprintf(stderr, "Garbage instead of arguments \"%s ...\". "
-					"Try \"ip link help\".\n", *argv);
-			return -1;
-		}
-		linkinfo->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)linkinfo;
-	} else if (flags & NLM_F_CREATE) {
-		fprintf(stderr, "Not enough information: \"type\" argument "
-				"is required\n");
-		return -1;
-	}
-
 	if (!(flags & NLM_F_CREATE)) {
 		if (!dev) {
 			fprintf(stderr, "Not enough information: \"dev\" "
@@ -559,6 +529,36 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
 	}
 
+	if (type) {
+		struct rtattr *linkinfo = NLMSG_TAIL(&req.n);
+		addattr_l(&req.n, sizeof(req), IFLA_LINKINFO, NULL, 0);
+		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
+			 strlen(type));
+
+		lu = get_link_kind(type);
+		if (lu && argc) {
+			struct rtattr * data = NLMSG_TAIL(&req.n);
+			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);
+
+			if (lu->parse_opt &&
+			    lu->parse_opt(lu, argc, argv, &req.n))
+				return -1;
+
+			data->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)data;
+		} else if (argc) {
+			if (matches(*argv, "help") == 0)
+				usage();
+			fprintf(stderr, "Garbage instead of arguments \"%s ...\". "
+					"Try \"ip link help\".\n", *argv);
+			return -1;
+		}
+		linkinfo->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)linkinfo;
+	} else if (flags & NLM_F_CREATE) {
+		fprintf(stderr, "Not enough information: \"type\" argument "
+				"is required\n");
+		return -1;
+	}
+
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
 		exit(2);
 
-- 
1.7.9.1
