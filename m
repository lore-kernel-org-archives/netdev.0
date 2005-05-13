From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 21:36:18 -0700 (PDT)
Message-ID: <20050512.213618.14358320.davem@davemloft.net>
References: <20050512231038.GA22440@gondor.apana.org.au>
	<20050512.162426.75782784.davem@davemloft.net>
	<20050512235236.GA22658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050512235236.GA22658@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 09:52:36 +1000

> > #2 could be handled by down-sizing TSO frames when packet loss occurs.
> > Ie. tcp_retransmit_skb() or whatever will segmentize a TSO packet
> > which is within the sequence it is trying to retransmit.  Implementing
> > this is non- trivial mostly due to the fact that it has to work handle
> > GFP_ATOMIC memory failures and also get all the pcount crap correct.
> 
> I think most of the code to do that might already be there.  Pity
> we'll have to keep track of the pcount though.

Yes, when we walk the queue to retransmit, we chop up the
TSO frame via tcp_trim_head() and tcp_fragment().  It is
very loose and would need refinements though.

I think we'd be OK, because even if we get a GFP_ATOMIC allocation
failure, it's just like any other failure.  We're doing retransmits
so a timer will be the worst case deadlock breaker should we get an
allocation failure while chopping up the TSO frame.

This actually makes me worried about sk->sk_send_head advancement.
I think we have a deadlock possible here.  If sk->sk_send_head is
the only packet in the output queue, and the remote system has no
reason to send us zero-window probes or any other packets, we could
wedge if the skb_clone() fails for the tcp_transmit_skb() call.
We won't set any timers if we fail to send that single sk->sk_send_head
write queue packet, and we have no pending frames waiting to be ACK'd,
so nothing will wake us up to retry the transmit.

> > and size appropriately.  I think the tcp_snd_test() simplifications
> > made by my TSO Reloaded patch would help a lot here.  The send test is
> > logically now split to it's two tests 1) whether to send anything at
> > all, and 2) once #1 passes, how many such packets.
> 
> That was another one of my comments to your patch :) I was going to
> suggest that we move the cwnd/in_flight loop from tcp_snd_test to
> emit_send_queue.

One elegant part of the tcp_snd_test() in the TCP Reloaded patch is
that tcp_write_queue() calls it exactly once.

That loop in there is bogus and unnecessary.  In the changelog for
the TCP Reloaded patch I mention that this can be simplified into:

	new_packets = skb_queue_len(&sk->sk_write_queue) - in_flight;
	cwnd -= in_flight;
	return min(new_packets, cwnd);

It is a BUG() for this calculation to be larger than the number of
packets from sk->sk_send_head to the end of the write queue (which is
the invariant we must guarentee for our caller).  We could even check
for this while debugging the implementation early on.

> > This would be a sort of super-TSO that would do less segmenting work
> > than even a "perfect" TSO segmenter would.
> > 
> > I'm still not sure which approach is best, just throwing around some
> > ideas.
> 
> On paper your new super-TSO approach sounds the best.  However, I
> suppose we won't know for sure until we try :)

Yeah, TCP Reloaded sounded really nice on paper too :-)

To handle these super-TSO frames properly, we would need to add
sk->sk_send_offset to go along with sk->sk_send_head.  So then
update_send_head() would advance sk->sk_send_offset, and if that
completely consumed sk->sk_send_head then the pointer would be
advanced.

Tests of sk->sk_send_head would need to be fixed up similarly.
