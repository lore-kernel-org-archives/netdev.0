From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call
Date: Mon, 13 Sep 2010 14:31:28 +0200
Message-ID: <4C8E19A0.6000501@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51195 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab0IMMeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 08:34:17 -0400
Received: by wwb18 with SMTP id 18so159817wwb.1
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 05:34:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thank you for digging in the depths of the tree history.

I agree with the usefulness of calling xfrm_get_acq_byseq in the 
processing of ADD_SA messages.

However, I'm still dubious about the usefulness of calling 
xfrm_get_acq_byseq in the handling of an ALLOC_SPI message:
In principle, ALLOC_SPI is called by the owner of the state destination 
address (because only this remote host can guarantee the uniqueness of 
the (daddr, spi, proto) triplet), so such call should not be issued for 
a state created by an acquire message (this state is always an outbound 
state, so the owner of the destination address is remote).



Now, I think we could (and should) optimize the current processing of 
ADD_SA and ALLOC_SPI:

I guess the larval state found by xfrm_get_acq_byseq must have the same 
parameters as those provided in the message (mode, reqid, proto, daddr, 
saddr, family). Contrary to what one might think, the call to 
xfrm_get_acq_byseq is more costly than the call to xfrm_find_acq, 
because the later uses a hash table.

Shouldn't we extend the xfrm_get_acq function so that it accepts an 
optional seq parameter? We would replace the first call to 
xfrm_find_acq_byseq by:

    x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 0, family, seq);

and the if no entry is found, we would call:

    x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 1, family, 0);

We would take benefit of the hash table, instead of looking up through 
the whole SAD as does xfrm_get_acq_byseq.




Regards,
Christophe

Thank you for digging into the history.
> From: Christophe Gouault <christophe.gouault@6wind.com>
> Date: Mon, 23 Aug 2010 16:47:18 +0200
>
> > Christophe Gouault wrote:
> >>> The likelyhood of breaking something if you remove the call is very
> >>> high.
> >> Probably. I'm still interested in a concrete example ;-)
>
> Christophe, digging deep into the tree history I found a
> commit that should answer your question:
>
> commit 4d9f62e953567482223b7110c5e8961c4d494c1f
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Sep 10 00:36:11 2004 -0700
>
>     [IPSEC]: Find larval SAs by sequence number
>     
>     When larval states are generated along with ACQUIRE messages, we should
>     use the sequence to find the corresponding larval state when creating
>     states with ADD_SA or ALLOC_SPI.
>     
>     If we don't do that, then it may take down an unrelated larval state
>     with the same parameters (think different TCP sessions).  This not only
>     leaves behind a larval state that shouldn't be there, it may also cause
>     another ACQUIRE message to be sent unnecessarily.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 40c65db..b5c9b10 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -896,4 +896,17 @@ typedef void (icv_update_fn_t)(struct crypto_tfm *, struct scatterlist *, unsign
>  extern void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
>  			 int offset, int len, icv_update_fn_t icv_update);
>  
> +static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
> +				int family)
> +{
> +	switch (family) {
> +	default:
> +	case AF_INET:
> +		return a->a4 - b->a4;
> +	case AF_INET6:
> +		return ipv6_addr_cmp((struct in6_addr *)a,
> +				     (struct in6_addr *)b);
> +	}
> +}
> +
>  #endif	/* _NET_XFRM_H */
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 8ca25fd..b059fa2 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1156,7 +1156,16 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
>  		break;
>  #endif
>  	}
> -	if (xdaddr)
> +
> +	if (hdr->sadb_msg_seq) {
> +		x = xfrm_find_acq_byseq(hdr->sadb_msg_seq);
> +		if (x && xfrm_addr_cmp(&x->id.daddr, xdaddr, family)) {
> +			xfrm_state_put(x);
> +			x = NULL;
> +		}
> +	}
> +
> +	if (!x)
>  		x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 1, family);
>  
>  	if (x == NULL)
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index f45fa55..835c92a 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -387,13 +387,17 @@ void xfrm_state_insert(struct xfrm_state *x)
>  	spin_unlock_bh(&xfrm_state_lock);
>  }
>  
> +static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
> +
>  int xfrm_state_add(struct xfrm_state *x)
>  {
>  	struct xfrm_state_afinfo *afinfo;
>  	struct xfrm_state *x1;
> +	int family;
>  	int err;
>  
> -	afinfo = xfrm_state_get_afinfo(x->props.family);
> +	family = x->props.family;
> +	afinfo = xfrm_state_get_afinfo(family);
>  	if (unlikely(afinfo == NULL))
>  		return -EAFNOSUPPORT;
>  
> @@ -407,9 +411,18 @@ int xfrm_state_add(struct xfrm_state *x)
>  		goto out;
>  	}
>  
> -	x1 = afinfo->find_acq(
> -		x->props.mode, x->props.reqid, x->id.proto,
> -		&x->id.daddr, &x->props.saddr, 0);
> +	if (x->km.seq) {
> +		x1 = __xfrm_find_acq_byseq(x->km.seq);
> +		if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {
> +			xfrm_state_put(x1);
> +			x1 = NULL;
> +		}
> +	}
> +
> +	if (!x1)
> +		x1 = afinfo->find_acq(
> +			x->props.mode, x->props.reqid, x->id.proto,
> +			&x->id.daddr, &x->props.saddr, 0);
>  
>  	__xfrm_state_insert(x);
>  	err = 0;
> @@ -570,12 +583,11 @@ xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
>  
>  /* Silly enough, but I'm lazy to build resolution list */
>  
> -struct xfrm_state * xfrm_find_acq_byseq(u32 seq)
> +static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
>  {
>  	int i;
>  	struct xfrm_state *x;
>  
> -	spin_lock_bh(&xfrm_state_lock);
>  	for (i = 0; i < XFRM_DST_HSIZE; i++) {
>  		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
>  			if (x->km.seq == seq) {
> @@ -585,9 +597,18 @@ struct xfrm_state * xfrm_find_acq_byseq(u32 seq)
>  			}
>  		}
>  	}
> -	spin_unlock_bh(&xfrm_state_lock);
>  	return NULL;
>  }
> +
> +struct xfrm_state *xfrm_find_acq_byseq(u32 seq)
> +{
> +	struct xfrm_state *x;
> +
> +	spin_lock_bh(&xfrm_state_lock);
> +	x = __xfrm_find_acq_byseq(seq);
> +	spin_unlock_bh(&xfrm_state_lock);
> +	return x;
> +}
>   
>  u32 xfrm_get_acqseq(void)
>  {
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index be298cd..db2087c 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -470,16 +470,32 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh, void **
>  	struct xfrm_state *x;
>  	struct xfrm_userspi_info *p;
>  	struct sk_buff *resp_skb;
> +	xfrm_address_t *daddr;
> +	int family;
>  	int err;
>  
>  	p = NLMSG_DATA(nlh);
>  	err = verify_userspi_info(p);
>  	if (err)
>  		goto out_noput;
> -	x = xfrm_find_acq(p->info.mode, p->info.reqid, p->info.id.proto,
> -			  &p->info.id.daddr,
> -			  &p->info.saddr, 1,
> -			  p->info.family);
> +
> +	family = p->info.family;
> +	daddr = &p->info.id.daddr;
> +
> +	x = NULL;
> +	if (p->info.seq) {
> +		x = xfrm_find_acq_byseq(p->info.seq);
> +		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
> +			xfrm_state_put(x);
> +			x = NULL;
> +		}
> +	}
> +
> +	if (!x)
> +		x = xfrm_find_acq(p->info.mode, p->info.reqid,
> +				  p->info.id.proto, daddr,
> +				  &p->info.saddr, 1,
> +				  family);
>  	err = -ENOENT;
>  	if (x == NULL)
>  		goto out_noput;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
