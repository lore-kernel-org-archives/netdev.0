From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net] ipv6: clean up anycast when an interface is
 destroyed
Date: Fri, 12 Sep 2014 21:45:13 +0200
Message-ID: <1410551113.2970.12.camel@localhost>
References: <20140910102714.GB21267@kria>
	 <CAHA+R7ODewXP69ULsR0RD+c3BEfMa90zATRjHF3dC9Dkv7jgZw@mail.gmail.com>
	 <20140910.135840.133555874665251669.davem@davemloft.net>
	 <20140910212302.GA26184@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:50759 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbaILTpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 15:45:16 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 8D33720CB0
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 15:45:15 -0400 (EDT)
In-Reply-To: <20140910212302.GA26184@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-09-10 at 23:23 +0200, Sabrina Dubroca wrote:
> If we try to rmmod the driver for an interface while sockets with
> setsockopt(JOIN_ANYCAST) are alive, some refcounts aren't cleaned up
> and we get stuck on:
> 
>   unregister_netdevice: waiting for ens3 to become free. Usage count = 1
> 
> If we LEAVE_ANYCAST/close everything before rmmod'ing, there is no
> problem.
> 
> We need to perform a cleanup similar to the one for multicast in
> addrconf_ifdown(how == 1).
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

This is the correct fix for the bug:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

more comments inline:

> ---
> v2: remove comment
> 
>  include/net/addrconf.h |  1 +
>  net/ipv6/addrconf.c    |  8 +++++---
>  net/ipv6/anycast.c     | 21 +++++++++++++++++++++
>  3 files changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index f679877bb601..ec51e673b4b6 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -204,6 +204,7 @@ void ipv6_sock_ac_close(struct sock *sk);
>  
>  int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
>  int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
> +void ipv6_ac_destroy_dev(struct inet6_dev *idev);
>  bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
>  			 const struct in6_addr *addr);
>  bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index fc1fac2a0528..3342ee64f2e3 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3094,11 +3094,13 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  
>  	write_unlock_bh(&idev->lock);
>  
> -	/* Step 5: Discard multicast list */
> -	if (how)
> +	/* Step 5: Discard anycast and multicast list */
> +	if (how) {
> +		ipv6_ac_destroy_dev(idev);
>  		ipv6_mc_destroy_dev(idev);
> -	else
> +	} else {
>  		ipv6_mc_down(idev);
> +	}

Do we also need to provide a ipv6_ac_down function to unload all anycast
sources when we ifdown an interface (we need to keep the entries in
aca_list around and activate them when we initialize the interface
again)?
 
Thanks,
Hannes
