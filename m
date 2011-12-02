From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 13:40:40 -0500 (EST)
Message-ID: <20111202.134040.638198723589712419.davem@davemloft.net>
References: <1322841935.2762.33.camel@edumazet-laptop>
	<20111202.131304.981034697414242002.davem@davemloft.net>
	<1322850989.2762.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab1LBSkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 13:40:47 -0500
In-Reply-To: <1322850989.2762.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 19:36:29 +0100

> What I ask now is following problem (even prior to my frag allocation
> patch) :
> 
> 1) We allocate a linear skb (SG being off) to cook a tcp frame of length
> XXX bytes.
> 
> 2) We send it.
> 
> 3) We receive an ACK for first 31 bytes.
> 
> 4) We trim 31 bytes from the head of skb.  (skb_pull(skb, 31))
>     skb->data is now not anymore aligned to a 4 bytes boundary.
> 
> 5) Later, we need to retransmit skb (XXX minus 31 bytes already ACKed)
>    We push TCP header, and skb->data is not aligned.
>    TCP header is not aligned anymore. x86 doesnt care, but what about
> other arches with misalign traps ?

Yes, for non-SG this always was technically possible.

But now you've made it possible for SG too.

Frankly, I think we should:

1) Revert your patch, so it's not possible for SG once more.

2) Add code to reallocate the SKB linear data when this happens in
   the non-SG case.
