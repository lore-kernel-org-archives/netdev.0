From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC Patch 3/3] bonding: make bonding support netpoll
Date: Mon, 22 Mar 2010 20:56:39 -0400
Message-ID: <20100323005639.GH2108@gospo.rdu.redhat.com>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain> <20100322082123.4967.77433.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100322082123.4967.77433.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 22, 2010 at 04:17:40AM -0400, Amerigo Wang wrote:
> 
> Based on Andy's work, but I modify a lot.
> 
> Similar to the patch for bridge, this patch does:
> 
> 1) implement the 4 methods to support netpoll for bonding;
> 
> 2) modify netpoll during forwarding packets in bonding;
> 
> 3) disable netpoll support of bridge when a netpoll-unabled device
>    is added to bonding;
> 
> 4) enable netpoll support when all underlying devices support netpoll.
> 
> Cc: Andy Gospodarek <gospo@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 

How much testing was done on this?

One of the potential problems with this code is how gracefully the
system can handle tear-down of interfaces or removal of the bonding
module when netconsole is active.  Was that tested heavily?

> 
> ---
> Index: linux-2.6/drivers/net/bonding/bond_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/bonding/bond_main.c
> +++ linux-2.6/drivers/net/bonding/bond_main.c
> @@ -59,6 +59,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/errno.h>
>  #include <linux/netdevice.h>
> +#include <linux/netpoll.h>
>  #include <linux/inetdevice.h>
>  #include <linux/igmp.h>
>  #include <linux/etherdevice.h>
> @@ -430,7 +431,17 @@ int bond_dev_queue_xmit(struct bonding *
>  	}
>  
>  	skb->priority = 1;
> -	dev_queue_xmit(skb);
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	if (bond->dev->priv_flags & IFF_IN_NETPOLL) {
> +		bond->dev->npinfo->netpoll->dev = skb->dev;
> +		if (!slave_dev->npinfo)
> +			slave_dev->npinfo = bond->dev->npinfo;
> +		slave_dev->priv_flags |= IFF_IN_NETPOLL;
> +		netpoll_send_skb(bond->dev->npinfo->netpoll, skb);
> +		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
> +	} else
> +#endif
> +		dev_queue_xmit(skb);
>  
>  	return 0;
>  }
> @@ -1324,6 +1335,87 @@ static void bond_detach_slave(struct bon
>  	bond->slave_cnt--;
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static bool slaves_support_netpoll(struct net_device *bond_dev)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	int i = 0;
> +	bool ret = true;
> +
> +	read_lock_bh(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL)
> +				|| !slave->dev->netdev_ops->ndo_poll_controller)
> +			ret = false;
> +	}
> +	read_unlock_bh(&bond->lock);
> +	return i != 0 && ret;
> +}
> +
> +static void bond_poll_controller(struct net_device *bond_dev)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	int i;
> +
> +	read_lock(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		if (slave->dev->netdev_ops->ndo_poll_controller)
> +			netpoll_poll_dev(slave->dev);
> +	}
> +	read_unlock(&bond->lock);
> +}
> +
> +static void bond_netpoll_setup(struct net_device *bond_dev,
> +			      struct netpoll_info *npinfo)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	int i;
> +
> +	write_lock_bh(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		if (slave->dev)
> +			slave->dev->npinfo = npinfo;
> +	}
> +	write_unlock_bh(&bond->lock);
> +}
> +
> +static void bond_netpoll_cleanup(struct net_device *bond_dev)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	const struct net_device_ops *ops;
> +	int i;
> +
> +	write_lock_bh(&bond->lock);
> +	bond_dev->npinfo = NULL;
> +	bond_for_each_slave(bond, slave, i) {
> +		if (slave->dev) {
> +			ops = slave->dev->netdev_ops;
> +			if (ops->ndo_netpoll_cleanup)
> +				ops->ndo_netpoll_cleanup(slave->dev);
> +			else
> +				slave->dev->npinfo = NULL;
> +		}
> +	}
> +	write_unlock_bh(&bond->lock);
> +}
> +
> +static int bond_netpoll_xmit(struct netpoll *np, struct sk_buff *skb,
> +			     struct net_device *dev)
> +{
> +	int ret;
> +
> +	dev->priv_flags |= IFF_IN_NETPOLL;
> +	ret = dev->netdev_ops->ndo_start_xmit(skb, dev);
> +	np->dev = dev;
> +	dev->priv_flags &= ~IFF_IN_NETPOLL;
> +	return ret;
> +}
> +#endif
> +
>  /*---------------------------------- IOCTL ----------------------------------*/
>  
>  static int bond_sethwaddr(struct net_device *bond_dev,
> @@ -1741,6 +1833,18 @@ int bond_enslave(struct net_device *bond
>  		new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
>  		new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	if (slaves_support_netpoll(bond_dev)) {
> +		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
> +		if (bond_dev->npinfo)
> +			slave_dev->npinfo = bond_dev->npinfo;
> +	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
> +		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
> +		pr_info("New slave device %s does not support netpoll\n",
> +			slave_dev->name);
> +		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
> +	}
> +#endif
>  	/* enslave is successful */
>  	return 0;
>  
> @@ -1924,6 +2028,15 @@ int bond_release(struct net_device *bond
>  
>  	netdev_set_master(slave_dev, NULL);
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	if (slaves_support_netpoll(bond_dev))
> +		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
> +	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
> +		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
> +	else
> +		slave_dev->npinfo = NULL;
> +#endif
> +
>  	/* close slave before restoring its mac address */
>  	dev_close(slave_dev);
>  
> @@ -2032,6 +2145,9 @@ static int bond_release_all(struct net_d
>  
>  		netdev_set_master(slave_dev, NULL);
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +		slave_dev->npinfo = NULL;
> +#endif
>  		/* close slave before restoring its mac address */
>  		dev_close(slave_dev);
>  
> @@ -4424,6 +4540,12 @@ static const struct net_device_ops bond_
>  	.ndo_vlan_rx_register	= bond_vlan_rx_register,
>  	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_netpoll_setup	= bond_netpoll_setup,
> +	.ndo_netpoll_xmit	= bond_netpoll_xmit,
> +	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
> +	.ndo_poll_controller	= bond_poll_controller,
> +#endif
>  };
>  
>  static void bond_setup(struct net_device *bond_dev)
