From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for	the	bonding
 driver
Date: Tue, 31 Jul 2007 17:36:05 +0300
Message-ID: <46AF48D5.9000502@voltaire.com>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>	<46AF3CA8.6050201@gmail.com>	<20070731140436.GA16015@mellanox.co.il>	<46AF44E0.50700@voltaire.com> <20070731142234.GC16015@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	fubar@us.ibm.com, general@lists.openfabrics.org,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:23002 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760523AbXGaOgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 10:36:08 -0400
In-Reply-To: <20070731142234.GC16015@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
>> Quoting Or Gerlitz <ogerlitz@voltaire.com>:

>> To be precise, bonding will copy all the symbols it copies today from 
>> the slave module (ipoib), see bond_setup_by_slave() in patch 3/7

> Not really.
> This copying of symbols is something that you added, isn't it?
> So with this approach, it won't be needed.

> It's always wrong to copy symbols from another module without
> referencing it.

Its the --first-- time you make this comment, please suggest a different 
approach, the relevant code is below.

> +static void bond_setup_by_slave(struct net_device *bond_dev,
> +				struct net_device *slave_dev)
> +{
> +	bond_dev->hard_header	        = slave_dev->hard_header;
> +	bond_dev->rebuild_header        = slave_dev->rebuild_header;
> +	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
> +	bond_dev->header_cache_update   = slave_dev->header_cache_update;
> +	bond_dev->hard_header_parse	= slave_dev->hard_header_parse;
> +
> +	bond_dev->neigh_setup           = slave_dev->neigh_setup;
> +
> +	bond_dev->type		    = slave_dev->type;
> +	bond_dev->hard_header_len   = slave_dev->hard_header_len;
> +	bond_dev->addr_len	    = slave_dev->addr_len;
> +
> +	memcpy(bond_dev->broadcast, slave_dev->broadcast,
> +		slave_dev->addr_len);
> +}
> +
>  /* enslave device <slave> to bond device <master> */
>  int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  {
> @@ -1351,6 +1371,24 @@ int bond_enslave(struct net_device *bond
>  		goto err_undo_flags;
>  	}
>  
> +	/* set bonding device ether type by slave - bonding netdevices are
> +	 * created with ether_setup, so when the slave type is not ARPHRD_ETHER
> +	 * there is a need to override some of the type dependent attribs/funcs.
> +	 *
> +	 * bond ether type mutual exclusion - don't allow slaves of dissimilar
> +	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
> +	 */
> +	if (bond->slave_cnt == 0) {
> +		if (slave_dev->type != ARPHRD_ETHER)
> +			bond_setup_by_slave(bond_dev, slave_dev);
> +	} else if (bond_dev->type != slave_dev->type) {
> +		printk(KERN_ERR DRV_NAME ": %s ether type (%d) is different from "
> +			"other slaves (%d), can not enslave it.\n", slave_dev->name,
> +			slave_dev->type, bond_dev->type);
> +			res = -EINVAL;
> +			goto err_undo_flags;
> +	}
> +



