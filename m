From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [v3 PATCH 2/2] SCTP: Convert bind_addr_list locking to RCU
Date: Thu, 13 Sep 2007 13:00:12 -0700
Message-ID: <1189713612.2748.34.camel@w-sridhar2.beaverton.ibm.com>
References: <11897120771278-git-send-email-vladislav.yasevich@hp.com>
	 <1189712077487-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp@hp.com
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:48234 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121AbXIMUEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 16:04:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DK4jXA004319
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:04:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DK4jGj559576
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:04:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DK4iT8011010
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:04:45 -0400
In-Reply-To: <1189712077487-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-13 at 15:34 -0400, Vlad Yasevich wrote:
> Since the sctp_sockaddr_entry is now RCU enabled as part of
> the patch to synchronize sctp_localaddr_list, it makes sense to
> change all handling of these entries to RCU.  This includes the
> sctp_bind_addrs structure and it's list of bound addresses.
> 
> This list is currently protected by an external rw_lock and that
> looks like an overkill.  There are only 2 writers to the list:
> bind()/bindx() calls, and BH processing of ASCONF-ACK chunks.
> These are already seriealized via the socket lock, so they will
> not step on each other.  These are also relatively rare, so we
> should be good with RCU.
> 
> The readers are varied and they are easily converted to RCU.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks
Sridhar
> ---
>  include/net/sctp/structs.h |    7 +--
>  net/sctp/associola.c       |   14 +-----
>  net/sctp/bind_addr.c       |   68 ++++++++++++++++++++----------
>  net/sctp/endpointola.c     |   27 +++---------
>  net/sctp/ipv6.c            |   12 ++---
>  net/sctp/protocol.c        |   25 ++++-------
>  net/sctp/sm_make_chunk.c   |   18 +++-----
>  net/sctp/socket.c          |   98 ++++++++++++-------------------------------
>  8 files changed, 106 insertions(+), 163 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index a89e361..c2fe2dc 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1155,7 +1155,9 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
>  			int flags);
>  int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
>  		       __u8 use_as_src, gfp_t gfp);
> -int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
> +int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
> +			void (*rcu_call)(struct rcu_head *,
> +					  void (*func)(struct rcu_head *)));
>  int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
>  			 struct sctp_sock *);
>  union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
> @@ -1226,9 +1228,6 @@ struct sctp_ep_common {
>  	 * bind_addr.address_list is our set of local IP addresses.
>  	 */
>  	struct sctp_bind_addr bind_addr;
> -
> -	/* Protection during address list comparisons. */
> -	rwlock_t   addr_lock;
>  };
> 
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 2ad1caf..9bad8ba 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -99,7 +99,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
> 
>  	/* Initialize the bind addr area.  */
>  	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
> -	rwlock_init(&asoc->base.addr_lock);
> 
>  	asoc->state = SCTP_STATE_CLOSED;
> 
> @@ -937,8 +936,6 @@ struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
>  {
>  	struct sctp_transport *transport;
> 
> -	sctp_read_lock(&asoc->base.addr_lock);
> -
>  	if ((htons(asoc->base.bind_addr.port) == laddr->v4.sin_port) &&
>  	    (htons(asoc->peer.port) == paddr->v4.sin_port)) {
>  		transport = sctp_assoc_lookup_paddr(asoc, paddr);
> @@ -952,7 +949,6 @@ struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
>  	transport = NULL;
> 
>  out:
> -	sctp_read_unlock(&asoc->base.addr_lock);
>  	return transport;
>  }
> 
> @@ -1376,19 +1372,13 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *asoc,
>  int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
>  			    const union sctp_addr *laddr)
>  {
> -	int found;
> +	int found = 0;
> 
> -	sctp_read_lock(&asoc->base.addr_lock);
>  	if ((asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
>  	    sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
> -				 sctp_sk(asoc->base.sk))) {
> +				 sctp_sk(asoc->base.sk)))
>  		found = 1;
> -		goto out;
> -	}
> 
> -	found = 0;
> -out:
> -	sctp_read_unlock(&asoc->base.addr_lock);
>  	return found;
>  }
> 
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index 7fc369f..d35cbf5 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -167,7 +167,11 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
> 
>  	INIT_LIST_HEAD(&addr->list);
>  	INIT_RCU_HEAD(&addr->rcu);
> -	list_add_tail(&addr->list, &bp->address_list);
> +
> +	/* We always hold a socket lock when calling this function,
> +	 * and that acts as a writer synchronizing lock.
> +	 */
> +	list_add_tail_rcu(&addr->list, &bp->address_list);
>  	SCTP_DBG_OBJCNT_INC(addr);
> 
>  	return 0;
> @@ -176,23 +180,35 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>  /* Delete an address from the bind address list in the SCTP_bind_addr
>   * structure.
>   */
> -int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
> +int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr,
> +			void (*rcu_call)(struct rcu_head *head,
> +					 void (*func)(struct rcu_head *head)))
>  {
> -	struct list_head *pos, *temp;
> -	struct sctp_sockaddr_entry *addr;
> +	struct sctp_sockaddr_entry *addr, *temp;
> 
> -	list_for_each_safe(pos, temp, &bp->address_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	/* We hold the socket lock when calling this function,
> +	 * and that acts as a writer synchronizing lock.
> +	 */
> +	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
>  		if (sctp_cmp_addr_exact(&addr->a, del_addr)) {
>  			/* Found the exact match. */
> -			list_del(pos);
> -			kfree(addr);
> -			SCTP_DBG_OBJCNT_DEC(addr);
> -
> -			return 0;
> +			addr->valid = 0;
> +			list_del_rcu(&addr->list);
> +			break;
>  		}
>  	}
> 
> +	/* Call the rcu callback provided in the args.  This function is
> +	 * called by both BH packet processing and user side socket option
> +	 * processing, but it works on different lists in those 2 contexts.
> +	 * Each context provides it's own callback, whether call_rcu_bh()
> +	 * or call_rcu(), to make sure that we wait for an appropriate time.
> +	 */
> +	if (addr && !addr->valid) {
> +		rcu_call(&addr->rcu, sctp_local_addr_free);
> +		SCTP_DBG_OBJCNT_DEC(addr);
> +	}
> +
>  	return -EINVAL;
>  }
> 
> @@ -302,15 +318,20 @@ int sctp_bind_addr_match(struct sctp_bind_addr *bp,
>  			 struct sctp_sock *opt)
>  {
>  	struct sctp_sockaddr_entry *laddr;
> -	struct list_head *pos;
> -
> -	list_for_each(pos, &bp->address_list) {
> -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> -		if (opt->pf->cmp_addr(&laddr->a, addr, opt))
> -			return 1;
> +	int match = 0;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> +		if (!laddr->valid)
> +			continue;
> +		if (opt->pf->cmp_addr(&laddr->a, addr, opt)) {
> +			match = 1;
> +			break;
> +		}
>  	}
> +	rcu_read_unlock();
> 
> -	return 0;
> +	return match;
>  }
> 
>  /* Find the first address in the bind address list that is not present in
> @@ -325,18 +346,19 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
>  	union sctp_addr			*addr;
>  	void 				*addr_buf;
>  	struct sctp_af			*af;
> -	struct list_head		*pos;
>  	int				i;
> 
> -	list_for_each(pos, &bp->address_list) {
> -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> -
> +	/* This is only called sctp_send_asconf_del_ip() and we hold
> +	 * the socket lock in that code patch, so that address list
> +	 * can't change.
> +	 */
> +	list_for_each_entry(laddr, &bp->address_list, list) {
>  		addr_buf = (union sctp_addr *)addrs;
>  		for (i = 0; i < addrcnt; i++) {
>  			addr = (union sctp_addr *)addr_buf;
>  			af = sctp_get_af_specific(addr->v4.sin_family);
>  			if (!af)
> -				return NULL;
> +				break;
> 
>  			if (opt->pf->cmp_addr(&laddr->a, addr, opt))
>  				break;
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 1404a9e..8f485a0 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -92,7 +92,6 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
> 
>  	/* Initialize the bind addr area */
>  	sctp_bind_addr_init(&ep->base.bind_addr, 0);
> -	rwlock_init(&ep->base.addr_lock);
> 
>  	/* Remember who we are attached to.  */
>  	ep->base.sk = sk;
> @@ -225,21 +224,14 @@ void sctp_endpoint_put(struct sctp_endpoint *ep)
>  struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
>  					       const union sctp_addr *laddr)
>  {
> -	struct sctp_endpoint *retval;
> +	struct sctp_endpoint *retval = NULL;
> 
> -	sctp_read_lock(&ep->base.addr_lock);
>  	if (htons(ep->base.bind_addr.port) == laddr->v4.sin_port) {
>  		if (sctp_bind_addr_match(&ep->base.bind_addr, laddr,
> -					 sctp_sk(ep->base.sk))) {
> +					 sctp_sk(ep->base.sk)))
>  			retval = ep;
> -			goto out;
> -		}
>  	}
> 
> -	retval = NULL;
> -
> -out:
> -	sctp_read_unlock(&ep->base.addr_lock);
>  	return retval;
>  }
> 
> @@ -261,9 +253,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
>  	list_for_each(pos, &ep->asocs) {
>  		asoc = list_entry(pos, struct sctp_association, asocs);
>  		if (rport == asoc->peer.port) {
> -			sctp_read_lock(&asoc->base.addr_lock);
>  			*transport = sctp_assoc_lookup_paddr(asoc, paddr);
> -			sctp_read_unlock(&asoc->base.addr_lock);
> 
>  			if (*transport)
>  				return asoc;
> @@ -295,20 +285,17 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
>  int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
>  				const union sctp_addr *paddr)
>  {
> -	struct list_head *pos;
>  	struct sctp_sockaddr_entry *addr;
>  	struct sctp_bind_addr *bp;
> 
> -	sctp_read_lock(&ep->base.addr_lock);
>  	bp = &ep->base.bind_addr;
> -	list_for_each(pos, &bp->address_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> -		if (sctp_has_association(&addr->a, paddr)) {
> -			sctp_read_unlock(&ep->base.addr_lock);
> +	/* This function is called with the socket lock held,
> +	 * so the address_list can not change.
> +	 */
> +	list_for_each_entry(addr, &bp->address_list, list) {
> +		if (sctp_has_association(&addr->a, paddr))
>  			return 1;
> -		}
>  	}
> -	sctp_read_unlock(&ep->base.addr_lock);
> 
>  	return 0;
>  }
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index e12fa0a..670fd27 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -302,9 +302,7 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
>  			      union sctp_addr *saddr)
>  {
>  	struct sctp_bind_addr *bp;
> -	rwlock_t *addr_lock;
>  	struct sctp_sockaddr_entry *laddr;
> -	struct list_head *pos;
>  	sctp_scope_t scope;
>  	union sctp_addr *baddr = NULL;
>  	__u8 matchlen = 0;
> @@ -324,14 +322,14 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
>  	scope = sctp_scope(daddr);
> 
>  	bp = &asoc->base.bind_addr;
> -	addr_lock = &asoc->base.addr_lock;
> 
>  	/* Go through the bind address list and find the best source address
>  	 * that matches the scope of the destination address.
>  	 */
> -	sctp_read_lock(addr_lock);
> -	list_for_each(pos, &bp->address_list) {
> -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> +		if (!laddr->valid)
> +			continue;
>  		if ((laddr->use_as_src) &&
>  		    (laddr->a.sa.sa_family == AF_INET6) &&
>  		    (scope <= sctp_scope(&laddr->a))) {
> @@ -353,7 +351,7 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
>  		       __FUNCTION__, asoc, NIP6(daddr->v6.sin6_addr));
>  	}
> 
> -	sctp_read_unlock(addr_lock);
> +	rcu_read_unlock();
>  }
> 
>  /* Make a copy of all potential local addresses. */
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 7ee120e..3d036cd 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -224,7 +224,7 @@ int sctp_copy_local_addr_list(struct sctp_bind_addr *bp, sctp_scope_t scope,
>  			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
>  			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
>  				error = sctp_add_bind_addr(bp, &addr->a, 1,
> -							   GFP_ATOMIC);
> +						    GFP_ATOMIC);
>  				if (error)
>  					goto end_copy;
>  			}
> @@ -428,9 +428,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  	struct rtable *rt;
>  	struct flowi fl;
>  	struct sctp_bind_addr *bp;
> -	rwlock_t *addr_lock;
>  	struct sctp_sockaddr_entry *laddr;
> -	struct list_head *pos;
>  	struct dst_entry *dst = NULL;
>  	union sctp_addr dst_saddr;
> 
> @@ -459,23 +457,20 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  		goto out;
> 
>  	bp = &asoc->base.bind_addr;
> -	addr_lock = &asoc->base.addr_lock;
> 
>  	if (dst) {
>  		/* Walk through the bind address list and look for a bind
>  		 * address that matches the source address of the returned dst.
>  		 */
> -		sctp_read_lock(addr_lock);
> -		list_for_each(pos, &bp->address_list) {
> -			laddr = list_entry(pos, struct sctp_sockaddr_entry,
> -					   list);
> -			if (!laddr->use_as_src)
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> +			if (!laddr->valid || !laddr->use_as_src)
>  				continue;
>  			sctp_v4_dst_saddr(&dst_saddr, dst, htons(bp->port));
>  			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
>  				goto out_unlock;
>  		}
> -		sctp_read_unlock(addr_lock);
> +		rcu_read_unlock();
> 
>  		/* None of the bound addresses match the source address of the
>  		 * dst. So release it.
> @@ -487,10 +482,10 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  	/* Walk through the bind address list and try to get a dst that
>  	 * matches a bind address as the source address.
>  	 */
> -	sctp_read_lock(addr_lock);
> -	list_for_each(pos, &bp->address_list) {
> -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> -
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> +		if (!laddr->valid)
> +			continue;
>  		if ((laddr->use_as_src) &&
>  		    (AF_INET == laddr->a.sa.sa_family)) {
>  			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
> @@ -502,7 +497,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  	}
> 
>  out_unlock:
> -	sctp_read_unlock(addr_lock);
> +	rcu_read_unlock();
>  out:
>  	if (dst)
>  		SCTP_DEBUG_PRINTK("rt_dst:%u.%u.%u.%u, rt_src:%u.%u.%u.%u\n",
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 79856c9..2e34220 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1531,7 +1531,7 @@ no_hmac:
>  	/* Also, add the destination address. */
>  	if (list_empty(&retval->base.bind_addr.address_list)) {
>  		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest, 1,
> -				   GFP_ATOMIC);
> +				GFP_ATOMIC);
>  	}
> 
>  	retval->next_tsn = retval->c.initial_tsn;
> @@ -2613,22 +2613,16 @@ static int sctp_asconf_param_success(struct sctp_association *asoc,
> 
>  	switch (asconf_param->param_hdr.type) {
>  	case SCTP_PARAM_ADD_IP:
> -		sctp_local_bh_disable();
> -		sctp_write_lock(&asoc->base.addr_lock);
> -		list_for_each(pos, &bp->address_list) {
> -			saddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +		/* This is always done in BH context with a socket lock
> +		 * held, so the list can not change.
> +		 */
> +		list_for_each_entry(saddr, &bp->address_list, list) {
>  			if (sctp_cmp_addr_exact(&saddr->a, &addr))
>  				saddr->use_as_src = 1;
>  		}
> -		sctp_write_unlock(&asoc->base.addr_lock);
> -		sctp_local_bh_enable();
>  		break;
>  	case SCTP_PARAM_DEL_IP:
> -		sctp_local_bh_disable();
> -		sctp_write_lock(&asoc->base.addr_lock);
> -		retval = sctp_del_bind_addr(bp, &addr);
> -		sctp_write_unlock(&asoc->base.addr_lock);
> -		sctp_local_bh_enable();
> +		retval = sctp_del_bind_addr(bp, &addr, call_rcu_bh);
>  		list_for_each(pos, &asoc->peer.transport_addr_list) {
>  			transport = list_entry(pos, struct sctp_transport,
>  						 transports);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index a3acf78..772fbfb 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -367,14 +367,10 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
>  	if (!bp->port)
>  		bp->port = inet_sk(sk)->num;
> 
> -	/* Add the address to the bind address list.  */
> -	sctp_local_bh_disable();
> -	sctp_write_lock(&ep->base.addr_lock);
> -
> -	/* Use GFP_ATOMIC since BHs are disabled.  */
> +	/* Add the address to the bind address list.
> +	 * Use GFP_ATOMIC since BHs will be disabled.
> +	 */
>  	ret = sctp_add_bind_addr(bp, addr, 1, GFP_ATOMIC);
> -	sctp_write_unlock(&ep->base.addr_lock);
> -	sctp_local_bh_enable();
> 
>  	/* Copy back into socket for getsockname() use. */
>  	if (!ret) {
> @@ -544,15 +540,12 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  		if (i < addrcnt)
>  			continue;
> 
> -		/* Use the first address in bind addr list of association as
> -		 * Address Parameter of ASCONF CHUNK.
> +		/* Use the first valid address in bind addr list of
> +		 * association as Address Parameter of ASCONF CHUNK.
>  		 */
> -		sctp_read_lock(&asoc->base.addr_lock);
>  		bp = &asoc->base.bind_addr;
>  		p = bp->address_list.next;
>  		laddr = list_entry(p, struct sctp_sockaddr_entry, list);
> -		sctp_read_unlock(&asoc->base.addr_lock);
> -
>  		chunk = sctp_make_asconf_update_ip(asoc, &laddr->a, addrs,
>  						   addrcnt, SCTP_PARAM_ADD_IP);
>  		if (!chunk) {
> @@ -567,8 +560,6 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  		/* Add the new addresses to the bind address list with
>  		 * use_as_src set to 0.
>  		 */
> -		sctp_local_bh_disable();
> -		sctp_write_lock(&asoc->base.addr_lock);
>  		addr_buf = addrs;
>  		for (i = 0; i < addrcnt; i++) {
>  			addr = (union sctp_addr *)addr_buf;
> @@ -578,8 +569,6 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  						    GFP_ATOMIC);
>  			addr_buf += af->sockaddr_len;
>  		}
> -		sctp_write_unlock(&asoc->base.addr_lock);
> -		sctp_local_bh_enable();
>  	}
> 
>  out:
> @@ -651,13 +640,7 @@ static int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
>  		 * socket routing and failover schemes. Refer to comments in
>  		 * sctp_do_bind(). -daisy
>  		 */
> -		sctp_local_bh_disable();
> -		sctp_write_lock(&ep->base.addr_lock);
> -
> -		retval = sctp_del_bind_addr(bp, sa_addr);
> -
> -		sctp_write_unlock(&ep->base.addr_lock);
> -		sctp_local_bh_enable();
> +		retval = sctp_del_bind_addr(bp, sa_addr, call_rcu);
> 
>  		addr_buf += af->sockaddr_len;
>  err_bindx_rem:
> @@ -748,14 +731,16 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		 * make sure that we do not delete all the addresses in the
>  		 * association.
>  		 */
> -		sctp_read_lock(&asoc->base.addr_lock);
>  		bp = &asoc->base.bind_addr;
>  		laddr = sctp_find_unmatch_addr(bp, (union sctp_addr *)addrs,
>  					       addrcnt, sp);
> -		sctp_read_unlock(&asoc->base.addr_lock);
>  		if (!laddr)
>  			continue;
> 
> +		/* We do not need RCU protection throughout this loop
> +		 * because this is done under a socket lock from the
> +		 * setsockopt call.
> +		 */
>  		chunk = sctp_make_asconf_update_ip(asoc, laddr, addrs, addrcnt,
>  						   SCTP_PARAM_DEL_IP);
>  		if (!chunk) {
> @@ -766,23 +751,16 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		/* Reset use_as_src flag for the addresses in the bind address
>  		 * list that are to be deleted.
>  		 */
> -		sctp_local_bh_disable();
> -		sctp_write_lock(&asoc->base.addr_lock);
>  		addr_buf = addrs;
>  		for (i = 0; i < addrcnt; i++) {
>  			laddr = (union sctp_addr *)addr_buf;
>  			af = sctp_get_af_specific(laddr->v4.sin_family);
> -			list_for_each(pos1, &bp->address_list) {
> -				saddr = list_entry(pos1,
> -						   struct sctp_sockaddr_entry,
> -						   list);
> +			list_for_each_entry(saddr, &bp->address_list, list) {
>  				if (sctp_cmp_addr_exact(&saddr->a, laddr))
>  					saddr->use_as_src = 0;
>  			}
>  			addr_buf += af->sockaddr_len;
>  		}
> -		sctp_write_unlock(&asoc->base.addr_lock);
> -		sctp_local_bh_enable();
> 
>  		/* Update the route and saddr entries for all the transports
>  		 * as some of the addresses in the bind address list are
> @@ -4057,11 +4035,9 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>  					       int __user *optlen)
>  {
>  	sctp_assoc_t id;
> -	struct list_head *pos;
>  	struct sctp_bind_addr *bp;
>  	struct sctp_association *asoc;
>  	struct sctp_sockaddr_entry *addr;
> -	rwlock_t *addr_lock;
>  	int cnt = 0;
> 
>  	if (len < sizeof(sctp_assoc_t))
> @@ -4078,17 +4054,13 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>  	 */
>  	if (0 == id) {
>  		bp = &sctp_sk(sk)->ep->base.bind_addr;
> -		addr_lock = &sctp_sk(sk)->ep->base.addr_lock;
>  	} else {
>  		asoc = sctp_id2assoc(sk, id);
>  		if (!asoc)
>  			return -EINVAL;
>  		bp = &asoc->base.bind_addr;
> -		addr_lock = &asoc->base.addr_lock;
>  	}
> 
> -	sctp_read_lock(addr_lock);
> -
>  	/* If the endpoint is bound to 0.0.0.0 or ::0, count the valid
>  	 * addresses from the global local address list.
>  	 */
> @@ -4115,12 +4087,14 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>  		goto done;
>  	}
> 
> -	list_for_each(pos, &bp->address_list) {
> +	/* Protection on the bound address list is not needed,
> +	 * since in the socket option context we hold the socket lock,
> +	 * so there is no way that the bound address list can change.
> +	 */
> +	list_for_each_entry(addr, &bp->address_list, list) {
>  		cnt ++;
>  	}
> -
>  done:
> -	sctp_read_unlock(addr_lock);
>  	return cnt;
>  }
> 
> @@ -4204,7 +4178,6 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  {
>  	struct sctp_bind_addr *bp;
>  	struct sctp_association *asoc;
> -	struct list_head *pos;
>  	int cnt = 0;
>  	struct sctp_getaddrs_old getaddrs;
>  	struct sctp_sockaddr_entry *addr;
> @@ -4212,7 +4185,6 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	union sctp_addr temp;
>  	struct sctp_sock *sp = sctp_sk(sk);
>  	int addrlen;
> -	rwlock_t *addr_lock;
>  	int err = 0;
>  	void *addrs;
>  	void *buf;
> @@ -4234,13 +4206,11 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	 */
>  	if (0 == getaddrs.assoc_id) {
>  		bp = &sctp_sk(sk)->ep->base.bind_addr;
> -		addr_lock = &sctp_sk(sk)->ep->base.addr_lock;
>  	} else {
>  		asoc = sctp_id2assoc(sk, getaddrs.assoc_id);
>  		if (!asoc)
>  			return -EINVAL;
>  		bp = &asoc->base.bind_addr;
> -		addr_lock = &asoc->base.addr_lock;
>  	}
> 
>  	to = getaddrs.addrs;
> @@ -4254,8 +4224,6 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	if (!addrs)
>  		return -ENOMEM;
> 
> -	sctp_read_lock(addr_lock);
> -
>  	/* If the endpoint is bound to 0.0.0.0 or ::0, get the valid
>  	 * addresses from the global local address list.
>  	 */
> @@ -4271,8 +4239,11 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	}
> 
>  	buf = addrs;
> -	list_for_each(pos, &bp->address_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	/* Protection on the bound address list is not needed since
> +	 * in the socket option context we hold a socket lock and
> +	 * thus the bound address list can't change.
> +	 */
> +	list_for_each_entry(addr, &bp->address_list, list) {
>  		memcpy(&temp, &addr->a, sizeof(temp));
>  		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
>  		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
> @@ -4284,8 +4255,6 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	}
> 
>  copy_getaddrs:
> -	sctp_read_unlock(addr_lock);
> -
>  	/* copy the entire address list into the user provided space */
>  	if (copy_to_user(to, addrs, bytes_copied)) {
>  		err = -EFAULT;
> @@ -4307,7 +4276,6 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  {
>  	struct sctp_bind_addr *bp;
>  	struct sctp_association *asoc;
> -	struct list_head *pos;
>  	int cnt = 0;
>  	struct sctp_getaddrs getaddrs;
>  	struct sctp_sockaddr_entry *addr;
> @@ -4315,7 +4283,6 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  	union sctp_addr temp;
>  	struct sctp_sock *sp = sctp_sk(sk);
>  	int addrlen;
> -	rwlock_t *addr_lock;
>  	int err = 0;
>  	size_t space_left;
>  	int bytes_copied = 0;
> @@ -4336,13 +4303,11 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  	 */
>  	if (0 == getaddrs.assoc_id) {
>  		bp = &sctp_sk(sk)->ep->base.bind_addr;
> -		addr_lock = &sctp_sk(sk)->ep->base.addr_lock;
>  	} else {
>  		asoc = sctp_id2assoc(sk, getaddrs.assoc_id);
>  		if (!asoc)
>  			return -EINVAL;
>  		bp = &asoc->base.bind_addr;
> -		addr_lock = &asoc->base.addr_lock;
>  	}
> 
>  	to = optval + offsetof(struct sctp_getaddrs,addrs);
> @@ -4352,8 +4317,6 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  	if (!addrs)
>  		return -ENOMEM;
> 
> -	sctp_read_lock(addr_lock);
> -
>  	/* If the endpoint is bound to 0.0.0.0 or ::0, get the valid
>  	 * addresses from the global local address list.
>  	 */
> @@ -4365,21 +4328,24 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  						space_left, &bytes_copied);
>  			if (cnt < 0) {
>  				err = cnt;
> -				goto error_lock;
> +				goto out;
>  			}
>  			goto copy_getaddrs;
>  		}
>  	}
> 
>  	buf = addrs;
> -	list_for_each(pos, &bp->address_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	/* Protection on the bound address list is not needed since
> +	 * in the socket option context we hold a socket lock and
> +	 * thus the bound address list can't change.
> +	 */
> +	list_for_each_entry(addr, &bp->address_list, list) {
>  		memcpy(&temp, &addr->a, sizeof(temp));
>  		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
>  		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
>  		if (space_left < addrlen) {
>  			err =  -ENOMEM; /*fixme: right error?*/
> -			goto error_lock;
> +			goto out;
>  		}
>  		memcpy(buf, &temp, addrlen);
>  		buf += addrlen;
> @@ -4389,8 +4355,6 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
>  	}
> 
>  copy_getaddrs:
> -	sctp_read_unlock(addr_lock);
> -
>  	if (copy_to_user(to, addrs, bytes_copied)) {
>  		err = -EFAULT;
>  		goto out;
> @@ -4401,12 +4365,6 @@ copy_getaddrs:
>  	}
>  	if (put_user(bytes_copied, optlen))
>  		err = -EFAULT;
> -
> -	goto out;
> -
> -error_lock:
> -	sctp_read_unlock(addr_lock);
> -
>  out:
>  	kfree(addrs);
>  	return err;

