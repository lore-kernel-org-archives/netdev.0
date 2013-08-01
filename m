From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v2] sis900: Fix the tx queue timeout issue
Date: Thu, 1 Aug 2013 15:50:51 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015E5576@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375340470-2126-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"venza@brownhat.org" <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.188] ([216.32.180.188]:38038 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755957Ab3HAPyg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 11:54:36 -0400
In-Reply-To: <1375340470-2126-1-git-send-email-kda@linux-powerpc.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, August 01, 2013 at 3:01 PM, Denis Kirjanov wrote:

> @@ -1613,9 +1613,12 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
> 	unsigned int  count_dirty_tx;
> 
> 	/* Don't transmit data before the complete of auto-negotiation */
> -	if(!sis_priv->autong_complete){
> -		netif_stop_queue(net_dev);
> -		return NETDEV_TX_BUSY;
> +	if (unlikely(!sis_priv->autong_complete)) {
> +		if (netif_msg_tx_err(sis_priv) && net_ratelimit())
> +			netdev_dbg(net_dev, "Auto negotiation in progress\n");
> +		net_dev->stats.tx_dropped++;
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
>  	}

I always insist on that tx queue timeout is caused by un-correctly phy link handler flow.
The link up handler flow: Auto-negotiation done-> netif_carrier_on()
 
The issue cannot be processed in xmit callback, which must be handled in link adjust process.

Thanks,
Andy
