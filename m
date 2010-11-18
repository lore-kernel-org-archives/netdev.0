From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch -next] Adapt s390 qeth & lcs driver code to use RCU
Date: Thu, 18 Nov 2010 10:33:14 +0100
Message-ID: <1290072794.2781.10.camel@edumazet-laptop>
References: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-s390@vger.kernel.org, linux-next@vger.kernel.org,
	ursula.braun@de.ibm.com
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 18 novembre 2010 =C3=A0 14:48 +0530, Sachin Sant a =C3=A9crit =
:
> Commit 1d7138de878d1d4210727c1200193e69596f93b3
> igmp: RCU conversion of in_dev->mc_list
>=20
> converted rwlock to RCU.
>=20
> Update the s390 network drivers(qeth & lcs) code to adapt to this cha=
nge.
>=20
> Signed-off-by : Sachin Sant <sachinp@in.ibm.com>
> ---
>=20
> Only compile tested.
>=20

Hmm, sorry but this wont work.

> diff -Narup linux-2.6-next/drivers/s390/net/lcs.c linux-2.6-next-new/=
drivers/s390/net/lcs.c
> --- linux-2.6-next/drivers/s390/net/lcs.c	2010-11-17 11:38:25.0000000=
00 +0530
> +++ linux-2.6-next-new/drivers/s390/net/lcs.c	2010-11-18 11:59:46.000=
000000 +0530
> @@ -1269,10 +1269,10 @@ lcs_register_mc_addresses(void *data)
>  	in4_dev =3D in_dev_get(card->dev);
>  	if (in4_dev =3D=3D NULL)
>  		goto out;
> -	read_lock(&in4_dev->mc_list_lock);
> +	rcu_read_lock();

If you use rcu_read_lock(), then you also need to=20
use the rcu list iterators in lcs_remove_mc_addresses() and
lcs_set_mc_addresses()

Then, its strange this driver is not protected by RTNL at this stage.

Ah yes, it uses a kthread from its ndo_set_multicast_list() handler.

This seems not safe at all.


>  	lcs_remove_mc_addresses(card,in4_dev);
>  	lcs_set_mc_addresses(card, in4_dev);
> -	read_unlock(&in4_dev->mc_list_lock);
> +	rcu_read_unlock();
>  	in_dev_put(in4_dev);
> =20
>  	netif_carrier_off(card->dev);
> diff -Narup linux-2.6-next/drivers/s390/net/qeth_l3_main.c linux-2.6-=
next-new/drivers/s390/net/qeth_l3_main.c
> --- linux-2.6-next/drivers/s390/net/qeth_l3_main.c	2010-10-30 12:54:2=
2.000000000 +0530
> +++ linux-2.6-next-new/drivers/s390/net/qeth_l3_main.c	2010-11-18 11:=
59:13.000000000 +0530
> @@ -1828,9 +1828,9 @@ static void qeth_l3_add_vlan_mc(struct q
>  		in_dev =3D in_dev_get(netdev);
>  		if (!in_dev)
>  			continue;
> -		read_lock(&in_dev->mc_list_lock);
> +		rcu_read_lock();
>  		qeth_l3_add_mc(card, in_dev);
> -		read_unlock(&in_dev->mc_list_lock);
> +		rcu_read_unlock();
>  		in_dev_put(in_dev);
>  	}
>  }
> @@ -1843,10 +1843,10 @@ static void qeth_l3_add_multicast_ipv4(s
>  	in4_dev =3D in_dev_get(card->dev);
>  	if (in4_dev =3D=3D NULL)
>  		return;
> -	read_lock(&in4_dev->mc_list_lock);
> +	rcu_read_lock();
>  	qeth_l3_add_mc(card, in4_dev);
>  	qeth_l3_add_vlan_mc(card);
> -	read_unlock(&in4_dev->mc_list_lock);
> +	rcu_read_unlock();
>  	in_dev_put(in4_dev);
>  }
> =20
