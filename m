From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: fix error handling if slave is busy (v2)
Date: Sun, 01 Jan 2012 01:09:50 +0100
Message-ID: <4EFFA44E.10507@gmail.com>
References: <20111230144023.371be015@nehalam.linuxnetplumber.net>	<4EFF3419.4050504@gmail.com> <20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59716 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab2AAAJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 19:09:35 -0500
Received: by wibhm6 with SMTP id hm6so7725734wib.19
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2011 16:09:33 -0800 (PST)
In-Reply-To: <20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/01/2012 00:26, Stephen Hemminger a =E9crit :
> If slave device already has a receive handler registered, then the
> error unwind of bonding device enslave function is broken.
>
> The following will leave a pointer to freed memory in the slave
> device list, causing a later kernel panic.
> # modprobe dummy
> # ip li add dummy0-1 link dummy0 type macvlan
> # modprobe bonding
> # echo +dummy0>/sys/class/net/bond0/bonding/slaves
>
> The fix is to detach the slave (which removes it from the list)
> in the unwind path.
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>

Thanks Stephen.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> ---
> v2 - need to keep original err_close for other unwind
>
> --- a/drivers/net/bonding/bond_main.c	2011-12-30 14:20:03.171823181 -=
0800
> +++ b/drivers/net/bonding/bond_main.c	2011-12-31 15:20:16.493379415 -=
0800
> @@ -1822,7 +1822,7 @@ int bond_enslave(struct net_device *bond
>   				 "but new slave device does not support netpoll.\n",
>   				 bond_dev->name);
>   			res =3D -EBUSY;
> -			goto err_close;
> +			goto err_detach;
>   		}
>   	}
>   #endif
> @@ -1831,7 +1831,7 @@ int bond_enslave(struct net_device *bond
>
>   	res =3D bond_create_slave_symlinks(bond_dev, slave_dev);
>   	if (res)
> -		goto err_close;
> +		goto err_detach;
>
>   	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
>   					 new_slave);
> @@ -1852,6 +1852,11 @@ int bond_enslave(struct net_device *bond
>   err_dest_symlinks:
>   	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>
> +err_detach:
> +	write_lock_bh(&bond->lock);
> +	bond_detach_slave(bond, new_slave);
> +	write_unlock_bh(&bond->lock);
> +
>   err_close:
>   	dev_close(slave_dev);
>
>
>
>
