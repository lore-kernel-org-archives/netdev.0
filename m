From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 25 Jul 2008 13:00:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807231821170.13775@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807181114.53059.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807181617550.24938@wrl-59.cs.helsinki.fi>
 <200807181602.42338.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-288504146-1216829068=:13775"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59212 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbYGYKAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:00:33 -0400
In-Reply-To: <200807181602.42338.thomas.jarosch@intra2net.com>
Content-ID: <Pine.LNX.4.64.0807251230300.11302@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-288504146-1216829068=:13775
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0807231908051.13775@wrl-59.cs.helsinki.fi>

On Fri, 18 Jul 2008, Thomas Jarosch wrote:

> On Friday, 18. July 2008 15:55:22 Ilpo Järvinen wrote:
> > Btw, on which kernel you ran these things (I hope it wasn't 2.6.24.7,
> > which has FRTO related bugs anyway that the patches I've sent now won't
> > fix)?
> 
> It's the git "master" tree from two days ago, so it should be 2.6.27-pre.
> Like I wrote before, there's another box doing NAT in front of it running 
> 2.6.24.7. FRTO is disabled on that box. Hope that helps a bit.

Ok.

I looked more into it, there indeed is a large number of spurious RTOs 
with extremely large round-trip times, though I suspect they occur due to 
some broken hw/cfg or whatever rather than due to a real wire+queueing 
delays, and that some external event is required to get things going again 
with it/them... but that's purely speculation since we don't know about 
the isp's stuff... :-)

Here are some example time-seqno graphs, the second was includes the first 
one in the lower left corner:

http://www.cs.helsinki.fi/u/ijjarvin/tcp/bigrto1.jpg
http://www.cs.helsinki.fi/u/ijjarvin/tcp/bigrto2.jpg

Larger boxes - data packets
Smaller boxes - ACKs (& receiver's advertized window)
...both are connected with lines in time order for easier tracking

RTOs occur when the data transfer line falls down, if there is more than 
one cumulative (advancing ACK) with FRTO sending pattern (ie., when there 
are two new datas following the retransmission) following the 
retransmission, it basically means that the original data segments made it 
through, and in the extreme cases it was sent much earlier!!! The longest 
round-trips are around 50 seconds in there. These increasing RTT 
measurements cause tp->rttvar to grow exponentially per each spurious RTO, 
which is very good to avoid spurious RTOs in future but obviously breaks 
down if future progress is also bound to actually triggering those RTOs

...I bet we could measure any desired value for RTT with those servers... 
except there's the application level timeout on the way... :-)

Could you try if the patch below helps any...

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
Tahoe (in the real world) :-).

FRTO assumes reordering is relatively rare thing, but this
middlebox has decided to _always_ reorder the key segments FRTO
depends on... Thus FRTO makes "wrong" decision and declares the
RTO spurious, which is not in fact wrong at all because the
receiver probably received the segments in that order (or at
least its TCP layer did) and clearly indicates it by the
cumulative ACK pattern. A cumulative ACK for a not retransmitted
range basically means that one of those segments just arrived,
in this case it's after ridiculous RTT, even 50 seconds were
measured in practice!! As a result, tp->rttvar flies to outer
space when exponentially increasing RTTs get sampled. But this
increase is much desired, in general, to avoid future RTOs would
the real RTT really grow that fast.

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
frequently so that period in between is not enough to lower
RTT estimation :-). In contrast, non-FRTO TCP can always happily
ignore high RTT readings because of the ambiguity problem, ie.,
by violating packet conservation principle by design :-).

I'm not that sure if this is worthwhile modification to the
kernel due to the reasons that are explained above.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 net/ipv4/tcp_input.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1f5e604..2a7528c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1721,6 +1721,13 @@ int tcp_use_frto(struct sock *sk)
 	if (tcp_is_sackfrto(tp))
 		return 1;
 
+	/* in-order-only "TCP proxy" fragility workaround, spam by go-back-n,
+	 * ie., consciously attempt to violate packet conservation principle
+	 * to cover every loss in the outstanding window on a single RTT
+	 */
+	if (!tp->frto_counter && tp->frto_highmark)
+		return 0;
+
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
 		return 0;
-- 
1.5.2.2

---696208474-288504146-1216829068=:13775--
