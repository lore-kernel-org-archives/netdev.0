From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] macsec: dynamically allocate space for sglist
Date: Tue, 25 Apr 2017 18:36:02 +0200
Message-ID: <20170425163602.GA17973@bistromath.localdomain>
References: <CAHmME9rZ29X=R-quViXaEO_ouxeB2EpzR2bkR93rrN4n--QDqw@mail.gmail.com>
 <20170425152300.3830-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40178 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1430579AbdDYQgF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 12:36:05 -0400
Content-Disposition: inline
In-Reply-To: <20170425152300.3830-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-25, 17:23:00 +0200, Jason A. Donenfeld wrote:
> We call skb_cow_data, which is good anyway to ensure we can actually
> modify the skb as such (another error from prior). Now that we have the
> number of fragments required, we can safely allocate exactly that amount
> of memory.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Sabrina Dubroca <sd@queasysnail.net>
> Cc: security@kernel.org
> Cc: stable@vger.kernel.org
> ---
>  drivers/net/macsec.c | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
> index dbab05afcdbe..56dafdee4c9c 100644
> --- a/drivers/net/macsec.c
> +++ b/drivers/net/macsec.c
[...]
> @@ -917,6 +926,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
>  {
>  	int ret;
>  	struct scatterlist *sg;
> +	struct sk_buff *trailer;
>  	unsigned char *iv;
>  	struct aead_request *req;
>  	struct macsec_eth_header *hdr;
> @@ -927,7 +937,12 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
>  	if (!skb)
>  		return ERR_PTR(-ENOMEM);
>  
> -	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg);
> +	ret = skb_cow_data(skb, 0, &trailer);
> +	if (unlikely(ret < 0)) {
> +		kfree_skb(skb);
> +		return ERR_PTR(ret);
> +	}
> +	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg, ret);
>  	if (!req) {
>  		kfree_skb(skb);
>  		return ERR_PTR(-ENOMEM);

There's a problem here (and in macsec_encrypt): you need to update the
call to sg_init_table, like I did in my patch.  Otherwise,
sg_init_table() is going to access sg[MAX_SKB_FRAGS], which may be
past what you allocated.

How did you test this? ;)

-- 
Sabrina
