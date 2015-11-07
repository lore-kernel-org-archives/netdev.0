From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sat, 7 Nov 2015 15:40:12 -0800
Message-ID: <CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
	<CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
	<CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35261 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbbKGXkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 18:40:14 -0500
In-Reply-To: <CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What I was thinking about is this: My driver receives a super-packet.
> By calling skb_gso_segment(), I'm given a list of equal sized packets
> (of gso_size each), except for the last one which is either the same
> size or smaller than the rest. Let's say calling skb_gso_segment()
> gives me a list of 1300 byte packets.

This isn't particularly efficient.  This is basically equivalent to doing
GSO before the superpacket reaches your driver (you might get some
savings by not bothering to look at the packet headers of the second
and on packets, but that's most likely minimal savings).

In particular you're allocating a new skb and clearing it for each of those
1300 byte packets (and deallocating the superpacket skb).  And then you
are presumably deallocating all those freshly allocated skbs - since
I'm guessing
you are creating new skbs for transmit.

What you really want to do (although of course it's much harder)
is not call skb_gso_segment() at all for packet formats you know how
to handle (ideally you can handle anything you claim to be able to
handle via the features bits)
and instead reach directly into the skb and grab the right portions
of it and handle them directly.  This way you only ever have the one
incoming skb,
but yes it requires considerable effort.

This should get you a fair bit of savings.

> Next, I do a particular
> transformation to the packet. Let's say I encrypt it somehow, and I
> add on some additional information. Now all those 1300 byte packets
> yield new 1400 byte packets. It is time to send those 1400 byte
> packets to a particular destination.

Are you in control of the receiver?  Can you modify packet format?

> Since they're all children of the
> same skb_gso_segment()ified packet, they're all destined for the same
> destination. So, one solution is to do this:
>
> for each skb in list:
>     udp_tunnel_xmit_skb(dst, skb);
>
> But this does not perform how I'd like it to perform. The reason is
> that now each and every one of these packets has to traverse the whole
> networking stack, including various netfilter postrouting hooks and
> such, but most importantly, it means the ethernet driver that's
> sending the physical packet has to process each and every one.

Theoretically you could manually add the proper headers to each
of the new packets, and create a chain and send that, although
honestly I'm not sure if the stack is at all capable of dealing with
that atm.

Alternatively instead of sending through the stack, put on full ethernet
headers and send straight to the nic via the nic's xmit function.

> My hope was that instead of doing the `for each` above, I could
> instead do something like:
>
> superpacket->gso_size = 1400
> for each skb in list:
>     add_to_superpacket_as_ufo(skb, superpacket);
> udp_tunnel_xmit_skb(dst, superpacket);

UFO = UDP Fragmentation Offload = really meaning 'UDP transmit
checksum offload + IP fragmentation offload'

so when you send that out you get ip fragments of 1 udp packet, not
many individual udp packets.

> And that way, the superpacket would only have to traverse the
> networking stack once, leaving it either to the final ethernet driver
> to send in a big chunk to the ethernet card, or to the
> skb_gso_segment() call in core.c's validate_xmit_skb().

> Is this conceptually okay? What you wrote would seem to indicate it
> doesn't make sense conceptually, but I'm not sure.

This definitely doesn't make sense with UFO.

---

It is possible some hardware (possibly some intel nics, maybe bnx2x)
could be tricked into doing udp segmentation with their tcp segmentation
engine.  Theoretically (based on having glanced at the datasheets) the
intel nic segmentation is pretty generic, and it would appear at first
glance that with the right driver hacks (populating the transmit descriptor
correctly) it could be made to work.  I mention bnx2x because
they managed to make tcp segmentation work with tunnels,
so it's possible that the support is generic enough for it to be possible (with
driver changes).  Who knows.

It may or may not require putting on a fake 20 byte TCP header.
There's some tunnel spec that basically does that (should be able to find
an RFC online [perhaps I'm thinking of STT - Stateless Transport Tunneling].

I don't think there is currently any way to setup a linux skb with the
right metadata for it to just happen though.

It does seem like something that could be potentially worth adding though.

> So you mean to say UFO is mostly useful for just IP fragmentation?
> Don't some NICs also generate individual UDP packets when you pass it
> a big buffer of multiple pieces of data all at once?

I'm not actually aware of any nics doing that.  It's possible if you
take an IP/TCP TSO
superpacket and stuff an extra IP/UDP header on it the existing tunnel offload
stuff in the kernel might make that happen with some nics.  Unsure though
(as in unsure whether IP/UDP tunneling is currently supported, I know
IP/GRE is).
