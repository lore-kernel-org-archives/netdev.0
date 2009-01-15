From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Wed, 14 Jan 2009 17:35:00 -0800
Message-ID: <9929d2390901141735j11fa609aya9196defdc9818d5@mail.gmail.com>
References: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com>
	 <20090114123653.GA19257@gondor.apana.org.au>
	 <9929d2390901141603s65cd27a3y732c5058de9145c8@mail.gmail.com>
	 <20090115003246.GA26461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Emil Tantilov" <emil.s.tantilov@intel.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:62122 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbZAOBfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 20:35:03 -0500
Received: by rn-out-0910.google.com with SMTP id k40so724190rnd.17
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 17:35:00 -0800 (PST)
In-Reply-To: <20090115003246.GA26461@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 4:32 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Jan 14, 2009 at 04:03:10PM -0800, Jeff Kirsher wrote:
>>
>> We are seeing a kernel panic during our testing using jumbo frames,
>> below is the trace.
>
> Thanks! This was the one case that I didn't test with e1000e,
> namely an skb with page frags which comes from the driver (as
> opposed to being constructed by the stack through gro_receive_frags).
>
> gro: Fix page ref count for skbs freed normally
>
> When an skb with page frags is merged into an existing one, we
> cannibalise its reference count.  This is OK when the skb is
> reused because we set nr_frags to zero in that case.  However,
> for the case where the skb is freed through kfree_skb, we didn't
> clear nr_frags which causes the page to be freed prematurely.
>
> This is fixed by moving the skb resetting into skb_gro_receive.
>
> Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 972a47d..4f69a2d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2481,12 +2481,6 @@ EXPORT_SYMBOL(napi_gro_receive);
>
>  void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
>  {
> -       skb_shinfo(skb)->nr_frags = 0;
> -
> -       skb->len -= skb->data_len;
> -       skb->truesize -= skb->data_len;
> -       skb->data_len = 0;
> -
>        __skb_pull(skb, skb_headlen(skb));
>        skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5110b35..65eac77 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2602,6 +2602,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>                       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
>
>                skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
> +               skb_shinfo(skb)->nr_frags = 0;
> +
> +               skb->truesize -= skb->data_len;
> +               skb->len -= skb->data_len;
> +               skb->data_len = 0;
> +
>                NAPI_GRO_CB(skb)->free = 1;
>                goto done;
>        }
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
>

Might want to redo the subject line so that Dave knows that this is a
different patch, since you already have the IGB conversion to GRO
patch in this mail thread.

-- 
Cheers,
Jeff
