From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v5 2/6] bonding: implement bond_poll_controller()
Date: Thu, 19 Feb 2015 01:10:14 +0100
Message-ID: <54E529E6.609@redhat.com>
References: <1424298682-18227-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382AbbBSAK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 19:10:27 -0500
In-Reply-To: <1424298682-18227-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 11:31 PM, Mahesh Bandewar wrote:
> This patches implements the poll_controller support for all
> bonding driver. If the slaves have poll_controller net_op defined,
> this implementation calls them. This is mode agnostic implementation
> and iterates through all slaves (based on mode) and calls respective
> handler.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>    Initial version
> v2:
>    Eliminate bool variable.
> v3:
>    Rebase
> v4:
>    Removed 3AD port_operational check
> v5:
>    Added rtnl protection for bond_for_each_slave()
> 
>  drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 

Hi Mahesh,
I should've explained more in my review, you cannot sleep in
bond_poll_controller() so you cannot acquire rtnl like that. I was thinking
more about using rcu and switching to the _rcu version of
bond_for_each_slave instead.

Cheers,
 Nik

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b979c265fc51..63e6c0dbe7b3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -928,6 +928,39 @@ static inline void slave_disable_netpoll(struct slave *slave)
>  
>  static void bond_poll_controller(struct net_device *bond_dev)
>  {
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave = NULL;
> +	struct list_head *iter;
> +	struct ad_info ad_info;
> +	struct netpoll_info *ni;
> +	const struct net_device_ops *ops;
> +
> +	if (BOND_MODE(bond) == BOND_MODE_8023AD)
> +		if (bond_3ad_get_active_agg_info(bond, &ad_info))
> +			return;
> +
> +	rtnl_lock();
> +	bond_for_each_slave(bond, slave, iter) {
> +		ops = slave->dev->netdev_ops;
> +		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
> +			continue;
> +
> +		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +			struct aggregator *agg =
> +			    SLAVE_AD_INFO(slave)->port.aggregator;
> +
> +			if (agg &&
> +			    agg->aggregator_identifier != ad_info.aggregator_id)
> +				continue;
> +		}
> +
> +		ni = rcu_dereference_bh(slave->dev->npinfo);
> +		if (down_trylock(&ni->dev_lock))
> +			continue;
> +		ops->ndo_poll_controller(slave->dev);
> +		up(&ni->dev_lock);
> +	}
> +	rtnl_unlock();
>  }
>  
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
> 
