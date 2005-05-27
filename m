From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 08:50:55 -0700
Message-ID: <20050527085055.79da3d75@dxpl.pdx.osdl.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 May 2005 14:36:22 -0700
Mitch Williams <mitch.a.williams@intel.com> wrote:

> The following patch (which applies to 2.6.12rc4) adds a new sysctl
> parameter called 'netdev_packet_weight'.  This parameter controls how many
> backlog work units each RX packet is worth.
> 
> With the parameter set to 0 (the default), NAPI polling works exactly as
> it does today:  each packet is worth one backlog work unit, and the
> maximum number of received packets that will be processed in any given
> softirq is controlled by the 'netdev_max_backlog' parameter.
> 
> By setting the netdev_packet_weight to a nonzero value, we make each
> packet worth more than one backlog work unit.  Since it's a shift value, a
> setting of 1 makes each packet worth 2 work units, a setting of 2 makes
> each packet worth 4 units, etc.  Under normal circumstances you would
> never use a value higher than 3, though 4 might work for Gigabit and 10
> Gigabit networks.
> 
> By increasing the packet weight, we accomplish two things:  first, we
> cause the individual NAPI RX loops in each driver to process fewer
> packets.  This means that they will free up RX resources to the hardware
> more often, which reduces the possibility of dropped packets.  Second, it
> shortens the total time spent in the NAPI softirq, which can free the CPU
> to handle other tasks more often, thus reducing overall latency.

Rather than weighting each packet differently, why not just reduce the upper
bound on number of packets. There are several patches is in my 2.6.12-rc5-tcp3
that make this easier:
----
http://developer.osdl.org/shemminger/patches/2.6.12-rc5-tcp3/patches/bigger-backlog.patch
Separate out the two uses of netdev_max_backlog. One controls the upper
bound on packets processed per softirq, the new name for this is netdev_max_weight;
the other controls the limit on packets queued via netif_rx

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


Index: linux-2.6.12-rc4-tcp2/net/core/sysctl_net_core.c
===================================================================
--- linux-2.6.12-rc4-tcp2.orig/net/core/sysctl_net_core.c
+++ linux-2.6.12-rc4-tcp2/net/core/sysctl_net_core.c
@@ -13,6 +13,7 @@
 #ifdef CONFIG_SYSCTL
 
 extern int netdev_max_backlog;
+extern int netdev_max_weight;
 extern int weight_p;
 extern int net_msg_cost;
 extern int net_msg_burst;
@@ -137,6 +138,14 @@ ctl_table core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_CORE_MAX_WEIGHT,
+		.procname	= "netdev_max_weight",
+		.data		= &netdev_max_weight,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
Index: linux-2.6.12-rc4-tcp2/net/core/dev.c
===================================================================
--- linux-2.6.12-rc4-tcp2.orig/net/core/dev.c
+++ linux-2.6.12-rc4-tcp2/net/core/dev.c
@@ -1334,7 +1334,8 @@ out:
 			Receiver routines
   =======================================================================*/
 
-int netdev_max_backlog = 300;
+int netdev_max_backlog = 10000;
+int netdev_max_weight  = 500;
 int weight_p = 64;            /* old backlog weight */
 
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
@@ -1682,8 +1683,7 @@ static void net_rx_action(struct softirq
 {
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
-	int budget = netdev_max_backlog;
-
+	int budget = netdev_max_weight;
 	
 	local_irq_disable();
 
Index: linux-2.6.12-rc4-tcp2/include/linux/sysctl.h
===================================================================
--- linux-2.6.12-rc4-tcp2.orig/include/linux/sysctl.h
+++ linux-2.6.12-rc4-tcp2/include/linux/sysctl.h
@@ -242,6 +242,7 @@ enum
 	NET_CORE_MOD_CONG=16,
 	NET_CORE_DEV_WEIGHT=17,
 	NET_CORE_SOMAXCONN=18,
+	NET_CORE_MAX_WEIGHT=19,
 };
 
 /* /proc/sys/net/ethernet */

----
http://developer.osdl.org/shemminger/patches/2.6.12-rc5-tcp3/patches/fix-weightp.patch
Changing the dev_weight sysctl parameter has no effect because the weight
of the backlog devices is set during initialization and never changed.
Fix this by propogating changes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


Index: linux-2.6.12-rc4-tcp2/net/core/dev.c
===================================================================
--- linux-2.6.12-rc4-tcp2.orig/net/core/dev.c
+++ linux-2.6.12-rc4-tcp2/net/core/dev.c
@@ -1636,6 +1636,7 @@ static int process_backlog(struct net_de
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
 
+	backlog_dev->weight = weight_p;
 	for (;;) {
 		struct sk_buff *skb;
 		struct net_device *dev;
