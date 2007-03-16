From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCHv5 0/5] LOST marking rewrite
Date: Fri, 16 Mar 2007 20:41:01 +0200
Message-ID: <11740704663475-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48892 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589AbXCPSlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 14:41:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's strange how I always manage to find couple of problems quite soon
after I've sent things to public... :-) Once again two important fixes
to v4.

This patchset provides new LOST detection algorithm. This is part
of tcp_sock diet program. Removes couple of hints, sadly enough this
is a tradeoff as one u32 is necessary for the new algorithm even though
most of the time the last SACK would give all necessary information.

It might be useful to add unlikely to the rexmit hint clearing since it
really shouldn't happen except very very rarely if ever. And maybe also
the !tp->sacked_out.

I think I have introduced a small problem to the timedout thingie,
however, we can work around that by faking highest_sack to a higher
value if timed out loop advances too far to avoid (potentially expensive)
walking... So that it would be highest_sacked_or_lost (or highest_marked,
whatever).

Testing of v5 underway (I'll have full results after couple of hours but
the part I checked already was correct, more trustworthy testing this
time as CBI was not interfering my testset).


    v4-to-v5 changes:
     - Fixed entry_seq when last (and updated) SACK block is less than
       tp->reordering * MSS (previously worked only by a change and
       CBI hid troubles)
     - Delayed holes_seen pre-increment to avoid exiting marker too early
     - Silenced compiler warning RFC3517 fast_rexmit thingie introduces

    v3-to-v4 changes:
     - Fixed FACK off-by-one error that was introduced in v3 change
     - Provided RFC3517 SACK as a separate patch
     - Added "a fastpath" optimization
     - Restructured the algorithm to get it cleaner
     - Decided that there isn't a clear way to handle R without L frames
       timedout thingie above the reord marking (the old code is quite
       impossible to follow anyway as does not have any reliable invariants
       because the timestamps change when -> R transition occurs). Besides,
       such case is probably too marginal one to do something expensive.
       Depending on the hint state, the results could be vastly different
       in the old algo. Thus I did go for a straight forward way: if we have
       a timed out skb, the remaining will also timeout (this could also be
       seen as ok defination since R without L should be made R|L at some
       point!). It could be possible to have some invariants for this if
       there is cheap way to access the skb right after the last rexmit skb
       (I have intentionally avoided hint usage since we're hopefully going
       to farewell them).
     - Handle !sacked_out case correctly
     - Guarantee highest_sack in sync only when sacked_out > 0
     - Rebased to a recent net-2.6.22 (couple of space changes hit the
       removed area & RB-tree fixes were done)
    
    v2-to-v3 changes:
     - Replace of skipping made worries in it obsolete and now really
       one skb less is traversed (was promised in v2)
    
    v1-to-v2 changes:
     - Changes non-fack SACK to something less broken; not a complete
       set of changes (other functions should also be fixed)
     - Fixed NewReno bugs
     - More comments & added RFCs to places I'm unsure of
     - Delayed reord_count increment (traverses now one skb less)
     - Copied retransmit_hint clearing from the original but I
       think it's superfluous
     - Separated highest_sack to own patch
     - Fixed off-by-one bug in skipping



