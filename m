From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 2/2] NET: fix memory leaks from security_secid_to_secctx()
Date: Wed, 01 Aug 2007 11:12:59 -0400
Message-ID: <20070801151557.264877461@hp.com>
References: <20070801151257.475951538@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:34366 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933983AbXHAPRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 11:17:50 -0400
Content-Disposition: inline; filename=network-audit_ctx_leaks
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The security_secid_to_secctx() function returns memory that must be freed
by a call to security_release_secctx() which was not always happening.  This
patch fixes two of these problems (all that I could find in the kernel source
at present).

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_user.c |    4 +++-
 net/xfrm/xfrm_policy.c       |    5 +++--
 2 files changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6_secctx-leaks/net/netlabel/netlabel_user.c
===================================================================
--- linux-2.6_secctx-leaks.orig/net/netlabel/netlabel_user.c
+++ linux-2.6_secctx-leaks/net/netlabel/netlabel_user.c
@@ -113,8 +113,10 @@ struct audit_buffer *netlbl_audit_start_
 	if (audit_info->secid != 0 &&
 	    security_secid_to_secctx(audit_info->secid,
 				     &secctx,
-				     &secctx_len) == 0)
+				     &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
+		security_release_secctx(secctx, secctx_len);
+	}
 
 	return audit_buf;
 }
Index: linux-2.6_secctx-leaks/net/xfrm/xfrm_policy.c
===================================================================
--- linux-2.6_secctx-leaks.orig/net/xfrm/xfrm_policy.c
+++ linux-2.6_secctx-leaks/net/xfrm/xfrm_policy.c
@@ -2195,9 +2195,10 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 	}
 
 	if (sid != 0 &&
-		security_secid_to_secctx(sid, &secctx, &secctx_len) == 0)
+	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
-	else
+		security_release_secctx(secctx, secctx_len);
+	} else
 		audit_log_task_context(audit_buf);
 
 	if (xp) {

-- 
paul moore
linux security @ hp
