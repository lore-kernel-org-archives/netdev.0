From: Daniel Lezcano <dlezcano@meiosys.com>
Subject: Re: [PATCH] bridge: sysfs locking fix.
Date: Fri, 24 Aug 2007 10:18:07 +0200
Message-ID: <46CE943F.9000308@meiosys.com>
References: <46BCE380.60508@cluded.net> <20070812012037.0195b610.akpm@linux-foundation.org> <20070814141105.0a4b8dde@oldman.hamilton.local> <20070814131822.GA13676@xi.wantstofly.org> <20070814145052.2d135d2f@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:60154 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991AbXHXIXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 04:23:36 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7O8N19Y190282
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 08:23:01 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7O8N1ZK2166798
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 10:23:01 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7O8N0Z0031628
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 10:23:01 +0200
In-Reply-To: <20070814145052.2d135d2f@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Forget earlier patch, it is wrong...
> 
> The stp change code generates "sleeping function called from invalid context"
> because rtnl_lock() called with BH disabled. This fixes it by not acquiring then
> dropping the bridge lock.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- a/net/bridge/br_sysfs_br.c	2007-08-06 09:26:48.000000000 +0100
> +++ b/net/bridge/br_sysfs_br.c	2007-08-14 14:29:52.000000000 +0100
> @@ -147,20 +147,26 @@ static ssize_t show_stp_state(struct dev
>  	return sprintf(buf, "%d\n", br->stp_enabled);
>  }
> 
> -static void set_stp_state(struct net_bridge *br, unsigned long val)
> -{
> -	rtnl_lock();
> -	spin_unlock_bh(&br->lock);
> -	br_stp_set_enabled(br, val);
> -	spin_lock_bh(&br->lock);
> -	rtnl_unlock();
> -}
> 
>  static ssize_t store_stp_state(struct device *d,
>  			       struct device_attribute *attr, const char *buf,
>  			       size_t len)
>  {
> -	return store_bridge_parm(d, buf, len, set_stp_state);
> +	struct net_bridge *br = to_bridge(d);
> +	char *endp;
> +	unsigned long val;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	val = simple_strtoul(buf, &endp, 0);
> +	if (endp == buf)
> +		return -EINVAL;
> +
> +	rtnl_lock();
> +	br_stp_set_enabled(br, val);
> +	rtnl_unlock();
> +

Shouldn't len value be returned at the end of the function ?

>  }
>  static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
>  		   store_stp_state);
> -

