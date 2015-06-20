From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light weight tunnels
Date: Sat, 20 Jun 2015 19:38:57 +0300
Message-ID: <B5595950-0AF1-4141-A7FA-2C0CB11950D3@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34972 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbbFTQjC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 12:39:02 -0400
Received: by wgbhy7 with SMTP id hy7so110867954wgb.2
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 09:39:00 -0700 (PDT)
In-Reply-To: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


<<<snip>>>
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

This seems to be called with rcu_read_lock so GFP_ATOMIC  would have to
be used. (Judging by patch 3/3=E2=80=99s mpls_build_state and lwtunnel_=
build_state)

> +}
> +EXPORT_SYMBOL(lwtunnel_state_alloc);
> +
> +const struct lwtunnel_encap_ops __rcu *
> +		lwtun_encaps[MAX_LWTUNNEL_ENCAP_OPS] __read_mostly;
> +
> +int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
> +			   unsigned int num)
> +{
> +	if (num >=3D MAX_LWTUNNEL_ENCAP_OPS)
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
> +	if (num >=3D MAX_LWTUNNEL_ENCAP_OPS)
> +		return -ERANGE;
> +
> +	ret =3D (cmpxchg((const struct lwtunnel_encap_ops **)
> +		       &lwtun_encaps[num],
> +		       ops, NULL) =3D=3D ops) ? 0 : -1;
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
> +	int ret =3D -EINVAL;
> +
> +	if (encap_type =3D=3D LWTUNNEL_ENCAP_NONE ||
> +	    encap_type >=3D MAX_LWTUNNEL_ENCAP_OPS)
> +		return ret;
> +
> +	ret =3D -EOPNOTSUPP;
> +	rcu_read_lock();
> +	ops =3D rcu_dereference(lwtun_encaps[encap_type]);
> +	if (likely(ops && ops->build_state))
> +		ret =3D ops->build_state(dev, encap, lws);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_build_state);
> +
> +int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *=
lwtstate)
> +{
> +	const struct lwtunnel_encap_ops *ops;
> +	struct nlattr *nest;
> +	int ret =3D -EINVAL;
> +
> +	if (lwtstate->type =3D=3D LWTUNNEL_ENCAP_NONE ||
> +	    lwtstate->type >=3D MAX_LWTUNNEL_ENCAP_OPS)
> +		return 0;
> +
> +	ret =3D -EOPNOTSUPP;
> +	nest =3D nla_nest_start(skb, RTA_ENCAP);
> +	rcu_read_lock();
> +	ops =3D rcu_dereference(lwtun_encaps[lwtstate->type]);
> +	if (likely(ops && ops->fill_encap))
> +		ret =3D ops->fill_encap(skb, lwtstate);
> +	rcu_read_unlock();
> +
> +	if (ret)
> +		goto errout;
> +
> +	nla_nest_end(skb, nest);
> +
> +	return 0;
> +
> +errout:
> +	nla_nest_cancel(skb, nest);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_fill_encap);
> +
> +int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate)
> +{
> +	const struct lwtunnel_encap_ops *ops;
> +	int ret =3D 0;
> +
> +	if (lwtstate->type =3D=3D LWTUNNEL_ENCAP_NONE ||
> +	    lwtstate->type >=3D MAX_LWTUNNEL_ENCAP_OPS)
> +		return 0;
> +
> +	rcu_read_lock();
> +	ops =3D rcu_dereference(lwtun_encaps[lwtstate->type]);
> +	if (likely(ops && ops->get_encap_size))
> +		ret =3D nla_total_size(ops->get_encap_size(lwtstate));
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_get_encap_size);
> +
> +int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
> +{
> +	const struct lwtunnel_encap_ops *ops;
> +	struct lwtunnel_state *lwtstate =3D lwtunnel_skb_lwstate(skb);
> +	int ret =3D 0;
> +
> +	if (!lwtstate)
> +		return -EINVAL;
> +
> +	if (lwtstate->type =3D=3D LWTUNNEL_ENCAP_NONE ||
> +	    lwtstate->type >=3D MAX_LWTUNNEL_ENCAP_OPS)
> +		return 0;
> +
> +	rcu_read_lock();
> +	ops =3D rcu_dereference(lwtun_encaps[lwtstate->type]);
> +	if (likely(ops && ops->output))
> +		ret =3D ops->output(sk, skb);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(lwtunnel_output);
> --=20
> 1.7.10.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
