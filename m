From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 19 Jun 2015 15:43:31 +0100
Message-ID: <55842A93.2040607@brocade.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>,
	<tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47752 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751391AbbFSOoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 10:44:17 -0400
In-Reply-To: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 05:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> provides ops to parse, build and output encaped
> packets for drivers that want to attach tunnel encap
> information to routes.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   include/linux/lwtunnel.h      |    6 ++
>   include/net/lwtunnel.h        |   84 +++++++++++++++++++++
>   include/uapi/linux/lwtunnel.h |   11 +++
>   net/Kconfig                   |    5 ++
>   net/core/Makefile             |    1 +
>   net/core/lwtunnel.c           |  162 +++++++++++++++++++++++++++++++++++++++++
>   6 files changed, 269 insertions(+)
>   create mode 100644 include/linux/lwtunnel.h
>   create mode 100644 include/net/lwtunnel.h
>   create mode 100644 include/uapi/linux/lwtunnel.h
>   create mode 100644 net/core/lwtunnel.c
>
> diff --git a/include/linux/lwtunnel.h b/include/linux/lwtunnel.h
> new file mode 100644
> index 0000000..97f32f8
> --- /dev/null
> +++ b/include/linux/lwtunnel.h
> @@ -0,0 +1,6 @@
> +#ifndef _LINUX_LWTUNNEL_H_
> +#define _LINUX_LWTUNNEL_H_
> +
> +#include <uapi/linux/lwtunnel.h>
> +
> +#endif /* _LINUX_LWTUNNEL_H_ */
> diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
> new file mode 100644
> index 0000000..649da3c
> --- /dev/null
> +++ b/include/net/lwtunnel.h
> @@ -0,0 +1,84 @@
> +#ifndef __NET_LWTUNNEL_H
> +#define __NET_LWTUNNEL_H 1
> +
> +#include <linux/lwtunnel.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/types.h>
> +#include <net/dsfield.h>
> +#include <net/ip.h>
> +#include <net/rtnetlink.h>
> +
> +#define LWTUNNEL_HASH_BITS   7
> +#define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
> +
> +struct lwtunnel_hdr {
> +	int             len;
> +	__u8            data[0];
> +};
> +
> +/* lw tunnel state flags */
> +#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
> +
> +#define lwtunnel_output_redirect(lwtstate) (lwtstate && \
> +			(lwtstate->flags & LWTUNNEL_STATE_OUTPUT_REDIRECT))

This could be made an inline function for type-safety.

> +
> +struct lwtunnel_state {
> +	__u16		type;
> +	__u16		flags;
> +	atomic_t	refcnt;
> +	struct lwtunnel_hdr tunnel;
> +};
> +
> +struct lwtunnel_net {
> +	struct hlist_head tunnels[LWTUNNEL_HASH_SIZE];
> +};

This type doesn't appear to be used in this patch series. Do you intend 
to use it in a future version?

> +
> +struct lwtunnel_encap_ops {
> +	int (*build_state)(struct net_device *dev, struct nlattr *encap,
> +			   struct lwtunnel_state **ts);
> +	int (*output)(struct sock *sk, struct sk_buff *skb);
> +	int (*fill_encap)(struct sk_buff *skb,
> +			  struct lwtunnel_state *lwtstate);
> +	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
> +};
> +
> +#define MAX_LWTUNNEL_ENCAP_OPS 8
> +extern const struct lwtunnel_encap_ops __rcu *
> +		lwtun_encaps[MAX_LWTUNNEL_ENCAP_OPS];
> +
> +static inline void lwtunnel_state_get(struct lwtunnel_state *lws)
> +{
> +	atomic_inc(&lws->refcnt);
> +}
> +
> +static inline void lwtunnel_state_put(struct lwtunnel_state *lws)
> +{
> +	if (!lws)
> +		return;
> +
> +	if (atomic_dec_and_test(&lws->refcnt))
> +		kfree(lws);
> +}
> +
> +static inline struct lwtunnel_state *lwtunnel_skb_lwstate(struct sk_buff *skb)
> +{
> +	struct rtable *rt = (struct rtable *)skb_dst(skb);
> +
> +	return rt->rt_lwtstate;
> +}

It doesn't look like this patch will build on its own because 
rt_lwtstate isn't added to struct rtable until patch 2.

More importantly, is it safe to assume that skb_dst will always return 
an IPv4 dst? How will this look when IPv6 support is added?

> +
> +int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
> +			   unsigned int num);
> +int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
> +			   unsigned int num);
> +int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
> +			 struct nlattr *encap,
> +			 struct lwtunnel_state **lws);
> +int lwtunnel_fill_encap(struct sk_buff *skb,
> +			struct lwtunnel_state *lwtstate);
> +int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
> +struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
> +int lwtunnel_output(struct sock *sk, struct sk_buff *skb);
> +
> +#endif /* __NET_LWTUNNEL_H */
...
> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
> new file mode 100644
> index 0000000..29c7802
> --- /dev/null
> +++ b/net/core/lwtunnel.c
> @@ -0,0 +1,162 @@
> +/*
> + * lwtunnel	Infrastructure for light weight tunnels like mpls
> + *
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/capability.h>
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +#include <linux/in.h>
> +#include <linux/init.h>
> +#include <linux/err.h>
> +
> +#include <net/lwtunnel.h>
> +#include <net/rtnetlink.h>
> +
> +struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
> +{
> +	struct lwtunnel_state *lws;
> +
> +	return kzalloc(sizeof(*lws) + hdr_len, GFP_KERNEL);
> +}
> +EXPORT_SYMBOL(lwtunnel_state_alloc);
> +
> +const struct lwtunnel_encap_ops __rcu *
> +		lwtun_encaps[MAX_LWTUNNEL_ENCAP_OPS] __read_mostly;
> +
> +int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
> +			   unsigned int num)
> +{
> +	if (num >= MAX_LWTUNNEL_ENCAP_OPS)
> +		return -ERANGE;
> +
> +	return !cmpxchg((const struct lwtunnel_encap_ops **)
> +			&lwtun_encaps[num],
> +			NULL, ops) ? 0 : -1;
> +}
> +EXPORT_SYMBOL(lwtunnel_encap_add_ops);
> +
> +int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
> +			   unsigned int num)
> +{
> +	int ret;
> +
> +	if (num >= MAX_LWTUNNEL_ENCAP_OPS)
> +		return -ERANGE;
> +
> +	ret = (cmpxchg((const struct lwtunnel_encap_ops **)
> +		       &lwtun_encaps[num],
> +		       ops, NULL) == ops) ? 0 : -1;
> +
> +	synchronize_net();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_encap_del_ops);
> +
> +int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
> +			 struct nlattr *encap, struct lwtunnel_state **lws)
> +{
> +	const struct lwtunnel_encap_ops *ops;
> +	int ret = -EINVAL;
> +
> +	if (encap_type == LWTUNNEL_ENCAP_NONE ||
> +	    encap_type >= MAX_LWTUNNEL_ENCAP_OPS)
> +		return ret;
> +
> +	ret = -EOPNOTSUPP;
> +	rcu_read_lock();
> +	ops = rcu_dereference(lwtun_encaps[encap_type]);
> +	if (likely(ops && ops->build_state))
> +		ret = ops->build_state(dev, encap, lws);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_build_state);
> +
> +int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
> +{
> +	const struct lwtunnel_encap_ops *ops;
> +	struct nlattr *nest;
> +	int ret = -EINVAL;
> +
> +	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
> +	    lwtstate->type >= MAX_LWTUNNEL_ENCAP_OPS)
> +		return 0;
> +
> +	ret = -EOPNOTSUPP;
> +	nest = nla_nest_start(skb, RTA_ENCAP);

Again, it doesn't look like this will build since RTA_ENCAP isn't added 
until patch 2.

Thanks,
Rob
