From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sun, 8 Nov 2015 11:36:53 +0100
Message-ID: <CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
	<CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
	<CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
	<CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:34340 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbbKHKhB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 05:37:01 -0500
In-Reply-To: <CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maciej,

On Sun, Nov 8, 2015 at 12:40 AM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> This isn't particularly efficient.  This is basically equivalent to d=
oing
> GSO before the superpacket reaches your driver (you might get some
> savings by not bothering to look at the packet headers of the second
> and on packets, but that's most likely minimal savings).

Actually, in my benchmarking, this results in enormous speedups in two =
places:

- In fact, I do have to examine the header of each incoming packet in
ndo_start_xmit(), and make a potentially expensive calculation on it
(due to the nature of my particular virtual driver). Having to only do
this once gets me about 100 additional megabits of bandwidth.
- Before sending the packet with udp_tunnel_xmit_skb, I can do only
one ip_route_output_flow() call, and reuse the rtable/dst_entry struct
for each send, instead of having to recompute it each time. This winds
up getting me around 400 more megabits.

> In particular you're allocating a new skb and clearing it for each of=
 those
> 1300 byte packets (and deallocating the superpacket skb).  And then y=
ou
> are presumably deallocating all those freshly allocated skbs - since
> I'm guessing
> you are creating new skbs for transmit.
>
> What you really want to do (although of course it's much harder)
> is not call skb_gso_segment() at all for packet formats you know how
> to handle (ideally you can handle anything you claim to be able to
> handle via the features bits)
> and instead reach directly into the skb and grab the right portions
> of it and handle them directly.  This way you only ever have the one
> incoming skb,
> but yes it requires considerable effort.
>
> This should get you a fair bit of savings.

Yes, I agree wholeheartedly; it would be much nicer to not have to
call skb_gso_segment at all, and just being able to operate on the
superpacket directly. Unfortunately, I'm not able to do this, because
I'm not simply adding or changing a header on the packet. I'm actually
making a calculation on the full bytes of the packet, which includes
the UDP and IP headers that are only added by skb_gso_segment, and
then I'm playing with ("scrambling" in some way) all of the bytes of
the entire packet. So, I really do need to decompose it into
individual packets, unfortunately.

>
> Are you in control of the receiver?  Can you modify packet format?

Yes, I am in control of the receiver. I suppose I could augment the
protocol to do this kind of reassembly. But that might conflict with
some other design goals, so I don't think that's going to happen.

>
> Theoretically you could manually add the proper headers to each
> of the new packets, and create a chain and send that, although
> honestly I'm not sure if the stack is at all capable of dealing with
> that atm.
>
> Alternatively instead of sending through the stack, put on full ether=
net
> headers and send straight to the nic via the nic's xmit function.

My initial prototype did that, actually, simply because I knew how to
build an ethernet frame but I didn't know (yet) how to use the
kernel's various APIs. This wasn't viable in the end, though, because
I do need to run the packets through netfilter and the full stack.

> UFO =3D UDP Fragmentation Offload =3D really meaning 'UDP transmit
> checksum offload + IP fragmentation offload'
>
> so when you send that out you get ip fragments of 1 udp packet, not
> many individual udp packets.

Shucks, really? So UFO really only works for single UDP packets?
That's a shame. I had hoped that since all the packets are the same
size, I could set gso_size to that, and then the splitting would take
place on those boundaries precisely. But I guess since the
fragmentation here actually does IP fragmentation, this would run
counter to my goals, since new UDP headers wouldn't be added in the
end. Total bummer.

Wouldn't there be some significant savings from bundling together
several UDP packets meant for the same destination, and sending those
all as one super-packet, so they don't each have to traverse the whole
networking and netfilter stack? By asking that question, it doesn't
feel as though I've come up with a new idea; is there a reason why
that isn't implemented or why (if) it was rejected?

>
> It is possible some hardware (possibly some intel nics, maybe bnx2x)
> could be tricked into doing udp segmentation with their tcp segmentat=
ion
> engine.  Theoretically (based on having glanced at the datasheets) th=
e
> intel nic segmentation is pretty generic, and it would appear at firs=
t
> glance that with the right driver hacks (populating the transmit desc=
riptor
> correctly) it could be made to work.  I mention bnx2x because
> they managed to make tcp segmentation work with tunnels,
> so it's possible that the support is generic enough for it to be poss=
ible (with
> driver changes).  Who knows.
>
> It may or may not require putting on a fake 20 byte TCP header.
> There's some tunnel spec that basically does that (should be able to =
find
> an RFC online [perhaps I'm thinking of STT - Stateless Transport Tunn=
eling].
>
> I don't think there is currently any way to setup a linux skb with th=
e
> right metadata for it to just happen though.
>
> It does seem like something that could be potentially worth adding th=
ough.

These are glorious dirty tricks. Awesome. It appears, NIC-wise, that
only the neterion driver currently supports UFO natively. I wonder if
the Intel folks will add it to their drivers, since the segmentation
is generic as you said.

Still, though, regardless of NIC support, using superpackets to reduce
the number of skbs that have to traverse the networking stack appears
to be worthwhile. It'd be nice to make this happen for clusters of UDP
packets.


I'm adding to the CC Herbert Xu, who mentioned in another thread:

> I don't see anything fundamentally wrong with your idea.  After
> all what you're describing is the basis of GSO, i.e., letting
> data stay in the form of super-packets for as long as we can.
>
> Of course there's going to be a lot of niggly bits that you'll
> have to sort out to get it to work.

So I wonder if he has any ideas about this too.


Anyway, thanks so much for your insight about this. I really
appreciate the pointers.

Regards,
Jason
