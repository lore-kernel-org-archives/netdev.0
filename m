From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net] ipv6: simplify detection of first operational link-local
 address on interface
Date: Thu, 16 Jan 2014 15:15:31 -0500
Message-ID: <52D83DE3.40806@hp.com>
References: <20140116135323.GA7961@minipsycho.orion> <20140116191304.GC17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:13656 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaAPUPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 15:15:33 -0500
In-Reply-To: <20140116191304.GC17529@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2014 02:13 PM, Hannes Frederic Sowa wrote:
> In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
> dad-completed ipv6 addresses") I build the detection of the first
> operational link-local address much to complex. Additionally this code
> now has a race condition.
> 
> Replace it with a much simpler variant, which just scans the address
> list when duplicate address detection completes, to check if this is
> the first valid link local address and send RS and MLD reports then.
> 
> Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

> +/* ifp->idev must be at least read locked */
> +static bool ipv6_lonely_lladdr(struct inet6_ifaddr *ifp)
> +{
> +	struct inet6_ifaddr *ifpiter;
> +	struct inet6_dev *idev = ifp->idev;
> +
> +	list_for_each_entry(ifpiter, &idev->addr_list, if_list) {
> +		if (ifp != ifpiter && ifpiter->scope == IFA_LINK &&
> +		    (ifpiter->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|
> +				       IFA_F_OPTIMISTIC|IFA_F_DADFAILED)) ==
> +		    IFA_F_PERMANENT)
> +			return false;
> +	}
> +	return true;
> +}

Just a nit, but the idev->addr_list is sorted by scope, so you could use
list_for_each_entry_reverse(), and break out once the scope is > IFA_LINK to
reduce the number of compares.

-Brian
