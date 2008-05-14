From: David Miller <davem@davemloft.net>
Subject: Re: L2TP: skb truesize bug in recent kernels
Date: Wed, 14 May 2008 03:12:56 -0700 (PDT)
Message-ID: <20080514.031256.180455080.davem@davemloft.net>
References: <482AB9D4.7050800@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754809AbYENKNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 06:13:01 -0400
In-Reply-To: <482AB9D4.7050800@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 14 May 2008 11:07:16 +0100

> The pppol2tp driver uses skb_cow_head() to make headroom for IP, UDP, 
> L2TP and PPP headers. As GRE is being used, it is more likely that there 
> will be insufficient headroom. Does the pppol2tp driver need to adjust 
> truesize if pskb_expand_head() is called?
> 
> I tried the following hack which stopped the skb truesize bug but caused 
> a kernel assert when the socket was closed:
> 
> KERN: assertion (!atomic_read(&sk->sk_wmem_alloc)) failed at 
> net/ipv4/af_inet.c (155)

You can't adjust the truesize when there is a socket associated
with the SKB.

We just had a weeklong thread on this list about these issues
wrt. the wireless stack :-)

skb->truesize records how much memory was charged to the assosicated
socket, so when the socket is freed, the destructor goes

	atomic_dec(&sk->sk_{r,w}mem_alloc, skb->truesize);

so if you increase truesize, the counter will be decremented
more than it was initially incremented.

You cannot change the size of the packet substantially when there is a
socket associated with it, because this makes the truesize inaccurate,
and thus provides a vector for a user's socket to use up more memory
than we were originally going to let it use based upon it's send and
receive buffer limits.
