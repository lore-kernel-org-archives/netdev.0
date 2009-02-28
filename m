From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] iptables: xt_hashlimit fix
Date: Sat, 28 Feb 2009 07:56:54 +0100
Message-ID: <49A8E036.5090802@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <499EF222.3060507@cosmosbay.com> <alpine.LSU.2.00.0902201919390.5911@fbirervta.pbzchgretzou.qr> <alpine.LSU.2.00.0902280253370.20614@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0902280253370.20614@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt a =E9crit :
> On Friday 2009-02-20 19:33, Jan Engelhardt wrote:
>> On Friday 2009-02-20 19:10, Eric Dumazet wrote:
>>> Damned this broke xt_hashlimit, version=3D0
>>> Look file "net/netfilter/xt_hashlimit.c" line 706
>>>
>>>    /* Ugly hack: For SMP, we only want to use one set */
>>>    r->u.master =3D r;
>>>
>>> So, it appears some modules are using pointers to themselves, what =
a hack :(
>>> We probably need an audit of other modules.
>> xt_limit and xt_statistic are affected; I'll happily fix that up.
>=20
> Please have a look!
>=20
> ---8<---
> parent b2bd9ab764d65237232c4aad5ab8d5d8b5714f72 (v2.6.29-rc6-31-gb2bd=
9ab)
> commit 3e7ee1dcc808b8eec82eddfa0436f78e31d2004a
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Sat Feb 28 02:49:28 2009 +0100
>=20
> netfilter: xtables: avoid pointer to self
>=20
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Seems good to me ! Thanks Jan !

Reviewed-by: Eric Dumazet <dada1@cosmosbay.com>

Are you sure xt_quota doesnt need some tweak, or should we not care of =
changes
done in quota while temporary tables are installed (iptables -L) ?

> ---
>  include/linux/netfilter/xt_limit.h     |    9 +++--
>  include/linux/netfilter/xt_statistic.h |    7 ++--
>  net/netfilter/xt_limit.c               |   40 +++++++++++++++++-----=
-
>  net/netfilter/xt_statistic.c           |   28 +++++++++++++---
>  4 files changed, 61 insertions(+), 23 deletions(-)
>=20
> diff --git a/include/linux/netfilter/xt_limit.h b/include/linux/netfi=
lter/xt_limit.h
> index b3ce653..fda222c 100644
> --- a/include/linux/netfilter/xt_limit.h
> +++ b/include/linux/netfilter/xt_limit.h
> @@ -4,6 +4,8 @@
>  /* timings are in milliseconds. */
>  #define XT_LIMIT_SCALE 10000
> =20
> +struct xt_limit_priv;
> +
>  /* 1/10,000 sec period =3D> max of 10,000/sec.  Min rate is then 429=
490
>     seconds, or one every 59 hours. */
>  struct xt_rateinfo {
> @@ -11,11 +13,10 @@ struct xt_rateinfo {
>  	u_int32_t burst;  /* Period multiplier for upper limit. */
> =20
>  	/* Used internally by the kernel */
> -	unsigned long prev;
> -	u_int32_t credit;
> +	unsigned long prev; /* moved to xt_limit_priv */
> +	u_int32_t credit; /* moved to xt_limit_priv */
>  	u_int32_t credit_cap, cost;
> =20
> -	/* Ugly, ugly fucker. */
> -	struct xt_rateinfo *master;
> +	struct xt_limit_priv *master;
>  };
>  #endif /*_XT_RATE_H*/
> diff --git a/include/linux/netfilter/xt_statistic.h b/include/linux/n=
etfilter/xt_statistic.h
> index 3d38bc9..8f521ab 100644
> --- a/include/linux/netfilter/xt_statistic.h
> +++ b/include/linux/netfilter/xt_statistic.h
> @@ -13,6 +13,8 @@ enum xt_statistic_flags {
>  };
>  #define XT_STATISTIC_MASK		0x1
> =20
> +struct xt_statistic_priv;
> +
>  struct xt_statistic_info {
>  	u_int16_t			mode;
>  	u_int16_t			flags;
> @@ -23,11 +25,10 @@ struct xt_statistic_info {
>  		struct {
>  			u_int32_t	every;
>  			u_int32_t	packet;
> -			/* Used internally by the kernel */
> -			u_int32_t	count;
> +			u_int32_t	count; /* unused */
>  		} nth;
>  	} u;
> -	struct xt_statistic_info	*master __attribute__((aligned(8)));
> +	struct xt_statistic_priv *master __attribute__((aligned(8)));
>  };
> =20
>  #endif /* _XT_STATISTIC_H */
> diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
> index c908d69..2e8089e 100644
> --- a/net/netfilter/xt_limit.c
> +++ b/net/netfilter/xt_limit.c
> @@ -14,6 +14,11 @@
>  #include <linux/netfilter/x_tables.h>
>  #include <linux/netfilter/xt_limit.h>
> =20
> +struct xt_limit_priv {
> +	unsigned long prev;
> +	uint32_t credit;
> +};
> +
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Herve Eychenne <rv@wallfire.org>");
>  MODULE_DESCRIPTION("Xtables: rate-limit match");
> @@ -60,18 +65,18 @@ static DEFINE_SPINLOCK(limit_lock);
>  static bool
>  limit_mt(const struct sk_buff *skb, const struct xt_match_param *par=
)
>  {
> -	struct xt_rateinfo *r =3D
> -		((const struct xt_rateinfo *)par->matchinfo)->master;
> +	const struct xt_rateinfo *r =3D par->matchinfo;
> +	struct xt_limit_priv *priv =3D r->master;
>  	unsigned long now =3D jiffies;
> =20
>  	spin_lock_bh(&limit_lock);
> -	r->credit +=3D (now - xchg(&r->prev, now)) * CREDITS_PER_JIFFY;
> -	if (r->credit > r->credit_cap)
> -		r->credit =3D r->credit_cap;
> +	priv->credit +=3D (now - xchg(&priv->prev, now)) * CREDITS_PER_JIFF=
Y;
> +	if (priv->credit > r->credit_cap)
> +		priv->credit =3D r->credit_cap;
> =20
> -	if (r->credit >=3D r->cost) {
> +	if (priv->credit >=3D r->cost) {
>  		/* We're not limited. */
> -		r->credit -=3D r->cost;
> +		priv->credit -=3D r->cost;
>  		spin_unlock_bh(&limit_lock);
>  		return true;
>  	}
> @@ -95,6 +100,7 @@ user2credits(u_int32_t user)
>  static bool limit_mt_check(const struct xt_mtchk_param *par)
>  {
>  	struct xt_rateinfo *r =3D par->matchinfo;
> +	struct xt_limit_priv *priv;
> =20
>  	/* Check for overflow. */
>  	if (r->burst =3D=3D 0
> @@ -104,19 +110,30 @@ static bool limit_mt_check(const struct xt_mtch=
k_param *par)
>  		return false;
>  	}
> =20
> -	/* For SMP, we only want to use one set of counters. */
> -	r->master =3D r;
> +	priv =3D kmalloc(sizeof(*priv), GFP_KERNEL);
> +	if (priv =3D=3D NULL)
> +		return -ENOMEM;
> +
> +	/* For SMP, we only want to use one set of state. */
> +	r->master =3D priv;
>  	if (r->cost =3D=3D 0) {
>  		/* User avg in seconds * XT_LIMIT_SCALE: convert to jiffies *
>  		   128. */
> -		r->prev =3D jiffies;
> -		r->credit =3D user2credits(r->avg * r->burst);	 /* Credits full. *=
/
> +		priv->prev =3D jiffies;
> +		priv->credit =3D user2credits(r->avg * r->burst); /* Credits full.=
 */
>  		r->credit_cap =3D user2credits(r->avg * r->burst); /* Credits full=
=2E */
>  		r->cost =3D user2credits(r->avg);
>  	}
>  	return true;
>  }
> =20
> +static void limit_mt_destroy(const struct xt_mtdtor_param *par)
> +{
> +	const struct xt_rateinfo *info =3D par->matchinfo;
> +
> +	kfree(info->master);
> +}
> +
>  #ifdef CONFIG_COMPAT
>  struct compat_xt_rateinfo {
>  	u_int32_t avg;
> @@ -167,6 +184,7 @@ static struct xt_match limit_mt_reg __read_mostly=
 =3D {
>  	.family           =3D NFPROTO_UNSPEC,
>  	.match            =3D limit_mt,
>  	.checkentry       =3D limit_mt_check,
> +	.destroy          =3D limit_mt_destroy,
>  	.matchsize        =3D sizeof(struct xt_rateinfo),
>  #ifdef CONFIG_COMPAT
>  	.compatsize       =3D sizeof(struct compat_xt_rateinfo),
> diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statisti=
c.c
> index 0d75141..d8c0f8f 100644
> --- a/net/netfilter/xt_statistic.c
> +++ b/net/netfilter/xt_statistic.c
> @@ -16,6 +16,10 @@
>  #include <linux/netfilter/xt_statistic.h>
>  #include <linux/netfilter/x_tables.h>
> =20
> +struct xt_statistic_priv {
> +	uint32_t count;
> +};
> +
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
>  MODULE_DESCRIPTION("Xtables: statistics-based matching (\"Nth\", ran=
dom)");
> @@ -27,7 +31,7 @@ static DEFINE_SPINLOCK(nth_lock);
>  static bool
>  statistic_mt(const struct sk_buff *skb, const struct xt_match_param =
*par)
>  {
> -	struct xt_statistic_info *info =3D (void *)par->matchinfo;
> +	const struct xt_statistic_info *info =3D par->matchinfo;
>  	bool ret =3D info->flags & XT_STATISTIC_INVERT;
> =20
>  	switch (info->mode) {
> @@ -36,10 +40,9 @@ statistic_mt(const struct sk_buff *skb, const stru=
ct xt_match_param *par)
>  			ret =3D !ret;
>  		break;
>  	case XT_STATISTIC_MODE_NTH:
> -		info =3D info->master;
>  		spin_lock_bh(&nth_lock);
> -		if (info->u.nth.count++ =3D=3D info->u.nth.every) {
> -			info->u.nth.count =3D 0;
> +		if (info->master->count++ =3D=3D info->u.nth.every) {
> +			info->master->count =3D 0;
>  			ret =3D !ret;
>  		}
>  		spin_unlock_bh(&nth_lock);
> @@ -56,16 +59,31 @@ static bool statistic_mt_check(const struct xt_mt=
chk_param *par)
>  	if (info->mode > XT_STATISTIC_MODE_MAX ||
>  	    info->flags & ~XT_STATISTIC_MASK)
>  		return false;
> -	info->master =3D info;
> +
> +	info->master =3D kzalloc(sizeof(*info->master), GFP_KERNEL);
> +	if (info->master =3D=3D NULL) {
> +		printk(KERN_ERR KBUILD_MODNAME ": Out of memory\n");
> +		return false;
> +	}
> +	info->master->count =3D info->u.nth.count;
> +
>  	return true;
>  }
> =20
> +static void statistic_mt_destroy(const struct xt_mtdtor_param *par)
> +{
> +	const struct xt_statistic_info *info =3D par->matchinfo;
> +
> +	kfree(info->master);
> +}
> +
>  static struct xt_match xt_statistic_mt_reg __read_mostly =3D {
>  	.name       =3D "statistic",
>  	.revision   =3D 0,
>  	.family     =3D NFPROTO_UNSPEC,
>  	.match      =3D statistic_mt,
>  	.checkentry =3D statistic_mt_check,
> +	.destroy    =3D statistic_mt_destroy,
>  	.matchsize  =3D sizeof(struct xt_statistic_info),
>  	.me         =3D THIS_MODULE,
>  };


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
