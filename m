From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net v2] sctp: fix ICMP processing if skb is non-linear
Date: Thu, 25 May 2017 14:29:29 -0300
Message-ID: <20170525172929.GA29312@localhost.localdomain>
References: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Xin Long <lucien.xin@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59394 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1424806AbdEYR3c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 13:29:32 -0400
Content-Disposition: inline
In-Reply-To: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 07:14:56PM +0200, Davide Caratti wrote:
> sometimes ICMP replies to INIT chunks are ignored by the client, even if
> the encapsulated SCTP headers match an open socket. This happens when the
> ICMP packet is carried by a paged skb: use skb_header_pointer() to read
> packet contents beyond the SCTP header, so that chunk header and initiate
> tag are validated correctly.
> 
> v2:
> - don't use skb_header_pointer() to read the transport header, since
>   icmp_socket_deliver() already puts these 8 bytes in the linear area.
> - change commit message to make specific reference to INIT chunks.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

LGTM
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/input.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 0e06a27..ba9ad32 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -473,15 +473,14 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
>  			     struct sctp_association **app,
>  			     struct sctp_transport **tpp)
>  {
> +	struct sctp_init_chunk *chunkhdr, _chunkhdr;
>  	union sctp_addr saddr;
>  	union sctp_addr daddr;
>  	struct sctp_af *af;
>  	struct sock *sk = NULL;
>  	struct sctp_association *asoc;
>  	struct sctp_transport *transport = NULL;
> -	struct sctp_init_chunk *chunkhdr;
>  	__u32 vtag = ntohl(sctphdr->vtag);
> -	int len = skb->len - ((void *)sctphdr - (void *)skb->data);
>  
>  	*app = NULL; *tpp = NULL;
>  
> @@ -516,13 +515,16 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
>  	 * discard the packet.
>  	 */
>  	if (vtag == 0) {
> -		chunkhdr = (void *)sctphdr + sizeof(struct sctphdr);
> -		if (len < sizeof(struct sctphdr) + sizeof(sctp_chunkhdr_t)
> -			  + sizeof(__be32) ||
> +		/* chunk header + first 4 octects of init header */
> +		chunkhdr = skb_header_pointer(skb, skb_transport_offset(skb) +
> +					      sizeof(struct sctphdr),
> +					      sizeof(struct sctp_chunkhdr) +
> +					      sizeof(__be32), &_chunkhdr);
> +		if (!chunkhdr ||
>  		    chunkhdr->chunk_hdr.type != SCTP_CID_INIT ||
> -		    ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag) {
> +		    ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag)
>  			goto out;
> -		}
> +
>  	} else if (vtag != asoc->c.peer_vtag) {
>  		goto out;
>  	}
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
