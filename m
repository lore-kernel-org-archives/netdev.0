From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH BUGFIX ] ipv6: fix the bug of address check
Date: Tue, 18 May 2010 08:50:37 +0800
Message-ID: <4BF1E45D.5000409@cn.fujitsu.com>
References: <4BF1354A.3060003@cn.fujitsu.com> <20100517103134.06160257@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64701 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab0ERAvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 20:51:39 -0400
In-Reply-To: <20100517103134.06160257@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, at 05/18/2010 01:31 AM:
> 
> Why not this instead. I don't like depending on the value of the
> loop variable in the hlist_for_each()
> 
> --- a/net/ipv6/addrconf.c	2010-05-17 10:27:58.218628126 -0700
> +++ b/net/ipv6/addrconf.c	2010-05-17 10:29:46.012198338 -0700
> @@ -1274,7 +1274,7 @@ static int ipv6_count_addresses(struct i
>  int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
>  		  struct net_device *dev, int strict)
>  {
> -	struct inet6_ifaddr *ifp = NULL;
> +	struct inet6_ifaddr *ifp;
>  	struct hlist_node *node;
>  	unsigned int hash = ipv6_addr_hash(addr);
>  
> @@ -1283,15 +1283,16 @@ int ipv6_chk_addr(struct net *net, struc
>  		if (!net_eq(dev_net(ifp->idev->dev), net))
>  			continue;
>  		if (ipv6_addr_equal(&ifp->addr, addr) &&
> -		    !(ifp->flags&IFA_F_TENTATIVE)) {
> -			if (dev == NULL || ifp->idev->dev == dev ||
> -			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))
> -				break;
> +		    !(ifp->flags&IFA_F_TENTATIVE) &&
> +		    (dev == NULL || ifp->idev->dev == dev ||
> +		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
> +			rcu_read_unlock_bh();
> +			return 1;
>  		}
>  	}
> -	rcu_read_unlock_bh();
>  
> -	return ifp != NULL;
> +	rcu_read_unlock_bh();
> +	return 0;
>  }
>  EXPORT_SYMBOL(ipv6_chk_addr);
>  
> 
> 

This looks good to me.
Can you send a intact patch to David with my Report-by or Review-by ?

-- 
Best Regards
-----
Shan Wei
