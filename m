From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 09 Mar 2016 15:47:25 -0500 (EST)
Message-ID: <20160309.154725.1921352291794389965.davem@davemloft.net>
References: <20160309175307.GM2207@uranus.lan>
	<20160309.152730.691838022304871697.davem@davemloft.net>
	<20160309204158.GO2207@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160309204158.GO2207@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 9 Mar 2016 23:41:58 +0300

> On Wed, Mar 09, 2016 at 03:27:30PM -0500, David Miller wrote:
>> > 
>> > Yes. I can drop it off for a while and run tests without it,
>> > then turn it back and try again. Would you like to see such
>> > numbers?
>> 
>> That would be very helpful, yes.
> 
> Just sent out. Take a look please. Indeed it sits inside get_next_corpse
> a lot. And now I think I've to figure out where we can optimize it.
> Continue tomorrow.

The problem is that the masquerading code flushes the entire conntrack
table once for _every_ address removed.

The code path is:

masq_device_event()
	if (event == NETDEV_DOWN) {
		/* Device was downed.  Search entire table for
		 * conntracks which were associated with that device,
		 * and forget them.
		 */
		NF_CT_ASSERT(dev->ifindex != 0);

		nf_ct_iterate_cleanup(net, device_cmp,
				      (void *)(long)dev->ifindex, 0, 0);

So if you have a million IP addresses, this flush happens a million times
on inetdev destroy.

Part of the problem is that we emit NETDEV_DOWN inetdev notifiers per
address removed, instead of once per inetdev destroy.

Maybe if we put some boolean state into the inetdev, we could make sure
we did this flush only once time while inetdev->dead = 1.
