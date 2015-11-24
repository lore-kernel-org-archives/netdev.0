From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 2/6] net: Add a generic udp_offload_get_port function
Date: Mon, 23 Nov 2015 22:37:35 -0800
Message-ID: <565405AF.9060302@gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-3-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35684 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbKXGhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 01:37:36 -0500
Received: by pacej9 with SMTP id ej9so11846020pac.2
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 22:37:36 -0800 (PST)
In-Reply-To: <1448312579-159544-3-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2015 01:02 PM, Anjali Singhai Jain wrote:
> The new function udp_offload_get_port replaces vxlan_get_rx_port().
> This is a generic function that will help replay all udp tunnel ports
> irrespective of tunnel type.
> This way when new udp tunnels get added this function need not change.
>
> Note: Drivers besides i40e are compile tested with this change.
>
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> ---

[...]

> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index f938616..8597020 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -290,6 +290,33 @@ unlock:
>   }
>   EXPORT_SYMBOL(udp_del_offload);
>
> +void udp_offload_get_port(struct net_device *dev)
> +{
> +	struct udp_offload_priv __rcu **head;
> +	struct udp_offload_priv *uo_priv;
> +	struct udp_offload *uo;
> +
> +	if (udp_offload_base)
> +		head = &udp_offload_base;
> +	else
> +		return;
> +
> +	spin_lock(&udp_offload_lock);
> +	uo_priv = udp_deref_protected(*head);
> +	for (; uo_priv != NULL; uo_priv = udp_deref_protected(*head)) {
> +		/* call the right add port */
> +		uo = uo_priv->offload;
> +		if (uo && dev->netdev_ops->ndo_add_udp_tunnel_port)
> +			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
> +							uo->family,
> +							uo->port,
> +							uo->tunnel_type);
> +		head = &uo_priv->next;
> +	}
> +	spin_unlock(&udp_offload_lock);
> +}
> +EXPORT_SYMBOL(udp_offload_get_port);
> +
>   struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>   				 struct udphdr *uh)
>   {
>

So when I got to patch 5 I realized this approach is horribly broken for 
IPv6 tunnels.  The udp_offload_base is only populated if the family is 
AF_INET.  What do you guys plan to do to get support for AF_INET6?

You probably ought to look at something like what ended up being done 
for the IOAT stuff.  What you end up needing is to support the drivers 
querying for what ports are active, and receiving notifications of 
tunnel updates, and the tunnel side that will register some 
functionality allowing the active ports for a given tunnel type to be 
queried.

- Alex
