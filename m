From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] "lockless loopback" patch for 2.6.6
Date: Fri, 21 May 2004 14:45:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521144536.250ca1a2@dell_ss3.pdx.osdl.net>
References: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com>
	<20040512120810.464aaee6.davem@redhat.com>
	<Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com>
	<Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 May 2004 14:04:09 -0700
Arthur Kepner <akepner@sgi.com> wrote:

> 
> Lock contention on the loopback device can lead to poor
> performance, even an essentially hung system, on systems
> with many processors.
> 
> For the loopback device, the only purpose that locking serves
> is to protect the device statistics. The attached patch
> keeps per-cpu statistics for the loopback device and removes
> all locking. The patch is against 2.6.6.

The problem is more general than just loopback.
This kind of special case hack is the right thing.
Really fast network devices will have the same issues.

> diff -Naur linux.orig/drivers/net/loopback.c linux/drivers/net/loopback.c
> --- linux.orig/drivers/net/loopback.c	2004-05-21 11:00:24.000000000 -0700
> +++ linux/drivers/net/loopback.c	2004-05-21 11:04:00.000000000 -0700
> @@ -123,7 +123,9 @@
>   */
>  static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct net_device_stats *stats = dev->priv;
> +	struct net_device_stats *global_stats = dev->priv;
> +	struct net_device_stats *percpu_stats = 0;
> +	struct net_device_stats *local_stats  = 0;
> 

Either do per-cpu stats or don't this seems confused with a mix of per-cpu
and global.


>  	skb_orphan(skb);
>  
> @@ -142,11 +144,13 @@
>  	}
>  
>  	dev->last_rx = jiffies;
> -	if (likely(stats)) {
> -		stats->rx_bytes+=skb->len;
> -		stats->tx_bytes+=skb->len;
> -		stats->rx_packets++;
> -		stats->tx_packets++;
> +	if (likely(global_stats)) {
> +		percpu_stats = global_stats + 1;
> +		local_stats  = &percpu_stats[smp_processor_id()];
> +		local_stats->rx_bytes+=skb->len;
> +		local_stats->tx_bytes+=skb->len;
> +		local_stats->rx_packets++;
> +		local_stats->tx_packets++;
>  	}
>  
>  	netif_rx(skb);
> @@ -156,7 +160,22 @@
>  
>  static struct net_device_stats *get_stats(struct net_device *dev)
>  {
> -	return (struct net_device_stats *)dev->priv;
> +	int i;
> +	struct net_device_stats *global_stats = dev->priv;
> +	struct net_device_stats *percpu_stats = 0;
> +
> +	if (global_stats) {
> +		percpu_stats = global_stats + 1;
> +		/* zero the system-wide stats */
> +		memset(global_stats, 0, sizeof(struct net_device_stats));
> +		for ( i = 0; i < NR_CPUS; i++ ) {
> +			global_stats->rx_bytes   += percpu_stats[i].rx_bytes;
> +			global_stats->tx_bytes   += percpu_stats[i].tx_bytes;
> +			global_stats->rx_packets += percpu_stats[i].rx_packets;
> +			global_stats->tx_packets += percpu_stats[i].tx_packets;
> +		}
> +	}
> +	return global_stats;
>  }
>  
>  struct net_device loopback_dev = {
> @@ -181,13 +200,19 @@
>  {
>  	struct net_device_stats *stats;
>  
> +#define NR_LOOP_STATS (NR_CPUS + 1)
> +	/* the first net_device_stats structure is for the whole system, the 
> +	 * remaining NR_CPUS of them are for each cpu */
> +
>  	/* Can survive without statistics */
> -	stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
> +	stats = kmalloc(NR_LOOP_STATS * sizeof(struct net_device_stats), GFP_KERNEL);
>

Use use per-cpu data rather than slots in an array.


>  	if (stats) {
> -		memset(stats, 0, sizeof(struct net_device_stats));
> +		memset(stats, 0, NR_LOOP_STATS * sizeof(struct net_device_stats));
>  		loopback_dev.priv = stats;
>  		loopback_dev.get_stats = &get_stats;
>  	}
> +#undef  NR_LOOP_STATS
>  	
>  	return register_netdev(&loopback_dev);
>  };
> diff -Naur linux.orig/net/core/dev.c linux/net/core/dev.c
> --- linux.orig/net/core/dev.c	2004-05-21 11:01:01.000000000 -0700
> +++ linux/net/core/dev.c	2004-05-21 11:03:44.000000000 -0700
> @@ -1295,6 +1295,7 @@
>  	struct net_device *dev = skb->dev;
>  	struct Qdisc *q;
>  	int rc = -ENOMEM;
> +	int loopback = dev->flags & IFF_LOOPBACK;

Boolean flags are for PASCAL programmers, test it where you use it.

>  
>  	if (skb_shinfo(skb)->frag_list &&
>  	    !(dev->features & NETIF_F_FRAGLIST) &&
> @@ -1322,17 +1323,19 @@
>  	}

The real problem here is having a single queue, for the loopback
device you don't want a a queue at all by default.  That would get around
a lot of the mess.


>  	/* Grab device queue */
> -	spin_lock_bh(&dev->queue_lock);
> -	q = dev->qdisc;
> -	if (q->enqueue) {
> -		rc = q->enqueue(skb, q);
> +	if (!loopback) {
> +		spin_lock_bh(&dev->queue_lock);
> +		q = dev->qdisc;
> +		if (q->enqueue) {
> +			rc = q->enqueue(skb, q);
>  
> -		qdisc_run(dev);
> +			qdisc_run(dev);
>  
> -		spin_unlock_bh(&dev->queue_lock);
> -		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
> -		goto out;
> -	}
> +			spin_unlock_bh(&dev->queue_lock);
> +			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
> +			goto out;
> +		}
> +	} /* !loopback */
>  
>  	/* The device has no queue. Common case for software devices:
>  	   loopback, all the sorts of tunnels...
> @@ -1354,11 +1357,13 @@
>  			 * The spin_lock effectivly does a preempt lock, but 
>  			 * we are about to drop that...
>  			 */
> -			preempt_disable();
> -			spin_unlock(&dev->queue_lock);
> -			spin_lock(&dev->xmit_lock);
> -			dev->xmit_lock_owner = cpu;
> -			preempt_enable();
> +			if (!loopback) {
> +				preempt_disable();
> +				spin_unlock(&dev->queue_lock);
> +				spin_lock(&dev->xmit_lock);
> +				dev->xmit_lock_owner = cpu;
> +				preempt_enable();
> +			}
>  
>  			if (!netif_queue_stopped(dev)) {
>  				if (netdev_nit)
> @@ -1366,13 +1371,17 @@
>  
>  				rc = 0;
>  				if (!dev->hard_start_xmit(skb, dev)) {
> -					dev->xmit_lock_owner = -1;
> -					spin_unlock_bh(&dev->xmit_lock);
> +					if (!loopback) {
> +						dev->xmit_lock_owner = -1;
> +						spin_unlock_bh(&dev->xmit_lock);
> +					}
>  					goto out;
>  				}
>  			}
> -			dev->xmit_lock_owner = -1;
> -			spin_unlock_bh(&dev->xmit_lock);
> +			if (!loopback) {
> +				dev->xmit_lock_owner = -1;
> +				spin_unlock_bh(&dev->xmit_lock);
> +			}
>  			if (net_ratelimit())
>  				printk(KERN_CRIT "Virtual device %s asks to "
>  				       "queue packet!\n", dev->name);
> @@ -1385,7 +1394,8 @@
>  				       "%s, fix it urgently!\n", dev->name);
>  		}
>  	}
> -	spin_unlock_bh(&dev->queue_lock);
> +	if (!loopback)
> +		spin_unlock_bh(&dev->queue_lock);
>  out_enetdown:
>  	rc = -ENETDOWN;
>  out_kfree_skb:
