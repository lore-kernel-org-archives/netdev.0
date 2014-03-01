From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Sat, 01 Mar 2014 01:00:52 +0000
Message-ID: <1393635652.14067.104.camel@deadeye.wl.decadent.org.uk>
References: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
	 <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
	 <1393033796.15717.90.camel@deadeye.wl.decadent.org.uk>
	 <8ecfc5a6-7cb7-46ff-847e-4b081522eb9b@CMEXHTCAS1.ad.emulex.com>
	 <1393347489.14067.5.camel@deadeye.wl.decadent.org.uk>
	 <ae566d8f-6535-4c6c-9c4e-463617b92a65@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1gREJwwyFcG7mgGO6VAS"
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
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50250 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbaCABBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 20:01:12 -0500
In-Reply-To: <ae566d8f-6535-4c6c-9c4e-463617b92a65@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1gREJwwyFcG7mgGO6VAS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-26 at 04:54 +0000, Sathya Perla wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> >=20
> ...
> > > > > >
> > > > > > From: Li Fengmao <li.fengmao@zte.com.cn>
> > > > > >
> > > > > > There will be packet drop with kernel param "swiotlb =3D force"=
 on
> > > > > > Emulex 10Gb NIC using be2net driver. The problem is caused by
> > > > > > receiving skb without calling pci_unmap_page() in get_rx_page_i=
nfo().
> > > > > > rx_page_info->last_page_user is initialized to false in
> > > > > > be_post_rx_frags() when current frag are mapped in the first ha=
lf of
> > > > > > the same page with another frag. But in that case with
> > > > > > "swiotlb =3D force" param, data can not be copied into the page=
 of
> > > > > > rx_page_info without calling pci_unmap_page, so the data frag m=
apped
> > > > > > in the first half of the page will be dropped.
> > > > > >
> > > > > > It can be solved by creating only a mapping relation between fr=
ag
> > > > > > and page, and deleting rx_page_info->last_page_user to ensure
> > > > > > calling pci_unmap_page when handling each receiving frag.
> > > > >
> > > > > This patch uses an entire page for each RX frag (whose default si=
ze is 2048).
> > > > > Consequently, on platforms like ppc64 where the default PAGE_SIZE=
 is 64K,
> > > > > memory usage becomes very inefficient.
> > > > >
> > > > > Instead, I've tried a partial-page mapping scheme. This retains t=
he
> > > > > page sharing logic, but un-maps each frag separately so that
> > > > > the data is copied from the bounce buffers.
> > > > [...]
> > > >
> > > > You don't need to map/unmap each fragment separately; you can sync =
a
> > > > sub-page range with dma_sync_single_for_cpu().
> > > >
> > >
> > > Ben, after syncing each frag with a dma_sync_single_for_cpu() call,
> > > would I still need to dma_unmap_page() after DMA is done on all the f=
rags
> > > of the page? I thought I needed to.
> >=20
> > Yes.
> >=20
> > > I'm confused to see that swiotlb_bounce() (that copies data from the =
bounce buffers)
> > > is called from both swiotlb_sync_single_for_cpu() and swiotlb_unmap_p=
age().
> > > I ofcourse don't want the data to be copied from the bounce buffers t=
wice!
> >=20
> > Right, unmap includes a sync so you should:
> > - for the last frag per page, dma_unmap_page() only
> > - for every other frag, dma_sync_single_for_cpu() only
>=20
> Ben, the dma_unmap_page() requires us to pass the same dma_addr and size =
returned by
> (and passed to) the dma_map_page() call.
> So, for the last frag, when I call dma_map_page() with the page_addr (and=
 not the frag_addr) and the
> page size, won't it try to copy the data belonging to all the previous fr=
ags of page again?!!

When using bounce buffers (e.g. swiotlb), yes this results in another
copy, which is inefficient.  But when using a real IOMMU neither
function will copy.  I would optimise for IOMMUs.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-1gREJwwyFcG7mgGO6VAS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxExROe/yOyVhhEJAQrd2A//SI/eck69VGGsSX+/XCwQWeg1ayQcegnU
3OsD5MktARl9e5pRdmdeFApC1UiRvq38P3JLvC2HuYp8zMD06uTIR/QtzXWUH5IO
yBbTmcOmTRy/+k5DaLMEh4VQ9e0jJ2MBaWJYNMdOHaWo5N/58VcBG4DlVB5nwJJw
wkq7Mf9i7oKenlw48IFOcQBd3D6hD2ByDV4KY8HS9In6B7kSP+vIYFZi9qmBl3O9
UVVMg6nbJ+Gb83J9uOBLaR4GOeeGiFmvVUwsn/wmmYEZD30JJ1WIJ4+nssM3+bO/
VVX66Q7fNNmvdto7uK2atmCDu9vStD8C5knO7xomNhFQTxcsDxRvehhoQgaP6L3y
DI8sx86KzeozdctmsjE8TgIOxY+/DUVcGJ6pRhQOnISmZi94hjR0e+DW0VEdhbY9
S0H8jgE0mxsYkETX9AN8sQtjwde7n5kxnz3fymXsLnMrWEivDD4YK6VpRjtnHYox
IjiFy7Pwc/IY4gvtC+hi3QZtMYnwcYG2VJgeulSXzcqz52bch/7TSNUHjx8YRDFr
jX8a56+wUcUbunvKWPdgmt//1MTgOduyHO3wqCWa9igyRMIp5p3sE+2OFR6/T9Je
dKcUJxh0q6GUOw9wa/GizaDIzX8y8m/n1XjP9SOz3+sPsTpZXcsp7k5frEilWXw5
HCIX5lmuKKk=
=bA9W
-----END PGP SIGNATURE-----

--=-1gREJwwyFcG7mgGO6VAS--
