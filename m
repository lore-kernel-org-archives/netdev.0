From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH bridge 3/5] bridge: Add vlan id to multicast groups
Date: Thu, 30 Aug 2012 15:30:46 +0300
Message-ID: <20120830123046.GD20228@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
 <1345750195-31598-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab2H3M31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 08:29:27 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7UCTRHU015540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 08:29:27 -0400
Content-Disposition: inline
In-Reply-To: <1345750195-31598-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 03:29:53PM -0400, Vlad Yasevich wrote:
> Add vlan_id to multicasts groups so that we know which vlan each group belongs
> to and can correctly forward to appropriate vlan.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_multicast.c |   64 +++++++++++++++++++++++++++++++--------------
>  net/bridge/br_private.h   |    1 +
>  2 files changed, 45 insertions(+), 20 deletions(-)
> 
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2417434..2976a2b 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -51,6 +51,8 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
>  {
>  	if (a->proto != b->proto)
>  		return 0;
> +	if (a->vid != b->vid)
> +		return 0;
>  	switch (a->proto) {
>  	case htons(ETH_P_IP):
>  		return a->u.ip4 == b->u.ip4;
> @@ -62,16 +64,19 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
>  	return 0;
>  }
>  
> -static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
> +static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip,
> +				__u16 vid)
>  {
> -	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
> +	return jhash_2words((__force u32)ip, vid, mdb->secret) & (mdb->max - 1);
>  }
>  
>  #if IS_ENABLED(CONFIG_IPV6)
>  static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
> -				const struct in6_addr *ip)
> +				const struct in6_addr *ip,
> +				__u16 vid)
>  {
> -	return jhash2((__force u32 *)ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
> +	u32 addr = *(__force u32 *)ip->s6_addr32;
> +	return jhash_2words(addr, vid, mdb->secret) & (mdb->max - 1);
>  }
>  #endif
>  
> @@ -80,10 +85,10 @@ static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
>  {
>  	switch (ip->proto) {
>  	case htons(ETH_P_IP):
> -		return __br_ip4_hash(mdb, ip->u.ip4);
> +		return __br_ip4_hash(mdb, ip->u.ip4, ip->vid);
>  #if IS_ENABLED(CONFIG_IPV6)
>  	case htons(ETH_P_IPV6):
> -		return __br_ip6_hash(mdb, &ip->u.ip6);
> +		return __br_ip6_hash(mdb, &ip->u.ip6, ip->vid);
>  #endif
>  	}
>  	return 0;
> @@ -113,24 +118,27 @@ static struct net_bridge_mdb_entry *br_mdb_ip_get(
>  }
>  
>  static struct net_bridge_mdb_entry *br_mdb_ip4_get(
> -	struct net_bridge_mdb_htable *mdb, __be32 dst)
> +	struct net_bridge_mdb_htable *mdb, __be32 dst, __u16 vlan_tci)
>  {
>  	struct br_ip br_dst;
>  
>  	br_dst.u.ip4 = dst;
>  	br_dst.proto = htons(ETH_P_IP);
> +	br_dst.vid = (vlan_tci & VLAN_VID_MASK);

() around value not needed.
Same in all cases below, I am not repeating
this comment.

>  
>  	return br_mdb_ip_get(mdb, &br_dst);
>  }
>  
>  #if IS_ENABLED(CONFIG_IPV6)
>  static struct net_bridge_mdb_entry *br_mdb_ip6_get(
> -	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
> +	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst,
> +	__u16 vlan_tci)
>  {
>  	struct br_ip br_dst;
>  
>  	br_dst.u.ip6 = *dst;
>  	br_dst.proto = htons(ETH_P_IPV6);
> +	br_dst.vid = vlan_tci & VLAN_VID_MASK;
>  
>  	return br_mdb_ip_get(mdb, &br_dst);
>  }
> @@ -692,7 +700,8 @@ err:
>  
>  static int br_ip4_multicast_add_group(struct net_bridge *br,
>  				      struct net_bridge_port *port,
> -				      __be32 group)
> +				      __be32 group,
> +				      __u16 vlan_tci)
>  {
>  	struct br_ip br_group;
>  
> @@ -701,6 +710,7 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
>  
>  	br_group.u.ip4 = group;
>  	br_group.proto = htons(ETH_P_IP);
> +	br_group.vid = vlan_tci & VLAN_VID_MASK;
>  
>  	return br_multicast_add_group(br, port, &br_group);
>  }
> @@ -708,7 +718,8 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
>  #if IS_ENABLED(CONFIG_IPV6)
>  static int br_ip6_multicast_add_group(struct net_bridge *br,
>  				      struct net_bridge_port *port,
> -				      const struct in6_addr *group)
> +				      const struct in6_addr *group,
> +				      __u16 vlan_tci)
>  {
>  	struct br_ip br_group;
>  
> @@ -717,6 +728,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
>  
>  	br_group.u.ip6 = *group;
>  	br_group.proto = htons(ETH_P_IPV6);
> +	br_group.vid = vlan_tci & VLAN_VID_MASK;
>  
>  	return br_multicast_add_group(br, port, &br_group);
>  }
> @@ -928,7 +940,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
>  			continue;
>  		}
>  
> -		err = br_ip4_multicast_add_group(br, port, group);
> +		err = br_ip4_multicast_add_group(br, port, group,
> +						skb->vlan_tci);


Pls align continuation line at (, same as other
code in this file. Same in all cases below, I am not repeating
this comment.

>  		if (err)
>  			break;
>  	}
> @@ -988,7 +1001,8 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
>  			continue;
>  		}
>  
> -		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
> +		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
> +						skb->vlan_tci);
>  		if (!err)
>  			break;
>  	}
> @@ -1106,7 +1120,8 @@ static int br_ip4_multicast_query(struct net_bridge *br,
>  	if (!group)
>  		goto out;
>  
> -	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group);
> +	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group,
> +				skb->vlan_tci);
>  	if (!mp)
>  		goto out;
>  
> @@ -1178,7 +1193,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
>  	if (!group)
>  		goto out;
>  
> -	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group);
> +	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group,
> +			skb->vlan_tci);
>  	if (!mp)
>  		goto out;
>  
> @@ -1262,7 +1278,8 @@ out:
>  
>  static void br_ip4_multicast_leave_group(struct net_bridge *br,
>  					 struct net_bridge_port *port,
> -					 __be32 group)
> +					 __be32 group,
> +					 __u16 vlan_tci)
>  {
>  	struct br_ip br_group;
>  
> @@ -1271,6 +1288,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
>  
>  	br_group.u.ip4 = group;
>  	br_group.proto = htons(ETH_P_IP);
> +	br_group.vid = (vlan_tci & VLAN_VID_MASK);
>  
>  	br_multicast_leave_group(br, port, &br_group);
>  }
> @@ -1278,7 +1296,8 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
>  #if IS_ENABLED(CONFIG_IPV6)
>  static void br_ip6_multicast_leave_group(struct net_bridge *br,
>  					 struct net_bridge_port *port,
> -					 const struct in6_addr *group)
> +					 const struct in6_addr *group,
> +					 __u16 vlan_tci)
>  {
>  	struct br_ip br_group;
>  
> @@ -1287,6 +1306,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
>  
>  	br_group.u.ip6 = *group;
>  	br_group.proto = htons(ETH_P_IPV6);
> +	br_group.vid = (vlan_tci & VLAN_VID_MASK);
>  
>  	br_multicast_leave_group(br, port, &br_group);
>  }
> @@ -1369,7 +1389,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
>  	case IGMP_HOST_MEMBERSHIP_REPORT:
>  	case IGMPV2_HOST_MEMBERSHIP_REPORT:
>  		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
> -		err = br_ip4_multicast_add_group(br, port, ih->group);
> +		err = br_ip4_multicast_add_group(br, port, ih->group,
> +						skb2->vlan_tci);
>  		break;
>  	case IGMPV3_HOST_MEMBERSHIP_REPORT:
>  		err = br_ip4_multicast_igmp3_report(br, port, skb2);
> @@ -1378,7 +1399,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
>  		err = br_ip4_multicast_query(br, port, skb2);
>  		break;
>  	case IGMP_HOST_LEAVE_MESSAGE:
> -		br_ip4_multicast_leave_group(br, port, ih->group);
> +		br_ip4_multicast_leave_group(br, port, ih->group,
> +						skb2->vlan_tci);
>  		break;
>  	}
>  
> @@ -1498,7 +1520,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
>  		}
>  		mld = (struct mld_msg *)skb_transport_header(skb2);
>  		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
> -		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
> +		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca,
> +						 skb2->vlan_tci);
>  		break;
>  	    }
>  	case ICMPV6_MLD2_REPORT:
> @@ -1515,7 +1538,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
>  			goto out;
>  		}
>  		mld = (struct mld_msg *)skb_transport_header(skb2);
> -		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
> +		br_ip6_multicast_leave_group(br, port, &mld->mld_mca,
> +						skb2->vlan_tci);
>  	    }
>  	}
>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 921b927..b6c56ab 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -61,6 +61,7 @@ struct br_ip
>  #endif
>  	} u;
>  	__be16		proto;
> +	__u16		vid;
>  };
>  
>  struct net_bridge_fdb_entry
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
