From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/6 v2] skb paged fragment destructors
Date: Thu, 5 Jan 2012 17:09:59 +0000
Message-ID: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:51604 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757758Ab2AERKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:10:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series makes use of the skb fragment API (which is in 3.2)
to add a per-paged-fragment destructor callback. This can be used by
creators of skbs who are interested in the lifecycle of the pages
included in that skb after they have handed it off to the network stack.
I think these have all been posted before, but have been backed up
behind the skb fragment API.

The mail at [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have also included a patch to the RPC subsystem which uses this API to
fix the bug which I describe at [2].

Last time I posted this series it was observed that the size of struct
skb_frag_struct was increased sufficiently that a 1500 byte frame would
no longer fit into a half page allocation (with 4K pages).

I investigated some options which did not require increasing the size of
the skb_frag_struct at all but they were mostly pretty ugly (either for
the user of the API or within the network stack itself). 

However having observed that MAX_SKB_FRAGS could be reduced by 1 (see
9d4dde521577 "net: only use a single page of slop in MAX_SKB_FRAGS") I
decided it was worth trying to see if I could pack the shared info a bit
tighter and fit it into the necessary space.

By tweaking the ordering of the fields and reducing the size of nr_frags
(in combination with 9d4dde521577) I was able to get the shinfo size
down to:

                                          BEFORE        AFTER(v1)	AFTER(v2)
AMD64:  sizeof(struct skb_frag_struct)  = 16            24		24
        sizeof(struct skb_shared_info)  = 344           488		456

i386:   sizeof(struct skb_frag_struct)  = 8             12		12
        sizeof(struct skb_shared_info)  = 188           260		244

(I think these are representative of 32 and 64 bit arches generally)

This isn't quite enough to squeeze things into half a page since both
the data allocation and shinfo are cache line aligned. e.g. for 64 byte
cache lines on amd64:

          ALIGN(NET_SKB_PAD(64) + 1500 + 14) + ALIGN(456)
        = ALIGN(1578) + ALIGN(456)
        = 1600 + 512
        = 2112

This actually leaves a fair bit of slack in many cases so we actually
align the end of the shinfo to a cache line by using ksize() to place it
right at the end of the actual allocation rather than aligning the
front.

If instead we align the total allocation size we reduce the amount of
slop and a maximum MTU frame fits into half a page:

          ALIGN(NET_SKB_PAD(64) + 1500 + 14 456)
        = ALIGN(1578 + 456)
        = ALIGN(2034)
        = 2048

The downside in this scenario is that, for 64 byte cache lines, the
first 8 bytes of shinfo are on the same cache line as the tail of the
data. I think this is the worst case and as the data size varies the
"overlap" will always be <= to this assuming the allocator always rounds
to a multiple of the cache line size. I think this small overlap is
better than spilling over into the next allocation size and it only
happens for sizes 427-490 and 1451-1500 bytes (inclusive).

For the 128 byte cache line case the overlap at worst is 72 bytes which
is up to and including shinfo->frags[0]. This happens for sizes in the
ranges 363-490 and 1387-1500 bytes (inclusive).

There may be various ways which we could mitigate this somewhat if it is
a problem, the most obvious being to reorder the shinfo to put less
frequently access members up front (e.g. destructor_arg seems like a
good candidate). An even more extreme idea might be to put the shinfo
_first_ within the allocation such that the overlap is with the last
(presumably less frequently used) frags.

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[2] http://marc.info/?l=linux-nfs&m=122424132729720&w=2
