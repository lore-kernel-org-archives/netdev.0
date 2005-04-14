From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Thu, 14 Apr 2005 15:43:37 -0700
Message-ID: <OF9945BD02.93FE9951-ON88256FE3.007AADB9-88256FE3.007CD7C9@us.ibm.com>
References: <20050414213040.GA21276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050414213040.GA21276@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote on 04/14/2005 02:30:40 PM:

> Thanks.  Actually I did include it in my patch too.

Yes, I just saw this -- at lower layer. I prefer the flush up
in sendmsg, since 1) that's where the other error case is done
and 2) that's where the append happens. But I could go either way.

> > A couple comments initially on your patch: multiple packet support I 
don't
> > think is needed here (in sendmsg). I agree it's good to put it in for
> > other
> > possible uses, but IPV6_CHECKSUM doesn't need it, as far as I can 
tell.

> Multiple packets will exist on the queue when the user has written
> more than one MTU worth of data.

I think the fragmentation happens in the IPv6 layer, so only memory
fragmentation can happen from sendmsg (as far as I can tell). Meaning
the frags array can have multiple buffers, but I'm not sure the
frag_list can have anything on it. In my testing, I wrote a 2K packet
(on Ethernet w/ 1500 MTU) and it all appeared in a single skb
(in fact, all contiguous, in the head). The nr_frags != 0 only happened
with multiple sendmsgs when the write queue had not been flushed, but
I expect it can happen in other cases (e.g., corking). Unless I'm wrong,
I think the frag_list stuff will only be filled at the (lower) IPv6 layer.
It accounts for the fragment header length in the initial allocation
if it will need to fragment, but doesn't appear to allocate the
skbs as separate frags based on MTU. I may be reading it wrong, too,
of course. :-)

> > How about a loop instead of a recursive call? If the list is long 
enough
> > and the architecture eats stack a lot of stack space on function 
calls,
> > that could be a problem.

> You mean where skb_store_bits calls itself? This can only recurse once
> at most.  In fact, in this particular instance it will not recurse at
> all since the fragments aren't chained together (the chaining occurs in
> ip6_push_pending_frames).  This is how skb_copy_bits works too.

Yeah, I wrote a non-recursive version of skb_store_bits, but it doesn't
look any less complex (what I was hoping for). And it doesn't handle
the case of a frag_list skb having a frag_list of its own, if that can
happen. That's the case where it could recurse multple times, but I don't
know if that's possible, either. Possible maybe on received packets, but,
unless I'm wrong, none of that can happen here.

                                                        +-DLS
