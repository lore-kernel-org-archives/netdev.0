From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: Call IP receive handler directly for
 inbound tunnel-mode packets
Date: Tue, 03 Jan 2012 12:56:37 -0500 (EST)
Message-ID: <20120103.125637.211885328407332997.davem@davemloft.net>
References: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
	<20120102072828.GA5380@gondor.apana.org.au>
	<1325492282.2526.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, david.ward@ll.mit.edu,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192Ab2ACR4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:56:52 -0500
In-Reply-To: <1325492282.2526.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jan 2012 09:18:02 +0100

> if (skb->data - skb->head < DEPTH_THRESHOLD)
> 	netif_receive_skb(skb);

Fundamentally I think such things are doomed to failure.

I encourage you to instead look into the idea proposed the other year
(but unfortunately I found no time to implement) wherein we have a
top-level looping structure.

The scheme was originally proposed for TX but we can do it just as easily
for RX too.  Essentially the entity that begins the traversal into the
packet send or receive path makes a mark in some per-cpu data structure.

When we return to the mark setting spot, we check if any "continued
processing" work got queued there, and run it if so, keeping the mark
set.  Once the queued work is rechecked and found to be all clear, we
clear the mark and finish.

This has performance benefits too because on both the TX and RX side
we'll stop this whole dance where we schedule a SW interrupt and incr
all the overhead necessary to do that.

It's going to be faster than your threshold test scheme because we'll
be using a smaller stack frame and thus get better cache hits there.
