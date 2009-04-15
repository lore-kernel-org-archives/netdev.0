From: Paul Smith <paul@mad-scientist.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to
	ifenslave a second interface to my bond
Date: Wed, 15 Apr 2009 01:29:27 -0400
Message-ID: <1239773367.6499.170.camel@homebase.localnet>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	 <11276.1239757967@death.nxdomain.ibm.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.lnh.mail.rcn.net ([207.172.157.102]:28967 "EHLO
	smtp02.lnh.mail.rcn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbZDOFjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 01:39:09 -0400
Received: from psmith by homebase.localnet with local (Exim 4.69)
	(envelope-from <paul@mad-scientist.net>)
	id 1Ltxge-0002tl-1l
	for netdev@vger.kernel.org; Wed, 15 Apr 2009 01:29:28 -0400
In-Reply-To: <11276.1239757967@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-14 at 18:12 -0700, Jay Vosburgh wrote:
> 	I think I know what's going on.  I believe this patch will
> resolve things, but I won't be able to test it until tomorrow.  If you
> want to test this, great; if you want to wait, that's fine too.

I tested this; it works great.  All my systems came up fine with this
change applied.  Thanks!

> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 8dc6fbb..b22467a 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1708,10 +1708,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
>   * Called with RTNL
>   */
>  int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
> -	__releases(&bond->curr_slave_lock)
> -	__releases(&bond->lock)
>  	__acquires(&bond->lock)
> -	__acquires(&bond->curr_slave_lock)
> +	__releases(&bond->lock)
>  {
>  	struct bonding *bond = netdev_priv(bond_dev);
>  	struct sockaddr *sa = addr;
> @@ -1747,9 +1745,6 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
>  		}
>  	}
>  
> -	write_unlock_bh(&bond->curr_slave_lock);
> -	read_unlock(&bond->lock);
> -
>  	if (swap_slave) {
>  		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
>  		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
> @@ -1757,16 +1752,17 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
>  		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
>  				       bond->alb_info.rlb_enabled);
>  
> -		alb_send_learning_packets(bond->curr_active_slave, bond_dev->dev_addr);
> +		read_lock(&bond->lock);
> +		alb_send_learning_packets(bond->curr_active_slave,
> +					  bond_dev->dev_addr);
>  		if (bond->alb_info.rlb_enabled) {
>  			/* inform clients mac address has changed */
> -			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
> +			rlb_req_update_slave_clients(bond,
> +						     bond->curr_active_slave);
>  		}
> +		read_unlock(&bond->lock);
>  	}
>  
> -	read_lock(&bond->lock);
> -	write_lock_bh(&bond->curr_slave_lock);
> -
>  	return 0;
>  }
>  

-- 
Paul Smith <paul@mad-scientist.net>
