From: Willy Tarreau <w@1wt.eu>
Subject: Re: [ANNOUNCE] ndiv: line-rate network traffic processing
Date: Wed, 21 Sep 2016 20:00:59 +0200
Message-ID: <20160921180059.GB1640@1wt.eu>
References: <20160921112852.GA991@1wt.eu>
 <20160921182639.2fce960a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:10647 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756128AbcIUSBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 14:01:16 -0400
Content-Disposition: inline
In-Reply-To: <20160921182639.2fce960a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper!

On Wed, Sep 21, 2016 at 06:26:39PM +0200, Jesper Dangaard Brouer wrote:
> I definitely want to study it!

Great, at least I've not put this online for nothing :-)

> You mention XDP.  If you didn't notice, I've created some documentation
> on XDP (it is very "live" documentation at this point and it will
> hopefully "materialized" later in the process).  But it should be a good
> starting point for understanding XDP:
> 
>  https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html

Thanks, I'll read it. We'll need to educate ourselves to see how to port
our anti-ddos to XDP in the future I guess, so better ensure the design
is fit from the beginning!

> > I presented it in 2014 at kernel recipes :
> >   http://kernel-recipes.org/en/2014/ndiv-a-low-overhead-network-traffic-diverter/
> 
> Cool, and it even have a video!

Yep, with a horrible english accent :-)

> > It now supports drivers mvneta, ixgbe, e1000e, e1000 and igb. It is
> > very light, and retrieves the packets in the NIC's driver before they
> > are converted to an skb, then submits them to a registered RX handler
> > running in softirq context so we have the best of all worlds by
> > benefitting from CPU scalability, delayed processing, and not paying
> > the cost of switching to userland. Also an rx_done() function allows
> > handlers to batch their processing. 
> 
> Wow - it does sound a lot like XDP!  I would say that is sort of
> validate the current direction of XDP, and that there are real
> use-cases for this stuff.

Absolutely! In fact what drove use to this architecture is that we first
wrote our anti-ddos in userland using netmap. While userland might be OK
for switches and routers, in our case we have haproxy listening on TCP
sockets and waiting for these packets. So the packets were bouncing from
kernel to user, then to kernel again, losing checksums, GRO, GSO, etc...
We modified it to support all of these but the performance was still poor,
capping at about 8 Gbps of forwarded traffic instead of ~40. Thus we thought
that the processing would definitely need to be placed in the kernel to avoid
this bouncing, and to avoid turning rings into newer rings all the time.
That's when I realized that it could possibly also cover my needs for a
sniffer and we redesigned the initial code to support both use cases. Now
we don't even see it in regular traffic, which is pretty nice.

> > The RX handler returns an action
> > among accepting the packet as-is, accepting it modified (eg: vlan or
> > tunnel decapsulation), dropping it, postponing the processing
> > (equivalent to EAGAIN), or building a new packet to send back.
> 
> I'll be very interested in studying in-details how you implemented and
> choose what actions to implement.

OK. The HTTP server is a good use case to study because it lets packets
pass through, being dropped, or being responded to, and the code is very
small, so easy to analyse.

> What was the need for postponing the processing (EAGAIN)?

Our SYN cookie generator. If the NIC's Tx queue is full and we cannot build
a SYN-ACK, we prefer to break out of the Rx loop because there's still room
in the Rx ring (statistically speaking).

> > This last function is the one requiring the most changes in existing
> > drivers, but offers the widest range of possibilities. We use it to
> > send SYN cookies, but I have also implemented a stateless HTTP server
> > supporting keep-alive using it, achieving line-rate traffic processing
> > on a single CPU core when the NIC supports it. It's very convenient to
> > test various stateful TCP components as it's easy to sustain millions
> > of connections per second on it.
> 
> Interesting, and controversial use-case.  One controversial use-case
> for XDP, that I imagine was implementing a DNS accelerator, what
> answers simple and frequent requests.

We thought about such a use case as well, just like of a ping responder
(rate limited to avoid serving as DDoS responders).

> You took it a step further with a HTTP server!

It's a fake HTTP server. You ask it to return 1kB of data and it sends you
1kB. It can even do multiple segments but then you're facing the risk of
losses that you'd preferably avoid. But in our case it's very useful to
test various things including netfilter, LVS and haproxy because it
consumes so little power to reach performance levels that they cannot even
reach that you can set it up on a small machine (eg: a cheap USB-powered
ARM board saturates the GigE link with 340 kcps, 663 krps). However I found
that it *could* be fun to improve it to deliver favicons or small error
pages.

> > It does not support forwarding between NICs. It was my first goal
> > because I wanted to implement a TAP with it, bridging the traffic
> > between two ports, but figured it was adding some complexity to the
> > system back then. 
> 
> With all the XDP features at the moment, we have avoided going through
> the page allocator, by relying on different page recycling tricks.
> 
> When doing forwarding between NICs is it harder to do these page
> recycling tricks.  I've measured that page allocators fast-path
> ("recycling" same page) cost approx 270 cycles, and the 14Mpps cycle
> count on this 4GHz CPU is 268 cycles.  Thus, it is a non-starter...

Wow indeed. We're doing complete stateful inspection and policy-based
filtering on less than 67 ns, so indeed here it would be far too long.

> Did you have to modify the page allocator?
> Or implement some kind of recycling?

We "simply" implemented our own Tx ring, depending on what drivers and
hardware support. This is the most complicated part of the code because
it is very hardware-dependant and because you want to deal with conflicts
between the packets being generated on the Rx path and other packets being
delivered by other cores on the regular Tx path. In some drivers we cheat
on the skb pointer in the descriptors, we set bit 0 to 1 to mark it as
being ours so that we recycle it into our ring after it's sent instead of
releasing an skb. That's why it would be hard to implement forwarding. I
thought that I could at least implement it between two NICs making use of
the same driver, but it could lead to starvation of certain tx rings and
other ones filling up. However I don't have a solution for now because I
decided to stop thinking about it at the moment. Over the long term I
would love to see my mirabox being used as an inline tap logging to USB3 :-)

Another important design choice that comes to my mind is that we purposely
decide to support optimal devices. We decided this after seeing how netmap
uses only the least common denominator between all supportable NICs
resulting in any NIC to become dumb. In our case, the driver has to feed
the checksum status, L3/L4 protocol types etc. If the NIC is too dumb to
support this, it just has to be implemented in software for this NIC only.
And in practice all NICs that matter support L3/L4 protocol identification
as well as checksum verification/computation, so it's not a problem and
the hardware continues to work for us for free.

> > However since then we've implemented traffic
> > capture in our product, exploiting this framework to capture without
> > losses at 14 Mpps. I may find some time to try to extract it later.
> > It uses the /sys API so that you can simply plug tcpdump -r on a
> > file there, though there's also an mmap version which uses less CPU
> > (that's important at 10G).
> 
> Interesting.  I do see a XDP use-case for RAW packet capture, but I've
> postponed that work until later.  I would interested in how you solved
> it?  E.g. Do you support zero-copy?

No, we intentionally copy. In fact on xeon processors, the memory bandwidth
is so huge that you don't even notice the copy. And by using small buffers,
you can even ensure that the memory blocks stays in L3 cache. We had most
difficulties with the /sys API because it only supports page-size transfers
and uses lots of CPU just for this, hence we had to implement mmap support
to present the packets to user-space (without copy here). But even the
regular /sys API with a double copy supports line-rate with high CPU usage.

I'll ask my coworker Emeric who did the sniffer if he can take it out as a
standalone component. It will take a bit of time because we're moving to a
new office and that significantly mangles our priorities as you can expect,
but that's definitely something we'd like to do.

> > In its current form since the initial code's intent was to limit
> > core changes, it happens not to modify anything in the kernel by
> > default and to reuse the net_device's ax25_ptr to attach devices
> > (idea borrowed from netmap), so it can be used on an existing
> > kernel just by loading the patched network drivers (yes, I know
> > it's not a valid solution for the long term).
> > 
> > The current code is available here :
> > 
> >   http://git.kernel.org/cgit/linux/kernel/git/wtarreau/ndiv.git/
> 
> I was just about to complain that the link was broken... but it fixed
> itself while writing this email ;-)

I noticed the same thing a few times already, and whatever I do, the
description is not updated. I suspect there's some load balancing with
one server not being updated as fast as the other ones.

> Can you instead explain what branch to look at?

Sure! For the most up-to-date code, better use ndiv_v5-4.4. It contains
the core (a single .h file), and support for ixgbe, e1000e, e1000, igb,
and the dummy HTTP server (slhttpd). For a more readable version, better
use ndiv_v5-3.14 which also contains the mvneta driver, it's much simpler
than the other ones and makes the code more readable. I'll have to port
it to 4.4 soon but didn't have time yet. We don't support mlx4 yet, and
it's a chicken-and-egg problem : by lack of time we don't work on porting
it and since we don't support it we don't use it in our products. That's
too bad because from what I've been told we should be able to reach high
packet rates there as well.

> > Please let me know if there could be some interest in rebasing it
> > on more recent versions (currently 3.10, 3.14 and 4.4 are supported).
> 
> What, no support for 2.4 ;-)

Not yet :-) Jokes aside, given that the API is very simple, it could be
done if anyone needed, as it really doesn't rely on any existing
infrastructure. The API is reasonably OS-agnostic as it only wants
pointers and lengths. For sniffing and/or filtering on Rx/Tx paths
only, the code basically only is (synthetic code, just to illustrate) :

     ndiv = netdev_get_ndiv(dev);
     if (ndiv) {
         ret = ndiv->handle_rx(ndiv, l3ptr, l3len, l2len, l2ptr, NULL);
         if (ret & NDIV_RX_R_F_DROP)
            continue;
     }

Best regards,
Willy
