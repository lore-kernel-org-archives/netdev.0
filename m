From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC net-next 3/7] sctp: add dst_pending_confirm flag
Date: Wed, 21 Dec 2016 09:11:08 -0500
Message-ID: <20161221141108.GB23197@hmsreliant.think-freely.org>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>
 <1482094596-26046-4-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42839 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcLUOMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 09:12:19 -0500
Content-Disposition: inline
In-Reply-To: <1482094596-26046-4-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 18, 2016 at 10:56:32PM +0200, Julian Anastasov wrote:
> Add new transport flag to allow sockets to confirm neighbour.
> When same struct dst_entry can be used for many different
> neighbours we can not use it for pending confirmations.
> The flag is propagated from transport to every packet.
> It is reset when cached dst is reset.
> 
> Reported-by: YueHaibing <yuehaibing@huawei.com>
> Fixes: 5110effee8fd ("net: Do delayed neigh confirmation.")
> Fixes: f2bb4bedf35d ("ipv4: Cache output routes in fib_info nexthops.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/sctp/sctp.h    |  6 ++----
>  include/net/sctp/structs.h |  4 ++++
>  net/sctp/associola.c       |  3 +--
>  net/sctp/output.c          | 10 +++++++++-
>  net/sctp/outqueue.c        |  2 +-
>  net/sctp/sm_make_chunk.c   |  6 ++----
>  net/sctp/sm_sideeffect.c   |  2 +-
>  net/sctp/socket.c          |  4 ++--
>  net/sctp/transport.c       | 18 +++++++++++++++++-
>  9 files changed, 39 insertions(+), 16 deletions(-)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index f0dcaeb..85d9083 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -586,10 +586,8 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
>   */
>  static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
>  {
> -	if (t->dst && !dst_check(t->dst, t->dst_cookie)) {
> -		dst_release(t->dst);
> -		t->dst = NULL;
> -	}
> +	if (t->dst && !dst_check(t->dst, t->dst_cookie))
> +		sctp_transport_dst_release(t);
>  
>  	return t->dst;
>  }
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 92daabd..e842e84 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -838,6 +838,8 @@ struct sctp_transport {
>  
>  	__u32 burst_limited;	/* Holds old cwnd when max.burst is applied */
>  
> +	__u32 dst_pending_confirm;	/* need to confirm neighbour */
> +
>  	/* Destination */
>  	struct dst_entry *dst;
>  	/* Source address. */
> @@ -980,6 +982,8 @@ void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
>  void sctp_transport_reset(struct sctp_transport *);
>  void sctp_transport_update_pmtu(struct sock *, struct sctp_transport *, u32);
>  void sctp_transport_immediate_rtx(struct sctp_transport *);
> +void sctp_transport_dst_release(struct sctp_transport *t);
> +void sctp_transport_dst_confirm(struct sctp_transport *t);
>  
>  
>  /* This is the structure we use to queue packets as they come into
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 68428e1..7bd26e0 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -820,8 +820,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>  		if (transport->state != SCTP_UNCONFIRMED)
>  			transport->state = SCTP_INACTIVE;
>  		else {
> -			dst_release(transport->dst);
> -			transport->dst = NULL;
> +			sctp_transport_dst_release(transport);
>  			ulp_notify = false;
>  		}
>  
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index f5320a8..4684a00 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -550,6 +550,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	struct sctp_association *asoc = tp->asoc;
>  	struct sctp_chunk *chunk, *tmp;
>  	int pkt_count, gso = 0;
> +	int confirm;
>  	struct dst_entry *dst;
>  	struct sk_buff *head;
>  	struct sctphdr *sh;
> @@ -628,7 +629,14 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  			asoc->peer.last_sent_to = tp;
>  	}
>  	head->ignore_df = packet->ipfragok;
> -	tp->af_specific->sctp_xmit(head, tp);
> +	confirm = tp->dst_pending_confirm;
> +	if (confirm)
> +		head->dst_pending_confirm = 1;
Why not use your confirm helper function here?

> +	/* neighbour should be confirmed on successful transmission or
> +	 * positive error
> +	 */
> +	if (tp->af_specific->sctp_xmit(head, tp) >= 0 && confirm)
> +		tp->dst_pending_confirm = 0;
>  
>  out:
>  	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index e540826..8234799 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1641,7 +1641,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  
>  		if (forward_progress) {
>  			if (transport->dst)
> -				dst_confirm(transport->dst);
> +				sctp_transport_dst_confirm(transport);
>  		}
>  	}
>  
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 9e9690b..6fb15bf 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3317,8 +3317,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> -			dst_release(transport->dst);
> -			transport->dst = NULL;
> +			sctp_transport_dst_release(transport);
>  		}
>  		break;
>  	case SCTP_PARAM_DEL_IP:
> @@ -3332,8 +3331,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> -			dst_release(transport->dst);
> -			transport->dst = NULL;
> +			sctp_transport_dst_release(transport);
>  		}
>  		break;
>  	default:
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index c345bf1..9255b29 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -723,7 +723,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	 * forward progress.
>  	 */
>  	if (t->dst)
> -		dst_confirm(t->dst);
> +		sctp_transport_dst_confirm(t);
>  
>  	/* The receiver of the HEARTBEAT ACK should also perform an
>  	 * RTT measurement for that destination transport address
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 318c678..9ee676a 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -588,7 +588,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  			list_for_each_entry(trans,
>  			    &asoc->peer.transport_addr_list, transports) {
>  				/* Clear the source and route cache */
> -				dst_release(trans->dst);
> +				sctp_transport_dst_release(trans);
>  				trans->cwnd = min(4*asoc->pathmtu, max_t(__u32,
>  				    2*asoc->pathmtu, 4380));
>  				trans->ssthresh = asoc->peer.i.a_rwnd;
> @@ -839,7 +839,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		 */
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  					transports) {
> -			dst_release(transport->dst);
> +			sctp_transport_dst_release(transport);
>  			sctp_transport_route(transport, NULL,
>  					     sctp_sk(asoc->base.sk));
>  		}
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index ce54dce..db66514 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -227,7 +227,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
>  {
>  	/* If we don't have a fresh route, look one up */
>  	if (!transport->dst || transport->dst->obsolete) {
> -		dst_release(transport->dst);
> +		sctp_transport_dst_release(transport);
>  		transport->af_specific->get_dst(transport, &transport->saddr,
>  						&transport->fl, sk);
>  	}
> @@ -659,3 +659,19 @@ void sctp_transport_immediate_rtx(struct sctp_transport *t)
>  			sctp_transport_hold(t);
>  	}
>  }
> +
> +/* Drop dst */
> +void sctp_transport_dst_release(struct sctp_transport *t)
> +{
> +	dst_release(t->dst);
> +	t->dst = NULL;
> +	t->dst_pending_confirm = 0;
> +}
> +
> +/* Schedule neighbour confirm */
> +void sctp_transport_dst_confirm(struct sctp_transport *t)
> +{
> +	if (!t->dst_pending_confirm)
> +		t->dst_pending_confirm = 1;
I'm not sure why you check it for being zero before setting it here, just set it
unilaterally instead, or are you trying to avoid dirtying a cacheline?

Neil

> +}
> +
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
