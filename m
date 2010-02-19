From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC 1/2] sctp: convert hash list to RCU
Date: Fri, 19 Feb 2010 07:58:25 -0800
Message-ID: <20100219155825.GA6778@linux.vnet.ibm.com>
References: <20100219055520.223027612@vyatta.com> <20100219055628.436258223@vyatta.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:56253 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375Ab0BSP61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 10:58:27 -0500
Content-Disposition: inline
In-Reply-To: <20100219055628.436258223@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2010 at 09:55:21PM -0800, Stephen Hemminger wrote:
> This patch converts existing SCTP hash list to using RCU
> rather than reader/writer lock. Also, get rid of no longer used
> locking wrappers.
> 
> In future, the SCTP hash locking should be broken out from the
> hash structure because of the wasted space for the hash locks
> and associated holes. A single lock per hashlist is sufficient
> now that RCU is used.
> 
> Compile tested only. I can't think of an SCTP stress application.
> 
> P.s: Some janitor ought to go through and remove the locking
> macros here.

One question below about what looks to be mixing of RCU and RCU-bh
read-side critical sections while waiting only for RCU grace periods.
Unless I am missing something, this can result in memory corruption.

						Thanx, Paul

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/include/net/sctp/sctp.h	2010-02-18 09:44:42.664390403 -0800
> +++ b/include/net/sctp/sctp.h	2010-02-18 09:52:48.004478538 -0800
> @@ -206,10 +206,6 @@ extern struct kmem_cache *sctp_bucket_ca
>  #define sctp_local_bh_enable()  local_bh_enable()
>  #define sctp_spin_lock(lock)    spin_lock(lock)
>  #define sctp_spin_unlock(lock)  spin_unlock(lock)
> -#define sctp_write_lock(lock)   write_lock(lock)
> -#define sctp_write_unlock(lock) write_unlock(lock)
> -#define sctp_read_lock(lock)    read_lock(lock)
> -#define sctp_read_unlock(lock)  read_unlock(lock)
> 
>  /* sock lock wrappers. */
>  #define sctp_lock_sock(sk)       lock_sock(sk)
> @@ -649,6 +645,9 @@ static inline int sctp_vtag_hashfn(__u16
>  #define sctp_for_each_hentry(epb, node, head) \
>  	hlist_for_each_entry(epb, node, head, node)
> 
> +#define sctp_for_each_hentry_rcu(epb, node, head) \
> +	hlist_for_each_entry_rcu(epb, node, head, node)
> +
>  /* Is a socket of this style? */
>  #define sctp_style(sk, style) __sctp_style((sk), (SCTP_SOCKET_##style))
>  static inline int __sctp_style(const struct sock *sk, sctp_socket_type_t style)
> --- a/include/net/sctp/structs.h	2010-02-18 09:47:29.964390311 -0800
> +++ b/include/net/sctp/structs.h	2010-02-18 09:57:26.792896287 -0800
> @@ -111,7 +111,7 @@ struct sctp_bind_hashbucket {
> 
>  /* Used for hashing all associations.  */
>  struct sctp_hashbucket {
> -	rwlock_t	lock;
> +	spinlock_t	lock;
>  	struct hlist_head	chain;
>  } __attribute__((__aligned__(8)));
> 
> @@ -1371,6 +1371,8 @@ struct sctp_endpoint {
>  	/* SCTP-AUTH: endpoint shared keys */
>  	struct list_head endpoint_shared_keys;
>  	__u16 active_key_id;
> +
> +	struct rcu_head rcu;
>  };
> 
>  /* Recover the outter endpoint structure. */
> --- a/net/sctp/endpointola.c	2010-02-18 09:43:22.868887786 -0800
> +++ b/net/sctp/endpointola.c	2010-02-18 10:00:55.807210206 -0800
> @@ -247,9 +247,9 @@ void sctp_endpoint_free(struct sctp_endp
>  }
> 
>  /* Final destructor for endpoint.  */
> -static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
> +static void sctp_endpoint_destroy_rcu(struct rcu_head *rcu)
>  {
> -	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
> +	struct sctp_endpoint *ep = container_of(rcu, struct sctp_endpoint, rcu);
> 
>  	/* Free up the HMAC transform. */
>  	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
> @@ -286,6 +286,13 @@ static void sctp_endpoint_destroy(struct
>  	}
>  }
> 
> +static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
> +{
> +	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
> +	call_rcu(&ep->rcu, sctp_endpoint_destroy_rcu);
> +}
> +
> +
>  /* Hold a reference to an endpoint. */
>  void sctp_endpoint_hold(struct sctp_endpoint *ep)
>  {
> @@ -338,8 +345,9 @@ static struct sctp_association *__sctp_e
> 
>  	hash = sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
>  	head = &sctp_assoc_hashtable[hash];
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +
> +	rcu_read_lock();
> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		asoc = sctp_assoc(epb);
>  		if (asoc->ep != ep || rport != asoc->peer.port)
>  			goto next;
> @@ -352,7 +360,7 @@ static struct sctp_association *__sctp_e
>  next:
>  		asoc = NULL;
>  	}
> -	read_unlock(&head->lock);
> +	rcu_read_unlock();
>  	return asoc;
>  }
> 
> --- a/net/sctp/input.c	2010-02-18 09:51:39.104889498 -0800
> +++ b/net/sctp/input.c	2010-02-18 10:02:42.972601804 -0800
> @@ -704,9 +704,9 @@ static void __sctp_hash_endpoint(struct 
>  	epb->hashent = sctp_ep_hashfn(epb->bind_addr.port);
>  	head = &sctp_ep_hashtable[epb->hashent];
> 
> -	sctp_write_lock(&head->lock);
> -	hlist_add_head(&epb->node, &head->chain);
> -	sctp_write_unlock(&head->lock);
> +	sctp_spin_lock(&head->lock);
> +	hlist_add_head_rcu(&epb->node, &head->chain);
> +	sctp_spin_unlock(&head->lock);
>  }
> 
>  /* Add an endpoint to the hash. Local BH-safe. */
> @@ -732,9 +732,9 @@ static void __sctp_unhash_endpoint(struc
> 
>  	head = &sctp_ep_hashtable[epb->hashent];
> 
> -	sctp_write_lock(&head->lock);
> -	__hlist_del(&epb->node);
> -	sctp_write_unlock(&head->lock);
> +	sctp_spin_lock(&head->lock);
> +	hlist_del_rcu(&epb->node);
> +	sctp_spin_unlock(&head->lock);
>  }
> 
>  /* Remove endpoint from the hash.  Local BH-safe. */
> @@ -756,8 +756,8 @@ static struct sctp_endpoint *__sctp_rcv_
> 
>  	hash = sctp_ep_hashfn(ntohs(laddr->v4.sin_port));
>  	head = &sctp_ep_hashtable[hash];
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +	rcu_read_lock();
> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		ep = sctp_ep(epb);
>  		if (sctp_endpoint_is_match(ep, laddr))
>  			goto hit;
> @@ -767,7 +767,7 @@ static struct sctp_endpoint *__sctp_rcv_
> 
>  hit:
>  	sctp_endpoint_hold(ep);
> -	read_unlock(&head->lock);
> +	rcu_read_unlock();
>  	return ep;
>  }
> 
> @@ -784,9 +784,9 @@ static void __sctp_hash_established(stru
> 
>  	head = &sctp_assoc_hashtable[epb->hashent];
> 
> -	sctp_write_lock(&head->lock);
> -	hlist_add_head(&epb->node, &head->chain);
> -	sctp_write_unlock(&head->lock);
> +	sctp_spin_lock(&head->lock);
> +	hlist_add_head_rcu(&epb->node, &head->chain);
> +	sctp_spin_unlock(&head->lock);
>  }
> 
>  /* Add an association to the hash. Local BH-safe. */
> @@ -813,9 +813,9 @@ static void __sctp_unhash_established(st
> 
>  	head = &sctp_assoc_hashtable[epb->hashent];
> 
> -	sctp_write_lock(&head->lock);
> -	__hlist_del(&epb->node);
> -	sctp_write_unlock(&head->lock);
> +	sctp_spin_lock(&head->lock);
> +	hlist_del_rcu(&epb->node);
> +	sctp_spin_unlock(&head->lock);
>  }
> 
>  /* Remove association from the hash table.  Local BH-safe. */
> @@ -847,22 +847,23 @@ static struct sctp_association *__sctp_l
>  	 */
>  	hash = sctp_assoc_hashfn(ntohs(local->v4.sin_port), ntohs(peer->v4.sin_port));
>  	head = &sctp_assoc_hashtable[hash];
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +
> +	rcu_read_lock();
> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		asoc = sctp_assoc(epb);
>  		transport = sctp_assoc_is_match(asoc, local, peer);
>  		if (transport)
>  			goto hit;
>  	}
> 
> -	read_unlock(&head->lock);
> +	rcu_read_unlock();
> 
>  	return NULL;
> 
>  hit:
>  	*pt = transport;
>  	sctp_association_hold(asoc);
> -	read_unlock(&head->lock);
> +	rcu_read_unlock();
>  	return asoc;
>  }
> 
> --- a/net/sctp/protocol.c	2010-02-18 09:42:04.556389428 -0800
> +++ b/net/sctp/protocol.c	2010-02-18 09:53:03.360663641 -0800
> @@ -1204,7 +1204,7 @@ SCTP_STATIC __init int sctp_init(void)
>  		goto err_ahash_alloc;
>  	}
>  	for (i = 0; i < sctp_assoc_hashsize; i++) {
> -		rwlock_init(&sctp_assoc_hashtable[i].lock);
> +		spin_lock_init(&sctp_assoc_hashtable[i].lock);
>  		INIT_HLIST_HEAD(&sctp_assoc_hashtable[i].chain);
>  	}
> 
> @@ -1218,7 +1218,7 @@ SCTP_STATIC __init int sctp_init(void)
>  		goto err_ehash_alloc;
>  	}
>  	for (i = 0; i < sctp_ep_hashsize; i++) {
> -		rwlock_init(&sctp_ep_hashtable[i].lock);
> +		spin_lock_init(&sctp_ep_hashtable[i].lock);
>  		INIT_HLIST_HEAD(&sctp_ep_hashtable[i].chain);
>  	}
> 
> --- a/net/sctp/proc.c	2010-02-18 10:03:50.428764115 -0800
> +++ b/net/sctp/proc.c	2010-02-18 10:05:09.961659526 -0800
> @@ -208,9 +208,9 @@ static int sctp_eps_seq_show(struct seq_
>  		return -ENOMEM;
> 
>  	head = &sctp_ep_hashtable[hash];
> -	sctp_local_bh_disable();
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +
> +	rcu_read_lock_bh();

Why _bh() here instead of just rcu_read_lock()?  Either way, we would
need a call_rcu_bh() to wait for this particular RCU read-side critical
section -- call_rcu() won't necessarily do it because and RCU grace
period is not guaranteed to wait for RCU-bh read-side critical sections.

If we do need _bh() here, one approach would be to do call_rcu(), and
make the callback do call_rcu_bh(), and the _bh callback could then do
the free.  This approach would be guaranteed to wait for both RCU and
RCU-bh read-side critical sections.

> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		ep = sctp_ep(epb);
>  		sk = epb->sk;
>  		seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
> @@ -221,8 +221,7 @@ static int sctp_eps_seq_show(struct seq_
>  		sctp_seq_dump_local_addrs(seq, epb);
>  		seq_printf(seq, "\n");
>  	}
> -	read_unlock(&head->lock);
> -	sctp_local_bh_enable();
> +	rcu_read_unlock_bh();
> 
>  	return 0;
>  }
> @@ -312,9 +311,9 @@ static int sctp_assocs_seq_show(struct s
>  		return -ENOMEM;
> 
>  	head = &sctp_assoc_hashtable[hash];
> -	sctp_local_bh_disable();
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +
> +	rcu_read_lock_bh();
> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		assoc = sctp_assoc(epb);
>  		sk = epb->sk;
>  		seq_printf(seq,
> @@ -339,8 +338,7 @@ static int sctp_assocs_seq_show(struct s
>  			assoc->rtx_data_chunks);
>  		seq_printf(seq, "\n");
>  	}
> -	read_unlock(&head->lock);
> -	sctp_local_bh_enable();
> +	rcu_read_unlock_bh();
> 
>  	return 0;
>  }
> @@ -425,9 +423,9 @@ static int sctp_remaddr_seq_show(struct 
>  		return -ENOMEM;
> 
>  	head = &sctp_assoc_hashtable[hash];
> -	sctp_local_bh_disable();
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, node, &head->chain) {
> +
> +	rcu_read_lock_bh();
> +	sctp_for_each_hentry_rcu(epb, node, &head->chain) {
>  		assoc = sctp_assoc(epb);
>  		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
>  					transports) {
> @@ -475,9 +473,7 @@ static int sctp_remaddr_seq_show(struct 
>  			seq_printf(seq, "\n");
>  		}
>  	}
> -
> -	read_unlock(&head->lock);
> -	sctp_local_bh_enable();
> +	rcu_read_unlock_bh();
> 
>  	return 0;
> 
> 
> -- 
> 
