From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: load transport header after sk_filter
Date: Mon, 18 Jul 2016 08:59:06 -0300
Message-ID: <20160718115906.GB9937@localhost.localdomain>
References: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbcGRL7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 07:59:10 -0400
Content-Disposition: inline
In-Reply-To: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 16, 2016 at 05:33:15PM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Do not cache pointers into the skb linear segment across sk_filter.
> The function call can trigger pskb_expand_head.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Just note that this change is included in 3acb50c18d8d ("sctp: delay
as much as possible skb_linearize") and accepting this one in net will
cause a conflict when merging them. Thanks

> ---
> 
> No Fixes tag: existed at the start of git log.
> 
> It is probably not necessary to store chunk->sctp_hdr at all, as
> chunk->skb exists. That is harder to verify, so not suitable for net.
> 
> SCTP sk_filter trimming does not work as expected for most packets.
> sctp_inq_pop marks most truncated linear packets as discarded with
> pdiscard = 1. The following crude change would make trimming behave as
> expected on linear data chunks but is probably not safe as is.
> 
> -        if (unlikely(skb_is_nonlinear(chunk->skb))) {
> +        if (1) {
> ---
>  net/sctp/input.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index a701527..47cf460 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -112,7 +112,6 @@ int sctp_rcv(struct sk_buff *skb)
>  	struct sctp_ep_common *rcvr;
>  	struct sctp_transport *transport = NULL;
>  	struct sctp_chunk *chunk;
> -	struct sctphdr *sh;
>  	union sctp_addr src;
>  	union sctp_addr dest;
>  	int family;
> @@ -127,8 +126,6 @@ int sctp_rcv(struct sk_buff *skb)
>  	if (skb_linearize(skb))
>  		goto discard_it;
>  
> -	sh = sctp_hdr(skb);
> -
>  	/* Pull up the IP and SCTP headers. */
>  	__skb_pull(skb, skb_transport_offset(skb));
>  	if (skb->len < sizeof(struct sctphdr))
> @@ -230,7 +227,7 @@ int sctp_rcv(struct sk_buff *skb)
>  	chunk->rcvr = rcvr;
>  
>  	/* Remember the SCTP header. */
> -	chunk->sctp_hdr = sh;
> +	chunk->sctp_hdr = sctp_hdr(skb);
>  
>  	/* Set the source and destination addresses of the incoming chunk.  */
>  	sctp_init_addrs(chunk, &src, &dest);
> -- 
> 2.8.0.rc3.226.g39d4020
> 
