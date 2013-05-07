From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 01/48] Audit: make audit kernel side netlink sock per
	userns
Date: Tue, 7 May 2013 10:20:22 +0800
Message-ID: <1367893269-9308-2-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch try to make the audit_sock per user namespace,
not global.

Since sock is assigned to net namespace, when creating
a netns, we will allocate a audit_sock for the userns
which create this netns, and this netns will keep alive
until the creator userns being destroyed.

If userns create many netns, the audit_sock is only
allocated once.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h          |  5 +++
 include/linux/user_namespace.h |  9 ++++++
 kernel/audit.c                 | 73 ++++++++++++++++++++++++++++++++++--------
 kernel/user_namespace.c        |  2 ++
 4 files changed, 75 insertions(+), 14 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 5a6d718..690d7d8 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -429,6 +429,8 @@ static inline void	    audit_log_secctx(struct audit_buffer *ab, u32 secid)
 { }
 #endif
 
+extern void		    audit_free_user_ns(struct user_namespace *ns);
+
 extern int		    audit_update_lsm_rules(void);
 
 				/* Private API (for audit.c only) */
@@ -476,6 +478,9 @@ static inline void audit_log_link_denied(const char *string,
 { }
 static inline void audit_log_secctx(struct audit_buffer *ab, u32 secid)
 { }
+
+static inline void audit_free_user_ns(struct user_namespace *ns)
+{ }
 #define audit_enabled 0
 #endif /* CONFIG_AUDIT */
 static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b6b215f..8797421 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -17,6 +17,12 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 	} extent[UID_GID_MAP_MAX_EXTENTS];
 };
 
+#ifdef CONFIG_AUDIT
+struct audit_ctrl {
+	struct sock		*sock;
+};
+#endif
+
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -26,6 +32,9 @@ struct user_namespace {
 	kuid_t			owner;
 	kgid_t			group;
 	unsigned int		proc_inum;
+#ifdef CONFIG_AUDIT
+	struct audit_ctrl	audit;
+#endif
 	bool			may_mount_sysfs;
 	bool			may_mount_proc;
 };
diff --git a/kernel/audit.c b/kernel/audit.c
index 0b084fa..766dcbf 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -62,6 +62,7 @@
 #include <linux/freezer.h>
 #include <linux/tty.h>
 #include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 
 #include "audit.h"
 
@@ -118,9 +119,6 @@ u32		audit_sig_sid = 0;
 */
 static atomic_t    audit_lost = ATOMIC_INIT(0);
 
-/* The netlink socket. */
-static struct sock *audit_sock;
-
 /* Hash for inode-based rules */
 struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
 
@@ -404,7 +402,8 @@ static void kauditd_send_skb(struct sk_buff *skb)
 	int err;
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
+	err = netlink_unicast(init_user_ns.audit.sock, skb,
+			      audit_nlk_portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
 		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
@@ -481,7 +480,7 @@ int audit_send_list(void *_dest)
 	mutex_unlock(&audit_cmd_mutex);
 
 	while ((skb = __skb_dequeue(&dest->q)) != NULL)
-		netlink_unicast(audit_sock, skb, pid, 0);
+		netlink_unicast(init_user_ns.audit.sock, skb, pid, 0);
 
 	kfree(dest);
 
@@ -522,7 +521,8 @@ static int audit_send_reply_thread(void *arg)
 
 	/* Ignore failure. It'll only happen if the sender goes away,
 	   because our timeout is set to infinite. */
-	netlink_unicast(audit_sock, reply->skb, reply->pid, 0);
+	netlink_unicast(init_user_ns.audit.sock, reply->skb,
+			reply->pid, 0);
 	kfree(reply);
 	return 0;
 }
@@ -937,24 +937,56 @@ static void audit_receive(struct sk_buff  *skb)
 	mutex_unlock(&audit_cmd_mutex);
 }
 
+static int __net_init audit_net_init(struct net *net)
+{
+	struct user_namespace *ns = net->user_ns;
+
+	if (!ns->audit.sock) {
+		struct sock *sk = NULL;
+		/*
+		 * create kernel side netlink socket for audit,
+		 * make audit sock per user namespace.
+		 */
+		struct netlink_kernel_cfg cfg = {
+			.input	= audit_receive,
+		};
+
+		sk = netlink_kernel_create(net, NETLINK_AUDIT, &cfg);
+		if (!sk) {
+			if (net_eq(net, &init_net))
+				audit_panic("cannot initialize netlink socket");
+			return -1;
+		}
+		sk->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
+		ns->audit.sock = sk;
+		/*
+		 * Get reference of net->passive, this force this netns
+		 * to be alive, it will be destroyed when we destroy the
+		 * userns.
+		 */
+		atomic_inc(&net->passive);
+	}
+
+	return 0;
+}
+
+static struct pernet_operations audit_net_ops = {
+	.init = audit_net_init,
+};
+
 /* Initialize audit support at boot time. */
 static int __init audit_init(void)
 {
 	int i;
-	struct netlink_kernel_cfg cfg = {
-		.input	= audit_receive,
-	};
 
 	if (audit_initialized == AUDIT_DISABLED)
 		return 0;
 
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, &cfg);
-	if (!audit_sock)
-		audit_panic("cannot initialize netlink socket");
-	else
-		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
+
+	if (register_pernet_subsys(&audit_net_ops) < 0)
+		return -1;
 
 	skb_queue_head_init(&audit_skb_queue);
 	skb_queue_head_init(&audit_skb_hold_queue);
@@ -1549,7 +1581,20 @@ void audit_log_secctx(struct audit_buffer *ab, u32 secid)
 EXPORT_SYMBOL(audit_log_secctx);
 #endif
 
+void audit_free_user_ns(struct user_namespace *ns)
+{
+	if (audit_initialized == AUDIT_DISABLED)
+		return;
+
+	if (ns->audit.sock) {
+		struct net *net = sock_net(ns->audit.sock);
+		netlink_kernel_release(ns->audit.sock);
+		net_drop_ns(net);
+	}
+}
+
 EXPORT_SYMBOL(audit_log_start);
 EXPORT_SYMBOL(audit_log_end);
 EXPORT_SYMBOL(audit_log_format);
 EXPORT_SYMBOL(audit_log);
+EXPORT_SYMBOL(audit_free_user_ns);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index d8c30db..99de920 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -22,6 +22,7 @@
 #include <linux/ctype.h>
 #include <linux/projid.h>
 #include <linux/fs_struct.h>
+#include <linux/audit.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 
@@ -124,6 +125,7 @@ void free_user_ns(struct user_namespace *ns)
 	do {
 		parent = ns->parent;
 		proc_free_inum(ns->proc_inum);
+		audit_free_user_ns(ns);
 		kmem_cache_free(user_ns_cachep, ns);
 		ns = parent;
 	} while (atomic_dec_and_test(&parent->count));
-- 
1.8.1.4
