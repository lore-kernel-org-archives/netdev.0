From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the cgroup tree with the net-next tree
Date: Thu, 31 Dec 2015 19:10:35 +1100
Message-ID: <20151231191035.3b063a9b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>
To: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

Today's linux-next merge of the cgroup tree got a conflict in:

  include/linux/cgroup.h
  kernel/cgroup.c

between commit:

  bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")

from the net-next tree and commit:

  f176ae3a5df6 ("cgroup: introduce cgroup namespaces")

from the cgroup tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/cgroup.h
index 322a28482745,6d0992f3543d..000000000000
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@@ -577,45 -569,47 +569,88 @@@ static inline int cgroup_init(void) { r
  
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
+ struct cgroup_namespace {
+ 	atomic_t		count;
+ 	struct ns_common	ns;
+ 	struct user_namespace	*user_ns;
+ 	struct css_set          *root_cset;
+ };
+ 
+ extern struct cgroup_namespace init_cgroup_ns;
+ 
+ #ifdef CONFIG_CGROUPS
+ 
+ void free_cgroup_ns(struct cgroup_namespace *ns);
+ 
+ struct cgroup_namespace *
+ copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+ 	       struct cgroup_namespace *old_ns);
+ 
+ char *cgroup_path(struct cgroup *cgrp, char *buf, size_t buflen);
+ 
+ #else /* !CONFIG_CGROUPS */
+ 
+ static inline void free_cgroup_ns(struct cgroup_namespace *ns) { }
+ static inline struct cgroup_namespace *
+ copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+ 	       struct cgroup_namespace *old_ns)
+ {
+ 	return old_ns;
+ }
+ 
+ #endif /* !CONFIG_CGROUPS */
+ 
+ static inline void get_cgroup_ns(struct cgroup_namespace *ns)
+ {
+ 	if (ns)
+ 		atomic_inc(&ns->count);
+ }
+ 
+ static inline void put_cgroup_ns(struct cgroup_namespace *ns)
+ {
+ 	if (ns && atomic_dec_and_test(&ns->count))
+ 		free_cgroup_ns(ns);
+ }
+ 
  #endif /* _LINUX_CGROUP_H */
diff --cc kernel/cgroup.c
index fe95970b1f79,7eb1d9de2afa..000000000000
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@@ -57,8 -57,11 +57,12 @@@
  #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
  #include <linux/kthread.h>
  #include <linux/delay.h>
+ #include <linux/proc_ns.h>
+ #include <linux/nsproxy.h>
+ #include <linux/proc_ns.h>
+ 
  #include <linux/atomic.h>
 +#include <net/sock.h>
  
  /*
   * pidlists linger the following amount before being destroyed.  The goal
@@@ -5839,59 -5900,134 +5901,187 @@@ struct cgroup *cgroup_get_from_path(con
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
 +DEFINE_SPINLOCK(cgroup_sk_update_lock);
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
+ /* cgroup namespaces */
+ 
+ static struct cgroup_namespace *alloc_cgroup_ns(void)
+ {
+ 	struct cgroup_namespace *new_ns;
+ 	int ret;
+ 
+ 	new_ns = kzalloc(sizeof(struct cgroup_namespace), GFP_KERNEL);
+ 	if (!new_ns)
+ 		return ERR_PTR(-ENOMEM);
+ 	ret = ns_alloc_inum(&new_ns->ns);
+ 	if (ret) {
+ 		kfree(new_ns);
+ 		return ERR_PTR(ret);
+ 	}
+ 	atomic_set(&new_ns->count, 1);
+ 	new_ns->ns.ops = &cgroupns_operations;
+ 	return new_ns;
+ }
+ 
+ void free_cgroup_ns(struct cgroup_namespace *ns)
+ {
+ 	put_css_set(ns->root_cset);
+ 	put_user_ns(ns->user_ns);
+ 	ns_free_inum(&ns->ns);
+ 	kfree(ns);
+ }
+ EXPORT_SYMBOL(free_cgroup_ns);
+ 
+ struct cgroup_namespace *
+ copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+ 	       struct cgroup_namespace *old_ns)
+ {
+ 	struct cgroup_namespace *new_ns = NULL;
+ 	struct css_set *cset = NULL;
+ 	int err;
+ 
+ 	BUG_ON(!old_ns);
+ 
+ 	if (!(flags & CLONE_NEWCGROUP)) {
+ 		get_cgroup_ns(old_ns);
+ 		return old_ns;
+ 	}
+ 
+ 	/* Allow only sysadmin to create cgroup namespace. */
+ 	err = -EPERM;
+ 	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
+ 		goto err_out;
+ 
+ 	cset = task_css_set(current);
+ 	get_css_set(cset);
+ 
+ 	err = -ENOMEM;
+ 	new_ns = alloc_cgroup_ns();
+ 	if (!new_ns)
+ 		goto err_out;
+ 
+ 	new_ns->user_ns = get_user_ns(user_ns);
+ 	new_ns->root_cset = cset;
+ 
+ 	return new_ns;
+ 
+ err_out:
+ 	if (cset)
+ 		put_css_set(cset);
+ 	kfree(new_ns);
+ 	return ERR_PTR(err);
+ }
+ 
+ static inline struct cgroup_namespace *to_cg_ns(struct ns_common *ns)
+ {
+ 	return container_of(ns, struct cgroup_namespace, ns);
+ }
+ 
+ static int cgroupns_install(struct nsproxy *nsproxy, struct ns_common *ns)
+ {
+ 	struct cgroup_namespace *cgroup_ns = to_cg_ns(ns);
+ 
+ 	if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN) ||
+ 	    !ns_capable(cgroup_ns->user_ns, CAP_SYS_ADMIN))
+ 		return -EPERM;
+ 
+ 	/* Don't need to do anything if we are attaching to our own cgroupns. */
+ 	if (cgroup_ns == nsproxy->cgroup_ns)
+ 		return 0;
+ 
+ 	get_cgroup_ns(cgroup_ns);
+ 	put_cgroup_ns(nsproxy->cgroup_ns);
+ 	nsproxy->cgroup_ns = cgroup_ns;
+ 
+ 	return 0;
+ }
+ 
+ static struct ns_common *cgroupns_get(struct task_struct *task)
+ {
+ 	struct cgroup_namespace *ns = NULL;
+ 	struct nsproxy *nsproxy;
+ 
+ 	task_lock(task);
+ 	nsproxy = task->nsproxy;
+ 	if (nsproxy) {
+ 		ns = nsproxy->cgroup_ns;
+ 		get_cgroup_ns(ns);
+ 	}
+ 	task_unlock(task);
+ 
+ 	return ns ? &ns->ns : NULL;
+ }
+ 
+ static void cgroupns_put(struct ns_common *ns)
+ {
+ 	put_cgroup_ns(to_cg_ns(ns));
+ }
+ 
+ const struct proc_ns_operations cgroupns_operations = {
+ 	.name		= "cgroup",
+ 	.type		= CLONE_NEWCGROUP,
+ 	.get		= cgroupns_get,
+ 	.put		= cgroupns_put,
+ 	.install	= cgroupns_install,
+ };
+ 
+ static __init int cgroup_namespaces_init(void)
+ {
+ 	return 0;
+ }
+ subsys_initcall(cgroup_namespaces_init);
+ 
  #ifdef CONFIG_CGROUP_DEBUG
  static struct cgroup_subsys_state *
  debug_css_alloc(struct cgroup_subsys_state *parent_css)
