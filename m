From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Thu, 14 Apr 2005 17:31:38 -0700
Message-ID: <OF8E587AEF.C9490192-ON88256FE3.0081CF1A-88256FE4.0002E57F@us.ibm.com>
References: <20050414232227.GB22721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050414232227.GB22721@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote on 04/14/2005 04:22:27 PM:

> On Thu, Apr 14, 2005 at 03:43:37PM -0700, David Stevens wrote:
> >
> > > Thanks.  Actually I did include it in my patch too.
> >
> > Yes, I just saw this -- at lower layer. I prefer the flush up
> > in sendmsg, since 1) that's where the other error case is done
> > and 2) that's where the append happens. But I could go either way.

> Sorry I disagree.  Look at the way ip6_push_pending_frames works, when
> it returns you're guaranteed that the packet has been sent or dropped.
> Either way the cork buffer has been freed.

> Therefore rawv6_push_pending_frames should act in an analagous way.

> In fact with your patch we can end up calling ip6_flush_pending_frames
> twice.  Granted that it is currently harmless but it isn't nice.

        I don't see this. My original patch only calls
ip6_flush_pending_frames() once, since the original code already only
calls rawv6_push_pending_frames() in the "else" of "if (err)". It's
just a question of whether you call it within rawv6_push_pending_frames()
before returning error, or immediately after returning, doing it in
the caller.
        It's asymmetric in your patch because the data isn't queued
from rawv6_push...(), but it's freed (on error) within it, while
the ip6_append_data...() itself flushs from the caller on error,
rather than doing it within ip6_append_data() and then returning an
error. I'm pretty sure they are functionally equivalent, which is
why I can go either way. :-)

> > > Multiple packets will exist on the queue when the user has written
> > > more than one MTU worth of data.
> >
> > I think the fragmentation happens in the IPv6 layer, so only memory
> > fragmentation can happen from sendmsg (as far as I can tell). Meaning

> Look at line 911 in ip6_output.c (inside ip6_append_data).  When the
> user sends more data than can be accomdated in one MTU-sized packet,
> we will allocate new skb's and put them on the write queue.

        I saw that in the code, but I also saw a 2K single skb when the
MTU is 1500. A piece I looked at appeared to be allocating space for
frag headers (to be filled in on fragmentation at IPv6 layer, I assume),
but still putting the data in the same skb; I'll do some
more testing and see if I can understand it better; maybe there's
another bug, or a way to avoid a copy when fragmenting in lower layers.
        But, you're right, if it can happen (appeared not, to me) then
your code handles that, too. Even if it doesn't happen in ordinary
data>MTU case, I expect it may be possible with MSG_MORE, corking,
or other less common cases.

> > Yeah, I wrote a non-recursive version of skb_store_bits, but it 
doesn't
> > look any less complex (what I was hoping for). And it doesn't handle
> > the case of a frag_list skb having a frag_list of its own, if that can
> > happen. That's the case where it could recurse multple times, but I 
don't

> It doesn't make sense to have a frag_list inside a frag_list and you
> can consider it disallowed.

> Well if you do come up with any simplifications please simplify
> skb_copy_bits too and submit a patch :)

        Well, it made more sense to me, but still complex enough that
it might not be clearer to anyone else. skb_copy_bits() works as
far as I know, so I guess we can keep both. :-)

                                                        +-DLS
