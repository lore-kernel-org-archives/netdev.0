From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 22:57:46 +0200
Message-ID: <1210021066.4181.41.camel@johannes.berg>
References: <1210017456.4181.23.camel@johannes.berg>
	 <20080505.130225.159803012.davem@davemloft.net>
	 <1210018214.4181.27.camel@johannes.berg>
	 <20080505.134420.194001886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZcuTxSAjKiyZ9yRqTKHz"
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44992 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbYEEU63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 16:58:29 -0400
In-Reply-To: <20080505.134420.194001886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZcuTxSAjKiyZ9yRqTKHz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 13:44 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 05 May 2008 22:10:14 +0200
>=20
> > So you're saying the check there to see if we can add 802.11 headers
> > should depend on skb_header_cloned() and not skb_cloned()?
>=20
> If you're pushing things in front (adding headers), you should basically
> always be OK.

We're not, we need to strip off the ethernet header and replace it with
802.11.

> The problem is the skb->data pointer, that has to remain stable
> once dev_queue_xmit() gets the frame because taps like AF_PACKET
> can have access to the packet (via net/core/dev.c:dev_queue_xmit_nit()).
>=20
> (If you read the AF_PACKET code, and notice how it munges the
>  headers, note that it only does so temporarily and restores the
>  skb->data and skb->len state before returning back up to
>  it's caller, dev_hard_start_xmit())
>=20
> I think the AF_PACKET stuff is actually superfluous on the transmit
> side, we always give it clones so it can modify skb->data however it
> pleases without having to restore anything.  Someone with some time
> should look more closely into this :-)  The problem here seems to
> be that pt->func is used for both receive and transmit paths, so it
> must be mindful to handle both cases properly.

Interesting, but I'm not really interested in looking into it right
now :)

> BTW, this gets back to the topic of the pain caused by pretending this
> stuff is ethernet when it isn't.  If we really made these wireless
> devices look the way they should, tcpdump could see the headers
> correctly.  I'm sure you have all sorts of hacks in the 80211 code to
> make 802.11 header capture possible via side-band stuff, but it would
> have been so much nicer (and transparently solved these header space
> issues) if we didn't try to put lipstick on a pig :-)

We can discuss this to no end and already have; I just don't see how
you'd want to handle the BSSID or QoS fields with things like dhclient.
As for header capture, that is actually not very interesting, the
interesting stuff is the transmit indication (was the frame ack'ed, ...)
and that's still not possible that way.

> Anyways, back to the original topic.  I think you can avoid COW'ing
> clones if you don't modify skb->data and give the drivers some other
> way to know where the wireless headers really start.
>=20
> Alternatively, you can just clone the packet.  At that point the
> skb->data etc. members are your's to modify to your heart's content.
> And because nobody can look below the original skb->data value, you
> can stick your headers there.

But I cannot modify the ethernet header that'll live on in the skb data
so that's not useful. Also, if two mac80211 netdevs are bridged together
they'd stomp on each other no?

johannes

--=-ZcuTxSAjKiyZ9yRqTKHz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB90yaVg1VMiehFYAQJHkw//Tf60LHw0LVGGI1a458winBBmDDIbn00i
csiND1cOk0IC4glfVcGC5oT6962E28Es5AfBQLqAu9CkXJUdZkpzVQ9NxSmOxKka
afKRES4hLdynUxljP59CZXivG1wPdXlb4OlKonJ+ON4nQyvWmw4yxmrYwv+bIauv
0B0ZzupAbqB0y2YINNY+KDGrMSR2CCjzp9Uii3+HDZA9KEyp57gkM0iLep76oyma
SdQdwRP6ih5h7OPu+dpHJzhkVlwjJfLvv76eTuC9vYHVfPOHpi+xq/WZIyKYU+nM
mPJPdu708JspSYJW2Af3LaDmASG66t4k6rZC3qsOfi6zzS0ABXYbamfZgiAR/aNQ
Xv8yLqUf3TTLlnEDMjuPk0O8ApQUq80lVFQWGiVJ32R2in058wcPARFKvfwUCYxq
I3J+PHBCg0xvVYrj9hP9Si4izNi6y/PDVOBsfabN4LkDSIWEOLbns80dnQRgKag0
V5fmkEYdRf0Rm9+PQ4L+8IEaLqMChB5tTnyHshNo0A1dwUuJzjJ7+HitHY3voZOV
GHGA9O4KuGwqFgLzVvrAlo0dHBj96cTDIzTT27XM1rbuikk3CUqD/ZIZCOXo7Jcy
GvSpGxk3TSkJ4NPzuo+C4VzEuSLSQFr9fCNeXdMyW08+QZ9TuOXkmRoqwe37r6m+
Ou3fSdmkw80=
=Ls3N
-----END PGP SIGNATURE-----

--=-ZcuTxSAjKiyZ9yRqTKHz--

