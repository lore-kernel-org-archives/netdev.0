From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 08/11] nfs: disable data cache revalidation for swapfiles
Date: Mon, 16 Apr 2012 14:44:22 +0100
Message-ID: <20120416134422.GC2359@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
 <1334578675-23445-9-git-send-email-mgorman@suse.de>
 <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux-MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Linux-Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-NFS <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>,
	Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
To: Fred Isaman <iisaman-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2012 at 09:10:04AM -0400, Fred Isaman wrote:
> > <SNIP>
> > -static struct nfs_page *nfs_page_find_request_locked(struct page *=
page)
> > +static struct nfs_page *
> > +nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *=
page)
> > =A0{
> > =A0 =A0 =A0 =A0struct nfs_page *req =3D NULL;
> >
> > - =A0 =A0 =A0 if (PagePrivate(page)) {
> > + =A0 =A0 =A0 if (PagePrivate(page))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req =3D (struct nfs_page *)page_priv=
ate(page);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (req !=3D NULL)
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&req->wb_kre=
f);
> > + =A0 =A0 =A0 else if (unlikely(PageSwapCache(page))) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs_page *freq, *t;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Linearly search the commit list fo=
r the correct req */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_safe(freq, t, &nf=
si->commit_list, wb_list) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (freq->wb_page =3D=
=3D page) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D=
 freq;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break=
;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(req =3D=3D NULL);
>=20
> I suspect I am missing something, but why is it guaranteed that the
> req is on the commit list?
>=20

It's a fair question and a statement about what I expected to happen.
The commit list replaces the nfs_page_tree radix tree that used to exis=
t
and my understanding was that the req would exist in the radix tree unt=
il
the swap IO was completed. I expected it to be the same for the commit
list and the BUG_ON was based on that expectation. Are there cases wher=
e
the req would not be found?

Thanks.

--=20
Mel Gorman
SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
