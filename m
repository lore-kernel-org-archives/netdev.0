From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Wed, 01 Dec 2010 12:21:16 +0100
Message-ID: <1291202476.2856.584.camel@edumazet-laptop>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291202063-6239-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 19:14 +0800, Amerigo Wang a =C3=
=A9crit :
> From: WANG Cong <amwang@redhat.com>
>=20
> The latest net-next-2.6 triggers an RCU warning during boot,
> lockdep complains that in inet_fill_link_af() we call rcu_dereference=
_check()
> without rcu_read_lock() protection.
>=20
> This patch fixes it by replacing __in_dev_get_rcu() with in_dev_get()=
=2E
>=20
> Signed-off-by: WANG Cong <amwang@redhat.com>
>=20

Sorry patch is not the right fix. Please take a look at commit 95ae6b22

We are working hard to remove all the not needed get()/put(), not to ad=
d
new ones ;)


> ---
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index d9f71ba..73baed8 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1258,31 +1258,36 @@ errout:
> =20
>  static size_t inet_get_link_af_size(const struct net_device *dev)
>  {
> -	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
> +	struct in_device *in_dev =3D in_dev_get(dev);
> =20
>  	if (!in_dev)
>  		return 0;
> =20
> +	in_dev_put(in_dev);
>  	return nla_total_size(IPV4_DEVCONF_MAX * 4); /* IFLA_INET_CONF */
>  }
> =20

In this function why should we even take a reference, just to check if
pointer exists ?

If RTNL is held (I believe so), just use __in_dev_get_rtnl()

>  static int inet_fill_link_af(struct sk_buff *skb, const struct net_d=
evice *dev)
>  {
> -	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
> +	struct in_device *in_dev =3D in_dev_get(dev);
>  	struct nlattr *nla;
> -	int i;
> +	int i, ret =3D 0;
> =20
>  	if (!in_dev)
>  		return -ENODATA;
> =20
>  	nla =3D nla_reserve(skb, IFLA_INET_CONF, IPV4_DEVCONF_MAX * 4);
> -	if (nla =3D=3D NULL)
> -		return -EMSGSIZE;
> +	if (nla =3D=3D NULL) {
> +		ret =3D -EMSGSIZE;
> +		goto out;
> +	}
> =20
>  	for (i =3D 0; i < IPV4_DEVCONF_MAX; i++)
>  		((u32 *) nla_data(nla))[i] =3D in_dev->cnf.data[i];
> =20
> -	return 0;
> +out:
> +	in_dev_put(in_dev);
> +	return ret;
>  }


In this function we hold RTNL...
 Please use __in_dev_get_rtnl()


> =20
>  static const struct nla_policy inet_af_policy[IFLA_INET_MAX+1] =3D {
> @@ -1293,11 +1298,14 @@ static int inet_validate_link_af(const struct=
 net_device *dev,
>  				 const struct nlattr *nla)
>  {
>  	struct nlattr *a, *tb[IFLA_INET_MAX+1];
> +	struct in_device *in_dev =3D in_dev_get(dev);
>  	int err, rem;
> =20
> -	if (dev && !__in_dev_get_rcu(dev))
> +	if (dev && !in_dev)
>  		return -EAFNOSUPPORT;
> =20
> +	in_dev_put(in_dev);
> +
>  	err =3D nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
>  	if (err < 0)
>  		return err;
> @@ -1319,7 +1327,7 @@ static int inet_validate_link_af(const struct n=
et_device *dev,
> =20
>  static int inet_set_link_af(struct net_device *dev, const struct nla=
ttr *nla)
>  {
> -	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
> +	struct in_device *in_dev =3D in_dev_get(dev);
>  	struct nlattr *a, *tb[IFLA_INET_MAX+1];
>  	int rem;
> =20
> @@ -1334,6 +1342,7 @@ static int inet_set_link_af(struct net_device *=
dev, const struct nlattr *nla)
>  			ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
>  	}
> =20
> +	in_dev_put(in_dev);
>  	return 0;
>  }

Same here. RTNL is held. Please use __in_dev_get_rtnl()
