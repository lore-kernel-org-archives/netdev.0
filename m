From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 3/3] sctp: remove the dead field of sctp_transport
Date: Thu, 21 Jan 2016 15:54:38 -0200
Message-ID: <20160121175438.GF3452@mrl.redhat.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
 <9467f6a273956a9b49c95f509a36e10371a481c2.1453398443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545AbcAURyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 12:54:40 -0500
Content-Disposition: inline
In-Reply-To: <9467f6a273956a9b49c95f509a36e10371a481c2.1453398443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 01:49:09AM +0800, Xin Long wrote:
> After we use refcnt to check if transport is alive, the dead can be
> removed from sctp_transport.
> 
> The traversal of transport_addr_list in procfs dump is using
> list_for_each_entry_rcu, no need to check if it has been freed.
> 
> sctp_generate_t3_rtx_event and sctp_generate_heartbeat_event is
> protected by sock lock, it's not necessary to check dead, either.
> also, the timers are cancelled when sctp_transport_free() is
> called, that it doesn't wait for refcnt to reach 0 to cancel them.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/net/sctp/structs.h |  3 +--
>  net/sctp/proc.c            |  4 ----
>  net/sctp/sm_sideeffect.c   | 12 ------------
>  net/sctp/transport.c       |  4 +---
>  4 files changed, 2 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 344da04..205630b 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -756,7 +756,6 @@ struct sctp_transport {
>  
>  	/* Reference counting. */
>  	atomic_t refcnt;
> -	__u32	 dead:1,
>  		/* RTO-Pending : A flag used to track if one of the DATA
>  		 *		chunks sent to this address is currently being
>  		 *		used to compute a RTT. If this flag is 0,
> @@ -766,7 +765,7 @@ struct sctp_transport {
>  		 *		calculation completes (i.e. the DATA chunk
>  		 *		is SACK'd) clear this flag.
>  		 */
> -		 rto_pending:1,
> +	__u32	rto_pending:1,
>  
>  		/*
>  		 * hb_sent : a flag that signals that we have a pending
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index c74a810..ded7d93 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -165,8 +165,6 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
>  	list_for_each_entry_rcu(transport, &assoc->peer.transport_addr_list,
>  			transports) {
>  		addr = &transport->ipaddr;
> -		if (transport->dead)
> -			continue;
>  
>  		af = sctp_get_af_specific(addr->sa.sa_family);
>  		if (af->cmp_addr(addr, primary)) {
> @@ -499,8 +497,6 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  
>  	list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
>  				transports) {
> -		if (tsp->dead)
> -			continue;
>  		/*
>  		 * The remote address (ADDR)
>  		 */
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 2e21384..b5327bb 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -259,12 +259,6 @@ void sctp_generate_t3_rtx_event(unsigned long peer)
>  		goto out_unlock;
>  	}
>  
> -	/* Is this transport really dead and just waiting around for
> -	 * the timer to let go of the reference?
> -	 */
> -	if (transport->dead)
> -		goto out_unlock;
> -
>  	/* Run through the state machine.  */
>  	error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
>  			   SCTP_ST_TIMEOUT(SCTP_EVENT_TIMEOUT_T3_RTX),
> @@ -380,12 +374,6 @@ void sctp_generate_heartbeat_event(unsigned long data)
>  		goto out_unlock;
>  	}
>  
> -	/* Is this structure just waiting around for us to actually
> -	 * get destroyed?
> -	 */
> -	if (transport->dead)
> -		goto out_unlock;
> -
>  	error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
>  			   SCTP_ST_TIMEOUT(SCTP_EVENT_TIMEOUT_HEARTBEAT),
>  			   asoc->state, asoc->ep, asoc,
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 69f3799..a431c14 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -132,8 +132,6 @@ fail:
>   */
>  void sctp_transport_free(struct sctp_transport *transport)
>  {
> -	transport->dead = 1;
> -
>  	/* Try to delete the heartbeat timer.  */
>  	if (del_timer(&transport->hb_timer))
>  		sctp_transport_put(transport);
> @@ -169,7 +167,7 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
>   */
>  static void sctp_transport_destroy(struct sctp_transport *transport)
>  {
> -	if (unlikely(!transport->dead)) {
> +	if (unlikely(atomic_read(&transport->refcnt))) {
>  		WARN(1, "Attempt to destroy undead transport %p!\n", transport);
>  		return;
>  	}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
