From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Thu, 18 Mar 2010 19:32:56 -0700
Message-ID: <20100319023256.GD2894@linux.vnet.ibm.com>
References: <1268947645.2894.166.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41164 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab0CSCc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 22:32:58 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2J2LUBq006624
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:21:30 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2J2WwI8133082
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:32:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2J2WvRf003209
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:32:57 -0400
Content-Disposition: inline
In-Reply-To: <1268947645.2894.166.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 10:27:25PM +0100, Eric Dumazet wrote:
> Use RCU to avoid RTNL use in dev_getfirstbyhwtype()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 17b1686..0f2e9fc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -772,14 +772,17 @@ EXPORT_SYMBOL(__dev_getfirstbyhwtype);
> 
>  struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
>  {
> -	struct net_device *dev;
> +	struct net_device *dev, *ret = NULL;
> 
> -	rtnl_lock();
> -	dev = __dev_getfirstbyhwtype(net, type);
> -	if (dev)
> -		dev_hold(dev);
> -	rtnl_unlock();
> -	return dev;
> +	rcu_read_lock();
> +	for_each_netdev_rcu(net, dev)
> +		if (dev->type == type) {
> +			dev_hold(dev);
> +			ret = dev;
> +			break;
> +		}
> +	rcu_read_unlock();
> +	return ret;

Looks good, but I don't understand how it helps to introduce the
local variable "ret".

							Thanx, Paul

>  }
>  EXPORT_SYMBOL(dev_getfirstbyhwtype);
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
