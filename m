From: paul.moore@hp.com
Subject: [PATCH 2/3] NetLabel: better error handling involving mls_export_cat()
Date: Wed, 11 Oct 2006 19:10:48 -0400
Message-ID: <20061011231356.545529000@hp.com>
References: <20061011231046.825517000@hp.com>
Cc: jmorris@namei.org, eparis@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:61651 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161274AbWJKXN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 19:13:58 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-selinux_mlsexportfix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Upon inspection it looked like the error handling for mls_export_cat() was
rather poor.  This patch addresses this by NULL'ing out kfree()'d pointers
before returning and checking the return value of the function everywhere
it is called.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/ss/ebitmap.c  |    8 ++++++--
 security/selinux/ss/mls.c      |   17 ++++++++++++++---
 security/selinux/ss/services.c |   18 ++++++++++--------
 3 files changed, 30 insertions(+), 13 deletions(-)

Index: net-2.6_bugfix_2/security/selinux/ss/ebitmap.c
===================================================================
--- net-2.6_bugfix_2.orig/security/selinux/ss/ebitmap.c
+++ net-2.6_bugfix_2/security/selinux/ss/ebitmap.c
@@ -93,11 +93,15 @@ int ebitmap_export(const struct ebitmap 
 	size_t bitmap_byte;
 	unsigned char bitmask;
 
+	if (src->highbit == 0) {
+		*dst = NULL;
+		*dst_len = 0;
+		return 0;
+	}
+
 	bitmap_len = src->highbit / 8;
 	if (src->highbit % 7)
 		bitmap_len += 1;
-	if (bitmap_len == 0)
-		return -EINVAL;
 
 	bitmap = kzalloc((bitmap_len & ~(sizeof(MAPTYPE) - 1)) +
 			 sizeof(MAPTYPE),
Index: net-2.6_bugfix_2/security/selinux/ss/mls.c
===================================================================
--- net-2.6_bugfix_2.orig/security/selinux/ss/mls.c
+++ net-2.6_bugfix_2/security/selinux/ss/mls.c
@@ -640,8 +640,13 @@ int mls_export_cat(const struct context 
 {
 	int rc = -EPERM;
 
-	if (!selinux_mls_enabled)
+	if (!selinux_mls_enabled) {
+		*low = NULL;
+		*low_len = 0;
+		*high = NULL;
+		*high_len = 0;
 		return 0;
+	}
 
 	if (low != NULL) {
 		rc = ebitmap_export(&context->range.level[0].cat,
@@ -661,10 +666,16 @@ int mls_export_cat(const struct context 
 	return 0;
 
 export_cat_failure:
-	if (low != NULL)
+	if (low != NULL) {
 		kfree(*low);
-	if (high != NULL)
+		*low = NULL;
+		*low_len = 0;
+	}
+	if (high != NULL) {
 		kfree(*high);
+		*high = NULL;
+		*high_len = 0;
+	}
 	return rc;
 }
 
Index: net-2.6_bugfix_2/security/selinux/ss/services.c
===================================================================
--- net-2.6_bugfix_2.orig/security/selinux/ss/services.c
+++ net-2.6_bugfix_2/security/selinux/ss/services.c
@@ -2399,31 +2399,33 @@ static int selinux_netlbl_socket_setsid(
 	if (!ss_initialized)
 		return 0;
 
+	netlbl_secattr_init(&secattr);
+
 	POLICY_RDLOCK;
 
 	ctx = sidtab_search(&sidtab, sid);
 	if (ctx == NULL)
 		goto netlbl_socket_setsid_return;
 
-	netlbl_secattr_init(&secattr);
 	secattr.domain = kstrdup(policydb.p_type_val_to_name[ctx->type - 1],
 				 GFP_ATOMIC);
 	mls_export_lvl(ctx, &secattr.mls_lvl, NULL);
 	secattr.mls_lvl_vld = 1;
-	mls_export_cat(ctx,
-		       &secattr.mls_cat,
-		       &secattr.mls_cat_len,
-		       NULL,
-		       NULL);
+	rc = mls_export_cat(ctx,
+			    &secattr.mls_cat,
+			    &secattr.mls_cat_len,
+			    NULL,
+			    NULL);
+	if (rc != 0)
+		goto netlbl_socket_setsid_return;
 
 	rc = netlbl_socket_setattr(sock, &secattr);
 	if (rc == 0)
 		sksec->nlbl_state = NLBL_LABELED;
 
-	netlbl_secattr_destroy(&secattr);
-
 netlbl_socket_setsid_return:
 	POLICY_RDUNLOCK;
+	netlbl_secattr_destroy(&secattr);
 	return rc;
 }
 

--
paul moore
linux security @ hp
