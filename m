From: David Miller <davem@davemloft.net>
Subject: Re: bonding inactive slaves vs rx_dropped
Date: Thu, 14 Feb 2013 17:18:21 -0500 (EST)
Message-ID: <20130214.171821.186191007478674738.davem@davemloft.net>
References: <20130214.160657.1394358701071068786.davem@davemloft.net>
	<4606.1360878661@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934965Ab3BNWSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 17:18:23 -0500
In-Reply-To: <4606.1360878661@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 14 Feb 2013 13:51:01 -0800

> David Miller <davem@davemloft.net> wrote:
> 
>>People are starting to notice that rx_dropped now increments on every
>>packet received on an bond's inactive slave.
>>
>>I'm actually fine with rx_dropped incrementing in this situation.
>>
>>The problem I want to address is that rx_dropped is encompassing
>>several unrelated situations and thus has become less useful for
>>diagnosis.
>>
>>I think we should add some new RX stats such that we can get at
>>least a small amount of granularity for rx_dropped.
>>
>>This way team, bond, etc. can increment a new netdev_stats->rx_foo in
>>this situation, and then someone doing diagnosis can see that
>>rx_dropped and rx_foo are incrementing at similar rates.
> 
> 	This drop isn't really happening in bonding, though.  From
> looking at the code, it comes about because, for the inactive slave, the
> rx_handler call returns EXACT, and there aren't any exact match ptype
> bindings, so __netif_receive_skb throws it away.  This isn't always the
> case; sometimes there is an exact match, for things like iSCSI or FCoE
> that are really determined to get the packet.

This isn't even the whole story, it won't return 'exact' if the packet
from the inactive slave is broadcast or multicast.

My general rule is that every special case increments a special
'absurdity' statistic counter for the code :-)

> 	We could probably add an, oh, rx_dropped_inactive, or some
> variation on that theme, that is incremented at the end of
> __netif_receive_skb if deliver_exact is set, e.g., something like:

Yes, that looks fine to me.

> 	There's the separate questions of whether there should be more
> counters (e.g., drops in dev_skb_forward or enqueue_to_backlog), and how
> to deliver the counter(s) to user space.

Since there is some pain in adding counters, I think we should try to
find a nice (very small) set of cases to cover all at once.
