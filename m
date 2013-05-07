From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 37/48] Audit: translate audit_log_start to
	audit_log_start_ns
Date: Tue, 7 May 2013 10:20:58 +0800
Message-ID: <1367893269-9308-38-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch translates the call of interface audit_log_start to
the namespace aware interface audit_log_start_ns.

After we finish translation, we can rename audit_log_start_ns
to audit_log_start.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index f723fe2..926d59b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1489,9 +1489,10 @@ void audit_log_key(struct audit_buffer *ab, char *key)
 void audit_log_link_denied(const char *operation, struct path *link)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start(current->audit_context, GFP_KERNEL,
-			     AUDIT_ANOM_LINK);
+	ab = audit_log_start_ns(ns, current->audit_context, GFP_KERNEL,
+				AUDIT_ANOM_LINK);
 	if (!ab)
 		return;
 	audit_log_format(ab, "op=%s action=denied", operation);
@@ -1501,7 +1502,7 @@ void audit_log_link_denied(const char *operation, struct path *link)
 	audit_log_format(ab, " dev=");
 	audit_log_untrustedstring(ab, link->dentry->d_inode->i_sb->s_id);
 	audit_log_format(ab, " ino=%lu", link->dentry->d_inode->i_ino);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
 void audit_log_end_ns(struct user_namespace *ns, struct audit_buffer *ab)
@@ -1558,12 +1559,12 @@ void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	struct audit_buffer *ab;
 	va_list args;
 
-	ab = audit_log_start(ctx, gfp_mask, type);
+	ab = audit_log_start_ns(&init_user_ns, ctx, gfp_mask, type);
 	if (ab) {
 		va_start(args, fmt);
 		audit_log_vformat(ab, fmt, args);
 		va_end(args);
-		audit_log_end(ab);
+		audit_log_end_ns(&init_user_ns, ab);
 	}
 }
 
-- 
1.8.1.4
