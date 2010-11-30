From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Tue, 30 Nov 2010 11:10:29 +0100
Message-ID: <1291111829.2904.25.camel@edumazet-laptop>
References: <4CF4CB85.4010708@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55311 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab0K3KKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 05:10:33 -0500
Received: by fxm8 with SMTP id 8so988999fxm.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 02:10:32 -0800 (PST)
In-Reply-To: <4CF4CB85.4010708@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 19:01 +0900, Taku Izumi a =C3=A9crit :
> This patch provides the sysfs interface to see RLB hash table
> like the following:
>=20
> # cat /sys/class/net/bond0/bonding/rlb_hash_table
>=20
> SourceIP        DestinationIP   Destination MAC   DEV
>  10.124.196.205  10.124.196. 81 00:19:99:XX:XX:XX eth3
>  10.124.196.205  10.124.196.222 00:0a:79:XX:XX:XX eth0
>  10.124.196.205  10.124.196. 75 00:15:17:XX:XX:XX eth4
>  10.124.196.205  10.124.196.  1 00:21:d8:XX:XX:XX eth3
>  10.124.196.205  10.124.196.205 ff:ff:ff:ff:ff:ff eth0
>=20

why spaces in IP addresses ?

>=20
> This is helpful to check if the receive load balancing works as expec=
ted.
>=20
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>=20
> ---
>  drivers/net/bonding/bond_sysfs.c |   56 ++++++++++++++++++++++++++++=
+++++++++++
>  1 file changed, 56 insertions(+)
>=20
> Index: net-next/drivers/net/bonding/bond_sysfs.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/bonding/bond_sysfs.c
> +++ net-next/drivers/net/bonding/bond_sysfs.c
> @@ -43,6 +43,7 @@
>  #include <linux/nsproxy.h>
>=20
>  #include "bonding.h"
> +#include "bond_alb.h"
>=20
>  #define to_dev(obj)	container_of(obj, struct device, kobj)
>  #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd)))=
)
> @@ -1643,6 +1644,60 @@ out:
>  static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
>  		   bonding_show_resend_igmp, bonding_store_resend_igmp);
>=20
> +/*
> + *  Show RLB hash table
> + */
> +#define RLB_NULL_INDEX  0xffffffff
> +static ssize_t bonding_show_rlb_hashtable(struct device *d,
> +					  struct device_attribute *attr,
> +					  char *buf)
> +{
> +	int count =3D 0;
> +	struct bonding *bond =3D to_bond(d);
> +	struct alb_bond_info *bond_info =3D &(BOND_ALB_INFO(bond));
> +	struct rlb_client_info *client_info;
> +	u32 hash_index;
> +
> +	if (bond->params.mode !=3D BOND_MODE_ALB)
> +		return count;
> +
> +	count +=3D sprintf(buf + count, "SourceIP        "
> +		"DestinationIP   Destination MAC   DEV\n");
> +
> +	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
> +
> +	hash_index =3D bond_info->rx_hashtbl_head;
> +	for (; hash_index !=3D RLB_NULL_INDEX; hash_index =3D client_info->=
next) {
> +		client_info =3D &(bond_info->rx_hashtbl[hash_index]);
> +
> +		count +=3D sprintf(buf + count,
> +			"%3d.%3d.%3d.%3d %3d.%3d.%3d.%3d "
> +			"%02x:%02x:%02x:%02x:%02x:%02x %s\n",


Oh well, I guess you dont read Joe patches on netdev ;)

Please take a look at %pI4 and %pM

sprintf(buf + count, "%pI4 %pI4 %pM %s\n", ...)


> +			client_info->ip_src & 0xff,
> +			(client_info->ip_src >> 8) & 0xff,
> +			(client_info->ip_src >> 16) & 0xff,
> +			(client_info->ip_src >> 24) & 0xff,
> +			client_info->ip_dst & 0xff,
> +			(client_info->ip_dst >> 8) & 0xff,
> +			(client_info->ip_dst >> 16) & 0xff,
> +			(client_info->ip_dst >> 24) & 0xff,
> +			client_info->mac_dst[0],
> +			client_info->mac_dst[1],
> +			client_info->mac_dst[2],
> +			client_info->mac_dst[3],
> +			client_info->mac_dst[4],
> +			client_info->mac_dst[5],
> +			client_info->slave->dev->name);
> +	}
> +

