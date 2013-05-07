From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 42/48] Audit: selinux: translate audit_log_start to audit_log_start_ns
Date: Tue, 7 May 2013 10:21:03 +0800
Message-ID: <1367893269-9308-43-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 security/selinux/hooks.c       | 14 ++++++++++----
 security/selinux/ss/services.c |  8 +++++---
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c6f2cd..93b6c72 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2785,6 +2785,7 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 			struct audit_buffer *ab;
 			size_t audit_size;
 			const char *str;
+			struct user_namespace *ns = current_user_ns();
 
 			/* We strip a nul only if it is at the end, otherwise the
 			 * context contains a nul and we should audit that */
@@ -2798,10 +2799,11 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 				str = "";
 				audit_size = 0;
 			}
-			ab = audit_log_start(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR);
+			ab = audit_log_start_ns(ns, current->audit_context,
+						GFP_ATOMIC, AUDIT_SELINUX_ERR);
 			audit_log_format(ab, "op=setxattr invalid_context=");
 			audit_log_n_untrustedstring(ab, value, audit_size);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 
 			return rc;
 		}
@@ -5328,6 +5330,7 @@ static int selinux_setprocattr(struct task_struct *p,
 			if (!capable(CAP_MAC_ADMIN)) {
 				struct audit_buffer *ab;
 				size_t audit_size;
+				struct user_namespace *ns = current_user_ns();
 
 				/* We strip a nul only if it is at the end, otherwise the
 				 * context contains a nul and we should audit that */
@@ -5335,10 +5338,13 @@ static int selinux_setprocattr(struct task_struct *p,
 					audit_size = size - 1;
 				else
 					audit_size = size;
-				ab = audit_log_start(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR);
+				ab = audit_log_start_ns(ns,
+							current->audit_context,
+							GFP_ATOMIC,
+							AUDIT_SELINUX_ERR);
 				audit_log_format(ab, "op=fscreate invalid_context=");
 				audit_log_n_untrustedstring(ab, value, audit_size);
-				audit_log_end(ab);
+				audit_log_end_ns(ns, ab);
 
 				return error;
 			}
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index b4feecc..140a383 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -473,6 +473,7 @@ static void security_dump_masked_av(struct context *scontext,
 	int index;
 	u32 length;
 	bool need_comma = false;
+	struct user_namespace *ns;
 
 	if (!permissions)
 		return;
@@ -501,8 +502,9 @@ static void security_dump_masked_av(struct context *scontext,
 		goto out;
 
 	/* audit a message */
-	ab = audit_log_start(current->audit_context,
-			     GFP_ATOMIC, AUDIT_SELINUX_ERR);
+	ns = current_user_ns();
+	ab = audit_log_start_ns(ns, current->audit_context,
+				GFP_ATOMIC, AUDIT_SELINUX_ERR);
 	if (!ab)
 		goto out;
 
@@ -522,7 +524,7 @@ static void security_dump_masked_av(struct context *scontext,
 				 ? permission_names[index] : "????");
 		need_comma = true;
 	}
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 out:
 	/* release scontext/tcontext */
 	kfree(tcontext_name);
-- 
1.8.1.4
