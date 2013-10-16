From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework pfkey_sadb2xfrm_user_sec_ctx
Date: Wed, 16 Oct 2013 11:15:48 -0400
Message-ID: <1541456.gnvYckRYYL@sifl>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:55125 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab3JPPPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:15:52 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so4606486qac.15
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:15:52 -0700 (PDT)
In-Reply-To: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 16, 2013 02:15:14 PM Fan Du wrote:
> Taking advantages of sadb_x_sec_ctx and xfrm_user_sec_ctx share the same
> structure arrangement, rework pfkey_sadb2xfrm_user_sec_ctx by casting
> sadb_x_sec_ctx into xfrm_user_sec_ctx with minor len fix.
> 
> Then we can:
>  -Avoid kmalloc/free memory for xfrm_user_sec_ctx, sadb_x_sec_ctx would be
>   fine.
>  -Fix missing return value check bug for pfkey_compile_policy when
>   kmalloc fails
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/key/af_key.c |   33 +--------------------------------
>  1 file changed, 1 insertion(+), 32 deletions(-)
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 9d58537..c7d304d 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -435,22 +435,9 @@ static inline int verify_sec_ctx_len(const void *p)
> 
>  static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const
> struct sadb_x_sec_ctx *sec_ctx) {
> -	struct xfrm_user_sec_ctx *uctx = NULL;
> -	int ctx_size = sec_ctx->sadb_x_ctx_len;
> -
> -	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
> -
> -	if (!uctx)
> -		return NULL;
> +	struct xfrm_user_sec_ctx *uctx = (struct xfrm_user_sec_ctx *)sec_ctx;
> 
>  	uctx->len = pfkey_sec_ctx_len(sec_ctx);
> -	uctx->exttype = sec_ctx->sadb_x_sec_exttype;
> -	uctx->ctx_doi = sec_ctx->sadb_x_ctx_doi;
> -	uctx->ctx_alg = sec_ctx->sadb_x_ctx_alg;
> -	uctx->ctx_len = sec_ctx->sadb_x_ctx_len;
> -	memcpy(uctx + 1, sec_ctx + 1,
> -	       uctx->ctx_len);
> -
>  	return uctx;
>  }

The fact that you are now changing sadb_x_sec_ctx->sadb_x_sec_len whenever
pfkey_sadb2xfrm_user_sec_ctx() is called raises an eyebrow.  Can you elaborate 
on why this is not a problem?

-- 
paul moore
www.paul-moore.com
