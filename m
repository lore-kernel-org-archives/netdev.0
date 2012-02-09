From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 09 Feb 2012 10:14:47 -0800
Message-ID: <1328811287.19664.9.camel@oc1677441337.ibm.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com,
	shemminger@vyatta.com, kvm@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-08 at 19:22 -0800, John Fastabend wrote:
> Propagate software FDB table into hardware uc, mc lists when
> the NETIF_F_HW_FDB is set.
> 
> This resolves the case below where an embedded switch is used
> in hardware to do inter-VF or VF-PF switching. This patch
> pushes the FDB entry (specifically the MAC address) into the
> embedded switch with dev_add_uc and dev_add_mc so the switch
> "learns" about the software bridge.
> 
> 
>           veth0  veth2
>             |      |
>           ------------
>           |  bridge0 |   <---- software bridging
>           ------------
>                /
>                /
>   ethx.y      ethx
>     VF         PF
>      \         \          <---- propagate FDB entries to HW
>      \         \
>   --------------------
>   |  Embedded Bridge |    <---- hardware offloaded switching
>   --------------------
> 

This scenario works now as adding an interface to a bridge puts it in
promiscuous mode. So adding a PF to a software bridge should not be
a problem as it supports promiscuous mode. But adding a VF will not
work.

Are you trying to avoid the requirement of having to put the interface 
in promiscuous mode when adding to a bridge?

Thanks
Sridhar



> This is only an RFC couple more changes are needed.
> 
> (1) Optimize HW FDB set/del to only walk list if an FDB offloaded
>     device is attached. Or decide it doesn't matter from unlikely()
>     path.
> 
> (2) Is it good enough to just call dev_uc_{add|del} or
>     dev_mc_{add|del}? Or do some devices really need a new netdev
>     callback to do this operation correctly. I think it should be
>     good enough as is.
> 
> (3) wrapped list walk in rcu_read_lock() just in case maybe every
>     case is already inside rcu_read_lock()/unlock().
> 
> Also this is in response to this thread regarding the macvlan and
> exposing rx filters posting now to see if folks think this is the
> right idea and if it will resolve at least the bridge case.
> 
> http://lists.openwall.net/netdev/2011/11/08/135
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/netdev_features.h |    2 ++
>  net/bridge/br_fdb.c             |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index 77f5202..5936fae 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -55,6 +55,8 @@ enum {
>  	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
>  	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
> 
> +	NETIF_F_HW_FDB,			/* Hardware supports switching */
> +
>  	/*
>  	 * Add your fresh new feature above and remember to update
>  	 * netdev_features_strings[] in net/core/ethtool.c and maybe
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 5ba0c84..4cc545b 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -81,9 +81,26 @@ static void fdb_rcu_free(struct rcu_head *head)
>  	kmem_cache_free(br_fdb_cache, ent);
>  }
> 
> +static void fdb_hw_delete(struct net_bridge *br,
> +			  struct net_bridge_fdb_entry *fdb)
> +{
> +	struct net_bridge_port *op;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(op, &br->port_list, list) {
> +		struct net_device *dev = op->dev;
> +
> +		if ((dev->features & NETIF_F_HW_FDB) &&
> +		    dev != fdb->dst->dev)
> +			dev_uc_del(dev, fdb->addr.addr);
> +	}
> +	rcu_read_unlock();
> +}
> +
>  static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
>  {
>  	hlist_del_rcu(&f->hlist);
> +	fdb_hw_delete(br, f);
>  	fdb_notify(br, f, RTM_DELNEIGH);
>  	call_rcu(&f->rcu, fdb_rcu_free);
>  }
> @@ -350,6 +367,22 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
>  	return NULL;
>  }
> 
> +static void fdb_hw_create(struct net_bridge *br,
> +			  struct net_bridge_fdb_entry *fdb)
> +{
> +	struct net_bridge_port *op;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(op, &br->port_list, list) {
> +		struct net_device *dev = op->dev;
> +
> +		if ((dev->features & NETIF_F_HW_FDB) &&
> +		    dev != fdb->dst->dev)
> +			dev_uc_add(dev, fdb->addr.addr);
> +	}
> +	rcu_read_unlock();
> +}
> +
>  static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
>  					       struct net_bridge_port *source,
>  					       const unsigned char *addr)
> @@ -363,6 +396,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
>  		fdb->is_local = 0;
>  		fdb->is_static = 0;
>  		fdb->updated = fdb->used = jiffies;
> +		fdb_hw_create(source->br, fdb);
>  		hlist_add_head_rcu(&fdb->hlist, head);
>  	}
>  	return fdb;
> 


