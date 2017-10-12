From: Henrik Austad <henrik@austad.us>
Subject: Re: [next-queue PATCH v6 3/5] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 12 Oct 2017 09:58:26 +0200
Message-ID: <20171012075826.GA29396@sisyphus.home.austad.us>
References: <20171012005449.26533-1-vinicius.gomes@intel.com>
 <20171012005449.26533-4-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:38211 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdJLH6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 03:58:25 -0400
Received: by mail-lf0-f65.google.com with SMTP id m7so1562328lfe.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 00:58:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012005449.26533-4-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 11, 2017 at 05:54:47PM -0700, Vinicius Costa Gomes wrote:
> This queueing discipline implements the shaper algorithm defined by
> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>=20
> It's primary usage is to apply some bandwidth reservation to user
> defined traffic classes, which are mapped to different queues via the
> mqprio qdisc.
>=20
> Only a simple software implementation is added for now.
>=20
> Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> ---
>  include/uapi/linux/pkt_sched.h |  18 +++
>  net/sched/Kconfig              |  11 ++
>  net/sched/Makefile             |   1 +
>  net/sched/sch_cbs.c            | 302 +++++++++++++++++++++++++++++++++++=
++++++
>  4 files changed, 332 insertions(+)
>  create mode 100644 net/sched/sch_cbs.c
>=20
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sche=
d.h
> index 099bf5528fed..41e349df4bf4 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -871,4 +871,22 @@ struct tc_pie_xstats {
>  	__u32 maxq;             /* maximum queue size */
>  	__u32 ecn_mark;         /* packets marked with ecn*/
>  };
> +
> +/* CBS */
> +struct tc_cbs_qopt {
> +	__u8 offload;
> +	__s32 hicredit;
> +	__s32 locredit;
> +	__s32 idleslope;
> +	__s32 sendslope;
> +};
> +
> +enum {
> +	TCA_CBS_UNSPEC,
> +	TCA_CBS_PARMS,
> +	__TCA_CBS_MAX,
> +};
> +
> +#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)
> +
>  #endif
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index e70ed26485a2..c03d86a7775e 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -172,6 +172,17 @@ config NET_SCH_TBF
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_tbf.
> =20
> +config NET_SCH_CBS
> +	tristate "Credit Based Shaper (CBS)"

Any particular reason why the dependency to MQPRIO was dropped? I'm only=20
asking because you added it in v1 of the series and then it disappeared in=
=20
v2 and onwards.

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
> index 000000000000..29de3e2bc33f
> --- /dev/null
> +++ b/net/sched/sch_cbs.c
> @@ -0,0 +1,302 @@
> +/*
> + * net/sched/sch_cbs.c	Credit Based Shaper
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	Vinicius Costa Gomes <vinicius.gomes@intel.com>
> + *
> + */
> +
> +/* Credit Based Shaper (CBS)
> + * =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> + *
> + * This is a simple rate-limiting shaper aimed at TSN applications on
> + * systems with known traffic workloads.
> + *
> + * Its algorithm is defined by the IEEE 802.1Q-2014 Specification,
> + * Section 8.6.8.2, and explained in more detail in the Annex L of the
> + * same specification.
> + *
> + * There are four tunables to be considered:
> + *
> + *	'idleslope': Idleslope is the rate of credits that is
> + *	accumulated (in kilobits per second) when there is at least
> + *	one packet waiting for transmission. Packets are transmitted
> + *	when the current value of credits is equal or greater than
> + *	zero. When there is no packet to be transmitted the amount of
> + *	credits is set to zero. This is the main tunable of the CBS
> + *	algorithm.
> + *
> + *	'sendslope':
> + *	Sendslope is the rate of credits that is depleted (it should be a
> + *	negative number of kilobits per second) when a transmission is
> + *	ocurring. It can be calculated as follows, (IEEE 802.1Q-2014 Section
> + *	8.6.8.2 item g):
> + *
> + *	sendslope =3D idleslope - port_transmit_rate
> + *
> + *	'hicredit': Hicredit defines the maximum amount of credits (in
> + *	bytes) that can be accumulated. Hicredit depends on the
> + *	characteristics of interfering traffic,
> + *	'max_interference_size' is the maximum size of any burst of
> + *	traffic that can delay the transmission of a frame that is
> + *	available for transmission for this traffic class, (IEEE
> + *	802.1Q-2014 Annex L, Equation L-3):
> + *
> + *	hicredit =3D max_interference_size * (idleslope / port_transmit_rate)
> + *
> + *	'locredit': Locredit is the minimum amount of credits that can
> + *	be reached. It is a function of the traffic flowing through
> + *	this qdisc (IEEE 802.1Q-2014 Annex L, Equation L-2):
> + *
> + *	locredit =3D max_frame_size * (sendslope / port_transmit_rate)
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
> +#define BYTES_PER_KBIT (1000 / 8)
> +
> +struct cbs_sched_data {
> +	s64 port_rate; /* in bytes/s */
> +	s64 last; /* timestamp in ns */
> +	s64 credits; /* in bytes */
> +	s32 locredit; /* in bytes */
> +	s32 hicredit; /* in bytes */
> +	s32 sendslope; /* in kbits/s */
> +	s32 idleslope; /* in kbits/s */
> +	struct qdisc_watchdog watchdog;
> +	int (*enqueue)(struct sk_buff *skb, struct Qdisc *sch);
> +	struct sk_buff *(*dequeue)(struct Qdisc *sch);
> +};
> +
> +static int cbs_enqueue_soft(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	if (sch->q.qlen =3D=3D 0 && q->credits > 0) {
> +		/* We need to stop accumulating credits when there's
> +		 * no packet enqueued packets and q->credits is
> +		 * positive.
> +		 */
> +		q->credits =3D 0;
> +		q->last =3D ktime_get_ns();
> +	}
> +
> +	return qdisc_enqueue_tail(skb, sch);
> +}
> +
> +static int cbs_enqueue(struct sk_buff *skb, struct Qdisc *sch,
> +		       struct sk_buff **to_free)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	return q->enqueue(skb, sch);
> +}
> +
> +/* timediff is in ns, slope is in kbps */
> +static s64 timediff_to_credits(s64 timediff, s32 slope)
> +{
> +	s64 credits =3D timediff * slope * BYTES_PER_KBIT;
> +
> +	do_div(credits, NSEC_PER_SEC);
> +
> +	return credits;
> +}
> +
> +static s64 delay_from_credits(s64 credits, s32 slope)
> +{
> +	s64 rate =3D slope * BYTES_PER_KBIT;
> +
> +	if (unlikely(rate =3D=3D 0))
> +		return S64_MAX;
> +
> +	return ((-credits * NSEC_PER_SEC) / rate);
> +}
> +
> +static s64 len_to_credits(unsigned int len, s32 slope, s64 port_rate)
> +{
> +	s64 rate =3D slope * BYTES_PER_KBIT;
> +
> +	if (unlikely(rate =3D=3D 0))
> +		return S64_MAX;
> +
> +	return (len * rate) / port_rate;
> +}
> +
> +static struct sk_buff *cbs_dequeue_soft(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	s64 now =3D ktime_get_ns();
> +	struct sk_buff *skb;
> +	s64 credits;
> +	int len;
> +
> +	if (q->credits < 0) {
> +		credits =3D timediff_to_credits(now - q->last, q->idleslope);
> +
> +		credits =3D q->credits + credits;
> +		q->credits =3D min_t(s64, credits, q->hicredit);
> +
> +		if (q->credits < 0) {
> +			s64 delay;
> +
> +			delay =3D delay_from_credits(q->credits, q->idleslope);
> +			qdisc_watchdog_schedule_ns(&q->watchdog, now + delay);
> +
> +			q->last =3D now;
> +
> +			return NULL;
> +		}
> +	}
> +
> +	skb =3D qdisc_dequeue_head(sch);
> +	if (!skb)
> +		return NULL;
> +
> +	len =3D qdisc_pkt_len(skb);
> +
> +	/* As sendslope is a negative number, this will decresease the
> +	 * amount of q->credits.
> +	 */
> +	credits =3D len_to_credits(len, q->sendslope, q->port_rate);
> +	credits +=3D q->credits;
> +
> +	q->credits =3D max_t(s64, credits, q->locredit);
> +	q->last =3D now;
> +
> +	return skb;
> +}
> +
> +static struct sk_buff *cbs_dequeue(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	return q->dequeue(sch);
> +}
> +
> +static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] =3D {
> +	[TCA_CBS_PARMS]	=3D { .len =3D sizeof(struct tc_cbs_qopt) },
> +};
> +
> +static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct net_device *dev =3D qdisc_dev(sch);
> +	struct nlattr *tb[TCA_CBS_MAX + 1];
> +	struct ethtool_link_ksettings ecmd;
> +	struct tc_cbs_qopt *qopt;
> +	s64 link_speed;
> +	int err;
> +
> +	err =3D nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	if (!tb[TCA_CBS_PARMS])
> +		return -EINVAL;
> +
> +	qopt =3D nla_data(tb[TCA_CBS_PARMS]);
> +
> +	if (qopt->offload)
> +		return -EOPNOTSUPP;
> +
> +	if (!__ethtool_get_link_ksettings(dev, &ecmd))
> +		link_speed =3D ecmd.base.speed;
> +	else
> +		link_speed =3D SPEED_1000;
> +
> +	q->port_rate =3D link_speed * 1000 * BYTES_PER_KBIT;
> +
> +	q->enqueue =3D cbs_enqueue_soft;
> +	q->dequeue =3D cbs_dequeue_soft;

How does one use the cbs_(en|de)queue instead of _soft()?

> +	q->hicredit =3D qopt->hicredit;
> +	q->locredit =3D qopt->locredit;
> +	q->idleslope =3D qopt->idleslope;
> +	q->sendslope =3D qopt->sendslope;
> +
> +	return 0;
> +}
> +
> +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	if (!opt)
> +		return -EINVAL;
> +
> +	qdisc_watchdog_init(&q->watchdog, sch);
> +
> +	return cbs_change(sch, opt);
> +}
> +
> +static void cbs_destroy(struct Qdisc *sch)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +
> +	qdisc_watchdog_cancel(&q->watchdog);
> +}
> +
> +static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct cbs_sched_data *q =3D qdisc_priv(sch);
> +	struct tc_cbs_qopt opt =3D { };
> +	struct nlattr *nest;
> +
> +	nest =3D nla_nest_start(skb, TCA_OPTIONS);
> +	if (!nest)
> +		goto nla_put_failure;
> +
> +	opt.hicredit =3D q->hicredit;
> +	opt.locredit =3D q->locredit;
> +	opt.sendslope =3D q->sendslope;
> +	opt.idleslope =3D q->idleslope;
> +	opt.offload =3D 0;
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
> +static struct Qdisc_ops cbs_qdisc_ops __read_mostly =3D {
> +	.id		=3D	"cbs",
> +	.priv_size	=3D	sizeof(struct cbs_sched_data),
> +	.enqueue	=3D	cbs_enqueue,
> +	.dequeue	=3D	cbs_dequeue,
> +	.peek		=3D	qdisc_peek_dequeued,
> +	.init		=3D	cbs_init,
> +	.reset		=3D	qdisc_reset_queue,
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
> 2.14.2
>=20

--=20
Henrik Austad

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnfIKIACgkQ6k5VT6v45lnBdACg6Dz1VAuAB0L+VLIEUvdrrCPD
dAwAnAp/BT/k1/R2VgH8zEu5+FESWntA
=wc0r
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
