From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 25 Jul 2008 17:06:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807251613230.11302@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807181602.42338.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807231821170.13775@wrl-59.cs.helsinki.fi>
 <200807251500.05527.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1961608114-1216994764=:11302"
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
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50655 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYGYOGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 10:06:09 -0400
In-Reply-To: <200807251500.05527.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1961608114-1216994764=:11302
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 25 Jul 2008, Thomas Jarosch wrote:

> On Friday, 25. July 2008 12:00:29 Ilpo Järvinen wrote:
> > [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
> 
> The latest patch works quite good. I accidentally had your
> previous patch applied, too, which gave even better results.
> Though I don't know enough about the gory details of FRTO
> if this effectivly disables it...

Indeed, it seems that with the earlier patch (or at least part of it)
one can achieve even better performance, though limiting sending window 
would probably be the most efficient way to communicate through the 
middlebox to avoid capacity waste that is going on whole the time due
to it.

This patch alone could occassionally leave TCP hanging until a new RTO 
occurs when it has already gotten the first ACK after RTO (but the second 
is not coming until we kick the middlebox again by retransmitting the 
missing segment). But other than that, it worked as expected and solved 
many of the situations...

I guess the patch below would be enough in itself to create the desired 
effect (though "desired" is hardly a negative enough word to describe a 
workaround of this kind). Currently the workaround is only for SACKless 
TCP, though I guess there could be some "engineers" around who could 
without a doubt design a system which allows negotiating SACK, yet, doing 
all delivery in-order... :-) I think SACKless is enough though this same 
problem could occur with SACK too but that's not as likely as without 
SACK.

Funny, the violation of packet conservation principle leads to another 
queue overflow (as often expected) in more than half of the cases and 
therefore another RTO is needed... :-)

There is a new things in the logs too (I didn't study all details of the 
earlier ones so I might have missed them in there), probably signs about 
link-layer retransmissions... and that "notch" in advertized window is 
hilarious... :-)

Some statistics; unnecessary retransmissions (%, n), packets, filename:

0.0000   0 3026 stalling2
0.0000   0  698 stalling1
2.2693 137 6037 smtp_slooow
3.4316 221 6440 smtp_sixteen_minutes
4.3833 284 6479 smtp_worked_but_stalling_here_and_there
4.8030  50 1041 smtp_stalled
5.2868 340 6431 smtp_highmark_and_TCP_CA_Loss
6.0382 392 6492 smtp_highmark_only
6.8752 435 6327 working_no_frto

Ie., in the worst case 6.8% of your link's capacity was wasted during the 
transfer due to inefficiency cause by that middlebox, not counting the 
under-utilization that occurs both because of a small window or a wait for 
RTOs, not bad result at all... :-D

Try the patch below (alone) which should be close to the behavior of the 
both patches put together.

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
index 75efd24..314bd55 100644
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

---696208474-1961608114-1216994764=:11302--
