From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 13/24] net: rbridge: Add set_node function
Date: Thu, 25 Sep 2014 15:34:32 +0400
Message-ID: <5423FDC8.5080901@cogentembedded.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net> <1411573940-14079-14-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:45256 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbaIYLef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 07:34:35 -0400
Received: by mail-lb0-f170.google.com with SMTP id n15so700218lbi.29
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 04:34:34 -0700 (PDT)
In-Reply-To: <1411573940-14079-14-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/24/2014 7:52 PM, Ahmed Amamou wrote:

> allow daemon to set distant Rbridges information in local database
> daemon has to periodically update distant Rbridges informations in lo=
cal database
> create a new node only if change on distant RBridge information are d=
etected

> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
> Signed-off-by: William Dauchy <william@gandi.net>
> ---
>   net/bridge/rbridge/rbr_netlink.c | 78 +++++++++++++++++++++++++++++=
+++++++++++
>   1 file changed, 78 insertions(+)

> diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rb=
r_netlink.c
> index 889e6c8..bb893f0 100644
> --- a/net/bridge/rbridge/rbr_netlink.c
> +++ b/net/bridge/rbridge/rbr_netlink.c
> @@ -38,9 +38,87 @@ static struct genl_multicast_group trill_mcgrps[] =
=3D {
>   	[TRILL_MCGRP_OFFSET] =3D {.name =3D TRILL_MCAST_NAME,},
>   };
>
> +static int create_node(struct net_bridge_port *p, struct rbr *rbr,
> +		       struct rbr_nickinfo *rbr_ni_partial,
> +		       struct genl_info *info)
> +{
> +	size_t size =3D 0;
> +	size_t old_size =3D 0;
> +	struct rbr_node *old;
> +	struct rbr_nickinfo *rbr_ni;
> +
> +	if (rbr_ni_partial =3D=3D NULL)
> +		return -EINVAL;
> +
> +	size =3D RBR_NI_TOTALSIZE(rbr_ni_partial);
> +	if (size > PAGE_SIZE - sizeof(struct trill_nl_header)) {
> +		pr_warn_ratelimited
> +		    ("create_node: size > (PAGE_SIZE-nickinfo_offset)\n");
> +		return -EINVAL;
> +	}
> +	rbr_ni =3D kzalloc(size, GFP_KERNEL);
> +	if (!rbr_ni)
> +		return -ENOMEM;
> +	old =3D rbr->rbr_nodes[rbr_ni_partial->nick];
> +	nla_memcpy(rbr_ni, info->attrs[TRILL_ATTR_BIN], size);
> +	if (old)
> +		old_size =3D RBR_NI_TOTALSIZE(old->rbr_ni);
> +	/* replace old node by a new one only if nickname information have =
changed */

    s/have/has/.

> +	if (old =3D=3D NULL || old_size !=3D size ||
> +	    memcmp(old->rbr_ni, rbr_ni, size)) {
> +		struct rbr_node *new;
> +
> +		new =3D kzalloc(sizeof(*old), GFP_KERNEL);
> +		if (!new) {
> +			kfree(rbr_ni);
> +			return -ENOMEM;
> +		}
> +		atomic_set(&new->refs, 1);
> +		new->rbr_ni =3D rbr_ni;
> +		/* avoid deleting node while it is been used for routing */

    Either "has been" or "is being".

> +		rcu_assign_pointer(rbr->rbr_nodes[rbr_ni->nick], new);
> +		if (old)
> +			rbr_node_put(old);
> +	} else {
> +		kfree(rbr_ni);
> +	}
> +
> +	return 0;
> +}
> +
>   static int trill_cmd_set_nicks_info(struct sk_buff *skb, struct gen=
l_info *info)
>   {
> +	struct trill_nl_header *trnlhdr;
> +	struct rbr_nickinfo rbr_ni;
> +	struct net_device *source_port =3D NULL;
> +	struct net *net =3D sock_net(skb->sk);
> +	struct net_bridge_port *p =3D NULL;
> +	int err =3D -EINVAL;
> +
> +	nla_memcpy(&rbr_ni, info->attrs[TRILL_ATTR_BIN], sizeof(rbr_ni));
> +	if (!VALID_NICK(rbr_ni.nick))
> +		goto fail;
> +
> +	trnlhdr =3D info->userhdr;
> +	if (trnlhdr->ifindex)
> +		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
> +
> +	if (!source_port)
> +		goto fail;
> +
> +	p =3D br_port_get_rcu(source_port);
> +	if (!p || !(p->br) || !(p->br->rbr))

    Inner parens not needed.

> +		goto fail;
> +
> +	err =3D create_node(p, p->br->rbr, &rbr_ni, info);
> +	if (err)
> +		goto fail;
> +
>   	return 0;
> +
> + fail:
> +	printk(KERN_WARNING "trill_cmd_set_nicks_info FAILED\n");

    pr_warn().

[...]

WBR, Sergei
