From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Wed, 21 Oct 2015 20:57:34 +0200
Message-ID: <20151021185734.GD31646@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <55645140.1050209@citrix.com>
 <20150526220312.GA1358@mail-itl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="/Uq4LBwYP4y1W6pO"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Annie Li <annie.li@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45211 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755622AbbJUS5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 14:57:40 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 0599A205D3
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 14:57:40 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20150526220312.GA1358@mail-itl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/Uq4LBwYP4y1W6pO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=C3=B3recki w=
rote:
> On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> > On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> > > Hi all,
> > >=20
> > > I'm experiencing xen-netfront crash when doing xl network-detach while
> > > some network activity is going on at the same time. It happens only w=
hen
> > > domU has more than one vcpu. Not sure if this matters, but the backend
> > > is in another domU (not dom0). I'm using Xen 4.2.2. It happens on ker=
nel
> > > 3.9.4 and 4.1-rc1 as well.
> > >=20
> > > Steps to reproduce:
> > > 1. Start the domU with some network interface
> > > 2. Call there 'ping -f some-IP'
> > > 3. Call 'xl network-detach NAME 0'
> >=20
> > There's a use-after-free in xennet_remove().  Does this patch fix it?
>=20
> Unfortunately not. Note that the crash is in xennet_disconnect_backend,
> which is called before xennet_destroy_queues in xennet_remove.
> I've tried to add napi_disable and even netif_napi_del just after
> napi_synchronize in xennet_disconnect_backend (which would probably
> cause crash when trying to cleanup the same later again), but it doesn't
> help - the crash is the same (still in gnttab_end_foreign_access called
> from xennet_disconnect_backend).

Finally I've found some more time to debug this... All tests redone on
v4.3-rc6 frontend and 3.18.17 backend.

Looking at xennet_tx_buf_gc(), I have an impression that shared page
(queue->grant_tx_page[id]) is/should be freed in some other means than
(indirectly) calling to free_page via gnttab_end_foreign_access. Maybe the =
bug
is that the page _is_ actually freed somewhere else already? At least chang=
ing
gnttab_end_foreign_access to gnttab_end_foreign_access_ref makes the crash
gone.

Relevant xennet_tx_buf_gc fragment:
            gnttab_end_foreign_access_ref(
                queue->grant_tx_ref[id], GNTMAP_readonly);
            gnttab_release_grant_reference(
                &queue->gref_tx_head, queue->grant_tx_ref[id]);
            queue->grant_tx_ref[id] =3D GRANT_INVALID_REF;
            queue->grant_tx_page[id] =3D NULL;
            add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, id);
            dev_kfree_skb_irq(skb);

And similar fragment from xennet_release_tx_bufs:
        get_page(queue->grant_tx_page[i]);
        gnttab_end_foreign_access(queue->grant_tx_ref[i],
                      GNTMAP_readonly,
                      (unsigned long)page_address(queue->grant_tx_page[i]));
        queue->grant_tx_page[i] =3D NULL;
        queue->grant_tx_ref[i] =3D GRANT_INVALID_REF;
        add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i);
        dev_kfree_skb_irq(skb);

Note that both have dev_kfree_skb_irq, but the former use
gnttab_end_foreign_access_ref, while the later - gnttab_end_foreign_access.
Also note that the crash is in gnttab_end_foreign_access, so before
dev_kfree_skb_irq. If that would be double free, I'd expect crash in the la=
ter.

This change was introduced by cefe007 "xen-netfront: fix resource leak in
netfront". I'm not sure if changing gnttab_end_foreign_access back to
gnttab_end_foreign_access_ref would not (re)introduce some memory leak.

Let me paste again the error message:
[   73.718636] page:ffffea000043b1c0 count:0 mapcount:0 mapping:          (=
null) index:0x0
[   73.718661] flags: 0x3ffc0000008000(tail)
[   73.718684] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_coun=
t) =3D=3D 0)
[   73.718725] ------------[ cut here ]------------
[   73.718743] kernel BUG at include/linux/mm.h:338!

Also it all look quite strange - there is get_page() call just before
gnttab_end_foreign_access, but page->_count is still 0. Maybe it have somet=
hing
to do how get_page() works on "tail" pages (whatever it means)?

    static inline void get_page(struct page *page)
    {
        if (unlikely(PageTail(page)))
            if (likely(__get_page_tail(page)))
                return;
        /*
         * Getting a normal page or the head of a compound page
         * requires to already have an elevated page->_count.
         */
        VM_BUG_ON_PAGE(atomic_read(&page->_count) <=3D 0, page);
        atomic_inc(&page->_count);
    }

which (I think) ends up in:

    static inline void __get_page_tail_foll(struct page *page,
                        bool get_page_head)
    {
        /*
         * If we're getting a tail page, the elevated page->_count is
         * required only in the head page and we will elevate the head
         * page->_count and tail page->_mapcount.
         *
         * We elevate page_tail->_mapcount for tail pages to force
         * page_tail->_count to be zero at all times to avoid getting
         * false positives from get_page_unless_zero() with
         * speculative page access (like in
         * page_cache_get_speculative()) on tail pages.
         */
        VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <=3D 0, page);
        if (get_page_head)
            atomic_inc(&page->first_page->_count);
        get_huge_page_tail(page);
    }

So the use counter is incremented in page->first_page->_count, not
page->_count. But according to the comment, it should influence
page->_mapcount, but the error message says it does not.

Any ideas?

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--/Uq4LBwYP4y1W6pO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCAAGBQJWJ+AgAAoJENuP0xzK19csSuQH/1+b5cnuQ6pF+FlPw/9t0Bpl
/YgCr+J1eSgvg7zbAjlSW82S0UHCdpInWLZNNucxGq5eoghnOsbnMVTjg9h1cDHV
DhRpIFyYZQVwYR3MXY8dHpHHQEYiKMSrmHliT1omi+Vdz9thm/Xon8KCI0DAcUBE
qRRNoBgnRYme8JHyukJoYGc5V8X+nA8QWJsEtZVQuwS1BhRcmvfe0BrGJ+Kr2BVD
InwrbUseDt8KaP9VMV3Oo13JMZHbjyBEuNEGz/5MpO4T4gSmvXoFLbI7/sY3ed9/
BHnWd5HARNUfvziLlYb+9pJAO6feqQB8UkSNh152BurUCH0HwwyES4MpuWb1leE=
=GJOT
-----END PGP SIGNATURE-----

--/Uq4LBwYP4y1W6pO--
