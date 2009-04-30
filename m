From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH, resend] netconsole: take care of NETDEV_UNREGISTER
 event
Date: Thu, 30 Apr 2009 11:48:35 -0500
Message-ID: <1241110115.938.1603.camel@calx>
References: <20090429223722.62da9dcd@neptune.home>
	 <20090429225625.75a016ff@neptune.home>
	 <20090429.144420.262432582.davem@davemloft.net>
	 <20090430084517.6de15689@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:45216 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757809AbZD3QtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 12:49:13 -0400
In-Reply-To: <20090430084517.6de15689@pluto.restena.lu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-30 at 08:45 +0200, Bruno Pr=C3=A9mont wrote:
> When netconsole is loaded and a network interface fades away (e.g. on
> rmmod $interface_driver_module) the rmmod remains stuck and some lock=
s
> are taken that prevent any additional module loading/unloading as wel=
l
> as interface up/down changes.
> In addition kernel logs (and console) get flooded at 10s interval wit=
h
>=20
> [  122.464065] unregister_netdevice: waiting for eth0 to become free.=
 Usage count =3D 1
> [  132.704059] unregister_netdevice: waiting for eth0 to become free.=
 Usage count =3D 1
>=20
> This patch lets netconsole take NETDEV_UNREGISTER event into account
> and release the affected interface if it was in use.
>=20
> Signed-off-by: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index eceadf7..bf4af52 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -664,7 +664,7 @@ static int netconsole_netdev_event(struct notifie=
r_block *this,
>  	struct netconsole_target *nt;
>  	struct net_device *dev =3D ptr;
> =20
> -	if (!(event =3D=3D NETDEV_CHANGENAME))
> +	if (!(event =3D=3D NETDEV_CHANGENAME || event =3D=3D NETDEV_UNREGIS=
TER))
>  		goto done;
> =20
>  	spin_lock_irqsave(&target_list_lock, flags);
> @@ -675,6 +675,15 @@ static int netconsole_netdev_event(struct notifi=
er_block *this,
>  			case NETDEV_CHANGENAME:
>  				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
>  				break;
> +			case NETDEV_UNREGISTER:
> +				if (!nt->enabled)
> +					break;
> +				netpoll_cleanup(&nt->np);
> +				nt->enabled =3D 0;
> +				printk(KERN_INFO "netconsole: network logging stopped"
> +					", interface %s unregistered\n",
> +					dev->name);
> +				break;
>  			}
>  		}
>  		netconsole_target_put(nt);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
http://selenic.com : development and support for Mercurial and Linux


