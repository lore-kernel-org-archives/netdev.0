From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH iproute2 1/3] xfrm_policy: Add filter option for socket
 policies
Date: Mon, 30 Oct 2017 19:11:44 +0100
Message-ID: <1fa88198-c1e4-e3bd-4a76-757e6ff23fa1@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58714 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751959AbdJ3SNI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 14:13:08 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id 79BE3201D1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:07 +0100 (CET)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id j7VFRv2uFfAG for <netdev@vger.kernel.org>;
        Mon, 30 Oct 2017 19:13:06 +0100 (CET)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id EDAC920078
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:06 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Listing policies on systems with a lot of socket policies can be
confusing due to the number of returned polices. Even if socket polices
are not of interest, they cannot be filtered. This patch adds an option
to filter all socket policies from the output.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 ip/xfrm.h        | 1 +
 ip/xfrm_policy.c | 8 +++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm.h b/ip/xfrm.h
index 54d80ce..8566d63 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -90,6 +90,7 @@ struct xfrm_filter {
 	__u8 action_mask;
 	__u32 priority_mask;
 	__u8 policy_flags_mask;
+	__u8 filter_socket;
 
 	__u8 ptype;
 	__u8 ptype_mask;
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 98460a0..7d2139e 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -58,7 +58,7 @@ static void usage(void)
 	fprintf(stderr, "        [ LIMIT-LIST ] [ TMPL-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { delete | get } { SELECTOR | index INDEX } dir DIR\n");
 	fprintf(stderr, "        [ ctx CTX ] [ mark MARK [ mask MASK ] ] [ ptype PTYPE ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ SELECTOR ] [ dir DIR ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ nosock ] [ SELECTOR ] [ dir DIR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
@@ -403,6 +403,9 @@ static int xfrm_policy_filter_match(struct xfrm_userpolicy_info *xpinfo,
 	if ((xpinfo->dir^filter.xpinfo.dir)&filter.dir_mask)
 		return 0;
 
+	if (filter.filter_socket && (xpinfo->dir >= XFRM_POLICY_MAX))
+		return 0;
+
 	if ((ptype^filter.ptype)&filter.ptype_mask)
 		return 0;
 
@@ -806,6 +809,9 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 
 			filter.policy_flags_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "nosock") == 0) {
+			/* filter all socket-based policies */
+			filter.filter_socket = 1;
 		} else {
 			if (selp)
 				invarg("unknown", *argv);
-- 
2.6.4
