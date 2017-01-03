From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH] Ipvlan should return an error when an address is already in use.
Date: Tue, 03 Jan 2017 10:50:00 -0500
Message-ID: <f7td1g49m8n.fsf@redhat.com>
References: <20161231041058.GC2448@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>, netdev@vger.kernel.org
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759455AbdACPuH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 10:50:07 -0500
In-Reply-To: <20161231041058.GC2448@templeofstupid.com> (Krister Johansen's
        message of "Fri, 30 Dec 2016 20:10:58 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Krister,

Krister Johansen <kjlx@templeofstupid.com> writes:

> The ipvlan code already knows how to detect when a duplicate address is
> about to be assigned to an ipvlan device.  However, that failure is not
> propogated outward and leads to a silent failure.  This teaches the ip
> address addition functions how to report this error to the user
> applications so that a notifier chain failure during ip address addition
> will not appear to succeed when it actually has not.
>
> This can be especially useful if it is necessary to provision many
> ipvlans in containers.  The provisioning software (or operator) can use
> this to detect situations where an ip address is unexpectedly in use.
>
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> ---

...

> @@ -489,7 +490,12 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>  	   Notifier will trigger FIB update, so that
>  	   listeners of netlink will know about new ifaddr */
>  	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
> -	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
> +	ret = blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);

Why are you doing this assignment if you aren't using the result?

> +	ret = notifier_to_errno(ret);
> +	if (ret) {
> +		__inet_del_ifa(in_dev, ifap, 1, NULL, portid);
> +		return ret;
> +	}
>  
>  	return 0;
>  }

<<snip>>

> @@ -1031,9 +1032,15 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  out2:
>  	rcu_read_unlock_bh();
>  
> -	if (likely(err == 0))
> -		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
> -	else {
> +	if (likely(err == 0)) {
> +		err = inet6addr_notifier_call_chain(NETDEV_UP, ifa);

Same here...

> +		err = notifier_to_errno(err);
> +		if (err) {
> +			__ipv6_del_addr(ifa, false);
> +			ifa = ERR_PTR(err);
> +			return ifa;
> +		}
> +	} else {
>  		kfree(ifa);
>  		ifa = ERR_PTR(err);
>  	}
