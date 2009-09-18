From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: set primary param
 via	sysfs
Date: Fri, 18 Sep 2009 22:21:21 +0200
Message-ID: <4AB3EBC1.6070100@free.fr>
References: <20090918121321.GB2801@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:45533 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757789AbZIRUV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 16:21:28 -0400
In-Reply-To: <20090918121321.GB2801@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Primary module parameter passed to bonding is pernament. That means if you

typo in "permanent".

> release the primary slave and enslave it again, it becomes the primary slave
> again. But if you set primary slave via sysfs, the primary slave is only set
> once and it's not remembered in bond->params structure. Therefore the setting is
> lost after releasing the primary slave. This simple one-liner fixes this.

You patch also has the side effect of fixing this strange behavior:

If you move the primary slave from one bond device to another one, it becomes 
the primary for this other bond device, ignoring what you might have set as the 
primary for this other bond device.

#modprobe bonding mode=active-backup primary=eth0
#echo +eth0 > /sys/class/net/bond0/bonding/slaves
#cat /sys/class/net/bond0/bonding/primary
eth0
#echo -eth0 > /sys/class/net/bond0/bonding/slaves

#echo +eth1 > /sys/class/net/bond1/bonding/slaves
#echo eth1 > /sys/class/net/bond1/bonding/primary
#cat /sys/class/net/bond1/bonding/primary
eth1
#echo +eth0 > /sys/class/net/bond1/bonding/slaves
#cat /sys/class/net/bond1/bonding/primary
eth0

=> Primary just changed, for no good reason.

Can someone imagine that some current configurations rely on this incredible 
side effect ?

	Nicolas.

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 6044e12..ff449de 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -1182,6 +1182,7 @@ static ssize_t bonding_store_primary(struct device *d,
>  				       ": %s: Setting %s as primary slave.\n",
>  				       bond->dev->name, slave->dev->name);
>  				bond->primary_slave = slave;
> +				strcpy(bond->params.primary, slave->dev->name);
>  				bond_select_active_slave(bond);
>  				goto out;
>  			}

