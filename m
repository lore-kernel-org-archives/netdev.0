From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 net-next 2/4] sock: ULP infrastructure
Date: Thu, 3 Aug 2017 16:26:15 -0700 (PDT)
Message-ID: <alpine.OSX.2.21.1708031542480.29414@herbergs-mobl.ger.corp.intel.com>
References: <20170803193144.24108-1-tom@quantonium.net> <20170803193144.24108-3-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, rohit@quantonium.net, davejwatson@fb.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64993 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752087AbdHCX0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 19:26:16 -0400
In-Reply-To: <20170803193144.24108-3-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 3 Aug 2017, Tom Herbert wrote:

> Generalize the TCP ULP infrastructure recently introduced to support
> kTLS. This adds a SO_ULP socket option and creates new fields in
> sock structure for ULP ops and ULP data. Also, the interface allows
> additional per ULP parameters to be set so that a ULP can be pushed
> and operations started in one shot.
>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
> arch/alpha/include/uapi/asm/socket.h   |   2 +
> arch/frv/include/uapi/asm/socket.h     |   2 +
> arch/ia64/include/uapi/asm/socket.h    |   2 +
> arch/m32r/include/uapi/asm/socket.h    |   2 +
> arch/mips/include/uapi/asm/socket.h    |   2 +
> arch/mn10300/include/uapi/asm/socket.h |   2 +
> arch/parisc/include/uapi/asm/socket.h  |   2 +
> arch/s390/include/uapi/asm/socket.h    |   2 +
> arch/sparc/include/uapi/asm/socket.h   |   2 +
> arch/xtensa/include/uapi/asm/socket.h  |   2 +
> include/linux/socket.h                 |   9 ++
> include/net/sock.h                     |   5 +
> include/net/ulp_sock.h                 |  75 +++++++++++++
> include/uapi/asm-generic/socket.h      |   2 +
> net/Kconfig                            |   4 +
> net/core/Makefile                      |   1 +
> net/core/sock.c                        |  14 +++
> net/core/sysctl_net_core.c             |  25 +++++
> net/core/ulp_sock.c                    | 194 +++++++++++++++++++++++++++++++++
> 19 files changed, 349 insertions(+)
> create mode 100644 include/net/ulp_sock.h
> create mode 100644 net/core/ulp_sock.c
>

...

> diff --git a/include/net/ulp_sock.h b/include/net/ulp_sock.h
> new file mode 100644
> index 000000000000..37bf4d2e16b9
> --- /dev/null
> +++ b/include/net/ulp_sock.h
> @@ -0,0 +1,75 @@
> +/*
> + * Pluggable upper layer protocol support in sockets.
> + *
> + * Copyright (c) 2016-2017, Mellanox Technologies. All rights reserved.
> + * Copyright (c) 2016-2017, Dave Watson <davejwatson@fb.com>. All rights reserved.
> + * Copyright (c) 2017, Tom Herbert <tom@quantonium.net>. All rights reserved.
> + *
> + */
> +
> +#ifndef __NET_ULP_SOCK_H
> +#define __NET_ULP_SOCK_H
> +
> +#include <linux/socket.h>
> +
> +#define ULP_MAX             128
> +#define ULP_BUF_MAX         (ULP_NAME_MAX * ULP_MAX)
> +
> +struct ulp_ops {
> +	struct list_head list;
> +
> +	/* initialize ulp */
> +	int (*init)(struct sock *sk, char __user *optval, int len);
> +
> +	/* cleanup ulp */
> +	void (*release)(struct sock *sk);
> +
> +	/* Get ULP specific parameters in getsockopt */
> +	int (*get_params)(struct sock *sk, char __user *optval, int *optlen);
> +
> +	char name[ULP_NAME_MAX];
> +	struct module *owner;
> +};
> +
> +#ifdef CONFIG_ULP_SOCK
> +
> +int ulp_register(struct ulp_ops *type);
> +void ulp_unregister(struct ulp_ops *type);
> +int ulp_set(struct sock *sk, char __user *optval, int len);
> +int ulp_get_config(struct sock *sk, char __user *optval, int *optlen);
> +void ulp_get_available(char *buf, size_t len);
> +void ulp_cleanup(struct sock *sk);
> +
> +#else
> +
> +static inline int ulp_register(struct ulp_ops *type)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static inline void ulp_unregister(struct ulp_ops *type)
> +{
> +}
> +
> +static inline int ulp_set(struct sock *sk, char __user *optval, int len)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static inline int ulp_get_config(struct sock *sk, char __user *optval,
> +				 int *optlen)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static inline void ulp_get_available(char *buf, size_t len)
> +{

proc_ulp_available() doesn't initialize *buf, so the string needs to be 
NUL-terminated here.

> +}
> +
> +static inline void ulp_cleanup(struct sock *sk)
> +{
> +}
> +
> +#endif
> +
> +#endif /* __NET_ULP_SOCK_H */

...

> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index b7cd9aafe99e..9e14f91b57eb 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -21,6 +21,7 @@
> #include <net/net_ratelimit.h>
> #include <net/busy_poll.h>
> #include <net/pkt_sched.h>
> +#include <net/ulp_sock.h>
>
> static int zero = 0;
> static int one = 1;
> @@ -249,6 +250,24 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
> 	return proc_dostring(&fake_table, write, buffer, lenp, ppos);
> }
>
> +static int proc_ulp_available(struct ctl_table *ctl,
> +			      int write,
> +			      void __user *buffer, size_t *lenp,
> +			      loff_t *ppos)
> +{
> +	struct ctl_table tbl = { .maxlen = ULP_BUF_MAX, };
> +	int ret;
> +
> +	tbl.data = kmalloc(tbl.maxlen, GFP_USER);

(Just flagging this to provide context for the uninitialized data comment 
above)

> +	if (!tbl.data)
> +		return -ENOMEM;
> +	ulp_get_available(tbl.data, ULP_BUF_MAX);
> +	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
> +	kfree(tbl.data);
> +
> +	return ret;
> +}
> +
> static struct ctl_table net_core_table[] = {
> #ifdef CONFIG_NET
> 	{
> @@ -460,6 +479,12 @@ static struct ctl_table net_core_table[] = {
> 		.proc_handler	= proc_dointvec_minmax,
> 		.extra1		= &zero,
> 	},
> +	{
> +		.procname	= "ulp_available",
> +		.maxlen		= ULP_BUF_MAX,
> +		.mode		= 0444,
> +		.proc_handler	= proc_ulp_available,
> +	},
> 	{ }
> };
>


Regards,
