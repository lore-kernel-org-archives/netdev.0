From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/8] net: wrap sock->sk_cgrp_prioidx and ->sk_classid inside a struct
Date: Mon,  7 Dec 2015 17:38:52 -0500
Message-ID: <1449527935-27056-6-git-send-email-tj@kernel.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com, Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35947 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933210AbbLGWjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 17:39:15 -0500
In-Reply-To: <1449527935-27056-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce sock->sk_cgrp_data which is a struct sock_cgroup_data.
->sk_cgroup_prioidx and ->sk_classid are moved into it.  The struct
and its accessors are defined in cgroup-defs.h.  This is to prepare
for overloading the fields with a cgroup pointer.

This patch mostly performs equivalent conversions but the followings
are noteworthy.

* Equality test before updating classid is removed from
  sock_update_classid().  This shouldn't make any noticeable
  difference and a similar test will be implemented on the helper side
  later.

* sock_update_netprioidx() now takes struct sock_cgroup_data and can
  be moved to netprio_cgroup.h without causing include dependency
  loop.  Moved.

* The dummy version of sock_update_netprioidx() converted to a static
  inline function while at it.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup-defs.h  | 36 ++++++++++++++++++++++++++++++++++++
 include/net/cls_cgroup.h     | 11 +++++------
 include/net/netprio_cgroup.h | 16 +++++++++++++---
 include/net/sock.h           | 11 +++--------
 net/Kconfig                  |  6 ++++++
 net/core/dev.c               |  3 ++-
 net/core/netclassid_cgroup.c |  4 ++--
 net/core/netprio_cgroup.c    |  3 ++-
 net/core/scm.c               |  4 ++--
 net/core/sock.c              | 15 ++-------------
 net/netfilter/nft_meta.c     |  2 +-
 net/netfilter/xt_cgroup.c    |  3 ++-
 12 files changed, 76 insertions(+), 38 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 504d859..ed128fed 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -542,4 +542,40 @@ static inline void cgroup_threadgroup_change_end(struct task_struct *tsk) {}
 
 #endif	/* CONFIG_CGROUPS */
 
+#ifdef CONFIG_SOCK_CGROUP_DATA
+
+struct sock_cgroup_data {
+	u16	prioidx;
+	u32	classid;
+};
+
+static inline u16 sock_cgroup_prioidx(struct sock_cgroup_data *skcd)
+{
+	return skcd->prioidx;
+}
+
+static inline u32 sock_cgroup_classid(struct sock_cgroup_data *skcd)
+{
+	return skcd->classid;
+}
+
+static inline void sock_cgroup_set_prioidx(struct sock_cgroup_data *skcd,
+					   u16 prioidx)
+{
+	skcd->prioidx = prioidx;
+}
+
+static inline void sock_cgroup_set_classid(struct sock_cgroup_data *skcd,
+					   u32 classid)
+{
+	skcd->classid = classid;
+}
+
+#else	/* CONFIG_SOCK_CGROUP_DATA */
+
+struct sock_cgroup_data {
+};
+
+#endif	/* CONFIG_SOCK_CGROUP_DATA */
+
 #endif	/* _LINUX_CGROUP_DEFS_H */
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index ccd6d8b..c0a92e2 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -41,13 +41,12 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 
-static inline void sock_update_classid(struct sock *sk)
+static inline void sock_update_classid(struct sock_cgroup_data *skcd)
 {
 	u32 classid;
 
 	classid = task_cls_classid(current);
-	if (classid != sk->sk_classid)
-		sk->sk_classid = classid;
+	sock_cgroup_set_classid(skcd, classid);
 }
 
 static inline u32 task_get_classid(const struct sk_buff *skb)
@@ -64,17 +63,17 @@ static inline u32 task_get_classid(const struct sk_buff *skb)
 	 * softirqs always disables bh.
 	 */
 	if (in_serving_softirq()) {
-		/* If there is an sk_classid we'll use that. */
+		/* If there is an sock_cgroup_classid we'll use that. */
 		if (!skb->sk)
 			return 0;
 
-		classid = skb->sk->sk_classid;
+		classid = sock_cgroup_classid(&skb->sk->sk_cgrp_data);
 	}
 
 	return classid;
 }
 #else /* !CONFIG_CGROUP_NET_CLASSID */
-static inline void sock_update_classid(struct sock *sk)
+static inline void sock_update_classid(struct sock_cgroup_data *skcd)
 {
 }
 
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index f2a9597..6041905 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -25,8 +25,6 @@ struct netprio_map {
 	u32 priomap[];
 };
 
-void sock_update_netprioidx(struct sock *sk);
-
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_subsys_state *css;
@@ -38,13 +36,25 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	rcu_read_unlock();
 	return idx;
 }
+
+static inline void sock_update_netprioidx(struct sock_cgroup_data *skcd)
+{
+	if (in_interrupt())
+		return;
+
+	sock_cgroup_set_prioidx(skcd, task_netprioidx(current));
+}
+
 #else /* !CONFIG_CGROUP_NET_PRIO */
+
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	return 0;
 }
 
-#define sock_update_netprioidx(sk)
+static inline void sock_update_netprioidx(struct sock_cgroup_data *skcd)
+{
+}
 
 #endif /* CONFIG_CGROUP_NET_PRIO */
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index a95bcf7..0ca22b0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -59,6 +59,7 @@
 #include <linux/static_key.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
+#include <linux/cgroup-defs.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -308,8 +309,7 @@ struct cg_proto;
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
-  *	@sk_cgrp_prioidx: socket group's priority map index
-  *	@sk_classid: this socket's cgroup classid
+  *	@sk_cgrp_data: cgroup data for this cgroup
   *	@sk_cgrp: this socket's cgroup-specific proto data
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
@@ -443,12 +443,7 @@ struct sock {
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
 #endif
-#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
-	u16			sk_cgrp_prioidx;
-#endif
-#ifdef CONFIG_CGROUP_NET_CLASSID
-	u32			sk_classid;
-#endif
+	struct sock_cgroup_data	sk_cgrp_data;
 	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk);
diff --git a/net/Kconfig b/net/Kconfig
index 127da94..11f8c22 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -250,9 +250,14 @@ config XPS
 	depends on SMP
 	default y
 
+config SOCK_CGROUP_DATA
+	bool
+	default n
+
 config CGROUP_NET_PRIO
 	bool "Network priority cgroup"
 	depends on CGROUPS
+	select SOCK_CGROUP_DATA
 	---help---
 	  Cgroup subsystem for use in assigning processes to network priorities on
 	  a per-interface basis.
@@ -260,6 +265,7 @@ config CGROUP_NET_PRIO
 config CGROUP_NET_CLASSID
 	bool "Network classid cgroup"
 	depends on CGROUPS
+	select SOCK_CGROUP_DATA
 	---help---
 	  Cgroup subsystem for use as general purpose socket classid marker that is
 	  being used in cls_cgroup and for netfilter matching.
diff --git a/net/core/dev.c b/net/core/dev.c
index e5c3954..8f705fc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2929,7 +2929,8 @@ static void skb_update_prio(struct sk_buff *skb)
 	struct netprio_map *map = rcu_dereference_bh(skb->dev->priomap);
 
 	if (!skb->priority && skb->sk && map) {
-		unsigned int prioidx = skb->sk->sk_cgrp_prioidx;
+		unsigned int prioidx =
+			sock_cgroup_prioidx(&skb->sk->sk_cgrp_data);
 
 		if (prioidx < map->priomap_len)
 			skb->priority = map->priomap[prioidx];
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 2e4df84..e60ded4 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -62,8 +62,8 @@ static int update_classid_sock(const void *v, struct file *file, unsigned n)
 	struct socket *sock = sock_from_file(file, &err);
 
 	if (sock)
-		sock->sk->sk_classid = (u32)(unsigned long)v;
-
+		sock_cgroup_set_classid(&sock->sk->sk_cgrp_data,
+					(unsigned long)v);
 	return 0;
 }
 
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 2b9159b..de42aa7 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -223,7 +223,8 @@ static int update_netprio(const void *v, struct file *file, unsigned n)
 	int err;
 	struct socket *sock = sock_from_file(file, &err);
 	if (sock)
-		sock->sk->sk_cgrp_prioidx = (u32)(unsigned long)v;
+		sock_cgroup_set_prioidx(&sock->sk->sk_cgrp_data,
+					(unsigned long)v);
 	return 0;
 }
 
diff --git a/net/core/scm.c b/net/core/scm.c
index 8a1741b..14596fb 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -289,8 +289,8 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		/* Bump the usage count and install the file. */
 		sock = sock_from_file(fp[i], &err);
 		if (sock) {
-			sock_update_netprioidx(sock->sk);
-			sock_update_classid(sock->sk);
+			sock_update_netprioidx(&sock->sk->sk_cgrp_data);
+			sock_update_classid(&sock->sk->sk_cgrp_data);
 		}
 		fd_install(new_fd, get_file(fp[i]));
 	}
diff --git a/net/core/sock.c b/net/core/sock.c
index 7965ef4..947741d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1393,17 +1393,6 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	module_put(owner);
 }
 
-#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
-void sock_update_netprioidx(struct sock *sk)
-{
-	if (in_interrupt())
-		return;
-
-	sk->sk_cgrp_prioidx = task_netprioidx(current);
-}
-EXPORT_SYMBOL_GPL(sock_update_netprioidx);
-#endif
-
 /**
  *	sk_alloc - All socket objects are allocated here
  *	@net: the applicable net namespace
@@ -1432,8 +1421,8 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, net);
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		sock_update_classid(sk);
-		sock_update_netprioidx(sk);
+		sock_update_classid(&sk->sk_cgrp_data);
+		sock_update_netprioidx(&sk->sk_cgrp_data);
 	}
 
 	return sk;
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 9dfaf4d..1915cab 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -174,7 +174,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		sk = skb_to_full_sk(skb);
 		if (!sk || !sk_fullsock(sk))
 			goto err;
-		*dest = sk->sk_classid;
+		*dest = sock_cgroup_classid(&sk->sk_cgrp_data);
 		break;
 #endif
 	default:
diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index a1d126f..54eaeb4 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -42,7 +42,8 @@ cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (skb->sk == NULL || !sk_fullsock(skb->sk))
 		return false;
 
-	return (info->id == skb->sk->sk_classid) ^ info->invert;
+	return (info->id == sock_cgroup_classid(&skb->sk->sk_cgrp_data)) ^
+		info->invert;
 }
 
 static struct xt_match cgroup_mt_reg __read_mostly = {
-- 
2.5.0
