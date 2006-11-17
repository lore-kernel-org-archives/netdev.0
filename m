From: paul.moore@hp.com
Subject: [PATCH 13/13] NetLabel: honor the audit_enabled flag
Date: Fri, 17 Nov 2006 17:38:55 -0500
Message-ID: <20061117224338.607672000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:410 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755988AbWKQWnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:40 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-audit_disabled
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The audit_enabled flag is used to signal when syscall auditing is to be
performed.  While NetLabel uses a Netlink interface instead of syscalls, it is
reasonable to consider the NetLabel Netlink interface as a form of syscall so
pay attention to the audit_enabled flag when generating audit messages in
NetLabel.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_cipso_v4.c   |   26 +++++++++++---------
 net/netlabel/netlabel_domainhash.c |   48 ++++++++++++++++---------------------
 net/netlabel/netlabel_unlabeled.c  |    8 ++++--
 net/netlabel/netlabel_user.c       |    7 +++++
 4 files changed, 50 insertions(+), 39 deletions(-)

Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_cipso_v4.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_cipso_v4.c
@@ -407,12 +407,14 @@ static int netlbl_cipsov4_add(struct sk_
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_ADD,
 					      &audit_info);
-	audit_log_format(audit_buf,
-			 " cipso_doi=%u cipso_type=%s res=%u",
-			 doi,
-			 type_str,
-			 ret_val == 0 ? 1 : 0);
-	audit_log_end(audit_buf);
+	if (audit_buf != NULL) {
+		audit_log_format(audit_buf,
+				 " cipso_doi=%u cipso_type=%s res=%u",
+				 doi,
+				 type_str,
+				 ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
 
 	return ret_val;
 }
@@ -680,11 +682,13 @@ static int netlbl_cipsov4_remove(struct 
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_DEL,
 					      &audit_info);
-	audit_log_format(audit_buf,
-			 " cipso_doi=%u res=%u",
-			 doi,
-			 ret_val == 0 ? 1 : 0);
-	audit_log_end(audit_buf);
+	if (audit_buf != NULL) {
+		audit_log_format(audit_buf,
+				 " cipso_doi=%u res=%u",
+				 doi,
+				 ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
 
 	return ret_val;
 }
Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_domainhash.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_domainhash.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_domainhash.c
@@ -202,7 +202,6 @@ int netlbl_domhsh_add(struct netlbl_dom_
 	int ret_val;
 	u32 bkt;
 	struct audit_buffer *audit_buf;
-	char *audit_domain;
 
 	switch (entry->type) {
 	case NETLBL_NLTYPE_UNLABELED:
@@ -243,24 +242,24 @@ int netlbl_domhsh_add(struct netlbl_dom_
 	} else
 		ret_val = -EINVAL;
 
-	if (entry->domain != NULL)
-		audit_domain = entry->domain;
-	else
-		audit_domain = "(default)";
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
-	audit_log_format(audit_buf, " nlbl_domain=%s", audit_domain);
-	switch (entry->type) {
-	case NETLBL_NLTYPE_UNLABELED:
-		audit_log_format(audit_buf, " nlbl_protocol=unlbl");
-		break;
-	case NETLBL_NLTYPE_CIPSOV4:
+	if (audit_buf != NULL) {
 		audit_log_format(audit_buf,
-				 " nlbl_protocol=cipsov4 cipso_doi=%u",
-				 entry->type_def.cipsov4->doi);
-		break;
+				 " nlbl_domain=%s",
+				 entry->domain ? entry->domain : "(default)");
+		switch (entry->type) {
+		case NETLBL_NLTYPE_UNLABELED:
+			audit_log_format(audit_buf, " nlbl_protocol=unlbl");
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			audit_log_format(audit_buf,
+					 " nlbl_protocol=cipsov4 cipso_doi=%u",
+					 entry->type_def.cipsov4->doi);
+			break;
+		}
+		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
 	}
-	audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
-	audit_log_end(audit_buf);
 
 	rcu_read_unlock();
 
@@ -310,7 +309,6 @@ int netlbl_domhsh_remove(const char *dom
 	int ret_val = -ENOENT;
 	struct netlbl_dom_map *entry;
 	struct audit_buffer *audit_buf;
-	char *audit_domain;
 
 	rcu_read_lock();
 	if (domain != NULL)
@@ -348,16 +346,14 @@ int netlbl_domhsh_remove(const char *dom
 		spin_unlock(&netlbl_domhsh_def_lock);
 	}
 
-	if (entry->domain != NULL)
-		audit_domain = entry->domain;
-	else
-		audit_domain = "(default)";
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_DEL, audit_info);
-	audit_log_format(audit_buf,
-			 " nlbl_domain=%s res=%u",
-			 audit_domain,
-			 ret_val == 0 ? 1 : 0);
-	audit_log_end(audit_buf);
+	if (audit_buf != NULL) {
+		audit_log_format(audit_buf,
+				 " nlbl_domain=%s res=%u",
+				 entry->domain ? entry->domain : "(default)",
+				 ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
 
 	if (ret_val == 0)
 		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_unlabeled.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_unlabeled.c
@@ -35,6 +35,7 @@
 #include <linux/socket.h>
 #include <linux/string.h>
 #include <linux/skbuff.h>
+#include <linux/audit.h>
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <net/genetlink.h>
@@ -92,8 +93,11 @@ static void netlbl_unlabel_acceptflg_set
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_ALLOW,
 					      audit_info);
-	audit_log_format(audit_buf, " unlbl_accept=%u old=%u", value, old_val);
-	audit_log_end(audit_buf);
+	if (audit_buf != NULL) {
+		audit_log_format(audit_buf,
+				 " unlbl_accept=%u old=%u", value, old_val);
+		audit_log_end(audit_buf);
+	}
 }
 
 /*
Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_user.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_user.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_user.c
@@ -46,6 +46,10 @@
 #include "netlabel_cipso_v4.h"
 #include "netlabel_user.h"
 
+/* do not do any auditing if audit_enabled == 0, see kernel/audit.c for
+ * details */
+extern int audit_enabled;
+
 /*
  * NetLabel NETLINK Setup Functions
  */
@@ -101,6 +105,9 @@ struct audit_buffer *netlbl_audit_start_
 	char *secctx;
 	u32 secctx_len;
 
+	if (audit_enabled == 0)
+		return NULL;
+
 	audit_buf = audit_log_start(audit_ctx, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 		return NULL;

--
paul moore
linux security @ hp
