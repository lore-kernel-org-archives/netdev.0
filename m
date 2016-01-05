From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 2/5] sctp: apply rhashtable api to send/recv path
Date: Tue, 5 Jan 2016 14:07:11 -0500
Message-ID: <568C145F.5040009@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
 <2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
 <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34436 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbcAETHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 14:07:14 -0500
In-Reply-To: <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2015 10:50 AM, Xin Long wrote:
> apply lookup apis to two functions, for __sctp_endpoint_lookup_assoc
> and __sctp_lookup_association, it's invoked in the protection of sock
> lock, it will be safe, but sctp_lookup_association need to call
> rcu_read_lock() and to detect the t->dead to protect it.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/associola.c   |  5 +++++
>  net/sctp/endpointola.c | 35 ++++++++---------------------------
>  net/sctp/input.c       | 39 ++++++++++-----------------------------
>  net/sctp/protocol.c    |  6 ++++++
>  4 files changed, 29 insertions(+), 56 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 559afd0..2bf8ec9 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -383,6 +383,7 @@ void sctp_association_free(struct sctp_association *asoc)
>  	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
>  		transport = list_entry(pos, struct sctp_transport, transports);
>  		list_del_rcu(pos);
> +		sctp_unhash_transport(transport);
>  		sctp_transport_free(transport);
>  	}
>  
> @@ -500,6 +501,8 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
>  
>  	/* Remove this peer from the list. */
>  	list_del_rcu(&peer->transports);
> +	/* Remove this peer from the transport hashtable */
> +	sctp_unhash_transport(peer);
>  
>  	/* Get the first transport of asoc. */
>  	pos = asoc->peer.transport_addr_list.next;
> @@ -699,6 +702,8 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
>  	/* Attach the remote transport to our asoc.  */
>  	list_add_tail_rcu(&peer->transports, &asoc->peer.transport_addr_list);
>  	asoc->peer.transport_count++;
> +	/* Add this peer into the transport hashtable */
> +	sctp_hash_transport(peer);

This is actually problematic.  The issue is that transports are unhashed when removed.
however, transport removal happens after the association has been declared dead and
should have been removed from the hash and marked unreachable.

As a result, with the code above, you can now find and return a dead association.
Checking for 'dead' state is racy.

The best solution I've come up with is to hash the transports in sctp_hash_established()
and clean-up in __sctp_unhash_established(), and then handle ADD-IP case separately.

The above would also remove the necessity to check for temporary associations, since they
should never be hashed.

-vlad

>  
>  	/* If we do not yet have a primary path, set one.  */
>  	if (!asoc->peer.primary_path) {
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 9da76ba..8838bf4 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -314,8 +314,8 @@ struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
>  }
>  
>  /* Find the association that goes with this chunk.
> - * We do a linear search of the associations for this endpoint.
> - * We return the matching transport address too.
> + * We lookup the transport from hashtable at first, then get association
> + * through t->assoc.
>   */
>  static struct sctp_association *__sctp_endpoint_lookup_assoc(
>  	const struct sctp_endpoint *ep,
> @@ -323,12 +323,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
>  	struct sctp_transport **transport)
>  {
>  	struct sctp_association *asoc = NULL;
> -	struct sctp_association *tmp;
> -	struct sctp_transport *t = NULL;
> -	struct sctp_hashbucket *head;
> -	struct sctp_ep_common *epb;
> -	int hash;
> -	int rport;
> +	struct sctp_transport *t;
>  
>  	*transport = NULL;
>  
> @@ -337,26 +332,12 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
>  	 */
>  	if (!ep->base.bind_addr.port)
>  		goto out;
> +	t = sctp_epaddr_lookup_transport(ep, paddr);
> +	if (!t || t->asoc->temp)
> +		goto out;
>  
> -	rport = ntohs(paddr->v4.sin_port);
> -
> -	hash = sctp_assoc_hashfn(sock_net(ep->base.sk), ep->base.bind_addr.port,
> -				 rport);
> -	head = &sctp_assoc_hashtable[hash];
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, &head->chain) {
> -		tmp = sctp_assoc(epb);
> -		if (tmp->ep != ep || rport != tmp->peer.port)
> -			continue;
> -
> -		t = sctp_assoc_lookup_paddr(tmp, paddr);
> -		if (t) {
> -			asoc = tmp;
> -			*transport = t;
> -			break;
> -		}
> -	}
> -	read_unlock(&head->lock);
> +	*transport = t;
> +	asoc = t->asoc;
>  out:
>  	return asoc;
>  }
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index bac8278..6f075d8 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -981,38 +981,19 @@ static struct sctp_association *__sctp_lookup_association(
>  					const union sctp_addr *peer,
>  					struct sctp_transport **pt)
>  {
> -	struct sctp_hashbucket *head;
> -	struct sctp_ep_common *epb;
> -	struct sctp_association *asoc;
> -	struct sctp_transport *transport;
> -	int hash;
> +	struct sctp_transport *t;
>  
> -	/* Optimize here for direct hit, only listening connections can
> -	 * have wildcards anyways.
> -	 */
> -	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
> -				 ntohs(peer->v4.sin_port));
> -	head = &sctp_assoc_hashtable[hash];
> -	read_lock(&head->lock);
> -	sctp_for_each_hentry(epb, &head->chain) {
> -		asoc = sctp_assoc(epb);
> -		transport = sctp_assoc_is_match(asoc, net, local, peer);
> -		if (transport)
> -			goto hit;
> -	}
> +	t = sctp_addrs_lookup_transport(net, local, peer);
> +	if (!t || t->dead || t->asoc->temp)
> +		return NULL;
>  
> -	read_unlock(&head->lock);
> +	sctp_association_hold(t->asoc);
> +	*pt = t;
>  
> -	return NULL;
> -
> -hit:
> -	*pt = transport;
> -	sctp_association_hold(asoc);
> -	read_unlock(&head->lock);
> -	return asoc;
> +	return t->asoc;
>  }
>  
> -/* Look up an association. BH-safe. */
> +/* Look up an association. protected by RCU read lock */
>  static
>  struct sctp_association *sctp_lookup_association(struct net *net,
>  						 const union sctp_addr *laddr,
> @@ -1021,9 +1002,9 @@ struct sctp_association *sctp_lookup_association(struct net *net,
>  {
>  	struct sctp_association *asoc;
>  
> -	local_bh_disable();
> +	rcu_read_lock();
>  	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
> -	local_bh_enable();
> +	rcu_read_unlock();
>  
>  	return asoc;
>  }
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 010aced..631cfb3 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1467,6 +1467,9 @@ static __init int sctp_init(void)
>  		INIT_HLIST_HEAD(&sctp_port_hashtable[i].chain);
>  	}
>  
> +	if (sctp_transport_hashtable_init())
> +		goto err_thash_alloc;
> +
>  	pr_info("Hash tables configured (established %d bind %d)\n",
>  		sctp_assoc_hashsize, sctp_port_hashsize);
>  
> @@ -1521,6 +1524,8 @@ err_register_defaults:
>  		   get_order(sctp_port_hashsize *
>  			     sizeof(struct sctp_bind_hashbucket)));
>  err_bhash_alloc:
> +	sctp_transport_hashtable_destroy();
> +err_thash_alloc:
>  	kfree(sctp_ep_hashtable);
>  err_ehash_alloc:
>  	free_pages((unsigned long)sctp_assoc_hashtable,
> @@ -1567,6 +1572,7 @@ static __exit void sctp_exit(void)
>  	free_pages((unsigned long)sctp_port_hashtable,
>  		   get_order(sctp_port_hashsize *
>  			     sizeof(struct sctp_bind_hashbucket)));
> +	sctp_transport_hashtable_destroy();
>  
>  	percpu_counter_destroy(&sctp_sockets_allocated);
>  
> 
