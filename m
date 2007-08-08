From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] allow device to stop packet mirror behaviour
Date: Wed, 08 Aug 2007 12:32:08 +0200
Message-ID: <1186569128.11717.44.camel@johannes.berg>
References: <1186475155.4067.17.camel@johannes.berg>
	 <20070807.180607.116354128.davem@davemloft.net>
	 <1186564441.11717.5.camel@johannes.berg>
	 <20070808.031755.91441405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cTNlzPcwyYgVjOjwnTA6"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070808.031755.91441405.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-cTNlzPcwyYgVjOjwnTA6
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-08 at 03:17 -0700, David Miller wrote:

> Then I don't understand your problem.  If they are specific 802.11
> protocol packets, the radio stack is in a much better situation to
> filter out things like this.

What do you mean by radio stack? You can't really send any frames into
the monitor devices *except* raw radiotap+802.11 frames, and these are
exactly the problem because they're mirrored out right away. But because
we have a different radiotap header on outgoing than on incoming frames
to allow userspace to see the transmission indication (was the packet
ACKed by the other side etc) we ourselves mirror them out as well.

We also mirror out packets from other virtual devices associated with
the same PHY as the virtual monitor.

So think of it this way:

[ monitor interface (radiotap+802.11) ]  [ STA mode interface (802.3) ]
                                  |       |
                                  \       /
                                   \     /
                                    \   /
                                     \ /
                                [ mac80211 ]
                                      |
                                   [ PHY ]
                                      |
                             [ wireless medium ]

Now for packets that come in on the right path, they get mirrored out
back to the STA mode interface as well. That's fine. For packets that
come from the bottom, they get cloned and sent to both devices at the
top with different framing.

Additionally, packets that come in via any interface on the top are
redirected to all monitor interfaces *after* their transmission via the
PHY and are amended by a radiotap header that indicates whether the
transmission was successful. So if you run tcpdump on both interfaces
above you'll see the IPv4 multicast packet sent to the STA mode
interface come up on the STA mode interface right away, and you'll also
see it on the monitor interface after it was transmitted by the PHY.

The problem now comes in when you actually transmit a 802.11 framed
packet down the monitor device. Because the mac80211 code mirrors all
transmitted packets up to all monitor interfaces, and the generic code
mirrors the packet as soon as it was sent to the device (via
dev_queue_xmit_nit) you see it twice.

johannes

--=-cTNlzPcwyYgVjOjwnTA6
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGuZuo/ETPhpq3jKURApCCAJ9kN0QxeEEOoPC6ivW4w2YZY21NZwCgo4cq
NL3Hd71WtBrhPtkl+GB5VsY=
=nWEs
-----END PGP SIGNATURE-----

--=-cTNlzPcwyYgVjOjwnTA6--
