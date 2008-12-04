From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 22:08:52 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812042125510.27758@wrl-59.cs.helsinki.fi>
References: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
 <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
 <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
 <20081204185022.6108d19e@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1400270891-1228418773=:27758"
Cc: Saverio Mascolo <saverio.mascolo@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Luca De Cicco <ldecicco@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34224 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbYLDUIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:08:54 -0500
In-Reply-To: <20081204185022.6108d19e@gmail.com>
Content-ID: <Pine.LNX.4.64.0812042207170.27758@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1400270891-1228418773=:27758
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0812042126221.27758@wrl-59.cs.helsinki.fi>

On Thu, 4 Dec 2008, Luca De Cicco wrote:

> Dear Ilpo,
> 
> please find my reply in line.
> 
> On Thu, 4 Dec 2008 14:41:05 +0200 (EET)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > On Wed, 3 Dec 2008, Saverio Mascolo wrote:
> > 
> > > we have added plots of cwnd at
> > > 
> > > http://c3lab.poliba.it/index.php/TCP_over_Hsdpa
> > > 
> > > in the case of newreno, wetwood+, bic/cubic.
> > 
> > You lack the most important detail, ie., the used kernel versions!
> > And also information if some sysctls were tuned or not. This is
> > especially important since you seem to claim that bic is the default
> > which it hasn't been for years?!
> > 
> 
> Thank you for pointing out, we employed the kernel 2.6.24 with web100
> patch in order to log the internal variables.

Thanks, this gives much more informative context to the results.

> You are right, cubic is the default, that was simply a cut & paste error.

Ok.

> For what concerns the sysctls, they are set all to the default values,
> with the only exception of tcp_no_metrics_save that is turned on in
> order not to save metrics (such as ssthresh) as specified in [1].
> The other sysctls were left as default in order to assess the
> performance of the algorithms as a normal user would do.

Did you know that 2.6.24 has broken frto fallback to conventional 
recovery? And frto is enabled by default... ...Once that bug was found the 
stable-2.6.24 was already obsolete (and therefore not updated by the 
stable team so it never got fixed). That bug will affect behavior after 
each rto quite a lot (basically it will invalidate all 2.6.24 results if 
any rto occurred during a test)! The fix is included from 2.6.25.7 and 
2.6.26 onward.

Yes, we know that ubuntu hardy cared a very little to fix that but asked 
users to do pointless bisects again and again, I think they never got 
around to fix it for real until upstream did that for them in intrepid so 
in a sense it's what many people would run but I don't find that too good 
reason to do decision about future (which includes the fix).

> > > basically the goodput is similar with all variants  but with
> > > significantly larger packet losses and timeouts with bic/cubic.
> > 
> > I've never understood what exactly is wrong with the larger amount of 
> > packet losses if they happen before (or at the bottleneck), here
> > they're just a consequence of having the larger window.
> 
> Saverio already replied to this objection. I would like to add a
> further consideration. The aggressive probing phase has also the
> negative effect of causing inflated values of RTT due to the excessive
> queuing (see the RTT time evolution in the Cwnd/RTT figures).

Obviously cwnd and rtt have strong correlation if any queuing happens.
In order to satisfy the needs with other paths (large bdp), there's this 
aggressiviness tradeoff which one makes, yes, the consequence is that 
window will be bigger and will hit more losses when they happen but those 
retransmission won't be unnecessary and therefore only waste spare 
resources on non-bottleneck links, the utilization of the bottleneck is 
kept full as long as the queue was long enough.

> > > i am pretty sure that this would happen with any algos -including
> > > h-tcp- that makes the probing more aggressive leaving the van
> > > jacobson linear phase.
> > 
> > Probably, but you seem to completely lack the analysis to find out
> > why the rtos did actually happen, whether it was due to most of the
> > window lost or perhaps spurious rtos?
> 
> Why are you suggesting spurious rtos? To my uderstanding the spurious
> rto should be mostly  due to the link layer retransmissions that
> are orthogonal to the congestion control algorithm employed.
> Let's say the average number of spurious timeouts is X, independent
> from the algo, the remaining number of timeouts should be caused by
> congestion, that IMHO is what differentiates the couple
> NewReno/Westwood+ from the Bic/Cubic one.

Dynamics of tcp are quite hard to figure out. ...I heard a wise saying 
yesterday (though in a bit different context) that it's not very wise, as 
a scientist, to be guessing things.

And you seem to totally ignore the nature of those wireless links. I 
haven't had time to check how a real-world queue of the hsdpa behaves but 
what I know of from umts I say that it's so complex dynamic setup that 
your simple assumptions here are totally irrelevant in reality. And I 
doubt that hsdpa differs that much from umts behavior, though ymmv a bit
depending on which operator, manufacturer, etc. devices are in question.

Anyway, now that I heard that it's broken frto many things might just 
vanish away if the fixed kernel would be used.

> However the high number of timeouts caused by Bic (and other TCP
> variants) has been already observed in [2] in a different scenario.
>
> [2] Saverio Mascolo, Francesco Vacirca, The effect of reverse traffic
> on TCP congestion control algorithms Protocols for Fast Long-distance
> Networks, Nara, Japan, Feb. 2006 

I'll take look into that later. ...I hope it tells which kernel version 
was in use.


-- 
 i.
---696208474-1400270891-1228418773=:27758--
