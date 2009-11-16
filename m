From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: factorize rt_do_flush for batch device unregistering
Date: Mon, 16 Nov 2009 22:32:55 +0100
Message-ID: <4B01C507.9050908@gmail.com>
References: <200911162308.59730.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39617 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464AbZKPVcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 16:32:54 -0500
In-Reply-To: <200911162308.59730.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> Tests performed with per device sysctl/sysfs entries disabled:
>=20
> $ insmod /lib/modules/dummy.ko numdummies=3D8000
> $ time rmmod dummy
>=20
> Without the patch:    With the patch:
> real    0m 3.65s      real    0m 0.27s
> user    0m 0.00s      user    0m 0.00s
> sys     0m 3.42s      sys     0m 0.24s
>=20
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/core/dev.c          |   28 ++++++++++++++++++++++++++--
>  net/ipv4/fib_frontend.c |   13 ++++++++-----
>  2 files changed, 34 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4b24d79..b0a14f0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4720,7 +4720,8 @@ static void net_set_todo(struct net_device *dev=
)
> =20
>  static void rollback_registered_many(struct list_head *head)
>  {
> -	struct net_device *dev;
> +	struct net_device *dev, *aux, *fdev;
> +	LIST_HEAD(rt_flush_list);
> =20
>  	BUG_ON(dev_boot_phase);
>  	ASSERT_RTNL();
> @@ -4778,8 +4779,28 @@ static void rollback_registered_many(struct li=
st_head *head)
> =20
>  	synchronize_net();
> =20
> -	list_for_each_entry(dev, head, unreg_list)
> +	/* flush route cache by resending one NETDEV_UNREGISTER per namespa=
ce */
> +	list_for_each_entry_safe(dev, aux, head, unreg_list) {
> +		int needs_flush =3D 1;
> +		list_for_each_entry(fdev, &rt_flush_list, unreg_list) {
> +			if (dev_net(dev) =3D=3D dev_net(fdev)) {
> +				needs_flush =3D 0;
> +				dev_put(dev);
> +				break;
> +			}
> +		}
> +		if (needs_flush) {
> +			list_del(&dev->unreg_list);
> +			list_add(&dev->unreg_list, &rt_flush_list);

list_move ...

> +		}
> +	}
> +
> +	list_for_each_entry_safe(dev, aux, &rt_flush_list, unreg_list) {
> +		list_del_init(&dev->unreg_list);
> +		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> +		list_add(&dev->unreg_list, head);
>  		dev_put(dev);
> +	}
>  }
> =20
>  static void rollback_registered(struct net_device *dev)
> @@ -5374,6 +5395,9 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
>   *	unregister_netdevice_many - unregister many devices
>   *	@head: list of devices
>   *
> + *	WARNING: This function modifies the list. It may change the order=
 of the
> + *	elements in the list. However, you can assume it does not add or =
delete
> + *	elements to/from the list.

Sorry I dont understand this comment

>   */
>  void unregister_netdevice_many(struct list_head *head)
>  {
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 816e218..1972760 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -895,11 +895,11 @@ static void nl_fib_lookup_exit(struct net *net)
>  	net->ipv4.fibnl =3D NULL;
>  }
> =20
> -static void fib_disable_ip(struct net_device *dev, int force)
> +static void fib_disable_ip(struct net_device *dev, int force, int de=
lay)
>  {
>  	if (fib_sync_down_dev(dev, force))
>  		fib_flush(dev_net(dev));
> -	rt_cache_flush(dev_net(dev), 0);
> +	rt_cache_flush(dev_net(dev), delay);
>  	arp_ifdown(dev);
>  }
> =20
> @@ -922,7 +922,7 @@ static int fib_inetaddr_event(struct notifier_blo=
ck *this, unsigned long event,
>  			/* Last address was deleted from this interface.
>  			   Disable IP.
>  			 */
> -			fib_disable_ip(dev, 1);
> +			fib_disable_ip(dev, 1, 0);
>  		} else {
>  			rt_cache_flush(dev_net(dev), -1);
>  		}
> @@ -937,7 +937,10 @@ static int fib_netdev_event(struct notifier_bloc=
k *this, unsigned long event, vo
>  	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
> =20
>  	if (event =3D=3D NETDEV_UNREGISTER) {
> -		fib_disable_ip(dev, 2);
> +		/* if this event is part of a batch then don't flush the cache
> +		 * now; we will receive another event at the end of the batch */
> +		int rt_flush =3D list_empty(&dev->unreg_list) ? 0 : -1;

hmm... a bit ugly...

> +		fib_disable_ip(dev, 2, rt_flush);
>  		return NOTIFY_DONE;
>  	}
> =20
> @@ -955,7 +958,7 @@ static int fib_netdev_event(struct notifier_block=
 *this, unsigned long event, vo
>  		rt_cache_flush(dev_net(dev), -1);
>  		break;
>  	case NETDEV_DOWN:
> -		fib_disable_ip(dev, 0);
> +		fib_disable_ip(dev, 0, 0);
>  		break;
>  	case NETDEV_CHANGEMTU:
>  	case NETDEV_CHANGE:


Are you sure you want to overload NETDEV_UNREGISTER ?

Maybe it would be cleaner to add a new value, NETDEV_UNREGISTER_PERNET =
or something=20
for the final loop...
