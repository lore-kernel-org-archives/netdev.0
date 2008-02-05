From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 21:50:23 +0100
Message-ID: <20080205205023.GA26746@1wt.eu>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <20080205154213.059ac6e8@core> <20080205163912.GB23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1737 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759700AbYBEVhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 16:37:20 -0500
Content-Disposition: inline
In-Reply-To: <20080205163912.GB23145@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi, Alan,

I've run extensive tests with/without syn cookies recently.

On Tue, Feb 05, 2008 at 05:39:12PM +0100, Andi Kleen wrote:
> On Tue, Feb 05, 2008 at 03:42:13PM +0000, Alan Cox wrote:
> > > Syncookies are discouraged these days. They disable too many 
> > > valuable TCP features (window scaling, SACK) and even without them 
> > > the kernel is usually strong enough to defend against syn floods
> > > and systems have much more memory than they used to be.
> > 
> > Somewhat untrue. Network speeds have risen dramatically, the number of
> 
> With strong I meant Linux has much better algorithms to handle the standard
> syn queue (syncookies was originally added when it had only dumb head drop) 
> and there are minisocks which also require significantly less overhead
> to manage than full sockets (less memory etc.) 

That's true, but not enough, see below.

> When I wrote syncookies originally that all was not true.
> 
> > appliances running Linux that are not PC class means memory has fallen
> > not risen and CPU has been pretty level.
> > 
> > > So I don't think it makes much sense to add more code to it, sorry.
> > 
> > I think it makes a lot of sense 
> 
> I have my doubts. It would be probably better to recheck everything
> and then remove syncookies.
> 
> Also your sub PC class appliances rarely run LISTEN servers anyways
> that are open to the world.

In my tests, I discovered that in fact SYN cookies more benefit high
end machines than low-end ones. Let me explain.

I noticed that computing the cookie consumes a lot of CPU, which is a
real problem on low-end machines. But on the other end, it helps the
system continue to respond when otherwise it would not. My tests on
an AMD LX800 with max_syn_backlog at 63000 on an HTTP reverse proxy
consisted in injecting 250 hits/s of legitimate traffic with 8000 SYN/s
of noise.

Without SYN cookies, the average response time was about 1.5 second and
unstable (due to retransmits), and the CPU was set to 60%. With SYN
cookies enabled, the response time dropped to 12-15ms only, but CPU
usage jumped to 70%. The difference appears at a higher legitimate
traffic rate. At 500 hits/s + 7800 SYN/s, the CPU is just saturated
with correct response time (SYN backlog almost full but never full),
and the performance slightly goes down with SYN cookies enabled, inducing
a drop of the hit rate due to the increased CPU consumption.

Till there, one would conclude that SYN cookies are bad. BUT! this was
with tcp_synack_retries = 1, which is the optimal situation without
SYN cookies under an attack and which is pretty bad for normal usage.

The real problem without SYN cookies is that you are forced to support
a huge SYN backlog (eg: 2 million entries to sustain 100 Mbps of SYN).
And what happens with a large backlog ? You send a lot of retries for
each SYN. 5 by default, meaning 6 SYN-ACKs for 1 SYN. Thus, you become
a SYN amplifier and the guy in front of you just has to send you 20 Mbps
of traffic for you to saturate your 100 Mbps uplink.

Also, sending all those SYN-ACKs takes a huge amount of CPU time. With
tcp_synack_retries at 0, my machine received 26600 SYN/s, and returned
26600 SYN-ACK/s at 100% CPU. With tcp_synack_retries set to 4, it could
only accept 12900 SYN/s, replying with 51200 SYN-ACK/s. So the input
load was halfed and the output was doubled. I did not bother going higher.

The only solution against this is then to reduce tcp_synack_retries to
very low values (0 ideally, to match SYN cookies behaviour), but in this
case, you degrade normal traffic 100% of the time, while SYN cookies would
only trigger while you're already under attack.

My conclusions after those tests was to set tcp_synack_retries to a reasonable
value (1 to 3), and set the backlog to the number of half-open sessions your
machine can accumulate under a SYN attack without collapsing. You then enable
SYN cookies, and they will only trigger when you know that your machine will
not be able to sustain the increased load.

This solution permits you to accept normal connections when not under attack,
with an acceptable number of retransmits and with TCP options working well.
Under a moderate attack, the large backlog will still help you accept
legitimate connections with all comfort (sack, wscale, ...). Under a massive
attack, you will not send more than tcp_synack_retries*backlog packets per
tcp_synack_retries period, thus limiting the outbound traffic, plus 1 SYN-ACK
per incoming SYN, legitimate or not. At this stage, if your users have a
castrated TCP stack in front of them, that's not a problem because you know
that otherwise they would not even have been able to connect.

So in this regard, SYN cookies are really needed.

Last, I've read on DJB's page that SYN cookies do not break TCP beahaviour.
Yes they do. If the client waits for the server to talk first, you'd better
not lose the first ACK from the client because it will not get retransmitted,
and the client will see an ESTABLISHED connection while the server will have
nothing. Fortunately, most attack targets are HTTP and do not have this
problem.

For this reason, I think that SYN cookies should be activable by port or
simply by a setsockopt() from the application itself. Having them enabled
by default on the whole system with small backlogs is bad, having large
backlogs to cover attacks is bad, but having medium backlogs with SYN
cookies per application would be very useful.

Best regards,
Willy

