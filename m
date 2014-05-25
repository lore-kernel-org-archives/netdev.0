From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1] bridge netlink interface at par with brctl
 show macs
Date: Sun, 25 May 2014 09:15:23 -0400
Message-ID: <5381ECEB.7030200@mojatatu.com>
References: <1401023042-6902-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, john.r.fastabend@intel.com,
	sfeldma@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:54933 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaEYNP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 09:15:26 -0400
Received: by mail-ig0-f178.google.com with SMTP id hl10so2281925igb.11
        for <netdev@vger.kernel.org>; Sun, 25 May 2014 06:15:25 -0700 (PDT)
In-Reply-To: <1401023042-6902-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Grrr... Just noticed a debug statement in there - will resend.

cheers,
jamal

On 05/25/14 09:04, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This patch allows something equivalent to
> "brctl showmacs <bridge device>" with iproute2
> syntax "bridge fdb show br <bridge device>"
> Filtering by bridge is done in the kernel.
> The current setup doesnt scale when you have many bridges each
> with large fdbs (preliminary fix with the kernel patch).
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   net/core/rtnetlink.c |   50 +++++++++++++++++++++++++++++++++++---------------
>   1 file changed, 35 insertions(+), 15 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index f31268d..a605742 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2509,26 +2509,46 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>   {
>   	int idx = 0;
>   	struct net *net = sock_net(skb->sk);
> +	const struct net_device_ops *ops;
>   	struct net_device *dev;
> +	struct ndmsg *ndm;
>
> -	rcu_read_lock();
> -	for_each_netdev_rcu(net, dev) {
> -		if (dev->priv_flags & IFF_BRIDGE_PORT) {
> -			struct net_device *br_dev;
> -			const struct net_device_ops *ops;
> -
> -			br_dev = netdev_master_upper_dev_get(dev);
> -			ops = br_dev->netdev_ops;
> -			if (ops->ndo_fdb_dump)
> -				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +	ndm = nlmsg_data(cb->nlh);
> +	if (ndm->ndm_ifindex) {
> +		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
> +		if (dev == NULL) {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
> +			return -ENODEV;
>   		}
>
> -		if (dev->netdev_ops->ndo_fdb_dump)
> -			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
> -		else
> -			idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
> +		printk("Requested for bridge <%s>\n", dev->name);
> +		ops = dev->netdev_ops;
> +		if (ops->ndo_fdb_dump) {
> +			idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +		} else {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
> +				dev->name);
> +			return -EINVAL;
> +		}
> +	} else {
> +		rcu_read_lock();
> +		for_each_netdev_rcu(net, dev) {
> +			if (dev->priv_flags & IFF_BRIDGE_PORT) {
> +				struct net_device *br_dev;
> +				br_dev = netdev_master_upper_dev_get(dev);
> +				ops = br_dev->netdev_ops;
> +				if (ops->ndo_fdb_dump)
> +					idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +			}
> +
> +			if (dev->netdev_ops->ndo_fdb_dump)
> +				idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev,
> +								    idx);
> +			else
> +				idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
> +		}
> +		rcu_read_unlock();
>   	}
> -	rcu_read_unlock();
>
>   	cb->args[0] = idx;
>   	return skb->len;
>
