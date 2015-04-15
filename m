From: George Dunlap <George.Dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Wed, 15 Apr 2015 14:43:58 +0100
Message-ID: <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	<1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	<CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	<1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35922 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbbDONoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 09:44:32 -0400
In-Reply-To: <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 2:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-04-13 at 11:56 +0100, George Dunlap wrote:
>
>> Is the problem perhaps that netback/netfront delays TX completion?
>> Would it be better to see if that can be addressed properly, so that
>> the original purpose of the patch (fighting bufferbloat) can be
>> achieved while not degrading performance for Xen?  Or at least, so
>> that people get decent perfomance out of the box without having to
>> tweak TCP parameters?
>
> Sure, please provide a patch, that does not break back pressure.
>
> But just in case, if Xen performance relied on bufferbloat, it might be
> very difficult to reach a stable equilibrium : Any small change in stack
> or scheduling might introduce a significant difference in 'raw
> performance'.

So help me understand this a little bit here.  tcp_limit_output_bytes
limits the amount of data allowed to be "in-transit" between a send()
and the wire, is that right?

And so the "bufferbloat" problem you're talking about here are TCP
buffers inside the kernel, and/or buffers in the NIC, is that right?

So ideally, you want this to be large enough to fill the "pipeline"
all the way from send() down to actually getting out on the wire;
otherwise, you'll have gaps in the pipeline, and the machinery won't
be working at full throttle.

And the reason it's a problem is that many NICs now come with large
send buffers; and effectively what happens then is that this makes the
"pipeline" longer -- as the buffer fills up, the time between send()
and the wire is increased.  This increased latency causes delays in
round-trip-times and interferes with the mechanisms TCP uses to try to
determine what the actual sustainable rate of data trasmission is.

By limiting the number of "in-transit" bytes, you make sure that
neither the kernel nor the NIC are going to have packets queues up for
long lengths of time in buffers, and you keep this "pipeline" as close
to the actual minimal length of the pipeline as possible.  And it
sounds like for your 40G NIC, 128k is big enough to fill the pipeline
without unduly making it longer by introducing buffering.

Is that an accurate picture of what you're trying to achieve?

But the problem for xennet (and a number of other drivers), as I
understand it, is that at the moment the "pipeline" itself is just
longer -- it just takes a longer time from the time you send a packet
to the time it actually gets out on the wire.

So it's not actually accurate to say that "Xen performance relies on
bufferbloat".  There's no buffering involved -- the pipeline is just
longer, and so to fill up the pipeline you need more data.

Basically, to maximize throughput while minimizing buffering, for
*any* connection, tcp_limit_output_bytes should ideally be around
(min_tx_latency * max_bandwidth).  For physical NICs, the minimum
latency is really small, but for xennet -- and I'm guessing for a lot
of virtualized cards -- the min_tx_latency will be a lot higher,
requiring a much higher ideal tcp_limit_output value.

Rather than trying to pick a single value which will be good for all
NICs, it seems like it would make more sense to have this vary
depending on the parameters of the NIC.  After all, for NICs that have
low throughput -- say, old 100MiB NICs -- even 128k may still
introduce a significant amount of buffering.

Obviously one solution would be to allow the drivers themselves to set
the tcp_limit_output_bytes, but that seems like a maintenance
nightmare.

Another simple solution would be to allow drivers to indicate whether
they have a high transmit latency, and have the kernel use a higher
value by default when that's the case.

Probably the most sustainable solution would be to have the networking
layer keep track of the average and minimum transmit latencies, and
automatically adjust tcp_limit_output_bytes based on that.  (Keeping
the minimum as well as the average because the whole problem with
bufferbloat is that the more data you give it, the longer the apparent
"pipeline" becomes.)

Thoughts?

 -George
