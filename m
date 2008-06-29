From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Add missing skb->dev assignment in Frame Relay RX code
Date: Sun, 29 Jun 2008 23:10:11 +0200
Message-ID: <m3od5kaqx8.fsf@maximus.localdomain>
References: <m3wsk8aupw.fsf@maximus.localdomain>
	<20080629130420.62d00d59@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37649 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbYF2VKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 17:10:13 -0400
In-Reply-To: <20080629130420.62d00d59@extreme> (Stephen Hemminger's message of "Sun\, 29 Jun 2008 13\:04\:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

>> --- a/drivers/net/wan/hdlc_fr.c
>> +++ b/drivers/net/wan/hdlc_fr.c
>> @@ -1008,6 +1008,7 @@ static int fr_rx(struct sk_buff *skb)
>>  		stats->rx_bytes += skb->len;
>>  		if (pvc->state.becn)
>>  			stats->rx_compressed++;
>> +		skb->dev = dev;
>>  		netif_rx(skb);
>>  		return NET_RX_SUCCESS;
>>  	} else {
>
> Better to use netdev_alloc_skb for receive buffers instead.
> --- a/drivers/net/wan/hdlc_fr.c	2008-06-29 13:02:42.000000000 -0700
> +++ b/drivers/net/wan/hdlc_fr.c	2008-06-29 13:04:01.000000000 -0700
> @@ -515,7 +515,7 @@ static void fr_lmi_send(struct net_devic
>  		}
>  	}
>  
> -	skb = dev_alloc_skb(len);
> +	skb = netdev_alloc_skb(dev, len);
>  	if (!skb) {
>  		printk(KERN_WARNING "%s: Memory squeeze on fr_lmi_send()\n",
>  		       dev->name);

Well, no, that's another story - the missing assignment is in fr_rx(),
in the regular receive path (similar to 802.1q case, ethX ->
ethX.VLAN_ID transition). I.e., we get incoming packet from a hardware
driver, with skb->dev pointing to hardware hdlcX device, and we change
it to point to a logical pvcX device.

fr_lmi_send() is for control messages (generated locally) only, in TX
path. IOW we alloc skb and send it through hw driver immediately. Not
related to the bug.

That said, perhaps I should indeed use netdev_alloc_skb() for those
control messages? Or is it RX-only?
-- 
Krzysztof Halasa
