From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 19/19] rxrpc: Use RCU to access a peer's service
 connection tree
Date: Thu, 30 Jun 2016 17:30:49 +0200
Message-ID: <20160630153049.GG30935@twins.programming.kicks-ass.net>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
 <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 30, 2016 at 03:12:58PM +0100, David Howells wrote:
> +struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *peer,
> +						     struct sk_buff *skb)
> +{
> +	struct rxrpc_connection *conn = NULL;
> +	struct rxrpc_conn_proto k;
> +	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
> +	struct rb_node *p;
> +	unsigned int seq;
> +
> +	k.epoch	= sp->hdr.epoch;
> +	k.cid	= sp->hdr.cid & RXRPC_CIDMASK;
> +
> +	do {
> +		/* Unfortunately, rbtree walking doesn't give reliable results
> +		 * under just the RCU read lock, so we have to check for
> +		 * changes.
> +		 */
> +		read_seqbegin_or_lock(&peer->service_conn_lock, &seq);
> +
> +		p = peer->service_conns.rb_node;
> +		while (p) {
> +			conn = rb_entry(p, struct rxrpc_connection, service_node);
> +
> +			if (conn->proto.index_key < k.index_key)
> +				p = p->rb_left;
> +			else if (conn->proto.index_key > k.index_key)
> +				p = p->rb_right;

You still very much need rcu_dereference() for both left and right
pointers. As well as the first p load.

> +			else
> +				goto done;
> +			conn = NULL;
> +		}
> +	} while (need_seqretry(&peer->service_conn_lock, seq));
> +
> +done:
> +	done_seqretry(&peer->service_conn_lock, seq);
> +	_leave(" = %d", conn ? conn->debug_id : -1);
> +	return conn;
> +}


> +static struct rxrpc_connection *
> +rxrpc_publish_service_conn(struct rxrpc_peer *peer,
> +			   struct rxrpc_connection *conn)
> +{
> +	struct rxrpc_connection *cursor = NULL;
> +	struct rxrpc_conn_proto k = conn->proto;
> +	struct rb_node **pp, *parent;
> +
> +	write_seqlock_bh(&peer->service_conn_lock);
> +
> +	pp = &peer->service_conns.rb_node;
> +	parent = NULL;
> +	while (*pp) {
> +		parent = *pp;
> +		cursor = rb_entry(parent,
> +				  struct rxrpc_connection, service_node);
> +
> +		if (cursor->proto.index_key < k.index_key)
> +			pp = &(*pp)->rb_left;
> +		else if (cursor->proto.index_key > k.index_key)
> +			pp = &(*pp)->rb_right;
> +		else
> +			goto found_extant_conn;
> +	}
> +
> +	rb_link_node(&conn->service_node, parent, pp);

You want rb_link_node_rcu() here.

> +	rb_insert_color(&conn->service_node, &peer->service_conns);
> +conn_published:
> +	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
> +	write_sequnlock_bh(&peer->service_conn_lock);
> +	_leave(" = %d [new]", conn->debug_id);
> +	return conn;
