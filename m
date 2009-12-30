From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Wed, 30 Dec 2009 12:50:53 -0600
Message-ID: <20091230185053.GB18712@us.ibm.com>
References: <20091227010441.GA12077@heat>
 <20091227010650.GA12190@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091227010650.GA12190@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Stone (michael@laptop.org):
> Implement security_* hooks for socket_create, socket_bind, socket_connect,
> socket_sendmsg, and ptrace_access_check which return -EPERM when called from a
> process with networking restrictions. Exempt AF_UNIX sockets.
> 
> Signed-off-by: Michael Stone <michael@laptop.org>

Acked-by: Serge Hallyn <serue@us.ibm.com>

> ---
>   include/linux/disablenetwork.h |   22 +++++++++++
>   security/Makefile              |    1 +
>   security/disablenetwork.c      |   73 ++++++++++++++++++++++++++++++++++++++
>   security/security.c            |   76 +++++++++++++++++++++++++++++++++++++---
>   4 files changed, 167 insertions(+), 5 deletions(-)
>   create mode 100644 include/linux/disablenetwork.h
>   create mode 100644 security/disablenetwork.c
> 
> diff --git a/include/linux/disablenetwork.h b/include/linux/disablenetwork.h
> new file mode 100644
> index 0000000..8a7bcc2
> --- /dev/null
> +++ b/include/linux/disablenetwork.h
> @@ -0,0 +1,22 @@
> +#ifndef __LINUX_DISABLENETWORK_H
> +#define __LINUX_DISABLENETWORK_H
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +
> +int disablenetwork_security_socket_create(int family, int type,
> +					  int protocol, int kern);

Bleh, I think disablenetwork_socket_create() is long enough :)

> +int disablenetwork_security_socket_bind(struct socket *sock,
> +				        struct sockaddr *address,
> +				        int addrlen);
> +int disablenetwork_security_socket_connect(struct socket *sock,
> +				           struct sockaddr *address,
> +					   int addrlen);
> +int disablenetwork_security_socket_sendmsg(struct socket *sock,
> +					   struct msghdr *msg,
> +					   int size);
> +int disablenetwork_security_ptrace_access_check(struct task_struct *child,
> +					        unsigned int mode);
> +
> +#endif /* CONFIG_SECURITY_DISABLENETWORK */
> +
> +#endif /* ! __LINUX_DISABLENETWORK_H */
> diff --git a/security/Makefile b/security/Makefile
> index da20a19..2f23b60 100644
> --- a/security/Makefile
> +++ b/security/Makefile
> @@ -20,6 +20,7 @@ obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
>   obj-$(CONFIG_AUDIT)			+= lsm_audit.o
>   obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
>   obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
> +obj-$(CONFIG_SECURITY_DISABLENETWORK)	+= disablenetwork.o
>   
>   # Object integrity file lists
>   subdir-$(CONFIG_IMA)			+= integrity/ima
> diff --git a/security/disablenetwork.c b/security/disablenetwork.c
> new file mode 100644
> index 0000000..f45ddfc
> --- /dev/null
> +++ b/security/disablenetwork.c
> @@ -0,0 +1,73 @@
> +/*
> + * disablenetwork security hooks.
> + *
> + * Copyright (C) 2008-2009 Michael Stone <michael@laptop.org>
> + *
> + * Implements the disablenetwork discretionary access control logic underlying
> + * the prctl(PRCTL_SET_NETWORK, PR_NETWORK_OFF) interface.
> + *
> + * See Documentation/disablenetwork.txt for more information.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation, version 2 of the
> + * License.
> + */
> +
> +#include <linux/errno.h>
> +#include <linux/sched.h>
> +#include <net/sock.h>
> +#include <linux/socket.h>
> +#include <linux/disablenetwork.h>
> +
> +static inline int maybe_allow(void)
> +{
> +	if (current->network)
> +		return -EPERM;
> +	return 0;
> +}
> +
> +int disablenetwork_security_socket_create(int family, int type,
> +					  int protocol, int kern)
> +{
> +	if (family == AF_UNIX)
> +		return 0;
> +	return maybe_allow();
> +}
> +
> +int disablenetwork_security_socket_bind(struct socket * sock,
> +					struct sockaddr * address,
> +					int addrlen)
> +{
> +	if (address->sa_family == AF_UNIX)
> +		return 0;
> +	return maybe_allow();
> +}
> +
> +int disablenetwork_security_socket_connect(struct socket * sock,
> +					   struct sockaddr * address,
> +					   int addrlen)
> +{
> +	if (address->sa_family == AF_UNIX)
> +		return 0;
> +	return maybe_allow();
> +}
> +
> +int disablenetwork_security_socket_sendmsg(struct socket * sock,
> +					   struct msghdr * msg, int size)
> +{
> +	if (sock->sk->sk_family != PF_UNIX &&
> +		current->network &&
> +		(msg->msg_name != NULL || msg->msg_namelen != 0))
> +		return -EPERM;
> +	return 0;
> +}
> +
> +int disablenetwork_security_ptrace_access_check(struct task_struct *child,
> +                                                unsigned int mode)
> +{
> +	/* does current have networking restrictions not shared by child? */
> +	if (current->network & ~child->network)
> +		return -EPERM;
> +	return 0;
> +}
> diff --git a/security/security.c b/security/security.c
> index 24e060b..40ac615 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -17,6 +17,7 @@
>   #include <linux/kernel.h>
>   #include <linux/security.h>
>   #include <linux/ima.h>
> +#include <linux/disablenetwork.h>
>   
>   /* Boot-time LSM user choice */
>   static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
> @@ -130,7 +131,20 @@ int register_security(struct security_operations *ops)
>   
>   int security_ptrace_access_check(struct task_struct *child, unsigned int mode)
>   {
> -	return security_ops->ptrace_access_check(child, mode);
> +	int ret = 0;
> +
> +	ret = security_ops->ptrace_access_check(child, mode);
> +	if (ret)
> +		goto out;
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +	ret = disablenetwork_security_ptrace_access_check(child, mode);
> +	if (ret)
> +		goto out;
> +#endif
> +
> +out:
> +	return ret;
>   }
>   
>   int security_ptrace_traceme(struct task_struct *parent)
> @@ -1054,7 +1068,20 @@ EXPORT_SYMBOL(security_unix_may_send);
>   
>   int security_socket_create(int family, int type, int protocol, int kern)
>   {
> -	return security_ops->socket_create(family, type, protocol, kern);
> +	int ret = 0;
> +
> +	ret = security_ops->socket_create(family, type, protocol, kern);
> +	if (ret)
> +		goto out;
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +	ret = disablenetwork_security_socket_create(family, type, protocol, kern);
> +	if (ret)
> +		goto out;
> +#endif
> +
> +out:
> +	return ret;
>   }
>   
>   int security_socket_post_create(struct socket *sock, int family,
> @@ -1066,12 +1093,38 @@ int security_socket_post_create(struct socket *sock, int family,
>   
>   int security_socket_bind(struct socket *sock, struct sockaddr *address, int addrlen)
>   {
> -	return security_ops->socket_bind(sock, address, addrlen);
> +	int ret = 0;
> +
> +	ret = security_ops->socket_bind(sock, address, addrlen);
> +	if (ret)
> +		goto out;
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +	ret = disablenetwork_security_socket_bind(sock, address, addrlen);
> +	if (ret)
> +		goto out;
> +#endif
> +
> +out:
> +	return ret;
>   }
>   
>   int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen)
>   {
> -	return security_ops->socket_connect(sock, address, addrlen);
> +	int ret = 0;
> +
> +	ret = security_ops->socket_connect(sock, address, addrlen);
> +	if (ret)
> +		goto out;
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +	ret = disablenetwork_security_socket_connect(sock, address, addrlen);
> +	if (ret)
> +		goto out;
> +#endif
> +
> +out:
> +	return ret;
>   }
>   
>   int security_socket_listen(struct socket *sock, int backlog)
> @@ -1086,7 +1139,20 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
>   
>   int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
>   {
> -	return security_ops->socket_sendmsg(sock, msg, size);
> +	int ret = 0;
> +
> +	ret = security_ops->socket_sendmsg(sock, msg, size);
> +	if (ret)
> +		goto out;
> +
> +#ifdef CONFIG_SECURITY_DISABLENETWORK
> +	ret = disablenetwork_security_socket_sendmsg(sock, msg, size);
> +	if (ret)
> +		goto out;
> +#endif
> +
> +out:
> +	return ret;
>   }
>   
>   int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
> -- 
> 1.6.6.rc2
