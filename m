From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 22:56:53 -0700 (PDT)
Message-ID: <20120620.225653.1103922403304200286.davem@davemloft.net>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	<1340170590.4604.784.camel@edumazet-glaptop>
	<1340180223.4604.828.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab2FUF4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 01:56:54 -0400
In-Reply-To: <1340180223.4604.828.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 10:17:03 +0200

> By the way, big cost in netdev_alloc_frag() is the irq
> masking/restore We probably could have a version for softirq
> users...

That's an extremely disappointing way for us to be losing cycles.

Everyone pays this price purely because:

1) __netdev_alloc_skb() uses netdev_alloc_frag()

and:

2) #1 is invoked, either directly or indirectly, by tons
   of slow non-NAPI drivers.

This got me looking into the plathora of interfaces we let drivers use
to allocate RX buffers.  It's a big mess.

We have dev_alloc_skb() which essentially calls __netdev_alloc_skb()
with a NULL device argument.  This is terrible because it means that
if we want to do something interesting on a per-device level we can't
rely upon the device being non-NULL in __netdev_alloc_skb().

I looked at the remaining dev_alloc_skb() users and these are in places
which are allocating packets in a module which is one level removed from
the netdevice level.  For example, ATM and infiniband IPATH.

What these callers want is something more like:

static inline struct sk_buff *alloc_skb_and_reserve_pad(unsinged int length,
							gfp_t gfp_mask)
{
	struct sk_buff *skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
					  0, NUMA_NO_NODE);
	if (likely(skb))
		skb_reserve(skb, NET_SKB_PAD);
	return skb;
}

Then we won't have the NULL device case for __netdev_alloc_skb() any more.
