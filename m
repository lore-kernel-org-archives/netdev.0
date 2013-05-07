From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 05/48] Audit: make audit_skb_hold_queue per user namespace
Date: Tue, 7 May 2013 10:20:26 +0800
Message-ID: <1367893269-9308-6-git-send-email-gaofeng@cn.fujitsu.com>
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

After this patch, ervery user namespace has one
audit_skb_hold_queue. Since we havn't finish the
preparations, only allow user to operate the skb
hold queue of init user namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 | 16 +++++++++-------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index e322f20..53420a4 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -22,6 +22,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 struct audit_ctrl {
 	struct sock		*sock;
 	struct sk_buff_head	queue;
+	struct sk_buff_head	hold_queue;
 };
 #endif
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 2a727af..61562c5 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -129,8 +129,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-/* queue of skbs to send to auditd when/if it comes back */
-static struct sk_buff_head audit_skb_hold_queue;
 static struct task_struct *kauditd_task;
 static DECLARE_WAIT_QUEUE_HEAD(kauditd_wait);
 static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
@@ -370,9 +368,11 @@ static int audit_set_failure(int state, kuid_t loginuid, u32 sessionid, u32 sid)
  */
 static void audit_hold_skb(struct sk_buff *skb)
 {
+	struct sk_buff_head *list = &init_user_ns.audit.hold_queue;
+
 	if (audit_default &&
-	    skb_queue_len(&audit_skb_hold_queue) < audit_backlog_limit)
-		skb_queue_tail(&audit_skb_hold_queue, skb);
+	    skb_queue_len(list) < audit_backlog_limit)
+		skb_queue_tail(list, skb);
 	else
 		kfree_skb(skb);
 }
@@ -419,6 +419,7 @@ static int kauditd_thread(void *dummy)
 {
 	struct sk_buff *skb;
 	struct sk_buff_head *queue = &init_user_ns.audit.queue;
+	struct sk_buff_head *hold_queue = &init_user_ns.audit.hold_queue;
 
 	set_freezable();
 	while (!kthread_should_stop()) {
@@ -436,11 +437,11 @@ static int kauditd_thread(void *dummy)
 		 * note and still have no friggin idea what i'm thinking today.
 		 */
 		if (audit_default && audit_pid) {
-			skb = skb_dequeue(&audit_skb_hold_queue);
+			skb = skb_dequeue(hold_queue);
 			if (unlikely(skb)) {
 				while (skb && audit_pid) {
 					kauditd_send_skb(skb);
-					skb = skb_dequeue(&audit_skb_hold_queue);
+					skb = skb_dequeue(hold_queue);
 				}
 			}
 		}
@@ -998,7 +999,6 @@ static int __init audit_init(void)
 		return -1;
 
 	audit_set_user_ns(&init_user_ns);
-	skb_queue_head_init(&audit_skb_hold_queue);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
 	audit_ever_enabled |= !!audit_default;
@@ -1599,6 +1599,7 @@ void audit_set_user_ns(struct user_namespace *ns)
 		return;
 
 	skb_queue_head_init(&ns->audit.queue);
+	skb_queue_head_init(&ns->audit.hold_queue);
 }
 
 void audit_free_user_ns(struct user_namespace *ns)
@@ -1613,6 +1614,7 @@ void audit_free_user_ns(struct user_namespace *ns)
 	}
 
 	skb_queue_purge(&ns->audit.queue);
+	skb_queue_purge(&ns->audit.hold_queue);
 }
 
 EXPORT_SYMBOL(audit_log_start);
-- 
1.8.1.4
