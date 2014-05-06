From: Steven Haigh <netwiz@crc.id.au>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Wed, 07 May 2014 03:07:53 +1000
Message-ID: <536916E9.7010509@crc.id.au>
References: <395225650.20140430124506@eikelenboom.it>	<536162D3.5080307@citrix.com>	<94755525.20140501002553@eikelenboom.it>	<53624E25.8040404@citrix.com>	<1810270947.20140501155911@eikelenboom.it>	<53626C39.3030304@citrix.com>	<928229683.20140501193936@eikelenboom.it>	<198418193.20140501213951@eikelenboom.it>	<5363A508.1000602@citrix.com>	<653156457.20140502160632@eikelenboom.it>	<5363AFED.5080601@citrix.com>	<1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>	<5363B929.1000502@citrix.com>	<35970097.20140502182818@eikelenboom.it>	<5363CBB0.6050804@citrix.com> <15602339.20140505121912@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DVs6cmM9hnlNRJKnFmM5bUe22oJbhl5kc"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, xen-devel@lists.xen.org
To: Sander Eikelenboom <linux@eikelenboom.it>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.crc.id.au ([203.56.246.92]:59873 "EHLO mail.crc.id.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbaEFRNO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 13:13:14 -0400
In-Reply-To: <15602339.20140505121912@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DVs6cmM9hnlNRJKnFmM5bUe22oJbhl5kc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On a related note, I'm seeing this on an Arch Linux DomU and kernel
3.14.2. Its running aria2c bit torrent client.

The Dom0 is EL6 with Xen 4.2.4 / 3.14.2 kernel.

I also lodged this on the Arch bug tracker:
	https://bugs.archlinux.org/task/40244

In a nutshell, I see:
[ 7432.398096] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7434.270870] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7434.782199] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7435.184794] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7437.530677] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7437.973905] xen_netfront: xennet: skb rides the rocket: 19 slots
[ 7438.383947] xen_netfront: xennet: skb rides the rocket: 19 slots

On 05/05/14 20:19, Sander Eikelenboom wrote:
>=20
> Hi Zoltan,
>=20
> This weekend i tried some more things, the summary:
>=20
>=20
> 1) It's a PITA to isolate your patches that went into 3.15 (to rule out=
 any other changes) and apply=20
>    them to 3.14.2, which is tested and worked ok. Could you put up a gi=
t tree=20
>    somewhere and rebase your patch series on 3.14.2 for testing ?
>=20
> 2) Does the test suite you are using also has tests verifying that the =
content of packets isn't altered ?
>=20
> 3) It's possible to simplify the test case to a apache webdav server an=
d a=20
>    simple curl put, this simplifies testing and puts ssl and duplicity =
out of the equation.
>=20
> 4) There seem to be (at least) two, from the eye of it, separate issues=
 with=20
>    netback / netfront.
>    a) Assumption that  "An upstream guest shouldn't be able to send 18 =
slots" is=20
>       false, which probably triggers the netback tx_frag_overflow case.=

>    b) Corruption of packet content when:
>           - sending packets between guests on the same routed network b=
ridge,
>           - sending packets between host (dom) and guest goes ok.
>    c) Both a and b are regressions from 3.14(.2), although at least a) =
seems just=20
>       uncovering a latent bug revealed by changed semantics.
>=20
> 5) Test outcome
>=20
> --
> Sander
>=20
> Ad 1) git tree somewhere and rebase your patch series on 3.14.2:
>     This is of course unless you are able to trigger this yourself and =
debug it with the simplified testcase described in (3).
>=20
> Ad 3) simplify the test case:
>     My current setup:
>     - working: host kernel 3.14.2 and guest kernels all 3.15-rc4 on Deb=
ian wheezy
>     - not working: host and guest kernels all 3.15-rc4 on Debian wheezy=
 (.config attached)
>     - not working: host and guest kernels all 3.15-rc4 + Eric's patch o=
n Debian wheezy (.config attached)
> =20
>     - guests are on a routed bridge (normal linux kernel bridge which i=
s routed=20
>       with eth0 and eth1.
>     - receiving guest has apache 2.2 running with mod_dav.
>=20
>     - test:
>           - create a 100mb testfile with a pattern (used perl script is=
 attached)
>           - Use curl in dom0 or in the sending guest to send the testfi=
le:
>             curl --upload-file testfile.bin http://webdav-guest/storage=
location/
>           - check the md5sum of testfile.bin on both sender and receive=
r
>=20
> Ad 4a) Assumption that  "An upstream guest shouldn't be able to send 18=
 slots":
>     - xen-netfront does this slot check in "xennet_start_xmit":
>         slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>                 xennet_count_skb_frag_slots(skb);
>         if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
>                 net_alert_ratelimited(
>                         "xennet: skb rides the rocket: %d slots\n", slo=
ts);
>                 goto drop;
>         }
>=20
>     - The "MAX_SKB_FRAGS + 1" was changed due to: http://www.gossamer-t=
hreads.com/lists/xen/devel/266980,
>       but it doesn't seem to be the proper solution.
>     - So your assumption doesn't hold, MAX_SKB_FRAGS=3D=3D17, so 18 slo=
ts can come through.
>     - On 3.15-rc4 i now started to see this warning getting triggered a=
nd packets dropped, i don't see this on 3.14.2:
>       [  118.526583] xen_netfront: xennet: skb rides the rocket: 19 slo=
ts | skb_shinfo(skb)->nr_frags: 3, len: 186, offset: 4070, skb->len: 6233=
0, skb->data_len: 62144, skb->truesize: 63424, np->tx.sring->rsp_prod: 21=
434, np->tx.rsp_cons: 21434  DIV_ROUND_UP(offset + len, PAGE_SIZE): 2=20
>     - So probably some change in semantics makes this thing popup again=
=2E
>     - What i don't understand is why in:
>       xen-netfront this slots check is done when the skb is already deq=
ueued (so dropping is the only thing left to do),
>       while in xen-netback it is done before the packet is dequeued (wh=
ich now seems to work correct since the fixup of Paul to 3.14)
>=20
>     - so your assumption isn't true, but it seems netfront needs to be =
fixed for that.
>=20
>     - A lot of the (slot) checking logic and frag handling seems to be =
about the same in xen-netfront and xen-netback, although they seem to hav=
e diverted
>       somewhat, wouldn't it make sense to put a lot of the generic help=
er functions in a xen-netcommon.c and share them ?
>=20
> Ad 4b) Corruption of packet content:
>     -  The dom0 case doesn't use zerocopy (tx_zerocopy_success: 0 &&  t=
x_frag_overflow: 0)
>     -  I'm getting less convinced it's (directly) coupled to (4a) and t=
he tx_frag_overflow case, although they can occur at about the same time,=
 it
>        doesn't necesarrily, the testfile is also corrupt when there is =
no tx_frag_overflow reported for both vifs:
>            ethtool -S vif2.0 (sender)
>            NIC statistics:
>            rx_gso_checksum_fixup: 0
>            tx_zerocopy_sent: 25705
>            tx_zerocopy_success: 25538
>            tx_zerocopy_fail: 167
>            tx_frag_overflow: 0
>           =20
>            ethtool -S vif1.0 (receiver)
>            NIC statistics:
>            rx_gso_checksum_fixup: 0
>            tx_zerocopy_sent: 246916
>            tx_zerocopy_success: 1
>            tx_zerocopy_fail: 246915
>            tx_frag_overflow: 0
>=20
>=20
> Ad 5) The test described in (3) results into (repeated 5 times each) th=
ese md5sums for testfile.bin::
>     - generated file: fe599e44789799bae5b6db3df9a34e2d
>    =20
>     - dom0 3.14.2        - dom0 to guest:  fe599e44789799bae5b6db3df9a3=
4e2d
>     - dom0 3.14.2        - guest to guest: fe599e44789799bae5b6db3df9a3=
4e2d
>    =20
>     - dom0 3.15-rc4      - dom0 to guest:  fe599e44789799bae5b6db3df9a3=
4e2d
>     - dom0 3.15-rc4      - guest to guest: 2f51d9baad6f7b2c99aa51e14878=
a55a fb7df5de7d08b6ad24aa9166949de8c9 0c0afc145f4fed9231e4f1ab6243d02f ef=
83ace3aafd7e57b8b2fbe324d38995 ffab10c9906381415e5697d2c0e05da3
>    =20
>     - dom0 3.15-rc4+eric - dom0 to guest:  fe599e44789799bae5b6db3df9a3=
4e2d
>     - dom0 3.15-rc4+eric - guest to guest: eb8f48c5613478bb0a69a6115570=
c713 66fc191b4a04ccddd8b926bc2f57c2b9 99891e0397ca119b0cfaea80b0c6b1f0 08=
99ab428d102791345c67fa4b608b36 4cc2e3badabc465630d8002004fc0fa3
>=20
>    - That's no good for the guest to guest case .. so inspect the recei=
ved testfile.bin:
>      - length is exactly the same .. good
>      - beginning and ending magic strings are there .. good
>      - the md5sums differ every time .. no good
>      - diff the files to see what is different (one diff from the hexdu=
mps is attached):
>          - although the byte counting strings should be unique, in the =
received testfile.bin they are not, for example:
>                grep -i -n 76234752 testfile2.hex
>                4764674:048b4010  20 20 20 20 20 20 20 20  37 36 32 33 3=
4 37 35 32  |        76234752|
>                4764930:048b5010  20 20 20 20 20 20 20 20  37 36 32 33 3=
4 37 35 32  |        76234752|
>=20
>     - So what do we have so far:
>         - it look likes all packet metadata is correct, so no warnings =
or errors from the network stack.
>         - only the actual payload gets mangled (otherwise i would have =
expected warnings from the network stack)
>         - it seems to only get mangled when it is travelling "xen-netfr=
ont -> xen-netback -> linux netw. bridge -> xen-netback -> xen-netfront".=

>         - it seems NOT to get mangled when it is travelling "xen-netbac=
k -> xen-netfront" only.
>         - it's not random corruption, it seems data from older/other fr=
ags/packets is used instead of the right data.
>         - and a simple test case ... so i hope you can reproduce.
>=20
> --
> Sander
>=20
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20


--=20
Steven Haigh

Email: netwiz@crc.id.au
Web: http://www.crc.id.au
Phone: (03) 9001 6090 - 0412 935 897
Fax: (03) 8338 0299


--DVs6cmM9hnlNRJKnFmM5bUe22oJbhl5kc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTaRbpAAoJEEGvNdV6fTHc7eMP/0zaQtI3pa2DmSHORCLBz/px
LE0gmZ0m/hgCdfNRzQx11W3vnffWzMGSxpj+Op3xy2wPA7bXttx8sY1XU4ucSwMN
NlgWPBkQC7OGLt4SnJnxpq/SCpXmsMp7ux09UYsChgUiGLAE7GUjfCOcnuonxG1L
Rqq/jQwImQCgUCzStRDmT6+b7NS2xNQ5u3d0qU0/e6MXKXrdeMZIkcImTo+TGm41
3c1QVRcgCgGLxbDX+Ux34zTgNZO0er1YLRUGYwXJHFS6NE+/3IOxDbipjUNReEZO
fzqlUacftFkjZENnTL4+K0K17WrDxgCL03T1HytgBV5d8xPgEXqA7F7uhkAeIjJI
2/EqOTZKUmDvNLBB0XB2Gb/7EymT/Z3mpxXCS8caCfJCE8DP9rJnVqcKeTORjU+/
WOck5ig7ucoo3ibnsRqF7iPgy5aGj2PsI1lPUgA5ATNVWdFiQrRW8R4ZayEJcmqb
oMYmifVG0y6+W8jL+CoUUdX/yD2rEa3UGXuWFw4FEyyQZDkcIWbrMWGsUXNBtjMG
cNCj0H9VrL9KEVXXO2JBrQyEicMteY33r3g/I9qoY/3NrwxJhDHr4uAbcthpRTyE
EZUwOLeJyGL7Lui89GUTijX2GV5H5BCPTiN6GHHS6FkxBjM3fNdly9ge08lTeCRC
CKG7TLqVntXZ3xpIOWpI
=eIKr
-----END PGP SIGNATURE-----

--DVs6cmM9hnlNRJKnFmM5bUe22oJbhl5kc--
