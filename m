From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH] net, tun: remove the flow cache
Date: Tue, 17 Dec 2013 16:49:14 +0800
Message-ID: <52B0100A.3030002@redhat.com>
References: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/17/2013 03:26 PM, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> The flow cache is an extremely broken concept, and it usually brings up
> growth issues and DoS attacks, so this patch is trying to remove it from
> the tuntap driver, and insteadly use a simpler way for its flow control.

NACK.

This single function revert does not make sense to me. Since:

- You in fact removes the flow steering function in tun. We definitely
need something like this to unbreak the TCP performance in a multiqueue
guest. Please have a look at the virtio-net driver / virtio sepc for
more information.
- The total number of flow caches were limited to 4096, so there's no
DoS or growth issue.
- The only issue is scalability, but fixing this is not easy. We can
just use arrays/indirection table like RSS instead of hash buckets, it
saves some time in linear search but has other issues like collision
- I've also had a RFC of using aRFS in the past, it also has several
drawbacks such as busy looping in the networking hotspot.

So in conclusion, we need flow steering in tun, just removing current
method does not help. The proper way is to expose several different
methods to user and let user to choose the preferable mechanism like
packet.

>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/tun.c |  208 +++--------------------------------------------------
>  1 files changed, 10 insertions(+), 198 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 7c8343a..7c27fdc 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -32,12 +32,15 @@
>   *
>   *  Daniel Podlejski <underley@underley.eu.org>
>   *    Modifications for 2.3.99-pre5 kernel.
> + *
> + *  Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> + *    Remove the flow cache.
>   */
>  
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #define DRV_NAME	"tun"
> -#define DRV_VERSION	"1.6"
> +#define DRV_VERSION	"1.7"
>  #define DRV_DESCRIPTION	"Universal TUN/TAP device driver"
>  #define DRV_COPYRIGHT	"(C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>"
>  
> @@ -146,18 +149,6 @@ struct tun_file {
>  	struct tun_struct *detached;
>  };
>  
> -struct tun_flow_entry {
> -	struct hlist_node hash_link;
> -	struct rcu_head rcu;
> -	struct tun_struct *tun;
> -
> -	u32 rxhash;
> -	int queue_index;
> -	unsigned long updated;
> -};
> -
> -#define TUN_NUM_FLOW_ENTRIES 1024
> -
>  /* Since the socket were moved to tun_file, to preserve the behavior of persist
>   * device, socket filter, sndbuf and vnet header size were restore when the
>   * file were attached to a persist device.
> @@ -184,163 +175,11 @@ struct tun_struct {
>  	int debug;
>  #endif
>  	spinlock_t lock;
> -	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
> -	struct timer_list flow_gc_timer;
> -	unsigned long ageing_time;
>  	unsigned int numdisabled;
>  	struct list_head disabled;
>  	void *security;
> -	u32 flow_count;
>  };
>  
> -static inline u32 tun_hashfn(u32 rxhash)
> -{
> -	return rxhash & 0x3ff;
> -}
> -
> -static struct tun_flow_entry *tun_flow_find(struct hlist_head *head, u32 rxhash)
> -{
> -	struct tun_flow_entry *e;
> -
> -	hlist_for_each_entry_rcu(e, head, hash_link) {
> -		if (e->rxhash == rxhash)
> -			return e;
> -	}
> -	return NULL;
> -}
> -
> -static struct tun_flow_entry *tun_flow_create(struct tun_struct *tun,
> -					      struct hlist_head *head,
> -					      u32 rxhash, u16 queue_index)
> -{
> -	struct tun_flow_entry *e = kmalloc(sizeof(*e), GFP_ATOMIC);
> -
> -	if (e) {
> -		tun_debug(KERN_INFO, tun, "create flow: hash %u index %u\n",
> -			  rxhash, queue_index);
> -		e->updated = jiffies;
> -		e->rxhash = rxhash;
> -		e->queue_index = queue_index;
> -		e->tun = tun;
> -		hlist_add_head_rcu(&e->hash_link, head);
> -		++tun->flow_count;
> -	}
> -	return e;
> -}
> -
> -static void tun_flow_delete(struct tun_struct *tun, struct tun_flow_entry *e)
> -{
> -	tun_debug(KERN_INFO, tun, "delete flow: hash %u index %u\n",
> -		  e->rxhash, e->queue_index);
> -	hlist_del_rcu(&e->hash_link);
> -	kfree_rcu(e, rcu);
> -	--tun->flow_count;
> -}
> -
> -static void tun_flow_flush(struct tun_struct *tun)
> -{
> -	int i;
> -
> -	spin_lock_bh(&tun->lock);
> -	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
> -		struct tun_flow_entry *e;
> -		struct hlist_node *n;
> -
> -		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link)
> -			tun_flow_delete(tun, e);
> -	}
> -	spin_unlock_bh(&tun->lock);
> -}
> -
> -static void tun_flow_delete_by_queue(struct tun_struct *tun, u16 queue_index)
> -{
> -	int i;
> -
> -	spin_lock_bh(&tun->lock);
> -	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
> -		struct tun_flow_entry *e;
> -		struct hlist_node *n;
> -
> -		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link) {
> -			if (e->queue_index == queue_index)
> -				tun_flow_delete(tun, e);
> -		}
> -	}
> -	spin_unlock_bh(&tun->lock);
> -}
> -
> -static void tun_flow_cleanup(unsigned long data)
> -{
> -	struct tun_struct *tun = (struct tun_struct *)data;
> -	unsigned long delay = tun->ageing_time;
> -	unsigned long next_timer = jiffies + delay;
> -	unsigned long count = 0;
> -	int i;
> -
> -	tun_debug(KERN_INFO, tun, "tun_flow_cleanup\n");
> -
> -	spin_lock_bh(&tun->lock);
> -	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
> -		struct tun_flow_entry *e;
> -		struct hlist_node *n;
> -
> -		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link) {
> -			unsigned long this_timer;
> -			count++;
> -			this_timer = e->updated + delay;
> -			if (time_before_eq(this_timer, jiffies))
> -				tun_flow_delete(tun, e);
> -			else if (time_before(this_timer, next_timer))
> -				next_timer = this_timer;
> -		}
> -	}
> -
> -	if (count)
> -		mod_timer(&tun->flow_gc_timer, round_jiffies_up(next_timer));
> -	spin_unlock_bh(&tun->lock);
> -}
> -
> -static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
> -			    struct tun_file *tfile)
> -{
> -	struct hlist_head *head;
> -	struct tun_flow_entry *e;
> -	unsigned long delay = tun->ageing_time;
> -	u16 queue_index = tfile->queue_index;
> -
> -	if (!rxhash)
> -		return;
> -	else
> -		head = &tun->flows[tun_hashfn(rxhash)];
> -
> -	rcu_read_lock();
> -
> -	/* We may get a very small possibility of OOO during switching, not
> -	 * worth to optimize.*/
> -	if (tun->numqueues == 1 || tfile->detached)
> -		goto unlock;
> -
> -	e = tun_flow_find(head, rxhash);
> -	if (likely(e)) {
> -		/* TODO: keep queueing to old queue until it's empty? */
> -		e->queue_index = queue_index;
> -		e->updated = jiffies;
> -	} else {
> -		spin_lock_bh(&tun->lock);
> -		if (!tun_flow_find(head, rxhash) &&
> -		    tun->flow_count < MAX_TAP_FLOWS)
> -			tun_flow_create(tun, head, rxhash, queue_index);
> -
> -		if (!timer_pending(&tun->flow_gc_timer))
> -			mod_timer(&tun->flow_gc_timer,
> -				  round_jiffies_up(jiffies + delay));
> -		spin_unlock_bh(&tun->lock);
> -	}
> -
> -unlock:
> -	rcu_read_unlock();
> -}
> -
>  /* We try to identify a flow through its rxhash first. The reason that
>   * we do not check rxq no. is becuase some cards(e.g 82599), chooses
>   * the rxq based on the txq where the last packet of the flow comes. As
> @@ -351,7 +190,6 @@ unlock:
>  static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  {
>  	struct tun_struct *tun = netdev_priv(dev);
> -	struct tun_flow_entry *e;
>  	u32 txq = 0;
>  	u32 numqueues = 0;
>  
> @@ -360,12 +198,11 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  
>  	txq = skb_get_rxhash(skb);
>  	if (txq) {
> -		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
> -		if (e)
> -			txq = e->queue_index;
> -		else
> +		txq = skb_get_queue_mapping(skb);
> +		if (!txq) {
>  			/* use multiply and shift instead of expensive divide */
>  			txq = ((u64)txq * numqueues) >> 32;
> +		}
>  	} else if (likely(skb_rx_queue_recorded(skb))) {
>  		txq = skb_get_rx_queue(skb);
>  		while (unlikely(txq >= numqueues))
> @@ -439,7 +276,6 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>  			tun_disable_queue(tun, tfile);
>  
>  		synchronize_net();
> -		tun_flow_delete_by_queue(tun, tun->numqueues + 1);
>  		/* Drop read queue */
>  		tun_queue_purge(tfile);
>  		tun_set_real_num_queues(tun);
> @@ -858,25 +694,6 @@ static const struct net_device_ops tap_netdev_ops = {
>  #endif
>  };
>  
> -static void tun_flow_init(struct tun_struct *tun)
> -{
> -	int i;
> -
> -	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++)
> -		INIT_HLIST_HEAD(&tun->flows[i]);
> -
> -	tun->ageing_time = TUN_FLOW_EXPIRE;
> -	setup_timer(&tun->flow_gc_timer, tun_flow_cleanup, (unsigned long)tun);
> -	mod_timer(&tun->flow_gc_timer,
> -		  round_jiffies_up(jiffies + tun->ageing_time));
> -}
> -
> -static void tun_flow_uninit(struct tun_struct *tun)
> -{
> -	del_timer_sync(&tun->flow_gc_timer);
> -	tun_flow_flush(tun);
> -}
> -
>  /* Initialize net device. */
>  static void tun_net_init(struct net_device *dev)
>  {
> @@ -986,7 +803,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	int copylen;
>  	bool zerocopy = false;
>  	int err;
> -	u32 rxhash;
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if (len < sizeof(pi))
> @@ -1146,13 +962,12 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	skb_reset_network_header(skb);
>  	skb_probe_transport_header(skb, 0);
>  
> -	rxhash = skb_get_rxhash(skb);
> +	skb_set_queue_mapping(skb, tfile->queue_index);
>  	netif_rx_ni(skb);
>  
>  	tun->dev->stats.rx_packets++;
>  	tun->dev->stats.rx_bytes += len;
>  
> -	tun_flow_update(tun, rxhash, tfile);
>  	return total_len;
>  }
>  
> @@ -1370,7 +1185,6 @@ static void tun_free_netdev(struct net_device *dev)
>  	struct tun_struct *tun = netdev_priv(dev);
>  
>  	BUG_ON(!(list_empty(&tun->disabled)));
> -	tun_flow_uninit(tun);
>  	security_tun_dev_free_security(tun->security);
>  	free_netdev(dev);
>  }
> @@ -1644,7 +1458,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  			goto err_free_dev;
>  
>  		tun_net_init(dev);
> -		tun_flow_init(tun);
>  
>  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
>  				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
> @@ -1655,7 +1468,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		INIT_LIST_HEAD(&tun->disabled);
>  		err = tun_attach(tun, file, false);
>  		if (err < 0)
> -			goto err_free_flow;
> +			goto err_free_security;
>  
>  		err = register_netdevice(tun->dev);
>  		if (err < 0)
> @@ -1705,8 +1518,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  err_detach:
>  	tun_detach_all(dev);
> -err_free_flow:
> -	tun_flow_uninit(tun);
> +err_free_security:
>  	security_tun_dev_free_security(tun->security);
>  err_free_dev:
>  	free_netdev(dev);
