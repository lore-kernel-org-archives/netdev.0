From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 21 Sep 2012 13:04:40 -0400 (EDT)
Message-ID: <20120921.130440.1881102470665263512.davem@davemloft.net>
References: <1348242511.2669.635.camel@edumazet-glaptop>
	<20120921.122705.1344923255084267186.davem@davemloft.net>
	<1348246281.2669.755.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab2IUREn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:04:43 -0400
In-Reply-To: <1348246281.2669.755.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Sep 2012 18:51:21 +0200

> On Fri, 2012-09-21 at 12:27 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 21 Sep 2012 17:48:31 +0200
>> 
>> > There is probably a reason why lo default MTU is 16436 ?
>> 
>> That's what fit into L1 caches back in 1999
> 
> I see ;)
> 
> Nowadays, we even have the NETIF_F_NOCACHE_COPY flag and
> __copy_from_user_nocache()
> 
> Hmm, we can not toggle this flag on loopback yet
> 
> # ethtool -K lo tx-nocache-copy on
> Could not change any device features

It's a silly limitation, in net/core/dev.c:

	/* Turn on no cache copy if HW is doing checksum */
	if (!(dev->flags & IFF_LOOPBACK)) {
		dev->hw_features |= NETIF_F_NOCACHE_COPY;
		if (dev->features & NETIF_F_ALL_CSUM) {
			dev->wanted_features |= NETIF_F_NOCACHE_COPY;
			dev->features |= NETIF_F_NOCACHE_COPY;
		}
	}

Maybe this is probably better done as:

	/* Turn on no cache copy if HW is doing checksum */
	dev->hw_features |= NETIF_F_NOCACHE_COPY;
	if (!(dev->flags & IFF_LOOPBACK)) {
		if (dev->features & NETIF_F_ALL_CSUM) {
			dev->wanted_features |= NETIF_F_NOCACHE_COPY;
			dev->features |= NETIF_F_NOCACHE_COPY;
		}
	}

And then the code matches more closely the comment. :-)
