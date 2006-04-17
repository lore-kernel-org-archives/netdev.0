From: "David S. Miller" <davem@davemloft.net>
Subject: Re: fixing sk_stream_rfree()
Date: Sun, 16 Apr 2006 22:32:03 -0700 (PDT)
Message-ID: <20060416.223203.47773632.davem@davemloft.net>
References: <20060414.205927.13626300.davem@davemloft.net>
	<20060416111831.GA15093@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25788
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750709AbWDQFbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 01:31:40 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060416111831.GA15093@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 16 Apr 2006 21:18:31 +1000

> Great eyes! Yes that bug seems to have been around forever.  I'll
> look over the patch tomorrow as right now I'm still on west-coast
> time :)

Let me save you some time, later in the thread you'll find
out that this whole thing is a dead end.

The reason is that all SKBs are unshared when we receive them
into the TCP stack for sk->sk_receive_queue.  (this is done
by ip_rcv()).

This means every __kfree_skb() call would happen in the context
of the TCP stack with the socket locked, so no concurrency issues
wrt. sk_forward_alloc as I originally thought.

In fact, this is what makes using __kfree_skb() explicitly legal
in the first place.  If skb->users could be non-zero, from tcpdump
etc., then we'd be required to call kfree_skb() in the TCP code
that frees up used packets on the receive queue.

But all is not lost, this is an important datapoint.  We've audited
the receive side accesses to sk_forward_alloc and it all looks good.

And again, as you mention, we go back again to TSO being the deciding
factor in triggering this or not.

So it nearly has to be a send side issue that can only trigger with
TSO enabled, and my next planned chore is to audit the TSO splitting
during ACK processing.  We may be doing something stupid there.
