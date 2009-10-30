From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Fri, 30 Oct 2009 10:33:22 -0700
Message-ID: <4AEB2362.5060601@hp.com>
References: <6980f83370cc081eb82dc2e0bd65bcf4.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: apetlund@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:8521 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932698AbZJ3RdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 13:33:21 -0400
In-Reply-To: <6980f83370cc081eb82dc2e0bd65bcf4.squirrel@webmail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

apetlund@simula.no wrote:
>> Just how thin can a thin stream be when a thin stream is found thin? (to 
>> the cadence of "How much wood could a woodchuck chuck if a woodchuck could 
>> chuck wood?")

>> Does a stream get so thin that a user's send could not be split into four,
>>  sub-MSS TCP segments?
> 
> 
> That was a nifty idea: Anti-Nagle the segments to be able to trigger fast
> retransmissions. I think it is possible.
> 
> Besides using more resources on each send, this scheme will introduce the
> need to delay parts of the segment, which is undesirable for
> time-dependent applications (the intended target of the mechanisms).
> 
> I think it would be fun to implement and play around with such a mechanism
> to see the effects.

Indeed, it does feel a bit "anti-nagle" but at the same time, these thin streams 
are supposed to be quite rare right?  I mean we have survived 20 odd years of 
congestion control and fast retransmission without it being a big issue.

They are also supposed to not have terribly high bandwidth requirements yes? 
Suppose that instead of an explicit "I promise to be thin" setsockopt(), they 
instead set a Very Small (tm) in today's thinking socket buffer size and the 
stack then picks the MSS to be no more than 1/4 that size?  Or for that matter, 
assuming the permissions are acceptable, the thin application makes a 
setsockopt(TCP_MAXSEG) call such that the actual MSS is small enough to allow 
the send()'s to be four (or more) segments.  And, if one wants to spin-away the 
anti-Nagle, Nagle is defined by the send() being smaller than the MSS, so if the 
MSS is smaller, it isn't anti-Nagle :)

Further blue-skying...

If SACK were also enabled, it would seem that only loss of the last segment in 
the "thin train" would be an issue?  Presumably, the thin stream receiver would 
be in a position to detect this, perhaps with an application-level timeout. 
Whether then it would suffice to allow the receiving app to make a setsockopt() 
call to force an extra ACK or two I'm not sure.  Perhaps if the thin-stream had 
a semi-aggressive "heartbeat" going...

But it does seem that it should be possible to deal with this sort of thing 
without having to make wholesale changes to TCP's RTO policies and whatnot?

rick jones
