From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 06/10] net: add support for
 per-paged-fragment destructors
Date: Thu, 26 Apr 2012 16:44:50 -0400
Message-ID: <20120426204450.GA7392@phenom.dumpdata.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
 <1334067984-7706-6-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, xen-devel@lists.xen.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	David Miller <davem@davemloft.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:23673 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab2DZUuq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 16:50:46 -0400
Content-Disposition: inline
In-Reply-To: <1334067984-7706-6-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 03:26:20PM +0100, Ian Campbell wrote:
> Entities which care about the complete lifecycle of pages which they =
inject
> into the network stack via an skb paged fragment can choose to set th=
is
> destructor in order to receive a callback when the stack is really fi=
nished
> with a page (including all clones, retransmits, pull-ups etc etc).
>=20
> This destructor will always be propagated alongside the struct page w=
hen
> copying skb_frag_t->page. This is the reason I chose to embed the des=
tructor in
> a "struct { } page" within the skb_frag_t, rather than as a separate =
field,
> since it allows existing code which propagates ->frags[N].page to Jus=
t
> Work(tm).
>=20
> When the destructor is present the page reference counting is done sl=
ightly
> differently. No references are held by the network stack on the struc=
t page (it
> is up to the caller to manage this as necessary) instead the network =
stack will
> track references via the count embedded in the destructor structure. =
When this
> reference count reaches zero then the destructor will be called and t=
he caller
> can take the necesary steps to release the page (i.e. release the str=
uct page
> reference itself).
>=20
> The intention is that callers can use this callback to delay completi=
on to
> _their_ callers until the network stack has completely released the p=
age, in
> order to prevent use-after-free or modification of data pages which a=
re still
> in use by the stack.
>=20
> It is allowable (indeed expected) for a caller to share a single dest=
ructor
> instance between multiple pages injected into the stack e.g. a group =
of pages
> included in a single higher level operation might share a destructor =
which is
> used to complete that higher level operation.
>=20
> With this change and the previous two changes to shinfo alignment and=
 field
> orderring it is now the case tyhat on a 64 bit system with 64 byte ca=
che lines,
                              ^^^^ - that.

> everything from nr_frags until the end of frags[0] is on the same cac=
heline.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
> Cc: netdev@vger.kernel.org
> ---
>  include/linux/skbuff.h |   43 ++++++++++++++++++++++++++++++++++++++=
+++++
>  net/core/skbuff.c      |   17 +++++++++++++++++
>  2 files changed, 60 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f0ae39c..6ac283e 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -166,9 +166,15 @@ struct sk_buff;
> =20
>  typedef struct skb_frag_struct skb_frag_t;
> =20
> +struct skb_frag_destructor {
> +	atomic_t ref;
> +	int (*destroy)(struct skb_frag_destructor *destructor);
> +};
> +
>  struct skb_frag_struct {
>  	struct {
>  		struct page *p;
> +		struct skb_frag_destructor *destructor;
>  	} page;
>  #if (BITS_PER_LONG > 32) || (PAGE_SIZE >=3D 65536)
>  	__u32 page_offset;
> @@ -1221,6 +1227,31 @@ static inline int skb_pagelen(const struct sk_=
buff *skb)
>  }
> =20
>  /**
> + * skb_frag_set_destructor - set destructor for a paged fragment
> + * @skb: buffer containing fragment to be initialised
> + * @i: paged fragment index to initialise
> + * @destroy: the destructor to use for this fragment
> + *
> + * Sets @destroy as the destructor to be called when all references =
to
> + * the frag @i in @skb (tracked over skb_clone, retransmit, pull-ups=
,
> + * etc) are released.
> + *
> + * When a destructor is set then reference counting is performed on
> + * @destroy->ref. When the ref reaches zero then @destroy->destroy
> + * will be called. The caller is responsible for holding and managin=
g
> + * any other references (such a the struct page reference count).
> + *
> + * This function must be called before any use of skb_frag_ref() or
> + * skb_frag_unref().
> + */
> +static inline void skb_frag_set_destructor(struct sk_buff *skb, int =
i,
> +					   struct skb_frag_destructor *destroy)
> +{
> +	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> +	frag->page.destructor =3D destroy;
> +}
> +
> +/**
>   * __skb_fill_page_desc - initialise a paged fragment in an skb
>   * @skb: buffer containing fragment to be initialised
>   * @i: paged fragment index to initialise
> @@ -1239,6 +1270,7 @@ static inline void __skb_fill_page_desc(struct =
sk_buff *skb, int i,
>  	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> =20
>  	frag->page.p		  =3D page;
> +	frag->page.destructor     =3D NULL;
>  	frag->page_offset	  =3D off;
>  	skb_frag_size_set(frag, size);
>  }
> @@ -1743,6 +1775,9 @@ static inline struct page *skb_frag_page(const =
skb_frag_t *frag)
>  	return frag->page.p;
>  }
> =20
> +extern void skb_frag_destructor_ref(struct skb_frag_destructor *dest=
roy);
> +extern void skb_frag_destructor_unref(struct skb_frag_destructor *de=
stroy);
> +
>  /**
>   * __skb_frag_ref - take an addition reference on a paged fragment.
>   * @frag: the paged fragment
> @@ -1751,6 +1786,10 @@ static inline struct page *skb_frag_page(const=
 skb_frag_t *frag)
>   */
>  static inline void __skb_frag_ref(skb_frag_t *frag)
>  {
> +	if (unlikely(frag->page.destructor)) {
> +		skb_frag_destructor_ref(frag->page.destructor);
> +		return;
> +	}
>  	get_page(skb_frag_page(frag));
>  }
> =20
> @@ -1774,6 +1813,10 @@ static inline void skb_frag_ref(struct sk_buff=
 *skb, int f)
>   */
>  static inline void __skb_frag_unref(skb_frag_t *frag)
>  {
> +	if (unlikely(frag->page.destructor)) {
> +		skb_frag_destructor_unref(frag->page.destructor);
> +		return;
> +	}
>  	put_page(skb_frag_page(frag));
>  }
> =20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b8a41d6..9ec88ce 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -349,6 +349,23 @@ struct sk_buff *dev_alloc_skb(unsigned int lengt=
h)
>  }
>  EXPORT_SYMBOL(dev_alloc_skb);
> =20
> +void skb_frag_destructor_ref(struct skb_frag_destructor *destroy)
> +{
> +	BUG_ON(destroy =3D=3D NULL);
> +	atomic_inc(&destroy->ref);
> +}
> +EXPORT_SYMBOL(skb_frag_destructor_ref);
> +
> +void skb_frag_destructor_unref(struct skb_frag_destructor *destroy)
> +{
> +	if (destroy =3D=3D NULL)
> +		return;
> +
> +	if (atomic_dec_and_test(&destroy->ref))
> +		destroy->destroy(destroy);
> +}
> +EXPORT_SYMBOL(skb_frag_destructor_unref);
> +
>  static void skb_drop_list(struct sk_buff **listp)
>  {
>  	struct sk_buff *list =3D *listp;
> --=20
> 1.7.2.5
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
