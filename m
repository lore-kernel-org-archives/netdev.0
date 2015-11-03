From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 03 Nov 2015 08:37:24 -0800
Message-ID: <1446568644.23275.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151101.155859.1206189858863918018.davem@davemloft.net>
	 <BY2PR0301MB16547E3AA4FB1F1AC8DE28ECA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
	 <20151103.103319.1465681990237533576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33192 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbbKCQh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:37:27 -0500
Received: by pabfh17 with SMTP id fh17so22871864pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 08:37:26 -0800 (PST)
In-Reply-To: <20151103.103319.1465681990237533576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 10:33 -0500, David Miller wrote:
> From: KY Srinivasan <kys@microsoft.com>
> Date: Tue, 3 Nov 2015 07:59:36 +0000
> 
> > I have implemented the scheme we had discussed a few weeks ago. In
> > this new implementation our driver is NOT requesting addition
> > headroom - rndis header and the per packet state is being maintained
> > outside of the skb. What I am seeing is that when I have
> > LL_MAX_HEADER set to 220 bytes, even though our driver is not using
> > the additional head room, I see about a 10% boost in the peak
> > performance (about 34 Gbps on a 40Gbps interface). However, when I
> > set the LL_MAX_HEADER value to the current default, the peak
> > performance drops back to what we currently have (around 31
> > Gbps). In both these cases, there is no reallocation of skb since no
> > additional headroom is being requested and yet there is a
> > significant difference in performance.  I trying to figure out why
> > this is the case, your insights will be greatly appreciated.
> 
> It probably has something to do with cache line or data alignment.

This also might be because of a slight change in skb->truesize, and/or
a change of amount of payload in skb->head

(Increasing LL_MAX_HEADER is reducing amount of payload in skb->head)

Can't you run perf tool to get some precise profiling ?


Another red flag in you driver xmit is :

return (ret == -EAGAIN) ? NETDEV_TX_BUSY : NETDEV_TX_OK;


extract from include/linux/netdevice.h
 * netdev_tx_t (*ndo_start_xmit)(struct sk_buff *skb,
 *                               struct net_device *dev);
 *      Called when a packet needs to be transmitted.
 *      Returns NETDEV_TX_OK.  Can return NETDEV_TX_BUSY, but you should stop
 *      the queue before that can happen; it's for obsolete devices and weird
 *      corner cases, but the stack really does a non-trivial amount
 *      of useless work if you return NETDEV_TX_BUSY.
