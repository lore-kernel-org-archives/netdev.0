From: Stefan Bader <stefan.bader@canonical.com>
Subject: xen-netfront possibly rides the rocket too often
Date: Tue, 13 May 2014 20:21:31 +0200
Message-ID: <537262AB.5010408@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="oOum5wo88OQkkSrVjAiKKhx7ntHtkgRiX"
To: xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56124 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbaEMSVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 14:21:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oOum5wo88OQkkSrVjAiKKhx7ntHtkgRiX
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

We had reports about this message being seen on EC2 for a while but final=
ly a
reporter did notice some details about the guests and was able to provide=
 a
simple way to reproduce[1].

For my local experiments I use a Xen-4.2.2 based host (though I would say=
 the
host versions are not important). The host has one NIC which is used as t=
he
outgoing port of a Linux based (not openvswitch) bridge. And the PV guest=
s use
that bridge. I set the mtu to 9001 (which was seen on affected instance t=
ypes)
and also inside the guests. As described in the report one guests runs
redis-server and the other nodejs through two scripts (for me I had to do=
 the
two sub.js calls in separate shells). After a bit the error messages appe=
ar on
the guest running the redis-server.

I added some debug printk's to show a bit more detail about the skb and g=
ot the
following (<length>@<offset (after masking off complete pages)>):

[ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 698.108134] header 1490@238 -> 1 slots
[ 698.108139] frag #0 1614@2164 -> + 1 pages
[ 698.108143] frag #1 3038@1296 -> + 2 pages
[ 698.108147] frag #2 6076@1852 -> + 2 pages
[ 698.108151] frag #3 6076@292 -> + 2 pages
[ 698.108156] frag #4 6076@2828 -> + 3 pages
[ 698.108160] frag #5 3038@1268 -> + 2 pages
[ 698.108164] frag #6 2272@1824 -> + 1 pages
[ 698.108168] frag #7 3804@0 -> + 1 pages
[ 698.108172] frag #8 6076@264 -> + 2 pages
[ 698.108177] frag #9 3946@2800 -> + 2 pages
[ 698.108180] frags adding 18 slots

Since I am not deeply familiar with the networking code, I wonder about t=
wo things:
- is there something that should limit the skb data length from all frags=

  to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
- is multiple frags having offsets expected?

The latter is the problem here. If I did the maths right, the overall dat=
a size
is around 41K. But since frags 1,4,5, and 9 have an offset big enough to =
require
an additional page, the overall slot count goes up to 19.

If such a layout is valid, maybe the xen-netfront driver needs to reduce =
its
XEN_NETIF_MAX_TX_SIZE which currently is set to 64K? Or something else...=


-Stefan

[1] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1317811


--oOum5wo88OQkkSrVjAiKKhx7ntHtkgRiX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTcmKrAAoJEOhnXe7L7s6jSMYQAJV2pQHHDDw2/pSwBOJKUJqP
wL+Q9MchPjNvpagc+SSprw74rF+Grp0hiAMLlWGzjSRMvUNpYuA6cskViQXF9ko5
puIxLPwv60lifdnOzz7KYf5HzeN0IW5ZcPT9AX3agRbKWxZNz76qmGc/31aewv3c
yEoSAqXD3qAJyQyFafg6yz3C9D5y2HcbAEET4Gqvqwl2ze7MbzPBfPOodJobuLx2
Z4vfD0zNIYNOzruCoMNnOQ6EpXPQ96IXZ4UU+TKSlo0cMVMQ/LUyHWSdKsN9m14D
oux65wTDzolYHENeHJAYz9m3QycaFFbcqHjFSiQVfHASv+3o+nhvgRVY70Lu1Ml4
2J1s94g8MNCVjYePDdDRfUjanCGMxMEfXG3JnCYcom2mQWj+aZal/xQEJA9siONn
IjFYDkLmI+6i3yKuiVPS36CRrHG+C3hKZrIkm/ebrRvkOuVhgFYkEg8ULhB1jmoI
JzFSjFVZgKTmf4byv9RhdSPn2UhdBRNP0Y735Nk/v07GOPLsjzt9BQGW+Yst1lGL
HgEtB9yFrnwPWXWsTLM1//ikxZFsDpXgNq39v80WcKdhmZQTQan4iFbXvnrfCQay
bPBZADwF3cIURy0NcPjI772RQD4vSWeS3ERDXESAkksNzXyqo8wZ36lXeBjUd8KU
9t8y6YionqRG8UvTygqu
=sLUN
-----END PGP SIGNATURE-----

--oOum5wo88OQkkSrVjAiKKhx7ntHtkgRiX--
