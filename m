From: George Dunlap <George.Dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 11:57:24 +0100
Message-ID: <CAFLBxZYn1t8huXrLyXPhRO=B4fthsQy9J+3bVTU5-n9AsRS43w@mail.gmail.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	<1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	<CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	<1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	<1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	<552E9E8D.1080000@eu.citrix.com>
	<1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<552EA2BC.5000707@eu.citrix.com>
	<1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<552EA844.5010308@eu.citrix.com>
	<1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<552F7936.9070205@eu.citrix.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB1F43C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	David Vrabel <david.vrabel@citrix.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33529 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbbDPK5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 06:57:24 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1F43C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 10:22 AM, David Laight <David.Laight@aculab.com> wrote:
> ISTM that you are changing the wrong knob.
> You need to change something that affects the global amount of pending tx data,
> not the amount that can be buffered by a single connection.

Well it seems like the problem is that the global amount of pending tx
data is high enough, but that the per-stream amount is too low for
only a single stream.

> If you change tcp_limit_output_bytes and then have 1000 connections trying
> to send data you'll suffer 'bufferbloat'.

Right -- so are you worried about the buffers in the local device
here, or are you worried about buffers elsewhere in the network?

If you're worried about buffers on the local device, don't you have a
similar problem for physical NICs?  i.e., if a NIC has a big buffer
that you're trying to keep mostly empty, limiting a single TCP stream
may keep that buffer empty, but if you have 1000 connections,
1000*limit will still fill up the buffer.

Or am I missing something?

> If you call skb_orphan() in the tx setup path then the total number of
> buffers is limited, but a single connection can (and will) will the tx
> ring leading to incorrect RTT calculations and additional latency for
> other connections.
> This will give high single connection throughput but isn't ideal.
>
> One possibility might be to call skb_orphan() when enough time has
> elapsed since the packet was queued for transmit that it is very likely
> to have actually been transmitted - even though 'transmit done' has
> not yet been signalled.
> Not at all sure how this would fit in though...

Right -- so it sounds like the problem with skb_orphan() is making
sure that the tx ring is shared properly between different streams.
That would mean that ideally we wouldn't call it until the tx ring
actually had space to add more packets onto it.

The Xen project is having a sort of developer meeting in a few weeks;
if we can get a good picture of all the constraints, maybe we can hash
out a solution that works for everyone.

 -George
