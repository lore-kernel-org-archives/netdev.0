From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: Pack dst_cookie into 1st cacheline hole
 for 64bit host
Date: Mon, 5 Aug 2013 07:42:12 -0400
Message-ID: <20130805114212.GA10956@hmsreliant.think-freely.org>
References: <1375693983-22824-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53076 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab3HELmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 07:42:35 -0400
Content-Disposition: inline
In-Reply-To: <1375693983-22824-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 05:13:03PM +0800, Fan Du wrote:
> As dst_cookie is used in fast path sctp_transport_dst_check.
> 
> Before:
> struct sctp_transport {
> 	struct list_head           transports;           /*     0    16 */
> 	atomic_t                   refcnt;               /*    16     4 */
> 	__u32                      dead:1;               /*    20:31  4 */
> 	__u32                      rto_pending:1;        /*    20:30  4 */
> 	__u32                      hb_sent:1;            /*    20:29  4 */
> 	__u32                      pmtu_pending:1;       /*    20:28  4 */
> 
> 	/* XXX 28 bits hole, try to pack */
> 
> 	__u32                      sack_generation;      /*    24     4 */
> 
> 	/* XXX 4 bytes hole, try to pack */
> 
> 	struct flowi               fl;                   /*    32    64 */
> 	/* --- cacheline 1 boundary (64 bytes) was 32 bytes ago --- */
> 	union sctp_addr            ipaddr;               /*    96    28 */
> 
> After:
> struct sctp_transport {
> 	struct list_head           transports;           /*     0    16 */
> 	atomic_t                   refcnt;               /*    16     4 */
> 	__u32                      dead:1;               /*    20:31  4 */
> 	__u32                      rto_pending:1;        /*    20:30  4 */
> 	__u32                      hb_sent:1;            /*    20:29  4 */
> 	__u32                      pmtu_pending:1;       /*    20:28  4 */
> 
> 	/* XXX 28 bits hole, try to pack */
> 
> 	__u32                      sack_generation;      /*    24     4 */
> 	u32                        dst_cookie;           /*    28     4 */
> 	struct flowi               fl;                   /*    32    64 */
> 	/* --- cacheline 1 boundary (64 bytes) was 32 bytes ago --- */
> 	union sctp_addr            ipaddr;               /*    96    28 */
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  include/net/sctp/structs.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index c0f4e29..d9c93a7 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -782,6 +782,7 @@ struct sctp_transport {
>  
>  	/* Has this transport moved the ctsn since we last sacked */
>  	__u32 sack_generation;
> +	u32 dst_cookie;
>  
>  	struct flowi fl;
>  
> @@ -946,7 +947,6 @@ struct sctp_transport {
>  	__u64 hb_nonce;
>  
>  	struct rcu_head rcu;
> -	u32 dst_cookie;
>  };
>  
>  struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
> -- 
> 1.7.9.5
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
