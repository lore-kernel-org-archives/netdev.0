From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: NAPI packet weighting patch
Date: Thu, 26 May 2005 18:05:02 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450BF67@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Are the systems that don't see any difference slower (older?) machines?
I'm wondering what could be the cause of this.  It seems like it should
always work.  I think we need to figure out why there is no difference
on some systems.

Just my 2 cents.

Cheers,
John


> -----Original Message-----
> From: Mitch Williams [mailto:mitch.a.williams@intel.com] 
> Sent: Thursday, May 26, 2005 2:36 PM
> To: netdev@oss.sgi.com
> Cc: Ronciak, John; Venkatesan, Ganesh; Brandeburg, Jesse
> Subject: RFC: NAPI packet weighting patch 
> 
> 
> The following patch (which applies to 2.6.12rc4) adds a new sysctl
> parameter called 'netdev_packet_weight'.  This parameter 
> controls how many
> backlog work units each RX packet is worth.
> 
> With the parameter set to 0 (the default), NAPI polling works 
> exactly as
> it does today:  each packet is worth one backlog work unit, and the
> maximum number of received packets that will be processed in any given
> softirq is controlled by the 'netdev_max_backlog' parameter.
> 
> By setting the netdev_packet_weight to a nonzero value, we make each
> packet worth more than one backlog work unit.  Since it's a 
> shift value, a
> setting of 1 makes each packet worth 2 work units, a setting 
> of 2 makes
> each packet worth 4 units, etc.  Under normal circumstances you would
> never use a value higher than 3, though 4 might work for 
> Gigabit and 10
> Gigabit networks.
> 
> By increasing the packet weight, we accomplish two things:  first, we
> cause the individual NAPI RX loops in each driver to process fewer
> packets.  This means that they will free up RX resources to 
> the hardware
> more often, which reduces the possibility of dropped packets. 
>  Second, it
> shortens the total time spent in the NAPI softirq, which can 
> free the CPU
> to handle other tasks more often, thus reducing overall latency.
> 
> Performance tests in our lab have shown that tweaking this parameter,
> along with the netdev_max_backlog parameter, can provide significant
> performance increase -- greater than 100Mbps improvement -- 
> over default
> settings.  I tested with both e1000 and tg3 drivers and saw 
> improvement in
> both cases.  I did not see higher CPU utilization, even with 
> the increased
> throughput.
> 
> The caveat, of course, is that different systems and network
> configurations require different settings.  On the other hand, that's
> really no different than what we see with the max_backlog 
> parameter today.
> On some systems neither parameter makes any difference.
> 
> Still, we feel that there is value to having this in the 
> kernel.  Please
> test and comment as you have time available.
> 
> Thanks!
> -Mitch Williams
> mitch.a.williams@intel.com
> 
> 
> 
> 
> diff -urpN -x dontdiff 
> rc4-clean/Documentation/filesystems/proc.txt 
> linux-2.6.12-rc4/Documentation/filesystems/proc.txt
> --- rc4-clean/Documentation/filesystems/proc.txt	
> 2005-05-18 16:35:43.000000000 -0700
> +++ linux-2.6.12-rc4/Documentation/filesystems/proc.txt	
> 2005-05-19 11:16:10.000000000 -0700
> @@ -1378,7 +1378,13 @@ netdev_max_backlog
>  ------------------
> 
>  Maximum number  of  packets,  queued  on  the  INPUT  side, 
> when the interface
> -receives packets faster than kernel can process them.
> +receives packets faster than kernel can process them.  This 
> is also the
> +maximum number of packets handled in a single softirq under NAPI.
> +
> +netdev_packet_weight
> +--------------------
> +The value, in netdev_max_backlog unit, of each received 
> packet.  This is a
> +shift value, and should be set no higher than 3.
> 
>  optmem_max
>  ----------
> diff -urpN -x dontdiff rc4-clean/include/linux/sysctl.h 
> linux-2.6.12-rc4/include/linux/sysctl.h
> --- rc4-clean/include/linux/sysctl.h	2005-05-18 
> 16:36:06.000000000 -0700
> +++ linux-2.6.12-rc4/include/linux/sysctl.h	2005-05-18 
> 16:44:07.000000000 -0700
> @@ -242,6 +242,7 @@ enum
>  	NET_CORE_MOD_CONG=16,
>  	NET_CORE_DEV_WEIGHT=17,
>  	NET_CORE_SOMAXCONN=18,
> +	NET_CORE_PACKET_WEIGHT=19,
>  };
> 
>  /* /proc/sys/net/ethernet */
> diff -urpN -x dontdiff rc4-clean/net/core/dev.c 
> linux-2.6.12-rc4/net/core/dev.c
> --- rc4-clean/net/core/dev.c	2005-05-18 16:36:07.000000000 -0700
> +++ linux-2.6.12-rc4/net/core/dev.c	2005-05-19 
> 11:16:57.000000000 -0700
> @@ -1352,6 +1352,7 @@ out:
>    
> ==============================================================
> =========*/
> 
>  int netdev_max_backlog = 300;
> +int netdev_packet_weight = 0; /* each packet is worth 1 
> backlog unit */
>  int weight_p = 64;            /* old backlog weight */
>  /* These numbers are selected based on intuition and some
>   * experimentatiom, if you have more scientific way of doing this
> @@ -1778,6 +1779,7 @@ static void net_rx_action(struct softirq
>  	struct softnet_data *queue = &__get_cpu_var(softnet_data);
>  	unsigned long start_time = jiffies;
>  	int budget = netdev_max_backlog;
> +	int budget_temp;
> 
> 
>  	local_irq_disable();
> @@ -1793,21 +1795,22 @@ static void net_rx_action(struct softirq
>  		dev = list_entry(queue->poll_list.next,
>  				 struct net_device, poll_list);
>  		netpoll_poll_lock(dev);
> -
> -		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
> +		budget_temp = budget;
> +		if (dev->quota <= 0 || dev->poll(dev, &budget_temp)) {
>  			netpoll_poll_unlock(dev);
>  			local_irq_disable();
>  			list_del(&dev->poll_list);
>  			list_add_tail(&dev->poll_list, 
> &queue->poll_list);
>  			if (dev->quota < 0)
> -				dev->quota += dev->weight;
> +				dev->quota += dev->weight >> 
> netdev_packet_weight;
>  			else
> -				dev->quota = dev->weight;
> +				dev->quota = dev->weight >> 
> netdev_packet_weight;
>  		} else {
>  			netpoll_poll_unlock(dev);
>  			dev_put(dev);
>  			local_irq_disable();
>  		}
> +		budget -= (budget - budget_temp) << 
> netdev_packet_weight;
>  	}
>  out:
>  	local_irq_enable();
> diff -urpN -x dontdiff rc4-clean/net/core/sysctl_net_core.c 
> linux-2.6.12-rc4/net/core/sysctl_net_core.c
> --- rc4-clean/net/core/sysctl_net_core.c	2005-03-01 
> 23:38:03.000000000 -0800
> +++ linux-2.6.12-rc4/net/core/sysctl_net_core.c	
> 2005-05-18 16:44:09.000000000 -0700
> @@ -13,6 +13,7 @@
>  #ifdef CONFIG_SYSCTL
> 
>  extern int netdev_max_backlog;
> +extern int netdev_packet_weight;
>  extern int weight_p;
>  extern int no_cong_thresh;
>  extern int no_cong;
> @@ -91,6 +92,14 @@ ctl_table core_table[] = {
>  		.proc_handler	= &proc_dointvec
>  	},
>  	{
> +		.ctl_name	= NET_CORE_PACKET_WEIGHT,
> +		.procname	= "netdev_packet_weight",
> +		.data		= &netdev_packet_weight,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec
> +	},
> +	{
>  		.ctl_name	= NET_CORE_MAX_BACKLOG,
>  		.procname	= "netdev_max_backlog",
>  		.data		= &netdev_max_backlog,
> 
