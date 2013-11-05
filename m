From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Tue, 05 Nov 2013 14:03:07 +0100
Message-ID: <5278EC8B.4060902@redhat.com>
References: <cover.1382101225.git.dborkman@redhat.com> <ee0fb538d6e43e23d0488d3edd741de9c4589fb1.1382101225.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ee0fb538d6e43e23d0488d3edd741de9c4589fb1.1382101225.git.dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/18/2013 03:28 PM, Daniel Borkmann wrote:
> It would be useful e.g. in a server or desktop environment to have
> a facility in the notion of fine-grained "per application" or "per
> application group" firewall policies. Probably, users in the mobile/
> embedded area (e.g. Android based) with different security policy
> requirements for application groups could have great benefit from
> that as well. For example, with a little bit of configuration effort,
> an admin could whitelist well-known applications, and thus block
> otherwise unwanted "hard-to-track" applications like [1] from a
> user's machine.
>
> Implementation of PID-based matching would not be appropriate
> as they frequently change, and child tracking would make that
> even more complex and ugly. Cgroups would be a perfect candidate
> for accomplishing that as they associate a set of tasks with a
> set of parameters for one or more subsystems, in our case the
> netfilter subsystem, which, of course, can be combined with other
> cgroup subsystems into something more complex.
>
> As mentioned, to overcome this constraint, such processes could
> be placed into one or multiple cgroups where different fine-grained
> rules can be defined depending on the application scenario, while
> e.g. everything else that is not part of that could be dropped (or
> vice versa), thus making life harder for unwanted processes to
> communicate to the outside world. So, we make use of cgroups here
> to track jobs and limit their resources in terms of iptables
> policies; in other words, limiting what they are allowed to
> communicate.
>
> Minimal, basic usage example (many other iptables options can be
> applied obviously):
>
>   1) Configuring cgroups:
>
>    mkdir /sys/fs/cgroup/net_filter
>    mount -t cgroup -o net_filter net_filter /sys/fs/cgroup/net_filter
>    mkdir /sys/fs/cgroup/net_filter/0
>    echo 1 > /sys/fs/cgroup/net_filter/0/net_filter.fwid
>
>   2) Configuring netfilter:
>
>    iptables -A OUTPUT -m cgroup ! --cgroup 1 -j DROP
>
>   3) Running applications:
>
>    ping 208.67.222.222  <pid:1799>
>    echo 1799 > /sys/fs/cgroup/net_filter/0/tasks
>    64 bytes from 208.67.222.222: icmp_seq=44 ttl=49 time=11.9 ms
>    ...
>
>    ping 208.67.220.220  <pid:1804>
>    ping: sendmsg: Operation not permitted
>    ...
>    echo 1804 > /sys/fs/cgroup/net_filter/0/tasks
>    64 bytes from 208.67.220.220: icmp_seq=89 ttl=56 time=19.0 ms
>    ...
>
> Of course, real-world deployments would make use of cgroups user
> space toolsuite, or own custom policy daemons dynamically moving
> applications from/to various net_filter cgroups.
>
> Design considerations appendix:
>
> Based on the discussion from [2], [3], it seems the best tradeoff
> imho to make this a subsystem, here's why:
>
> netfilter is a large enough and ubiquitous subsystem, meaning it
> is not somewhere in a niche, and enabled/shipped on most machines.
> It is true that the descision making on fwid is "outsourced" to
> netfilter itself, but that does not necessarily need to be
> considered as a bad thing to delegate and reuse as much as possible.
> The matching performance in the critical path is just a simple
> comparison of fwid tags, nothing more, thus resulting in a good
> performance suited for high-speed networking. Moreover, by simply
> transfering fwids between user- and kernel space, we can have the
> ruleset as packed as possible, giving an optimal footprint for
> large rulesets using this feature. The alternative draft that we
> have proposed in [3] comes at the cost of exposing some of the
> cgroups internals outside of cgroups to make it work, at least a
> higher memory footprint for transferal of rules and even worse a
> lower performance as more work needs to be done in the matching
> critical path, that is traversing all cgroups a task belongs to
> to find the one of our interest. Moreover, from the usability
> point of view, it seems less intuitive, rather more confusing
> than the approach presented here. Therefore, I consider this design
> the better and less intrusive tradeoff to go with.

As I've provided a code proposal for both variants and a design
discussion/conclusion, are you d'accord with this patch Tejun?

>    [1] http://www.blackhat.com/presentations/bh-europe-06/bh-eu-06-biondi/bh-eu-06-biondi-up.pdf
>    [2] http://patchwork.ozlabs.org/patch/280687/
>    [3] http://patchwork.ozlabs.org/patch/282477/
>
> Signed-off-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>   v1->v2:
>    - Updated commit message, rebased
>    - Applied Gao Feng's feedback from [2]
>
>   Note: iptables part is still available in http://patchwork.ozlabs.org/patch/280690/
>
>   Documentation/cgroups/00-INDEX           |   2 +
>   Documentation/cgroups/net_filter.txt     |  27 +++++
>   include/linux/cgroup_subsys.h            |   5 +
>   include/net/netfilter/xt_cgroup.h        |  58 ++++++++++
>   include/net/sock.h                       |   3 +
>   include/uapi/linux/netfilter/Kbuild      |   1 +
>   include/uapi/linux/netfilter/xt_cgroup.h |  11 ++
>   net/core/scm.c                           |   2 +
>   net/core/sock.c                          |  14 +++
>   net/netfilter/Kconfig                    |   8 ++
>   net/netfilter/Makefile                   |   1 +
>   net/netfilter/xt_cgroup.c                | 177 +++++++++++++++++++++++++++++++
>   12 files changed, 309 insertions(+)
>   create mode 100644 Documentation/cgroups/net_filter.txt
>   create mode 100644 include/net/netfilter/xt_cgroup.h
>   create mode 100644 include/uapi/linux/netfilter/xt_cgroup.h
>   create mode 100644 net/netfilter/xt_cgroup.c
>
> diff --git a/Documentation/cgroups/00-INDEX b/Documentation/cgroups/00-INDEX
> index bc461b6..14424d2 100644
> --- a/Documentation/cgroups/00-INDEX
> +++ b/Documentation/cgroups/00-INDEX
> @@ -20,6 +20,8 @@ memory.txt
>   	- Memory Resource Controller; design, accounting, interface, testing.
>   net_cls.txt
>   	- Network classifier cgroups details and usages.
> +net_filter.txt
> +	- Network firewalling (netfilter) cgroups details and usages.
>   net_prio.txt
>   	- Network priority cgroups details and usages.
>   resource_counter.txt
> diff --git a/Documentation/cgroups/net_filter.txt b/Documentation/cgroups/net_filter.txt
> new file mode 100644
> index 0000000..22759e4
> --- /dev/null
> +++ b/Documentation/cgroups/net_filter.txt
> @@ -0,0 +1,27 @@
> +Netfilter cgroup
> +----------------
> +
> +The netfilter cgroup provides an interface to aggregate jobs
> +to a particular netfilter tag, that can be used to apply
> +various iptables/netfilter policies for those jobs in order
> +to limit resources/abilities for network communication.
> +
> +Creating a net_filter cgroups instance creates a net_filter.fwid
> +file. The value of net_filter.fwid is initialized to 0 on
> +default (so only global iptables/netfilter policies apply).
> +You can write a unique decimal fwid tag into net_filter.fwid
> +file, and use that tag along with iptables' --cgroup option.
> +
> +Minimal/basic usage example:
> +
> +1) Configuring cgroup:
> +
> + mkdir /sys/fs/cgroup/net_filter
> + mount -t cgroup -o net_filter net_filter /sys/fs/cgroup/net_filter
> + mkdir /sys/fs/cgroup/net_filter/0
> + echo 1 > /sys/fs/cgroup/net_filter/0/net_filter.fwid
> + echo [pid] > /sys/fs/cgroup/net_filter/0/tasks
> +
> +2) Configuring netfilter:
> +
> + iptables -A OUTPUT -m cgroup ! --cgroup 1 -p tcp --dport 80 -j DROP
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index b613ffd..ef58217 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -50,6 +50,11 @@ SUBSYS(net_prio)
>   #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
>   SUBSYS(hugetlb)
>   #endif
> +
> +#if IS_SUBSYS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +SUBSYS(net_filter)
> +#endif
> +
>   /*
>    * DO NOT ADD ANY SUBSYSTEM WITHOUT EXPLICIT ACKS FROM CGROUP MAINTAINERS.
>    */
> diff --git a/include/net/netfilter/xt_cgroup.h b/include/net/netfilter/xt_cgroup.h
> new file mode 100644
> index 0000000..b2c702f
> --- /dev/null
> +++ b/include/net/netfilter/xt_cgroup.h
> @@ -0,0 +1,58 @@
> +#ifndef _XT_CGROUP_H
> +#define _XT_CGROUP_H
> +
> +#include <linux/types.h>
> +#include <linux/cgroup.h>
> +#include <linux/hardirq.h>
> +#include <linux/rcupdate.h>
> +
> +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +struct cgroup_nf_state {
> +	struct cgroup_subsys_state css;
> +	u32 fwid;
> +};
> +
> +void sock_update_fwid(struct sock *sk);
> +
> +#if IS_BUILTIN(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +static inline u32 task_fwid(struct task_struct *p)
> +{
> +	u32 fwid;
> +
> +	if (in_interrupt())
> +		return 0;
> +
> +	rcu_read_lock();
> +	fwid = container_of(task_css(p, net_filter_subsys_id),
> +			    struct cgroup_nf_state, css)->fwid;
> +	rcu_read_unlock();
> +
> +	return fwid;
> +}
> +#elif IS_MODULE(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +static inline u32 task_fwid(struct task_struct *p)
> +{
> +	struct cgroup_subsys_state *css;
> +	u32 fwid = 0;
> +
> +	if (in_interrupt())
> +		return 0;
> +
> +	rcu_read_lock();
> +	css = task_css(p, net_filter_subsys_id);
> +	if (css)
> +		fwid = container_of(css, struct cgroup_nf_state, css)->fwid;
> +	rcu_read_unlock();
> +
> +	return fwid;
> +}
> +#endif
> +#else /* !CONFIG_NETFILTER_XT_MATCH_CGROUP */
> +static inline u32 task_fwid(struct task_struct *p)
> +{
> +	return 0;
> +}
> +
> +#define sock_update_fwid(sk)
> +#endif /* CONFIG_NETFILTER_XT_MATCH_CGROUP */
> +#endif /* _XT_CGROUP_H */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index e3bf213..f7da4b4 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -387,6 +387,9 @@ struct sock {
>   #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
>   	__u32			sk_cgrp_prioidx;
>   #endif
> +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +	__u32			sk_cgrp_fwid;
> +#endif
>   	struct pid		*sk_peer_pid;
>   	const struct cred	*sk_peer_cred;
>   	long			sk_rcvtimeo;
> diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
> index 1749154..94a4890 100644
> --- a/include/uapi/linux/netfilter/Kbuild
> +++ b/include/uapi/linux/netfilter/Kbuild
> @@ -37,6 +37,7 @@ header-y += xt_TEE.h
>   header-y += xt_TPROXY.h
>   header-y += xt_addrtype.h
>   header-y += xt_bpf.h
> +header-y += xt_cgroup.h
>   header-y += xt_cluster.h
>   header-y += xt_comment.h
>   header-y += xt_connbytes.h
> diff --git a/include/uapi/linux/netfilter/xt_cgroup.h b/include/uapi/linux/netfilter/xt_cgroup.h
> new file mode 100644
> index 0000000..43acb7e
> --- /dev/null
> +++ b/include/uapi/linux/netfilter/xt_cgroup.h
> @@ -0,0 +1,11 @@
> +#ifndef _UAPI_XT_CGROUP_H
> +#define _UAPI_XT_CGROUP_H
> +
> +#include <linux/types.h>
> +
> +struct xt_cgroup_info {
> +	__u32 id;
> +	__u32 invert;
> +};
> +
> +#endif /* _UAPI_XT_CGROUP_H */
> diff --git a/net/core/scm.c b/net/core/scm.c
> index b442e7e..f08672a 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -36,6 +36,7 @@
>   #include <net/sock.h>
>   #include <net/compat.h>
>   #include <net/scm.h>
> +#include <net/netfilter/xt_cgroup.h>
>   #include <net/cls_cgroup.h>
>
>
> @@ -290,6 +291,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
>   		/* Bump the usage count and install the file. */
>   		sock = sock_from_file(fp[i], &err);
>   		if (sock) {
> +			sock_update_fwid(sock->sk);
>   			sock_update_netprioidx(sock->sk);
>   			sock_update_classid(sock->sk);
>   		}
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 2bd9b3f..524a376 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -125,6 +125,7 @@
>   #include <linux/skbuff.h>
>   #include <net/net_namespace.h>
>   #include <net/request_sock.h>
> +#include <net/netfilter/xt_cgroup.h>
>   #include <net/sock.h>
>   #include <linux/net_tstamp.h>
>   #include <net/xfrm.h>
> @@ -1337,6 +1338,18 @@ void sock_update_netprioidx(struct sock *sk)
>   EXPORT_SYMBOL_GPL(sock_update_netprioidx);
>   #endif
>
> +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_CGROUP)
> +void sock_update_fwid(struct sock *sk)
> +{
> +	u32 fwid;
> +
> +	fwid = task_fwid(current);
> +	if (fwid != sk->sk_cgrp_fwid)
> +		sk->sk_cgrp_fwid = fwid;
> +}
> +EXPORT_SYMBOL(sock_update_fwid);
> +#endif
> +
>   /**
>    *	sk_alloc - All socket objects are allocated here
>    *	@net: the applicable net namespace
> @@ -1363,6 +1376,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>
>   		sock_update_classid(sk);
>   		sock_update_netprioidx(sk);
> +		sock_update_fwid(sk);
>   	}
>
>   	return sk;
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 6e839b6..d276ff4 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -806,6 +806,14 @@ config NETFILTER_XT_MATCH_BPF
>
>   	  To compile it as a module, choose M here.  If unsure, say N.
>
> +config NETFILTER_XT_MATCH_CGROUP
> +	tristate '"control group" match support'
> +	depends on NETFILTER_ADVANCED
> +	depends on CGROUPS
> +	---help---
> +	Socket/process control group matching allows you to match locally
> +	generated packets based on which control group processes belong to.
> +
>   config NETFILTER_XT_MATCH_CLUSTER
>   	tristate '"cluster" match support'
>   	depends on NF_CONNTRACK
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index c3a0a12..12f014f 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -124,6 +124,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_NFACCT) += xt_nfacct.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
> +obj-$(CONFIG_NETFILTER_XT_MATCH_CGROUP) += xt_cgroup.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
>   obj-$(CONFIG_NETFILTER_XT_MATCH_POLICY) += xt_policy.o
> diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
> new file mode 100644
> index 0000000..249c7ee
> --- /dev/null
> +++ b/net/netfilter/xt_cgroup.c
> @@ -0,0 +1,177 @@
> +/*
> + * Xtables module to match the process control group.
> + *
> + * Might be used to implement individual "per-application" firewall
> + * policies in contrast to global policies based on control groups.
> + *
> + * (C) 2013 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> + * (C) 2013 Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/skbuff.h>
> +#include <linux/module.h>
> +#include <linux/file.h>
> +#include <linux/cgroup.h>
> +#include <linux/fdtable.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_cgroup.h>
> +#include <net/netfilter/xt_cgroup.h>
> +#include <net/sock.h>
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>");
> +MODULE_DESCRIPTION("Xtables: process control group matching");
> +MODULE_ALIAS("ipt_cgroup");
> +MODULE_ALIAS("ip6t_cgroup");
> +
> +static int cgroup_mt_check(const struct xt_mtchk_param *par)
> +{
> +	struct xt_cgroup_info *info = par->matchinfo;
> +
> +	if (info->invert & ~1)
> +		return -EINVAL;
> +
> +	return info->id ? 0 : -EINVAL;
> +}
> +
> +static bool
> +cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
> +{
> +	const struct xt_cgroup_info *info = par->matchinfo;
> +
> +	if (skb->sk == NULL)
> +		return false;
> +
> +	return (info->id == skb->sk->sk_cgrp_fwid) ^ info->invert;
> +}
> +
> +static struct xt_match cgroup_mt_reg __read_mostly = {
> +	.name       = "cgroup",
> +	.revision   = 0,
> +	.family     = NFPROTO_UNSPEC,
> +	.checkentry = cgroup_mt_check,
> +	.match      = cgroup_mt,
> +	.matchsize  = sizeof(struct xt_cgroup_info),
> +	.me         = THIS_MODULE,
> +	.hooks      = (1 << NF_INET_LOCAL_OUT) |
> +	              (1 << NF_INET_POST_ROUTING),
> +};
> +
> +static inline struct cgroup_nf_state *
> +css_nf_state(struct cgroup_subsys_state *css)
> +{
> +	return css ? container_of(css, struct cgroup_nf_state, css) : NULL;
> +}
> +
> +static struct cgroup_subsys_state *
> +cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
> +{
> +	struct cgroup_nf_state *cs;
> +
> +	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
> +	if (!cs)
> +		return ERR_PTR(-ENOMEM);
> +
> +	return &cs->css;
> +}
> +
> +static int cgroup_css_online(struct cgroup_subsys_state *css)
> +{
> +	struct cgroup_nf_state *cs = css_nf_state(css);
> +	struct cgroup_nf_state *parent = css_nf_state(css_parent(css));
> +
> +	if (parent)
> +		cs->fwid = parent->fwid;
> +
> +	return 0;
> +}
> +
> +static void cgroup_css_free(struct cgroup_subsys_state *css)
> +{
> +	kfree(css_nf_state(css));
> +}
> +
> +static int cgroup_fwid_update(const void *v, struct file *file, unsigned n)
> +{
> +	int err;
> +	struct socket *sock = sock_from_file(file, &err);
> +
> +	if (sock)
> +		sock->sk->sk_cgrp_fwid = (u32)(unsigned long) v;
> +
> +	return 0;
> +}
> +
> +static u64 cgroup_fwid_read(struct cgroup_subsys_state *css,
> +			    struct cftype *cft)
> +{
> +	return css_nf_state(css)->fwid;
> +}
> +
> +static int cgroup_fwid_write(struct cgroup_subsys_state *css,
> +			     struct cftype *cft, u64 id)
> +{
> +	css_nf_state(css)->fwid = (u32) id;
> +
> +	return 0;
> +}
> +
> +static void cgroup_attach(struct cgroup_subsys_state *css,
> +			  struct cgroup_taskset *tset)
> +{
> +	struct cgroup_nf_state *cs = css_nf_state(css);
> +	void *v = (void *)(unsigned long) cs->fwid;
> +	struct task_struct *p;
> +
> +	cgroup_taskset_for_each(p, css, tset) {
> +		task_lock(p);
> +		iterate_fd(p->files, 0, cgroup_fwid_update, v);
> +		task_unlock(p);
> +	}
> +}
> +
> +static struct cftype net_filter_ss_files[] = {
> +	{
> +		.name		= "fwid",
> +		.read_u64	= cgroup_fwid_read,
> +		.write_u64	= cgroup_fwid_write,
> +	},
> +	{ }
> +};
> +
> +struct cgroup_subsys net_filter_subsys = {
> +	.name		= "net_filter",
> +	.css_alloc	= cgroup_css_alloc,
> +	.css_online	= cgroup_css_online,
> +	.css_free	= cgroup_css_free,
> +	.attach		= cgroup_attach,
> +	.subsys_id	= net_filter_subsys_id,
> +	.base_cftypes	= net_filter_ss_files,
> +	.module		= THIS_MODULE,
> +};
> +
> +static int __init cgroup_mt_init(void)
> +{
> +	int ret = cgroup_load_subsys(&net_filter_subsys);
> +	if (ret)
> +		goto out;
> +
> +	ret = xt_register_match(&cgroup_mt_reg);
> +	if (ret)
> +		cgroup_unload_subsys(&net_filter_subsys);
> +out:
> +	return ret;
> +}
> +
> +static void __exit cgroup_mt_exit(void)
> +{
> +	xt_unregister_match(&cgroup_mt_reg);
> +	cgroup_unload_subsys(&net_filter_subsys);
> +}
> +
> +module_init(cgroup_mt_init);
> +module_exit(cgroup_mt_exit);
>
