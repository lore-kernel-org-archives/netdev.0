From: Jonas Johansson <jonasj76@gmail.com>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Fri, 20 Feb 2015 17:19:55 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1502201657390.8221@hellgate.skynet>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-2-git-send-email-jonasj76@gmail.com> <20150220151248.GC13797@lunn.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:43107 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294AbbBTQXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 11:23:47 -0500
Received: by lbiw7 with SMTP id w7so7215039lbi.10
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 08:23:45 -0800 (PST)
In-Reply-To: <20150220151248.GC13797@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 20 Feb 2015, Andrew Lunn wrote:

> On Fri, Feb 20, 2015 at 11:51:12AM +0100, Jonas Johansson wrote:
>> From: Jonas Johansson <jonas.johansson@westermo.se>
>>
>> This patch will implement hooks for hardware bonding support for the DSA
>> driver. When the team driver adds a DSA slave port the port will be assigned
>> a bond group id and the DSA slave driver can setup the hardware. When team
>> changes the port state (enabled/disabled) the DSA slave driver is able to
>> use the attach/detach callback which will allow the hardware to change the
>> hardware settings to reflect the state.
>>
>> Added DSA hooks:
>>  bond_add_group: To add a port to a bond group
>>  bond_del_group: To remove a port from a bond group
>>  bond_attach: To mark the port in a bond group as attached/active
>>  bond_detach: To unmark the port in a bond group as detach/inactive
>>
>> Added new network device hooks:
>>  ndo_bond_attach: To attach a device to a bond group.
>>  ndo_bond_detach: To detach a device from a bond group.
>>
>> Team:
>>  Added callback to ndo_bond_attach when port is enabled.
>>  Added callback to ndo_bond_detach when port is disabled.
>>
>> Added DSA notifier:
>>  Listening on NETDEV_CHANGEUPPER to add or deleta a port to/from a bond group.
>>
>> Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
>> ---
>>  drivers/net/team/team.c   |  4 ++++
>>  include/linux/netdevice.h |  8 +++++++
>>  include/net/dsa.h         |  8 +++++++
>>  net/dsa/dsa.c             | 60 +++++++++++++++++++++++++++++++++++++++++++++++
>>  net/dsa/dsa_priv.h        |  6 +++++
>>  net/dsa/slave.c           | 23 ++++++++++++++++++
>>  6 files changed, 109 insertions(+)
>>
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> index 0e62274..f7b2afb 100644
>> --- a/drivers/net/team/team.c
>> +++ b/drivers/net/team/team.c
>> @@ -934,6 +934,8 @@ static void team_port_enable(struct team *team,
>>  		team->ops.port_enabled(team, port);
>>  	team_notify_peers(team);
>>  	team_mcast_rejoin(team);
>> +	if (port->dev->netdev_ops->ndo_bond_attach)
>> +		port->dev->netdev_ops->ndo_bond_attach(port->dev);
>>  }
>>
>>  static void __reconstruct_port_hlist(struct team *team, int rm_index)
>> @@ -965,6 +967,8 @@ static void team_port_disable(struct team *team,
>>  	team_adjust_ops(team);
>>  	team_notify_peers(team);
>>  	team_mcast_rejoin(team);
>> +	if (port->dev->netdev_ops->ndo_bond_detach)
>> +		port->dev->netdev_ops->ndo_bond_detach(port->dev);
>>  }
>>
>>  #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 5897b4e..8ebaefa 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -939,6 +939,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>   * int (*ndo_del_slave)(struct net_device *dev, struct net_device *slave_dev);
>>   *	Called to release previously enslaved netdev.
>>   *
>> + * int (*ndo_bond_attach)(struct net_device *dev);
>> + *	Called to attach the device to a bond group.
>> + *
>> + * int (*ndo_bond_detach)(struct net_device *dev);
>> + *	Called to detach the device from a bond group.
>> + *
>>   *      Feature/offload setting functions.
>>   * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
>>   *		netdev_features_t features);
>> @@ -1131,6 +1137,8 @@ struct net_device_ops {
>>  						 struct net_device *slave_dev);
>>  	int			(*ndo_del_slave)(struct net_device *dev,
>>  						 struct net_device *slave_dev);
>> +	int			(*ndo_bond_attach)(struct net_device *dev);
>> +	int			(*ndo_bond_detach)(struct net_device *dev);
>>  	netdev_features_t	(*ndo_fix_features)(struct net_device *dev,
>>  						    netdev_features_t features);
>>  	int			(*ndo_set_features)(struct net_device *dev,
>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>> index ed3c34b..64b5963 100644
>> --- a/include/net/dsa.h
>> +++ b/include/net/dsa.h
>> @@ -254,6 +254,14 @@ struct dsa_switch_driver {
>>  	int	(*get_eee)(struct dsa_switch *ds, int port,
>>  			   struct ethtool_eee *e);
>>
>> +	/*
>> +	 * Bonding
>> +	 */
>> +	int	(*bond_add_group)(struct dsa_switch *ds, int port, int gid);
>> +	int	(*bond_del_group)(struct dsa_switch *ds, int port, int gid);
>> +	int	(*bond_attach)(struct dsa_switch *ds, int port);
>> +	int	(*bond_detach)(struct dsa_switch *ds, int port);
>> +
>>  #ifdef CONFIG_NET_DSA_HWMON
>>  	/* Hardware monitoring */
>>  	int	(*get_temp)(struct dsa_switch *ds, int *temp);
>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>> index 2173402..3d2c599 100644
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -17,6 +17,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/module.h>
>>  #include <net/dsa.h>
>> +#include <net/rtnetlink.h>
>>  #include <linux/of.h>
>>  #include <linux/of_mdio.h>
>>  #include <linux/of_platform.h>
>> @@ -442,6 +443,62 @@ static void dsa_link_poll_timer(unsigned long _dst)
>>  	schedule_work(&dst->link_poll_work);
>>  }
>>
>> +/* net device notifier event handler ****************************************/
>> +static int dsa_master_changed(struct net_device *dev)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_switch *ds = p->parent;
>> +	struct net_device *master = netdev_master_upper_dev_get(dev);
>> +	int err = 0;
>> +
>> +	/* Add port to bond group */
>> +	if (master && master->rtnl_link_ops &&
>> +	    !strcmp(master->rtnl_link_ops->kind, "team")) {
>> +
>> +		p->bond_gid = master->ifindex;
>> +
>> +		if (!ds->drv->bond_add_group)
>> +			return -EOPNOTSUPP;
>> +		return ds->drv->bond_add_group(ds, p->port, p->bond_gid);
>> +	}
>
> Hi Jonas
>
> Maybe it is here and i cannot see it, but where do you check the slave
> devices in the group are in the same physical switch. Remember that
> DSA allows nearly arbitrary trees of switches.
>
>       Andrew
>
Thanks for the review.
You are correct, there is no check if the slave devices are in the same 
physical switch. I know that some devices (e.g. 88E6095) can handle 
cross-chip trunking, but as this implementation was targeting single-chip 
trunking you are correct that a check needs to be implemented to prevent 
the slaves to spread over several devices. I'll look into it.
