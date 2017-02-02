From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 2 Feb 2017 08:40:24 +0000
Message-ID: <DB3PR05MB0764A96B7BB6DE69AD5F749FAC4C0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <20170202124944.6c3fd4f4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170202124944.6c3fd4f4@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] O=
n
>Behalf Of Stephen Rothwell
>Sent: Thursday, February 02, 2017 3:50 AM
>To: David Miller <davem@davemloft.net>; Networking <netdev@vger.kernel.org=
>
>Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Yotam Gigi
><yotamg@mellanox.com>
>Subject: linux-next: manual merge of the net-next tree with Linus' tree
>
>Hi all,
>
>Today's linux-next merge of the net-next tree got a conflict in:
>
>  net/sched/cls_matchall.c
>
>between commit:
>
>  fd62d9f5c575 ("net/sched: matchall: Fix configuration race")
>
>from Linus' tree and commit:
>
>  ec2507d2a306 ("net/sched: cls_matchall: Fix error path")
>
>from the net-next tree.
>
>I fixed it up (see below) and can carry the fix as necessary. This
>is now fixed as far as linux-next is concerned, but any non trivial
>conflicts should be mentioned to your upstream maintainer when your tree
>is submitted for merging.  You may also want to consider cooperating
>with the maintainer of the conflicting tree to minimise any particularly
>complex conflicts.

Looks good. Thanks!

>
>--
>Cheers,
>Stephen Rothwell
>
>diff --cc net/sched/cls_matchall.c
>index b12bc2abea93,fcecf5aac666..000000000000
>--- a/net/sched/cls_matchall.c
>+++ b/net/sched/cls_matchall.c
>@@@ -118,19 -141,24 +118,24 @@@ static int mall_set_parms(struct net *n
>  	struct tcf_exts e;
>  	int err;
>
>- 	tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
>+ 	err =3D tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
>+ 	if (err)
>+ 		return err;
>  	err =3D tcf_exts_validate(net, tp, tb, est, &e, ovr);
>  	if (err < 0)
>- 		return err;
>+ 		goto errout;
>
>  	if (tb[TCA_MATCHALL_CLASSID]) {
> -		f->res.classid =3D nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
> -		tcf_bind_filter(tp, &f->res, base);
> +		head->res.classid =3D nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
> +		tcf_bind_filter(tp, &head->res, base);
>  	}
>
> -	tcf_exts_change(tp, &f->exts, &e);
> +	tcf_exts_change(tp, &head->exts, &e);
>
>  	return 0;
>+ errout:
>+ 	tcf_exts_destroy(&e);
>+ 	return err;
>  }
>
>  static int mall_change(struct net *net, struct sk_buff *in_skb,
>@@@ -162,39 -194,43 +167,44 @@@
>  			return -EINVAL;
>  	}
>
> -	f =3D kzalloc(sizeof(*f), GFP_KERNEL);
> -	if (!f)
> +	new =3D kzalloc(sizeof(*new), GFP_KERNEL);
> +	if (!new)
>  		return -ENOBUFS;
>
>- 	tcf_exts_init(&new->exts, TCA_MATCHALL_ACT, 0);
> -	err =3D tcf_exts_init(&f->exts, TCA_MATCHALL_ACT, 0);
>++	err =3D tcf_exts_init(&new->exts, TCA_MATCHALL_ACT, 0);
>+ 	if (err)
>+ 		goto err_exts_init;
>
>  	if (!handle)
>  		handle =3D 1;
> -	f->handle =3D handle;
> -	f->flags =3D flags;
> +	new->handle =3D handle;
> +	new->flags =3D flags;
>
> -	err =3D mall_set_parms(net, tp, f, base, tb, tca[TCA_RATE], ovr);
> +	err =3D mall_set_parms(net, tp, new, base, tb, tca[TCA_RATE], ovr);
>  	if (err)
>- 		goto errout;
>+ 		goto err_set_parms;
>
>  	if (tc_should_offload(dev, tp, flags)) {
> -		err =3D mall_replace_hw_filter(tp, f, (unsigned long) f);
> +		err =3D mall_replace_hw_filter(tp, new, (unsigned long) new);
>  		if (err) {
>  			if (tc_skip_sw(flags))
>- 				goto errout;
>+ 				goto err_replace_hw_filter;
>  			else
>  				err =3D 0;
>  		}
>  	}
>
> -	*arg =3D (unsigned long) f;
> -	rcu_assign_pointer(head->filter, f);
> -
> +	*arg =3D (unsigned long) head;
> +	rcu_assign_pointer(tp->root, new);
> +	if (head)
> +		call_rcu(&head->rcu, mall_destroy_rcu);
>  	return 0;
>
>- errout:
>+ err_replace_hw_filter:
>+ err_set_parms:
> -	tcf_exts_destroy(&f->exts);
>++	tcf_exts_destroy(&new->exts);
>+ err_exts_init:
> -	kfree(f);
> +	kfree(new);
>  	return err;
>  }
>
