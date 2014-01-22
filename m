From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Re: [PATCH] net: Correctly sync addresses from multiple sources to
 single device
Date: Wed, 22 Jan 2014 18:18:21 +0400
Message-ID: <52DFD32D.4060805@oktetlabs.ru>
References: <1389988332-22472-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:56114 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754553AbaAVOSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 09:18:34 -0500
In-Reply-To: <1389988332-22472-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 11:52 PM, Vlad Yasevich wrote:
> When we have multiple devices attempting to sync the same address
> to a single destination, each device should be permitted to sync
> it once.  To accomplish this, pass the sync count of the source
> address to __hw_addr_add_ex().  'sync_cnt' tracks how many time
> a given address has been successfully synced.  If the address
> is found in the destination list, but the 'sync_cnt' of the source
> is 0, then this address has not been synced from this interface
> and we need to allow the sync operation to succeed thus incrementing
> reference counts.
>
> Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
> CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/core/dev_addr_lists.c | 12 +++++++-----
>   1 file changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
> index ec40a84..bd1b880 100644
> --- a/net/core/dev_addr_lists.c
> +++ b/net/core/dev_addr_lists.c
> @@ -48,7 +48,8 @@ static int __hw_addr_create_ex(struct netdev_hw_add=
r_list *list,
>  =20
>   static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
>   			    const unsigned char *addr, int addr_len,
> -			    unsigned char addr_type, bool global, bool sync)
> +			    unsigned char addr_type, bool global, bool sync,
> +			    int sync_count)
>   {
>   	struct netdev_hw_addr *ha;
>  =20
> @@ -66,7 +67,7 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_l=
ist *list,
>   					ha->global_use =3D true;
>   			}
>   			if (sync) {
> -				if (ha->synced)
> +				if (ha->synced && sync_count)
>   					return -EEXIST;
>   				else
>   					ha->synced =3D true;
> @@ -84,7 +85,8 @@ static int __hw_addr_add(struct netdev_hw_addr_list=
 *list,
>   			 const unsigned char *addr, int addr_len,
>   			 unsigned char addr_type)
>   {
> -	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, fal=
se);
> +	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, fal=
se,
> +				0);
>   }
>  =20
>   static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
> @@ -139,7 +141,7 @@ static int __hw_addr_sync_one(struct netdev_hw_ad=
dr_list *to_list,
>   	int err;
>  =20
>   	err =3D __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
> -			       false, true);
> +			       false, true, ha->sync_count);
>   	if (err && err !=3D -EEXIST)
>   		return err;
>  =20
> @@ -676,7 +678,7 @@ static int __dev_mc_add(struct net_device *dev, c=
onst unsigned char *addr,
>  =20
>   	netif_addr_lock_bh(dev);
>   	err =3D __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
> -			       NETDEV_HW_ADDR_T_MULTICAST, global, false);
> +			       NETDEV_HW_ADDR_T_MULTICAST, global, false, 0);
>   	if (!err)
>   		__dev_set_rx_mode(dev);
>   	netif_addr_unlock_bh(dev);

Thanks. The patch was tested with linux-3.12.6.

However, while building the kernel I got complains on:

> 	err =3D __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
> -			       false, true);
> +			       false, true, ha->sync_count);

Namely ha (struct netdev_hw_addr) has no field sync_count. It has sync_=
cnt.
So I=E2=80=99ve fixed this when testing the patch. Is it a typo or some=
thing intentional?

Your patch solves the initial problem, but it looks like it introduces =
a new one.

When interface joins multicast group corresponding MAC address is added=
 to the interface maddr list. It should be removed when socket explicit=
ly leaves the group or is just closed. It=E2=80=99s the case without yo=
ur patch. However, with the patched kernel address is still there after=
 socket is closed.

You can reproduce it with mcast_client binary (mcast_client.c was attac=
hed to the first letter in the thread). To be specific:

$ ip maddr show eth3
9:  eth3
  link  33:33:00:00:00:01 users 3
  link  01:00:5e:00:00:01 users 3
  link  33:33:ff:01:39:7c users 3
  link  01:80:c2:00:00:21 users 2
  inet  224.0.0.1
  inet6 ff02::1:ff01:397c
  inet6 ff02::1
  inet6 ff01::1

$ gcc mcast_client.c -o cl
$ sudo ./cl
Abort it with Ctrl+c
$ ip maddr show eth3
9:  eth3
  link  33:33:00:00:00:01 users 3
  link  01:00:5e:00:00:01 users 3
  link  33:33:ff:01:39:7c users 3
  link  01:80:c2:00:00:21 users 2
  link  01:00:5e:11:58:a8
  inet  224.0.0.1
  inet6 ff02::1:ff01:397c
  inet6 ff02::1
  inet6 ff01::1

'link 01:00:5e:11:58:a8=E2=80=99 address is still there. Should=E2=80=99=
ve been removed.

Andrey
