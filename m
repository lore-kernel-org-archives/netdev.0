From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 36/48] Audit: Log watch related audit message to proper
	user namespace
Date: Tue, 7 May 2013 10:20:57 +0800
Message-ID: <1367893269-9308-37-git-send-email-gaofeng@cn.fujitsu.com>
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

Now, we can log watch related audit message to the user namespace
which the task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit_watch.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 6be4cbe..1bac505 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -235,22 +235,26 @@ out:
 	return new;
 }
 
-static void audit_watch_log_rule_change(struct audit_krule *r, struct audit_watch *w, char *op)
+static void audit_watch_log_rule_change(struct audit_krule *r,
+					struct audit_watch *w, char *op)
 {
-	if (audit_enabled) {
+	struct user_namespace *ns = current_user_ns();
+
+	if (audit_enabled_ns(ns)) {
 		struct audit_buffer *ab;
-		ab = audit_log_start(NULL, GFP_NOFS, AUDIT_CONFIG_CHANGE);
+		ab = audit_log_start_ns(ns, NULL, GFP_NOFS,
+					AUDIT_CONFIG_CHANGE);
 		if (unlikely(!ab))
 			return;
 		audit_log_format(ab, "auid=%u ses=%u op=",
-				 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+				 from_kuid(ns, audit_get_loginuid(current)),
 				 audit_get_sessionid(current));
 		audit_log_string(ab, op);
 		audit_log_format(ab, " path=");
 		audit_log_untrustedstring(ab, w->path);
 		audit_log_key(ab, r->filterkey);
 		audit_log_format(ab, " list=%d res=1", r->listnr);
-		audit_log_end(ab);
+		audit_log_end_ns(ns, ab);
 	}
 }
 
@@ -262,6 +266,7 @@ static void audit_update_watch(struct audit_parent *parent,
 	struct audit_watch *owatch, *nwatch, *nextw;
 	struct audit_krule *r, *nextr;
 	struct audit_entry *oentry, *nentry;
+	struct user_namespace *ns = current_user_ns();
 
 	mutex_lock(&audit_filter_mutex);
 	/* Run all of the watches on this parent looking for the one that
@@ -274,7 +279,7 @@ static void audit_update_watch(struct audit_parent *parent,
 		/* If the update involves invalidating rules, do the inode-based
 		 * filtering now, so we don't omit records. */
 		if (invalidating && !audit_dummy_context())
-			audit_filter_inodes(current_user_ns(), current,
+			audit_filter_inodes(ns, current,
 					    current->audit_context);
 
 		/* updating ino will likely change which audit_hash_list we
@@ -311,7 +316,7 @@ static void audit_update_watch(struct audit_parent *parent,
 				nentry->rule.watch = nwatch;
 				list_add(&nentry->rule.rlist, &nwatch->rules);
 				list_add_rcu(&nentry->list,
-					&init_user_ns.audit.inode_hash[h]);
+					&ns->audit.inode_hash[h]);
 				list_replace(&oentry->rule.list,
 					     &nentry->rule.list);
 			}
-- 
1.8.1.4
