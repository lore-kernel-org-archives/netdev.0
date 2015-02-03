From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 03/10] net/bonding: Notify state change on slaves
Date: Tue, 03 Feb 2015 17:09:27 +0100
Message-ID: <54D0F2B7.4000005@redhat.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com> <1422974919-28084-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933938AbbBCQJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 11:09:37 -0500
In-Reply-To: <1422974919-28084-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/15 15:48, Or Gerlitz wrote:
> From: Moni Shoua <monis@mellanox.com>
> 
> Use notifier chain to dispatch an event upon a change in slave state.
> Event is dispatched with slave specific info.
> 
> Signed-off-by: Moni Shoua <monis@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c |   42 +++++++++++++++++++++++++++++++++++++++
>  include/net/bonding.h           |   12 +++++++++++
>  2 files changed, 54 insertions(+), 0 deletions(-)
> 

Hi Or,
A few questions below,

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0665608..c9771f3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1191,6 +1191,47 @@ static void bond_fill_ifslave(struct slave *slave, struct ifslave *info)
>  	info->link_failure_count = slave->link_failure_count;
>  }
>  
> +static void bond_netdev_notify(struct slave *slave, struct net_device *dev)
> +{
> +	struct bonding *bond = slave->bond;
^^^^^^^^^^^
What if the struct slave where "slave" points to gets freed before this execution ?

> +	struct netdev_bonding_info bonding_info;
> +
> +	rtnl_lock();
> +	/* make sure that slave is still valid */
> +	if (dev->priv_flags & IFF_BONDING) {
^^^^^^^
What if the slave is released, enslaved to a different bond and the old bond is
destroyed between the dereference up there and the rtnl_lock() ?
Or the bonding gets unloaded altogether ?

> +		bond_fill_ifslave(slave, &bonding_info.slave);
> +		bond_fill_ifbond(bond, &bonding_info.master);
> +		netdev_bonding_info_change(slave->dev, &bonding_info);
> +	}
> +	rtnl_unlock();
> +}
> +
> +static void bond_netdev_notify_work(struct work_struct *_work)
> +{
> +	struct netdev_notify_work *w =
> +		container_of(_work, struct netdev_notify_work, work.work);
> +
> +	bond_netdev_notify(w->slave, w->dev);
> +	dev_put(w->dev);
> +}
> +
> +void bond_queue_slave_event(struct slave *slave)
> +{
> +	struct netdev_notify_work *nnw = kzalloc(sizeof(*nnw), GFP_ATOMIC);
^^^^^^^^
Where's this freed after the work's done ?

> +
> +	if (!nnw)
> +		return;
> +
> +	INIT_DELAYED_WORK(&nnw->work, bond_netdev_notify_work);
> +	nnw->slave = slave;
> +	nnw->dev = slave->dev;
> +
> +	if (queue_delayed_work(slave->bond->wq, &nnw->work, 0))
> +		dev_hold(slave->dev);
> +	else
> +		kfree(nnw);
> +}
> +
<snip>

Cheers,
 Nik
