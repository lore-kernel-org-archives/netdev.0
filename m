From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] bonding: fix netdev event NULL pointer dereference
Date: Thu, 11 Apr 2013 17:40:01 +0400
Message-ID: <5166BD31.5020404@cogentembedded.com>
References: <1365538644-1502-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:50207 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935039Ab3DKNlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 09:41:05 -0400
Received: by mail-lb0-f181.google.com with SMTP id r11so1614320lbv.12
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 06:41:03 -0700 (PDT)
In-Reply-To: <1365538644-1502-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-04-2013 0:17, Nikolay Aleksandrov wrote:

> In commit 471cb5a33dcbd7c529684a2ac7ba4451414ee4a7 ("bonding: remove
> usage of dev->master") a bug was introduced which causes a NULL pointer
> dereference. If a bond device is in mode 6 (ALB) and a slave is added
> it will dereference a NULL pointer in bond_slave_netdev_event().
> This is because in bond_enslave we have bond_alb_init_slave() which
> changes the MAC address of the slave and causes a NETDEV_CHANGEADDR.
> Then we have in bond_slave_netdev_event():
>          struct slave *slave = bond_slave_get_rtnl(slave_dev);
>          struct bonding *bond = slave->bond;
> bond_slave_get_rtnl() dereferences slave_dev->rx_handler_data which at
> that time is NULL since netdev_rx_handler_register() is called later.

> This is fixed by checking if slave is NULL before dereferencing it.

> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
[...]

    Minor formatting nit.

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 171b10f..9995ddc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3168,11 +3168,21 @@ static int bond_slave_netdev_event(unsigned long event,
>   				   struct net_device *slave_dev)
>   {
>   	struct slave *slave = bond_slave_get_rtnl(slave_dev);
> -	struct bonding *bond = slave->bond;
> -	struct net_device *bond_dev = slave->bond->dev;
> +	struct bonding *bond;
> +	struct net_device *bond_dev;
>   	u32 old_speed;
>   	u8 old_duplex;
>
> +	/*
> +	 * A netdev event can be generated while enslaving a device
> +	 * before netdev_rx_handler_register is called in which case
> +	 * slave will be NULL
> +	 */

    The preferred multi-line comment style in the networking code is:

/* bla
  * bla
  */

WBR, Sergei
