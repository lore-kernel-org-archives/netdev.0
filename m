From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: sctp: remove sctp_ep_common struct
 member 'malloced'
Date: Mon, 15 Apr 2013 10:04:54 -0400
Message-ID: <516C0906.6020905@gmail.com>
References: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:43802 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3DOOE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 10:04:59 -0400
In-Reply-To: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2013 09:27 AM, Daniel Borkmann wrote:
> There is actually no need to keep this member in the structure, because
> after init it's always 1 anyway, thus always kfree called. This seems to
> be an ancient leftover from the very initial implementation from 2.5
> times. Only in case the initialization of an association fails, we leave
> base.malloced as 0, but we nevertheless kfree it in the error path in
> sctp_association_new().
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
> ---
>   Likely, there are also other such candidates in SCTP. Will have a look
>   for some follow-ups.
>
>   include/net/sctp/structs.h |  2 --
>   net/sctp/associola.c       |  8 ++------
>   net/sctp/endpointola.c     | 10 +++-------
>   3 files changed, 5 insertions(+), 15 deletions(-)
>
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 0e0f9d2..3e80eed 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1174,11 +1174,9 @@ struct sctp_ep_common {
>   	/* Some fields to help us manage this object.
>   	 *   refcnt   - Reference count access to this object.
>   	 *   dead     - Do not attempt to use this object.
> -	 *   malloced - Do we need to kfree this object?
>   	 */
>   	atomic_t    refcnt;
>   	char	    dead;
> -	char	    malloced;
>
>   	/* What socket does this endpoint belong to?  */
>   	struct sock *sk;
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index d2709e2..b893aa6 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -105,7 +105,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>   	/* Initialize the object handling fields.  */
>   	atomic_set(&asoc->base.refcnt, 1);
>   	asoc->base.dead = 0;
> -	asoc->base.malloced = 0;
>
>   	/* Initialize the bind addr area.  */
>   	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
> @@ -371,7 +370,6 @@ struct sctp_association *sctp_association_new(const struct sctp_endpoint *ep,
>   	if (!sctp_association_init(asoc, ep, sk, scope, gfp))
>   		goto fail_init;
>
> -	asoc->base.malloced = 1;
>   	SCTP_DBG_OBJCNT_INC(assoc);
>   	SCTP_DEBUG_PRINTK("Created asoc %p\n", asoc);
>
> @@ -484,10 +482,8 @@ static void sctp_association_destroy(struct sctp_association *asoc)
>
>   	WARN_ON(atomic_read(&asoc->rmem_alloc));
>
> -	if (asoc->base.malloced) {
> -		kfree(asoc);
> -		SCTP_DBG_OBJCNT_DEC(assoc);
> -	}
> +	kfree(asoc);
> +	SCTP_DBG_OBJCNT_DEC(assoc);
>   }
>
>   /* Change the primary destination address for the peer. */
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 12ed45d..46bbfc2 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -122,7 +122,6 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
>   	/* Initialize the basic object fields. */
>   	atomic_set(&ep->base.refcnt, 1);
>   	ep->base.dead = 0;
> -	ep->base.malloced = 1;
>
>   	/* Create an input queue.  */
>   	sctp_inq_init(&ep->base.inqueue);
> @@ -198,7 +197,7 @@ struct sctp_endpoint *sctp_endpoint_new(struct sock *sk, gfp_t gfp)
>   		goto fail;
>   	if (!sctp_endpoint_init(ep, sk, gfp))
>   		goto fail_init;
> -	ep->base.malloced = 1;
> +
>   	SCTP_DBG_OBJCNT_INC(ep);
>   	return ep;
>
> @@ -279,11 +278,8 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>   	if (ep->base.sk)
>   		sock_put(ep->base.sk);
>
> -	/* Finally, free up our memory. */
> -	if (ep->base.malloced) {
> -		kfree(ep);
> -		SCTP_DBG_OBJCNT_DEC(ep);
> -	}
> +	kfree(ep);
> +	SCTP_DBG_OBJCNT_DEC(ep);
>   }
>
>   /* Hold a reference to an endpoint. */
>
