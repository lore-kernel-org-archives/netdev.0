From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 23:13:51 +0300
Message-ID: <20160310201351.GB1989@uranus.lan>
References: <CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
 <20160310.145543.990436948715023108.davem@davemloft.net>
 <20160310200133.GA1989@uranus.lan>
 <20160310.150311.1210460824855467762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:35817 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbcCJUOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 15:14:03 -0500
Content-Disposition: inline
In-Reply-To: <20160310.150311.1210460824855467762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 03:03:11PM -0500, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Thu, 10 Mar 2016 23:01:34 +0300
> 
> > On Thu, Mar 10, 2016 at 02:55:43PM -0500, David Miller wrote:
> >> > 
> >> > Hmm, but inetdev_destroy() is only called when NETDEV_UNREGISTER
> >> > is happening and masq already registers a netdev notifier...
> >> 
> >> Indeed, good catch.  Therefore:
> >> 
> >> 1) Keep the masq netdev notifier.  That will flush the conntrack table
> >>    for the inetdev_destroy event.
> >> 
> >> 2) Make the inetdev notifier only do something if inetdev->dead is
> >>    false.  (ie. we are flushing an individual address)
> >> 
> >> And then we don't need the NETDEV_UNREGISTER thing at all:
> >> 
> >> diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> >> index c6eb421..f71841a 100644
> >> --- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> >> +++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
> >> @@ -108,10 +108,20 @@ static int masq_inet_event(struct notifier_block *this,
> >>  			   unsigned long event,
> >>  			   void *ptr)
> >>  {
> >> -	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
> >>  	struct netdev_notifier_info info;
> >> +	struct in_ifaddr *ifa = ptr;
> >> +	struct in_device *idev;
> >>  
> >> -	netdev_notifier_info_init(&info, dev);
> >> +	/* The masq_dev_notifier will catch the case of the device going
> >> +	 * down.  So if the inetdev is dead and being destroyed we have
> >> +	 * no work to do.  Otherwise this is an individual address removal
> >> +	 * and we have to perform the flush.
> >> +	 */
> >> +	idev = ifa->ifa_dev;
> >> +	if (idev->dead)
> >> +		return NOTIFY_DONE;
> >> +
> >> +	netdev_notifier_info_init(&info, idev->dev);
> >>  	return masq_device_event(this, event, &info);
> >>  }
> > 
> > Guys, I'm lost. Currently masq_device_event calls for conntrack
> > cleanup with device index, so that once device is going down, the
> > appropriate conntracks gonna be dropped off. Now if device is dead
> > nobody will cleanup the conntracks?
> 
> Both notifiers are run in the inetdev_destroy() case.
> 
> Maybe that's what you are missing.

No :) Look, here is what I mean. Previously with your two patches
we've been calling nf-cleanup for every address, so we had to make
code call for cleanup for one time only. Now with the patch above
the code flow is the following

inetdev_destroy
	in_dev->dead = 1;
	...
	inet_del_ifa
		...
		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
		...
		masq_inet_event
		 ...
		  masq_device_event
			if (idev->dead)
				return NOTIFY_DONE;

and nobody calls for nf_ct_iterate_cleanup, no?
