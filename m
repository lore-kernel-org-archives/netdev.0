From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Thu, 7 Aug 2008 14:33:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807310939.42406.thomas.jarosch@intra2net.com>
 <20080731094436.12ec99ae@tux> <200807311547.57189.thomas.jarosch@intra2net.com>
 <20080806155306.72039010@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-440937060-1218108827=:4551"
Cc: Netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080806155306.72039010@tux>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-440937060-1218108827=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 6 Aug 2008, Dâniel Fraga wrote:

> On Thu, 31 Jul 2008 15:47:55 +0200
> Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> 
> > If your problem is really FRTO related (that what the patch is for),
> > you could try to disable FRTO temporarily:
> 
> 	Hi, the patch helped, but what's the conclusion? Is the problem
> "solved"? Will this patch be merged in the next kernel? This thread
> seems to be forgotten.

...Dave, I think we should probably put this FRTO work-around to net-2.6 
and -stable to remain somewhat robust (it's currently worked around only 
for newreno anyway). ...But I leave the final decision up to you.


-- 
 i.

[PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround

Hmm, it wasn't non-dup ACKing receiver, there were dupACKs when
an unnecessary retransmission was made (though those ACKs revoke
a part of the advertized window, which is strange enough in
itself :-)).

2nd try:

This is probably due to some broken middlebox but that's purely
speculation since the details of the not named ISP's (you can
find some hint in Patrick's blog though ;-)) equipment are not
available to us.

It seems that we will have to consciously attempt to violate
packet conservation principle and do a spammy go-back-n in case
there's a middlebox using split TCPish approach by waiting an
arrival of TCP layer retransmission and then doing an in-order
delivery (basically violates end-to-end semantics of a TCP
connection). I.e., the proxy intentionally reorders segment by
_any_ amount (well, there's some upper limit based on the
advertized window I guess), it's ridiculously fragile approach...

Such middleboxes basically mean two things: First, any measured
RTT value when a loss occurred is entirely bogus, yet all
indication of the existance of that loss is hidden intentionally,
so the correct operation basically depends on ambiguity problem
and the inability to measure RTTs during it. Secondly, a timely
feedback from network is non-existing, ie., no fast recovery &
friends... This goodbye for RFC2581 clearly signifies that such
way of behavior is contradicting some very fundamental
assumptions a standard TCP is allowed to make about the network,
would the RFC2581 stuff work, also FRTO would work. ...Finally
I see something which resembles something as pre-historic as TCP
Tahoe (I mean in the real world) :-).

FRTO assumes reordering is relatively rare thing, but this
middlebox has decided to _always_ reorder the key segments FRTO
depends on... Thus FRTO makes "wrong" decision and declares the
RTO spurious, which is not in fact wrong at all because the
receiver probably received the segments in that order (or at
least its TCP layer did) and clearly indicates it by the
cumulative ACK pattern. A cumulative ACK for a not retransmitted
range basically means that one of those segments just arrived
when an ACK got sent, in this case it's after ridiculous RTT,
even 50 seconds were measured in practice!! As a result,
tp->rttvar flies to outer space when exponentially increasing
RTTs get sampled. But this increase is much desired, in general,
to avoid future RTOs would the real RTT really grow that fast.
It just leads to a disaster here because the RTT measurements
are sender driven.

The workaround prevents reentry to FRTO when a previous FRTO
recovery occurred within the last window (though multiple RTOs
for a single segment are still allowed to go into FRTO each
time). This workaround impacts FRTO accuracy as we lose ability
to detect more than one spurious segment per window. We just
consciously violate packet conservation principle by
retransmitting unnecessarily to make rest of the high RTT
readings ambiguous and that's it... :-) Though even go-back-N
as fallback this won't guarantee anything if we're just unlucky
because RTTs we measure can still grow if losses occur too
frequently so that period in between is not enough to lower RTT
estimation :-). In contrast, non-FRTO TCP can always happily
ignore high RTT readings because of the ambiguity problem, ie.,
by violating packet conservation principle by design :-).

I currently implemented the workaround for newreno only though
SACK TCP could be subject to similar middlebox but lets hope that
there won't be that many of middleboxes that allow negotiating
SACK through them while forcing SACK blocks to extinction.

I find this workaround quite controversial, it seems that without
FRTO (at all), amusing 6.8% of the transmitted segments were
unnecessarily retransmitted, which do cause buffer overflow that
often leads to another RTO (in ~50% of cases), which is sort of
expected when packet conservation principle gets violated like
here. With FRTO, even if its final decision (ie., RTO=spurious)
here is probably "flawed" because of the carefully selected
reordering, _all_ unnecessary retransmissions are avoided (those
duplicate ACKs that indicated old segment arrivals vanished) and
with the default response the congestion window gets shrunk anyway
so it's not more aggressive than what non-FRTO TCP would be. Sadly
enough the RTT times will grow making FRTO approach unbearable
without some changes. Still, that kind of middleboxes do no good
for any TCP flow and should be fixed.

A better workaround would have to consider two things to keep
performance on a semi-acceptable level: prevent exponential RTT
back-off while avoiding over-aggressive cwnd calculation. The latter
seems easy to deal with because either the RTO is genuine spurious
RTO within the original window or there's this crazy middlebox which
only received the retransmission while the original got lost, both
events fall to the same RTT where cwnd was already reduced and
therefore it is possible to show that there's no further need for
congestion window reduction. But the RTT back-off prevention would
be more controversial because as said before, it is a desirable
property in case of a genuine spurious RTO. However, it might be
possible to argue that this situation where two spurious RTOs hit
the same window won't occur that often in practice (for different
segments, we already adjusted the RTO value anyway on the first of
them). ...I leave that into future consideration.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Tested-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Tested-by: Dâniel Fraga <fragabr@gmail.com>
---
 net/ipv4/tcp_input.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 67ccce2..e137578 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1721,6 +1721,13 @@ int tcp_use_frto(struct sock *sk)
 	if (tcp_is_sackfrto(tp))
 		return 1;
 
+	/* in-order-only "TCP proxy" fragility workaround, spam by go-back-n,
+	 * ie., consciously attempt to violate packet conservation principle
+	 * to cover every loss in the outstanding window on a single RTT
+	 */
+	if (tp->frto_counter != 1 && tp->frto_highmark)
+		return 0;
+
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
 		return 0;
-- 
1.5.2.2

---696208474-440937060-1218108827=:4551--
