From: Stephen Hemminger <shemminger@vyatta.com>
Subject: RFC - should network devices trim frames > soft mtu
Date: Wed, 31 Aug 2011 15:18:23 -0700
Message-ID: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994Ab1HaWSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 18:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed the following in the bnx2 driver.


static int
bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
{
...
		skb->protocol = eth_type_trans(skb, bp->dev);

		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
			(ntohs(skb->protocol) != 0x8100)) {

			dev_kfree_skb(skb);
			goto next_rx;

		}

This means that for non-VLAN tagged frames, the device drops received
packets if the length is greater than the MTU.  I don't see that in
other devices. What is the correct method? IMHO the bnx2 driver is
wrong here and if the policy is desired it should be enforced at
the next level (netif_receive_skb).  Hardcoding a protocol value is
kind of a giveaway that something is fishy.
