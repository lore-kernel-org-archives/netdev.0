From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv4: Add hash table of interface addresses.
Date: Fri, 18 Feb 2011 07:22:30 +0100
Message-ID: <1298010150.2642.5.camel@edumazet-laptop>
References: <20110217.204638.104041410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41455 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab1BRGWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 01:22:38 -0500
Received: by bwz15 with SMTP id 15so421010bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 22:22:37 -0800 (PST)
In-Reply-To: <20110217.204638.104041410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 f=C3=A9vrier 2011 =C3=A0 20:46 -0800, David Miller a =C3=A9=
crit :
> This will be used to optimize __ip_dev_find() and friends.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/inetdevice.h |    1 +
>  net/ipv4/devinet.c         |   44 ++++++++++++++++++++++++++++++++++=
++++++++++
>  2 files changed, 45 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index ae8fdc5..5f81466 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -144,6 +144,7 @@ static inline void ipv4_devconf_setall(struct in_=
device *in_dev)
>  #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIF=
Y)
> =20
>  struct in_ifaddr {
> +	struct hlist_node	hash;
>  	struct in_ifaddr	*ifa_next;
>  	struct in_device	*ifa_dev;
>  	struct rcu_head		rcu_head;
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 748cb5b..c1f2552 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -92,6 +92,38 @@ static const struct nla_policy ifa_ipv4_policy[IFA=
_MAX+1] =3D {
>  	[IFA_LABEL]     	=3D { .type =3D NLA_STRING, .len =3D IFNAMSIZ - 1 =
},
>  };
> =20
> +/* inet_addr_hash's shifting is dependent upon this IN4_ADDR_HSIZE
> + * value.  So if you change this define, make appropriate changes to
> + * inet_addr_hash as well.
> + */
> +#define IN4_ADDR_HSIZE	256
> +static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
> +static DEFINE_SPINLOCK(inet_addr_hash_lock);
> +
> +static inline unsigned int inet_addr_hash(__be32 addr)
> +{
> +	u32 val =3D (__force u32) addr;
> +
> +	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> +		(IN4_ADDR_HSIZE - 1));
> +}

Maybe you should take into account net pointer here, or machines with
many net namespaces will hash collide for 127.0.0.1



