From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC v3 PATCH 2/21] SCTP: Convert bind_addr_list locking to RCU
Date: Thu, 13 Sep 2007 10:59:06 -0700
Message-ID: <1189706346.2748.20.camel@w-sridhar2.beaverton.ibm.com>
References: <46E85344.1030402@hp.com>
	 <11896310224146-git-send-email-vladislav.yasevich@hp.com>
	 <20070912223352.GJ9830@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48551 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458AbXIMSDk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 14:03:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DI3doJ029080
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 14:03:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DI3cvX560402
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 14:03:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DI3cjo009553
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 14:03:38 -0400
In-Reply-To: <20070912223352.GJ9830@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 15:33 -0700, Paul E. McKenney wrote:
> On Wed, Sep 12, 2007 at 05:03:42PM -0400, Vlad Yasevich wrote:
> > [... and here is the updated version as promissed ...]
> > 
> > Since the sctp_sockaddr_entry is now RCU enabled as part of
> > the patch to synchronize sctp_localaddr_list, it makes sense to
> > change all handling of these entries to RCU.  This includes the
> > sctp_bind_addrs structure and it's list of bound addresses.
> > 
> > This list is currently protected by an external rw_lock and that
> > looks like an overkill.  There are only 2 writers to the list:
> > bind()/bindx() calls, and BH processing of ASCONF-ACK chunks.
> > These are already seriealized via the socket lock, so they will
> > not step on each other.  These are also relatively rare, so we
> > should be good with RCU.
> > 
> > The readers are varied and they are easily converted to RCU.
> 
> Looks good from an RCU viewpoint -- I must defer to others on
> the networking aspects.
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

looks good to me too. some minor typos and some comments on
RCU usage comments inline.

Also, I guess we can remove the sctp_[read/write]_[un]lock macros
from sctp.h now that you removed the all the users of rwlocks
in SCTP

Thanks
Sridhar
> 
> > Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> > ---
> >  include/net/sctp/structs.h |    7 +--
> >  net/sctp/associola.c       |   14 +-----
> >  net/sctp/bind_addr.c       |   68 ++++++++++++++++++++----------
> >  net/sctp/endpointola.c     |   27 +++---------
> >  net/sctp/ipv6.c            |   12 ++---
> >  net/sctp/protocol.c        |   25 ++++-------
> >  net/sctp/sm_make_chunk.c   |   18 +++-----
> >  net/sctp/socket.c          |   98 ++++++++++++-------------------------------
> >  8 files changed, 106 insertions(+), 163 deletions(-)
> > 
> > diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> > index a89e361..c2fe2dc 100644
> > --- a/include/net/sctp/structs.h
> > +++ b/include/net/sctp/structs.h
> > @@ -1155,7 +1155,9 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
> >  			int flags);
> >  int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
> >  		       __u8 use_as_src, gfp_t gfp);
> > -int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
> > +int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
> > +			void (*rcu_call)(struct rcu_head *,
> > +					  void (*func)(struct rcu_head *)));
> >  int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
> >  			 struct sctp_sock *);
> >  union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
> > @@ -1226,9 +1228,6 @@ struct sctp_ep_common {
> >  	 * bind_addr.address_list is our set of local IP addresses.
> >  	 */
> >  	struct sctp_bind_addr bind_addr;
> > -
> > -	/* Protection during address list comparisons. */
> > -	rwlock_t   addr_lock;
> >  };
> > 
> > 
> > diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> > index 2ad1caf..9bad8ba 100644
> > --- a/net/sctp/associola.c
> > +++ b/net/sctp/associola.c
> > @@ -99,7 +99,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
> > 
> >  	/* Initialize the bind addr area.  */
> >  	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
> > -	rwlock_init(&asoc->base.addr_lock);
> > 
> >  	asoc->state = SCTP_STATE_CLOSED;
> > 
> > @@ -937,8 +936,6 @@ struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
> >  {
> >  	struct sctp_transport *transport;
> > 
> > -	sctp_read_lock(&asoc->base.addr_lock);
> > -
> >  	if ((htons(asoc->base.bind_addr.port) == laddr->v4.sin_port) &&
> >  	    (htons(asoc->peer.port) == paddr->v4.sin_port)) {
> >  		transport = sctp_assoc_lookup_paddr(asoc, paddr);
> > @@ -952,7 +949,6 @@ struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
> >  	transport = NULL;
> > 
> >  out:
> > -	sctp_read_unlock(&asoc->base.addr_lock);
> >  	return transport;
> >  }
> > 
> > @@ -1376,19 +1372,13 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *asoc,
> >  int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> >  			    const union sctp_addr *laddr)
> >  {
> > -	int found;
> > +	int found = 0;
> > 
> > -	sctp_read_lock(&asoc->base.addr_lock);
> >  	if ((asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
> >  	    sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
> > -				 sctp_sk(asoc->base.sk))) {
> > +				 sctp_sk(asoc->base.sk)))
> >  		found = 1;
> > -		goto out;
> > -	}
> > 
> > -	found = 0;
> > -out:
> > -	sctp_read_unlock(&asoc->base.addr_lock);
> >  	return found;
> >  }
> > 
> > diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> > index 7fc369f..d16055f 100644
> > --- a/net/sctp/bind_addr.c
> > +++ b/net/sctp/bind_addr.c
> > @@ -167,7 +167,11 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
> > 
> >  	INIT_LIST_HEAD(&addr->list);
> >  	INIT_RCU_HEAD(&addr->rcu);
> > -	list_add_tail(&addr->list, &bp->address_list);
> > +
> > +	/* We always hold a socket lock when calling this function,
> > +	 * so rcu_read_lock is not needed.
> > +	 */
> > +	list_add_tail_rcu(&addr->list, &bp->address_list);

I am little confused with the comment above.
Isn't this an update-side of RCU. If so, this should be protected
by a spin-lock or a mutex rather than rcu_read_lock().

> >  	SCTP_DBG_OBJCNT_INC(addr);
> > 
> >  	return 0;
> > @@ -176,23 +180,35 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
> >  /* Delete an address from the bind address list in the SCTP_bind_addr
> >   * structure.
> >   */
> > -int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
> > +int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr,
> > +			void (*rcu_call)(struct rcu_head *head,
> > +					 void (*func)(struct rcu_head *head)))
> >  {
> > -	struct list_head *pos, *temp;
> > -	struct sctp_sockaddr_entry *addr;
> > +	struct sctp_sockaddr_entry *addr, *temp;
> > 
> > -	list_for_each_safe(pos, temp, &bp->address_list) {
> > -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> > +	/* We hold the socket lock when calling this function, so
> > +	 * rcu_read_lock is not needed.
> > +	 */

Same as above. This is also an update-side of RCU protected 
by socket lock.

> > +	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
> >  		if (sctp_cmp_addr_exact(&addr->a, del_addr)) {
> >  			/* Found the exact match. */
> > -			list_del(pos);
> > -			kfree(addr);
> > -			SCTP_DBG_OBJCNT_DEC(addr);
> > -
> > -			return 0;
> > +			addr->valid = 0;
> > +			list_del_rcu(&addr->list);
> > +			break;
> >  		}
> >  	}
> > 
> > +	/* Call the rcu callback provided in the args.  This function is
> > +	 * called by both BH packet processing and user side socket option
> > +	 * processing, but it works on different lists in those 2 contexts.
> > +	 * Each context provides it's own callback, whether call_rc_bh()
s/call_rc_bh/call_rcu_bh

> > +	 * or call_rcu(), to make sure that we wait an for appropriate time.
s/an for/for an

> > +	 */
> > +	if (addr && !addr->valid) {
> > +		rcu_call(&addr->rcu, sctp_local_addr_free);
> > +		SCTP_DBG_OBJCNT_DEC(addr);
> > +	}
> > +
> >  	return -EINVAL;
> >  }
> > 
> > @@ -302,15 +318,20 @@ int sctp_bind_addr_match(struct sctp_bind_addr *bp,
> >  			 struct sctp_sock *opt)
> >  {
> >  	struct sctp_sockaddr_entry *laddr;
> > -	struct list_head *pos;
> > -
> > -	list_for_each(pos, &bp->address_list) {
> > -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> > -		if (opt->pf->cmp_addr(&laddr->a, addr, opt))
> > -			return 1;
> > +	int match = 0;
> > +
> > +	rcu_read_lock();
> > +	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> > +		if (!laddr->valid)
> > +			continue;
> > +		if (opt->pf->cmp_addr(&laddr->a, addr, opt)) {
> > +			match = 1;
> > +			break;
> > +		}
> >  	}
> > +	rcu_read_unlock();
> > 
> > -	return 0;
> > +	return match;
> >  }
> > 
> >  /* Find the first address in the bind address list that is not present in
> > @@ -325,18 +346,19 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
> >  	union sctp_addr			*addr;
> >  	void 				*addr_buf;
> >  	struct sctp_af			*af;
> > -	struct list_head		*pos;
> >  	int				i;
> > 
> > -	list_for_each(pos, &bp->address_list) {
> > -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> > -
> > +	/* This is only called sctp_send_asconf_del_ip() and we hold
> > +	 * the socket lock in that code patch, so that address list
> > +	 * can't change.
> > +	 */
> > +	list_for_each_entry(laddr, &bp->address_list, list) {
> >  		addr_buf = (union sctp_addr *)addrs;
> >  		for (i = 0; i < addrcnt; i++) {
> >  			addr = (union sctp_addr *)addr_buf;
> >  			af = sctp_get_af_specific(addr->v4.sin_family);
> >  			if (!af)
> > -				return NULL;
> > +				break;
> > 
> >  			if (opt->pf->cmp_addr(&laddr->a, addr, opt))
> >  				break;
> > diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> > index 1404a9e..110d912 100644
> > --- a/net/sctp/endpointola.c
> > +++ b/net/sctp/endpointola.c
> > @@ -92,7 +92,6 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
> > 
> >  	/* Initialize the bind addr area */
> >  	sctp_bind_addr_init(&ep->base.bind_addr, 0);
> > -	rwlock_init(&ep->base.addr_lock);
> > 
> >  	/* Remember who we are attached to.  */
> >  	ep->base.sk = sk;
> > @@ -225,21 +224,14 @@ void sctp_endpoint_put(struct sctp_endpoint *ep)
> >  struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
> >  					       const union sctp_addr *laddr)
> >  {
> > -	struct sctp_endpoint *retval;
> > +	struct sctp_endpoint *retval = NULL;
> > 
> > -	sctp_read_lock(&ep->base.addr_lock);
> >  	if (htons(ep->base.bind_addr.port) == laddr->v4.sin_port) {
> >  		if (sctp_bind_addr_match(&ep->base.bind_addr, laddr,
> > -					 sctp_sk(ep->base.sk))) {
> > +					 sctp_sk(ep->base.sk)))
> >  			retval = ep;
> > -			goto out;
> > -		}
> >  	}
> > 
> > -	retval = NULL;
> > -
> > -out:
> > -	sctp_read_unlock(&ep->base.addr_lock);
> >  	return retval;
> >  }
> > 
> > @@ -261,9 +253,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
> >  	list_for_each(pos, &ep->asocs) {
> >  		asoc = list_entry(pos, struct sctp_association, asocs);
> >  		if (rport == asoc->peer.port) {
> > -			sctp_read_lock(&asoc->base.addr_lock);
> >  			*transport = sctp_assoc_lookup_paddr(asoc, paddr);
> > -			sctp_read_unlock(&asoc->base.addr_lock);
> > 
> >  			if (*transport)
> >  				return asoc;
> > @@ -295,20 +285,17 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
> >  int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
> >  				const union sctp_addr *paddr)
> >  {
> > -	struct list_head *pos;
> >  	struct sctp_sockaddr_entry *addr;
> >  	struct sctp_bind_addr *bp;
> > 
> > -	sctp_read_lock(&ep->base.addr_lock);
> >  	bp = &ep->base.bind_addr;
> > -	list_for_each(pos, &bp->address_list) {
> > -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> > -		if (sctp_has_association(&addr->a, paddr)) {
> > -			sctp_read_unlock(&ep->base.addr_lock);
> > +	/* This function is called whith the socket lock held,
s/whith/with

> > +	 * so the address_list can not change.
> > +	 */
> > +	list_for_each_entry(addr, &bp->address_list, list) {
> > +		if (sctp_has_association(&addr->a, paddr))
> >  			return 1;
> > -		}
> >  	}
> > -	sctp_read_unlock(&ep->base.addr_lock);
> > 
> >  	return 0;
> >  }

<snip>
deleted the rest of the patch as it looks good and i have no
comments.

