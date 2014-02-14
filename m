From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: check for ndo_select_queue during queue
 selection
Date: Fri, 14 Feb 2014 13:48:43 -0500 (EST)
Message-ID: <20140214.134843.1912150240271947468.davem@davemloft.net>
References: <1392311935-10275-1-git-send-email-dborkman@redhat.com>
	<20140214.004048.616136663605863975.davem@davemloft.net>
	<52FDEE22.9010503@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathias.kretschmer@fokus.fraunhofer.de, netdev@vger.kernel.org,
	brouer@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbaBNSsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 13:48:46 -0500
In-Reply-To: <52FDEE22.9010503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 14 Feb 2014 11:21:22 +0100

> The other two possibilities I see is 1) to check for
> dev->ieee80211_ptr on setsockopt(2) and bind(2) (which could happen
> _after_ the option was set) and just disallow that option for those
> cases (doesn't make sense to use it for ieee80211 devs anyway, and
> they seem to be the only special-cased users), or, preferably 2) to
> just leave the code as it currently is, that is, similar to pktgen.

Don't sell yourself so short, think out of the box:

typedef u16 (*select_queue_fallback_t)(struct net_device *dev, struct sk_buff *skb);
 ...
	u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
				void *accel_priv, select_queue_fallback_t fallback);

And your packet code would do something like:

static u16 __packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
{
	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
}

static u16 packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
{
	u16 queue_index;

	if (ops->ndo_select_queue)
		queue_index = ops->ndo_select_queue(dev, skb, NULL, __packet_pick_tx_queue);
	else
		queue_index = __packet_pick_tx_queue(dev, skb);
	skb_set_queue_mapping(skb, queue_index);
}

Then you go through the existing ndo_select_queue implementations, you'll notice
a lot of them are of the form:

	if (special_stuff)
		queue_index = whatever;
	else
		queue_index = __netdev_pick_tx(...);

replace that __netdev_pick_tx call with one to "fallback".
