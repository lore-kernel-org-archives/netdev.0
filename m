From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V6 2/4 net-next] skbuff: Add userspace zero-copy
 buffers in skb
Date: Thu, 26 May 2011 13:24:02 -0700
Message-ID: <1306441442.5180.51.camel@localhost.localdomain>
References: <1306438593.5180.33.camel@localhost.localdomain>
	 <1306440247.2543.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306440247.2543.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 22:04 +0200, Eric Dumazet wrote:
> Le jeudi 26 mai 2011 =C3=A0 12:36 -0700, Shirley Ma a =C3=A9crit :
> > This patch adds userspace buffers support in skb shared info. A new=
=20
> > struct skb_ubuf_info is needed to maintain the userspace buffers
> > argument and index, a callback is used to notify userspace to
> release
> > the buffers once lower device has done DMA (Last reference to that
> skb
> > has gone).
> >=20
> > If there is any userspace apps to reference these userspace buffers=
,
> > then these userspaces buffers will be copied into kernel. This way
> we
> > can prevent userspace apps to hold these userspace buffers too long=
=2E
> >=20
> > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > ---
> >=20
> >  include/linux/skbuff.h |   26 +++++++++++++++
> >  net/core/skbuff.c      |   80
> ++++++++++++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 104 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index d0ae90a..025de5c 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -189,6 +189,18 @@ enum {
> >       SKBTX_DRV_NEEDS_SK_REF =3D 1 << 3,
> >  };
> > =20
> > +/*
> > + * The callback notifies userspace to release buffers when skb DMA
> is done in
> > + * lower device, the skb last reference should be 0 when calling
> this.
> > + * The desc is used to track userspace buffer index.
> > + */
> > +struct skb_ubuf_info {
> > +     /* support buffers allocation from userspace */
> > +     void            (*callback)(struct sk_buff *);
> > +     void            *arg;
> > +     size_t          desc;
> > +};
>=20
> Thats 24 bytes on each skb...   desc for example is not used in this
> patch (yes, its used later in patch 4/4)
>=20
> But still... could you instead use one pointer only in skb ?

I could reduce callback pointer by moving it to *arg, but not desc, thi=
s
indicates that which buffer DMA hasn't done yet in *arg.

>=20
> > +
> >  /* This data is invariant across clones and lives at
> >   * the end of the header data, ie. at skb->end.
> >   */
> > @@ -211,6 +223,10 @@ struct skb_shared_info {
> >       /* Intermediate layers must ensure that destructor_arg
> >        * remains valid until skb destructor */
> >       void *          destructor_arg;
> > +
> > +     /* DMA mapping from/to userspace buffers */
> > +     struct skb_ubuf_info ubuf;
> > +
> >       /* must be last field, see pskb_expand_head() */
> >       skb_frag_t      frags[MAX_SKB_FRAGS];
> >  };
> > @@ -2261,5 +2277,15 @@ static inline void
> skb_checksum_none_assert(struct sk_buff *skb)
> >  }
> > =20
> >  bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)=
;
> > +
> > +/*
> > + *   skb_ubuf - is the buffer from userspace
> > + *   @skb: buffer to check
> > + */
> > +static inline int skb_ubuf(const struct sk_buff *skb)
> > +{
> > +     return (skb_shinfo(skb)->ubuf.callback !=3D NULL);
>=20
>         return skb_shinfo(skb)->ubuf.callback !=3D NULL;
>=20
> > +}
> > +
> >  #endif       /* __KERNEL__ */
> >  #endif       /* _LINUX_SKBUFF_H */
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 7ebeed0..890447c 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -210,6 +210,8 @@ struct sk_buff *__alloc_skb(unsigned int size,
> gfp_t gfp_mask,
> >       shinfo =3D skb_shinfo(skb);
> >       memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> >       atomic_set(&shinfo->dataref, 1);
> > +     shinfo->ubuf.callback =3D NULL;
> > +     shinfo->ubuf.arg =3D NULL;
>=20
> if you put ubuf ptr before dataref, no need to add this (the memset()
> clear all shared_info up to dataref)

Ok, will remove it.

> >       kmemcheck_annotate_variable(shinfo->destructor_arg);
> > =20
> >       if (fclone) {
> > @@ -328,6 +330,14 @@ static void skb_release_data(struct sk_buff
> *skb)
> >                               put_page(skb_shinfo(skb)->frags[i].pa=
ge);
> >               }
> > =20
> > +             /*
> > +              * if skb buf is from userspace, we need to notify th=
e
> caller
> > +              * the lower device DMA has done;
> > +              */
> > +             if (skb_ubuf(skb)) {
> > +                     skb_shinfo(skb)->ubuf.callback(skb);
> > +                     skb_shinfo(skb)->ubuf.callback =3D NULL;
> > +             }
> >               if (skb_has_frag_list(skb))
> >                       skb_drop_fraglist(skb);
> > =20
> > @@ -480,6 +490,9 @@ bool skb_recycle_check(struct sk_buff *skb, int
> skb_size)
> >       if (irqs_disabled())
> >               return false;
> > =20
> > +     if (skb_ubuf(skb))
> > +             return false;
> > +
> >       if (skb_is_nonlinear(skb) || skb->fclone !=3D
> SKB_FCLONE_UNAVAILABLE)
> >               return false;
> > =20
> > @@ -572,6 +585,7 @@ static struct sk_buff *__skb_clone(struct
> sk_buff *n, struct sk_buff *skb)
> >       atomic_set(&n->users, 1);
> > =20
> >       atomic_inc(&(skb_shinfo(skb)->dataref));
> > +     skb_shinfo(skb)->ubuf.callback =3D NULL;
> >       skb->cloned =3D 1;
> > =20
> >       return n;
> > @@ -595,6 +609,48 @@ struct sk_buff *skb_morph(struct sk_buff *dst,
> struct sk_buff *src)
> >  }
> >  EXPORT_SYMBOL_GPL(skb_morph);
> > =20
> > +/* skb frags copy userspace buffers to kernel */
> > +static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> > +{
> > +     int i;
> > +     int num_frags =3D skb_shinfo(skb)->nr_frags;
> > +     struct page *page, *head =3D NULL;
> > +
> > +     for (i =3D 0; i < num_frags; i++) {
> > +             u8 *vaddr;
> > +             skb_frag_t *f =3D &skb_shinfo(skb)->frags[i];
> > +
> > +             page =3D alloc_page(GFP_ATOMIC);
> > +             if (!page) {
> > +                     while (head) {
> > +                             put_page(head);
> > +                             head =3D (struct page *)head->private=
;
> > +                     }
> > +                     return -ENOMEM;
> > +             }
> > +             vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
> > +             memcpy(page_address(page), vaddr + f->page_offset,
> f->size);
> > +             kunmap_skb_frag(vaddr);
> > +             page->private =3D (unsigned long)head;
> > +             head =3D page;
> > +     }
> > +
> > +     /* skb frags release userspace buffers */
> > +     for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> > +             put_page(skb_shinfo(skb)->frags[i].page);
> > +     skb_shinfo(skb)->ubuf.callback(skb);
> > +     skb_shinfo(skb)->ubuf.callback =3D NULL;
> > +
> > +     /* skb frags point to kernel buffers */
> > +     for (i =3D skb_shinfo(skb)->nr_frags; i > 0; i--) {
> > +             skb_shinfo(skb)->frags[i - 1].page_offset =3D 0;
> > +             skb_shinfo(skb)->frags[i - 1].page =3D head;
> > +             head =3D (struct page *)head->private;
> > +     }
> > +     return 0;
> > +}
> > +
> > +
> >  /**
> >   *   skb_clone       -       duplicate an sk_buff
> >   *   @skb: buffer to clone
> > @@ -613,6 +669,11 @@ struct sk_buff *skb_clone(struct sk_buff *skb,
> gfp_t gfp_mask)
> >  {
> >       struct sk_buff *n;
> > =20
> > +     if (skb_ubuf(skb)) {
> > +             if (skb_copy_ubufs(skb, gfp_mask))
> > +                     return NULL;
> > +     }
> > +
> >       n =3D skb + 1;
> >       if (skb->fclone =3D=3D SKB_FCLONE_ORIG &&
> >           n->fclone =3D=3D SKB_FCLONE_UNAVAILABLE) {
> > @@ -730,6 +791,12 @@ struct sk_buff *pskb_copy(struct sk_buff *skb,
> gfp_t gfp_mask)
> >       if (skb_shinfo(skb)->nr_frags) {
> >               int i;
> > =20
> > +             if (skb_ubuf(skb)) {
> > +                     if (skb_copy_ubufs(skb, gfp_mask)) {
> > +                             kfree(n);
> > +                             goto out;
> > +                     }
> > +             }
> >               for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> >                       skb_shinfo(n)->frags[i] =3D
> skb_shinfo(skb)->frags[i];
> >                       get_page(skb_shinfo(n)->frags[i].page);
> > @@ -743,6 +810,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb,
> gfp_t gfp_mask)
> >       }
> > =20
> >       copy_skb_header(n, skb);
> > +
>=20
> please dont add new lines like this in your patch

checkpatch doesn't check this kind of line, will remove it.

> >  out:
> >       return n;
> >  }
> > @@ -787,7 +855,6 @@ int pskb_expand_head(struct sk_buff *skb, int
> nhead, int ntail,
> >               fastpath =3D true;
> >       else {
> >               int delta =3D skb->nohdr ? (1 << SKB_DATAREF_SHIFT) +
> 1 : 1;
> > -
>=20
> and dont delete this one as well.
>=20
> >               fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=
=3D
> delta;
> >       }
> > =20
> > @@ -818,14 +885,19 @@ int pskb_expand_head(struct sk_buff *skb, int
> nhead, int ntail,
> >       if (fastpath) {
> >               kfree(skb->head);
> >       } else {
> > +             /* copy this zero copy skb frags */
> > +             if (skb_ubuf(skb)) {
> > +                     if (skb_copy_ubufs(skb, gfp_mask))
> > +                             goto nofrags;
> > +             }
> >               for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> >                       get_page(skb_shinfo(skb)->frags[i].page);
> > -
>=20
> ditto
>=20
> >               if (skb_has_frag_list(skb))
> >                       skb_clone_fraglist(skb);
> > =20
> >               skb_release_data(skb);
> >       }
> > +
>=20
> ditto
>=20
> >       off =3D (data + nhead) - skb->head;
> > =20
> >       skb->head     =3D data;
> > @@ -852,6 +924,8 @@ adjust_others:
> >       atomic_set(&skb_shinfo(skb)->dataref, 1);
> >       return 0;
> > =20
> > +nofrags:
> > +     kfree(data);
> >  nodata:
> >       return -ENOMEM;
> >  }
> > @@ -1353,6 +1427,8 @@ int skb_copy_bits(const struct sk_buff *skb,
> int offset, void *to, int len)
> >               }
> >               start =3D end;
> >       }
> > +     skb_shinfo(skb)->ubuf.callback =3D NULL;
> > +
> >       if (!len)
> >               return 0;
> > =20
> >=20
> >=20
>=20
>=20
