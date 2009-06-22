From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Mon, 22 Jun 2009 16:20:03 +0930
Message-ID: <20090622162003.35ff28da.lk-netdev@lk-netdev.nosense.org>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
	<20090620105325.GC31266@Chamillionaire.breakpoint.cc>
	<20090620205026.05219c33.lk-netdev@lk-netdev.nosense.org>
	<20090621.225018.185805046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:34150 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbZFVGua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 02:50:30 -0400
In-Reply-To: <20090621.225018.185805046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Sun, 21 Jun 2009 22:50:18 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Sat, 20 Jun 2009 20:50:26 +0930
> 
> > On Sat, 20 Jun 2009 12:53:25 +0200
> > Florian Westphal <fw@strlen.de> wrote:
> > 
> >> Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:
> >> > econet_rcv() calls ec_queue_packet(). The return from ec_queue_packet()
> >> > is the direct result of a call to sock_queue_rcv_skb(). Error returns
> >> > from ec_queue_packet() and therefore sock_queue_rcv_skb() are due to
> >> > kernel errors, so have econet_rcv() return NET_RX_BAD in this case.
> >> 
> >> What about doing this instead?
> > 
> > I think there is value in distinguishing between network/protocol
> > errors and kernel errors. It helps determine where the fault might lie
> > - in the network somewhere, or isolated to the receiving host. In
> > larger organisations there is typically a networks support team and a
> > hosts/sys admin team. Hints such as this that help determine who's
> > problem the fault is to deal with can be a big time saver (being a
> > networking person on one of these sorts of teams, I'm scrathing an
> > itch :-) )
> > 
> > If these econet patches are accepted, I'll send through similar patches
> > for the other protocols in the kernel where necessary.
> 
> Indeed I bet whoever added NET_RX_BAD thought the distinction had
> value too.
> 
> But it's been there for many years, and:
> 
> 1) almost nobody sets it
> 
> 2) nothing really acts upon or reports it specially
> 
> and if after all that time these two things are still true, then
> it's obviously worthless in reality.
> 

It could be a bit of a chicken-and-egg problem. I didn't know there was
the option for the kernel to distinguish these errors until I
looked into the variety of NET_TX returns. Of course, the kernel doesn't
actually distinguish these types of errors because none of the protocols
(or at least the main ones I've looked at) specifically report them.

I'm not aware though as to currently where a general per-protocol count
of NET_RX_BADs vs NET_RX_DROPs might be exposed. I interpret the NIC
stats to be specific to the ethernet layer, so I think the dropped and
error counts for a NIC shouldn't be incremented for these layer 3
protocol errors. Having a brief look at the IPv4 and IPv6
implementations, they count these or similar errors in their MIB
counters.

Have a brief read through Neil Horman's dropwatch project page (I've
cc'd Neil), it would seem that the ideal place to report NET_RX_DROP vs
NET_RX_BAD would be via the netlink drop monitor protocol, exposing
packet drops between the generic incoming SKB and protocol handling
layer. Possibly more granularity could be added to report the error
type e.g. failed layer 3 checksum, incorrect version, socket queue full
etc.

> Therefore my inclination is to apply Florian's patch once the
> merge window closes and the next-next-net-2.6 stuff starts getting
> applied :-)
> 
> You can submit the econet stuff relative to that if you like.  But
> I wonder Mark, are you actually using that protocol? :-)
> 

Hah! I've used it once in my life. In the late 80s, BBC Microcomputers
were pretty propular here in Australia in schools, and my high school
had a network of them. Of course I don't think I even knew the word
protocol at the time, let alone which one we were using.

More recently though I did use the this econet implementation as one
of the things I looked at when I worked on ECTP a few months ago. I
looked around at appletalk, ipx, decnet, ipv4 and ipv6 to see examples
of the correct NET_RX return, which is when I noticed some
inconsistencies and also the lack of use of NET_RX_BAD where I thought
it should be used. (as an inconsistency example, in 2.6.30,
IPv6 is currently always returning 0, NET_RX_SUCCESS, even when the
packet is dropped.) I thought I'd have a go at cleaning up some of these
inconsistencies, with econet a very non-intrusive place to start.

Regards,
Mark.


