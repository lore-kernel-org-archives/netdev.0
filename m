From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 1/4] net: Add SRIOV VGT+ support
Date: Sun, 27 Aug 2017 20:38:57 -0400
Message-ID: <20170827203857.369c2b16@cakuba>
References: <20170827110618.20599-1-saeedm@mellanox.com>
        <20170827110618.20599-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:32027 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbdH1Aj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:39:29 -0400
In-Reply-To: <20170827110618.20599-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 27 Aug 2017 14:06:15 +0300, Saeed Mahameed wrote:
> From: Mohamad Haj Yahia <mohamad@mellanox.com>
> 
> VGT+ is a security feature that gives the administrator the ability of
> controlling the allowed vlan-ids list that can be transmitted/received
> from/to the VF.
> The allowed vlan-ids list is called "trunk".
> Admin can add/remove a range of allowed vlan-ids via iptool.
> Example:
> After this series of configuration :
> 1) ip link set eth3 vf 0 trunk add 10 100 (allow vlan-id 10-100, default tpid 0x8100)
> 2) ip link set eth3 vf 0 trunk add 105 proto 802.1q (allow vlan-id 105 tpid 0x8100)
> 3) ip link set eth3 vf 0 trunk add 105 proto 802.1ad (allow vlan-id 105 tpid 0x88a8)
> 4) ip link set eth3 vf 0 trunk rem 90 (block vlan-id 90)
> 5) ip link set eth3 vf 0 trunk rem 50 60 (block vlan-ids 50-60)
> 
> The VF 0 can only communicate on vlan-ids: 10-49,61-89,91-100,105 with
> tpid 0x8100 and vlan-id 105 with tpid 0x88a8.
> 
> For this purpose we added the following netlink sr-iov commands:
> 
> 1) IFLA_VF_VLAN_RANGE: used to add/remove allowed vlan-ids range.
> We added the ifla_vf_vlan_range struct to specify the range we want to
> add/remove from the userspace.
> We added ndo_add_vf_vlan_trunk_range and ndo_del_vf_vlan_trunk_range
> netdev ops to add/remove allowed vlan-ids range in the netdev.
> 
> 2) IFLA_VF_VLAN_TRUNK: used to query the allowed vlan-ids trunk.
> We added trunk bitmap to the ifla_vf_info struct to get the current
> allowed vlan-ids trunk from the netdev.
> We added ifla_vf_vlan_trunk struct for sending the allowed vlan-ids
> trunk to the userspace.
> 
> Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Interesting work, I have some minor questions if you don't mind :)

I was under impression that "trunk" is a vendor-specific term, would it
make sense to drop it from the APIs?

> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 8d062c58d5cb..3aa895c5fbc1 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -168,6 +168,8 @@ enum {
>  #ifndef __KERNEL__
>  #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
>  #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
> +#define BITS_PER_BYTE 8
> +#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
>  #endif
>  
>  enum {
> @@ -645,6 +647,8 @@ enum {
>  	IFLA_VF_IB_NODE_GUID,	/* VF Infiniband node GUID */
>  	IFLA_VF_IB_PORT_GUID,	/* VF Infiniband port GUID */
>  	IFLA_VF_VLAN_LIST,	/* nested list of vlans, option for QinQ */
> +	IFLA_VF_VLAN_RANGE,	/* add/delete vlan range filtering */
> +	IFLA_VF_VLAN_TRUNK,	/* vlan trunk filtering */
>  	__IFLA_VF_MAX,
>  };
>  
> @@ -669,6 +673,7 @@ enum {
>  
>  #define IFLA_VF_VLAN_INFO_MAX (__IFLA_VF_VLAN_INFO_MAX - 1)
>  #define MAX_VLAN_LIST_LEN 1
> +#define VF_VLAN_N_VID 4096
>  
>  struct ifla_vf_vlan_info {
>  	__u32 vf;
> @@ -677,6 +682,21 @@ struct ifla_vf_vlan_info {
>  	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
>  };
>  
> +struct ifla_vf_vlan_range {
> +	__u32 vf;
> +	__u32 start_vid;   /* 1 - 4095 */
> +	__u32 end_vid;     /* 1 - 4095 */
> +	__u32 setting;
> +	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
> +};
> +
> +#define VF_VLAN_BITMAP	DIV_ROUND_UP(VF_VLAN_N_VID, sizeof(__u64) * BITS_PER_BYTE)
> +struct ifla_vf_vlan_trunk {
> +	__u32 vf;
> +	__u64 allowed_vlans_8021q_bm[VF_VLAN_BITMAP];
> +	__u64 allowed_vlans_8021ad_bm[VF_VLAN_BITMAP];
> +};

Would you mind explaining why you chose to make the API asymmetrical
like that?  I mean the set operation is range-based, yet the get
returns a bitmask.  You seem to solely depend on the bitmasks in the
driver anyway...

>  struct ifla_vf_tx_rate {
>  	__u32 vf;
>  	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a78fd61da0ec..56909f11d88e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -827,6 +827,7 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
>  			 nla_total_size(MAX_VLAN_LIST_LEN *
>  					sizeof(struct ifla_vf_vlan_info)) +
>  			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
> +			 nla_total_size(sizeof(struct ifla_vf_vlan_trunk)) +
>  			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
>  			 nla_total_size(sizeof(struct ifla_vf_rate)) +
>  			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
> @@ -1098,31 +1099,43 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
>  	struct ifla_vf_link_state vf_linkstate;
>  	struct ifla_vf_vlan_info vf_vlan_info;
>  	struct ifla_vf_spoofchk vf_spoofchk;
> +	struct ifla_vf_vlan_trunk *vf_trunk;
>  	struct ifla_vf_tx_rate vf_tx_rate;
>  	struct ifla_vf_stats vf_stats;
>  	struct ifla_vf_trust vf_trust;
>  	struct ifla_vf_vlan vf_vlan;
>  	struct ifla_vf_rate vf_rate;
>  	struct ifla_vf_mac vf_mac;
> -	struct ifla_vf_info ivi;
> +	struct ifla_vf_info *ivi;
>  
> -	memset(&ivi, 0, sizeof(ivi));
> +	ivi = kzalloc(sizeof(*ivi), GFP_KERNEL);
> +	if (!ivi)
> +		return -ENOMEM;

In the future please try to split code adjustments like allocating ivi
here into a separate patch.  Makes the changes a little more obvious to
read.
