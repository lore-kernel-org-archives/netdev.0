From: "David S. Miller" <davem@davemloft.net>
Subject: fixing sk_stream_rfree()
Date: Fri, 14 Apr 2006 20:59:27 -0700 (PDT)
Message-ID: <20060414.205927.13626300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22168
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030231AbWDOD7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 23:59:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Herbert, as you may have noticed we found some missing
locking in sk_stream_rfree().  It could explain the
"!sk_forward_alloc" BUG() we thought was caused by e1000's
TSO implementation and the Intel folks have provided enough
datapoints to prove that it is indeed not an e1000 specific
problem.

sk_stream_rfree() modifies sk->sk_forward_alloc without holding any
locks from the __kfree_skb() callback.

Now, _most_ of the time it is OK because we're being invoked with the
socket lock held as ACKs come back to liberate the transmit queue or
during socket shutdown which also holds the socket locked.  (I did
audit this, but I may have missed something, please double check this
assertion)

However, if skb->users is incremented or similar, that entity could
end up being the context in which the skb is freed up and that will
not necessarily have the socket locked correctly when the
skb->destructor callback invokes sk_stream_rfree().  Consider tcpdump
or similar.

But we're stuck if we try to cure this:

1) We can't take bh_lock_sock().  Well, we could if we disabled
   BH explicitly first but even then if the socket is locked
   by the user we can't tell if that's the current cpu and there
   is no easy way to handle deferring this work.

   We really can't consider using a workqueue or something like
   that to handle this, that's way too heavy handed.

2) We can't turn sk_forward_alloc easily into an atomic_t.  The
   masking operation in __sk_stream_mem_reclaim() does not translate
   readily into an atomic_t op:

		sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;

   That line has always driven me nuts, but I know that it is there
   to handle partial page allocations existing when that function
   is called.

I guess for #2 we could change those two lines into:

		int n = atomic_read(&sk->sk_forward_alloc) /
				SK_STREAM_MEM_QUANTUM;

		atomic_sub(n, sk->sk_prot->memory_allocated);
		sk->sk_forward_alloc -= n * SK_STREAM_MEM_QUANTUM;

in order to make it "atomic_t op" translatable.

But even if we did this with sk->sk_forward_alloc as an atomic_t
it would have the same kinds of races we're trying to cure here,
namely that we test the value and then act upon it while an unlocked
asynchronous context can modify the value in another thread of
execution in between the test and the action.

Any ideas?  Come to think of it, __sk_stream_mem_reclaim() looks
really racey even as-is.
