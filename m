From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 3/3] mpls: add multipath route support
Date: Wed, 12 Aug 2015 20:18:55 +0100
Message-ID: <55CB9C1F.7000702@brocade.com>
References: <1439329548-50935-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:21605 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750826AbbHLTTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 15:19:10 -0400
In-Reply-To: <1439329548-50935-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/15 22:45, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Adds support for MPLS multipath routes.
> supports parse/fill of RTA_MULTIPATH netlink attribute
> for multipath routes similar to ipv4 fib. Mostly based on
> multipath handling in ipv4 fib code.
>
> The multipath route nexthop selection algorithm is the same
> code as in ipv4 fib.
>
> This patch also adds new functions to parse multipath attributes
> from route config into mpls_nhlfe.
>
> note that it also simplifies mpls_route_update. Removes handling
> route updates based on dev argument. The reason for
> doing that is, the function was not being used for route updates
> based on dev and if we do need to support route updates based
> on dev in the future it will have to be done differently.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   net/mpls/af_mpls.c  |  378 +++++++++++++++++++++++++++++++++++++++++----------
>   net/mpls/internal.h |   19 +++
>   2 files changed, 323 insertions(+), 74 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index eb089ef..de5ae29 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -19,10 +19,12 @@
>   #include <net/ipv6.h>
>   #include <net/addrconf.h>
>   #endif
> +#include <net/nexthop.h>
>   #include "internal.h"
>
>   static int zero = 0;
>   static int label_limit = (1 << 20) - 1;
> +static DEFINE_SPINLOCK(mpls_multipath_lock);
>
>   static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>   		       struct nlmsghdr *nlh, struct net *net, u32 portid,
> @@ -51,10 +53,10 @@ bool mpls_output_possible(const struct net_device *dev)
>   }
>   EXPORT_SYMBOL_GPL(mpls_output_possible);
>
> -static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
> +static unsigned int mpls_nhlfe_header_size(const struct mpls_nhlfe *nhlfe)
>   {
>   	/* The size of the layer 2.5 labels to be added for this route */
> -	return rt->rt_nh->nh_labels * sizeof(struct mpls_shim_hdr);
> +	return nhlfe->nh_labels * sizeof(struct mpls_shim_hdr);
>   }
>
>   unsigned int mpls_dev_mtu(const struct net_device *dev)
> @@ -76,7 +78,52 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>   }
>   EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
>
> -static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
> +/* This is a cut/copy/modify from fib_select_multipath */
> +static void mpls_select_multipath(struct mpls_route *rt, int *nhidx)
> +{
> +	int w;
> +
> +	spin_lock_bh(&mpls_multipath_lock);
> +	if (rt->rt_power <= 0) {
> +		int power = 0;
> +
> +		change_nexthops(rt) {
> +			power += nhlfe->nh_weight;
> +			nhlfe->nh_power = nhlfe->nh_weight;
> +		} endfor_nexthops(rt);
> +		rt->rt_power = power;
> +		if (power <= 0) {
> +			spin_unlock_bh(&mpls_multipath_lock);
> +			/* Race condition: route has just become dead. */
> +			*nhidx = 0;
> +			return;
> +		}
> +	}
> +
> +	/* w should be random number [0..rt->rt_power-1],
> +	 * it is pretty bad approximation.
> +	 */
> +	w = jiffies % rt->rt_power;
> +
> +	change_nexthops(rt) {
> +		if (nhlfe->nh_power) {
> +			w -= nhlfe->nh_power;
> +			if (w <= 0) {
> +				nhlfe->nh_power--;
> +				rt->rt_power--;
> +				*nhidx = nhsel;
> +				spin_unlock_bh(&mpls_multipath_lock);
> +				return;
> +			}
> +		}
> +	} endfor_nexthops(rt);
> +
> +	/* Race condition: route has just become dead. */
> +	*nhidx = 0;
> +	spin_unlock_bh(&mpls_multipath_lock);
> +}

If we were to do flow-based hashing then this would also avoid the 
locking required here.

> +
> +static bool mpls_egress(struct mpls_nhlfe *nhlfe, struct sk_buff *skb,
>   			struct mpls_entry_decoded dec)
>   {
>   	enum mpls_payload_type payload_type;
> @@ -95,7 +142,7 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>   	if (!pskb_may_pull(skb, 12))
>   		return false;
>
> -	payload_type = rt->rt_nh->nh_payload_type;
> +	payload_type = nhlfe->nh_payload_type;
>   	if (payload_type == MPT_UNSPEC)
>   		payload_type = ip_hdr(skb)->version;
>
> @@ -130,6 +177,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	struct net *net = dev_net(dev);
>   	struct mpls_shim_hdr *hdr;
>   	struct mpls_route *rt;
> +	struct mpls_nhlfe *nhlfe;
>   	struct mpls_entry_decoded dec;
>   	struct net_device *out_dev;
>   	struct mpls_dev *mdev;
> @@ -137,6 +185,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	unsigned int new_header_size;
>   	unsigned int mtu;
>   	int err;
> +	int nhidx;
>
>   	/* Careful this entire function runs inside of an rcu critical section */
>
> @@ -167,9 +216,12 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	if (!rt)
>   		goto drop;
>
> +	mpls_select_multipath(rt, &nhidx);
> +	nhlfe = &rt->rt_nh[nhidx];

How about just returning the nexthop from mpls_select_multipath rather 
than going via nhidx?

> +
>   	/* Find the output device */
> -	out_dev = rcu_dereference(rt->rt_nh->nh_dev);
> -	if (!mpls_output_possible(out_dev))
> +	out_dev = rcu_dereference(nhlfe->nh_dev);
> +	if (!out_dev || !mpls_output_possible(out_dev))
>   		goto drop;
>
>   	if (skb_warn_if_lro(skb))
...
> @@ -796,6 +954,48 @@ int nla_get_labels(const struct nlattr *nla,
>   }
>   EXPORT_SYMBOL_GPL(nla_get_labels);
>
> +int nla_get_via(const struct nlattr *nla, u8 *via_alen,
> +		u8 *via_table, u8 via_addr[])

This isn't used by any other source files so couldn't this be made static?

> +{
> +	struct rtvia *via = nla_data(nla);
> +	int err = -EINVAL;
> +	u8 alen;

Should this be an int to avoid false negatives below for large values of 
nla_len?

> +
> +	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
> +		goto errout;
> +	alen = nla_len(nla) -
> +			offsetof(struct rtvia, rtvia_addr);
> +	if (alen > MAX_VIA_ALEN)
> +		goto errout;
> +
> +	/* Validate the address family */
> +	switch (via->rtvia_family) {
> +	case AF_PACKET:
> +		*via_table = NEIGH_LINK_TABLE;
> +		break;
> +	case AF_INET:
> +		*via_table = NEIGH_ARP_TABLE;
> +		if (alen != 4)
> +			goto errout;
> +		break;
> +	case AF_INET6:
> +		*via_table = NEIGH_ND_TABLE;
> +		if (alen != 16)
> +			goto errout;
> +		break;
> +	default:
> +		/* Unsupported address family */
> +		goto errout;
> +	}
> +
> +	memcpy(via_addr, via->rtvia_addr, alen);
> +	*via_alen = alen;
> +	err = 0;
> +
> +errout:
> +	return err;
> +}
> +
>   static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>   			       struct mpls_route_config *cfg)
>   {
> @@ -872,35 +1072,15 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>   		}
>   		case RTA_VIA:
>   		{
> -			struct rtvia *via = nla_data(nla);
> -			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
> -				goto errout;
> -			cfg->rc_via_alen   = nla_len(nla) -
> -				offsetof(struct rtvia, rtvia_addr);
> -			if (cfg->rc_via_alen > MAX_VIA_ALEN)
> -				goto errout;
> -
> -			/* Validate the address family */
> -			switch(via->rtvia_family) {
> -			case AF_PACKET:
> -				cfg->rc_via_table = NEIGH_LINK_TABLE;
> -				break;
> -			case AF_INET:
> -				cfg->rc_via_table = NEIGH_ARP_TABLE;
> -				if (cfg->rc_via_alen != 4)
> -					goto errout;
> -				break;
> -			case AF_INET6:
> -				cfg->rc_via_table = NEIGH_ND_TABLE;
> -				if (cfg->rc_via_alen != 16)
> -					goto errout;
> -				break;
> -			default:
> -				/* Unsupported address family */
> +			if (nla_get_via(nla, &cfg->rc_via_alen,
> +					&cfg->rc_via_table, cfg->rc_via))
>   				goto errout;
> -			}
> -
> -			memcpy(cfg->rc_via, via->rtvia_addr, cfg->rc_via_alen);
> +			break;
> +		}
> +		case RTA_MULTIPATH:
> +		{
> +			cfg->rc_mp = nla_data(nla);
> +			cfg->rc_mp_len = nla_len(nla);
>   			break;
>   		}

Nit: these scope brackets can be removed here and now above for the 
RTA_VIA case.

>   		default:

Thanks,
Rob
