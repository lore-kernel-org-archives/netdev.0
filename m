From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 09/10] [TCP]: Rewrite SACK block processing &
 sack_recv_cache use
Date: Fri, 16 Nov 2007 15:44:40 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711161306490.29353@kivilampi-30.cs.helsinki.fi>
References: <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071115.200032.115040183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-899914299-1195220680=:29353"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54942 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757351AbXKPNon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 08:44:43 -0500
In-Reply-To: <20071115.200032.115040183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-899914299-1195220680=:29353
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 15 Nov 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 15 Nov 2007 15:37:33 +0200
> 
> > Key points of this patch are:
> > 
> >   - In case new SACK information is advance only type, no skb
> >     processing below previously discovered highest point is done
> >   - Optimize cases below highest point too since there's no need
> >     to always go up to highest point (which is very likely still
> >     present in that SACK), this is not entirely true though
> >     because I'm dropping the fastpath_skb_hint which could
> >     previously optimize those cases even better. Whether that's
> >     significant, I'm not too sure.
> > 
> > Corrently it will provide skipping by walking. Combined with
> > RB-tree, all skipping would become fast too regardless of window
> > size (can be done incrementally later).
> > 
> > Previously a number of cases in TCP SACK processing fails to
> > take advantage of costly stored information in sack_recv_cache,
> > most importantly, expected events such as cumulative ACK and new
> > hole ACKs. Processing on such ACKs result in rather long walks
> > building up latencies (which easily gets nasty when window is
> > huge). Those latencies are often completely unnecessary
> > compared with the amount of _new_ information received, usually
> > for cumulative ACK there's no new information at all, yet TCP
> > walks whole queue unnecessary potentially taking a number of
> > costly cache misses on the way, etc.!
> > 
> > Since the inclusion of highest_sack, there's a lot information
> > that is very likely redundant (SACK fastpath hint stuff,
> > fackets_out, highest_sack), though there's no ultimate guarantee
> > that they'll remain the same whole the time (in all unearthly
> > scenarios). Take advantage of this knowledge here and drop
> > fastpath hint and use direct access to highest SACKed skb as
> > a replacement.
> > 
> > Effectively "special cased" fastpath is dropped. This change
> > adds some complexity to introduce better coveraged "fastpath",
> > though the added complexity should make TCP behave more cache
> > friendly.
> > 
> > The current ACK's SACK blocks are compared against each cached
> > block individially and only ranges that are new are then scanned
> > by the high constant walk. For other parts of write queue, even
> > when in previously known part of the SACK blocks, a faster skip
> > function is used (if necessary at all). In addition, whenever
> > possible, TCP fast-forwards to highest_sack skb that was made
> > available by an earlier patch. In typical case, no other things
> > but this fast-forward and mandatory markings after that occur
> > making the access pattern quite similar to the former fastpath
> > "special case".
> > 
> > DSACKs are special case that must always be walked.
> > 
> > The local to recv_sack_cache copying could be more intelligent
> > w.r.t DSACKs which are likely to be there only once but that
> > is left to a separate patch.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> I like this patch a lot, and if there are any errors in it
> they are in the details not the design, and we have lots of
> time to sort that out before the 2.6.25 merge window so
> I have applied this.
> 
> I have been thinking off an on about the core SACK cost problem.

...Me too.

> One thing that keeps occuring to me is that to conquer this fully we
> have to change the domain of the problem in our favor.
>
> Basically, even if we have RB-trie and all of these nice fastpaths, we
> still can walk the complete queue for a receiver which maliciously
> advertises lots of SACK information in one ACK (say covering every
> retransmit queue SKB except one) and then nearly no SACK information
> in the next one.  Repeating this cycle we can get into excessive usage
> of cpu cycles.

I agree. I made this change not to optimize malicious cases but to
remove sub-optimalities that non-malicious flows experience in
_typical cases_, people are already hit by them in legitimate scenarios.

I think that we cannot prevent malicious guys from inventing ways to 
circumvent the tweak and optimization that may exists for the typical,
legitimate use cases. This patch falls to that category. Currently we
just don't know if removing the recv_sack_cache is going to cost too
much, that is should be kept. It can always be removed separately if
cache misses are not that bad.

...It may well turn out that this change wouldn't have been necessary
with the new approach we're now discussing, however, as long as the old 
code lives, the approach shouldn't hurt either (except the unsurity 
related to the fastpath_skb_hint != tp->highest_sack case).

...It's just that we're on quite unsure grounds when moving to something 
completely new, it's not some funny new protocol which nobody has used 
before, people have high expectations on reliability and how it such 
perform in their favorite, legimitate scenario. :-) Thus it's IMHO also 
about having a safe enough fallback available (without horrible revert 
resolution if there's a need to back off).

> Only in situations of severe memory constraints will a receiver
> release out-of-order packets and thus remove sequences from previously
> advertised SACK blocks (which by RFCs we must handle).  And in such
> cases it is OK to resort to timeout based recovery.

RFCs basically have specified only RTO recovery for that, they don't 
specify nor mention any other method (IIRC). Not that Linux' way is in 
violation of them but it likely rare enough that it may receive the most 
insignicant optimization award. Having that RTO break might actually help 
a legitimate receiver to sort out its problems more than hurt.

Alternatively it could be handled by adding CA_SackReneging state which 
would retransmit also sacked skb but there are tradeoffs in that approach 
too (either may result in suboptimal behavior by rexmitting also not 
discarded segments that are reported by SACK after RTO, or makes code more 
messy by using last ACK's SACK blocks to avoid that). ...It might still be 
useful for removing a need for costly rebuilding of RB-tree or whatever at 
RTO in such case though (for legitimate this is really a corner case and 
malicious can still push sender to that extra work too easily).

> This simplifies everything and puts a very strict upper bound of
> the amount of processing the most aggressive "bad guy" receiver
> can impose upon us.  One full SKB queue scan per window/RTT.

Upper-bound we lack, yeah. But I'd say that's somewhat underestimating
the problem because CA_Recovery is going cost another "scan", unless 
somebody is going to combine that to SACK processing as well (sounds 
scary). Luckily, due to cache effects, it's likely going to be a cheaper 
scan.

> With all of those other weird cases out of the way, there is only
> one event to process: SACKS cover more data.
>
> Ilpo what do you think about these ideas?

Besides the log(n) search for which patches already exists, only O(new 
information) scan start..end range would be necessary. Or had you 
something else in mind (I'm not that sure what the "ideas", in plural,
were :-))? ...I haven't forgotten the RB-tree things either (and I'm
well aware of the limited scope of things this patch addresses).

One idea probably not mentioned earlier: I've thought (ab)using skb's 
end_seq to lazily point to the end of SACK blocks but that's probably 
going to a dead-end because of the laziness.

Couple of things that are still on the way making things not that 
straighforward. DSACKs which are significant for already SACKed if 
EVER_RETRANS bit is not set and for S|R skbs, and lost_retrans loop
is interested in S|R skbs too... Have you thought how to solve them
if the only optimized event would be "SACKS cover more data"?

...Also there's the third problem which may constrain us quite a lot. 
Any additional cache misses to the typical, legitimate, use case might be 
too much wrt. high expectation of the current users. They have just very 
few skb accesses currently (and I made it hopefully even better with
this patch ;-)). Adding log(n) cache misses to that per ACK with SACK, may 
well be significant, though it may be closer to log(outstanding not acked) 
which is considerably smaller on average. Therefore something like I've 
now done in this patch might still be necessary.


...anyway, I'll have to get some work done today as well... :-)

-- 
 i.

---696243703-899914299-1195220680=:29353--
