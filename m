From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sat, 7 Nov 2015 23:39:59 +0100
Message-ID: <CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
	<CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:36574 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193AbbKGWkH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 17:40:07 -0500
In-Reply-To: <CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maciej,

Thanks for your reply. Some interesting things to consider here... See
inline below.

On Sat, Nov 7, 2015 at 6:19 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
>
> UFO will never collapse multiple (UDP) packets.
>
> It would be incorrect to do so, since UDP has to maintain packet
> framing boundaries, and the only way to mark that on the wire is via
> individual appropriately sized packets.

What I was thinking about is this: My driver receives a super-packet.
By calling skb_gso_segment(), I'm given a list of equal sized packets
(of gso_size each), except for the last one which is either the same
size or smaller than the rest. Let's say calling skb_gso_segment()
gives me a list of 1300 byte packets. Next, I do a particular
transformation to the packet. Let's say I encrypt it somehow, and I
add on some additional information. Now all those 1300 byte packets
yield new 1400 byte packets. It is time to send those 1400 byte
packets to a particular destination. Since they're all children of the
same skb_gso_segment()ified packet, they're all destined for the same
destination. So, one solution is to do this:

for each skb in list:
    udp_tunnel_xmit_skb(dst, skb);

But this does not perform how I'd like it to perform. The reason is
that now each and every one of these packets has to traverse the whole
networking stack, including various netfilter postrouting hooks and
such, but most importantly, it means the ethernet driver that's
sending the physical packet has to process each and every one.

My hope was that instead of doing the `for each` above, I could
instead do something like:

superpacket->gso_size =3D 1400
for each skb in list:
    add_to_superpacket_as_ufo(skb, superpacket);
udp_tunnel_xmit_skb(dst, superpacket);

And that way, the superpacket would only have to traverse the
networking stack once, leaving it either to the final ethernet driver
to send in a big chunk to the ethernet card, or to the
skb_gso_segment() call in core.c's validate_xmit_skb().

Is this conceptually okay? What you wrote would seem to indicate it
doesn't make sense conceptually, but I'm not sure.
I started to write some code to do that, which isn't really working,
and I outlined it here [1].


> UFO prevents the need to do IP fragmentation on overly large
> *singular* UDP packets.
>
> The case where UFO (should) help is if you are taking a TCP TSO
> segment of 10k and adding UDP headers and sending it out as an
> 20+8+10k UDP packet.
> Without UFO this would now need to be software (potentially
> checksummed and) ip fragmented into (8+10k)/(1500-20) packets
> (assuming 1500 mtu), with UFO hw offload the nic deals with that (it
> does the checksumming and it does the ip fragmentation).

So you mean to say UFO is mostly useful for just IP fragmentation?
Don't some NICs also generate individual UDP packets when you pass it
a big buffer of multiple pieces of data all at once?

Thanks,
Jason

[1] http://www.spinics.net/lists/netdev/msg351400.html
