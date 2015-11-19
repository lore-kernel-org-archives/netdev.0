From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/7] sock, cgroup: add sock->sk_cgroup
Date: Thu, 19 Nov 2015 13:52:50 -0500
Message-ID: <1447959171-20749-7-git-send-email-tj@kernel.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-1-git-send-email-tj@kernel.org>
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

In preparation, this patch updates sock->sk_cgrp_data handling so that
it points to the v2 cgroup that sock was created in until either
net_prio or net_cls is used.  Once either of the two is used,
sock->sk_cgrp_data reverts to its previous role of carrying prioidx
and classid.  This is to avoid adding yet another cgroup related field
to struct sock.

As the mode switching can happen at most once per boot, the switching
mechanism is aimed at lowering hot path overhead.  It may leak a
finite, likely small, number of cgroup refs and report spurious
prioidx or classid on switching; however, dynamic updates of prioidx
and classid have always been racy and lossy - socks between creation
and fd installation are never updated, config changes don't update
existing sockets at all, and prioidx may index with dead and recycled
cgroup IDs.  Non-critical inaccuracies from small race windows won't
make any noticeable difference.

This patch doesn't make use of the pointer yet.  The following patch
will implement netfilter match for cgroup2 membership.

v2: Use sock_cgroup_data to avoid inflating struct sock w/ another
    cgroup specific field.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: Neil Horman <nhorman@tuxdriver.com>
---
 include/linux/cgroup-defs.h  | 86 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/cgroup.h       | 41 +++++++++++++++++++++
 kernel/cgroup.c              | 55 +++++++++++++++++++++++++++-
 net/core/netclassid_cgroup.c |  6 +++-
 net/core/netprio_cgroup.c    |  7 +++-
 net/core/sock.c              |  2 ++
 6 files changed, 188 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index ed128fed..76fe7c7 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -544,31 +544,105 @@ static inline void cgroup_threadgroup_change_end(struct task_struct *tsk) {}
 
 #ifdef CONFIG_SOCK_CGROUP_DATA
 
+/*
+ * sock_cgroup_data is embedded at sock->sk_cgrp_data and contains
+ * per-socket cgroup information except for memcg association.
+ *
+ * On legacy hierarchies, net_prio and net_cls controllers directly set
+ * attributes on each sock which can then be tested by the network layer.
+ * On the default hierarchy, each sock is associated with the cgroup it was
+ * created in and the networking layer can match the cgroup directly.
+ *
+ * To avoid carrying all three cgroup related fields separately in sock,
+ * sock_cgroup_data overloads (prioidx, classid) and the cgroup pointer.
+ * On boot, sock_cgroup_data records the cgroup that the sock was created
+ * in so that cgroup2 matches can be made; however, once either net_prio or
+ * net_cls starts being used, the area is overriden to carry prioidx and/or
+ * classid.  The two modes are distinguished by whether the lowest bit is
+ * set.  Clear bit indicates cgroup pointer while set bit prioidx and
+ * classid.
+ *
+ * While userland may start using net_prio or net_cls at any time, once
+ * either is used, cgroup2 matching no longer works.  There is no reason to
+ * mix the two and this is in line with how legacy and v2 compatibility is
+ * handled.  On mode switch, cgroup references which are already being
+ * pointed to by socks may be leaked.  While this can be remedied by adding
+ * synchronization around sock_cgroup_data, given that the number of leaked
+ * cgroups is bound and highly unlikely to be high, this seems to be the
+ * better trade-off.
+ */
 struct sock_cgroup_data {
-	u16	prioidx;
-	u32	classid;
+	union {
+#ifdef __LITTLE_ENDIAN
+		struct {
+			u8	is_data;
+			u8	padding;
+			u16	prioidx;
+			u32	classid;
+		} __packed;
+#else
+		struct {
+			u32	classid;
+			u16	prioidx;
+			u8	padding;
+			u8	is_data;
+		} __packed;
+#endif
+		u64		val;
+	};
 };
 
+/*
+ * There's a theoretical window where the following accessors race with
+ * updaters and return part of the previous pointer as the prioidx or
+ * classid.  Such races are short-lived and the result isn't critical.
+ */
 static inline u16 sock_cgroup_prioidx(struct sock_cgroup_data *skcd)
 {
-	return skcd->prioidx;
+	return (skcd->is_data & 1) ? skcd->prioidx : 1;
 }
 
 static inline u32 sock_cgroup_classid(struct sock_cgroup_data *skcd)
 {
-	return skcd->classid;
+	return (skcd->is_data & 1) ? skcd->classid : 0;
 }
 
+/*
+ * If invoked concurrently, the updaters may clobber each other.  The
+ * caller is responsible for synchronization.
+ */
 static inline void sock_cgroup_set_prioidx(struct sock_cgroup_data *skcd,
 					   u16 prioidx)
 {
-	skcd->prioidx = prioidx;
+	struct sock_cgroup_data skcd_buf = { .val = READ_ONCE(skcd->val) };
+
+	if (sock_cgroup_prioidx(&skcd_buf) == prioidx)
+		return;
+
+	if (!(skcd_buf.is_data & 1)) {
+		skcd_buf.val = 0;
+		skcd_buf.is_data = 1;
+	}
+
+	skcd_buf.prioidx = prioidx;
+	WRITE_ONCE(skcd->val, skcd_buf.val);	/* see sock_cgroup_ptr() */
 }
 
 static inline void sock_cgroup_set_classid(struct sock_cgroup_data *skcd,
 					   u32 classid)
 {
-	skcd->classid = classid;
+	struct sock_cgroup_data skcd_buf = { .val = READ_ONCE(skcd->val) };
+
+	if (sock_cgroup_classid(&skcd_buf) == classid)
+		return;
+
+	if (!(skcd_buf.is_data & 1)) {
+		skcd_buf.val = 0;
+		skcd_buf.is_data = 1;
+	}
+
+	skcd_buf.classid = classid;
+	WRITE_ONCE(skcd->val, skcd_buf.val);	/* see sock_cgroup_ptr() */
 }
 
 #else	/* CONFIG_SOCK_CGROUP_DATA */
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 4c3ffab..a8ba1ea 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -578,4 +578,45 @@ static inline int cgroup_init(void) { return 0; }
 
 #endif /* !CONFIG_CGROUPS */
 
+/*
+ * sock->sk_cgrp_data handling.  For more info, see sock_cgroup_data
+ * definition in cgroup-defs.h.
+ */
+#ifdef CONFIG_SOCK_CGROUP_DATA
+
+#if defined(CONFIG_CGROUP_NET_PRIO) || defined(CONFIG_CGROUP_NET_CLASSID)
+extern spinlock_t cgroup_sk_update_lock;
+#endif
+
+void cgroup_sk_alloc_disable(void);
+void cgroup_sk_alloc(struct sock_cgroup_data *skcd);
+void cgroup_sk_free(struct sock_cgroup_data *skcd);
+
+static inline struct cgroup *sock_cgroup_ptr(struct sock_cgroup_data *skcd)
+{
+#if defined(CONFIG_CGROUP_NET_PRIO) || defined(CONFIG_CGROUP_NET_CLASSID)
+	unsigned long v;
+
+	/*
+	 * @skcd->val is 64bit but the following is safe on 32bit too as we
+	 * just need the lower ulong to be written and read atomically.
+	 */
+	v = READ_ONCE(skcd->val);
+
+	if (v & 1)
+		return &cgrp_dfl_root.cgrp;
+
+	return (struct cgroup *)(unsigned long)v ?: &cgrp_dfl_root.cgrp;
+#else
+	return (struct cgroup *)(unsigned long)skcd->val;
+#endif
+}
+
+#else	/* CONFIG_CGROUP_DATA */
+
+static inline void cgroup_sk_alloc(struct sock_cgroup_data *skcd) {}
+static inline void cgroup_sk_free(struct sock_cgroup_data *skcd) {}
+
+#endif	/* CONFIG_CGROUP_DATA */
+
 #endif /* _LINUX_CGROUP_H */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3db5e8f..4f8f792 100644
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
@@ -5782,6 +5782,59 @@ struct cgroup *cgroup_get_from_path(const char *path)
 }
 EXPORT_SYMBOL_GPL(cgroup_get_from_path);
 
+/*
+ * sock->sk_cgrp_data handling.  For more info, see sock_cgroup_data
+ * definition in cgroup-defs.h.
+ */
+#ifdef CONFIG_SOCK_CGROUP_DATA
+
+#if defined(CONFIG_CGROUP_NET_PRIO) || defined(CONFIG_CGROUP_NET_CLASSID)
+
+spinlock_t cgroup_sk_update_lock;
+static bool cgroup_sk_alloc_disabled __read_mostly;
+
+void cgroup_sk_alloc_disable(void)
+{
+	if (cgroup_sk_alloc_disabled)
+		return;
+	pr_info("cgroup: disabling cgroup2 socket matching due to net_prio or net_cls activation\n");
+	cgroup_sk_alloc_disabled = true;
+}
+
+#else
+
+#define cgroup_sk_alloc_disabled	false
+
+#endif
+
+void cgroup_sk_alloc(struct sock_cgroup_data *skcd)
+{
+	if (cgroup_sk_alloc_disabled)
+		return;
+
+	rcu_read_lock();
+
+	while (true) {
+		struct css_set *cset;
+
+		cset = task_css_set(current);
+		if (likely(cgroup_tryget(cset->dfl_cgrp))) {
+			skcd->val = (unsigned long)cset->dfl_cgrp;
+			break;
+		}
+		cpu_relax();
+	}
+
+	rcu_read_unlock();
+}
+
+void cgroup_sk_free(struct sock_cgroup_data *skcd)
+{
+	cgroup_put(sock_cgroup_ptr(skcd));
+}
+
+#endif	/* CONFIG_SOCK_CGROUP_DATA */
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *
 debug_css_alloc(struct cgroup_subsys_state *parent_css)
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 991c513..a575538 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -61,9 +61,12 @@ static int update_classid(const void *v, struct file *file, unsigned n)
 	int err;
 	struct socket *sock = sock_from_file(file, &err);
 
-	if (sock)
+	if (sock) {
+		spin_lock(&cgroup_sk_update_lock);
 		sock_cgroup_set_classid(&sock->sk->sk_cgrp_data,
 					(unsigned long)v);
+		spin_unlock(&cgroup_sk_update_lock);
+	}
 	return 0;
 }
 
@@ -89,6 +92,7 @@ static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
 static int write_classid(struct cgroup_subsys_state *css, struct cftype *cft,
 			 u64 value)
 {
+	cgroup_sk_alloc_disable();
 	css_cls_state(css)->classid = (u32) value;
 
 	return 0;
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index de42aa7..053d60c 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -209,6 +209,8 @@ static ssize_t write_priomap(struct kernfs_open_file *of,
 	if (!dev)
 		return -ENODEV;
 
+	cgroup_sk_alloc_disable();
+
 	rtnl_lock();
 
 	ret = netprio_set_prio(of_css(of), dev, prio);
@@ -222,9 +224,12 @@ static int update_netprio(const void *v, struct file *file, unsigned n)
 {
 	int err;
 	struct socket *sock = sock_from_file(file, &err);
-	if (sock)
+	if (sock) {
+		spin_lock(&cgroup_sk_update_lock);
 		sock_cgroup_set_prioidx(&sock->sk->sk_cgrp_data,
 					(unsigned long)v);
+		spin_unlock(&cgroup_sk_update_lock);
+	}
 	return 0;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 35af060..ecce5df 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1363,6 +1363,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
+		cgroup_sk_alloc(&sk->sk_cgrp_data);
 	}
 
 	return sk;
@@ -1385,6 +1386,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	owner = prot->owner;
 	slab = prot->slab;
 
+	cgroup_sk_free(&sk->sk_cgrp_data);
 	security_sk_free(sk);
 	if (slab != NULL)
 		kmem_cache_free(slab, sk);
-- 
2.5.0
