From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [net,v2] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Tue, 20 Jun 2017 11:15:53 +0800
Message-ID: <59489369.8000309@rock-chips.com>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, dsahern@gmail.com,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>
To: WANG Cong <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.134]:37053 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdFTDQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:16:11 -0400
In-Reply-To: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

i hit some warnings when testing this patch on my local 4.4 kernel(arm64 
chromebook) with KASAN & SLUB_DEBUG:

[    9.919374] BUG: KASAN: use-after-free in 
ip6_route_dev_notify+0x194/0x2bc at addr ffffffc0c9d4e480
[    9.928469] Read of size 4 by task kworker/u12:3/124
[    9.933463] 
=============================================================================
[    9.941686] BUG kmalloc-1024 (Not tainted): kasan: bad access detected
...
[   10.741337] Workqueue: netns cleanup_net
[   10.745300] Call trace:
[   10.747776] [<ffffffc00020b30c>] dump_backtrace+0x0/0x200
[   10.753203] [<ffffffc00020b530>] show_stack+0x24/0x30
[   10.758284] [<ffffffc000602948>] dump_stack+0xa8/0xcc
[   10.763364] [<ffffffc0003d8e90>] print_trailer+0x158/0x168
[   10.768877] [<ffffffc0003d927c>] object_err+0x4c/0x5c
[   10.773956] [<ffffffc0003dfef0>] kasan_report+0x338/0x4ec
[   10.779383] [<ffffffc0003df05c>] __asan_load4+0x7c/0x84
[   10.784640] [<ffffffc000c65d60>] ip6_route_dev_notify+0x194/0x2bc
[   10.790763] [<ffffffc000258550>] notifier_call_chain+0x78/0xc0
[   10.796625] [<ffffffc0002586f4>] raw_notifier_call_chain+0x3c/0x4c
[   10.802835] [<ffffffc000b06118>] call_netdevice_notifiers_info+0x8c/0x9c
[   10.809564] [<ffffffc000b061c4>] call_netdevice_notifiers+0x9c/0xcc
[   10.815859] [<ffffffc000b146c8>] netdev_run_todo+0x224/0x3f0
[   10.821547] [<ffffffc000b25054>] rtnl_unlock+0x14/0x1c
[   10.826716] [<ffffffc000b0f6e0>] default_device_exit_batch+0x258/0x2a0
[   10.833269] [<ffffffc000afe060>] ops_exit_list+0x74/0xdc
[   10.838608] [<ffffffc000affd00>] cleanup_net+0x290/0x400


and also this:
[   11.607268] BUG kmalloc-1024 (Tainted: G    B          ): Poison 
overwritten
[   11.607270] 
-----------------------------------------------------------------------------
[   11.607274] INFO: 0xffffffc0c9d4e478-0xffffffc0c9d4e478. First byte 
0x67 instead of 0x6b
...
[   11.607679] [<ffffffc0003d8e90>] print_trailer+0x158/0x168
[   11.607683] [<ffffffc0003d8f78>] check_bytes_and_report+0xd8/0x13c
[   11.607688] [<ffffffc0003d93c0>] check_object+0x134/0x230
[   11.607692] [<ffffffc0003da7ac>] alloc_debug_processing+0x104/0x178
[   11.607697] [<ffffffc0003dab0c>] ___slab_alloc.constprop.26+0x2ec/0x434
[   11.607702] [<ffffffc0003dac9c>] 
__slab_alloc.isra.23.constprop.25+0x48/0x5c
[   11.607707] [<ffffffc0003deabc>] __kmalloc_track_caller+0x12c/0x338



it looks like the "struct inet6_dev" been touched after freed, and 
refcnt changed(0xffffffc0c9d4e478, 376 bytes of struct inet6_dev) when 
reusing this memory.




i think the problem would be we are assuming NETDEV_REGISTER and 
NETDEV_UNREGISTER be paired in ip6_route_dev_notify:

 > +	if (event == NETDEV_REGISTER) {
 >   		net->ipv6.ip6_null_entry->dst.dev = dev;
 >   		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
 >   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 > @@ -3718,6 +3721,12 @@ static int ip6_route_dev_notify(struct 
notifier_block *this,
 >   		net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
 >   		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
 >   #endif
 > +	 } else if (event == NETDEV_UNREGISTER) {
 > +		in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev);
 > +#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 > +		in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev);
 > +		in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev);
 > +#endif
 >   	}

but actually they are not guaranteed to be paired:

the netdev_run_todo(see the first dump stack above) would call 
netdev_wait_allrefs to rebroadcast unregister notification multiple 
times, unless timed out or all of the "struct net_device"'s refs released:

  * This is called when unregistering network devices.
  *
  * Any protocol or device that holds a reference should register
  * for netdevice notification, and cleanup and put back the
  * reference if they receive an UNREGISTER event.
  * We can get stuck here if buggy protocols don't correctly
  * call dev_put.
  */
static void netdev_wait_allrefs(struct net_device *dev)
{
...
         while (refcnt != 0) {
                 if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
                         rtnl_lock();

                         /* Rebroadcast unregister notification */
                         call_netdevice_notifiers(NETDEV_UNREGISTER, dev);

                         __rtnl_unlock();
                         rcu_barrier();
                         rtnl_lock();

 
call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);



On 05/05/2017 01:36 AM, WANG Cong wrote:
> For each netns (except init_net), we initialize its null entry
> in 3 places:
>
> 1) The template itself, as we use kmemdup()
> 2) Code around dst_init_metrics() in ip6_route_net_init()
> 3) ip6_route_dev_notify(), which is supposed to initialize it after
>     loopback registers
>
> Unfortunately the last one still happens in a wrong order because
> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
> net->loopback_dev's idev, so we have to do that after we add
> idev to it. However, this notifier has priority == 0 same as
> ipv6_dev_notf, and ipv6_dev_notf is registered after
> ip6_route_dev_notifier so it is called actually after
> ip6_route_dev_notifier.
>
> Fix it by picking a smaller priority for ip6_route_dev_notifier.
> Also, we have to release the refcnt accordingly when unregistering
> loopback_dev because device exit functions are called before subsys
> exit functions.
>
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Acked-by: David Ahern <dsahern@gmail.com>
> Tested-by: David Ahern <dsahern@gmail.com>
> ---
>   include/net/addrconf.h |  2 ++
>   net/ipv6/addrconf.c    |  1 +
>   net/ipv6/route.c       | 13 +++++++++++--
>   3 files changed, 14 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 1aeb25d..6c0ee3c 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -20,6 +20,8 @@
>   #define ADDRCONF_TIMER_FUZZ		(HZ / 4)
>   #define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
>
> +#define ADDRCONF_NOTIFY_PRIORITY	0
> +
>   #include <linux/in.h>
>   #include <linux/in6.h>
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 77a4bd5..8d297a7 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3548,6 +3548,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>    */
>   static struct notifier_block ipv6_dev_notf = {
>   	.notifier_call = addrconf_notify,
> +	.priority = ADDRCONF_NOTIFY_PRIORITY,
>   };
>
>   static void addrconf_type_change(struct net_device *dev, unsigned long event)
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 2f11366..dc61b0b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -3709,7 +3709,10 @@ static int ip6_route_dev_notify(struct notifier_block *this,
>   	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>   	struct net *net = dev_net(dev);
>
> -	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
> +	if (!(dev->flags & IFF_LOOPBACK))
> +		return NOTIFY_OK;
> +
> +	if (event == NETDEV_REGISTER) {
>   		net->ipv6.ip6_null_entry->dst.dev = dev;
>   		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
>   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
> @@ -3718,6 +3721,12 @@ static int ip6_route_dev_notify(struct notifier_block *this,
>   		net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
>   		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
>   #endif
> +	 } else if (event == NETDEV_UNREGISTER) {
> +		in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev);
> +#ifdef CONFIG_IPV6_MULTIPLE_TABLES
> +		in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev);
> +		in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev);
> +#endif
>   	}
>
>   	return NOTIFY_OK;
> @@ -4024,7 +4033,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
>
>   static struct notifier_block ip6_route_dev_notifier = {
>   	.notifier_call = ip6_route_dev_notify,
> -	.priority = 0,
> +	.priority = ADDRCONF_NOTIFY_PRIORITY - 10,
>   };
>
>   void __init ip6_route_init_special_entries(void)
>
