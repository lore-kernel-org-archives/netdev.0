From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 1/6] selinux: Fix a problem in
	security_netlbl_sid_to_secattr()
Date: Fri, 08 Aug 2008 16:52:54 -0400
Message-ID: <20080808205254.21077.91894.stgit@flek>
References: <20080808203542.21077.37084.stgit@flek>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:15193 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbYHHUw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 16:52:57 -0400
In-Reply-To: <20080808203542.21077.37084.stgit@flek>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when SELinux fails to allocate memory in
security_netlbl_sid_to_secattr() the NetLabel LSM domain field is set to
NULL which triggers the default NetLabel LSM domain mapping which may not
always be the desired mapping.  This patch fixes this by returning an error
when the kernel is unable to allocate memory.  This could result in more
failures on a system with heavy memory pressure but it is the "correct"
thing to do.

Signed-off-by: XXX
---

 security/selinux/ss/services.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index b52f923..5b7ecc1 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2788,7 +2788,7 @@ netlbl_secattr_to_sid_return_cleanup:
  */
 int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 {
-	int rc = -ENOENT;
+	int rc;
 	struct context *ctx;
 
 	if (!ss_initialized)
@@ -2796,10 +2796,16 @@ int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 
 	read_lock(&policy_rwlock);
 	ctx = sidtab_search(&sidtab, sid);
-	if (ctx == NULL)
+	if (ctx == NULL) {
+		rc = -ENOENT;
 		goto netlbl_sid_to_secattr_failure;
+	}
 	secattr->domain = kstrdup(policydb.p_type_val_to_name[ctx->type - 1],
 				  GFP_ATOMIC);
+	if (secattr->domain == NULL) {
+		rc = -ENOMEM;
+		goto netlbl_sid_to_secattr_failure;
+	}
 	secattr->flags |= NETLBL_SECATTR_DOMAIN_CPY;
 	mls_export_netlbl_lvl(ctx, secattr);
 	rc = mls_export_netlbl_cat(ctx, secattr);

