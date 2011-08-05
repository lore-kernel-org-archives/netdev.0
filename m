From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv3] Bridge: Always send NETDEV_CHANGEADDR up on br MAC
 change.
Date: Thu, 4 Aug 2011 21:36:05 -0700
Message-ID: <20110804213605.31be6131@nehalam.ftrdhcpuser.net>
References: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
	<1312510625-26596-2-git-send-email-andreiw@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrei Warkentin <andreiw@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54106 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab1HEEf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 00:35:57 -0400
In-Reply-To: <1312510625-26596-2-git-send-email-andreiw@motorola.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Aug 2011 21:17:05 -0500
Andrei Warkentin <andreiw@motorola.com> wrote:

Half ok, half not.

> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index cf09fe5..ef18070 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -162,6 +162,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
>  	br->flags |= BR_SET_MAC_ADDR;
>  	spin_unlock_bh(&br->lock);
>  
> +	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>  	return 0;
>  }

This is unnecessary since already done by dev_set_mac_address.

> @@ -492,10 +493,13 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>  	del_nbp(p);
>  
>  	spin_lock_bh(&br->lock);
> -	br_stp_recalculate_bridge_id(br);
> +	changed_addr = br_stp_recalculate_bridge_id(br);
>  	br_features_recompute(br);
>  	spin_unlock_bh(&br->lock);
>  
> +	if (changed_addr)
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
> +
>  	return 0;
>  }
>  
Good, I forgot that case.

> diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
> index 404d4e1..651eac3 100644
> --- a/net/bridge/br_notify.c
> +++ b/net/bridge/br_notify.c
> @@ -34,6 +34,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
>  	struct net_device *dev = ptr;
>  	struct net_bridge_port *p = br_port_get(dev);
>  	struct net_bridge *br;
> +	bool changed_addr;
>  	int err;
>  
>  	/* not a port of a bridge */
> @@ -51,8 +52,11 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
>  	case NETDEV_CHANGEADDR:
>  		spin_lock_bh(&br->lock);
>  		br_fdb_changeaddr(p, dev->dev_addr);
> -		br_stp_recalculate_bridge_id(br);
> +		changed_addr = br_stp_recalculate_bridge_id(br);
>  		spin_unlock_bh(&br->lock);
> +
> +		if (changed_addr)
> +			call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
>  		break;
>  
>  	case NETDEV_CHANGE:

This is also fine.

> iff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index c0990ba..4528e9a 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
>  
>  	/* user has chosen a value so keep it */
>  	if (br->flags & BR_SET_MAC_ADDR)
> -		return;
> +		return false;
>  
>  	list_for_each_entry(p, &br->port_list, list) {
>  		if (addr == br_mac_zero ||

This is already in net-next.




