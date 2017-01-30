From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 RFC net-next 3/7] sctp: add dst_pending_confirm flag
Date: Mon, 30 Jan 2017 09:45:23 -0500
Message-ID: <20170130144523.GA11389@hmswarspite.think-freely.org>
References: <1485613578-19973-1-git-send-email-ja@ssi.bg>
 <1485613578-19973-4-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33896 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753804AbdA3PwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:52:20 -0500
Content-Disposition: inline
In-Reply-To: <1485613578-19973-4-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 04:26:14PM +0200, Julian Anastasov wrote:
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
>  net/sctp/transport.c       | 17 ++++++++++++++++-
>  9 files changed, 38 insertions(+), 16 deletions(-)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 3cfd365b..480b65a 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -593,10 +593,8 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
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
> index 231fa9ac..6a68504 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -804,6 +804,8 @@ struct sctp_transport {
>  
>  	__u32 burst_limited;	/* Holds old cwnd when max.burst is applied */
>  
> +	__u32 dst_pending_confirm;	/* need to confirm neighbour */
> +
>  	/* Destination */
>  	struct dst_entry *dst;
>  	/* Source address. */
> @@ -950,6 +952,8 @@ void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
>  void sctp_transport_reset(struct sctp_transport *);
>  void sctp_transport_update_pmtu(struct sock *, struct sctp_transport *, u32);
>  void sctp_transport_immediate_rtx(struct sctp_transport *);
> +void sctp_transport_dst_release(struct sctp_transport *t);
> +void sctp_transport_dst_confirm(struct sctp_transport *t);
>  
>  
>  /* This is the structure we use to queue packets as they come into
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index e50dc6d..2a6835b 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -832,8 +832,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
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
> index 07ab506..814eac0 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -546,6 +546,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	struct sctp_association *asoc = tp->asoc;
>  	struct sctp_chunk *chunk, *tmp;
>  	int pkt_count, gso = 0;
> +	int confirm;
>  	struct dst_entry *dst;
>  	struct sk_buff *head;
>  	struct sctphdr *sh;
> @@ -624,7 +625,14 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  			asoc->peer.last_sent_to = tp;
>  	}
>  	head->ignore_df = packet->ipfragok;
> -	tp->af_specific->sctp_xmit(head, tp);
> +	confirm = tp->dst_pending_confirm;
> +	if (confirm)
> +		skb_set_dst_pending_confirm(head, 1);
> +	/* neighbour should be confirmed on successful transmission or
> +	 * positive error
> +	 */
> +	if (tp->af_specific->sctp_xmit(head, tp) >= 0 && confirm)
> +		tp->dst_pending_confirm = 0;
>  
>  out:
>  	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 65abe22..db352e5 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1654,7 +1654,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  
>  		if (forward_progress) {
>  			if (transport->dst)
> -				dst_confirm(transport->dst);
> +				sctp_transport_dst_confirm(transport);
>  		}
>  	}
>  
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index ad3445b..c7d3249 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3333,8 +3333,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> -			dst_release(transport->dst);
> -			transport->dst = NULL;
> +			sctp_transport_dst_release(transport);
>  		}
>  		break;
>  	case SCTP_PARAM_DEL_IP:
> @@ -3348,8 +3347,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
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
> index a455271..51abcc9 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -755,7 +755,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	 * forward progress.
>  	 */
>  	if (t->dst)
> -		dst_confirm(t->dst);
> +		sctp_transport_dst_confirm(t);
>  
>  	/* The receiver of the HEARTBEAT ACK should also perform an
>  	 * RTT measurement for that destination transport address
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d699d2c..9e98c87 100644
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
> index baa1ac0..df274ff 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -240,7 +240,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
>  {
>  	/* If we don't have a fresh route, look one up */
>  	if (!transport->dst || transport->dst->obsolete) {
> -		dst_release(transport->dst);
> +		sctp_transport_dst_release(transport);
>  		transport->af_specific->get_dst(transport, &transport->saddr,
>  						&transport->fl, sk);
>  	}
> @@ -672,3 +672,18 @@ void sctp_transport_immediate_rtx(struct sctp_transport *t)
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
> +	t->dst_pending_confirm = 1;
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
For the SCTP bits:

Acked-by: Neil Horman <nhorman@tuxdriver.com>
