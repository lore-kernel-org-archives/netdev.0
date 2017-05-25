From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] sctp: fix ICMP processing if skb is non-linear
Date: Thu, 25 May 2017 13:58:34 -0400
Message-ID: <8eee2583-488f-9f90-2323-2dd19f26acbf@redhat.com>
References: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34946 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759580AbdEYR6h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 13:58:37 -0400
In-Reply-To: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2017 01:14 PM, Davide Caratti wrote:
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

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad


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
> 
