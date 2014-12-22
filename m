From: Jason Wang <jasowang@redhat.com>
Subject: Re: caif: Fix napi poll list corruption
Date: Mon, 22 Dec 2014 10:10:01 +0008
Message-ID: <1419242521.4592.0@smtp.corp.redhat.com>
References: <20141220002327.GA31975@gondor.apana.org.au>
	<5497D3D9.2070509@redhat.com> <20141222093525.GA18616@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, edumazet@google.com,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141AbaLWI4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 03:56:09 -0500
In-Reply-To: <20141222093525.GA18616@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Dec 22, 2014 at 5:35 PM, Herbert Xu 
<herbert@gondor.apana.org.au> wrote:
> On Mon, Dec 22, 2014 at 04:18:33PM +0800, Jason Wang wrote:
>> 
>>  btw, looks like at least caif_virtio has the same issue.
> 
> Good catch.
> 
> -- >8 --
> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) breaks caif.
> 
> It is now required that if the entire budget is consumed when poll
> returns, the napi poll_list must remain empty.  However, like some
> other drivers caif tries to do a last-ditch check and if there is
> more work it will call napi_schedule and then immediately process
> some of this new work.  Should the entire budget be consumed while
> processing such new work then we will violate the new caller
> contract.
> 
> This patch fixes this by not touching any work when we reschedule
> in caif.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Jason Wang <jasowang@redhat.com>

Thanks.
> 
> 
> diff --git a/drivers/net/caif/caif_virtio.c 
> b/drivers/net/caif/caif_virtio.c
> index a5fefb9..b306210 100644
> --- a/drivers/net/caif/caif_virtio.c
> +++ b/drivers/net/caif/caif_virtio.c
> @@ -257,7 +257,6 @@ static int cfv_rx_poll(struct napi_struct *napi, 
> int quota)
>  	struct vringh_kiov *riov = &cfv->ctx.riov;
>  	unsigned int skb_len;
>  
> -again:
>  	do {
>  		skb = NULL;
>  
> @@ -322,7 +321,6 @@ exit:
>  		    napi_schedule_prep(napi)) {
>  			vringh_notify_disable_kern(cfv->vr_rx);
>  			__napi_schedule(napi);
> -			goto again;
>  		}
>  		break;
> 
> Thanks,
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
