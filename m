From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 02/10] MLSXFRM-v02: Define new SELinux service routine
Date: Tue, 18 Jul 2006 12:24:15 -0500
Message-ID: <44BD193F.8070303@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:43967 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932314AbWGRRYi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:24:38 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This defines a routine that combines the Type Enforcement portion of one sid
with the MLS portion from the other sid to arrive at a new sid. This would be
used to define a sid for a security association that is to be negotiated by IKE
as well as for determing the sid for open requests and connection-oriented child
sockets.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---

 security/selinux/include/security.h |    2 
 security/selinux/ss/mls.c           |   20 -------
 security/selinux/ss/mls.h           |   20 +++++++
 security/selinux/ss/services.c      |   69 ++++++++++++++++++++++++++
 4 files changed, 91 insertions(+), 20 deletions(-)

--- linux-2.6.17.flask/security/selinux/include/security.h	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/security/selinux/include/security.h	2006-07-17 13:25:00.000000000 -0500
@@ -78,6 +78,8 @@ int security_node_sid(u16 domain, void *
 int security_validate_transition(u32 oldsid, u32 newsid, u32 tasksid,
                                  u16 tclass);
 
+int security_sid_mls_copy(u32 sid, u32 mls_sid, u32 *new_sid);
+
 #define SECURITY_FS_USE_XATTR		1 /* use xattr */
 #define SECURITY_FS_USE_TRANS		2 /* use transition SIDs, e.g. devpts/tmpfs */
 #define SECURITY_FS_USE_TASK		3 /* use task SIDs, e.g. pipefs/sockfs */
--- linux-2.6.17.flask/security/selinux/ss/mls.c	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/security/selinux/ss/mls.c	2006-07-17 13:25:15.000000000 -0500
@@ -212,26 +212,6 @@ int mls_context_isvalid(struct policydb 
 }
 
 /*
- * Copies the MLS range from `src' into `dst'.
- */
-static inline int mls_copy_context(struct context *dst,
-				   struct context *src)
-{
-	int l, rc = 0;
-
-	/* Copy the MLS range from the source context */
-	for (l = 0; l < 2; l++) {
-		dst->range.level[l].sens = src->range.level[l].sens;
-		rc = ebitmap_cpy(&dst->range.level[l].cat,
-				 &src->range.level[l].cat);
-		if (rc)
-			break;
-	}
-
-	return rc;
-}
-
-/*
  * Set the MLS fields in the security context structure
  * `context' based on the string representation in
  * the string `*scontext'.  Update `*scontext' to
--- linux-2.6.17.flask/security/selinux/ss/mls.h	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/security/selinux/ss/mls.h	2006-07-17 13:25:33.000000000 -0500
@@ -17,6 +17,26 @@
 #include "context.h"
 #include "policydb.h"
 
+/*
+ * Copies the MLS range from `src' into `dst'.
+ */
+static inline int mls_copy_context(struct context *dst,
+				   struct context *src)
+{
+	int l, rc = 0;
+
+	/* Copy the MLS range from the source context */
+	for (l = 0; l < 2; l++) {
+		dst->range.level[l].sens = src->range.level[l].sens;
+		rc = ebitmap_cpy(&dst->range.level[l].cat,
+				 &src->range.level[l].cat);
+		if (rc)
+			break;
+	}
+
+	return rc;
+}
+
 int mls_compute_context_len(struct context *context);
 void mls_sid_to_context(struct context *context, char **scontext);
 int mls_context_isvalid(struct policydb *p, struct context *c);
--- linux-2.6.17.flask/security/selinux/ss/services.c	2006-07-14 09:28:40.000000000 -0500
+++ linux-2.6.17/security/selinux/ss/services.c	2006-07-17 13:25:51.000000000 -0500
@@ -1817,6 +1817,75 @@ out:
 	return rc;
 }
 
+/*
+ * security_sid_mls_copy() - computes a new sid based on the given
+ * sid and the mls portion of mls_sid.
+ */
+int security_sid_mls_copy(u32 sid, u32 mls_sid, u32 *new_sid)
+{
+	struct context *context1;
+	struct context *context2;
+	struct context newcon;
+	char *s;
+	u32 len;
+	int rc = 0;
+
+	if (!ss_initialized) {
+		*new_sid = sid;
+		goto out;
+	}
+
+	context_init(&newcon);
+
+	POLICY_RDLOCK;
+	context1 = sidtab_search(&sidtab, sid);
+	if (!context1) {
+		printk(KERN_ERR "security_sid_mls_copy:  unrecognized SID "
+		       "%d\n", sid);
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+
+	context2 = sidtab_search(&sidtab, mls_sid);
+	if (!context2) {
+		printk(KERN_ERR "security_sid_mls_copy:  unrecognized SID "
+		       "%d\n", mls_sid);
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+
+	newcon.user = context1->user;
+	newcon.role = context1->role;
+	newcon.type = context1->type;
+	rc = mls_copy_context(&newcon, context2);
+	if (rc)
+		goto out_unlock;
+
+
+	/* Check the validity of the new context. */
+	if (!policydb_context_isvalid(&policydb, &newcon)) {
+		rc = convert_context_handle_invalid_context(&newcon);
+		if (rc)
+			goto bad;
+	}
+
+	rc = sidtab_context_to_sid(&sidtab, &newcon, new_sid);
+	goto out_unlock;
+
+bad:
+	if (!context_struct_to_string(&newcon, &s, &len)) {
+		audit_log(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+			  "security_sid_mls_copy: invalid context %s", s);
+		kfree(s);
+	}
+
+out_unlock:
+	POLICY_RDUNLOCK;
+	context_destroy(&newcon);
+out:
+	return rc;
+}
+
 struct selinux_audit_rule {
 	u32 au_seqno;
 	struct context au_ctxt;
