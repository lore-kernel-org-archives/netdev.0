From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Fri, 22 Aug 2008 03:42:17 -0700 (PDT)
Message-ID: <20080822.034217.135152551.davem@davemloft.net>
References: <20080822065655.GA18471@gondor.apana.org.au>
	<20080822.001620.141235108.davem@davemloft.net>
	<20080822074115.GB25615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080822074115.GB25615-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Fri, 22 Aug 2008 17:41:15 +1000

> On Fri, Aug 22, 2008 at 12:16:20AM -0700, David Miller wrote:
> > 
> > I suppose you're talking about the grand unified flow cache
> > that never gets implemented right?  I classify that in the
> > same category as net channels at the moment, theoretically
> > very interesting but no practical implementation in sight.
> 
> In any case, we could implement what I suggested even without
> a flow cache, by simply storing the info in the dst.  This means
> that all flows on the same dst will end up in the same queue, which
> is not as good as what a flow cache could give, but it's useful
> enough to be an option.

I had another idea in the back of my head that I wanted to mention.

The SKB has a hash, and sources set the hash.  It doesn't matter
where in the stack it comes from.

At transmit time, the select queue logic in dev_queue_xmit() will use
the SKB hash if one has been set already.  Otherwise it will do the
hashing it does currently.

So in the simplest case for forwarding, the RX side puts the RSS
hash or whatever into this SKB hash location.

Then, taking things to the next level, protocols set hashes for
locally created packets.  And this leads to being able to delete
the simple_tx_hash() code entirely and also we won't have to add
support for every protocol on the planet to that function. :)

TCP sockets maybe could even do something clever, like, using the
incoming SKB hash of the SYN and SYN+ACK packets for all subsequent
SKBs sent by that socket.

Another nice side effect, we have the choice of allowing IPSEC
encapsulation of locally generated frames to not change the TX queue.
This would have to be controlled by a sysctl or similar because I
can see both ways being useful in different circumstances.

You get the idea.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
