From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v4 2/6] bonding: implement bond_poll_controller()
Date: Wed, 18 Feb 2015 14:40:45 +0100
Message-ID: <54E4965D.5040203@redhat.com>
References: <1424243869-27029-1-git-send-email-maheshb@google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:51462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbbBRNk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 08:40:59 -0500
In-Reply-To: <1424243869-27029-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 08:17 AM, Mahesh Bandewar wrote:
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
> 
>  drivers/net/bonding/bond_main.c | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b979c265fc51..f6bdaae7519d 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -928,6 +928,37 @@ static inline void slave_disable_netpoll(struct slave *slave)
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
> +	bond_for_each_slave(bond, slave, iter) {
> +		ops = slave->dev->netdev_ops;
> +		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
> +			continue;
> +
> +		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +			struct aggregator *agg =
> +			    SLAVE_AD_INFO(slave)->port.aggregator;
> +
> +			if (agg && agg->aggregator_identifier !=
> +				   ad_info.aggregator_id)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Please move the second half on its own line without breaking it like
this.

> +				continue;
> +		}
> +
> +		ni = rcu_dereference_bh(slave->dev->npinfo);
> +		if (down_trylock(&ni->dev_lock))
> +			continue;
> +		ops->ndo_poll_controller(slave->dev);
> +		up(&ni->dev_lock);
> +	}
>  }
>  
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
> 
