From: David Miller <davem@davemloft.net>
Subject: Re: IGMP sent to Foreign VLAN
Date: Tue, 07 Oct 2008 16:07:02 -0700 (PDT)
Message-ID: <20081007.160702.189194318.davem@davemloft.net>
References: <1223322707.24688.46.camel@deepthought.nh.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: j.neuner@networkharbor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35467
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754295AbYJGXH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:07:27 -0400
In-Reply-To: <1223322707.24688.46.camel@deepthought.nh.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Neuner <j.neuner@networkharbor.com>
Date: Mon, 6 Oct 2008 14:51:47 -0500

> I noticed a problem where the kernel is not responding to IGMP Queries
> from several Level-3 network switches.  This behavior is caused by these
> switches using VLAN tags on IGMP messages.  At first I thought the
> switches were out of spec, but every other network stack I've checked
> delivers packets with unconfigured VLAN assignments directly to the
> incoming interface.  
> 
> This patch corrects my problem, but I'm still interested in discussion
> about whether or not this should be a parameter in /proc/sys/net or even
> if this policy change should be applied elsewhere in the the network
> stack.

Interesting.

Patrick, any opinion?

> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 4bf014e..b65a8fd 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -158,9 +158,13 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
>         rcu_read_lock();
>         skb->dev = __find_vlan_dev(dev, vlan_id);
>         if (!skb->dev) {
> -               pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
> +               pr_debug("%s: WARNING: Forwarding VID: %u to dev: %s\n",
>                          __func__, vlan_id, dev->name);
> -               goto err_unlock;
> +               skb->dev = dev;
> +               skb_pull_rcsum(skb, VLAN_HLEN);
> +               vlan_set_encap_proto(skb, vhdr);
> +               rcu_read_lock();
> +               return 0;
>         }
> 
>         skb->dev->last_rx = jiffies;
> 
> 
