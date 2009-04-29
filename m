From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [PATCH] netconsole: take care of  NETDEV_UNREGISTER event
Date: Wed, 29 Apr 2009 22:56:25 +0200
Message-ID: <20090429225625.75a016ff@neptune.home>
References: <20090429223722.62da9dcd@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758823AbZD2U4j@vger.kernel.org>
In-Reply-To: <20090429223722.62da9dcd@neptune.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(fix netdev CC)

The printk line is slightly over 80 though I have no better idea
for the line-wrapping while keeping it searchable with grep.

Bruno

On Wed, 29 April 2009 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org> wr=
ote:
> When netconsole is loaded and a network interface fades away (e.g. on
> rmmod $interface_driver_module) the rmmod remains stuck and some lock=
s
> are taken that prevent any additional module loading/unloading as wel=
l
> as interface up/down changes.
> In addition kernel logs (and console) get flooded at 10s interval wit=
h
>=20
> [  122.464065] unregister_netdevice: waiting for eth0 to become free.
> Usage count =3D 1 [  132.704059] unregister_netdevice: waiting for et=
h0
> to become free. Usage count =3D 1
>=20
> This patch lets netconsole take NETDEV_UNREGISTER event into account
> and release the affected interface if it was in use.
>=20
> Signed-off-by: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
> ---
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index eceadf7..bf4af52 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -664,7 +664,7 @@ static int netconsole_netdev_event(struct
> notifier_block *this, struct netconsole_target *nt;
>  	struct net_device *dev =3D ptr;
> =20
> -	if (!(event =3D=3D NETDEV_CHANGENAME))
> +	if (!(event =3D=3D NETDEV_CHANGENAME || event =3D=3D NETDEV_UNREGIS=
TER))
>  		goto done;
> =20
>  	spin_lock_irqsave(&target_list_lock, flags);
> @@ -675,6 +675,15 @@ static int netconsole_netdev_event(struct
> notifier_block *this, case NETDEV_CHANGENAME:
>  				strlcpy(nt->np.dev_name, dev->name,
> IFNAMSIZ); break;
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
