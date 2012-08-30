From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Thu, 30 Aug 2012 15:17:59 +0300
Message-ID: <20120830121759.GA20228@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
 <1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897Ab2H3MQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 08:16:40 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7UCGena018162
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 08:16:40 -0400
Content-Disposition: inline
In-Reply-To: <1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 03:29:54PM -0400, Vlad Yasevich wrote:
> Add a private ioctl to add and remove vlan configuration on bridge port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
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


That's not a lot of documentation especially
considering tricks such as using vlan 0
to mean untagged (an internal convention in kernel).

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

Use DECLARE_BITMAP[VLAN_N_VID + 1]?

> +	unsigned long *vid_map = NULL;
> +	__u16 vid = (__u16) vlan + 1;

Don't put space after cast: (__u16)vlan.

In fact, cast is not needed here at all.
Applies to other places in this patch that do this.


> +
> +	/* We are under lock so we can check this without rcu.
> +	 * The vlan map is indexed by vid+1.  This way we can store
> +	 * vid 0 (untagged) into the map as well.
> +	 */

Would be better to put this documentation in struct
definition where vid_map is defined.

> +	if (!p->vlan_map) {
> +		vid_map = kzalloc(table_size, GFP_KERNEL);
> +		if (!vid_map)
> +			return -ENOMEM;
> +
> +		set_bit(vid, vid_map);

What prevents vid from being > table_size * BITS_PER_LONG?

> +		rcu_assign_pointer(p->vlan_map, vid_map);
> +
> +	} else {
> +		/* Map is already allocated */
> +		set_bit(vid, p->vlan_map);

This should call rcu_dereference_protected.

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

Same as above.

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

() not needed around arguments.

> +
> +	if ((__u16)first_bit != vid || (__u16)next_bit < tbl_len) {

What are these type casts doing? How can you get a value > 0xffff?

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
> +		return br_set_port_vlan(p, args[2]);

So this sets vlan but does not synchronize RCU.
This means if this is the 1st vlan we set,
we return to userspace and afterwards
interfaces get packets with a wrong vlan.

I am guessing all these ioctls should synchronize_net.

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

Same problem as above as synchronize_net is not
invoked always.

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
