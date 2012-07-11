From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 2/5] cgroup: Do not add sock_update_classid() when CONFIG_NET_CLS_CGROUP=0
Date: Wed, 11 Jul 2012 11:35:38 +0200
Message-ID: <1341999341-1808-3-git-send-email-wagi@monom.org>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1341999341-1808-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

With the configuration CONFIG_CGROUPS=y and CONFIG_NET_CLS_CGROUP=0
sock_update_classid() was still added and introduced unnecessary load.

Also remove cls cgroup related definition form sock.h. The only user
is socket.h which includes cls_cgroup.h direclty.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/cls_cgroup.h | 33 +++++++++++++++++++++++----------
 include/net/sock.h       |  8 --------
 net/core/sock.c          |  4 +++-
 3 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..d2a8cfa 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -17,14 +17,29 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+
 struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
 	u32 classid;
 };
 
-#ifdef CONFIG_NET_CLS_CGROUP
+extern void sock_update_classid(struct sock *sk);
+
+#else
+
+#define sock_update_classid(sk)
+
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	return 0;
+}
+
+#endif
+
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
@@ -39,7 +54,9 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#else
+
+#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -60,11 +77,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#endif
-#else
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	return 0;
-}
-#endif
+
+#endif /* CONFIG_NET_CLS_GROUP */
+
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index dcb54a0..6282230 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1451,14 +1451,6 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
-#ifdef CONFIG_CGROUPS
-extern void sock_update_classid(struct sock *sk);
-#else
-static inline void sock_update_classid(struct sock *sk)
-{
-}
-#endif
-
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
diff --git a/net/core/sock.c b/net/core/sock.c
index bbab10d..52c4a2a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -272,7 +272,7 @@ int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
 #if defined(CONFIG_CGROUPS)
-#if !defined(CONFIG_NET_CLS_CGROUP)
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
@@ -1168,6 +1168,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
@@ -1179,6 +1180,7 @@ void sock_update_classid(struct sock *sk)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+#endif
 
 void sock_update_netprioidx(struct sock *sk)
 {
-- 
1.7.11.1.165.g299666c
