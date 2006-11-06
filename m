From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Tue, 07 Nov 2006 00:06:34 +0100
Message-ID: <1162854394.1412.40.camel@johannes.berg>
References: <1162741174.24574.22.camel@johannes.berg>
	 <20061106210145.6824bec6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uWQaY3US3FuddnuO2uwr"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:61326 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753911AbWKFXIM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 18:08:12 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061106210145.6824bec6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uWQaY3US3FuddnuO2uwr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-11-06 at 21:01 +0100, Jiri Benc wrote:

> This definitely breaks AP mode. In the code, there is heavily (ab)used
> the fact that the master device is in fact an AP device. I tried to fix
> that but it was so difficult I gave up. It is needed to rewrite the
> whole RX path (and even that is probably not enough).

Alright, I see the point. Let's fix it up good while at it. Here's a
braindump.

Keeping with the protocol theme, we need to rewrite the rx path to do
the following in the order listed:

 1) if any monitor interfaces are up, copy the skb, add the
    prism/radiotap/whatever header and then clone it to all monitor
    interfaces (don't actually copy for each as we do now)
 2) if it is a unicast frame, determine which interface the frame should
    go to now, it can't be going to more than one afaik
 2) decrypt the frame
 3) defragment the frame
 4) send the frame off to each sub_if that might care about it
 5) do further device specific processing

I need to think more about this though.

If we're careful, we can probably get away with a lot less copying than
we do now by pushing the copying down into those handlers that really
need different data. This would probably only be the crypto handlers,
the others can live with just pskb_copy instead. Then again, we don't
handle non-linear skbs anyway. Actually, we should be calling
skb_linearize at least, no?

And if the frame is not encrypted at all, then we can even save the
skb_copy for the monitor and just use skb_clone and later pskb_copy...

Time for bed,
johannes

--=-uWQaY3US3FuddnuO2uwr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARU+/+aVg1VMiehFYAQJoVw/+KezP+MBdCnWsfzR2gE45AuFs2arfIQuT
B0UIDYvGD+9g6GyJypTFvkTaqsEyN+EbhtDCe4s5NXQYbcMCuAvH2I7W8WdBJr3N
HzNdFR/Kqti4PLgeVG7V6BzI3hirwg+xoqXIQyk6qVy8eV4xCylM/7rpCTQqvd0+
mEt+vIdQflVZ1F2C5PeOfnAN72CBklGfyiNirqt+xCN5+sU8piBuxkzoo0kshIB2
DheBrIWaUsTxDTh9e9uxFeu8xcloNpiOTcrenOOJVv7fpxcabE5qTNgy1DxsA5xj
18I68uSv7jPp3Wij4fnxFc5At3Ny4BUpXbqDTQhsC8MGdKxZyo9VKx67bx4ALsjY
4zAwWgPODeLVJd6qEdCyHvBbcIh+IH+h6L5d26Owy0W1HPxB37in3k/bDNSeUAJN
62+Q01kYLP6KZHir4oLb3mICqWmKa6NPbaH8ybYxuaBeVT2SbjBfKZFhWgkY1VsE
OpLUQw4Cu5JNy64rwGyMaZ62oti7ozfPcVD4/oqJ++Inctd8mfGIXTvdl08b/FZP
iTzyu/1EaOJPVIi82W3VUpQYRLt10CJP+7Qz87/CSMq5dAbKw/dahRIvHuTlfHGt
52BcZykhlLhf+t3SmqSyu1XQwN0x8AGJT/Gda36APos5pmrXwc2d5gnSf1QD7MSS
gj8LqWMvqQI=
=7ujT
-----END PGP SIGNATURE-----

--=-uWQaY3US3FuddnuO2uwr--

