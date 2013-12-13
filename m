From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH net-next] sch_tbf: add TBF_BURST/TBF_PBURST attribute
Date: Fri, 13 Dec 2013 17:50:31 +0800
Message-ID: <52AAD867.5030305@cn.fujitsu.com>
References: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51036 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752436Ab3LMJui convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 04:50:38 -0500
In-Reply-To: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B412=E6=9C=8813=E6=97=A5 17:41, Yang Yingliang =E5=
=86=99=E9=81=93:
> When we set burst to 1514 with low rate in userspace,
> the kernel get a value of burst that less than 1514,
> which doesn't work.
>=20
> Because it may make some loss when transform burst
> to buffer in userspace. This makes burst lose some
> bytes, when the kernel transform the buffer back to
> burst.
>=20
> This patch adds two new attributes to support sending
> burst/mtu to kernel directly to avoid the loss.
>=20
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  include/uapi/linux/pkt_sched.h |  2 ++
>  net/sched/sch_tbf.c            | 25 +++++++++++++++++++++----
>  2 files changed, 23 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_=
sched.h
> index a806687..fd8e17e 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -173,6 +173,8 @@ enum {
>  	TCA_TBF_PTAB,
>  	TCA_TBF_RATE64,
>  	TCA_TBF_PRATE64,
> +	TCA_TBF_BURST,
> +	TCA_TBF_PBURST,
>  	__TCA_TBF_MAX,
>  };
> =20
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 887e672..a746049 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -307,6 +307,8 @@ static const struct nla_policy tbf_policy[TCA_TBF=
_MAX + 1] =3D {
>  	[TCA_TBF_PTAB]	=3D { .type =3D NLA_BINARY, .len =3D TC_RTAB_SIZE },
>  	[TCA_TBF_RATE64]	=3D { .type =3D NLA_U64 },
>  	[TCA_TBF_PRATE64]	=3D { .type =3D NLA_U64 },
> +	[TCA_TBF_BURST]		=3D { .type =3D NLA_U32 },

This place should remove one tab.

Thanks,
  Duan

> +	[TCA_TBF_PBURST]	=3D { .type =3D NLA_U32 },
>  };
> =20
>  static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
> @@ -358,7 +360,11 @@ static int tbf_change(struct Qdisc *sch, struct =
nlattr *opt)
>  		rate64 =3D nla_get_u64(tb[TCA_TBF_RATE64]);
>  	psched_ratecfg_precompute(&rate, &qopt->rate, rate64);
> =20
> -	max_size =3D min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
> +	if (tb[TCA_TBF_BURST]) {
> +		max_size =3D nla_get_u32(tb[TCA_TBF_BURST]);
> +		buffer =3D psched_l2t_ns(&rate, max_size);
> +	} else
> +		max_size =3D min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
> =20
>  	if (qopt->peakrate.rate) {
>  		if (tb[TCA_TBF_PRATE64])
> @@ -371,7 +377,12 @@ static int tbf_change(struct Qdisc *sch, struct =
nlattr *opt)
>  			goto done;
>  		}
> =20
> -		max_size =3D min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
> +		if (tb[TCA_TBF_PBURST]) {
> +			u32 pburst =3D nla_get_u32(tb[TCA_TBF_PBURST]);
> +			max_size =3D min_t(u32, max_size, pburst);
> +			mtu =3D psched_l2t_ns(&peak, pburst);
> +		} else
> +			max_size =3D min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
>  	}
> =20
>  	if (max_size < psched_mtu(qdisc_dev(sch)))
> @@ -391,9 +402,15 @@ static int tbf_change(struct Qdisc *sch, struct =
nlattr *opt)
>  		q->qdisc =3D child;
>  	}
>  	q->limit =3D qopt->limit;
> -	q->mtu =3D PSCHED_TICKS2NS(qopt->mtu);
> +	if (tb[TCA_TBF_PBURST])
> +		q->mtu =3D mtu;
> +	else
> +		q->mtu =3D PSCHED_TICKS2NS(qopt->mtu);
>  	q->max_size =3D max_size;
> -	q->buffer =3D PSCHED_TICKS2NS(qopt->buffer);
> +	if (tb[TCA_TBF_BURST])
> +		q->buffer =3D buffer;
> +	else
> +		q->buffer =3D PSCHED_TICKS2NS(qopt->buffer);
>  	q->tokens =3D q->buffer;
>  	q->ptokens =3D q->mtu;
> =20
>=20
