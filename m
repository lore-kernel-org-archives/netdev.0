From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Date: Tue, 18 Nov 2008 07:14:14 +0100
Message-ID: <20081118061414.GA4015@gerrit.erg.abdn.ac.uk>
References: <5bc4c4570811060538h2d662507u5de1fb62c61cd569@mail.gmail.com> <20081106152048.GA3621@gerrit.erg.abdn.ac.uk> <20081106153824.GA9709@ghostprotocols.net> <5bc4c4570811060946j4d5d8d1mf88f8b92c72b59c7@mail.gmail.com> <5bc4c4570811061004nfc2afdcn6035d49ae654aef1@mail.gmail.com> <5bc4c4570811061017j3acef860vee84992e7295d06d@mail.gmail.com> <5bc4c4570811061405qe72e43cx861c537885804132@mail.gmail.com> <20081108085035.GA7112@gerrit.erg.abdn.ac.uk> <20081115105042.GA7798@gerrit.erg.abdn.ac.uk> <5640c7e00811160014p17414c54v2499c5b1e996278f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leandro Sales <leandroal@gmail.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	netdev@vger.kernel.org, DCCP mailing list <dccp@ietf.org>
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51900 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750761AbYKRGPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 01:15:24 -0500
Content-Disposition: inline
In-Reply-To: <5640c7e00811160014p17414c54v2499c5b1e996278f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian, -
| However RFC 5348 changes this as this clause is added to 4.6:
|   To limit burstiness, a TFRC implementation MUST prevent bursts of
|    arbitrary size.  This limit MUST be less than or equal to one round-
|    trip time's worth of packets.  A TFRC implementation MAY limit bursts
|    to less than a round-trip time's worth of packets
| 
| and this is further explained in section 8.3 and the downside - that
| you can't send big bursts so you can't get the full calculated rate.
| 
| The RFC uses an example of 1 msec scheduling and 0.1 msec RTT. However
| what would be worse is devices on a LAN with 10 msec timer - e.g. two
| embedded devices at home - I haven't done the maths but I think the
| rate achievable would be quite low.
If we use lower-resolution timers I think there should be a
recommendation (in the Kconfig menu for instance) not to use
low HZ values.

Previously this was done as a build warning, but it is annoying if
people do an allmodconfig and are not otherwise interested in DCCP.

| 
| One thing that I think we do need to be careful about though is
| assuming that we should be trying to get very high speed transfer -
| DCCP is not what we would layer a file serving protocol on top of....
| (some have argued you shouldn't even use TCP for this on a LAN...)
| 
This agrees with Gorry's reply and is an important point, since low
RTTs will be the rule when people use Gbit ethernet or loopback.

CCID-4 has a speed limiter of limiting the speed to 100 packets per
second, at Ethernet MTU this is still around 1 Mbps.

So the problem is that the parameters will suggest very high speeds,
while CCID-3 in fact targets lower speed ranges.

Do you think we could live with clamping the RTT to some sensible
minimum, since on a local LAN the use of congestion control is
questionable? I was thinking in the order of 0.5 ... 1msec.

I believe that with some sensible engineering and a suitable algorithm
it is possible to get good performance out of CCID-3 without resorting
to high-resolution timers, i.e. I think that your earlier emails
were right.

I have been looking at the jiffy-based TCP RTT estimator in
net/ipv4/tcp_input.c a lot. It is an excellent example that even with
low-resolution timers a good algorithm can make a lot of difference.
In tests it worked so well that this algorithm has been ported to 
replace the current CCID-2 RTT estimator.

| Thinking laterally there is another possible solution - something I
| used way back in the 80s for another project - build your own
| scheduler! We could set a high resolution timer to tick every 0.1 msec
| and then use the coarse grained algorithm at that point....
| 
So we have three possible options - timer-based (low/high), and your
suggestion above. We can keep these variants open by spawning an
experimental subtree which provides an alternative implementation, so
that people could explore alternative algorithms, compare and send patches.

For production use the low-resolution variant is the simplest and less
expensive option, and it is good that there is consensus about it.

In a discussion about two years ago there was another
idea, doing away with the nofeedback timer, by checking the nofeedback
time at the instant a packet is sent.

Gerrit
