From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [net-next PATCH 2/2] bridge: netlink dump interface at par with
 brctl
Date: Mon, 09 Jun 2014 12:41:40 -0400
Message-ID: <5395E3C4.5080904@redhat.com>
References: <1402151244-3324-1-git-send-email-jhs@emojatatu.com> <1402151244-3324-2-git-send-email-jhs@emojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbaFIQmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 12:42:17 -0400
In-Reply-To: <1402151244-3324-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2014 10:27 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Actually better than brctl showmacs because we can filter by bridge
> port in the kernel.
> The current bridge netlink interface doesnt scale when you have many
> bridges each with large fdbs or even bridges with many bridge ports
> 
> For example usage look at accompanying iproute2 patch.

The code was a bit tough to follow.  I think the main reason is
that you now always pass a filtering devices even when there was
no filtering information requested.

I am wondering if it could be made simpler...

> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/bridge/br_fdb.c  |   17 +++++++++---
>  net/core/rtnetlink.c |   71 +++++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 72 insertions(+), 16 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 48449fc..7114382 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -694,9 +694,20 @@ int br_fdb_dump(struct sk_buff *skb,
>  			if (idx < cb->args[0])
>  				goto skip;
>  
> -			if (filter_dev && (!f->dst || !f->dst->dev ||
> -					   f->dst->dev != filter_dev))
> -				goto skip;
> +			if (filter_dev && (!f->dst || f->dst->dev != filter_dev)) {
> +				if (filter_dev != dev)
> +					goto skip;
> +				else {
> +					/* 
> +					 * !f->dst is a speacial case for bridge
> +					 * It means the MAC belongs to the bridge
> +					 * Therefore need a little more filtering
> +					 * we only want to dump the !f->dst case
> +					 */
> +					if (f->dst)
> +						goto skip;
> +				}
> +			}
>  
>  			if (fdb_fill_info(skb, br, f,
>  					  NETLINK_CB(cb->skb).portid,
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 8721f1b..2a3c225 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2512,26 +2512,71 @@ EXPORT_SYMBOL(ndo_dflt_fdb_dump);
>  
>  static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> -	int idx = 0;
> -	struct net *net = sock_net(skb->sk);
>  	struct net_device *dev;
> +	struct nlattr *tb[IFLA_MAX+1];
> +	struct net_device *bdev = NULL; /*pacify stoopid gcc*/
> +	struct net_device *br_dev = NULL; /*pacify stoopid gcc*/
> +	const struct net_device_ops *ops = NULL; /*pacify stoopid gcc*/
> +	struct ifinfomsg *ifm = nlmsg_data(cb->nlh);
> +	struct net *net = sock_net(skb->sk);
> +	int brport_idx = 0;
> +	int br_idx = 0;
> +	int idx = 0;
> +
> +	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
> +			ifla_policy) == 0) {
> +		if (tb[IFLA_MASTER])
> +			br_idx = nla_get_u32(tb[IFLA_MASTER]);
> +	}
> +	
> +	brport_idx = ifm->ifi_index;
>  
>  	rcu_read_lock();
> +	if (br_idx) {
> +		br_dev = __dev_get_by_index(net, br_idx);
> +		if (!br_dev) {
> +			rcu_read_unlock();
> +			return -ENODEV;
> +		}
> +		ops = br_dev->netdev_ops;
> +		bdev = br_dev;
> +	}
> +

I think this can be outside of the rcu since you hold an rtnl at this time.

-vlad

>  	for_each_netdev_rcu(net, dev) {
> -		if (dev->priv_flags & IFF_BRIDGE_PORT) {
> -			struct net_device *br_dev;
> -			const struct net_device_ops *ops;
> -
> -			br_dev = netdev_master_upper_dev_get(dev);
> -			ops = br_dev->netdev_ops;
> -			if (ops->ndo_fdb_dump)
> -				idx = ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
> +
> +		if (brport_idx && (dev->ifindex != brport_idx))
> +			continue;
> +
> +		if (!br_idx) { /* user did not specify a specific bridge */
> +			if (dev->priv_flags & IFF_BRIDGE_PORT) {
> +				br_dev = netdev_master_upper_dev_get(dev);
> +				ops = br_dev->netdev_ops;
> +				if (ops->ndo_fdb_dump)
> +					idx = ops->ndo_fdb_dump(skb, cb, br_dev,
> +								dev, idx);
> +			}
> +
> +			bdev = dev;
> +		} else {
> +			if (dev != br_dev &&
> +			    !(dev->priv_flags & IFF_BRIDGE_PORT))
> +				continue;
> +
> +			if (br_dev != netdev_master_upper_dev_get(dev) &&
> +			    !(dev->priv_flags & IFF_EBRIDGE))
> +				continue;
> +
> +			if (dev->priv_flags & IFF_BRIDGE_PORT)
> +				idx = ops->ndo_fdb_dump(skb, cb, br_dev,
> +							dev, idx);
>  		}
>  
> -		if (dev->netdev_ops->ndo_fdb_dump)
> -			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
> -		else
> +		if (dev->netdev_ops->ndo_fdb_dump) {
> +			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
> +							    idx);
> +		} else {
>  			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
> +		}
>  	}
>  	rcu_read_unlock();
>  
> 
