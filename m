From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add igmpv3 and mldv2 query support
Date: Fri, 18 Nov 2016 11:04:46 +0100
Message-ID: <9c1e16c2-b716-21e0-fa2c-3e3126607953@cumulusnetworks.com>
References: <1479454321-31304-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linus.luessing@c0d3.blue, roopa <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36520 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbcKRKEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 05:04:49 -0500
Received: by mail-wm0-f44.google.com with SMTP id g23so27311421wme.1
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 02:04:49 -0800 (PST)
In-Reply-To: <1479454321-31304-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/11/16 08:32, Hangbin Liu wrote:
> Add bridge IGMPv3 and MLDv2 query support. But before we think it is stable
> enough, only enable it when declare in force_igmp/mld_version.
>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/bridge/br_multicast.c | 203 ++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 194 insertions(+), 9 deletions(-)
>

(+CC Roopa)
Hi Hangbin,
This patch is not correct, you should not use the port net device IGMP config in the bridge.
These packets may never make it to the host and they may not be reflected, even more the
host may have very different igmp config for the port net device than the bridge does.
Also your current implementation switches to V3 only if it is globally set, and that should
be controlled on a per-bridge basis, even per-vlan later.
One more thing, if someone does a V2 leave for a group, you can end up sending them V3
group-specific query.

I have been working on an implementation for IGMPv3/MLDv2 querier for the bridge device, it re-uses
most of the current code and allows you to configure it per-bridge (and later per-vlan). The only
reason I've not yet sent it to upstream is that we (at Cumulus) are working out the compatibility
parts (e.g. RFC3376 sec 7, sec 8) of the RFC since it has some unclear cases.
But I can rip the compatibility out and send it early for review if you'd like, we can add the
compat code later.

Cheers,
  Nik

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2136e45..9fb47f3 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -35,6 +35,10 @@
>
>  #include "br_private.h"
>
> +#define IGMP_V3_SEEN(in_dev) \
> +	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 3 || \
> +	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 3)
> +
>  static void br_multicast_start_querier(struct net_bridge *br,
>  				       struct bridge_mcast_own_query *query);
>  static void br_multicast_add_router(struct net_bridge *br,
> @@ -360,9 +364,8 @@ static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
>  	return 0;
>  }
>
> -static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
> -						    __be32 group,
> -						    u8 *igmp_type)
> +static struct sk_buff *br_ip4_alloc_query_v2(struct net_bridge *br,
> +					     __be32 group, u8 *igmp_type)
>  {
>  	struct sk_buff *skb;
>  	struct igmphdr *ih;
> @@ -428,10 +431,82 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
>  	return skb;
>  }
>
> +static struct sk_buff *br_ip4_alloc_query_v3(struct net_bridge *br,
> +					     __be32 group, u8 *igmp_type)
> +{
> +	struct sk_buff *skb;
> +	struct igmpv3_query *ih3;
> +	struct ethhdr *eth;
> +	struct iphdr *iph;
> +
> +	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*iph) +
> +						 sizeof(*ih3) + 4);
> +	if (!skb)
> +		goto out;
> +
> +	skb->protocol = htons(ETH_P_IP);
> +
> +	skb_reset_mac_header(skb);
> +	eth = eth_hdr(skb);
> +
> +	ether_addr_copy(eth->h_source, br->dev->dev_addr);
> +	eth->h_dest[0] = 1;
> +	eth->h_dest[1] = 0;
> +	eth->h_dest[2] = 0x5e;
> +	eth->h_dest[3] = 0;
> +	eth->h_dest[4] = 0;
> +	eth->h_dest[5] = 1;
> +	eth->h_proto = htons(ETH_P_IP);
> +	skb_put(skb, sizeof(*eth));
> +
> +	skb_set_network_header(skb, skb->len);
> +	iph = ip_hdr(skb);
> +
> +	iph->version = 4;
> +	iph->ihl = 6;
> +	iph->tos = 0xc0;
> +	iph->tot_len = htons(sizeof(*iph) + sizeof(*ih3) + 4);
> +	iph->id = 0;
> +	iph->frag_off = htons(IP_DF);
> +	iph->ttl = 1;
> +	iph->protocol = IPPROTO_IGMP;
> +	iph->saddr = br->multicast_query_use_ifaddr ?
> +		     inet_select_addr(br->dev, 0, RT_SCOPE_LINK) : 0;
> +	iph->daddr = htonl(INADDR_ALLHOSTS_GROUP);
> +	((u8 *)&iph[1])[0] = IPOPT_RA;
> +	((u8 *)&iph[1])[1] = 4;
> +	((u8 *)&iph[1])[2] = 0;
> +	((u8 *)&iph[1])[3] = 0;
> +	ip_send_check(iph);
> +	skb_put(skb, 24);
> +
> +	skb_set_transport_header(skb, skb->len);
> +	ih3 = igmpv3_query_hdr(skb);
> +
> +	*igmp_type = IGMP_HOST_MEMBERSHIP_QUERY;
> +	ih3->type = IGMP_HOST_MEMBERSHIP_QUERY;
> +	ih3->code = (group ? br->multicast_last_member_interval :
> +			    br->multicast_query_response_interval) /
> +		   (HZ / IGMP_TIMER_SCALE);
> +	ih3->csum = 0;
> +	ih3->group = group;
> +	ih3->resv = 0;
> +	ih3->suppress = 0;
> +	ih3->qrv= 2;
> +	ih3->qqic = br->multicast_query_interval / HZ;
> +	ih3->nsrcs = 0;
> +	ih3->csum = ip_compute_csum((void *)ih3, sizeof(struct igmpv3_query ));
> +	skb_put(skb, sizeof(*ih3));
> +
> +	__skb_pull(skb, sizeof(*eth));
> +
> +out:
> +	return skb;
> +}
>  #if IS_ENABLED(CONFIG_IPV6)
> -static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
> -						    const struct in6_addr *grp,
> -						    u8 *igmp_type)
> +static struct sk_buff *br_ip6_alloc_query_v1(struct net_bridge *br,
> +					     const struct in6_addr *grp,
> +					     u8 *igmp_type)
>  {
>  	struct sk_buff *skb;
>  	struct ipv6hdr *ip6h;
> @@ -514,19 +589,129 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
>  out:
>  	return skb;
>  }
> +
> +static struct sk_buff *br_ip6_alloc_query_v2(struct net_bridge *br,
> +					     const struct in6_addr *grp,
> +					     u8 *igmp_type)
> +{
> +	struct sk_buff *skb;
> +	struct ipv6hdr *ip6h;
> +	struct mld2_query *mld2q;
> +	struct ethhdr *eth;
> +	u8 *hopopt;
> +	unsigned long interval;
> +
> +	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*ip6h) +
> +						 8 + sizeof(*mld2q));
> +	if (!skb)
> +		goto out;
> +
> +	skb->protocol = htons(ETH_P_IPV6);
> +
> +	/* Ethernet header */
> +	skb_reset_mac_header(skb);
> +	eth = eth_hdr(skb);
> +
> +	ether_addr_copy(eth->h_source, br->dev->dev_addr);
> +	eth->h_proto = htons(ETH_P_IPV6);
> +	skb_put(skb, sizeof(*eth));
> +
> +	/* IPv6 header + HbH option */
> +	skb_set_network_header(skb, skb->len);
> +	ip6h = ipv6_hdr(skb);
> +
> +	*(__force __be32 *)ip6h = htonl(0x60000000);
> +	ip6h->payload_len = htons(8 + sizeof(*mld2q));
> +	ip6h->nexthdr = IPPROTO_HOPOPTS;
> +	ip6h->hop_limit = 1;
> +	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
> +	if (ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
> +			       &ip6h->saddr)) {
> +		kfree_skb(skb);
> +		br->has_ipv6_addr = 0;
> +		return NULL;
> +	}
> +
> +	br->has_ipv6_addr = 1;
> +	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
> +
> +	hopopt = (u8 *)(ip6h + 1);
> +	hopopt[0] = IPPROTO_ICMPV6;		/* next hdr */
> +	hopopt[1] = 0;				/* length of HbH */
> +	hopopt[2] = IPV6_TLV_ROUTERALERT;	/* Router Alert */
> +	hopopt[3] = 2;				/* Length of RA Option */
> +	hopopt[4] = 0;				/* Type = 0x0000 (MLD) */
> +	hopopt[5] = 0;
> +	hopopt[6] = IPV6_TLV_PAD1;		/* Pad1 */
> +	hopopt[7] = IPV6_TLV_PAD1;		/* Pad1 */
> +
> +	skb_put(skb, sizeof(*ip6h) + 8);
> +
> +	/* ICMPv6 */
> +	skb_set_transport_header(skb, skb->len);
> +	mld2q = (struct mld2_query *) icmp6_hdr(skb);
> +
> +	interval = ipv6_addr_any(grp) ?
> +			br->multicast_query_response_interval :
> +			br->multicast_last_member_interval;
> +
> +	*igmp_type = ICMPV6_MGM_QUERY;
> +	mld2q->mld2q_type = ICMPV6_MGM_QUERY;
> +	mld2q->mld2q_code = 0;
> +	mld2q->mld2q_cksum = 0;
> +	mld2q->mld2q_mrc = htons((u16)jiffies_to_msecs(interval));
> +	mld2q->mld2q_resv1 = 0;
> +	mld2q->mld2q_mca = *grp;
> +	mld2q->mld2q_resv2 = 0;
> +	mld2q->mld2q_suppress = 0;
> +	mld2q->mld2q_qrv = 2;
> +	mld2q->mld2q_qqic = br->multicast_query_interval / HZ;
> +	mld2q->mld2q_nsrcs = 0;
> +
> +	/* checksum */
> +	mld2q->mld2q_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
> +					  sizeof(*mld2q), IPPROTO_ICMPV6,
> +					  csum_partial(mld2q,
> +						       sizeof(*mld2q), 0));
> +	skb_put(skb, sizeof(*mld2q));
> +
> +	__skb_pull(skb, sizeof(*eth));
> +
> +out:
> +	return skb;
> +}
>  #endif
>
> +static int mld_force_mld_version(const struct inet6_dev *idev)
> +{
> +	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version != 0)
> +		return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version;
> +	else
> +		return idev->cnf.force_mld_version;
> +}
> +
>  static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
>  						struct br_ip *addr,
>  						u8 *igmp_type)
>  {
> +	struct in_device *in_dev = __in_dev_get_rcu(br->dev);
> +	struct inet6_dev *idev = __in6_dev_get(br->dev);
>  	switch (addr->proto) {
>  	case htons(ETH_P_IP):
> -		return br_ip4_multicast_alloc_query(br, addr->u.ip4, igmp_type);
> +		if (IGMP_V3_SEEN(in_dev))
> +			return br_ip4_alloc_query_v3(br, addr->u.ip4,
> +						     igmp_type);
> +		else
> +			return br_ip4_alloc_query_v2(br, addr->u.ip4,
> +						     igmp_type);
>  #if IS_ENABLED(CONFIG_IPV6)
>  	case htons(ETH_P_IPV6):
> -		return br_ip6_multicast_alloc_query(br, &addr->u.ip6,
> -						    igmp_type);
> +		if (mld_force_mld_version(idev) == 2)
> +			return br_ip6_alloc_query_v2(br, &addr->u.ip6,
> +						     igmp_type);
> +		else
> +			return br_ip6_alloc_query_v1(br, &addr->u.ip6,
> +						     igmp_type);
>  #endif
>  	}
>  	return NULL;
>
