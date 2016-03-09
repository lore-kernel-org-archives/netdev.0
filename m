From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 23:57:47 +0300
Message-ID: <20160309205746.GQ2207@uranus.lan>
References: <20160309175307.GM2207@uranus.lan>
 <20160309.152730.691838022304871697.davem@davemloft.net>
 <20160309204158.GO2207@uranus.lan>
 <20160309.154725.1921352291794389965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160309.154725.1921352291794389965.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2016 at 03:47:25PM -0500, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Wed, 9 Mar 2016 23:41:58 +0300
> 
> > On Wed, Mar 09, 2016 at 03:27:30PM -0500, David Miller wrote:
> >> > 
> >> > Yes. I can drop it off for a while and run tests without it,
> >> > then turn it back and try again. Would you like to see such
> >> > numbers?
> >> 
> >> That would be very helpful, yes.
> > 
> > Just sent out. Take a look please. Indeed it sits inside get_next_corpse
> > a lot. And now I think I've to figure out where we can optimize it.
> > Continue tomorrow.
> 
> The problem is that the masquerading code flushes the entire conntrack
> table once for _every_ address removed.
> 
> The code path is:
> 
> masq_device_event()
> 	if (event == NETDEV_DOWN) {
> 		/* Device was downed.  Search entire table for
> 		 * conntracks which were associated with that device,
> 		 * and forget them.
> 		 */
> 		NF_CT_ASSERT(dev->ifindex != 0);
> 
> 		nf_ct_iterate_cleanup(net, device_cmp,
> 				      (void *)(long)dev->ifindex, 0, 0);
> 
> So if you have a million IP addresses, this flush happens a million times
> on inetdev destroy.
> 
> Part of the problem is that we emit NETDEV_DOWN inetdev notifiers per
> address removed, instead of once per inetdev destroy.
> 
> Maybe if we put some boolean state into the inetdev, we could make sure
> we did this flush only once time while inetdev->dead = 1.

Aha! So in your patch __inet_del_ifa bypass first blocking_notifier_call_chain

__inet_del_ifa
	...
	if (in_dev->dead)
		goto no_promotions;

	// First call to NETDEV_DOWN
...
no_promotions:
	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, portid);
	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);

and here we call for NETDEV_DOWN, which then hits masq_device_event
and go further to conntrack code.
