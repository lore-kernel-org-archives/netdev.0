From: David Lamparter <equinox@diac24.net>
Subject: Re: IGMPMSG_WRONGVIF only happens when true VIF is an OIF of correct
 IIF?
Date: Fri, 18 Feb 2011 18:12:25 +0100
Message-ID: <20110218171225.GC1739639@jupiter.n2.diac24.net>
References: <1298044016.2898.12.camel@thor>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DSayHWYpDlRfCAAQ"
Cc: netdev@vger.kernel.org
To: Dan Langlois <daniel.langlois@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:46066 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830Ab1BRRMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 12:12:42 -0500
Content-Disposition: inline
In-Reply-To: <1298044016.2898.12.camel@thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DSayHWYpDlRfCAAQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 18, 2011 at 04:46:56PM +0100, Dan Langlois wrote:
> Hi, I have a question about the IGMPMSG_WRONGVIF message.
> I have MRT_ASSERT enabled but do not receive notifications.
> However, if I enable MRT_PIM, I do get them.  I'm curious
> why MRT_ASSERT alone isn't sufficient.
>=20
> This if-statement appears in ip_mr_forward() in net/ipv4/ipmr.c
>=20
>        if (true_vifi >=3D 0 && net->ipv4.mroute_do_assert &&
>             /* pimsm uses asserts, when switching from RPT to SPT,=20
>                so that we cannot check that packet arrived on an oif.=20
>                It is bad, but otherwise we would need to move pretty
>                large chunk of pimd to kernel. Ough... --ANK
>              */     =20
>             (net->ipv4.mroute_do_pim ||
>              cache->mfc_un.res.ttls[true_vifi] < 255) &&=20
>             time_after(jiffies,
>                        cache->mfc_un.res.last_assert +
> MFC_ASSERT_THRESH)) {
>                 cache->mfc_un.res.last_assert =3D jiffies;
>                 ipmr_cache_report(net, skb, true_vifi,
> IGMPMSG_WRONGVIF);
>         }      =20
>=20
>=20
> By the time this statement is reached, it is known that the packet
> did not arrive on the expected incoming interface (IIF) and thus a
> "WRONGVIF" condition.  This if-statement decides whether a PIM-assert
> notification needs to be sent to the multicast routing daemon.
>=20
> The part of this if-statement I'm questioning is:
>     (net->ipv4.mroute_do_pim ||
>      cache->mfc_un.res.ttls[true_vifi] < 255) &&
>=20
> I read this as:
> "send WRONGVIF if PIM is enabled -OR-
> the packet arrived on an outgoing interface OIF of the correct IIF"
>=20
> So this statement is always true when PIM is enabled.
> However, if only ASSERT is enabled, this statement is only true when
> a packet is reflected back on an OIF.
>=20
> Why not always send the assert for any WRONGVIF condition regardless
> of the interface it came in on?  I mean, isn't that the point of
> enabling MRT_ASSERT in the first place?  If the assertions weren't
> wanted, just don't enable that feature, right?

The point of MRT_ASSERT is to aid in resolving duplication issues where
you end up with multiple mrouters thinking they're responsible for the
same subnet. This condition is indicated by more than 1 router on the
subnet having the subnet as OIF on the (*,G) or (S,G). Therefore, your
daemon receives the assertion if it is one of the forwarding mrouters,
which it will only be if it's an OIF.

If your daemon doesn't have the target subnet listed as oif, the
assumption is that a different mrouter has been elected to forward
packets for this G/S,G to this subnet. The kernel knows that your daemon
decided to not forward things to this subnet, so you are not involved in
duplicates, so you don't get an assert.

The "PIM or" is a kludge to make PIM work, as indicated by the comment
above the if. I'd have to refreshen my PIM knowledge to fully understand
it or explain it ;)

> In our system, multicast streams may get rerouted through a different
> VIF than what was first installed in the MFC cache.  I would very much
> like to get these WRONGVIF assertions in this case, which is NOT the
> case that a packet is seen on an OIF.
>=20
> Of course I can simply enable MRT_PIM to get the messages, but in that
> case I don't understand the reason for having two separate toggles
> (MRT_ASSERT versus MRT_PIM).

I don't really understand you use case -- is this a case of another
router showing up on the subnet and directing traffic to it? If so, why
wasn't the first router directing traffic to it? Do you have a primary
multicast forwarder election system in place?


-David


--DSayHWYpDlRfCAAQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1eqHkACgkQpfBGV6DCGYYbhACffGhspK3HgsAgM/qU0YaOWOaO
xecAoI3LC+0Ks5OTiqBoXJst/Iw9a5J2
=EAQO
-----END PGP SIGNATURE-----

--DSayHWYpDlRfCAAQ--
