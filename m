From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd oops with 2.6.5-rc2-mm4
Date: Mon, 29 Mar 2004 11:03:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16487.30191.933378.175350@notabene.cse.unsw.edu.au>
References: <20040327130757.GA6760@c9x.org>
	<Pine.LNX.4.58.0403271816450.20100@ppc970.osdl.org>
	<1080511633.5553.29.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Bruce Allan <bwa@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Linus Torvalds <torvalds@osdl.org>, David S Miller <davem@redhat.com>,
        Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
In-Reply-To: message from Trond Myklebust on Sunday March 28
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday March 28, trond.myklebust@fys.uio.no wrote:
> P=E5 lau , 27/03/2004 klokka 21:30, skreiv Linus Torvalds:
> > This oops is on a=20
> >=20
> > 	lock incl 0x4(%edx)
> >=20
> > and as far as I can tell, it's from do_tcp_sendpages():
> >=20
> > 		....
> >=20
> >                 i =3D skb_shinfo(skb)->nr_frags;
> >                 if (can_coalesce(skb, i, page, offset)) {
> >                         skb_shinfo(skb)->frags[i - 1].size +=3D copy;
> >                 } else if (i < MAX_SKB_FRAGS) {
> > *********		get_page(page);			***************
> >                         fill_page_desc(skb, i, page, offset, copy);
> >                 } else {
> >                         tcp_mark_push(tp, skb);
> >                         goto new_segment;
> >                 }
> > 		...
> >=20
> > where "page" is NULL.
> >=20
> > The caller seems to be svc_sendto()->tcp_sendpage()->do_tcp_sendpages=
() =20
> > (the other addresses seem to be stale crud on the stack), which doesn=
't
> > look like it has changed lately. Unless there are changes in this are=
a in
> > -mm..
> >=20
> > Any ideas?
>=20
> I'm not really that familiar with Neil's code, but looking at
> encode_entry(), shouldn't it test for the buffer overflow condition
> whereby pn >=3D cd->rqstp->rq_resused, and exit if it does? Neil?

No... and yes... sort of....

It is (should be) an invariant that cd->buffer is always inside one
of the pages in rq_respages.  If a particular entry won't fit, it is
not added and nfserr_toosmall is returned there.

I say "should" because there is a '<=3D' which should be a '<', so it is
possible that if the entry fits exactly in the page, cd->buffer will
be left pointing off the end of the page, and so the invariant won't
be true.

While this won't happen often, it is more likely to happen with larger
directories, which seems to be a common theme.

There is another problem in this code - num_entry_words isn't set
properly if there is a problem getting the filehandle for a file.

I'm not sure if this has been a problem or not.


Anyway, here is the patch.  I don't have a test case that breaks
without this patch, but a large directory can be listed from Solaris
(which uses readdir-plus) with this patch, so I don't think I've
broken anything.

NeilBrown

###Comments for Changeset
Fix bugs introduced by recent improvements to readdir_plus

1/ make sure cd->buffer is always inside a page - previously if an
  entry fit perfectly in the remainder of a page, cd->buffer would=20
  end up pointing past the end of that page.
2/ make sure num_entry_words is always correct, even on the error
  path.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2004-03-29 10:10:25.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2004-03-29 10:26:21.000000000 +1000
@@ -884,10 +884,11 @@ encode_entry(struct readdir_cd *ccd, con
 		if (plus) {
 			struct svc_fh	fh;
=20
-			if (compose_entry_fh(cd, &fh, name, namlen) > 0)
-				goto noexec;
-
-			p =3D encode_entryplus_baggage(cd, p, &fh);
+			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
+				*p++ =3D 0;
+				*p++ =3D 0;
+			} else
+				p =3D encode_entryplus_baggage(cd, p, &fh);
 		}
 		num_entry_words =3D p - cd->buffer;
 	} else if (cd->rqstp->rq_respages[pn+1] !=3D NULL) {
@@ -916,7 +917,7 @@ encode_entry(struct readdir_cd *ccd, con
 		/* determine entry word length and lengths to go in pages */
 		num_entry_words =3D p1 - tmp;
 		len1 =3D curr_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
-		if ((num_entry_words << 2) <=3D len1) {
+		if ((num_entry_words << 2) < len1) {
 			/* the actual number of words in the entry is less
 			 * than elen and can still fit in the current page
 			 */
@@ -945,16 +946,11 @@ encode_entry(struct readdir_cd *ccd, con
 		return -EINVAL;
 	}
=20
-out:
 	cd->buflen -=3D num_entry_words;
 	cd->buffer =3D p;
 	cd->common.err =3D nfs_ok;
 	return 0;
=20
-noexec:
-	*p++ =3D 0;
-	*p++ =3D 0;
-	goto out;
 }
=20
 int
