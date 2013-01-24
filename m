From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next] bond: have random dev address by default instead
 of zeroes
Date: Thu, 24 Jan 2013 09:37:17 -0500
Message-ID: <CAHashqDcxXdU7_2SuJnq+bxOUDdosfdyJAF+CDTsKR=c8nARCg@mail.gmail.com>
References: <1359022329-6919-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:58814 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab3AXOoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 09:44:01 -0500
Received: by mail-ob0-f181.google.com with SMTP id wc18so4364370obb.12
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 06:44:01 -0800 (PST)
In-Reply-To: <1359022329-6919-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 5:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Makes more sense to have randomly generated address by default than to
> have all zeroes. It also allows user to for example put the bond into
> bridge without need to have any slaves in it.
>
> Also, fix dev_assign_type values on the way.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Seems like a pretty good plan.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
>  1 file changed, 16 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 564cf42..af3a777 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
>
>  /*---------------------------------- IOCTL ----------------------------------*/
>
> -static int bond_sethwaddr(struct net_device *bond_dev,
> -                         struct net_device *slave_dev)
> +static void bond_set_dev_addr(struct net_device *bond_dev,
> +                             struct net_device *slave_dev)
>  {
>         pr_debug("bond_dev=%p\n", bond_dev);
>         pr_debug("slave_dev=%p\n", slave_dev);
>         pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
>         memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
> -       return 0;
> +       bond_dev->addr_assign_type |= NET_ADDR_SET;
>  }
>
>  static netdev_features_t bond_fix_features(struct net_device *dev,
> @@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>
>         /* If this is the first slave, then we need to set the master's hardware
>          * address to be the same as the slave's. */
> -       if (is_zero_ether_addr(bond->dev->dev_addr))
> -               memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
> -                      slave_dev->addr_len);
> -
> +       if (bond->dev->addr_assign_type != NET_ADDR_SET)
> +               bond_set_dev_addr(bond->dev, slave_dev);
>
>         new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
>         if (!new_slave) {
> @@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
>         if (bond->slave_cnt == 0) {
>                 bond_set_carrier(bond);
>
> -               /* if the last slave was removed, zero the mac address
> -                * of the master so it will be set by the application
> -                * to the mac address of the first slave
> +               /* If the last slave was removed, set random mac address
> +                * of the master so it will be set by bond_enslave()
> +                * to the mac address of the first slave.
>                  */
> -               memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
> +               eth_hw_addr_random(bond_dev);
>
>                 if (bond_vlan_used(bond)) {
>                         pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
> @@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
>                         break;
>                 case BOND_SETHWADDR_OLD:
>                 case SIOCBONDSETHWADDR:
> -                       res = bond_sethwaddr(bond_dev, slave_dev);
> +                       bond_set_dev_addr(bond_dev, slave_dev);
> +                       res = 0;
>                         break;
>                 case BOND_CHANGE_ACTIVE_OLD:
>                 case SIOCBONDCHANGEACTIVE:
> @@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_dev)
>
>         bond_debug_register(bond);
>
> +       /* Ensure valid dev_addr */
> +       if (is_zero_ether_addr(bond_dev->dev_addr) &&
> +           bond_dev->addr_assign_type == NET_ADDR_PERM)
> +               eth_hw_addr_random(bond_dev);
> +
>         __hw_addr_init(&bond->mc_list);
>         return 0;
>  }
> --
> 1.8.1
>
