From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 17/48] Audit: make kauditd_wait per user namespace
Date: Tue, 7 May 2013 10:20:38 +0800
Message-ID: <1367893269-9308-18-git-send-email-gaofeng@cn.fujitsu.com>
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

kauditd_task is added to the wait queue kaudit_wait when
there is no audit message being generated in user namespace,
so the kaudit_wait should be per user namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h | 1 +
 kernel/audit.c                 | 8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index c7b5bf7..7c2c65c 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -28,6 +28,7 @@ struct audit_ctrl {
 	struct sk_buff_head	queue;
 	struct sk_buff_head	hold_queue;
 	struct task_struct	*kauditd_task;
+	wait_queue_head_t	kauditd_wait;
 	bool			ever_enabled;
 };
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index f5e106f..ad03f4f 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -117,7 +117,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static DECLARE_WAIT_QUEUE_HEAD(kauditd_wait);
 static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
 
 /* Serialize requests from userspace. */
@@ -454,7 +453,7 @@ static int kauditd_thread(void *dummy)
 		} else {
 			DECLARE_WAITQUEUE(wait, current);
 			set_current_state(TASK_INTERRUPTIBLE);
-			add_wait_queue(&kauditd_wait, &wait);
+			add_wait_queue(&ns->audit.kauditd_wait, &wait);
 
 			if (!skb_queue_len(queue)) {
 				try_to_freeze();
@@ -462,7 +461,7 @@ static int kauditd_thread(void *dummy)
 			}
 
 			__set_current_state(TASK_RUNNING);
-			remove_wait_queue(&kauditd_wait, &wait);
+			remove_wait_queue(&ns->audit.kauditd_wait, &wait);
 		}
 	}
 	return 0;
@@ -1528,7 +1527,7 @@ void audit_log_end(struct audit_buffer *ab)
 		if (init_user_ns.audit.pid) {
 			skb_queue_tail(&init_user_ns.audit.queue,
 				       ab->skb);
-			wake_up_interruptible(&kauditd_wait);
+			wake_up_interruptible(&init_user_ns.audit.kauditd_wait);
 		} else {
 			audit_printk_skb(&init_user_ns, ab->skb);
 		}
@@ -1599,6 +1598,7 @@ void audit_set_user_ns(struct user_namespace *ns)
 	skb_queue_head_init(&ns->audit.hold_queue);
 	ns->audit.enabled = audit_default;
 	ns->audit.ever_enabled |= !!audit_default;
+	init_waitqueue_head(&ns->audit.kauditd_wait);
 
 	ns->audit.initialized = AUDIT_INITIALIZED;
 }
-- 
1.8.1.4
