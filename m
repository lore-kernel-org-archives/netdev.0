From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 9 Nov 2011 15:01:35 +0000
Message-ID: <1320850895.955.172.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:25179 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab1KIPBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 10:01:37 -0500
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

I presented this work at LPC in September and there was a
question/concern raised (by Jesse Brandenburg IIRC) regarding the
overhead of adding this extra field per fragment. If I understand
correctly it seems that in the there have been performance regressions
in the past with allocations outgrowing one allocation size bucket and
therefore using the next. The change in datastructure size resulting
from this series is:
					  BEFORE	AFTER
AMD64:	sizeof(struct skb_frag_struct)	= 16		24
	sizeof(struct skb_shared_info)	= 344		488
	sizeof(struct sk_buff)		= 240		240

i386:	sizeof(struct skb_frag_struct)	= 8		12
	sizeof(struct skb_shared_info)	= 188		260
	sizeof(struct sk_buff)		= 192		192

(I think these are representative of 32 and 64 bit arches generally)

On amd64 this doesn't in itself push the shared_info over a slab
boundary but since the linear data is part of the same allocation the
size of the linear data which will push us into the next size is reduced
from 168 to 24 bytes, which is effectively the same thing as pushing
directly into the next size. On i386 we go straight to the next bucket
(although the 68 bytes available slack for linear area becomes 252 in
that larger size).

I'm not sure if this is a showstopper or the particular issue with slab
still exists (or maybe it was only slab/slub/slob specific?). I need to
find some benchmark which might demonstrate the issue (presumably
something where frames are commonly 24<size<168). Jesse, any hints on
how to test this or references to the previous occurrence(s) would be
gratefully accepted.

Possible solutions all seem a bit fugly:

      * suitably sized slab caches appropriate to these new sizes (no
        suitable number leaps out at me...)
      * split linear data allocation and shinfo allocation into two. I
        suspect this will have its own performance implications? On the
        positive side skb_shared_info could come from its own fixed size
        pool/cache which might have some benefits
      * steal a bit a pointer to indicate destructor pointer vs regular
        struct page pointer (moving the struct page into the destructor
        datastructure for that case). Stops us sharing a single
        destructor between multiple pages, but that isn't critical
      * add a bitmap to shinfo indicating the kind of each frag.
        Requires modification of anywhere which propagates the page
        member (doable, but another huge series)
      * some sort of pointer compression scheme?

I'm sure there are others I'm not seeing right now.

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[2] http://marc.info/?l=linux-nfs&m=122424132729720&w=2
