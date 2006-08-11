From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: skb_shared_info()
Date: Fri, 11 Aug 2006 18:00:19 +0400
Message-ID: <20060811140019.GA8611@ms2.inr.ac.ru>
References: <20060808.163915.03600382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:45212 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751123AbWHKOAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 10:00:34 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.163915.03600382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

>> management schemes and to just wrap SKB's around
>> arbitrary pieces of data.
+
> and something clever like a special page_offset encoding
> means "use data, not page".

But for what purpose do you plan to use it?


> The e1000 issue is just one example of this, another

What is this issue?


What's about aggregated tcp queue, I can guess you did not find place
where to add protocol headers, but cannot figure out how adding non-pagecache
references could help.

You would rather want more then one skb_shared_info(): at least two,
one is immutable, another is for headers.

I think Evgeniy's idea about inlining skb_shared_info to skb head
is promising and simple enough. All the point of shared skb_shared_info
was to make cloning fast. But it makes lots of sense to inline some short
vector inot skb head (and, probably, even a MAX_HEADER space _instead_
of space for fclone).

With aggregated tcp send queue, when transmitting a segment, you could
allocate new skb head with space for header and either take existing
skb_shared_info from queue, attach it to head and set offset/length.
Or, alternatively, set one or two of page pointers in array, inlined in head.
(F.e. in the case of AF_UNIX socket, mentioned by Evgeniy, we would keep data
in pages and attach it directly to skb head).

Cloning becomes more expensive, but who needs it cheap, if tcp does not?



Returning to "arbitrary pieces of data".

Page cache references in skb_shared_info are unique thing,
get_page()/page_cache_release() are enough to clone data.

But it is not enough even for such simple thing as splice().
It wants we remembered some strange "pipe_buffer", where each page
is wrapped together with some ops, flags and even pipe_inode_info :-),
and called some destructor, when it is released. First thought is that
it is insane: it does not respect page cache logic, requires we implemented
additional level of refcounting, abuses amount of information, which
have to be stored in skb beyond all the limits of sanity.

But the second thought is that something like this is required in any case.
At least we must report to someone when a page is not in use and
can be recycled. I think Evgeniy knows more about this, AIO has
the same issue. But this is simpler, because release callback can be done
not per fragment or even per-skb, but actually per-transaction.

One idea is to announce (some) skb_shared_info completely immutable,
force each layer who needs to add a header or to fragment to refer
to original skb_shared_info as whole, using for modifications
another skb_shared_info() or area inlined in skb head.
And if someone is not able to, he must reallocate all the pages.
In this case destructor/notification can be done not for fragment,
but for whole aggregated skb_shared_info. Seems, it will work both
with aggregated tcp queue and with udp.

Alexey
