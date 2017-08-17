From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Thu, 17 Aug 2017 14:45:30 +0200
Message-ID: <20170817124530.GN773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-2-equinox@diac24.net>
 <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
 <20170817110324.GK773745@eidolon>
 <4d4c8d17-1e0b-b78f-983b-e419e153b2bf@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:49238 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751620AbdHQMpd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 08:45:33 -0400
Content-Disposition: inline
In-Reply-To: <4d4c8d17-1e0b-b78f-983b-e419e153b2bf@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 02:39:43PM +0300, Nikolay Aleksandrov wrote:
> On 17/08/17 14:03, David Lamparter wrote:
> > On Wed, Aug 16, 2017 at 11:38:06PM +0300, Nikolay Aleksandrov wrote:
> >> On 16/08/17 20:01, David Lamparter wrote:
> >> and hitting the fast path for everyone in a few different places for a
> >> feature that the majority will not use does not sound acceptable to
> >> me. We've been trying hard to optimize it, trying to avoid additional
> >> cache lines, removing tests and keeping special cases to a minimum. 
> > 
> > skb->dst is on the same cacheline as skb->len.
> > fdb->md_dst is on the same cacheline as fdb->dst.
> > Both will be 0 in a lot of cases, so this should be two null checks on
> > data that is hot in the cache.  Are you sure this is an actual problem?
> > 
> 
> Sure - no, I haven't benchmarked it, but I don't see skb->len being on
> the same cache line as _skb_refdst assuming 64 byte cache lines.
> But again any special cases, in my opinion, should be handled on their own,
> it is both about the fast path and the code complexity that they bring in.

(separate thread)

[cut]
> > I really hope you're not suggesting the entire MDB with IPv4 & IPv6
> > snooping be duplicated into both VPLS and mac80211?
> 
> Code can always be shared if there are more users, no need to stuff
> everything in the bridge,

The MDB code is far from trivial, has several configuration knobs, and
even sends its own queries if configured to do so.  It can also use
quite a bit of memory of there's a nontrivial number of multicast
groups.  I *really* think it shouldn't be duplicated.

> but I'm not that familiar with this case, once patches are out I can
> comment further.

I've pushed my hacks to:
https://github.com/eqvinox/vpls-linux-kernel/commits/mdb-hack
(top two commits)

THIS IS ABSOLUTELY A PROOF OF CONCEPT.  It doesn't un-learn dst
metadata, it probably leaks buckets, and it may kill your cat.
(I haven't pushed my attempts at mac80211, because I haven't gotten
anywhere useful there just yet.)

> >> As you've noted this is only an RFC so I will not point out every issue, but there seems
> >> to be a major problem with br_fdb_update(), note that it runs without any locks except RCU.
> > 
> > Right, Thanks! ... I only thought about concurrent access, forgetting
> > about concurrent modification...  I'll replace it with an xchg I think.
> > (No need for a lock that way)
> 
> I think you can still lose references to a dst that way, what if someone changes the
> dst you read before the xchg and you xchg it ?

The dst to be released is the return from (atomic) xchg, not the value
read earlier for comparison.  This can happen in parallel, but apart
from a little extra churn in the update case it has no ill effects.

If someone changes it in the meantime, they have new dst information for
the fdb entry, and so do we.  With xchg'ing it, either one of the
updates will stick and the other will be properly released.  Considering
that there is no correct ordering here (either packet could be processed
a nanosecond later or earlier), this is perfectly fine as an outcome.


-David
