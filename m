From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] netlabel: Compiler warning and NULL pointer dereference fix
Date: Thu, 11 Dec 2008 13:43:12 -0500
Message-ID: <20081211184312.30832.25526.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, geert.uytterhoeven@sonycom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:46950 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbYLKSnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 13:43:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the two compiler warnings show below.  Thanks to Geert Uytterhoeven for
finding and reporting the problem.

 net/netlabel/netlabel_unlabeled.c:567: warning: 'entry' may be used
   uninitialized in this function
 net/netlabel/netlabel_unlabeled.c:629: warning: 'entry' may be used
   uninitialized in this function

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_unlabeled.c |   38 +++++++++++++++++++------------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 90c8506..8c03080 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -562,7 +562,6 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 				      const struct in_addr *mask,
 				      struct netlbl_audit *audit_info)
 {
-	int ret_val = 0;
 	struct netlbl_af4list *list_entry;
 	struct netlbl_unlhsh_addr4 *entry;
 	struct audit_buffer *audit_buf;
@@ -577,7 +576,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 	if (list_entry != NULL)
 		entry = netlbl_unlhsh_addr4_entry(list_entry);
 	else
-		ret_val = -ENOENT;
+		entry = NULL;
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);
@@ -588,19 +587,21 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 					  addr->s_addr, mask->s_addr);
 		if (dev != NULL)
 			dev_put(dev);
-		if (entry && security_secid_to_secctx(entry->secid,
-						      &secctx,
-						      &secctx_len) == 0) {
+		if (entry != NULL &&
+		    security_secid_to_secctx(entry->secid,
+					     &secctx, &secctx_len) == 0) {
 			audit_log_format(audit_buf, " sec_obj=%s", secctx);
 			security_release_secctx(secctx, secctx_len);
 		}
-		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
+		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
 		audit_log_end(audit_buf);
 	}
 
-	if (ret_val == 0)
-		call_rcu(&entry->rcu, netlbl_unlhsh_free_addr4);
-	return ret_val;
+	if (entry == NULL)
+		return -ENOENT;
+
+	call_rcu(&entry->rcu, netlbl_unlhsh_free_addr4);
+	return 0;
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -624,7 +625,6 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 				      const struct in6_addr *mask,
 				      struct netlbl_audit *audit_info)
 {
-	int ret_val = 0;
 	struct netlbl_af6list *list_entry;
 	struct netlbl_unlhsh_addr6 *entry;
 	struct audit_buffer *audit_buf;
@@ -638,7 +638,7 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 	if (list_entry != NULL)
 		entry = netlbl_unlhsh_addr6_entry(list_entry);
 	else
-		ret_val = -ENOENT;
+		entry = NULL;
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);
@@ -649,19 +649,21 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 					  addr, mask);
 		if (dev != NULL)
 			dev_put(dev);
-		if (entry && security_secid_to_secctx(entry->secid,
-						      &secctx,
-						      &secctx_len) == 0) {
+		if (entry != NULL &&
+		    security_secid_to_secctx(entry->secid,
+					     &secctx, &secctx_len) == 0) {
 			audit_log_format(audit_buf, " sec_obj=%s", secctx);
 			security_release_secctx(secctx, secctx_len);
 		}
-		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
+		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
 		audit_log_end(audit_buf);
 	}
 
-	if (ret_val == 0)
-		call_rcu(&entry->rcu, netlbl_unlhsh_free_addr6);
-	return ret_val;
+	if (entry == NULL)
+		return -ENOENT;
+
+	call_rcu(&entry->rcu, netlbl_unlhsh_free_addr6);
+	return 0;
 }
 #endif /* IPv6 */
 

