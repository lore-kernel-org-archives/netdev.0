From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Tue, 17 Nov 2015 03:45:15 +0100
Message-ID: <20151117024515.GN976@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <55645140.1050209@citrix.com>
 <20150526220312.GA1358@mail-itl>
 <20151021185734.GD31646@mail-itl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="/9ZOS6odDaRI+0hI"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Annie Li <annie.li@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47154 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730AbbKQCpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 21:45:22 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 9F5A0205B3
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 21:45:21 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20151021185734.GD31646@mail-itl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/9ZOS6odDaRI+0hI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 21, 2015 at 08:57:34PM +0200, Marek Marczykowski-G=C3=B3recki w=
rote:
> On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=C3=B3recki=
 wrote:
> > On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> > > On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> > > > Hi all,
> > > >=20
> > > > I'm experiencing xen-netfront crash when doing xl network-detach wh=
ile
> > > > some network activity is going on at the same time. It happens only=
 when
> > > > domU has more than one vcpu. Not sure if this matters, but the back=
end
> > > > is in another domU (not dom0). I'm using Xen 4.2.2. It happens on k=
ernel
> > > > 3.9.4 and 4.1-rc1 as well.
> > > >=20
> > > > Steps to reproduce:
> > > > 1. Start the domU with some network interface
> > > > 2. Call there 'ping -f some-IP'
> > > > 3. Call 'xl network-detach NAME 0'
> > >=20
> > > There's a use-after-free in xennet_remove().  Does this patch fix it?
> >=20
> > Unfortunately not. Note that the crash is in xennet_disconnect_backend,
> > which is called before xennet_destroy_queues in xennet_remove.
> > I've tried to add napi_disable and even netif_napi_del just after
> > napi_synchronize in xennet_disconnect_backend (which would probably
> > cause crash when trying to cleanup the same later again), but it doesn't
> > help - the crash is the same (still in gnttab_end_foreign_access called
> > from xennet_disconnect_backend).
>=20
> Finally I've found some more time to debug this... All tests redone on
> v4.3-rc6 frontend and 3.18.17 backend.
>=20
> Looking at xennet_tx_buf_gc(), I have an impression that shared page
> (queue->grant_tx_page[id]) is/should be freed in some other means than
> (indirectly) calling to free_page via gnttab_end_foreign_access. Maybe th=
e bug
> is that the page _is_ actually freed somewhere else already? At least cha=
nging
> gnttab_end_foreign_access to gnttab_end_foreign_access_ref makes the crash
> gone.
>=20
> Relevant xennet_tx_buf_gc fragment:
>             gnttab_end_foreign_access_ref(
>                 queue->grant_tx_ref[id], GNTMAP_readonly);
>             gnttab_release_grant_reference(
>                 &queue->gref_tx_head, queue->grant_tx_ref[id]);
>             queue->grant_tx_ref[id] =3D GRANT_INVALID_REF;
>             queue->grant_tx_page[id] =3D NULL;
>             add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i=
d);
>             dev_kfree_skb_irq(skb);
>=20
> And similar fragment from xennet_release_tx_bufs:
>         get_page(queue->grant_tx_page[i]);
>         gnttab_end_foreign_access(queue->grant_tx_ref[i],
>                       GNTMAP_readonly,
>                       (unsigned long)page_address(queue->grant_tx_page[i]=
));
>         queue->grant_tx_page[i] =3D NULL;
>         queue->grant_tx_ref[i] =3D GRANT_INVALID_REF;
>         add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i);
>         dev_kfree_skb_irq(skb);
>=20
> Note that both have dev_kfree_skb_irq, but the former use
> gnttab_end_foreign_access_ref, while the later - gnttab_end_foreign_acces=
s.
> Also note that the crash is in gnttab_end_foreign_access, so before
> dev_kfree_skb_irq. If that would be double free, I'd expect crash in the =
later.
>=20
> This change was introduced by cefe007 "xen-netfront: fix resource leak in
> netfront". I'm not sure if changing gnttab_end_foreign_access back to
> gnttab_end_foreign_access_ref would not (re)introduce some memory leak.
>=20
> Let me paste again the error message:
> [   73.718636] page:ffffea000043b1c0 count:0 mapcount:0 mapping:         =
 (null) index:0x0
> [   73.718661] flags: 0x3ffc0000008000(tail)
> [   73.718684] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_co=
unt) =3D=3D 0)
> [   73.718725] ------------[ cut here ]------------
> [   73.718743] kernel BUG at include/linux/mm.h:338!
>=20
> Also it all look quite strange - there is get_page() call just before
> gnttab_end_foreign_access, but page->_count is still 0. Maybe it have som=
ething
> to do how get_page() works on "tail" pages (whatever it means)?
>=20
>     static inline void get_page(struct page *page)
>     {
>         if (unlikely(PageTail(page)))
>             if (likely(__get_page_tail(page)))
>                 return;
>         /*
>          * Getting a normal page or the head of a compound page
>          * requires to already have an elevated page->_count.
>          */
>         VM_BUG_ON_PAGE(atomic_read(&page->_count) <=3D 0, page);
>         atomic_inc(&page->_count);
>     }
>=20
> which (I think) ends up in:
>=20
>     static inline void __get_page_tail_foll(struct page *page,
>                         bool get_page_head)
>     {
>         /*
>          * If we're getting a tail page, the elevated page->_count is
>          * required only in the head page and we will elevate the head
>          * page->_count and tail page->_mapcount.
>          *
>          * We elevate page_tail->_mapcount for tail pages to force
>          * page_tail->_count to be zero at all times to avoid getting
>          * false positives from get_page_unless_zero() with
>          * speculative page access (like in
>          * page_cache_get_speculative()) on tail pages.
>          */
>         VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <=3D 0, pag=
e);
>         if (get_page_head)
>             atomic_inc(&page->first_page->_count);
>         get_huge_page_tail(page);
>     }
>=20
> So the use counter is incremented in page->first_page->_count, not
> page->_count. But according to the comment, it should influence
> page->_mapcount, but the error message says it does not.
>=20
> Any ideas?

Ping?

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--/9ZOS6odDaRI+0hI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCAAGBQJWSpS7AAoJENuP0xzK19csSGgH/1Qqk7PFZ+lWjI0EhPicSDbk
P1Hf3gTJ4iDEcvJxhfFwK4vc0a6HlmPlBI5h7GnJLzwJ4x36f+jc1Vi+B421T7Uk
Pti2hhr2jvSbCJ80S/UyjLvR+lVhPHpxfa3XqXduec8QAhkf5tkRB0MvoMbKsn5X
C0Kal7s5M97eQco0mApUpgQKcf1JeGVwJpLmY4MUWHwlY0ORZytRfkd9F4qmb0yO
snueBGeFLR5HS7QNihX17r1tNr75it1NQipw0tOB+etUB7sbsLcgmaYW6wjEIGvP
lGT/C82Qu4yGDLauEKqjW1MHAdyNUN3S9+ixN71v5A+nyZIdCNLi6Kpd3Fg2u3k=
=CI6X
-----END PGP SIGNATURE-----

--/9ZOS6odDaRI+0hI--
