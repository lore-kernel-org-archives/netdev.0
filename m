From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 23/48] Audit: netfilter: Log xt table replace behavior in
	proper user namespace
Date: Tue, 7 May 2013 10:20:44 +0800
Message-ID: <1367893269-9308-24-git-send-email-gaofeng@cn.fujitsu.com>
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

Log the audit message in the user namespace which
current task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/netfilter/x_tables.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8b03028..ba90a1b 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -824,6 +824,7 @@ xt_replace_table(struct xt_table *table,
 	      int *error)
 {
 	struct xt_table_info *private;
+	struct user_namespace *ns = current_user_ns();
 	int ret;
 
 	ret = xt_jumpstack_alloc(newinfo);
@@ -857,16 +858,16 @@ xt_replace_table(struct xt_table *table,
 	local_bh_enable();
 
 #ifdef CONFIG_AUDIT
-	if (audit_enabled) {
+	if (audit_enabled_ns(ns)) {
 		struct audit_buffer *ab;
 
-		ab = audit_log_start(current->audit_context, GFP_KERNEL,
-				     AUDIT_NETFILTER_CFG);
+		ab = audit_log_start_ns(ns, current->audit_context,
+					GFP_KERNEL, AUDIT_NETFILTER_CFG);
 		if (ab) {
 			audit_log_format(ab, "table=%s family=%u entries=%u",
 					 table->name, table->af,
 					 private->number);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 		}
 	}
 #endif
-- 
1.8.1.4
