From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 07 Jan 2009 14:01:10 +0800
Message-ID: <49644526.8030205@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090106230554.GB25228-IaEwMO9oKu/77SC2UrCW1JJg/dWx8T/9@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

I'll review the cgroup part if this patch is regarded as useful.

Grzegorz Nosek wrote:
> This is a very simple cgroup subsystem to restrict IP addresses used
> by member processes. Currently it is limited to IPv4 only but IPv6 (or
> other protocols) should be easy to implement.
> 
> IP addresses are write-once (via /cgroup/.../ipaddr.ipv4 in dotted-quad

Why they should be write-once ?

> format) and are inherited by descendant cgroups, so a process once
> restricted should never be able to get rid of the limits. Any address
> may be specified in multiple cgroups. No verification is done to ensure
> the addresses are actually configured on the machine, which has its
> advantages (may add the addresses later) and disadvantages (if you enter
> the wrong address, the cgroup will be effectively cut off from the
> network).
> 
> Whenever a process inside a restricted cgroup calls bind(2), the address
> is checked like this:
>  - INADDR_LOOPBACK is explicitly allowed (a special case)
>  - INADDR_ANY is remapped to _the_ IP address
>  - _the_ IP address is passed through unharmed
>  - everything else causes -EPERM
> 
> When a process calls connect(2), this subsystem calls bind(_the_IP_)
> quietly behind its back, while preserving the original bound port (if
> any).
> 
> Rationale (or when/why would you want it):
> The use case for ipaddr_cgroup doesn't overlap with network namespaces,
> which also allow IP address restrictions, because it aims to be much
> lighter due to its limited scope (hopefully able to easily support
> hundreds or possibly thousands of distinct cgroups). It does not attempt
> to hide the existence of other IP addresses from the user.
> 
> Signed-off-by: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
> ---
> 
> This is more of an RFC than a finished patch so any and all comments are
> appreciated.
> 
> The patch is based to a significant extent on the device_cgroup code,
> including bypassing the security infrastructure and hooking directly
> into the networking code.
> 
> I'd also love to hear your opinion about locking--I have a version of this
> patch that uses a seqlock to protect the IP address but I'm not sure this
> is the Right Way to do it (and raw non-atomic lockless access looks scary,
> regardless of how rarely would the address be changed, i.e. at most
> once).
> 
> And of course, if the whole idea is stupid, let me know.
> 
>  include/linux/cgroup_subsys.h |    6 ++
>  include/linux/ipaddr_cgroup.h |   23 +++++
>  init/Kconfig                  |    7 ++
>  net/socket.c                  |   16 +++-
>  security/Makefile             |    1 +
>  security/ipaddr_cgroup.c      |  200 +++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 250 insertions(+), 3 deletions(-)
>  create mode 100644 include/linux/ipaddr_cgroup.h
>  create mode 100644 security/ipaddr_cgroup.c
> 
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index 9c22396..70dd375 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -54,3 +54,9 @@ SUBSYS(freezer)
>  #endif
>  
>  /* */
> +
> +#ifdef CONFIG_CGROUP_IPADDR
> +SUBSYS(ipaddr)
> +#endif
> +
> +/* */
> diff --git a/include/linux/ipaddr_cgroup.h b/include/linux/ipaddr_cgroup.h
> new file mode 100644
> index 0000000..19dc382
> --- /dev/null
> +++ b/include/linux/ipaddr_cgroup.h
> @@ -0,0 +1,23 @@
> +#ifndef HAVE_IPADDR_CGROUP_H
> +#define HAVE_IPADDR_CGROUP_H
> +
> +struct socket;
> +struct sockaddr;
> +
> +#ifdef CONFIG_CGROUP_IPADDR
> +int ipaddr_cgroup_connect(struct socket *sock, struct sockaddr *address, int addrlen);
> +int ipaddr_cgroup_bind(struct socket *sock, struct sockaddr *address, int addrlen);
> +
> +#else
> +static inline int ipaddr_cgroup_connect(struct socket *sock, struct sockaddr *address, int addrlen)
> +{
> +	return 0;
> +}
> +
> +static inline int ipaddr_cgroup_bind(struct socket *sock, struct sockaddr *address, int addrlen)
> +{
> +	return 0;
> +}
> +
> +#endif /* CONFIG_CGROUP_IPADDR */
> +#endif /* HAVE_IPADDR_CGROUP_H */
> diff --git a/init/Kconfig b/init/Kconfig
> index 35d87b9..db43344 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -338,6 +338,13 @@ config CGROUP_DEVICE
>  	  Provides a cgroup implementing whitelists for devices which
>  	  a process in the cgroup can mknod or open.
>  
> +config CGROUP_IPADDR
> +	bool "IP address controller for cgroups"
> +	depends on CGROUPS && EXPERIMENTAL
> +	help
> +	  Provides a cgroup restricting IP addresses its member processes
> +	  can use.
> +
>  config CPUSETS
>  	bool "Cpuset support"
>  	depends on SMP && CGROUPS
> diff --git a/net/socket.c b/net/socket.c
> index 3e8d4e3..3bd8c08 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -87,6 +87,7 @@
>  #include <linux/audit.h>
>  #include <linux/wireless.h>
>  #include <linux/nsproxy.h>
> +#include <linux/ipaddr_cgroup.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/unistd.h>
> @@ -1375,9 +1376,13 @@ asmlinkage long sys_bind(int fd, struct sockaddr __user *umyaddr, int addrlen)
>  	if (sock) {
>  		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
>  		if (err >= 0) {
> -			err = security_socket_bind(sock,
> -						   (struct sockaddr *)&address,
> -						   addrlen);
> +			err = ipaddr_cgroup_bind(sock,
> +						 (struct sockaddr *)&address,
> +						 addrlen);
> +			if (!err)
> +				err = security_socket_bind(sock,
> +							   (struct sockaddr *)&address,
> +							   addrlen);
>  			if (!err)
>  				err = sock->ops->bind(sock,
>  						      (struct sockaddr *)
> @@ -1600,6 +1605,11 @@ asmlinkage long sys_connect(int fd, struct sockaddr __user *uservaddr,
>  		goto out_put;
>  
>  	err =
> +	    ipaddr_cgroup_connect(sock, (struct sockaddr *)&address, addrlen);
> +	if (err)
> +		goto out_put;
> +
> +	err =
>  	    security_socket_connect(sock, (struct sockaddr *)&address, addrlen);
>  	if (err)
>  		goto out_put;
> diff --git a/security/Makefile b/security/Makefile
> index f654260..aaf225e 100644
> --- a/security/Makefile
> +++ b/security/Makefile
> @@ -16,3 +16,4 @@ obj-$(CONFIG_SECURITY_SELINUX)		+= selinux/built-in.o
>  obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
>  obj-$(CONFIG_SECURITY_ROOTPLUG)		+= root_plug.o
>  obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
> +obj-$(CONFIG_CGROUP_IPADDR)		+= ipaddr_cgroup.o
> diff --git a/security/ipaddr_cgroup.c b/security/ipaddr_cgroup.c
> new file mode 100644
> index 0000000..96ccf27
> --- /dev/null
> +++ b/security/ipaddr_cgroup.c
> @@ -0,0 +1,200 @@
> +/*
> + * IP address cgroup subsystem
> + */
> +
> +#include <linux/ipaddr_cgroup.h>
> +
> +#include <linux/cgroup.h>
> +#include <linux/err.h>
> +#include <linux/in.h>
> +#include <linux/inet.h>
> +#include <linux/seq_file.h>
> +#include <linux/socket.h>
> +
> +#include <net/inet_sock.h>
> +
> +struct ipaddr_cgroup {
> +	struct cgroup_subsys_state css;
> +	u32 ipv4_addr;
> +};
> +
> +static inline struct ipaddr_cgroup *css_to_ipcgroup(struct cgroup_subsys_state *s)
> +{
> +	return container_of(s, struct ipaddr_cgroup, css);
> +}
> +
> +static inline struct ipaddr_cgroup *cgroup_to_ipcgroup(struct cgroup *cgroup)
> +{
> +	return css_to_ipcgroup(cgroup_subsys_state(cgroup, ipaddr_subsys_id));
> +}
> +
> +static inline struct ipaddr_cgroup *task_ipcgroup(struct task_struct *task)
> +{
> +	return css_to_ipcgroup(task_subsys_state(task, ipaddr_subsys_id));
> +}
> +
> +struct cgroup_subsys ipaddr_subsys;
> +
> +static int ipcgroup_can_attach(struct cgroup_subsys *ss,
> +		struct cgroup *new_cgroup, struct task_struct *task)
> +{
> +	struct ipaddr_cgroup *old_ipcgroup, *new_ipcgroup;
> +	u32 old_ipv4;
> +
> +	if (current != task && !capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	old_ipcgroup = task_ipcgroup(task);
> +	new_ipcgroup = cgroup_to_ipcgroup(new_cgroup);
> +	old_ipv4 = old_ipcgroup->ipv4_addr;
> +
> +	if (old_ipv4 != INADDR_ANY && old_ipv4 != new_ipcgroup->ipv4_addr)
> +		return -EPERM;
> +
> +	return 0;
> +}
> +
> +static struct cgroup_subsys_state *ipcgroup_create(struct cgroup_subsys *ss,
> +						struct cgroup *cgroup)
> +{
> +	struct ipaddr_cgroup *ipcgroup, *parent_ipcgroup;
> +	struct cgroup *parent_cgroup;
> +
> +	ipcgroup = kzalloc(sizeof(*ipcgroup), GFP_KERNEL);
> +	if (!ipcgroup)
> +		return ERR_PTR(-ENOMEM);
> +	parent_cgroup = cgroup->parent;
> +
> +	if (parent_cgroup == NULL) {
> +		ipcgroup->ipv4_addr = htonl(INADDR_ANY);
> +	} else {
> +		parent_ipcgroup = cgroup_to_ipcgroup(parent_cgroup);
> +		ipcgroup->ipv4_addr = parent_ipcgroup->ipv4_addr;
> +	}
> +
> +	return &ipcgroup->css;
> +}
> +
> +static void ipcgroup_destroy(struct cgroup_subsys *ss,
> +			struct cgroup *cgroup)
> +{
> +	struct ipaddr_cgroup *ipcgroup;
> +
> +	ipcgroup = cgroup_to_ipcgroup(cgroup);
> +	kfree(ipcgroup);
> +}
> +
> +static int ipcgroup_write_ipv4(struct cgroup *cgrp, struct cftype *cft,
> +			const char *buffer)
> +{
> +	u32 new_addr;
> +	struct ipaddr_cgroup *ipcgroup;
> +	int ret;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	ipcgroup = cgroup_to_ipcgroup(cgrp);
> +	if (ipcgroup->ipv4_addr != htonl(INADDR_ANY))
> +		return -EPERM;
> +
> +	ret = in4_pton(buffer, -1, (u8 *)&new_addr, '\0', NULL);
> +	if (!ret)
> +		return -EINVAL;
> +
> +	/* already network-endian */
> +	ipcgroup->ipv4_addr = new_addr;
> +	return 0;
> +}
> +
> +static int ipcgroup_read_ipv4(struct cgroup *cgrp, struct cftype *cft,
> +			struct seq_file *m)
> +{
> +	struct ipaddr_cgroup *ipcgroup;
> +
> +	ipcgroup = cgroup_to_ipcgroup(cgrp);
> +	seq_printf(m, NIPQUAD_FMT "\n", NIPQUAD(ipcgroup->ipv4_addr));
> +	return 0;
> +}
> +
> +static struct cftype ipaddr_cgroup_files[] = {
> +	{
> +		.name = "ipv4",
> +		.write_string = ipcgroup_write_ipv4,
> +		.read_seq_string = ipcgroup_read_ipv4,
> +	},
> +};
> +
> +static int ipcgroup_populate(struct cgroup_subsys *ss,
> +				struct cgroup *cgroup)
> +{
> +	return cgroup_add_files(cgroup, ss, ipaddr_cgroup_files,
> +					ARRAY_SIZE(ipaddr_cgroup_files));
> +}
> +
> +struct cgroup_subsys ipaddr_subsys = {
> +	.name = "ipaddr",
> +	.can_attach = ipcgroup_can_attach,
> +	.create = ipcgroup_create,
> +	.destroy = ipcgroup_destroy,
> +	.populate = ipcgroup_populate,
> +	.subsys_id = ipaddr_subsys_id
> +};
> +
> +int ipaddr_cgroup_connect(struct socket *sock, struct sockaddr *address, int addrlen)
> +{
> +	struct sockaddr_in sa_in;
> +	struct ipaddr_cgroup *ipcgroup;
> +	struct inet_sock *inet;
> +	int err;
> +
> +	if (address->sa_family != AF_INET)
> +		return 0;
> +
> +	ipcgroup = task_ipcgroup(current);
> +	if (ipcgroup->ipv4_addr == htonl(INADDR_ANY))
> +		return 0;
> +
> +	inet = inet_sk(sock->sk);
> +
> +	sa_in.sin_family = AF_INET;
> +	sa_in.sin_addr.s_addr = ipcgroup->ipv4_addr;
> +	sa_in.sin_port = inet->sport;
> +
> +	err = security_socket_bind(sock, (struct sockaddr *)&sa_in, sizeof(sa_in));
> +	if (err)
> +		return err;
> +
> +	err = sock->ops->bind(sock, (struct sockaddr *)&sa_in, sizeof(sa_in));
> +
> +	return err;
> +}
> +
> +int ipaddr_cgroup_bind(struct socket *sock, struct sockaddr *address, int addrlen)
> +{
> +	struct sockaddr_in *sa_in;
> +	struct ipaddr_cgroup *ipcgroup;
> +
> +	if (address->sa_family != AF_INET)
> +		return 0;
> +
> +	ipcgroup = task_ipcgroup(current);
> +	if (ipcgroup->ipv4_addr == htonl(INADDR_ANY))
> +		return 0;
> +
> +	sa_in = (struct sockaddr_in *) address;
> +
> +	/* remap INADDR_ANY to cgroup IP address */
> +	if (sa_in->sin_addr.s_addr == htonl(INADDR_ANY))
> +		sa_in->sin_addr.s_addr = ipcgroup->ipv4_addr;
> +
> +	/* a very special case */
> +	if (sa_in->sin_addr.s_addr == htonl(INADDR_LOOPBACK))
> +		return 0;
> +
> +	if (sa_in->sin_addr.s_addr == ipcgroup->ipv4_addr)
> +		return 0;
> +
> +	return -EPERM;
> +}
> +
