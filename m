From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: remove unused multiple cookie keys
Date: Tue, 12 Feb 2013 09:36:27 -0500
Message-ID: <20130212143627.GA7849@hmsreliant.think-freely.org>
References: <cover.1360593589.git.dborkman@redhat.com>
 <c1d3c108e6dc72f14e6251543b9ff826f56f5f78.1360593589.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45514 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759477Ab3BLOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 09:36:42 -0500
Content-Disposition: inline
In-Reply-To: <c1d3c108e6dc72f14e6251543b9ff826f56f5f78.1360593589.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2013 at 03:50:07PM +0100, Daniel Borkmann wrote:
> Vlad says: The whole multiple cookie keys code is completely unused
> and has been all this time. Noone uses anything other then the
> secret_key[0] since there is no changeover support anywhere.
> 
> Thus, for now clean up its left-over fragments.
> 
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>  
>  	/* Remove and free the port */
>  	if (sctp_sk(ep->base.sk)->bind_hash)
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index e1c5fc2..1063b83 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1650,8 +1650,8 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
>  
>  		/* Sign the message.  */
>  		sg_init_one(&sg, &cookie->c, bodysize);
> -		keylen = SCTP_SECRET_SIZE;
> -		key = (char *)ep->secret_key[ep->current_key];
> +		keylen = sizeof(ep->secret_key);
> +		key = (char *) ep->secret_key;
You can drop the use of they local key variable entirely here.
crypto_hash_setkey takes a u8 * as a key parameter, so you can pass
ep->secret_key directly.

>  		desc.tfm = sctp_sk(ep->base.sk)->hmac;
>  		desc.flags = 0;
>  
> @@ -1718,9 +1718,9 @@ struct sctp_association *sctp_unpack_cookie(
>  		goto no_hmac;
>  
>  	/* Check the signature.  */
> -	keylen = SCTP_SECRET_SIZE;
>  	sg_init_one(&sg, bear_cookie, bodysize);
> -	key = (char *)ep->secret_key[ep->current_key];
> +	keylen = sizeof(ep->secret_key);
> +	key = (char *) ep->secret_key;
Ditto the above.


Otherwise it looks good.
Neil
