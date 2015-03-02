From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next v2 2/4] net: add IPv4 routing FIB support for
 switchdev
Date: Mon, 02 Mar 2015 14:27:04 -0800
Message-ID: <54F4E3B8.5020705@intel.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com> <1425290777-22702-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	jiri@resnulli.us, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44670 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937AbbCBW1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 17:27:07 -0500
In-Reply-To: <1425290777-22702-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2015 2:06 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add two new ndo ops (ndo_switch_fib_ipv4_add/del) for switchdev devices
> capable of offloading IPv4 L3 routing function from the kernel.  The ops are
> called by the core IPv4 FIB code when installing/removing/modifying FIB entries
> in the kernel FIB.  On install/modify, the driver should return 0 if FIB entry
> (route) can be installed/modified to device; -EOPNOTSUPP if route cannot be
> installed/modified due to device limitations; and any other negative error code
> on failure to install route to device.  On failure error code, the route is not
> installed to device, and not installed in kernel FIB, and the return code is
> propagated back to the user-space caller (via netlink).  An -EOPNOTSUPP error
> code is skipped for the device but installed in the kernel FIB.
>
> The FIB entry (route) nexthop list is used to find the switchdev netdev to
> anchor the ndo op call.  The route's fib_dev (the first nexthop's dev) is used
> find the switchdev netdev by recursively traversing the fib_dev's lower_dev
> list until a switchdev netdev is found.  The ndo op is called on this switchdev
> netdev.  This downward traversal is necessary for switchdev ports stacked under
> bonds and/or bridges, where the bond or bridge has the L3 interface.
>
> Thw switchdev driver can monitor netevent notifier NETEVENT_NEIGH_UPDATE to
> know neighbor IP addresses which are resolved to a MAC address.  In the case
> where the route's nexthops list contains unresolved neighbor IP addresses, the
> driver can ask the kernel to resolve the neighbor.  As route nexthops are
> resolved, the driver has enough information to program the device for
> L3 forwarding offload.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/netdevice.h |   22 +++++++++++
>   include/net/switchdev.h   |   19 +++++++++
>   net/ipv4/fib_trie.c       |   33 ++++++++++++++--
>   net/switchdev/switchdev.c |   95 +++++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 166 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5897b4e..73b2766 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -769,6 +769,8 @@ struct netdev_phys_item_id {
>   typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   				       struct sk_buff *skb);
>   
> +struct fib_info;
> +
>   /*
>    * This structure defines the management hooks for network devices.
>    * The following hooks can be defined; unless noted otherwise, they are
> @@ -1032,6 +1034,14 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>    *	Called to notify switch device port of bridge port STP
>    *	state change.
> + * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
> + *				     int dst_len, struct fib_info *fi,
> + *				     u8 tos, u8 type, u32 tb_id);
> + *	Called to add/modify IPv4 route to switch device.
> + * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
> + *				     int dst_len, struct fib_info *fi,
> + *				     u8 tos, u8 type, u32 tb_id);
> + *	Called to delete IPv4 route from switch device.
>    */
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1193,6 +1203,18 @@ struct net_device_ops {
>   							    struct netdev_phys_item_id *psid);
>   	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
>   							      u8 state);
> +	int			(*ndo_switch_fib_ipv4_add)(struct net_device *dev,
> +							   __be32 dst,
> +							   int dst_len,
> +							   struct fib_info *fi,
> +							   u8 tos, u8 type,
> +							   u32 tb_id);
> +	int			(*ndo_switch_fib_ipv4_del)(struct net_device *dev,
> +							   __be32 dst,
> +							   int dst_len,
> +							   struct fib_info *fi,
> +							   u8 tos, u8 type,
> +							   u32 tb_id);
>   #endif
>   };
>   

Don't we need ndo's to offload adding/deleting neighbor table entries 
and router interface or gateway addresses?
Is it expected that the switch driver can program the hardware in 
response to the neighbor update events?

Thanks
Sridhar
