From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sat, 7 Nov 2015 09:19:50 -0800
Message-ID: <CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34552 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbbKGRTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 12:19:52 -0500
In-Reply-To: <CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I suppose this is about UFO.
>
> Specifically -- let's say I have a list of 500 skbs, which have their
> data in place but don't yet have an IP or UDP header etc. I want to
> send out these out using udp_tunnel_xmit_skb. Right now, if I just
> send them all out, one after another, they don't seem to be getting
> assembled into a super packet suitable for UFO. Instead, they're just
> sent one at a time, and I get the vast majority of `perf top` CPU
> usage in my ethernet card's driver and along the path to it -- the
> problem that UFO is supposed to solve.
>
> So my question is -- how can I make UFO happen with udp_tunnel_xmit_skb?

UFO will never collapse multiple (UDP) packets.

It would be incorrect to do so, since UDP has to maintain packet
framing boundaries, and the only way to mark that on the wire is via
individual appropriately sized packets.

UFO prevents the need to do IP fragmentation on overly large
*singular* UDP packets.

The case where UFO (should) help is if you are taking a TCP TSO
segment of 10k and adding UDP headers and sending it out as an
20+8+10k UDP packet.
Without UFO this would now need to be software (potentially
checksummed and) ip fragmented into (8+10k)/(1500-20) packets
(assuming 1500 mtu), with UFO hw offload the nic deals with that (it
does the checksumming and it does the ip fragmentation).

Although note: in the case of UDP+TCP TSO this has reliability issues,
since a loss of a single frame will now lose the entire fragmented IP
UDP datagram and thus lose the entire TCP TSO segment,
meaning that you probably do not want to use this unless your network
is lossless (ie. loopback, veth and other virtual networks come to
mind).

I guess UDP encap of a larger than mtu UDP is probably a valid use
case for UFO, since we'd have ip fragmented anyway, and it's cheaper
to ip fragment on the outer IP header than on the inner.
