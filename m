From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v4] net: ipv6: allow explicitly choosing optimistic
 addresses
Date: Thu, 05 Feb 2015 11:51:18 +0100
Message-ID: <1423133478.16980.16.camel@stressinduktion.org>
References: <1423047683-16267-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:34302 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756895AbbBEKvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 05:51:21 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id EB57E20CB5
	for <netdev@vger.kernel.org>; Thu,  5 Feb 2015 05:51:20 -0500 (EST)
In-Reply-To: <1423047683-16267-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2015-02-04 at 20:01 +0900, Erik Kline wrote:
> RFC 4429 ("Optimistic DAD") states that optimistic addresses
> should be treated as deprecated addresses.  From section 2.1:
> 
>    Unless noted otherwise, components of the IPv6 protocol stack
>    should treat addresses in the Optimistic state equivalently to
>    those in the Deprecated state, indicating that the address is
>    available for use but should not be used if another suitable
>    address is available.
> 
> Optimistic addresses are indeed avoided when other addresses are
> available (i.e. at source address selection time), but they have
> not heretofore been available for things like explicit bind() and
> sendmsg() with struct in6_pktinfo, etc.
> 
> This change makes optimistic addresses treated more like
> deprecated addresses than tentative ones.
> 
> Signed-off-by: Erik Kline <ek@google.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

> ---
>  include/net/addrconf.h |  3 +++
>  net/ipv6/addrconf.c    | 19 +++++++++++++++++--
>  net/ipv6/ndisc.c       |  4 +++-
>  3 files changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index d13573b..80456f7 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -62,6 +62,9 @@ int addrconf_set_dstaddr(struct net *net, void __user *arg);
>  
>  int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>  		  const struct net_device *dev, int strict);
> +int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
> +			    const struct net_device *dev, int strict,
> +			    u32 banned_flags);
>  
>  #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
>  int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f7c8bbe..62900ae 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1519,15 +1519,30 @@ static int ipv6_count_addresses(struct inet6_dev *idev)
>  int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>  		  const struct net_device *dev, int strict)
>  {
> +	return ipv6_chk_addr_and_flags(net, addr, dev, strict, IFA_F_TENTATIVE);
> +}
> +EXPORT_SYMBOL(ipv6_chk_addr);
> +
> +int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
> +			    const struct net_device *dev, int strict,
> +			    u32 banned_flags)
> +{
>  	struct inet6_ifaddr *ifp;
>  	unsigned int hash = inet6_addr_hash(addr);
> +	u32 ifp_flags;
>  
>  	rcu_read_lock_bh();
>  	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
>  		if (!net_eq(dev_net(ifp->idev->dev), net))
>  			continue;
> +		/* Decouple optimistic from tentative for evaluation here.
> +		 * Ban optimistic addresses explicitly, when required.
> +		 */
> +		ifp_flags = (ifp->flags&IFA_F_OPTIMISTIC)
> +			    ? (ifp->flags&~IFA_F_TENTATIVE)
> +			    : ifp->flags;
>  		if (ipv6_addr_equal(&ifp->addr, addr) &&
> -		    !(ifp->flags&IFA_F_TENTATIVE) &&
> +		    !(ifp_flags&banned_flags) &&
>  		    (dev == NULL || ifp->idev->dev == dev ||
>  		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
>  			rcu_read_unlock_bh();
> @@ -1538,7 +1553,7 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>  	rcu_read_unlock_bh();
>  	return 0;
>  }
> -EXPORT_SYMBOL(ipv6_chk_addr);
> +EXPORT_SYMBOL(ipv6_chk_addr_and_flags);

Nit: I don't think the export is necessary.

Bye,
Hannes
