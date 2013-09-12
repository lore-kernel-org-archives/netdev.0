From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Thu, 12 Sep 2013 13:06:53 -0700
Message-ID: <87txhp249u.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35363 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208Ab3ILUHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 16:07:05 -0400
In-Reply-To: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	(Francesco Ruggeri's message of "Thu, 12 Sep 2013 10:59:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> Resending.

To summarize:

In netdev_run_todo, netdev_wait_allrefs, call_netdevice_notifiers you
have observed a situation where dev_net(dev) was an invalid pointer.

My first impression is that we probably just want to remove the repeated
call to call_netdevice_notifiers, that happens after 1 second of
waiting.

Your suggested patch below doesn't have a prayer of working, as it only
decreases the device reference count after the loop to wait for the
reference count to go to zero.

Your patch modified to grab a count on the network namespace the device
references and not the device itself might make sense, but that runs the
risk of incrementing the network namespace counts after the network
namespace is down.

Simply not rerunning call_netdevice_notifiers seems like the proper
approach to fix this.

So I think the fix will probably just be:

David, Eric, do any of you know why we have this netdevice notfier
rebroadcast?

diff --git a/net/core/dev.c b/net/core/dev.c
index a3d8d44..e6bd828 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5556,42 +5556,15 @@ EXPORT_SYMBOL(netdev_refcnt_read);
  */
 static void netdev_wait_allrefs(struct net_device *dev)
 {
-       unsigned long rebroadcast_time, warning_time;
+       unsigned long warning_time;
        int refcnt;
 
        linkwatch_forget_dev(dev);
 
-       rebroadcast_time = warning_time = jiffies;
+       warning_time = jiffies;
        refcnt = netdev_refcnt_read(dev);
 
        while (refcnt != 0) {
-               if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
-                       rtnl_lock();
-
-                       /* Rebroadcast unregister notification */
-                       call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-
-                       __rtnl_unlock();
-                       rcu_barrier();
-                       rtnl_lock();
-
-                       call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-                       if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
-                                    &dev->state)) {
-                               /* We must not have linkwatch events
-                                * pending on unregister. If this
-                                * happens, we simply run the queue
-                                * unscheduled, resulting in a noop
-                                * for this device.
-                                */
-                               linkwatch_run_queue();
-                       }
-
-                       __rtnl_unlock();
-
-                       rebroadcast_time = jiffies;
-               }
-
                msleep(250);
 
                refcnt = netdev_refcnt_read(dev);

> There is a race condition when removing a net_device while its net namespace
> is also being removed.
> This can result in a crash or other unpredictable behavior.
> This is a sample scenario with veth, but the same applies to other virtual
> devices such as vlan and macvlan.
> veth pair v0-v1 is created, with v0 in namespace ns0 and v1 in ns1.
> Process p0 deletes v0. v1 is also unregistered (in veth_dellink), so when p0
> gets to netdev_run_todo both v0 and v1 are in net_todo_list, and they have both
> been unlisted from their respective namespaces. If all references to v1 have not
> already been dropped then netdev_run_todo/netdev_wait_allrefs will call netdev
> notifiers for v1, releasing the rtnl lock between calls.
> Now process p1 removes namespace ns1. v1 will not prevent this from happening
> (in default_device_exit_batch) since it was already unlisted by p0.
> Next time p0 invokes the notifiers for v1 any notifiers that use dev_net(v1)
> will get a pointer to a namespace that has been or is being removed.
> Similar scenarios apply with v1 as a vlan or macvlan interface and v0 as its
> real device.
> We hit this problem in 3.4 with sequence fib_netdev_event, fib_disable_ip,
> rt_cache_flush, rt_cache_invalidate, inetpeer_invalidate_tree. That sequence no
> longer applies in later kernels, but unless we can guarantee that no
> NETDEV_UNREGISTER or NETDEV_UNREGISTER_FINAL handler accesses a net_device's
> dev_net(dev) then there is a vulnerability (this happens for example with
> NETDEV_UNREGISTER_FINAL in dst_dev_event/dst_ifdown).
> Commit 0115e8e3 later made things better by reducing the chances of this
> happening, but the underlying problem still seems to be there.
> I would like to get some feedback on this patch.
> The idea is to take a reference to the loopback_dev of a net_device's
> namespace (which is always the last net_device to be removed when a namespace
> is destroyed) when the net_device is unlisted, and release it when the
> net_device is disposed of.
> To avoid deadlocks in cleanup_net all loopback_devs are queued at the end
> of net_todo_list.
>
> Tested on Linux 3.4.
>
> Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
> ---
>  net/core/dev.c |   30 +++++++++++++++++++++++++++++-
>  1 files changed, 29 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 26755dd..da2fd78 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -225,10 +225,14 @@ static void list_netdevice(struct net_device *dev)
>  }
>  
>  /* Device list removal
> + * Take a reference to dev_net(dev)->loopback_dev, so dev_net(dev)
> + * will not be freed until we are done with dev.
>   * caller must respect a RCU grace period before freeing/reusing dev
>   */
>  static void unlist_netdevice(struct net_device *dev)
>  {
> +	struct net_device *loopback_dev = dev_net(dev)->loopback_dev;
> +
>  	ASSERT_RTNL();
>  
>  	/* Unlink dev from the device chain */
> @@ -238,9 +242,23 @@ static void unlist_netdevice(struct net_device *dev)
>  	hlist_del_rcu(&dev->index_hlist);
>  	write_unlock_bh(&dev_base_lock);
>  
> +	if (dev != loopback_dev)
> +		dev_hold(loopback_dev);
> +
>  	dev_base_seq_inc(dev_net(dev));
>  }
>  
> +/**
> + * Called when a net_device that has been previously unlisted from a net
> + * namespace is disposed of.
> + */
> +static inline void unlist_netdevice_done(struct net_device *dev)
> +{
> +	struct net_device *loopback_dev = dev_net(dev)->loopback_dev;
> +	if (dev != loopback_dev)
> +		dev_put(loopback_dev);
> +}
> +
>  /*
>   *	Our notifier list
>   */
> @@ -5009,10 +5027,17 @@ static int dev_new_index(struct net *net)
>  
>  /* Delayed registration/unregisteration */
>  static LIST_HEAD(net_todo_list);
> +static struct list_head *first_loopback_dev = &net_todo_list;
>  
>  static void net_set_todo(struct net_device *dev)
>  {
> -	list_add_tail(&dev->todo_list, &net_todo_list);
> +	/* All loopback_devs go to end of net_todo_list. */
> +	if (dev == dev_net(dev)->loopback_dev) {
> +		list_add_tail(&dev->todo_list, &net_todo_list);
> +		if (first_loopback_dev == &net_todo_list)
> +			first_loopback_dev = &dev->todo_list;
> +	} else
> +		list_add_tail(&dev->todo_list, first_loopback_dev);
>  }
>  
>  static void rollback_registered_many(struct list_head *head)
> @@ -5641,6 +5666,7 @@ void netdev_run_todo(void)
>  
>  	/* Snapshot list, allow later requests */
>  	list_replace_init(&net_todo_list, &list);
> +	first_loopback_dev = &net_todo_list;
>  
>  	__rtnl_unlock();
>  
> @@ -5670,6 +5696,7 @@ void netdev_run_todo(void)
>  		on_each_cpu(flush_backlog, dev, 1);
>  
>  		netdev_wait_allrefs(dev);
> +		unlist_netdevice_done(dev);
>  
>  		/* paranoia */
>  		BUG_ON(netdev_refcnt_read(dev));
> @@ -6076,6 +6103,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
>  
>  	/* Actually switch the network namespace */
> +	unlist_netdevice_done(dev);
>  	dev_net_set(dev, net);
>  
>  	/* If there is an ifindex conflict assign a new one */
