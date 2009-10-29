From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 22:52:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0910292235240.14335@melkinkari.cs.Helsinki.FI>
References: <69812160e5682c9fb4acba05bc082664.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-283498188-1256849290=:14335"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39465 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535AbZJ2Uw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 16:52:29 -0400
In-Reply-To: <69812160e5682c9fb4acba05bc082664.squirrel@webmail.uio.no>
Content-ID: <Pine.LNX.4.64.0910292249030.14335@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-283498188-1256849290=:14335
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0910292249031.14335@melkinkari.cs.Helsinki.FI>

On Thu, 29 Oct 2009, apetlund@simula.no wrote:

> > Andreas Petlund a écrit :
> >
> >> The removal of exponential backoff on a general basis has been
> >> investigated and discussed already, for instance here:
> >> http://ccr.sigcomm.org/online/?q=node/416
> >> Such steps are, however considered drastic, and I agree that caution
> must be made to thoroughly investigate the effects of such changes. The
> changes introduced by the proposed patches, however, are not
> default
> >> behaviour, but an option for applications that suffer from the
> >> thin-stream TCP increased retransmission latencies. They will, as such,
> not affect all streams. In addition, the changes will only be active
> for
> >> streams which are perpetually thin or in the early phase of expanding
> their cwnd. Also, experiments performed on congested bottlenecks with
> tail-drop queues show very little (if any at all) effect on goodput for
> the modified scenario compared to a scenario with unmodified TCP
> streams.
> >> Graphs both for latency-results and fairness tests can be found here:
> http://folk.uio.no/apetlund/lktmp/
> >
> > There should be a limit to linear timeouts, to say ... no more than 6
> retransmits
> > (eventually tunable), then switch to exponential backoff. Maybe your
> patch
> > already implement such heuristic ?
> 
> The limitation you suggest to the linear timeouts makes very good sense.
> Our experiments performed on the Internet indicate that it is extremely
> rare that more than 6 retransmissions are needed to recover. It is not
> included in the current patch, so I will include this in the next
> iteration.

I've heard that BSD would use linear for first three and then exponential 
but this is based on some gossip (which could well turn out to be a myth) 
rather than checking it out myself. But if it is true, it certainly hasn't 
been that devastating.

> > True link collapses do happen, it would be good if not all streams
> wakeup
> > in the same
> > second and make recovery very slow.
> >
> 
> Each stream will have its own schedule for wakeup, so such events will
> still be subject to coincidence. The timer granularity of the TCP wakeup
> timer will also influence how many streams will wake at the same time. The
> experiments we have performed on severely congested bottlenecks (link
> above) indicate that the modifications will not create a large negative
> effect. In fact, when goodput is drastically reduced due to severe
> overload, regular TCP and the LT and dupACK modifications seem to perform
> nearly identically. Other scenarios may exist where different effects can
> be observed, and I am open to suggestions for further testing.

Could you point out where exactly where the goodput results? ...I only 
seem to find latency results which is not exactly the same. I don't except
some that is in order of what Nagle talks (32kbps -> 40bps irc) but 10-50% 
goodput reduction over a relatively short period of time (until RTTs top 
RTOs once again preventing spurious RTOs and thus also segment duplication 
due to retransmissions ceases).

Were these results obtained with Linux, and if so what was FRTO set to?

> > Thats too easy to accept possibly dangerous features with the excuse of
> saying
> > "It wont be used very much", because you cannot predict the future.
> 
> I agree that it is no argument to say that it won't be used much; indeed,
> my hope is that it will be used much. However, our experiments indicate no
> negative effects while showing a large improvement on retransmission
> latency for the scenario in question. I therefore think that the option
> for such an improvement should be made available for time-dependent
> thin-stream applications.

Everyone can right away tell that most RTOs are not due to extreme 
congestion, so some linear back off seems sensible when dupACK feedback 
is lacking for some reason. Of course it is a tradeoff as there's that 
chance for getting 1/(n+1) goodput only (where n is the number of linear 
steps) step if RTOs were spurious (and without FRTO even more unnecessary 
retransmission will be triggered so in fact even could be slightly worse 
in theory). But that to happen in the first place requires of course this 
RTT > RTO situation which is hard to see to be a persisting state.


-- 
 i.
---696243445-283498188-1256849290=:14335--
