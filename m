From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH V6 5/9] net/bonding: Enable IP multicast for bonding
 IPoIB devices
Date: Mon, 24 Sep 2007 09:04:37 -0700
Message-ID: <20070924090437.0406e147@freepuppy.rosehill>
References: <46F7D770.4090500@voltaire.com>
	<46F7D99C.3030602@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org,
	OpenFabrics General <general@lists.openfabrics.org>
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33693 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753899AbXIXQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 12:05:32 -0400
In-Reply-To: <46F7D99C.3030602@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Sep 2007 17:37:00 +0200
Moni Shoua <monis@voltaire.com> wrote:

> Allow to enslave devices when the bonding device is not up. Over the discussion
> held at the previous post this seemed to be the most clean way to go, where it
> is not expected to cause instabilities.
> 
> Normally, the bonding driver is UP before any enslavement takes place.
> Once a netdevice is UP, the network stack acts to have it join some multicast groups
> (eg the all-hosts 224.0.0.1). Now, since ether_setup() have set the bonding device
> type to be ARPHRD_ETHER and address len to be ETHER_ALEN, the net core code
> computes a wrong multicast link address. This is b/c ip_eth_mc_map() is called
> where for multicast joins taking place after the enslavement another ip_xxx_mc_map()
> is called (eg ip_ib_mc_map() when the bond type is ARPHRD_INFINIBAND)
> 
> Signed-off-by: Moni Shoua <monis at voltaire.com>
> Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
> ---
>  drivers/net/bonding/bond_main.c  |    5 +++--
>  drivers/net/bonding/bond_sysfs.c |    6 ++----
>  2 files changed, 5 insertions(+), 6 deletions(-)
> 
> Index: net-2.6/drivers/net/bonding/bond_main.c
> ===================================================================
> --- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:54:41.000000000 +0300
> +++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-15 10:55:48.431862446 +0300
> @@ -1285,8 +1285,9 @@ int bond_enslave(struct net_device *bond
>  
>  	/* bond must be initialized by bond_open() before enslaving */
>  	if (!(bond_dev->flags & IFF_UP)) {
> -		dprintk("Error, master_dev is not up\n");
> -		return -EPERM;
> +		printk(KERN_WARNING DRV_NAME
> +			" %s: master_dev is not up in bond_enslave\n",
> +			bond_dev->name);
>  	}
>  
>  	/* already enslaved */
> Index: net-2.6/drivers/net/bonding/bond_sysfs.c
> ===================================================================
> --- net-2.6.orig/drivers/net/bonding/bond_sysfs.c	2007-08-15 10:08:58.000000000 +0300
> +++ net-2.6/drivers/net/bonding/bond_sysfs.c	2007-08-15 10:55:48.432862269 +0300
> @@ -266,11 +266,9 @@ static ssize_t bonding_store_slaves(stru
>  
>  	/* Quick sanity check -- is the bond interface up? */
>  	if (!(bond->dev->flags & IFF_UP)) {
> -		printk(KERN_ERR DRV_NAME
> -		       ": %s: Unable to update slaves because interface is down.\n",
> +		printk(KERN_WARNING DRV_NAME
> +		       ": %s: doing slave updates when interface is down.\n",
>  		       bond->dev->name);
> -		ret = -EPERM;
> -		goto out;
>  	}
>  

Please get rid of the warning. Make bonding work correctly and allow enslave/remove
of device when bonding is down.
