From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Mon, 5 Dec 2011 13:42:44 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1112051221510.31705@wel-95.cs.helsinki.fi>
References: <1322684749.2602.3.camel@edumazet-laptop>  <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>  <1322773594.2750.28.camel@edumazet-laptop>  <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
 <1322776643.2750.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-153778889-1323081433=:31705"
Cc: Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>, Jim Gettys <jg@freedesktop.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57595 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082Ab1LELmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 06:42:46 -0500
In-Reply-To: <1322776643.2750.45.camel@edumazet-laptop>
Content-ID: <alpine.DEB.2.00.1112051331560.31705@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-153778889-1323081433=:31705
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1112051237581.31705@wel-95.cs.helsinki.fi>

On Thu, 1 Dec 2011, Eric Dumazet wrote:
> Le jeudi 01 décembre 2011 à 22:35 +0100, Dave Taht a écrit :
> > On Thu, Dec 1, 2011 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Le mercredi 30 novembre 2011 à 14:36 -0800, Stephen Hemminger a écrit :
> > >
> > >> (Almost) nobody uses RED because they can't figure it out.
> > >> According to Wikipedia, VJ says that:
> > >>  "there are not one, but two bugs in classic RED."
> > 
> > Heh. "There were not two, but four bugs in Linux red".
> > 
> > Now reduced to 2. :)
> 
> This story about VJ and bugs in classic RED is urban legend if you ask
> me :)

I think at least one bug he claims to find in "the" manuscript is not a 
bug at all :-). Essentially he assumes that once instantaneous queue is 
zero, the load is zero, which is not true (e.g., during any typical slow 
start while the link is still not saturated).

> > RED is useful for high throughput routers, I doubt many linux machines
> > > act as such devices.
> > 
> > "High throughput" at the time red was designed was not much faster
> > than a T1 line.
> > 
> > RED appears to be used by default in both gargoyle's and openwrt's QoS systems,
> > underneath unholy combinations of HTB, HSFC, and SFQ
> > so it's more widely used than you might think. Not that works well.
> > 
> > RED doesn't work worth beans on variable bandwidth links (cable
> > modems/wireless).
> 
> Adaptative RED is the answer

I disagree. Slowly responding adaptation is not going to do much good if 
put together with variable something.

And besides, Adaptive RED is as hard if not even harder to configure than 
the standard RED. That is, it has one key parameter and absolutely no info 
is given how that should be configured?!? :-)

> > Once you are simulating a fixed rate link (e.g with HTB), then it sort of
> > kinda maybe can apply.
> > 
> > RED was also designed at a time when long distance traffic was fixed rate
> > and bidirectional, so the 'average packet' parameter made sense.
> > Modern day traffic is far more asymmetric.
> > 
> 
> The truth is : For RED be effective (with say 20 to 100 flows), you need
> a reasonable amount of packets in queue, and low wq (high burst value in
> linux), depending on the RTT. And on consumer links (ADSL, cable
> modem ...), RTT is quite big.

To be more exact, it's BDP (BW-delay product) which matters, not the RTT 
alone.

> RED performance is best when the average queue size is estimated over a
> small _multiple_ of round-trip times, not over a fraction of a single
> round-trip time.

I disagree. If there's any slow starting flow that alone can fill the 
bottleneck, anything significantly larger than RTT just harms. RED is 
just "too slow" if you follow the recommended parametrization..

In a core router you can probably get away with multiple RTTs, but near 
edge that is a grave mistake due to how slow-start behaves. With average 
based on many RTTs, RED still estimates that the link has low load while 
congestion has escalated to higher dimensions due to slow start. As a 
result, RED graciously falls back to tail-drop once the physical queue 
runs out and the flows respond allowing the load to decrease. However, 
finally RED reaches a state where it starts to "pro-actively" react to an 
"incipient congestion"?!? :-/ => Problem is made worse by those extra 
drops/marks happening too late.

...And the obvious looking solution by making physical buffer size 
larger brings in even worse problems. There's simply no other way around 
this than making wq larger instead of smaller in order to arrest the slow 
start in time. (We have a paper to appear about these in AINA 2012.)

I know this is pretty much against the mantra repeated about RED. And I'm 
not too surprised why so many have found out that RED does not help.

> In this respect, your RED setups are pathological (minimum burst value,
> meaning wq = 0.5 or so), so in a small fraction of RTT, avgqsz value is
> completely changed, so flows have no chance to be able to react
> smoothly.

Here I agree, 0.5 is probably too much though... only if BDP is very small 
this is useful but then RED is probably having other problems due to 
granularities affecting its measurement accuracy.


-- 
 i.
--8323329-153778889-1323081433=:31705--
