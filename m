From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 21 Nov 2011 10:16:28 +0100
Message-ID: <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111118072519.GA1615@x4.trippels.de>
	 <20111118075521.GB1615@x4.trippels.de> <1321605837.30341.551.camel@debian>
	 <20111118085436.GC1615@x4.trippels.de>
	 <20111118120201.GA1642@x4.trippels.de> <1321836285.30341.554.camel@debian>
	 <20111121080554.GB1625@x4.trippels.de>
	 <20111121082445.GD1625@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111121082445.GD1625@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 09:24 +0100, Markus Trippelsdorf a =C3=A9=
crit :
> On 2011.11.21 at 09:05 +0100, Markus Trippelsdorf wrote:
> > On 2011.11.21 at 08:44 +0800, Alex,Shi wrote:
> > > On Fri, 2011-11-18 at 20:02 +0800, Markus Trippelsdorf wrote:
> > > > On 2011.11.18 at 09:54 +0100, Markus Trippelsdorf wrote:
> > > > > On 2011.11.18 at 16:43 +0800, Alex,Shi wrote:
> > > > > > > >=20
> > > > > > > > The dirty flag comes from a bunch of unrelated xfs patche=
s from Christoph, that
> > > > > > > > I'm testing right now.
> > > > > >=20
> > > > > > Where is the xfs patchset? I am wondering if it is due to slu=
b code.=20
> > > >=20
> > > > I begin to wonder if this might be the result of a compiler bug.=20
> > > > The kernel in question was compiled with gcc version 4.7.0 201111=
17. And
> > > > there was commit to the gcc repository today that looks suspiciou=
s:
> > > > http://gcc.gnu.org/viewcvs?view=3Drevision&revision=3D181466
> > > >=20
> > >=20
> > > Tell us if it is still there and you can reproduce it.
> >=20
> > Hm, just noticed the "3.2.0-rc1 panic on PowerPC" thread:
> > http://thread.gmane.org/gmane.linux.kernel/1215584
> >=20
> > The backtraces look suspiciously similar to mine.
>=20
> So everything points to commit 87fb4b7b533:
> "net: more accurate skb truesize"
>=20
> Can you take a look Eric?


This commit was followed by a fix (for SLOB, since SLUB/SLAB were not
affected)

Check commit bc417e30f8df (net: Add back alignment for size for
__alloc_skb)

If current kernel still crash, I believe there is a problem elsewhere (a
refcounting problem) that makes underlying page being reused :

The ksize(skb->head) call in pskb_expand_head() assumes skb->head is a
valid zone, not an already freed one...

By the way, we probably can remove (almost dead) code from
pskb_expand_head() since we now place struct skb_shared_info at the end
of skb->head at skb creation.

I'll send this patch later for net-next

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 18a3ceb..5fd67a8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -892,17 +892,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead,=
 int ntail,
 		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
 	}
=20
-	if (fastpath &&
-	    size + sizeof(struct skb_shared_info) <=3D ksize(skb->head)) {
-		memmove(skb->head + size, skb_shinfo(skb),
-			offsetof(struct skb_shared_info,
-				 frags[skb_shinfo(skb)->nr_frags]));
-		memmove(skb->head + nhead, skb->head,
-			skb_tail_pointer(skb) - skb->head);
-		off =3D nhead;
-		goto adjust_others;
-	}
-
 	data =3D kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -935,7 +924,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, =
int ntail,
 	off =3D (data + nhead) - skb->head;
=20
 	skb->head     =3D data;
-adjust_others:
 	skb->data    +=3D off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end      =3D size;








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
