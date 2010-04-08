From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: powerpc boot failure
Date: Thu, 8 Apr 2010 16:58:48 +1000
Message-ID: <20100408165848.38f75f40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__8_Apr_2010_16_58_48_+1000_YAINVecS+pk+udO."
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Timo =?UTF-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:52555 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758408Ab0DHG65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 02:58:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__8_Apr_2010_16_58_48_+1000_YAINVecS+pk+udO.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi ,

Today's linux-next (20100408) failed a powerpc boot test like this:

[While bringing up the network interfaces ...]

Unable to handle kernel paging request for data at address 0x200000025
Faulting instruction address: 0xc00000000053d32c
cpu 0x5: Vector: 300 (Data Access) at [c0000000bb277680]
    pc: c00000000053d32c: .__xfrm_lookup+0x32c/0x4c0
    lr: c0000000004e6e10: .ip_route_output_flow+0xb0/0x300
    sp: c0000000bb277900
   msr: 8000000000009032
   dar: 200000025
 dsisr: 40000000
  current =3D 0xc0000000bce55640
  paca    =3D 0xc000000007691a00
    pid   =3D 4106, comm =3D ntpdate
[c0000000bb277a20] c0000000004e6e10 .ip_route_output_flow+0xb0/0x300
[c0000000bb277ad0] c0000000005158c8 .ip4_datagram_connect+0x1a8/0x2f0
[c0000000bb277bd0] c000000000523dc0 .inet_dgram_connect+0x80/0x110
[c0000000bb277c60] c0000000004a6904 .SyS_connect+0xa4/0xf0
[c0000000bb277d90] c0000000004d5f48 .compat_sys_socketcall+0x128/0x2f0
[c0000000bb277e30] c00000000000852c syscall_exit+0x0/0x40

The most obvious suspect is commit
80c802f3073e84c956846e921e8a0b02dfa3755f ("xfrm: cache bundles instead of
policies for outgoing flows") and the couple of commits around that
(these are new to linux-next today).

The above pc is in this piece of code (I think - I don't have the actual
kernel) from __xfrm_lookup (in net/xfrm/xfrm_policy.c):

        if ((flags & XFRM_LOOKUP_ICMP) &&
            !(pols[0]->flags & XFRM_POLICY_ICMP)) {
                err =3D -ENOENT;
                goto error;
        }

        for (i =3D 0; i < num_pols; i++)
                pols[i]->curlft.use_time =3D get_seconds(); <-------- (line=
 1845)

And the 0x200000025 is probably &(pols[i]) (which actually seems unlikely
since pols is an array on the stack).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__8_Apr_2010_16_58_48_+1000_YAINVecS+pk+udO.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAku9fqgACgkQjjKRsyhoI8wiKQCfat2gTZuQik7gOjMylG7fmovw
PQkAoI8+Oi+1/zWus+GaB5GahEQ+vZs5
=ty+C
-----END PGP SIGNATURE-----

--Signature=_Thu__8_Apr_2010_16_58_48_+1000_YAINVecS+pk+udO.--
