From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 05:16:02 -0700
Message-ID: <1429186562.7346.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429119688.7346.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504151846110.7690@kaball.uk.xensource.com>
	 <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552F9F60.7090406@eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: George Dunlap <george.dunlap@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33538 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbbDPMQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:16:06 -0400
In-Reply-To: <552F9F60.7090406@eu.citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 12:39 +0100, George Dunlap wrote:
> On 04/15/2015 07:17 PM, Eric Dumazet wrote:
> > Do not expect me to fight bufferbloat alone. Be part of the challenge,
> > instead of trying to get back to proven bad solutions.
> 
> I tried that.  I wrote a description of what I thought the situation
> was, so that you could correct me if my understanding was wrong, and
> then what I thought we could do about it.  You apparently didn't even
> read it, but just pointed me to a single cryptic comment that doesn't
> give me enough information to actually figure out what the situation is.
> 
> We all agree that bufferbloat is a problem for everybody, and I can
> definitely understand the desire to actually make the situation better
> rather than dying the death of a thousand exceptions.
> 
> If you want help fighting bufferbloat, you have to educate people to
> help you; or alternately, if you don't want to bother educating people,
> you have to fight it alone -- or lose the battle due to having a
> thousand exceptions.
> 
> So, back to TSQ limits.  What's so magical about 2 packets being *in the
> device itself*?  And what does 1ms, or 2*64k packets (the default for
> tcp_limit_output_bytes), have anything to do with it?
> 
> Your comment lists three benefits:
> 1. better RTT estimation
> 2. faster recovery
> 3. high rates
> 
> #3 is just marketing fluff; it's also contradicted by the statement that
> immediately follows it -- i.e., there are drivers for which the
> limitation does *not* give high rates.
> 
> #1, as far as I can tell, has to do with measuring the *actual* minimal
> round trip time of an empty pipe, rather than the round trip time you
> get when there's 512MB of packets in the device buffer.  If a device has
> a large internal buffer, then having a large number of packets
> outstanding means that the measured RTT is skewed.
> 
> The goal here, I take it, is to have this "pipe" *exactly* full; having
> it significantly more than "full" is what leads to bufferbloat.
> 
> #2 sounds like you're saying that if there are too many packets
> outstanding when you discover that you need to adjust things, that it
> takes a long time for your changes to have an effect; i.e., if you have
> 5ms of data in the pipe, it will take at least 5ms for your reduced
> transmmission rate to actually have an effect.
> 
> Is that accurate, or have I misunderstood something?

#2 means that :

If you have an outstanding queue of 500 packets for a flow in qdisc.

A rtx has to be done, because we receive a SACK.

The rtx is queued _after_ the previous 500 packets.

500 packets have to be drained before rtx can be sent and eventually
reach destination.


These 500 packets will likely be dropped because the destination cannot
process them before the rtx.

2 TSO packets are already 90 packets (MSS=1448). It is not small, but a
good compromise allowing line rate even on 40Gbit NIC.


#1 is not marketing. It is hugely relevant.

You might use cubic as the default congestion control, you have to
understand we work hard on delay based cc, as losses are no longer a way
to measure congestion in modern networks.

Vegas and delay gradient congestion depends on precise RTT measures.

I added usec RTT estimations (instead of jiffies based rtt samples) to
increase resolution by 3 order of magnitude, not for marketing, but
because it had to be done when DC communications have typical rtt of 25
usec these days.

And jitter in host queues is not nice and must be kept at the minimum.

You do not have the whole picture, but this tight bufferbloat control is
one step before we can replace cubic by new upcoming cc, that many
companies are actively developing and testing.

The steps are the following :

1) TCP Small queues
2) FQ/pacing
3) TSO auto sizing
3) usec rtt estimations
4) New revolutionary cc module currently under test at Google,
   but others have alternatives.


The fact that few drivers have bugs should not stop this effort.

If you guys are in the Bay area, we would be happy to host a meeting
where we can present you how our work reduced packet drops in our
networks by 2 order of magnitude, and increased capacity by 40 or 50%.
