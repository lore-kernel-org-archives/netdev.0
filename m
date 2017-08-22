From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Tue, 22 Aug 2017 02:29:56 +0200
Message-ID: <20170822002956.GY773745@eidolon>
References: <20170821171523.951260-1-equinox@diac24.net>
 <20170821170151.5b12a392@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, amine.kherbouche@6wind.com,
        roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:39300 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754168AbdHVA37 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 20:29:59 -0400
Content-Disposition: inline
In-Reply-To: <20170821170151.5b12a392@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:01:51PM -0700, Stephen Hemminger wrote:
> On Mon, 21 Aug 2017 19:15:17 +0200 David Lamparter <equinox@diac24.net> wrote:
> > > P.S.: For a little context on the bridge FDB changes - I'm hoping to
> > > find some time to extend this to the MDB to allow aggregating dst
> > > metadata and handing down a list of dst metas on TX.  This isn't
> > > specifically for VPLS but rather to give sufficient information to the
> > > 802.11 stack to allow it to optimize selecting rates (or unicasting)
> > > for multicast traffic by having the multicast subscriber list known.
> > > This is done by major commercial wifi solutions (e.g. google "dynamic
> > > multicast optimization".)  
> > 
> > You can find hacks at this on:
> > https://github.com/eqvinox/vpls-linux-kernel/tree/mdb-hack
> > Please note that the patches in that branch are not at an acceptable
> > quality level, but you can see the semantic relation to 802.11.
> > 
> > I would, however, like to point out that this branch has pseudo-working
> > IGMP/MLD snooping for VPLS, and it'd be 20-ish lines to add it to NVGRE
> > (I'll do that as soon as I get to it, it'll pop up on that branch too.)
> > 
> > This is relevant to the discussion because it's a feature which is
> > non-obvious (to me) on how to do with the VXLAN model of having an
> > entirely separate FDB.  Meanwhile, with this architecture, the proof of
> > concept / hack is coming in at a measly cost of:
> > 8 files changed, 176 insertions(+), 15 deletions(-)
> 
> I know the bridge is an easy target to extend L2 forwarding, but it is not
> the only option. Have you condidered building a new driver

Yes I have;  I dismissed the approach because even though an fdb is
reasonable to duplicate, I did not believe replicating multicast
snooping code into both VPLS and 802.11 (and possibly VXLAN) to be a
viable option.  ...is it?

> (like VXLAN does) which does the forwarding you want. Having all
> features in one driver makes for worse performance, and increased
> complexity.

Can you elaborate?  I agree with that sentence as a general statement,
but a general statement needs to apply to a specific situation.  As
discussed in the previous thread with Nikolay, checking skb->_refdst
against 0 should be doable without touching additional cachelines, so
the performance cost should be rather small.  For complexity - it's
keeping an extra pointer around, which is semantically bound to the
existing net_bridge_fdb_entry->dst.  On the other hand, it spares us
from another copy of a fdb implementation, and two copies of multicast
snooping code...  I honestly believe this patchset is a good approach.


-David
