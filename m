From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/2] IPv6: keep permanent addresses on admin down
Date: Tue, 09 Feb 2010 09:40:11 -0500
Message-ID: <4B7173CB.3020506@hp.com>
References: <20100208214805.1f8f2c6d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:10632 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189Ab0BIOkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 09:40:17 -0500
In-Reply-To: <20100208214805.1f8f2c6d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> @@ -2686,18 +2687,30 @@ static int addrconf_ifdown(struct net_de
>  		write_lock_bh(&idev->lock);
>  	}
>  #endif
> -	while ((ifa = idev->addr_list) != NULL) {
> -		idev->addr_list = ifa->if_next;
> -		ifa->if_next = NULL;
> -		ifa->dead = 1;
> -		addrconf_del_timer(ifa);
> -		write_unlock_bh(&idev->lock);
> -
> -		__ipv6_ifa_notify(RTM_DELADDR, ifa);
> -		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
> -		in6_ifa_put(ifa);
> +	bifa = &idev->addr_list;
> +	while ((ifa = *bifa) != NULL) {
> +		if (how == 0 && (ifa->flags&IFA_F_PERMANENT)) {
> +			/* Retain permanent address on admin down */
> +			bifa = &ifa->if_next;
> +
> +			/* Restart DAD if needed when link comes back up */
> +			if ( !((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
> +			       idev->cnf.accept_dad <= 0 ||
> +			       (ifa->flags & IFA_F_NODAD)))
> +				ifa->flags |= IFA_F_TENTATIVE;
> +		} else {
> +			*bifa = ifa->if_next;
> +			ifa->if_next = NULL;
> +
> +			ifa->dead = 1;
> +			write_unlock_bh(&idev->lock);
> +
> +			__ipv6_ifa_notify(RTM_DELADDR, ifa);
> +			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
> +			in6_ifa_put(ifa);
>  
> -		write_lock_bh(&idev->lock);
> +			write_lock_bh(&idev->lock);
> +		}

What about addrconf_del_timer()?  It didn't seem to make it to this else{} from
the original.

-Brian
