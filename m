From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCHv2 bridge 4/7] bridge: Add netlink interface to
 configure vlans on bridge ports
Date: Sat, 22 Sep 2012 18:17:54 +0100
Message-ID: <1348334274.2521.103.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	 <1348058536-22607-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48565 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751596Ab2IVRR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:17:57 -0400
In-Reply-To: <1348058536-22607-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
> Add a netlink interface to add and remove vlan configuration on bridge port.
> The interface uses the RTM_SETLINK message and encodes the vlan
> configuration inside the IFLA_AF_SPEC.  It is possble to include multiple
> vlans to either add or remove in a single message.
[...]
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
> @@ -445,6 +446,79 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>  	return 0;
>  }
>  
> +/* Called with RTNL */
> +int br_set_port_vlan(struct net_bridge_port *p, unsigned short vlan)
> +{
> +	unsigned long table_size = BITS_TO_LONGS(br_vid(VLAN_N_VID));
> +	unsigned long *vid_map = NULL;
> +	__u16 vid = br_vid(vlan);
> +	int ret = 0;
> +
> +	/* The vlan map is indexed by vid+1.  This way we can store
> +	 * vid 0 (untagged) into the map as well.
> +	 */

So bit 1 is for untagged, bits 2-4096 are for tagged, and bit 0 is
for...?

> +	if (!p->vlan_map) {
> +		vid_map = kzalloc(table_size, GFP_KERNEL);
> +		if (!vid_map) {
> +			return -ENOMEM;
> +		}
> +
> +		set_bit(vid, vid_map);
> +		rcu_assign_pointer(p->vlan_map, vid_map);
> +		synchronize_net();
> +	} else {
> +		/* Map is already allocated */
> +		set_bit(vid, rcu_dereference_rtnl(p->vlan_map));
> +	}
> +
> +	return ret;
> +}
> +
> +
> +/* Called with RTNL */
> +int br_del_port_vlan(struct net_bridge_port *p, unsigned short vlan)
> +{
> +	unsigned long first_bit;
> +	unsigned long next_bit;
> +	__u16 vid = br_vid(vlan);

Which is the bit number, not really the VID - a little confusing...

> +	unsigned long tbl_len = BITS_TO_LONGS(br_vid(VLAN_N_VID));
> +
> +	if (!p->vlan_map) {
> +		return -EINVAL;
> +	}
> +
> +	if (!test_bit(vlan, p->vlan_map)) {
> +		return -EINVAL;
> +	}
> +
> +	/* Check to see if any other vlans are in this table.  If this
> +	 * is the last vlan, delete the whole table.  If this is not the
> +	 * last vlan, just clear the bit.
> +	 */
> +	first_bit = find_first_bit(p->vlan_map, tbl_len);
> +	next_bit = find_next_bit(p->vlan_map, tbl_len, (tbl_len - vid));
[...]

Last parameter to find_next_bit is the starting offset, which should
presumably be vid + 1.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
