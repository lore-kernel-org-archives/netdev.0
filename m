From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: get sock from transport in
 sctp_transport_update_pmtu
Date: Tue, 4 Apr 2017 18:51:51 -0300
Message-ID: <20170404215151.GB911@localhost.localdomain>
References: <c3e6d7cac1bc8d426be814c17c87dd9a7d4f3df9.1491284395.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57046 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754090AbdDDVvz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 17:51:55 -0400
Content-Disposition: inline
In-Reply-To: <c3e6d7cac1bc8d426be814c17c87dd9a7d4f3df9.1491284395.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 01:39:55PM +0800, Xin Long wrote:
> This patch is almost to revert commit 02f3d4ce9e81 ("sctp: Adjust PMTU
> updates to accomodate route invalidation."). As t->asoc can't be NULL
> in sctp_transport_update_pmtu, it could get sk from asoc, and no need
> to pass sk into that function.
> 
> It is also to remove some duplicated codes from that function.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/net/sctp/sctp.h    |  5 ++---
>  include/net/sctp/structs.h |  6 +++---
>  net/sctp/associola.c       |  6 +++---
>  net/sctp/input.c           |  4 ++--
>  net/sctp/output.c          |  4 ++--
>  net/sctp/socket.c          |  6 +++---
>  net/sctp/transport.c       | 19 +++++++------------
>  7 files changed, 22 insertions(+), 28 deletions(-)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index d75caa7..069582e 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -448,10 +448,9 @@ static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
>  	return frag;
>  }
>  
> -static inline void sctp_assoc_pending_pmtu(struct sock *sk, struct sctp_association *asoc)
> +static inline void sctp_assoc_pending_pmtu(struct sctp_association *asoc)
>  {
> -
> -	sctp_assoc_sync_pmtu(sk, asoc);
> +	sctp_assoc_sync_pmtu(asoc);
>  	asoc->pmtu_pending = 0;
>  }
>  
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index a127b7c..138f861 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -952,8 +952,8 @@ void sctp_transport_lower_cwnd(struct sctp_transport *, sctp_lower_cwnd_t);
>  void sctp_transport_burst_limited(struct sctp_transport *);
>  void sctp_transport_burst_reset(struct sctp_transport *);
>  unsigned long sctp_transport_timeout(struct sctp_transport *);
> -void sctp_transport_reset(struct sctp_transport *);
> -void sctp_transport_update_pmtu(struct sock *, struct sctp_transport *, u32);
> +void sctp_transport_reset(struct sctp_transport *t);
> +void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu);
>  void sctp_transport_immediate_rtx(struct sctp_transport *);
>  void sctp_transport_dst_release(struct sctp_transport *t);
>  void sctp_transport_dst_confirm(struct sctp_transport *t);
> @@ -1954,7 +1954,7 @@ void sctp_assoc_update(struct sctp_association *old,
>  
>  __u32 sctp_association_get_next_tsn(struct sctp_association *);
>  
> -void sctp_assoc_sync_pmtu(struct sock *, struct sctp_association *);
> +void sctp_assoc_sync_pmtu(struct sctp_association *asoc);
>  void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned int);
>  void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned int);
>  void sctp_assoc_set_primary(struct sctp_association *,
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 0b26df5..a9708da 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1412,7 +1412,7 @@ sctp_assoc_choose_alter_transport(struct sctp_association *asoc,
>  /* Update the association's pmtu and frag_point by going through all the
>   * transports. This routine is called when a transport's PMTU has changed.
>   */
> -void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
> +void sctp_assoc_sync_pmtu(struct sctp_association *asoc)
>  {
>  	struct sctp_transport *t;
>  	__u32 pmtu = 0;
> @@ -1424,8 +1424,8 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
>  	list_for_each_entry(t, &asoc->peer.transport_addr_list,
>  				transports) {
>  		if (t->pmtu_pending && t->dst) {
> -			sctp_transport_update_pmtu(sk, t,
> -						   SCTP_TRUNC4(dst_mtu(t->dst)));
> +			sctp_transport_update_pmtu(
> +					t, SCTP_TRUNC4(dst_mtu(t->dst)));
>  			t->pmtu_pending = 0;
>  		}
>  		if (!pmtu || (t->pathmtu < pmtu))
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 2a28ab2..0e06a27 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -401,10 +401,10 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
>  
>  	if (t->param_flags & SPP_PMTUD_ENABLE) {
>  		/* Update transports view of the MTU */
> -		sctp_transport_update_pmtu(sk, t, pmtu);
> +		sctp_transport_update_pmtu(t, pmtu);
>  
>  		/* Update association pmtu. */
> -		sctp_assoc_sync_pmtu(sk, asoc);
> +		sctp_assoc_sync_pmtu(asoc);
>  	}
>  
>  	/* Retransmit with the new pmtu setting.
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index ec4d50a..1409a87 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -105,10 +105,10 @@ void sctp_packet_config(struct sctp_packet *packet, __u32 vtag,
>  	if (!sctp_transport_dst_check(tp)) {
>  		sctp_transport_route(tp, NULL, sctp_sk(sk));
>  		if (asoc->param_flags & SPP_PMTUD_ENABLE)
> -			sctp_assoc_sync_pmtu(sk, asoc);
> +			sctp_assoc_sync_pmtu(asoc);
>  	} else if (!sctp_transport_pmtu_check(tp)) {
>  		if (asoc->param_flags & SPP_PMTUD_ENABLE)
> -			sctp_assoc_sync_pmtu(sk, asoc);
> +			sctp_assoc_sync_pmtu(asoc);
>  	}
>  
>  	/* If there a is a prepend chunk stick it on the list before
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 12fbae2..c1401f4 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1907,7 +1907,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>  	}
>  
>  	if (asoc->pmtu_pending)
> -		sctp_assoc_pending_pmtu(sk, asoc);
> +		sctp_assoc_pending_pmtu(asoc);
>  
>  	/* If fragmentation is disabled and the message length exceeds the
>  	 * association fragmentation point, return EMSGSIZE.  The I-D
> @@ -2435,7 +2435,7 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
>  	if ((params->spp_flags & SPP_PMTUD_DISABLE) && params->spp_pathmtu) {
>  		if (trans) {
>  			trans->pathmtu = params->spp_pathmtu;
> -			sctp_assoc_sync_pmtu(sctp_opt2sk(sp), asoc);
> +			sctp_assoc_sync_pmtu(asoc);
>  		} else if (asoc) {
>  			asoc->pathmtu = params->spp_pathmtu;
>  		} else {
> @@ -2451,7 +2451,7 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
>  				(trans->param_flags & ~SPP_PMTUD) | pmtud_change;
>  			if (update) {
>  				sctp_transport_pmtu(trans, sctp_opt2sk(sp));
> -				sctp_assoc_sync_pmtu(sctp_opt2sk(sp), asoc);
> +				sctp_assoc_sync_pmtu(asoc);
>  			}
>  		} else if (asoc) {
>  			asoc->param_flags =
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 3379668..721eeeb 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -251,14 +251,13 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
>  		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
>  }
>  
> -void sctp_transport_update_pmtu(struct sock *sk, struct sctp_transport *t, u32 pmtu)
> +void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
>  {
> -	struct dst_entry *dst;
> +	struct dst_entry *dst = sctp_transport_dst_check(t);
>  
>  	if (unlikely(pmtu < SCTP_DEFAULT_MINSEGMENT)) {
>  		pr_warn("%s: Reported pmtu %d too low, using default minimum of %d\n",
> -			__func__, pmtu,
> -			SCTP_DEFAULT_MINSEGMENT);
> +			__func__, pmtu, SCTP_DEFAULT_MINSEGMENT);
>  		/* Use default minimum segment size and disable
>  		 * pmtu discovery on this transport.
>  		 */
> @@ -267,17 +266,13 @@ void sctp_transport_update_pmtu(struct sock *sk, struct sctp_transport *t, u32 p
>  		t->pathmtu = pmtu;
>  	}
>  
> -	dst = sctp_transport_dst_check(t);
> -	if (!dst)
> -		t->af_specific->get_dst(t, &t->saddr, &t->fl, sk);
> -
>  	if (dst) {
> -		dst->ops->update_pmtu(dst, sk, NULL, pmtu);
> -
> +		dst->ops->update_pmtu(dst, t->asoc->base.sk, NULL, pmtu);
>  		dst = sctp_transport_dst_check(t);
> -		if (!dst)
> -			t->af_specific->get_dst(t, &t->saddr, &t->fl, sk);
>  	}
> +
> +	if (!dst)
> +		t->af_specific->get_dst(t, &t->saddr, &t->fl, t->asoc->base.sk);
>  }
>  
>  /* Caches the dst entry and source address for a transport's destination
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
