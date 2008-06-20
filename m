From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/8] bonding: Check return of
 dev_set_promiscuity/allmulti
Date: Thu, 19 Jun 2008 19:07:24 -0700 (PDT)
Message-ID: <20080619.190724.264140435.davem@davemloft.net>
References: <485AFFD2.4090304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	kaber@trash.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbYFTCHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:07:24 -0400
In-Reply-To: <485AFFD2.4090304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 20 Jun 2008 08:54:42 +0800

> @@ -419,8 +419,11 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
>  	}
>  
>  	if (!bond->alb_info.primary_is_promisc) {
> -		bond->alb_info.primary_is_promisc = 1;
> -		dev_set_promiscuity(bond->curr_active_slave->dev, 1);
> +		/* dev_set_promiscuity might overflow, check it here */
> +		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))

Like the first patch, please don't add such comments.

> @@ -955,6 +965,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
>  	}
>  
>  	if (new_active) {
> +		/* FIXME: promiscuity and allmulti might overflow,
> +		 * but bond_mc_swap's caller likes quiet handle.
> +		 */
>  		if (bond->dev->flags & IFF_PROMISC) {
>  			dev_set_promiscuity(new_active->dev, 1);
>  		}

Please reword this comment.  The issue is that this code path has no
mechanism to signal errors upstream.  It isn't about a specific type
of error condition in particular, it's about error handling capabilites
in general.

> @@ -3933,6 +3950,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>  	 * Do promisc before checking multicast_mode
>  	 */
>  	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC)) {
> +		/*
> +		 * FIXME: If bond has multi slaves, how to handle the error
> +		 * when one of the slaves encounters promiscuity overflow.
> +		 */
>  		bond_set_promiscuity(bond, 1);
>  	}
>  

Remove specific reference to promiscuity overflow, these are generic error
handling issues here regardless of the types of errors that the down
calls could encounter.

> @@ -3942,6 +3963,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>  
>  	/* set allmulti flag to slaves */
>  	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI)) {
> +		/*
> +		 * FIXME: If bond has multi slaves, how to handle the error
> +		 * when one of the slaves encounters allmulti overflow.
> +		 */
>  		bond_set_allmulti(bond, 1);
>  	}

Likewise.
