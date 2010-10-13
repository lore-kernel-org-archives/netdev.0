From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 4/5] tipc: Rework data structures that track
 neighboring nodes and links
Date: Wed, 13 Oct 2010 12:24:58 -0400
Message-ID: <20101013162458.GE31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-4-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54857 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab0JMQZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 12:25:18 -0400
Content-Disposition: inline
In-Reply-To: <1286929558-2954-4-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 08:25:57PM -0400, Paul Gortmaker wrote:
> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Convert existing linked list of neighboring nodes to a standard
> doubly-linked list. Add counters that track total number of nodes
> in list and total number of links to these nodes, thereby allowing
> configuration message replies to allocate only space based on
> the actual number of nodes and links rather than the worst case.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/bcast.c |    5 ++-
>  net/tipc/link.c  |    3 +-
>  net/tipc/node.c  |   60 ++++++++++++++++++++++++++---------------------------
>  net/tipc/node.h  |    5 +--
>  4 files changed, 36 insertions(+), 37 deletions(-)
> 
NAK, this is completely broken.  You're casting tipc_node structure as
struct list_heads.  That basically makes the first 64 (or 128 bits on 64 bit
arches) act like a list_heads prev and next pointers.  So if you use node like a
list head, you're corrupting those first 64 or 128 bits.  If you modify
node->addr, node->lock, etc, you're corrupting your list pointers.  What you
want is an empty list head pointer defined somewhere to serve as the head of
your list, and to use the node_list member that you added to tipc_node to serve
as your list member in the use of list_add, list_del and list_for_each_entry
calls.

Neil


> diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
> index ba6dcb2..e006678 100644
> --- a/net/tipc/bcast.c
> +++ b/net/tipc/bcast.c
> @@ -454,10 +454,11 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
>  			tipc_node_unlock(node);
>  			spin_lock_bh(&bc_lock);
>  			bcl->stats.recv_nacks++;
> -			bcl->owner->next = node;   /* remember requestor */
> +			/* remember retransmit requester */
> +			bcl->owner->node_list.next =
> +				(struct list_head *)node;
>  			bclink_retransmit_pkt(msg_bcgap_after(msg),
>  					      msg_bcgap_to(msg));
> -			bcl->owner->next = NULL;
>  			spin_unlock_bh(&bc_lock);
>  		} else {
>  			tipc_bclink_peek_nack(msg_destnode(msg),
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 54bd99d..13bc0b6 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -1652,7 +1652,8 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
>  		tipc_printf(TIPC_OUTPUT, "Outstanding acks: %lu\n",
>  				     (unsigned long) TIPC_SKB_CB(buf)->handle);
>  
> -		n_ptr = l_ptr->owner->next;
> +		/* recover retransmit requester */
> +		n_ptr = (struct tipc_node *)l_ptr->owner->node_list.next;
>  		tipc_node_lock(n_ptr);
>  
>  		tipc_addr_string_fill(addr_string, n_ptr->addr);
> diff --git a/net/tipc/node.c b/net/tipc/node.c
> index 7c49cd0..944b480 100644
> --- a/net/tipc/node.c
> +++ b/net/tipc/node.c
> @@ -50,7 +50,9 @@ void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str);
>  static void node_lost_contact(struct tipc_node *n_ptr);
>  static void node_established_contact(struct tipc_node *n_ptr);
>  
> -struct tipc_node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
> +static LIST_HEAD(nodes_list);	/* sorted list of neighboring nodes */
> +static int node_count;	/* number of neighboring nodes that exist */
> +static int link_count;	/* number of unicast links node currently has */
>  
>  static DEFINE_SPINLOCK(node_create_lock);
>  
> @@ -70,11 +72,11 @@ struct tipc_node *tipc_node_create(u32 addr)
>  {
>  	struct cluster *c_ptr;
>  	struct tipc_node *n_ptr;
> -	struct tipc_node **curr_node;
> +	struct tipc_node *new_n_ptr;
>  
>  	spin_lock_bh(&node_create_lock);
>  
> -	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
> +	list_for_each_entry(n_ptr, &nodes_list, node_list) {
>  		if (addr < n_ptr->addr)
>  			break;
>  		if (addr == n_ptr->addr) {
> @@ -83,8 +85,8 @@ struct tipc_node *tipc_node_create(u32 addr)
>  		}
>  	}
>  
> -	n_ptr = kzalloc(sizeof(*n_ptr),GFP_ATOMIC);
> -	if (!n_ptr) {
> +	new_n_ptr = kzalloc(sizeof(*new_n_ptr), GFP_ATOMIC);
> +	if (!new_n_ptr) {
>  		spin_unlock_bh(&node_create_lock);
>  		warn("Node creation failed, no memory\n");
>  		return NULL;
> @@ -96,28 +98,22 @@ struct tipc_node *tipc_node_create(u32 addr)
>  	}
>  	if (!c_ptr) {
>  		spin_unlock_bh(&node_create_lock);
> -		kfree(n_ptr);
> +		kfree(new_n_ptr);
>  		return NULL;
>  	}
>  
> -	n_ptr->addr = addr;
> -		spin_lock_init(&n_ptr->lock);
> -	INIT_LIST_HEAD(&n_ptr->nsub);
> -	n_ptr->owner = c_ptr;
> -	tipc_cltr_attach_node(c_ptr, n_ptr);
> -	n_ptr->last_router = -1;
> +	new_n_ptr->addr = addr;
> +	spin_lock_init(&new_n_ptr->lock);
> +	INIT_LIST_HEAD(&new_n_ptr->nsub);
> +	new_n_ptr->owner = c_ptr;
> +	tipc_cltr_attach_node(c_ptr, new_n_ptr);
> +	new_n_ptr->last_router = -1;
> +
> +	list_add_tail(&new_n_ptr->node_list, &n_ptr->node_list);
> +	node_count++;
>  
> -	/* Insert node into ordered list */
> -	for (curr_node = &tipc_nodes; *curr_node;
> -	     curr_node = &(*curr_node)->next) {
> -		if (addr < (*curr_node)->addr) {
> -			n_ptr->next = *curr_node;
> -			break;
> -		}
> -	}
> -	(*curr_node) = n_ptr;
>  	spin_unlock_bh(&node_create_lock);
> -	return n_ptr;
> +	return new_n_ptr;
>  }
>  
>  void tipc_node_delete(struct tipc_node *n_ptr)
> @@ -136,6 +132,8 @@ void tipc_node_delete(struct tipc_node *n_ptr)
>  #endif
>  
>  	dbg("node %x deleted\n", n_ptr->addr);
> +	node_count--;
> +	list_del(&n_ptr->node_list);
>  	kfree(n_ptr);
>  }
>  
> @@ -275,6 +273,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
>  			n_ptr->links[bearer_id] = l_ptr;
>  			tipc_net.zones[tipc_zone(l_ptr->addr)]->links++;
>  			n_ptr->link_cnt++;
> +			link_count++;
>  			return n_ptr;
>  		}
>  		err("Attempt to establish second link on <%s> to %s\n",
> @@ -289,6 +288,7 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
>  	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
>  	tipc_net.zones[tipc_zone(l_ptr->addr)]->links--;
>  	n_ptr->link_cnt--;
> +	link_count--;
>  }
>  
>  /*
> @@ -619,7 +619,7 @@ u32 tipc_available_nodes(const u32 domain)
>  	u32 cnt = 0;
>  
>  	read_lock_bh(&tipc_net_lock);
> -	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
> +	list_for_each_entry(n_ptr, &nodes_list, node_list) {
>  		if (!tipc_in_scope(domain, n_ptr->addr))
>  			continue;
>  		if (tipc_node_is_up(n_ptr))
> @@ -646,15 +646,14 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
>  						   " (network address)");
>  
>  	read_lock_bh(&tipc_net_lock);
> -	if (!tipc_nodes) {
> +	if (!node_count) {
>  		read_unlock_bh(&tipc_net_lock);
>  		return tipc_cfg_reply_none();
>  	}
>  
> -	/* For now, get space for all other nodes
> -	   (will need to modify this when slave nodes are supported */
> +	/* Get space for all neighboring nodes */
>  
> -	payload_size = TLV_SPACE(sizeof(node_info)) * (tipc_max_nodes - 1);
> +	payload_size = TLV_SPACE(sizeof(node_info)) * node_count;
>  	if (payload_size > 32768u) {
>  		read_unlock_bh(&tipc_net_lock);
>  		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
> @@ -668,7 +667,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
>  
>  	/* Add TLVs for all nodes in scope */
>  
> -	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
> +	list_for_each_entry(n_ptr, &nodes_list, node_list) {
>  		if (!tipc_in_scope(domain, n_ptr->addr))
>  			continue;
>  		node_info.addr = htonl(n_ptr->addr);
> @@ -704,8 +703,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
>  
>  	/* Get space for all unicast links + multicast link */
>  
> -	payload_size = TLV_SPACE(sizeof(link_info)) *
> -		(tipc_net.zones[tipc_zone(tipc_own_addr)]->links + 1);
> +	payload_size = TLV_SPACE(sizeof(link_info)) * (link_count + 1);
>  	if (payload_size > 32768u) {
>  		read_unlock_bh(&tipc_net_lock);
>  		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
> @@ -726,7 +724,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
>  
>  	/* Add TLVs for any other links in scope */
>  
> -	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
> +	list_for_each_entry(n_ptr, &nodes_list, node_list) {
>  		u32 i;
>  
>  		if (!tipc_in_scope(domain, n_ptr->addr))
> diff --git a/net/tipc/node.h b/net/tipc/node.h
> index 45f3db3..26715dc 100644
> --- a/net/tipc/node.h
> +++ b/net/tipc/node.h
> @@ -47,7 +47,7 @@
>   * @addr: network address of node
>   * @lock: spinlock governing access to structure
>   * @owner: pointer to cluster that node belongs to
> - * @next: pointer to next node in sorted list of cluster's nodes
> + * @node_list: adjacent entries in sorted list of nodes
>   * @nsub: list of "node down" subscriptions monitoring node
>   * @active_links: pointers to active links to node
>   * @links: pointers to all links to node
> @@ -73,7 +73,7 @@ struct tipc_node {
>  	u32 addr;
>  	spinlock_t lock;
>  	struct cluster *owner;
> -	struct tipc_node *next;
> +	struct list_head node_list;
>  	struct list_head nsub;
>  	struct link *active_links[2];
>  	struct link *links[MAX_BEARERS];
> @@ -96,7 +96,6 @@ struct tipc_node {
>  	} bclink;
>  };
>  
> -extern struct tipc_node *tipc_nodes;
>  extern u32 tipc_own_tag;
>  
>  struct tipc_node *tipc_node_create(u32 addr);
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
