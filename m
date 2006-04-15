From: "David S. Miller" <davem@davemloft.net>
Subject: Re: fixing sk_stream_rfree()
Date: Sat, 15 Apr 2006 01:23:27 -0700 (PDT)
Message-ID: <20060415.012327.68977713.davem@davemloft.net>
References: <20060414.205927.13626300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16257
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751573AbWDOIXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 04:23:16 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060414.205927.13626300.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 14 Apr 2006 20:59:27 -0700 (PDT)

> Any ideas?  Come to think of it, __sk_stream_mem_reclaim() looks
> really racey even as-is.

I came up with one more possible approach, it goes something like
this:

1) Get rid of the skb->destructor callback for TCP receive
   data.

2) Adjust sk_rmem_alloc and sk_forward_alloc explicitly when we add
   packets to sk_receive_queue/out_of_order_queue, and when we unlink
   them from sk_receive_queue and __kfree_skb() them up.

I think this would work and get rid of the unlocked accesses to
sk_forward_alloc.  And it would do so without adding new overheads
(the other two ideas did, by adding locks or turning sk_forward_alloc
into an atomic_t).

The implementation needs a bit of thinking in order to not mess up all
the nice abstractions Arnaldo has created for stream sockets and the
interfaces we share between TCP and DCCP.

But actually DCCP needs this fix too, since it also uses
sk_forward_alloc, so building the solution into the shared interfaces
is desirable.

Too bad this will take a little bit of time to implement, I really
want to be able to cook up a much simpler test patch that the people
who can reproduce the BUG() can try out.
