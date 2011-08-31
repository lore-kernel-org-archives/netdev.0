From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC - should network devices trim frames > soft mtu
Date: Wed, 31 Aug 2011 23:45:28 +0100
Message-ID: <1314830728.3274.52.camel@bwh-desktop>
References: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14062 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab1HaWpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 18:45:31 -0400
In-Reply-To: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 15:18 -0700, Stephen Hemminger wrote:
> I noticed the following in the bnx2 driver.
> 
> 
> static int
> bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
> {
> ...
> 		skb->protocol = eth_type_trans(skb, bp->dev);
> 
> 		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
> 			(ntohs(skb->protocol) != 0x8100)) {
> 
> 			dev_kfree_skb(skb);
> 			goto next_rx;
> 
> 		}
> 
> This means that for non-VLAN tagged frames, the device drops received
> packets if the length is greater than the MTU.  I don't see that in
> other devices. What is the correct method? IMHO the bnx2 driver is
> wrong here and if the policy is desired it should be enforced at
> the next level (netif_receive_skb).  Hardcoding a protocol value is
> kind of a giveaway that something is fishy.

According to netdevices.txt:

"MTU is symmetrical and applies both to receive and transmit.  ...
The device may either: drop, truncate, or pass up oversize packets, but
dropping oversize packets is preferred."

I believe UNH interop tests expect that MRU = MTU and oversize packets
are dropped.  However, I seem to recall that David has said more
recently that it's preferable to always use the maximum possible MRU if
DMA scatter is supported (so that this doesn't require page allocations
of order > 0).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
