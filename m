From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Wed, 18 Jul 2012 08:21:06 -0400
Message-ID: <20120718122106.GB25563@hmsreliant.think-freely.org>
References: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com>
 <5005CF5D.9070905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao feng <gaofeng@cn.fujitsu.com>, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5005CF5D.9070905@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 17, 2012 at 01:47:25PM -0700, John Fastabend wrote:
> On 7/12/2012 12:50 AM, Gao feng wrote:
> >there are some out of bound accesses in netprio cgroup.
> >
> >now before accessing the dev->priomap.priomap array,we only check
> >if the dev->priomap exist.and because we don't want to see
> >additional bound checkings in fast path, so we should make sure
> >that dev->priomap is null or array size of dev->priomap.priomap
> >is equal to max_prioidx + 1;
> >
> >so in write_priomap logic,we should call extend_netdev_table when
> >dev->priomap is null and dev->priomap.priomap_len < max_len.
> >and in cgrp_create->update_netdev_tables logic,we should call
> >extend_netdev_table only when dev->priomap exist and
> >dev->priomap.priomap_len < max_len.
> >
> >and it's not needed to call update_netdev_tables in write_priomap,
> >we can only allocate the net device's priomap which we change through
> >net_prio.ifpriomap.
> >
> >this patch also add a return value for update_netdev_tables &
> >extend_netdev_table, so when new_priomap is allocated failed,
> >write_priomap will stop to access the priomap,and return -ENOMEM
> >back to the userspace to tell the user what happend.
> >
> >Change From v3:
> >1. add rtnl protect when reading max_prioidx in write_priomap.
> >
> >2. only call extend_netdev_table when map->priomap_len < max_len,
> >    this will make sure array size of dev->map->priomap always
> >    bigger than any prioidx.
> >
> >3. add a function write_update_netdev_table to make codes clear.
> >
> >Change From v2:
> >1. protect extend_netdev_table by RTNL.
> >2. when extend_netdev_table failed,call dev_put to reduce device's refcount.
> >
> >Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >Cc: Neil Horman <nhorman@tuxdriver.com>
> >Cc: Eric Dumazet <edumazet@google.com>
> >---
> >  net/core/netprio_cgroup.c |   71 ++++++++++++++++++++++++++++++++++-----------
> >  1 files changed, 54 insertions(+), 17 deletions(-)
> >
> 
> [...]
> 
> >+
> >+static int update_netdev_tables(void)
> >+{
> >+	int ret = 0;
> >  	struct net_device *dev;
> >-	u32 max_len = atomic_read(&max_prioidx) + 1;
> >+	u32 max_len;
> >  	struct netprio_map *map;
> 
> 
> need to check if net subsystem is initialized before we try
> to use it here...
> 
> 	if (some_check)     -> need to lookup what this check is
> 		return ret;
> 
> >
> >  	rtnl_lock();
> >+	max_len = atomic_read(&max_prioidx) + 1;
> >  	for_each_netdev(&init_net, dev) {
> >  		map = rtnl_dereference(dev->priomap);
> >-		if ((!map) ||
> >-		    (map->priomap_len < max_len))
> >-			extend_netdev_table(dev, max_len);
> >+		/*
> >+		 * don't allocate priomap if we didn't
> >+		 * change net_prio.ifpriomap (map == NULL),
> >+		 * this will speed up skb_update_prio.
> >+		 */
> >+		if (map && map->priomap_len < max_len) {
> >+			ret = extend_netdev_table(dev, max_len);
> >+			if (ret < 0)
> >+				break;
> >+		}
> >  	}
> >  	rtnl_unlock();
> >+	return ret;
> >  }
> >
> >  static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
> >  {
> >  	struct cgroup_netprio_state *cs;
> >-	int ret;
> >+	int ret = -EINVAL;
> >
> >  	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
> >  	if (!cs)
> >  		return ERR_PTR(-ENOMEM);
> >
> >-	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx) {
> >-		kfree(cs);
> >-		return ERR_PTR(-EINVAL);
> >-	}
> >+	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx)
> >+		goto out;
> >
> >  	ret = get_prioidx(&cs->prioidx);
> >-	if (ret != 0) {
> >+	if (ret < 0) {
> >  		pr_warn("No space in priority index array\n");
> >-		kfree(cs);
> >-		return ERR_PTR(ret);
> >+		goto out;
> >+	}
> >+
> >+	ret = update_netdev_tables();
> >+	if (ret < 0) {
> >+		put_prioidx(cs->prioidx);
> >+		goto out;
> >  	}
> 
> Gao,
> 
> This introduces a null ptr dereference when netprio_cgroup is built
> into the kernel because update_netdev_tables() depends on init_net.
> However cgrp_create is being called by cgroup_init before
> do_initcalls() is called and before net_dev_init().
> 
> .John
> 
Not sure I follow here John.  Shouldn't init_net be initialized prior to any
network devices getting registered?  In other words, shouldn't for_each_netdev
just result in zero iterations through the loop?
Neil
