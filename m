From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] bonding: move bond-specific init after enslave
 happens
Date: Mon, 21 Oct 2013 09:35:09 +0800
Message-ID: <526484CD.3010100@huawei.com>
References: <1382273273-27344-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:31844 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab3JUBgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 21:36:12 -0400
In-Reply-To: <1382273273-27344-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/20 20:47, Veaceslav Falico wrote:
> As Jiri noted, currently we first do all bonding-specific initialization
> (specifically - bond_select_active_slave(bond)) before we actually attach
> the slave (so that it becomes visible through bond_for_each_slave() and
> friends). This might result in bond_select_active_slave() not seeing the
> first/new slave and, thus, not actually selecting an active slave.
> 
> Fix this by moving all the bond-related init part after we've actually
> completely initialized and linked (via bond_master_upper_dev_link()) the
> new slave.
> 
> After this we have all the initialization of the new slave *before*
> linking, and all the stuff that needs to be done on bonding *after* it. It
> has also a bonus effect - we can remove the locking on the new slave init
> completely, and only use it for bond_select_active_slave().
> 
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 29 ++++++++++-------------------
>  1 file changed, 10 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index d90734f..047c0fb 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1471,22 +1471,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_close;
>  	}
>  
> -	write_lock_bh(&bond->lock);
> -
>  	prev_slave = bond_last_slave(bond);
>  	bond_attach_slave(bond, new_slave);
>  
>  	new_slave->delay = 0;
>  	new_slave->link_failure_count = 0;
>  
> -	write_unlock_bh(&bond->lock);
> -
> -	bond_compute_features(bond);
> -
>  	bond_update_speed_duplex(new_slave);
>  
> -	read_lock(&bond->lock);
> -
>  	new_slave->last_arp_rx = jiffies -
>  		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>  	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
> @@ -1547,12 +1539,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		}
>  	}
>  
> -	write_lock_bh(&bond->curr_slave_lock);
> -
>  	switch (bond->params.mode) {
>  	case BOND_MODE_ACTIVEBACKUP:
>  		bond_set_slave_inactive_flags(new_slave);
> -		bond_select_active_slave(bond);
>  		break;
>  	case BOND_MODE_8023AD:
>  		/* in 802.3ad mode, the internal mechanism
> @@ -1578,7 +1567,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	case BOND_MODE_ALB:
>  		bond_set_active_slave(new_slave);
>  		bond_set_slave_inactive_flags(new_slave);
> -		bond_select_active_slave(bond);
>  		break;
>  	default:
>  		pr_debug("This slave is always active in trunk mode\n");
> @@ -1596,10 +1584,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		break;
>  	} /* switch(bond_mode) */
>  
> -	write_unlock_bh(&bond->curr_slave_lock);
> -
> -	bond_set_carrier(bond);
> -
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	slave_dev->npinfo = bond->dev->npinfo;
>  	if (slave_dev->npinfo) {
> @@ -1614,8 +1598,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	}
>  #endif
>  
> -	read_unlock(&bond->lock);
> -
>  	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
>  					 new_slave);
>  	if (res) {
> @@ -1629,6 +1611,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_unregister;
>  	}
>  
> +	bond_compute_features(bond);
> +	bond_set_carrier(bond);
> +
> +	if (USES_PRIMARY(bond->params.mode)) {
> +		read_lock(&bond->lock);
> +		write_lock_bh(&bond->curr_slave_lock);
> +		bond_select_active_slave(bond);
> +		write_unlock_bh(&bond->curr_slave_lock);
> +		read_unlock(&bond->lock);
> +	}
>  

agree to move the lock, and I think bond_attach_slave() should add here,
as it look more logical, the slave_cnt should not add before the slave truly
add to the bond.

Regards.
Ding

>  	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
>  		bond_dev->name, slave_dev->name,
> @@ -1686,7 +1678,6 @@ err_free:
>  	kfree(new_slave);
>  
>  err_undo_flags:
> -	bond_compute_features(bond);
>  	/* Enslave of first slave has failed and we need to fix master's mac */
>  	if (!bond_has_slaves(bond) &&
>  	    ether_addr_equal(bond_dev->dev_addr, slave_dev->dev_addr))
> 
