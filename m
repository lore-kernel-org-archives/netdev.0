From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 RFC net-next 2/4] sunvnet: Use RCU to synchronize port
 usage with vnet_port_remove()
Date: Wed, 15 Oct 2014 12:53:42 -0400
Message-ID: <543EA696.3010607@oracle.com>
References: <20141015164303.GC11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	davem@davemloft.net, bob.picco@oracle.com, dwight.engen@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39433 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaJOQxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:53:47 -0400
In-Reply-To: <20141015164303.GC11840@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/15/2014 12:43 PM, Sowmini Varadhan wrote:

>  
> @@ -1000,6 +1003,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
...
>  #if IS_ENABLED(CONFIG_IPV6)
> -		else if (skb->protocol == htons(ETH_P_IPV6))
> +		else if (skb->protocol == htons(ETH_P_IPV6)) {
> +			rcu_read_unlock();
>  			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, localmtu);
> +		}
>  #endif
>  		goto out_dropped;
>  	}

I don't think you want this one; "out_dropped" does this already:


>  
>  out_dropped:
...
>  		del_timer(&port->clean_timer);
> +	if (port)
> +		rcu_read_unlock();
> +	if (skb)
> +		dev_kfree_skb(skb);
> +	vnet_free_skbs(freeskbs);
>  	dev->stats.tx_dropped++;
>  	return NETDEV_TX_OK;
>  }


					+-DLS
