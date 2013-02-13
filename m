From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [PATCH v10 net-next 10/12] bridge: Add vlan support to static
 neighbors
Date: Wed, 13 Feb 2013 11:25:08 -0800
Message-ID: <20130213112508.00001a29@unknown>
References: <1360777309-25522-1-git-send-email-vyasevic@redhat.com>
	<1360777309-25522-11-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bridge@lists.linux-foundation.org>,
	<shemminger@vyatta.com>, <davem@davemloft.net>, <mirqus@gmail.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19725 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab3BMTZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 14:25:14 -0500
In-Reply-To: <1360777309-25522-11-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2013 12:41:47 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> When a user adds bridge neighbors, allow him to specify VLAN id.
> If the VLAN id is not specified, the neighbor will be added
> for VLANs currently in the ports filter list.  If no VLANs are
> configured on the port, we use vlan 0 and only add 1 entry.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>  drivers/net/macvlan.c                         |    2 +-
>  drivers/net/vxlan.c                           |    3 +-
>  include/linux/netdevice.h                     |    1 +
>  include/uapi/linux/neighbour.h                |    1 +
>  net/bridge/br_fdb.c                           |  148
> ++++++++++++++++++++++---
> net/bridge/br_private.h                       |    6 +-
> net/core/rtnetlink.c                          |   23 +++-- 8 files
> changed, 154 insertions(+), 32 deletions(-)

You (or someone) needs to fix up the ndo_fdb_del functions for the
mellanox and qlogic drivers also since that also instantiate those
operations.

I look forward to having this feature set.  Quite useful.

Thanks,

- Greg Rose
Networking Division
Intel Corp.

> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c index
> eecd9cb..c1394dd 100644 ---
> a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c +++
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c @@ -7001,7 +7001,7 @@
> static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> return err; }
>  
> -static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
> +static int ixgbe_ndo_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
>  			     struct net_device *dev,
>  			     const unsigned char *addr)
>  {
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 7b44ebd..afbea93 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -564,7 +564,7 @@ static int macvlan_fdb_add(struct ndmsg *ndm,
> struct nlattr *tb[], return err;
>  }
>  
> -static int macvlan_fdb_del(struct ndmsg *ndm,
> +static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
>  			   struct net_device *dev,
>  			   const unsigned char *addr)
>  {
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 72485b9..9d70421 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -393,7 +393,8 @@ static int vxlan_fdb_add(struct ndmsg *ndm,
> struct nlattr *tb[], }
>  
>  /* Delete entry (via netlink) */
> -static int vxlan_fdb_delete(struct ndmsg *ndm, struct net_device
> *dev, +static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr
> *tb[],
> +			    struct net_device *dev,
>  			    const unsigned char *addr)
>  {
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index bf3db11..6eb70eb 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1008,6 +1008,7 @@ struct net_device_ops {
>  					       const unsigned char
> *addr, u16 flags);
>  	int			(*ndo_fdb_del)(struct ndmsg *ndm,
> +					       struct nlattr *tb[],
>  					       struct net_device
> *dev, const unsigned char *addr);
>  	int			(*ndo_fdb_dump)(struct sk_buff
> *skb, diff --git a/include/uapi/linux/neighbour.h
> b/include/uapi/linux/neighbour.h index 275e5d6..adb068c 100644
> --- a/include/uapi/linux/neighbour.h
> +++ b/include/uapi/linux/neighbour.h
> @@ -20,6 +20,7 @@ enum {
>  	NDA_LLADDR,
>  	NDA_CACHEINFO,
>  	NDA_PROBES,
> +	NDA_VLAN,
>  	__NDA_MAX
>  };
>  
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 276a522..4b75ad4 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -505,6 +505,10 @@ static int fdb_fill_info(struct sk_buff *skb,
> const struct net_bridge *br, ci.ndm_refcnt	 = 0;
>  	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
>  		goto nla_put_failure;
> +
> +	if (nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
> +		goto nla_put_failure;
> +
>  	return nlmsg_end(skb, nlh);
>  
>  nla_put_failure:
> @@ -516,6 +520,7 @@ static inline size_t fdb_nlmsg_size(void)
>  {
>  	return NLMSG_ALIGN(sizeof(struct ndmsg))
>  		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
> +		+ nla_total_size(sizeof(u16)) /* NDA_VLAN */
>  		+ nla_total_size(sizeof(struct nda_cacheinfo));
>  }
>  
> @@ -617,6 +622,25 @@ static int fdb_add_entry(struct net_bridge_port
> *source, const __u8 *addr, return 0;
>  }
>  
> +static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
> +	       const unsigned char *addr, u16 nlh_flags, u16 vid)
> +{
> +	int err = 0;
> +
> +	if (ndm->ndm_flags & NTF_USE) {
> +		rcu_read_lock();
> +		br_fdb_update(p->br, p, addr, vid);
> +		rcu_read_unlock();
> +	} else {
> +		spin_lock_bh(&p->br->hash_lock);
> +		err = fdb_add_entry(p, addr, ndm->ndm_state,
> +				    nlh_flags, vid);
> +		spin_unlock_bh(&p->br->hash_lock);
> +	}
> +
> +	return err;
> +}
> +
>  /* Add new permanent fdb entry with RTM_NEWNEIGH */
>  int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  	       struct net_device *dev,
> @@ -624,12 +648,29 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr
> *tb[], {
>  	struct net_bridge_port *p;
>  	int err = 0;
> +	struct net_port_vlans *pv;
> +	unsigned short vid = VLAN_N_VID;
>  
>  	if (!(ndm->ndm_state &
> (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) { pr_info("bridge:
> RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state); return
> -EINVAL; }
>  
> +	if (tb[NDA_VLAN]) {
> +		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short))
> {
> +			pr_info("bridge: RTM_NEWNEIGH with invalid
> vlan\n");
> +			return -EINVAL;
> +		}
> +
> +		vid = nla_get_u16(tb[NDA_VLAN]);
> +
> +		if (vid >= VLAN_N_VID) {
> +			pr_info("bridge: RTM_NEWNEIGH with invalid
> vlan id %d\n",
> +				vid);
> +			return -EINVAL;
> +		}
> +	}
> +
>  	p = br_port_get_rtnl(dev);
>  	if (p == NULL) {
>  		pr_info("bridge: RTM_NEWNEIGH %s not a bridge
> port\n", @@ -637,41 +678,90 @@ int br_fdb_add(struct ndmsg *ndm,
> struct nlattr *tb[], return -EINVAL;
>  	}
>  
> -	if (ndm->ndm_flags & NTF_USE) {
> -		rcu_read_lock();
> -		br_fdb_update(p->br, p, addr, 0);
> -		rcu_read_unlock();
> +	pv = nbp_get_vlan_info(p);
> +	if (vid != VLAN_N_VID) {
> +		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
> +			pr_info("bridge: RTM_NEWNEIGH with
> unconfigured "
> +				"vlan %d on port %s\n", vid,
> dev->name);
> +			return -EINVAL;
> +		}
> +
> +		/* VID was specified, so use it. */
> +		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
>  	} else {
> -		spin_lock_bh(&p->br->hash_lock);
> -		err = fdb_add_entry(p, addr, ndm->ndm_state,
> nlh_flags,
> -				0);
> -		spin_unlock_bh(&p->br->hash_lock);
> +		if (!pv || bitmap_empty(pv->vlan_bitmap,
> BR_VLAN_BITMAP_LEN)) {
> +			err = __br_fdb_add(ndm, p, addr, nlh_flags,
> 0);
> +			goto out;
> +		}
> +
> +		/* We have vlans configured on this port and user
> didn't
> +		 * specify a VLAN.  To be nice, add/update entry for
> every
> +		 * vlan on this port.
> +		 */
> +		vid = find_first_bit(pv->vlan_bitmap,
> BR_VLAN_BITMAP_LEN);
> +		while (vid < BR_VLAN_BITMAP_LEN) {
> +			err = __br_fdb_add(ndm, p, addr, nlh_flags,
> vid);
> +			if (err)
> +				goto out;
> +			vid = find_next_bit(pv->vlan_bitmap,
> +					    BR_VLAN_BITMAP_LEN,
> vid+1);
> +		}
>  	}
>  
> +out:
>  	return err;
>  }
>  
> -static int fdb_delete_by_addr(struct net_bridge_port *p, const u8
> *addr) +static int fdb_delete_by_addr(struct net_bridge *br, const u8
> *addr,
> +			      u16 vlan)
>  {
> -	struct net_bridge *br = p->br;
> -	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
> +	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
>  	struct net_bridge_fdb_entry *fdb;
>  
> -	fdb = fdb_find(head, addr, 0);
> +	fdb = fdb_find(head, addr, vlan);
>  	if (!fdb)
>  		return -ENOENT;
>  
> -	fdb_delete(p->br, fdb);
> +	fdb_delete(br, fdb);
>  	return 0;
>  }
>  
> +static int __br_fdb_delete(struct net_bridge_port *p,
> +			   const unsigned char *addr, u16 vid)
> +{
> +	int err;
> +
> +	spin_lock_bh(&p->br->hash_lock);
> +	err = fdb_delete_by_addr(p->br, addr, vid);
> +	spin_unlock_bh(&p->br->hash_lock);
> +
> +	return err;
> +}
> +
>  /* Remove neighbor entry with RTM_DELNEIGH */
> -int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
> +int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
> +		  struct net_device *dev,
>  		  const unsigned char *addr)
>  {
>  	struct net_bridge_port *p;
>  	int err;
> +	struct net_port_vlans *pv;
> +	unsigned short vid = VLAN_N_VID;
>  
> +	if (tb[NDA_VLAN]) {
> +		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short))
> {
> +			pr_info("bridge: RTM_NEWNEIGH with invalid
> vlan\n");
> +			return -EINVAL;
> +		}
> +
> +		vid = nla_get_u16(tb[NDA_VLAN]);
> +
> +		if (vid >= VLAN_N_VID) {
> +			pr_info("bridge: RTM_NEWNEIGH with invalid
> vlan id %d\n",
> +				vid);
> +			return -EINVAL;
> +		}
> +	}
>  	p = br_port_get_rtnl(dev);
>  	if (p == NULL) {
>  		pr_info("bridge: RTM_DELNEIGH %s not a bridge
> port\n", @@ -679,9 +769,33 @@ int br_fdb_delete(struct ndmsg *ndm,
> struct net_device *dev, return -EINVAL;
>  	}
>  
> -	spin_lock_bh(&p->br->hash_lock);
> -	err = fdb_delete_by_addr(p, addr);
> -	spin_unlock_bh(&p->br->hash_lock);
> +	pv = nbp_get_vlan_info(p);
> +	if (vid != VLAN_N_VID) {
> +		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
> +			pr_info("bridge: RTM_DELNEIGH with
> unconfigured "
> +				"vlan %d on port %s\n", vid,
> dev->name);
> +			return -EINVAL;
> +		}
>  
> +		err = __br_fdb_delete(p, addr, vid);
> +	} else {
> +		if (!pv || bitmap_empty(pv->vlan_bitmap,
> BR_VLAN_BITMAP_LEN)) {
> +			err = __br_fdb_delete(p, addr, 0);
> +			goto out;
> +		}
> +
> +		/* We have vlans configured on this port and user
> didn't
> +		 * specify a VLAN.  To be nice, add/update entry for
> every
> +		 * vlan on this port.
> +		 */
> +		err = -ENOENT;
> +		vid = find_first_bit(pv->vlan_bitmap,
> BR_VLAN_BITMAP_LEN);
> +		while (vid < BR_VLAN_BITMAP_LEN) {
> +			err &= __br_fdb_delete(p, addr, vid);
> +			vid = find_next_bit(pv->vlan_bitmap,
> +					    BR_VLAN_BITMAP_LEN,
> vid+1);
> +		}
> +	}
> +out:
>  	return err;
>  }
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index eb197a9..7d2ae78 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -391,7 +391,7 @@ extern void br_fdb_update(struct net_bridge *br,
>  			  const unsigned char *addr,
>  			  u16 vid);
>  
> -extern int br_fdb_delete(struct ndmsg *ndm,
> +extern int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>  			 struct net_device *dev,
>  			 const unsigned char *addr);
>  extern int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[],
> @@ -580,13 +580,13 @@ extern void nbp_vlan_flush(struct
> net_bridge_port *port); static inline struct net_port_vlans
> *br_get_vlan_info( const struct net_bridge *br)
>  {
> -	return rcu_dereference(br->vlan_info);
> +	return rcu_dereference_rtnl(br->vlan_info);
>  }
>  
>  static inline struct net_port_vlans *nbp_get_vlan_info(
>  						const struct
> net_bridge_port *p) {
> -	return rcu_dereference(p->vlan_info);
> +	return rcu_dereference_rtnl(p->vlan_info);
>  }
>  
>  /* Since bridge now depends on 8021Q module, but the time bridge
> sees the diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e163a60..257b73e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2122,7 +2122,7 @@ static int rtnl_fdb_del(struct sk_buff *skb,
> struct nlmsghdr *nlh, void *arg) {
>  	struct net *net = sock_net(skb->sk);
>  	struct ndmsg *ndm;
> -	struct nlattr *llattr;
> +	struct nlattr *tb[NDA_MAX+1];
>  	struct net_device *dev;
>  	int err = -EINVAL;
>  	__u8 *addr;
> @@ -2130,8 +2130,9 @@ static int rtnl_fdb_del(struct sk_buff *skb,
> struct nlmsghdr *nlh, void *arg) if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
> -	if (nlmsg_len(nlh) < sizeof(*ndm))
> -		return -EINVAL;
> +	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
> +	if (err < 0)
> +		return err;
>  
>  	ndm = nlmsg_data(nlh);
>  	if (ndm->ndm_ifindex == 0) {
> @@ -2145,13 +2146,17 @@ static int rtnl_fdb_del(struct sk_buff *skb,
> struct nlmsghdr *nlh, void *arg) return -ENODEV;
>  	}
>  
> -	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
> -	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
> -		pr_info("PF_BRIGDE: RTM_DELNEIGH with invalid
> address\n");
> +	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
> +		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid
> address\n");
> +		return -EINVAL;
> +	}
> +
> +	addr = nla_data(tb[NDA_LLADDR]);
> +	if (!is_valid_ether_addr(addr)) {
> +		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether
> address\n"); return -EINVAL;
>  	}
>  
> -	addr = nla_data(llattr);
>  	err = -EOPNOTSUPP;
>  
>  	/* Support fdb on master device the net/bridge default case
> */ @@ -2161,7 +2166,7 @@ static int rtnl_fdb_del(struct sk_buff *skb,
> struct nlmsghdr *nlh, void *arg) const struct net_device_ops *ops =
> br_dev->netdev_ops; 
>  		if (ops->ndo_fdb_del)
> -			err = ops->ndo_fdb_del(ndm, dev, addr);
> +			err = ops->ndo_fdb_del(ndm, tb, dev, addr);
>  
>  		if (err)
>  			goto out;
> @@ -2171,7 +2176,7 @@ static int rtnl_fdb_del(struct sk_buff *skb,
> struct nlmsghdr *nlh, void *arg) 
>  	/* Embedded bridge, macvlan, and any other device support */
>  	if ((ndm->ndm_flags & NTF_SELF) &&
> dev->netdev_ops->ndo_fdb_del) {
> -		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
> +		err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev,
> addr); 
>  		if (!err) {
>  			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
