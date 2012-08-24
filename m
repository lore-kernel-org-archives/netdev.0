From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Fri, 24 Aug 2012 10:56:16 -0700
Message-ID: <20120824175616.GL2472@linux.vnet.ibm.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
 <1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52925 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542Ab2HXR4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:56:53 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 11:56:53 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 13AFF1FF003C
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 11:56:48 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OHuOhr165848
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 11:56:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OHuHnK021003
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 11:56:17 -0600
Content-Disposition: inline
In-Reply-To: <1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 03:29:54PM -0400, Vlad Yasevich wrote:
> Add a private ioctl to add and remove vlan configuration on bridge port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

One question below...

> ---
>  include/linux/if_bridge.h |    2 +
>  net/bridge/br_if.c        |   69 +++++++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_ioctl.c     |   31 ++++++++++++++++++++
>  net/bridge/br_private.h   |    2 +
>  4 files changed, 104 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index 288ff10..ab750dd 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -42,6 +42,8 @@
>  #define BRCTL_SET_PORT_PRIORITY 16
>  #define BRCTL_SET_PATH_COST 17
>  #define BRCTL_GET_FDB_ENTRIES 18
> +#define BRCTL_ADD_VLAN 19
> +#define BRCTL_DEL_VLAN 20
> 
>  #define BR_STATE_DISABLED 0
>  #define BR_STATE_LISTENING 1
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index e1144e1..90c1038 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -23,6 +23,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/slab.h>
>  #include <net/sock.h>
> +#include <linux/if_vlan.h>
> 
>  #include "br_private.h"
> 
> @@ -441,6 +442,74 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>  	return 0;
>  }
> 
> +/* Called with RTNL */
> +int br_set_port_vlan(struct net_bridge_port *p, unsigned long vlan)
> +{
> +	unsigned long table_size = (VLAN_N_VID/sizeof(unsigned long)) + 1;
> +	unsigned long *vid_map = NULL;
> +	__u16 vid = (__u16) vlan + 1;
> +
> +	/* We are under lock so we can check this without rcu.
> +	 * The vlan map is indexed by vid+1.  This way we can store
> +	 * vid 0 (untagged) into the map as well.
> +	 */
> +	if (!p->vlan_map) {
> +		vid_map = kzalloc(table_size, GFP_KERNEL);
> +		if (!vid_map)
> +			return -ENOMEM;
> +
> +		set_bit(vid, vid_map);
> +		rcu_assign_pointer(p->vlan_map, vid_map);
> +
> +	} else {
> +		/* Map is already allocated */
> +		set_bit(vid, p->vlan_map);
> +	}
> +
> +	return 0;
> +}
> +
> +
> +/* Called with RTNL */
> +int br_del_port_vlan(struct net_bridge_port *p, unsigned long vlan)
> +{
> +	unsigned long first_bit;
> +	unsigned long next_bit;
> +	__u16 vid = (__u16) vlan+1;
> +	unsigned long tbl_len = VLAN_N_VID+1;
> +
> +	if (!p->vlan_map)
> +		return -EINVAL;
> +
> +	if (!test_bit(vlan, p->vlan_map))
> +		return -EINVAL;
> +
> +	/* Check to see if any other vlans are in this table.  If this
> +	 * is the last vlan, delete the whole table.  If this is not the
> +	 * last vlan, just clear the bit.
> +	 */
> +	first_bit = find_first_bit(p->vlan_map, tbl_len);
> +	next_bit = find_next_bit(p->vlan_map, tbl_len, (tbl_len - vid));
> +
> +	if ((__u16)first_bit != vid || (__u16)next_bit < tbl_len) {
> +		/* There are other vlans still configured.  We can simply
> +		 * clear our bit and be safe.
> +		 */
> +		clear_bit(vid, p->vlan_map);
> +	} else {
> +		/* This is the last vlan we are removing.  Replace the
> +		 * map with a NULL pointer and free the old map
> +		 */
> +		unsigned long *map = rcu_dereference(p->vlan_map);
> +
> +		rcu_assign_pointer(p->vlan_map, NULL);
> +		synchronize_net();
> +		kfree(map);
> +	}
> +
> +	return 0;
> +}
> +
>  void __net_exit br_net_exit(struct net *net)
>  {
>  	struct net_device *dev;
> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
> index 7222fe1..3a5b1f9 100644
> --- a/net/bridge/br_ioctl.c
> +++ b/net/bridge/br_ioctl.c
> @@ -289,6 +289,37 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	case BRCTL_GET_FDB_ENTRIES:
>  		return get_fdb_entries(br, (void __user *)args[1],
>  				       args[2], args[3]);
> +	case BRCTL_ADD_VLAN:
> +	{
> +		struct net_bridge_port *p;
> +
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +
> +		rcu_read_lock();
> +		if ((p = br_get_port(br, args[1])) == NULL) {
> +			rcu_read_unlock();
> +			return -EINVAL;
> +		}
> +		rcu_read_unlock();

Why is it safe to pass "p" out of the RCU read-side critical section?
I don't see that br_get_port() does anything to make this safe, at least
not in v3.5.

> +		return br_set_port_vlan(p, args[2]);
> +	}
> +
> +	case BRCTL_DEL_VLAN:
> +	{
> +		struct net_bridge_port *p;
> +
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +
> +		rcu_read_lock();
> +		if ((p = br_get_port(br, args[1])) == NULL) {
> +			rcu_read_unlock();
> +			return -EINVAL;
> +		}
> +		rcu_read_unlock();
> +		br_set_port_vlan(p, args[2]);
> +	}
>  	}
> 
>  	return -EOPNOTSUPP;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index b6c56ab..5639c1c 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -402,6 +402,8 @@ extern int br_del_if(struct net_bridge *br,
>  extern int br_min_mtu(const struct net_bridge *br);
>  extern netdev_features_t br_features_recompute(struct net_bridge *br,
>  	netdev_features_t features);
> +extern int br_set_port_vlan(struct net_bridge_port *p, unsigned long vid);
> +extern int br_del_port_vlan(struct net_bridge_port *p, unsigned long vid);
> 
>  /* br_input.c */
>  extern int br_handle_frame_finish(struct sk_buff *skb);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
