From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 16 Mar 2015 14:26:13 -0700
Message-ID: <55074A75.1080604@gmail.com>
References: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com, davem@davemloft.net, sfeldma@gmail.com,
	jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34950 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbbCPV0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 17:26:50 -0400
Received: by pdbop1 with SMTP id op1so69085281pdb.2
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 14:26:50 -0700 (PDT)
In-Reply-To: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/03/15 10:32, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
> 
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
> direct bridge ports can be stacked netdevices (like bonds
> and team of switch ports) which may not imeplement this ndo.
> 
> v2 to v3:
> 	- remove changes to bond and team. Bring back the
> 	transparently following lowerdevs like i initially
> 	had for setlink/getlink
> 	(http://www.spinics.net/lists/netdev/msg313436.html)
> 	dave and scott feldman also seem to prefer it be that
> 	way and move to non-transparent way of doing things
> 	if we see a problem down the lane.
> 
> v3 to v4:
> 	- fix ret initialization

The changelog should be after "---" otherwise it will get included in
the final git commit, we don't want that as this changelog only makes
sense during the submission process.

> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/switchdev/switchdev.c |   20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index c9bfa00..e593b59 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -47,11 +47,23 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>  int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>  {
>  	const struct swdev_ops *ops = dev->swdev_ops;
> +	struct net_device *lower_dev;
> +	struct list_head *iter;
> +	int ret = -EOPNOTSUPP, err;
>  
> -	if (!ops || !ops->swdev_port_stp_update)
> -		return -EOPNOTSUPP;
> -	WARN_ON(!ops->swdev_parent_id_get);
> -	return ops->swdev_port_stp_update(dev, state);
> +	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +		return ret;
> +
> +	if (ops && ops->swdev_port_stp_update)
> +		return ops->swdev_port_stp_update(dev, state);
> +
> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +		err = netdev_switch_port_stp_update(lower_dev, state);
> +		if (err && err != -EOPNOTSUPP)
> +			ret = err;
> +	}
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
>  
> 


-- 
Florian
