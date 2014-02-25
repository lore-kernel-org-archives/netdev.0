From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Tue, 25 Feb 2014 16:58:09 +0000
Message-ID: <1393347489.14067.5.camel@deadeye.wl.decadent.org.uk>
References: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
	 <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
	 <1393033796.15717.90.camel@deadeye.wl.decadent.org.uk>
	 <8ecfc5a6-7cb7-46ff-847e-4b081522eb9b@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ciqIBi8W2mlLjgUc/mYc"
Cc: "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"wang.liang82@zte.com.cn" <wang.liang82@zte.com.cn>,
	"cai.qu@zte.com.cn" <cai.qu@zte.com.cn>,
	"li.fengmao@zte.com.cn" <li.fengmao@zte.com.cn>,
	"long.chun@zte.com.cn" <long.chun@zte.com.cn>,
	David Miller <davem@davemloft.net>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38777 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052AbaBYQ6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 11:58:25 -0500
In-Reply-To: <8ecfc5a6-7cb7-46ff-847e-4b081522eb9b@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ciqIBi8W2mlLjgUc/mYc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-25 at 14:06 +0000, Sathya Perla wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> >=20
> > On Thu, 2014-02-20 at 09:39 +0000, Sathya Perla wrote:
> > > > -----Original Message-----
> > > > From: jiang.biao2@zte.com.cn [mailto:jiang.biao2@zte.com.cn]
> > > >
> > > >
> > > > From: Li Fengmao <li.fengmao@zte.com.cn>
> > > >
> > > > There will be packet drop with kernel param "swiotlb =3D force" on
> > > > Emulex 10Gb NIC using be2net driver. The problem is caused by
> > > > receiving skb without calling pci_unmap_page() in get_rx_page_info(=
).
> > > > rx_page_info->last_page_user is initialized to false in
> > > > be_post_rx_frags() when current frag are mapped in the first half o=
f
> > > > the same page with another frag. But in that case with
> > > > "swiotlb =3D force" param, data can not be copied into the page of
> > > > rx_page_info without calling pci_unmap_page, so the data frag mappe=
d
> > > > in the first half of the page will be dropped.
> > > >
> > > > It can be solved by creating only a mapping relation between frag
> > > > and page, and deleting rx_page_info->last_page_user to ensure
> > > > calling pci_unmap_page when handling each receiving frag.
> > >
> > > This patch uses an entire page for each RX frag (whose default size i=
s 2048).
> > > Consequently, on platforms like ppc64 where the default PAGE_SIZE is =
64K,
> > > memory usage becomes very inefficient.
> > >
> > > Instead, I've tried a partial-page mapping scheme. This retains the
> > > page sharing logic, but un-maps each frag separately so that
> > > the data is copied from the bounce buffers.
> > [...]
> >=20
> > You don't need to map/unmap each fragment separately; you can sync a
> > sub-page range with dma_sync_single_for_cpu().
> >=20
>=20
> Ben, after syncing each frag with a dma_sync_single_for_cpu() call,
> would I still need to dma_unmap_page() after DMA is done on all the frags
> of the page? I thought I needed to.

Yes.

> I'm confused to see that swiotlb_bounce() (that copies data from the boun=
ce buffers)
> is called from both swiotlb_sync_single_for_cpu() and swiotlb_unmap_page(=
).
> I ofcourse don't want the data to be copied from the bounce buffers twice=
!

Right, unmap includes a sync so you should:
- for the last frag per page, dma_unmap_page() only
- for every other frag, dma_sync_single_for_cpu() only

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-ciqIBi8W2mlLjgUc/mYc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwzLoee/yOyVhhEJAQqrrhAAutldMliz+iCMjx72KPIDoemd9faBCwfS
mg8HEQ2jEp/vjNFQQYzZSQCi4cWRcnUx71JJ7sG3dv3cCNuAiSKUiU7VgNktPvNK
5PajVyB48VpBYo40dh0TDJIw/gy0yvUKHgHSJ9RfJZo7AyoTTje2+u9nMLzPXJRB
AjDb3fudFkcqqZ3kkvydJsGuX+VZXKAySXOyqDiQqLg4Lh255Pxlb+lM7VPvVql8
dZDFcZEj06ym715tpyBV21WGxxvNhWT//8TN/jH5BY1mYu2nu/mDP1hiGS87Af+S
YFzTHd+L0zpjgmmGgSz34eDCD77S6+ZzsRyqAHBc/k1AS1tHButYGUCKHHEBuNWC
Grz0TbXuFzIDetvSUDtouf9pduCWnG0puWLhlPKYCaEJyk79vXJF2hXYLup/aXKh
KJnOQawFqIr+7SfRWGoxJj31lvCX1RLiAV5uQVI05OQdekiY50zf4iGwVuWIWC93
S8tZam7IIzvItIekS1pYFa7Jjau+BUMQN5SlPcYusd+bCWCUVsA1PjrCnr5k61p5
3kOd4uiFDHFKGLyLEz6U8nRirzMsHo1KIWt5i+NgGABU2oNUrsp8R8ZSzKT33TgK
GtrzgWQMy0EjEeIEBaCvVDzArWfJOZyycDwqJ7jx3ToXNqkbhRoWxfycXm4R8kh5
v1f65DmXP6M=
=Q7y4
-----END PGP SIGNATURE-----

--=-ciqIBi8W2mlLjgUc/mYc--
