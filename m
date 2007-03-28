From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Inline net_device_stats
Date: Wed, 28 Mar 2007 08:52:24 -0700
Message-ID: <460A8F38.1050106@osdl.org>
References: <1175073418.12230.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:48672 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932495AbXC1Pwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 11:52:31 -0400
In-Reply-To: <1175073418.12230.52.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> Hi all,
>
> 	Does something like this make sense for future drivers?
>
> Cheers,
> Rusty.
> ===
> Network drivers which keep stats allocate their own stats structure
> then write a get_stats() function to return them.  It would be nice if
> this were done by default.
>
> 1) Add a new "stats" field to "struct net_device".
> 2) Add a new feature field to say "this driver uses the internal one"
> 3) Have a default "get_stats" which returns NULL if that feature not set.
> 4) Change callers to check result of get_stats call for NULL, not if
>    ->get_stats is set.
>
> This should not break backwards compatibility with older drivers, yet
> allow modern drivers to shed some boilerplate code.
>
> Lightly tested: works for a modified lguest network driver.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  0 files changed
>
> diff -r 1ccab0a087b7 arch/s390/appldata/appldata_net_sum.c
> --- a/arch/s390/appldata/appldata_net_sum.c	Tue Mar 27 13:46:10 2007 +1000
> +++ b/arch/s390/appldata/appldata_net_sum.c	Tue Mar 27 14:28:47 2007 +1000
> @@ -108,10 +108,10 @@ static void appldata_get_net_sum_data(vo
>  	collisions = 0;
>  	read_lock(&dev_base_lock);
>  	for (dev = dev_base; dev != NULL; dev = dev->next) {
> -		if (dev->get_stats == NULL) {
> +		stats = dev->get_stats(dev);
> +		if (stats == NULL) {
>  			continue;
>  		}
> -		stats = dev->get_stats(dev);
>  		rx_packets += stats->rx_packets;
>  		tx_packets += stats->tx_packets;
>  		rx_bytes   += stats->rx_bytes;
> diff -r 1ccab0a087b7 drivers/net/bonding/bond_main.c
> --- a/drivers/net/bonding/bond_main.c	Tue Mar 27 13:46:10 2007 +1000
> +++ b/drivers/net/bonding/bond_main.c	Tue Mar 27 14:29:08 2007 +1000
> @@ -3621,9 +3621,8 @@ static struct net_device_stats *bond_get
>  	read_lock_bh(&bond->lock);
>  
>  	bond_for_each_slave(bond, slave, i) {
> -		if (slave->dev->get_stats) {
> -			sstats = slave->dev->get_stats(slave->dev);
> -
> +		sstats = slave->dev->get_stats(slave->dev);
> +		if (sstats) {
>  			stats->rx_packets += sstats->rx_packets;
>  			stats->rx_bytes += sstats->rx_bytes;
>  			stats->rx_errors += sstats->rx_errors;
> diff -r 1ccab0a087b7 drivers/parisc/led.c
> --- a/drivers/parisc/led.c	Tue Mar 27 13:46:10 2007 +1000
> +++ b/drivers/parisc/led.c	Tue Mar 27 14:29:17 2007 +1000
> @@ -372,9 +372,9 @@ static __inline__ int led_get_net_activi
>  		continue;
>  	    if (LOOPBACK(in_dev->ifa_list->ifa_local))
>  		continue;
> -	    if (!dev->get_stats) 
> +	    stats = dev->get_stats(dev);
> +	    if (!stats) 
>  		continue;
> -	    stats = dev->get_stats(dev);
>  	    rx_total += stats->rx_packets;
>  	    tx_total += stats->tx_packets;
>  	}
> diff -r 1ccab0a087b7 include/linux/netdevice.h
> --- a/include/linux/netdevice.h	Tue Mar 27 13:46:10 2007 +1000
> +++ b/include/linux/netdevice.h	Tue Mar 27 14:21:09 2007 +1000
> @@ -325,6 +325,7 @@ struct net_device
>  #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
>  #define NETIF_F_GSO		2048	/* Enable software GSO. */
>  #define NETIF_F_LLTX		4096	/* LockLess TX */
> +#define NETIF_F_INTERNAL_STATS	8192	/* Use stats structure in net_device */
>  
>  	/* Segmentation offload features */
>  #define NETIF_F_GSO_SHIFT	16
> @@ -349,6 +350,7 @@ struct net_device
>  
>  
>  	struct net_device_stats* (*get_stats)(struct net_device *dev);
> +	struct net_device_stats	stats;
>  
>  #ifdef CONFIG_WIRELESS_EXT
>  	/* List of functions to handle Wireless Extensions (instead of ioctl).
> diff -r 1ccab0a087b7 net/core/dev.c
> --- a/net/core/dev.c	Tue Mar 27 13:46:10 2007 +1000
> +++ b/net/core/dev.c	Tue Mar 27 14:30:05 2007 +1000
> @@ -825,7 +825,6 @@ static int default_rebuild_header(struct
>  	return 1;
>  }
>  
> -
>  /**
>   *	dev_open	- prepare an interface for use.
>   *	@dev:	device to open
> @@ -2120,9 +2119,9 @@ void dev_seq_stop(struct seq_file *seq, 
>  
>  static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
>  {
> -	if (dev->get_stats) {
> -		struct net_device_stats *stats = dev->get_stats(dev);
> -
> +	struct net_device_stats *stats = dev->get_stats(dev);
> +
> +	if (stats) {
>  		seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
>  				"%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
>  			   dev->name, stats->rx_bytes, stats->rx_packets,
> @@ -3146,6 +3145,13 @@ out:
>  	mutex_unlock(&net_todo_run_mutex);
>  }
>  
> +static struct net_device_stats *maybe_internal_stats(struct net_device *dev)
> +{
> +	if (dev->features & NETIF_F_INTERNAL_STATS)
> +		return &dev->stats;
> +	return NULL;
> +}
> +
>  /**
>   *	alloc_netdev - allocate network device
>   *	@sizeof_priv:	size of private data to allocate space for
> @@ -3181,6 +3187,7 @@ struct net_device *alloc_netdev(int size
>  	if (sizeof_priv)
>  		dev->priv = netdev_priv(dev);
>  
> +	dev->get_stats = maybe_internal_stats;
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
>
>
>   
It would make sense to do it per-cpu and 64 bit for the non-error counters.


