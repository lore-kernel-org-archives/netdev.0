From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: Updates to netif_index_is_vrf
Date: Sun, 16 Aug 2015 02:39:26 +0200
Message-ID: <20150816003926.GA31357@breakpoint.cc>
References: <1439683793-2999-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34183 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751350AbbHPAj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 20:39:28 -0400
Content-Disposition: inline
In-Reply-To: <1439683793-2999-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> wrote:
> As Eric noted netif_index_is_vrf is not called with rcu_read_lock held,
> so use dev_get_by_index instead of dev_get_by_index_rcu.
> 
> If VRF is not enabled or oif is 0 skip the device lookup.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Why not

>  static inline bool netif_index_is_vrf(struct net *net, int ifindex)
>  {
> -	struct net_device *dev = dev_get_by_index_rcu(net, ifindex);
>  	bool rc = false;
>  
> -	if (dev)
> -		rc = netif_is_vrf(dev);
> +#if IS_ENABLED(CONFIG_NET_VRF)
> +	struct net_device *dev;
> +
> +	if (ifindex == 0)
> +		return false;

	rcu_read_lock();

	dev = dev_get_by_index_rcu(net, ifindex);
	if (dev)
		rc = netif_is_vrf(dev);

	rcu_read_unlock();

> +#endif
>  	return rc;

instead?
