From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Mon, 16 Dec 2013 20:30:41 +0100
Message-ID: <20131216193041.GA16966@cpaasch-mac>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
 <1387132859.19078.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAK6E8=eeH=6daXoX9Dwe3Nj5LEhKBfL=-2FaLd=Jo7WM-q34qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59224 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231Ab3LPTih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:38:37 -0500
Content-Disposition: inline
In-Reply-To: <CAK6E8=eeH=6daXoX9Dwe3Nj5LEhKBfL=-2FaLd=Jo7WM-q34qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/13 - 10:45:13, Yuchung Cheng wrote:
> On Sun, Dec 15, 2013 at 10:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2013-12-15 at 13:10 +0100, Christoph Paasch wrote:
> >> Currently tcp-metrics only stores per-destination addresses. This brings
> >> problems, when a host has multiple interfaces (e.g., a smartphone having
> >> WiFi/3G):
> >>
> >> For example, a host contacting a server over WiFi will store the tcp-metrics
> >> per destination IP. If then the host contacts the same server over 3G, the
> >> same tcp-metrics will be used, although the path-characteristics are completly
> >> different (e.g., the ssthresh is probably not the same).
> >
> > ssthresh caching is very problematic anyway.
> >
> > hystart is way better to probe the actual capacity, as the real network
> > conditions change every seconds or so.
> >
> >>
> >> The same holds for the fast-open cookie. The server will generate a cookie
> >> based on our source-address. So, if we contact the same server with another
> >> source-IP we should request a new cookie.
> >
> > Yuchung, what do you think ? I think this should already be handled
> > gracefully, as client be behind a NAT device using a pool of external IP
> > addresses ?
> Right. Today the Fast Open attempt will fall back to regular TCP
> gracefully with the new cookie in SYN-ACK. So if the source ip changed
> when the public IP/nat remain the same (common case?), the proposed
> change will reduce Fast Open success rate. So it likely has negative
> impact only.

Agreed, in this case it would be negative. Although I doubt that it happens
often that the source changes while the public IP remains the same.

But for the WiFi/3G-case it is really bad that parameters like
ssthresh/rtt/... are kept the same. We will exit slow-start too early when
going from WiFi to 3G because ssthresh is too low.

What if we copy the fast-open cookie across the different src/dst tcp_metrics-pairs
to handle Yuchung's case?
Or, maybe get rid of ssthresh/rtt/... in tcp-metrics? But that would probably be too
agressive...


Cheers,
Christoph
