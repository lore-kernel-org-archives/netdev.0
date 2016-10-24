From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: fix the panic caused by route update
Date: Mon, 24 Oct 2016 10:05:11 -0400
Message-ID: <20161024140511.GA23714@hmsreliant.think-freely.org>
References: <a0659fd9a23fc95fe9a586be4b57c8032c8a6060.1477242069.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33215 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935741AbcJXOFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 10:05:31 -0400
Content-Disposition: inline
In-Reply-To: <a0659fd9a23fc95fe9a586be4b57c8032c8a6060.1477242069.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2016 at 01:01:09AM +0800, Xin Long wrote:
> Commit 7303a1475008 ("sctp: identify chunks that need to be fragmented
> at IP level") made the chunk be fragmented at IP level in the next round
> if it's size exceed PMTU.
> 
> But there still is another case, PMTU can be updated if transport's dst
> expires and transport's pmtu_pending is set in sctp_packet_transmit. If
> the new PMTU is less than the chunk, the same issue with that commit can
> be triggered.
> 
> So we should drop this packet and let it retransmit in another round
> where it would be fragmented at IP level.
> 
> This patch is to fix it by checking the chunk size after PMTU may be
> updated and dropping this packet if it's size exceed PMTU.
> 
> Fixes: 90017accff61 ("sctp: Add GSO support")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/output.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 2a5c189..6cb0df8 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -418,6 +418,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	__u8 has_data = 0;
>  	int gso = 0;
>  	int pktcount = 0;
> +	int auth_len = 0;
>  	struct dst_entry *dst;
>  	unsigned char *auth = NULL;	/* pointer to auth in skb data */
>  
> @@ -510,7 +511,12 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  			list_for_each_entry(chunk, &packet->chunk_list, list) {
>  				int padded = SCTP_PAD4(chunk->skb->len);
>  
> -				if (pkt_size + padded > tp->pathmtu)
> +				if (chunk == packet->auth)
> +					auth_len = padded;
> +				else if (auth_len + padded + packet->overhead >
> +					 tp->pathmtu)
> +					goto nomem;
> +				else if (pkt_size + padded > tp->pathmtu)
>  					break;
>  				pkt_size += padded;
>  			}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@txudriver.com>
