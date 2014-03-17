From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Mon, 17 Mar 2014 11:08:37 +0800
Message-ID: <53266735.8050607@huawei.com>
References: <5321165A.1000208@huawei.com> <20140314.220253.2108022241165181233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ben@decadent.org.uk>, <john.r.fastabend@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:10987 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818AbaCQDJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 23:09:55 -0400
In-Reply-To: <20140314.220253.2108022241165181233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/15 10:02, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Thu, 13 Mar 2014 10:22:18 +0800
> 
>> When I open the LOCKDEP config and run these steps:
> 
> This doesn't work?
> 

It make no sense, I have try it before, the class check only focus on the lock_class_key,
not the lockdep_subclass_key.

Regards
Ding

> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 4b65aa4..9ad89ff 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -556,10 +556,22 @@ static struct device_type vlan_type = {
>  
>  static const struct net_device_ops vlan_netdev_ops;
>  
> +static int vlan_calculate_locking_subclass(struct net_device *real_dev)
> +{
> +	int subclass = 0;
> +
> +	while (is_vlan_dev(real_dev)) {
> +		subclass++;
> +		real_dev = vlan_dev_priv(real_dev)->real_dev;
> +	}
> +
> +	return subclass;
> +}
> +
>  static int vlan_dev_init(struct net_device *dev)
>  {
>  	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
> -	int subclass = 0, i;
> +	int subclass, i;
>  
>  	netif_carrier_off(dev);
>  
> @@ -604,9 +616,7 @@ static int vlan_dev_init(struct net_device *dev)
>  
>  	SET_NETDEV_DEVTYPE(dev, &vlan_type);
>  
> -	if (is_vlan_dev(real_dev))
> -		subclass = 1;
> -
> +	subclass = vlan_calculate_locking_subclass(real_dev);
>  	vlan_dev_set_lockdep_class(dev, subclass);
>  
>  	vlan_dev_priv(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
> 
> .
> 
