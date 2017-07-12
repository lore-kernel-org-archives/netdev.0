From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v1 net-next 1/5] drop_monitor: import netnamespace
 framework
Date: Wed, 12 Jul 2017 09:37:48 -0400
Message-ID: <20170712133748.GA21036@hmswarspite.think-freely.org>
References: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        zhangjunweimartin@didichuxing.com
To: martinbj2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53734 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdGLNiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 09:38:08 -0400
Content-Disposition: inline
In-Reply-To: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 12, 2017 at 06:40:49PM +0800, martinbj2008@gmail.com wrote:
> From: martin Zhang <zhangjunweimartin@didichuxing.com>
> 
> This is a serial patch for drop monitor, in order to support net namespace.
> 
> Import two struct to support net ns:
> 
> 1. struct per_ns_dm_cb:
>   Just like its name, it is used in per net ns.
> 
>   In this patch it is empty, but in following patch, these field will be added.
>   a. trace_state: every net ns has a switch to indicate the trace state.
>   b. ns_dm_mutex: the mutex will only work and keep exclusive operatons in a net ns.
>   c. hw_stats_list: monitor for NAPI of net device.
> 
> 2. ns_pcpu_dm_data
>    It is used to replace per_cpu_dm_data under per net ns.
> 
>    per_cpu_dm_data will only keep the dm_alert_work, and the other field
> will be moved to ns_pcpu_dm_data. They do same thing just like current
> code, and the only difference is under per net ns.
> 
>   Keep there is a work under percpu, to send alter netlink message.
> 
> Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
> ---
> The dropwatch is a very useful tool to diagnose network problem,
> which give us greate help.
> Dropwatch could not work under container(net namespace).
> It is a pitty, so let it support net ns.
> 
Sorry, Im having a hard time wrapping my head around this.  Why exactly is it
that dropwatch won't work in a namespaced environment?  IIRC, the kfree
tracepoints are namespace agnostic, and so running dropwatch anywhere should
result in seeing drops in all namespaces.  I grant that perhaps it would be nice
to filter on a namespace, but it should all 'just work' for some definition of
the term, no?

Neil

>  net/core/drop_monitor.c | 41 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 41 insertions(+)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 70ccda2..6a75e04 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -32,6 +32,10 @@
>  #include <trace/events/napi.h>
>  
>  #include <asm/unaligned.h>
> +#include <net/sock.h>
> +#include <net/net_namespace.h>
> +#include <net/netns/generic.h>
> +#include <linux/smp.h>
>  
>  #define TRACE_ON 1
>  #define TRACE_OFF 0
> @@ -41,6 +45,13 @@
>   * and the work handle that will send up
>   * netlink alerts
>   */
> +
> +struct ns_pcpu_dm_data {
> +};
> +
> +struct per_ns_dm_cb {
> +};
> +
>  static int trace_state = TRACE_OFF;
>  static DEFINE_MUTEX(trace_state_mutex);
>  
> @@ -59,6 +70,7 @@ struct dm_hw_stat_delta {
>  	unsigned long last_drop_val;
>  };
>  
> +static int dm_net_id __read_mostly;
>  static struct genl_family net_drop_monitor_family;
>  
>  static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
> @@ -382,6 +394,33 @@ static int dropmon_net_event(struct notifier_block *ev_block,
>  	.notifier_call = dropmon_net_event
>  };
>  
> +static int __net_init dm_net_init(struct net *net)
> +{
> +	struct per_ns_dm_cb *ns_dm_cb;
> +
> +	ns_dm_cb = net_generic(net, dm_net_id);
> +	if (!ns_dm_cb)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void __net_exit dm_net_exit(struct net *net)
> +{
> +	struct per_ns_dm_cb *ns_dm_cb;
> +
> +	ns_dm_cb = net_generic(net, dm_net_id);
> +	if (!ns_dm_cb)
> +		return;
> +}
> +
> +static struct pernet_operations dm_net_ops = {
> +	.init = dm_net_init,
> +	.exit = dm_net_exit,
> +	.id   = &dm_net_id,
> +	.size = sizeof(struct per_ns_dm_cb),
> +};
> +
>  static int __init init_net_drop_monitor(void)
>  {
>  	struct per_cpu_dm_data *data;
> @@ -393,6 +432,7 @@ static int __init init_net_drop_monitor(void)
>  		pr_err("Unable to store program counters on this arch, Drop monitor failed\n");
>  		return -ENOSPC;
>  	}
> +	rc = register_pernet_subsys(&dm_net_ops);
>  
>  	rc = genl_register_family(&net_drop_monitor_family);
>  	if (rc) {
> @@ -441,6 +481,7 @@ static void exit_net_drop_monitor(void)
>  	 * or pending schedule calls
>  	 */
>  
> +	unregister_pernet_subsys(&dm_net_ops);
>  	for_each_possible_cpu(cpu) {
>  		data = &per_cpu(dm_cpu_data, cpu);
>  		del_timer_sync(&data->send_timer);
> -- 
> 1.8.3.1
> 
> 
