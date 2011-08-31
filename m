From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: RFC - should network devices trim frames > soft mtu
Date: Wed, 31 Aug 2011 15:27:31 -0700
Message-ID: <1314829651.9556.37.camel@HP1>
References: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4990 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756836Ab1HaWfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 18:35:20 -0400
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
> 

I guess the reasoning is that we program the RX MTU in our chip to
automatically discard packets bigger than the RX MTU and count them as
over-size packets.  We add 4 bytes to the RX MTU to account for the VLAN
tag which may be stripped or not stripped by the chip depending on
settings.  The extra 4 bytes in the RX MTU setting will allow over-size
packets by up to 4 bytes to get through.

I agree we should move this to the next level.
