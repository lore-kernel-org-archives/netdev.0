From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 15/48] Audit: allow to send netlink message to auditd in uninit user namespace
Date: Tue, 7 May 2013 10:20:36 +0800
Message-ID: <1367893269-9308-16-git-send-email-gaofeng@cn.fujitsu.com>
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

We can allow audit kernel side netlink sock of uninit
user namespace to send message to the right auditd.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 kernel/audit.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 18cf5ce..d39296b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -361,9 +361,9 @@ static int audit_set_failure(int state, kuid_t loginuid, u32 sessionid, u32 sid)
  * This only holds messages is audit_default is set, aka booting with audit=1
  * or building your kernel that way.
  */
-static void audit_hold_skb(struct sk_buff *skb)
+static void audit_hold_skb(struct user_namespace *ns, struct sk_buff *skb)
 {
-	struct sk_buff_head *list = &init_user_ns.audit.hold_queue;
+	struct sk_buff_head *list = &ns->audit.hold_queue;
 
 	if (audit_default &&
 	    skb_queue_len(list) < audit_backlog_limit)
@@ -376,7 +376,7 @@ static void audit_hold_skb(struct sk_buff *skb)
  * For one reason or another this nlh isn't getting delivered to the userspace
  * audit daemon, just send it to printk.
  */
-static void audit_printk_skb(struct sk_buff *skb)
+static void audit_printk_skb(struct user_namespace *ns, struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 	char *data = nlmsg_data(nlh);
@@ -388,24 +388,24 @@ static void audit_printk_skb(struct sk_buff *skb)
 			audit_log_lost("printk limit exceeded\n");
 	}
 
-	audit_hold_skb(skb);
+	audit_hold_skb(ns, skb);
 }
 
-static void kauditd_send_skb(struct sk_buff *skb)
+static void kauditd_send_skb(struct user_namespace *ns, struct sk_buff *skb)
 {
 	int err;
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(init_user_ns.audit.sock, skb,
-			      init_user_ns.audit.portid, 0);
+	err = netlink_unicast(ns->audit.sock, skb,
+			      ns->audit.portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
 		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n",
-		       init_user_ns.audit.pid);
+		       ns->audit.pid);
 		audit_log_lost("auditd disappeared\n");
-		init_user_ns.audit.pid = 0;
+		ns->audit.pid = 0;
 		/* we might get lucky and get this in the next auditd */
-		audit_hold_skb(skb);
+		audit_hold_skb(ns, skb);
 	} else
 		/* drop the extra reference if sent ok */
 		consume_skb(skb);
@@ -437,7 +437,7 @@ static int kauditd_thread(void *dummy)
 			skb = skb_dequeue(hold_queue);
 			if (unlikely(skb)) {
 				while (skb && ns->audit.pid) {
-					kauditd_send_skb(skb);
+					kauditd_send_skb(ns, skb);
 					skb = skb_dequeue(hold_queue);
 				}
 			}
@@ -447,9 +447,9 @@ static int kauditd_thread(void *dummy)
 		wake_up(&audit_backlog_wait);
 		if (skb) {
 			if (ns->audit.pid)
-				kauditd_send_skb(skb);
+				kauditd_send_skb(ns, skb);
 			else
-				audit_printk_skb(skb);
+				audit_printk_skb(ns, skb);
 		} else {
 			DECLARE_WAITQUEUE(wait, current);
 			set_current_state(TASK_INTERRUPTIBLE);
@@ -1529,7 +1529,7 @@ void audit_log_end(struct audit_buffer *ab)
 				       ab->skb);
 			wake_up_interruptible(&kauditd_wait);
 		} else {
-			audit_printk_skb(ab->skb);
+			audit_printk_skb(&init_user_ns, ab->skb);
 		}
 		ab->skb = NULL;
 	}
-- 
1.8.1.4
