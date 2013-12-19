From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 01:07:59 +0100
Message-ID: <20131219000759.GF3505@order.stressinduktion.org>
References: <20131215022336.GA27866@order.stressinduktion.org> <20131218.173442.336109133942416102.davem@davemloft.net> <CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37915 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3LSAIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:08:00 -0500
Content-Disposition: inline
In-Reply-To: <CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 06:55:13PM -0500, John Heffner wrote:
> On Wed, Dec 18, 2013 at 5:34 PM, David Miller <davem@davemloft.net> wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Sun, 15 Dec 2013 03:23:36 +0100
> >
> >> While forwarding we should not use the protocol path mtu to calculate
> >> the mtu for a forwarded packet but instead use the interface mtu.
> >>
> >> We mark forwarded skbs in ip_forward with IPSKB_FORWARDED which was
> >> introduced for multicast forwarding. But as it does not conflict with
> >> our usage in unicast code path it is perfect for reuse.
> >>
> >> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> >> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> >> dependencies because of IPSKB_FORWARDED.
> >>
> >> Because someone might have written a software which does probe
> >> destinations manually and expects the kernel to honour those path mtus
> >> I introduced a new per-namespace "forwarding_uses_pmtu" knob so someone
> >> can disable this new behaviour. We also use mtus which are locked on a
> >> route for forwarding.
> >>
> >> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> >> Cc: David Miller <davem@davemloft.net>
> >> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >
> > Sockets aren't the only entity that create cached PMTU information
> > we might like to use during forwarding, tunnels do too.
> >
> > I'm afraid what the side effects of this change will be in that
> > situation, because the dst_mtu() is exactly what will allow us
> > to relay the ICMP back to the pre-decapsulation source address
> > properly.
> >
> > In any event, this code was made to explicitly behave this way
> > back in 2007 by John Heffner, maybe he has some opinions too.
> 
> I added IP_PMTUDISC_PROBE, intended for use with MTU diagnostic tools,
> i.e., tracepath.
> 
> I don't keep up that well these days with Linux networking, but I see
> now the recent addition of IP_PMTUDISC_INTERFACE.  As an aside, I'm a
> bit skeptical that we'd actually want to send out packets with DF
> unset.  (One, there is no equivalent in IPv6, plus all the
> well-documented bad things that happen when you do this.)  But this is
> already committed...

The idea is that DNS servers can prevent local fragmentation but the
packet is still allowed to get fragmented on the way. Otherwise those
packets get dropped and wouldn't reach their destination.

DNS servers should tweak their edns max packet size below the outgoing MTU
so packets will still reach the target but can retry with TCP transport
(trunc bit being set). In case of retry, pmtu data must be respected.

> On using the interface MTU for all forwarded packets, I have a similar
> reaction as David.  And why are forwarded packets more special than
> local ones, from the routing code's point of view?  It seems like
> there could be other ways to harden a router, like firewall rules.

I doubt it is trivial to set up such a filter as we have to inspect
the payload of the icmp error. I played with it and it is certainly
possible, but my intention was that the networking stack does try to
prevent fragmentation and delay generation of fragments to the last
router on the path where it is necessary.

Greetings,

  Hannes
