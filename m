From: Joy Latten <jml@austin.ibm.com>
Subject: [iproute2 PATCH 1/3]: xfrm security context support
Date: Wed, 02 Feb 2011 17:31:39 -0600
Message-ID: <201102022331.p12NVdgp029376@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:53963 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab1BBX6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 18:58:43 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p12Jenbx026740
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 14:40:49 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 737764DE8026
	for <netdev@vger.kernel.org>; Wed,  2 Feb 2011 18:58:04 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p12NwdSq475190
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 18:58:40 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12Nwd7U026429
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:58:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the Linux kernel, ipsec policy and SAs can include a
security context to support MAC networking. This feature
is often referred to as "labeled ipsec".

This patchset adds security context support into ip xfrm 
such that a security context can be included when 
add/delete/display SAs and policies with the ip command.
The user provides the security context when adding 
SAs and policies. If a policy or SA contains a security
context, the changes allow the security context to be displayed.

For example, 
ip xfrm state
src 10.1.1.6 dst 10.1.1.2
	proto esp spi 0x00000301 reqid 0 mode transport
	replay-window 0 
	auth hmac(digest_null) 0x3078
	enc cbc(des3_ede) 0x6970763672656164796c6f676f33646573636263696e3031
	security context root:system_r:unconfined_t:s0 


Please  let me know if all is ok with the patchset.
Thanks!!

regards,
Joy


Signed-off-by:  Joy Latten <latten@austin.ibm.com>
---
 ip/ipxfrm.c |   28 ++++++++++++++++++++++++++++
 ip/xfrm.h   |    3 ++-
 2 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 9753822..cc4dc80 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -850,6 +850,20 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		xfrm_lifetime_print(&xsinfo->lft, &xsinfo->curlft, fp, buf);
 		xfrm_stats_print(&xsinfo->stats, fp, buf);
 	}
+
+	if (tb[XFRMA_SEC_CTX]) {
+		struct xfrm_user_sec_ctx *sctx;
+
+		fprintf(fp, "\tsecurity context ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_SEC_CTX]) < sizeof(*sctx))
+			fprintf(fp, "(ERROR truncated)");
+
+		sctx = (struct xfrm_user_sec_ctx *)RTA_DATA(tb[XFRMA_SEC_CTX]);
+
+		fprintf(fp, "%s %s", (char *)(sctx + 1), _SL_);
+	}
+
 }
 
 void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
@@ -862,6 +876,20 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 
 	xfrm_selector_print(&xpinfo->sel, preferred_family, fp, title);
 
+	if (tb[XFRMA_SEC_CTX]) {
+		struct xfrm_user_sec_ctx *sctx;
+
+		fprintf(fp, "\tsecurity context ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_SEC_CTX]) < sizeof(*sctx))
+			fprintf(fp, "(ERROR truncated)");
+
+		sctx = (struct xfrm_user_sec_ctx *)RTA_DATA(tb[XFRMA_SEC_CTX]);
+
+		fprintf(fp, "%s ", (char *)(sctx + 1));
+		fprintf(fp, "%s", _SL_);
+	}
+
 	if (prefix)
 		STRBUF_CAT(buf, prefix);
 	STRBUF_CAT(buf, "\t");
diff --git a/ip/xfrm.h b/ip/xfrm.h
index d3ca5c5..784a201 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -154,5 +154,6 @@ int xfrm_reqid_parse(__u32 *reqid, int *argcp, char ***argvp);
 int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp);
 int xfrm_lifetime_cfg_parse(struct xfrm_lifetime_cfg *lft,
 			    int *argcp, char ***argvp);
-
+int xfrm_sctx_parse(char *ctxstr, char *context,
+		    struct xfrm_user_sec_ctx *sctx);
 #endif
-- 
1.5.5.6

