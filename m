From: Ben Hutchings <ben@decadent.org.uk>
Subject: IPv6 UFO for VMs
Date: Wed, 22 Oct 2014 00:44:05 +0100
Message-ID: <1413935045.5994.2.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7484912238815775305=="
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: netdev <netdev@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============7484912238815775305==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-V2wfc0Zp4YD4ovVO7COI"


--=-V2wfc0Zp4YD4ovVO7COI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

There are several ways that VMs can take advantage of UFO and get the
host to do fragmentation for them:

drivers/net/macvtap.c:                  gso_type =3D SKB_GSO_UDP;
drivers/net/tun.c:                      skb_shinfo(skb)->gso_type =3D SKB_G=
SO_UDP;
drivers/net/virtio_net.c:                       skb_shinfo(skb)->gso_type =
=3D SKB_GSO_UDP;

Our implementation of UFO for IPv6 does:

		fptr =3D (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
		fptr->nexthdr =3D nexthdr;
		fptr->reserved =3D 0;
		fptr->identification =3D skb_shinfo(skb)->ip6_frag_id;

which assumes ip6_frag_id has been set.  That's only true if the local
stack constructed the skb; otherwise it appears we get zero.

This seems to be a regression as a result of:

commit 916e4cf46d0204806c062c8c6c4d1f633852c5b6
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Fri Feb 21 02:55:35 2014 +0100

    ipv6: reuse ip6_frag_id from ip6_ufo_append_data

However, that change seems reasonable - we *shouldn't* be choosing IDs
for any other stack.  Any paravirt net driver that can use IPv6 UFO
needs to have some way of passing a fragmentation ID to put in
skb_shared_info::ip6_frag_id.

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-V2wfc0Zp4YD4ovVO7COI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVEbvyue/yOyVhhEJAQoquQ/+JHzLuxmgpNH75qtzrsRijEhonzKi+Sr4
YSwnDh7VYBBq11CB15WOtg4PEBkvl8S66AwEhgTJbllWUWDOCFmsgKUHmGOzHDIm
hiq8tnXieGMKkyqn1i5JaJAp/r3VeA3LDacdlHBg/fWpjFlB8v2FOoKUDNY3kmV6
YanhnBpiAVoSpaK7gjZT+9XS+jVEHnsJ5VYM4jfhwr7wyD7ccXzXAuyoO9cw3d+j
s67bUdCwFoLGKCrioAjg2CWiWYI4AeMCEIlLOdaPrVbuhgH7f+zTEhxzdPv0TP6z
hEnk/SaZx9Z148pan3atBc4+zIj1VP2K6odXKJMy+24FS1h9O8SPyOykjMqEqzBA
ugQsKH0TRGp/9Z/pU+GpzUq8JJir1jiJIrQRSRe/zFodPIB8ppYsLKT9Za8g6jHi
mpuBayJl3CoM3IeieHM8K9mb6TyGsPsIl9+lDmMoDQj1B6JaKt24sIXVKPD7c/El
QiSk4FIAqsiNGQ6+cmq6pJvsrOCyPCEyp52SzViZL9r+mTINBd76hwPt3uFSkIi7
XDq4WiivwXr+7Dr59EfyNnWbjqyLicuk0dRzxnnmxbXiyogXlPo+0CULpfZdXpfF
BJZDVfFy+Onoqi5GGfGGpKxYJiP9TQHmwbhgOU9Jis5mK7YEOgroON9j2XAFfwhS
6peYWwOg69I=
=gres
-----END PGP SIGNATURE-----

--=-V2wfc0Zp4YD4ovVO7COI--

--===============7484912238815775305==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7484912238815775305==--
