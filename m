From: Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Thu, 10 Oct 2013 23:55:29 +0200
Message-ID: <52572251.7000102@iogearbox.net>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <20131007164647.GA2481@htj.dyndns.org> <5253BCAE.5060409@redhat.com> <20131009170409.GH22495@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Borkmann <dborkmann-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131009170409.GH22495-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 10/09/2013 07:04 PM, Tejun Heo wrote:
> On Tue, Oct 08, 2013 at 10:05:02AM +0200, Daniel Borkmann wrote:
>> Could you elaborate on "Wouldn't it be more logical to implement netfilter
>> rule to match the target cgroup paths?". I don't think (or hope) you mean
>> some string comparison on the dentry path here? :) With our proposal, we
>> have in the network stack's critical path only the following code that is
>> being executed here to match the cgroup ...
>
> Comparing path each time obviously doesn't make sense but you can
> determine the cgroup on config and hold onto the pointer while the
> rule exists.
>
>> ... where ``info->id == skb->sk->sk_cgrp_fwid'' is the actual work, so very
>> lightweight, which is good for high loads (1Gbit/s, 10Gbit/s and beyond), of
>> course. Also, it would be intuitive for admins familiar with other subsystems
>> to just set up and use these cgroup ids in iptabels. I'm not yet quite sure
>> how your suggestion would look like, so you would need to setup some "dummy"
>> subgroups first just to have a path that you can match on?
>
> Currently, it's tricky because we have multiple hierarchies to
> consider and there isn't an efficient way to map from task to cgroup
> on a specific hierarchy.  I'm not sure whether we should add another
> mapping table in css_set or just allow using path matching on the
> unified hierarchy.  The latter should be cleaner and easier but more
> restrictive.
>
> Anyways, it isn't manageable in the long term to keep adding
> controllers simply to tag tasks differently.  If we want to do this,
> let's please work on a way to match a task's cgroup affiliation
> efficiently.

Here's a draft (!) of an alternative w/o using a new cgroup subsystem. I've
tested it and it would basically work this way as well. I've used serial_nr
as an identifier of cgroups here, as we'd actually want the xt_cgroup_info
structure as small as possible for rule sets (since they can be large and
are flat-copied to kernel). Logic in cgroup_mt() needs to change a bit as
we cannot hold css_set_lock here. Anyway, iptables would match here against
cgroup.serial (that can probably also be widely used otherwise). The way we
do it here is to cache the corresponding task in socket structure, and walk
all cgroups belonging to that task, comparing if serial_nr's match.

Still, I think my original patch is more clean, user friendly and intuitive,
and has a better performance (main work is one comparison instead of walking
all corresponding cgroups), so I'd still consider this the better tradeoff
to go with, I think netfilter is a large enough candidate for a subsys. ;)

Thanks,
Daniel

Draft patch:

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 3561d30..3c5e953 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -399,6 +399,26 @@ struct cgroup_map_cb {
  };

  /*
+ * A cgroup can be associated with multiple css_sets as different tasks may
+ * belong to different cgroups on different hierarchies.  In the other
+ * direction, a css_set is naturally associated with multiple cgroups.
+ * This M:N relationship is represented by the following link structure
+ * which exists for each association and allows traversing the associations
+ * from both sides.
+ */
+struct cgrp_cset_link {
+	/* the cgroup and css_set this link associates */
+	struct cgroup		*cgrp;
+	struct css_set		*cset;
+
+	/* list of cgrp_cset_links anchored at cgrp->cset_links */
+	struct list_head	cset_link;
+
+	/* list of cgrp_cset_links anchored at css_set->cgrp_links */
+	struct list_head	cgrp_link;
+};
+
+/*
   * struct cftype: handler definitions for cgroup control files
   *
   * When reading/writing to a file:
diff --git a/include/net/sock.h b/include/net/sock.h
index e3bf213..b035ba3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -406,6 +406,9 @@ struct sock {
  	__u32			sk_mark;
  	u32			sk_classid;
  	struct cg_proto		*sk_cgrp;
+#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
+	struct task_struct	*sk_task_cached;
+#endif
  	void			(*sk_state_change)(struct sock *sk);
  	void			(*sk_data_ready)(struct sock *sk, int bytes);
  	void			(*sk_write_space)(struct sock *sk);
@@ -2098,6 +2101,22 @@ static inline gfp_t gfp_any(void)
  	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
  }

+static inline struct task_struct *sock_task(const struct sock *sk)
+{
+#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
+	return sk->sk_task_cached;
+#else
+	return NULL;
+#endif
+}
+
+static inline void sock_task_set(struct sock *sk, struct task_struct *task)
+{
+#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
+	sk->sk_task_cached = task;
+#endif
+}
+
  static inline long sock_rcvtimeo(const struct sock *sk, bool noblock)
  {
  	return noblock ? 0 : sk->sk_rcvtimeo;
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 1749154..94a4890 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -37,6 +37,7 @@ header-y += xt_TEE.h
  header-y += xt_TPROXY.h
  header-y += xt_addrtype.h
  header-y += xt_bpf.h
+header-y += xt_cgroup.h
  header-y += xt_cluster.h
  header-y += xt_comment.h
  header-y += xt_connbytes.h
diff --git a/include/uapi/linux/netfilter/xt_cgroup.h b/include/uapi/linux/netfilter/xt_cgroup.h
new file mode 100644
index 0000000..c59ff53
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_cgroup.h
@@ -0,0 +1,11 @@
+#ifndef _UAPI_XT_CGROUP_H
+#define _UAPI_XT_CGROUP_H
+
+#include <linux/types.h>
+
+struct xt_cgroup_info {
+	__u64 serial_nr;
+	__u32 invert;
+};
+
+#endif /* _UAPI_XT_CGROUP_H */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2418b6e..1f9dc5b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -357,26 +357,6 @@ static void cgroup_release_agent(struct work_struct *work);
  static DECLARE_WORK(release_agent_work, cgroup_release_agent);
  static void check_for_release(struct cgroup *cgrp);

-/*
- * A cgroup can be associated with multiple css_sets as different tasks may
- * belong to different cgroups on different hierarchies.  In the other
- * direction, a css_set is naturally associated with multiple cgroups.
- * This M:N relationship is represented by the following link structure
- * which exists for each association and allows traversing the associations
- * from both sides.
- */
-struct cgrp_cset_link {
-	/* the cgroup and css_set this link associates */
-	struct cgroup		*cgrp;
-	struct css_set		*cset;
-
-	/* list of cgrp_cset_links anchored at cgrp->cset_links */
-	struct list_head	cset_link;
-
-	/* list of cgrp_cset_links anchored at css_set->cgrp_links */
-	struct list_head	cgrp_link;
-};
-
  /* The default css_set - used by init and its children prior to any
   * hierarchies being mounted. It contains a pointer to the root state
   * for each subsystem. Also used to anchor the list of css_sets. Not
@@ -4163,6 +4143,12 @@ static int cgroup_clone_children_write(struct cgroup_subsys_state *css,
  	return 0;
  }

+static u64 cgroup_serial_read(struct cgroup_subsys_state *css,
+			      struct cftype *cft)
+{
+	return css->cgroup->serial_nr;
+}
+
  static struct cftype cgroup_base_files[] = {
  	{
  		.name = "cgroup.procs",
@@ -4187,6 +4173,11 @@ static struct cftype cgroup_base_files[] = {
  		.flags = CFTYPE_ONLY_ON_ROOT,
  		.read_seq_string = cgroup_sane_behavior_show,
  	},
+	{
+		.name = "cgroup.serial",
+		.read_u64 = cgroup_serial_read,
+		.mode = S_IRUGO,
+	},

  	/*
  	 * Historical crazy stuff.  These don't have "cgroup."  prefix and
diff --git a/net/core/scm.c b/net/core/scm.c
index b442e7e..9a40ab0 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -292,6 +292,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
  		if (sock) {
  			sock_update_netprioidx(sock->sk);
  			sock_update_classid(sock->sk);
+			sock_task_set(sock->sk, current);
  		}
  		fd_install(new_fd, get_file(fp[i]));
  	}
diff --git a/net/core/sock.c b/net/core/sock.c
index 2bd9b3f..ab53afc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1359,6 +1359,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
  		sk->sk_prot = sk->sk_prot_creator = prot;
  		sock_lock_init(sk);
  		sock_net_set(sk, get_net(net));
+		sock_task_set(sk, current);
  		atomic_set(&sk->sk_wmem_alloc, 1);

  		sock_update_classid(sk);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 6e839b6..d276ff4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -806,6 +806,14 @@ config NETFILTER_XT_MATCH_BPF

  	  To compile it as a module, choose M here.  If unsure, say N.

+config NETFILTER_XT_MATCH_CGROUP
+	tristate '"control group" match support'
+	depends on NETFILTER_ADVANCED
+	depends on CGROUPS
+	---help---
+	Socket/process control group matching allows you to match locally
+	generated packets based on which control group processes belong to.
+
  config NETFILTER_XT_MATCH_CLUSTER
  	tristate '"cluster" match support'
  	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index c3a0a12..12f014f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -124,6 +124,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_NFACCT) += xt_nfacct.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CGROUP) += xt_cgroup.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
  obj-$(CONFIG_NETFILTER_XT_MATCH_POLICY) += xt_policy.o
diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
new file mode 100644
index 0000000..f04cba8
--- /dev/null
+++ b/net/netfilter/xt_cgroup.c
@@ -0,0 +1,79 @@
+#include <linux/skbuff.h>
+#include <linux/module.h>
+#include <linux/file.h>
+#include <linux/cgroup.h>
+#include <linux/fdtable.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_cgroup.h>
+#include <net/sock.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>");
+MODULE_DESCRIPTION("Xtables: process control group matching");
+MODULE_ALIAS("ipt_cgroup");
+MODULE_ALIAS("ip6t_cgroup");
+
+static int cgroup_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_cgroup_info *info = par->matchinfo;
+
+	return (info->invert & ~1) ? -EINVAL : 0;
+}
+
+static bool
+cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cgroup_info *info = par->matchinfo;
+	struct cgrp_cset_link *link, *link_tmp;
+	const struct sock *sk = skb->sk;
+	struct task_struct *task;
+	struct css_set *cset;
+	bool found = false;
+
+	if (sk == NULL)
+		return false;
+
+	task = sock_task(sk);
+	if (task == NULL)
+		return false;
+
+	rcu_read_lock();
+	/* XXX: read_lock(&css_set_lock); */
+	cset = task_css_set(task);
+	list_for_each_entry_safe(link, link_tmp, &cset->cgrp_links, cgrp_link) {
+		struct cgroup *cgrp = link->cgrp;
+		if (cgrp->serial_nr == info->serial_nr) {
+			found = true;
+			break;
+		}
+	}
+	/* XXX: read_unlock(&css_set_lock); */
+	rcu_read_unlock();
+
+	return found ^ info->invert;
+}
+
+static struct xt_match cgroup_mt_reg __read_mostly = {
+	.name       = "cgroup",
+	.revision   = 0,
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = cgroup_mt_check,
+	.match      = cgroup_mt,
+	.matchsize  = sizeof(struct xt_cgroup_info),
+	.me         = THIS_MODULE,
+	.hooks      = (1 << NF_INET_LOCAL_OUT) |
+	              (1 << NF_INET_POST_ROUTING),
+};
+
+static int __init cgroup_mt_init(void)
+{
+	return xt_register_match(&cgroup_mt_reg);
+}
+
+static void __exit cgroup_mt_exit(void)
+{
+	xt_unregister_match(&cgroup_mt_reg);
+}
+
+module_init(cgroup_mt_init);
+module_exit(cgroup_mt_exit);
-- 
1.8.3.1
