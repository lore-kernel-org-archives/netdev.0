From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 09/10] [TCP]: Rewrite SACK block processing &
 sack_recv_cache use
Date: Thu, 15 Nov 2007 20:00:32 -0800 (PST)
Message-ID: <20071115.200032.115040183.davem@davemloft.net>
References: <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757860AbXKPEAd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 23:00:33 -0500
In-Reply-To: <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:33 +0200

> Key points of this patch are:
>=20
>   - In case new SACK information is advance only type, no skb
>     processing below previously discovered highest point is done
>   - Optimize cases below highest point too since there's no need
>     to always go up to highest point (which is very likely still
>     present in that SACK), this is not entirely true though
>     because I'm dropping the fastpath_skb_hint which could
>     previously optimize those cases even better. Whether that's
>     significant, I'm not too sure.
>=20
> Corrently it will provide skipping by walking. Combined with
> RB-tree, all skipping would become fast too regardless of window
> size (can be done incrementally later).
>=20
> Previously a number of cases in TCP SACK processing fails to
> take advantage of costly stored information in sack_recv_cache,
> most importantly, expected events such as cumulative ACK and new
> hole ACKs. Processing on such ACKs result in rather long walks
> building up latencies (which easily gets nasty when window is
> huge). Those latencies are often completely unnecessary
> compared with the amount of _new_ information received, usually
> for cumulative ACK there's no new information at all, yet TCP
> walks whole queue unnecessary potentially taking a number of
> costly cache misses on the way, etc.!
>=20
> Since the inclusion of highest_sack, there's a lot information
> that is very likely redundant (SACK fastpath hint stuff,
> fackets_out, highest_sack), though there's no ultimate guarantee
> that they'll remain the same whole the time (in all unearthly
> scenarios). Take advantage of this knowledge here and drop
> fastpath hint and use direct access to highest SACKed skb as
> a replacement.
>=20
> Effectively "special cased" fastpath is dropped. This change
> adds some complexity to introduce better coveraged "fastpath",
> though the added complexity should make TCP behave more cache
> friendly.
>=20
> The current ACK's SACK blocks are compared against each cached
> block individially and only ranges that are new are then scanned
> by the high constant walk. For other parts of write queue, even
> when in previously known part of the SACK blocks, a faster skip
> function is used (if necessary at all). In addition, whenever
> possible, TCP fast-forwards to highest_sack skb that was made
> available by an earlier patch. In typical case, no other things
> but this fast-forward and mandatory markings after that occur
> making the access pattern quite similar to the former fastpath
> "special case".
>=20
> DSACKs are special case that must always be walked.
>=20
> The local to recv_sack_cache copying could be more intelligent
> w.r.t DSACKs which are likely to be there only once but that
> is left to a separate patch.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I like this patch a lot, and if there are any errors in it
they are in the details not the design, and we have lots of
time to sort that out before the 2.6.25 merge window so
I have applied this.

I have been thinking off an on about the core SACK cost problem.

One thing that keeps occuring to me is that to conquer this fully we
have to change the domain of the problem in our favor.

Basically, even if we have RB-trie and all of these nice fastpaths, we
still can walk the complete queue for a receiver which maliciously
advertises lots of SACK information in one ACK (say covering every
retransmit queue SKB except one) and then nearly no SACK information
in the next one.  Repeating this cycle we can get into excessive usage
of cpu cycles.

Only in situations of severe memory constraints will a receiver
release out-of-order packets and thus remove sequences from previously
advertised SACK blocks (which by RFCs we must handle).  And in such
cases it is OK to resort to timeout based recovery.

This simplifies everything and puts a very strict upper bound of
the amount of processing the most aggressive "bad guy" receiver
can impose upon us.  One full SKB queue scan per window/RTT.

With all of those other weird cases out of the way, there is only
one event to process: SACKS cover more data.

Ilpo what do you think about these ideas?
