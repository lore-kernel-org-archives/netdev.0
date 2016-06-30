From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 19/19] rxrpc: Use RCU to access a peer's service
 connection tree
Date: Thu, 30 Jun 2016 22:19:46 +0200
Message-ID: <20160630201946.GF30921@twins.programming.kicks-ass.net>
References: <19436.1467303739@warthog.procyon.org.uk>
 <20160630153049.GG30935@twins.programming.kicks-ass.net>
 <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
 <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
 <587.1467304611@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <587.1467304611@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 30, 2016 at 05:36:51PM +0100, David Howells wrote:
> David Howells <dhowells@redhat.com> wrote:
> 
> > > You want rb_link_node_rcu() here.
> > 
> > Should there be an rb_replace_node_rcu() also?
> 
> Or I could make rb_replace_node() RCU friendly.  What do you think of the
> attached changes (split into appropriate patches)?  It's a case of changing
> the order in which pointers are set in the rbtree code and inserting a
> barrier.

> diff --git a/lib/rbtree.c b/lib/rbtree.c
> index 1356454e36de..2b1a190c737c 100644
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -539,15 +539,17 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
>  {
>  	struct rb_node *parent = rb_parent(victim);
>  
> +	/* Copy the pointers/colour from the victim to the replacement */
> +	*new = *victim;
> +
>  	/* Set the surrounding nodes to point to the replacement */
> -	__rb_change_child(victim, new, parent, root);
>  	if (victim->rb_left)
>  		rb_set_parent(victim->rb_left, new);
>  	if (victim->rb_right)
>  		rb_set_parent(victim->rb_right, new);
>  
> -	/* Copy the pointers/colour from the victim to the replacement */
> -	*new = *victim;
> +	/* Set the onward pointer last with an RCU barrier */
> +	__rb_change_child_rcu(victim, new, parent, root);
>  }
>  EXPORT_SYMBOL(rb_replace_node);

So back when I did this work there was resistance to making the regular
RB-tree primitives more expensive for the rare RCU user. And I suspect
that this is still so.

Now, rb_replace_node() isn't a widely used primitive, so it might go
unnoticed, but since we already have rb_link_node_rcu() adding
rb_replace_node_rcu() is the consistent thing to do.


> diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
> index dc64211c5ee8..298ec300cfcc 100644
> --- a/net/rxrpc/conn_service.c
> +++ b/net/rxrpc/conn_service.c
> @@ -41,14 +41,14 @@ struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *peer,
>  		 */
>  		read_seqbegin_or_lock(&peer->service_conn_lock, &seq);
>  
> -		p = peer->service_conns.rb_node;
> +		p = rcu_dereference(peer->service_conns.rb_node);
>  		while (p) {
>  			conn = rb_entry(p, struct rxrpc_connection, service_node);
>  
>  			if (conn->proto.index_key < k.index_key)
> -				p = p->rb_left;
> +				p = rcu_dereference(p->rb_left);
>  			else if (conn->proto.index_key > k.index_key)
> -				p = p->rb_right;
> +				p = rcu_dereference(p->rb_right);
>  			else
>  				goto done;
>  			conn = NULL;
> @@ -90,7 +90,7 @@ rxrpc_publish_service_conn(struct rxrpc_peer *peer,
>  			goto found_extant_conn;
>  	}
>  
> -	rb_link_node(&conn->service_node, parent, pp);
> +	rb_link_node_rcu(&conn->service_node, parent, pp);
>  	rb_insert_color(&conn->service_node, &peer->service_conns);
>  conn_published:
>  	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);

Yep, that's about right.
