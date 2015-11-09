From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Mon, 9 Nov 2015 03:23:18 +0100
Message-ID: <CAHmME9rfbkn+5M0zPQKEtjrmieBjsvPWG9o9q+YHVkpuLGzuKQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:45740 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbbKICX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 21:23:26 -0500
In-Reply-To: <20151109014045.GA1358@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 9, 2015 at 2:40 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> You're right.  I don't think the ordering matters.

Cool, so we're on the same page then.

In that case, any ideas about constructing UDP super-packets for GSO?
As Maciej pointed out, UFO is actually just IP fragmentation and UDP
checksums, but doesn't actually add on new UDP headers as we'd wish.
But I was digging a bit deeper and I found this gem:
skb_udp_tunnel_segment. This is the segmentation function called for
SKB_GSO_UDP_TUNNEL. For this, it does something sort of neat.

If the skb's inner_protocol_type is ENCAP_TYPE_IPPROTO, then it looks
up an "gso_inner_segment" function based on the skb->inner_ipproto
field. The lookup happens on a list of functions (called
inet6_offloads and inet_offloads) that has some nice setter/getter
methods for various modules to call.

Once it figures out which gso_inner_segment to use, it calls
__skb_udp_tunnel_segment with it, which then does some curious header
calculations on various lengths (that I need to read carefully), and
then proceeds to split the segments using our gso_inner_segment
function of choice, and then adds the length and checksum header
fields. Unfortunately, it doesn't add the UDP source and destination
port header fields. That means I might as well be building the UDP
headers ahead of time myself, which is a bit of a bummer.

Anyway, the idea would be to [ab]use SKB_GSO_UDP_TUNNEL with a
scintillating gso_inner_segment function for a custom inner_ipproto
field, in order to make a superpacket.

How's this looking as a strategy (and an outline of the "niggly bits"
as you put it)?

Jason
