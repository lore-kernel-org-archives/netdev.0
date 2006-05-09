From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Tue, 9 May 2006 11:56:33 -0700
Message-ID: <20060509115633.36b4879e@localhost.localdomain>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20060509085201.446830000@sous-sol.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

The stuff in /proc could easily just be added attributes to the class_device kobject
of the net device (and then show up in sysfs).


> +
> +#define GRANT_INVALID_REF	0
> +
> +#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
> +#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
> +
> +static inline void init_skb_shinfo(struct sk_buff *skb)
> +{
> +	atomic_set(&(skb_shinfo(skb)->dataref), 1);
> +	skb_shinfo(skb)->nr_frags = 0;
> +	skb_shinfo(skb)->frag_list = NULL;
> +}
> +

Could you use existing sk_buff_head instead of inventing your
own skb queue?

> +struct netfront_info
> +{
> +	struct list_head list;
> +	struct net_device *netdev;
> +
> +	struct net_device_stats stats;
> +	unsigned int tx_full;
> +
> +	struct netif_tx_front_ring tx;
> +	struct netif_rx_front_ring rx;
> +
> +	spinlock_t   tx_lock;
> +	spinlock_t   rx_lock;
> +
> +	unsigned int handle;
> +	unsigned int evtchn, irq;
> +
> +	/* What is the status of our connection to the remote backend? */
> +#define BEST_CLOSED       0
> +#define BEST_DISCONNECTED 1
> +#define BEST_CONNECTED    2
> +	unsigned int backend_state;
> +
> +	/* Is this interface open or closed (down or up)? */
> +#define UST_CLOSED        0
> +#define UST_OPEN          1
> +	unsigned int user_state;
> +
> +	/* Receive-ring batched refills. */
> +#define RX_MIN_TARGET 8
> +#define RX_DFL_MIN_TARGET 64
> +#define RX_MAX_TARGET NET_RX_RING_SIZE
> +	int rx_min_target, rx_max_target, rx_target;
> +	struct sk_buff_head rx_batch;
> +
> +	struct timer_list rx_refill_timer;
> +
> +	/*
> +	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in each
> +	 * array is an index into a chain of free entries.
> +	 */
> +	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
> +	struct sk_buff *rx_skbs[NET_RX_RING_SIZE+1];
> +
> +	grant_ref_t gref_tx_head;
> +	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
> +	grant_ref_t gref_rx_head;
> +	grant_ref_t grant_rx_ref[NET_TX_RING_SIZE + 1];
> +
> +	struct xenbus_device *xbdev;
> +	int tx_ring_ref;
> +	int rx_ring_ref;
> +	u8 mac[ETH_ALEN];

Isn't mac address already stored in dev->dev_addr and/or dev->perm_addr?
