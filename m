From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 17:43:12 -0700 (PDT)
Message-ID: <20120723.174312.898352203879290533.davem@davemloft.net>
References: <20120723.160541.184307938805782289.davem@davemloft.net>
	<20120723.161446.36265037346365173.davem@davemloft.net>
	<alpine.LFD.2.00.1207240226340.2633@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681Ab2GXAnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 20:43:15 -0400
In-Reply-To: <alpine.LFD.2.00.1207240226340.2633@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 24 Jul 2012 03:24:38 +0300 (EEST)

> On Mon, 23 Jul 2012, David Miller wrote:
> 
>> Hmmm, the problem is that when we decapsulate VLAN devices, we're left
>> with the parent device's index in skb->skb_iif.
> 
> 	Not sure if it is a problem with VLANs, can be also
> with some virtual devices but may be they use dev_forward_skb()
> where skb_iif is zeroed.

dev_forward_skb() gives the packet to netif_rx() which will thus send
the packet down to __netif_receive_skb() which will set the
skb->skb_iif to the new device's ifindex.  It will not stay at zero
:-)

> 	I was also worrying about ip_mc_output looping packets with
> skb_iif because skb_clone copies the field but may be such loops
> happen only for locally originated traffic where skb_iif starts with
> 0.

Loopback of multicast packets is done in ip_mc_output(), via
the clone that you mention, via dev_loopback_xmit().

dev_loopback_xmit() gives the packet to netif_rx_ni() which again
lands it back at __netif_receive_skb(), which (with my changes)
will adjust the skb->skb_iif to match whatever sits in skb->dev
at the time.

It should be alright.
