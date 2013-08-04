From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net 1/2] vlan: make vlan_dev_real_dev work over stacked
 vlans
Date: Sun, 04 Aug 2013 04:17:43 +0200
Message-ID: <51FDB9C7.4090703@redhat.com>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vfalico@redhat.com, fubar@us.ibm.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405Ab3HDCRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 22:17:50 -0400
In-Reply-To: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 10:07 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> Sometimes we might have stacked vlans on top of each other, and we're
> interested in the first non-vlan real device on the path, so transform
> vlan_dev_real_dev to go over the stacked vlans and extract the first
> non-vlan device.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>  net/8021q/vlan_core.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 4a78c4d..6ee48aa 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -91,7 +91,12 @@ EXPORT_SYMBOL(__vlan_find_dev_deep);
>  
>  struct net_device *vlan_dev_real_dev(const struct net_device *dev)
>  {
> -	return vlan_dev_priv(dev)->real_dev;
> +	struct net_device *ret = vlan_dev_priv(dev)->real_dev;
> +
> +	while (is_vlan_dev(ret))
> +		ret = vlan_dev_priv(ret)->real_dev;
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL(vlan_dev_real_dev);
>  
> 
I have one question - why not make it possible to call vlan_dev_real_dev()
with any device (vlan/non-vlan) and make it return a real device in all
cases (e.g. if it's a non-vlan device simply return it) ?
In the terms of the code above - simply change:
struct net_device *ret = vlan_dev_priv(dev)->real_dev;
with
struct net_device *ret = dev;

This way we'll be able to simplify calls like if (is_vlan_dev(dev)) (or the
flag check alternative of this) to just vlan_dev_real_dev(). The old call
sites of this function will still work properly.

Nik
