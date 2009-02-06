From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: TX pre-headers...
Date: Fri, 06 Feb 2009 13:02:13 +0100
Message-ID: <498C26C5.7010003@linux.vnet.ibm.com>
References: <20090206.014107.231141422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:55045 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbZBFMDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 07:03:06 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id n16C2Fg4568106
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 12:02:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n16C2ETq1130634
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 12:02:14 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n16C2EIh031170
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 12:02:14 GMT
In-Reply-To: <20090206.014107.231141422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:
> Some NIC hardware wants a pre-header pushed in front of the packet
> data on transmit.
> 
> When routing or bridging this will cause a reallocation of skb->data
> on every packet forwarded because there will only be NET_IP_ALIGN
> space reserved at the head by the device receive path.
> 
> NIU is one such NIC and I only noticed this because of some things I
> saw in some of Robert Olsson's routing stress test oprofile dumps.
> 
> Putting a hack into NIU is the wrong way to do this and would only fix
> cases where NIU is the receiver and transmitting device. e1000 to
> NIU would still be broken, for example.
> 
> I think the way to solve this is to have each device indicate how
> much TX slack space it neads for it's preheaders.  On device
> registration we have some global "netdev_max_tx_hdr_space" that
> records the maximum value seen.
> 
> We could decrease it on unregister (by walking the device list)
> but I don't think that is worth it.
> 
> We also round netdev_max_tx_hdr_space up to be a multiple of 4
> or something reasonable like that.
> 
> Then we get drivers to use a new interface:
> 
> 	struct sk_buff *netdev_alloc_rx_skb(struct net_device *dev, int size);
> 
> which is nearly identical to netdev_alloc_skb() except that it does:
> 
> 	size += NET_IP_ALIGN + netdev_max_tx_hdr_space;
> 	skb = netdev_alloc_skb(dev, size);
> 	if (skb)
> 		skb_reserve(skb, NET_IP_ALIGN + netdev_max_tx_hdr_space);
> 	return skb;
> 
> Seems reasonable?
Absolutely yes, this would help the s/390 qeth drivers too
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


