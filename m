From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re:[PATCH v14 06/17] Use callback to deal with
 skb_release_data() specially.
Date: Mon, 08 Nov 2010 09:24:46 +0100
Message-ID: <1289204686.2478.375.camel@edumazet-laptop>
References: <1288861663.2659.47.camel@edumazet-laptop>
	 <1289203430-5935-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1289203430-5935-1-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 08 novembre 2010 =C3=A0 16:03 +0800, xiaohui.xin@intel.com a =C3=
=A9crit :
> From: Xin Xiaohui <xiaohui.xin@intel.com>
>=20
> >> Hmm, I suggest you read the comment two lines above.
> >>
> >> If destructor_arg is now cleared each time we allocate a new skb, =
then,
> >> please move it before dataref in shinfo structure, so that the fol=
lowing
> >> memset() does the job efficiently...
> >
> >
> >Something like :
> >
> >diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> >index e6ba898..2dca504 100644
> >--- a/include/linux/skbuff.h
> >+++ b/include/linux/skbuff.h
> >@@ -195,6 +195,9 @@ struct skb_shared_info {
> > 	__be32          ip6_frag_id;
> > 	__u8		tx_flags;
> > 	struct sk_buff	*frag_list;
> >+	/* Intermediate layers must ensure that destructor_arg
> >+	 * remains valid until skb destructor */
> >+	void		*destructor_arg;
> > 	struct skb_shared_hwtstamps hwtstamps;
> >
> > 	/*
> >@@ -202,9 +205,6 @@ struct skb_shared_info {
> > 	 */
> > 	atomic_t	dataref;
> >
> >-	/* Intermediate layers must ensure that destructor_arg
> >-	 * remains valid until skb destructor */
> >-	void *		destructor_arg;
> > 	/* must be last field, see pskb_expand_head() */
> > 	skb_frag_t	frags[MAX_SKB_FRAGS];
> > };
> >
> >
>=20
> Will that affect the cache line?

What do you mean ?

> Or, we can move the line to clear destructor_arg to the end of __allo=
c_skb().
> It looks like as the following, which one do you prefer?
>=20
> Thanks
> Xiaohui
>=20
> ---
>  net/core/skbuff.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c83b421..df852f2 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -224,6 +224,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
> =20
>  		child->fclone =3D SKB_FCLONE_UNAVAILABLE;
>  	}
> +	shinfo->destructor_arg =3D NULL;
>  out:
>  	return skb;
>  nodata:

I dont understand why you want to do this.

This adds an instruction, makes code bigger, and no obvious gain for me=
,
at memory transactions side.

If integrated in the existing memset(), cost is an extra iteration to
perform the clear of this field.


