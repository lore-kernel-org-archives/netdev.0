From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Tue, 01 May 2012 03:27:57 +0200
Message-ID: <1335835677.11396.5.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop>  <4F9F21E2.3080407@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47608 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab2EAB2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:28:04 -0400
Received: by wibhj6 with SMTP id hj6so3320042wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 18:28:02 -0700 (PDT)
In-Reply-To: <4F9F21E2.3080407@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-30 at 16:36 -0700, Alexander Duyck wrote:
> On 04/30/2012 11:10 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > GRO can check if skb to be merged has its skb->head mapped to a pag=
e
> > fragment, instead of a kmalloc() area.
> >
> > We 'upgrade' skb->head as a fragment in itself
> >
> > This avoids the frag_list fallback, and permits to build true GRO s=
kb
> > (one sk_buff and up to 16 fragments), using less memory.
> >
> > This reduces number of cache misses when user makes its copy, since=
 a
> > single sk_buff is fetched.
> >
> > This is a followup of patch "net: allow skb->head to be a page frag=
ment"
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Maciej =C5=BBenczykowski <maze@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Cc: Tom Herbert <therbert@google.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Cc: Ben Hutchings <bhutchings@solarflare.com>
> > Cc: Matt Carlson <mcarlson@broadcom.com>
> > Cc: Michael Chan <mchan@broadcom.com>
> > ---
> >
> > v2: change skb->head by skb->data to compute correct first_offset i=
n
> > frag
> >
> >  include/linux/netdevice.h |    2 ++
> >  include/linux/skbuff.h    |    1 +
> >  net/core/dev.c            |    5 ++++-
> >  net/core/skbuff.c         |   27 ++++++++++++++++++++++++++-
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index e0b70e9..7f377fb 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1509,6 +1509,8 @@ struct napi_gro_cb {
> > =20
> >  	/* Free the skb? */
> >  	int free;
> > +#define NAPI_GRO_FREE		  1
> > +#define NAPI_GRO_FREE_STOLEN_HEAD 2
> >  };
> > =20
> >  #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 9d28a22..2c75e98 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -561,6 +561,7 @@ static inline struct rtable *skb_rtable(const s=
truct sk_buff *skb)
> >  extern void kfree_skb(struct sk_buff *skb);
> >  extern void consume_skb(struct sk_buff *skb);
> >  extern void	       __kfree_skb(struct sk_buff *skb);
> > +extern struct kmem_cache *skbuff_head_cache;
> >  extern struct sk_buff *__alloc_skb(unsigned int size,
> >  				   gfp_t priority, int fclone, int node);
> >  extern struct sk_buff *build_skb(void *data, unsigned int frag_siz=
e);
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 501f3cc..a2be59f 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3546,7 +3546,10 @@ gro_result_t napi_skb_finish(gro_result_t re=
t, struct sk_buff *skb)
> >  		break;
> > =20
> >  	case GRO_MERGED_FREE:
> > -		consume_skb(skb);
> > +		if (NAPI_GRO_CB(skb)->free =3D=3D NAPI_GRO_FREE_STOLEN_HEAD)
> > +			kmem_cache_free(skbuff_head_cache, skb);
> > +		else
> > +			__kfree_skb(skb);
> >  		break;
> > =20
> >  	case GRO_HELD:
> How can you go from consume_skb() which checks for skb->users to a ca=
se
> that doesn't, or are you guaranteed that there is no way to get here
> with skb->users greater than 1?
>=20

GRO runs with skbs delivered from NIC rx handlers, and they MUST have
skb->users =3D=3D 1.

Thinks GRO is the first layer above drivers. We own each skb.

> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index effa75d..2ad1ee7 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -69,7 +69,7 @@
> >  #include <trace/events/skb.h>
> >  #include <linux/highmem.h>
> > =20
> > -static struct kmem_cache *skbuff_head_cache __read_mostly;
> > +struct kmem_cache *skbuff_head_cache __read_mostly;
> >  static struct kmem_cache *skbuff_fclone_cache __read_mostly;
> > =20
> >  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
> > @@ -2901,6 +2901,31 @@ int skb_gro_receive(struct sk_buff **head, s=
truct sk_buff *skb)
> > =20
> >  		NAPI_GRO_CB(skb)->free =3D 1;
> >  		goto done;
> > +	} else if (skb->head_frag) {
> > +		int nr_frags =3D pinfo->nr_frags;
> > +		skb_frag_t *frag =3D pinfo->frags + nr_frags;
> > +		struct page *page =3D virt_to_head_page(skb->head);
> > +		unsigned int first_size =3D headlen - offset;
> > +		unsigned int first_offset;
> > +
> > +		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
> > +			return -E2BIG;
> > +
> > +		first_offset =3D skb->data -
> > +			       (unsigned char *)page_address(page) +
> > +			       offset;
> > +
> > +		pinfo->nr_frags =3D nr_frags + 1 + skbinfo->nr_frags;
> > +
> > +		frag->page.p	  =3D page;
> > +		frag->page_offset =3D first_offset;
> > +		skb_frag_size_set(frag, first_size);
> > +
> > +		memcpy(frag + 1, skbinfo->frags, sizeof(*frag) * skbinfo->nr_fra=
gs);
> > +		/* We dont need to clear skbinfo->nr_frags here */
> > +
> > +		NAPI_GRO_CB(skb)->free =3D NAPI_GRO_FREE_STOLEN_HEAD;
> > +		goto done;
> >  	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
> >  		return -E2BIG;
> > =20
> >
> >
> Maybe I missed something, but shouldn't you be checking skb->cloned, =
and
> skb_shinfo()->dataref before you can consider just dropping the
> sk_buff?  It seems like if you are sharing the frag with a clone you
> would have to retain the skb->head so that you can track the dataref.=
=20
> Otherwise you will likely cause issues because the stack could end up
> freeing the sk_buff, or the GRO frame will be capable of calling
> put_page and freeing the page out from under the clone.
>=20

Is it a general question, or specific to this patch ?

If its a general problem, we already check dataref where appropriate.
=46act that skb->head is a kmalloc() or frag doesnt matter.

If specific to GRO, see my first answer. GRO owns each skb.

adding a BUG() would make no sense here.
