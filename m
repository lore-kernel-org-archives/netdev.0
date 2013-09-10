From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/4] bridge: Don't use VID 0 and 4095 in vlan filtering
Date: Tue, 10 Sep 2013 10:22:26 -0400
Message-ID: <522F2B22.5010007@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita> <1378809144.3988.6.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab3IJOWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 10:22:30 -0400
In-Reply-To: <1378809144.3988.6.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 06:32 AM, Toshiaki Makita wrote:
> IEEE 802.1Q says that:
> - VID 0 shall not be configured as a PVID, or configured in any Filtering
> Database entry.
> - VID 4095 shall not be configured as a PVID, or transmitted in a tag
> header. This VID value may be used to indicate a wildcard match for the VID
> in management operations or Filtering Database entries.
> (See IEEE 802.1Q-2005 6.7.1 and Table 9-2)
>
> Don't accept adding these VIDs in the vlan_filtering implementation.
>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Reviewed-by: Vlad Yasevich <vyasevich@redhat.com>

-vlad
> ---
>   net/bridge/br_fdb.c     |  4 +-
>   net/bridge/br_netlink.c |  2 +-
>   net/bridge/br_vlan.c    | 97 +++++++++++++++++++++++--------------------------
>   3 files changed, 49 insertions(+), 54 deletions(-)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index ffd5874..33e8f23 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -700,7 +700,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>
>   		vid = nla_get_u16(tb[NDA_VLAN]);
>
> -		if (vid >= VLAN_N_VID) {
> +		if (!vid || vid >= VLAN_VID_MASK) {
>   			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
>   				vid);
>   			return -EINVAL;
> @@ -794,7 +794,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>
>   		vid = nla_get_u16(tb[NDA_VLAN]);
>
> -		if (vid >= VLAN_N_VID) {
> +		if (!vid || vid >= VLAN_VID_MASK) {
>   			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
>   				vid);
>   			return -EINVAL;
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index b9259ef..9bac61e 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -243,7 +243,7 @@ static int br_afspec(struct net_bridge *br,
>
>   		vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
>
> -		if (vinfo->vid >= VLAN_N_VID)
> +		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
>   			return -EINVAL;
>
>   		switch (cmd) {
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 9a9ffe7..21b6d21 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -45,37 +45,34 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
>   		return 0;
>   	}
>
> -	if (vid) {
> -		if (v->port_idx) {
> -			p = v->parent.port;
> -			br = p->br;
> -			dev = p->dev;
> -		} else {
> -			br = v->parent.br;
> -			dev = br->dev;
> -		}
> -		ops = dev->netdev_ops;
> -
> -		if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
> -			/* Add VLAN to the device filter if it is supported.
> -			 * Stricly speaking, this is not necessary now, since
> -			 * devices are made promiscuous by the bridge, but if
> -			 * that ever changes this code will allow tagged
> -			 * traffic to enter the bridge.
> -			 */
> -			err = ops->ndo_vlan_rx_add_vid(dev, htons(ETH_P_8021Q),
> -						       vid);
> -			if (err)
> -				return err;
> -		}
> -
> -		err = br_fdb_insert(br, p, dev->dev_addr, vid);
> -		if (err) {
> -			br_err(br, "failed insert local address into bridge "
> -			       "forwarding table\n");
> -			goto out_filt;
> -		}
> +	if (v->port_idx) {
> +		p = v->parent.port;
> +		br = p->br;
> +		dev = p->dev;
> +	} else {
> +		br = v->parent.br;
> +		dev = br->dev;
> +	}
> +	ops = dev->netdev_ops;
> +
> +	if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
> +		/* Add VLAN to the device filter if it is supported.
> +		 * Stricly speaking, this is not necessary now, since
> +		 * devices are made promiscuous by the bridge, but if
> +		 * that ever changes this code will allow tagged
> +		 * traffic to enter the bridge.
> +		 */
> +		err = ops->ndo_vlan_rx_add_vid(dev, htons(ETH_P_8021Q),
> +					       vid);
> +		if (err)
> +			return err;
> +	}
>
> +	err = br_fdb_insert(br, p, dev->dev_addr, vid);
> +	if (err) {
> +		br_err(br, "failed insert local address into bridge "
> +		       "forwarding table\n");
> +		goto out_filt;
>   	}
>
>   	set_bit(vid, v->vlan_bitmap);
> @@ -98,7 +95,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
>   	__vlan_delete_pvid(v, vid);
>   	clear_bit(vid, v->untagged_bitmap);
>
> -	if (v->port_idx && vid) {
> +	if (v->port_idx) {
>   		struct net_device *dev = v->parent.port->dev;
>   		const struct net_device_ops *ops = dev->netdev_ops;
>
> @@ -248,7 +245,9 @@ bool br_allowed_egress(struct net_bridge *br,
>   	return false;
>   }
>
> -/* Must be protected by RTNL */
> +/* Must be protected by RTNL.
> + * Must be called with vid in range from 1 to 4094 inclusive.
> + */
>   int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>   {
>   	struct net_port_vlans *pv = NULL;
> @@ -278,7 +277,9 @@ out:
>   	return err;
>   }
>
> -/* Must be protected by RTNL */
> +/* Must be protected by RTNL.
> + * Must be called with vid in range from 1 to 4094 inclusive.
> + */
>   int br_vlan_delete(struct net_bridge *br, u16 vid)
>   {
>   	struct net_port_vlans *pv;
> @@ -289,14 +290,9 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
>   	if (!pv)
>   		return -EINVAL;
>
> -	if (vid) {
> -		/* If the VID !=0 remove fdb for this vid. VID 0 is special
> -		 * in that it's the default and is always there in the fdb.
> -		 */
> -		spin_lock_bh(&br->hash_lock);
> -		fdb_delete_by_addr(br, br->dev->dev_addr, vid);
> -		spin_unlock_bh(&br->hash_lock);
> -	}
> +	spin_lock_bh(&br->hash_lock);
> +	fdb_delete_by_addr(br, br->dev->dev_addr, vid);
> +	spin_unlock_bh(&br->hash_lock);
>
>   	__vlan_del(pv, vid);
>   	return 0;
> @@ -329,7 +325,9 @@ unlock:
>   	return 0;
>   }
>
> -/* Must be protected by RTNL */
> +/* Must be protected by RTNL.
> + * Must be called with vid in range from 1 to 4094 inclusive.
> + */
>   int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
>   {
>   	struct net_port_vlans *pv = NULL;
> @@ -363,7 +361,9 @@ clean_up:
>   	return err;
>   }
>
> -/* Must be protected by RTNL */
> +/* Must be protected by RTNL.
> + * Must be called with vid in range from 1 to 4094 inclusive.
> + */
>   int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
>   {
>   	struct net_port_vlans *pv;
> @@ -374,14 +374,9 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
>   	if (!pv)
>   		return -EINVAL;
>
> -	if (vid) {
> -		/* If the VID !=0 remove fdb for this vid. VID 0 is special
> -		 * in that it's the default and is always there in the fdb.
> -		 */
> -		spin_lock_bh(&port->br->hash_lock);
> -		fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
> -		spin_unlock_bh(&port->br->hash_lock);
> -	}
> +	spin_lock_bh(&port->br->hash_lock);
> +	fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
> +	spin_unlock_bh(&port->br->hash_lock);
>
>   	return __vlan_del(pv, vid);
>   }
>
