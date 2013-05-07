From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 40/48] Audit: ima: translate audit_log_start to
	audit_log_start_ns
Date: Tue, 7 May 2013 10:21:01 +0800
Message-ID: <1367893269-9308-41-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now we can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/integrity/ima/ima_api.c    |  7 ++++---
 security/integrity/ima/ima_audit.c  | 11 +++++++----
 security/integrity/ima/ima_policy.c |  5 +++--
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/security/integrity/ima/ima_api.c b/security/integrity/ima/ima_api.c
index 1c03e8f1..a94b54e 100644
--- a/security/integrity/ima/ima_api.c
+++ b/security/integrity/ima/ima_api.c
@@ -213,6 +213,7 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 {
 	struct audit_buffer *ab;
 	char hash[(IMA_DIGEST_SIZE * 2) + 1];
+	struct user_namespace *ns = current_user_ns();
 	int i;
 
 	if (iint->flags & IMA_AUDITED)
@@ -222,8 +223,8 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 		hex_byte_pack(hash + (i * 2), iint->ima_xattr.digest[i]);
 	hash[i * 2] = '\0';
 
-	ab = audit_log_start(current->audit_context, GFP_KERNEL,
-			     AUDIT_INTEGRITY_RULE);
+	ab = audit_log_start_ns(ns, current->audit_context, GFP_KERNEL,
+				AUDIT_INTEGRITY_RULE);
 	if (!ab)
 		return;
 
@@ -233,7 +234,7 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 	audit_log_untrustedstring(ab, hash);
 
 	audit_log_task_info(ab, current);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 
 	iint->flags |= IMA_AUDITED;
 }
diff --git a/security/integrity/ima/ima_audit.c b/security/integrity/ima/ima_audit.c
index c586faa..e7a205b 100644
--- a/security/integrity/ima/ima_audit.c
+++ b/security/integrity/ima/ima_audit.c
@@ -33,15 +33,18 @@ void integrity_audit_msg(int audit_msgno, struct inode *inode,
 			 const char *cause, int result, int audit_info)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns;
 
 	if (!ima_audit && audit_info == 1) /* Skip informational messages */
 		return;
 
-	ab = audit_log_start(current->audit_context, GFP_KERNEL, audit_msgno);
+	ns = current_user_ns();
+	ab = audit_log_start_ns(ns, current->audit_context,
+				GFP_KERNEL, audit_msgno);
 	audit_log_format(ab, "pid=%d uid=%u auid=%u ses=%u",
 			 current->pid,
-			 from_kuid(&init_user_ns, current_cred()->uid),
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+			 from_kuid(ns, current_cred()->uid),
+			 from_kuid(ns, audit_get_loginuid(current)),
 			 audit_get_sessionid(current));
 	audit_log_task_context(ab);
 	audit_log_format(ab, " op=");
@@ -60,5 +63,5 @@ void integrity_audit_msg(int audit_msgno, struct inode *inode,
 		audit_log_format(ab, " ino=%lu", inode->i_ino);
 	}
 	audit_log_format(ab, " res=%d", !result);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 399433a..c817d35 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -414,8 +414,9 @@ static int ima_parse_rule(char *rule, struct ima_rule_entry *entry)
 	struct audit_buffer *ab;
 	char *p;
 	int result = 0;
+	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_INTEGRITY_RULE);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_INTEGRITY_RULE);
 
 	entry->uid = INVALID_UID;
 	entry->fowner = INVALID_UID;
@@ -633,7 +634,7 @@ static int ima_parse_rule(char *rule, struct ima_rule_entry *entry)
 	else if (entry->func == MODULE_CHECK)
 		ima_appraise |= IMA_APPRAISE_MODULES;
 	audit_log_format(ab, "res=%d", !result);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 	return result;
 }
 
-- 
1.8.1.4
