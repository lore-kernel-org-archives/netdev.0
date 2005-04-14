From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Fri, 15 Apr 2005 09:22:27 +1000
Message-ID: <20050414232227.GB22721@gondor.apana.org.au>
References: <20050414213040.GA21276@gondor.apana.org.au> <OF9945BD02.93FE9951-ON88256FE3.007AADB9-88256FE3.007CD7C9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF9945BD02.93FE9951-ON88256FE3.007AADB9-88256FE3.007CD7C9@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2005 at 03:43:37PM -0700, David Stevens wrote:
> 
> > Thanks.  Actually I did include it in my patch too.
> 
> Yes, I just saw this -- at lower layer. I prefer the flush up
> in sendmsg, since 1) that's where the other error case is done
> and 2) that's where the append happens. But I could go either way.

Sorry I disagree.  Look at the way ip6_push_pending_frames works, when
it returns you're guaranteed that the packet has been sent or dropped.
Either way the cork buffer has been freed.

Therefore rawv6_push_pending_frames should act in an analagous way.

In fact with your patch we can end up calling ip6_flush_pending_frames
twice.  Granted that it is currently harmless but it isn't nice.
 
> > Multiple packets will exist on the queue when the user has written
> > more than one MTU worth of data.
> 
> I think the fragmentation happens in the IPv6 layer, so only memory
> fragmentation can happen from sendmsg (as far as I can tell). Meaning

Look at line 911 in ip6_output.c (inside ip6_append_data).  When the
user sends more data than can be accomdated in one MTU-sized packet,
we will allocate new skb's and put them on the write queue.

> the frags array can have multiple buffers, but I'm not sure the
> frag_list can have anything on it. In my testing, I wrote a 2K packet

frag_list is guaranteed to be empty in rawv6_push_pending_frames, however
the write queue may have multiple packets.  That's where your patch went
wrong.  It only handled the case where the checksum is in the first skb
on the write queue.

> (in fact, all contiguous, in the head). The nr_frags != 0 only happened
> with multiple sendmsgs when the write queue had not been flushed, but
> I expect it can happen in other cases (e.g., corking). Unless I'm wrong,

nr_frags != 0 will happen when

1) Your NIC supports SG.
2) Your MTU > PAGE_SIZE or the socket page is partially used when you enter
   ip6_append_data.
 
> Yeah, I wrote a non-recursive version of skb_store_bits, but it doesn't
> look any less complex (what I was hoping for). And it doesn't handle
> the case of a frag_list skb having a frag_list of its own, if that can
> happen. That's the case where it could recurse multple times, but I don't

It doesn't make sense to have a frag_list inside a frag_list and you
can consider it disallowed.

> know if that's possible, either. Possible maybe on received packets, but,
> unless I'm wrong, none of that can happen here.

Well if you do come up with any simplifications please simplify
skb_copy_bits too and submit a patch :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
