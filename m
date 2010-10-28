From: David Miller <davem@davemloft.net>
Subject: Re: [Just for fun] loopback: avoid softirq on most transmits
Date: Thu, 28 Oct 2010 13:09:17 -0700 (PDT)
Message-ID: <20101028.130917.179938102.davem@davemloft.net>
References: <1288295326.2711.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761548Ab0J1UIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 16:08:53 -0400
In-Reply-To: <1288295326.2711.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Oct 2010 21:48:46 +0200

> With the introduction of xmit_recursion percpu variable, its pretty
> cheap to check our recursion level in loopback transmit, and avoid
> raising softirq.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> tbench faster by 4%, sorry I couldnt resist...

Hehehe :-)

Maybe even that limit is low enough to prevent stack overflow
situations even when doing NFS over a loopback to a raid volume using
XFS as the filesystem which seems to be the standard stack usage
stress test.

But really, just like DST iteration, we should probably make these
things more iterative.

The cool thing about loopback is that we have a trigger for the cases
we care about, release_sock().

So we could have something like:

1) lock_sock() sets "local cpu will run release_sock()" mark.

2) netif_rx() checks mark, if set it puts SKB on "release_sock()
   local cpu work queue"

3) release_sock() retains mark, and runs SKB queue until empty.
   Once SKB work queue is empty, mark is cleared.

Anyways, just an idea.
