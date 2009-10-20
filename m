From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 14:10:13 -0700
Message-ID: <4ADE2735.9000807@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51946 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbZJTVKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 17:10:13 -0400
In-Reply-To: <4ADE0770.8060708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2009 11:54 AM, Eric Dumazet wrote:

> -	queue_map = skb_get_queue_mapping(pkt_dev->skb);
> +	queue_map = pkt_dev->cur_queue_map;
> +	/*
> +	 * tells skb_tx_hash() to use this tx queue.
> +	 * We should reset skb->mapping before each xmit() because
> +	 * xmit() might change it.
> +	 */
> +	skb_record_rx_queue(pkt_dev->skb, queue_map);
>   	txq = netdev_get_tx_queue(odev, queue_map);

I think that must be wrong.  The record_rx_queue sets it to queue_map + 1,
but the hard-start-xmit method (in ixgbe/ixgbe_main.c, at least), takes the
skb->queue_map and uses it as an index with no subtraction.

This causes watchdog timeouts because we are calling txq_trans_update in pktgen on
queue 0, for instance, but sending pkts on queue 1.  If queue 1 is ever
busy when the WD fires, link is reset.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

