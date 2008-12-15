From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Mon, 15 Dec 2008 15:29:42 -0800
Message-ID: <20081215232942.GD6759@linux.vnet.ibm.com>
References: <20081213013420.GA13549@gondor.apana.org.au> <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60249 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbYLOX3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 18:29:44 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBFNStgQ022964
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 18:28:55 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBFNThH3169012
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 18:29:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBG0Tqc5028161
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 19:29:53 -0500
Content-Disposition: inline
In-Reply-To: <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 12:35:21PM +1100, Herbert Xu wrote:
> net: Add Generic Receive Offload infrastructure
> 
> This patch adds the top-level GRO (Generic Receive Offload) infrastructure.
> This is pretty similar to LRO except that this is protocol-independent.
> Instead of holding packets in an lro_mgr structure, they're now held in
> napi_struct.

Looks good from an RCU standpoint, assuming that the hash table is 
fixed and never resized.  (If not, please see below.)

							Thanx, Paul

> For drivers that intend to use this, they can set the NETIF_F_GRO bit and
> call napi_gro_receive instead of netif_receive_skb or just call netif_rx.
> The latter will call napi_receive_skb automatically.  When napi_gro_receive
> is used, the driver must either call napi_complete/napi_rx_complete, or
> call napi_gro_flush in softirq context if the driver uses the primitives
> __napi_complete/__napi_rx_complete.
> 
> Protocols will set the gro_receive and gro_complete function pointers in
> order to participate in this scheme.
> 
> In addition to the packet, gro_receive will get a list of currently held
> packets.  Each packet in the list has a same_flow field which is non-zero
> if it is a potential match for the new packet.  For each packet that may
> match, they also have a flush field which is non-zero if the held packet
> must not be merged with the new packet.
> 
> Once gro_receive has determined that the new skb matches a held packet,
> the held packet may be processed immediately if the new skb cannot be
> merged with it.  In this case gro_receive should return the pointer to
> the existing skb in gro_list.  Otherwise the new skb should be merged into
> the existing packet and NULL should be returned, unless the new skb makes
> it impossible for any further merges to be made (e.g., FIN packet) where
> the merged skb should be returned.
> 
> Whenever the skb is merged into an existing entry, the gro_receive
> function should set NAPI_GRO_CB(skb)->same_flow.  Note that if an skb
> merely matches an existing entry but can't be merged with it, then
> this shouldn't be set.
> 
> If gro_receive finds it pointless to hold the new skb for future merging,
> it should set NAPI_GRO_CB(skb)->flush.
> 
> Held packets will be flushed by napi_gro_flush which is called by
> napi_complete and napi_rx_complete.
> 
> Currently held packets are stored in a singly liked list just like LRO.
> The list is limited to a maximum of 8 entries.  In future, this may be
> expanded to use a hash table to allow more flows to be held for merging.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  include/linux/netdevice.h |   74 ++++++------------
>  include/linux/netpoll.h   |    5 -
>  net/core/dev.c            |  186 +++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 212 insertions(+), 53 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8bf9127..5acd176 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -311,8 +311,9 @@ struct napi_struct {
>  	spinlock_t		poll_lock;
>  	int			poll_owner;
>  	struct net_device	*dev;
> -	struct list_head	dev_list;
>  #endif
> +	struct list_head	dev_list;
> +	struct sk_buff		*gro_list;
>  };
> 
>  enum
> @@ -372,22 +373,8 @@ static inline int napi_reschedule(struct napi_struct *napi)
>   *
>   * Mark NAPI processing as complete.
>   */
> -static inline void __napi_complete(struct napi_struct *n)
> -{
> -	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
> -	list_del(&n->poll_list);
> -	smp_mb__before_clear_bit();
> -	clear_bit(NAPI_STATE_SCHED, &n->state);
> -}
> -
> -static inline void napi_complete(struct napi_struct *n)
> -{
> -	unsigned long flags;
> -
> -	local_irq_save(flags);
> -	__napi_complete(n);
> -	local_irq_restore(flags);
> -}
> +extern void __napi_complete(struct napi_struct *n);
> +extern void napi_complete(struct napi_struct *n);
> 
>  /**
>   *	napi_disable - prevent NAPI from scheduling
> @@ -495,9 +482,7 @@ struct net_device
>  	unsigned long		state;
> 
>  	struct list_head	dev_list;
> -#ifdef CONFIG_NETPOLL
>  	struct list_head	napi_list;
> -#endif
>  	
>  	/* The device initialization function. Called only once. */
>  	int			(*init)(struct net_device *dev);
> @@ -521,6 +506,7 @@ struct net_device
>  #define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
>  					/* do not use LLTX in new drivers */
>  #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
> +#define NETIF_F_GRO		16384	/* Generic receive offload */
>  #define NETIF_F_LRO		32768	/* large receive offload */
> 
>  	/* Segmentation offload features */
> @@ -858,22 +844,8 @@ static inline void *netdev_priv(const struct net_device *dev)
>   * netif_napi_add() must be used to initialize a napi context prior to calling
>   * *any* of the other napi related functions.
>   */
> -static inline void netif_napi_add(struct net_device *dev,
> -				  struct napi_struct *napi,
> -				  int (*poll)(struct napi_struct *, int),
> -				  int weight)
> -{
> -	INIT_LIST_HEAD(&napi->poll_list);
> -	napi->poll = poll;
> -	napi->weight = weight;
> -#ifdef CONFIG_NETPOLL
> -	napi->dev = dev;
> -	list_add(&napi->dev_list, &dev->napi_list);
> -	spin_lock_init(&napi->poll_lock);
> -	napi->poll_owner = -1;
> -#endif
> -	set_bit(NAPI_STATE_SCHED, &napi->state);
> -}
> +void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
> +		    int (*poll)(struct napi_struct *, int), int weight);
> 
>  /**
>   *  netif_napi_del - remove a napi context
> @@ -881,12 +853,20 @@ static inline void netif_napi_add(struct net_device *dev,
>   *
>   *  netif_napi_del() removes a napi context from the network device napi list
>   */
> -static inline void netif_napi_del(struct napi_struct *napi)
> -{
> -#ifdef CONFIG_NETPOLL
> -	list_del(&napi->dev_list);
> -#endif
> -}
> +void netif_napi_del(struct napi_struct *napi);
> +
> +struct napi_gro_cb {
> +	/* This is non-zero if the packet may be of the same flow. */
> +	int same_flow;
> +
> +	/* This is non-zero if the packet cannot be merged with the new skb. */
> +	int flush;
> +
> +	/* Number of segments aggregated. */
> +	int count;
> +};
> +
> +#define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
> 
>  struct packet_type {
>  	__be16			type;	/* This is really htons(ether_type). */
> @@ -898,6 +878,9 @@ struct packet_type {
>  	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
>  						int features);
>  	int			(*gso_send_check)(struct sk_buff *skb);
> +	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
> +					       struct sk_buff *skb);
> +	int			(*gro_complete)(struct sk_buff *skb);
>  	void			*af_packet_priv;
>  	struct list_head	list;
>  };
> @@ -1251,6 +1234,9 @@ extern int		netif_rx(struct sk_buff *skb);
>  extern int		netif_rx_ni(struct sk_buff *skb);
>  #define HAVE_NETIF_RECEIVE_SKB 1
>  extern int		netif_receive_skb(struct sk_buff *skb);
> +extern void		napi_gro_flush(struct napi_struct *napi);
> +extern int		napi_gro_receive(struct napi_struct *napi,
> +					 struct sk_buff *skb);
>  extern void		netif_nit_deliver(struct sk_buff *skb);
>  extern int		dev_valid_name(const char *name);
>  extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
> @@ -1495,11 +1481,7 @@ static inline void __netif_rx_complete(struct net_device *dev,
>  static inline void netif_rx_complete(struct net_device *dev,
>  				     struct napi_struct *napi)
>  {
> -	unsigned long flags;
> -
> -	local_irq_save(flags);
> -	__netif_rx_complete(dev, napi);
> -	local_irq_restore(flags);
> +	napi_complete(napi);
>  }
> 
>  static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index e3d7959..e38d3c9 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -94,11 +94,6 @@ static inline void netpoll_poll_unlock(void *have)
>  	rcu_read_unlock();
>  }
> 
> -static inline void netpoll_netdev_init(struct net_device *dev)
> -{
> -	INIT_LIST_HEAD(&dev->napi_list);
> -}
> -
>  #else
>  static inline int netpoll_rx(struct sk_buff *skb)
>  {
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4388e27..5e5132c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -130,6 +130,9 @@
> 
>  #include "net-sysfs.h"
> 
> +/* Instead of increasing this, you should create a hash table. */
> +#define MAX_GRO_SKBS 8
> +
>  /*
>   *	The list of packet types we will receive (as opposed to discard)
>   *	and the routines to invoke.
> @@ -2323,6 +2326,122 @@ static void flush_backlog(void *arg)
>  		}
>  }
> 
> +static int napi_gro_complete(struct sk_buff *skb)
> +{
> +	struct packet_type *ptype;
> +	__be16 type = skb->protocol;
> +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> +	int err = -ENOENT;
> +
> +	if (!skb_shinfo(skb)->frag_list)
> +		goto out;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ptype, head, list) {
> +		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
> +			continue;
> +
> +		err = ptype->gro_complete(skb);
> +		break;
> +	}
> +	rcu_read_unlock();
> +
> +	if (err) {
> +		WARN_ON(&ptype->list == head);

Presumably ptype_base[] is a static array rather than a dynamically
allocated array that is resized under RCU protection, right?  Otherwise,
you could get in trouble if the above raced with the resize operation due
to the fact that you are outside of the RCU read-side critical section.

> +		kfree_skb(skb);
> +		return NET_RX_SUCCESS;
> +	}
> +
> +out:
> +	__skb_push(skb, -skb_network_offset(skb));
> +	return netif_receive_skb(skb);
> +}
> +
> +void napi_gro_flush(struct napi_struct *napi)
> +{
> +	struct sk_buff *skb, *next;
> +
> +	for (skb = napi->gro_list; skb; skb = next) {
> +		next = skb->next;
> +		skb->next = NULL;
> +		napi_gro_complete(skb);
> +	}
> +
> +	napi->gro_list = NULL;
> +}
> +EXPORT_SYMBOL(napi_gro_flush);
> +
> +int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> +{
> +	struct sk_buff **pp;
> +	struct packet_type *ptype;
> +	__be16 type = skb->protocol;
> +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> +	int count = 0;
> +	int mac_len;
> +
> +	if (!(skb->dev->features & NETIF_F_GRO))
> +		goto normal;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ptype, head, list) {
> +		struct sk_buff *p;
> +
> +		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
> +			continue;
> +
> +		skb_reset_network_header(skb);
> +		mac_len = skb->network_header - skb->mac_header;
> +		skb->mac_len = mac_len;
> +		NAPI_GRO_CB(skb)->same_flow = 0;
> +		NAPI_GRO_CB(skb)->flush = 0;
> +
> +		for (p = napi->gro_list; p; p = p->next) {
> +			count++;
> +			NAPI_GRO_CB(p)->same_flow =
> +				p->mac_len == mac_len &&
> +				!memcmp(skb_mac_header(p), skb_mac_header(skb),
> +					mac_len);
> +			NAPI_GRO_CB(p)->flush = 0;
> +		}
> +
> +		pp = ptype->gro_receive(&napi->gro_list, skb);
> +		break;
> +	}
> +	rcu_read_unlock();
> +
> +	if (&ptype->list == head)

Ditto.

> +		goto normal;
> +
> +	if (pp) {
> +		struct sk_buff *nskb = *pp;
> +
> +		*pp = nskb->next;
> +		nskb->next = NULL;
> +		napi_gro_complete(nskb);
> +		count--;
> +	}
> +
> +	if (NAPI_GRO_CB(skb)->same_flow)
> +		goto ok;
> +
> +	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS) {
> +		__skb_push(skb, -skb_network_offset(skb));
> +		goto normal;
> +	}
> +
> +	NAPI_GRO_CB(skb)->count = 1;
> +	skb->next = napi->gro_list;
> +	napi->gro_list = skb;
> +
> +ok:
> +	return NET_RX_SUCCESS;
> +
> +normal:
> +	return netif_receive_skb(skb);
> +}
> +EXPORT_SYMBOL(napi_gro_receive);
> +
>  static int process_backlog(struct napi_struct *napi, int quota)
>  {
>  	int work = 0;
> @@ -2342,9 +2461,11 @@ static int process_backlog(struct napi_struct *napi, int quota)
>  		}
>  		local_irq_enable();
> 
> -		netif_receive_skb(skb);
> +		napi_gro_receive(napi, skb);
>  	} while (++work < quota && jiffies == start_time);
> 
> +	napi_gro_flush(napi);
> +
>  	return work;
>  }
> 
> @@ -2365,6 +2486,61 @@ void __napi_schedule(struct napi_struct *n)
>  }
>  EXPORT_SYMBOL(__napi_schedule);
> 
> +void __napi_complete(struct napi_struct *n)
> +{
> +	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
> +	BUG_ON(n->gro_list);
> +
> +	list_del(&n->poll_list);
> +	smp_mb__before_clear_bit();
> +	clear_bit(NAPI_STATE_SCHED, &n->state);
> +}
> +EXPORT_SYMBOL(__napi_complete);
> +
> +void napi_complete(struct napi_struct *n)
> +{
> +	unsigned long flags;
> +
> +	napi_gro_flush(n);
> +	local_irq_save(flags);
> +	__napi_complete(n);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(napi_complete);
> +
> +void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
> +		    int (*poll)(struct napi_struct *, int), int weight)
> +{
> +	INIT_LIST_HEAD(&napi->poll_list);
> +	napi->gro_list = NULL;
> +	napi->poll = poll;
> +	napi->weight = weight;
> +	list_add(&napi->dev_list, &dev->napi_list);
> +#ifdef CONFIG_NETPOLL
> +	napi->dev = dev;
> +	spin_lock_init(&napi->poll_lock);
> +	napi->poll_owner = -1;
> +#endif
> +	set_bit(NAPI_STATE_SCHED, &napi->state);
> +}
> +EXPORT_SYMBOL(netif_napi_add);
> +
> +void netif_napi_del(struct napi_struct *napi)
> +{
> +	struct sk_buff *skb, *next;
> +
> +	list_del(&napi->dev_list);
> +
> +	for (skb = napi->gro_list; skb; skb = next) {
> +		next = skb->next;
> +		skb->next = NULL;
> +		kfree_skb(skb);
> +	}
> +
> +	napi->gro_list = NULL;
> +}
> +EXPORT_SYMBOL(netif_napi_del);
> +
> 
>  static void net_rx_action(struct softirq_action *h)
>  {
> @@ -4348,7 +4524,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  	netdev_init_queues(dev);
> 
>  	dev->get_stats = internal_stats;
> -	netpoll_netdev_init(dev);
> +	INIT_LIST_HEAD(&dev->napi_list);
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
> @@ -4365,10 +4541,15 @@ EXPORT_SYMBOL(alloc_netdev_mq);
>   */
>  void free_netdev(struct net_device *dev)
>  {
> +	struct napi_struct *p, *n;
> +
>  	release_net(dev_net(dev));
> 
>  	kfree(dev->_tx);
> 
> +	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
> +		netif_napi_del(p);
> +
>  	/*  Compatibility with error handling in drivers */
>  	if (dev->reg_state == NETREG_UNINITIALIZED) {
>  		kfree((char *)dev - dev->padded);
> @@ -4904,6 +5085,7 @@ static int __init net_dev_init(void)
> 
>  		queue->backlog.poll = process_backlog;
>  		queue->backlog.weight = weight_p;
> +		queue->backlog.gro_list = NULL;
>  	}
> 
>  	netdev_dma_register();
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
