From: jamal <hadi@cyberus.ca>
Subject: [iproute2 PATCH 2/3] xfrm: policy by mark
Date: Tue, 23 Feb 2010 08:15:11 -0500
Message-ID: <1266930912-14640-2-git-send-email-hadi@cyberus.ca>
References: <xfrm-iproute-mark>
 <1266930912-14640-1-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f174.google.com ([209.85.222.174]:44124 "EHLO
	mail-pz0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab0BWNnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 08:43:10 -0500
Received: by pzk4 with SMTP id 4so559005pzk.21
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 05:43:10 -0800 (PST)
In-Reply-To: <1266930912-14640-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Add support for SP manipulation by mark

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 ip/xfrm_policy.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2788477..121afa1 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -54,8 +54,8 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] [ ptype PTYPE ]\n");
-	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ptype PTYPE ]\n");
+	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ] [ LIMIT-LIST ] [ TMPL-LIST ] [mark MARK [mask MASK]]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ptype PTYPE ] [mark MARK [mask MASK]]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]  [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
@@ -235,6 +235,7 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 	struct xfrm_userpolicy_type upt;
 	char tmpls_buf[XFRM_TMPLS_BUF_SIZE];
 	int tmpls_len = 0;
+	struct xfrm_mark mark = {0, 0};
 
 	memset(&req, 0, sizeof(req));
 	memset(&upt, 0, sizeof(upt));
@@ -258,6 +259,8 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpinfo.dir, &argc, &argv);
+		} else if (strcmp(*argv, "mark") == 0) {
+			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.index, *argv, 0))
@@ -334,6 +337,16 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 			  (void *)tmpls_buf, tmpls_len);
 	}
 
+	if (mark.m & mark.v) {
+		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
+				  (void *)&mark, sizeof(mark));
+		if (r < 0) {
+			fprintf(stderr, "%s: XFRMA_MARK failed\n",__func__);
+			exit(1);
+		}
+	}
+
+
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
 
@@ -515,6 +528,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 	char *indexp = NULL;
 	char *ptypep = NULL;
 	struct xfrm_userpolicy_type upt;
+	struct xfrm_mark mark = {0, 0};
 
 	memset(&req, 0, sizeof(req));
 	memset(&upt, 0, sizeof(upt));
@@ -532,6 +546,8 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpid.dir, &argc, &argv);
 
+		} else if (strcmp(*argv, "mark") == 0) {
+			xfrm_parse_mark(&mark, &argc, &argv);
 		} else if (strcmp(*argv, "index") == 0) {
 			if (indexp)
 				duparg("index", *argv);
@@ -584,6 +600,15 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 	if (req.xpid.sel.family == AF_UNSPEC)
 		req.xpid.sel.family = AF_INET;
 
+	if (mark.m & mark.v) {
+		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
+				  (void *)&mark, sizeof(mark));
+		if (r < 0) {
+			fprintf(stderr, "%s: XFRMA_MARK failed\n",__func__);
+			exit(1);
+		}
+	}
+
 	if (rtnl_talk(&rth, &req.n, 0, 0, res_nlbuf, NULL, NULL) < 0)
 		exit(2);
 
-- 
1.6.0.4

