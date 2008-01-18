From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/7] bonding: fix lock ordering for rtnl and
 bonding_rwsem
Date: Thu, 17 Jan 2008 16:38:01 -0800
Message-ID: <20080117163801.77c62170.akpm@linux-foundation.org>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
	<12006159063217-git-send-email-fubar@us.ibm.com>
	<12006159071917-git-send-email-fubar@us.ibm.com>
	<12006159081875-git-send-email-fubar@us.ibm.com>
	<12006159102124-git-send-email-fubar@us.ibm.com>
	<12006159111680-git-send-email-fubar@us.ibm.com>
	<12006159123054-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	andy@greyhouse.net, fubar@us.ibm.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35121 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760687AbYARAit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 19:38:49 -0500
In-Reply-To: <12006159123054-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 16:25:02 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Fix the handling of rtnl and the bonding_rwsem to always be acquired
> in a consistent order (rtnl, then bonding_rwsem).
> 
> The existing code sometimes acquired them in this order, and sometimes
> in the opposite order, which opens a window for deadlock between ifenslave
> and sysfs.
> 
> ...
>
>  int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
>  {
>  	struct net_device *bond_dev;
> +	struct bonding *bond, *nxt;
>  	int res;
>  
>  	rtnl_lock();
> +	down_write(&bonding_rwsem);
> +
> +	/* Check to see if the bond already exists. */
> +	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)

this could (should) use list_for_each_entry().

> +		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
> +			printk(KERN_ERR DRV_NAME
> +			       ": cannot add bond %s; it already exists\n",
> +			       name);
> +			res = -EPERM;
> +			goto out_rtnl;
> +		}
> +
>  	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
>  				ether_setup);
>  	if (!bond_dev) {
> @@ -4915,10 +4928,12 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
>  
>  	netif_carrier_off(bond_dev);
>  
> +	up_write(&bonding_rwsem);
>  	rtnl_unlock(); /* allows sysfs registration of net device */
>  	res = bond_create_sysfs_entry(bond_dev->priv);
>  	if (res < 0) {
>  		rtnl_lock();
> +		down_write(&bonding_rwsem);
>  		goto out_bond;
>  	}
>  
> @@ -4929,6 +4944,7 @@ out_bond:
>  out_netdev:
>  	free_netdev(bond_dev);
>  out_rtnl:
> +	up_write(&bonding_rwsem);
>  	rtnl_unlock();
>  	return res;
>  }
> @@ -4949,6 +4965,9 @@ static int __init bonding_init(void)
>  #ifdef CONFIG_PROC_FS
>  	bond_create_proc_dir();
>  #endif
> +
> +	init_rwsem(&bonding_rwsem);

It would be better to initialise this at compile time with DECLARE_RWSEM().


But neither of those things need to be done for 2.6.24.

