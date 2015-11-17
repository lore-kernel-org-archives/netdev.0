From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/5] sock, cgroup: add sock->sk_cgroup
Date: Tue, 17 Nov 2015 14:40:39 -0500
Message-ID: <1447789240-29394-5-git-send-email-tj@kernel.org>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447789240-29394-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In cgroup v1, dealing with cgroup membership was difficult because the
number of membership associations was unbound.  As a result, cgroup v1
grew several controllers whose primary purpose is either tagging
membership or pull in configuration knobs from other subsystems so
that cgroup membership test can be avoided.

net_cls and net_prio controllers are examples of the latter.  They
allow configuring network-specific attributes from cgroup side so that
network subsystem can avoid testing cgroup membership; unfortunately,
these are not only cumbersome but also problematic.

Both net_cls and net_prio aren't properly hierarchical.  Both inherit
configuration from the parent on creation but there's no interaction
afterwards.  An ancestor doesn't restrict the behavior in its subtree
in anyway and configuration changes aren't propagated downwards.
Especially when combined with cgroup delegation, this is problematic
because delegatees can mess up whatever network configuration
implemented at the system level.  net_prio would allow the delegatees
to set whatever priority value regardless of CAP_NET_ADMIN and net_cls
the same for classid.

While it is possible to solve these issues from controller side by
implementing hierarchical allowable ranges in both controllers, it
would involve quite a bit of complexity in the controllers and further
obfuscate network configuration as it becomes even more difficult to
tell what's actually being configured looking from the network side.
While not much can be done for v1 at this point, as membership
handling is sane on cgroup v2, it'd be better to make cgroup matching
behave like other network matches and classifiers than introducing
further complications.

In preparation, this patch adds sock->sk_cgroup which points to the
associated cgroup.  A sock is associated on creation and stays
associated to the same cgroup until freed; unfortunately, this ends up
adding another cgroup field to struct sock on top of sk_cgrp_prioidx
and sk_classid.  I tried to think of a way to somehow overload the
existing fields but couldn't come up with a reasonable one.  For the
longer term, the fields can be rearranged so that disabling prio and
cls controllers reduce the size of the struct.

This patch doesn't make use of the added field yet.  The following
patch will implement netfilter match for cgroup2 membership.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: Neil Horman <nhorman@tuxdriver.com>
---
 include/linux/cgroup.h |  8 ++++++++
 include/net/sock.h     |  4 ++++
 kernel/cgroup.c        | 25 ++++++++++++++++++++++++-
 net/core/sock.c        |  2 ++
 4 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 4c3ffab..2a6d7c4 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -20,6 +20,8 @@
 
 #include <linux/cgroup-defs.h>
 
+struct sock;
+
 #ifdef CONFIG_CGROUPS
 
 /*
@@ -108,6 +110,9 @@ void cgroup_free(struct task_struct *p);
 int cgroup_init_early(void);
 int cgroup_init(void);
 
+void cgroup_sk_alloc(struct sock *sk);
+void cgroup_sk_free(struct sock *sk);
+
 /*
  * Iteration helpers and macros.
  */
@@ -576,6 +581,9 @@ static inline void cgroup_free(struct task_struct *p) {}
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 
+static inline void cgroup_sk_alloc(struct sock *sk) {}
+static inline void cgroup_sk_free(struct sock *sk) {}
+
 #endif /* !CONFIG_CGROUPS */
 
 #endif /* _LINUX_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index bbf7c2c..6c5d195 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -310,6 +310,7 @@ struct cg_proto;
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
   *	@sk_classid: this socket's cgroup classid
+  *	@sk_cgroup: the v2 cgroup this socket is associated with
   *	@sk_cgrp: this socket's cgroup-specific proto data
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
@@ -447,6 +448,9 @@ struct sock {
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	u32			sk_classid;
 #endif
+#ifdef CONFIG_CGROUPS
+	struct cgroup		*sk_cgroup;
+#endif
 	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 49947c1..f26533b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -57,8 +57,8 @@
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 #include <linux/kthread.h>
 #include <linux/delay.h>
-
 #include <linux/atomic.h>
+#include <net/sock.h>
 
 /*
  * pidlists linger the following amount before being destroyed.  The goal
@@ -5781,6 +5781,29 @@ struct cgroup *cgroup_get_from_path(const char *path)
 	return cgrp;
 }
 
+void cgroup_sk_alloc(struct sock *sk)
+{
+	rcu_read_lock();
+
+	while (true) {
+		struct css_set *cset;
+
+		cset = task_css_set(current);
+		if (likely(cgroup_tryget(cset->dfl_cgrp))) {
+			sk->sk_cgroup = cset->dfl_cgrp;
+			break;
+		}
+		cpu_relax();
+	}
+
+	rcu_read_unlock();
+}
+
+void cgroup_sk_free(struct sock *sk)
+{
+	cgroup_put(sk->sk_cgroup);
+}
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *
 debug_css_alloc(struct cgroup_subsys_state *parent_css)
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54..7c34bba 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1363,6 +1363,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
+		cgroup_sk_alloc(sk);
 	}
 
 	return sk;
@@ -1385,6 +1386,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	owner = prot->owner;
 	slab = prot->slab;
 
+	cgroup_sk_free(sk);
 	security_sk_free(sk);
 	if (slab != NULL)
 		kmem_cache_free(slab, sk);
-- 
2.5.0
