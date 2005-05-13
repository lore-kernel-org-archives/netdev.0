From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 23:25:02 +1000
Message-ID: <20050513132502.GA22568@gondor.apana.org.au>
References: <20050512231038.GA22440@gondor.apana.org.au> <20050512.162426.75782784.davem@davemloft.net> <20050512235236.GA22658@gondor.apana.org.au> <20050512.213618.14358320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512.213618.14358320.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 09:36:18PM -0700, David S. Miller wrote:
> 
> Yes, when we walk the queue to retransmit, we chop up the
> TSO frame via tcp_trim_head() and tcp_fragment().  It is
> very loose and would need refinements though.

I'm also thinking that we might also want to do segmentation in
response to SACKs.  So we'd start with a super-frame and keep
trimming bits off at the head as normal ACKs stream in.  Once
we get a SACK, we chop it down the middle to create two SKBs.

> I think we'd be OK, because even if we get a GFP_ATOMIC allocation
> failure, it's just like any other failure.  We're doing retransmits
> so a timer will be the worst case deadlock breaker should we get an
> allocation failure while chopping up the TSO frame.

Yep.

> This actually makes me worried about sk->sk_send_head advancement.
> I think we have a deadlock possible here.  If sk->sk_send_head is
> the only packet in the output queue, and the remote system has no
> reason to send us zero-window probes or any other packets, we could
> wedge if the skb_clone() fails for the tcp_transmit_skb() call.
> We won't set any timers if we fail to send that single sk->sk_send_head
> write queue packet, and we have no pending frames waiting to be ACK'd,
> so nothing will wake us up to retry the transmit.

AFAIK all the paths that do the initial send will start a timer if
it fails.  I've checked the callers of tcp_push_one, tcp_write_xmit
and tcp_write_wakeup.  I might've easily missed something though.
 
> That loop in there is bogus and unnecessary.  In the changelog for
> the TCP Reloaded patch I mention that this can be simplified into:
> 
> 	new_packets = skb_queue_len(&sk->sk_write_queue) - in_flight;
> 	cwnd -= in_flight;
> 	return min(new_packets, cwnd);

I think we still need to limit it to snd_wnd which is what the
loop was doing.

> To handle these super-TSO frames properly, we would need to add
> sk->sk_send_offset to go along with sk->sk_send_head.  So then
> update_send_head() would advance sk->sk_send_offset, and if that
> completely consumed sk->sk_send_head then the pointer would be
> advanced.

We probably shouldn't avoid segmentation altogether.  We could just
segment lazily.  So when we come around to actually transmitting
something, we will allocate an skb and cut off the data according
to the cwnd.  We should then store the segmented skb's on our send
queue instead of the super-frame since we've spent that effort
anyway and it's pretty unlikely for us to have to retransmit
something that crosses the point where we cut off the skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
