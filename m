From: David Miller <davem@davemloft.net>
Subject: TX pre-headers...
Date: Fri, 06 Feb 2009 01:41:07 -0800 (PST)
Message-ID: <20090206.014107.231141422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751986AbZBFJlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:41:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A9984C8CA74
	for <netdev@vger.kernel.org>; Fri,  6 Feb 2009 01:41:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some NIC hardware wants a pre-header pushed in front of the packet
data on transmit.

When routing or bridging this will cause a reallocation of skb->data
on every packet forwarded because there will only be NET_IP_ALIGN
space reserved at the head by the device receive path.

NIU is one such NIC and I only noticed this because of some things I
saw in some of Robert Olsson's routing stress test oprofile dumps.

Putting a hack into NIU is the wrong way to do this and would only fix
cases where NIU is the receiver and transmitting device. e1000 to
NIU would still be broken, for example.

I think the way to solve this is to have each device indicate how
much TX slack space it neads for it's preheaders.  On device
registration we have some global "netdev_max_tx_hdr_space" that
records the maximum value seen.

We could decrease it on unregister (by walking the device list)
but I don't think that is worth it.

We also round netdev_max_tx_hdr_space up to be a multiple of 4
or something reasonable like that.

Then we get drivers to use a new interface:

	struct sk_buff *netdev_alloc_rx_skb(struct net_device *dev, int size);

which is nearly identical to netdev_alloc_skb() except that it does:

	size += NET_IP_ALIGN + netdev_max_tx_hdr_space;
	skb = netdev_alloc_skb(dev, size);
	if (skb)
		skb_reserve(skb, NET_IP_ALIGN + netdev_max_tx_hdr_space);
	return skb;

Seems reasonable?
