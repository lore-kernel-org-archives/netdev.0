From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sun, 8 Nov 2015 19:18:08 -0800
Message-ID: <CAHo-OozFzSeEcj5t8x_boaRDX=cVh4c_kC-q9RnU9NKem-3jhw@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
	<CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
	<CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
	<CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
	<CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
	<20151108105710.GA30282@gondor.apana.org.au>
	<CAHmME9rSGbfNFeQMCXr+0j=mSTfyxFkyLEJ0rMqnOgH6L4OSng@mail.gmail.com>
	<20151109014045.GA1358@gondor.apana.org.au>
	<CAHmME9rfbkn+5M0zPQKEtjrmieBjsvPWG9o9q+YHVkpuLGzuKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rfbkn+5M0zPQKEtjrmieBjsvPWG9o9q+YHVkpuLGzuKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Once it figures out which gso_inner_segment to use, it calls
> __skb_udp_tunnel_segment with it, which then does some curious header
> calculations on various lengths (that I need to read carefully), and
> then proceeds to split the segments using our gso_inner_segment
> function of choice, and then adds the length and checksum header
> fields. Unfortunately, it doesn't add the UDP source and destination
> port header fields. That means I might as well be building the UDP
> headers ahead of time myself, which is a bit of a bummer.

I'm guessing the udp src dst port (and ??possibly?? optional gue
headers) are meant to be part of the external headers that are already
pre-populated.

> Anyway, the idea would be to [ab]use SKB_GSO_UDP_TUNNEL with a
> scintillating gso_inner_segment function for a custom inner_ipproto
> field, in order to make a superpacket.

That's probably basically what that was designed for.  So doesn't seem
like an abuse.

Tunnel GSO offloads are still very very fresh and actively being
worked on (by Tom and Eric among others).
I'm afraid my knowledge of them at HEAD is very limited.
I've only recently started experimenting in this area myself.

> How's this looking as a strategy (and an outline of the "niggly bits"
> as you put it)?

Looks fine.  Devil is in the details.  You may discover that the stack
is still missing some things you'll need to add in.

(for example, personally I'm trying to understand if CHECKSUM_PARTIAL
shouldn't carry an extra bit of information specifying whether
we need a TCP or UDP style checksum, since they differ in how a
checksum of 0 is transmitted, it appears this causes nic drivers
to need to redigest the packet to figure it out before they can pass
it on to the hardware)

- Maciej
