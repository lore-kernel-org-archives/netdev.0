From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link
 down
Date: Wed, 1 Dec 2010 12:22:53 -0800
Message-ID: <20101201122253.2a8be2e0@nehalam>
References: <20101201.110157.246534994.davem@davemloft.net>
	<AAs7234jas72lda05laWgh1LziatUa+qSHd+6Jj+k_eO=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60710 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840Ab0LAUWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 15:22:55 -0500
In-Reply-To: <AAs7234jas72lda05laWgh1LziatUa+qSHd+6Jj+k_eO=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Dec 2010 11:38:58 -0800
Lorenzo Colitti <lorenzo@google.com> wrote:

> ipv6: slightly simplify keeping IPv6 addresses on link down
> 
> When link goes down, all statically-configured (i.e.,
> permanent and not link-local) IPv6 addresses are kept on
> the interface. Instead of moving addresses to a temporary
> keep list and then splicing that back on to the interface
> address list, use list_for_each_entry_safe and delete the
> ones we don't want.
> 
> Tested by configuring two static addresses on an interface
> and verifying that pings from the addresses keep working
> when bringing link down and up again and when disabling and
> re-enabling IPv6 on the interface.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6dfd5c5..23cc8e1 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2663,7 +2663,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  {
>  	struct net *net = dev_net(dev);
>  	struct inet6_dev *idev;
> -	struct inet6_ifaddr *ifa, *ifn;
> +	struct inet6_ifaddr *ifa;
> +	LIST_HEAD(keep_list);
>  	int state;

Your patch is backwards? The existing code is:

static int addrconf_ifdown(struct net_device *dev, int how)
{
	struct net *net = dev_net(dev);
	struct inet6_dev *idev;
	struct inet6_ifaddr *ifa;
	LIST_HEAD(keep_list);
	int state;

	ASSERT_RTNL();

Also, the addrconf_ifdown can race with other updates to idev->addr_list
from addrconf timers etc.  Therefore even list_for_each_entry_safe is not safe.
