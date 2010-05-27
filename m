From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 09:14:09 -0700
Message-ID: <AANLkTime8wfTLfdNMAx_HYr6XO0DiO12r5FVdGBjVNwT@mail.gmail.com>
References: <20100526212745.GC24615@basil.fritz.box>
	<20100526.151014.70204145.davem@davemloft.net>
	<20100526231512.GD2684@nuttenaction>
	<20100526.200443.232751390.davem@davemloft.net>
	<20100527070827.GB2728@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:40078 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757598Ab0E0QOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 12:14:15 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o4RGEBYl002201
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 09:14:11 -0700
Received: from pxi18 (pxi18.prod.google.com [10.243.27.18])
	by wpaz13.hot.corp.google.com with ESMTP id o4RGE9Qu018864
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 09:14:10 -0700
Received: by pxi18 with SMTP id 18so102527pxi.5
        for <netdev@vger.kernel.org>; Thu, 27 May 2010 09:14:09 -0700 (PDT)
In-Reply-To: <20100527070827.GB2728@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And this is the most important aspect in this email: core network components
> rely on end hosts to behave in a fair manner. Disable Slow Start/Congestion
> Avoidance and the network will instantly collapse (mmh, net-next? ;-)
>
> The mechanism as proposed in the patch is not fair. There are a lot of
> publications available that analyse the impact CWND in great detail as well as
> several RFC that talk about the CWND.

The mechanism proposed in the patch is merely an API change; misuse,
abuse, or unfairness are inferences of how it might be used.  Proper
safeguards should be applied to prevent misuse, but I don't see that
it should be any more insidious than 350 other mechanisms in the
system that could be used to screw things up.

Yes, there has been a lot of talk about CWND, but the standard has not
changed since 2002.  In the meantime, browsers have increased the
number of parallel connections they open to a destination, and servers
hide behind multiple domains-- the end result of this is that browsers
use aggregate initial congestion windows much larger than the
standard, which sidesteps slowstart and is a source of unfairness.
This is contrary to RFC 3390:

"When web browsers open simultaneous TCP connections to the same
destination, they are working against TCP's congestion control
mechanisms"

I have yet to find any paper on CWND that analyzed the effect of this
phenomena on the Internet which is quite unfortunate.  In our own full
scale experiments
(http://code.google.com/speed/articles/tcp_initcwnd_paper.pdf), we
anlayzed the effects of using larger initial congestion windows on the
Internet which might be the closest thing to such an analysis.  I know
in LEDBAT WG of IETF they are trying to come up with new
recommendations for number of connections a browser can open, this is
good but I hope it's not after the fact.

It would be better, by almost any perspective, to rein in the number
of connections servers are allowing clients to open.  However this
isn't going to happen if this means increase latency for end users,
there's is no competitive rationale for servers to do that.  That's
where a primary motivation of this patch becomes evident.  Instead of
a server allowing 6 connections from a client, for instance, it could
allow just one connection but with a initial congestion window equal
to the aggregate of the 6 connections.  This reduces connections and
does not change the size of initial data burst going into the
Internet.  The Internet is happy because there a fewer connections
(better for fairness) and fewer packets (fewer 3WHS); the server and
client are happy because there are fewer connections to deal without
and no increased latency.

Tom
