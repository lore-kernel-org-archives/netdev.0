From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 5/6] cls_cgroup: use IS_ENABLED() and family
Date: Wed, 01 Feb 2012 14:56:28 +0800
Message-ID: <4F28E21C.9020406@cn.fujitsu.com>
References: <4F28E1D1.900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F28E1D1.900-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

- remove net_cls_subsys_id when CGROUPS=y && !NET_CLS_CGRUOP
- remove sock->classid when !NET_CLS_CGROUP
- don't use "ifndef CONFIG_NET_CLS_CGROUP" to sugguest it's
a module, use IS_MODULE().

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/cls_cgroup.h |   12 ++++--------
 include/net/sock.h       |    4 +++-
 net/core/sock.c          |    6 ++----
 net/sched/cls_cgroup.c   |    6 +++---
 4 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..806b9a1 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -17,14 +17,14 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
 	u32 classid;
 };
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
@@ -39,7 +39,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#else
+#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -61,10 +61,6 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 #endif
-#else
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	return 0;
-}
+
 #endif
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index b08a44e..7b80d55 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -362,7 +362,9 @@ struct sock {
 	void			*sk_security;
 #endif
 	__u32			sk_mark;
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 	u32			sk_classid;
+#endif
 	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
@@ -1382,7 +1384,7 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 extern void sock_update_classid(struct sock *sk);
 #else
 static inline void sock_update_classid(struct sock *sk)
diff --git a/net/core/sock.c b/net/core/sock.c
index 76df203..213c856 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -267,12 +267,10 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
-#if defined(CONFIG_CGROUPS)
-#if !defined(CONFIG_NET_CLS_CGROUP)
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
-#endif
 
 #if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 int net_prio_subsys_id = -1;
@@ -1157,7 +1155,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	module_put(owner);
 }
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f84fdc3..f57245c 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -32,7 +32,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.populate	= cgrp_populate,
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 	.subsys_id	= net_cls_subsys_id,
 #endif
 	.module		= THIS_MODULE,
@@ -294,7 +294,7 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		goto out;
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	/* We can't use rcu_assign_pointer because this is an int. */
 	smp_wmb();
 	net_cls_subsys_id = net_cls_subsys.subsys_id;
@@ -312,7 +312,7 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	net_cls_subsys_id = -1;
 	synchronize_rcu();
 #endif
-- 
1.7.3.1
