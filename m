From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Fri, 12 Feb 2010 12:03:40 -0700
Message-ID: <20100212190340.GB20231@esk.cs.usu.edu>
References: <20091210231103.GA20231@esk.cs.usu.edu>
 <4B218E36.4030808@gmail.com>
 <20091215172119.GF20231@esk.cs.usu.edu>
 <4B27E4A1.4050802@gmail.com>
 <20100210205048.GT20231@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:42876 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829Ab0BLTDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 14:03:41 -0500
Content-Disposition: inline
In-Reply-To: <20100210205048.GT20231@esk.cs.usu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Feb 10 13:50-0700, Eldon Koyle wrote:
<snip>
> I am now trying 2.6.32.7 with the in-tree ixgbe driver.  I am still
> seeing some unusual behavior when bridging VLAN interfaces.  It looks
> like there is an off-by-one error in the mapping from rx queue to tx
> queue (ie. packets are sent on <rx queue number>-1 instead of using the
> same rx and tx queue number).
> 
> Any idea what might cause this?

Looking at the code, we are having difficulty finding the problem.  I
think we did find an accounting error in the vlan code, though.

In net/8021q/vlan_dev.c:

static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
                                            struct net_device *dev)
{
        int i = skb_get_queue_mapping(skb);
        struct netdev_queue *txq = netdev_get_tx_queue(dev, i);      
...
        if (likely(ret == NET_XMIT_SUCCESS)) {
                txq->tx_packets++;
                txq->tx_bytes += len;
        } else
                txq->tx_dropped++;
...
}

skb_get_queue_mapping returns skb->queue_mapping, which is rx_queue + 1
or 0 for unset.

Does dev->_tx[0] have some special meaning, or is this wrong?

-- 
Eldon Koyle
-- 
I have a theory that it's impossible to prove anything, but I can't prove it.
