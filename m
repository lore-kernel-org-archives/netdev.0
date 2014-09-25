From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 10/24] net: rbridge: Add elected dtroot
Date: Thu, 25 Sep 2014 15:30:58 +0400
Message-ID: <5423FCF2.6000303@cogentembedded.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net> <1411573940-14079-11-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:54143 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaIYLbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 07:31:02 -0400
Received: by mail-la0-f54.google.com with SMTP id ge10so12078330lab.41
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 04:31:00 -0700 (PDT)
In-Reply-To: <1411573940-14079-11-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/24/2014 7:52 PM, Ahmed Amamou wrote:

> provide function to get the locally elected distributed tree root fro=
m the daemon
> in TRILL RFC multiple tree root can be elected but this is not mendat=
ory
> for this first version we use a unique distributed tree root

> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
> Signed-off-by: William Dauchy <william@gandi.net>
> ---
>   net/bridge/br_private.h          |  1 +
>   net/bridge/rbridge/rbr.c         | 17 +++++++++++++++++
>   net/bridge/rbridge/rbr_netlink.c | 21 +++++++++++++++++++++
>   3 files changed, 39 insertions(+)

[...]
> diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
> index 41d47db..8d6d37e 100644
> --- a/net/bridge/rbridge/rbr.c
> +++ b/net/bridge/rbridge/rbr.c
> @@ -76,3 +76,20 @@ void br_trill_set_enabled(struct net_bridge *br, u=
nsigned long val)
>   			br_trill_stop(br);
>   	}
>   }
> +
> +int set_treeroot(struct rbr *rbr, uint16_t treeroot)
> +{
> +	if (unlikely(!VALID_NICK(treeroot))) {
> +		pr_warn_ratelimited
> +		    ("rbr_set_treeroot: given tree root not valid\n");
> +		goto set_tree_root_fail;
> +	}
> +	if (rbr->treeroot !=3D treeroot) {
> +		spin_lock_bh(&rbr->br->lock);
> +		rbr->treeroot =3D treeroot;
> +		spin_unlock_bh(&rbr->br->lock);

    I think the assignment is already atomic.

> +	}
> +	return 0;

    Empty line wouldn't hurt here...

> + set_tree_root_fail:
> +	return ENOENT;
> +}
> diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rb=
r_netlink.c
> index ccba5ae..889e6c8 100644
> --- a/net/bridge/rbridge/rbr_netlink.c
> +++ b/net/bridge/rbridge/rbr_netlink.c
> @@ -56,7 +56,28 @@ static int trill_cmd_add_nicks_info(struct sk_buff=
 *skb, struct genl_info *info)
>   static int trill_cmd_set_treeroot_id(struct sk_buff *skb,
>   				     struct genl_info *info)
>   {
> +	int err =3D -EINVAL;
> +	u16 nickname;
> +	struct trill_nl_header *trnlhdr;
> +	struct net_device *source_port =3D NULL;
> +	struct net *net =3D sock_net(skb->sk);
> +	struct net_bridge_port *p =3D NULL;

    Need empty line here.

> +	nickname =3D nla_get_u16(info->attrs[TRILL_ATTR_U16]);
> +	trnlhdr =3D info->userhdr;
> +	if (trnlhdr->ifindex)
> +		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
> +	if (!source_port)
> +		goto fail;
> +	p =3D br_port_get_rcu(source_port);
> +	if (!p || !(p->br) || !(p->br->rbr))

    Inner () not needed.

> +		goto fail;
> +	err =3D set_treeroot(p->br->rbr, htons(nickname));
> +	if (err)
> +		goto fail;
>   	return 0;

    Empty lien wouldn't hurt here...

> + fail:
> +	printk(KERN_WARNING "trill_cmd_set_treeroot_id FAILED\n");

    Use pr_warn() instead.

[...]

WBR, Sergei
