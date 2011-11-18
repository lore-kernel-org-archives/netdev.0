From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure (v2)
Date: Thu, 17 Nov 2011 19:17:28 -0800
Message-ID: <4EC5CE48.8020603@intel.com>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com> <1321566472-28969-1-git-send-email-nhorman@tuxdriver.com> <1321566472-28969-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48080 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab1KRDR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 22:17:29 -0500
In-Reply-To: <1321566472-28969-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2011 1:47 PM, Neil Horman wrote:
> This patch adds in the infrastructure code to create the network priority
> cgroup.  The cgroup, in addition to the standard processes file creates two
> control files:
> 
> 1) prioidx - This is a read-only file that exports the index of this cgroup.
> This is a value that is both arbitrary and unique to a cgroup in this subsystem,
> and is used to index the per-device priority map
> 
> 2) priomap - This is a writeable file.  On read it reports a table of 2-tuples
> <name:priority> where name is the name of a network interface and priority is
> indicates the priority assigned to frames egresessing on the named interface and
> originating from a pid in this cgroup
> 
> This cgroup allows for skb priority to be set prior to a root qdisc getting
> selected. This is benenficial for DCB enabled systems, in that it allows for any
> application to use dcb configured priorities so without application modification
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Robert Love <robert.w.love@intel.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---

one more nit... can we convert the rcu_dereference() into rtnl_dereference()
where it is relevant?

/**
 * rtnl_dereference - fetch RCU pointer when updates are prevented by RTNL
 * @p: The pointer to read, prior to dereferencing
 *
 * Return the value of the specified RCU-protected pointer, but omit
 * both the smp_read_barrier_depends() and the ACCESS_ONCE(), because
 * caller holds RTNL.
 */
#define rtnl_dereference(p)                                     \
        rcu_dereference_protected(p, lockdep_rtnl_is_held())

[...]

> +
> +static void extend_netdev_table(struct net_device *dev, u32 new_len)
> +{
> +       size_t new_size = sizeof(struct netprio_map) +
> +                          ((sizeof(u32) * new_len));
> +       struct netprio_map *new_priomap = kzalloc(new_size, GFP_KERNEL);
> +       struct netprio_map *old_priomap;
> +       int i;
> +
> +       old_priomap  = rcu_dereference(dev->priomap);
> +

This could be rtnl_dereference(dev->priomap) to annotate that we always
have the rtnl lock here.

> +       if (!new_priomap) {
> +               printk(KERN_WARNING "Unable to alloc new priomap!\n");
> +               return;
> +       }
> +
> +       for (i = 0;
> +            old_priomap && (i < old_priomap->priomap_len);
> +            i++)
> +               new_priomap->priomap[i] = old_priomap->priomap[i];
> +
> +       new_priomap->priomap_len = new_len;
> +
> +       rcu_assign_pointer(dev->priomap, new_priomap);
> +       if (old_priomap)
> +               kfree_rcu(old_priomap, rcu);
> +}
> +
> +static void update_netdev_tables(void)
> +{
> +       struct net_device *dev;
> +       u32 max_len = atomic_read(&max_prioidx);
> +       struct netprio_map *map;
> +
> +       rtnl_lock();
          ^^^^^^^^^^^
> +
> +
> +       for_each_netdev(&init_net, dev) {
> +               map = rcu_dereference(dev->priomap);

same here rtnl_dereference(dev->priomap);

> +               if ((!map) ||
> +                   (map->priomap_len < max_len))
> +                       extend_netdev_table(dev, max_len);
> +       }
> +
> +       rtnl_unlock();
> +}
> +
> +static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
> +                                                struct cgroup *cgrp)
> +{
> +       struct cgroup_netprio_state *cs;
> +       int ret;
> +
> +       cs = kzalloc(sizeof(*cs), GFP_KERNEL);
> +       if (!cs)
> +               return ERR_PTR(-ENOMEM);
> +
> +       if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx) {
> +               kfree(cs);
> +               return ERR_PTR(-EINVAL);
> +       }
> +
> +       ret = get_prioidx(&cs->prioidx);
> +       if (ret != 0) {
> +               printk(KERN_WARNING "No space in priority index array\n");
> +               kfree(cs);
> +               return ERR_PTR(ret);
> +       }
> +
> +       return &cs->css;
> +}
> +
> +static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +       struct cgroup_netprio_state *cs;
> +       struct net_device *dev;
> +       struct netprio_map *map;
> +
> +       cs = cgrp_netprio_state(cgrp);
> +       rtnl_lock();
> +       for_each_netdev(&init_net, dev) {
> +               map = rcu_dereference(dev->priomap);

map = rtnl_dereference(dev->priomap)

> +               if (map)
> +                       map->priomap[cs->prioidx] = 0;
> +       }
> +       rtnl_unlock();
> +       put_prioidx(cs->prioidx);
> +       kfree(cs);
> +}
> +
> +static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
> +{
> +       return (u64)cgrp_netprio_state(cgrp)->prioidx;
> +}
> +
> +static int read_priomap(struct cgroup *cont, struct cftype *cft,
> +                       struct cgroup_map_cb *cb)
> +{
> +       struct net_device *dev;
> +       u32 prioidx = cgrp_netprio_state(cont)->prioidx;
> +       u32 priority;
> +       struct netprio_map *map;
> +
> +       rcu_read_lock();
> +
> +       for_each_netdev_rcu(&init_net, dev) {
> +               map = rcu_dereference(dev->priomap);
> +               priority = map ? map->priomap[prioidx] : 0;
> +               cb->fill(cb, dev->name, priority);
> +       }
> +       rcu_read_unlock();
> +       return 0;
> +}
> +

[...]

> +static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +       return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
> +}
> +
> +static int netprio_device_event(struct notifier_block *unused,
> +                               unsigned long event, void *ptr)
> +{
> +       struct net_device *dev = ptr;
> +       struct netprio_map *old;
> +       u32 max_len = atomic_read(&max_prioidx);
> +
> +       old = rcu_dereference_protected(dev->priomap, 1);

This is protected because of the rtnl lock so use,

old = rtnl_dereference(dev->priomap);

> +       /*
> +        * Note this is called with rtnl_lock held so we have update side
> +        * protection on our rcu assignments
> +        */
> +
> +       switch (event) {
> +
> +       case NETDEV_REGISTER:
> +               if (max_len)
> +                       extend_netdev_table(dev, max_len);
> +               break;
> +       case NETDEV_UNREGISTER:
> +               rcu_assign_pointer(dev->priomap, NULL);
> +               if (old)
> +                       kfree_rcu(old, rcu);
> +               break;
> +       }
> +       return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block netprio_device_notifier = {
> +       .notifier_call = netprio_device_event
> +};
> +

I can roll an update if you want, just let me know.

Thanks,
John
