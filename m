From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Thu, 04 Nov 2010 10:04:25 +0100
Message-ID: <1288861465.2659.44.camel@edumazet-laptop>
References: <1288861513-5707-1-git-send-email-xiaohui.xin@intel.com>
	 <bd4abd1568dfc75daed6713f9a568bf0f895de4b.1288860477.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <bd4abd1568dfc75daed6713f9a568bf0f895de4b.1288860477.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 04 novembre 2010 =C3=A0 17:05 +0800, xiaohui.xin@intel.com a =C3=
=A9crit :
> From: Xin Xiaohui <xiaohui.xin@intel.com>
>=20
> If buffer is external, then use the callback to destruct
> buffers.
>=20
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
> ---
>  net/core/skbuff.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c83b421..5e6d69c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -210,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
> =20
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo =3D skb_shinfo(skb);
> +	shinfo->destructor_arg =3D NULL;

Hmm, I suggest you read the comment two lines above.

If destructor_arg is now cleared each time we allocate a new skb, then,
please move it before dataref in shinfo structure, so that the followin=
g
memset() does the job efficiently...

>  	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
>  	atomic_set(&shinfo->dataref, 1);
> =20
> @@ -343,6 +344,13 @@ static void skb_release_data(struct sk_buff *skb=
)
>  		if (skb_has_frags(skb))
>  			skb_drop_fraglist(skb);
> =20
> +		if (skb->dev && dev_is_mpassthru(skb->dev)) {
> +			struct skb_ext_page *ext_page =3D
> +				skb_shinfo(skb)->destructor_arg;
> +			if (ext_page && ext_page->dtor)
> +				ext_page->dtor(ext_page);
> +		}
> +
>  		kfree(skb->head);
>  	}
>  }


