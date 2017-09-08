From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 2/5] net/sched: Introduce Credit Based Shaper
 (CBS) qdisc
Date: Fri, 8 Sep 2017 15:43:32 +0200
Message-ID: <20170908134332.GD9064@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170901012625.14838-3-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FFoLq8A0u+X9iRU8"
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34897 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933042AbdIHNn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 09:43:57 -0400
Received: by mail-lf0-f67.google.com with SMTP id c8so1131017lfe.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 06:43:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901012625.14838-3-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FFoLq8A0u+X9iRU8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 31, 2017 at 06:26:22PM -0700, Vinicius Costa Gomes wrote:
> This queueing discipline implements the shaper algorithm defined by
> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>=20
> It's primary usage is to apply some bandwidth reservation to user
> defined traffic classes, which are mapped to different queues via the
> mqprio qdisc.
>=20
> Initially, it only supports offloading the traffic shaping work to
> supporting controllers.
>=20
> Later, when a software implementation is added, the current dependency
> on being installed "under" mqprio can be lifted.
>=20
> Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

So, I started testing this in my VM to make sure I didn't do anything silly=
=20
and it exploded spectacularly as it used the underlying e1000 driver which=
=20
does not have a ndo_setup_tc present.

I commented inline below, but as a tl;dr

The cbs_init() would call into cbs_change() that would correctly detect=20
that ndo_setup_tc is missing and abort. However, at this stage it would try=
=20
to desroy the qdisc and in cbs_destroy() there's no such guard leading to a

BUG: unable to handle kernel NULL pointer dereference at 0000000000000010

Fixing that, another NULL would be found when the code walks into=20
qdisc_destroy(q->qdisc).

Apart from this, it loaded fine after some wrestling with tc :)

Awesome! :D

> ---
>  include/linux/netdevice.h |   1 +
>  net/sched/Kconfig         |  11 ++
>  net/sched/Makefile        |   1 +
>  net/sched/sch_cbs.c       | 286 ++++++++++++++++++++++++++++++++++++++++=
++++++
>  4 files changed, 299 insertions(+)
>  create mode 100644 net/sched/sch_cbs.c
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 35de8312e0b5..dd9a2ecd0c03 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -775,6 +775,7 @@ enum tc_setup_type {
>  	TC_SETUP_CLSFLOWER,
>  	TC_SETUP_CLSMATCHALL,
>  	TC_SETUP_CLSBPF,
> +	TC_SETUP_CBS,
>  };
> =20
>  /* These structures hold the attributes of xdp state that are being pass=
ed
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index e70ed26485a2..c03d86a7775e 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -172,6 +172,17 @@ config NET_SCH_TBF
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_tbf.
> =20
> +config NET_SCH_CBS

Shouldn't this depend on NET_SCH_MQPRIO as it is supposed to hook into=20
that?

@@ -173,6 +173,7 @@ config NET_SCH_TBF
          module will be called sch_tbf.
=20
 config NET_SCH_CBS
+       depends on NET_SCH_MQPRIO
        tristate "Credit Based Shaper (CBS)"
        ---help---
          Say Y here if you want to use the Credit Based Shaper (CBS) packet

> +	tristate "Credit Based Shaper (CBS)"
> +	---help---
> +	  Say Y here if you want to use the Credit Based Shaper (CBS) packet
> +	  scheduling algorithm.
> +
> +	  See the top of <file:net/sched/sch_cbs.c> for more details.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called sch_cbs.
> +
>  config NET_SCH_GRED
>  	tristate "Generic Random Early Detection (GRED)"
>  	---help---
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 7b915d226de7..80c8f92d162d 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -52,6 +52,7 @@ obj-$(CONFIG_NET_SCH_FQ_CODEL)	+=3D sch_fq_codel.o
>  obj-$(CONFIG_NET_SCH_FQ)	+=3D sch_fq.o
>  obj-$(CONFIG_NET_SCH_HHF)	+=3D sch_hhf.o
>  obj-$(CONFIG_NET_SCH_PIE)	+=3D sch_pie.o
> +obj-$(CONFIG_NET_SCH_CBS)	+=3D sch_cbs.o
> =20
>  obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
>  obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
> diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
> new file mode 100644
> index 000000000000..1c86a9e14150
> --- /dev/null
> +++ b/net/sched/sch_cbs.c
> @@ -0,0 +1,286 @@
> +/*
> + * net/sched/sch_cbs.c	Credit Based Shaper
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	Vininicius Costa Gomes <vinicius.gomes@intel.com>
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/netlink.h>
> +#include <net/sch_generic.h>
> +#include <net/pkt_sched.h>
> +
> +struct cbs_sched_data {
> +	struct Qdisc *qdisc; /* Inner qdisc, default - pfifo queue */
> +	s32 queue;
> +	s32 locredit;
> +	s32 hicredit;
> +	s32 sendslope;
> +	s32 idleslope;
> +};
> +
> +static int cbs_enqueue(struct sk_buff *skb, struct Qdisc *sch,
> +		       struct sk_buff **to_free)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	int ret;
> +
> +	ret =3D qdisc_enqueue(skb, q->qdisc, to_free);
> +	if (ret !=3D NET_XMIT_SUCCESS) {
> +		if (net_xmit_drop_count(ret))
> +			qdisc_qstats_drop(sch);
> +		return ret;
> +	}
> +
> +	qdisc_qstats_backlog_inc(sch, skb);
> +	sch->q.qlen++;
> +	return NET_XMIT_SUCCESS;
> +}
> +
> +static struct sk_buff *cbs_dequeue(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct sk_buff *skb;
> +
> +	skb =3D q->qdisc->ops->peek(q->qdisc);
> +	if (skb) {
> +		skb =3D qdisc_dequeue_peeked(q->qdisc);
> +		if (unlikely(!skb))
> +			return NULL;
> +
> +		qdisc_qstats_backlog_dec(sch, skb);
> +		sch->q.qlen--;
> +		qdisc_bstats_update(sch, skb);
> +
> +		return skb;
> +	}
> +	return NULL;
> +}
> +
> +static void cbs_reset(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	qdisc_reset(q->qdisc);
> +}
> +
> +static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] =3D {
> +	[TCA_CBS_PARMS]	=3D { .len =3D sizeof(struct tc_cbs_qopt) },
> +};
> +
> +static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct tc_cbs_qopt_offload cbs =3D { };
> +	struct nlattr *tb[TCA_CBS_MAX + 1];
> +	const struct net_device_ops *ops;
> +	struct tc_cbs_qopt *qopt;
> +	struct net_device *dev;
> +	int err;
> +
> +	err =3D nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	err =3D -EINVAL;
> +	if (!tb[TCA_CBS_PARMS])
> +		goto done;
> +
> +	qopt =3D nla_data(tb[TCA_CBS_PARMS]);
> +
> +	dev =3D qdisc_dev(sch);
> +	ops =3D dev->netdev_ops;
> +
> +	/* FIXME: this means that we can only install this qdisc
> +	 * "under" mqprio. Do we need a more generic way to retrieve
> +	 * the queue, or do we pass the netdev_queue to the driver?
> +	 */
> +	cbs.queue =3D TC_H_MIN(sch->parent) - 1 - netdev_get_num_tc(dev);
> +
> +	cbs.enable =3D 1;
> +	cbs.hicredit =3D qopt->hicredit;
> +	cbs.locredit =3D qopt->locredit;
> +	cbs.idleslope =3D qopt->idleslope;
> +	cbs.sendslope =3D qopt->sendslope;
> +
> +	err =3D -ENOTSUPP;
> +	if (!ops->ndo_setup_tc)
> +		goto done;

This confuses tc a bit, and looking at other qdisc schedulers, it seems=20
like EOPNOTSUPP is an alternative, this changes the output from

RTNETLINK answers: Unknown error 524
 - to
RTNETLINK answers: Operation not supported

which perhaps is more informative.

> +
> +	err =3D dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
> +	if (err < 0)
> +		goto done;
> +
> +	q->queue =3D cbs.queue;
> +	q->hicredit =3D cbs.hicredit;
> +	q->locredit =3D cbs.locredit;
> +	q->idleslope =3D cbs.idleslope;
> +	q->sendslope =3D cbs.sendslope;
> +
> +done:
> +	return err;
> +}
> +
> +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	if (!opt)
> +		return -EINVAL;
> +
> +	q->qdisc =3D fifo_create_dflt(sch, &pfifo_qdisc_ops, 1024);
> +	qdisc_hash_add(q->qdisc, true);
> +
> +	return cbs_change(sch, opt);
> +}
> +
> +static void cbs_destroy(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct tc_cbs_qopt_offload cbs =3D { };
> +	struct net_device *dev;
> +	int err;
> +
> +	q->hicredit =3D 0;
> +	q->locredit =3D 0;
> +	q->idleslope =3D 0;
> +	q->sendslope =3D 0;
> +
> +	dev =3D qdisc_dev(sch);
> +
> +	cbs.queue =3D q->queue;
> +	cbs.enable =3D 0;
> +
> +	err =3D dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);

This can lead to NULL pointer deref if it is not set (tested for in=20
cbs_change and error there leads us here, which then explodes).

> +	if (err < 0)
> +		pr_warn("Couldn't reset queue %d to default values\n",
> +			cbs.queue);
> +
> +	qdisc_destroy(q->qdisc);

Same, q->qdisc was NULL when cbs_init() failed.

> +}
> +
> +static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct nlattr *nest;
> +	struct tc_cbs_qopt opt;
> +
> +	sch->qstats.backlog =3D q->qdisc->qstats.backlog;
> +	nest =3D nla_nest_start(skb, TCA_OPTIONS);
> +	if (!nest)
> +		goto nla_put_failure;
> +
> +	opt.hicredit =3D q->hicredit;
> +	opt.locredit =3D q->locredit;
> +	opt.sendslope =3D q->sendslope;
> +	opt.idleslope =3D q->idleslope;
> +
> +	if (nla_put(skb, TCA_CBS_PARMS, sizeof(opt), &opt))
> +		goto nla_put_failure;
> +
> +	return nla_nest_end(skb, nest);
> +
> +nla_put_failure:
> +	nla_nest_cancel(skb, nest);
> +	return -1;
> +}
> +
> +static int cbs_dump_class(struct Qdisc *sch, unsigned long cl,
> +			  struct sk_buff *skb, struct tcmsg *tcm)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	tcm->tcm_handle |=3D TC_H_MIN(1);
> +	tcm->tcm_info =3D q->qdisc->handle;
> +
> +	return 0;
> +}
> +
> +static int cbs_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc =
*new,
> +		     struct Qdisc **old)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	if (!new)
> +		new =3D &noop_qdisc;
> +
> +	*old =3D qdisc_replace(sch, new, &q->qdisc);
> +	return 0;
> +}
> +
> +static struct Qdisc *cbs_leaf(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	return q->qdisc;
> +}
> +
> +static unsigned long cbs_find(struct Qdisc *sch, u32 classid)
> +{
> +	return 1;
> +}
> +
> +static int cbs_delete(struct Qdisc *sch, unsigned long arg)
> +{
> +	return 0;
> +}
> +
> +static void cbs_walk(struct Qdisc *sch, struct qdisc_walker *walker)
> +{
> +	if (!walker->stop) {
> +		if (walker->count >=3D walker->skip)
> +			if (walker->fn(sch, 1, walker) < 0) {
> +				walker->stop =3D 1;
> +				return;
> +			}
> +		walker->count++;
> +	}
> +}
> +
> +static const struct Qdisc_class_ops cbs_class_ops =3D {
> +	.graft		=3D	cbs_graft,
> +	.leaf		=3D	cbs_leaf,
> +	.find		=3D	cbs_find,
> +	.delete		=3D	cbs_delete,
> +	.walk		=3D	cbs_walk,
> +	.dump		=3D	cbs_dump_class,
> +};
> +
> +static struct Qdisc_ops cbs_qdisc_ops __read_mostly =3D {
> +	.next		=3D	NULL,
> +	.cl_ops		=3D	&cbs_class_ops,
> +	.id		=3D	"cbs",
> +	.priv_size	=3D	sizeof(struct cbs_sched_data),
> +	.enqueue	=3D	cbs_enqueue,
> +	.dequeue	=3D	cbs_dequeue,
> +	.peek		=3D	qdisc_peek_dequeued,
> +	.init		=3D	cbs_init,
> +	.reset		=3D	cbs_reset,
> +	.destroy	=3D	cbs_destroy,
> +	.change		=3D	cbs_change,
> +	.dump		=3D	cbs_dump,
> +	.owner		=3D	THIS_MODULE,
> +};
> +
> +static int __init cbs_module_init(void)
> +{
> +	return register_qdisc(&cbs_qdisc_ops);
> +}
> +
> +static void __exit cbs_module_exit(void)
> +{
> +	unregister_qdisc(&cbs_qdisc_ops);
> +}
> +module_init(cbs_module_init)
> +module_exit(cbs_module_exit)
> +MODULE_LICENSE("GPL");
> --=20
> 2.14.1
>=20

--=20
Henrik Austad

--FFoLq8A0u+X9iRU8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmynoQACgkQ6k5VT6v45llW+QCeN1X+qaHQLwpxeDIwpytfcETe
xSIAoLo0fdSonoPrmNpl6UyIuxK7/Jri
=Pdqv
-----END PGP SIGNATURE-----

--FFoLq8A0u+X9iRU8--
