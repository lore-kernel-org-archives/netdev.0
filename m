From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 02/19] net: bridge: Add support for offloading
 port attributes
Date: Thu, 8 Jun 2017 11:29:57 +0200
Message-ID: <0c27de88-e543-e29d-95fc-12d3521440b9@redhat.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751625AbdFHJaB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 05:30:01 -0400
In-Reply-To: <20170608064428.4785-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8.6.2017 08:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Currently the flood, learning and learning_sync port attributes are
> offloaded by setting the SELF flag. Add support for offloading the
> flood and learning attribute through the bridge code. In case of
> setting an unsupported flag on a offloded port the operation will
> fail.
> 
> The learning_sync attribute doesn't have any software representation
> and cannot be offloaded through the bridge code.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_netlink.c   | 87 +++++++++++++++++++++++++++++++++++------------
>  net/bridge/br_private.h   | 10 ++++++
>  net/bridge/br_switchdev.c | 43 +++++++++++++++++++++++
>  3 files changed, 119 insertions(+), 21 deletions(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 3bcda55..63dca34 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -662,16 +662,26 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>  }
>  
>  /* Set/clear or port flags based on attribute */
> -static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
> -			   int attrtype, unsigned long mask)
> +static int br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
> +			    int attrtype, unsigned long mask)
>  {
> -	if (tb[attrtype]) {
> -		u8 flag = nla_get_u8(tb[attrtype]);
> -		if (flag)
> -			p->flags |= mask;
> -		else
> -			p->flags &= ~mask;
> -	}
> +	unsigned long flags;
> +	int err;
> +
> +	if (!tb[attrtype])
> +		return 0;
> +
> +	if (nla_get_u8(tb[attrtype]))
> +		flags = p->flags | mask;
> +	else
> +		flags = p->flags & ~mask;
> +
> +	err = br_switchdev_set_port_flag(p, flags, mask);
> +	if (err)
> +		return err;
> +
> +	p->flags = flags;
> +	return 0;
>  }
>  
>  /* Process bridge protocol info on port */
> @@ -681,20 +691,55 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  	bool br_vlan_tunnel_old = false;
>  	int err;
>  
> -	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_BCAST_FLOOD, BR_BCAST_FLOOD);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_BCAST_FLOOD, BR_BCAST_FLOOD);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
> +	if (err)
> +		return err;
> +
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
> +	if (err)
> +		return err;
>  
>  	br_vlan_tunnel_old = (p->flags & BR_VLAN_TUNNEL) ? true : false;
> -	br_set_port_flag(p, tb, IFLA_BRPORT_VLAN_TUNNEL, BR_VLAN_TUNNEL);
> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_VLAN_TUNNEL, BR_VLAN_TUNNEL);
> +	if (err)
> +		return err;
> +
>  	if (br_vlan_tunnel_old && !(p->flags & BR_VLAN_TUNNEL))
>  		nbp_vlan_tunnel_info_flush(p);
>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 2062692..7f43992 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -1076,6 +1076,9 @@ void nbp_switchdev_frame_mark(const struct net_bridge_port *p,
>  			      struct sk_buff *skb);
>  bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
>  				  const struct sk_buff *skb);
> +int br_switchdev_set_port_flag(struct net_bridge_port *p,
> +			       unsigned long flags,
> +			       unsigned long mask);
>  #else
>  static inline int nbp_switchdev_mark_set(struct net_bridge_port *p)
>  {
> @@ -1092,6 +1095,13 @@ static inline bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
>  {
>  	return true;
>  }
> +
> +static inline int br_switchdev_set_port_flag(struct net_bridge_port *p,
> +					     unsigned long flags,
> +					     unsigned long mask)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_NET_SWITCHDEV */
>  
>  #endif
> diff --git a/net/bridge/br_switchdev.c b/net/bridge/br_switchdev.c
> index f4097b9..b975959 100644
> --- a/net/bridge/br_switchdev.c
> +++ b/net/bridge/br_switchdev.c
> @@ -55,3 +55,46 @@ bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
>  	return !skb->offload_fwd_mark ||
>  	       BR_INPUT_SKB_CB(skb)->offload_fwd_mark != p->offload_fwd_mark;
>  }
> +
> +/* Flags that can be offloaded to hardware */
> +#define BR_PORT_FLAGS_HW_OFFLOAD (BR_LEARNING | BR_FLOOD | \
> +				  BR_MCAST_FLOOD | BR_BCAST_FLOOD)
> +
> +int br_switchdev_set_port_flag(struct net_bridge_port *p,
> +			       unsigned long flags,
> +			       unsigned long mask)
> +{
> +	struct switchdev_attr attr = {
> +		.orig_dev = p->dev,
> +		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT,
> +	};
> +	int err;
> +
> +	if (mask & ~BR_PORT_FLAGS_HW_OFFLOAD)
> +		return 0;
> +
> +	err = switchdev_port_attr_get(p->dev, &attr);
> +	if (err == -EOPNOTSUPP)
> +		return 0;
> +	if (err)
> +		return err;
> +
> +	/* Check if specific bridge flag attribute offload is supported */
> +	if (!(attr.u.brport_flags_support & mask)) {
> +		br_warn(p->br, "bridge flag offload is not supported %u(%s)\n",
> +			(unsigned int)p->port_no, p->dev->name);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	attr.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS;
> +	attr.flags = SWITCHDEV_F_DEFER;
> +	attr.u.brport_flags = flags;
> +	err = switchdev_port_attr_set(p->dev, &attr);
> +	if (err) {
> +		br_warn(p->br, "error setting offload flag on port %u(%s)\n",
> +			(unsigned int)p->port_no, p->dev->name);
> +		return err;
> +	}
> +
> +	return 0;
> +}
> 

Reviewed-by: Ivan Vecera <ivecera@redhat.com>
